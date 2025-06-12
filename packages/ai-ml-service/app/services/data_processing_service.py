# import pandas as pd
# from psycopg2.extras import execute_values
# from app.features.cpu_transformer import CpuMetricTransformer
# from app.core.db import get_db_connection
# import logging

# logging.basicConfig(level=logging.INFO)
# logger = logging.getLogger(__name__)

# def process_cpu_metrics():
#     """
#     Fetches new CPU data, creates features, and stores them in the database.
#     """
#     conn = get_db_connection()
#     if conn is None:
#         logger.error("No database connection available.")
#         return

#     try:
#         with conn.cursor() as cur:
#             cur.execute("SELECT max(ts) FROM features WHERE metric_name = 'cpu_util_pct'")
#             result = cur.fetchone()
#             last_processed_ts = result[0] if result else None

#         query = "SELECT bucket, vm_id, cpu_util_pct FROM metrics_wide WHERE cpu_util_pct IS NOT NULL"
#         if last_processed_ts:
#             query += f" AND bucket > '{last_processed_ts}'"
#         query += " ORDER BY bucket"

#         data_df = pd.read_sql(query, conn)
#         if data_df.empty:
#             logger.info("No new data to process for cpu_util_pct.")
#             return

#         data_df.rename(columns={'bucket': 'ts', 'cpu_util_pct': 'value'}, inplace=True)

#         all_features = []
#         transformer = CpuMetricTransformer()

#         for vm_id, group in data_df.groupby('vm_id'):
#             if len(group) < 48:
#                 logger.warning(f"Not enough data for vm_id {vm_id} to decompose. Need 48 points, have {len(group)}. Skipping.")
#                 continue

#             # The transformer expects 'ts' as index and a 'value' column.
#             group_for_transform = group.set_index('ts')[['value']]
#             features_df = transformer.create_features(group_for_transform)
            
#             if not features_df.empty:
#                 features_df['vm_id'] = vm_id
#                 features_df.reset_index(inplace=True)
#                 all_features.append(features_df)

#         if not all_features:
#             logger.info("No features were generated from the new data.")
#             return

#         final_features_df = pd.concat(all_features)
#         melted_df = final_features_df.melt(
#             id_vars=['ts', 'vm_id'],
#             value_vars=['trend', 'seasonal', 'resid'],
#             var_name='feature_name',
#             value_name='value'
#         )
#         melted_df['metric_name'] = 'cpu_util_pct'

#         with conn.cursor() as cur:
#             execute_values(
#                 cur,
#                 "INSERT INTO features (ts, vm_id, metric_name, feature_name, value) VALUES %s ON CONFLICT (ts, vm_id, metric_name, feature_name) DO NOTHING",
#                 [tuple(row) for row in melted_df[['ts', 'vm_id', 'metric_name', 'feature_name', 'value']].to_numpy()]
#             )
#         conn.commit()
#         logger.info(f"Inserted {len(melted_df)} new features for cpu_util_pct.")

#     except Exception as e:
#         logger.error(f"An error occurred during CPU metrics processing: {e}")
#         if conn:
#             conn.rollback()
