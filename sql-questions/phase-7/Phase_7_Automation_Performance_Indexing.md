# 📕 Phase 7 — Automation, Performance Optimization & Indexing
## Stored Procedures · Triggers · UDFs · Indexes · EXPLAIN · Partitioning · Dynamic SQL
### PostgreSQL | NHS Hospital Analytics | Data Science Perspective

---

## 📋 Phase Topics

| Group | Commands & Concepts |
|---|---|
| Programmability | Stored Procedures (`CREATE PROCEDURE`), PL/pgSQL Functions, Anonymous Blocks (`DO`) |
| Triggers | `CREATE TRIGGER`, `BEFORE/AFTER/INSTEAD OF`, `FOR EACH ROW/STATEMENT`, trigger functions |
| UDFs | `CREATE FUNCTION`, `RETURNS TABLE`, `RETURNS SETOF`, `LANGUAGE sql/plpgsql` |
| Indexes | B-tree, Hash, GIN, GiST, BRIN, Partial, Composite, Expression, Covering (`INCLUDE`) |
| EXPLAIN | `EXPLAIN`, `EXPLAIN ANALYZE`, `EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)` |
| Maintenance | `VACUUM`, `ANALYZE`, `VACUUM FULL`, `CLUSTER`, `REINDEX` |
| Partitioning | `PARTITION BY RANGE/LIST/HASH`, Partition Pruning, Partition Maintenance |
| Dynamic SQL | `EXECUTE FORMAT(...)`, `USING` clause for parameters |
| Advanced | Recursive Functions, `pg_cron`, Connection Pooling awareness, `pg_stat_*` monitoring |

---

## 🟢 Beginner

---

### Q1. Create a Scalar Function for Risk Label
Create a PL/pgSQL function `get_risk_label(risk_category VARCHAR) RETURNS VARCHAR` that returns: 'LOW' for 'Low', 'MEDIUM' for 'Medium', 'HIGH' for 'High', 'CRITICAL' for 'Critical', 'UNKNOWN' for anything else.
> 🔍 **Hint:** `CREATE OR REPLACE FUNCTION get_risk_label(risk_category VARCHAR) RETURNS VARCHAR AS $$ BEGIN RETURN CASE ... END; END $$ LANGUAGE plpgsql IMMUTABLE`.
> 📚 **Concept:** PL/pgSQL is PostgreSQL's procedural language. `IMMUTABLE` declares the function deterministic — same inputs always return same outputs, no side effects. PostgreSQL uses `IMMUTABLE` for: query constant folding (the function result is computed once per query, not once per row), function-based index creation, and aggressive caching. Use `VOLATILE` (default) for functions with side effects or those reading current timestamps/random values.
> 🐘 **PG Ref:** [CREATE FUNCTION](https://www.postgresql.org/docs/current/sql-createfunction.html) | [Function volatility](https://www.postgresql.org/docs/current/xfunc-volatility.html)
> 🔬 **DS Equivalent:** A pure Python function with `@functools.lru_cache` — same input, same output, cached. IMMUTABLE enables the same caching at the database level.

---

### Q2. Simple Stored Procedure for Data Refresh
Create a stored procedure `sp_refresh_hospital_stats()` that runs `ANALYZE` on `fact_patient_visits` and refreshes `mv_hospital_scorecard` (if it exists). Call it.
> 🔍 **Hint:** `CREATE OR REPLACE PROCEDURE sp_refresh_hospital_stats() LANGUAGE plpgsql AS $$ BEGIN ANALYZE fact_patient_visits; REFRESH MATERIALIZED VIEW CONCURRENTLY mv_hospital_scorecard; END $$; CALL sp_refresh_hospital_stats();`
> 📚 **Concept:** `CREATE PROCEDURE` (PostgreSQL 11+) differs from `CREATE FUNCTION`: procedures use `CALL`, support `COMMIT`/`ROLLBACK` within the body (functions cannot), and don't return values. Use procedures for: ETL orchestration, multi-step data workflows, batch jobs. Functions for: reusable computations that return values and are used in SELECT/WHERE.
> 🐘 **PG Ref:** [CREATE PROCEDURE](https://www.postgresql.org/docs/current/sql-createprocedure.html)
> 🔬 **DS Equivalent:** A Python function called by an Airflow DAG task — `sp_refresh_hospital_stats()` is one task in a data pipeline.

---

### Q3. B-tree Index on Foreign Key Column
Create a B-tree index on `fact_patient_visits.hospital_id` to speed up joins. Verify with EXPLAIN.
> 🔍 **Hint:** `CREATE INDEX idx_fpv_hospital_id ON fact_patient_visits(hospital_id)`. Then `EXPLAIN SELECT * FROM fact_patient_visits WHERE hospital_id = 'H001'`.
> 📚 **Concept:** B-tree is PostgreSQL's default and most versatile index type. It supports: equality (`=`), range (`<`, `>`, `BETWEEN`), and sort operations. An index on a FK column accelerates: JOINs (nested loop index scan instead of seq scan), WHERE filters on FK, and `DELETE` operations that check FK constraints. Always index FK columns on large fact tables.
> 🐘 **PG Ref:** [B-tree indexes](https://www.postgresql.org/docs/current/indexes-types.html#INDEXES-TYPES-BTREE)
> 🔬 **DS Equivalent:** A pandas index: `df.set_index('hospital_id')` — O(log N) lookup instead of O(N) linear scan. Database B-tree indexes are the physical equivalent.

---

### Q4. Composite Index for Multi-Column Filter
Create a composite index on `fact_patient_visits(hospital_id, admission_type)` to optimise queries filtering on both columns. Demonstrate with EXPLAIN.
> 🔍 **Hint:** `CREATE INDEX idx_fpv_hospital_admission ON fact_patient_visits(hospital_id, admission_type)`. Test: `WHERE hospital_id = 'H001' AND admission_type = 'Emergency'`.
> 📚 **Concept:** Composite indexes support queries filtering on the leftmost columns. `(hospital_id, admission_type)` supports: `WHERE hospital_id = ?`, `WHERE hospital_id = ? AND admission_type = ?`. But NOT: `WHERE admission_type = ?` alone (no leftmost column). This is the "leading column" rule. Column order matters — put the most selective, most frequently filtered column first.
> 🐘 **PG Ref:** [Multi-column indexes](https://www.postgresql.org/docs/current/indexes-multicolumn.html)
> 🔬 **DS Equivalent:** A MultiIndex in pandas: `df.set_index(['hospital_id', 'admission_type'])` — the leftmost index level must be specified for efficient lookup.

---

### Q5. EXPLAIN to Read a Query Plan
Run `EXPLAIN SELECT * FROM fact_patient_visits WHERE hospital_id = 'H001'` both without and with an index. Identify: Seq Scan, Index Scan, Bitmap Index Scan nodes.
> 🔍 **Hint:** Run EXPLAIN, then `CREATE INDEX`, then EXPLAIN again.
> 📚 **Concept:** EXPLAIN shows the query execution plan without running the query. Key nodes: `Seq Scan` (full table scan — no index used), `Index Scan` (uses index, returns rows one by one), `Bitmap Index Scan` + `Bitmap Heap Scan` (builds bitmap of matching pages, then fetches — efficient for range scans returning many rows), `Index Only Scan` (index contains all needed columns — no heap access).
> 🐘 **PG Ref:** [EXPLAIN](https://www.postgresql.org/docs/current/sql-explain.html) | [Scan types](https://www.postgresql.org/docs/current/using-explain.html)
> 🔬 **DS Equivalent:** Profiling a pandas operation: checking if an index is being used for a `.loc[]` lookup vs a linear scan through all rows.

---

### Q6. EXPLAIN ANALYZE: Actual vs Estimated Rows
Run `EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM fact_patient_visits WHERE severity_level >= 4`. Identify estimated vs actual rows and whether the estimate is accurate.
> 🔍 **Hint:** Look for `rows=X` (estimated) vs `actual rows=Y` (actual) in the plan.
> 📚 **Concept:** `EXPLAIN ANALYZE` runs the query and shows actual execution statistics. `rows=` is the planner's estimate (from table statistics). `actual rows=` is the real count. When estimates are off by 10x+, the planner may choose a suboptimal join order. Fix: run `ANALYZE table_name` to refresh statistics. The `Buffers:` section shows: `shared hit` (from cache), `shared read` (from disk) — high `read` count indicates cold cache.
> 🐘 **PG Ref:** [EXPLAIN ANALYZE](https://www.postgresql.org/docs/current/sql-explain.html#id-1.9.3.145.7)
> 🔬 **DS Equivalent:** Comparing expected vs actual output shapes in a ML pipeline — `assert X_train.shape == expected_shape`. Mismatches indicate upstream data issues.

---

### Q7. VACUUM and ANALYZE on Fact Tables
Run `VACUUM ANALYZE fact_patient_visits` and `VACUUM FULL fact_staffing`. Explain the difference. Check `pg_stat_user_tables` before and after.
> 🔍 **Hint:** `VACUUM fact_patient_visits; ANALYZE fact_patient_visits;` or combined. Check `n_dead_tup`, `last_vacuum`, `last_analyze` from `pg_stat_user_tables`.
> 📚 **Concept:** `VACUUM`: reclaims space from dead tuples (rows marked for deletion by MVCC). Non-blocking. `VACUUM FULL`: compacts the table physically (reclaims disk space) but locks the table. `ANALYZE`: updates query planner statistics (table size, column distribution). `VACUUM ANALYZE`: does both. Autovacuum handles routine VACUUM automatically — manual vacuum is needed after large bulk deletes/updates that generate many dead tuples.
> 🐘 **PG Ref:** [VACUUM](https://www.postgresql.org/docs/current/sql-vacuum.html) | [pg_stat_user_tables](https://www.postgresql.org/docs/current/monitoring-stats.html#MONITORING-PG-STAT-USER-TABLES-VIEW)
> 🔬 **DS Equivalent:** Garbage collection in Python — VACUUM reclaims memory/disk from objects no longer referenced. `VACUUM FULL` is like `gc.collect()` with compaction.

---

### Q8. Create an Audit Trigger Function
Create a trigger function `trg_audit_visits()` that writes to `audit_log` whenever a row in `fact_patient_visits` is INSERTED or UPDATED. Include: table name, operation, old/new `visit_id`, timestamp.
> 🔍 **Hint:** `CREATE OR REPLACE FUNCTION trg_audit_visits() RETURNS TRIGGER AS $$ BEGIN INSERT INTO audit_log(table_name, operation, record_id, changed_at) VALUES (TG_TABLE_NAME, TG_OP, NEW.visit_id, NOW()); RETURN NEW; END $$ LANGUAGE plpgsql`.
> 📚 **Concept:** Trigger functions use special variables: `TG_OP` (INSERT/UPDATE/DELETE), `TG_TABLE_NAME`, `NEW` (new row values), `OLD` (old row values for UPDATE/DELETE). `RETURN NEW` is required for row-level BEFORE triggers (to pass the row to the database). `RETURN NULL` cancels the operation (useful for validation triggers).
> 🐘 **PG Ref:** [Trigger functions](https://www.postgresql.org/docs/current/plpgsql-trigger.html) | [Trigger special variables](https://www.postgresql.org/docs/current/plpgsql-trigger.html#PLPGSQL-DML-TRIGGER)
> 🔬 **DS Equivalent:** A database event hook — equivalent to `df.pipe(log_changes)` after every DataFrame modification, but enforced at the database layer rather than application code.

---

### Q9. Attach the Trigger to the Table
Using the trigger function from Q8, create an `AFTER INSERT OR UPDATE` trigger on `fact_patient_visits` called `audit_visits_trigger`.
> 🔍 **Hint:** `CREATE TRIGGER audit_visits_trigger AFTER INSERT OR UPDATE ON fact_patient_visits FOR EACH ROW EXECUTE FUNCTION trg_audit_visits()`.
> 📚 **Concept:** Triggers attach to tables and fire on specified events. `AFTER` triggers fire after the row is written (data is committed to the table). `BEFORE` triggers fire before the write — useful for validation (RETURN NULL to reject) or data transformation (modify NEW values). `FOR EACH ROW` fires once per affected row. `FOR EACH STATEMENT` fires once per SQL statement regardless of how many rows are affected.
> 🐘 **PG Ref:** [CREATE TRIGGER](https://www.postgresql.org/docs/current/sql-createtrigger.html)
> 🔬 **DS Equivalent:** An event listener/observer pattern — `table.on('insert', audit_handler)` in application code. Database triggers enforce this regardless of which application/user modifies the data.

---

### Q10. Partial Index for Active Records
Create a partial index on `fact_patient_visits(hospital_id)` where `is_deleted = false` (or `mortality_flag = false`). Show EXPLAIN with and without the partial index.
> 🔍 **Hint:** `CREATE INDEX idx_active_visits_hospital ON fact_patient_visits(hospital_id) WHERE is_deleted = false`.
> 📚 **Concept:** Partial indexes index only rows matching a WHERE condition — the index is physically smaller than a full index (proportional to matching rows). Queries with the same WHERE condition can use the partial index; queries without it cannot. If 90% of visits are active (`is_deleted = false`), the partial index has the same size as a full index — not useful. Ideal when the indexed subset is 1–30% of total rows.
> 🐘 **PG Ref:** [Partial indexes](https://www.postgresql.org/docs/current/indexes-partial.html)
> 🔬 **DS Equivalent:** Filtering before indexing — like building an sklearn pipeline that first filters rows then applies transformations, rather than processing all rows first.

---

### Q11. Hash Index for Exact-Match Only
Create a Hash index on `dim_patient.insurance_type`. Explain when it's faster than B-tree and its limitations.
> 🔍 **Hint:** `CREATE INDEX idx_patient_insurance_hash ON dim_patient USING hash (insurance_type)`.
> 📚 **Concept:** Hash indexes support ONLY equality comparisons (`=`). They cannot support: range queries (`<`, `>`), sorting, or `LIKE`. They are slightly faster than B-tree for pure equality lookups. Hash indexes are WAL-logged in PostgreSQL 10+ (previously not crash-safe). In practice, B-tree is usually preferred for its versatility — only choose Hash when you need pure equality at maximum speed and are certain no range queries will ever be needed.
> 🐘 **PG Ref:** [Hash indexes](https://www.postgresql.org/docs/current/indexes-types.html#INDEXES-TYPES-HASH)
> 🔬 **DS Equivalent:** A Python `dict` (hash map) vs a sorted list — `dict` has O(1) lookup for exact keys, but cannot find "all keys greater than X". B-tree indexes are sorted lists with O(log N) lookup for both equality and range.

---

### Q12. REINDEX: Rebuild a Bloated Index
Simulate index bloat by running many UPDATEs on `fact_patient_visits`. Check index size with `pg_relation_size`. Run `REINDEX INDEX` and compare size.
> 🔍 **Hint:** `SELECT pg_size_pretty(pg_relation_size('idx_fpv_hospital_id'))`. After UPDATEs, compare. `REINDEX INDEX CONCURRENTLY idx_fpv_hospital_id`.
> 📚 **Concept:** Index bloat occurs when frequent updates/deletes leave dead index entries — the index grows but doesn't shrink automatically. `REINDEX` rebuilds the index from scratch. `REINDEX INDEX CONCURRENTLY` rebuilds without locking (PostgreSQL 12+) — safe for production. `REINDEX DATABASE CONCURRENTLY` rebuilds all indexes. Check bloat via `pg_stat_user_indexes.idx_blks_read / idx_blks_hit` ratio — high ratio indicates bloat.
> 🐘 **PG Ref:** [REINDEX](https://www.postgresql.org/docs/current/sql-reindex.html) | [pg_relation_size](https://www.postgresql.org/docs/current/functions-admin.html)
> 🔬 **DS Equivalent:** Rebuilding a sklearn model with accumulated data drift — the "index" (learned structure) has degraded and needs rebuilding from scratch for optimal performance.

---

## 🟡 Medium
> 2–3 concepts · Multi-table · Automation focus

---

### Q1. Parameterised Stored Procedure for Monthly Report
Create `sp_monthly_visit_report(p_hospital_id VARCHAR, p_year INT, p_month INT)` that returns a report of visit metrics for a specific hospital and month. Use a CURSOR or RETURNS TABLE approach.

> 🔍 **Hint:** `CREATE OR REPLACE PROCEDURE sp_monthly_visit_report(...)` with `RAISE NOTICE` output, or use a function with `RETURNS TABLE`.

> 📚 **Concept:** Parameterised procedures accept input arguments. `IN` parameters are input-only. `INOUT` parameters can return values from procedures. Functions returning `TABLE` are more flexible: `CREATE FUNCTION get_monthly_report(hospital_id VARCHAR, ...) RETURNS TABLE(visit_count INT, avg_cost NUMERIC, ...)` — callable with `SELECT * FROM get_monthly_report(...)`. Returning a table from a function is preferred over procedures for query-compatible output.
> 🐘 **PG Ref:** [Procedures with parameters](https://www.postgresql.org/docs/current/sql-createprocedure.html) | [Functions returning sets](https://www.postgresql.org/docs/current/xfunc-sql.html#XFUNC-SQL-FUNCTIONS-RETURNING-TABLE)
> 🔬 **DS Equivalent:** A Python function that returns a DataFrame: `def get_monthly_report(hospital_id, year, month) -> pd.DataFrame: ...` — parameterised, reusable analytical computation.

---

### Q2. SCD Type 2 Update Trigger
Create a trigger on `dim_hospital` that, when a row is UPDATED, automatically: (1) inserts the old values into `dim_hospital_v2` with `valid_to = NOW()`, (2) inserts the new values with `valid_from = NOW()`, `valid_to = NULL`.

> 🔍 **Hint:** `BEFORE UPDATE` trigger on `dim_hospital`. Access `OLD.*` for the previous values, `NEW.*` for new.

> 📚 **Concept:** Triggers that implement SCD Type 2 automatically maintain historical dimension records without application-layer code. `BEFORE UPDATE` fires before the update is applied — `OLD` has the current values, `NEW` has the incoming values. By inserting `OLD` into the archive table and letting the UPDATE proceed on the main table, you maintain both current and historical states. This is how enterprise ETL tools (Informatica, Ab Initio) implement SCD2 under the hood.
> 🐘 **PG Ref:** [Trigger special variables NEW/OLD](https://www.postgresql.org/docs/current/plpgsql-trigger.html)
> 🔬 **DS Equivalent:** An event-sourcing pattern — every change creates a new event record rather than modifying in place. The trigger is the event capture mechanism.

---

### Q3. Covering Index with INCLUDE
Create a covering index on `fact_patient_visits(hospital_id, admission_type)` that INCLUDES `treatment_cost` and `wait_time_minutes`. Show that queries selecting these columns can use an Index Only Scan.

> 🔍 **Hint:** `CREATE INDEX idx_covering ON fact_patient_visits(hospital_id, admission_type) INCLUDE (treatment_cost, wait_time_minutes)`.

> 📚 **Concept:** A covering index (using `INCLUDE`) stores additional columns in the index leaf pages. Queries selecting only indexed + included columns can use an "Index Only Scan" — no heap access at all. The key difference: `INCLUDE` columns cannot be used in WHERE predicates or ORDER BY; they are only available for projection (SELECT). This makes the index larger but eliminates heap access for common queries.
> 🐘 **PG Ref:** [Covering indexes](https://www.postgresql.org/docs/current/indexes-index-only-scans.html) | [CREATE INDEX INCLUDE](https://www.postgresql.org/docs/current/sql-createindex.html)
> 🔬 **DS Equivalent:** A pre-joined lookup table that contains all needed columns — zero additional I/O required when the lookup hits the index.

---

### Q4. Dynamic SQL: Flexible Table Stats Procedure
Create a procedure `sp_table_stats(p_table_name VARCHAR)` that dynamically executes `SELECT COUNT(*), MAX(updated_at) FROM <table>` using `EXECUTE FORMAT(...)`. Use `%I` for safe identifier quoting.

> 🔍 **Hint:** `EXECUTE FORMAT('SELECT COUNT(*), MAX(arrival_datetime) FROM %I', p_table_name) INTO row_count, max_date`.

> 📚 **Concept:** Dynamic SQL builds query strings at runtime using `EXECUTE`. `FORMAT('%I', name)` safely quote-escapes identifiers — critical for preventing SQL injection. Without `%I`, a table name like `dim_hospital; DROP TABLE dim_hospital` would be catastrophic. `%L` safely quotes literal values. Dynamic SQL enables: metadata-driven ETL, generic utilities, database tooling. The `USING` clause passes parameterised values: `EXECUTE 'SELECT ... WHERE id = $1' USING my_id`.
> 🐘 **PG Ref:** [Dynamic SQL EXECUTE](https://www.postgresql.org/docs/current/plpgsql-statements.html#PLPGSQL-STATEMENTS-EXECUTING-DYN) | [FORMAT %I](https://www.postgresql.org/docs/current/functions-string.html#FUNCTIONS-STRING-FORMAT)
> 🔬 **DS Equivalent:** `f"SELECT * FROM {table_name}"` — dangerous without sanitisation. `%I` is the SQL equivalent of parameterised queries in Python (`cursor.execute("SELECT * FROM %s", (table_name,))` with proper escaping).

---

### Q5. Table Partitioning: Range Partition by Year
Create a partitioned version of `fact_patient_visits` partitioned by RANGE on `arrival_datetime`. Create partitions for 2021, 2022, 2023, and a default. Show partition pruning with EXPLAIN.

> 🔍 **Hint:** `CREATE TABLE fact_patient_visits_p (LIKE fact_patient_visits INCLUDING ALL) PARTITION BY RANGE (arrival_datetime)`. Then `CREATE TABLE fpv_2021 PARTITION OF fact_patient_visits_p FOR VALUES FROM ('2021-01-01') TO ('2022-01-01')`.

> 📚 **Concept:** Declarative range partitioning splits a large table into child tables by value range. PostgreSQL routes: INSERTs to the correct partition automatically, SELECTs only scan partitions matching the WHERE clause (partition pruning). A query `WHERE arrival_datetime BETWEEN '2023-01-01' AND '2023-12-31'` only scans the 2023 partition — ignoring 2021, 2022 entirely. For 5 years × 12 months partitions = 60 children, queries filter to 1 partition: 60x speedup potential.
> 🐘 **PG Ref:** [Declarative partitioning](https://www.postgresql.org/docs/current/ddl-partitioning.html#DDL-PARTITIONING-DECLARATIVE)
> 🔬 **DS Equivalent:** Parquet file partitioning: `df.to_parquet('data/', partition_cols=['year'])` — queries on partitioned Parquet read only matching year folders. PostgreSQL partitioning is the relational equivalent.

---

### Q6. BRIN Index for Time-Series Fact Table
Create a BRIN index on `fact_patient_visits.arrival_datetime`. Explain when BRIN is appropriate and when B-tree is better.

> 🔍 **Hint:** `CREATE INDEX idx_fpv_arrival_brin ON fact_patient_visits USING brin(arrival_datetime)`.

> 📚 **Concept:** BRIN (Block Range INdex) stores min/max values per range of disk pages. It's tiny (a few KB for millions of rows) but only efficient when data is physically sorted by the indexed column (e.g., an append-only time-series table). For `arrival_datetime` in a time-ordered append table, BRIN eliminates page blocks outside the queried range. For random-write tables (updates/deletes scramble page order), BRIN loses effectiveness. Rule: BRIN for append-only time-series, B-tree for everything else.
> 🐘 **PG Ref:** [BRIN indexes](https://www.postgresql.org/docs/current/brin-intro.html)
> 🔬 **DS Equivalent:** Zone maps in Parquet files — each row group stores min/max per column for predicate pushdown. BRIN is PostgreSQL's equivalent of Parquet zone maps.

---

### Q7. GIN Index for Full-Text and Array Search
Create a GIN index on `dim_patient.chronic_conditions` (as text, using `pg_trgm`) for fast ILIKE queries. Also create a GIN index on `conditions_jsonb` for fast JSON containment queries.

> 🔍 **Hint:** `CREATE EXTENSION IF NOT EXISTS pg_trgm; CREATE INDEX idx_patient_conditions_trgm ON dim_patient USING gin(chronic_conditions gin_trgm_ops)`.

> 📚 **Concept:** GIN (Generalised Inverted Index) stores a posting list per element — each element in an array/tsvector/jsonb maps to a list of rows containing it. GIN is ideal for: full-text search (tsvector), JSONB containment (`@>`), array membership (`&&`, `@>`), trigram matching (`ILIKE`). GIN indexes are slower to build and maintain than B-tree but dramatically faster for multi-value type queries. GiST (Generalised Search Tree) is the alternative for geometric/range type overlaps.
> 🐘 **PG Ref:** [GIN indexes](https://www.postgresql.org/docs/current/gin-intro.html) | [GiST vs GIN](https://www.postgresql.org/docs/current/textsearch-indexes.html)
> 🔬 **DS Equivalent:** An inverted index in information retrieval — the core data structure of search engines (Elasticsearch, Lucene). GIN brings search engine speed to PostgreSQL for text and array queries.

---

### Q8. Partition Maintenance: Add and Detach Partitions
For the partitioned `fact_patient_visits_p`, add a 2024 partition. Then detach the 2021 partition for archival. Show that queries on current data are unaffected.

> 🔍 **Hint:** `CREATE TABLE fpv_2024 PARTITION OF fact_patient_visits_p FOR VALUES FROM ('2024-01-01') TO ('2025-01-01')`. Detach: `ALTER TABLE fact_patient_visits_p DETACH PARTITION fpv_2021`.

> 📚 **Concept:** Partition maintenance is the key operational advantage of partitioning. Adding a new partition: just CREATE TABLE with the new range — zero data movement. Detaching an old partition: `DETACH PARTITION` removes the child from the parent table (instantly) — the child table still exists with its data. Archive by renaming: `ALTER TABLE fpv_2021 RENAME TO fpv_2021_archive`. This is 1000x faster than `DELETE WHERE year = 2021` for archival.
> 🐘 **PG Ref:** [Partition maintenance](https://www.postgresql.org/docs/current/ddl-partitioning.html#DDL-PARTITIONING-DECLARATIVE-MAINTENANCE)
> 🔬 **DS Equivalent:** Adding/removing a partition in Apache Iceberg or Hive: `ALTER TABLE ADD PARTITION` / `ALTER TABLE DROP PARTITION` — same concept, same speed advantage over DELETE.

---

### Q9. Function that Returns a Table
Create `fn_hospital_visits(p_hospital_id VARCHAR, p_year INT) RETURNS TABLE(visit_id VARCHAR, patient_id VARCHAR, treatment_cost NUMERIC, admission_type VARCHAR)` that returns filtered visit records. Use it in a JOIN.

> 🔍 **Hint:** `CREATE OR REPLACE FUNCTION fn_hospital_visits(p_hospital_id VARCHAR, p_year INT) RETURNS TABLE(visit_id VARCHAR, ...) AS $$ SELECT visit_id, patient_id, ... FROM fact_patient_visits WHERE hospital_id = p_hospital_id AND EXTRACT(YEAR FROM arrival_datetime) = p_year $$ LANGUAGE sql STABLE`.

> 📚 **Concept:** `RETURNS TABLE` functions are "table-valued functions" — they return result sets usable in FROM clauses. `LANGUAGE sql` is used for pure-SQL functions (no procedural code needed). `STABLE` declares the function returns consistent results within one transaction (may read tables but doesn't modify them). These are used to encapsulate parameterised views — a view with parameters. The function appears in `FROM` as: `SELECT * FROM fn_hospital_visits('H001', 2023) fhv JOIN ...`.
> 🐘 **PG Ref:** [Table-valued functions](https://www.postgresql.org/docs/current/xfunc-sql.html#XFUNC-SQL-FUNCTIONS-RETURNING-TABLE)
> 🔬 **DS Equivalent:** A Python function returning a filtered DataFrame: `def get_hospital_visits(hospital_id, year) -> pd.DataFrame`. Used in a pipeline like any other dataset source.

---

### Q10. Expression Index for Case-Insensitive Search
Create an expression index on `LOWER(hospital_name)` in `dim_hospital`. Show that `WHERE LOWER(hospital_name) = 'royal london hospital'` uses the index.

> 🔍 **Hint:** `CREATE INDEX idx_hosp_lower_name ON dim_hospital (LOWER(hospital_name))`. Then `EXPLAIN SELECT * FROM dim_hospital WHERE LOWER(hospital_name) = 'royal london hospital'`.

> 📚 **Concept:** Expression indexes (function-based indexes) store the result of a function/expression rather than the raw column value. The query planner uses an expression index when the exact expression in the WHERE clause matches the index definition. Requirements: the function must be `IMMUTABLE` (LOWER is immutable — it always produces the same result for the same input). Expression indexes are also used for: date extraction (`EXTRACT(YEAR FROM col)`), JSON field access (`data->>'key'`), computed hash values.
> 🐘 **PG Ref:** [Indexes on expressions](https://www.postgresql.org/docs/current/indexes-expressional.html)
> 🔬 **DS Equivalent:** Precomputing a transformed column for fast lookup — like adding `df['lower_name'] = df['hospital_name'].str.lower()` then indexing that column. The expression index does this at the database layer automatically.

---

### Q11. Trigger for Data Validation
Create a BEFORE INSERT trigger on `fact_patient_visits` that rejects inserts where `wait_time_minutes < 0` or `severity_level` is outside 1–5. Use `RAISE EXCEPTION` to block the invalid insert.

> 🔍 **Hint:** Trigger function: `IF NEW.wait_time_minutes < 0 THEN RAISE EXCEPTION 'Invalid wait time: %', NEW.wait_time_minutes; END IF`.

> 📚 **Concept:** BEFORE INSERT/UPDATE triggers can validate data before it reaches the database, providing an application-agnostic safety net. `RAISE EXCEPTION` rolls back the statement and returns an error to the caller. `RAISE WARNING` logs without aborting. Trigger-based validation is complementary to CHECK constraints — triggers can implement complex multi-column validation logic that CHECK constraints cannot. However, triggers add overhead to every INSERT/UPDATE — only use them for validation that cannot be expressed as a CHECK constraint.
> 🐘 **PG Ref:** [RAISE statement](https://www.postgresql.org/docs/current/plpgsql-errors-and-messages.html)
> 🔬 **DS Equivalent:** Pydantic validators with `@validator` decorator — the database trigger is the same concept enforced at the persistence layer rather than the application layer.

---

### Q12. pg_stat_statements: Find Slowest Queries
Enable `pg_stat_statements` extension. Query it to find the 10 slowest queries (by total execution time) in your database. Show query text, call count, total time, mean time.

> 🔍 **Hint:** `CREATE EXTENSION pg_stat_statements; SELECT query, calls, total_exec_time, mean_exec_time, rows FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 10`.

> 📚 **Concept:** `pg_stat_statements` records statistics for every unique SQL query. `total_exec_time`: total CPU+I/O time for all executions. `mean_exec_time`: average per call. `calls`: how many times it was executed. The product `calls × mean_exec_time` shows total impact. High `calls` + low mean time (many fast queries) can be as impactful as low `calls` + high mean time. This is the #1 tool for query performance tuning in production.
> 🐘 **PG Ref:** [pg_stat_statements](https://www.postgresql.org/docs/current/pgstatstatements.html)
> 🔬 **DS Equivalent:** Python cProfile or line_profiler — identifying which functions consume the most CPU time. `pg_stat_statements` is the database-level profiler.

---

## 🟠 Medium Hard
> Automation pipelines · Performance analysis · Steps required

---

### Q1. Automated ETL Procedure with Error Handling
Build `sp_load_daily_visits(p_source_table VARCHAR, p_load_date DATE)` that: (1) validates source data quality, (2) inserts valid rows into `fact_patient_visits`, (3) logs errors to `etl_error_log`, (4) wraps in SAVEPOINT for partial rollback.

> 🔍 **Hint:** Concepts: Dynamic SQL for source table access, SAVEPOINT + ROLLBACK TO SAVEPOINT, EXCEPTION WHEN, INSERT into error log.

> 🪜 **Steps:**
> 1. Create `etl_error_log (log_id SERIAL, error_msg TEXT, error_time TIMESTAMP DEFAULT NOW())`.
> 2. In procedure: `SAVEPOINT sp1`.
> 3. Dynamic: `EXECUTE FORMAT('INSERT INTO fact_patient_visits SELECT * FROM %I WHERE load_date = $1', p_source_table) USING p_load_date`.
> 4. `EXCEPTION WHEN OTHERS THEN ROLLBACK TO SAVEPOINT sp1; INSERT INTO etl_error_log(error_msg) VALUES (SQLERRM)`.
> 5. Log success/failure to a load_log table.

> 📚 **Concept:** `SAVEPOINT` creates a partial transaction save point — `ROLLBACK TO SAVEPOINT name` rolls back to that point without rolling back the entire transaction. Combined with `EXCEPTION WHEN OTHERS THEN`, this enables graceful error handling: log the error, rollback the failed part, and continue processing. `SQLERRM` contains the error message. `SQLSTATE` contains the error code. This pattern is the foundation of robust ETL pipelines.
> 🐘 **PG Ref:** [SAVEPOINT](https://www.postgresql.org/docs/current/sql-savepoint.html) | [PL/pgSQL exception handling](https://www.postgresql.org/docs/current/plpgsql-control-structures.html#PLPGSQL-ERROR-TRAPPING)
> 🔬 **DS Equivalent:** Python try/except in an ETL function with partial rollback: `try: process_batch(); except Exception as e: log_error(e); connection.rollback()` — but SAVEPOINTs allow finer granularity.

---

### Q2. Index Strategy for Star Schema Queries
Analyse the 4-table star join (fact_patient_visits + 3 dims) from Phase 3. Design and implement the optimal index strategy: identify which columns need indexes, what type (B-tree/composite/covering), and verify with EXPLAIN.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_patient`, `dim_doctor`, `dim_hospital`. Concepts: FK indexes on fact table, primary key indexes on dims, covering indexes for frequent SELECT columns.

> 🪜 **Steps:**
> 1. Identify FK columns in `fact_patient_visits`: `patient_id`, `doctor_id`, `hospital_id`, `department_id`.
> 2. Create B-tree indexes on each FK.
> 3. Identify the most common WHERE clause: `admission_type`, `severity_level`, `arrival_datetime` range.
> 4. Create composite: `(admission_type, severity_level)`, `(hospital_id, arrival_datetime)`.
> 5. EXPLAIN the star join before and after — count Seq Scans eliminated.

> 📚 **Concept:** Star schema index strategy: (1) Primary keys on all dimension tables (already exist). (2) B-tree on all FK columns in fact table (most impactful). (3) Composite indexes for frequent multi-column WHERE. (4) Covering indexes (`INCLUDE`) for high-frequency projection columns. Indexes are not free — each index adds overhead to INSERT/UPDATE/DELETE. The goal: maximum query speedup with minimum write penalty. For a read-heavy analytics workload, err toward more indexes.
> 🐘 **PG Ref:** [Index best practices](https://www.postgresql.org/docs/current/indexes-ordering.html)
> 🔬 **DS Equivalent:** Feature selection for a model — choosing which columns to index is like choosing which features provide the most signal. Both involve a trade-off between coverage and overhead.

---

### Q3. Partition-Wise Aggregation Analysis
For the partitioned `fact_patient_visits_p`, run: `SELECT DATE_TRUNC('year', arrival_datetime), COUNT(*) FROM fact_patient_visits_p GROUP BY 1`. Enable `enable_partitionwise_aggregate = on`. Compare EXPLAIN plans with it on and off.

> 🔍 **Hint:** `SET enable_partitionwise_aggregate = on; EXPLAIN (ANALYZE, BUFFERS) SELECT DATE_TRUNC('year', ...), COUNT(*) FROM fact_patient_visits_p GROUP BY 1`.

> 🪜 **Steps:**
> 1. `SET enable_partitionwise_aggregate = off` — baseline plan.
> 2. `SET enable_partitionwise_aggregate = on` — partitioned plan.
> 3. With on: each partition aggregates independently, results merged. Enables parallel partition scanning.
> 4. Compare: node types, execution time, buffer reads.
> 5. `SET max_parallel_workers_per_gather = 4` — combine with parallelism.

> 📚 **Concept:** Partition-wise aggregation pushes GROUP BY down into each partition — each partition computes its partial aggregate in parallel. The coordinator then merges partial results (like MapReduce's combine phase). For a 12-partition table with `GROUP BY year` (matching partition key), partitionwise aggregation is 12x parallelisable. Combined with `max_parallel_workers_per_gather`, this delivers near-linear scalability for time-series aggregations.
> 🐘 **PG Ref:** [Partition-wise aggregation](https://www.postgresql.org/docs/current/ddl-partitioning.html#DDL-PARTITIONING-PERFORMANCE) | [enable_partitionwise_aggregate](https://www.postgresql.org/docs/current/runtime-config-query.html#GUC-ENABLE-PARTITIONWISE-AGGREGATE)
> 🔬 **DS Equivalent:** Spark's partition-local aggregation (`reduceByKey`) vs global aggregation (`groupByKey`) — the same push-down aggregation concept for distributed compute.

---

### Q4. Recursive Function: Factorial and Fibonacci
Implement factorial as a recursive PL/pgSQL function. Then implement a memoised version using a `cache` table. Benchmark both for N=20.

> 🔍 **Hint:** `CREATE OR REPLACE FUNCTION factorial(n INT) RETURNS BIGINT AS $$ BEGIN IF n <= 1 THEN RETURN 1; END IF; RETURN n * factorial(n - 1); END $$ LANGUAGE plpgsql`.

> 🪜 **Steps:**
> 1. Write the recursive factorial function.
> 2. Test: `SELECT factorial(10)`.
> 3. Create `factorial_cache (n INT PRIMARY KEY, result BIGINT)`.
> 4. Memoised version: check cache first, compute and store if miss.
> 5. Benchmark: `\timing SELECT factorial(20)` vs memoised version — second call should be near-instant.

> 📚 **Concept:** Recursive PL/pgSQL functions use the call stack — deep recursion risks a stack overflow. PostgreSQL limits stack depth via `max_stack_depth`. Memoisation (caching results in a table) converts O(N) recursion into O(1) for repeated calls. This is the SQL equivalent of Python's `@functools.lru_cache`. For recursive computations called frequently with the same inputs (risk score, derived metrics), memoisation dramatically improves performance.
> 🐘 **PG Ref:** [PL/pgSQL recursive functions](https://www.postgresql.org/docs/current/plpgsql-control-structures.html) | [max_stack_depth](https://www.postgresql.org/docs/current/runtime-config-resource.html#GUC-MAX-STACK-DEPTH)
> 🔬 **DS Equivalent:** `@functools.lru_cache(maxsize=None)` in Python — the memoisation pattern applies identically to SQL functions.

---

### Q5. Trigger-Based SCD Type 2 Automation
Implement a complete SCD Type 2 trigger system on `dim_hospital`: BEFORE UPDATE trigger that inserts the old record into `dim_hospital_history` (with `valid_to = NOW()`) and sets `valid_from = NOW()` on the updated record.

> 🔍 **Hint:** Trigger function: `INSERT INTO dim_hospital_history SELECT OLD.*, OLD.valid_from, NOW()`. Then `NEW.valid_from = NOW(); RETURN NEW`.

> 🪜 **Steps:**
> 1. Create `dim_hospital_history` with same columns as `dim_hospital` + `valid_from TIMESTAMP`, `valid_to TIMESTAMP`.
> 2. BEFORE UPDATE trigger function: archive `OLD.*` with `valid_to = NOW()`, set `NEW.valid_from = NOW()`.
> 3. `RETURN NEW` — allows the UPDATE to proceed with modified `valid_from`.
> 4. Test: UPDATE a hospital record, check history table has the old version.
> 5. Verify: query history for all versions of hospital 'H001'.

> 📚 **Concept:** This trigger automates what Phase 2 SCD2 did manually. The BEFORE UPDATE trigger fires before the row is written — `NEW` can be modified (set `valid_from`) before the database stores it. The history table accumulates all versions. Combined with a partial index `WHERE valid_to IS NULL` for current records, this is a production-grade slowly changing dimension implementation — no application code required.
> 🐘 **PG Ref:** [BEFORE triggers modifying NEW](https://www.postgresql.org/docs/current/plpgsql-trigger.html)
> 🔬 **DS Equivalent:** Event sourcing: every change is recorded as an immutable event. The trigger is the event capture mechanism; the history table is the event store. Modern data platforms (Delta Lake, Iceberg) implement this at the storage layer.

---

### Q6. Query Plan Forcing with pg_hint_plan
Install `pg_hint_plan` extension. Force specific join type (HashJoin vs NestLoop) and index usage on the 4-table star join. Demonstrate when forcing is useful and when it backfires.

> 🔍 **Hint:** `/*+ HashJoin(fpv dh) IndexScan(fpv idx_fpv_hospital_id) */ SELECT ...` — comment hints before the query.

> 🪜 **Steps:**
> 1. `CREATE EXTENSION pg_hint_plan` (if available).
> 2. Write 4-table star join with hint: `/*+ NestLoop(fpv dp) HashJoin(fpv dh) */`.
> 3. EXPLAIN with and without hints — compare plans and costs.
> 4. Force a bad plan intentionally — observe higher cost.
> 5. Conclusion: hints are emergency tools, not defaults — fix statistics first.

> 📚 **Concept:** `pg_hint_plan` allows overriding the query planner with explicit join type, scan type, and join order hints. It's an emergency tool — the planner is usually right. When to use hints: statistics are stale and you can't run ANALYZE (production lock risk), parameterised queries where the planner makes consistently bad estimates, one-off analytical queries where you've profiled the optimal plan. Wrong hints can degrade performance by 100x.
> 🐘 **PG Ref:** [pg_hint_plan](https://pghintplan.osdn.jp/pg_hint_plan.html)
> 🔬 **DS Equivalent:** Overriding sklearn's hyperparameter search with manually set values — sometimes you know better than the automated process, but usually you don't.

---

### Q7. Comprehensive Index Audit Procedure
Create a procedure `sp_index_audit()` that queries `pg_stat_user_indexes`, `pg_stat_user_tables`, and `pg_indexes` to report: (1) unused indexes (zero scans since last stats reset), (2) duplicate indexes (same column combination), (3) tables with no indexes (only seq scans).

> 🔍 **Hint:** `pg_stat_user_indexes.idx_scan = 0` for unused; self-join on `pg_indexes.indexdef` for duplicates; `pg_stat_user_tables.seq_scan > 1000 AND idx_scan = 0` for unindexed hot tables.

> 🪜 **Steps:**
> 1. Unused: `WHERE idx_scan = 0 AND schemaname = 'public'` from `pg_stat_user_indexes`.
> 2. Duplicates: self-join `pg_indexes` on `tablename, indexdef` where two indexes have same definition.
> 3. Hot unindexed: `pg_stat_user_tables WHERE seq_scan > 1000 AND idx_tup_fetch < seq_tup_read` — high seq scan, low index use.
> 4. Combine into one report with a `UNION ALL` labeling each finding type.

> 📚 **Concept:** Index auditing is a routine DBA task. Unused indexes consume disk space and slow INSERT/UPDATE/DELETE without benefit. Duplicate indexes do the same. `pg_stat_user_indexes.idx_scan` counts how many times the index was used since the last stats reset (`SELECT pg_stat_reset()` clears all stats — run sparingly). A zero-scan index over a week in production is a candidate for removal — but verify first, as some indexes are only used during batch jobs.
> 🐘 **PG Ref:** [pg_stat_user_indexes](https://www.postgresql.org/docs/current/monitoring-stats.html#MONITORING-PG-STAT-ALL-INDEXES-VIEW)
> 🔬 **DS Equivalent:** Feature importance analysis — removing zero-importance features (unused indexes) and redundant features (duplicate indexes) to reduce model overhead. Same principle: eliminate what doesn't contribute.

---

### Q8. Automatic Partition Creation Procedure
Create `sp_ensure_partition(p_year INT, p_month INT)` that checks if the appropriate monthly partition of `fact_patient_visits_p` exists and creates it if not. Use dynamic SQL with `EXECUTE`.

> 🔍 **Hint:** Check `pg_class` for partition name. If missing: `EXECUTE FORMAT('CREATE TABLE fpv_%s_%s PARTITION OF fact_patient_visits_p FOR VALUES FROM (%L) TO (%L)', year, month, start_date, end_date)`.

> 🪜 **Steps:**
> 1. Compute start_date: `MAKE_DATE(p_year, p_month, 1)`.
> 2. Compute end_date: `start_date + INTERVAL '1 month'`.
> 3. Partition name: `FORMAT('fpv_%s_%s', p_year, LPAD(p_month::text, 2, '0'))`.
> 4. Check existence: `SELECT 1 FROM pg_class WHERE relname = partition_name`.
> 5. If not exists: `EXECUTE FORMAT('CREATE TABLE %I PARTITION OF ...')`.

> 📚 **Concept:** Auto-provisioning partitions is essential for time-series workloads — you can't manually create 12 partitions per year forever. This procedure is called from an Airflow DAG or pg_cron job before each monthly load. `LPAD` ensures consistent naming (`fpv_2024_01`, not `fpv_2024_1`). `pg_class.relname` is the catalog for table/partition names. This is a core data engineering pattern for maintaining long-running partitioned tables.
> 🐘 **PG Ref:** [pg_class](https://www.postgresql.org/docs/current/catalog-pg-class.html) | [pg_cron](https://github.com/citusdata/pg_cron)
> 🔬 **DS Equivalent:** Auto-scaling Airflow DAG that creates new data lake partitions: `s3://bucket/year=2024/month=01/` — the same "ensure partition exists before loading" pattern.

---

### Q9. Logical Replication Preparation: Publication and Slot
Set up logical replication on `fact_patient_visits` for CDC: create a PUBLICATION, verify the replication slot configuration, and show what a subscriber would receive.

> 🔍 **Hint:** `CREATE PUBLICATION pub_visits FOR TABLE fact_patient_visits`; check `pg_publication`, `pg_stat_replication`.

> 🪜 **Steps:**
> 1. Set `wal_level = logical` in postgresql.conf (requires restart).
> 2. `CREATE PUBLICATION pub_hospital_facts FOR TABLE fact_patient_visits, fact_staffing, fact_financials`.
> 3. On subscriber: `CREATE SUBSCRIPTION sub_hospital_facts CONNECTION '...' PUBLICATION pub_hospital_facts`.
> 4. Verify: `SELECT * FROM pg_stat_replication` — shows connected subscribers.
> 5. Monitor lag: `sent_lsn - replay_lsn` in `pg_stat_replication`.

> 📚 **Concept:** Logical replication enables row-level change streaming from PostgreSQL — the foundation of CDC (Change Data Capture) pipelines. Publications define which tables are replicated. Subscriptions receive the changes on another database or are consumed by Debezium to produce Kafka messages. This is how real-time data pipelines work: `PostgreSQL → Debezium → Kafka → Flink/Spark → Data Lake`. Understanding the PostgreSQL side (publications, WAL, replication slots) is essential for data engineers building modern pipelines.
> 🐘 **PG Ref:** [Logical replication](https://www.postgresql.org/docs/current/logical-replication.html) | [pg_stat_replication](https://www.postgresql.org/docs/current/monitoring-stats.html#MONITORING-PG-STAT-REPLICATION-VIEW)
> 🔬 **DS Equivalent:** An event stream source in a streaming ML pipeline — PostgreSQL logical replication is the data source; Kafka is the transport; Flink is the real-time feature computation.

---

### Q10. Complete Performance Regression Test Suite
Create a stored procedure `sp_run_benchmark()` that runs 5 key queries (with and without indexes) and logs execution time to a `perf_benchmark` table. Use `clock_timestamp()` for precise timing.

> 🔍 **Hint:** `DECLARE t_start TIMESTAMP; t_start := clock_timestamp(); EXECUTE 'SELECT ...'; INSERT INTO perf_benchmark(query_name, duration_ms) VALUES ('4-table join', EXTRACT(MILLISECONDS FROM clock_timestamp() - t_start))`.

> 🪜 **Steps:**
> 1. Create `perf_benchmark (run_id SERIAL, query_name VARCHAR, duration_ms NUMERIC, run_at TIMESTAMP DEFAULT NOW())`.
> 2. For each benchmark query: capture `clock_timestamp()` before, execute, capture after.
> 3. Calculate: `EXTRACT(EPOCH FROM (t_end - t_start)) * 1000` milliseconds.
> 4. INSERT result into `perf_benchmark`.
> 5. After creating/dropping indexes, re-run and compare.

> 📚 **Concept:** `clock_timestamp()` returns the actual wall-clock time — it changes between calls within a transaction (unlike `NOW()` which is constant within a transaction). A performance regression test suite detects when schema changes or new indexes accidentally degrade query performance. This is the SQL equivalent of unit tests for performance — run it after every migration to catch regressions before production deployment.
> 🐘 **PG Ref:** [clock_timestamp()](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-CURRENT)
> 🔬 **DS Equivalent:** `pytest-benchmark` in Python — automated benchmarking that tracks performance across code changes. The `perf_benchmark` table is the CI/CD benchmark history for database queries.

---

## 🔴 Advanced

---

### Q1. Full Partitioned Table Migration
Migrate the existing `fact_patient_visits` (unpartitioned) to `fact_patient_visits_p` (range-partitioned by year). Strategy: (1) create partitioned table with same structure, (2) copy data in batches with minimal lock, (3) rename tables atomically, (4) verify row counts.

> 🔍 **Hint:** Concepts: CTAS for partitioned table structure, batch INSERT with range filter, `BEGIN; ALTER TABLE RENAME; ALTER TABLE RENAME; COMMIT;` for atomic swap.

> 🪜 **Steps:**
> 1. Create `fact_patient_visits_new PARTITION BY RANGE (arrival_datetime)`.
> 2. Create all year partitions.
> 3. Batch copy: `INSERT INTO fact_patient_visits_new SELECT * FROM fact_patient_visits WHERE arrival_datetime BETWEEN '2021-01-01' AND '2022-01-01'` — repeat per year.
> 4. `BEGIN; ALTER TABLE fact_patient_visits RENAME TO fact_patient_visits_old; ALTER TABLE fact_patient_visits_new RENAME TO fact_patient_visits; COMMIT;`.
> 5. Verify counts: `SELECT COUNT(*) FROM fact_patient_visits_old` = `SELECT COUNT(*) FROM fact_patient_visits`.

> 📚 **Concept:** Zero-downtime table migrations require: (1) build the new structure while the old is live, (2) copy data (may take hours for large tables), (3) brief lock for atomic rename swap. Steps 1-2 don't require locks. Step 4 takes a brief ACCESS EXCLUSIVE lock (milliseconds). Applications see the new partitioned table immediately after the rename. This is the "blue-green deployment" pattern for database schema changes.
> 🐘 **PG Ref:** [Online schema changes](https://www.postgresql.org/docs/current/ddl-partitioning.html)
> 🔬 **DS Equivalent:** Blue-green deployment for ML models — new model runs in shadow mode, then atomic swap from old to new with no downtime.

---

### Q2. Full Audit System with Row Versioning
Implement a complete audit system: (1) audit table with old/new values stored as JSONB, (2) AFTER UPDATE OR DELETE trigger, (3) function to retrieve full history of any row, (4) function to restore a deleted row from audit.

> 🔍 **Hint:** `CREATE TABLE audit_trail (audit_id SERIAL, table_name VARCHAR, operation VARCHAR, old_data JSONB, new_data JSONB, changed_by TEXT DEFAULT CURRENT_USER, changed_at TIMESTAMP DEFAULT NOW())`. Trigger: `INSERT INTO audit_trail VALUES(TG_TABLE_NAME, TG_OP, row_to_json(OLD), row_to_json(NEW))`.

> 🪜 **Steps:**
> 1. Create `audit_trail` with JSONB columns for old/new row snapshots.
> 2. Trigger function: `row_to_json(OLD)::jsonb` and `row_to_json(NEW)::jsonb` for full row capture.
> 3. Attach trigger: AFTER UPDATE OR DELETE FOR EACH ROW.
> 4. Restore function: `INSERT INTO dim_hospital SELECT (jsonb_populate_record(null::dim_hospital, old_data)).* FROM audit_trail WHERE ...`.

> 📚 **Concept:** `row_to_json(OLD)::jsonb` serialises an entire row as JSONB — every column and value captured in one flexible structure. `jsonb_populate_record(null::tabletype, jsonb)` deserialises JSONB back into a typed record. This JSONB-based audit trail works even as table columns are added/removed — the JSON captures the schema at the time of the change. Combined with `CURRENT_USER`, this provides a legally defensible audit trail for HIPAA/GDPR compliance.
> 🐘 **PG Ref:** [row_to_json](https://www.postgresql.org/docs/current/functions-json.html) | [jsonb_populate_record](https://www.postgresql.org/docs/current/functions-json.html)
> 🔬 **DS Equivalent:** Event sourcing with full state snapshots — every database row change is a serialised event. Reconstruction of state at any point in time = replay all events up to that timestamp.

---

### Q3. pg_cron: Schedule Automated Database Jobs
Install `pg_cron`. Schedule: (1) daily `VACUUM ANALYZE fact_patient_visits` at 2am, (2) weekly materialized view refresh on Sunday, (3) monthly partition creation on the 1st of each month.

> 🔍 **Hint:** `SELECT cron.schedule('nightly-vacuum', '0 2 * * *', 'VACUUM ANALYZE fact_patient_visits'); SELECT cron.schedule('weekly-refresh', '0 3 * * 0', 'REFRESH MATERIALIZED VIEW CONCURRENTLY mv_hospital_scorecard')`.

> 🪜 **Steps:**
> 1. `CREATE EXTENSION pg_cron` (requires superuser).
> 2. Schedule vacuum: `cron.schedule(name, cron_expression, sql_command)`.
> 3. Schedule weekly refresh with CONCURRENTLY.
> 4. Schedule monthly partition creation: `CALL sp_ensure_partition(EXTRACT(YEAR FROM NOW())::int, EXTRACT(MONTH FROM NOW()+INTERVAL '1 month')::int)`.
> 5. Verify: `SELECT * FROM cron.job` — view all scheduled jobs.

> 📚 **Concept:** `pg_cron` is a PostgreSQL extension running cron-style scheduled SQL jobs inside the database — no external scheduler needed. Cron expressions: `'0 2 * * *'` = 2am daily, `'0 3 * * 0'` = 3am every Sunday, `'0 0 1 * *'` = midnight on the 1st of each month. For production: combine with monitoring (`cron.job_run_details` table) to alert on failures. Alternative to: Airflow (for simple database-only tasks), custom shell scripts (which require OS access).
> 🐘 **PG Ref:** [pg_cron](https://github.com/citusdata/pg_cron) | [cron.job_run_details](https://github.com/citusdata/pg_cron#viewing-active-jobs)
> 🔬 **DS Equivalent:** Airflow DAG with `schedule_interval='@daily'` — pg_cron is the in-database scheduler; Airflow is the external orchestration equivalent for more complex pipelines.

---

## ⚫ Expert

---

### Q1. Connection Pooling: PgBouncer Configuration Analysis
Write a monitoring query that identifies connection pressure: active connections, waiting connections, idle connections, max connections. Calculate what PgBouncer pool sizes should be based on current load.

> 🔍 **Hint:** `pg_stat_activity` for active connections; `pg_settings WHERE name = 'max_connections'`; calculate pool ratio.

> 🪜 **Steps:**
> 1. `SELECT state, COUNT(*) FROM pg_stat_activity GROUP BY state` — active/idle/idle in transaction/waiting.
> 2. `SELECT setting::int AS max_conn FROM pg_settings WHERE name = 'max_connections'`.
> 3. Recommendation: PgBouncer pool_size = `max_connections * 0.9 / number_of_apps`.
> 4. Identify long-running idle connections: `WHERE state = 'idle' AND query_start < NOW() - INTERVAL '5 minutes'`.
> 5. Identify blocked queries: `WHERE wait_event_type = 'Lock'`.

> 📚 **Concept:** PostgreSQL spawns a new OS process per connection — each connection uses ~5–10MB RAM. 500 connections = 2.5–5GB just for connection overhead, before any queries run. PgBouncer pools connections in transaction mode: 500 application connections map to 50 actual PostgreSQL connections. `pg_stat_activity.wait_event_type = 'Lock'` identifies blocked queries — a sign of lock contention. Tuning `max_connections` + PgBouncer is the single highest-impact configuration change for PostgreSQL production deployments.
> 🐘 **PG Ref:** [pg_stat_activity](https://www.postgresql.org/docs/current/monitoring-stats.html#MONITORING-PG-STAT-ACTIVITY-VIEW) | [Connection limits](https://www.postgresql.org/docs/current/runtime-config-connection.html)
> 🔬 **DS Equivalent:** Thread pool sizing in a Python service — too many threads (connections) = context switching overhead; too few = queue backup. PgBouncer is the connection pool equivalent of Python's `ThreadPoolExecutor` or `asyncio` task limiting.

---

### Q2. Query Rewriting with Partition Pruning Verification
Take a complex analytical query that spans 5 years of `fact_patient_visits` but only needs 2023 data. Verify partition pruning is active. Force disable it. Measure the difference. Identify common mistakes that defeat pruning.

> 🔍 **Hint:** Partition pruning is defeated by: `WHERE EXTRACT(YEAR FROM arrival_datetime) = 2023` (function on column), `WHERE arrival_datetime::date = ...` (casting). Preserved by: `WHERE arrival_datetime >= '2023-01-01' AND arrival_datetime < '2024-01-01'`.

> 🪜 **Steps:**
> 1. Query 1 (pruning works): `WHERE arrival_datetime >= '2023-01-01' AND arrival_datetime < '2024-01-01'`.
> 2. Query 2 (pruning defeated): `WHERE EXTRACT(YEAR FROM arrival_datetime) = 2023`.
> 3. EXPLAIN both — Query 1 shows 1 partition; Query 2 shows all partitions.
> 4. `SET constraint_exclusion = off` — disable pruning entirely, compare.
> 5. Document: which functions/expressions defeat pruning on your partition key.

> 📚 **Concept:** Partition pruning requires the WHERE clause to operate directly on the partition key without transformation. Wrapping the partition key in a function (`EXTRACT`, `CAST`, `DATE_TRUNC`) hides the value from the pruning logic — PostgreSQL scans all partitions. This is the single most common mistake in partitioned table queries. The fix: compare the raw column to a date literal range. Expression indexes on `EXTRACT(YEAR FROM arrival_datetime)` enable index use but do NOT enable partition pruning.
> 🐘 **PG Ref:** [Partition pruning](https://www.postgresql.org/docs/current/ddl-partitioning.html#DDL-PARTITIONING-PRUNING)
> 🔬 **DS Equivalent:** Predicate pushdown in Parquet/Iceberg — reading only matching row groups. The same "don't wrap your partition column in a function" rule applies to Spark, Trino, and BigQuery partition filters.

---

### Q3. Complete Database Health Dashboard Query
Write a single comprehensive SQL query (using CTEs) that produces a complete database health dashboard: table sizes, index hit ratios, cache hit ratios, slowest queries (pg_stat_statements), table bloat estimates, and replication lag (if applicable).

> 🔍 **Hint:** CTEs combining: `pg_stat_user_tables`, `pg_stat_user_indexes`, `pg_stat_bgwriter`, `pg_stat_statements`, `pg_database`, `pg_replication_slots`.

> 🪜 **Steps:**
> 1. CTE `table_sizes`: `SELECT relname, pg_size_pretty(pg_total_relation_size(relid)) FROM pg_stat_user_tables`.
> 2. CTE `cache_hit`: `SELECT sum(heap_blks_hit)/(sum(heap_blks_hit)+sum(heap_blks_read)) AS cache_ratio FROM pg_statio_user_tables`.
> 3. CTE `index_efficiency`: `SELECT indexrelname, idx_scan, idx_tup_read, idx_tup_fetch FROM pg_stat_user_indexes`.
> 4. CTE `slow_queries`: from `pg_stat_statements ORDER BY mean_exec_time DESC LIMIT 5`.
> 5. Final: `SELECT * FROM table_sizes, cache_hit, (SELECT ...) AS summary` — one combined health report.

> 📚 **Concept:** A database health dashboard in SQL — the DBA's "one-stop report". Cache hit ratio > 99% indicates hot data is in shared_buffers (RAM). Index hit ratio > 95% indicates queries are using indexes effectively. Table bloat (n_dead_tup / n_live_tup > 10%) signals VACUUM is needed. Replication lag (`sent_lsn - flush_lsn`) in `pg_stat_replication` shows how far behind read replicas are. Knowing how to build this query from scratch demonstrates deep operational PostgreSQL knowledge.
> 🐘 **PG Ref:** [pg_statio_user_tables](https://www.postgresql.org/docs/current/monitoring-stats.html#MONITORING-PG-STATIO-ALL-TABLES-VIEW) | [pg_stat_bgwriter](https://www.postgresql.org/docs/current/monitoring-stats.html#MONITORING-PG-STAT-BGWRITER-VIEW)
> 🔬 **DS Equivalent:** An MLOps monitoring dashboard: model performance metrics, feature drift scores, prediction latency, error rates — all in one report. The database health dashboard is the operations equivalent.

---

## 💎 Super Expert
> No questions. These are curated topics to make you a world-class PostgreSQL practitioner.

---

### 🚀 What to Master After Phase 7

**1. Citus: PostgreSQL Horizontal Sharding**
Citus converts PostgreSQL into a distributed database — spreading rows across multiple nodes by a distribution column (e.g., `hospital_id`). Queries run in parallel across all shards. `fact_patient_visits` distributed by `hospital_id` with `dim_hospital` as a reference table (replicated to all nodes) — JOINs on `hospital_id` run locally on each shard. When: your database has outgrown a single server (>1TB, >10K queries/sec). Why you stand out: Citus is used by Microsoft Azure Database for PostgreSQL — understanding it bridges SQL expertise and distributed systems engineering.

**2. Logical Replication + Debezium for Real-Time Pipelines**
PostgreSQL WAL → Debezium (CDC connector) → Apache Kafka → Apache Flink (stream processing) → Delta Lake / Elasticsearch. Each row INSERT/UPDATE/DELETE in PostgreSQL becomes a Kafka message in milliseconds. Flink processes the stream: joins, aggregations, ML scoring. Delta Lake or Iceberg stores the results. This is the modern "Lambda architecture" replacement — pure streaming, no batch. Understanding PostgreSQL WAL and logical replication is the entry point to this entire pipeline architecture.

**3. pg_partman: Automated Partition Management**
`pg_partman` automates everything from Phase 7 Medium Hard Q8: creates time-based partitions automatically, retains a configurable number of active partitions, moves old ones to a "retention" schema for archival, drops extremely old ones. Configuration: `SELECT partman.create_parent('fact_patient_visits', 'arrival_datetime', 'native', 'monthly')`. When: any partitioned table that will receive data indefinitely. Why: never manually manage partition creation again.

**4. Query Performance with Actual Execution Statistics**
Beyond `EXPLAIN ANALYZE`: `auto_explain` extension logs slow queries with full execution plans automatically. `pg_stat_monitor` (PgBouncer-compatible alternative to `pg_stat_statements`) tracks: query plans, histogram of execution times, client application source, and includes p99/p95 latency percentiles. For production performance engineering, these tools identify: which specific query plans are slow (not just average times), which application code paths trigger them, and which percentile of users experience latency.

**5. PostgreSQL and Machine Learning: The In-Database ML Stack**
The emerging architecture: `plpython3u` for UDF-based sklearn/XGBoost scoring → `pg_vector` extension for vector similarity search (storing and querying embedding vectors for LLM-based features) → `timescaledb` for ML feature time-series → `madlib` for in-database model training. For healthcare: patient risk models scoring at INSERT time (BEFORE trigger calling `plpython3u` UDF), drug-drug interaction search via vector similarity (pg_vector), real-time anomaly detection via streaming SQL. This stack eliminates the data export bottleneck entirely.

**6. PostgreSQL in the Modern Data Stack**
The complete data stack: PostgreSQL (OLTP source) → Fivetran/Debezium (EL) → Snowflake/BigQuery/Databricks (cloud warehouse) → dbt (transformation) → Metabase/Looker (BI). OR: PostgreSQL → Airbyte (EL) → Apache Iceberg on S3 (storage) → Trino/Spark SQL (query) → dbt on Spark (transformation). Understanding PostgreSQL deeply — its WAL, replication, indexes, partitioning — makes you the expert who bridges the source database and the entire downstream stack. That T-shaped knowledge (deep in one tool, broad across the stack) is what makes a world-class data engineer in 2025.

**7. Observability: OpenTelemetry + PostgreSQL**
Modern database observability: `otel_fdw` or application-level tracing that correlates individual SQL queries to distributed traces. When a user reports "the dashboard is slow", OpenTelemetry traces show exactly which SQL query took 3 seconds, in which microservice, triggered by which user action. Combined with `pg_stat_statements` and `auto_explain`, this is full-stack database observability. The era of isolated database monitoring is over — queries must be traceable through the entire application stack.
