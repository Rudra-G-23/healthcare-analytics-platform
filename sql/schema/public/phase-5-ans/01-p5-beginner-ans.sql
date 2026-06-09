/*
================================================================
					PHASE 5: BEGINNER ANSWER
================================================================
*/

-- 1. From fact_patient_visits, count total visits and count of distinct patients.
SELECT 
	(SELECT COUNT (visit_id) FROM public.fact_patient_visits) total_visit_count,
	(SELECT COUNT (DISTINCT patient_id) FROM public.fact_patient_visits) distinct_patient_count;

-- 2. From fact_financials, calculate total revenue per hospital_id. Show top 10 by total revenue.
SELECT
	hospital_id,
	(
		operational_cost + staffing_cost + emergency_department_cost + icu_cost 
	) / SUM (revenue) AS revenue_per_hospital
FROM public.fact_financials
GROUP BY hospital_id, revenue
ORDER BY revenue_per_hospital DESC
LIMIT 10;

SELECT
	(f.hospital_id),
	h.hospital_name,
	(
		f.operational_cost + f.staffing_cost + f.emergency_department_cost + f.icu_cost 
	) / SUM (f.revenue) AS revenue_per_hospital
FROM public.fact_financials f
LEFT JOIN public.dim_hospital h
	ON f.hospital_id = h.hospital_id
GROUP BY f.hospital_id, H.hospital_name, (f.revenue)
ORDER BY revenue_per_hospital DESC
LIMIT 10;

-- 3. From fact_patient_visits, find the average wait_time_minutes per admission_type. Round to 2 decimal places.
SELECT
	admission_type,
	ROUND (AVG (wait_time_minutes), 2) "AvgWaitTimeMinutesPerAdmissionType"
FROM public.fact_patient_visits
GROUP BY admission_type;

-- 4. From fact_patient_visits, show department_id, maximum and minimum severity_level. 
	-- Filter departments with more than 100 visits.
SELECT 
	COUNT (visit_id) > 100,
	department_id
FROM public.fact_patient_visits
GROUP BY visit_id
WHERE visit_id > 100;


--5. From fact_patient_visits, assign a row number to each visit per patient, 
	-- ordered by arrival_datetime ascending. Show patient_id, visit_id, arrival_datetime, row_num.

	-- 5.1 Check 
	SELECT COUNT (DISTINCT patient_id) FROM public.fact_patient_visits;
	
	-- 5.2 Code
	SELECT
		patient_id,
		visit_id,
		arrival_datetime,
		ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY arrival_datetime DESC) row_num
	FROM public.fact_patient_visits
	ORDER BY arrival_datetime ASC;

--6. From fact_financials, rank hospitals by total revenue using both RANK() 
	-- and DENSE_RANK(). Show where they differ (ties).
	
	-- 6.1 Check
	SELECT * FROM public.fact_financials;

	-- 6.2 Overall Hospital 
	SELECT
		hospital_id,
		SUM (revenue) total_revenue,
		RANK() OVER( ORDER BY SUM(revenue) ) revenue_rank,
		DENSE_RANK() OVER( ORDER BY SUM(revenue)) revenue_dense_rank
	FROM public.fact_financials
	GROUP BY hospital_id
	ORDER BY hospital_id;

	-- 6.3 Individual Hospital 
	SELECT
		hospital_id,
		revenue,
		RANK() OVER (PARTITION BY hospital_id ORDER BY revenue) revenue_rank,
		DENSE_RANK() OVER (PARTITION BY hospital_id ORDER BY revenue)
	FROM public.fact_financials


-- 7. From fact_patient_visits, compute a running (cumulative) total of treatment_cost per hospital_id,
	-- ordered by arrival_datetime. Show visit_id, treatment_cost, running_total.

SELECT * FROM public.fact_patient_visits;

SELECT COUNT(DISTINCT(visit_id)) total_visit_count FROM public.fact_patient_visits;

SELECT
	hospital_id,
	visit_id,
	treatment_cost,
	arrival_datetime,
	SUM(treatment_cost) OVER( PARTITION BY hospital_id ORDER BY arrival_datetime) cumlative_cost
FROM public.fact_patient_visits
ORDER BY arrival_datetime;

SELECT
	hospital_id,
	SUM (treatment_cost),
	arrival_datetime,
	SUM(treatment_cost) OVER( PARTITION BY hospital_id ORDER BY arrival_datetime) cumlative_cost
FROM public.fact_patient_visits
GROUP BY hospital_id, arrival_datetime, treatment_cost
ORDER BY hospital_id, arrival_datetime ASC;

--8. From fact_financials, use LAG to compute the previous month's revenue for each hospital, 
	-- and calculate the change. Show hospital_id, year_int, month_name, revenue, prev_revenue, change.
SELECT * FROM public.fact_financials;

SELECT
	hospital_id,
	year_int,
	month_name,
	revenue,
	LAG(revenue, 1, 0) OVER(PARTITION BY hospital_id ORDER BY year_int, month_name) prev_revenue,
	(LAG(revenue, 1, 0) OVER(PARTITION BY hospital_id ORDER BY year_int, month_name) - revenue)  change
	/*
	CASE 
		WHEN change < 0 THEN 'Postive'
		WHEN change > 0 THEN 'Negative'
		ELSE 'Zero'
	END signal_of_growth
	*/
FROM public.fact_financials;

--9. From dim_doctor, compute each doctor's salary percentile rank within their specialty.
	-- Show doctor_name, specialty, annual_salary, salary_percentile.
SELECT * FROM public.dim_doctor;

SELECT
	doctor_name,
	specialty,
	annual_salary,
	PERCENT_RANK() OVER(PARTITION BY specialty ORDER BY annual_salary) salary_percentile,
	RANK() OVER(PARTITION BY specialty ORDER BY annual_salary) rank_salary_wise
FROM public.dim_doctor;

--10. From fact_patient_visits, for each hospital find the 3rd most expensive
	-- visit's treatment cost using NTH_VALUE.
SELECT * FROM public.fact_patient_visits;

SELECT
	visit_id,
	hospital_id,
	NTH_VALUE(treatment_cost, 3) OVER(PARTITION BY hospital_id ORDER BY treatment_cost)
FROM public.fact_patient_visits;

NTH_VALUE(treatment_cost, 3) OVER (
		PARTITION BY hospital_id ORDER BY treatment_cost DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		

SELECT
	DISTINCT hospital_id,
	treatment_cost,
	NTH_VALUE(treatment_cost, 3) OVER(
		PARTITION BY hospital_id ORDER BY treatment_cost DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) most_expensive_3rd_postion_per_hospital
FROM public.fact_patient_visits
ORDER BY treatment_cost DESC;

-- 11. From fact_patient_visits, compute for each hospital: total visits, emergency visits 
	-- only, ICU-required visits only, weekend visits (use dim_date.is_weekend). 
	-- Use the FILTER clause instead of CASE WHEN.
SELECT * FROM public.fact_patient_visits;

SELECT
	hospital_id,
	hospital_name,
	COUNT(visit_id) total_visit,
	discharge_datetime
FROM public.fact_patient_visits
WHERE admission_type = 'Emergency' 
	AND icu_required_flag = true
GROUP BY hospital_id, hospital_name, discharge_datetime
HAVING discharge_datetime ;

-- 12. From fact_financials joined with dim_hospital, compute total revenue with subtotals: 
	-- per hospital per month, per hospital (all months), and grand total. Use ROLLUP.
SELECT
	h.hospital_name,
	f.year_int,
	f.month_name,
	f.revenue
FROM public.fact_financials f
LEFT JOIN public.dim_hospital h
	ON f.hospital_id = h.hospital_id
GROUP BY ROLLUP(h.hospital_name, f.year_int, f.month_name, f.revenue);


-- From fact_patient_visits, divide patients into 4 quartiles by wait_time_minutes using NTILE. 
	-- Show visit_id, wait_time_minutes, quartile.

SELECT * FROM public.fact_patient_visits;

SELECT
		visit_id,
		wait_time_minutes,
		NITLE(0.75) OVER(ORDER BY wait_time_minutes)
FROM public.fact_patient_visits;

-- From fact_staffing, for each hospital_id, show the first and last shift_date 
	-- in the dataset using FIRST_VALUE and LAST_VALUE.
SELECT * FROM public.fact_staffing;

SELECT
	shift_id,
	shift_date,
	FIRST_VALUE(shift_date) OVER(ORDER BY shift_id),
	LAST_VALUE(shift_date) OVER(ORDER BY shift_id)
FROM public.fact_staffing
ORDER BY shift_date ASC;


-- From fact_patient_visits, count visits per month_name across all hospitals. 
	-- Show month_name, visit_count, ordered by month_name.
SELECT * FROM public.fact_patient_visits;

SELECT
	hospital_name,
	COUNT (visit_id),
	EXTRACT MONTH FROM (arrival_datetime)
FROM public.fact_patient_visits
GROUP BY hospital_name;

-- From dim_patient, for each risk_category, list all distinct chronic_conditions 
	-- values concatenated as a comma-separated string.

