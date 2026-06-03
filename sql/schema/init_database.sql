/*
================================================================
CREATE DATABASE & SCHEMAS
================================================================
Script Purpose:
    - This script creates a new database named 'HospitalDB' after checking if it already exists.
    - First, it terminates active connections if the database is active, then it is dropped and recreated.
    - Additionally, the script sets up three schemas within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    - Running this script will drop the entire 'HospitalDB' database if it exists.
    - All data in the database will be permanently deleted. Proceed with caution.
    - Ensure you have proper backups before running this script.
================================================================
*/

-- Terminate active connections to the 'HospitalDB' database
-- Avoid terminating the current connection
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'HospitalDB' AND pid <> pg_backend_pid(); 

-- Drop the database if it exists
DROP DATABASE IF EXISTS HospitalDB;

-- Recreate the database
CREATE DATABASE HospitalDB;

-- Connect to the newly created database
\c HospitalDB;

-- Create Schemas
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;