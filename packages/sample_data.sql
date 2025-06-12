-- Insert VMs
INSERT INTO vm (vm_id, name, ip_address, labels) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'vm1', '192.168.1.101', 'env => prod, region => us-east'),
  ('550e8400-e29b-41d4-a716-446655440002', 'vm2', '192.168.1.102', 'env => dev, region => us-west');

-- Insert Metrics (feeds metrics_wide)
INSERT INTO metrics (ts, vm_id, metric_name, value, job, instance) VALUES
  ('2025-06-11 21:30:00+07', '550e8400-e29b-41d4-a716-446655440001', 'cpu_util_pct', 75.5, 'node_exporter', '192.168.1.101:9100'),
  ('2025-06-11 21:30:00+07', '550e8400-e29b-41d4-a716-446655440001', 'load_1m', 1.2, 'node_exporter', '192.168.1.101:9100'),
  ('2025-06-11 21:30:00+07', '550e8400-e29b-41d4-a716-446655440001', 'mem_util_pct', 60.0, 'node_exporter', '192.168.1.101:9100'),
  ('2025-06-11 21:30:00+07', '550e8400-e29b-41d4-a716-446655440002', 'cpu_util_pct', 50.0, 'node_exporter', '192.168.1.102:9100'),
  ('2025-06-11 21:31:00+07', '550e8400-e29b-41d4-a716-446655440001', 'cpu_util_pct', 80.0, 'node_exporter', '192.168.1.101:9100');

-- Refresh metrics_wide to populate it
CALL refresh_continuous_aggregate('metrics_wide', '2025-06-11 21:00:00+07', '2025-06-11 22:00:00+07');

-- Insert Features
INSERT INTO features (ts, vm_id, metric_name, feature_name, value) VALUES
  ('2025-06-11 21:30:00+07', '550e8400-e29b-41d4-a716-446655440001', 'cpu_util_pct', 'moving_avg_5m', 70.0),
  ('2025-06-11 21:30:00+07', '550e8400-e29b-41d4-a716-446655440001', 'cpu_util_pct', 'std_dev_10m', 5.5);

-- Insert Model Registry
INSERT INTO model_registry (model_id, metric_name, horizon_min, model_name, framework, version_tag, storage_uri, train_start, train_end, metrics, status) VALUES
  ('550e8400-e29b-41d4-a716-446655440003', 'cpu_util_pct', 5, 'lstm_v1', 'pytorch', '1.0.0', 's3://models/lstm_v1', '2025-06-01 00:00:00+07', '2025-06-02 00:00:00+07', '{"rmse": 0.05, "mape": 0.03}', 'active');

-- Insert Prometheus Static Targets
INSERT INTO prom_sd_static_targets (vm_id, job_name, port, scrape, labels) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'node_exporter', 9100, TRUE, 'env => prod, region => us-east'),
  ('550e8400-e29b-41d4-a716-446655440002', 'node_exporter', 9100, TRUE, 'env => dev, region => us-west');