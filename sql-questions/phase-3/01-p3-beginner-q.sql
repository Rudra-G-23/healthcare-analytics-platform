/*
================================================================
						PHASE 3: BEGINNER
================================================================
*/

-- 1. Join dim_patient and fact_patient_visits to display patient_id, age, gender, visit_id, admission_type, treatment_cost.

-- 2. Join dim_hospital to fact_financials showing all hospitals, even those with no financial data. Show hospital_name, city, revenue (NULL if no record exists).

-- 3. Join fact_financials to dim_hospital showing all financial records, even orphaned ones with no hospital match. Show financial_record_id, hospital_id from financials, hospital_name (NULL if unmatched).

-- 4. Join dim_patient and fact_patient_visits with a FULL OUTER JOIN. Show all patients (even with no visits) and all visits (even with no matching patient record).

-- 5. Join dim_doctor and dim_hospital to show doctor_name, specialty, grade, hospital_name, city for all doctors.

-- 6. Join fact_patient_visits with dim_department to show visit_id, admission_type, department_name, type (department type), icu_capable. Filter for only ICU-capable departments.

-- 7. Join dim_patient, fact_patient_visits, and dim_hospital to show patient_id, age, risk_category, admission_type, hospital_name, city. Limit to 20 rows.

-- 8. Find pairs of doctors who work at the same hospital. Show doctor1_name, doctor2_name, hospital_id, both specialties.

-- 9. Use a CROSS JOIN between dim_doctor and dim_department to generate all possible doctor-department assignments. Show doctor name, department name. Limit to 50.

-- 10. Write two separate SELECT queries (Emergency visits and ICU-required visits from fact_patient_visits) and combine them with UNION to get a unique list. Show visit_id, patient_id, admission_type.

-- 11. Repeat Q10 using UNION ALL instead of UNION. Compare row counts.

-- 12. Find patient IDs who had BOTH an Emergency admission AND a Planned admission (appear in both filtered sets).
