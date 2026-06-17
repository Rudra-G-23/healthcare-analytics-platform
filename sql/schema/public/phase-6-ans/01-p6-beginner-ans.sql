/*
================================================================
					PHASE 6: BEGINNER ANSWER
================================================================
*/

-- 1. From fact_patient_visits, show all visits where treatment_cost
	-- is above the overall average. Use a scalar subquery.
SELECT *
FROM public.fact_patient_visits
WHERE treatment_cost > (
	SELECT AVG(treatment_cost) 
	FROM public.fact_patient_visits
	);


-- 2. From dim_hospital, find hospitals whose hospital_id 
	-- appears in fact_financials with total revenue above 5 million.
WITH above_5miilion_db AS (
	SELECT 
		hospital_id,
		SUM(revenue) total_revenue
	FROM public.fact_financials
	GROUP BY hospital_id
	HAVING SUM(revenue) > 50_00_000
)
SELECT 
	h.hospital_name, 
	f.total_revenue
FROM public.dim_hospital h
INNER JOIN above_5miilion_db f
	ON h.hospital_id = f.hospital_id;


-- 3. From dim_hospital, show only hospitals that have 
	-- at least one record in fact_financials. Use EXISTS.
SELECT *
FROM public.dim_hospital
WHERE EXISTS (
	SELECT 1 FROM public.fact_financials
	WHERE public.dim_hospital.hospital_id = public.fact_financials.hospital_id
);


-- 4. From dim_doctor, find doctors with NO recorded visits in fact_patient_visits. Use NOT EXISTS.
SELECT *
FROM public.dim_doctor
WHERE NOT EXISTS (
	SELECT 1
	FROM public.fact_patient_visits
	WHERE public.fact_patient_visits.doctor_id = public.dim_doctor.doctor_id
);


-- 5. Write a CTE named hospital_visit_counts that counts visits per hospital 
	-- from fact_patient_visits. Then SELECT the top 10 from it.
WITH hospital_visit_counts AS (
	SELECT
		hospital_id,
		COUNT(*) visit_count
	FROM public.fact_patient_visits
	GROUP BY hospital_id
)
SELECT *
FROM hospital_visit_counts
ORDER BY visit_count DESC
LIMIT 10;


-- 6. Write two CTEs: high_risk_patients (patients with risk_category IN ('High','Critical')) 
	-- and costly_visits (visits with treatment_cost > 5000). Then join them.
WITH high_risk_patients AS(
	SELECT 
		patient_id
	FROM public.dim_patient
	WHERE risk_category IN ('High', 'Critical')
), 
costly_visits AS (
	SELECT
	p.patient_id,
	pv.treatment_cost
	FROM public.dim_patient p
	LEFT JOIN public.fact_patient_visits pv
		ON p.patient_id = pv.patient_id
	WHERE pv.treatment_cost > 5000
)
SELECT
	cv.patient_id,
	cv.treatment_cost
FROM high_risk_patients hp
INNER JOIN costly_visits cv
	ON hp.patient_id = cv.patient_id
ORDER BY cv.treatment_cost ASC;

-- 7. Create a view vw_hospital_financial_summary that joins dim_hospital with aggregated 
	-- fact_financials to show hospital name, total revenue, avg profit margin, and latest year. Use it in a SELECT.
CREATE VIEW vw_hospital_financial_summary AS (
SELECT 
	h.hospital_id,
	SUM(pv.revenue_amount) total_revenue,
	h.founding_year
FROM public.dim_hospital h
LEFT JOIN public.fact_patient_visits pv
	ON h.hospital_id = pv.hospital_id
GROUP BY h.hospital_id
);
