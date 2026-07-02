DO $$
DECLARE
    target_schema TEXT := 'feat';
    target_table  TEXT := 'rate_gain_matrix_history';   -- Change as needed
    output_table  TEXT := 'rate_gain_unique_value';        -- Change as needed

    col_record RECORD;
    sql_base TEXT;
BEGIN
    -- Create output table if it doesn't exist
    EXECUTE format('
        CREATE TABLE IF NOT EXISTS %I.%I (
            id SERIAL PRIMARY KEY,
            schema_name TEXT,
            table_name TEXT,
            column_name TEXT,
            data_type TEXT,
            distinct_count BIGINT,
            unique_values_list TEXT,
            created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            created_by TEXT DEFAULT ''auto_stats''
        )',
        target_schema,
        output_table
    );

    ------------------------------------------------------------------
    -- Process ALL columns (numeric + text + others)
    ------------------------------------------------------------------
    FOR col_record IN
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = target_schema
          AND table_name = target_table
    LOOP

        RAISE NOTICE 'Processing column: %', col_record.column_name;

        -- Build dynamic SQL
        IF col_record.data_type IN
            ('integer','bigint','smallint','numeric','real','double precision') THEN

            sql_base := format('
                WITH agg AS (
                    SELECT
                        COUNT(DISTINCT %I) AS distinct_count,
                        CASE
                            WHEN COUNT(DISTINCT %I) < 20
                            THEN STRING_AGG(DISTINCT %I::text, '', '' ORDER BY %I::text)
                            ELSE NULL
                        END AS unique_list
                    FROM %I.%I
                )
                INSERT INTO %I.%I
                (
                    schema_name,
                    table_name,
                    column_name,
                    data_type,
                    distinct_count,
                    unique_values_list
                )
                SELECT
                    %L,
                    %L,
                    %L,
                    %L,
                    distinct_count,
                    unique_list
                FROM agg',
                col_record.column_name,
                col_record.column_name,
                col_record.column_name,
                col_record.column_name,
                target_schema,
                target_table,
                target_schema,
                output_table,
                target_schema,
                target_table,
                col_record.column_name,
                col_record.data_type
            );

        ELSE

            sql_base := format('
                WITH agg AS (
                    SELECT
                        COUNT(DISTINCT %I) AS distinct_count,
                        CASE
                            WHEN COUNT(DISTINCT %I) < 20
                            THEN STRING_AGG(DISTINCT %I, '', '' ORDER BY %I)
                            ELSE NULL
                        END AS unique_list
                    FROM %I.%I
                )
                INSERT INTO %I.%I
                (
                    schema_name,
                    table_name,
                    column_name,
                    data_type,
                    distinct_count,
                    unique_values_list
                )
                SELECT
                    %L,
                    %L,
                    %L,
                    %L,
                    distinct_count,
                    unique_list
                FROM agg',
                col_record.column_name,
                col_record.column_name,
                col_record.column_name,
                col_record.column_name,
                target_schema,
                target_table,
                target_schema,
                output_table,
                target_schema,
                target_table,
                col_record.column_name,
                col_record.data_type
            );

        END IF;

        BEGIN
            EXECUTE sql_base;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE WARNING 'Error processing column %: %',
                    col_record.column_name,
                    SQLERRM;
        END;

    END LOOP;

    RAISE NOTICE 'Unique value profiling completed for %.%',
        target_schema,
        target_table;

END $$;