-- === Meta Data ===

-- How many columns 
SELECT COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_schema = 'your_schema_name'
  AND table_name = 'your_table_name';


-- Meta data of two table (1. Fare Class, 2. Rate Gain)
SELECT 
    ordinal_position AS pos,
    column_name,
    data_type,
    character_maximum_length AS max_len,
    numeric_precision AS num_prec,
    numeric_scale AS num_scale,
    is_nullable,
    column_default AS default_value
FROM information_schema.columns
WHERE table_schema = 'your_schema_name'
  AND table_name = 'your_table_name'
ORDER BY ordinal_position;

-- Test Foreign key and Primary Key matching
SELECT 
    kcu.column_name, 
    tco.constraint_type
FROM information_schema.table_constraints tco
JOIN information_schema.key_column_usage kcu 
     ON kcu.constraint_name = tco.constraint_name
     AND kcu.table_schema = tco.table_schema
     AND kcu.table_name = tco.table_name
WHERE tco.table_schema = 'your_schema_name'
  AND tco.table_name = 'your_table_name';

-- Copy Exiting Table for cleaning and feature creations


CREATE SCHEMA IF NOT EXISTS feat;

CREATE TABLE feat.fare_class_feat AS 
SELECT * FROM source_schema.old_table_name;


-- === Laptop Optimization ====

-- Prevents a single query from using too much RAM for sorting data
SET work_mem = '64MB';

-- Limits the memory used for background operations
SET maintenance_work_mem = '256MB';

-- Disables parallel workers so PostgreSQL doesn't try to use 100% of your CPU/RAM at once
SET max_parallel_workers_per_gather = 0;


-- === Stats ====

-- Stats from system 
SELECT 
    attname AS column_name,
    inherited,
    null_frac * 100 AS missing_percentage,
    avg_width AS average_column_byte_width,
    n_distinct AS estimated_distinct_values
FROM pg_stats
WHERE schemaname = 'your_schema' 
  AND tablename = 'your_table';

-- Manually 
SELECT 
    COUNT(column_name) AS count,
    COUNT(*) - COUNT(column_name) AS missing_values,
    AVG(column_name) AS mean,
    STDDEV(column_name) AS std,
    MIN(column_name) AS min,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY column_name) AS "25%",
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY column_name) AS "50%",
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY column_name) AS "75%",
    MAX(column_name) AS max
FROM your_schema.your_table;

