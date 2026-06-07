/*
================================================================
						PHASE 2: MEDIUM
================================================================
*/

-- 1. From dim_hospital, retrieve hospital_name, city, beds, icu_beds where beds > 500 AND teaching_hospital = true. Sort by beds descending.

-- 2. From dim_patient, find patients whose risk_category IN ('High', 'Critical') AND chronic_condition_count > 2. Show patient_id, age, gender, risk_category, chronic_condition_count.

-- 3. From dim_doctor, find doctors whose specialty contains 'Cardio' (case-insensitive) AND years_experience > 10. Show doctor_name, specialty, grade, years_experience.

-- 4. From fact_patient_visits, retrieve visits where severity_level BETWEEN 3 AND 5 AND admission_type = 'Emergency'. Show visit_id, patient_id, severity_level, wait_time_minutes.

-- 5. From dim_department, retrieve departments that are NOT 'Administrative' AND are ICU capable. Show all columns, ordered by department_name.

-- 6. From fact_patient_visits, filter visits where diagnosis_category IN ('Cardiac', 'Respiratory', 'Neurological'). Show visit_id, patient_id, diagnosis_category, treatment_cost. Order by treatment_cost DESC, limit 20.

-- 7. Create dim_hospital_tier with: tier_id VARCHAR(20) PRIMARY KEY, hospital_id VARCHAR(20), tier_label VARCHAR(50), assigned_date DATE. Insert 3 rows using a single multi-row INSERT.

-- 8. Update dim_patient: set risk_category = 'Critical' for all patients who have 4+ chronic conditions AND whose current risk_category is 'High'.

-- 9. From dim_hospital, find hospitals where hospital_name LIKE 'Royal%' OR beds > 1000, but EXCLUDE private hospitals (private_int = false). Display hospital_id, hospital_name, beds, private_int.

-- 10. Add a CHECK constraint to dim_patient ensuring age BETWEEN 0 AND 120. Also set gender to NOT NULL.

-- 11. From fact_staffing, find shifts where month_name = 1, overtime_hours > 8, AND burnout_risk_index > 7. Show shift_id, hospital_id, shift_type, burnout_risk_index, overtime_hours.

-- 12. Retrieve all distinct non-NULL values of insurance_type from fact_patient_visits, ordered alphabetically.

