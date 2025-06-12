import logging
import json
import pandas as pd
import time
from datetime import datetime, timezone
from app.core.db import get_db_connection
from app.core.cache import get_redis_connection
from app.services.gemini_service import gemini_service  # Import the new service
from psycopg2.extras import execute_values

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class PredictionService:
    def __init__(self):
        self.db_conn = None
        self.redis_conn = None
        self.ALLOWED_METRICS = ['cpu_util_pct', 'load_1m', 'mem_util_pct']

    def process_prediction_request(self, task_id, vm_id, metric_name, horizon_min):
        self.db_conn = get_db_connection()
        self.redis_conn = get_redis_connection()

        try:
            logger.info(f"Processing prediction request for task_id: {task_id}")
            processing_timestamp = datetime.now(timezone.utc).isoformat()

            # Determine the number of output points based on the horizon
            num_outputs, horizon_desc, features_df = self._fetch_features_and_get_params(vm_id, metric_name, horizon_min)
            
            if features_df.empty:
                raise ValueError("No features found for the given vm_id and metric_name.")

            # Use the Gemini service to get a mock prediction
            historical_values = features_df[metric_name].tolist()
            prediction_values = gemini_service.generate_mock_prediction(historical_values, num_outputs, horizon_desc)

            # Create a DataFrame for the predictions with future timestamps
            last_ts = features_df['ts'].iloc[-1]
            # Determine frequency based on horizon
            freq = '1min'
            if horizon_min > 60: freq = '5min'
            if horizon_min > 360: freq = '15min'

            future_timestamps = pd.to_datetime(pd.date_range(start=last_ts, periods=num_outputs + 1, freq=freq)[1:])
            prediction_df = pd.DataFrame({'ts': future_timestamps, 'value': prediction_values})

            self._store_prediction(task_id, vm_id, metric_name, prediction_df)

            result = {
                "status": "COMPLETED",
                "prediction": json.dumps(prediction_values),
                "timestamp": processing_timestamp
            }
            self._cache_result(task_id, result)
            self._notify_prediction_ready(vm_id, horizon_min, task_id)

            logger.info(f"Prediction successful for task_id: {task_id}")

        except Exception as e:
            logger.error(f"Prediction failed for task_id: {task_id}, error: {e}", exc_info=True)
            result = {"status": "FAILED", "error": str(e), "timestamp": datetime.now(timezone.utc).isoformat()}
            if not self.redis_conn:
                self.redis_conn = get_redis_connection()
            self._cache_result(task_id, result)

    def _fetch_features_and_get_params(self, vm_id, metric_name, horizon_min):
        logger.info(f"Fetching features for vm_id: {vm_id}, metric: {metric_name}, horizon: {horizon_min} min")

        if metric_name not in self.ALLOWED_METRICS:
            raise ValueError(f"Invalid metric_name: {metric_name}. Allowed are: {self.ALLOWED_METRICS}")

        # Determine query, output points, and description based on horizon
        if horizon_min <= 60:  # 1 hour
            query = f"""
                SELECT bucket as ts, {metric_name}
                FROM metrics_wide
                WHERE vm_id = %(vm_id)s AND {metric_name} IS NOT NULL AND bucket >= now() - INTERVAL '120 minutes'
                ORDER BY bucket ASC LIMIT 120;
            """
            num_outputs = 60
            horizon_desc = "1 hour"
        elif horizon_min <= 360:  # 6 hours
            query = f"""
                SELECT time_bucket('5 minutes', bucket) AS ts, AVG({metric_name}) AS {metric_name}
                FROM metrics_wide
                WHERE vm_id = %(vm_id)s AND {metric_name} IS NOT NULL AND bucket >= now() - INTERVAL '12 hours'
                GROUP BY ts ORDER BY ts ASC LIMIT 144;
            """
            num_outputs = 72
            horizon_desc = "6 hours"
        else:  # 24 hours
            query = f"""
                SELECT time_bucket('15 minutes', bucket) AS ts, AVG({metric_name}) AS {metric_name}
                FROM metrics_wide
                WHERE vm_id = %(vm_id)s AND {metric_name} IS NOT NULL AND bucket >= now() - INTERVAL '2 days'
                GROUP BY ts ORDER BY ts ASC LIMIT 192;
            """
            num_outputs = 96
            horizon_desc = "24 hours"
            
        df = pd.read_sql(query, self.db_conn, params={'vm_id': vm_id}, index_col=None)
        df['ts'] = pd.to_datetime(df['ts'])
        return num_outputs, horizon_desc, df

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
