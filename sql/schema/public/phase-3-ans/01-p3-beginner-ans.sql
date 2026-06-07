/*
================================================================
						PHASE 3: BEGINNER
================================================================
*/

-- 1. Join dim_patient and fact_patient_visits to display patient_id, age, gender, 
	-- visit_id, admission_type, treatment_cost.
SELECT 
	p.patient_id,
	p.age,
	p.gender,
	pv.visit_id,
	pv.admission_type,
	pv.treatment_cost
FROM public.dim_patient AS p
LEFT JOIN public.fact_patient_visits AS pv
ON p.patient_id = pv.patient_id;

-- 2. Join dim_hospital to fact_financials showing all hospitals, even those with no financial data.
	-- Show hospital_name, city, revenue (NULL if no record exists).
SELECT * FROM public.fact_financials WHERE revenue <0; -- Null record 

SELECT 
	h.hospital_name,
	h.city,
	f.revenue
FROM public.dim_hospital h
LEFT JOIN public.fact_financials f
ON h.hospital_id = f.hospital_id
WHERE f.revenue >0;

-- 3. Join fact_financials to dim_hospital showing all financial records, even orphaned ones with 
	-- no hospital match. Show financial_record_id, hospital_id from financials, hospital_name 
	-- (NULL if unmatched).
SELECT 
	f.financial_record_id,
	f.hospital_id,
	h.hospital_name
FROM public.fact_financials f
LEFT JOIN public.dim_hospital h
ON h.hospital_id = f.hospital_id;

-- 4. Join dim_patient and fact_patient_visits with a FULL OUTER JOIN. 
	-- Show all patients (even with no visits) and all visits 
	-- (even with no matching patient record).

	-- 4.1 Check 
	SELECT COUNT(DISTINCT patient_id) FROM public.dim_patient;
	SELECT COUNT(DISTINCT patient_id) FROM public.fact_patient_visits;

	-- 4.2 Join
	SELECT *
	FROM public.dim_patient p
	FULL OUTER JOIN public.fact_patient_visits pv
	ON p.patient_id = pv.patient_id;

-- 5. Join dim_doctor and dim_hospital to show doctor_name, specialty,
	-- grade, hospital_name, city for all doctors.
	-- Hint: Join 4 tables for this
SELECT 
	d.doctor_name,
	d.specialty,
	d.grade,
	h.hospital_name,
	h.city
FROM public.dim_doctor d
LEFT JOIN public.fact_patient_visits pv
	ON d.doctor_id = pv.doctor_id
LEFT JOIN public.fact_financials f
	ON f.hospital_id = pv.hospital_id
LEFT JOIN public.dim_hospital h
	ON f.hospital_id = h.hospital_id;

-- 6. Join fact_patient_visits with dim_department to show visit_id, admission_type,
	-- department_name, type (department type), icu_capable. Filter for only ICU-capable departments.
SELECT 
	pv.visit_id,
	pv.admission_type,
	d.department_name,
	d.icu_capable
FROM public.fact_patient_visits pv
LEFT JOIN public.dim_department d
	ON pv.department_id = d.department_id
WHERE d.icu_capable = true;

-- 7. Join dim_patient, fact_patient_visits, and dim_hospital to show patient_id, age,
	-- risk_category, admission_type, hospital_name, city. Limit to 20 rows.
SELECT 
	p.patient_id,
	p.age,
	p.risk_category,
	pv.admission_type,
	h.hospital_name,
	h.city
FROM public.dim_patient p
LEFT JOIN public.fact_patient_visits pv
	ON p.patient_id = pv.patient_id 
LEFT JOIN public.dim_hospital h
	ON h.hospital_id = pv.hospital_id
LIMIT 20;

-- 8. Find pairs of doctors who work at the same hospital. Show doctor1_name, 
	-- doctor2_name, hospital_id, both specialties.
SELECT 
	d.doctor_name doctor1_name ,
	d.doctor_name doctor_2_name,
	d.specialty,
	h.hospital_name -- why this null 
FROM public.dim_doctor d
LEFT JOIN public.fact_patient_visits pv
	ON d.doctor_id = pv.doctor_id
	AND d.doctor_id < pv.doctor_id
LEFT JOIN public.fact_financials f
	ON f.hospital_id = pv.hospital_id
	AND f.hospital_id < pv.hospital_id
LEFT JOIN public.dim_hospital h
	ON f.hospital_id = h.hospital_id;

-- 9. Use a CROSS JOIN between dim_doctor and dim_department to generate all 
	-- possible doctor-department assignments. Show doctor name, department name. Limit to 50.
SELECT 
	d.doctor_name,
	dp.department_name
FROM public.dim_doctor d
LEFT JOIN public.fact_patient_visits pv
	ON d.doctor_id = pv.doctor_id
CROSS JOIN public.dim_department dp
	-- ON pv.department_id = dp.department_id -- WHY THIS SHOW ERROR near ON?
LIMIT 50;

-- 10. Write two separate SELECT queries (Emergency visits and ICU-required visits from fact_patient_visits) 
	-- and combine them with UNION to get a unique list. Show visit_id, patient_id, admission_type.
SELECT 
	visit_id,
	patient_id,
	admission_type
FROM public.fact_patient_visits
WHERE admission_type = 'Emergency'

UNION

SELECT 
	visit_id,
	patient_id,
	admission_type
FROM public.fact_patient_visits
WHERE icu_required_flag = true;

-- 11. Repeat Q10 using UNION ALL instead of UNION. Compare row counts. 
	-- Found 6030 rows
SELECT 
	visit_id,
	patient_id,
	admission_type
FROM public.fact_patient_visits
WHERE admission_type = 'Emergency'

UNION ALL

SELECT 
	visit_id,
	patient_id,
	admission_type
FROM public.fact_patient_visits
WHERE icu_required_flag = true;

-- 12. Find patient IDs who had BOTH an Emergency admission AND a Planned admission 
	-- (appear in both filtered sets).
SELECT *
FROM public.fact_patient_visits
WHERE readmission_30_days_flag = true

UNION 

SELECT *
FROM public.fact_patient_visits
WHERE admission_type = 'Emergency';