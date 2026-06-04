--------------------------------------------------------------------------------
-->> Few SQL Query to fix the created_at column issues
--------------------------------------------------------------------------------

-- Simple make default this column and automatically fill during ingestion time
ALTER TABLE public.dim_date
ALTER COLUMN created_at
SET DEFAULT CURRENT_TIMESTAMP;

-- Provide us the command to run but in table format
SELECT 'ALTER TABLE ' || table_schema || '.' || table_name || ' DROP COLUMN ' || column_name || ';'
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND column_name = 'created_at';

-- This a loop automatically create command and run to deleted the created_at column 
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE table_schema = 'public' AND column_name = 'created_at'
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(r.table_name) || ' DROP COLUMN created_at';
    END LOOP;
END $$;
