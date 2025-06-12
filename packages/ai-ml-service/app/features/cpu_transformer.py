import logging
import pandas as pd
from sqlalchemy import text
from app.core.db import engine

# --- Standard library logging setup ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class CpuFeatureTransformer:
    """
    A class to handle the feature engineering process for CPU metrics
    in a robust, idempotent, and worker-friendly manner.
    """
    def __init__(self, metric_name='cpu_util_pct'):
        self.metric_name = metric_name

    def _calculate_features(self, df: pd.DataFrame) -> list[dict]:
        """
        Calculates rolling features from a DataFrame and transforms them into a
        narrow format suitable for the 'features' table.
        """
        if df.empty:
            return []

        df['bucket'] = pd.to_datetime(df['bucket'])
        df = df.set_index('bucket')

        # Calculate rolling features per VM
        features_df = df.groupby('vm_id')[self.metric_name] \
                        .rolling(window=5, min_periods=1) \
                        .agg(['mean', 'std']) \
                        .reset_index()

        # --- THE FIX IS HERE ---
        # The column created from the time index is named 'bucket', not 'level_1'.
        # We rename it to 'ts' to match the schema of the 'features' table.
        features_df.rename(columns={'bucket': 'ts'}, inplace=True)

        features_df = features_df.fillna(0.0)

        # Melt the DataFrame from wide to long/narrow format.
        # This will now succeed because the 'ts' column exists.
        melted_df = features_df.melt(
            id_vars=['ts', 'vm_id'],
            value_vars=['mean', 'std'],
            var_name='feature_name_suffix',
            value_name='value'
        )

        melted_df['metric_name'] = self.metric_name
        melted_df['feature_name'] = self.metric_name + '_' + melted_df['feature_name_suffix'] + '_5m'
        
        return melted_df[['ts', 'vm_id', 'metric_name', 'feature_name', 'value']].to_dict('records')

    def run_batch(self):
        """
        Runs a single, atomic batch of the feature engineering process.
        """
        logger.info(f"Running feature engineering batch for '{self.metric_name}'...")

        with engine.begin() as conn:
            try:
                # Step 1: Lock and get watermark
                last_done = conn.execute(text("""
                    SELECT last_bucket FROM fe_progress WHERE metric_name = :metric_name FOR UPDATE
                """), {"metric_name": self.metric_name}).scalar_one()
                logger.info(f"Watermark for '{self.metric_name}' is at: {last_done}")

                # Step 2: Fetch new data finalized for processing
                raw_data_result = conn.execute(text(f"""
                    SELECT bucket, vm_id, {self.metric_name}
                    FROM   metrics_wide
                    WHERE  bucket > :last_done
                      AND  bucket <= now() - INTERVAL '1 minute'
                    ORDER BY bucket, vm_id
                """), {"last_done": last_done}).fetchall()

                if not raw_data_result:
                    logger.info("No new finalized data to process.")
                    return

                logger.info(f"Fetched {len(raw_data_result)} new rows to process.")

                # Step 3: Transform raw data into features
                df = pd.DataFrame(raw_data_result, columns=['bucket', 'vm_id', self.metric_name])
                feature_rows = self._calculate_features(df)

                if not feature_rows:
                    logger.warning("Feature engineering resulted in zero feature rows; skipping DB writes.")
                    return

                # Step 4: Idempotently UPSERT into the 'features' table
                upsert_stmt = text("""
                    INSERT INTO features (ts, vm_id, metric_name, feature_name, value)
                    VALUES (:ts, :vm_id, :metric_name, :feature_name, :value)
                    ON CONFLICT (ts, vm_id, metric_name, feature_name) DO UPDATE
                    SET value = EXCLUDED.value;
                """)
                conn.execute(upsert_stmt, feature_rows)
                logger.info(f"Upserted {len(feature_rows)} feature rows into 'features'.")

                # Step 5: Advance the watermark
                new_watermark = max(row['ts'] for row in feature_rows)
                conn.execute(text("""
                    UPDATE fe_progress SET last_bucket = :new_watermark WHERE metric_name = :metric_name
                """), {"new_watermark": new_watermark, "metric_name": self.metric_name})
                
                logger.info(f"Advanced watermark for '{self.metric_name}' to {new_watermark}")

            except Exception as e:
                logger.error(f"Transaction failed, will be rolled back. Error: {e}", exc_info=True)
                raise # Re-raise the exception to ensure the transaction rolls back

        logger.info(f"Feature engineering batch for '{self.metric_name}' finished successfully.")
