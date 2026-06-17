# 📗 Phase 2 — Core SQL Commands
## DDL · DML · Filtering · Constraints · Sequences
### PostgreSQL | NHS Hospital Analytics | Data Science Perspective

---

## 📋 Phase Topics

| Command Group | Commands Covered |
|---|---|
| Data Retrieval | `SELECT`, `DISTINCT`, `ORDER BY`, `LIMIT`, `OFFSET` |
| DDL | `CREATE TABLE`, `ALTER TABLE`, `DROP`, `RENAME`, `CREATE SEQUENCE`, `COMMENT ON` |
| DML | `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, `RETURNING` |
| Filtering | `WHERE`, `AND`, `OR`, `NOT`, `LIKE`, `ILIKE`, `BETWEEN`, `IN`, `IS NULL`, `IS NOT NULL` |
| Constraints | `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `NOT NULL`, `DEFAULT` |
| Extras | `SERIAL`, `GENERATED ALWAYS AS IDENTITY`, `CTAS`, system catalogs, soft deletes |

---

## 🗺️ Question Format Guide

| Level | Format | Tables | Depth |
|---|---|---|---|
| 🟢 Beginner | Q → Hint → Concept | 1 table | Phase commands only |
| 🟡 Medium | Q → Hint → Concept | 2 tables | 2+ mixed concepts |
| 🟠 Medium Hard | Q → Hint → **Steps** → Concept | 2–3 tables | Mixed phases |
| 🔴 Advanced | Q → Hint → **Steps** → Concept | 3+ tables | Cross-phase analytics |
| ⚫ Expert | Q → Hint → **Steps** → Concept | All relevant | Deep analytical |
| 💎 Super Expert | Suggestions only | — | What to master next |

---

## 🟢 Beginner

---

### Q1. First Look at the Patient Dimension

Retrieve all columns and all rows from `dim_patient` to get a first look at the data.

> 🔍 **Hint:** Use the `*` wildcard to select all columns.

> 📚 **Concept:** `SELECT *` returns every row and column. Useful for initial exploration but avoid in production — it increases I/O, breaks when schema changes, and leaks sensitive columns. Always project only the columns you need.
> 🐘 **PG Ref:** [`SELECT` docs](https://www.postgresql.org/docs/current/sql-select.html)
> 🔬 **DS Equivalent:** `df.head()` or `df` in pandas — the very first thing you do to inspect a new DataFrame.

---

### Q2. Project Only Needed Columns

Retrieve `patient_id`, `age`, `gender`, and `risk_category` from `dim_patient`.

> 🔍 **Hint:** List column names separated by commas after `SELECT`.

> 📚 **Concept:** Column projection reduces I/O and memory. In wide fact tables like `fact_patient_visits` (25+ columns), projecting only needed columns can cut query cost by 80%. This is especially important in columnar storage engines (Redshift, BigQuery, Parquet) where unused columns are never read.
> 🐘 **PG Ref:** [Query select list](https://www.postgresql.org/docs/current/queries-select-lists.html)
> 🔬 **DS Equivalent:** `df[['patient_id', 'age', 'gender', 'risk_category']]` — column subsetting in pandas.

---

### Q3. Discover Admission Types

Find all unique values of `admission_type` from `fact_patient_visits` to understand what categories exist.

> 🔍 **Hint:** Use `DISTINCT` before the column name.

> 📚 **Concept:** `DISTINCT` deduplicates results. PostgreSQL uses sorting or hashing internally — it can be slow on large tables without an index. For counting distinct values: `COUNT(DISTINCT col)`. Use this during EDA to understand column cardinality before building filters or GROUP BY logic.
> 🐘 **PG Ref:** [DISTINCT clause](https://www.postgresql.org/docs/current/sql-select.html#SQL-DISTINCT)
> 🔬 **DS Equivalent:** `df['admission_type'].unique()` or `df['admission_type'].nunique()` in pandas.

---

### Q4. Top 10 Largest Hospitals

From `dim_hospital`, retrieve `hospital_name`, `city`, and `beds` ordered by `beds` descending. Show only the first 10.

> 🔍 **Hint:** Use `ORDER BY beds DESC LIMIT 10`.

> 📚 **Concept:** `ORDER BY` is cosmetic — it does not change physical storage. Always pair `LIMIT` with `ORDER BY`; without it, LIMIT returns arbitrary rows (non-deterministic). For pagination, combine with `OFFSET n` — but beware: `OFFSET` + `LIMIT` on large tables is slow because PostgreSQL must scan and skip `n` rows every time. Keyset pagination is faster.
> 🐘 **PG Ref:** [LIMIT / OFFSET](https://www.postgresql.org/docs/current/queries-limit.html)
> 🔬 **DS Equivalent:** `df.nlargest(10, 'beds')[['hospital_name', 'city', 'beds']]` in pandas.

---

### Q5. Find ICU-Capable Departments

Retrieve all records from `dim_department` where `icu_capable = true`.

> 🔍 **Hint:** In PostgreSQL, boolean literals are `true` / `false` (lowercase). `WHERE icu_capable` is valid shorthand.

> 📚 **Concept:** PostgreSQL has a native BOOLEAN type — no need for 0/1 or 'Y'/'N' flags. Shorthand: `WHERE icu_capable` is identical to `WHERE icu_capable = true`. Boolean columns are also efficient in aggregations: `SUM(icu_capable::int)` counts TRUE values.
> 🐘 **PG Ref:** [Boolean type](https://www.postgresql.org/docs/current/datatype-boolean.html)
> 🔬 **DS Equivalent:** `df[df['icu_capable']]` — filtering on a boolean Series in pandas.

---

### Q6. Back Up a Table's Structure

Create a new empty table `dim_patient_backup` with the same columns as `dim_patient`, but no data.

> 🔍 **Hint:** `CREATE TABLE dim_patient_backup (LIKE dim_patient)`.

> 📚 **Concept:** `CREATE TABLE ... (LIKE source)` copies column names, data types, and defaults. Add `INCLUDING ALL` to also copy indexes, constraints, and sequences. This is the professional pattern before any destructive DML — create structure backup, run operation, verify, then optionally drop backup.
> 🐘 **PG Ref:** [CREATE TABLE — LIKE clause](https://www.postgresql.org/docs/current/sql-createtable.html)
> 🔬 **DS Equivalent:** `df.copy()` — creating a safe copy before in-place transformations.

---

### Q7. Add a Contact Column to Doctors

Add a `contact_email VARCHAR(150)` column to the `dim_doctor` table.

> 🔍 **Hint:** `ALTER TABLE dim_doctor ADD COLUMN contact_email VARCHAR(150)`.

> 📚 **Concept:** In PostgreSQL 11+, adding a nullable column is metadata-only — instant, even on billions of rows. Adding a `NOT NULL` column without a `DEFAULT` requires a full table rewrite (can take hours). Workaround: add nullable first, backfill with UPDATE, then add NOT NULL constraint using `ALTER COLUMN SET NOT NULL`.
> 🐘 **PG Ref:** [ALTER TABLE](https://www.postgresql.org/docs/current/sql-altertable.html)
> 🔬 **DS Equivalent:** `df['contact_email'] = None` — adding a new column with null values to a DataFrame.

---

### Q8. Rename a Column

Rename `contact_email` to `work_email` in `dim_doctor`.

> 🔍 **Hint:** `ALTER TABLE dim_doctor RENAME COLUMN contact_email TO work_email`.

> 📚 **Concept:** `RENAME COLUMN` updates only the metadata — instant. But any views, stored procedures, triggers, or application queries referencing the old name will break. Always use `pg_depend` or `information_schema.view_column_usage` to audit dependencies before renaming.
> 🐘 **PG Ref:** [ALTER TABLE — RENAME](https://www.postgresql.org/docs/current/sql-altertable.html)
> 🔬 **DS Equivalent:** `df.rename(columns={'contact_email': 'work_email'}, inplace=True)` in pandas.

---

### Q9. Drop a Column

Drop the `work_email` column from `dim_doctor`.

> 🔍 **Hint:** `ALTER TABLE dim_doctor DROP COLUMN work_email`. Add `CASCADE` to also drop dependent views.

> 📚 **Concept:** `DROP COLUMN` removes the column and its data permanently from the table. PostgreSQL marks it as dropped in the catalog but does not immediately reclaim disk space — the physical bytes are reclaimed during the next `VACUUM FULL`. For columns referenced by indexes or constraints, use `DROP COLUMN CASCADE`.
> 🐘 **PG Ref:** [ALTER TABLE](https://www.postgresql.org/docs/current/sql-altertable.html)
> 🔬 **DS Equivalent:** `df.drop(columns=['work_email'], inplace=True)` in pandas.

---

### Q10. Insert a New Region

Insert one new record into `dim_region`. Choose values for all columns. Always list column names explicitly.

> 🔍 **Hint:** `INSERT INTO dim_region (region_id, region_name, ...) VALUES ('R999', 'Test Region', ...)`.

> 📚 **Concept:** Never rely on positional INSERT (no column list). If the schema changes — a column is added, reordered, or removed — positional inserts silently insert wrong data or error. Named column inserts are self-documenting and schema-change safe. PostgreSQL's `INSERT ... RETURNING *` shows the inserted row, useful for confirmation.
> 🐘 **PG Ref:** [INSERT](https://www.postgresql.org/docs/current/sql-insert.html)
> 🔬 **DS Equivalent:** `pd.concat([df, pd.DataFrame([new_row])], ignore_index=True)` — appending a new row to a DataFrame.

---

### Q11. Fix a Hospital's City

Update the `city` of the hospital with `hospital_id = 'H001'` to `'Manchester'`.

> 🔍 **Hint:** `UPDATE dim_hospital SET city = 'Manchester' WHERE hospital_id = 'H001'`.

> 📚 **Concept:** ALWAYS use `WHERE` in `UPDATE`. Omitting it updates every row in the table — one of the most destructive DML mistakes. Best practice: run `SELECT * FROM dim_hospital WHERE hospital_id = 'H001'` first to confirm exactly which rows will be affected. In PostgreSQL, `UPDATE ... RETURNING *` shows you what changed.
> 🐘 **PG Ref:** [UPDATE — RETURNING](https://www.postgresql.org/docs/current/sql-update.html)
> 🔬 **DS Equivalent:** `df.loc[df['hospital_id'] == 'H001', 'city'] = 'Manchester'` — targeted row mutation in pandas.

---

### Q12. Remove Unknown-Risk Patients

Delete all records from `dim_patient` where `risk_category = 'Unknown'`.

> 🔍 **Hint:** `DELETE FROM dim_patient WHERE risk_category = 'Unknown'`. Add `RETURNING patient_id` to confirm.

> 📚 **Concept:** Always use `WHERE` with `DELETE`. `TRUNCATE` is faster for removing ALL rows (no row-level WAL logging). `DELETE ... RETURNING *` returns deleted rows — you can even log them: `INSERT INTO archive SELECT * FROM old WHERE ... ; DELETE FROM old WHERE ...` (both in one transaction). In warehouses, prefer soft deletes (a boolean flag) over physical deletes.
> 🐘 **PG Ref:** [DELETE — RETURNING](https://www.postgresql.org/docs/current/sql-delete.html)
> 🔬 **DS Equivalent:** `df = df[df['risk_category'] != 'Unknown']` — the filter-out pattern in pandas.

---

## 🟡 Medium
> 2 tables · 2+ concepts merged · Table names in hints

---

### Q1. Big Teaching Hospitals

From `dim_hospital`, retrieve `hospital_name`, `city`, `beds`, `icu_beds` where `beds > 500` AND `teaching_hospital = true`. Sort by `beds` descending.

> 🔍 **Hint:** Tables: `dim_hospital`. Concepts: `AND`, boolean filter, `ORDER BY`.

> 📚 **Concept:** Execution order: FROM → WHERE → SELECT → ORDER BY. `AND` requires ALL conditions to be true. Placing the most selective condition first in `AND` chains helps readability (not performance — the optimizer reorders anyway). Always use explicit `ORDER BY` when combining with `LIMIT`.
> 🐘 **PG Ref:** [Logical operators](https://www.postgresql.org/docs/current/functions-logical.html)
> 🔬 **DS Equivalent:** `df[(df['beds'] > 500) & (df['teaching_hospital'])]` — note `&` not `and`; `and` would throw a ValueError in pandas.

---

### Q2. High-Risk Patient Profile

From `dim_patient`, find patients whose `risk_category IN ('High', 'Critical')` AND `chronic_condition_count > 2`. Show `patient_id`, `age`, `gender`, `risk_category`, `chronic_condition_count`.

> 🔍 **Hint:** Tables: `dim_patient`. Concepts: `IN`, `AND`.

> 📚 **Concept:** `IN ('A','B')` is syntactic sugar for `col = 'A' OR col = 'B'`. The optimizer handles both the same way. Prefer `IN` for 3+ values — it's cleaner. For very large lists (1000+), `IN (subquery)` is better, or join to a temp table which the optimizer can hash-join efficiently.
> 🐘 **PG Ref:** [Row and Array comparison](https://www.postgresql.org/docs/current/functions-comparisons.html)
> 🔬 **DS Equivalent:** `df[df['risk_category'].isin(['High', 'Critical']) & (df['chronic_condition_count'] > 2)]` in pandas.

---

### Q3. Experienced Cardiology Specialists

From `dim_doctor`, find doctors whose `specialty` contains 'Cardio' (case-insensitive) AND `years_experience > 10`. Show `doctor_name`, `specialty`, `grade`, `years_experience`.

> 🔍 **Hint:** Tables: `dim_doctor`. Concepts: `ILIKE` (case-insensitive LIKE in PostgreSQL), `%` wildcard, `AND`.

> 📚 **Concept:** PostgreSQL's `ILIKE` is case-insensitive LIKE — not available in most other RDBMS. Both `LIKE` and `ILIKE` with a leading `%` cannot use a B-tree index (sequential scan). For large-scale text search, enable the `pg_trgm` extension and create a GIN trigram index — it supports fast ILIKE queries.
> 🐘 **PG Ref:** [Pattern matching](https://www.postgresql.org/docs/current/functions-matching.html) | Extension: [pg_trgm](https://www.postgresql.org/docs/current/pgtrgm.html)
> 🔬 **DS Equivalent:** `df[df['specialty'].str.contains('Cardio', case=False, na=False) & (df['years_experience'] > 10)]` — `na=False` prevents errors on NULLs.

---

### Q4. Emergency Visits at Moderate-High Severity

From `fact_patient_visits`, retrieve visits where `severity_level BETWEEN 3 AND 5` AND `admission_type = 'Emergency'`. Show `visit_id`, `patient_id`, `severity_level`, `wait_time_minutes`.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `BETWEEN`, `AND`.

> 📚 **Concept:** `BETWEEN a AND b` is inclusive on both ends (`>= a AND <= b`). For timestamps, `BETWEEN '2024-01-01' AND '2024-01-31'` misses records at `2024-01-31 12:00:00` — use explicit `>= ... AND <` for timestamps. For a composite index on `(admission_type, severity_level)`, PostgreSQL will use an index range scan here.
> 🐘 **PG Ref:** [Comparison operators](https://www.postgresql.org/docs/current/functions-comparison.html)
> 🔬 **DS Equivalent:** `df[(df['severity_level'].between(3, 5)) & (df['admission_type'] == 'Emergency')]` in pandas.

---

### Q5. Clinical ICU Departments Only

From `dim_department`, retrieve departments that are NOT 'Administrative' AND are ICU capable. Show all columns, ordered by `department_name`.

> 🔍 **Hint:** Tables: `dim_department`. Concepts: `<>`, boolean filter, `ORDER BY`.

> 📚 **Concept:** `<>` is ANSI-standard for not-equal (same as `!=`). Critical trap: `NOT IN (subquery)` — if the subquery returns any NULL, the ENTIRE `NOT IN` result is empty (NULL propagation). Always add `WHERE col IS NOT NULL` inside NOT IN subqueries, or use `NOT EXISTS` which is NULL-safe.
> 🐘 **PG Ref:** [Comparison operators](https://www.postgresql.org/docs/current/functions-comparison.html)
> 🔬 **DS Equivalent:** `df[(df['type'] != 'Administrative') & df['icu_capable']]` in pandas.

---

### Q6. Top 20 Most Expensive Diagnosis Visits

From `fact_patient_visits`, filter visits where `diagnosis_category IN ('Cardiac', 'Respiratory', 'Neurological')`. Show `visit_id`, `patient_id`, `diagnosis_category`, `treatment_cost`. Order by `treatment_cost` DESC, limit 20.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `IN`, `ORDER BY`, `LIMIT`.

> 📚 **Concept:** `IN` + `ORDER BY` + `LIMIT` = "Top-N within a filter" — the most common analytics pattern. PostgreSQL evaluates WHERE first, then sorts, then limits. A covering index on `(diagnosis_category, treatment_cost DESC)` would allow this query to complete with an index-only scan — no heap access needed.
> 🐘 **PG Ref:** [Index-only scans](https://www.postgresql.org/docs/current/indexes-index-only-scans.html)
> 🔬 **DS Equivalent:** `df[df['diagnosis_category'].isin([...])].nlargest(20, 'treatment_cost')` in pandas.

---

### Q7. Create and Populate a Tier Table

Create `dim_hospital_tier` with: `tier_id VARCHAR(20) PRIMARY KEY`, `hospital_id VARCHAR(20)`, `tier_label VARCHAR(50)`, `assigned_date DATE`. Insert 3 rows using a single multi-row INSERT.

> 🔍 **Hint:** Tables: New `dim_hospital_tier`. Concepts: `CREATE TABLE` with inline PRIMARY KEY, multi-row `INSERT INTO ... VALUES (...), (...), (...)`.

> 📚 **Concept:** Multi-row INSERT in one statement is far more efficient than 3 separate statements — fewer round trips, single transaction. PostgreSQL's `INSERT ... ON CONFLICT DO NOTHING` (upsert) is useful when re-running scripts. Declaring PRIMARY KEY inline creates a unique B-tree index automatically.
> 🐘 **PG Ref:** [INSERT multiple rows](https://www.postgresql.org/docs/current/sql-insert.html)
> 🔬 **DS Equivalent:** `df.to_sql('dim_hospital_tier', engine, if_exists='append')` — bulk insert from pandas to PostgreSQL.

---

### Q8. Escalate High-Burden Patients to Critical

Update `dim_patient`: set `risk_category = 'Critical'` for all patients who have 4+ chronic conditions AND whose current `risk_category` is 'High'.

> 🔍 **Hint:** Tables: `dim_patient`. Concepts: `UPDATE ... SET ... WHERE`, `AND`, `>=`, `RETURNING`.

> 📚 **Concept:** Multi-condition UPDATE is a data migration pattern. Add `RETURNING patient_id, risk_category` to see which rows were affected without a follow-up SELECT. In large tables, run `EXPLAIN` on the equivalent SELECT first to ensure the WHERE clause uses an index — a full sequential scan on a million-row update can lock the table for a long time.
> 🐘 **PG Ref:** [UPDATE — RETURNING](https://www.postgresql.org/docs/current/sql-update.html)
> 🔬 **DS Equivalent:** `df.loc[(df['chronic_condition_count'] >= 4) & (df['risk_category'] == 'High'), 'risk_category'] = 'Critical'`.

---

### Q9. Royal or Large Non-Private Hospitals

From `dim_hospital`, find hospitals where `hospital_name LIKE 'Royal%'` OR `beds > 1000`, but EXCLUDE private hospitals (`private_int = false`). Display `hospital_id`, `hospital_name`, `beds`, `private_int`.

> 🔍 **Hint:** Tables: `dim_hospital`. Concepts: `LIKE`, `OR`, `AND`, operator precedence — **use parentheses!**

> 📚 **Concept:** `AND` has higher precedence than `OR`. Without parentheses: `A OR B AND C` = `A OR (B AND C)` — not what you intended. Always parenthesize OR groups: `(name LIKE 'Royal%' OR beds > 1000) AND private_int = false`. This is one of the most common SQL logic bugs in production code.
> 🐘 **PG Ref:** [Operator precedence](https://www.postgresql.org/docs/current/sql-expressions.html#OPERATOR-PRECEDENCE)
> 🔬 **DS Equivalent:** `df[((df['hospital_name'].str.startswith('Royal')) | (df['beds'] > 1000)) & (~df['private_int'])]` — the extra outer parentheses in pandas mirror the SQL precedence rule.

---

### Q10. Enforce Age and Gender Integrity

Add a CHECK constraint to `dim_patient` ensuring `age BETWEEN 0 AND 120`. Also set `gender` to NOT NULL.

> 🔍 **Hint:** Tables: `dim_patient`. Concepts: `ALTER TABLE ADD CONSTRAINT ... CHECK (...)`, `ALTER COLUMN ... SET NOT NULL`.

> 📚 **Concept:** CHECK constraints enforce domain integrity at the database layer — they reject invalid data before it reaches storage. In bulk ETL loads, constraints can be disabled for performance and re-enabled after using `ALTER TABLE ... VALIDATE CONSTRAINT` (validates existing rows without blocking). This is standard in warehouse refresh workflows.
> 🐘 **PG Ref:** [Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html)
> 🔬 **DS Equivalent:** Schema validation libraries (Pydantic, Pandera, Great Expectations) — SQL constraints are the database-native version of the same concept.

---

### Q11. Detect High-Risk Night Shifts in January

From `fact_staffing`, find shifts where `month_name = 1`, `overtime_hours > 8`, AND `burnout_risk_index > 7`. Show `shift_id`, `hospital_id`, `shift_type`, `burnout_risk_index`, `overtime_hours`.

> 🔍 **Hint:** Tables: `fact_staffing`. Concepts: `WHERE`, `AND`, numeric comparisons.

> 📚 **Concept:** Multi-condition filtering on large fact tables is where indexes matter most. A composite index on `(month_name, overtime_hours, burnout_risk_index)` would turn this query from a sequential scan to an index range scan. Run `EXPLAIN (ANALYZE, BUFFERS)` to see whether an index is being used and how many disk pages are read.
> 🐘 **PG Ref:** [Multi-column indexes](https://www.postgresql.org/docs/current/indexes-multicolumn.html)
> 🔬 **DS Equivalent:** `df[(df['month_name'] == 1) & (df['overtime_hours'] > 8) & (df['burnout_risk_index'] > 7)]` in pandas.

---

### Q12. Known Insurance Types Alphabetically

Retrieve all distinct non-NULL values of `insurance_type` from `fact_patient_visits`, ordered alphabetically.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `DISTINCT`, `IS NOT NULL`, `ORDER BY`.

> 📚 **Concept:** `IS NOT NULL` is the ONLY correct way to filter NULLs. `!= NULL` always returns FALSE/NULL in SQL — NULLs represent "unknown" and are never equal to (or unequal to) anything, including themselves. This is SQL's three-valued logic: TRUE / FALSE / NULL (UNKNOWN). `IS NULL` and `IS NOT NULL` are the only reliable NULL operators.
> 🐘 **PG Ref:** [NULL comparison](https://www.postgresql.org/docs/current/functions-comparison.html)
> 🔬 **DS Equivalent:** `df['insurance_type'].dropna().unique()` — `dropna()` is the pandas equivalent of IS NOT NULL filtering.

---

## 🟠 Medium Hard
> Mixed Phase 2 concepts · 2–3 tables · Steps required

---

### Q1. Data Quality Audit on dim_hospital

Identify all hospitals in `dim_hospital` with data quality issues: `beds IS NULL OR beds < 10`, `annual_budget_m IS NULL`, or `efficiency_score` outside 0–100. Flag each with the issue type.

> 🔍 **Hint:** Tables: `dim_hospital`. Concepts: `IS NULL`, `OR`, range checks, `CASE WHEN` (preview), `AND`.

> 🪜 **Steps:**
> 1. Write individual WHERE conditions for each quality check, combined with OR.
> 2. Add a `CASE WHEN` column labeling the issue: 'Missing Beds', 'Missing Budget', 'Invalid Efficiency'.
> 3. Use `OR` so any one failing condition flags the row.
> 4. Order by `hospital_name` for readability.
> 5. Handle multi-issue rows: use concatenation or priority CASE ordering.

> 📚 **Concept:** SQL DQ audits use NULL checks + range checks combined with OR. `CASE WHEN` labels the issue type in-query — no need for separate queries per issue. NULL checks must always be explicit (`IS NULL`) because comparisons against NULL always return UNKNOWN, not TRUE/FALSE.
> 🐘 **PG Ref:** [CASE expressions](https://www.postgresql.org/docs/current/functions-conditional.html)
> 🔬 **DS Equivalent:** `df.query('beds.isna() or beds < 10 or ...')` or Great Expectations `expect_column_values_to_be_between` — SQL CHECK + CASE is the in-database version.

---

### Q2. Classify Hospitals by Size

Two steps: (1) Add `size_category VARCHAR(20)` to `dim_hospital`. (2) In a single UPDATE with CASE WHEN: 'Large' for 500+ beds, 'Medium' for 200–499, 'Small' under 200, 'Unknown' for NULL beds.

> 🔍 **Hint:** Tables: `dim_hospital`. Concepts: `ALTER TABLE ADD COLUMN`, `UPDATE SET CASE WHEN`, NULL handling in CASE.

> 🪜 **Steps:**
> 1. `ALTER TABLE dim_hospital ADD COLUMN size_category VARCHAR(20)`.
> 2. Write UPDATE with CASE WHEN — put `WHEN beds IS NULL THEN 'Unknown'` FIRST (before numeric comparisons).
> 3. Verify with `SELECT size_category, COUNT(*) FROM dim_hospital GROUP BY size_category`.
> 4. Observe: all rows should be accounted for — total should equal original row count.

> 📚 **Concept:** CASE WHEN evaluates top-to-bottom, first match wins. Put NULL conditions first — numeric comparisons on NULL return UNKNOWN, so `WHEN beds >= 500` is FALSE when beds IS NULL, falling through to ELSE 'Small' unintentionally. Single-pass CASE UPDATE is more efficient than 3 separate UPDATEs (1 scan vs 3 scans).
> 🐘 **PG Ref:** [CASE expression](https://www.postgresql.org/docs/current/functions-conditional.html) | [UPDATE](https://www.postgresql.org/docs/current/sql-update.html)
> 🔬 **DS Equivalent:** `pd.cut(df['beds'], bins=[0,200,500,float('inf')], labels=['Small','Medium','Large'])` in pandas — with `pd.isna()` handling for nulls.

---

### Q3. Build a Simple Audit Log Table

Create `audit_log` with `log_id SERIAL PRIMARY KEY`, `table_name VARCHAR(50)`, `operation VARCHAR(10)`, `record_id VARCHAR(30)`, `changed_at TIMESTAMP DEFAULT NOW()`. Insert 5 records. Query logs for `fact_patient_visits`.

> 🔍 **Hint:** Tables: New `audit_log`. Concepts: `SERIAL`, `DEFAULT NOW()`, multi-row INSERT.

> 🪜 **Steps:**
> 1. Define `log_id SERIAL PRIMARY KEY` — auto-increments with no value needed in INSERT.
> 2. Use `DEFAULT NOW()` for `changed_at` — auto-populates insert timestamp.
> 3. Insert 5 rows without including `log_id` in the column list.
> 4. Use single multi-row INSERT: `VALUES (...), (...), (...)`.
> 5. Query: `WHERE table_name = 'fact_patient_visits'`.

> 📚 **Concept:** `SERIAL` is syntactic sugar for a sequence + column default. In PostgreSQL 10+, `GENERATED ALWAYS AS IDENTITY` is the preferred SQL-standard equivalent. Sequences are non-transactional — a rolled-back INSERT still consumes a sequence number, creating gaps. Gaps are intentional and normal — never design logic that assumes no gaps in a sequence.
> 🐘 **PG Ref:** [SERIAL type](https://www.postgresql.org/docs/current/datatype-numeric.html#DATATYPE-SERIAL) | [CREATE SEQUENCE](https://www.postgresql.org/docs/current/sql-createsequence.html)
> 🔬 **DS Equivalent:** A database's auto-increment PK = pandas' default RangeIndex — auto-generated, monotonically increasing, but gap-tolerant.

---

### Q4. Detect Wait Time Outliers

From `fact_patient_visits`, find visits where `wait_time_minutes < 0` (invalid), `> 1440` (over 24 hours), or `IS NULL` (missing). Show `visit_id`, `hospital_id`, `arrival_datetime`, `wait_time_minutes`.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: Boundary comparisons, `IS NULL`, `OR`.

> 🪜 **Steps:**
> 1. Condition 1: `wait_time_minutes < 0`.
> 2. Condition 2: `wait_time_minutes > 1440`.
> 3. Condition 3: `wait_time_minutes IS NULL` — this MUST be explicit; it is NOT caught by `< 0 OR > 1440`.
> 4. Combine all three with `OR`.
> 5. Order by `hospital_id`, `wait_time_minutes` to group anomalies.

> 📚 **Concept:** NULL is not caught by boundary comparisons — `NULL < 0` returns UNKNOWN, not TRUE. Always add an explicit `IS NULL` check when doing range-based outlier detection. This is the most common missed case in data validation scripts.
> 🐘 **PG Ref:** [NULL in queries](https://www.postgresql.org/docs/current/functions-comparison.html)
> 🔬 **DS Equivalent:** `df[(df['wait_time_minutes'] < 0) | (df['wait_time_minutes'] > 1440) | df['wait_time_minutes'].isna()]` — `isna()` handles the NULL case explicitly.

---

### Q5. Safe Delete Pattern with Preview

Find patients in `dim_patient` where `risk_category = 'Unknown'` AND `chronic_condition_count = 0` AND `age BETWEEN 0 AND 18`. First preview with SELECT. Then delete them with RETURNING. Verify count.

> 🔍 **Hint:** Tables: `dim_patient`. Concepts: SELECT preview → DELETE, `RETURNING`, `AND`, `BETWEEN`.

> 🪜 **Steps:**
> 1. Write `SELECT * FROM dim_patient WHERE ...` with all three conditions to preview.
> 2. Run `SELECT COUNT(*)` with same conditions to count expected deletions.
> 3. Replace SELECT with `DELETE FROM dim_patient WHERE ...` — same WHERE clause.
> 4. Add `RETURNING patient_id` — returns deleted row IDs.
> 5. Re-run the preview SELECT — should return 0 rows.

> 📚 **Concept:** The "preview → count → delete" pattern is professional best practice. `DELETE ... RETURNING *` returns the deleted rows inline — you can even pipe them into an archive: `WITH deleted AS (DELETE ... RETURNING *) INSERT INTO archive SELECT * FROM deleted`. In warehouses, soft deletes (a boolean flag) are preferred over physical deletes for audit trail compliance.
> 🐘 **PG Ref:** [DELETE — RETURNING](https://www.postgresql.org/docs/current/sql-delete.html) | [WITH in DML](https://www.postgresql.org/docs/current/queries-with.html#QUERIES-WITH-MODIFYING)
> 🔬 **DS Equivalent:** `rows_to_delete = df[condition]` then `df = df[~condition]` — inspect first, then remove.

---

### Q6. Find Doctors in a City (Implicit Join)

Find all doctors in `dim_doctor` associated with hospitals in `dim_hospital` located in 'London'. Use only WHERE-based joining (no JOIN keyword). Show `doctor_name`, `specialty`, `hospital_name`, `city`.

> 🔍 **Hint:** Tables: `dim_doctor`, `dim_hospital`. Concepts: Comma-separated FROM, WHERE join condition + city filter.

> 🪜 **Steps:**
> 1. `FROM dim_doctor d, dim_hospital h` — creates a Cartesian product.
> 2. `WHERE d.primary_hospital_id = h.hospital_id` — the join predicate (filters to matching pairs).
> 3. `AND h.city = 'London'` — the business filter.
> 4. Select only needed columns with table aliases.

> 📚 **Concept:** Implicit join (comma-separated FROM + WHERE predicate) is the pre-ANSI SQL style. It produces a Cartesian product first, then filters — functionally identical to INNER JOIN. Modern SQL uses explicit JOIN for clarity and safety (forgetting the WHERE predicate with implicit join = accidental full Cartesian product; with JOIN syntax, the ON clause is mandatory).
> 🐘 **PG Ref:** [FROM clause — joined tables](https://www.postgresql.org/docs/current/queries-table-expressions.html)
> 🔬 **DS Equivalent:** `pd.merge(dim_doctor, dim_hospital, left_on='primary_hospital_id', right_on='hospital_id')` — pandas always uses explicit merge.

---

### Q7. Enrich Financials with Derived Flags

Add three columns to `fact_financials`: `financial_year INTEGER`, `quarter_number INTEGER`, `profit_flag BOOLEAN`. Update `profit_flag = (profit_margin > 0)` in one UPDATE statement. Handle NULL `profit_margin`.

> 🔍 **Hint:** Tables: `fact_financials`. Concepts: Multiple `ADD COLUMN`, `UPDATE SET` with boolean expression, `COALESCE` for NULL handling.

> 🪜 **Steps:**
> 1. Three `ALTER TABLE ADD COLUMN` statements (or one with commas).
> 2. `UPDATE fact_financials SET profit_flag = (profit_margin > 0)` — PostgreSQL evaluates the boolean directly.
> 3. BUT: if `profit_margin IS NULL`, the expression evaluates to NULL, not false. Fix: `SET profit_flag = COALESCE(profit_margin, 0) > 0`.
> 4. Verify with GROUP BY: `SELECT profit_flag, COUNT(*) FROM fact_financials GROUP BY 1`.

> 📚 **Concept:** PostgreSQL allows boolean expressions in SET clauses: `SET flag = (expr > 0)`. But NULL propagation means `NULL > 0 = NULL` — the flag becomes NULL, not false. Always handle NULLs explicitly with `COALESCE`. This pattern (adding derived boolean flags) is common in ETL pipelines for downstream dashboarding.
> 🐘 **PG Ref:** [ALTER TABLE multiple columns](https://www.postgresql.org/docs/current/sql-altertable.html) | [COALESCE](https://www.postgresql.org/docs/current/functions-conditional.html)
> 🔬 **DS Equivalent:** `df['profit_flag'] = df['profit_margin'].fillna(0) > 0` — pandas' `fillna()` is the COALESCE equivalent.

---

### Q8. Identify After-Hours Shifts with Burnout

From `fact_staffing`, find all shifts where `shift_type NOT IN ('Morning', 'Afternoon')` AND `burnout_risk_index > 6` AND `month_name = 1`. Demonstrate and handle the NOT IN NULL trap.

> 🔍 **Hint:** Tables: `fact_staffing`. Concepts: `NOT IN`, `AND`, NULL trap.

> 🪜 **Steps:**
> 1. `WHERE shift_type NOT IN ('Morning', 'Afternoon')`.
> 2. Add `AND burnout_risk_index > 6 AND month_name = 1`.
> 3. Safety: add `AND shift_type IS NOT NULL` — if ANY `shift_type` is NULL, NOT IN returns 0 rows silently.
> 4. Verify: run with and without the IS NOT NULL clause and compare result counts.

> 📚 **Concept:** `NOT IN (list)` with a NULL in the column being tested causes the entire condition to evaluate as UNKNOWN for that row (excluded). The fix is to add `WHERE col IS NOT NULL`. For subquery-based NOT IN, always add `WHERE col IS NOT NULL` INSIDE the subquery too. Prefer `NOT EXISTS` (Phase 6) which is always NULL-safe.
> 🐘 **PG Ref:** [IN / NOT IN](https://www.postgresql.org/docs/current/functions-comparisons.html)
> 🔬 **DS Equivalent:** `~df['shift_type'].isin(['Morning', 'Afternoon'])` — the `~` (tilde) is NOT IN; note pandas' isin handles NaN automatically (they don't match), but SQL's NOT IN does not.

---

### Q9. CTAS for High-Risk Diagnosis Reference

From `dim_diagnosis`, find rows where `readmission_risk = 'High'` AND `icu_probability > 0.5` AND `avg_los_hours > 48`. Save as new table `high_risk_diagnoses` using CTAS. Verify row count.

> 🔍 **Hint:** Tables: `dim_diagnosis`. Concepts: Multiple AND conditions, CTAS (`CREATE TABLE ... AS SELECT`).

> 🪜 **Steps:**
> 1. Write the SELECT first with all three conditions.
> 2. Wrap with `CREATE TABLE high_risk_diagnoses AS (SELECT ...)`.
> 3. Verify: `SELECT COUNT(*) FROM high_risk_diagnoses`.
> 4. Note: the new table has NO indexes or constraints — add them manually if needed.

> 📚 **Concept:** CTAS creates a new table and populates it in one statement. The resulting table inherits column names and data types but NOT constraints, indexes, or foreign keys from the source. Widely used in ETL for: pre-computed aggregates, denormalized reporting tables, test datasets. In Redshift/BigQuery, CTAS is the primary way to materialize intermediate results.
> 🐘 **PG Ref:** [CREATE TABLE AS](https://www.postgresql.org/docs/current/sql-createtableas.html)
> 🔬 **DS Equivalent:** `high_risk_df = df[(df['readmission_risk']=='High') & ...]` then `.to_sql(...)` — materializing a filtered subset as a new table.

---

### Q10. Elderly Emergency Patients via Implicit Join

Using an implicit WHERE-based join between `dim_patient` and `fact_patient_visits`, retrieve `patient_id`, `age`, `gender` and `visit_id`, `admission_type`, `severity_level`, `treatment_cost`. Filter: patients over 60, severity IN (4, 5). Order by `treatment_cost` DESC, limit 15.

> 🔍 **Hint:** Tables: `dim_patient`, `fact_patient_visits`. Concepts: Implicit join, column aliases, multiple conditions, `ORDER BY`, `LIMIT`.

> 🪜 **Steps:**
> 1. `FROM dim_patient dp, fact_patient_visits fpv`.
> 2. `WHERE dp.patient_id = fpv.patient_id` (join key).
> 3. `AND dp.age > 60 AND fpv.severity_level IN (4, 5)`.
> 4. `ORDER BY fpv.treatment_cost DESC LIMIT 15`.
> 5. Use table aliases (`dp`, `fpv`) throughout for readability.

> 📚 **Concept:** Table aliases are mandatory when the same column name exists in both tables (e.g., `patient_id` appears in both). Without aliases, PostgreSQL throws an "ambiguous column" error. Short, consistent aliases are a professional coding standard — always alias multi-table queries.
> 🐘 **PG Ref:** [Table aliases](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-TABLE-ALIASES)
> 🔬 **DS Equivalent:** `pd.merge(dim_patient, fact_patient_visits, on='patient_id').query('age > 60 and severity_level in [4, 5]').nlargest(15, 'treatment_cost')`.

---

## 🔴 Advanced
> 3+ tables · Transaction-aware · Cross-phase logic

---

### Q1. Full Hospital Onboarding Script

Write a complete ordered INSERT transaction: new hospital (dim_hospital), 2 departments (dim_department), 3 doctors (dim_doctor), 1 financial record (fact_financials). Wrap in BEGIN/COMMIT. Verify each table.

> 🔍 **Hint:** Tables: All 4. Concepts: FK dependency insert order, `BEGIN`/`COMMIT`, multi-table INSERT sequence.

> 🪜 **Steps:**
> 1. `BEGIN;` — start transaction.
> 2. INSERT into `dim_hospital` first (parent of `dim_doctor` via `primary_hospital_id`).
> 3. INSERT 2 departments (no FK to hospital in this schema but logically related).
> 4. INSERT 3 doctors referencing the new `hospital_id`.
> 5. INSERT 1 `fact_financials` row referencing new `hospital_id`.
> 6. `COMMIT;` — if any INSERT fails, use `ROLLBACK` to undo all.
> 7. Verify with 4 SELECT statements.

> 📚 **Concept:** In FK-constrained schemas, INSERT order follows parent → child hierarchy. Wrapping in a transaction ensures atomicity — either all 7 INSERTs succeed or none do. `DEFERRABLE INITIALLY DEFERRED` FK constraints allow out-of-order inserts within a transaction (useful for circular FK relationships). Without transactions, a partial failure leaves orphaned records.
> 🐘 **PG Ref:** [FK deferrable](https://www.postgresql.org/docs/current/sql-set-constraints.html) | [BEGIN](https://www.postgresql.org/docs/current/sql-begin.html)
> 🔬 **DS Equivalent:** A pipeline dependency graph — loading lookup tables before transactional tables. Like Airflow DAG dependencies: `dim_hospital >> dim_doctor >> fact_visits`.

---

### Q2. Null-Safe Risk Category Migration

In `dim_patient`, update all rows where `risk_category IS NULL`: set to 'Unknown' if `chronic_condition_count = 0`, 'Medium' if 1–2, 'High' if 3+. Single UPDATE with CASE WHEN. Verify with GROUP BY count.

> 🔍 **Hint:** Tables: `dim_patient`. Concepts: `UPDATE CASE WHEN` with NULL check first, `WHERE IS NULL`, GROUP BY verification.

> 🪜 **Steps:**
> 1. `UPDATE dim_patient SET risk_category = CASE WHEN chronic_condition_count = 0 THEN 'Unknown' WHEN chronic_condition_count BETWEEN 1 AND 2 THEN 'Medium' ELSE 'High' END WHERE risk_category IS NULL`.
> 2. Note: add `WHEN chronic_condition_count IS NULL THEN 'Unknown'` before numeric conditions to handle NULL counts.
> 3. Verify: `SELECT risk_category, COUNT(*) FROM dim_patient GROUP BY 1 ORDER BY 2 DESC`.
> 4. Confirm total rows unchanged.

> 📚 **Concept:** CASE WHEN processes top-to-bottom — first match wins. Always handle NULL and edge cases first. After any data migration, verify: total row count must match before/after. GROUP BY count shows the distribution of the updated values — essential QA step for any backfill operation.
> 🐘 **PG Ref:** [CASE](https://www.postgresql.org/docs/current/functions-conditional.html) | [UPDATE](https://www.postgresql.org/docs/current/sql-update.html)
> 🔬 **DS Equivalent:** `df['risk_category'] = df.apply(lambda r: 'Unknown' if r['chronic_condition_count'] == 0 else 'Medium' if 1 <= r['chronic_condition_count'] <= 2 else 'High', axis=1)` — with `.where(df['risk_category'].isna())`.

---

### Q3. Implement Soft Deletes

Add `is_deleted BOOLEAN DEFAULT FALSE` and `deleted_at TIMESTAMP` to `fact_patient_visits`. Soft-delete all visits where `mortality_flag = true AND outcome = 'Deceased'`. Write the active-record filter.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `ALTER TABLE ADD COLUMN DEFAULT`, multi-column `UPDATE SET`, soft delete pattern.

> 🪜 **Steps:**
> 1. `ALTER TABLE fact_patient_visits ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE`.
> 2. `ALTER TABLE fact_patient_visits ADD COLUMN deleted_at TIMESTAMP`.
> 3. `UPDATE ... SET is_deleted = true, deleted_at = NOW() WHERE mortality_flag = true AND outcome = 'Deceased'`.
> 4. Active record filter: `WHERE is_deleted = false OR is_deleted IS NULL`.
> 5. Create a partial index: `CREATE INDEX idx_active_visits ON fact_patient_visits(visit_id) WHERE is_deleted = false`.

> 📚 **Concept:** Soft deletes are a data warehouse best practice — they preserve audit trails, enable recovery, and support regulatory compliance (HIPAA requires data retention). The partial index on `is_deleted = false` means only active records are indexed — queries on active visits are fast and the index is small (size = active records, not all records).
> 🐘 **PG Ref:** [Partial indexes](https://www.postgresql.org/docs/current/indexes-partial.html)
> 🔬 **DS Equivalent:** An `is_active` flag in an ML feature store — never delete features, just deactivate them. Enables point-in-time correct feature retrieval without data leakage.

---

### Q4. Hospital Alert Dashboard

Join `fact_financials` with `dim_hospital`. Flag hospitals under 3 alerts: (1) `profit_margin < -10`, (2) `mortality_rate > 5`, (3) `avg_wait_time_minutes > 120`. Use CASE WHEN per alert. Allow multiple alerts per hospital.

> 🔍 **Hint:** Tables: `fact_financials`, `dim_hospital`. Concepts: Join via WHERE, CASE WHEN for separate alert flags, OR for row inclusion.

> 🪜 **Steps:**
> 1. Join on `hospital_id` via WHERE clause.
> 2. WHERE: include rows that match ANY alert condition (use OR).
> 3. SELECT: 3 separate CASE WHEN boolean columns: `is_loss_making`, `is_high_mortality`, `is_slow_service`.
> 4. OR use CASE to build a concatenated label string.
> 5. DISTINCT on hospital to avoid duplicate rows from multiple financial periods.

> 📚 **Concept:** Business alert logic: WHERE for inclusion (any alert triggered), CASE WHEN for labeling (which alert). When a row can trigger multiple alerts, separate boolean columns are more dashboard-friendly than a single label — you can use `SUM(is_loss_making)`, `SUM(is_high_mortality)` to count affected hospitals per alert type. This is multi-label classification in SQL.
> 🐘 **PG Ref:** [CASE](https://www.postgresql.org/docs/current/functions-conditional.html)
> 🔬 **DS Equivalent:** Multi-label classification output — `sklearn.preprocessing.MultiLabelBinarizer` equivalent as SQL CASE columns.

---

### Q5. Custom Sequence for Visit Keys

Create sequence `visit_seq` starting at 100000, increment 1, no max. Create `fact_visits_v2` using it as default for `seq_visit_id INTEGER`. Insert 5 rows. Roll back one insert — observe the gap in sequence.

> 🔍 **Hint:** Concepts: `CREATE SEQUENCE`, `nextval('seq_name')`, `DEFAULT nextval(...)`, `ROLLBACK` gap demonstration.

> 🪜 **Steps:**
> 1. `CREATE SEQUENCE visit_seq START 100000 INCREMENT 1 NO MAXVALUE`.
> 2. Create table with `seq_visit_id INTEGER DEFAULT nextval('visit_seq')`.
> 3. Insert 5 rows without specifying `seq_visit_id`.
> 4. `BEGIN; INSERT ... ; ROLLBACK;` — then insert again.
> 5. Observe: the rolled-back insert consumed a sequence value — there is a gap.

> 📚 **Concept:** Sequences are non-transactional — once `nextval()` is called, the number is consumed even if the transaction rolls back. This creates gaps. Gaps are normal and expected in production. Design that assumes no gaps breaks under load. Use `GENERATED ALWAYS AS IDENTITY` (PostgreSQL 10+) for modern sequence handling — it's the SQL standard.
> 🐘 **PG Ref:** [Sequence functions](https://www.postgresql.org/docs/current/functions-sequence.html) | [Identity columns](https://www.postgresql.org/docs/current/sql-createtable.html)
> 🔬 **DS Equivalent:** A pandas RangeIndex after row deletion — the index has gaps (0,1,2,4,5...) after `df.drop(3)`. Use `df.reset_index(drop=True)` to re-sequence, but database sequences don't support resetting in production.

---

### Q6. Composite Constraints and Partial Indexes

On `dim_diagnosis`: (1) Composite UNIQUE on `(category, icd_chapter)`. (2) CHECK on `severity_weight BETWEEN 0 AND 10`. (3) Partial index for `readmission_risk = 'High'` rows only.

> 🔍 **Hint:** Concepts: `ADD CONSTRAINT UNIQUE (c1, c2)`, `ADD CONSTRAINT CHECK`, `CREATE INDEX ... WHERE`.

> 🪜 **Steps:**
> 1. `ALTER TABLE dim_diagnosis ADD CONSTRAINT uq_cat_icd UNIQUE (category, icd_chapter)`.
> 2. `ALTER TABLE dim_diagnosis ADD CONSTRAINT chk_severity CHECK (severity_weight BETWEEN 0 AND 10)`.
> 3. `CREATE INDEX idx_high_readmission ON dim_diagnosis(diagnosis_id) WHERE readmission_risk = 'High'`.
> 4. Verify via `information_schema.table_constraints` and `pg_indexes`.

> 📚 **Concept:** Composite UNIQUE enforces multi-column business rules at the DB layer. Partial indexes are one of PostgreSQL's most powerful features — an index over a SUBSET of rows. If 10% of diagnoses are 'High' risk, the partial index is 10x smaller than a full index, fits in cache, and accelerates queries with that filter. Standard B-tree indexes can't do this.
> 🐘 **PG Ref:** [Partial indexes](https://www.postgresql.org/docs/current/indexes-partial.html)
> 🔬 **DS Equivalent:** Sparse feature representation — only indexing the "interesting" rows is like using a sparse matrix (scipy.sparse) instead of a dense array for mostly-zero data.

---

### Q7. Schema Introspection via System Catalogs

Query `information_schema.columns` for all columns in `fact_patient_visits` with data type, nullable, and default. Then query `pg_indexes` for all indexes on `fact_patient_visits`. Cross-reference: which FK columns are missing an index?

> 🔍 **Hint:** System tables: `information_schema.columns`, `pg_indexes`. Filter by `table_schema = 'public'` and `table_name = 'fact_patient_visits'`.

> 🪜 **Steps:**
> 1. `SELECT column_name, data_type, is_nullable, column_default FROM information_schema.columns WHERE table_schema='public' AND table_name='fact_patient_visits' ORDER BY ordinal_position`.
> 2. `SELECT indexname, indexdef FROM pg_indexes WHERE schemaname='public' AND tablename='fact_patient_visits'`.
> 3. Identify FK columns: `patient_id`, `hospital_id`, `department_id`, `doctor_id`.
> 4. Cross-reference with index list — are they indexed?

> 📚 **Concept:** `information_schema` is ANSI-standard — available in PostgreSQL, MySQL, SQL Server, DB2. `pg_catalog` views (`pg_indexes`, `pg_stat_user_tables`, etc.) are PostgreSQL-specific but richer. Querying system catalogs is essential for: schema documentation, automated code generation, data lineage tracking, index auditing, and dynamic SQL. Every data engineer should know these tables.
> 🐘 **PG Ref:** [information_schema](https://www.postgresql.org/docs/current/information-schema.html) | [pg_indexes](https://www.postgresql.org/docs/current/view-pg-indexes.html)
> 🔬 **DS Equivalent:** `df.dtypes`, `df.info()`, `df.describe()` — metadata inspection before EDA. In SQLAlchemy: `inspect(engine).get_columns('table')`.

---

### Q8. Demonstrate the NOT IN NULL Trap

Show departments in `dim_department` with no visits in `fact_patient_visits` using NOT IN. Then insert a NULL into `fact_patient_visits.department_id`, re-run the query, and observe the result. Provide the NULL-safe alternative.

> 🔍 **Hint:** Tables: `dim_department`, `fact_patient_visits`. Concepts: `NOT IN (subquery)`, NULL trap, `WHERE col IS NOT NULL` fix.

> 🪜 **Steps:**
> 1. Write `WHERE department_id NOT IN (SELECT DISTINCT department_id FROM fact_patient_visits)`.
> 2. Insert one test row with `department_id = NULL` into `fact_patient_visits`.
> 3. Re-run — query returns 0 rows (NULL trap).
> 4. Fix: add `WHERE department_id IS NOT NULL` inside the subquery.
> 5. Write the NULL-safe alternative using LEFT JOIN ... WHERE IS NULL.

> 📚 **Concept:** NOT IN NULL trap: `x NOT IN (1, 2, NULL)` = `x <> 1 AND x <> 2 AND x <> NULL`. Since `x <> NULL = UNKNOWN`, the entire AND chain = UNKNOWN, row excluded. Solution: add IS NOT NULL inside the subquery. Better: use NOT EXISTS or ANTI JOIN (Phase 3) which are always NULL-safe. This is a top-10 SQL correctness pitfall.
> 🐘 **PG Ref:** [Subquery expressions](https://www.postgresql.org/docs/current/functions-subquery.html)
> 🔬 **DS Equivalent:** `~df['dept'].isin(other_df['dept'].dropna())` — dropna() is mandatory when using isin for NOT IN semantics.

---

### Q9. PostgreSQL Table Inheritance

Create parent `dim_facility` (`facility_id VARCHAR(20) PK`, `facility_name VARCHAR(150)`, `city VARCHAR(100)`). Create child `dim_clinic` inheriting from `dim_facility`, adding `specialty VARCHAR(100)`. Insert into both. Query parent and observe child row inclusion.

> 🔍 **Hint:** PostgreSQL-specific: `CREATE TABLE child (extra_col TYPE) INHERITS (parent_table)`. `SELECT * FROM ONLY parent` for parent-only rows.

> 🪜 **Steps:**
> 1. `CREATE TABLE dim_facility (facility_id VARCHAR(20) PRIMARY KEY, facility_name VARCHAR(150), city VARCHAR(100))`.
> 2. `CREATE TABLE dim_clinic (specialty VARCHAR(100)) INHERITS (dim_facility)`.
> 3. Insert 2 rows into `dim_facility`, 2 rows into `dim_clinic`.
> 4. `SELECT * FROM dim_facility` — returns 4 rows (2 parent + 2 child).
> 5. `SELECT * FROM ONLY dim_facility` — returns 2 rows (parent only).

> 📚 **Concept:** Table inheritance is PostgreSQL-specific. A `SELECT` on the parent returns rows from all children unless `ONLY` is used. This is the mechanism behind PostgreSQL's declarative table partitioning — each partition is a child table. Understanding inheritance explains HOW partition pruning works: the query planner knows which child tables (partitions) contain matching data and skips the rest.
> 🐘 **PG Ref:** [Table inheritance](https://www.postgresql.org/docs/current/ddl-inherit.html) | [Partitioning](https://www.postgresql.org/docs/current/ddl-partitioning.html)
> 🔬 **DS Equivalent:** Class inheritance in Python — `SELECT * FROM dim_facility` is like calling a polymorphic method on a base class that returns instances of all subclasses.

---

### Q10. FK Constraints with Business-Rule ON DELETE Behaviors

Add FK constraints: (1) `dim_doctor.primary_hospital_id` → `dim_hospital` ON DELETE RESTRICT. (2) `dim_hospital.region_id` → `dim_region` ON DELETE SET NULL. (3) `fact_patient_visits.patient_id` → `dim_patient` ON DELETE RESTRICT. Justify each choice.

> 🔍 **Hint:** `ALTER TABLE child ADD CONSTRAINT fk_name FOREIGN KEY (col) REFERENCES parent(col) ON DELETE RESTRICT|CASCADE|SET NULL`.

> 🪜 **Steps:**
> 1. Write 3 `ALTER TABLE ... ADD CONSTRAINT ... FOREIGN KEY ... REFERENCES ... ON DELETE ...` statements.
> 2. RESTRICT for doctors: can't delete a hospital with assigned doctors.
> 3. SET NULL for hospital region: deleting a region doesn't delete hospitals, just nullifies the region link.
> 4. RESTRICT for patient visits: can't delete a patient with existing visits.
> 5. Test: try to delete a parent record for each — observe the enforced behavior.

> 📚 **Concept:** FK behavior choices reflect business rules. CASCADE on fact tables is dangerous — deleting a dimension row cascades to potentially millions of fact rows. RESTRICT is the safest default for fact-dimension relationships. SET NULL is appropriate for optional relationships. In high-throughput systems, FKs are sometimes disabled for bulk load performance and re-enabled after — `ALTER TABLE DISABLE TRIGGER ALL` / `ENABLE TRIGGER ALL`.
> 🐘 **PG Ref:** [FK constraints](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-FK)
> 🔬 **DS Equivalent:** Referential integrity rules in pandas: `pd.merge(df1, df2, how='inner')` silently drops non-matching rows — SQL FKs enforce this explicitly rather than silently losing data.

---

## ⚫ Expert
> Deep analytical · Catalog-level · Dynamic SQL · Production-aware

---

### Q1. Audit: Find Unindexed FK Columns

Use `pg_catalog` system tables to find FK columns on `fact_patient_visits`, `fact_staffing`, and `fact_financials` that have no corresponding B-tree index. Report: table name, FK column, index exists (Y/N).

> 🔍 **Hint:** Use `pg_constraint` (type = 'f' for FK), `pg_attribute` (column names), `pg_index` (index info). Alternatively: `information_schema.key_column_usage` + `pg_indexes`.

> 🪜 **Steps:**
> 1. Query `information_schema.key_column_usage` for FK columns on fact tables.
> 2. Query `pg_indexes` for all indexes on those tables.
> 3. LEFT JOIN: FK column list LEFT JOIN index list — rows with NULL index = missing index.
> 4. Filter to `schemaname = 'public'`.
> 5. Output: table, column, index_exists.

> 📚 **Concept:** Unindexed FK columns on large fact tables cause sequential scans on every JOIN — the #1 performance bottleneck in analytics. PostgreSQL does NOT auto-create FK indexes (unlike MySQL InnoDB). A high `seq_scan` count in `pg_stat_user_tables` is the diagnostic signal. This audit query should run after every schema change.
> 🐘 **PG Ref:** [pg_constraint](https://www.postgresql.org/docs/current/catalog-pg-constraint.html) | [pg_stat_user_tables](https://www.postgresql.org/docs/current/monitoring-stats.html#MONITORING-PG-STAT-USER-TABLES-VIEW)
> 🔬 **DS Equivalent:** A "metadata validation pipeline" — equivalent to checking that all join keys in a feature store have cardinality stats and indexes for efficient lookup.

---

### Q2. Metadata-Driven DQ Framework

Create `dq_rules` table (`rule_id SERIAL`, `table_name VARCHAR(50)`, `column_name VARCHAR(50)`, `rule_type VARCHAR(20)`, `rule_expression TEXT`). Insert 5 rules for this schema. Write a PL/pgSQL DO block that executes each rule dynamically using `EXECUTE FORMAT(...)`.

> 🔍 **Hint:** Concepts: `CREATE TABLE`, `INSERT`, PL/pgSQL `DO $$...$$`, `FOR rec IN ... LOOP`, `EXECUTE FORMAT('%I', ...)`, `%s` for raw strings.

> 🪜 **Steps:**
> 1. Design 5 rules: e.g., `('dim_patient', 'age', 'RANGE', 'age BETWEEN 0 AND 120')`.
> 2. Write `DO $$ DECLARE rec RECORD; v_count INT; BEGIN FOR rec IN SELECT * FROM dq_rules LOOP EXECUTE FORMAT('SELECT COUNT(*) FROM %I WHERE NOT (%s)', rec.table_name, rec.rule_expression) INTO v_count; RAISE NOTICE '% | % | violations: %', rec.table_name, rec.column_name, v_count; END LOOP; END $$`.
> 3. Run and read output.

> 📚 **Concept:** Dynamic SQL builds query strings at runtime. `FORMAT('%I', name)` safely quote-escapes identifiers (prevents SQL injection). `%s` injects raw values. This metadata-driven pattern is how automated DQ frameworks (dbt tests, Great Expectations, Soda Core) work internally — rules are data, not hardcoded queries. The loop architecture is reusable for any schema.
> 🐘 **PG Ref:** [Dynamic SQL — EXECUTE](https://www.postgresql.org/docs/current/plpgsql-statements.html#PLPGSQL-STATEMENTS-EXECUTING-DYN) | [FORMAT function](https://www.postgresql.org/docs/current/functions-string.html#FUNCTIONS-STRING-FORMAT)
> 🔬 **DS Equivalent:** A validation rule engine in Python: `for rule in rules: result = validate(df, rule)` — same "rules as data" pattern, same dynamic dispatch.

---

### Q3. TRUNCATE vs DELETE vs DROP in Transactions

Write 3 scripts (each wrapped in BEGIN/ROLLBACK) to safely demonstrate: (1) `TRUNCATE fact_patient_visits RESTART IDENTITY`. (2) `DELETE FROM fact_patient_visits WHERE visit_id = 'V001'`. (3) `DROP TABLE audit_log`. Explain the difference in transactional behavior and performance.

> 🔍 **Hint:** Concepts: `BEGIN`, `ROLLBACK`, PostgreSQL's transactional DDL (unique feature).

> 🪜 **Steps:**
> 1. For each: `BEGIN; [command]; SELECT COUNT(*) to verify; ROLLBACK;`.
> 2. Verify after ROLLBACK that the state is restored.
> 3. TRUNCATE: clears all rows, resets sequences, WAL-logged at page level (fast).
> 4. DELETE: row-by-row, fully WAL-logged (slow on large tables), WHERE clause possible.
> 5. DROP: removes table structure entirely.

> 📚 **Concept:** PostgreSQL is unique — ALL DDL including TRUNCATE and DROP is transactional. Oracle and MySQL do not support this. This is why Flyway/Liquibase work reliably with PostgreSQL — a failed migration script can be fully rolled back. `TRUNCATE RESTART IDENTITY` resets sequences. `TRUNCATE` does not fire per-row triggers (only `BEFORE/AFTER TRUNCATE` triggers).
> 🐘 **PG Ref:** [TRUNCATE](https://www.postgresql.org/docs/current/sql-truncate.html) | [Transactional DDL](https://wiki.postgresql.org/wiki/Transactional_DDL_in_PostgreSQL:_A_Competitive_Analysis)
> 🔬 **DS Equivalent:** Transactions are like Python context managers (`with transaction: do_stuff()`). TRUNCATE ≈ `df = pd.DataFrame(columns=df.columns)` — clear rows, keep structure.

---

### Q4. Generate INSERT Template from Metadata

Use `information_schema.columns` + `STRING_AGG` to dynamically build the INSERT statement template for `dim_patient`: `INSERT INTO dim_patient (col1, col2, ...) VALUES ($1, $2, ...)`.

> 🔍 **Hint:** `STRING_AGG(column_name, ', ' ORDER BY ordinal_position)` for column list; `STRING_AGG('$' || ordinal_position::text, ', ')` for placeholders.

> 🪜 **Steps:**
> 1. Query `information_schema.columns` WHERE `table_name = 'dim_patient'` ORDER BY `ordinal_position`.
> 2. `STRING_AGG(column_name, ', ' ORDER BY ordinal_position)` → col list.
> 3. `STRING_AGG('$' || ordinal_position::text, ', ' ORDER BY ordinal_position)` → placeholder list.
> 4. Combine: `'INSERT INTO dim_patient (' || col_list || ') VALUES (' || placeholder_list || ')'`.
> 5. The result is a parameterized INSERT template.

> 📚 **Concept:** ORMs (SQLAlchemy, Hibernate, ActiveRecord) generate INSERT templates exactly this way — reading schema metadata at startup. `STRING_AGG` is PostgreSQL's group string concatenation function (similar to MySQL's `GROUP_CONCAT`). The ORDER BY inside STRING_AGG ensures column order matches the table definition. This bridges SQL and software engineering.
> 🐘 **PG Ref:** [STRING_AGG](https://www.postgresql.org/docs/current/functions-aggregate.html) | [information_schema.columns](https://www.postgresql.org/docs/current/infoschema-columns.html)
> 🔬 **DS Equivalent:** `', '.join(df.columns)` in Python — building a dynamic query string from a DataFrame schema. Used in pandas `to_sql()` source code.

---

### Q5. Schema Evolution Log

Create `schema_changes` (`change_id SERIAL`, `change_type VARCHAR(20)`, `object_name VARCHAR(100)`, `change_sql TEXT`, `executed_by TEXT DEFAULT CURRENT_USER`, `executed_at TIMESTAMP DEFAULT NOW()`). Perform 8 DDL operations on the schema, manually logging each. Query the log.

> 🔍 **Hint:** Concepts: `SERIAL`, `CURRENT_USER`, `DEFAULT NOW()`. Each DDL is followed by an INSERT into `schema_changes`.

> 🪜 **Steps:**
> 1. Create `schema_changes`.
> 2. Perform 8 DDL operations: ADD COLUMN, CREATE INDEX, ADD CONSTRAINT, CREATE SEQUENCE, RENAME COLUMN, CREATE TABLE, DROP COLUMN, ADD FK.
> 3. After each DDL: `INSERT INTO schema_changes (change_type, object_name, change_sql) VALUES ('ADD_COLUMN', 'fact_financials', 'ALTER TABLE ...')`.
> 4. Query: `SELECT * FROM schema_changes ORDER BY executed_at`.

> 📚 **Concept:** Schema evolution logging is the SQL equivalent of Git commits. `CURRENT_USER` returns the connected database role. `CURRENT_TIMESTAMP` is deterministic within a transaction (all rows in one transaction get the same timestamp). Tools like Flyway and Liquibase automate this — every migration script is logged with a checksum. Understanding the manual version first clarifies what these tools do.
> 🐘 **PG Ref:** [Session information functions](https://www.postgresql.org/docs/current/functions-info.html) — CURRENT_USER, CURRENT_TIMESTAMP
> 🔬 **DS Equivalent:** Git commit messages for code. Metadata-driven schema versioning enables: rollback, auditing, CI/CD deployments. dbt's `run_results.json` stores equivalent information for data transformations.

---

### Q6. Data Drift — NULL Rate per Hospital

For each `hospital_id` in `fact_patient_visits`, compute the NULL percentage for `satisfaction_score`, `treatment_cost`, `discharge_datetime`. Flag hospitals where any null percentage exceeds 20%.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `COUNT(*) - COUNT(col)` = null count, `100.0 * ...` (float division), GROUP BY, CASE WHEN flag.

> 🪜 **Steps:**
> 1. `GROUP BY hospital_id`.
> 2. Total: `COUNT(*)`.
> 3. NULLs: `COUNT(*) - COUNT(column)` — COUNT(col) skips NULLs.
> 4. Percentage: `ROUND(100.0 * (COUNT(*) - COUNT(col)) / COUNT(*), 2)`. Use `100.0` (not `100`) to force float division.
> 5. Flag: `CASE WHEN any_pct > 20 THEN 'Alert' ELSE 'OK' END`.

> 📚 **Concept:** `COUNT(column)` ignores NULLs; `COUNT(*)` counts all rows. Their difference = NULL count — a fundamental SQL trick. Data drift detection (monitoring null rates per partition) is a core MLOps concern: rising null rates in input features can cause ML model performance degradation. Automating this query as a daily scheduled job is a practical monitoring solution.
> 🐘 **PG Ref:** [Aggregate functions — COUNT](https://www.postgresql.org/docs/current/functions-aggregate.html)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id').apply(lambda g: g.isnull().mean() * 100)` in pandas. Tools like Evidently AI, Whylogs, and Monte Carlo Data automate this for ML pipelines.

---

### Q7. Document Schema with Column Comments

Add `COMMENT ON TABLE` and `COMMENT ON COLUMN` to `fact_patient_visits` for at least 8 columns. Retrieve all comments via `pg_description` joined with `pg_class` and `pg_attribute`.

> 🔍 **Hint:** `COMMENT ON TABLE t IS '...'`; `COMMENT ON COLUMN t.col IS '...'`. Retrieve: `pg_description` joined with `pg_class` (table) and `pg_attribute` (column).

> 🪜 **Steps:**
> 1. Write 1 `COMMENT ON TABLE` + 8 `COMMENT ON COLUMN` statements.
> 2. Retrieve: `SELECT c.relname AS table, a.attname AS column, d.description FROM pg_description d JOIN pg_class c ON d.objoid = c.oid JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = d.objsubid WHERE c.relname = 'fact_patient_visits' AND d.objsubid > 0`.

> 📚 **Concept:** PostgreSQL stores comments in `pg_description`. Modern data catalog tools (DataHub, Atlan, Alation, dbt docs) ingest these automatically to build searchable data dictionaries. In dbt, `schema.yml` descriptions are pushed to the DB as column comments. Self-documenting schemas dramatically reduce onboarding time — a team member can understand any column without reading external documentation.
> 🐘 **PG Ref:** [COMMENT ON](https://www.postgresql.org/docs/current/sql-comment.html) | [pg_description](https://www.postgresql.org/docs/current/catalog-pg-description.html)
> 🔬 **DS Equivalent:** Python docstrings and pandas `df.attrs` — SQL column comments are the database-native equivalent. Documented datasets lead to better, safer feature engineering.

---

### Q8. SCD Type 2 Versioning for dim_hospital

Create `dim_hospital_v2` (same structure as `dim_hospital`). Add `data_version INTEGER DEFAULT 1`, `valid_from TIMESTAMP`, `valid_to TIMESTAMP`. INSERT all current hospitals with `valid_from = '2020-01-01'`, `valid_to = NULL`. Simulate one record update as a new version row.

> 🔍 **Hint:** Concepts: `CREATE TABLE (LIKE ...) INCLUDING ALL`, multiple `ADD COLUMN`, `INSERT INTO ... SELECT`, SCD Type 2 pattern: NULL valid_to = currently active.

> 🪜 **Steps:**
> 1. `CREATE TABLE dim_hospital_v2 (LIKE dim_hospital INCLUDING ALL)`.
> 2. Add `data_version`, `valid_from`, `valid_to`.
> 3. `INSERT INTO dim_hospital_v2 SELECT *, 1, '2020-01-01'::timestamp, NULL FROM dim_hospital`.
> 4. Simulate update: close old version: `UPDATE SET valid_to = NOW() WHERE hospital_id = 'H001' AND valid_to IS NULL`.
> 5. Insert new version: `INSERT INTO dim_hospital_v2 (..., data_version, valid_from, valid_to) VALUES (..., 2, NOW(), NULL)`.

> 📚 **Concept:** SCD Type 2 tracks full change history per record. NULL `valid_to` = currently active. Query current state: `WHERE valid_to IS NULL`. Query historical state: `WHERE valid_from <= 'target_dt' AND (valid_to > 'target_dt' OR valid_to IS NULL)`. This powers Snowflake Time Travel, Delta Lake versioning, and Apache Iceberg — all implement SCD2 at the storage layer.
> 🐘 **PG Ref:** [Temporal patterns in PostgreSQL](https://wiki.postgresql.org/wiki/Temporal_Tables)
> 🔬 **DS Equivalent:** Feature store point-in-time correct retrieval — fetching features as they existed at a specific timestamp prevents target leakage in ML training. SCD2 is the database implementation of this concept.

---

### Q9. Table Row Count Loop in PL/pgSQL

Write a PL/pgSQL DO block that loops over all tables in `public` schema (from `pg_stat_user_tables`) and prints each table name with its approximate live row count. Add exception handling.

> 🔍 **Hint:** `DO $$ DECLARE rec RECORD; BEGIN FOR rec IN ... LOOP RAISE NOTICE ...; END LOOP; END $$`. Use `pg_stat_user_tables.n_live_tup`.

> 🪜 **Steps:**
> 1. `DO $$ DECLARE rec RECORD; BEGIN`.
> 2. `FOR rec IN SELECT relname, n_live_tup FROM pg_stat_user_tables WHERE schemaname = 'public' ORDER BY n_live_tup DESC LOOP`.
> 3. `RAISE NOTICE 'Table: % | ~% rows', rec.relname, rec.n_live_tup;`.
> 4. `END LOOP; END $$`.
> 5. Add `EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Error on %: %', rec.relname, SQLERRM` inside the loop.

> 📚 **Concept:** PL/pgSQL DO blocks enable procedural logic. `pg_stat_user_tables` provides: `n_live_tup` (approx live rows — updated by autovacuum/ANALYZE), `n_dead_tup` (rows pending VACUUM), `seq_scan` (sequential scan count — high numbers signal missing indexes), `last_autovacuum`. These statistics are essential for DB health monitoring and identifying optimization targets.
> 🐘 **PG Ref:** [PL/pgSQL control structures](https://www.postgresql.org/docs/current/plpgsql-control-structures.html) | [pg_stat_user_tables](https://www.postgresql.org/docs/current/monitoring-stats.html#MONITORING-PG-STAT-USER-TABLES-VIEW)
> 🔬 **DS Equivalent:** `for table in metadata.sorted_tables: print(table.name, engine.execute(f'SELECT COUNT(*) FROM {table.name}').scalar())` — metadata-driven inspection loop in SQLAlchemy.

---

### Q10. Data Archival Transaction

Build a full archival pipeline: create `fact_patient_visits_archive` (same structure + `archived_at TIMESTAMP DEFAULT NOW()`), INSERT old records, DELETE from main, verify counts match. Wrap entirely in a transaction.

> 🔍 **Hint:** Concepts: `CREATE TABLE (LIKE ...) INCLUDING ALL`, `ADD COLUMN`, `INSERT INTO ... SELECT`, `DELETE`, `BEGIN`/`COMMIT`/`ROLLBACK`.

> 🪜 **Steps:**
> 1. `CREATE TABLE fact_patient_visits_archive (LIKE fact_patient_visits INCLUDING ALL)`.
> 2. `ALTER TABLE ... ADD COLUMN archived_at TIMESTAMP DEFAULT NOW()`.
> 3. `BEGIN`.
> 4. `INSERT INTO archive SELECT *, NOW() FROM main WHERE year_int < 2022` — store inserted count.
> 5. `DELETE FROM main WHERE year_int < 2022` — store deleted count.
> 6. Assert: inserted count = deleted count. If equal: `COMMIT`. Otherwise: `ROLLBACK`.

> 📚 **Concept:** Archival wraps INSERT + DELETE in a transaction for atomicity — either both succeed or neither. In production, partition detach is vastly faster for bulk archival: `ALTER TABLE fact_patient_visits DETACH PARTITION p2020` takes milliseconds vs. DELETE which can take hours on millions of rows. `INCLUDING ALL` copies indexes and constraints, making the archive table query-ready.
> 🐘 **PG Ref:** [Partition management](https://www.postgresql.org/docs/current/ddl-partitioning.html#DDL-PARTITIONING-DECLARATIVE-MAINTENANCE)
> 🔬 **DS Equivalent:** Moving old data from a hot database to cold storage (S3 Parquet) — a standard data lakehouse pattern. The two-step INSERT+DELETE is the same as a `MOVE` operation in storage migration.

---

## 💎 Super Expert
> No questions. These are curated learning directions to make you stand out globally.

---

### 🚀 What to Master After Phase 2

**1. PostgreSQL MVCC (Multi-Version Concurrency Control)**
Every row has hidden columns (`xmin`, `xmax` transaction IDs). Reads never block writes. Dead tuples accumulate and require VACUUM. Understanding MVCC explains: why long transactions cause bloat, why VACUUM is critical, why `REPEATABLE READ` and `SERIALIZABLE` isolation differ. Catalog: `pg_stat_activity`, `pg_locks`, `pg_stat_user_tables.n_dead_tup`. When to care: any high-write environment or ETL pipeline design.

**2. WAL (Write-Ahead Log)**
Every change is written to WAL before the data file — this is PostgreSQL's durability mechanism. WAL enables: crash recovery, streaming replication (read replicas for BI), logical replication (CDC / Debezium), and PITR. When: setting up read replicas for analytics, designing event-driven pipelines from CDC. This depth distinguishes you from 99% of practitioners.

**3. Row-Level Security (RLS)**
`CREATE POLICY` + `ALTER TABLE ENABLE ROW LEVEL SECURITY`. Restricts which rows a DB user can see. A cardiologist sees only cardiology records. Critical for HIPAA/GDPR in healthcare analytics. When: multi-tenant SaaS, regulatory compliance, shared analytical environments. The only SQL mechanism that enforces data access at the storage layer.

**4. Domain Types**
`CREATE DOMAIN severity_t AS INTEGER CHECK (VALUE BETWEEN 1 AND 5)`. A reusable constrained type — all columns using it inherit the CHECK constraint automatically. Implements schema-level DRY (Don't Repeat Yourself). When: large schemas with the same constraint across many tables/columns (like `severity_level` appearing in multiple fact tables).

**5. Declarative Table Partitioning**
`fact_patient_visits` at scale needs partitioning: `CREATE TABLE fact_patient_visits PARTITION BY RANGE (arrival_datetime)`. Each monthly partition is a child table. Queries with date filters only scan relevant partitions — 100x speedup. `PARTITION BY LIST (hospital_id)` for regional partitioning. All major cloud warehouses (BigQuery, Redshift, Snowflake) implement this automatically.

**6. Data Modeling Paradigms**
Star schema (your current design), Snowflake schema (normalized dims), Data Vault (hub-satellite-link for auditability), One Big Table (denormalized for simplicity). Know WHY your schema is designed as it is — the trade-offs for query performance, ETL complexity, and schema flexibility. This is what data architects understand that analysts don't.

**7. PostgreSQL Extensions**
`pg_trgm` (fast ILIKE + full-text search with GIN), `pgcrypto` (column encryption for PII), `uuid-ossp` (UUID surrogate keys), `TimescaleDB` (time-series optimization for `arrival_datetime`), `PostGIS` (geospatial queries on `latitude`/`longitude` columns already in your schema). These cover production use cases that other databases can't match natively.

**8. Connection Pooling and Production Deployment**
Every psycopg2/SQLAlchemy connection in Python opens a PostgreSQL process. Without pooling (PgBouncer), 100 concurrent Airflow tasks = 100 connections = memory exhaustion. PgBouncer pools connections in transaction mode. When: any production Python data pipeline. This is an infrastructure detail every data engineer deploying SQL to production must understand.
