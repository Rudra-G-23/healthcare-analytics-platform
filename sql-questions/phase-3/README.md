# 📘 Phase 3 — Relational Data & Joins
## INNER · LEFT · RIGHT · FULL · ANTI · CROSS · SELF · SET OPERATIONS
### PostgreSQL | NHS Hospital Analytics | Data Science Perspective

---

## 📋 Phase Topics

| Concept | Commands |
|---|---|
| Basic Joins | `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL OUTER JOIN` |
| Advanced Joins | `SELF JOIN`, `CROSS JOIN`, `ANTI JOIN` (pattern) |
| Multi-Table | 3+ table joins, star schema joins |
| Set Operations | `UNION`, `UNION ALL`, `EXCEPT`, `INTERSECT` |
| PostgreSQL Extra | `LATERAL`, join ordering hints, join cardinality |

---

## 🟢 Beginner

---

### Q1. Match Patients to Their Visits
Join `dim_patient` and `fact_patient_visits` to display `patient_id`, `age`, `gender`, `visit_id`, `admission_type`, `treatment_cost`.
> 🔍 **Hint:** Use `INNER JOIN ... ON dim_patient.patient_id = fact_patient_visits.patient_id`.
> 📚 **Concept:** `INNER JOIN` returns only rows where the join key exists in BOTH tables. Rows with no match in either table are excluded. In a star schema, this is the standard fact-to-dimension join. Always qualify column names with table aliases when joining.
> 🐘 **PG Ref:** [Joined tables](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-JOIN)
> 🔬 **DS Equivalent:** `pd.merge(dim_patient, fact_patient_visits, on='patient_id', how='inner')` — inner merge in pandas.

---

### Q2. All Hospitals Even Without Financial Records
Join `dim_hospital` to `fact_financials` showing all hospitals, even those with no financial data. Show `hospital_name`, `city`, `revenue` (NULL if no record exists).
> 🔍 **Hint:** Use `LEFT JOIN fact_financials ON dim_hospital.hospital_id = fact_financials.hospital_id`.
> 📚 **Concept:** `LEFT JOIN` returns ALL rows from the left table and matching rows from the right. Unmatched right-side columns become NULL. In analytics, LEFT JOIN is the most common join — you rarely want to silently drop dimension records just because the fact table is empty.
> 🐘 **PG Ref:** [Joined tables](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-JOIN)
> 🔬 **DS Equivalent:** `pd.merge(dim_hospital, fact_financials, on='hospital_id', how='left')` — left merge in pandas.

---

### Q3. All Financial Records Even Without Hospital Info
Join `fact_financials` to `dim_hospital` showing all financial records, even orphaned ones with no hospital match. Show `financial_record_id`, `hospital_id` from financials, `hospital_name` (NULL if unmatched).
> 🔍 **Hint:** Use `RIGHT JOIN dim_hospital ON fact_financials.hospital_id = dim_hospital.hospital_id`.
> 📚 **Concept:** `RIGHT JOIN` returns ALL rows from the right table and matching rows from the left. It is the mirror image of LEFT JOIN. In practice, RIGHT JOIN is rare — most developers rewrite it as a LEFT JOIN by swapping table order. Understanding it matters when reading legacy code.
> 🐘 **PG Ref:** [Joined tables](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-JOIN)
> 🔬 **DS Equivalent:** `pd.merge(fact_financials, dim_hospital, on='hospital_id', how='right')` — right merge.

---

### Q4. All Patients and All Visits — Full Picture
Join `dim_patient` and `fact_patient_visits` with a FULL OUTER JOIN. Show all patients (even with no visits) and all visits (even with no matching patient record).
> 🔍 **Hint:** Use `FULL OUTER JOIN ... ON patient_id`.
> 📚 **Concept:** `FULL OUTER JOIN` = LEFT JOIN ∪ RIGHT JOIN. Returns all rows from BOTH tables, with NULLs on the unmatched side. Use it for data reconciliation: identifying records in one table with no match in the other. Equivalent to UNION of LEFT JOIN and RIGHT JOIN results.
> 🐘 **PG Ref:** [Joined tables](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-JOIN)
> 🔬 **DS Equivalent:** `pd.merge(dim_patient, fact_patient_visits, on='patient_id', how='outer')` — outer merge.

---

### Q5. Doctor Details with Hospital Name
Join `dim_doctor` and `dim_hospital` to show `doctor_name`, `specialty`, `grade`, `hospital_name`, `city` for all doctors.
> 🔍 **Hint:** `JOIN dim_hospital ON dim_doctor.primary_hospital_id = dim_hospital.hospital_id`.
> 📚 **Concept:** This is a dimension-to-dimension join — joining two dimension tables directly. Use short, consistent aliases (e.g., `d` for doctor, `h` for hospital). The join key is `primary_hospital_id` → `hospital_id` — different column names, so use `ON` clause explicitly.
> 🐘 **PG Ref:** [Table aliases](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-TABLE-ALIASES)
> 🔬 **DS Equivalent:** `pd.merge(dim_doctor, dim_hospital, left_on='primary_hospital_id', right_on='hospital_id')` — different key names require explicit left_on/right_on.

---

### Q6. Visits Enriched with Department Info
Join `fact_patient_visits` with `dim_department` to show `visit_id`, `admission_type`, `department_name`, `type` (department type), `icu_capable`. Filter for only ICU-capable departments.
> 🔍 **Hint:** `JOIN dim_department ON fact_patient_visits.department_id = dim_department.department_id WHERE dim_department.icu_capable = true`.
> 📚 **Concept:** Adding `WHERE` after JOIN filters the joined result set. The order matters conceptually: JOIN produces combined rows, WHERE filters them. Putting join conditions in ON and business filters in WHERE is the cleanest pattern — don't mix them without reason.
> 🐘 **PG Ref:** [Joined tables](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-JOIN)
> 🔬 **DS Equivalent:** `pd.merge(...).query('icu_capable == True')` in pandas.

---

### Q7. Three-Table Join: Patient + Visit + Hospital
Join `dim_patient`, `fact_patient_visits`, and `dim_hospital` to show `patient_id`, `age`, `risk_category`, `admission_type`, `hospital_name`, `city`. Limit to 20 rows.
> 🔍 **Hint:** Two sequential JOINs — `fact_patient_visits JOIN dim_patient ON ... JOIN dim_hospital ON ...`. Order can vary; results are the same.
> 📚 **Concept:** Multi-table joins chain sequentially. The query planner decides the optimal join order regardless of how you write them. Adding `LIMIT` early is a good habit during development to avoid accidentally pulling millions of rows. In star schema queries, the fact table is typically the central table with dims joined on either side.
> 🐘 **PG Ref:** [Join order](https://www.postgresql.org/docs/current/runtime-config-query.html#GUC-JOIN-COLLAPSE-LIMIT)
> 🔬 **DS Equivalent:** `df1.merge(df2, ...).merge(df3, ...)` — chained merges in pandas.

---

### Q8. Self-Join: Doctors at the Same Hospital
Find pairs of doctors who work at the same hospital. Show `doctor1_name`, `doctor2_name`, `hospital_id`, both specialties.
> 🔍 **Hint:** `FROM dim_doctor d1 JOIN dim_doctor d2 ON d1.primary_hospital_id = d2.primary_hospital_id AND d1.doctor_id < d2.doctor_id`.
> 📚 **Concept:** Self-join joins a table to itself using two aliases. `d1.doctor_id < d2.doctor_id` prevents duplicate pairs (A,B and B,A) and self-pairs (A,A). Self-joins are used for: hierarchical data, finding related records, comparing rows within the same table. They are expensive on large tables — ensure the join key is indexed.
> 🐘 **PG Ref:** [Table aliases](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-TABLE-ALIASES)
> 🔬 **DS Equivalent:** `df.merge(df, left_on='hospital_id', right_on='hospital_id', suffixes=('_1','_2'))` — self-merge in pandas.

---

### Q9. Cross Join: Every Doctor-Department Combination
Use a CROSS JOIN between `dim_doctor` and `dim_department` to generate all possible doctor-department assignments. Show doctor name, department name. Limit to 50.
> 🔍 **Hint:** `FROM dim_doctor CROSS JOIN dim_department LIMIT 50`.
> 📚 **Concept:** CROSS JOIN returns the Cartesian product — every row from table A combined with every row from table B. If A has 100 rows and B has 20 rows, the result has 2,000 rows. Use cases: generating all combinations for scheduling, capacity planning, scenario analysis. Always use LIMIT when exploring — accidentally forgetting it on large tables can generate billions of rows.
> 🐘 **PG Ref:** [CROSS JOIN](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-JOIN)
> 🔬 **DS Equivalent:** `df1.assign(key=1).merge(df2.assign(key=1), on='key').drop('key', axis=1)` — the pandas cross-join idiom (or `pd.MultiIndex.from_product`).

---

### Q10. UNION: Emergency + ICU Visit Types
Write two separate SELECT queries (Emergency visits and ICU-required visits from `fact_patient_visits`) and combine them with UNION to get a unique list. Show `visit_id`, `patient_id`, `admission_type`.
> 🔍 **Hint:** `SELECT ... WHERE admission_type = 'Emergency' UNION SELECT ... WHERE icu_required_flag = true`. Both queries must have the same column count and compatible types.
> 📚 **Concept:** `UNION` stacks two result sets vertically and removes duplicates. Both queries must have the same number of columns in the same order with compatible data types. Column names come from the FIRST query. Deduplication requires a sort pass — UNION ALL (no dedup) is always faster.
> 🐘 **PG Ref:** [UNION / EXCEPT / INTERSECT](https://www.postgresql.org/docs/current/queries-union.html)
> 🔬 **DS Equivalent:** `pd.concat([df1, df2]).drop_duplicates()` — vertical stack + dedup.

---

### Q11. UNION ALL: Combine Without Deduplication
Repeat Q10 using `UNION ALL` instead of `UNION`. Compare row counts.
> 🔍 **Hint:** Replace `UNION` with `UNION ALL`. Count rows from each: `SELECT COUNT(*) FROM (... UNION ALL ...) t`.
> 📚 **Concept:** `UNION ALL` stacks result sets without deduplication — always faster than UNION because no sort is needed. Use UNION ALL by default; only use UNION when deduplication is actually required. A visit that was both Emergency and ICU-required will appear twice with UNION ALL but once with UNION.
> 🐘 **PG Ref:** [UNION ALL](https://www.postgresql.org/docs/current/queries-union.html)
> 🔬 **DS Equivalent:** `pd.concat([df1, df2])` — vertical stack without dedup. Adding `.drop_duplicates()` makes it UNION.

---

### Q12. INTERSECT: Patients Who Had Both Emergency and Planned Visits
Find patient IDs who had BOTH an Emergency admission AND a Planned admission (appear in both filtered sets).
> 🔍 **Hint:** `SELECT patient_id FROM fact_patient_visits WHERE admission_type = 'Emergency' INTERSECT SELECT patient_id FROM fact_patient_visits WHERE admission_type = 'Planned'`.
> 📚 **Concept:** `INTERSECT` returns only rows that appear in BOTH result sets — the set-theoretic intersection. Unlike UNION/EXCEPT, INTERSECT is not widely used in practice but is powerful for finding overlap between populations. It implicitly deduplicates.
> 🐘 **PG Ref:** [INTERSECT](https://www.postgresql.org/docs/current/queries-union.html)
> 🔬 **DS Equivalent:** `set(df[condition1]['patient_id']) & set(df[condition2]['patient_id'])` — set intersection in Python.

---

## 🟡 Medium
> 2–3 tables · 2+ concepts · Table names in hints

---

### Q1. Visit Count per Hospital (with Hospital Name)
Count visits per hospital from `fact_patient_visits`, showing the hospital name from `dim_hospital`. Include only hospitals with 100+ visits. Show `hospital_name`, `visit_count`.
> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_hospital`. Concepts: `INNER JOIN`, `GROUP BY`, `COUNT`, `HAVING`.
> 📚 **Concept:** Combining JOIN with GROUP BY + HAVING is the most fundamental analytics pattern. `HAVING` filters AFTER aggregation (unlike WHERE which filters before). The join enriches the fact table with human-readable dimension labels — classic star schema reporting pattern.
> 🐘 **PG Ref:** [GROUP BY / HAVING](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-GROUP)
> 🔬 **DS Equivalent:** `fact.merge(dim_hospital, on='hospital_id').groupby('hospital_name')['visit_id'].count().loc[lambda x: x >= 100]` in pandas.

---

### Q2. Hospitals with No Patient Visits (ANTI JOIN)
Find hospitals in `dim_hospital` that have NO records in `fact_patient_visits`. Use LEFT JOIN + IS NULL pattern.
> 🔍 **Hint:** Tables: `dim_hospital`, `fact_patient_visits`. Concepts: `LEFT JOIN`, `WHERE right_table.key IS NULL` (ANTI JOIN).
> 📚 **Concept:** ANTI JOIN pattern: `LEFT JOIN` then filter `WHERE right_table.key IS NULL` — returns only left-table rows with NO match. This is more reliable than `NOT IN (subquery)` because it's NULL-safe. The query planner often converts this to a hash anti-join internally — very efficient.
> 🐘 **PG Ref:** [Anti-join via LEFT JOIN](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-JOIN)
> 🔬 **DS Equivalent:** `dim_hospital[~dim_hospital['hospital_id'].isin(fact_patient_visits['hospital_id'])]` in pandas.

---

### Q3. Patients with Visits in ICU Departments
From `fact_patient_visits`, join with `dim_department` to find visits in ICU-capable departments. Also join `dim_patient` for patient age and risk category. Show `patient_id`, `age`, `risk_category`, `department_name`, `wait_time_minutes`.
> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_department`, `dim_patient`. Concepts: 3-table JOIN, boolean filter.
> 📚 **Concept:** Three-table star joins chain fact → dim1, fact → dim2. Always join via the fact table to dimension tables, not dimension-to-dimension directly through the fact table. This keeps the join graph clean and the query planner can optimize each dimension join independently.
> 🐘 **PG Ref:** [Star schema joins](https://www.postgresql.org/docs/current/performance-tips.html)
> 🔬 **DS Equivalent:** `fact.merge(dim_dept, on='department_id').merge(dim_patient, on='patient_id').query('icu_capable')` in pandas.

---

### Q4. Visits with Doctor and Hospital Context
Show `visit_id`, `admission_type`, `treatment_cost`, `doctor_name`, `specialty`, `hospital_name` for all visits. Join `fact_patient_visits` to `dim_doctor` and `dim_hospital`.
> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_doctor`, `dim_hospital`. Concepts: 3-table JOIN, alias clarity.
> 📚 **Concept:** Three-way joins are the bread and butter of analytics reporting. Always use short aliases consistently: `fpv` for fact_patient_visits, `dd` for dim_doctor, `dh` for dim_hospital. Without aliases, column ambiguity errors are common when multiple tables share column names (like `hospital_id` appearing in fact and dim_doctor).
> 🐘 **PG Ref:** [Table aliases](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-TABLE-ALIASES)
> 🔬 **DS Equivalent:** Three-way `pd.merge()` chain — each merge enriches the previous DataFrame with dimension context.

---

### Q5. Doctors with No Visits Assigned
Find all doctors in `dim_doctor` who have no recorded visits in `fact_patient_visits`. Use an ANTI JOIN pattern.
> 🔍 **Hint:** Tables: `dim_doctor`, `fact_patient_visits`. Concepts: `LEFT JOIN`, `WHERE fpv.doctor_id IS NULL`.
> 📚 **Concept:** ANTI JOIN is the "exclusion" pattern — extremely useful in data reconciliation (which doctors are registered but never see patients?). The LEFT JOIN + IS NULL approach is standard. `NOT EXISTS` (Phase 6) is an alternative that is often more readable. Both translate to the same query plan in PostgreSQL.
> 🐘 **PG Ref:** [Anti-join performance](https://www.postgresql.org/docs/current/performance-tips.html)
> 🔬 **DS Equivalent:** `dim_doctor[~dim_doctor['doctor_id'].isin(fact_patient_visits['doctor_id'])]` in pandas.

---

### Q6. EXCEPT: Patients Without Readmissions
Use EXCEPT to find patient IDs who had visits but NO readmission within 30 days.
> 🔍 **Hint:** Tables: `fact_patient_visits`. `SELECT patient_id FROM ... EXCEPT SELECT patient_id FROM ... WHERE readmission_30_days_flag = true`.
> 📚 **Concept:** `EXCEPT` returns rows from the first query that do NOT appear in the second query — the set difference. Useful for finding populations that qualify for one condition but not another. Like UNION, it deduplicates. `EXCEPT ALL` preserves duplicates.
> 🐘 **PG Ref:** [EXCEPT](https://www.postgresql.org/docs/current/queries-union.html)
> 🔬 **DS Equivalent:** `set(all_patients) - set(readmitted_patients)` or `df1[~df1['patient_id'].isin(df2['patient_id'])]` in pandas.

---

### Q7. UNION ALL Report: Staffing and Visits per Hospital
Combine: (1) distinct `hospital_id` values from `fact_staffing` labeled as 'Staffing', and (2) distinct `hospital_id` values from `fact_patient_visits` labeled as 'Visits'. Use UNION ALL. Add a source label column.
> 🔍 **Hint:** Tables: `fact_staffing`, `fact_patient_visits`. Concepts: `UNION ALL`, literal column values.
> 📚 **Concept:** Adding a literal string column (`SELECT 'Staffing' AS source`) to label the origin of records in a UNION is standard for multi-source reports. UNION ALL is used here because we want all records including duplicates (same hospital in both tables is expected). This pattern is used in audit and reconciliation reports.
> 🐘 **PG Ref:** [UNION ALL](https://www.postgresql.org/docs/current/queries-union.html)
> 🔬 **DS Equivalent:** `pd.concat([df1.assign(source='Staffing'), df2.assign(source='Visits')])` in pandas.

---

### Q8. Regions with No Hospitals
Find regions in `dim_region` that have no associated hospitals in `dim_hospital`. Use ANTI JOIN.
> 🔍 **Hint:** Tables: `dim_region`, `dim_hospital`. Concepts: `LEFT JOIN`, `WHERE dh.region_id IS NULL`.
> 📚 **Concept:** Region → Hospital is a one-to-many relationship. An ANTI JOIN here identifies underserved regions — a real public health analytics use case. The `region_id` FK in `dim_hospital` links them. If `region_id` in `dim_hospital` is NULL for some hospitals, they won't match any region (watch for this in the LEFT JOIN result).
> 🐘 **PG Ref:** [FK relationships](https://www.postgresql.org/docs/current/ddl-constraints.html)
> 🔬 **DS Equivalent:** `dim_region[~dim_region['region_id'].isin(dim_hospital['region_id'].dropna())]` in pandas.

---

### Q9. Financial and Staffing Data Side by Side via UNION
Show a combined view of `hospital_id`, `year_int`, `month_name` and a `record_type` label from both `fact_financials` (labeled 'Financial') and `fact_staffing` (labeled 'Staffing'). Use UNION ALL.
> 🔍 **Hint:** Tables: `fact_financials`, `fact_staffing`. Concepts: `UNION ALL`, matching column count/types, literal string column.
> 📚 **Concept:** When combining tables with UNION, column count and data types must match. If one table has more columns, add NULLs as placeholders: `SELECT col1, col2, NULL::numeric AS col3`. Use explicit type casting (`NULL::numeric`) when the type might be ambiguous — PostgreSQL is strict about type matching in UNION.
> 🐘 **PG Ref:** [UNION type compatibility](https://www.postgresql.org/docs/current/typeconv-union-case.html)
> 🔬 **DS Equivalent:** `pd.concat([df1, df2], axis=0)` — requires compatible column structures, NaN used as placeholders for missing columns.

---

### Q10. Diagnosis Category Cross-Reference
Show all diagnosis categories from `dim_diagnosis` alongside every visit for those categories in `fact_patient_visits`. Use `dim_diagnosis.category` matched against `fact_patient_visits.diagnosis_category`. Show counts.
> 🔍 **Hint:** Tables: `dim_diagnosis`, `fact_patient_visits`. Concepts: `JOIN` on text column, `GROUP BY`, `COUNT`.
> 📚 **Concept:** Joining on a VARCHAR text column (category) instead of a surrogate key ID works but is slower and fragile (case sensitivity, typos). This is why `diagnosis_id` exists as a proper FK. In a production schema, always join on integer surrogate keys — text joins are slower, case-sensitive by default, and prone to data quality issues.
> 🐘 **PG Ref:** [Join performance](https://www.postgresql.org/docs/current/performance-tips.html)
> 🔬 **DS Equivalent:** `pd.merge(dim_diagnosis, fact_visits, left_on='category', right_on='diagnosis_category')` — string-based merge, equivalent but same performance caveats apply.

---

### Q11. Full Outer Join: Patients With or Without Visits
FULL OUTER JOIN `dim_patient` with `fact_patient_visits`. Show patients with visits, patients without visits, and (theoretically) visits without a patient record. Flag each row type with a CASE WHEN label.
> 🔍 **Hint:** Tables: `dim_patient`, `fact_patient_visits`. Concepts: `FULL OUTER JOIN`, CASE WHEN to label row type based on which side has NULLs.
> 📚 **Concept:** FULL OUTER JOIN is primarily a data reconciliation tool. Use CASE WHEN to classify rows: `WHEN fpv.visit_id IS NULL THEN 'Patient No Visits'` / `WHEN dp.patient_id IS NULL THEN 'Orphan Visit'` / `ELSE 'Matched'`. This three-way classification exposes data integrity issues that INNER JOIN silently hides.
> 🐘 **PG Ref:** [FULL OUTER JOIN](https://www.postgresql.org/docs/current/queries-table-expressions.html)
> 🔬 **DS Equivalent:** `pd.merge(df1, df2, how='outer', indicator=True)` — the `_merge` indicator column labels 'left_only', 'right_only', 'both' — equivalent to the CASE WHEN approach.

---

### Q12. INTERSECT: Hospitals Appearing in All Three Fact Tables
Find hospital IDs that appear in ALL THREE of: `fact_patient_visits`, `fact_staffing`, `fact_financials`.
> 🔍 **Hint:** Tables: All three fact tables. Concepts: Chained `INTERSECT`.
> 📚 **Concept:** INTERSECT can be chained: `A INTERSECT B INTERSECT C`. Each INTERSECT narrows the result to the common set. This is useful for finding "complete" records — hospitals with all three types of data loaded. Used in data completeness audits.
> 🐘 **PG Ref:** [INTERSECT chaining](https://www.postgresql.org/docs/current/queries-union.html)
> 🔬 **DS Equivalent:** `set(fpv_ids) & set(fs_ids) & set(ff_ids)` — three-way set intersection in Python.

---

## 🟠 Medium Hard
> Mixed phases · 3–4 tables · Steps required

---

### Q1. Star Schema: Full Patient Visit Report
Join all four central tables: `fact_patient_visits`, `dim_patient`, `dim_doctor`, `dim_hospital`. Show `patient_id`, `age`, `risk_category`, `doctor_name`, `specialty`, `hospital_name`, `treatment_cost`, `outcome`. Filter for mortality_flag = true.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_patient`, `dim_doctor`, `dim_hospital`. Concepts: 4-table INNER JOIN chain.

> 🪜 **Steps:**
> 1. Start from `fact_patient_visits` as the central fact table.
> 2. `JOIN dim_patient ON patient_id`.
> 3. `JOIN dim_doctor ON doctor_id`.
> 4. `JOIN dim_hospital ON hospital_id`.
> 5. Add `WHERE fpv.mortality_flag = true`.
> 6. Use aliases: `fpv`, `dp`, `dd`, `dh`.

> 📚 **Concept:** Star schema query: fact table at center, all dimension joins radiating outward. The query planner evaluates all possible join orders and picks the most efficient one. With proper indexes on FK columns, a 4-table join on millions of rows completes in seconds. Without FK indexes — sequential scans on every dimension.
> 🐘 **PG Ref:** [JOIN performance](https://www.postgresql.org/docs/current/performance-tips.html#PERFORMANCE-TIPS-JOIN-ORDER)
> 🔬 **DS Equivalent:** `fact.merge(dim_patient).merge(dim_doctor).merge(dim_hospital)` — chained merges building a denormalized analytical table.

---

### Q2. Hospital Capacity with Regional Context
Join `dim_hospital`, `dim_region`, and aggregate `fact_patient_visits` visit counts. Show `region_name`, `hospital_name`, `beds`, `visit_count`. Include hospitals even if they have no visits (LEFT JOIN to fact).

> 🔍 **Hint:** Tables: `dim_hospital`, `dim_region`, `fact_patient_visits`. Concepts: 3-table join, LEFT JOIN to fact, GROUP BY, COUNT.

> 🪜 **Steps:**
> 1. `FROM dim_region dr JOIN dim_hospital dh ON dr.region_id = dh.region_id`.
> 2. `LEFT JOIN fact_patient_visits fpv ON dh.hospital_id = fpv.hospital_id`.
> 3. `GROUP BY dr.region_name, dh.hospital_name, dh.beds`.
> 4. `SELECT ..., COUNT(fpv.visit_id) AS visit_count` — COUNT on FK column (counts non-NULLs, so hospitals with no visits = 0).
> 5. ORDER BY region_name, visit_count DESC.

> 📚 **Concept:** `COUNT(column)` vs `COUNT(*)` distinction: `COUNT(fpv.visit_id)` counts non-NULL visit IDs (0 for unmatched LEFT JOIN rows). `COUNT(*)` would count 1 even for NULL rows. When using LEFT JOIN with GROUP BY, always use `COUNT(right_table.key)` to correctly count 0 for unmatched rows.
> 🐘 **PG Ref:** [Aggregate functions](https://www.postgresql.org/docs/current/functions-aggregate.html)
> 🔬 **DS Equivalent:** `dim_hospital.merge(dim_region).merge(fact_visits, how='left').groupby(['region_name','hospital_name'])['visit_id'].count()`.

---

### Q3. UNION ALL Multi-Period Comparison Report
Build a combined report showing hospital-level metrics from `fact_financials` for two specific years (e.g., 2022 and 2023) side by side using UNION ALL, with a year label column. Show `hospital_id`, `year_int`, `revenue`, `profit_margin`, `readmission_rate`.

> 🔍 **Hint:** Tables: `fact_financials`. Concepts: UNION ALL with filter per query, literal year label column.

> 🪜 **Steps:**
> 1. Query 1: `SELECT hospital_id, year_int, revenue, profit_margin, readmission_rate FROM fact_financials WHERE year_int = 2022`.
> 2. Query 2: Same structure, `WHERE year_int = 2023`.
> 3. `UNION ALL` — preserves all rows including duplicates.
> 4. Wrap in an outer query for sorting: `SELECT * FROM (...) t ORDER BY hospital_id, year_int`.
> 5. ORDER BY inside UNION queries is not allowed — must be in the outer wrapper.

> 📚 **Concept:** ORDER BY cannot appear inside individual UNION member queries (PostgreSQL error). It must be in the outermost query. To ORDER BY columns from a UNION, wrap it in a subquery or CTE first. UNION ALL is always the right choice for period-over-period reports — no deduplication needed.
> 🐘 **PG Ref:** [ORDER BY with UNION](https://www.postgresql.org/docs/current/queries-union.html)
> 🔬 **DS Equivalent:** `pd.concat([df_2022, df_2023])` then `.sort_values(['hospital_id', 'year_int'])` — ORDER BY must happen after concat.

---

### Q4. Doctor Workload vs Hospital Capacity
Find doctors with more than 50 assigned visits (from `fact_patient_visits`) and enrich with their hospital's ICU capacity (from `dim_hospital`). Use INNER JOIN + ANTI JOIN for doctors with no qualifying visits.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_doctor`, `dim_hospital`. Concepts: 3-table JOIN, GROUP BY + HAVING, attribute enrichment.

> 🪜 **Steps:**
> 1. `FROM fact_patient_visits fpv JOIN dim_doctor dd ON fpv.doctor_id = dd.doctor_id JOIN dim_hospital dh ON dd.primary_hospital_id = dh.hospital_id`.
> 2. `GROUP BY dd.doctor_id, dd.doctor_name, dh.hospital_name, dh.icu_beds`.
> 3. `HAVING COUNT(fpv.visit_id) > 50`.
> 4. SELECT: doctor_name, hospital_name, icu_beds, visit_count.
> 5. ORDER BY visit_count DESC.

> 📚 **Concept:** Combining 3-table JOIN with GROUP BY and HAVING is the core of analytical queries. `HAVING COUNT(...) > 50` is the post-aggregation filter. The hospital's ICU capacity provides operational context — a doctor seeing 100+ patients in a hospital with only 2 ICU beds is a red flag. This is the SQL equivalent of a feature engineering step for an ML model predicting burnout.
> 🐘 **PG Ref:** [HAVING](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-HAVING)
> 🔬 **DS Equivalent:** `fact.merge(dim_doctor).merge(dim_hospital).groupby('doctor_name').filter(lambda g: len(g) > 50)` in pandas.

---

### Q5. Shifts in Departments That Had No ICU Visits
Find departments in `dim_department` where there were staff shifts (in `fact_staffing`) but NO ICU-required visits (in `fact_patient_visits` where `icu_required_flag = true`).

> 🔍 **Hint:** Tables: `dim_department`, `fact_staffing`, `fact_patient_visits`. Concepts: JOIN + EXCEPT pattern (or ANTI JOIN).

> 🪜 **Steps:**
> 1. Query 1: dept IDs from `fact_staffing` (departments with shifts): `SELECT DISTINCT department_id FROM fact_staffing`.
> 2. Query 2: dept IDs from `fact_patient_visits` with ICU visits: `SELECT DISTINCT department_id WHERE icu_required_flag = true`.
> 3. `Query1 EXCEPT Query2` — departments with shifts but no ICU visits.
> 4. Join result to `dim_department` for names.

> 📚 **Concept:** EXCEPT is perfect for "A but not B" population queries. Wrapping in a JOIN after EXCEPT to get human-readable labels is a common two-step pattern. Alternatively, use a CTE (Phase 6): `WITH no_icu_depts AS (... EXCEPT ...) SELECT d.department_name FROM no_icu_depts JOIN dim_department d ON ...`.
> 🐘 **PG Ref:** [EXCEPT](https://www.postgresql.org/docs/current/queries-union.html)
> 🔬 **DS Equivalent:** `set(staffed_depts) - set(icu_depts)` — set difference, then lookup in dim table.

---

### Q6. Patient Risk Cohorts: INTERSECT and EXCEPT Analysis
Find patients who: (a) appear in the 'High' risk category AND had an ICU visit (INTERSECT). (b) appear in the 'High' risk category but did NOT have an ICU visit (EXCEPT). Compare counts.

> 🔍 **Hint:** Tables: `dim_patient`, `fact_patient_visits`. Concepts: `INTERSECT`, `EXCEPT`, COUNT wrapper.

> 🪜 **Steps:**
> 1. Set A: `SELECT patient_id FROM dim_patient WHERE risk_category = 'High'`.
> 2. Set B: `SELECT patient_id FROM fact_patient_visits WHERE icu_required_flag = true`.
> 3. High-risk WITH ICU: `A INTERSECT B`.
> 4. High-risk WITHOUT ICU: `A EXCEPT B`.
> 5. Wrap each in `SELECT COUNT(*) FROM (...) t` to compare.

> 📚 **Concept:** Using INTERSECT and EXCEPT to define population cohorts is a powerful epidemiological analysis technique. The two-cohort comparison (with ICU vs without ICU for the same risk category) is the basis of case-control study design in clinical data analysis. In SQL, this clean set algebra replaces complex nested WHERE logic.
> 🐘 **PG Ref:** [Set operations](https://www.postgresql.org/docs/current/queries-union.html)
> 🔬 **DS Equivalent:** Cohort analysis: `high_risk = set(dim_patient.query('risk_category=="High"')['patient_id'])`, `icu_patients = set(fpv.query('icu_required_flag')['patient_id'])`, then `high_risk & icu_patients` vs `high_risk - icu_patients`.

---

### Q7. Non-Matching Financial Records (Orphan Detection)
Find rows in `fact_financials` where the `hospital_id` does not exist in `dim_hospital`. These are orphaned financial records.

> 🔍 **Hint:** Tables: `fact_financials`, `dim_hospital`. Concepts: `LEFT JOIN`, `WHERE IS NULL` (ANTI JOIN).

> 🪜 **Steps:**
> 1. `FROM fact_financials ff LEFT JOIN dim_hospital dh ON ff.hospital_id = dh.hospital_id`.
> 2. `WHERE dh.hospital_id IS NULL` — these are orphaned records.
> 3. Return: `ff.financial_record_id`, `ff.hospital_id`, `ff.year_int`.
> 4. Count them: how many orphaned records exist?

> 📚 **Concept:** Orphan detection (FK violation check) is a critical data quality task. Without enforced FK constraints on fact tables, orphaned records accumulate over time and silently corrupt analytics. The ANTI JOIN via LEFT JOIN is the standard SQL pattern for detecting them. Running this check regularly is part of a data quality monitoring framework.
> 🐘 **PG Ref:** [Referential integrity](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-FK)
> 🔬 **DS Equivalent:** Checking for NaN values after a merge: `merged = pd.merge(fact, dim, how='left'); orphans = merged[merged['dim_col'].isna()]`.

---

### Q8. Full Patient Journey (5 Tables)
Build a comprehensive patient journey record: `fact_patient_visits` joined with `dim_patient`, `dim_doctor`, `dim_department`, `dim_hospital`. Show: age, risk_category, doctor_name, department_name, hospital_name, icu_capable, treatment_cost, outcome. Filter: severity_level >= 4.

> 🔍 **Hint:** Tables: 5-table star join. Concepts: Chained INNER JOINs on fact.

> 🪜 **Steps:**
> 1. `FROM fact_patient_visits fpv`.
> 2. `JOIN dim_patient dp ON fpv.patient_id = dp.patient_id`.
> 3. `JOIN dim_doctor dd ON fpv.doctor_id = dd.doctor_id`.
> 4. `JOIN dim_department ddep ON fpv.department_id = ddep.department_id`.
> 5. `JOIN dim_hospital dh ON fpv.hospital_id = dh.hospital_id`.
> 6. `WHERE fpv.severity_level >= 4`.

> 📚 **Concept:** A 5-table star join is a standard analytics query. PostgreSQL's query planner evaluates join order using table statistics — it builds a cost model and picks the cheapest plan. For large fact tables, ensure all FK columns (`patient_id`, `doctor_id`, `department_id`, `hospital_id`) have indexes. The planner will use hash joins for large-to-large and nested loop for large-to-small (indexed).
> 🐘 **PG Ref:** [Query planning](https://www.postgresql.org/docs/current/planner-optimizer.html)
> 🔬 **DS Equivalent:** Building a "master analytical dataset" — the join-all step in feature engineering before ML model training. The resulting denormalized table feeds into pandas/sklearn pipelines.

---

### Q9. Regional Coverage: Hospitals Missing from dim_region
Find `region_id` values that appear in `dim_hospital` but do NOT exist as valid entries in `dim_region`. These represent FK violations (hospitals referencing non-existent regions).

> 🔍 **Hint:** Tables: `dim_hospital`, `dim_region`. Concepts: EXCEPT, or ANTI JOIN pattern.

> 🪜 **Steps:**
> 1. Query 1: `SELECT DISTINCT region_id FROM dim_hospital WHERE region_id IS NOT NULL`.
> 2. Query 2: `SELECT region_id FROM dim_region`.
> 3. `Query1 EXCEPT Query2` — region_ids in hospitals not in region table.
> 4. Alternatively: `LEFT JOIN dim_region ON ... WHERE dr.region_id IS NULL`.

> 📚 **Concept:** This is an FK integrity check without relying on the database to enforce it. In warehouses that disable FK constraints for performance, this SQL check performs the same validation at query time. Run this after every ETL load as part of a post-load validation suite.
> 🐘 **PG Ref:** [EXCEPT](https://www.postgresql.org/docs/current/queries-union.html)
> 🔬 **DS Equivalent:** `set(dim_hospital['region_id'].dropna()) - set(dim_region['region_id'])` — checking for FK violations in Python before database loading.

---

### Q10. Staffing Gaps: Departments in Hospital Facts Without Staff Shifts
Find `department_id` values that appear in `fact_patient_visits` (patients treated there) but have NO corresponding shifts in `fact_staffing` (no staff assigned). These are operational anomalies.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `fact_staffing`. Concepts: EXCEPT, or ANTI JOIN.

> 🪜 **Steps:**
> 1. Query 1: `SELECT DISTINCT department_id FROM fact_patient_visits`.
> 2. Query 2: `SELECT DISTINCT department_id FROM fact_staffing`.
> 3. `Q1 EXCEPT Q2` — departments treating patients with no staff record.
> 4. Join result to `dim_department` for names.
> 5. Investigate: are these data quality issues or legitimate edge cases?

> 📚 **Concept:** Set operations (EXCEPT) are cleaner than complex subqueries for population-level comparisons. Departments with patient visits but no staffing records are an operational anomaly worth flagging. In healthcare analytics, this pattern catches data pipeline failures — e.g., the staffing feed failed to load for certain departments.
> 🐘 **PG Ref:** [Set operations](https://www.postgresql.org/docs/current/queries-union.html)
> 🔬 **DS Equivalent:** `set(visit_depts) - set(staffed_depts)` — two-set difference identifying the gap population.

---

## 🔴 Advanced
> 3–6 tables · Performance-aware · Cross-phase concepts

---

### Q1. Hospital Performance Scorecard
Build a hospital scorecard joining `dim_hospital`, `dim_region`, `fact_financials`, and aggregated metrics from `fact_patient_visits`. Show hospital name, region, total visits, avg satisfaction, avg wait time, profit margin. Join all four sources.

> 🔍 **Hint:** Tables: 4 tables. Concepts: Multi-source join, GROUP BY multiple dims, aggregate functions, LEFT JOIN to preserve hospitals with no visits.

> 🪜 **Steps:**
> 1. Start with `dim_hospital dh JOIN dim_region dr ON dh.region_id = dr.region_id`.
> 2. `LEFT JOIN fact_financials ff ON dh.hospital_id = ff.hospital_id`.
> 3. `LEFT JOIN fact_patient_visits fpv ON dh.hospital_id = fpv.hospital_id`.
> 4. GROUP BY: `dh.hospital_name, dr.region_name, ff.profit_margin`.
> 5. Aggregate: `COUNT(fpv.visit_id)`, `AVG(fpv.satisfaction_score)`, `AVG(fpv.wait_time_minutes)`.

> 📚 **Concept:** Multi-source scorecards are the output of star schema design. The LEFT JOINs ensure hospitals with no visits or no financial data still appear in the report (with NULLs for missing metrics). Use `COALESCE(COUNT(fpv.visit_id), 0)` to replace NULL counts with 0. This is the canonical BI report query.
> 🐘 **PG Ref:** [COALESCE](https://www.postgresql.org/docs/current/functions-conditional.html) | [Star schema patterns](https://www.postgresql.org/docs/current/performance-tips.html)
> 🔬 **DS Equivalent:** Feature engineering for a hospital quality ML model — joining multiple data sources into one analytical feature set.

---

### Q2. Burnout Risk by Region: Multi-Table Aggregation
Calculate average `burnout_risk_index` per region by joining `fact_staffing` → `dim_hospital` → `dim_region`. Show region name, hospital count, avg burnout risk, total overtime hours. Filter regions with avg burnout > 5.

> 🔍 **Hint:** Tables: `fact_staffing`, `dim_hospital`, `dim_region`. Concepts: 3-table JOIN, GROUP BY region, HAVING.

> 🪜 **Steps:**
> 1. `FROM fact_staffing fs JOIN dim_hospital dh ON fs.hospital_id = dh.hospital_id JOIN dim_region dr ON dh.region_id = dr.region_id`.
> 2. `GROUP BY dr.region_name`.
> 3. Aggregate: `COUNT(DISTINCT dh.hospital_id)`, `AVG(fs.burnout_risk_index)`, `SUM(fs.overtime_hours)`.
> 4. `HAVING AVG(fs.burnout_risk_index) > 5`.
> 5. ORDER BY avg_burnout DESC.

> 📚 **Concept:** Joining through multiple dimension levels (staffing → hospital → region) is a "drill-up" aggregation — starting from granular fact data and rolling up to a higher dimension level. This is the essence of OLAP (Online Analytical Processing). The GROUP BY level determines the granularity of the result.
> 🐘 **PG Ref:** [GROUP BY advanced](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-GROUPING-SETS)
> 🔬 **DS Equivalent:** `fact_staffing.merge(dim_hospital).merge(dim_region).groupby('region_name').agg({'burnout_risk_index': 'mean', 'overtime_hours': 'sum'})` in pandas.

---

### Q3. Mortality Analysis: High-Risk Diagnoses in ICU Departments
Join `fact_patient_visits`, `dim_diagnosis`, `dim_department`, `dim_hospital` to find visits where: `dim_diagnosis.readmission_risk = 'High'`, `dim_department.icu_capable = true`, `fact_patient_visits.mortality_flag = true`. Report hospital name, department, diagnosis category, mortality count.

> 🔍 **Hint:** Tables: 4 tables. Concepts: Multi-condition JOIN + WHERE filter, GROUP BY + COUNT for mortality count.

> 🪜 **Steps:**
> 1. Join `fact_patient_visits` to `dim_diagnosis` on `diagnosis_category` (or `diagnosis_id` if linked).
> 2. Join to `dim_department` on `department_id`.
> 3. Join to `dim_hospital` on `hospital_id`.
> 4. WHERE: all three conditions.
> 5. GROUP BY: `hospital_name, department_name, diagnosis_category`.
> 6. SELECT: count of visits, AVG treatment_cost.

> 📚 **Concept:** This query represents a clinical mortality investigation — finding the intersection of high-risk diagnoses, ICU settings, and mortality outcomes. Joining `dim_diagnosis` on the `diagnosis_category` VARCHAR column is a design issue — the schema has `diagnosis_id` in dim but `diagnosis_category` (text) in the fact table. This is a schema denormalization that requires text matching.
> 🐘 **PG Ref:** [Performance on text joins](https://www.postgresql.org/docs/current/indexes-types.html)
> 🔬 **DS Equivalent:** Survival analysis feature preparation — building a dataset of high-risk ICU patients with mortality outcomes for a Cox proportional hazards model.

---

### Q4. LATERAL JOIN: Top 3 Visits per Hospital
For each hospital in `dim_hospital`, find the 3 most expensive patient visits using a LATERAL join. Show `hospital_name`, `visit_id`, `treatment_cost`, `rank`.

> 🔍 **Hint:** Tables: `dim_hospital`, `fact_patient_visits`. Concepts: `LATERAL JOIN` (PostgreSQL-specific), subquery per outer row.

> 🪜 **Steps:**
> 1. `FROM dim_hospital dh, LATERAL (SELECT visit_id, treatment_cost FROM fact_patient_visits WHERE hospital_id = dh.hospital_id ORDER BY treatment_cost DESC LIMIT 3) top3`.
> 2. The LATERAL subquery runs once PER hospital row, referencing `dh.hospital_id` from the outer query.
> 3. Add `ROW_NUMBER() OVER (ORDER BY treatment_cost DESC)` inside LATERAL for ranking.

> 📚 **Concept:** LATERAL is PostgreSQL's "correlated subquery in FROM" — the subquery can reference columns from the preceding FROM item. It's the SQL equivalent of a pandas `apply()` per group. LATERAL is more powerful than a correlated subquery in SELECT because it can return multiple rows. Use case: top-N per group, most recent record per group, unnested arrays per row.
> 🐘 **PG Ref:** [LATERAL subqueries](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-LATERAL)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id').apply(lambda g: g.nlargest(3, 'treatment_cost'))` — per-group top-N in pandas.

---

### Q5. Self-Join: Identify Doctor Mentorship Pairs by Seniority
Using a self-join on `dim_doctor`, find pairs where one doctor (senior) has 5+ more years experience than another (junior) and both work at the same hospital. Show senior_name, junior_name, experience gap.

> 🔍 **Hint:** Tables: `dim_doctor` (self-join as d1 senior, d2 junior). Concepts: Self-join with inequality condition.

> 🪜 **Steps:**
> 1. `FROM dim_doctor d1 JOIN dim_doctor d2 ON d1.primary_hospital_id = d2.primary_hospital_id`.
> 2. Add: `AND d1.years_experience >= d2.years_experience + 5`.
> 3. Add: `AND d1.doctor_id <> d2.doctor_id` (no self-pairs).
> 4. SELECT: `d1.doctor_name AS senior`, `d2.doctor_name AS junior`, `d1.years_experience - d2.years_experience AS gap`.

> 📚 **Concept:** Self-joins with inequality conditions (`>=`, `<`) rather than equality are powerful for finding relative comparisons within the same population. The `<>` guard prevents self-pairs. Self-joins on large tables without appropriate indexes on the join key and inequality column are expensive — an index on `(primary_hospital_id, years_experience)` helps here.
> 🐘 **PG Ref:** [Non-equijoins](https://www.postgresql.org/docs/current/queries-table-expressions.html)
> 🔬 **DS Equivalent:** `df.merge(df, on='primary_hospital_id', suffixes=('_senior', '_junior')).query('years_experience_senior >= years_experience_junior + 5 and doctor_id_senior != doctor_id_junior')`.

---

### Q6. SCD Type 2 Point-in-Time Join
Given `dim_hospital_v2` (from Phase 2 Expert Q8, with `valid_from`, `valid_to` columns), join it to `fact_patient_visits` to get the hospital record as it existed AT THE TIME of each visit.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_hospital_v2`. Concepts: Range-based JOIN (temporal join) using `arrival_datetime BETWEEN valid_from AND COALESCE(valid_to, NOW())`.

> 🪜 **Steps:**
> 1. `FROM fact_patient_visits fpv JOIN dim_hospital_v2 dhv2 ON fpv.hospital_id = dhv2.hospital_id`.
> 2. AND: `fpv.arrival_datetime >= dhv2.valid_from AND (fpv.arrival_datetime < dhv2.valid_to OR dhv2.valid_to IS NULL)`.
> 3. This ensures each visit gets the hospital record that was active at visit time.
> 4. Verify: each visit matches exactly one hospital version.

> 📚 **Concept:** Temporal joins match fact records to dimension records that were valid at the fact's timestamp. This is the core of SCD Type 2 querying and feature store point-in-time correctness. Temporal joins are range-based (not equality), which means standard B-tree index lookups are less efficient — BRIN indexes or GiST indexes on timestamp ranges can help.
> 🐘 **PG Ref:** [Range types and indexes](https://www.postgresql.org/docs/current/rangetypes.html) | [BRIN indexes](https://www.postgresql.org/docs/current/brin-intro.html)
> 🔬 **DS Equivalent:** Point-in-time feature retrieval in a feature store (Feast, Hopsworks) — "what was the hospital's bed count when this patient visited?" prevents target leakage in ML training.

---

### Q7. Multi-Way UNION ALL Dashboard Feed
Build a single result set combining: (1) Hospital-level metrics from `fact_financials`, (2) Staffing summaries from `fact_staffing`, (3) Visit summaries from `fact_patient_visits`. All labeled with a `source` column. Use UNION ALL. Handle column mismatches with NULL placeholders.

> 🔍 **Hint:** Tables: All 3 fact tables. Concepts: UNION ALL with aligned columns, NULL::type casting, literal source column.

> 🪜 **Steps:**
> 1. Define a common schema: `hospital_id`, `year_int`, `metric_type`, `metric_value`, `source`.
> 2. Query 1 (financials): `SELECT hospital_id, year_int, 'Revenue' AS metric_type, revenue AS metric_value, 'Financials' AS source`.
> 3. Query 2 (staffing): `SELECT hospital_id, NULL AS year_int, 'Overtime Hours' AS metric_type, SUM(overtime_hours), 'Staffing'`.
> 4. Query 3 (visits): `SELECT hospital_id, NULL, 'Visit Count' AS metric_type, COUNT(*)::numeric, 'Visits'`.
> 5. UNION ALL all three.

> 📚 **Concept:** Entity-Attribute-Value (EAV) format via UNION ALL enables flexible dashboards — different metric types in one table. The trade-off: column alignment requires explicit NULL padding and type casting. `NULL::numeric` casts NULL to a specific type — PostgreSQL requires type-compatible columns in UNION. This pattern is common in BI tools that build "long format" data for charting.
> 🐘 **PG Ref:** [UNION type resolution](https://www.postgresql.org/docs/current/typeconv-union-case.html)
> 🔬 **DS Equivalent:** `pd.melt(df, id_vars=['hospital_id'], value_vars=['revenue','overtime_hours'])` — converting wide to long format for visualization.

---

### Q8. Identify Patients Treated Across Multiple Hospital Types
Find patients who were treated in BOTH a teaching hospital AND a non-teaching hospital (appear in both sets). Use INTERSECT.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_hospital`. Concepts: JOIN to dim, INTERSECT between filtered populations.

> 🪜 **Steps:**
> 1. Query 1: patients treated in teaching hospitals: `SELECT fpv.patient_id FROM fact_patient_visits fpv JOIN dim_hospital dh ON fpv.hospital_id = dh.hospital_id WHERE dh.teaching_hospital = true`.
> 2. Query 2: patients treated in non-teaching: same, `WHERE dh.teaching_hospital = false`.
> 3. `Q1 INTERSECT Q2` — patients who experienced both.
> 4. Join result to `dim_patient` for demographic context.

> 📚 **Concept:** INTERSECT with a preceding JOIN is a powerful patient cohort builder. This pattern identifies "crossover" patients — those who experienced different care settings. In healthcare research, this is used for comparative effectiveness studies. The JOIN enriches both queries with necessary dimension attributes before set operations are applied.
> 🐘 **PG Ref:** [Set operations after joins](https://www.postgresql.org/docs/current/queries-union.html)
> 🔬 **DS Equivalent:** `set(teaching_patients) & set(non_teaching_patients)` — two-set intersection after separate grouped filters.

---

### Q9. Join Cardinality: Understanding How Row Counts Propagate
Query the row counts at each step of a 4-table join: (1) fact_patient_visits alone, (2) after joining dim_patient, (3) after joining dim_doctor, (4) after joining dim_hospital. Do the counts change? Why?

> 🔍 **Hint:** Tables: All 4. Concepts: INNER JOIN cardinality — rows are never added, may be reduced when FKs have no match; LEFT JOIN preserves left table count.

> 🪜 **Steps:**
> 1. `SELECT COUNT(*) FROM fact_patient_visits` — baseline.
> 2. `SELECT COUNT(*) FROM fact_patient_visits fpv JOIN dim_patient dp ON ...` — INNER JOIN.
> 3. Repeat for each additional JOIN.
> 4. Compare counts — where do rows get dropped?
> 5. Repeat with LEFT JOINs and compare.

> 📚 **Concept:** INNER JOIN can only decrease or maintain row count (rows with no FK match are dropped). LEFT JOIN preserves the left table's row count. If an INNER JOIN reduces rows unexpectedly, it reveals FK violations or NULLs in the join column. Understanding join cardinality is essential for debugging unexpected row count discrepancies in reports.
> 🐘 **PG Ref:** [EXPLAIN cardinality estimation](https://www.postgresql.org/docs/current/sql-explain.html)
> 🔬 **DS Equivalent:** `print(df.shape)` after each `pd.merge()` step — tracking row count changes is a standard debugging technique for complex merge pipelines.

---

### Q10. All-Dimension Hospital Snapshot (Denormalization)
Build a fully denormalized snapshot by joining ALL dimension tables relevant to hospitals: `dim_hospital` + `dim_region` + aggregated `fact_patient_visits` + aggregated `fact_staffing` + aggregated `fact_financials`. One row per hospital with all metrics.

> 🔍 **Hint:** Tables: All 6 tables. Concepts: Multiple LEFT JOINs, pre-aggregated subqueries or CTEs as join targets.

> 🪜 **Steps:**
> 1. Pre-aggregate each fact table into a subquery: `(SELECT hospital_id, COUNT(*) AS visit_count, AVG(treatment_cost) AS avg_cost FROM fact_patient_visits GROUP BY hospital_id) fpv_agg`.
> 2. Similarly for `fact_staffing` (avg burnout, total overtime) and `fact_financials` (avg profit margin).
> 3. `FROM dim_hospital dh LEFT JOIN dim_region dr ON ... LEFT JOIN fpv_agg ON ... LEFT JOIN fs_agg ON ... LEFT JOIN ff_agg ON ...`.
> 4. One row per hospital with all pre-aggregated metrics.

> 📚 **Concept:** This is the "one big table" anti-pattern done correctly — pre-aggregate fact tables BEFORE joining to avoid row multiplication. Joining a fact table directly to another fact table without pre-aggregation creates a many-to-many explosion (M × N rows). Always pre-aggregate or use CTEs (Phase 6) to reduce cardinality before cross-fact joins.
> 🐘 **PG Ref:** [Subquery optimization](https://www.postgresql.org/docs/current/planner-optimizer.html)
> 🔬 **DS Equivalent:** Building a hospital-level feature matrix for ML — one row per hospital with aggregated features from multiple sources. Standard feature engineering workflow.

---

## ⚫ Expert
> Star schema mastery · Performance-aware · Real-world analytics

---

### Q1. Explain Plan Analysis on a Multi-Table Join
Run `EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)` on the 4-table star join from Q1 of Advanced. Identify: join types used (hash/nested loop/merge), which table is the outer in each join, estimated vs actual row counts, and buffer hits/misses.

> 🔍 **Hint:** `EXPLAIN (ANALYZE, BUFFERS) SELECT ...`. Look for: `Hash Join`, `Nested Loop`, `Seq Scan` vs `Index Scan`, `Rows=` estimates vs actuals.

> 🪜 **Steps:**
> 1. Prefix the 4-table join query with `EXPLAIN (ANALYZE, BUFFERS)`.
> 2. Read the plan tree — innermost node executes first.
> 3. Identify join types: Hash Join (large tables), Nested Loop (small table + index), Merge Join (pre-sorted).
> 4. Find rows estimate vs actual — large discrepancies indicate stale statistics.
> 5. Buffer hits (`shared hit`) vs reads (`shared read`) — high read count means cold cache.

> 📚 **Concept:** `EXPLAIN ANALYZE` is the most important SQL performance tool. Each node shows estimated vs actual rows — discrepancies > 10x indicate stale table statistics (run `ANALYZE table_name` to update). Nested Loop is efficient when the inner table is small and indexed. Seq Scan on a large table = missing index. `Buffers: shared hit/read` shows cache efficiency.
> 🐘 **PG Ref:** [EXPLAIN](https://www.postgresql.org/docs/current/sql-explain.html) | [Using EXPLAIN](https://www.postgresql.org/docs/current/using-explain.html)
> 🔬 **DS Equivalent:** Profiling a pandas pipeline: `%timeit`, `df.memory_usage()`, Spark's `queryExecution.executedPlan.stats`. Understanding execution plans is the DB equivalent of profiling ML pipelines.

---

### Q2. Hash Join vs Nested Loop — Force Different Plans
For the `fact_patient_visits JOIN dim_hospital` join, disable hash join to force nested loop: `SET enable_hashjoin = false`. Run both plans with EXPLAIN ANALYZE. Compare performance.

> 🔍 **Hint:** `SET enable_hashjoin = false; EXPLAIN ANALYZE SELECT ... ; SET enable_hashjoin = true;`. Compare `Execution Time`.

> 🪜 **Steps:**
> 1. Run the join normally — note execution time and join type.
> 2. `SET enable_hashjoin = false` — forces planner to avoid hash join.
> 3. Re-run with EXPLAIN ANALYZE — observe nested loop or merge join.
> 4. Compare execution times.
> 5. `SET enable_hashjoin = true` to restore.

> 📚 **Concept:** Hash Join: builds a hash table of the smaller table, probes with rows from the larger — O(N+M). Best for: large tables without usable indexes. Nested Loop: for each outer row, scan inner — O(N×M) without index, O(N×log M) with index. Best for: small outer table + indexed inner. Merge Join: both sides must be sorted — good for sorted data or indexed columns. Understanding when each is used guides index design.
> 🐘 **PG Ref:** [Planner cost constants](https://www.postgresql.org/docs/current/runtime-config-query.html#RUNTIME-CONFIG-QUERY-ENABLE) | [Join strategies](https://www.postgresql.org/docs/current/planner-optimizer.html)
> 🔬 **DS Equivalent:** Forcing different Spark join strategies (`broadcast`, `sort-merge`, `shuffle-hash`) to benchmark — the same concept as enable_hashjoin = false.

---

### Q3. Many-to-Many Join Resolution
The `fact_patient_visits` to `dim_diagnosis` relationship is effectively many-to-many (one visit has one diagnosis category, many diagnoses share a category). Create a proper bridge table `visit_diagnosis_bridge` with `visit_id` and `diagnosis_id`. Insert sample data. Then join through the bridge to get full visit+diagnosis details.

> 🔍 **Hint:** Tables: New bridge table. Concepts: Many-to-many via bridge, 3-table join through bridge.

> 🪜 **Steps:**
> 1. `CREATE TABLE visit_diagnosis_bridge (visit_id VARCHAR(30), diagnosis_id VARCHAR(20), PRIMARY KEY (visit_id, diagnosis_id))`.
> 2. Insert sample rows linking visits to specific diagnosis IDs.
> 3. Join: `fact_patient_visits fpv JOIN visit_diagnosis_bridge vdb ON fpv.visit_id = vdb.visit_id JOIN dim_diagnosis dd ON vdb.diagnosis_id = dd.diagnosis_id`.
> 4. Observe: visits can now link to MULTIPLE diagnoses (row multiplication).

> 📚 **Concept:** Many-to-many relationships require a junction/bridge table. Joining through it multiplies rows (a visit with 3 diagnoses appears 3 times). Always aggregate after joining through a bridge table if you want one row per visit. This is the standard dimensional modeling pattern for multi-valued attributes in healthcare (one patient can have multiple diagnoses per visit).
> 🐘 **PG Ref:** [Composite primary keys](https://www.postgresql.org/docs/current/ddl-constraints.html)
> 🔬 **DS Equivalent:** Multi-label classification data format — one row per label (MLBinarized) vs wide format (one column per label). The bridge table is the "long format" representation.

---

### Q4. LATERAL for Running Context Per Row
Use LATERAL to add, for each patient visit, the previous visit's treatment cost and the next visit's treatment cost (lead/lag via correlated subquery in LATERAL). Demonstrate LATERAL as an alternative to window functions (Phase 5 preview).

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: LATERAL with ORDER BY + LIMIT 1 for previous/next rows.

> 🪜 **Steps:**
> 1. `FROM fact_patient_visits fpv`.
> 2. `LEFT JOIN LATERAL (SELECT treatment_cost FROM fact_patient_visits WHERE patient_id = fpv.patient_id AND arrival_datetime < fpv.arrival_datetime ORDER BY arrival_datetime DESC LIMIT 1) prev_visit ON true`.
> 3. Same for next visit: `arrival_datetime > fpv.arrival_datetime ORDER BY arrival_datetime ASC LIMIT 1`.
> 4. Compare cost columns: current, previous, next.

> 📚 **Concept:** LATERAL is an alternative to LAG/LEAD window functions (Phase 5). It's more flexible — you can reference any column and apply complex logic inside the subquery. But it's slower than window functions because it executes once per outer row. Use window functions for standard lead/lag; use LATERAL when the per-row subquery logic is too complex for a window function.
> 🐘 **PG Ref:** [LATERAL join](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-LATERAL)
> 🔬 **DS Equivalent:** `df.apply(lambda row: prev_visit_cost(row), axis=1)` — row-wise apply that references the full DataFrame per row. Equivalent power, similar performance trade-off.

---

### Q5. Join Elimination by Planner
Write a query that joins `fact_patient_visits` with `dim_hospital` but only uses columns from `fact_patient_visits`. Use EXPLAIN to verify PostgreSQL's join elimination optimization — the planner may eliminate the unused join.

> 🔍 **Hint:** `SELECT visit_id, treatment_cost FROM fact_patient_visits fpv JOIN dim_hospital dh ON fpv.hospital_id = dh.hospital_id`. If no `dh.*` columns are selected and FK is guaranteed, planner may eliminate the join.

> 🪜 **Steps:**
> 1. Write the join but select only `fpv.*` columns.
> 2. `EXPLAIN` — check if dim_hospital appears in the plan.
> 3. With a real FK constraint enforced, the planner knows every fact row has a matching dim row — the join adds no new information if you're not selecting dim columns.
> 4. Compare plan with and without the FK constraint.

> 📚 **Concept:** Join elimination is a query optimizer technique: if a JOIN doesn't affect the result (unused columns + guaranteed FK match), the planner removes it from the execution plan. This is why properly enforced FK constraints improve query performance — not just data integrity. PostgreSQL performs this optimization with NOT NULL FK columns and guaranteed referential integrity.
> 🐘 **PG Ref:** [Query optimizer](https://www.postgresql.org/docs/current/planner-optimizer.html)
> 🔬 **DS Equivalent:** Dead code elimination in compiled languages — the compiler removes code that has no effect on the output. The query planner does the same for SQL joins.

---

### Q6. Temporal Coverage: Find Date Gaps in Fact Data
For each `hospital_id` in `fact_financials`, find months where financial data is missing (gaps in the year_int/month_name time series). Use a CROSS JOIN with a numbers series to generate expected dates.

> 🔍 **Hint:** Concepts: `generate_series()` (PostgreSQL), CROSS JOIN to generate expected months, LEFT JOIN to find actual months, ANTI JOIN to find gaps.

> 🪜 **Steps:**
> 1. `SELECT generate_series(1, 12) AS expected_month` for months 1-12.
> 2. CROSS JOIN with distinct hospital IDs: `(SELECT DISTINCT hospital_id FROM fact_financials)`.
> 3. LEFT JOIN to `fact_financials` on hospital_id + month_name.
> 4. `WHERE fact_financials.month_name IS NULL` — these are gaps.

> 📚 **Concept:** `generate_series()` generates a sequence of values — a PostgreSQL power feature for building expected date/month/year grids. CROSS JOIN with a generated series creates all expected combinations. LEFT JOIN + IS NULL pattern then finds the gaps. This is the standard SQL technique for time-series completeness checking — essential in finance, healthcare, and IoT analytics.
> 🐘 **PG Ref:** [generate_series](https://www.postgresql.org/docs/current/functions-srf.html)
> 🔬 **DS Equivalent:** `pd.date_range(...).difference(df['date'])` — finding expected dates not present in the DataFrame.

---

### Q7. Full Schema Lineage Join
Query `information_schema.table_constraints`, `information_schema.key_column_usage`, and `information_schema.referential_constraints` to build a full FK dependency graph of the schema — showing each FK relationship as: parent_table, parent_column, child_table, child_column.

> 🔍 **Hint:** Tables: `information_schema.table_constraints`, `information_schema.key_column_usage`, `information_schema.referential_constraints`. Concepts: 3-way catalog join.

> 🪜 **Steps:**
> 1. Join `table_constraints` (type = 'FOREIGN KEY') with `key_column_usage` on constraint name.
> 2. Join `referential_constraints` on constraint name to get unique constraint name (the referenced constraint).
> 3. Join again to get the referenced table's columns.
> 4. Filter to `table_schema = 'public'`.

> 📚 **Concept:** Data lineage — tracking which tables depend on which — is foundational for impact analysis ("if I change this column, what breaks?"). The `information_schema` provides this metadata. Tools like dbt, DataHub, and OpenLineage build lineage graphs by querying these catalogs. Understanding the catalog join manually gives you the insight to build your own lineage tools.
> 🐘 **PG Ref:** [information_schema.referential_constraints](https://www.postgresql.org/docs/current/infoschema-referential-constraints.html)
> 🔬 **DS Equivalent:** Building a data dependency DAG — equivalent to how Apache Airflow tracks task dependencies or MLflow tracks model-to-dataset lineage.

---

### Q8. Non-Equi Join: Finding Overlapping Shift Periods
In `fact_staffing`, find pairs of shifts at the same hospital and department that overlap in time (both Night shifts happening simultaneously). Requires a self-join with date range overlap condition.

> 🔍 **Hint:** Tables: `fact_staffing` (self-join as s1 and s2). Concepts: Non-equi join on same hospital/dept, overlap condition, `s1.shift_date = s2.shift_date`, `s1.shift_id < s2.shift_id`.

> 🪜 **Steps:**
> 1. `FROM fact_staffing s1 JOIN fact_staffing s2 ON s1.hospital_id = s2.hospital_id AND s1.department_id = s2.department_id`.
> 2. AND `s1.shift_date = s2.shift_date AND s1.shift_type = s2.shift_type`.
> 3. AND `s1.shift_id < s2.shift_id` (avoid duplicates).
> 4. This finds duplicate shifts for same hospital/dept/date/type.

> 📚 **Concept:** Non-equi joins (conditions other than `=`) are powerful but expensive without indexes. A self-join with date overlap conditions is a standard technique for detecting scheduling conflicts, overlapping events, or duplicate bookings. In healthcare, this might catch double-booked OR tables or conflicting staff schedules — a real operational quality check.
> 🐘 **PG Ref:** [Non-equi joins](https://www.postgresql.org/docs/current/queries-table-expressions.html)
> 🔬 **DS Equivalent:** Interval overlap detection: `(s1.start < s2.end) AND (s1.end > s2.start)` — the standard interval overlap algorithm, applied in pandas with `apply()` or vectorized boolean indexing.

---

### Q9. Column-Level Join Conditions: Multiple ON Conditions
Write a query joining `fact_patient_visits` to `fact_staffing` matching on BOTH `hospital_id` AND `department_id` (not just hospital). Then identify visits where no staff shift record exists for that specific hospital-department combination.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `fact_staffing`. Concepts: Multi-column join ON condition, ANTI JOIN.

> 🪜 **Steps:**
> 1. `FROM fact_patient_visits fpv LEFT JOIN fact_staffing fs ON fpv.hospital_id = fs.hospital_id AND fpv.department_id = fs.department_id`.
> 2. `WHERE fs.shift_id IS NULL` — visits with no matching staff shift.
> 3. Show: visit_id, hospital_id, department_id, admission_type.

> 📚 **Concept:** Multi-column join conditions in ON clauses are common in fact-to-fact joins where no single surrogate key connects them. Composite join conditions can use indexes on `(hospital_id, department_id)` — PostgreSQL can use a composite index for both conditions simultaneously. Single-column indexes on each individually may not be used for the composite join condition.
> 🐘 **PG Ref:** [Composite indexes for joins](https://www.postgresql.org/docs/current/indexes-multicolumn.html)
> 🔬 **DS Equivalent:** `pd.merge(df1, df2, on=['hospital_id', 'department_id'], how='left')` — multi-key merge in pandas.

---

### Q10. Parallel Query Awareness
Write a 5-table star join on `fact_patient_visits` with all 4 dimension tables. Enable parallel query (`SET max_parallel_workers_per_gather = 4`) and run `EXPLAIN ANALYZE`. Identify whether any `Gather` or `Gather Merge` nodes appear — these indicate parallel execution.

> 🔍 **Hint:** `SET max_parallel_workers_per_gather = 4; EXPLAIN (ANALYZE, BUFFERS) SELECT ...`. Look for `Gather` nodes in the plan.

> 🪜 **Steps:**
> 1. `SET max_parallel_workers_per_gather = 4`.
> 2. Write the 5-table join query.
> 3. `EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)`.
> 4. Identify `Parallel Seq Scan`, `Parallel Hash`, `Gather Merge` nodes.
> 5. Compare execution time with `max_parallel_workers_per_gather = 1`.

> 📚 **Concept:** PostgreSQL supports parallel query execution — splitting a Seq Scan or Hash Join across multiple worker processes. `Gather` nodes collect results from workers. Parallel query accelerates large analytical queries (full table scans, large aggregations, hash joins). Table-level `parallel_workers` parameter and row count threshold (`parallel_tuple_cost`, `min_parallel_table_scan_size`) control eligibility.
> 🐘 **PG Ref:** [Parallel query](https://www.postgresql.org/docs/current/parallel-query.html) | [Parallel plans](https://www.postgresql.org/docs/current/parallel-plans.html)
> 🔬 **DS Equivalent:** Distributed compute in Spark/Dask — `Gather` nodes are like Spark's `collect()` stage that aggregates results from distributed workers into a single node.

---

## 💎 Super Expert
> No questions. Curated next-level topics for world-class practitioners.

---

### 🚀 What to Master After Phase 3

**1. Join Ordering and the `join_collapse_limit` Planner Setting**
PostgreSQL tries all possible join orderings up to `join_collapse_limit` (default: 8) tables. For 9+ table joins, it uses a greedy algorithm. Understand: when does the planner make wrong choices? How to use `EXPLAIN` to identify bad join orders? When to use `SET join_collapse_limit = 1` to force explicit left-to-right ordering? Why: you'll encounter 10+ table joins in real data warehouses.

**2. Hash Join, Merge Join, Nested Loop — Deep Internals**
Know exactly: when is each chosen? How does `work_mem` affect hash join performance (larger work_mem = larger hash table = fewer passes)? What is a multi-batch hash join? When does merge join beat hash join? This knowledge enables targeted `work_mem` tuning — setting `SET work_mem = '256MB'` for a heavy analytical session can 10x hash join performance.

**3. Partition-Wise Joins**
When joining two partitioned tables (both partitioned by the same key, e.g., hospital_id or date), PostgreSQL can execute partition-wise joins — each pair of matching partitions joined independently, in parallel. Enable: `SET enable_partitionwise_join = on`. Why it matters: joins between large partitioned fact tables (visits × financials by month) are dramatically faster with partition-wise execution.

**4. Materialized CTEs as Join Optimization**
In PostgreSQL 12+, CTEs are non-materialized by default (inlined). Sometimes you want to force materialization (`WITH cte AS MATERIALIZED (...)`) to prevent a complex subquery from being re-evaluated multiple times in a query. Understanding when to materialize CTEs vs let them inline is an advanced query tuning skill.

**5. GIN and GiST Indexes for Non-Standard Joins**
Standard B-tree indexes support equality and range joins. For: full-text search joins (`tsvector JOIN tsvector`), JSON containment joins, array overlap joins, and geometric/geospatial joins (using `latitude`/`longitude` in your schema), GIN and GiST indexes are required. PostGIS uses GiST indexes for spatial joins — 1000x faster than calculating distances row by row.

**6. Foreign Data Wrappers (FDW) for Cross-Database Joins**
`postgres_fdw` enables joining tables from a remote PostgreSQL database as if they were local. `file_fdw` joins against CSV files. This is how data federation works — querying across a data lake and a warehouse in one SQL statement. When: your hospital schema is split across multiple databases or you need to join against S3/external data. Why you stand out: very few practitioners understand FDW.

**7. Join Strategies in Distributed SQL (Redshift, BigQuery, Spark SQL)**
The join concepts from PostgreSQL translate directly to distributed systems. Broadcast join (Spark: `BROADCAST`) = Nested Loop (small table replicated to all nodes). Shuffle join = Hash Join (both tables repartitioned by join key). Sort-merge join = Merge Join. Understanding PostgreSQL's join mechanics gives you a head start on Spark, Trino, Redshift, and BigQuery query optimization — all use the same fundamental strategies.
