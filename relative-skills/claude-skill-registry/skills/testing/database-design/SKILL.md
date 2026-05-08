---
name: database-design
description: Guidelines for designing, implementing, and maintaining high-quality data models, ensuring data integrity, performance, and scalability.
version: 1.0.0
---

# Data Modeling & Design Maintenance

## 🎯 Purpose
To design, implement, and maintain high-quality data models that ensure data integrity, performance, and ease of use for downstream analytics and machine learning.

## 🏗️ Design Principles

### 1. Architectural Standards
- **Modular Design**: Use a layered approach (e.g., Bronze/Silver/Gold or Staging/Intermediate/Mart).
- **Star Schema Preference**: For BI layers, prioritize Fact and Dimension tables to optimize join performance and readability.
- **Idempotency**: Every transformation must be repeatable. If run multiple times with the same input, it must produce the same output.

### 2. Technical Requirements
- **Primary Keys**: Every table must have a defined Primary Key (composite or surrogate).
- **Naming Conventions**: Use snake_case. Prefix tables based on layer (e.g., stg_, fct_, dim_).
- **Data Types**: Use the most efficient types possible (e.g., INT vs BIGINT) and ensure consistent timestamp formats (UTC preferred).

## 🛠️ Implementation Workflow

### Step 1: Requirements Gathering
- Identify the grain of the table (e.g., "One row per transaction").
- Define the business logic for every calculated field.

### Step 2: DDL & Schema Design
- Apply constraints where supported (NOT NULL, UNIQUE).
- Document columns using descriptions within the code or yml files.

### Step 3: Orchestration Integration (Airflow 3.x)
- **Dynamic Task Mapping**: Use Airflow 3.x features to scale model processing across partitions.
- **Task Flow API**: Use decorators for Python-based transformations to maintain clean, readable DAGs.
- **Retries**: Configure sensible retry logic for transient failures during model builds.

## 🧹 Maintenance & Governance

### Quality Assurance
- **Schema Tests**: Run tests for null values, uniqueness, and referential integrity (e.g., using dbt tests or Airflow SQL sensors).
- **Volume Monitoring**: Alert if row counts deviate significantly from historical averages.

### Refactoring Logic
- **Impact Analysis**: Use lineage tools to identify which downstream reports will be affected by a schema change.

## 📝 Quality Checklist
- [ ] Is the grain clearly defined?
- [ ] Are all columns documented?
- [ ] Does the model handle incremental loads correctly?
- [ ] Have you verified the join logic doesn't cause fan-out (duplicate rows)?
