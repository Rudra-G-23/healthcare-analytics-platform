/*
================================================================
						PHASE 2: BEGINNER
================================================================
Topic we Cover:
	- Select all columns
	- Select few columns
	- Find unique value
	- Create a new table from exiting table
	- Add, rename, drop a column 
	- 
*/


-- 1. Retrieve all columns and all rows from dim_patient to get a first look at the data.
SELECT *
FROM public.dim_patient;

-- 2. Retrieve patient_id, age, gender, and risk_category from dim_patient.
SELECT 
	patient_id,
	age,
	gender,
	risk_Category
FROM public.dim_patient;

-- 3. Find all unique values of admission_type from fact_patient_visits to understand what categories exist.
SELECT DISTINCT admission_type
FROM public.fact_patient_visits;

-- 4. From dim_hospital, retrieve hospital_name, city, and beds ordered by beds descending. Show only the first 10.
SELECT 
	hospital_name,
	city,
	beds
FROM public.dim_hospital
ORDER BY beds DESC 
LIMIT 10;

-- 5. Retrieve all records from dim_department where icu_capable = true.
SELECT *
FROM public.dim_department
WHERE icu_capable = true;

-- 6. Create a new empty table dim_patient_backup with the same columns as dim_patient, but no data.
CREATE TABLE public.dim_patient_backup (LIKE public.dim_patient);

-- 7. Add a contact_email VARCHAR(150) column to the dim_doctor table.
ALTER TABLE public.dim_doctor 
ADD COLUMN 	contact_email VARCHAR(150);

-- 8. Rename contact_email to work_email in dim_doctor.
ALTER TABLE public.dim_doctor
RENAME COLUMN contact_email TO work_email;

-- 9. Drop the work_email column from dim_doctor.
ALTER TABLE public.dim_doctor
DROP COLUMN work_email;

-- 10. Insert one new record into dim_region. Choose values for all columns. Always list column names explicitly.
INSERT INTO public.dim_region
	(region_id, region_name, population_m, urban_rural, avg_income_k, elderly_pct, poverty_rate)
VALUES
	('R08', 'Dummy Region P2 B10', 100, 'Rural', 50, 30, 1);

SELECT * FROM public.dim_region; -- Check

-- 11. Update the city of the hospital with hospital_id = 'H001' to '"Harrogate"'.
SELECT * FROM public.dim_hospital;

-- 11.1 Copy the tale
	CREATE TEMP TABLE demo AS 
	SELECT * FROM public.dim_hospital;

-- 11.2 Update
	UPDATE demo
	SET city = 'Harrogate'
	WHERE hospital_id = 'H01';

	DELETE FROM demo
	WHERE hospital_id = 'H01';
	
-- 11.3 Check
	SELECT * FROM demo

-- 12. Delete all records from dim_patient where risk_category = 'Low'.
-- 12.1 See
	SELECT DISTINCT dim_patient.risk_category FROM public.dim_patient;
	
-- 12.2 Demo Table
	CREATE TEMP TABLE demo AS
	SELECT * FROM public.dim_patient;
	
-- 12.3 Update value
	UPDATE demo
	SET 
	WHERE risk_category != 'Low';
	
	SELECT *
	FROM demo
	WHERE risk_category != 'Low';


-- 13. Delete new record what you made on Q10.
DELETE FROM public.dim_region
WHERE region_id = 'R08';