/*
================================================================
					PHASE 7: BEGINNER QUESTIONS
================================================================
*/

-- 1. Create a PL/pgSQL function get_risk_label(risk_category VARCHAR) RETURNS VARCHAR that returns: 'LOW' for 'Low', 'MEDIUM' for 'Medium', 'HIGH' for 'High', 'CRITICAL' for 'Critical', 'UNKNOWN' for anything else.

-- 2. Create a stored procedure sp_refresh_hospital_stats() that runs ANALYZE on fact_patient_visits and refreshes mv_hospital_scorecard (if it exists). Call it.

-- 3. Create a B-tree index on fact_patient_visits.hospital_id to speed up joins. Verify with EXPLAIN.

-- 4. Create a composite index on fact_patient_visits(hospital_id, admission_type) to optimise queries filtering on both columns. Demonstrate with EXPLAIN.

-- 5. Run EXPLAIN SELECT * FROM fact_patient_visits WHERE hospital_id = 'H001' both without and with an index. Identify: Seq Scan, Index Scan, Bitmap Index Scan nodes.

-- 6. Run EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM fact_patient_visits WHERE severity_level >= 4. Identify estimated vs actual rows and whether the estimate is accurate.

-- 7. Run VACUUM ANALYZE fact_patient_visits and VACUUM FULL fact_staffing. Explain the difference. Check pg_stat_user_tables before and after.

-- 8. Create a trigger function trg_audit_visits() that writes to audit_log whenever a row in fact_patient_visits is INSERTED or UPDATED. Include: table name, operation, old/new visit_id, timestamp.

-- 9. Using the trigger function from Q8, create an AFTER INSERT OR UPDATE trigger on fact_patient_visits called audit_visits_trigger.

-- 10. Create a partial index on fact_patient_visits(hospital_id) where is_deleted = false (or mortality_flag = false). Show EXPLAIN with and without the partial index.

-- 11. Create a Hash index on dim_patient.insurance_type. Explain when it's faster than B-tree and its limitations.

-- 12. Simulate index bloat by running many UPDATEs on fact_patient_visits. Check index size with pg_relation_size. Run REINDEX INDEX and compare size.
