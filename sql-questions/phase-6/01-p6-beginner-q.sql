/*
================================================================
					PHASE 6: BEGINNER QUESTIONS
================================================================
*/

-- 1. From fact_patient_visits, show all visits where treatment_cost is above the overall average. Use a scalar subquery.

-- 2. From dim_hospital, find hospitals whose hospital_id appears in fact_financials with total revenue above 5 million.

-- 3. From dim_hospital, show only hospitals that have at least one record in fact_financials. Use EXISTS.

-- 4. From dim_doctor, find doctors with NO recorded visits in fact_patient_visits. Use NOT EXISTS.

-- 5. Write a CTE named hospital_visit_counts that counts visits per hospital from fact_patient_visits. Then SELECT the top 10 from it.

-- 6. Write two CTEs: high_risk_patients (patients with risk_category IN ('High','Critical')) and costly_visits (visits with treatment_cost > 5000). Then join them.

-- 7. Create a view vw_hospital_financial_summary that joins dim_hospital with aggregated fact_financials to show hospital name, total revenue, avg profit margin, and latest year. Use it in a SELECT.

--8. From fact_patient_visits, compute the average treatment cost per admission_type in a subquery, then query results above 3000.

-- 9. Create a temporary table tmp_high_burnout populated with shifts from fact_staffing where burnout_risk_index > 8. Query it. Confirm it disappears after session ends.

-- 10. From fact_patient_visits, find visits where treatment_cost is above that visit's hospital average. Use a correlated subquery.

-- 11. From dim_department, show each department's name alongside the total number of visits it has had (from fact_patient_visits). Use a correlated subquery in SELECT.

-- 12. Rewrite the following complex query using CTEs for clarity: Find the top 5 hospitals by total ICU visits, showing hospital name, total ICU visits, and total ICU treatment cost.
