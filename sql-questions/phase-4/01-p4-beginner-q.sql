/*
================================================================
						PHASE 4: BEGINNER
================================================================
*/

-- 1. Display hospital_id and hospital_name in UPPER CASE from dim_hospital.

-- 2. Show doctor_name and the character length of each name from dim_doctor. Order by length descending.

-- 3. From fact_patient_visits, show visit_id and treatment_cost rounded to 0 decimal places.

-- 4. From fact_financials, show hospital_id, profit_margin, and its absolute value. Order by absolute value descending.

-- 5. Write a query that returns the current date, current timestamp, and current time zone from PostgreSQL's built-in functions. No table needed.

-- 6. From fact_patient_visits, show visit_id and the year extracted from arrival_datetime.

-- 7. From fact_patient_visits, display visit_id and satisfaction_score. Replace NULL scores with 0 using COALESCE.

-- 8. From fact_patient_visits, show visit_id and arrival_datetime truncated to the start of the month.

-- 9. From dim_patient, the age column is already stored. But demonstrate: if you had date_of_birth, how would you calculate age using AGE() and EXTRACT?

-- 10. From dim_doctor, apply TRIM to doctor_name to remove leading and trailing spaces. Show original vs trimmed.

-- 11. From fact_patient_visits, add a severity_label column: 1='Minor', 2='Low', 3='Moderate', 4='High', 5='Critical'. Use CASE WHEN.

-- 12. From fact_financials, calculate cost efficiency ratio: operational_cost / visit_count. Use NULLIF to prevent division by zero.
