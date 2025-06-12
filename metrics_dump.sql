--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Homebrew)
-- Dumped by pg_dump version 17.5 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: timescaledb; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;


--
-- Name: EXTENSION timescaledb; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data (Community Edition)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cpu_utilization_pct; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.cpu_utilization_pct (
    ts timestamp with time zone NOT NULL,
    instance text NOT NULL,
    value_pct double precision NOT NULL
);


ALTER TABLE public.cpu_utilization_pct OWNER TO huygdo;

--
-- Name: _hyper_1_1_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: huygdo
--

CREATE TABLE _timescaledb_internal._hyper_1_1_chunk (
    CONSTRAINT constraint_1 CHECK (((ts >= '2025-06-05 07:00:00+07'::timestamp with time zone) AND (ts < '2025-06-12 07:00:00+07'::timestamp with time zone)))
)
INHERITS (public.cpu_utilization_pct);


ALTER TABLE _timescaledb_internal._hyper_1_1_chunk OWNER TO huygdo;

--
-- Name: metric_labels; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_labels (
    metric_id bigint NOT NULL,
    metric_name text NOT NULL,
    metric_name_label text NOT NULL,
    metric_labels jsonb
);


ALTER TABLE public.metric_labels OWNER TO huygdo;

--
-- Name: metric_values; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
)
PARTITION BY RANGE (metric_time);


ALTER TABLE public.metric_values OWNER TO huygdo;

--
-- Name: metric_values_20250611; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
)
PARTITION BY RANGE (metric_time);


ALTER TABLE public.metric_values_20250611 OWNER TO huygdo;

--
-- Name: metric_values_20250611_00; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_00 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_00 OWNER TO huygdo;

--
-- Name: metric_values_20250611_01; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_01 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_01 OWNER TO huygdo;

--
-- Name: metric_values_20250611_02; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_02 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_02 OWNER TO huygdo;

--
-- Name: metric_values_20250611_03; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_03 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_03 OWNER TO huygdo;

--
-- Name: metric_values_20250611_04; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_04 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_04 OWNER TO huygdo;

--
-- Name: metric_values_20250611_05; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_05 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_05 OWNER TO huygdo;

--
-- Name: metric_values_20250611_06; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_06 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_06 OWNER TO huygdo;

--
-- Name: metric_values_20250611_07; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_07 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_07 OWNER TO huygdo;

--
-- Name: metric_values_20250611_08; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_08 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_08 OWNER TO huygdo;

--
-- Name: metric_values_20250611_09; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_09 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_09 OWNER TO huygdo;

--
-- Name: metric_values_20250611_10; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_10 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_10 OWNER TO huygdo;

--
-- Name: metric_values_20250611_11; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_11 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_11 OWNER TO huygdo;

--
-- Name: metric_values_20250611_12; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_12 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_12 OWNER TO huygdo;

--
-- Name: metric_values_20250611_13; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_13 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_13 OWNER TO huygdo;

--
-- Name: metric_values_20250611_14; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_14 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_14 OWNER TO huygdo;

--
-- Name: metric_values_20250611_15; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_15 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_15 OWNER TO huygdo;

--
-- Name: metric_values_20250611_16; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_16 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_16 OWNER TO huygdo;

--
-- Name: metric_values_20250611_17; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_17 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_17 OWNER TO huygdo;

--
-- Name: metric_values_20250611_18; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_18 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_18 OWNER TO huygdo;

--
-- Name: metric_values_20250611_19; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_19 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_19 OWNER TO huygdo;

--
-- Name: metric_values_20250611_20; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_20 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_20 OWNER TO huygdo;

--
-- Name: metric_values_20250611_21; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_21 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_21 OWNER TO huygdo;

--
-- Name: metric_values_20250611_22; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_22 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_22 OWNER TO huygdo;

--
-- Name: metric_values_20250611_23; Type: TABLE; Schema: public; Owner: huygdo
--

CREATE TABLE public.metric_values_20250611_23 (
    metric_id bigint,
    metric_time timestamp with time zone,
    metric_value double precision
);


ALTER TABLE public.metric_values_20250611_23 OWNER TO huygdo;

--
-- Name: metric_values_20250611; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values ATTACH PARTITION public.metric_values_20250611 FOR VALUES FROM ('2025-06-11 00:00:00+07') TO ('2025-06-12 00:00:00+07');


--
-- Name: metric_values_20250611_00; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_00 FOR VALUES FROM ('2025-06-11 00:00:00+07') TO ('2025-06-11 01:00:00+07');


--
-- Name: metric_values_20250611_01; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_01 FOR VALUES FROM ('2025-06-11 01:00:00+07') TO ('2025-06-11 02:00:00+07');


--
-- Name: metric_values_20250611_02; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_02 FOR VALUES FROM ('2025-06-11 02:00:00+07') TO ('2025-06-11 03:00:00+07');


--
-- Name: metric_values_20250611_03; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_03 FOR VALUES FROM ('2025-06-11 03:00:00+07') TO ('2025-06-11 04:00:00+07');


--
-- Name: metric_values_20250611_04; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_04 FOR VALUES FROM ('2025-06-11 04:00:00+07') TO ('2025-06-11 05:00:00+07');


--
-- Name: metric_values_20250611_05; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_05 FOR VALUES FROM ('2025-06-11 05:00:00+07') TO ('2025-06-11 06:00:00+07');


--
-- Name: metric_values_20250611_06; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_06 FOR VALUES FROM ('2025-06-11 06:00:00+07') TO ('2025-06-11 07:00:00+07');


--
-- Name: metric_values_20250611_07; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_07 FOR VALUES FROM ('2025-06-11 07:00:00+07') TO ('2025-06-11 08:00:00+07');


--
-- Name: metric_values_20250611_08; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_08 FOR VALUES FROM ('2025-06-11 08:00:00+07') TO ('2025-06-11 09:00:00+07');


--
-- Name: metric_values_20250611_09; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_09 FOR VALUES FROM ('2025-06-11 09:00:00+07') TO ('2025-06-11 10:00:00+07');


--
-- Name: metric_values_20250611_10; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_10 FOR VALUES FROM ('2025-06-11 10:00:00+07') TO ('2025-06-11 11:00:00+07');


--
-- Name: metric_values_20250611_11; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_11 FOR VALUES FROM ('2025-06-11 11:00:00+07') TO ('2025-06-11 12:00:00+07');


--
-- Name: metric_values_20250611_12; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_12 FOR VALUES FROM ('2025-06-11 12:00:00+07') TO ('2025-06-11 13:00:00+07');


--
-- Name: metric_values_20250611_13; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_13 FOR VALUES FROM ('2025-06-11 13:00:00+07') TO ('2025-06-11 14:00:00+07');


--
-- Name: metric_values_20250611_14; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_14 FOR VALUES FROM ('2025-06-11 14:00:00+07') TO ('2025-06-11 15:00:00+07');


--
-- Name: metric_values_20250611_15; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_15 FOR VALUES FROM ('2025-06-11 15:00:00+07') TO ('2025-06-11 16:00:00+07');


--
-- Name: metric_values_20250611_16; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_16 FOR VALUES FROM ('2025-06-11 16:00:00+07') TO ('2025-06-11 17:00:00+07');


--
-- Name: metric_values_20250611_17; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_17 FOR VALUES FROM ('2025-06-11 17:00:00+07') TO ('2025-06-11 18:00:00+07');


--
-- Name: metric_values_20250611_18; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_18 FOR VALUES FROM ('2025-06-11 18:00:00+07') TO ('2025-06-11 19:00:00+07');


--
-- Name: metric_values_20250611_19; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_19 FOR VALUES FROM ('2025-06-11 19:00:00+07') TO ('2025-06-11 20:00:00+07');


--
-- Name: metric_values_20250611_20; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_20 FOR VALUES FROM ('2025-06-11 20:00:00+07') TO ('2025-06-11 21:00:00+07');


--
-- Name: metric_values_20250611_21; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_21 FOR VALUES FROM ('2025-06-11 21:00:00+07') TO ('2025-06-11 22:00:00+07');


--
-- Name: metric_values_20250611_22; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_22 FOR VALUES FROM ('2025-06-11 22:00:00+07') TO ('2025-06-11 23:00:00+07');


--
-- Name: metric_values_20250611_23; Type: TABLE ATTACH; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_values_20250611 ATTACH PARTITION public.metric_values_20250611_23 FOR VALUES FROM ('2025-06-11 23:00:00+07') TO ('2025-06-12 00:00:00+07');


--
-- Data for Name: hypertable; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.hypertable (id, schema_name, table_name, associated_schema_name, associated_table_prefix, num_dimensions, chunk_sizing_func_schema, chunk_sizing_func_name, chunk_target_size, compression_state, compressed_hypertable_id, status) FROM stdin;
1	public	cpu_utilization_pct	_timescaledb_internal	_hyper_1	1	_timescaledb_functions	calculate_chunk_interval	0	0	\N	0
\.


--
-- Data for Name: chunk; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.chunk (id, hypertable_id, schema_name, table_name, compressed_chunk_id, dropped, status, osm_chunk, creation_time) FROM stdin;
1	1	_timescaledb_internal	_hyper_1_1_chunk	\N	f	0	f	2025-06-08 15:38:00.072017+07
\.


--
-- Data for Name: chunk_column_stats; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.chunk_column_stats (id, hypertable_id, chunk_id, column_name, range_start, range_end, valid) FROM stdin;
\.


--
-- Data for Name: dimension; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.dimension (id, hypertable_id, column_name, column_type, aligned, num_slices, partitioning_func_schema, partitioning_func, interval_length, compress_interval_length, integer_now_func_schema, integer_now_func) FROM stdin;
1	1	ts	timestamp with time zone	t	\N	\N	\N	604800000000	\N	\N	\N
\.


--
-- Data for Name: dimension_slice; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.dimension_slice (id, dimension_id, range_start, range_end) FROM stdin;
1	1	1749081600000000	1749686400000000
\.


--
-- Data for Name: chunk_constraint; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.chunk_constraint (chunk_id, dimension_slice_id, constraint_name, hypertable_constraint_name) FROM stdin;
1	1	constraint_1	\N
1	\N	1_1_cpu_utilization_pct_pkey	cpu_utilization_pct_pkey
\.


--
-- Data for Name: chunk_index; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.chunk_index (chunk_id, index_name, hypertable_id, hypertable_index_name) FROM stdin;
1	1_1_cpu_utilization_pct_pkey	1	cpu_utilization_pct_pkey
1	_hyper_1_1_chunk_cpu_utilization_pct_ts_idx	1	cpu_utilization_pct_ts_idx
\.


--
-- Data for Name: compression_chunk_size; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.compression_chunk_size (chunk_id, compressed_chunk_id, uncompressed_heap_size, uncompressed_toast_size, uncompressed_index_size, compressed_heap_size, compressed_toast_size, compressed_index_size, numrows_pre_compression, numrows_post_compression, numrows_frozen_immediately) FROM stdin;
\.


--
-- Data for Name: compression_settings; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.compression_settings (relid, compress_relid, segmentby, orderby, orderby_desc, orderby_nullsfirst) FROM stdin;
\.


--
-- Data for Name: continuous_agg; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.continuous_agg (mat_hypertable_id, raw_hypertable_id, parent_mat_hypertable_id, user_view_schema, user_view_name, partial_view_schema, partial_view_name, direct_view_schema, direct_view_name, materialized_only, finalized) FROM stdin;
\.


--
-- Data for Name: continuous_agg_migrate_plan; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.continuous_agg_migrate_plan (mat_hypertable_id, start_ts, end_ts, user_view_definition) FROM stdin;
\.


--
-- Data for Name: continuous_agg_migrate_plan_step; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.continuous_agg_migrate_plan_step (mat_hypertable_id, step_id, status, start_ts, end_ts, type, config) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_bucket_function; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.continuous_aggs_bucket_function (mat_hypertable_id, bucket_func, bucket_width, bucket_origin, bucket_offset, bucket_timezone, bucket_fixed_width) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_hypertable_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.continuous_aggs_hypertable_invalidation_log (hypertable_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_invalidation_threshold; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.continuous_aggs_invalidation_threshold (hypertable_id, watermark) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_materialization_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.continuous_aggs_materialization_invalidation_log (materialization_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_watermark; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.continuous_aggs_watermark (mat_hypertable_id, watermark) FROM stdin;
\.


--
-- Data for Name: metadata; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.metadata (key, value, include_in_telemetry) FROM stdin;
install_timestamp	2025-06-08 15:18:49.563032+07	t
timescaledb_version	2.20.2	f
exported_uuid	4845e292-4cc4-4f87-a92a-6706990cd19f	t
\.


--
-- Data for Name: tablespace; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: huygdo
--

COPY _timescaledb_catalog.tablespace (id, hypertable_id, tablespace_name) FROM stdin;
\.


--
-- Data for Name: bgw_job; Type: TABLE DATA; Schema: _timescaledb_config; Owner: huygdo
--

COPY _timescaledb_config.bgw_job (id, application_name, schedule_interval, max_runtime, max_retries, retry_period, proc_schema, proc_name, owner, scheduled, fixed_schedule, initial_start, hypertable_id, config, check_schema, check_name, timezone) FROM stdin;
\.


--
-- Data for Name: _hyper_1_1_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: huygdo
--

COPY _timescaledb_internal._hyper_1_1_chunk (ts, instance, value_pct) FROM stdin;
2025-06-08 15:38:00.033+07	192.168.0.166:9182	2.452256944444443
2025-06-08 15:38:15.011+07	192.168.0.166:9182	3.2769097222222285
2025-06-08 15:38:30.01+07	192.168.0.166:9182	3.411458333333343
2025-06-08 15:38:45.011+07	192.168.0.166:9182	4.257812500000014
2025-06-08 15:39:00.012+07	192.168.0.166:9182	3.3246527777777857
2025-06-08 15:39:15.008+07	192.168.0.166:9182	3.2573581698184313
2025-06-08 15:42:15.026+07	192.168.0.166:9182	3.088124180537335
2025-06-08 15:42:30.015+07	192.168.0.166:9182	2.8407228493966556
2025-06-08 16:00:30.025+07	192.168.0.166:9182	3.1488894197648847
2025-06-08 16:00:45.013+07	192.168.0.166:9182	3.194444444444457
2025-06-08 16:01:00.012+07	192.168.0.166:9182	2.9861111111111285
2025-06-08 16:01:15.009+07	192.168.0.166:9182	3.0425347222222285
2025-06-08 16:01:30.009+07	192.168.0.166:9182	3.5395231005133354
2025-06-08 16:01:45.008+07	192.168.0.166:9182	3.8086263028067293
2025-06-08 16:02:00.011+07	192.168.0.166:9182	3.3072916666666856
2025-06-08 16:02:15.01+07	192.168.0.166:9182	3.1814236111111285
2025-06-08 16:02:30.012+07	192.168.0.166:9182	3.077256944444457
2025-06-08 16:02:45.013+07	192.168.0.166:9182	2.929687500000014
2025-06-08 16:03:00.01+07	192.168.0.166:9182	2.6215277777777857
2025-06-08 16:03:15.01+07	192.168.0.166:9182	2.6605902777777857
2025-06-08 16:03:30.006+07	192.168.0.166:9182	2.4262152777777857
2025-06-08 16:03:45.01+07	192.168.0.166:9182	2.0876736111111143
2025-06-08 16:04:00.008+07	192.168.0.166:9182	1.5885416666666714
2025-06-08 16:04:15.01+07	192.168.0.166:9182	2.3459201871152686
2025-06-08 16:04:30.01+07	192.168.0.166:9182	6.846888264183647
2025-06-08 16:04:45.009+07	192.168.0.166:9182	15.497254105646789
2025-06-08 16:05:00.011+07	192.168.0.166:9182	18.224826388888886
2025-06-08 16:05:15.007+07	192.168.0.166:9182	15.447048611111128
2025-06-08 16:05:30.011+07	192.168.0.166:9182	6.8315972222222285
2025-06-08 16:05:45.009+07	192.168.0.166:9182	3.645833333333343
2025-06-08 16:06:00.008+07	192.168.0.166:9182	2.4392361111111143
2025-06-08 16:06:15.011+07	192.168.0.166:9182	4.168877363941419
2025-06-08 16:06:30.008+07	192.168.0.166:9182	4.5486111111111285
2025-06-08 16:34:15.029+07	192.168.0.166:9182	3.997395833333343
2025-06-08 16:34:30.013+07	192.168.0.166:9182	4.171006944444457
2025-06-08 16:34:45.011+07	192.168.0.166:9182	6.571180555555571
2025-06-08 16:35:00.012+07	192.168.0.166:9182	6.519097222222214
2025-06-08 16:43:45.028+07	192.168.0.166:9182	4.5095486111111285
2025-06-08 16:44:00.015+07	192.168.0.166:9182	3.825921923957253
2025-06-08 16:44:15.011+07	192.168.0.166:9182	3.7174173907246484
2025-06-08 16:44:30.012+07	192.168.0.166:9182	4.108033710361994
2025-06-08 16:44:45.011+07	192.168.0.166:9182	4.5269097222222285
2025-06-08 16:45:00.01+07	192.168.0.166:9182	4.5486111111111285
2025-06-08 16:45:15.012+07	192.168.0.166:9182	4.3532986111111285
2025-06-08 16:45:30.01+07	192.168.0.166:9182	3.919270833333343
2025-06-08 16:45:45.013+07	192.168.0.166:9182	3.7760416666666714
2025-06-08 16:46:00.009+07	192.168.0.166:9182	3.6892361111111285
2025-06-08 16:46:15.009+07	192.168.0.166:9182	4.917534722222243
2025-06-08 16:46:30.009+07	192.168.0.166:9182	5.223460311993051
2025-06-08 16:46:45.012+07	192.168.0.166:9182	8.75636791404635
2025-06-08 16:47:00.01+07	192.168.0.166:9182	7.493375147218956
2025-06-08 16:47:15.011+07	192.168.0.166:9182	7.413194444444457
2025-06-08 16:47:30.011+07	192.168.0.166:9182	3.2855902777778
2025-06-08 16:47:45.012+07	192.168.0.166:9182	3.6545138888889
2025-06-08 16:48:00.009+07	192.168.0.166:9182	3.203125
2025-06-08 16:48:15.01+07	192.168.0.166:9182	4.036458333333343
2025-06-08 16:48:30.01+07	192.168.0.166:9182	3.6414930555555713
2025-06-08 16:48:45.007+07	192.168.0.166:9182	4.053819444444457
2025-06-08 16:49:00.008+07	192.168.0.166:9182	3.353201067022354
2025-06-08 16:49:15.009+07	192.168.0.166:9182	3.4727239884392986
2025-06-08 16:49:30.017+07	192.168.0.166:9182	3.01466582920159
2025-06-08 16:49:45.009+07	192.168.0.166:9182	3.3248271915007166
2025-06-08 16:50:00.01+07	192.168.0.166:9182	4.41646294032671
2025-06-08 16:50:15.009+07	192.168.0.166:9182	5.282248655495806
2025-06-08 16:50:30.012+07	192.168.0.166:9182	5.312631950308898
2025-06-08 16:50:45.012+07	192.168.0.166:9182	4.539930555555571
2025-06-08 16:51:00.009+07	192.168.0.166:9182	3.819444444444457
2025-06-08 16:51:15.011+07	192.168.0.166:9182	3.9887152777777857
2025-06-08 16:51:30.007+07	192.168.0.166:9182	3.6935163992711466
2025-06-08 16:51:45.012+07	192.168.0.166:9182	4.240367094795772
2025-06-08 16:52:00.012+07	192.168.0.166:9182	3.628415125994394
2025-06-08 16:52:15.01+07	192.168.0.166:9182	3.6979166666666856
2025-06-08 16:52:30.01+07	192.168.0.166:9182	3.0902777777778
2025-06-08 16:52:45.013+07	192.168.0.166:9182	3.085937500000014
2025-06-08 16:53:00.011+07	192.168.0.166:9182	2.278645833333343
2025-06-08 16:53:15.012+07	192.168.0.166:9182	1.8793402777777715
2025-06-08 16:53:30.012+07	192.168.0.166:9182	1.5885416666666714
2025-06-08 16:53:45.013+07	192.168.0.166:9182	1.8880208333333428
2025-06-08 16:54:00.011+07	192.168.0.166:9182	2.4045138888889
2025-06-08 16:54:15.012+07	192.168.0.166:9182	3.0121527777777715
2025-06-08 16:54:30.01+07	192.168.0.166:9182	3.0642361111111143
2025-06-08 16:54:45.01+07	192.168.0.166:9182	2.914483844803442
2025-06-08 16:55:00.012+07	192.168.0.166:9182	2.358940634652555
2025-06-08 16:55:15.013+07	192.168.0.166:9182	2.762577498277807
2025-06-08 16:55:30.012+07	192.168.0.166:9182	3.2421875
2025-06-08 16:55:45.014+07	192.168.0.166:9182	4.355513455854577
2025-06-08 16:56:00.011+07	192.168.0.166:9182	3.5265019778217237
2025-06-08 16:56:15.011+07	192.168.0.166:9182	3.020833333333343
2025-06-08 17:01:15.011+07	192.168.0.166:9182	50.30587932557674
2025-06-08 21:45:15.012+07	192.168.0.166:9182	66.82069134862647
2025-06-08 21:45:30.01+07	192.168.0.166:9182	42.006035289691305
2025-06-08 21:45:45.01+07	192.168.0.166:9182	23.373932086832866
2025-06-08 21:46:00.01+07	192.168.0.166:9182	16.622629272032356
2025-06-08 21:46:15.01+07	192.168.0.166:9182	21.97656024310571
2025-06-08 21:46:30.012+07	192.168.0.166:9182	23.233506944444457
2025-06-08 21:46:45.01+07	192.168.0.166:9182	23.73697916666667
2025-06-08 21:47:00.012+07	192.168.0.166:9182	19.396701388888886
2025-06-08 21:47:15.01+07	192.168.0.166:9182	16.150173611111114
2025-06-08 21:47:30.008+07	192.168.0.166:9182	13.298611111111128
2025-06-08 21:47:45.01+07	192.168.0.166:9182	11.5060763888889
2025-06-08 21:48:00.01+07	192.168.0.166:9182	11.627604166666686
2025-06-08 21:48:15.011+07	192.168.0.166:9182	10.629340277777786
2025-06-08 21:48:30.009+07	192.168.0.166:9182	11.180555555555557
2025-06-08 21:48:45.006+07	192.168.0.166:9182	11.384548611111128
\.


--
-- Data for Name: cpu_utilization_pct; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.cpu_utilization_pct (ts, instance, value_pct) FROM stdin;
\.


--
-- Data for Name: metric_labels; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_labels (metric_id, metric_name, metric_name_label, metric_labels) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_00; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_00 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_01; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_01 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_02; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_02 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_03; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_03 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_04; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_04 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_05; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_05 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_06; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_06 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_07; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_07 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_08; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_08 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_09; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_09 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_10; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_10 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_11; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_11 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_12; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_12 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_13; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_13 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_14; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_14 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_15; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_15 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_16; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_16 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_17; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_17 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_18; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_18 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_19; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_19 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_20; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_20 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_21; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_21 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_22; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_22 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Data for Name: metric_values_20250611_23; Type: TABLE DATA; Schema: public; Owner: huygdo
--

COPY public.metric_values_20250611_23 (metric_id, metric_time, metric_value) FROM stdin;
\.


--
-- Name: chunk_column_stats_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: huygdo
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_column_stats_id_seq', 1, false);


--
-- Name: chunk_constraint_name; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: huygdo
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_constraint_name', 1, true);


--
-- Name: chunk_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: huygdo
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_id_seq', 1, true);


--
-- Name: continuous_agg_migrate_plan_step_step_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: huygdo
--

SELECT pg_catalog.setval('_timescaledb_catalog.continuous_agg_migrate_plan_step_step_id_seq', 1, false);


--
-- Name: dimension_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: huygdo
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_id_seq', 1, true);


--
-- Name: dimension_slice_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: huygdo
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_slice_id_seq', 1, true);


--
-- Name: hypertable_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: huygdo
--

SELECT pg_catalog.setval('_timescaledb_catalog.hypertable_id_seq', 1, true);


--
-- Name: bgw_job_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_config; Owner: huygdo
--

SELECT pg_catalog.setval('_timescaledb_config.bgw_job_id_seq', 1000, false);


--
-- Name: _hyper_1_1_chunk 1_1_cpu_utilization_pct_pkey; Type: CONSTRAINT; Schema: _timescaledb_internal; Owner: huygdo
--

ALTER TABLE ONLY _timescaledb_internal._hyper_1_1_chunk
    ADD CONSTRAINT "1_1_cpu_utilization_pct_pkey" PRIMARY KEY (ts, instance);


--
-- Name: cpu_utilization_pct cpu_utilization_pct_pkey; Type: CONSTRAINT; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.cpu_utilization_pct
    ADD CONSTRAINT cpu_utilization_pct_pkey PRIMARY KEY (ts, instance);


--
-- Name: metric_labels metric_labels_metric_name_metric_labels_key; Type: CONSTRAINT; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_labels
    ADD CONSTRAINT metric_labels_metric_name_metric_labels_key UNIQUE (metric_name, metric_labels);


--
-- Name: metric_labels metric_labels_pkey; Type: CONSTRAINT; Schema: public; Owner: huygdo
--

ALTER TABLE ONLY public.metric_labels
    ADD CONSTRAINT metric_labels_pkey PRIMARY KEY (metric_id);


--
-- Name: _hyper_1_1_chunk_cpu_utilization_pct_ts_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: huygdo
--

CREATE INDEX _hyper_1_1_chunk_cpu_utilization_pct_ts_idx ON _timescaledb_internal._hyper_1_1_chunk USING btree (ts DESC);


--
-- Name: cpu_utilization_pct_ts_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX cpu_utilization_pct_ts_idx ON public.cpu_utilization_pct USING btree (ts DESC);


--
-- Name: metric_labels_labels_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_labels_labels_idx ON public.metric_labels USING gin (metric_labels);


--
-- Name: metric_values_id_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_id_time_idx ON ONLY public.metric_values USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_metric_id_metric_time_idx ON ONLY public.metric_values_20250611 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_00_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_00_metric_id_metric_time_idx ON public.metric_values_20250611_00 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_time_idx ON ONLY public.metric_values USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_metric_time_idx ON ONLY public.metric_values_20250611 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_00_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_00_metric_time_idx ON public.metric_values_20250611_00 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_01_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_01_metric_id_metric_time_idx ON public.metric_values_20250611_01 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_01_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_01_metric_time_idx ON public.metric_values_20250611_01 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_02_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_02_metric_id_metric_time_idx ON public.metric_values_20250611_02 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_02_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_02_metric_time_idx ON public.metric_values_20250611_02 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_03_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_03_metric_id_metric_time_idx ON public.metric_values_20250611_03 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_03_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_03_metric_time_idx ON public.metric_values_20250611_03 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_04_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_04_metric_id_metric_time_idx ON public.metric_values_20250611_04 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_04_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_04_metric_time_idx ON public.metric_values_20250611_04 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_05_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_05_metric_id_metric_time_idx ON public.metric_values_20250611_05 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_05_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_05_metric_time_idx ON public.metric_values_20250611_05 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_06_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_06_metric_id_metric_time_idx ON public.metric_values_20250611_06 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_06_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_06_metric_time_idx ON public.metric_values_20250611_06 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_07_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_07_metric_id_metric_time_idx ON public.metric_values_20250611_07 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_07_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_07_metric_time_idx ON public.metric_values_20250611_07 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_08_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_08_metric_id_metric_time_idx ON public.metric_values_20250611_08 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_08_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_08_metric_time_idx ON public.metric_values_20250611_08 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_09_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_09_metric_id_metric_time_idx ON public.metric_values_20250611_09 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_09_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_09_metric_time_idx ON public.metric_values_20250611_09 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_10_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_10_metric_id_metric_time_idx ON public.metric_values_20250611_10 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_10_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_10_metric_time_idx ON public.metric_values_20250611_10 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_11_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_11_metric_id_metric_time_idx ON public.metric_values_20250611_11 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_11_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_11_metric_time_idx ON public.metric_values_20250611_11 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_12_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_12_metric_id_metric_time_idx ON public.metric_values_20250611_12 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_12_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_12_metric_time_idx ON public.metric_values_20250611_12 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_13_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_13_metric_id_metric_time_idx ON public.metric_values_20250611_13 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_13_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_13_metric_time_idx ON public.metric_values_20250611_13 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_14_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_14_metric_id_metric_time_idx ON public.metric_values_20250611_14 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_14_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_14_metric_time_idx ON public.metric_values_20250611_14 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_15_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_15_metric_id_metric_time_idx ON public.metric_values_20250611_15 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_15_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_15_metric_time_idx ON public.metric_values_20250611_15 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_16_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_16_metric_id_metric_time_idx ON public.metric_values_20250611_16 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_16_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_16_metric_time_idx ON public.metric_values_20250611_16 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_17_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_17_metric_id_metric_time_idx ON public.metric_values_20250611_17 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_17_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_17_metric_time_idx ON public.metric_values_20250611_17 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_18_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_18_metric_id_metric_time_idx ON public.metric_values_20250611_18 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_18_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_18_metric_time_idx ON public.metric_values_20250611_18 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_19_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_19_metric_id_metric_time_idx ON public.metric_values_20250611_19 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_19_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_19_metric_time_idx ON public.metric_values_20250611_19 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_20_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_20_metric_id_metric_time_idx ON public.metric_values_20250611_20 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_20_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_20_metric_time_idx ON public.metric_values_20250611_20 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_21_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_21_metric_id_metric_time_idx ON public.metric_values_20250611_21 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_21_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_21_metric_time_idx ON public.metric_values_20250611_21 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_22_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_22_metric_id_metric_time_idx ON public.metric_values_20250611_22 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_22_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_22_metric_time_idx ON public.metric_values_20250611_22 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_23_metric_id_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_23_metric_id_metric_time_idx ON public.metric_values_20250611_23 USING btree (metric_id, metric_time DESC);


--
-- Name: metric_values_20250611_23_metric_time_idx; Type: INDEX; Schema: public; Owner: huygdo
--

CREATE INDEX metric_values_20250611_23_metric_time_idx ON public.metric_values_20250611_23 USING btree (metric_time DESC);


--
-- Name: metric_values_20250611_00_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_00_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_00_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_00_metric_time_idx;


--
-- Name: metric_values_20250611_01_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_01_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_01_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_01_metric_time_idx;


--
-- Name: metric_values_20250611_02_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_02_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_02_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_02_metric_time_idx;


--
-- Name: metric_values_20250611_03_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_03_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_03_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_03_metric_time_idx;


--
-- Name: metric_values_20250611_04_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_04_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_04_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_04_metric_time_idx;


--
-- Name: metric_values_20250611_05_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_05_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_05_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_05_metric_time_idx;


--
-- Name: metric_values_20250611_06_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_06_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_06_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_06_metric_time_idx;


--
-- Name: metric_values_20250611_07_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_07_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_07_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_07_metric_time_idx;


--
-- Name: metric_values_20250611_08_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_08_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_08_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_08_metric_time_idx;


--
-- Name: metric_values_20250611_09_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_09_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_09_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_09_metric_time_idx;


--
-- Name: metric_values_20250611_10_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_10_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_10_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_10_metric_time_idx;


--
-- Name: metric_values_20250611_11_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_11_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_11_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_11_metric_time_idx;


--
-- Name: metric_values_20250611_12_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_12_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_12_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_12_metric_time_idx;


--
-- Name: metric_values_20250611_13_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_13_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_13_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_13_metric_time_idx;


--
-- Name: metric_values_20250611_14_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_14_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_14_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_14_metric_time_idx;


--
-- Name: metric_values_20250611_15_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_15_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_15_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_15_metric_time_idx;


--
-- Name: metric_values_20250611_16_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_16_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_16_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_16_metric_time_idx;


--
-- Name: metric_values_20250611_17_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_17_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_17_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_17_metric_time_idx;


--
-- Name: metric_values_20250611_18_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_18_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_18_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_18_metric_time_idx;


--
-- Name: metric_values_20250611_19_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_19_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_19_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_19_metric_time_idx;


--
-- Name: metric_values_20250611_20_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_20_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_20_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_20_metric_time_idx;


--
-- Name: metric_values_20250611_21_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_21_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_21_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_21_metric_time_idx;


--
-- Name: metric_values_20250611_22_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_22_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_22_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_22_metric_time_idx;


--
-- Name: metric_values_20250611_23_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_id_metric_time_idx ATTACH PARTITION public.metric_values_20250611_23_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_23_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_20250611_metric_time_idx ATTACH PARTITION public.metric_values_20250611_23_metric_time_idx;


--
-- Name: metric_values_20250611_metric_id_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_id_time_idx ATTACH PARTITION public.metric_values_20250611_metric_id_metric_time_idx;


--
-- Name: metric_values_20250611_metric_time_idx; Type: INDEX ATTACH; Schema: public; Owner: huygdo
--

ALTER INDEX public.metric_values_time_idx ATTACH PARTITION public.metric_values_20250611_metric_time_idx;


--
-- Name: cpu_utilization_pct ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: huygdo
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.cpu_utilization_pct FOR EACH ROW EXECUTE FUNCTION _timescaledb_functions.insert_blocker();


--
-- PostgreSQL database dump complete
--

