# Data Models

> [!NOTE]
> **YT Video**: [All about Data Model & Different Types](https://youtu.be/hd1sOmvEsU0)

## 1. Database Models Based on Relationship

![img](/docs/data-models/db-model-based-on-relationship.png)

As shown in **`db-model-based-on-relationship.png`**, this perspective categorizes databases by how they structurally represent relationships between different pieces of data.

* **Relational Model:** Data is stored in fixed-schema tables (rows and columns). Relationships are formed using shared keys (Primary Keys and Foreign Keys). This is the foundation of SQL databases like PostgreSQL and MySQL.
* **Object-based Model:** Combines database capabilities with object-oriented programming (OOP) principles. Data is represented as "objects" rather than tables, naturally supporting concepts like classes, inheritance, and encapsulation.
* **Semi-Structured Model:** Data does not conform to a rigid table format but contains markers or tags to separate semantic elements. Think of JSON or XML files where fields can vary from one record to the next.
* **Entity Model (often Entity-Relationship / ER Model):** An abstract, high-level conceptual model that uses entities (like a "User" or "Product") and relationships (like "Buys") to map out business logic visually before building the database.

---

## 2. Database Models Based on Stage

![img](/docs/data-models/db-model-based-on-stage.png)

As shown in **`db-model-based-on-stage.png`**, this represents the chronological **design lifecycle** of a database project. You move from abstract ideas to concrete code.

* **Conceptual Model (The "What"):** The initial high-level blueprint. It focuses entirely on defining the business entities and how they relate, completely independent of software or hardware constraints. It’s meant for communicating with non-technical stakeholders.
* **Logical Model (The "How, broadly"):** Adds technical structure to the conceptual model. Here, you define explicit attributes, primary/foreign keys, and data types, but you still haven't chosen a specific database software (e.g., it's a general relational plan, but not specifically optimized for PostgreSQL vs. Oracle).
* **Physical Model (The "Implementation"):** The actual database implementation script. This is tailored entirely to your chosen database engine. It includes specific data types, indexes, table partitions, constraints, and storage paths.

---

## 3. Database Models Based on Connection

![img](/docs/data-models/db-model-based-on-connection.png)

As shown in **`db-model-based-on-connection.png`**, this groups data models by the geometric or structural architecture of how data points link together.

* **Flat Model:** The simplest style. Data is stored in a single, two-dimensional array or plain text file (like a CSV or Excel sheet). There are no structural connections or relationships between different files.
* **Hierarchical Model:** Organizes data into a strict tree-like structure. Each child record has exactly one parent record (a 1-to-many relationship). Think of a file system (Folders contain sub-folders).
* **Network Model:** An evolution of the hierarchical model, but a child record can have *multiple* parent records (supporting many-to-many relationships). It forms a flexible graph structure rather than a strict tree.
* **Relational Model:** (Overlaps with the relationship perspective) Connects data dynamically using values in common columns rather than hardcoded physical pointers.
* **Star Model:** Highly optimized for data warehousing and analytics. It features a centralized, massive "Fact table" (containing quantitative metrics) surrounded by connected "Dimension tables" (containing descriptive attributes), resembling a star.
* **Snowflake Model:** A variation of the Star Model where the surrounding dimension tables are further normalized into sub-dimension tables. This reduces data redundancy, making the schema look like a more intricate snowflake.

---

*AI generated.