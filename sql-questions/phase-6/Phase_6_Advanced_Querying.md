# 📓 Phase 6 — Advanced Querying Techniques
## Subqueries · CTEs · Views · Materialized Views · Temp Tables · LATERAL · Recursive CTEs
### PostgreSQL | NHS Hospital Analytics | Data Science Perspective

---

## 📋 Phase Topics

| Concept | Commands & Keywords |
|---|---|
| Subqueries | Scalar, IN/NOT IN, EXISTS/NOT EXISTS, Correlated, Derived Table (in FROM), in SELECT |
| CTEs | `WITH`, Multi-CTE, chained CTEs, CTE in DML |
| Recursive CTEs | `WITH RECURSIVE`, hierarchical/graph traversal |
| Views | `CREATE VIEW`, `CREATE OR REPLACE VIEW`, updatable views, `DROP VIEW` |
| Materialized Views | `CREATE MATERIALIZED VIEW`, `REFRESH MATERIALIZED VIEW`, indexes on matviews |
| Temp Tables | `CREATE TEMP TABLE`, session-scoped, ON COMMIT DROP |
| CTAS | `CREATE TABLE AS SELECT` |
| LATERAL | `LATERAL` subquery in FROM |

---

## 🟢 Beginner

---

### Q1. Scalar Subquery: Average Treatment Cost Threshold
From `fact_patient_visits`, show all visits where `treatment_cost` is above the overall average. Use a scalar subquery.
> 🔍 **Hint:** `WHERE treatment_cost > (SELECT AVG(treatment_cost) FROM fact_patient_visits)`.
> 📚 **Concept:** A scalar subquery returns exactly one row and one column — it can be used wherever a single value is expected. The inner query is executed once and the result is compared against each outer row. For large tables, this is efficient because the subquery result is cached. This is the simplest form of subquery — and the foundation for understanding all others.
> 🐘 **PG Ref:** [Scalar subqueries](https://www.postgresql.org/docs/current/sql-expressions.html#SQL-SYNTAX-SCALAR-SUBQUERIES)
> 🔬 **DS Equivalent:** `df[df['treatment_cost'] > df['treatment_cost'].mean()]` — filtering above the mean in pandas.

---

### Q2. Subquery in WHERE: Hospitals Above Average Revenue
From `dim_hospital`, find hospitals whose `hospital_id` appears in `fact_financials` with total revenue above 5 million.
> 🔍 **Hint:** `WHERE hospital_id IN (SELECT hospital_id FROM fact_financials GROUP BY hospital_id HAVING SUM(revenue) > 5000000)`.
> 📚 **Concept:** Subquery in `IN (...)` returns a column of values for comparison. The outer WHERE checks membership. This is equivalent to an INNER JOIN + HAVING, but subqueries are sometimes more readable for "membership" logic. For large subquery results (1000+ rows), a JOIN is typically faster.
> 🐘 **PG Ref:** [IN subquery](https://www.postgresql.org/docs/current/functions-subquery.html#FUNCTIONS-SUBQUERY-IN)
> 🔬 **DS Equivalent:** `df[df['hospital_id'].isin(high_revenue_hospitals)]` — filtering by membership in a derived set.

---

### Q3. EXISTS: Hospitals That Have Financial Records
From `dim_hospital`, show only hospitals that have at least one record in `fact_financials`. Use EXISTS.
> 🔍 **Hint:** `WHERE EXISTS (SELECT 1 FROM fact_financials WHERE fact_financials.hospital_id = dim_hospital.hospital_id)`.
> 📚 **Concept:** `EXISTS` returns TRUE if the subquery returns at least one row. It short-circuits — stops as soon as one matching row is found. `SELECT 1` is the standard idiom (the value returned doesn't matter). EXISTS is always NULL-safe (unlike NOT IN) and is generally faster than IN for large subqueries because it stops at the first match.
> 🐘 **PG Ref:** [EXISTS](https://www.postgresql.org/docs/current/functions-subquery.html#FUNCTIONS-SUBQUERY-EXISTS)
> 🔬 **DS Equivalent:** `dim_hospital[dim_hospital['hospital_id'].isin(fact_financials['hospital_id'])]` — equivalent result; EXISTS is the SQL idiom for membership checking.

---

### Q4. NOT EXISTS: Doctors With No Visits
From `dim_doctor`, find doctors with NO recorded visits in `fact_patient_visits`. Use NOT EXISTS.
> 🔍 **Hint:** `WHERE NOT EXISTS (SELECT 1 FROM fact_patient_visits WHERE fact_patient_visits.doctor_id = dim_doctor.doctor_id)`.
> 📚 **Concept:** `NOT EXISTS` is the NULL-safe anti-join pattern — preferred over `NOT IN (subquery)` because NULL values in the subquery don't cause the entire condition to return UNKNOWN. `NOT EXISTS` evaluates to TRUE only when the subquery returns zero rows — clean, predictable, and safe.
> 🐘 **PG Ref:** [NOT EXISTS](https://www.postgresql.org/docs/current/functions-subquery.html#FUNCTIONS-SUBQUERY-EXISTS)
> 🔬 **DS Equivalent:** `dim_doctor[~dim_doctor['doctor_id'].isin(fact_patient_visits['doctor_id'].dropna())]` — note the `dropna()` is required to match NOT EXISTS NULL-safety.

---

### Q5. Basic CTE: Top 10 Hospitals by Visit Count
Write a CTE named `hospital_visit_counts` that counts visits per hospital from `fact_patient_visits`. Then SELECT the top 10 from it.
> 🔍 **Hint:** `WITH hospital_visit_counts AS (SELECT hospital_id, COUNT(*) AS visit_count FROM fact_patient_visits GROUP BY hospital_id) SELECT * FROM hospital_visit_counts ORDER BY visit_count DESC LIMIT 10`.
> 📚 **Concept:** A CTE (Common Table Expression) defined with `WITH` is a named temporary result set. It improves readability by naming intermediate results. In PostgreSQL 12+, CTEs are inlined by default (the planner optimises them as if they were subqueries). Use `WITH cte AS MATERIALIZED (...)` to force physical materialisation (computed once and stored).
> 🐘 **PG Ref:** [WITH queries (CTEs)](https://www.postgresql.org/docs/current/queries-with.html)
> 🔬 **DS Equivalent:** `hospital_visit_counts = fact_patient_visits.groupby('hospital_id').size().reset_index(name='visit_count')` — a named intermediate DataFrame.

---

### Q6. Multi-CTE: Patient Risk and Visit Cost Analysis
Write two CTEs: `high_risk_patients` (patients with risk_category IN ('High','Critical')) and `costly_visits` (visits with treatment_cost > 5000). Then join them.
> 🔍 **Hint:** `WITH high_risk AS (...), costly AS (...) SELECT ... FROM high_risk JOIN costly ON ...`.
> 📚 **Concept:** Multiple CTEs are separated by commas in the WITH clause. Later CTEs can reference earlier CTEs. This creates a pipeline of named transformations — equivalent to chaining DataFrames in pandas. Multi-CTE queries self-document analytical logic by naming each step.
> 🐘 **PG Ref:** [Multiple CTEs](https://www.postgresql.org/docs/current/queries-with.html)
> 🔬 **DS Equivalent:** `step1 = df[condition1]; step2 = df[condition2]; result = step1.merge(step2)` — named intermediate DataFrames chained together.

---

### Q7. Simple View: Active Hospital Financial Summary
Create a view `vw_hospital_financial_summary` that joins `dim_hospital` with aggregated `fact_financials` to show hospital name, total revenue, avg profit margin, and latest year. Use it in a SELECT.
> 🔍 **Hint:** `CREATE VIEW vw_hospital_financial_summary AS SELECT dh.hospital_name, ... FROM dim_hospital dh JOIN ... GROUP BY ...`.
> 📚 **Concept:** A VIEW is a stored query — it has no physical data, it runs the underlying query each time it's SELECTed. Views simplify complex queries (users write `SELECT * FROM vw_...` instead of the full join). Views also provide security abstraction — grant access to the view while restricting direct table access.
> 🐘 **PG Ref:** [CREATE VIEW](https://www.postgresql.org/docs/current/sql-createview.html)
> 🔬 **DS Equivalent:** A reusable function that returns a DataFrame — `def get_hospital_summary(): return fact.merge(dim).groupby(...)`. Each call runs the computation.

---

### Q8. Subquery in FROM (Derived Table): Average Per Admission Type
From `fact_patient_visits`, compute the average treatment cost per `admission_type` in a subquery, then query results above 3000.
> 🔍 **Hint:** `SELECT * FROM (SELECT admission_type, AVG(treatment_cost) AS avg_cost FROM fact_patient_visits GROUP BY admission_type) AS avg_costs WHERE avg_cost > 3000`.
> 📚 **Concept:** A subquery in FROM is called a "derived table" or "inline view". It must be aliased. PostgreSQL can often inline it (treat it as if the subquery were folded into the outer query). Derived tables allow filtering on aggregate results without HAVING — though HAVING is usually cleaner for simple cases.
> 🐘 **PG Ref:** [Subquery in FROM](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-SUBQUERIES)
> 🔬 **DS Equivalent:** `avg_costs = df.groupby('admission_type')['treatment_cost'].mean().reset_index(); avg_costs[avg_costs['treatment_cost'] > 3000]`.

---

### Q9. Temp Table: Staging High-Burnout Shifts
Create a temporary table `tmp_high_burnout` populated with shifts from `fact_staffing` where `burnout_risk_index > 8`. Query it. Confirm it disappears after session ends.
> 🔍 **Hint:** `CREATE TEMP TABLE tmp_high_burnout AS SELECT * FROM fact_staffing WHERE burnout_risk_index > 8`.
> 📚 **Concept:** `TEMP TABLE` (or `TEMPORARY TABLE`) exists only for the current session — it's automatically dropped when the session ends. Multiple sessions can create temp tables with the same name without conflict (each session has its own). Use `ON COMMIT DROP` to make a temp table last only for the current transaction. Temp tables are ideal for multi-step analytical pipelines.
> 🐘 **PG Ref:** [Temporary tables](https://www.postgresql.org/docs/current/sql-createtable.html)
> 🔬 **DS Equivalent:** A local variable in a function — exists only within the function scope. Or a pandas DataFrame in memory — gone when the Python process ends.

---

### Q10. Correlated Subquery: Visits Above Hospital Average
From `fact_patient_visits`, find visits where `treatment_cost` is above that visit's hospital average. Use a correlated subquery.
> 🔍 **Hint:** `WHERE fpv.treatment_cost > (SELECT AVG(fpv2.treatment_cost) FROM fact_patient_visits fpv2 WHERE fpv2.hospital_id = fpv.hospital_id)`.
> 📚 **Concept:** A correlated subquery references a column from the outer query — it runs once per outer row. This is the same as `AVG() OVER (PARTITION BY hospital_id)` window function but expressed as a subquery. Correlated subqueries are often rewritten as window functions for performance — the window version is O(N log N) while the correlated subquery may be O(N²) without good indexes.
> 🐘 **PG Ref:** [Correlated subqueries](https://www.postgresql.org/docs/current/functions-subquery.html)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id')['treatment_cost'].transform('mean')` — the `.transform()` method propagates group aggregates back to each row, equivalent to a correlated subquery.

---

### Q11. Subquery in SELECT: Department Visit Count per Row
From `dim_department`, show each department's name alongside the total number of visits it has had (from `fact_patient_visits`). Use a correlated subquery in SELECT.
> 🔍 **Hint:** `SELECT department_name, (SELECT COUNT(*) FROM fact_patient_visits WHERE department_id = dd.department_id) AS visit_count FROM dim_department dd`.
> 📚 **Concept:** A subquery in SELECT computes one value per row of the outer query — equivalent to a LEFT JOIN with aggregation. If the subquery returns more than one row, PostgreSQL throws an error. Always prefer a LEFT JOIN + GROUP BY over a subquery in SELECT for performance — the join version is optimised more aggressively by the planner.
> 🐘 **PG Ref:** [Subquery in SELECT list](https://www.postgresql.org/docs/current/sql-expressions.html#SQL-SYNTAX-SCALAR-SUBQUERIES)
> 🔬 **DS Equivalent:** `dim_dept.assign(visit_count=dim_dept['department_id'].map(fact_visits.groupby('department_id')['visit_id'].count()))` — adding a mapped aggregate column to a DataFrame.

---

### Q12. CTE for Readability: Breaking Down a Complex Report
Rewrite the following complex query using CTEs for clarity: Find the top 5 hospitals by total ICU visits, showing hospital name, total ICU visits, and total ICU treatment cost.
> 🔍 **Hint:** CTE 1: filter ICU visits. CTE 2: aggregate per hospital. CTE 3: join to dim_hospital for names. Final: ORDER BY + LIMIT 5.
> 📚 **Concept:** CTEs serve as "SQL comments with results" — they name each analytical step. Breaking a complex query into 3–4 named CTEs makes it readable by a colleague without SQL expertise. The test: can a non-technical person understand what `WITH icu_visits AS (...)` does just from the name? Good CTE naming is a professional SQL skill.
> 🐘 **PG Ref:** [CTEs for readability](https://www.postgresql.org/docs/current/queries-with.html)
> 🔬 **DS Equivalent:** Named intermediate DataFrames: `icu_visits = ...`, `icu_by_hospital = ...`, `icu_named = ...` — each step named and self-documenting.

---

## 🟡 Medium
> 2–3 tables · 2+ concepts combined

---

### Q1. CTE Chain: Patient Risk Journey
Build a 3-step CTE chain: (1) `patient_visits` — join dim_patient + fact_patient_visits, (2) `high_severity` — filter severity >= 4 from step 1, (3) `patient_summary` — aggregate by patient, count visits, avg cost. Final SELECT: patients with 2+ high-severity visits.

> 🔍 **Hint:** Tables: `dim_patient`, `fact_patient_visits`. Concepts: Multi-CTE chain, each CTE referencing the previous, final filter.

> 📚 **Concept:** CTE chains create a linear data pipeline — each stage processes and narrows the data. `high_severity` references `patient_visits`, `patient_summary` references `high_severity`. This mirrors a pandas pipeline: `df.pipe(step1).pipe(step2).pipe(step3)`. In PostgreSQL 12+, inline CTEs are optimised as subqueries. For large intermediate results that are accessed multiple times, use `MATERIALIZED` to compute once.
> 🐘 **PG Ref:** [Chained CTEs](https://www.postgresql.org/docs/current/queries-with.html)
> 🔬 **DS Equivalent:** `df.pipe(join_patient).pipe(filter_high_severity).pipe(aggregate_patient)` — functional pipeline in pandas.

---

### Q2. Materialized View for Pre-Computed Hospital Scorecard
Create a materialized view `mv_hospital_scorecard` that pre-computes: hospital name, region, total visits, avg wait time, avg satisfaction, mortality rate, readmission rate. Refresh it. Create an index on the materialized view.

> 🔍 **Hint:** `CREATE MATERIALIZED VIEW mv_hospital_scorecard AS SELECT ...`; `REFRESH MATERIALIZED VIEW mv_hospital_scorecard`; `CREATE INDEX ON mv_hospital_scorecard(hospital_id)`.

> 📚 **Concept:** A MATERIALIZED VIEW stores the query result physically on disk — unlike a regular VIEW which reruns the query each time. Queries on a matview are instant (reads from stored data). The trade-off: data is stale until `REFRESH MATERIALIZED VIEW` is run. `REFRESH MATERIALIZED VIEW CONCURRENTLY` (requires a unique index) refreshes without locking reads — essential for production dashboards. Use matviews for expensive aggregation queries that power dashboards.
> 🐘 **PG Ref:** [CREATE MATERIALIZED VIEW](https://www.postgresql.org/docs/current/sql-creatematerializedview.html) | [REFRESH](https://www.postgresql.org/docs/current/sql-refreshmaterializedview.html)
> 🔬 **DS Equivalent:** A cached feature table in a feature store — pre-computed once, served from cache for low-latency model inference. Refreshing the matview = re-running the feature pipeline.

---

### Q3. Recursive CTE: Simulated Escalation Hierarchy
The `dim_department` doesn't have a self-referencing hierarchy, but suppose `dim_doctor` had a `supervisor_id VARCHAR(20)` column referencing another `doctor_id`. Write a recursive CTE to traverse the management hierarchy for a given top-level doctor.

> 🔍 **Hint:** First add `supervisor_id` column. Then: `WITH RECURSIVE hierarchy AS (SELECT doctor_id, doctor_name, 1 AS level FROM dim_doctor WHERE supervisor_id IS NULL UNION ALL SELECT d.doctor_id, d.doctor_name, h.level + 1 FROM dim_doctor d JOIN hierarchy h ON d.supervisor_id = h.doctor_id) SELECT * FROM hierarchy`.

> 📚 **Concept:** Recursive CTEs have two parts: (1) Anchor member — the starting rows (WHERE supervisor_id IS NULL = top level), (2) Recursive member — joins the CTE to itself, adding one level per iteration. PostgreSQL repeats the recursive member until no new rows are added. Use `level` counter and `LIMIT` depth to prevent infinite recursion on cyclic data.
> 🐘 **PG Ref:** [WITH RECURSIVE](https://www.postgresql.org/docs/current/queries-with.html#QUERIES-WITH-RECURSIVE)
> 🔬 **DS Equivalent:** BFS/DFS graph traversal: `networkx.descendants(G, root_node)` — recursive CTE is SQL's tree/graph traversal mechanism.

---

### Q4. NOT EXISTS vs LEFT JOIN ANTI JOIN vs NOT IN — Performance Comparison
For the same query (departments with no visits), write three versions: (1) NOT EXISTS, (2) LEFT JOIN IS NULL, (3) NOT IN. Use EXPLAIN to compare query plans. Note when they differ.

> 🔍 **Hint:** Tables: `dim_department`, `fact_patient_visits`. Concepts: Three anti-join patterns, EXPLAIN comparison.

> 📚 **Concept:** PostgreSQL typically generates the same hash anti-join plan for all three patterns. NOT EXISTS is usually preferred for code clarity and NULL safety. NOT IN is the most dangerous (NULL trap). LEFT JOIN IS NULL is most explicit about the anti-join intent. The planner recognises all three as anti-joins and optimises them identically when statistics are good. Use `EXPLAIN` to verify — the plan type (Hash Anti Join) confirms equivalence.
> 🐘 **PG Ref:** [NOT EXISTS vs NOT IN](https://www.postgresql.org/docs/current/functions-subquery.html)
> 🔬 **DS Equivalent:** Three ways to subtract sets in pandas: `~isin()`, merge+filter NaN, set difference — same result, different code.

---

### Q5. CTE with DML: Archive and Delete in One Statement
Use a CTE to simultaneously INSERT old visits into `fact_patient_visits_archive` AND DELETE them from `fact_patient_visits`. Use the `WITH ... AS (DELETE ... RETURNING *) INSERT INTO archive SELECT * FROM deleted_cte`.

> 🔍 **Hint:** `WITH deleted AS (DELETE FROM fact_patient_visits WHERE arrival_datetime < '2022-01-01' RETURNING *) INSERT INTO fact_patient_visits_archive SELECT *, NOW() FROM deleted`.

> 📚 **Concept:** CTEs can contain DML statements (INSERT, UPDATE, DELETE) in PostgreSQL — a powerful feature. `DELETE ... RETURNING *` captures deleted rows as a result set, which the outer INSERT then consumes. This atomic archive-and-delete runs in one transaction — either both succeed or neither does. This is the cleanest implementation of the archival pattern from Phase 2.
> 🐘 **PG Ref:** [Data-modifying CTEs](https://www.postgresql.org/docs/current/queries-with.html#QUERIES-WITH-MODIFYING)
> 🔬 **DS Equivalent:** A transactional pipeline: `archive_df = df[condition]; df = df[~condition]; archive_df.to_sql('archive')` — but SQL's CTE version is atomic; the pandas version is not.

---

### Q6. View with Row-Level Security Context
Create a view `vw_my_hospital_visits` that only shows visits for hospitals matching `CURRENT_USER`'s hospital. (Simulate: assume users are named after hospital IDs like 'H001'.) Show how views can enforce data scoping.

> 🔍 **Hint:** `CREATE VIEW vw_my_hospital_visits AS SELECT * FROM fact_patient_visits WHERE hospital_id = CURRENT_USER`.

> 📚 **Concept:** Views with `CURRENT_USER` or `SESSION_USER` in the WHERE clause enforce row-level access control — each user sees only their own data. This is a lightweight alternative to PostgreSQL's Row-Level Security (RLS). However, a view is owned by its creator — if created with `SECURITY DEFINER`, it runs as the creator's permissions. `SECURITY INVOKER` (default) runs as the calling user's permissions.
> 🐘 **PG Ref:** [Security in views](https://www.postgresql.org/docs/current/sql-createview.html#SQL-CREATEVIEW-SECURITY) | [Row-level security](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
> 🔬 **DS Equivalent:** A pandas DataFrame filtered to the current user's hospital — the SQL view enforces this at the database layer without trusting application-level filtering.

---

### Q7. Subquery Pushdown: Optimising a Correlated Subquery
Rewrite a correlated subquery that finds visits above their hospital's average cost as: (1) the original correlated subquery version, (2) a window function version, (3) a CTE + join version. Use EXPLAIN to compare all three.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: Correlated subquery O(N²), window function O(N log N), CTE version.

> 📚 **Concept:** Correlated subqueries execute once per outer row — O(N×M). Window functions compute the aggregate once per partition in a single sorted pass — O(N log N). The CTE + join version pre-aggregates per hospital (O(M)) then joins back (O(N)). For large fact tables, the performance difference is dramatic: 100M visits × 1000 hospitals = correlated subquery runs 100M subqueries vs window running one pass. This comparison is the textbook argument for learning window functions.
> 🐘 **PG Ref:** [Subquery vs window function](https://www.postgresql.org/docs/current/tutorial-window.html)
> 🔬 **DS Equivalent:** `df.apply(lambda row: row['cost'] > hospital_avgs[row['hospital_id']], axis=1)` (slow, O(N)) vs `df.groupby('hospital_id')['cost'].transform('mean')` (fast, vectorised) — same lesson in pandas.

---

### Q8. Temp Table Pipeline: Multi-Step Analytical Workflow
Build a 3-step temp table pipeline: (1) `tmp_visit_flags` — add computed flag columns to visits, (2) `tmp_hospital_summary` — aggregate from step 1, (3) `tmp_final_report` — join step 2 to dim_hospital for names. Each step indexes the join key.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_hospital`. Concepts: CREATE TEMP TABLE AS SELECT, CREATE INDEX on temp table, chained pipeline.

> 📚 **Concept:** Temp table pipelines are more flexible than CTE chains when: (a) intermediate results are large and queried multiple times, (b) you need to add indexes to intermediate results, (c) debugging — you can SELECT from each step independently. The key advantage over CTEs: you can `CREATE INDEX` on a temp table (CTEs cannot be indexed). For pipelines with multiple downstream queries from the same intermediate result, temp tables + indexes are faster.
> 🐘 **PG Ref:** [Temp tables vs CTEs](https://www.postgresql.org/docs/current/sql-createtable.html)
> 🔬 **DS Equivalent:** Named DataFrames in a pipeline with `.reset_index()` between steps — each step materialised in memory, accessible by name for debugging. Equivalent to Apache Airflow tasks that write intermediate results to S3.

---

### Q9. LATERAL JOIN for Top-3 Visits per Patient
For each patient (limited to 20 patients for demo), find their 3 most recent visits using a LATERAL join. Show patient_id, age, and the 3 most recent visit dates and costs.

> 🔍 **Hint:** Tables: `dim_patient`, `fact_patient_visits`. Concepts: `LATERAL (SELECT ... FROM fact_patient_visits WHERE patient_id = dp.patient_id ORDER BY arrival_datetime DESC LIMIT 3) top3`.

> 📚 **Concept:** LATERAL enables a subquery in FROM to reference columns from the preceding table in FROM — each outer row spawns its own subquery execution. It's PostgreSQL's "foreach row, run this query" — more powerful than correlated subqueries in SELECT because LATERAL can return multiple rows and multiple columns. This is the most natural way to implement "top-N per group" in PostgreSQL.
> 🐘 **PG Ref:** [LATERAL join](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-LATERAL)
> 🔬 **DS Equivalent:** `df.groupby('patient_id').apply(lambda g: g.nlargest(3, 'arrival_datetime'))` — per-group top-N in pandas.

---

### Q10. View with Aggregation: Hospital Quality Dashboard
Create a view `vw_quality_dashboard` that joins `fact_patient_visits`, `fact_staffing`, `dim_hospital`, and shows: hospital_name, region_id, avg_satisfaction, readmission_rate, avg_burnout, mortality_rate. Refresh by dropping and recreating.

> 🔍 **Hint:** `CREATE OR REPLACE VIEW vw_quality_dashboard AS SELECT ...` — joins multiple tables.

> 📚 **Concept:** `CREATE OR REPLACE VIEW` updates an existing view without dropping dependent objects. Views on complex multi-table joins are the standard BI pattern — BI tools (Tableau, Power BI, Metabase) connect directly to views rather than raw tables. Regular views are "virtual tables" — no physical storage, no staleness, but no index support. Use materialized views when query latency matters.
> 🐘 **PG Ref:** [CREATE OR REPLACE VIEW](https://www.postgresql.org/docs/current/sql-createview.html)
> 🔬 **DS Equivalent:** A reusable function that returns a merged/aggregated DataFrame — executed on every call, like a regular view. A cached version (with `functools.lru_cache`) is more like a materialized view.

---

### Q11. Recursive CTE: Generate Date Series
Use a recursive CTE to generate a complete list of months from January 2020 to December 2025. Then LEFT JOIN to `fact_financials` to find which months are missing data per hospital.

> 🔍 **Hint:** `WITH RECURSIVE months AS (SELECT '2020-01-01'::date AS month_start UNION ALL SELECT month_start + INTERVAL '1 month' FROM months WHERE month_start < '2025-12-01') SELECT * FROM months`.

> 📚 **Concept:** Recursive CTE for sequence generation is a clean alternative to `generate_series()` when you need date-period series without a table function. The anchor = starting date; the recursive member adds one period each iteration. The termination condition (`WHERE date < limit`) prevents infinite recursion. Using `generate_series()` is simpler for date ranges — but recursive CTEs work in all SQL dialects that support them (unlike generate_series which is PostgreSQL-specific).
> 🐘 **PG Ref:** [WITH RECURSIVE for sequences](https://www.postgresql.org/docs/current/queries-with.html#QUERIES-WITH-RECURSIVE)
> 🔬 **DS Equivalent:** `pd.date_range('2020-01', '2025-12', freq='MS')` — pandas date range generation. The recursive CTE is the SQL equivalent, especially in databases without generate_series.

---

### Q12. CTE for Unpivot + Re-Aggregate
Use a CTE to unpivot `fact_financials` cost columns (operational_cost, staffing_cost, icu_cost, emergency_department_cost) into long format, then re-aggregate to find the highest-cost category per hospital.

> 🔍 **Hint:** CTE uses UNION ALL for unpivoting, then outer query uses GROUP BY + MAX or conditional aggregation.

> 📚 **Concept:** CTE-based unpivot (long format) + re-aggregation is a powerful pattern for "which category has the highest value per group?" After unpivoting to (hospital_id, cost_type, cost_value), a simple `MAX(cost_value)` + join-back gives the winning category. This avoids the complex CASE WHEN expressions needed when data is in wide format.
> 🐘 **PG Ref:** [CTE with UNION ALL](https://www.postgresql.org/docs/current/queries-with.html)
> 🔬 **DS Equivalent:** `pd.melt(df, id_vars=['hospital_id'], ...).groupby('hospital_id').apply(lambda g: g.loc[g['cost_value'].idxmax()])` — melt + idxmax per group in pandas.

---

## 🟠 Medium Hard
> Mixed phases · 3–4 tables · Steps required

---

### Q1. Recursive CTE: Simulate Patient Escalation Path
Given that patients with severity >= 4 escalate to ICU, and ICU patients with LOS > 72h escalate to specialist care, use a recursive CTE to simulate a 3-level escalation path. Show each patient's current care level.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: WITH RECURSIVE, UNION ALL anchor + recursive member with escalation conditions, level counter.

> 🪜 **Steps:**
> 1. Anchor: `SELECT patient_id, visit_id, severity_level, 'Standard' AS care_level, 1 AS step FROM fact_patient_visits WHERE severity_level < 4`.
> 2. Recursive: `UNION ALL SELECT ..., 'ICU', step + 1 WHERE severity_level >= 4 AND icu_required_flag = true`.
> 3. Further level: `UNION ALL SELECT ..., 'Specialist', step + 1 WHERE icu AND length_of_stay_hours > 72`.
> 4. Add `WHERE step <= 3` to prevent infinite recursion.
> 5. SELECT DISTINCT ON (patient_id) to get final level.

> 📚 **Concept:** Recursive CTEs simulate state machines — each iteration represents a state transition. The level counter guards against infinite recursion. `DISTINCT ON (patient_id)` (PostgreSQL-specific) gets the first row per patient after ordering by step DESC — the highest escalation level reached. State machine simulation is used in: clinical pathway analysis, workflow automation, and graph traversal.
> 🐘 **PG Ref:** [WITH RECURSIVE — state machine pattern](https://www.postgresql.org/docs/current/queries-with.html#QUERIES-WITH-RECURSIVE)
> 🔬 **DS Equivalent:** Markov chain state transitions — `current_state = transition_matrix.dot(current_state)` repeated until convergence. The recursive CTE is SQL's Markov chain simulator.

---

### Q2. Complex Multi-CTE Analytical Report
Build a 5-CTE analytical report: (1) `base_visits` — join visits + patients + hospitals, (2) `risk_segments` — assign risk tier using CASE WHEN, (3) `hospital_metrics` — aggregate by hospital + tier, (4) `benchmarks` — compute national averages per tier, (5) `final` — compare each hospital to benchmark, flag outliers.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_patient`, `dim_hospital`. Concepts: 5-CTE pipeline, JOIN, aggregation, comparison to benchmark, outlier flag.

> 🪜 **Steps:**
> 1. CTE 1: `base_visits` — 3-table join, select key columns.
> 2. CTE 2: `risk_segments` — CASE WHEN to segment by age + chronic conditions + severity.
> 3. CTE 3: `hospital_metrics` — GROUP BY hospital + risk_tier: avg cost, avg wait, mortality rate.
> 4. CTE 4: `benchmarks` — GROUP BY risk_tier only: national avg cost, wait, mortality.
> 5. CTE 5: JOIN hospital_metrics to benchmarks, compute deviation, CASE WHEN outlier flag.

> 📚 **Concept:** Multi-CTE analytical pipelines are the SQL equivalent of a pandas analysis notebook — each CTE is one cell with a named output. Five CTEs is manageable; 10+ CTEs starts to need documentation. Rule of thumb: if a CTE name doesn't clearly describe its content, rename it. This pipeline pattern is how dbt models work — each `.sql` file is one CTE-equivalent transformation.
> 🐘 **PG Ref:** [Multi-CTE pipelines](https://www.postgresql.org/docs/current/queries-with.html)
> 🔬 **DS Equivalent:** A Jupyter notebook with 5 named DataFrame steps — each cell builds on the previous. dbt equivalent: 5 staging/intermediate/mart models forming a DAG.

---

### Q3. Materialized View Strategy for a BI Dashboard
Design and implement a complete materialized view strategy for a hospital analytics dashboard: (1) Create `mv_daily_visit_summary` (daily aggregation by hospital), (2) Create a unique index for CONCURRENTLY refresh, (3) Write the REFRESH statement, (4) Show how queries against it are faster than the base table join.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_hospital`. Concepts: `CREATE MATERIALIZED VIEW`, `CREATE UNIQUE INDEX`, `REFRESH MATERIALIZED VIEW CONCURRENTLY`.

> 🪜 **Steps:**
> 1. `CREATE MATERIALIZED VIEW mv_daily_visit_summary AS SELECT hospital_id, DATE_TRUNC('day', arrival_datetime) AS day, COUNT(*) AS visit_count, AVG(treatment_cost), AVG(wait_time_minutes) FROM fact_patient_visits GROUP BY 1, 2`.
> 2. `CREATE UNIQUE INDEX ON mv_daily_visit_summary(hospital_id, day)`.
> 3. `REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_visit_summary` — non-blocking.
> 4. EXPLAIN on both matview query and original query — compare costs.

> 📚 **Concept:** `REFRESH MATERIALIZED VIEW CONCURRENTLY` requires a unique index but allows reads during refresh — critical for production dashboards that can't tolerate downtime. Without CONCURRENTLY, refresh locks the matview for reads. Schedule refresh via pg_cron extension or a cron job. The matview query scans pre-aggregated data (days × hospitals rows) vs the original (all fact rows). For a 100M-row fact table aggregated to 365 × 1000 = 365K rows, the matview is 274x smaller.
> 🐘 **PG Ref:** [REFRESH MATERIALIZED VIEW CONCURRENTLY](https://www.postgresql.org/docs/current/sql-refreshmaterializedview.html)
> 🔬 **DS Equivalent:** A pre-computed feature table refreshed daily by an Airflow DAG — serving model inference from cache rather than recomputing from raw data on every request.

---

### Q4. Temporal CTE: Point-in-Time Patient Profile
Using the SCD Type 2 table `dim_hospital_v2` (from Phase 2), write a CTE that retrieves the hospital record as it existed on a specific date (e.g., '2023-06-01'). Then join to visits on that date.

> 🔍 **Hint:** Tables: `dim_hospital_v2`, `fact_patient_visits`. Concepts: CTE for point-in-time filter, temporal JOIN.

> 🪜 **Steps:**
> 1. CTE `hospital_at_date`: `SELECT * FROM dim_hospital_v2 WHERE valid_from <= '2023-06-01' AND (valid_to > '2023-06-01' OR valid_to IS NULL)`.
> 2. JOIN to `fact_patient_visits` on `hospital_id` AND `arrival_datetime::date = '2023-06-01'`.
> 3. Show hospital attributes as they existed on that specific date.
> 4. Compare to current values — verify SCD2 captures the change.

> 📚 **Concept:** Point-in-time joins using SCD2 tables are the cornerstone of temporally correct analytics and ML feature engineering. The CTE `hospital_at_date` encapsulates the "as-of" logic cleanly — reusable across multiple queries. This prevents target leakage in ML: using a hospital's current bed count to predict outcomes from 2020 visits introduces information that didn't exist at prediction time.
> 🐘 **PG Ref:** [Temporal queries pattern](https://wiki.postgresql.org/wiki/Temporal_Tables)
> 🔬 **DS Equivalent:** Feature store point-in-time correct retrieval (Feast's `get_historical_features(entity_df, feature_refs)`) — returns the feature value as it existed at the event timestamp, not the current value.

---

### Q5. Recursive CTE: Fibonacci and Sequence Generation
Use a recursive CTE to generate Fibonacci numbers up to 1000. Then use the same pattern to generate a sequence of exponentially growing patient risk scores. Apply to `dim_patient` as a demonstration of recursive data generation.

> 🔍 **Hint:** `WITH RECURSIVE fib(a, b) AS (SELECT 1::bigint, 1::bigint UNION ALL SELECT b, a+b FROM fib WHERE b < 1000) SELECT a FROM fib`.

> 🪜 **Steps:**
> 1. `WITH RECURSIVE fib(a, b) AS (VALUES(1::bigint, 1::bigint) UNION ALL SELECT b, a+b FROM fib WHERE b <= 1000)`.
> 2. `SELECT a AS fibonacci FROM fib`.
> 3. Extend concept: exponential risk score `SELECT 1 AS risk, 1.5 AS multiplier UNION ALL SELECT risk * multiplier, multiplier WHERE risk < 1000`.

> 📚 **Concept:** Recursive CTEs can carry multiple values per iteration (a, b for Fibonacci). The termination condition (`WHERE b <= 1000`) is crucial — without it, infinite recursion hits PostgreSQL's default limit of 100 iterations (`max_recursion_depth`). Recursive sequence generation is used for: Monte Carlo sampling indices, exponential decay schedules, iterative approximation algorithms — all without application code.
> 🐘 **PG Ref:** [Recursive CTE depth limit](https://www.postgresql.org/docs/current/queries-with.html#QUERIES-WITH-RECURSIVE)
> 🔬 **DS Equivalent:** Python generator: `def fibonacci(): a, b = 1, 1; while b < 1000: yield a; a, b = b, a+b` — same lazy sequence generation concept.

---

### Q6. View Dependency Tracking
Write a query to find all views in the `public` schema and their dependencies (which tables they reference) using `information_schema.view_table_usage` and `information_schema.views`.

> 🔍 **Hint:** `information_schema.view_table_usage`, `information_schema.views`. JOIN on `view_name`.

> 🪜 **Steps:**
> 1. `SELECT v.table_name AS view_name, vtu.table_name AS depends_on FROM information_schema.views v JOIN information_schema.view_table_usage vtu ON v.table_name = vtu.view_name WHERE v.table_schema = 'public'`.
> 2. Also query `pg_depend` for more granular dependency tracking.
> 3. Identify views that depend on `fact_patient_visits` — these break if fact table structure changes.

> 📚 **Concept:** View dependency tracking prevents accidental schema changes from breaking downstream views. Before dropping or altering a table, check `information_schema.view_table_usage` to find all views that reference it. PostgreSQL's `DROP TABLE ... CASCADE` drops dependent views silently — a trap that breaks production dashboards. Always track dependencies before schema changes.
> 🐘 **PG Ref:** [information_schema.view_table_usage](https://www.postgresql.org/docs/current/infoschema-view-table-usage.html)
> 🔬 **DS Equivalent:** Data lineage tracking — understanding which downstream datasets/models depend on each upstream table. Tools like dbt's `ref()` make this explicit; SQL's `information_schema` provides it implicitly.

---

### Q7. Subquery Rewrite Challenge
A slow query uses a correlated subquery to find each department's most expensive visit. Rewrite it using: (1) a CTE + window function, (2) a LATERAL join. Prove equivalence. Compare EXPLAIN plans.

> 🔍 **Hint:** Original: `WHERE treatment_cost = (SELECT MAX(treatment_cost) FROM fpv2 WHERE fpv2.department_id = fpv.department_id)`. Rewrite 1: CTE with RANK(). Rewrite 2: LATERAL with ORDER BY LIMIT 1.

> 🪜 **Steps:**
> 1. Write the original correlated subquery version.
> 2. Rewrite 1: `WITH ranked AS (SELECT *, RANK() OVER (PARTITION BY department_id ORDER BY treatment_cost DESC) AS rk FROM fpv) SELECT * FROM ranked WHERE rk = 1`.
> 3. Rewrite 2: `FROM dim_department dd, LATERAL (SELECT * FROM fpv WHERE department_id = dd.department_id ORDER BY treatment_cost DESC LIMIT 1) top_visit`.
> 4. `EXPLAIN (ANALYZE, BUFFERS)` on all three — compare execution times.

> 📚 **Concept:** The correlated subquery runs N subqueries (one per row). The window function version scans and sorts once. The LATERAL version runs one subquery per department (smaller N). For `fact_patient_visits` with 1M+ rows and 20 departments: correlated = 1M subqueries, window = 1 sorted pass, LATERAL = 20 subqueries with indexed access. This exercise trains query rewrite intuition — a highly valued production SQL skill.
> 🐘 **PG Ref:** [EXPLAIN ANALYZE](https://www.postgresql.org/docs/current/sql-explain.html)
> 🔬 **DS Equivalent:** Profiling equivalent pandas operations: `apply()` per row (O(N)) vs `transform()` (vectorised O(N)) vs `groupby().nth(0)` (per-group first/nth) — same performance lesson.

---

### Q8. CTE Fence: Control CTE Materialisation
Write a query where a CTE is referenced twice in the outer query. In PostgreSQL 12+, demonstrate the difference between inlined CTE (re-executed twice) vs `MATERIALIZED` CTE (computed once). Use EXPLAIN to verify.

> 🔍 **Hint:** `WITH cte AS (SELECT * FROM fact_patient_visits WHERE treatment_cost > 5000)` — referenced in two JOINs. Then `WITH cte AS MATERIALIZED (...)` — compare plans.

> 🪜 **Steps:**
> 1. Write a query referencing the same CTE twice (e.g., self-join the CTE).
> 2. `WITH cte AS (SELECT ...)` — PostgreSQL may inline and execute twice.
> 3. `WITH cte AS MATERIALIZED (SELECT ...)` — forces one execution, stored temporarily.
> 4. `EXPLAIN` both — the materialised version shows `CTE Scan` node; inlined shows the base scan twice.
> 5. Compare execution times for a large result set.

> 📚 **Concept:** In PostgreSQL 12+, the planner inlines CTEs by default — the CTE isn't a materialisation barrier. If the CTE contains expensive computation or side effects and is referenced multiple times, use `MATERIALIZED` to ensure it runs once. `NOT MATERIALIZED` forces inlining. Understanding this determines when CTEs vs temp tables vs views are more appropriate for pipeline performance.
> 🐘 **PG Ref:** [CTE materialisation](https://www.postgresql.org/docs/current/queries-with.html#id-1.5.6.12.7)
> 🔬 **DS Equivalent:** Eager vs lazy evaluation in Python: `MATERIALIZED` ≈ `list(generator)` (compute once, store); inlined CTE ≈ a generator that recomputes on each iteration.

---

### Q9. Recursive CTE: Find All Hospitals in a Region Chain
Suppose regions can have sub-regions (add `parent_region_id` to `dim_region`). Write a recursive CTE to find all hospitals in a region and all its sub-regions, regardless of nesting depth.

> 🔍 **Hint:** `ALTER TABLE dim_region ADD COLUMN parent_region_id VARCHAR(20)`. Then recursive CTE traverses region hierarchy; join to `dim_hospital` at the end.

> 🪜 **Steps:**
> 1. Add `parent_region_id` to `dim_region` and populate a small hierarchy.
> 2. Anchor: `SELECT region_id FROM dim_region WHERE parent_region_id IS NULL`.
> 3. Recursive: `UNION ALL SELECT dr.region_id FROM dim_region dr JOIN region_tree rt ON dr.parent_region_id = rt.region_id`.
> 4. Join `region_tree` to `dim_hospital` on `region_id`.
> 5. Collect all hospitals under the top-level region.

> 📚 **Concept:** Recursive CTE tree traversal is the SQL standard for hierarchical data (org charts, geographic hierarchies, product taxonomies, menu trees). The depth is unlimited — the recursion continues until no new rows are added. Adding `level` and `path` columns (array of region IDs from root to current) enables: depth-limited queries, cycle detection, and breadcrumb navigation.
> 🐘 **PG Ref:** [Recursive CTE tree traversal](https://www.postgresql.org/docs/current/queries-with.html#QUERIES-WITH-RECURSIVE)
> 🔬 **DS Equivalent:** `networkx.descendants(G, root)` for all descendants in a DAG. Or recursive `os.walk()` for directory trees. The recursive CTE is SQL's tree walker.

---

### Q10. Lateral JSON Unnest for Multi-Condition Patients
Using the JSONB `conditions_jsonb` column (from Phase 4 Expert Q4, if added), use a LATERAL + `jsonb_array_elements_text()` to unnest each patient's conditions and count how many patients have each condition.

> 🔍 **Hint:** Tables: `dim_patient`. Concepts: `LATERAL`, `jsonb_array_elements_text(conditions_jsonb) AS condition`, GROUP BY condition.

> 🪜 **Steps:**
> 1. `FROM dim_patient dp, LATERAL jsonb_array_elements_text(dp.conditions_jsonb) AS condition`.
> 2. This unnests each patient's conditions array into individual rows.
> 3. `SELECT condition, COUNT(DISTINCT dp.patient_id) AS patient_count`.
> 4. `GROUP BY condition ORDER BY patient_count DESC`.
> 5. Handle NULL: `WHERE dp.conditions_jsonb IS NOT NULL`.

> 📚 **Concept:** Implicit LATERAL: when a set-returning function (SRF) like `jsonb_array_elements_text()` appears in FROM alongside a table, PostgreSQL automatically treats it as a LATERAL. This unnests arrays into rows — the SQL equivalent of `.explode()` in pandas. The result is one row per (patient, condition) pair — a long-format representation of a multi-valued attribute.
> 🐘 **PG Ref:** [Set-returning functions in FROM](https://www.postgresql.org/docs/current/functions-srf.html)
> 🔬 **DS Equivalent:** `df.explode('conditions')` — pandas `.explode()` converts a column of lists into individual rows, equivalent to the LATERAL unnest.

---

## 🔴 Advanced

---

### Q1. Graph Shortest Path via Recursive CTE
Model hospital-to-hospital patient transfer paths: if patient moves from Hospital A → B → C, find all paths up to 4 hops. Add `patient_transfer` table. Use recursive CTE with path tracking and cycle detection.

> 🔍 **Hint:** Concepts: `ARRAY` for path tracking, `NOT (node = ANY(path))` for cycle detection, `UNION ALL` for BFS.

> 🪜 **Steps:**
> 1. Create `patient_transfer (from_hospital VARCHAR, to_hospital VARCHAR, patient_id VARCHAR, transfer_date DATE)`.
> 2. Anchor: `SELECT patient_id, from_hospital, to_hospital, ARRAY[from_hospital, to_hospital] AS path, 1 AS depth`.
> 3. Recursive: `UNION ALL SELECT ..., path || pt.to_hospital, depth + 1 WHERE NOT (pt.to_hospital = ANY(path)) AND depth < 4`.
> 4. Collect all paths, show shortest per patient using MIN(depth).

> 📚 **Concept:** Graph traversal with cycle detection in SQL using recursive CTEs. The `path` array tracks visited nodes; `NOT (node = ANY(path))` prevents revisiting. This is BFS (breadth-first search) in SQL. Applications: patient transfer network analysis, drug interaction graph queries, hospital referral pathway optimisation. PostgreSQL handles this natively — dedicated graph databases (Neo4j) are only needed for graphs too large for memory.
> 🐘 **PG Ref:** [Recursive CTE with arrays](https://www.postgresql.org/docs/current/queries-with.html#QUERIES-WITH-RECURSIVE)
> 🔬 **DS Equivalent:** `networkx.shortest_path(G, source, target)` — Python's NetworkX for graph algorithms. The recursive CTE is the in-database equivalent.

---

### Q2. Incremental Materialised View Refresh Strategy
Design a strategy to incrementally refresh `mv_hospital_scorecard` (from Medium Q2) by only updating rows where the underlying data changed since the last refresh. Use a `last_updated` tracking table.

> 🔍 **Hint:** Concepts: Tracking table `mv_refresh_log`, partial DELETE + INSERT into matview, `REFRESH MATERIALIZED VIEW CONCURRENTLY` limitations.

> 🪜 **Steps:**
> 1. Create `mv_refresh_log (view_name VARCHAR, last_refreshed TIMESTAMP)`.
> 2. Identify changed hospitals: `SELECT DISTINCT hospital_id FROM fact_patient_visits WHERE arrival_datetime > (SELECT last_refreshed FROM mv_refresh_log WHERE view_name = 'mv_hospital_scorecard')`.
> 3. Delete stale rows: `DELETE FROM mv_hospital_scorecard WHERE hospital_id IN (changed hospitals)`.
> 4. Insert fresh rows: `INSERT INTO mv_hospital_scorecard SELECT ... WHERE hospital_id IN (changed hospitals)`.
> 5. Update `mv_refresh_log`.

> 📚 **Concept:** PostgreSQL's `REFRESH MATERIALIZED VIEW` is all-or-nothing — it rebuilds the entire view. For large matviews, incremental refresh (only update changed partitions) is dramatically faster. This manual incremental approach simulates what Apache Iceberg's incremental materialized views or dbt's incremental models do automatically. The tracking table pattern is the same as dbt's `is_incremental()` macro.
> 🐘 **PG Ref:** [Limitations of REFRESH CONCURRENTLY](https://www.postgresql.org/docs/current/sql-refreshmaterializedview.html)
> 🔬 **DS Equivalent:** dbt incremental model: `{% if is_incremental() %} WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }}) {% endif %}` — the same "only process new data" logic.

---

### Q3. Subquery Factoring for Performance
Identify a query with 3 identical subquery computations (e.g., avg treatment cost per hospital used 3 times for different comparisons). Refactor using a single CTE. Measure improvement with EXPLAIN.

> 🔍 **Hint:** Write the original query with the same subquery appearing 3 times in different WHERE/SELECT positions. Refactor to a single CTE.

> 🪜 **Steps:**
> 1. Write the "bad" query: same `(SELECT AVG(treatment_cost) FROM ... WHERE hospital_id = ...)` in 3 places.
> 2. Refactor: `WITH avg_costs AS (SELECT hospital_id, AVG(treatment_cost) AS avg_cost FROM fact_patient_visits GROUP BY hospital_id)`.
> 3. Reference `avg_costs` in all 3 places.
> 4. With `MATERIALIZED` hint, ensure computed once.
> 5. EXPLAIN both — compare total cost.

> 📚 **Concept:** Subquery factoring (CTE) eliminates redundant computation. Without it, the database executes the subquery 3 times. With a materialized CTE, it runs once. This is the "DRY" (Don't Repeat Yourself) principle applied to SQL. In complex analytical queries, the same intermediate result is often used multiple times — CTEs eliminate the redundancy. This is one of the most impactful query optimisation techniques.
> 🐘 **PG Ref:** [CTE for query factoring](https://www.postgresql.org/docs/current/queries-with.html)
> 🔬 **DS Equivalent:** Computing `hospital_means = df.groupby('hospital_id')['cost'].mean()` once and reusing it, rather than recomputing inside every subsequent filter/join.

---

## ⚫ Expert

---

### Q1. Full dbt-Style Layered Architecture
Design and implement a 3-layer analytical architecture in SQL: (1) `stg_patient_visits` view (staging — raw data renamed/typed), (2) `int_visit_enriched` materialized view (intermediate — joined with dims), (3) `mart_hospital_quality` materialized view (mart — aggregated metrics). Write DDL for all 3.

> 🔍 **Hint:** Concepts: Views for staging (no physical storage), Materialized Views for expensive intermediate + mart layers, dependency chain.

> 🪜 **Steps:**
> 1. `CREATE VIEW stg_patient_visits AS SELECT visit_id, patient_id, hospital_id, arrival_datetime::date AS visit_date, treatment_cost, COALESCE(satisfaction_score, 5) AS satisfaction_score, ... FROM fact_patient_visits`.
> 2. `CREATE MATERIALIZED VIEW int_visit_enriched AS SELECT stg.*, dp.age, dp.risk_category, dh.hospital_name, dh.city, dd.department_name FROM stg_patient_visits stg JOIN dim_patient dp USING (patient_id) JOIN dim_hospital dh USING (hospital_id) JOIN dim_department dd USING (department_id)`.
> 3. `CREATE MATERIALIZED VIEW mart_hospital_quality AS SELECT hospital_name, city, COUNT(*) visit_count, AVG(satisfaction_score), AVG(treatment_cost), ... FROM int_visit_enriched GROUP BY ...`.
> 4. Refresh order: stg is a view (always fresh), refresh int first, then mart.

> 📚 **Concept:** This is dbt's 3-layer architecture in raw SQL: staging (clean raw data) → intermediate (joined/transformed) → mart (business-metric aggregates). dbt `ref()` makes dependencies explicit; in raw SQL, you manage dependency order manually (refresh int before mart). Understanding this architecture is foundational for data engineering careers — dbt is the industry standard tool built on this exact pattern.
> 🐘 **PG Ref:** [dbt architecture in PostgreSQL](https://docs.getdbt.com/docs/build/models)
> 🔬 **DS Equivalent:** A feature engineering pipeline: raw → feature → model-ready. Each layer in dbt corresponds to one analytical transformation stage, documented, tested, and lineage-tracked.

---

### Q2. Recursive CTE with Probabilistic Risk Propagation
Model a risk propagation scenario: if a patient is high-risk (from `dim_patient`), their doctor's risk score increases. If the doctor's risk score is high, the department's average risk increases. Simulate 3 levels of propagation using recursive CTEs.

> 🔍 **Hint:** Concepts: Multi-level recursive CTE, aggregation at each level, risk score propagation logic.

> 🪜 **Steps:**
> 1. Level 0: patient risk scores.
> 2. Level 1: doctor avg patient risk = AVG(patient_risk) WHERE doctor treated them.
> 3. Level 2: department avg doctor risk = AVG(doctor_risk).
> 4. Level 3: hospital avg department risk.
> 5. Use CTEs (not recursive CTE strictly — chained CTEs work here): `WITH patient_risk AS (...), doctor_risk AS (... FROM patient_risk ...), dept_risk AS (...)`.

> 📚 **Concept:** Risk propagation through a hierarchy is a real clinical analytics pattern — burnout propagates from overloaded departments to individual staff, patient complexity propagates to doctor workload. This is modelled naturally with chained CTEs (each level references the previous). In network science, this is influence propagation on a graph — the same algorithm runs in Python's NetworkX but SQL handles it at database scale without data extraction.
> 🐘 **PG Ref:** [Chained CTEs for multi-level analysis](https://www.postgresql.org/docs/current/queries-with.html)
> 🔬 **DS Equivalent:** Graph neural network message passing — each node aggregates messages from neighbours. The CTE version is a fixed-depth (3 iterations) version of GNN propagation.

---

### Q3. CTE for Complex Upsert (MERGE equivalent)
PostgreSQL doesn't have MERGE (until PG15). Implement an upsert using a CTE: for a batch of new hospital records, insert new ones and update existing ones atomically.

> 🔍 **Hint:** PG15+: `MERGE INTO dim_hospital USING new_data ON (...) WHEN MATCHED THEN UPDATE ... WHEN NOT MATCHED THEN INSERT ...`. Pre-PG15: `WITH upsert AS (UPDATE ... RETURNING hospital_id) INSERT INTO ... SELECT ... WHERE hospital_id NOT IN (SELECT hospital_id FROM upsert)`.

> 🪜 **Steps:**
> 1. If on PG15+: write a MERGE statement.
> 2. Pre-PG15: `WITH updated AS (UPDATE dim_hospital SET ... FROM new_data WHERE dim_hospital.hospital_id = new_data.hospital_id RETURNING dim_hospital.hospital_id)`.
> 3. `INSERT INTO dim_hospital SELECT * FROM new_data WHERE hospital_id NOT IN (SELECT hospital_id FROM updated)`.
> 4. Wrap in transaction.

> 📚 **Concept:** The UPSERT pattern is fundamental in data pipelines — processing new data that may contain both new records and updates to existing ones. Pre-PG15, the CTE-based upsert is the standard PostgreSQL idiom. PG15 added `MERGE` (ANSI SQL). `INSERT ... ON CONFLICT DO UPDATE` (PostgreSQL's `UPSERT`) is simpler for single-table upserts. The CTE version handles complex join conditions across tables.
> 🐘 **PG Ref:** [INSERT ON CONFLICT](https://www.postgresql.org/docs/current/sql-insert.html#SQL-ON-CONFLICT) | [MERGE (PG15)](https://www.postgresql.org/docs/15/sql-merge.html)
> 🔬 **DS Equivalent:** `df.set_index('hospital_id').combine_first(new_data.set_index('hospital_id'))` — pandas combine_first does update-existing + insert-new simultaneously.

---

### Q4. View-Based API Layer
Design a complete view-based API for the hospital analytics system: (1) `api.patient_summary` — one row per patient, all metrics, (2) `api.hospital_dashboard` — one row per hospital, (3) `api.doctor_performance` — one row per doctor. Create a separate schema `api` for these.

> 🔍 **Hint:** `CREATE SCHEMA api; CREATE VIEW api.patient_summary AS ...`. Grant SELECT on schema to `reporting_role`.

> 🪜 **Steps:**
> 1. `CREATE SCHEMA api`.
> 2. `CREATE VIEW api.patient_summary AS SELECT dp.*, COUNT(fpv.visit_id) AS total_visits, SUM(fpv.treatment_cost) AS total_cost, MAX(fpv.arrival_datetime) AS last_visit FROM dim_patient dp LEFT JOIN fact_patient_visits fpv USING (patient_id) GROUP BY dp.patient_id`.
> 3. Similarly: `api.hospital_dashboard`, `api.doctor_performance`.
> 4. `GRANT SELECT ON SCHEMA api TO reporting_role; GRANT SELECT ON ALL TABLES IN SCHEMA api TO reporting_role`.
> 5. Reporting users query `api.*` without knowing internal schema structure.

> 📚 **Concept:** Schema-based API layers separate internal storage from external access. The `api` schema exposes only approved, pre-joined views — no direct fact table access. This is the SQL equivalent of a REST API facade pattern: internal implementation can change (table structures, column names) without breaking the API contract (view definitions). Used in: multi-team organisations where data engineers own `public.*` and analysts access `api.*`.
> 🐘 **PG Ref:** [CREATE SCHEMA](https://www.postgresql.org/docs/current/sql-createschema.html) | [GRANT](https://www.postgresql.org/docs/current/sql-grant.html)
> 🔬 **DS Equivalent:** A data catalog's curated dataset layer — exposing `Patients`, `Hospitals`, `Doctors` as clean entities rather than raw tables. Like Databricks' Delta Sharing or Snowflake's Data Sharing for clean, governed data access.

---

### Q5. LATERAL with Machine Learning Scoring Proxy
For each hospital, use LATERAL to call a UDF `classify_patient_risk()` (from Phase 4 Expert) on each patient's top-3 most expensive visits. Return hospital, visit details, and ML-proxy risk classification.

> 🔍 **Hint:** Concepts: LATERAL for top-N per hospital, UDF call in SELECT, result set enrichment.

> 🪜 **Steps:**
> 1. `FROM dim_hospital dh, LATERAL (SELECT fpv.visit_id, fpv.treatment_cost, fpv.arrival_datetime, dp.age, dp.chronic_condition_count, fpv.severity_level FROM fact_patient_visits fpv JOIN dim_patient dp USING (patient_id) WHERE fpv.hospital_id = dh.hospital_id ORDER BY fpv.treatment_cost DESC LIMIT 3) top3`.
> 2. In outer SELECT: `classify_patient_risk(top3.age, top3.chronic_condition_count, top3.severity_level) AS risk_class`.
> 3. Result: each hospital's 3 most expensive visits with ML-proxy classification.

> 📚 **Concept:** LATERAL + UDF is the closest SQL gets to applying a machine learning model per row entirely within the database. The UDF encapsulates the classification logic; LATERAL provides per-hospital context. For production ML scoring at scale, this pattern using `plpython3u` (Phase 4 Super Expert) can load a scikit-learn model from a table and score thousands of rows per second — entirely in-database, no data export.
> 🐘 **PG Ref:** [LATERAL with UDF](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-LATERAL) | [PL/Python](https://www.postgresql.org/docs/current/plpython.html)
> 🔬 **DS Equivalent:** `df.apply(classify_patient_risk, axis=1)` — applying an ML scoring function row-wise in pandas. The LATERAL+UDF version keeps data in-database for latency-sensitive or compliance-restricted environments.

---

## 💎 Super Expert
> No questions. Curated topics for world-class advanced querying mastery.

---

### 🚀 What to Master After Phase 6

**1. dbt (data build tool) — The Industry Standard for SQL Transformation**
dbt formalises the CTE/view/matview patterns you've learned. Every dbt model is a `.sql` file with CTEs. `ref()` tracks dependencies. `source()` defines raw data contracts. Tests run on every build. Documentation is auto-generated from `schema.yml`. Why it makes you stand out: dbt is the most widely adopted data transformation tool in 2024/2025. Every data team using a cloud warehouse uses dbt or is migrating to it.

**2. Apache Iceberg Table Format — SQL Time Travel at Scale**
Iceberg tables provide: time travel (`SELECT * FROM table FOR VERSION AS OF timestamp`), schema evolution without rewrites, partition evolution without data movement. Backed by Parquet files in S3. Query via Spark, Trino, Snowflake, BigQuery (via external tables), or DuckDB. Your SCD Type 2 patterns from Phase 2 are what Iceberg provides natively — understanding SCD2 gives you intuition for how Iceberg versioning works.

**3. Apache Spark SQL — Same SQL, Distributed Scale**
Spark SQL supports: CTEs, window functions, subqueries, LATERAL (Spark 3.x), and most PostgreSQL-compatible SQL. The key difference: Spark executes on a cluster. Your Phase 5 and 6 queries run unchanged on 10TB of data in Spark. The mental model — query plan optimisation, join strategies, partition pruning — is identical. Understanding PostgreSQL's query planner prepares you for Spark's Catalyst optimizer.

**4. DuckDB — OLAP in Your Laptop**
DuckDB runs analytical SQL directly on Parquet/CSV files without a server. It supports: window functions, CTEs, LATERAL, UNNEST, PIVOT/UNPIVOT (native), `read_parquet()`, `read_csv()`. Query an S3 bucket directly: `SELECT * FROM read_parquet('s3://bucket/data/*.parquet')`. For data scientists: DuckDB is pandas-replacement for analytical SQL — 10-100x faster than pandas for GROUP BY + JOIN workloads. Zero setup, Python integration via `import duckdb`.

**5. Recursive CTEs for Graph Analytics at Scale**
Graph algorithms in recursive CTEs scale to millions of nodes in PostgreSQL, but trillions of edges need dedicated graph databases (Neo4j, Amazon Neptune, TigerGraph). The boundary: if your graph fits in PostgreSQL's working memory, CTEs work. For patient transfer networks (thousands of hospitals, millions of transfers), CTEs are sufficient. For social network graphs (billions of nodes), use a graph DB. Knowing this boundary is what experienced architects know.

**6. Logical Replication for CDC (Change Data Capture)**
PostgreSQL's logical replication publishes row-level changes (INSERT/UPDATE/DELETE) to a replication slot. Tools like Debezium capture these changes and stream them to Kafka. Downstream: Apache Flink or Spark Structured Streaming process the change events in near-real-time. This is the modern CDC pipeline: PostgreSQL WAL → Debezium → Kafka → Flink → Data Lake. Your understanding of transactions (Phase 2), triggers (Phase 7), and CTEs powers the source side of this pipeline.

**7. Query Result Caching Layers**
PostgreSQL doesn't have a built-in query result cache (unlike MySQL). Production architectures add: Redis (key-value cache for frequent queries), Materialized Views (scheduled refresh), PgBouncer with statement-level caching (limited), or CDN-level caching for API responses. For BI tools: pre-aggregate data in matviews that BI tools query. For ML serving: cache model predictions in Redis, refreshed by a background SQL job. Understanding WHERE in the stack to cache is an architectural skill.
