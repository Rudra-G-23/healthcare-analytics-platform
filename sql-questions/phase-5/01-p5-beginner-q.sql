/*
================================================================
					PHASE 5: BEGINNER QUESTIONS
================================================================
*/

-- 1. From fact_patient_visits, count total visits and count of distinct patients.

-- 2. From fact_financials, calculate total revenue per hospital_id. Show top 10 by total revenue.

-- 3. From fact_patient_visits, find the average wait_time_minutes per admission_type. Round to 2 decimal places.

-- 4. From fact_patient_visits, show department_id, maximum and minimum severity_level. Filter departments with more than 100 visits.

--5. From fact_patient_visits, assign a row number to each visit per patient, ordered by arrival_datetime ascending. Show patient_id, visit_id, arrival_datetime, row_num.

--6. From fact_financials, rank hospitals by total revenue using both RANK() and DENSE_RANK(). Show where they differ (ties).

-- 7. From fact_patient_visits, compute a running (cumulative) total of treatment_cost per hospital_id, ordered by arrival_datetime. Show visit_id, treatment_cost, running_total.

--8. From fact_financials, use LAG to compute the previous month's revenue for each hospital, and calculate the change. Show hospital_id, year_int, month_name, revenue, prev_revenue, change.

--9. From dim_doctor, compute each doctor's salary percentile rank within their specialty. Show doctor_name, specialty, annual_salary, salary_percentile.

--10. From fact_patient_visits, for each hospital find the 3rd most expensive visit's treatment cost using NTH_VALUE.

-- 11. From fact_patient_visits, compute for each hospital: total visits, emergency visits only, ICU-required visits only, weekend visits (use dim_date.is_weekend). Use the FILTER clause instead of CASE WHEN.

-- 12. From fact_financials joined with dim_hospital, compute total revenue with subtotals: per hospital per month, per hospital (all months), and grand total. Use ROLLUP.
