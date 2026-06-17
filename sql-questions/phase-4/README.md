# 📙 Phase 4 — SQL Functions & Conditional Logic
## String · Number · Date/Time · NULL Handling · CASE WHEN
### PostgreSQL | NHS Hospital Analytics | Data Science Perspective

---

## 📋 Phase Topics

| Group | Functions & Commands |
|---|---|
| String | `UPPER`, `LOWER`, `INITCAP`, `LENGTH`, `TRIM`, `LTRIM`, `RTRIM`, `LPAD`, `RPAD`, `CONCAT`, `\|\|`, `SUBSTRING`, `LEFT`, `RIGHT`, `REPLACE`, `REGEXP_REPLACE`, `SPLIT_PART`, `POSITION`, `OVERLAY` |
| Number | `ROUND`, `CEIL`, `FLOOR`, `TRUNC`, `ABS`, `MOD`, `POWER`, `SQRT`, `SIGN`, `GREATEST`, `LEAST` |
| Date/Time | `NOW()`, `CURRENT_DATE`, `CURRENT_TIMESTAMP`, `EXTRACT`, `DATE_PART`, `DATE_TRUNC`, `AGE()`, `INTERVAL`, `TO_CHAR`, `TO_DATE`, `MAKE_DATE`, `JUSTIFY_INTERVAL` |
| NULL Handling | `COALESCE`, `NULLIF`, `IS NULL`, `IS NOT NULL`, `NVL` (not in PG — use COALESCE) |
| Conditional | `CASE WHEN ... THEN ... ELSE ... END`, searched and simple CASE |

---

## 🟢 Beginner

---

### Q1. Standardise Hospital Names to Upper Case
Display `hospital_id` and `hospital_name` in UPPER CASE from `dim_hospital`.
> 🔍 **Hint:** `UPPER(hospital_name)`.
> 📚 **Concept:** `UPPER()` and `LOWER()` convert string case. `INITCAP()` capitalises each word's first letter. These are frequently used for normalising data before joining on text columns — 'Royal London' vs 'royal london' won't match without case normalisation.
> 🐘 **PG Ref:** [String functions](https://www.postgresql.org/docs/current/functions-string.html)
> 🔬 **DS Equivalent:** `df['hospital_name'].str.upper()` — pandas `.str.upper()` method.

---

### Q2. Measure Doctor Name Lengths
Show `doctor_name` and the character length of each name from `dim_doctor`. Order by length descending.
> 🔍 **Hint:** `LENGTH(doctor_name)` or `CHAR_LENGTH()`.
> 📚 **Concept:** `LENGTH()` returns the number of characters. `OCTET_LENGTH()` returns bytes (differs for multi-byte/Unicode characters). Used in data quality checks — names shorter than 2 chars or longer than 150 chars may be corrupt entries.
> 🐘 **PG Ref:** [String functions — LENGTH](https://www.postgresql.org/docs/current/functions-string.html)
> 🔬 **DS Equivalent:** `df['doctor_name'].str.len()` in pandas.

---

### Q3. Round Treatment Costs to Nearest Pound
From `fact_patient_visits`, show `visit_id` and `treatment_cost` rounded to 0 decimal places.
> 🔍 **Hint:** `ROUND(treatment_cost, 0)`.
> 📚 **Concept:** `ROUND(n, d)` rounds to `d` decimal places. PostgreSQL uses "round half to even" (banker's rounding) for `NUMERIC` type — `ROUND(0.5) = 0`, `ROUND(1.5) = 2`. For `FLOAT` type, it uses traditional rounding. In financial calculations, always use `NUMERIC` type, not `FLOAT`, to avoid floating-point precision errors.
> 🐘 **PG Ref:** [Mathematical functions](https://www.postgresql.org/docs/current/functions-math.html)
> 🔬 **DS Equivalent:** `df['treatment_cost'].round(0)` in pandas. Note: pandas also uses banker's rounding.

---

### Q4. Absolute Value of Profit Margins
From `fact_financials`, show `hospital_id`, `profit_margin`, and its absolute value. Order by absolute value descending.
> 🔍 **Hint:** `ABS(profit_margin)`.
> 📚 **Concept:** `ABS()` returns the non-negative absolute value. Useful for finding the largest deviations regardless of direction — `ABS(profit_margin)` > 20 finds hospitals with extreme losses OR extreme profits. Combine with `SIGN()` which returns -1, 0, or 1 to re-attach the direction.
> 🐘 **PG Ref:** [Mathematical functions — ABS](https://www.postgresql.org/docs/current/functions-math.html)
> 🔬 **DS Equivalent:** `df['profit_margin'].abs()` or `np.abs(arr)` — standard absolute value in pandas/numpy.

---

### Q5. Current Date and Time Metadata
Write a query that returns the current date, current timestamp, and current time zone from PostgreSQL's built-in functions. No table needed.
> 🔍 **Hint:** `SELECT NOW(), CURRENT_DATE, CURRENT_TIMESTAMP, CURRENT_TIME, LOCALTIME, LOCALTIMESTAMP`.
> 📚 **Concept:** `NOW()` = `CURRENT_TIMESTAMP` — both return timestamp with timezone. `LOCALTIME` returns time without timezone. `CURRENT_DATE` returns a date (no time component). These are stable within a transaction — all calls in one transaction return the same value. `clock_timestamp()` returns actual current clock time (changes mid-transaction).
> 🐘 **PG Ref:** [Date/time current functions](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-CURRENT)
> 🔬 **DS Equivalent:** `pd.Timestamp.now()`, `datetime.now()`, `datetime.date.today()` — Python equivalents.

---

### Q6. Extract Year from Arrival Datetime
From `fact_patient_visits`, show `visit_id` and the year extracted from `arrival_datetime`.
> 🔍 **Hint:** `EXTRACT(YEAR FROM arrival_datetime)` or `DATE_PART('year', arrival_datetime)`.
> 📚 **Concept:** `EXTRACT()` and `DATE_PART()` are functionally equivalent in PostgreSQL. `EXTRACT` is ANSI SQL standard; `DATE_PART` is PostgreSQL-specific but identical in behaviour. Both return a `double precision` value. For GROUP BY on year/month, use `DATE_TRUNC` instead — it returns a proper timestamp that is easier to format.
> 🐘 **PG Ref:** [EXTRACT / DATE_PART](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-EXTRACT)
> 🔬 **DS Equivalent:** `df['arrival_datetime'].dt.year` — pandas `.dt.year` accessor.

---

### Q7. Replace NULL Satisfaction Scores with Zero
From `fact_patient_visits`, display `visit_id` and `satisfaction_score`. Replace NULL scores with 0 using COALESCE.
> 🔍 **Hint:** `COALESCE(satisfaction_score, 0)`.
> 📚 **Concept:** `COALESCE(a, b, c, ...)` returns the first non-NULL argument. It's a variadic function — accepts any number of arguments. The replacement value's type must be compatible with the original. `COALESCE` is standard SQL; PostgreSQL's `NVL()` does not exist — always use `COALESCE`.
> 🐘 **PG Ref:** [COALESCE](https://www.postgresql.org/docs/current/functions-conditional.html)
> 🔬 **DS Equivalent:** `df['satisfaction_score'].fillna(0)` in pandas.

---

### Q8. Truncate Arrival Timestamps to the Month
From `fact_patient_visits`, show `visit_id` and `arrival_datetime` truncated to the start of the month.
> 🔍 **Hint:** `DATE_TRUNC('month', arrival_datetime)`.
> 📚 **Concept:** `DATE_TRUNC('unit', timestamp)` truncates to the specified precision — 'year', 'quarter', 'month', 'week', 'day', 'hour', 'minute', 'second'. It returns a `timestamp` (not just a number), making it ideal for GROUP BY on time periods. `DATE_TRUNC('month', '2024-03-15')` returns `2024-03-01 00:00:00`.
> 🐘 **PG Ref:** [DATE_TRUNC](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-TRUNC)
> 🔬 **DS Equivalent:** `df['arrival_datetime'].dt.to_period('M')` or `.dt.floor('MS')` in pandas.

---

### Q9. Calculate Patient Age from a Fixed Reference Date
From `dim_patient`, the `age` column is already stored. But demonstrate: if you had `date_of_birth`, how would you calculate age using `AGE()` and `EXTRACT`?
> 🔍 **Hint:** `EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth))` or `AGE('2024-01-01'::date, '1980-05-15'::date)`.
> 📚 **Concept:** `AGE(end_date, start_date)` returns an INTERVAL (e.g., '43 years 7 months 16 days'). Wrapping with `EXTRACT(YEAR FROM ...)` gives just the year component of the age. This is the correct SQL approach for age calculation — arithmetic subtraction on dates gives days, not years. Always recalculate age at query time from DOB rather than storing a static age column.
> 🐘 **PG Ref:** [AGE function](https://www.postgresql.org/docs/current/functions-datetime.html)
> 🔬 **DS Equivalent:** `(pd.Timestamp.now() - df['date_of_birth']).dt.days / 365.25` — approximate; `relativedelta` from `dateutil` gives exact years.

---

### Q10. Trim Whitespace from Doctor Names
From `dim_doctor`, apply `TRIM` to `doctor_name` to remove leading and trailing spaces. Show original vs trimmed.
> 🔍 **Hint:** `TRIM(doctor_name)`, `LTRIM(doctor_name)`, `RTRIM(doctor_name)`.
> 📚 **Concept:** `TRIM()` removes leading and trailing spaces by default. `TRIM(BOTH 'x' FROM col)` removes a specific character. `LTRIM`/`RTRIM` remove left or right only. Untrimmed strings break equality matches — `'London '` ≠ `'London'`. Always TRIM imported data before loading into dimensional tables.
> 🐘 **PG Ref:** [String functions — TRIM](https://www.postgresql.org/docs/current/functions-string.html)
> 🔬 **DS Equivalent:** `df['doctor_name'].str.strip()` — pandas `.str.strip()` method.

---

### Q11. Classify Severity with CASE WHEN
From `fact_patient_visits`, add a `severity_label` column: 1='Minor', 2='Low', 3='Moderate', 4='High', 5='Critical'. Use CASE WHEN.
> 🔍 **Hint:** `CASE WHEN severity_level = 1 THEN 'Minor' WHEN ... ELSE 'Unknown' END AS severity_label`.
> 📚 **Concept:** CASE WHEN is SQL's if-else. Two forms: Searched CASE (`CASE WHEN condition THEN value`) and Simple CASE (`CASE col WHEN value THEN result`). Simple CASE is shorter but only supports equality. Searched CASE supports any condition. Always include ELSE — without it, unmatched rows get NULL.
> 🐘 **PG Ref:** [CASE expression](https://www.postgresql.org/docs/current/functions-conditional.html)
> 🔬 **DS Equivalent:** `df['severity_level'].map({1:'Minor', 2:'Low', 3:'Moderate', 4:'High', 5:'Critical'})` — dictionary mapping in pandas.

---

### Q12. Prevent Division by Zero with NULLIF
From `fact_financials`, calculate cost efficiency ratio: `operational_cost / visit_count`. Use NULLIF to prevent division by zero.
> 🔍 **Hint:** `operational_cost / NULLIF(visit_count, 0)`.
> 📚 **Concept:** `NULLIF(a, b)` returns NULL if `a = b`, otherwise returns `a`. Used as a division-by-zero guard: `value / NULLIF(denominator, 0)` — if denominator is 0, the division becomes `value / NULL = NULL` instead of a runtime error. Combine with `COALESCE` to replace the NULL result: `COALESCE(numerator / NULLIF(denom, 0), 0)`.
> 🐘 **PG Ref:** [NULLIF](https://www.postgresql.org/docs/current/functions-conditional.html)
> 🔬 **DS Equivalent:** `df['operational_cost'] / df['visit_count'].replace(0, np.nan)` — `.replace(0, np.nan)` is the pandas NULLIF equivalent for division safety.

---

## 🟡 Medium
> 2 tables · 2+ concepts combined · Table names in hints

---

### Q1. Calculate Wait Time in Hours and Categorise
From `fact_patient_visits`, convert `wait_time_minutes` to hours (rounded to 2 dp) and label as: 'Fast' (<30 min), 'Standard' (30–120), 'Slow' (>120). Show `visit_id`, `hospital_name`, `wait_minutes`, `wait_hours`, `wait_category`.
> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_hospital`. Concepts: Arithmetic (`/ 60.0`), `ROUND`, `CASE WHEN`, JOIN.
> 📚 **Concept:** Integer division in PostgreSQL: `121 / 60 = 2` (integer result). Use `/ 60.0` or `CAST(... AS numeric)` to force decimal division. Combining arithmetic, ROUND, and CASE WHEN in one SELECT is standard analytical transformation — equivalent to a pandas transform pipeline.
> 🐘 **PG Ref:** [Arithmetic operators](https://www.postgresql.org/docs/current/functions-math.html)
> 🔬 **DS Equivalent:** `df.assign(wait_hours=lambda x: x['wait_time_minutes'].div(60).round(2), wait_category=lambda x: pd.cut(x['wait_time_minutes'], bins=[-inf,30,120,inf], labels=['Fast','Standard','Slow']))`.

---

### Q2. Full Doctor Name Formatted with Hospital
Concatenate `doctor_name` with their hospital city and specialty to produce a formatted label: "Dr. John Smith — Cardiology (London)". Show this for all doctors.
> 🔍 **Hint:** Tables: `dim_doctor`, `dim_hospital`. Concepts: `CONCAT()` or `||`, string literals, JOIN.
> 📚 **Concept:** `CONCAT(a, b, c)` treats NULLs as empty strings. The `||` operator propagates NULLs — `'A' || NULL = NULL`. Use `CONCAT` when columns might be NULL. `FORMAT('%s — %s (%s)', col1, col2, col3)` is a cleaner PostgreSQL alternative for complex string formatting.
> 🐘 **PG Ref:** [String concatenation](https://www.postgresql.org/docs/current/functions-string.html)
> 🔬 **DS Equivalent:** `'Dr. ' + df['doctor_name'] + ' — ' + df['specialty'] + ' (' + df['city'] + ')'` — string concatenation in pandas (use `.fillna('')` first to handle NULLs).

---

### Q3. Length of Stay Analysis
From `fact_patient_visits`, calculate: LOS in days (`ROUND(length_of_stay_hours / 24.0, 1)`), LOS category using CASE WHEN, and the difference between `discharge_datetime` and `arrival_datetime` using interval arithmetic. Verify both methods agree.
> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: Division, `ROUND`, `CASE WHEN`, interval arithmetic (`discharge_datetime - arrival_datetime`), `EXTRACT(EPOCH FROM ...)`.
> 📚 **Concept:** Subtracting two timestamps gives an `INTERVAL` in PostgreSQL. `EXTRACT(EPOCH FROM interval)` converts it to total seconds. `EXTRACT(EPOCH FROM (discharge - arrival)) / 3600.0` = hours. This is more accurate than the stored `length_of_stay_hours` column if datetimes are precise — always verify derived columns against source datetime columns.
> 🐘 **PG Ref:** [Date/time arithmetic](https://www.postgresql.org/docs/current/functions-datetime.html)
> 🔬 **DS Equivalent:** `(df['discharge_datetime'] - df['arrival_datetime']).dt.total_seconds() / 3600` in pandas.

---

### Q4. Seasonal Burnout Pattern
From `fact_staffing`, use `EXTRACT(MONTH FROM shift_date)` to label each shift's season: Dec–Feb='Winter', Mar–May='Spring', Jun–Aug='Summer', Sep–Nov='Autumn'. Calculate avg burnout per season. Join with `dim_hospital` for hospital name.
> 🔍 **Hint:** Tables: `fact_staffing`, `dim_hospital`. Concepts: `EXTRACT(MONTH)`, CASE WHEN for season label, GROUP BY season.
> 📚 **Concept:** Month extraction for seasonal grouping is a very common time-series pattern. Combining EXTRACT with CASE WHEN creates a derived categorical variable. This is the SQL equivalent of feature engineering — adding a 'season' feature from a raw timestamp for downstream analysis or ML.
> 🐘 **PG Ref:** [EXTRACT](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-EXTRACT)
> 🔬 **DS Equivalent:** `df['season'] = df['shift_date'].dt.month.map({12:'Winter',1:'Winter',2:'Winter',3:'Spring',...})` in pandas.

---

### Q5. Hospital Names — Standardise and Extract Components
From `dim_hospital`, extract: (1) first word of `hospital_name` using `SPLIT_PART`, (2) everything after the first space using `SUBSTRING`, (3) whether the name contains 'Royal' using `POSITION`. Show results.
> 🔍 **Hint:** Tables: `dim_hospital`. Concepts: `SPLIT_PART(col, ' ', 1)`, `SUBSTRING(col FROM POSITION(' ' IN col) + 1)`, `POSITION('Royal' IN col)`.
> 📚 **Concept:** `SPLIT_PART(str, delimiter, n)` splits a string by a delimiter and returns the nth segment — more readable than complex SUBSTRING/POSITION combinations. `POSITION(substr IN str)` returns the character position (0 if not found). These functions are essential for parsing semi-structured data stored in text columns.
> 🐘 **PG Ref:** [SPLIT_PART](https://www.postgresql.org/docs/current/functions-string.html) | [POSITION](https://www.postgresql.org/docs/current/functions-string.html)
> 🔬 **DS Equivalent:** `df['hospital_name'].str.split(' ').str[0]` for first word; `df['hospital_name'].str.contains('Royal')` for position check.

---

### Q6. Days Since Last Visit per Hospital
From `fact_patient_visits`, for each hospital, find the most recent `arrival_datetime` and calculate the number of days between that date and TODAY using `CURRENT_DATE`.
> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `MAX(arrival_datetime)`, `CURRENT_DATE - MAX(...)::date`, GROUP BY `hospital_id`.
> 📚 **Concept:** Subtracting a date from another date in PostgreSQL returns an integer (days). `CURRENT_DATE - '2024-01-01'::date = 365` (approximately). This "days since" pattern is used extensively in churn analysis, data freshness checks, and monitoring dashboards. Wrapping `MAX()` in date arithmetic gives per-group freshness metrics.
> 🐘 **PG Ref:** [Date arithmetic](https://www.postgresql.org/docs/current/functions-datetime.html)
> 🔬 **DS Equivalent:** `(pd.Timestamp.today() - df.groupby('hospital_id')['arrival_datetime'].max()).dt.days` in pandas.

---

### Q7. Clean Diagnosis Category Text
From `fact_patient_visits`, use `REPLACE` to standardise: remove hyphens from `diagnosis_category`, convert to `INITCAP` case, and trim spaces. Show original vs cleaned versions.
> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `REPLACE`, `INITCAP`, `TRIM`, function chaining.
> 📚 **Concept:** Functions can be chained: `TRIM(INITCAP(REPLACE(col, '-', ' ')))` — evaluated inside-out. This multi-step text cleaning is equivalent to a pandas transformation pipeline. For complex patterns, `REGEXP_REPLACE(col, pattern, replacement)` handles regex-based cleaning. In PostgreSQL, `REGEXP_REPLACE` uses POSIX regular expressions (not PCRE).
> 🐘 **PG Ref:** [REGEXP_REPLACE](https://www.postgresql.org/docs/current/functions-string.html)
> 🔬 **DS Equivalent:** `df['diagnosis_category'].str.replace('-',' ').str.title().str.strip()` — chained pandas string methods.

---

### Q8. Financial Period Label Generation
From `fact_financials`, generate a human-readable period label: e.g., "Apr 2023", "Q1 2024". Use `TO_CHAR` for month name and year formatting.
> 🔍 **Hint:** Tables: `fact_financials`. Concepts: `TO_CHAR(MAKE_DATE(year_int, month_name, 1), 'Mon YYYY')`, `CASE WHEN` for quarter.
> 📚 **Concept:** `TO_CHAR(date, format)` formats a date as a string using format codes: 'YYYY' (4-digit year), 'MM' (2-digit month), 'Mon' (abbreviated month name), 'Month' (full month name), 'Q' (quarter). `MAKE_DATE(year, month, day)` constructs a date from integer parts. Combining both reconstructs a readable period label from `year_int` and `month_name` integer columns.
> 🐘 **PG Ref:** [TO_CHAR](https://www.postgresql.org/docs/current/functions-formatting.html)
> 🔬 **DS Equivalent:** `pd.Period(year=2024, month=4, freq='M').strftime('%b %Y')` or `pd.Timestamp(year=2024, month=4, day=1).strftime('%b %Y')` in pandas.

---

### Q9. NULL Propagation Analysis in Calculations
From `fact_patient_visits`, compute: `treatment_cost + COALESCE(revenue_amount, 0)` vs `treatment_cost + revenue_amount`. Show both columns and flag rows where they differ.
> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `COALESCE`, NULL arithmetic propagation, CASE WHEN for flag.
> 📚 **Concept:** Any arithmetic involving NULL returns NULL: `100 + NULL = NULL`. This silently corrupts aggregations — `SUM(treatment_cost + revenue_amount)` skips rows where `revenue_amount IS NULL`. Always use `COALESCE(col, 0)` in arithmetic expressions when NULLs are possible. The difference between the two computed columns shows exactly where NULLs cause silent data loss.
> 🐘 **PG Ref:** [NULL in expressions](https://www.postgresql.org/docs/current/functions-comparison.html)
> 🔬 **DS Equivalent:** `(df['treatment_cost'] + df['revenue_amount'])` produces NaN where revenue_amount is NaN — equivalent to NULL propagation. `df['revenue_amount'].fillna(0)` is the fix.

---

### Q10. Regulatory Compliance Date Formatter
For each visit in `fact_patient_visits`, generate a formatted string for a compliance report: "Patient [patient_id] admitted on [Day, DD Month YYYY] at [HH:MI:SS]". Use string functions and date formatters.
> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `CONCAT`, `TO_CHAR(arrival_datetime, 'Day, DD Month YYYY')`, `TO_CHAR(arrival_datetime, 'HH24:MI:SS')`.
> 📚 **Concept:** `TO_CHAR` format codes: 'Day' (full day name with padding), 'FMDay' (no padding), 'DD' (day of month), 'Month' (full month name), 'HH24' (24-hour), 'HH12' (12-hour), 'MI' (minutes), 'SS' (seconds). The 'FM' prefix removes padding spaces. Generating standardised date strings for compliance reports is a common operational analytics task.
> 🐘 **PG Ref:** [TO_CHAR date formats](https://www.postgresql.org/docs/current/functions-formatting.html#FUNCTIONS-FORMATTING-DATETIME-TABLE)
> 🔬 **DS Equivalent:** `df['arrival_datetime'].dt.strftime('%A, %d %B %Y at %H:%M:%S')` in pandas.

---

### Q11. Extract Hour of Day for Demand Analysis
From `fact_patient_visits`, extract the hour of `arrival_datetime` and classify as: 'Night' (0–5), 'Morning' (6–11), 'Afternoon' (12–17), 'Evening' (18–23). Count visits per time-of-day category.
> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `EXTRACT(HOUR FROM ...)`, CASE WHEN, GROUP BY.
> 📚 **Concept:** Hour extraction for time-of-day demand analysis is a classic operational analytics pattern. Healthcare demand is strongly cyclical — understanding arrival patterns by hour helps with staffing optimisation. This derived feature (time-of-day category) is a key input in demand forecasting ML models.
> 🐘 **PG Ref:** [EXTRACT HOUR](https://www.postgresql.org/docs/current/functions-datetime.html)
> 🔬 **DS Equivalent:** `df['arrival_datetime'].dt.hour` then `pd.cut(hours, bins=[0,6,12,18,24], labels=['Night','Morning','Afternoon','Evening'])`.

---

### Q12. Least and Greatest for Bounded Scores
From `fact_patient_visits`, ensure `satisfaction_score` is capped between 1 and 10 using `GREATEST` and `LEAST`. Show original vs bounded values.
> 🔍 **Hint:** `LEAST(GREATEST(satisfaction_score, 1), 10)`.
> 📚 **Concept:** `GREATEST(a, b, ...)` returns the largest value; `LEAST(a, b, ...)` returns the smallest. Chaining them creates a clamp: `LEAST(GREATEST(value, min_bound), max_bound)`. This is the SQL equivalent of `numpy.clip(arr, min, max)` — essential for bounding scores, percentages, or any metric with valid range constraints.
> 🐘 **PG Ref:** [GREATEST/LEAST](https://www.postgresql.org/docs/current/functions-conditional.html)
> 🔬 **DS Equivalent:** `np.clip(df['satisfaction_score'], 1, 10)` or `df['satisfaction_score'].clip(lower=1, upper=10)` in pandas.

---

## 🟠 Medium Hard
> Mixed phases · 2–3 tables · Steps required

---

### Q1. Visit Duration Outlier Report with Text Labels
From `fact_patient_visits` joined with `dim_hospital`, compute the LOS in days, flag outliers (< 0 or > 30 days), and generate a human-readable summary string: "Visit [id] at [hospital]: [N] days — [OUTLIER/NORMAL]".

> 🔍 **Hint:** Tables: `fact_patient_visits`, `dim_hospital`. Concepts: Arithmetic, `ROUND`, CASE WHEN, `CONCAT`, `TO_CHAR`, JOIN.

> 🪜 **Steps:**
> 1. JOIN `fact_patient_visits` to `dim_hospital` on `hospital_id`.
> 2. Compute LOS: `ROUND(length_of_stay_hours / 24.0, 1)`.
> 3. CASE WHEN for flag: `WHEN los_days < 0 OR los_days > 30 THEN 'OUTLIER' ELSE 'NORMAL'`.
> 4. CONCAT for summary: `'Visit ' || visit_id || ' at ' || hospital_name || ': ' || los_days || ' days — ' || flag`.
> 5. Filter to only OUTLIER rows in final output.

> 📚 **Concept:** Combining arithmetic transformation, CASE WHEN classification, and string concatenation in one SELECT is a multi-step analytical transformation — equivalent to a pandas `.assign()` chain. Always compute derived values as aliases first (in a subquery) and reference them by name, rather than repeating the expression. PostgreSQL does NOT allow referencing a SELECT alias in another SELECT expression in the same query level — use a subquery or CTE.
> 🐘 **PG Ref:** [String concatenation](https://www.postgresql.org/docs/current/functions-string.html) | [CASE](https://www.postgresql.org/docs/current/functions-conditional.html)
> 🔬 **DS Equivalent:** `df.assign(los_days=..., flag=..., summary=lambda x: 'Visit ' + x['visit_id'] + ...)` — chained `.assign()` in pandas, where each step can reference the previous.

---

### Q2. Patient Age Bucket Analysis for Treatment Cost Segmentation
From `dim_patient` joined with `fact_patient_visits`, bucket patients into age groups (0–17, 18–35, 36–60, 60+) and calculate avg treatment cost and avg wait time per age group. Use CASE WHEN for bucketing.

> 🔍 **Hint:** Tables: `dim_patient`, `fact_patient_visits`. Concepts: CASE WHEN for age buckets, GROUP BY on derived expression, AVG.

> 🪜 **Steps:**
> 1. JOIN on `patient_id`.
> 2. Define age bucket in SELECT: `CASE WHEN age < 18 THEN 'Paediatric' WHEN age BETWEEN 18 AND 35 THEN 'Young Adult' WHEN age BETWEEN 36 AND 60 THEN 'Adult' ELSE 'Senior' END`.
> 3. GROUP BY the same CASE WHEN expression (or its alias in a subquery).
> 4. SELECT: age_bucket, COUNT(*), AVG(treatment_cost), AVG(wait_time_minutes).
> 5. Note: cannot reference a SELECT alias in GROUP BY of the same SELECT — wrap in a subquery.

> 📚 **Concept:** PostgreSQL does NOT allow referencing a SELECT alias in the same query's GROUP BY. Use a subquery or CTE: `SELECT age_bucket, COUNT(*) FROM (SELECT *, CASE WHEN ... END AS age_bucket FROM ...) t GROUP BY age_bucket`. This is a common PostgreSQL gotcha — SQL Server and MySQL allow alias references in GROUP BY; PostgreSQL does not.
> 🐘 **PG Ref:** [GROUP BY alias limitation](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-GROUP)
> 🔬 **DS Equivalent:** `df['age_bucket'] = pd.cut(df['age'], bins=[0,18,35,60,120], labels=['Paediatric','Young Adult','Adult','Senior'])` then `df.groupby('age_bucket')[['treatment_cost','wait_time_minutes']].mean()`.

---

### Q3. Day-of-Week Demand Heatmap Data
From `fact_patient_visits`, produce a heatmap-ready dataset: for each combination of `day_of_week` (from `arrival_datetime`) and `admission_type`, count visits. Use `TO_CHAR` for day name and handle all 7 days even if some have zero visits.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `TO_CHAR(arrival_datetime, 'Day')`, TRIM (day names are padded), GROUP BY, CROSS JOIN for zero-fill.

> 🪜 **Steps:**
> 1. `TRIM(TO_CHAR(arrival_datetime, 'Day'))` to get day name without padding.
> 2. `EXTRACT(DOW FROM arrival_datetime)` for numeric sort (0=Sunday).
> 3. GROUP BY day_name, day_num, admission_type.
> 4. For zero-filling: CROSS JOIN `(SELECT DISTINCT admission_type FROM fpv)` with a days list, then LEFT JOIN to actual counts.
> 5. ORDER BY day_num, admission_type.

> 📚 **Concept:** TO_CHAR with 'Day' format pads to 9 chars — always TRIM. The 'FMDay' format variant removes padding automatically. Zero-filling (showing 0 counts for day/type combinations with no visits) requires a CROSS JOIN to generate all expected combinations, then a LEFT JOIN to actual data — a standard technique for complete heatmap datasets.
> 🐘 **PG Ref:** [TO_CHAR format codes](https://www.postgresql.org/docs/current/functions-formatting.html#FUNCTIONS-FORMATTING-DATETIME-TABLE)
> 🔬 **DS Equivalent:** `df.groupby([day_of_week, admission_type]).size().unstack(fill_value=0)` — pivot table with zero-fill in pandas. Perfect input for a seaborn heatmap.

---

### Q4. Readmission Risk Score Enhancement
From `dim_diagnosis`, compute a composite risk score: `ROUND((severity_weight * 0.4) + (icu_probability * 100 * 0.3) + (CASE readmission_risk WHEN 'High' THEN 30 WHEN 'Medium' THEN 15 ELSE 0 END * 0.3), 2)`. Label results Low/Medium/High using CASE WHEN thresholds.

> 🔍 **Hint:** Tables: `dim_diagnosis`. Concepts: Weighted arithmetic, CASE WHEN (simple form for readmission_risk), nested CASE WHEN for final label.

> 🪜 **Steps:**
> 1. Compute component 1: `severity_weight * 0.4`.
> 2. Compute component 2: `icu_probability * 100 * 0.3`.
> 3. Compute component 3: Simple CASE WHEN on `readmission_risk` string.
> 4. Sum all components, ROUND to 2dp.
> 5. Final label: outer CASE WHEN `< 20 THEN 'Low'`, `20–50 THEN 'Medium'`, `> 50 THEN 'High'`.

> 📚 **Concept:** Weighted scoring in SQL is the manual equivalent of a linear scoring model (`w1*f1 + w2*f2 + ...`). This is the SQL implementation of a simple risk score — used in clinical decision support systems. The composite calculation mirrors what `sklearn.linear_model.LinearRegression` computes, but fully in SQL without extracting data. Useful for real-time scoring at query time.
> 🐘 **PG Ref:** [Arithmetic operators](https://www.postgresql.org/docs/current/functions-math.html)
> 🔬 **DS Equivalent:** `df['risk_score'] = df['severity_weight']*0.4 + df['icu_probability']*30 + df['readmission_risk'].map({'High':30,'Medium':15}).fillna(0)*0.3` in pandas.

---

### Q5. ISO Week and Quarter Reporting
From `fact_financials`, produce a reporting period breakdown: ISO week number, ISO year (important — differs from calendar year for week 52/53), quarter, and a formatted string "Q{n} {year}".

> 🔍 **Hint:** Tables: `fact_financials`. Concepts: `EXTRACT(WEEK FROM ...)`, `EXTRACT(ISOYEAR FROM ...)`, `EXTRACT(QUARTER FROM ...)`, `MAKE_DATE`, `TO_CHAR`.

> 🪜 **Steps:**
> 1. Reconstruct a date from year_int and month_name: `MAKE_DATE(year_int, month_name, 1)`.
> 2. `EXTRACT(ISOYEAR FROM date)` — ISO year (may differ from calendar year in late December/early January).
> 3. `EXTRACT(WEEK FROM date)` — ISO week number (1–53).
> 4. `EXTRACT(QUARTER FROM date)` — quarter 1–4.
> 5. Quarter label: `'Q' || EXTRACT(QUARTER FROM date)::int || ' ' || year_int`.

> 📚 **Concept:** ISO year ≠ calendar year. In ISO 8601, week 1 belongs to the year that contains its Thursday. So 2023-12-31 might be ISO week 52 of 2023, but 2024-01-01 might be ISO week 1 of 2024. Use `ISOYEAR` not `YEAR` when working with ISO weeks — mixing them produces off-by-one errors in financial reporting at year boundaries.
> 🐘 **PG Ref:** [EXTRACT ISOYEAR](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-EXTRACT)
> 🔬 **DS Equivalent:** `df['date'].dt.isocalendar()` — pandas returns ISO year, week, and day. `dt.quarter` for quarter.

---

### Q6. Multi-Condition COALESCE Chain
From `fact_patient_visits`, create a "best available score" column: use `satisfaction_score` if available, else `CAST((10 - severity_level * 1.0) AS NUMERIC)` (inverted severity as proxy), else `5.0` (neutral default). Label the source of each value.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `COALESCE` with multiple fallbacks, `CAST`, arithmetic inside COALESCE.

> 🪜 **Steps:**
> 1. `COALESCE(satisfaction_score, CAST((10 - severity_level * 1.0) AS NUMERIC), 5.0)` — three-level fallback.
> 2. Label source: `CASE WHEN satisfaction_score IS NOT NULL THEN 'Actual' WHEN severity_level IS NOT NULL THEN 'Derived' ELSE 'Default' END`.
> 3. Show both columns: best_score, score_source.

> 📚 **Concept:** Multi-level COALESCE chains implement fallback logic — a common data engineering pattern for building complete features from sparse data. `COALESCE` evaluates arguments left to right, returning the first non-NULL. This is identical to Python's `a or b or c` logic for falsy values, or `df['col'].combine_first(fallback_df['col'])` in pandas for non-null filling from a fallback column.
> 🐘 **PG Ref:** [COALESCE](https://www.postgresql.org/docs/current/functions-conditional.html)
> 🔬 **DS Equivalent:** `df['col1'].combine_first(df['col2']).combine_first(pd.Series(5.0, index=df.index))` — chained `combine_first()` for multi-level NULL fallback in pandas.

---

### Q7. Regex-Based Data Cleaning
From `dim_hospital`, use `REGEXP_REPLACE` to: (1) remove all non-alphanumeric characters from `hospital_name`, (2) extract only the numeric part of `hospital_id` using `REGEXP_MATCHES`. Show original, cleaned, and extracted.

> 🔍 **Hint:** Tables: `dim_hospital`. Concepts: `REGEXP_REPLACE(col, pattern, replacement, flags)`, `REGEXP_MATCHES(col, pattern)`.

> 🪜 **Steps:**
> 1. `REGEXP_REPLACE(hospital_name, '[^a-zA-Z0-9 ]', '', 'g')` — 'g' flag = replace all occurrences.
> 2. `REGEXP_MATCHES(hospital_id, '\d+')` — returns arrays of matches.
> 3. Or `SUBSTRING(hospital_id FROM '\d+')` for a scalar result.
> 4. Show: original_name, cleaned_name, extracted_id_number.

> 📚 **Concept:** PostgreSQL uses POSIX regular expressions (ERE — Extended Regular Expressions). The 'g' flag in `REGEXP_REPLACE` enables global replacement (all occurrences). `REGEXP_MATCHES` returns an array of all matches. For extracting one match: `SUBSTRING(col FROM pattern)` or `REGEXP_REPLACE` with capture groups. Advanced text cleaning (ICD codes, hospital IDs, postcodes) requires regex fluency.
> 🐘 **PG Ref:** [Regular expressions](https://www.postgresql.org/docs/current/functions-matching.html#FUNCTIONS-POSIX-REGEXP)
> 🔬 **DS Equivalent:** `df['hospital_name'].str.replace(r'[^a-zA-Z0-9 ]', '', regex=True)` — pandas `.str.replace()` with `regex=True`.

---

### Q8. Running Age at Time of Visit
Join `dim_patient` with `fact_patient_visits`. Since only `age` is stored (not DOB), estimate a "visit age" by adding years elapsed since a fictional reference year (assume patients' age was recorded in 2020). Show how age at visit differs from stored age.

> 🔍 **Hint:** Tables: `dim_patient`, `fact_patient_visits`. Concepts: `EXTRACT(YEAR FROM arrival_datetime)`, arithmetic on age, INTERVAL.

> 🪜 **Steps:**
> 1. JOIN on `patient_id`.
> 2. Visit year: `EXTRACT(YEAR FROM arrival_datetime)`.
> 3. Age at visit: `dp.age + (EXTRACT(YEAR FROM fpv.arrival_datetime) - 2020)`.
> 4. Flag if age_at_visit differs significantly from stored age.
> 5. Note: this is an estimation — a real system would store DOB.

> 📚 **Concept:** Storing a static `age` column (as in `dim_patient`) is a data modelling anti-pattern — age changes over time. Best practice: store `date_of_birth` and compute age at query time using `AGE()`. This is a critical data science consideration: using stale age data in ML features introduces label leakage or incorrect demographic segmentation.
> 🐘 **PG Ref:** [Date arithmetic](https://www.postgresql.org/docs/current/functions-datetime.html)
> 🔬 **DS Equivalent:** A static feature vs a dynamic computed feature — in feature stores, age should always be computed at serving time from DOB, never stored as a precomputed static value.

---

### Q9. Financial Performance Tier with Multi-Condition CASE
From `fact_financials`, create a 5-tier hospital performance label based on BOTH `profit_margin` AND `readmission_rate`: 'Excellent' (profit > 10 AND readmission < 5), 'Good' (profit > 0), 'Neutral' (profit = 0), 'At Risk' (profit < 0 AND readmission > 10), 'Critical' (profit < -10 OR readmission > 20).

> 🔍 **Hint:** Tables: `fact_financials`. Concepts: Searched CASE WHEN with multi-column AND/OR conditions, ordering by priority.

> 🪜 **Steps:**
> 1. Build searched CASE WHEN — order from most specific to least: 'Excellent' first, 'Critical' last.
> 2. CASE WHEN with both `profit_margin` and `readmission_rate` conditions.
> 3. Handle NULLs: if either is NULL, CASE falls through to ELSE.
> 4. Verify distribution: `SELECT tier, COUNT(*) GROUP BY tier`.

> 📚 **Concept:** Multi-column CASE WHEN creates a composite classification from two or more dimensions simultaneously. The ordering of CASE conditions matters — put more specific, high-priority conditions first (e.g., 'Excellent' before 'Good' because 'Excellent' is a subset of 'Good' conditions). This is equivalent to a decision tree with explicit rules — a "white-box" classification approach.
> 🐘 **PG Ref:** [Searched CASE](https://www.postgresql.org/docs/current/functions-conditional.html)
> 🔬 **DS Equivalent:** `df.apply(lambda r: 'Excellent' if r['profit_margin']>10 and r['readmission_rate']<5 else 'Good' if r['profit_margin']>0 else ..., axis=1)` — row-wise conditional logic in pandas.

---

### Q10. Date Boundary Calculations for Reporting Periods
From `fact_patient_visits`, for each visit compute: (1) first day of the visit month, (2) last day of the visit month, (3) first day of the visit quarter, (4) number of days remaining in the month after the visit.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `DATE_TRUNC('month', ...)`, `DATE_TRUNC('month', ...) + INTERVAL '1 month' - INTERVAL '1 day'`, arithmetic.

> 🪜 **Steps:**
> 1. First of month: `DATE_TRUNC('month', arrival_datetime)::date`.
> 2. Last of month: `(DATE_TRUNC('month', arrival_datetime) + INTERVAL '1 month' - INTERVAL '1 day')::date`.
> 3. First of quarter: `DATE_TRUNC('quarter', arrival_datetime)::date`.
> 4. Days remaining: `last_of_month - arrival_datetime::date`.

> 📚 **Concept:** Date boundary calculations are essential for financial period reporting. The "last day of month" formula — first of next month minus 1 day — works for any month without hardcoding 28/30/31. PostgreSQL's `INTERVAL` arithmetic handles month boundaries correctly (leap years, varying month lengths). `DATE_TRUNC('quarter')` snaps to Jan 1, Apr 1, Jul 1, Oct 1.
> 🐘 **PG Ref:** [Interval arithmetic](https://www.postgresql.org/docs/current/functions-datetime.html)
> 🔬 **DS Equivalent:** `df['date'].dt.to_period('M').dt.start_time` (month start) and `df['date'].dt.to_period('M').dt.end_time` (month end) in pandas.

---

## 🔴 Advanced

---

### Q1. Full Text Normalisation Pipeline
From `dim_hospital`, create a fully normalised search key: LOWER, TRIM, REGEXP_REPLACE to remove punctuation, REPLACE all multiple spaces with single space, LEFT to first 50 chars. Use for fuzzy matching preparation.

> 🔍 **Hint:** Tables: `dim_hospital`. Concepts: Function chaining, `REGEXP_REPLACE(..., '\s+', ' ', 'g')`, `LEFT(col, n)`.

> 🪜 **Steps:**
> 1. `LOWER(TRIM(hospital_name))`.
> 2. `REGEXP_REPLACE(result, '[^a-z0-9 ]', '', 'g')` — remove non-alphanumeric.
> 3. `REGEXP_REPLACE(result, '\s+', ' ', 'g')` — collapse multiple spaces.
> 4. `LEFT(result, 50)` — truncate to 50 chars.
> 5. Store as a `search_key` column for deduplication joins.

> 📚 **Concept:** Text normalisation pipelines prepare strings for fuzzy matching or deduplication. This is the SQL equivalent of a text preprocessing pipeline in NLP (lowercase → strip → remove punctuation → normalise whitespace). The `search_key` is then used in JOIN conditions for matching records across systems where hospital names might differ slightly.
> 🐘 **PG Ref:** [Regular expressions](https://www.postgresql.org/docs/current/functions-matching.html)
> 🔬 **DS Equivalent:** `re.sub(r'\s+', ' ', re.sub(r'[^a-z0-9 ]', '', str.lower(name).strip()))` — text normalisation in Python. Or spaCy/NLTK preprocessing pipeline equivalent.

---

### Q2. Time-Series Interpolation via Arithmetic
The `fact_financials` table has monthly data. For hospitals with missing months, generate interpolated revenue estimates: `(prev_month_revenue + next_month_revenue) / 2.0`. Use LAG/LEAD preview or subqueries. Show actual vs interpolated.

> 🔍 **Hint:** Tables: `fact_financials`. Concepts: Self-join or subquery for prev/next values, COALESCE, arithmetic averaging.

> 🪜 **Steps:**
> 1. Self-join `fact_financials` to get prev month: `JOIN ff2 ON ff2.hospital_id = ff1.hospital_id AND ff2.month_name = ff1.month_name - 1 AND ff2.year_int = ff1.year_int`.
> 2. Similarly for next month (month_name + 1).
> 3. `COALESCE(ff1.revenue, (ff_prev.revenue + ff_next.revenue) / 2.0)` — interpolated.
> 4. Label: `CASE WHEN ff1.revenue IS NULL THEN 'Interpolated' ELSE 'Actual' END`.

> 📚 **Concept:** Linear interpolation in SQL — filling gaps with the average of neighbours. Handles edge cases: month 1 has no prev (use next only), month 12 has no next (use prev only). This is the SQL equivalent of `df.interpolate(method='linear')` in pandas — used for time-series imputation in ML feature engineering.
> 🐘 **PG Ref:** [Self-join patterns](https://www.postgresql.org/docs/current/queries-table-expressions.html)
> 🔬 **DS Equivalent:** `df.set_index('date').resample('M').interpolate(method='linear')` — pandas time-series interpolation.

---

### Q3. Pivot Table via Conditional Aggregation
From `fact_patient_visits`, build a pivot showing visit count per hospital (rows) by admission type (columns): Emergency, Planned, Urgent. Use conditional aggregation with CASE WHEN inside SUM/COUNT.

> 🔍 **Hint:** Tables: `fact_patient_visits`. Concepts: `SUM(CASE WHEN col = 'val' THEN 1 ELSE 0 END)` pattern, GROUP BY `hospital_id`.

> 🪜 **Steps:**
> 1. `GROUP BY hospital_id`.
> 2. `SUM(CASE WHEN admission_type = 'Emergency' THEN 1 ELSE 0 END) AS emergency_count`.
> 3. Same for 'Planned', 'Urgent'.
> 4. Add `COUNT(*) AS total_visits`.
> 5. JOIN to `dim_hospital` for hospital_name.

> 📚 **Concept:** Conditional aggregation with `SUM(CASE WHEN ...)` is the SQL pivot technique — converting row values into columns. More flexible than SQL Server's `PIVOT` syntax (which PostgreSQL doesn't have). Each CASE WHEN adds one column of the pivot. This is equivalent to `pd.pivot_table(df, values='visit_id', index='hospital_id', columns='admission_type', aggfunc='count', fill_value=0)`.
> 🐘 **PG Ref:** [Conditional aggregation](https://www.postgresql.org/docs/current/functions-aggregate.html)
> 🔬 **DS Equivalent:** `pd.pivot_table(fact_visits, values='visit_id', index='hospital_id', columns='admission_type', aggfunc='count', fill_value=0)` — pandas pivot table.

---

### Q4. Create a PL/pgSQL Function for Risk Classification
Create a PL/pgSQL function `classify_patient_risk(age INT, chronic_count INT, severity INT) RETURNS VARCHAR` that returns a risk label based on business rules. Test it on 5 different input combinations.

> 🔍 **Hint:** Concepts: `CREATE OR REPLACE FUNCTION`, `RETURNS VARCHAR`, `LANGUAGE plpgsql`, `$$ BEGIN ... END $$`, IF-ELSIF-ELSE.

> 🪜 **Steps:**
> 1. `CREATE OR REPLACE FUNCTION classify_patient_risk(age INT, chronic_count INT, severity INT) RETURNS VARCHAR AS $$`
> 2. `DECLARE result VARCHAR;`
> 3. `BEGIN`
> 4. `IF age > 70 AND chronic_count > 3 THEN result := 'Critical';`
> 5. `ELSIF ...` — chain conditions.
> 6. `RETURN result; END $$ LANGUAGE plpgsql;`
> 7. Test: `SELECT classify_patient_risk(75, 4, 5)`.

> 📚 **Concept:** PL/pgSQL functions extend SQL with procedural logic — loops, conditionals, exception handling. `LANGUAGE plpgsql` specifies the procedural language. Functions can be used directly in SELECT, WHERE, JOIN — making them reusable across all queries. Mark pure calculation functions as `IMMUTABLE` (no side effects, same input always returns same output) — PostgreSQL can then cache results and use function-based indexes on them.
> 🐘 **PG Ref:** [CREATE FUNCTION](https://www.postgresql.org/docs/current/sql-createfunction.html) | [PL/pgSQL](https://www.postgresql.org/docs/current/plpgsql.html)
> 🔬 **DS Equivalent:** A Python function wrapped with `@udf` in PySpark, or registered with `engine.execute(DDL(...))` in SQLAlchemy — a reusable classification function deployed at the database layer.

---

### Q5. Generated Column for Automatic LOS Category
Add a `GENERATED ALWAYS AS` column `los_category` to `fact_patient_visits` that automatically computes: 'Short' (< 24h), 'Medium' (24–72h), 'Long' (> 72h) from `length_of_stay_hours`. This column auto-updates on INSERT/UPDATE.

> 🔍 **Hint:** Concepts: `ALTER TABLE ADD COLUMN col TYPE GENERATED ALWAYS AS (expression) STORED`.

> 🪜 **Steps:**
> 1. `ALTER TABLE fact_patient_visits ADD COLUMN los_category VARCHAR(20) GENERATED ALWAYS AS (CASE WHEN length_of_stay_hours < 24 THEN 'Short' WHEN length_of_stay_hours <= 72 THEN 'Medium' ELSE 'Long' END) STORED`.
> 2. INSERT a test row — observe `los_category` auto-populates.
> 3. UPDATE `length_of_stay_hours` — observe `los_category` auto-recalculates.
> 4. Cannot directly UPDATE a generated column — PostgreSQL rejects it.

> 📚 **Concept:** `GENERATED ALWAYS AS ... STORED` (PostgreSQL 12+) creates a virtual computed column stored physically on disk. `STORED` computes on write; there is no `VIRTUAL` variant in PostgreSQL (unlike MySQL). Generated columns eliminate the need for triggers or application logic to maintain derived columns. They can be indexed (since they're physically stored).
> 🐘 **PG Ref:** [Generated columns](https://www.postgresql.org/docs/current/ddl-generated-columns.html)
> 🔬 **DS Equivalent:** A `@property` in a Python dataclass that computes on access, but the STORED variant is more like persisting the computed property to a database column — trade-off between storage and compute.

---

### Q6. Window Function Preview: Running Average Wait Time
Without using window functions syntax (Phase 5 preview), approximate a 3-visit running average of `wait_time_minutes` per hospital using a self-join approach.

> 🔍 **Hint:** Tables: `fact_patient_visits` (self-join). Concepts: Self-join with inequality on `arrival_datetime`, AVG over a range.

> 🪜 **Steps:**
> 1. For each visit `v1`, find visits `v2` at the same hospital where `v2.arrival_datetime <= v1.arrival_datetime` and `v2.arrival_datetime >= v1.arrival_datetime - INTERVAL '3 days'`.
> 2. Average `v2.wait_time_minutes`.
> 3. Join result back to `v1`.
> 4. Note the complexity vs Phase 5's `AVG(...) OVER (PARTITION BY ... ORDER BY ... ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`.

> 📚 **Concept:** This self-join approach is how running averages were computed before window functions existed. It's O(N²) in complexity — quadratic scaling. Window functions (Phase 5) compute running aggregations in O(N log N) with a single pass over the data. This exercise demonstrates WHY window functions were invented — they replace complex self-joins with a clean, efficient syntax.
> 🐘 **PG Ref:** [Window functions](https://www.postgresql.org/docs/current/tutorial-window.html) — introduced to solve exactly this problem.
> 🔬 **DS Equivalent:** `df.rolling(window=3).mean()` in pandas — the window function equivalent. Try implementing rolling average with a self-merge and see the code complexity difference.

---

### Q7. CASE WHEN as Unpivot (Long Format Conversion)
From `dim_diagnosis`, convert the wide-format `fact_financials` row (with `operational_cost`, `staffing_cost`, `icu_cost`, `emergency_department_cost` as columns) into long format using UNION ALL. Each output row: `hospital_id`, `year_int`, `cost_type`, `cost_value`.

> 🔍 **Hint:** Tables: `fact_financials`. Concepts: UNION ALL for unpivoting (manual melt), literal string column for category label.

> 🪜 **Steps:**
> 1. `SELECT hospital_id, year_int, 'Operational' AS cost_type, operational_cost AS cost_value FROM fact_financials`.
> 2. `UNION ALL SELECT hospital_id, year_int, 'Staffing', staffing_cost FROM fact_financials`.
> 3. Repeat for `icu_cost`, `emergency_department_cost`.
> 4. Order by `hospital_id, year_int, cost_type`.

> 📚 **Concept:** UNION ALL for unpivoting (wide → long) is the inverse of conditional aggregation pivoting (long → wide). Long format is better for: time-series analysis, BI tools that expect metrics in rows, statistical modelling. Wide format is better for: joins, human-readable reports, ML feature matrices. Knowing both transformations and when to use each is a core data engineering skill.
> 🐘 **PG Ref:** [UNION ALL](https://www.postgresql.org/docs/current/queries-union.html)
> 🔬 **DS Equivalent:** `pd.melt(df, id_vars=['hospital_id','year_int'], value_vars=['operational_cost','staffing_cost','icu_cost','emergency_department_cost'], var_name='cost_type', value_name='cost_value')` — the pandas `melt()` operation.

---

### Q8. Trigram Similarity for Fuzzy Name Matching
Enable `pg_trgm` extension. Use `similarity()` function to find hospitals in `dim_hospital` whose names are similar (>0.3 similarity) to a user-supplied query string (e.g., 'Kings Colege Hospital'). Show name and similarity score.

> 🔍 **Hint:** `CREATE EXTENSION IF NOT EXISTS pg_trgm; SELECT hospital_name, similarity(hospital_name, 'Kings Colege Hospital') AS sim FROM dim_hospital WHERE similarity(hospital_name, 'Kings Colege Hospital') > 0.3 ORDER BY sim DESC`.

> 🪜 **Steps:**
> 1. `CREATE EXTENSION IF NOT EXISTS pg_trgm`.
> 2. `similarity(col, search_term) > 0.3` — returns 0.0 to 1.0.
> 3. Add a GIN trigram index: `CREATE INDEX idx_hospital_trgm ON dim_hospital USING gin (hospital_name gin_trgm_ops)`.
> 4. Re-run — now uses the index for fast similarity search.

> 📚 **Concept:** `pg_trgm` breaks strings into trigrams (3-character subsets) and uses them for similarity scoring and fast pattern matching (ILIKE with leading %). The `similarity()` function returns a score from 0 (no similarity) to 1 (identical). A GIN trigram index enables sub-millisecond fuzzy string matching even on millions of rows. This is PostgreSQL's built-in approximate string matching — for full NLP-grade fuzzy matching use `pg_similarity` or an external Elasticsearch.
> 🐘 **PG Ref:** [pg_trgm](https://www.postgresql.org/docs/current/pgtrgm.html)
> 🔬 **DS Equivalent:** `fuzzywuzzy.fuzz.ratio()` or `rapidfuzz.fuzz.ratio()` in Python — string similarity scoring. `pg_trgm` brings this capability into the database for set-scale matching without data extraction.

---

### Q9. Immutable UDF for Function-Based Index
Create an `IMMUTABLE` PL/pgSQL function `normalised_hospital_name(name VARCHAR) RETURNS VARCHAR` that returns LOWER(TRIM(name)). Then create a function-based index on `dim_hospital(normalised_hospital_name(hospital_name))`. Show how it enables case-insensitive joins.

> 🔍 **Hint:** Concepts: `CREATE FUNCTION ... IMMUTABLE`, `CREATE INDEX ON table (function(column))`.

> 🪜 **Steps:**
> 1. Create the function with `IMMUTABLE` qualifier.
> 2. `CREATE INDEX idx_hosp_normalised ON dim_hospital (normalised_hospital_name(hospital_name))`.
> 3. Query: `WHERE normalised_hospital_name(hospital_name) = normalised_hospital_name('Royal London Hospital ')` — uses the index.
> 4. `EXPLAIN` to confirm index scan.

> 📚 **Concept:** `IMMUTABLE` functions always return the same result for the same inputs and have no side effects — PostgreSQL can use their output for indexing. A function-based index stores the function's result for each row, enabling indexed lookups on transformed values. Critical: if you later change the function's logic, you must `REINDEX` — the stored index values won't auto-update.
> 🐘 **PG Ref:** [Function volatility](https://www.postgresql.org/docs/current/xfunc-volatility.html) | [Indexes on expressions](https://www.postgresql.org/docs/current/indexes-expressional.html)
> 🔬 **DS Equivalent:** A cached/memoised transformation applied at index build time — similar to precomputing embeddings and storing them for fast lookup rather than recomputing on every query.

---

### Q10. Date Arithmetic for Admission Pattern Analysis
From `fact_patient_visits`, compute: (1) day of week for each admission, (2) whether it's a weekend, (3) time since last admission for the same patient (self-join or Phase 5 preview), (4) whether the interval between admissions is < 30 days (potential readmission indicator).

> 🔍 **Hint:** Tables: `fact_patient_visits` (self-join for previous admission). Concepts: `EXTRACT(DOW)`, arithmetic comparison, INTERVAL.

> 🪜 **Steps:**
> 1. `EXTRACT(DOW FROM arrival_datetime)` — 0=Sunday, 6=Saturday.
> 2. `CASE WHEN EXTRACT(DOW FROM arrival_datetime) IN (0,6) THEN true ELSE false END AS is_weekend`.
> 3. Self-join for previous: find the latest admission for same patient BEFORE current.
> 4. Days since last: `arrival_datetime - prev_arrival_datetime` → interval → `EXTRACT(EPOCH FROM ...)/86400`.
> 5. Flag: `days_since_last < 30 AS potential_readmission`.

> 📚 **Concept:** Temporal self-joins compute "time since previous event" — a key feature in medical research (readmission analysis) and predictive analytics (churn prediction, fraud detection). The pattern: `WHERE prev.patient_id = curr.patient_id AND prev.arrival_datetime < curr.arrival_datetime` finds all prior visits; adding `ORDER BY prev.arrival_datetime DESC LIMIT 1` gets the most recent. Phase 5's `LAG()` window function does this elegantly in one pass.
> 🐘 **PG Ref:** [Date/time arithmetic](https://www.postgresql.org/docs/current/functions-datetime.html)
> 🔬 **DS Equivalent:** `df.groupby('patient_id')['arrival_datetime'].diff()` — pandas diff() computes time between consecutive rows per group. Feature engineering for readmission prediction models.

---

## ⚫ Expert

---

### Q1. Custom Aggregate Function for Trimmed Mean
Create a PostgreSQL custom aggregate function `trimmed_mean(NUMERIC, NUMERIC)` that computes a 10% trimmed mean (excluding top and bottom 10% of values) on `treatment_cost` from `fact_patient_visits`. Compare with standard `AVG`.

> 🔍 **Hint:** Concepts: `CREATE AGGREGATE`, `SFUNC` (state transition), `FINALFUNC`, or use `percentile_cont` + filter approach as simpler alternative.

> 🪜 **Steps:**
> 1. Simpler approach: `SELECT AVG(treatment_cost) FROM (SELECT treatment_cost, PERCENT_RANK() OVER (ORDER BY treatment_cost) AS pct FROM fact_patient_visits) t WHERE pct BETWEEN 0.1 AND 0.9`.
> 2. Full custom aggregate: `CREATE AGGREGATE trimmed_mean(NUMERIC) (SFUNC = array_append, STYPE = NUMERIC[], FINALFUNC = trimmed_mean_final)`.
> 3. `CREATE FUNCTION trimmed_mean_final(arr NUMERIC[]) RETURNS NUMERIC` — sort, remove 10% each end, average remainder.

> 📚 **Concept:** Custom aggregates extend PostgreSQL with new GROUP BY-compatible functions. An aggregate requires: a state type (`STYPE`), a state transition function (`SFUNC` called for each row), and optionally a `FINALFUNC` to compute the final result from the accumulated state. The `PERCENT_RANK()` approach (using window functions) is simpler and sufficient for most needs. Custom aggregates are needed when window function workarounds become complex.
> 🐘 **PG Ref:** [User-defined aggregates](https://www.postgresql.org/docs/current/xaggr.html) | [CREATE AGGREGATE](https://www.postgresql.org/docs/current/sql-createaggregate.html)
> 🔬 **DS Equivalent:** `scipy.stats.trim_mean(arr, proportiontocut=0.1)` — the Python equivalent. Implementing it as a database aggregate enables trimmed means inside GROUP BY without exporting data.

---

### Q2. Text Search with tsvector and tsquery
Add a `search_vector TSVECTOR` generated column to `dim_hospital` populated from `hospital_name || ' ' || city || ' ' || archetype`. Create a GIN index on it. Query for hospitals matching 'teaching trauma cardiology'.

> 🔍 **Hint:** `to_tsvector('english', hospital_name || ' ' || COALESCE(archetype,''))`, `to_tsquery('teaching & trauma')`, `@@` match operator.

> 🪜 **Steps:**
> 1. `ALTER TABLE dim_hospital ADD COLUMN search_vector TSVECTOR GENERATED ALWAYS AS (to_tsvector('english', COALESCE(hospital_name,'') || ' ' || COALESCE(city,'') || ' ' || COALESCE(archetype,''))) STORED`.
> 2. `CREATE INDEX idx_hospital_fts ON dim_hospital USING gin(search_vector)`.
> 3. `SELECT hospital_name, city FROM dim_hospital WHERE search_vector @@ to_tsquery('english', 'teaching & trauma')`.
> 4. Use `ts_rank(search_vector, query)` for relevance scoring.

> 📚 **Concept:** `tsvector` is PostgreSQL's full-text search document type — a sorted list of lexemes (normalised words) with positions. `tsquery` is a search expression. The `@@` operator performs full-text match. GIN indexes make this O(log N) for millions of documents. Unlike ILIKE (substring match), full-text search handles stemming, stop words, and ranking. This is PostgreSQL's built-in Elasticsearch alternative for simple cases.
> 🐘 **PG Ref:** [Full-text search](https://www.postgresql.org/docs/current/textsearch.html) | [tsvector/tsquery](https://www.postgresql.org/docs/current/datatype-textsearch.html)
> 🔬 **DS Equivalent:** `sklearn.feature_extraction.text.TfidfVectorizer` — converting text to searchable vectors. PostgreSQL's `ts_rank` is equivalent to TF-IDF scoring within the database.

---

### Q3. Domain Type for Validated Medical Scores
Create three domain types: `score_0_10 AS NUMERIC CHECK (VALUE BETWEEN 0 AND 10)`, `satisfaction_score_t AS score_0_10`, `burnout_index_t AS NUMERIC CHECK (VALUE BETWEEN 0 AND 100)`. Apply them to validate incoming data and demonstrate how they enforce constraints schema-wide.

> 🔍 **Hint:** `CREATE DOMAIN score_0_10 AS NUMERIC(5,2) CHECK (VALUE BETWEEN 0 AND 10)`. Apply to a new staging table.

> 🪜 **Steps:**
> 1. `CREATE DOMAIN score_0_10 AS NUMERIC(5,2) CHECK (VALUE BETWEEN 0 AND 10)`.
> 2. `CREATE DOMAIN burnout_index_t AS NUMERIC(5,2) CHECK (VALUE BETWEEN 0 AND 100)`.
> 3. Create a test table using these domains: `CREATE TABLE staging_scores (visit_id VARCHAR(30), satisfaction score_0_10, burnout burnout_index_t)`.
> 4. Insert valid row — succeeds. Insert 11.0 for satisfaction — fails with constraint error.
> 5. `ALTER DOMAIN score_0_10 ADD CONSTRAINT ...` to further tighten the domain.

> 📚 **Concept:** `CREATE DOMAIN` defines a reusable constrained data type. All columns using it automatically inherit the CHECK constraint. When the business rule changes, you update the domain once — not every table. Domains are PostgreSQL-specific (not in SQL Server/MySQL). They're the DRY principle applied to data types — don't repeat constraint definitions across every table.
> 🐘 **PG Ref:** [CREATE DOMAIN](https://www.postgresql.org/docs/current/sql-createdomain.html)
> 🔬 **DS Equivalent:** Pydantic `conint(ge=0, le=10)` — a reusable validated type applied consistently across all models. The database-layer equivalent of Pydantic validators in Python.

---

### Q4. JSON Functions for Semi-Structured Data
The `dim_patient.chronic_conditions` column stores text. Suppose it were JSONB (e.g., `'["Diabetes","Hypertension","COPD"]'`). Demonstrate: extracting array elements, checking containment, aggregating by condition prevalence.

> 🔍 **Hint:** Concepts: `CAST(chronic_conditions AS jsonb)`, `jsonb_array_elements_text()`, `@>` containment operator.

> 🪜 **Steps:**
> 1. `ALTER TABLE dim_patient ADD COLUMN conditions_jsonb JSONB`.
> 2. `UPDATE SET conditions_jsonb = CASE WHEN chronic_conditions IS NOT NULL THEN ('["' || REPLACE(chronic_conditions, ',', '","') || '"]')::jsonb ELSE NULL END`.
> 3. `SELECT patient_id, jsonb_array_elements_text(conditions_jsonb) AS condition FROM dim_patient` — unnests array.
> 4. Find patients with Diabetes: `WHERE conditions_jsonb @> '["Diabetes"]'::jsonb`.
> 5. Count by condition: wrap in `GROUP BY condition`.

> 📚 **Concept:** PostgreSQL's JSONB type stores JSON as a binary, decomposed format — faster than TEXT-stored JSON. `jsonb_array_elements_text()` unnests a JSON array into rows (a set-returning function). The `@>` operator checks containment. A GIN index on a JSONB column enables fast containment queries. JSONB is ideal for semi-structured data like multi-valued medical conditions, tags, and flexible attributes.
> 🐘 **PG Ref:** [JSON functions](https://www.postgresql.org/docs/current/functions-json.html) | [JSONB](https://www.postgresql.org/docs/current/datatype-json.html)
> 🔬 **DS Equivalent:** `df['conditions_jsonb'].apply(json.loads)` then `.explode()` — unnesting JSON arrays in pandas. PostgreSQL's approach eliminates the Python layer entirely for set-scale queries.

---

### Q5. Floating-Point Precision Pitfalls in Healthcare Finance
Write queries demonstrating the difference between `FLOAT8` and `NUMERIC(12,4)` for financial calculations. Show: a sum of 10,000 small costs where FLOAT8 introduces rounding errors vs NUMERIC's exact arithmetic.

> 🔍 **Hint:** `SELECT SUM(cost::float8) vs SUM(cost::numeric(12,4))`. Generate 10,000 rows with `generate_series`.

> 🪜 **Steps:**
> 1. `CREATE TEMP TABLE float_test (cost FLOAT8, cost_n NUMERIC(12,4))`.
> 2. `INSERT INTO float_test SELECT 0.1::float8, 0.1::numeric(12,4) FROM generate_series(1,10000)`.
> 3. `SELECT SUM(cost), SUM(cost_n) FROM float_test` — observe difference.
> 4. `SELECT SUM(cost) = 1000.0, SUM(cost_n) = 1000.0 FROM float_test` — one is false.

> 📚 **Concept:** `FLOAT8` (double precision) uses binary floating-point — cannot exactly represent 0.1 in binary. 10,000 × 0.1 in FLOAT8 ≠ exactly 1000.0. `NUMERIC` uses exact decimal arithmetic — no floating-point error. In financial systems, ALWAYS use `NUMERIC(precision, scale)` for money values. In scientific computing where exact decimal values aren't needed, FLOAT8 is fine. The fact tables in this schema use `NUMERIC` correctly.
> 🐘 **PG Ref:** [Numeric types](https://www.postgresql.org/docs/current/datatype-numeric.html) | [Floating point](https://www.postgresql.org/docs/current/datatype-numeric.html#DATATYPE-FLOAT)
> 🔬 **DS Equivalent:** `0.1 + 0.2 != 0.3` in Python — classic floating-point issue. Use `decimal.Decimal` for exact arithmetic in Python. Pandas `Float64` dtype still uses IEEE 754 — use `object` dtype with `Decimal` for exact financial calculations.

---

## 💎 Super Expert
> No questions. These are curated topics to make you world-class in SQL functions.

---

### 🚀 What to Master After Phase 4

**1. PostgreSQL Extensions for Advanced Analytics**
`tablefunc` extension: `crosstab()` for server-side pivot tables — more efficient than UNION ALL unpivot/pivot patterns. `cube` extension: `ROLLUP`, `CUBE`, `GROUPING SETS` for multi-dimensional aggregation. `earthdistance`: Haversine distance calculations using the `latitude`/`longitude` columns already in your schema — find hospitals within X km of a postcode without exporting to Python.

**2. Array Functions — PostgreSQL's Hidden Power**
`ARRAY_AGG`, `UNNEST`, `ARRAY_LENGTH`, array slicing (`arr[1:3]`), `ANY(arr)`, `ALL(arr)`, `array_to_string`. Arrays eliminate the need for junction tables for simple multi-valued attributes. `intarray` extension adds fast GIN-indexed array operations. When: storing multi-valued attributes (patient conditions, diagnosis codes) without normalisation.

**3. Window Functions Composite Patterns (preview of Phase 5)**
`FILTER` clause with aggregates: `COUNT(*) FILTER (WHERE condition)` — conditional counting within GROUP BY without CASE WHEN. Available as both aggregate and window function form. Enables clean, readable conditional aggregation that replaces verbose CASE WHEN patterns.

**4. Temporal Tables (PostgreSQL 17+ / Bitemporal Modelling)**
PostgreSQL 17 introduces `WITHOUT OVERLAPS` constraint for temporal primary keys — enforcing non-overlapping valid_from/valid_to ranges without manual trigger logic. Combined with `FOR PORTION OF` for temporal updates. When available, this replaces the manual SCD Type 2 patterns built in Phase 2.

**5. PL/Python (plpython3u) — Python Logic Inside PostgreSQL**
Write functions in Python that run inside PostgreSQL: `CREATE FUNCTION score_patient() RETURNS NUMERIC LANGUAGE plpython3u`. Load scikit-learn models, call APIs, run pandas operations — all inside a SQL function. Enables ML scoring at the database layer without extracting data. When: real-time scoring pipelines, eliminating data extraction for batch scoring.

**6. Number Theory in SQL — Advanced Analytical Functions**
`width_bucket(val, min, max, n_buckets)` for histogram building. `generate_series` for Monte Carlo simulations. `random()` + `setseed()` for reproducible random sampling. `percent_rank()` and `cume_dist()` for distribution analysis. These enable statistical computations that traditionally required Python/R.

**7. Text Search Ranking — Beyond Simple Matching**
`ts_rank(vector, query)` and `ts_rank_cd(vector, query, normalization)` for relevance scoring. Cover density ranking (`ts_rank_cd`) accounts for the proximity of matching terms. `phraseto_tsquery()` for phrase matching. `websearch_to_tsquery()` for Google-style query parsing. These power search features in clinical knowledge bases and EHR systems.
