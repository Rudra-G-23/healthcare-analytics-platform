DO $$
DECLARE
    target_schema  TEXT := 'feat';
    target_table   TEXT := 'fareclass';
    output_table   TEXT := 'fareclass_stats_adv_2';
    target_columns TEXT[] := ARRAY['authorized_units','sold_seats','remaining_seats','seats_sold_in_interval']; -- <<< EDIT: put only the column(s) you want here

    col_record RECORD;
    sql_base TEXT;
    sql_percentiles TEXT;
    inserted_id INT;
    col_mean NUMERIC;
BEGIN
    EXECUTE 'SET LOCAL work_mem = ''1GB''';
    EXECUTE 'SET LOCAL max_parallel_workers_per_gather = 4';

    EXECUTE format('
        CREATE TABLE IF NOT EXISTS %I.%I (
            id SERIAL PRIMARY KEY,
            schema_name TEXT, table_name TEXT, column_name TEXT, data_type TEXT,
            row_count BIGINT, missing_values BIGINT, mean NUMERIC, std_dev NUMERIC,
            skewness NUMERIC, unique_values_list TEXT, min_value TEXT,
            p10 NUMERIC, p20 NUMERIC, p25 NUMERIC, p30 NUMERIC, p40 NUMERIC,
            p50_median NUMERIC, p60_numeric NUMERIC, p70 NUMERIC, p75 NUMERIC,
            p80 NUMERIC, p85 NUMERIC, p90 NUMERIC, p95 NUMERIC, p97 NUMERIC,
            p98 NUMERIC, p99 NUMERIC, max_value TEXT,
            created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            created_by TEXT DEFAULT ''auto_stats''
        )', target_schema, output_table);

    ------------------------------------------------------------
    -- NUMERIC COLUMNS (only those in target_columns)
    ------------------------------------------------------------
    FOR col_record IN
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = target_schema AND table_name = target_table
          AND data_type IN ('integer','bigint','smallint','numeric','real','double precision')
          AND column_name = ANY(target_columns)
    LOOP
        RAISE NOTICE 'Numeric column: %', col_record.column_name;

        -- remove any existing row for this column so it's replaced, not duplicated
        EXECUTE format('DELETE FROM %I.%I WHERE column_name = %L',
            target_schema, output_table, col_record.column_name);

        EXECUTE format('SELECT AVG(%I) FROM %I.%I',
            col_record.column_name, target_schema, target_table) INTO col_mean;

        sql_base := format('
            WITH agg AS (
                SELECT
                    COUNT(%I) AS row_count,
                    COUNT(*) - COUNT(%I) AS missing_values,
                    AVG(%I) AS mean,
                    STDDEV(%I) AS std_dev,
                    CASE WHEN STDDEV(%I) = 0 OR STDDEV(%I) IS NULL THEN 0
                         ELSE (SUM(POWER(%I::numeric - %L::numeric, 3)) / COUNT(%I)) / POWER(STDDEV(%I), 3)
                    END AS skewness,
                    MIN(%I)::text AS min_value,
                    MAX(%I)::text AS max_value,
                    COUNT(DISTINCT %I) AS distinct_count,
                    CASE WHEN COUNT(DISTINCT %I) < 20
                         THEN string_agg(DISTINCT %I::text, '', '')
                         ELSE NULL END AS unique_list
                FROM %I.%I
            )
            INSERT INTO %I.%I (
                schema_name, table_name, column_name, data_type,
                row_count, missing_values, mean, std_dev, skewness,
                unique_values_list, min_value, max_value
            )
            SELECT %L, %L, %L, %L,
                   row_count, missing_values, mean, std_dev, skewness,
                   unique_list, min_value, max_value
            FROM agg
            RETURNING id',
            col_record.column_name, col_record.column_name, col_record.column_name,
            col_record.column_name, col_record.column_name, col_record.column_name,
            col_record.column_name, col_mean, col_record.column_name, col_record.column_name,
            col_record.column_name, col_record.column_name,
            col_record.column_name, col_record.column_name, col_record.column_name,
            target_schema, target_table,
            target_schema, output_table,
            target_schema, target_table, col_record.column_name, col_record.data_type
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
    -- TEXT / CATEGORICAL COLUMNS (only those in target_columns)
    ------------------------------------------------------------
    FOR col_record IN
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = target_schema AND table_name = target_table
          AND data_type IN ('character varying','text','character','citext')
          AND column_name = ANY(target_columns)
    LOOP
        RAISE NOTICE 'Text column: %', col_record.column_name;

        EXECUTE format('DELETE FROM %I.%I WHERE column_name = %L',
            target_schema, output_table, col_record.column_name);

        sql_base := format('
            WITH agg AS (
                SELECT
                    COUNT(%I) AS row_count,
                    COUNT(*) - COUNT(%I) AS missing_values,
                    MIN(%I) AS min_value,
                    MAX(%I) AS max_value,
                    COUNT(DISTINCT %I) AS distinct_count,
                    CASE WHEN COUNT(DISTINCT %I) < 20
                         THEN string_agg(DISTINCT %I, '', '')
                         ELSE NULL END AS unique_list
                FROM %I.%I
            )
            INSERT INTO %I.%I (
                schema_name, table_name, column_name, data_type,
                row_count, missing_values, unique_values_list, min_value, max_value
            )
            SELECT %L, %L, %L, %L,
                   row_count, missing_values, unique_list, min_value, max_value
            FROM agg',
            col_record.column_name, col_record.column_name,
            col_record.column_name, col_record.column_name,
            col_record.column_name, col_record.column_name, col_record.column_name,
            target_schema, target_table,
            target_schema, output_table,
            target_schema, target_table, col_record.column_name, col_record.data_type
        );

        BEGIN
            EXECUTE sql_base;
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Error on text column %: %', col_record.column_name, SQLERRM;
        END;
    END LOOP;

    RAISE NOTICE 'Completed for columns: %', target_columns;
END $$;