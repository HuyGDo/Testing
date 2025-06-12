CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS pgcrypto;          -- for UUID generation
CREATE EXTENSION IF NOT EXISTS hstore;            -- handy for key/value VM labels

-- 1.1  Virtual Machines under management
CREATE TABLE vm (
    vm_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name          TEXT         NOT NULL,
    ip_address    INET         NOT NULL,
    labels        HSTORE       DEFAULT hstore(''),        -- arbitrary k/v tags
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX vm_labels_env_btree_idx ON vm USING BTREE ((labels -> 'env'));  -- B-tree index on env tag
-- 2.1  Narrow table fed by prom-pg-adapter
CREATE TABLE metrics (
    ts            TIMESTAMPTZ  NOT NULL,
    vm_id         UUID         NOT NULL REFERENCES vm(vm_id),
    metric_name   TEXT         NOT NULL,
    value         DOUBLE PRECISION NOT NULL,
    -- Optional Prometheus meta
    job           TEXT,
    instance      TEXT,
    PRIMARY KEY (ts, vm_id, metric_name)
);

SELECT create_hypertable('metrics', 'ts',
                         chunk_time_interval => INTERVAL '1 day',
                         create_default_indexes => FALSE);   -- we add custom ones

-- Helpful indexes / compression tags
CREATE INDEX metrics_metricname_ts_idx ON metrics (metric_name, ts DESC);
ALTER TABLE metrics SET (timescaledb.compress, timescaledb.compress_segmentby = 'vm_id,metric_name');
SELECT add_compression_policy('metrics', INTERVAL '14 days');

CREATE MATERIALIZED VIEW metrics_wide
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 minute', ts)    AS bucket,
    vm_id,
    MAX(value)      FILTER (WHERE metric_name = 'cpu_util_pct')  AS cpu_util_pct,
    MAX(value)      FILTER (WHERE metric_name = 'load_1m')       AS load_1m,
    MAX(value)      FILTER (WHERE metric_name = 'mem_util_pct')  AS mem_util_pct
FROM metrics
GROUP BY bucket, vm_id;

SELECT add_continuous_aggregate_policy('metrics_wide',
        start_offset => INTERVAL '2 hours',
        end_offset   => INTERVAL '1 minute',
        schedule_interval => INTERVAL '1 minute');

CREATE TABLE features (
    ts            TIMESTAMPTZ NOT NULL,
    vm_id         UUID        NOT NULL REFERENCES vm(vm_id),
    metric_name   TEXT        NOT NULL,
    feature_name  TEXT        NOT NULL,
    value         DOUBLE PRECISION,
    PRIMARY KEY (ts, vm_id, metric_name, feature_name)
);
SELECT create_hypertable('features', 'ts', chunk_time_interval => INTERVAL '1 day');

CREATE TYPE model_status AS ENUM ('active', 'shadow', 'deprecated');

CREATE TABLE model_registry (
    model_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_name    TEXT          NOT NULL,     -- e.g. cpu_util_pct
    horizon_min    SMALLINT      NOT NULL,     -- prediction horizon (minutes)
    model_name     TEXT          NOT NULL,     -- “lstm_v1”, “tft_v3”, …
    framework      TEXT          NOT NULL,     -- “pytorch”, “tensorflow”, …
    version_tag    TEXT          NOT NULL,     -- “1.0.3” or Git SHA
    storage_uri    TEXT          NOT NULL,     -- S3/MinIO/FS path
    train_start    TIMESTAMPTZ   NOT NULL,
    train_end      TIMESTAMPTZ   NOT NULL,
    metrics        JSONB,                      -- eval metrics (RMSE, MAPE…)
    status         model_status  NOT NULL DEFAULT 'active',
    created_at     TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX registry_unq
    ON model_registry(metric_name, horizon_min, version_tag);

    CREATE TABLE prom_sd_static_targets (
    vm_id      UUID REFERENCES vm(vm_id),
    job_name   TEXT NOT NULL,
    port       SMALLINT NOT NULL DEFAULT 9100,
    scrape     BOOLEAN NOT NULL DEFAULT TRUE,
    labels     HSTORE DEFAULT hstore('')
);


-- Modify the metrics table to include a `type` column to distinguish historical from predicted data
CREATE TABLE metrics_extended (
    ts TIMESTAMPTZ NOT NULL,                -- Timestamp of the metric
    vm_id UUID NOT NULL REFERENCES vm(vm_id), -- VM ID
    metric_name TEXT NOT NULL,             -- e.g., cpu_util_pct
    value DOUBLE PRECISION NOT NULL,      -- Value of the metric
    job TEXT,                              -- Optional: job name (from Prometheus)
    instance TEXT,                         -- Optional: instance name
    type TEXT CHECK (type IN ('historical', 'predicted')) NOT NULL, -- Type of data: historical or predicted
    horizon_min SMALLINT;
    PRIMARY KEY (ts, vm_id, metric_name, type)
);
