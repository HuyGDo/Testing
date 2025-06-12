import logging
import json
import joblib
import pandas as pd
import time
from datetime import datetime, timezone
from app.core.db import get_db_connection
from app.core.cache import get_redis_connection
from app.core.config import settings
from psycopg2.extras import execute_values

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class PredictionService:
    def __init__(self):
        # Connections will be fetched on-demand in the processing method
        # to avoid initialization order issues with the worker.
        self.db_conn = None
        self.redis_conn = None
        self.ALLOWED_METRICS = ['cpu_util_pct', 'load_1m', 'mem_util_pct']

    def process_prediction_request(self, task_id, vm_id, metric_name, horizon_min):
        # Fetch connections at the time of processing to ensure they are available
        self.db_conn = get_db_connection()
        self.redis_conn = get_redis_connection()
        
        try:
            logger.info(f"Processing prediction request for task_id: {task_id}")
            
            # Create a timestamp for when the processing starts
            processing_timestamp = datetime.now(timezone.utc).isoformat()

            if settings.TEST_MODE:
                logger.info("TEST MODE: Simulating model lookup and prediction.")
                time.sleep(3)
                dummy_prediction = [10.5, 11.2, 12.0, 11.8, 12.5]
                result = {
                    "status": "COMPLETED",
                    "prediction": json.dumps(dummy_prediction),
                    "timestamp": processing_timestamp
                }
                self._cache_result(task_id, result)
                logger.info(f"TEST MODE: Successfully simulated prediction for task_id: {task_id}")
                return

            storage_uri = self._get_model_uri(metric_name, horizon_min)
            if not storage_uri:
                logger.warning(f"Model not found for metric='{metric_name}', horizon='{horizon_min}'. Caching as FAILED for task_id: {task_id}")
                result = {"status": "FAILED", "error": "Model not found in registry.", "timestamp": processing_timestamp}
                self._cache_result(task_id, result)
                return

            model = self._load_model(storage_uri)
            
            features_df = self._fetch_features(vm_id, metric_name)
            if features_df.empty:
                raise ValueError("No features found for the given vm_id and metric_name.")

            prediction_values = model.predict(features_df) # Assuming model takes dataframe
            
            # Create a DataFrame for the predictions with future timestamps
            last_ts = features_df['bucket'].iloc[0]
            future_timestamps = pd.to_datetime(pd.date_range(start=last_ts, periods=horizon_min + 1, freq='min')[1:])
            prediction_df = pd.DataFrame({'ts': future_timestamps, 'value': prediction_values.flatten()})

            self._store_prediction(task_id, vm_id, metric_name, prediction_df)

            # Ensure prediction is JSON serializable for the cache
            result = {
                "status": "COMPLETED",
                "prediction": json.dumps(prediction_values.tolist()),
                "timestamp": processing_timestamp
            }
            self._cache_result(task_id, result)
            self._notify_prediction_ready(vm_id, horizon_min, task_id)
            
            logger.info(f"Prediction successful for task_id: {task_id}")

        except Exception as e:
            logger.error(f"Prediction failed for task_id: {task_id}, error: {e}", exc_info=True)
            result = {"status": "FAILED", "error": str(e), "timestamp": datetime.now(timezone.utc).isoformat()}
            # Ensure redis_conn is available before trying to cache the error
            if not self.redis_conn:
                self.redis_conn = get_redis_connection()
            self._cache_result(task_id, result)

    def _get_model_uri(self, metric_name, horizon_min):
        logger.info(f"Fetching model URI for metric: {metric_name}, horizon: {horizon_min}")
        # Placeholder for DB lookup
        with self.db_conn.cursor() as cur:
            cur.execute(
                """
                SELECT storage_uri FROM model_registry
                WHERE metric_name = %s AND horizon_min = %s AND is_active = TRUE
                ORDER BY created_at DESC
                LIMIT 1;
                """,
                (metric_name, horizon_min)
            )
            result = cur.fetchone()
            return result[0] if result else None

    def _load_model(self, storage_uri):
        logger.info(f"Loading model from: {storage_uri}")
        # In a real scenario, this might download from S3 etc.
        # For now, we assume it's a local path.
        return joblib.load(storage_uri)

    def _fetch_features(self, vm_id, metric_name, horizon_min):
        logger.info(f"Fetching features for vm_id: {vm_id}, metric: {metric_name}, horizon: {horizon_min}")
        
        if metric_name not in self.ALLOWED_METRICS:
            raise ValueError(f"Invalid metric_name: {metric_name}. Allowed are: {self.ALLOWED_METRICS}")

        # Choose query based on horizon, as per requirements
        if horizon_min <= 60: # 1h
            query = f"""
                SELECT bucket, {metric_name}
                FROM metrics_wide
                WHERE vm_id = %(vm_id)s
                  AND {metric_name} IS NOT NULL
                  AND bucket >= now() - INTERVAL '120 minutes'
                ORDER BY bucket DESC
                LIMIT 120;
            """
        elif horizon_min <= 360: # 6h
            query = f"""
                SELECT time_bucket('5 minutes', bucket) AS ts, AVG({metric_name}) AS {metric_name}
                FROM metrics_wide
                WHERE vm_id = %(vm_id)s
                  AND {metric_name} IS NOT NULL
                  AND bucket >= now() - INTERVAL '12 hours'
                GROUP BY ts
                ORDER BY ts DESC
                LIMIT 144; -- 12 hours / 5 min = 144 points
            """
        else: # 24h
            query = f"""
                SELECT time_bucket('15 minutes', bucket) AS ts, AVG({metric_name}) AS {metric_name}
                FROM metrics_wide
                WHERE vm_id = %(vm_id)s
                  AND {metric_name} IS NOT NULL
                  AND bucket >= now() - INTERVAL '4 days'
                GROUP BY ts
                ORDER BY ts DESC
                LIMIT 384; -- 4 days / 15 min = 384 points
            """
            
        df = pd.read_sql(query, self.db_conn, params={'vm_id': vm_id})
        
        # Reverse to get chronological order for the model
        return df.iloc[::-1]

    def _store_prediction(self, task_id, vm_id, metric_name, prediction_df):
        logger.info(f"Storing prediction in metrics_extended for task_id: {task_id}")
        with self.db_conn.cursor() as cur:
            records_to_insert = [
                (row['ts'], vm_id, metric_name, row['value'], 'predicted')
                for _, row in prediction_df.iterrows()
            ]

            # Use ON CONFLICT to UPSERT the predicted values
            execute_values(
                cur,
                """
                INSERT INTO metrics_extended (ts, vm_id, metric_name, value, type)
                VALUES %s
                ON CONFLICT (ts, vm_id, metric_name, type) DO UPDATE
                SET value = EXCLUDED.value;
                """,
                records_to_insert
            )
            self.db_conn.commit()
        logger.info(f"Successfully stored prediction for task_id: {task_id}")

    def _notify_prediction_ready(self, vm_id, horizon_min, task_id):
        channel = "prediction_events"
        message = json.dumps({
            "event": "prediction_ready",
            "vm_id": vm_id,
            "horizon_min": horizon_min,
            "task_id": task_id
        })
        logger.info(f"Publishing message to Redis channel '{channel}': {message}")
        self.redis_conn.publish(channel, message)

    def _cache_result(self, task_id, result):
        key = f"prediction:{task_id}"
        logger.info(f"Attempting to cache result for task_id: {task_id} at key: {key}")
        
        if self.redis_conn is None:
            logger.error("Redis connection is None. Cannot cache result.")
            return

        try:
            # Log connection details for debugging. This helps verify the correct DB is used.
            # In a real production environment, be careful about logging sensitive info.
            conn_kwargs = self.redis_conn.connection_pool.connection_kwargs
            logger.info(f"Using Redis connection: host={conn_kwargs.get('host')}, port={conn_kwargs.get('port')}, db={conn_kwargs.get('db')}")
            
            # The hset command returns the number of fields that were added.
            num_fields_added = self.redis_conn.hset(key, mapping=result)
            logger.info(f"Redis HSET command executed for key '{key}'. Number of new fields added: {num_fields_added}.")

            if num_fields_added == 0:
                logger.warning(f"Redis HSET command returned 0. This might mean the key already existed and all fields were updated, or the input was empty.")

        except Exception as e:
            # Added detailed exception logging, just in case.
            logger.error(f"An exception occurred while caching to Redis for key '{key}': {e}", exc_info=True)

prediction_service = PredictionService()
