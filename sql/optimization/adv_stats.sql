DO $$
DECLARE
    target_schema TEXT := 'TARGET_TABLE_NAME';           -- fixed: both tables live here
    target_table  TEXT := 'TARGET_TABLE_NAME';       -- <<< EDIT per run: 'fareclass' or 'rategain'
    output_table  TEXT := 'OUTPUT_TABLE_stats_adv'; -- <<< EDIT per run: matching output table name

    col_record RECORD;
    sql_base TEXT;
    sql_percentiles TEXT;
    distinct_count BIGINT;
    unique_list TEXT;
    inserted_id INT;
    col_mean NUMERIC;
BEGIN
    EXECUTE 'SET LOCAL work_mem = ''48MB''';
    EXECUTE 'SET LOCAL max_parallel_workers_per_gather = 0';

    -- Create output table if it doesn't exist yet
    EXECUTE format('
        CREATE TABLE IF NOT EXISTS %I.%I (
            id SERIAL PRIMARY KEY,
            schema_name TEXT,
            table_name TEXT,
            column_name TEXT,
            data_type TEXT,
            row_count BIGINT,
            missing_values BIGINT,
            mean NUMERIC,
            std_dev NUMERIC,
            skewness NUMERIC,
            unique_values_list TEXT,
            min_value TEXT,
            p10 NUMERIC, p20 NUMERIC, p25 NUMERIC, p30 NUMERIC, p40 NUMERIC,
            p50_median NUMERIC, p60_numeric NUMERIC, p70 NUMERIC, p75 NUMERIC,
            p80 NUMERIC, p85 NUMERIC, p90 NUMERIC, p95 NUMERIC, p97 NUMERIC,
            p98 NUMERIC, p99 NUMERIC,
            max_value TEXT,
            created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            created_by TEXT DEFAULT ''auto_stats''
        )', target_schema, output_table);

    RAISE NOTICE 'Output table %.% ready.', target_schema, output_table;

    ------------------------------------------------------------
    -- NUMERIC COLUMNS
    ------------------------------------------------------------
    FOR col_record IN
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = target_schema
          AND table_name = target_table
          AND data_type IN ('integer','bigint','smallint','numeric','real','double precision')
    LOOP
        RAISE NOTICE 'Processing numeric column: %', col_record.column_name;
        unique_list := NULL;

        EXECUTE format('SELECT COUNT(DISTINCT %I) FROM %I.%I',
            col_record.column_name, target_schema, target_table) INTO distinct_count;

        IF distinct_count < 20 THEN
            EXECUTE format('SELECT string_agg(DISTINCT %I::text, '', '') FROM %I.%I',
                col_record.column_name, target_schema, target_table) INTO unique_list;
        END IF;

        -- get real mean up front for the skewness formula
        EXECUTE format('SELECT AVG(%I) FROM %I.%I',
            col_record.column_name, target_schema, target_table) INTO col_mean;

        sql_base := format('
            INSERT INTO %I.%I (
                schema_name, table_name, column_name, data_type,
                row_count, missing_values, mean, std_dev, skewness,
                unique_values_list, min_value, max_value
            )
            SELECT
                %L, %L, %L, %L,
                COUNT(%I),
                COUNT(*) - COUNT(%I),
                AVG(%I),
                STDDEV(%I),
                CASE WHEN STDDEV(%I) = 0 OR STDDEV(%I) IS NULL THEN 0
                     ELSE (SUM(POWER(%I - %L, 3)) / COUNT(%I)) / POWER(STDDEV(%I), 3)
                END,
                %L,
                MIN(%I)::text,
                MAX(%I)::text
            FROM %I.%I
            RETURNING id',
            target_schema, output_table,
            target_schema, target_table, col_record.column_name, col_record.data_type,
            col_record.column_name, col_record.column_name, col_record.column_name, col_record.column_name,
            col_record.column_name, col_record.column_name,
            col_record.column_name, col_mean, col_record.column_name, col_record.column_name,
            unique_list, col_record.column_name, col_record.column_name,
            target_schema, target_table
        );

        BEGIN
            EXECUTE sql_base INTO inserted_id;

            sql_percentiles := format('
                UPDATE %I.%I
                SET p10=sub.p10, p20=sub.p20, p25=sub.p25, p30=sub.p30, p40=sub.p40,
                    p50_median=sub.p50, p60_numeric=sub.p60, p70=sub.p70, p75=sub.p75,
                    p80=sub.p80, p85=sub.p85, p90=sub.p90, p95=sub.p95, p97=sub.p97,
                    p98=sub.p98, p99=sub.p99
                FROM (
                    SELECT
                        PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY %I) AS p10,
                        PERCENTILE_CONT(0.20) WITHIN GROUP (ORDER BY %I) AS p20,
                        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY %I) AS p25,
                        PERCENTILE_CONT(0.30) WITHIN GROUP (ORDER BY %I) AS p30,
                        PERCENTILE_CONT(0.40) WITHIN GROUP (ORDER BY %I) AS p40,
                        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY %I) AS p50,
                        PERCENTILE_CONT(0.60) WITHIN GROUP (ORDER BY %I) AS p60,
                        PERCENTILE_CONT(0.70) WITHIN GROUP (ORDER BY %I) AS p70,
                        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY %I) AS p75,
                        PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY %I) AS p80,
                        PERCENTILE_CONT(0.85) WITHIN GROUP (ORDER BY %I) AS p85,
                        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY %I) AS p90,
                        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY %I) AS p95,
                        PERCENTILE_CONT(0.97) WITHIN GROUP (ORDER BY %I) AS p97,
                        PERCENTILE_CONT(0.98) WITHIN GROUP (ORDER BY %I) AS p98,
                        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY %I) AS p99
                    FROM %I.%I
                ) sub
                WHERE id = %L',
                target_schema, output_table,
                col_record.column_name, col_record.column_name, col_record.column_name, col_record.column_name,
                col_record.column_name, col_record.column_name, col_record.column_name, col_record.column_name,
                col_record.column_name, col_record.column_name, col_record.column_name, col_record.column_name,
                col_record.column_name, col_record.column_name, col_record.column_name, col_record.column_name,
                target_schema, target_table, inserted_id
            );
            EXECUTE sql_percentiles;

        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Error on numeric column %: %', col_record.column_name, SQLERRM;
        END;
    END LOOP;

    ------------------------------------------------------------
    -- TEXT / CATEGORICAL COLUMNS
    ------------------------------------------------------------
    FOR col_record IN
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = target_schema
          AND table_name = target_table
          AND data_type IN ('character varying','text','character','citext')
    LOOP
        RAISE NOTICE 'Processing text column: %', col_record.column_name;
        unique_list := NULL;

        EXECUTE format('SELECT COUNT(DISTINCT %I) FROM %I.%I',
            col_record.column_name, target_schema, target_table) INTO distinct_count;

        IF distinct_count < 20 THEN
            EXECUTE format('SELECT string_agg(DISTINCT %I, '', '') FROM %I.%I',
                col_record.column_name, target_schema, target_table) INTO unique_list;
        END IF;

        sql_base := format('
            INSERT INTO %I.%I (
                schema_name, table_name, column_name, data_type,
                row_count, missing_values, unique_values_list, min_value, max_value
            )
            SELECT
                %L, %L, %L, %L,
                COUNT(%I),
                COUNT(*) - COUNT(%I),
                %L,
                MIN(%I),
                MAX(%I)
            FROM %I.%I',
            target_schema, output_table,
            target_schema, target_table, col_record.column_name, col_record.data_type,
            col_record.column_name, col_record.column_name,
            unique_list, col_record.column_name, col_record.column_name,
            target_schema, target_table
        );

        BEGIN
            EXECUTE sql_base;
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Error on text column %: %', col_record.column_name, SQLERRM;
        END;
    END LOOP;

    RAISE NOTICE 'Profiling of %.% into %.% completed.', target_schema, target_table, target_schema, output_table;
END $$;