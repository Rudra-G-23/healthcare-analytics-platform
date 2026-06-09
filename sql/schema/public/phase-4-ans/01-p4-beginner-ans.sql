/*
================================================================
					PHASE 4: BEGINNER ANSWER
================================================================
*/

-- 1. Display hospital_id and hospital_name in UPPER CASE from dim_hospital.
SELECT 
	UPPER (hospital_id),
	UPPER (hospital_name)
FROM public.dim_hospital;

-- 2. Show doctor_name and the character length of each name from dim_doctor. 
	-- Order by length descending.
SELECT
	DISTINCT (doctor_name),
	LENGTH (doctor_name)
FROM public.dim_doctor
ORDER BY LENGTH (doctor_name) DESC;

-- 3. From fact_patient_visits, show visit_id and treatment_cost rounded to 0 decimal places.
SELECT 
	visit_id,
	ROUND (treatment_cost, 0)
FROM public.fact_patient_visits;

-- 4. From fact_financials, show hospital_id, profit_margin, and its absolute value. 
	-- Order by absolute value descending.
SELECT
	hospital_id,
	profit_margin,
	ABS (profit_margin)
FROM public.fact_financials
ORDER BY ABS (profit_margin);

-- 5. Write a query that returns the current date, current timestamp, and 
	-- current time zone from PostgreSQL's built-in functions. No table needed.
SELECT 
	NOW(),
	CURRENT_TIME,
	CURRENT_TIMESTAMP,
	CURRENT_DATE,
	LOCALTIME,
	LOCALTIMESTAMP;

-- 6. From fact_patient_visits, show visit_id and the year extracted from arrival_datetime.
SELECT 
	visit_id,
	EXTRACT (YEAR FROM arrival_datetime),
	date_part('year', arrival_datetime)
FROM public.fact_patient_visits;

-- 7. From fact_patient_visits, display visit_id and satisfaction_score. 
	-- Replace NULL scores with 0 using COALESCE.

	-- 7.1 How many null
	SELECT COUNT(*)
	FROM public.fact_patient_visits
	WHERE satisfaction_score < 0;

	-- 7.2 Ans
	SELECT
		visit_id,
		satisfaction_score,
		COALESCE (satisfaction_score, 0)
	FROM public.fact_patient_visits;

-- 8. From fact_patient_visits, show visit_id and arrival_datetime truncated to the start of the month.
SELECT 
	visit_id,
	arrival_datetime,
	date_part('month', arrival_datetime) starting_month,
	DATE_TRUNC ('month', arrival_datetime) only_start_of_month
FROM public.fact_patient_visits;

-- 9. From dim_patient, the age column is already stored. But demonstrate: 
	-- if you had date_of_birth, how would you calculate age using AGE() and EXTRACT?

SELECT AGE('2026-06-08'::date, '1980-05-15'::date);

SELECT EXTRACT (
	YEAR FROM AGE(CURRENT_DATE, '1980-05-23'::date)
);

-- 10. From dim_doctor, apply TRIM to doctor_name to remove leading and trailing spaces. 
	-- Show original vs trimmed.
SELECT
	doctor_name,
	TRIM (doctor_name),
	LENGTH (doctor_name) name_length,
	LENGTH (TRIM (doctor_name) ) trim_name_length
FROM public.dim_doctor;
-- WHERE  LENGTH (doctor_name) > LENGTH (TRIM (doctor_name) )

-- 11. From fact_patient_visits, add a severity_label 
	-- column: 1='Minor', 2='Low', 3='Moderate', 4='High', 5='Critical'. Use CASE WHEN.
SELECT 	severity_level FROM public.fact_patient_visits;

SELECT 
	severity_level,
	CASE 
		WHEN severity_level = 1 THEN 'Minor'
		WHEN severity_level = 2 THEN 'Low'
		WHEN severity_level = 3 THEN 'Moderate'
		WHEN severity_level = 4 THEN 'High'
		WHEN severity_level = 5 THEN 'Critical'
		ELSE 'Unknown'
	END text_severity_level
FROM public.fact_patient_visits;

-- 12. From fact_financials, calculate cost efficiency ratio: 
	-- operational_cost / visit_count. Use NULLIF to prevent division by zero.
SELECT
	hospital_id,
	operational_cost,
	visit_count,
	operational_cost / NULLIF(visit_count, 0) ratio
FROM public.fact_financials;
-- WHERE visit_count = 0
