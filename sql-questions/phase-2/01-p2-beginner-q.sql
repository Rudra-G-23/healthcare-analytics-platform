/*
================================================================
						PHASE 2: BEGINNER
================================================================
*/


-- 1. Retrieve all columns and all rows from dim_patient to get a first look at the data.

-- 2. Retrieve patient_id, age, gender, and risk_category from dim_patient.

-- 3. Find all unique values of admission_type from fact_patient_visits to understand what categories exist.

-- 4. From dim_hospital, retrieve hospital_name, city, and beds ordered by beds descending. Show only the first 10.

-- 5. Retrieve all records from dim_department where icu_capable = true.

-- 6. Create a new empty table dim_patient_backup with the same columns as dim_patient, but no data.

-- 7. Add a contact_email VARCHAR(150) column to the dim_doctor table.

-- 8. Rename contact_email to work_email in dim_doctor.

-- 9. Drop the work_email column from dim_doctor.

-- 10. Insert one new record into dim_region. Choose values for all columns. Always list column names explicitly.

-- 11. Update the city of the hospital with hospital_id = 'H001' to '"Harrogate"'.

-- 12. Delete all records from dim_patient where risk_category = 'Unknown'.

-- 13. Delete new record what you made on Q10.
