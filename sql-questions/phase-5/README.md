# 📒 Phase 5 — Data Aggregation & Window Functions
## GROUP BY · HAVING · Aggregate Functions · Window Functions
### PostgreSQL | NHS Hospital Analytics | Data Science Perspective

---

## 📋 Phase Topics

| Group | Commands & Functions |
|---|---|
| Aggregation | `COUNT`, `SUM`, `AVG`, `MAX`, `MIN`, `COUNT(DISTINCT)`, `STRING_AGG`, `ARRAY_AGG` |
| Grouping | `GROUP BY`, `HAVING`, `ROLLUP`, `CUBE`, `GROUPING SETS`, `FILTER` |
| Window Basics | `OVER()`, `PARTITION BY`, `ORDER BY`, `FRAME` (`ROWS BETWEEN`, `RANGE BETWEEN`) |
| Ranking | `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `NTILE()`, `PERCENT_RANK()`, `CUME_DIST()` |
| Value Windows | `LAG()`, `LEAD()`, `FIRST_VALUE()`, `LAST_VALUE()`, `NTH_VALUE()` |
| Aggregate Windows | `SUM() OVER`, `AVG() OVER`, `COUNT() OVER`, `MAX() OVER`, `MIN() OVER` |

---

## 🟢 Beginner

---

### Q1. Total Visits and Unique Patients
From `fact_patient_visits`, count total visits and count of distinct patients.
> 🔍 **Hint:** `COUNT(*)` for total visits, `COUNT(DISTINCT patient_id)` for unique patients.
> 📚 **Concept:** `COUNT(*)` counts all rows including NULLs. `COUNT(column)` counts non-NULL values. `COUNT(DISTINCT column)` counts unique non-NULL values. On large tables, `COUNT(DISTINCT)` is expensive — it requires deduplication. Approximate counts using `approx_count_distinct` or HyperLogLog extensions are faster at the cost of slight inaccuracy.
> 🐘 **PG Ref:** [Aggregate functions](https://www.postgresql.org/docs/current/functions-aggregate.html)
> 🔬 **DS Equivalent:** `len(df)`, `df['patient_id'].nunique()` — total vs unique counts in pandas.

---

### Q2. Total Revenue by Hospital
From `fact_financials`, calculate total `revenue` per `hospital_id`. Show top 10 by total revenue.
> 🔍 **Hint:** `GROUP BY hospital_id`, `SUM(revenue)`, `ORDER BY ... DESC LIMIT 10`.
> 📚 **Concept:** `GROUP BY` collapses rows with the same value into one row. All columns in SELECT must either be in GROUP BY or be wrapped in an aggregate function. Violation is a SQL error in PostgreSQL (stricter than MySQL which silently picks arbitrary values). The query execution order: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT.
> 🐘 **PG Ref:** [GROUP BY](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-GROUP)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id')['revenue'].sum().nlargest(10)` in pandas.

---

### Q3. Average Wait Time per Admission Type
From `fact_patient_visits`, find the average `wait_time_minutes` per `admission_type`. Round to 2 decimal places.
> 🔍 **Hint:** `GROUP BY admission_type`, `ROUND(AVG(wait_time_minutes), 2)`.
> 📚 **Concept:** `AVG` ignores NULLs — if 30% of wait times are NULL, AVG computes over the non-NULL 70%. This can distort results. Check null rates first: `COUNT(*) - COUNT(wait_time_minutes)` = NULL count. For NULL-aware mean: `SUM(COALESCE(wait_time_minutes, 0)) / COUNT(*)` (treats NULLs as 0, changes interpretation).
> 🐘 **PG Ref:** [AVG](https://www.postgresql.org/docs/current/functions-aggregate.html)
> 🔬 **DS Equivalent:** `df.groupby('admission_type')['wait_time_minutes'].mean().round(2)` — note pandas also skips NaN in mean by default.

---

### Q4. Max and Min Severity per Department
From `fact_patient_visits`, show `department_id`, maximum and minimum `severity_level`. Filter departments with more than 100 visits.
> 🔍 **Hint:** `GROUP BY department_id`, `MAX`, `MIN`, `HAVING COUNT(*) > 100`.
> 📚 **Concept:** `HAVING` filters AFTER aggregation — it can reference aggregate results. `WHERE` filters BEFORE aggregation — it cannot reference aggregates. Common error: `WHERE COUNT(*) > 100` — this fails. Must be `HAVING COUNT(*) > 100`. Use WHERE for row-level filters, HAVING for group-level filters.
> 🐘 **PG Ref:** [HAVING](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-HAVING)
> 🔬 **DS Equivalent:** `df.groupby('department_id').agg(max_sev=('severity_level','max'), min_sev=('severity_level','min')).query('size > 100')` in pandas (using filter after groupby).

---

### Q5. ROW_NUMBER for Visit Ranking per Patient
From `fact_patient_visits`, assign a row number to each visit per patient, ordered by `arrival_datetime` ascending. Show `patient_id`, `visit_id`, `arrival_datetime`, `row_num`.
> 🔍 **Hint:** `ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY arrival_datetime)`.
> 📚 **Concept:** Window functions compute a value for each row RELATIVE to a window of rows, without collapsing rows (unlike GROUP BY). `PARTITION BY` divides rows into groups. `ORDER BY` defines the ordering within each partition. `ROW_NUMBER` assigns 1,2,3,... uniquely — even for ties. Execution order: window functions run AFTER WHERE, GROUP BY, and HAVING — but BEFORE the outer ORDER BY.
> 🐘 **PG Ref:** [Window functions](https://www.postgresql.org/docs/current/tutorial-window.html)
> 🔬 **DS Equivalent:** `df.groupby('patient_id').cumcount() + 1` or `df.groupby('patient_id')['arrival_datetime'].rank(method='first').astype(int)` in pandas.

---

### Q6. RANK vs DENSE_RANK for Hospital Revenue
From `fact_financials`, rank hospitals by total revenue using both `RANK()` and `DENSE_RANK()`. Show where they differ (ties).
> 🔍 **Hint:** `RANK() OVER (ORDER BY SUM(revenue) DESC)` — note: window functions can use aggregates if the outer query is grouped, or use a subquery.
> 📚 **Concept:** `RANK()`: ties get the same rank; the next rank skips numbers (1,1,3). `DENSE_RANK()`: ties get the same rank; the next rank does NOT skip (1,1,2). `ROW_NUMBER()`: always unique — no ties. For leaderboards: RANK if gap matters, DENSE_RANK if you just want position. In competitive analytics, DENSE_RANK is usually preferred for user-facing rankings.
> 🐘 **PG Ref:** [Ranking functions](https://www.postgresql.org/docs/current/functions-window.html)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id')['revenue'].sum().rank(method='min')` for RANK; `method='dense'` for DENSE_RANK in pandas.

---

### Q7. Running Total of Treatment Costs per Hospital
From `fact_patient_visits`, compute a running (cumulative) total of `treatment_cost` per `hospital_id`, ordered by `arrival_datetime`. Show `visit_id`, `treatment_cost`, `running_total`.
> 🔍 **Hint:** `SUM(treatment_cost) OVER (PARTITION BY hospital_id ORDER BY arrival_datetime)`.
> 📚 **Concept:** A window aggregate with PARTITION BY + ORDER BY and no explicit FRAME computes a running aggregate. The default frame is `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. Running totals are used in financial cumulative P&L, patient admission counts, and KPI dashboards. The window function computes without collapsing rows — unlike GROUP BY.
> 🐘 **PG Ref:** [Window function frame](https://www.postgresql.org/docs/current/sql-expressions.html#SYNTAX-WINDOW-FUNCTIONS)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id')['treatment_cost'].cumsum()` in pandas — cumulative sum per group.

---

### Q8. LAG: Month-over-Month Revenue Change
From `fact_financials`, use `LAG` to compute the previous month's revenue for each hospital, and calculate the change. Show `hospital_id`, `year_int`, `month_name`, `revenue`, `prev_revenue`, `change`.
> 🔍 **Hint:** `LAG(revenue, 1) OVER (PARTITION BY hospital_id ORDER BY year_int, month_name)`.
> 📚 **Concept:** `LAG(col, offset, default)` returns the value from `offset` rows before the current row within the partition. `LEAD` does the same but looks forward. The optional `default` parameter fills in for rows with no prior/next value (e.g., first row of each partition). LAG/LEAD power time-series analysis: month-over-month, week-over-week comparisons without self-joins.
> 🐘 **PG Ref:** [LAG/LEAD](https://www.postgresql.org/docs/current/functions-window.html)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id')['revenue'].shift(1)` — pandas `.shift(1)` is LAG(1).

---

### Q9. NTILE for Patient Wait Time Quartiles
From `fact_patient_visits`, divide patients into 4 quartiles by `wait_time_minutes` using NTILE. Show `visit_id`, `wait_time_minutes`, `quartile`.
> 🔍 **Hint:** `NTILE(4) OVER (ORDER BY wait_time_minutes)`.
> 📚 **Concept:** `NTILE(n)` divides rows into n equally-sized buckets (as equal as possible). Useful for quartile/decile/percentile analysis. Note: NTILE assigns approximate equal-sized groups — it doesn't guarantee equal counts if n doesn't divide evenly into total rows. For exact percentile values (P25, P50, P75), use `PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY col)`.
> 🐘 **PG Ref:** [NTILE](https://www.postgresql.org/docs/current/functions-window.html)
> 🔬 **DS Equivalent:** `pd.qcut(df['wait_time_minutes'], q=4, labels=[1,2,3,4])` — quantile-based discretisation in pandas.

---

### Q10. FIRST_VALUE and LAST_VALUE for Shift Boundaries
From `fact_staffing`, for each `hospital_id`, show the first and last `shift_date` in the dataset using `FIRST_VALUE` and `LAST_VALUE`.
> 🔍 **Hint:** `FIRST_VALUE(shift_date) OVER (PARTITION BY hospital_id ORDER BY shift_date)` and `LAST_VALUE(shift_date) OVER (PARTITION BY hospital_id ORDER BY shift_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)`.
> 📚 **Concept:** `LAST_VALUE` with the default frame only looks at rows up to the current row — not the full partition. To get the true last value, you MUST specify `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`. This is the most common `LAST_VALUE` gotcha. `FIRST_VALUE` doesn't have this issue because the default frame always starts from the beginning.
> 🐘 **PG Ref:** [FIRST_VALUE / LAST_VALUE](https://www.postgresql.org/docs/current/functions-window.html)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id')['shift_date'].agg(['min','max'])` — first and last values per group.

---

### Q11. Count of Visits per Month Across All Hospitals
From `fact_patient_visits`, count visits per `month_name` across all hospitals. Show `month_name`, `visit_count`, ordered by `month_name`.
> 🔍 **Hint:** `GROUP BY month_name`, `COUNT(*)`, `ORDER BY month_name`.
> 📚 **Concept:** Simple single-column GROUP BY + COUNT is the most basic aggregation. Always pair GROUP BY with meaningful ORDER BY. Month-level aggregation is the foundation of seasonal demand analysis — a core operational analytics pattern. Combine with CASE WHEN to label month numbers as names.
> 🐘 **PG Ref:** [GROUP BY](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-GROUP)
> 🔬 **DS Equivalent:** `df.groupby('month_name').size()` in pandas.

---

### Q12. String Aggregation of Chronic Conditions per Risk Category
From `dim_patient`, for each `risk_category`, list all distinct `chronic_conditions` values concatenated as a comma-separated string.
> 🔍 **Hint:** `STRING_AGG(DISTINCT chronic_conditions, ', ' ORDER BY chronic_conditions)`, GROUP BY `risk_category`.
> 📚 **Concept:** `STRING_AGG(expr, delimiter)` concatenates values with a separator. The `DISTINCT` modifier deduplicates, and `ORDER BY` inside STRING_AGG controls concatenation order. `ARRAY_AGG` is the array equivalent — returns `ARRAY[val1, val2, ...]` instead of a string. String aggregation is useful for building comma-separated lists without application-layer processing.
> 🐘 **PG Ref:** [STRING_AGG](https://www.postgresql.org/docs/current/functions-aggregate.html)
> 🔬 **DS Equivalent:** `df.groupby('risk_category')['chronic_conditions'].apply(lambda x: ', '.join(sorted(x.dropna().unique())))` in pandas.

---

## 🟡 Medium
> 2–3 tables · Multiple aggregate concepts

---

### Q1. Hospital Scorecard with Multiple Aggregates
From `fact_patient_visits` joined with `dim_hospital`, compute per hospital: visit count, avg treatment cost, avg wait time, mortality rate (% where mortality_flag=true), readmission rate. Round all metrics to 2dp.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_hospital`. Concepts: GROUP BY + multiple aggregates, conditional aggregation for rates.

> 📚 **Concept:** Mortality rate via conditional aggregation: `ROUND(100.0 * SUM(CASE WHEN mortality_flag THEN 1 ELSE 0 END) / COUNT(*), 2)`. This is equivalent to `AVG(CASE WHEN flag THEN 1 ELSE 0 END) * 100` — more concise. Always use `100.0` (float) not `100` (integer) to prevent integer division giving 0.
> 🐘 **PG Ref:** [Conditional aggregation](https://www.postgresql.org/docs/current/functions-aggregate.html) | [FILTER clause](https://www.postgresql.org/docs/current/sql-expressions.html#SYNTAX-AGGREGATES)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id').agg(visit_count=('visit_id','count'), avg_cost=('treatment_cost','mean'), mortality_rate=('mortality_flag','mean')).assign(mortality_rate=lambda x: x['mortality_rate']*100)`.

---

### Q2. Top Doctor per Hospital by Visit Count
For each hospital, find the doctor with the most visits. Use ROW_NUMBER to rank doctors by visit count within each hospital, then filter to rank 1.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_doctor`. Concepts: ROW_NUMBER over aggregate (use subquery), PARTITION BY `hospital_id`.

> 📚 **Concept:** The "top-N per group" pattern requires a window function + filter: (1) Aggregate visits per doctor per hospital, (2) Apply `ROW_NUMBER() OVER (PARTITION BY hospital_id ORDER BY visit_count DESC)`, (3) Filter `WHERE rn = 1`. PostgreSQL requires wrapping this in a subquery or CTE because you can't filter on window function results in the same query level.
> 🐘 **PG Ref:** [Window functions in subqueries](https://www.postgresql.org/docs/current/tutorial-window.html)
> 🔬 **DS Equivalent:** `df.groupby(['hospital_id','doctor_id']).size().reset_index().sort_values('count', ascending=False).groupby('hospital_id').first()` in pandas.

---

### Q3. Month-over-Month Revenue Growth Rate
From `fact_financials`, compute month-over-month revenue growth rate: `(current - previous) / previous * 100`. Use LAG. Handle division by zero. Show `hospital_id`, period, `revenue`, `prev_revenue`, `growth_pct`.

> 🔍 **Hint:** Tables: `fact_financials`. Concepts: `LAG(revenue) OVER (PARTITION BY hospital_id ORDER BY year_int, month_name)`, `NULLIF` for division safety.

> 📚 **Concept:** MoM growth: `ROUND((revenue - LAG(revenue) OVER (...)) / NULLIF(LAG(revenue) OVER (...), 0) * 100, 2)`. Computing LAG twice is inefficient — wrap in a subquery to compute LAG once, then reference it. Growth rates with LAG are a fundamental time-series feature — used in financial monitoring, patient volume tracking, and KPI dashboards.
> 🐘 **PG Ref:** [LAG function](https://www.postgresql.org/docs/current/functions-window.html)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id')['revenue'].pct_change() * 100` — pandas `.pct_change()` is LAG-based percentage change.

---

### Q4. 3-Month Rolling Average Burnout Index
From `fact_staffing`, compute a 3-month rolling average of `burnout_risk_index` per hospital. Use `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` frame specification.

> 🔍 **Hint:** Tables: `fact_staffing`. Concepts: `AVG(burnout_risk_index) OVER (PARTITION BY hospital_id ORDER BY month_name ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`.

> 📚 **Concept:** `ROWS BETWEEN n PRECEDING AND CURRENT ROW` creates a sliding window of n+1 rows. `RANGE BETWEEN` uses value-based boundaries (e.g., rows within 3 days of current value). For time-series smoothing, `ROWS BETWEEN` is typically more appropriate. The rolling average smooths spikes — a key technique in anomaly detection. First 2 months will have smaller window (fewer preceding rows available).
> 🐘 **PG Ref:** [Window frames](https://www.postgresql.org/docs/current/sql-expressions.html#SYNTAX-WINDOW-FUNCTIONS)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id')['burnout_risk_index'].rolling(3, min_periods=1).mean()` in pandas — `min_periods=1` handles the first rows with fewer than 3 preceding.

---

### Q5. Percentile Analysis of Treatment Costs
From `fact_patient_visits`, compute the 25th, 50th (median), 75th, and 90th percentile of `treatment_cost` overall and per `admission_type`.

> 🔍 **Hint:** `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY treatment_cost)` — ordered set aggregate.

> 📚 **Concept:** `PERCENTILE_CONT(p) WITHIN GROUP (ORDER BY col)` computes the p-th percentile using linear interpolation between values. `PERCENTILE_DISC` returns the nearest actual data value. Median (50th percentile) is a robust alternative to mean — unaffected by outliers. In healthcare cost analysis, median is often more informative than mean because of extreme high-cost outliers.
> 🐘 **PG Ref:** [Ordered-set aggregates](https://www.postgresql.org/docs/current/functions-aggregate.html#FUNCTIONS-ORDEREDSET-TABLE)
> 🔬 **DS Equivalent:** `df.quantile([0.25, 0.5, 0.75, 0.90])` or `df.groupby('admission_type')['treatment_cost'].describe()` which includes quartiles. `np.percentile(arr, 90)` in numpy.

---

### Q6. NTILE Deciles for Patient Wait Time Stratification
From `fact_patient_visits`, stratify patients into deciles (10 groups) by `wait_time_minutes`. Show the min, max, and avg wait time within each decile.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `NTILE(10) OVER (ORDER BY wait_time_minutes)` in a subquery, then GROUP BY decile.

> 📚 **Concept:** NTILE assigns groups, but to aggregate WITHIN each group you must wrap in a subquery (window functions cannot be in WHERE or GROUP BY of the same query). NTILE is useful for equal-sized stratification — binning a continuous variable into N equal-population groups. Unlike `pd.cut` (equal-width bins), NTILE creates equal-count bins (like `pd.qcut`).
> 🐘 **PG Ref:** [NTILE](https://www.postgresql.org/docs/current/functions-window.html)
> 🔬 **DS Equivalent:** `pd.qcut(df['wait_time_minutes'], q=10, labels=False)` then `df.groupby('decile')['wait_time_minutes'].agg(['min','max','mean'])`.

---

### Q7. GROUPING SETS for Multi-Level Aggregation
From `fact_patient_visits`, compute visit counts at three levels simultaneously: (1) per hospital + admission_type, (2) per hospital only, (3) grand total. Use GROUPING SETS.

> 🔍 **Hint:** `GROUP BY GROUPING SETS ((hospital_id, admission_type), (hospital_id), ())`.

> 📚 **Concept:** `GROUPING SETS` is a single query that produces multiple aggregation levels simultaneously — equivalent to UNION ALL of separate GROUP BY queries, but more efficient (one pass over data). `ROLLUP(a, b)` = GROUPING SETS((a,b),(a),()); `CUBE(a,b)` = all combinations. `GROUPING(col)` returns 1 for subtotal rows — useful for labeling.
> 🐘 **PG Ref:** [GROUPING SETS / ROLLUP / CUBE](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-GROUPING-SETS)
> 🔬 **DS Equivalent:** `pd.pivot_table(df, values='visit_id', index=['hospital_id','admission_type'], aggfunc='count', margins=True)` — `margins=True` adds subtotals, equivalent to ROLLUP.

---

### Q8. LEAD to Predict Next Visit Date
From `fact_patient_visits`, for each patient show: current visit date, next visit date (using LEAD), and days until next visit. Flag patients with next visit within 30 days.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `LEAD(arrival_datetime, 1) OVER (PARTITION BY patient_id ORDER BY arrival_datetime)`, date arithmetic.

> 📚 **Concept:** `LEAD(col, n, default)` returns the value `n` rows after the current row within the partition. Unlike LAG which looks back, LEAD looks forward. `days_to_next = EXTRACT(EPOCH FROM LEAD(arrival_datetime) - arrival_datetime) / 86400`. Combining LEAD with date arithmetic is the SQL equivalent of feature engineering "time to next event" — a key predictive feature in churn and readmission models.
> 🐘 **PG Ref:** [LEAD](https://www.postgresql.org/docs/current/functions-window.html)
> 🔬 **DS Equivalent:** `df.groupby('patient_id')['arrival_datetime'].shift(-1)` — pandas `.shift(-1)` is LEAD(1), negative for forward-looking.

---

### Q9. PERCENT_RANK for Doctor Salary Distribution
From `dim_doctor`, compute each doctor's salary percentile rank within their specialty. Show `doctor_name`, `specialty`, `annual_salary`, `salary_percentile`.

> 🔍 **Hint:** Tables: `dim_doctor`. Concepts: `PERCENT_RANK() OVER (PARTITION BY specialty ORDER BY annual_salary)`.

> 📚 **Concept:** `PERCENT_RANK()` returns a value between 0 and 1: `(rank - 1) / (total_rows - 1)`. Multiply by 100 for percentage. `CUME_DIST()` is similar but includes the current row: `rank / total_rows`. PERCENT_RANK is useful for showing relative position within a group — a doctor at 0.9 earns more than 90% of peers in their specialty.
> 🐘 **PG Ref:** [PERCENT_RANK / CUME_DIST](https://www.postgresql.org/docs/current/functions-window.html)
> 🔬 **DS Equivalent:** `df.groupby('specialty')['annual_salary'].rank(pct=True)` — pandas `.rank(pct=True)` computes CUME_DIST equivalent (slightly different formula from PERCENT_RANK).

---

### Q10. NTH_VALUE: Third Most Expensive Visit per Hospital
From `fact_patient_visits`, for each hospital find the 3rd most expensive visit's treatment cost using `NTH_VALUE`.

> 🔍 **Hint:** `NTH_VALUE(treatment_cost, 3) OVER (PARTITION BY hospital_id ORDER BY treatment_cost DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)`.

> 📚 **Concept:** `NTH_VALUE(col, n)` returns the value from the nth row in the window. Like `LAST_VALUE`, it requires `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` to see the full partition. Otherwise it only sees up to the current row — returning NULL for rows before position n. An alternative: use `ROW_NUMBER` and filter for `rn = 3` in a subquery.
> 🐘 **PG Ref:** [NTH_VALUE](https://www.postgresql.org/docs/current/functions-window.html)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id')['treatment_cost'].nlargest(3).groupby('hospital_id').last()` — nth largest per group using chained nlargest/last in pandas.

---

### Q11. FILTER Clause for Clean Conditional Aggregation
From `fact_patient_visits`, compute for each hospital: total visits, emergency visits only, ICU-required visits only, weekend visits (use `dim_date.is_weekend`). Use the `FILTER` clause instead of CASE WHEN.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_date`. Concepts: `COUNT(*) FILTER (WHERE condition)`.

> 📚 **Concept:** `AGG(...) FILTER (WHERE condition)` is more readable than `SUM(CASE WHEN cond THEN 1 ELSE 0 END)`. The FILTER clause is ANSI SQL standard (PostgreSQL, newer versions of others). It also works with window functions: `COUNT(*) FILTER (WHERE ...) OVER (PARTITION BY ...)`. Cleaner code, same performance.
> 🐘 **PG Ref:** [FILTER clause](https://www.postgresql.org/docs/current/sql-expressions.html#SYNTAX-AGGREGATES)
> 🔬 **DS Equivalent:** Multiple `df.groupby(...).apply(lambda g: len(g[condition]))` calls — the FILTER clause bundles all these into a single pass in SQL.

---

### Q12. ROLLUP for Monthly Revenue Subtotals
From `fact_financials` joined with `dim_hospital`, compute total revenue with subtotals: per hospital per month, per hospital (all months), and grand total. Use ROLLUP.

> 🔍 **Hint:** Tables: `fact_financials`, `dim_hospital`. Concepts: `GROUP BY ROLLUP(hospital_name, year_int, month_name)`, `GROUPING(col)` to flag subtotal rows.

> 📚 **Concept:** `ROLLUP(a, b, c)` generates groupings: (a,b,c), (a,b), (a), () — progressively rolling up from finest to coarsest grain. `GROUPING(col)` returns 1 when `col` is a subtotal placeholder (not a real group value). Use `COALESCE(hospital_name, 'ALL HOSPITALS')` to label subtotal rows. ROLLUP is the SQL equivalent of Excel PivotTable subtotals.
> 🐘 **PG Ref:** [ROLLUP](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-ROLLUP)
> 🔬 **DS Equivalent:** `pd.pivot_table(df, values='revenue', index=['hospital_name','year_int','month_name'], aggfunc='sum', margins=True)` — `margins=True` adds subtotals at each level.

---

## 🟠 Medium Hard
> Mixed phases · 2–3 tables · Steps required

---

### Q1. Gap and Island Detection: Consecutive High-Burnout Shifts
In `fact_staffing`, identify "islands" of consecutive shifts (by date) within the same hospital where `burnout_risk_index > 7`. An island is a group of consecutive high-burnout days.

> 🔍 **Hint:** Tables: `fact_staffing`. Concepts: ROW_NUMBER, DATE arithmetic, GROUP BY on island key.

> 🪜 **Steps:**
> 1. Filter: `WHERE burnout_risk_index > 7`.
> 2. Assign row numbers per hospital, ordered by `shift_date`.
> 3. Key insight: `shift_date - ROW_NUMBER() * INTERVAL '1 day'` is constant for consecutive days.
> 4. GROUP BY hospital_id + this constant → each group is one island.
> 5. Show island start/end dates, duration, average burnout.

> 📚 **Concept:** Gap-and-island is a classic SQL pattern. Consecutive rows have the property that `value - row_number = constant`. This constant groups consecutive rows into islands. Non-consecutive rows produce different constants → different groups. Used in: detecting consecutive sick days, continuous ICU stays, uninterrupted monitoring periods. Essential for longitudinal medical data analysis.
> 🐘 **PG Ref:** [Window functions advanced](https://www.postgresql.org/docs/current/tutorial-window.html)
> 🔬 **DS Equivalent:** `df['island'] = (df['date'].diff() != pd.Timedelta('1 day')).cumsum()` in pandas — cumulative sum of "gap" flags creates island IDs.

---

### Q2. Year-over-Year Hospital Performance Comparison
From `fact_financials`, compute YoY change in revenue, profit margin, and readmission rate per hospital. Use LAG with `PARTITION BY hospital_id ORDER BY year_int, month_name`.

> 🔍 **Hint:** Tables: `fact_financials`, `dim_hospital`. Concepts: LAG with offset 12 (same month last year), percentage change.

> 🪜 **Steps:**
> 1. `LAG(revenue, 12) OVER (PARTITION BY hospital_id ORDER BY year_int, month_name)` — 12 months ago (same month last year).
> 2. Revenue YoY %: `(revenue - lag_revenue) / NULLIF(lag_revenue, 0) * 100`.
> 3. Similarly for profit_margin and readmission_rate.
> 4. Join to `dim_hospital` for hospital names.
> 5. Filter to current year only for clean output.

> 📚 **Concept:** `LAG(col, 12)` retrieves the value 12 rows back — for monthly data ordered by period, this is the same month one year ago. YoY comparison is more meaningful than MoM for seasonal businesses. Using offset 12 requires exactly 12 months of data per hospital — gaps cause incorrect LAG targets. Always verify data completeness before YoY analysis.
> 🐘 **PG Ref:** [LAG with offset](https://www.postgresql.org/docs/current/functions-window.html)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id')['revenue'].shift(12)` — pandas shift by 12 periods for YoY comparison.

---

### Q3. Patient Readmission Cohort Analysis
From `fact_patient_visits`, identify patients with readmissions (2+ visits where consecutive visit gap < 30 days). Use LEAD to find next visit date, calculate gap, and flag readmissions. Count readmissions per hospital.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_hospital`. Concepts: LEAD(arrival_datetime), date arithmetic, GROUP BY hospital + COUNT.

> 🪜 **Steps:**
> 1. `LEAD(arrival_datetime) OVER (PARTITION BY patient_id ORDER BY arrival_datetime) AS next_visit_dt`.
> 2. `EXTRACT(EPOCH FROM next_visit_dt - arrival_datetime) / 86400 AS days_to_readmission`.
> 3. Flag: `CASE WHEN days_to_readmission < 30 THEN true ELSE false END`.
> 4. Group by hospital_id and count readmission flags.
> 5. Join to `dim_hospital` for context.

> 📚 **Concept:** Readmission analysis is a core healthcare quality metric. The LEAD-based approach computes "time to next event" in a single pass — no self-join needed. `days_to_readmission < 30` aligns with the standard 30-day hospital readmission metric (CMS quality measure). This feature is used in readmission prediction ML models.
> 🐘 **PG Ref:** [LEAD](https://www.postgresql.org/docs/current/functions-window.html)
> 🔬 **DS Equivalent:** `df.groupby('patient_id')['arrival_datetime'].shift(-1)` then `(next_date - current_date).dt.days < 30` — pandas approach to readmission flagging.

---

### Q4. Hospital Efficiency Benchmarking with PERCENT_RANK
From `fact_financials`, rank each hospital's `efficiency_score` relative to hospitals in the same region. Join `dim_hospital` for region context. Show: hospital name, region, efficiency score, regional percentile rank, national percentile rank.

> 🔍 **Hint:** Tables: `fact_financials`, `dim_hospital`, `dim_region`. Concepts: `PERCENT_RANK() OVER (PARTITION BY region_id ORDER BY efficiency_score)` and without PARTITION for national rank.

> 🪜 **Steps:**
> 1. Join all three tables.
> 2. Regional rank: `PERCENT_RANK() OVER (PARTITION BY dh.region_id ORDER BY ff.efficiency_score)`.
> 3. National rank: `PERCENT_RANK() OVER (ORDER BY ff.efficiency_score)` — no PARTITION BY.
> 4. Multiply by 100 for percentage.
> 5. Use `AVG(efficiency_score)` to aggregate per hospital first (multiple months in financials).

> 📚 **Concept:** Two window functions with different partitions in the same query — one regional, one national — is a common benchmarking pattern. Omitting PARTITION BY creates a window over the ENTIRE result set. This enables relative benchmarking: a hospital at the 80th percentile nationally but 40th percentile regionally may be in a high-performing region.
> 🐘 **PG Ref:** [Window function PARTITION BY](https://www.postgresql.org/docs/current/tutorial-window.html)
> 🔬 **DS Equivalent:** `df.groupby('region_id')['efficiency_score'].rank(pct=True)` for regional, `df['efficiency_score'].rank(pct=True)` for national — two separate rank computations in pandas.

---

### Q5. Anomaly Detection: Z-Score per Department
From `fact_patient_visits`, compute the Z-score of `wait_time_minutes` per department: `(value - mean) / stddev`. Flag visits more than 2 standard deviations from the department mean.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `AVG(wait_time_minutes) OVER (PARTITION BY department_id)`, `STDDEV(wait_time_minutes) OVER (PARTITION BY department_id)`, arithmetic.

> 🪜 **Steps:**
> 1. `dept_mean = AVG(wait_time_minutes) OVER (PARTITION BY department_id)`.
> 2. `dept_stddev = STDDEV(wait_time_minutes) OVER (PARTITION BY department_id)`.
> 3. `z_score = (wait_time_minutes - dept_mean) / NULLIF(dept_stddev, 0)`.
> 4. Flag: `ABS(z_score) > 2 AS is_anomaly`.
> 5. Wrap in subquery (window functions can't be referenced in WHERE directly).

> 📚 **Concept:** Z-score normalisation in SQL using window functions is a powerful anomaly detection technique. `STDDEV()` computes population standard deviation (use `STDDEV_SAMP()` for sample). Window function Z-scores compute relative to each department's distribution — much more meaningful than global Z-scores when departments have very different wait time baselines.
> 🐘 **PG Ref:** [Statistical aggregates](https://www.postgresql.org/docs/current/functions-aggregate.html#FUNCTIONS-AGGREGATE-STATISTICS-TABLE)
> 🔬 **DS Equivalent:** `from scipy import stats; df.groupby('department_id')['wait_time_minutes'].transform(lambda x: stats.zscore(x, ddof=0))` in pandas — per-group Z-score.

---

### Q6. Histogram of Treatment Costs using width_bucket
From `fact_patient_visits`, build a histogram of `treatment_cost` with 10 equal-width bins between 0 and 10000. Show bucket number, range, and count.

> 🔍 **Hint:** `width_bucket(treatment_cost, 0, 10000, 10)` — PostgreSQL bucket function.

> 🪜 **Steps:**
> 1. `SELECT width_bucket(treatment_cost, 0, 10000, 10) AS bucket, COUNT(*) FROM fact_patient_visits WHERE treatment_cost BETWEEN 0 AND 10000 GROUP BY bucket ORDER BY bucket`.
> 2. Compute bucket range: `(bucket - 1) * 1000 || '–' || bucket * 1000 AS range_label`.
> 3. Handle outliers (< 0 or > 10000): `width_bucket` returns 0 or n+1 for out-of-range values.

> 📚 **Concept:** `width_bucket(val, min, max, n)` assigns each value to an equal-width bucket — equivalent to `pd.cut`. For equal-count buckets, use NTILE. Histograms in SQL enable distribution analysis without exporting data. This is a key EDA tool — understanding cost distribution guides pricing models, outlier detection thresholds, and patient cost risk stratification.
> 🐘 **PG Ref:** [width_bucket](https://www.postgresql.org/docs/current/functions-math.html)
> 🔬 **DS Equivalent:** `pd.cut(df['treatment_cost'], bins=10, include_lowest=True).value_counts().sort_index()` or `plt.hist(df['treatment_cost'], bins=10)` — pandas/matplotlib histogram.

---

### Q7. CUBE for Multi-Dimensional Financial Analysis
From `fact_financials` joined with `dim_hospital`, compute total revenue with ALL combinations of: `region_id`, `year_int`. Use CUBE. Show which cells represent subtotals using GROUPING().

> 🔍 **Hint:** Tables: `fact_financials`, `dim_hospital`. Concepts: `GROUP BY CUBE(region_id, year_int)`, `GROUPING(col)`.

> 🪜 **Steps:**
> 1. Join tables, group by `CUBE(dh.region_id, ff.year_int)`.
> 2. `GROUPING(dh.region_id)` returns 1 when region_id is a subtotal.
> 3. `GROUPING(ff.year_int)` returns 1 when year is a subtotal.
> 4. Label rows: when both = 1 → grand total; when only region = 1 → all-region year subtotal; etc.
> 5. Use COALESCE(region_id, 'ALL') to label subtotal cells.

> 📚 **Concept:** CUBE generates all 2^n combinations of GROUP BY columns. For n=2: (region, year), (region), (year), () — 4 levels. For n=3: 8 levels. This enables OLAP-style analysis: drill down from grand total to any combination. `GROUPING()` is essential to distinguish NULL group values (no data for that combination) from NULL subtotal placeholders.
> 🐘 **PG Ref:** [CUBE](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-CUBE)
> 🔬 **DS Equivalent:** `pd.pivot_table(df, values='revenue', index=['region_id'], columns=['year_int'], aggfunc='sum', margins=True)` — 2D pivot table with row/column subtotals.

---

### Q8. Funnel Analysis: Patient Journey Drop-off
From `fact_patient_visits`, compute a simplified patient journey funnel: (1) all arrivals, (2) triaged (triage_datetime IS NOT NULL), (3) treatment started (treatment_start_datetime IS NOT NULL), (4) discharged (discharge_datetime IS NOT NULL). Show counts and conversion rates at each stage.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `COUNT(*) FILTER (WHERE ...)`, percentage of total.

> 🪜 **Steps:**
> 1. Total arrivals: `COUNT(*)`.
> 2. Triaged: `COUNT(*) FILTER (WHERE triage_datetime IS NOT NULL)`.
> 3. Treatment started: `COUNT(*) FILTER (WHERE treatment_start_datetime IS NOT NULL)`.
> 4. Discharged: `COUNT(*) FILTER (WHERE discharge_datetime IS NOT NULL)`.
> 5. Conversion rates: each stage / total * 100.

> 📚 **Concept:** Funnel analysis measures drop-off at each stage of a process. In healthcare: triage rate, treatment start rate, discharge rate. In e-commerce: view → add to cart → checkout → purchase. The FILTER clause enables computing all stages in a single query. Low conversion at any stage signals an operational bottleneck — a direct input to capacity planning models.
> 🐘 **PG Ref:** [FILTER clause](https://www.postgresql.org/docs/current/sql-expressions.html#SYNTAX-AGGREGATES)
> 🔬 **DS Equivalent:** `df.agg({'triage_datetime': lambda x: x.notna().mean(), 'treatment_start_datetime': lambda x: x.notna().mean()...})` — a conversion funnel using notna().mean() in pandas.

---

### Q9. Moving Median using PERCENTILE_CONT in Window Context
From `fact_financials`, for each hospital compute a 3-month rolling median of `profit_margin`. Note: PERCENTILE_CONT is not a window function — use a self-join or CTE approach.

> 🔍 **Hint:** Tables: `fact_financials`. Concepts: Self-join for rolling window, `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ...)`.

> 🪜 **Steps:**
> 1. For each row (hospital, year, month), self-join to find rows within ±1 month.
> 2. `JOIN fact_financials ff2 ON ff1.hospital_id = ff2.hospital_id AND ff2.period IN (current, current-1, current+1)`.
> 3. Group by ff1 row, apply `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ff2.profit_margin)`.
> 4. Note: this is a simplified approach — a proper rolling median is complex in SQL.
> 5. Compare with `AVG` — median is more robust to outlier months.

> 📚 **Concept:** `PERCENTILE_CONT` is an ordered-set aggregate — not a window function. Rolling median in SQL requires a self-join to materialise the window, making it O(N²). PostgreSQL 16+ has `allow percentile functions in window context` but it's still limited. Rolling median is much simpler in pandas (`rolling().median()`). This illustrates that not all analytics are equally natural in SQL — use the right tool.
> 🐘 **PG Ref:** [Ordered-set aggregates](https://www.postgresql.org/docs/current/functions-aggregate.html#FUNCTIONS-ORDEREDSET-TABLE)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id')['profit_margin'].rolling(3, center=True, min_periods=1).median()` — pandas rolling median is one line; SQL requires a self-join.

---

### Q10. Conditional Rank: Top Hospitals by Mortality Rate (Among Those with Sufficient Volume)
From `fact_patient_visits` grouped by hospital, rank hospitals by mortality rate. Only include hospitals with at least 100 visits (low-volume hospitals have unreliable rates). Show rank, hospital name, visit count, mortality rate.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_hospital`. Concepts: Conditional aggregation, HAVING, RANK() OVER, subquery layering.

> 🪜 **Steps:**
> 1. Aggregate per hospital: `COUNT(*) AS visit_count`, mortality rate.
> 2. `HAVING COUNT(*) >= 100`.
> 3. Apply `RANK() OVER (ORDER BY mortality_rate DESC)` in an outer query.
> 4. Join to `dim_hospital` for names.
> 5. Filter to top 10.

> 📚 **Concept:** Ranking after filtering for minimum volume is the "volume-adjusted ranking" pattern — critical in healthcare quality metrics. A hospital with 2 visits and 1 death has a 50% mortality rate but is statistically meaningless. The HAVING clause filters to hospitals with sufficient volume before ranking. This is how CMS (Centers for Medicare & Medicaid Services) publicly reports hospital quality metrics.
> 🐘 **PG Ref:** [HAVING + window functions in subquery](https://www.postgresql.org/docs/current/tutorial-window.html)
> 🔬 **DS Equivalent:** `df.groupby('hospital_id').filter(lambda g: len(g) >= 100).groupby('hospital_id')['mortality_flag'].mean().rank(ascending=False)` in pandas.

---

## 🔴 Advanced

---

### Q1. Patient Lifetime Value Equivalent (Total Healthcare Cost per Patient)
From `fact_patient_visits`, compute total treatment cost per patient (their "lifetime" healthcare value to the system), their visit frequency (visits per year), and segment by NTILE quartiles. Join with `dim_patient` for demographics.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_patient`. Concepts: GROUP BY patient, SUM, COUNT/date range, NTILE(4) over aggregate.

> 🪜 **Steps:**
> 1. GROUP BY `patient_id`: `SUM(treatment_cost) AS total_cost`, `COUNT(*) AS visit_count`.
> 2. Visit span: `EXTRACT(DAYS FROM MAX(arrival_datetime) - MIN(arrival_datetime)) / 365.0 AS years_active`.
> 3. Frequency: `COUNT(*) / NULLIF(years_active, 0)`.
> 4. NTILE(4) in outer query on total_cost to segment.
> 5. JOIN to `dim_patient` for age, risk_category.

> 📚 **Concept:** Patient Lifetime Value (LTV) is the healthcare equivalent of Customer Lifetime Value (CLV) — total resource consumption over a patient's relationship with the system. High-LTV patients require case management and preventive care investment. The NTILE segmentation identifies which patients are in the top quartile of resource consumption — the classic "20% of patients consume 80% of costs" insight.
> 🐘 **PG Ref:** [Window functions over aggregated subqueries](https://www.postgresql.org/docs/current/tutorial-window.html)
> 🔬 **DS Equivalent:** CLV calculation in e-commerce: `total_spend`, `purchase_frequency`, `customer_lifespan` — all aggregated per customer, then segmented. Direct input to customer segmentation ML models (K-means, RFM analysis).

---

### Q2. Session Analysis: Visit Episodes per Patient
Group consecutive visits (within 30 days of each other) into "episodes of care" per patient. Count episodes, avg cost per episode, and flag patients with 3+ episodes.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: LAG for previous visit date, flag new session start, cumulative SUM to generate session IDs.

> 🪜 **Steps:**
> 1. `LAG(arrival_datetime) OVER (PARTITION BY patient_id ORDER BY arrival_datetime) AS prev_visit`.
> 2. `CASE WHEN prev_visit IS NULL OR days_since_prev > 30 THEN 1 ELSE 0 END AS is_new_episode`.
> 3. `SUM(is_new_episode) OVER (PARTITION BY patient_id ORDER BY arrival_datetime) AS episode_id`.
> 4. GROUP BY patient_id, episode_id: COUNT visits, SUM costs.
> 5. Outer query: GROUP BY patient_id, flag if COUNT(episodes) >= 3.

> 📚 **Concept:** Session/episode analysis is the SQL equivalent of web analytics sessionisation. The pattern: LAG to detect gaps between events → CASE to flag session starts → cumulative SUM window to assign session IDs. This three-step pattern is universal: web sessions, patient episodes, customer journeys. The result is a complete episode-level dataset ready for time-series ML modelling.
> 🐘 **PG Ref:** [Cumulative sum window](https://www.postgresql.org/docs/current/tutorial-window.html)
> 🔬 **DS Equivalent:** `df.groupby('patient_id').apply(lambda g: (g['days_gap'] > 30).cumsum())` — sessionisation in pandas using cumsum on gap flags.

---

### Q3. CUBE: Full Financial Multidimensional Report
From `fact_financials` joined with `dim_hospital` and `dim_region`, compute total revenue, avg profit margin, and readmission rate across ALL combinations of: region, year, admission type. Use CUBE(3 dimensions) for a complete OLAP cube.

> 🔍 **Hint:** Tables: `fact_financials`, `dim_hospital`, `dim_region`. Concepts: `GROUP BY CUBE(region_name, year_int, admission_type)`, GROUPING(), COALESCE labeling.

> 🪜 **Steps:**
> 1. Join all three tables.
> 2. `GROUP BY CUBE(dr.region_name, ff.year_int, fv.admission_type)` — 2^3 = 8 aggregation levels.
> 3. Use `GROUPING(col)` to identify subtotals.
> 4. Label subtotals: `CASE WHEN GROUPING(region_name) = 1 THEN 'ALL REGIONS' ELSE region_name END`.
> 5. Aggregate: SUM(revenue), AVG(profit_margin), AVG(readmission_rate).

> 📚 **Concept:** A 3-dimension CUBE generates 8 grouping levels — the full OLAP cube. This is what BI tools (Tableau, Power BI) generate internally when you add dimensions to a dashboard view. Understanding CUBE in SQL means you can reproduce ANY BI tool output directly in the database — enabling server-side aggregation that reduces data transfer and speeds up dashboards.
> 🐘 **PG Ref:** [CUBE](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-CUBE)
> 🔬 **DS Equivalent:** Multi-dimensional pandas pivot tables nested across 3 axes — equivalent to a pandas `df.pivot_table(index=[...], columns=[...], aggfunc={...})` with margins at every level.

---

### Q4. Survival Analysis Proxy: Time to First ICU Admission
From `fact_patient_visits` per patient, compute "time to first ICU admission" — days from first-ever visit to first ICU-required visit. For patients with no ICU visit, report NULL (censored). Aggregate into survival buckets.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: MIN() for first visit, MIN() filtered for first ICU, date arithmetic.

> 🪜 **Steps:**
> 1. Per patient: `MIN(arrival_datetime) AS first_visit`.
> 2. `MIN(arrival_datetime) FILTER (WHERE icu_required_flag = true) AS first_icu_visit`.
> 3. `days_to_icu = first_icu_visit - first_visit` — NULL for patients never in ICU.
> 4. Bucket: `CASE WHEN days_to_icu < 30 THEN '0–30 days' WHEN ... ELSE 'No ICU (Censored)' END`.
> 5. GROUP BY bucket, COUNT patients.

> 📚 **Concept:** Kaplan-Meier survival analysis: "time to event" with censored observations (patients who haven't experienced the event yet). The SQL proxy computes `time_to_event` with NULL for censored. For proper survival analysis, feed this into R's `survfit()` or Python's `lifelines` library. SQL handles the data preparation; statistical packages handle the analysis.
> 🐘 **PG Ref:** [MIN with FILTER](https://www.postgresql.org/docs/current/sql-expressions.html#SYNTAX-AGGREGATES)
> 🔬 **DS Equivalent:** `from lifelines import KaplanMeierFitter; kmf.fit(durations, event_observed)` — where `durations` is `days_to_icu` (NaN = censored) from the SQL output.

---

### Q5. Doctor Peer Comparison: Performance vs Department Average
For each doctor, compute their visit count, avg treatment cost, avg patient satisfaction, and compare each metric to the department average using window functions. Show deviation from mean and z-score.

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_doctor`. Concepts: AVG() OVER (PARTITION BY department_id), deviation, Z-score with STDDEV OVER.

> 🪜 **Steps:**
> 1. JOIN to `dim_doctor` for doctor names.
> 2. Per doctor: COUNT visits, AVG treatment_cost, AVG satisfaction.
> 3. Department averages via window: `AVG(avg_cost) OVER (PARTITION BY department_id)`.
> 4. Deviation: `doctor_avg - dept_avg`.
> 5. Z-score: `deviation / NULLIF(STDDEV(avg_cost) OVER (PARTITION BY department_id), 0)`.

> 📚 **Concept:** Peer comparison using window functions computes doctor-level and department-level metrics in the same query — no separate aggregation queries needed. The z-score normalises deviations by department variability — a doctor 10% above average in a low-variance department is more notable than one 10% above in a high-variance department. This is the foundation of clinical performance analytics dashboards.
> 🐘 **PG Ref:** [Statistical window functions](https://www.postgresql.org/docs/current/functions-aggregate.html#FUNCTIONS-AGGREGATE-STATISTICS-TABLE)
> 🔬 **DS Equivalent:** `df.groupby('department_id')['cost'].transform('mean')` for department averages without collapsing rows — window function equivalent in pandas.

---

## ⚫ Expert

---

### Q1. Median Absolute Deviation (MAD) for Robust Outlier Detection
Compute the Median Absolute Deviation of `treatment_cost` per hospital: `MAD = MEDIAN(ABS(xi - MEDIAN(xi)))`. Use nested PERCENTILE_CONT to implement. Flag visits where `|cost - median| > 3 * MAD`.

> 🔍 **Hint:** Concepts: Nested `PERCENTILE_CONT(0.5) WITHIN GROUP`, `ABS()`, subquery with pre-computed median, self-join or CTE.

> 🪜 **Steps:**
> 1. Compute per-hospital median in a CTE: `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY treatment_cost)`.
> 2. JOIN back to full data: compute `ABS(treatment_cost - hospital_median)` per row.
> 3. Second CTE: compute median of those absolute deviations = MAD.
> 4. Flag: `ABS(treatment_cost - median) > 3 * MAD`.

> 📚 **Concept:** MAD is a robust alternative to mean ± 2σ for outlier detection — it's resistant to outliers themselves distorting the threshold. `3 * MAD` rule catches extreme outliers. In healthcare billing fraud detection, MAD-based flagging of extreme treatment costs is more reliable than Z-score methods. Implementing in SQL via nested PERCENTILE_CONT + CTEs is a multi-step but achievable analytical pattern.
> 🐘 **PG Ref:** [PERCENTILE_CONT](https://www.postgresql.org/docs/current/functions-aggregate.html#FUNCTIONS-ORDEREDSET-TABLE)
> 🔬 **DS Equivalent:** `scipy.stats.median_abs_deviation(arr)` or `np.median(np.abs(arr - np.median(arr)))` in Python. Used in sklearn's `RobustScaler` under the hood.

---

### Q2. Correlation Analysis: Staffing and Patient Outcomes
Compute the Pearson correlation between `avg_burnout_risk_index` (from `fact_staffing`) and `avg_wait_time_minutes` (from `fact_patient_visits`) per hospital per month. Use PostgreSQL's `CORR()` aggregate.

> 🔍 **Hint:** Concepts: `CORR(y, x)` aggregate function. Join both fact tables pre-aggregated per hospital/month.

> 🪜 **Steps:**
> 1. Pre-aggregate: `fact_staffing` → avg burnout per hospital per month.
> 2. Pre-aggregate: `fact_patient_visits` → avg wait time per hospital per month.
> 3. JOIN on hospital_id + month_name.
> 4. Apply `CORR(avg_wait_time, avg_burnout)` for overall correlation.
> 5. Or: compute `CORR() OVER (PARTITION BY hospital_id)` for per-hospital rolling correlation.

> 📚 **Concept:** `CORR(y, x)` computes Pearson correlation coefficient (-1 to +1). PostgreSQL also provides `REGR_SLOPE(y, x)`, `REGR_INTERCEPT(y, x)`, `REGR_R2(y, x)` for simple linear regression — all in SQL. This enables basic statistical modelling without extracting data. A strong positive CORR(wait_time, burnout) quantifies the operational hypothesis that burnt-out staff increase wait times.
> 🐘 **PG Ref:** [Statistical aggregates — CORR](https://www.postgresql.org/docs/current/functions-aggregate.html#FUNCTIONS-AGGREGATE-STATISTICS-TABLE)
> 🔬 **DS Equivalent:** `df[['avg_burnout','avg_wait']].corr()` or `scipy.stats.pearsonr(x, y)` — correlation analysis in pandas/scipy. PostgreSQL's `CORR()` brings this into the database.

---

### Q3. WINDOW Clause for Reusable Window Definitions
Rewrite a complex query that uses the same window specification multiple times (`PARTITION BY hospital_id ORDER BY arrival_datetime`) using the WINDOW clause to define it once and reference it by name.

> 🔍 **Hint:** `SELECT ..., ROW_NUMBER() OVER w, LAG(treatment_cost) OVER w, ... FROM fact_patient_visits WINDOW w AS (PARTITION BY hospital_id ORDER BY arrival_datetime)`.

> 🪜 **Steps:**
> 1. Write a query needing 5+ window functions with the same partition/order.
> 2. Add `WINDOW w AS (PARTITION BY hospital_id ORDER BY arrival_datetime)` after FROM clause.
> 3. Reference as `OVER w` or `OVER (w ROWS BETWEEN ...)` (extending the named window).
> 4. Verify: same results as repeating the window spec inline.

> 📚 **Concept:** The `WINDOW` clause defines a named window specification — DRY (Don't Repeat Yourself) for window definitions. The named window can be extended in individual function calls: `OVER (w ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`. This makes complex analytical queries with many window functions dramatically more readable and maintainable.
> 🐘 **PG Ref:** [WINDOW clause](https://www.postgresql.org/docs/current/sql-select.html#SQL-WINDOW)
> 🔬 **DS Equivalent:** Defining a reusable transform pipeline — `pipe = Pipeline([step1, step2, ...])` in sklearn — and applying it consistently rather than redefining per output.

---

### Q4. Cohort Retention Matrix
Build a patient retention matrix: for each admission month cohort, show how many patients returned in months 1, 2, 3, and 4 after their first visit. Output as a matrix with cohort month as rows and retention periods as columns.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: ROW_NUMBER to find first visit, cohort assignment, conditional aggregation for each retention period.

> 🪜 **Steps:**
> 1. Find each patient's first visit month: `MIN(DATE_TRUNC('month', arrival_datetime)) AS cohort_month`.
> 2. For each visit, compute months since first: `EXTRACT(MONTH FROM AGE(visit_month, cohort_month))`.
> 3. FLAG visits at months 1, 2, 3, 4 with `CASE WHEN months_since = 1 THEN patient_id`.
> 4. GROUP BY cohort_month: `COUNT(DISTINCT CASE WHEN months_since = 1 THEN patient_id END) AS m1_retained`.
> 5. Divide by cohort size for retention rate.

> 📚 **Concept:** Cohort retention analysis is the cornerstone of customer (or patient) analytics. Patients who return within 1 month may indicate readmission risk; those returning at 3 months may be scheduled follow-ups. The cohort matrix shows decay of engagement over time — foundational for understanding care utilisation patterns. In e-commerce, this same analysis measures whether customers repeat-purchase.
> 🐘 **PG Ref:** [Conditional aggregation](https://www.postgresql.org/docs/current/functions-aggregate.html)
> 🔬 **DS Equivalent:** `df.pivot_table(index='cohort_month', columns='months_since', values='patient_id', aggfunc='nunique').div(cohort_sizes, axis=0)` — cohort retention matrix in pandas, visualised as a heatmap.

---

### Q5. REGR Functions for Linear Trend in Financial Data
From `fact_financials`, use `REGR_SLOPE`, `REGR_INTERCEPT`, `REGR_R2` to fit a linear trend to monthly revenue per hospital over time. Show hospitals with positive slope (growing revenue) and R² > 0.7 (good fit).

> 🔍 **Hint:** Tables: `fact_financials`. Concepts: `REGR_SLOPE(revenue, period_num)`, `REGR_R2(revenue, period_num)` — where `period_num = year_int * 12 + month_name`.

> 🪜 **Steps:**
> 1. Compute `period_num = year_int * 12 + month_name` as the numeric X variable.
> 2. `REGR_SLOPE(revenue, period_num)` as the slope per hospital.
> 3. `REGR_INTERCEPT(revenue, period_num)` as the y-intercept.
> 4. `REGR_R2(revenue, period_num)` for goodness-of-fit.
> 5. Filter: `WHERE slope > 0 AND r_squared > 0.7` for reliably growing hospitals.

> 📚 **Concept:** PostgreSQL's `REGR_*` functions implement simple linear regression as SQL aggregates. `REGR_SLOPE` = β₁, `REGR_INTERCEPT` = β₀, `REGR_R2` = coefficient of determination. R² > 0.7 indicates a good linear fit. A positive slope + high R² confirms a reliable upward trend — not just noise. This is in-database linear regression for trend detection without exporting to Python.
> 🐘 **PG Ref:** [Regression aggregates](https://www.postgresql.org/docs/current/functions-aggregate.html#FUNCTIONS-AGGREGATE-STATISTICS-TABLE)
> 🔬 **DS Equivalent:** `from sklearn.linear_model import LinearRegression; lm.fit(X, y); lm.coef_[0], lm.score(X, y)` — but REGR functions run inside the database per GROUP BY, without data extraction.

---

## 💎 Super Expert
> No questions. Curated topics for world-class analytical SQL mastery.

---

### 🚀 What to Master After Phase 5

**1. HyperLogLog for Approximate Distinct Counts**
The `hll` extension provides approximate COUNT(DISTINCT) with < 1% error at < 1% the computation cost. When: counting distinct patients per hospital per day across billions of rows — exact COUNT(DISTINCT) requires full deduplication sort. HyperLogLog uses probabilistic counting with configurable precision. Used by: Facebook, Twitter, Redshift's `APPROXIMATE COUNT(DISTINCT)`. When you stand out: proposing HLL instead of COUNT(DISTINCT) for performance-critical dashboards.

**2. TimescaleDB for Time-Series Optimization**
TimescaleDB is a PostgreSQL extension converting regular tables into time-series optimised "hypertables" — partitioned automatically by time with compression and continuous aggregates. `CREATE MATERIALIZED VIEW daily_visits WITH (timescaledb.continuous) AS SELECT time_bucket('1 day', arrival_datetime), COUNT(*) ...`. Continuous aggregates auto-refresh — no scheduled jobs needed. For `fact_patient_visits` at scale, TimescaleDB provides 10–100x faster time-series queries.

**3. Window Function Internals: Sort and Frame Optimisation**
PostgreSQL needs to sort data for each window function — `ORDER BY` in a window triggers a sort. Multiple window functions with the same `ORDER BY` share one sort (optimised). Multiple windows with different `ORDER BY` require multiple sorts. Optimise: define all window functions using the same `WINDOW w AS (...)`. For very large analytical queries, `enable_sort = false` combined with covering indexes can eliminate sort operations entirely.

**4. Incremental/Streaming Aggregation (Continuous Aggregates)**
Batch aggregation (GROUP BY on historical data) is insufficient for real-time dashboards. TimescaleDB's continuous aggregates, PostgreSQL triggers, or materialised view refresh on insert simulate streaming aggregation. Apache Kafka + Flink is the proper streaming solution for sub-second analytics. SQL window functions (LEAD/LAG) are the bridge: understanding them in PostgreSQL directly maps to Flink's `OVER WINDOW` and Spark Structured Streaming's `window()` operator.

**5. Statistical ML in PostgreSQL via MADlib**
Apache MADlib is a PostgreSQL extension providing: logistic regression, random forests, k-means, linear SVM, association rules — all as SQL functions. `SELECT madlib.logregr_train(...)` trains a model stored in a table. `SELECT madlib.logregr_predict(...)` scores new rows. For teams who can't extract data from the hospital database (HIPAA compliance), in-database ML eliminates the security risk of data extraction while enabling ML at scale.

**6. Foreign Key-based Partition Elimination in Star Schema Queries**
With declarative partitioning + FK constraints + `constraint_exclusion = on`, the query planner can eliminate partitions for dimension filters even when the filter is on a dimension table, not the fact table. Example: `WHERE dh.city = 'London'` on a query joining partitioned `fact_patient_visits` to `dim_hospital` — the planner can exclude fact partitions containing no London hospital records if the constraint metadata is available. Deep optimisation territory.

**7. Aggregation Pushdown in Distributed Queries**
In Citus (PostgreSQL horizontal sharding extension), GROUP BY queries are executed partially on each shard (partial aggregation) and combined by the coordinator (finalization). Understanding this two-phase aggregation is crucial for writing shard-efficient queries: `GROUP BY shard_key` enables full pushdown; `GROUP BY non_shard_key` requires cross-shard data movement. This maps directly to Spark's `reduceByKey` (full pushdown) vs `groupByKey` (shuffles all data).
