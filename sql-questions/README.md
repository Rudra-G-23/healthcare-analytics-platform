# Syllabus

Step-by-step journey to mastering SQL. The series is broken down into sequential phases, covering topics, subtopics, and the specific SQL commands discussed in each video. As requested, all project-based videos have been excluded from this list.

### Phase 1: Introduction and Environment Setup
*   **Course 1 & 2: Introduction to SQL**
    *   *Topic:* Learning paths and visual explanations of SQL.
    *   *Subtopics:* How to learn SQL effectively in 2025 and a visual breakdown of what SQL actually is.
*   **Course 3: Database Installation & Creation**
    *   *Topic:* Environment setup.
    *   *Subtopics:* Installing SQL Server and SQL Server Management Studio (SSMS) 2026, and creating your very first database.

### Phase 2: Core SQL Commands (DDL, DML, and Filtering)
*   **Course 4: Data Retrieval**
    *   *Topic:* SQL `SELECT` Queries.
    *   *Subtopics:* Essential clauses for beginners.
*   **Course 5: Data Definition Language (DDL)**
    *   *Topic:* Creating and modifying database structures.
    *   *Commands Used:* `CREATE`, `ALTER`, `DROP`.
*   **Course 6: Data Manipulation Language (DML)**
    *   *Topic:* Modifying data within tables.
    *   *Commands Used:* `INSERT`, `UPDATE`, `DELETE`.
*   **Course 7: Data Filtering**
    *   *Topic:* SQL `WHERE` Conditions.
    *   *Commands Used:* `AND`, `OR`, `NOT`, `LIKE`, `BETWEEN`, `IN`.

### Phase 3: Relational Data and Joins
*   **Course 8: Basic Joins**
    *   *Topic:* Combining data from two tables.
    *   *Commands Used:* `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL JOIN`.
*   **Course 9 & 10: Advanced Joins**
    *   *Topic:* Complex table relationships.
    *   *Commands Used:* `ANTI JOIN`, `CROSS JOIN`, and joining 3 or more tables simultaneously.
*   **Course 11: Set Operators**
    *   *Topic:* Combining result sets vertically.
    *   *Commands Used:* `UNION`, `UNION ALL`, `EXCEPT`, `INTERSECT`.

### Phase 4: SQL Functions and Conditional Logic
*   **Course 12, 13 & 14: String and Number Functions**
    *   *Topic:* Manipulating text and numeric data.
    *   *Commands Used:* `ROUND`, `ABS`, and a detailed guide on string manipulation functions.
*   **Course 15, 16 & 17: Date & Time Functions**
    *   *Topic:* Handling temporal data.
    *   *Commands Used:* `DATEPART`, `DATENAME`, `DATETRUNC`, `EOMONTH`, `FORMAT`, `CONVERT`, `CAST`, `DATEADD`, `DATEDIFF`, `ISDATE`.
*   **Course 18 & 19: Handling Missing Data**
    *   *Topic:* Managing `NULL` values vs. Empty Strings vs. Blank Spaces.
    *   *Commands Used:* `COALESCE`, `ISNULL`, `NULLIF`, `IS NULL`, `IS NOT NULL`.
*   **Course 20: Conditional Logic**
    *   *Topic:* If/Else logic in SQL.
    *   *Commands Used:* `CASE WHEN`.

### Phase 5: Data Aggregation and Window Functions
*   **Course 21: Basic Aggregation**
    *   *Topic:* Grouping and summarizing data.
    *   *Commands Used:* `COUNT`, `SUM`, `AVG`, `MAX`, `MIN`.
*   **Course 22: Window Functions Basics**
    *   *Topic:* Introduction to window functions.
    *   *Commands Used:* `PARTITION BY`, `ORDER BY`, `FRAME`.
*   **Course 23: Aggregate Window Functions**
    *   *Topic:* Using standard aggregations over a specific window of rows.
    *   *Commands Used:* `COUNT`, `AVG`, `SUM`, `MAX`, `MIN` (as window functions).
*   **Course 24: Ranking Window Functions**
    *   *Topic:* Assigning ranks and organizing data.
    *   *Commands Used:* `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`.
*   **Course 25: Value Window Functions**
    *   *Topic:* Accessing data from other rows.
    *   *Commands Used:* `LEAD`, `LAG`, `FIRST_VALUE`, `LAST_VALUE`.

### Phase 6: Advanced Querying Techniques
*   **Course 26 & 27: Subqueries**
    *   *Topic:* Nesting queries inside other queries.
    *   *Subtopics:* Complete guide covering Correlated Subqueries and 5 essential techniques for every project.
*   **Course 28 & 29: CTEs and Views**
    *   *Topic:* Creating readable and reusable queries.
    *   *Commands Used:* `WITH` Clause (for Common Table Expressions) and `CREATE VIEW` (covering 6 top use cases).
*   **Course 30, 31 & 32: Temporary Data Storage & Comparison**
    *   *Topic:* Creating tables from queries and managing temporary data.
    *   *Commands Used:* CTAS (Create Table As Select) and Temporary Tables.
    *   *Subtopics:* A visual comparison of Subqueries vs. CTEs vs. Views vs. CTAS vs. Temp Tables to know when to use which.

### Phase 7: Automation, Performance Optimization, and Indexing
*   **Course 33 & 34: Programmability**
    *   *Topic:* Automating processes and auditing.
    *   *Commands/Concepts Used:* Stored Procedures and Triggers (specifically for Audit Logs).
*   **Course 35 & 36: Indexing Basics**
    *   *Topic:* Speeding up database queries.
    *   *Subtopics:* Clustered vs. Nonclustered indexes, Columnstore vs. Rowstore indexes.
*   **Course 37, 38 & 39: Advanced Indexing & Maintenance**
    *   *Topic:* Creating specialized indexes and maintaining database health.
    *   *Subtopics:* Unique & Filtered Indexes, choosing the right index, and 5 maintenance tasks including updating SQL Statistics.
*   **Course 40 & 41: Query Execution and Strategy**
    *   *Topic:* Analyzing performance.
    *   *Subtopics:* Reading Execution Plans, applying SQL Hints, and formulating a professional indexing strategy.
*   **Course 42: Large Data Optimization**
    *   *Topic:* Handling massive tables.
    *   *Commands/Concepts Used:* SQL Table Partitioning to optimize big table performance.

### Phase 8: Expert Tips & AI Integration
*   **Course 43: Expert Advice**
    *   *Topic:* 30 SQL tips and tricks derived from 18 years of experience.
*   **Course 44: AI Tools**
    *   *Topic:* Modern coding assistance.
    *   *Subtopics:* How to integrate ChatGPT and GitHub Copilot into your SQL projects.


## Relationships

- **fact_staffing to fact_patient_visits**: one_to_one
- **fact_patient_visits to fact_financials**: one_to_one
- **fact_staffing to fact_financials**: one_to_one
- **dim_patient to fact_patient_visits**: one_to_many
- **dim_region to dim_hospital**: one_to_many
- **fact_patient_visits to dim_doctor**: many_to_one
- **dim_hospital to fact_financials**: one_to_many
- **fact_patient_visits to dim_diagnosis**: many_to_one
- **fact_patient_visits to dim_department**: many_to_one
- **fact_staffing to dim_department**: many_to_one