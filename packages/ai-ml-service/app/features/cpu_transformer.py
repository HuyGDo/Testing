import logging
import pandas as pd
from sqlalchemy import text
from app.core.db import engine # Assuming engine is configured and available

# --- Standard library logging setup ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


def _calculate_cpu_features(df: pd.DataFrame, metric_name: str) -> list[dict]:
    """
    Calculates features and transforms them into a narrow format for the 'features' table.
    
    Args:
        df: A pandas DataFrame with columns ['bucket', 'vm_id', 'cpu_util_pct'].
        metric_name: The name of the metric being processed (e.g., 'cpu_util_pct').

    Returns:
        A list of dictionaries, where each dictionary is a single feature value
        ready to be inserted into the 'features' table.
    """
    if df.empty:
        return []

    df['bucket'] = pd.to_datetime(df['bucket'])
    df = df.set_index('bucket')

    # Calculate rolling features per VM
    features_df = df.groupby('vm_id')['cpu_util_pct'] \
                    .rolling(window=5, min_periods=1) \
                    .agg(['mean', 'std']) \
                    .reset_index() \
                    .rename(columns={"level_1": "ts"}) # Use 'ts' to match the features table

    features_df = features_df.fillna(0.0)

    # Melt the DataFrame from wide to long/narrow format
    melted_df = features_df.melt(
        id_vars=['ts', 'vm_id'],
        value_vars=['mean', 'std'],
        var_name='feature_name_suffix',
        value_name='value'
    )

    # Construct the full feature name
    melted_df['metric_name'] = metric_name
    melted_df['feature_name'] = metric_name + '_' + melted_df['feature_name_suffix'] + '_5m'
    
    # Drop the temporary suffix column and return records
    return melted_df[['ts', 'vm_id', 'metric_name', 'feature_name', 'value']].to_dict('records')


def run_cpu_feature_engineering_batch():
    """
    Runs a single, atomic batch of the idempotent feature engineering process,
    adapted for the narrow 'features' table schema.
    """
    logger.info("Running CPU feature engineering batch...")
    metric_name = 'cpu_util_pct'

    with engine.begin() as conn:
        try:
            # Step 1: Lock and get watermark (unchanged)
            last_done = conn.execute(text("""
                SELECT last_bucket FROM fe_progress WHERE metric_name = :metric_name FOR UPDATE
            """), {"metric_name": metric_name}).scalar_one()
            logger.info(f"Watermark for '{metric_name}' is at: {last_done}")

            # Step 2: Fetch new data (unchanged)
            raw_data_result = conn.execute(text("""
                SELECT bucket, vm_id, cpu_util_pct
                FROM   metrics_wide
                WHERE  bucket > :last_done
                  AND  bucket <= now() - INTERVAL '1 minute'
                ORDER BY bucket, vm_id
            """), {"last_done": last_done}).fetchall()

            if not raw_data_result:
                logger.info("No new finalized data to process.")
                return

            logger.info(f"Fetched {len(raw_data_result)} new rows to process.")

            # Step 3: Transform raw data into features (updated logic)
            df = pd.DataFrame(raw_data_result, columns=['bucket', 'vm_id', 'cpu_util_pct'])
            feature_rows = _calculate_cpu_features(df, metric_name)

            if not feature_rows:
                logger.warning("Feature engineering resulted in zero rows; skipping DB writes.")
                return

            # Step 4: Idempotently UPSERT into the new 'features' table
            upsert_stmt = text("""
                INSERT INTO features (ts, vm_id, metric_name, feature_name, value)
                VALUES (:ts, :vm_id, :metric_name, :feature_name, :value)
                ON CONFLICT (ts, vm_id, metric_name, feature_name) DO UPDATE
                SET value = EXCLUDED.value;
            """)
            conn.execute(upsert_stmt, feature_rows)
            logger.info(f"Upserted {len(feature_rows)} feature rows into 'features'.")

            # Step 5: Advance the watermark (updated to use 'ts' from feature rows)
            new_watermark = max(row['ts'] for row in feature_rows)
            conn.execute(text("""
                UPDATE fe_progress SET last_bucket = :new_watermark WHERE metric_name = :metric_name
            """), {"new_watermark": new_watermark, "metric_name": metric_name})
            
            logger.info(f"Advanced watermark for '{metric_name}' to {new_watermark}")

        except Exception as e:
            logger.error(f"Transaction failed, will be rolled back. Error: {e}", exc_info=True)
            raise

    logger.info("CPU feature engineering batch finished successfully.")
