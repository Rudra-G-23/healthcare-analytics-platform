/*
--------------------------------------------------------------------------------
-->> Show the Table of specific table name
    - Column name
    - Data Type
    - Position
--------------------------------------------------------------------------------
*/
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'dim_date';

-- With Position of column
SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'dim_date'
ORDER BY ordinal_position;