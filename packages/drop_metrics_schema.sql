--────────────────────────────────────────────────────────────
--  Reset schema: drop policies, view, hypertables, enum
--────────────────────────────────────────────────────────────
DO $$
BEGIN
  ----------------------------------------------------------------
  -- Remove compression policy on hypertable `metrics` if it exists
  ----------------------------------------------------------------
  IF EXISTS (
        SELECT 1
        FROM   timescaledb_information.jobs
        WHERE  hypertable_name = 'metrics'
        AND    proc_name       = 'policy_compression'
  ) THEN
        PERFORM remove_compression_policy('metrics'::regclass);
  END IF;

  ----------------------------------------------------------------
  -- Remove continuous-aggregate policy on view `metrics_wide`
  ----------------------------------------------------------------
  IF EXISTS (
        SELECT 1
        FROM   timescaledb_information.continuous_aggregates
        WHERE  view_name = 'metrics_wide'
  ) THEN
        PERFORM remove_continuous_aggregate_policy('metrics_wide');
  END IF;
END$$;

-- Drop the continuous aggregate (CASCADE removes its internal tables)
DROP MATERIALIZED VIEW IF EXISTS metrics_wide CASCADE;

-- Drop hypertables and other tables
DROP TABLE IF EXISTS features               CASCADE;
DROP TABLE IF EXISTS metrics                CASCADE;
DROP TABLE IF EXISTS prom_sd_static_targets CASCADE;
DROP TABLE IF EXISTS model_registry         CASCADE;
DROP TABLE IF EXISTS vm                     CASCADE;

-- Drop custom enum
DROP TYPE IF EXISTS model_status;
