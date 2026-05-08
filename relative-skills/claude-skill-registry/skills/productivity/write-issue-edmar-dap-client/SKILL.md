---
name: write-issue
description: Create or update project issues following the standardized format with Functional Specifications (Preconditions/Workflow/Postconditions), Technical Specifications, and hierarchical task lists. Use when user asks to create/update an issue, document requirements, or write specifications for a new feature.
---

# Write Issue

## Overview

This skill helps create and update project issues that combine behavioral specifications with technical implementation details. Issues written in this format serve as both documentation and implementation guides, with functional specs that translate directly into behavioral tests using the PreDB/PostDB pattern.

## Issue Structure

Issues follow this format:

```markdown
# ISSUE-ID Title

Brief description.

# Functional Specifications

## Scenario Name

### Preconditions
[CSV-like database state]

### Workflow
* Call `class.method(args)`
* [What happens step by step]

### Postconditions
[Expected database state]

---

# Technical Specifications

## Database Schema
[Drizzle ORM schema code]

## Class Structure
[Implementation skeleton]

## Tasks
- [ ] Category
  - [ ] Specific task
```

## Workflow for Creating Issues

### 1. Check Current Implementation

**Before writing the issue, analyze what already exists:**

1. **Search for related files:**
   - Check if agent/feature files exist (e.g., `agents/judge/judge.ts`)
   - Look for existing tests (e.g., `agents/judge/tests/*.test.ts`)
   - Review database schema (`db/schema.ts`)

2. **Review existing code:**
   - Read any existing implementation files
   - Check what's already implemented vs. what's missing
   - Note patterns and conventions used in the codebase
   - Identify dependencies (e.g., which AI models, embedding dimensions)

3. **Align with current state:**
   - Match existing naming conventions
   - Use same dependencies and libraries
   - Follow established patterns (e.g., test structure, database types)
   - Identify gaps between spec and current implementation

**Example checks:**
- If writing Judge issue, check: Dreamer implementation for AI model choices, embedding dimensions, test patterns
- If related tables exist in schema, note their structure and relationships
- Check environment configuration for API keys and database setup

### 2. Gather Context

Determine:
- **Issue ID**: Format `INF-X` where X is the issue number
- **Feature**: What is being implemented
- **Purpose**: One-line description
- **File Path**: `docs/issues/[issue-id]-[kebab-case-title].md`

If information is missing, ask the user before proceeding.

### 3. Write Functional Specifications

Define **what** the system should do behaviorally. Each scenario becomes a test case.

**Scenario format:**
```markdown
## [Action] [context/condition]

### Preconditions
table_name:
column1, column2, column3
value1, value2, value3

(or for empty tables)
table_name:
(empty table)

### Workflow
* Call `className.methodName(args)`
* [Step describing what happens]
* Returns [object/value]

### Postconditions
table_name:
column1, column2, column3
existing_value1, existing_value2, new_value
```

**Key points:**
- Use CSV-like format for database tables (headers, then data rows)
- Use placeholders: `<uuid>`, `<timestamp>`, `<vector>`, `<1536-dim vector>`
- First workflow bullet specifies the method call
- Workflow describes behavior, not implementation
- Postconditions include both pre-existing and new rows
- **Keep it simple**: Start with 2-3 essential scenarios, not more

**Essential scenario patterns (pick 2-3):**
1. **Primary use case** - The main, expected scenario (this is usually NOT the empty database case)
2. **One key edge case** - The most important boundary condition, error case, or alternative path
3. **Optional second edge case** - Only if absolutely critical (e.g., empty state if it behaves differently)

**Avoid over-specification:**
- Don't create scenarios for every possible edge case
- Focus on the primary behavior path and the most important edge case
- Empty database is often an edge case, not the main use case
- More scenarios = more work without proportional value

### 4. Write Technical Specifications

Define **how** to implement the feature.

**Include:**

**Database Schema** (if needed):
```typescript
export const tableName = sqliteTable('table_name', {
  id: text('id').primaryKey(),
  field: text('field').notNull(),
  createdAt: integer('created_at', { mode: 'timestamp' })
    .notNull()
    .default(sql`(unixepoch())`),
});

export type InsertTableName = typeof tableName.$inferInsert;
export type SelectTableName = typeof tableName.$inferSelect;
```

**Class Structure**:
```typescript
export class ClassName {
  constructor(
    private readonly db: Database,
    // other dependencies
  ) {}

  async mainMethod(): Promise<ReturnType> {
    // 1. [Step description]
    // 2. [Step description]
    return result;
  }

  private async helperMethod(): Promise<Type> {
    // [Purpose]
  }
}
```

**Additional details** (as needed):
- LLM prompts (if using AI models)
- Algorithms or complex logic
- External integrations
- Configuration requirements

### 5. Write Tasks

Break down implementation into trackable tasks using markdown checkboxes.

**Structure:**
```markdown
## Tasks

- [ ] High-level category 1
  - [ ] Specific task 1.1
  - [ ] Specific task 1.2
- [ ] High-level category 2
  - [ ] Specific task 2.1
```

**Typical task order:**
1. Schema/Database (create tables, migrations)
2. Core Implementation (class, methods)
3. Integrations (LLM, APIs)
4. Tests (behavioral tests for all scenarios)

**Task guidelines:**
- Make tasks specific and actionable
- Use verbs: Create, Implement, Add, Set up
- Include method names or file names
- Order by dependency
- Each scenario should have a corresponding test task

### 6. Create or Update File

**For new issues:**
Use Write tool with path `docs/issues/[issue-id]-[kebab-case-title].md`

**For updating existing issues:**
1. Read the existing file first
2. Use Edit tool for targeted changes

### 7. Validate

Check:
- [ ] **2-3 scenarios maximum** covering primary use case + key edge cases
- [ ] Each scenario has Preconditions/Workflow/Postconditions
- [ ] Placeholders used for generated values
- [ ] Database schema included if needed
- [ ] Class structure shows main methods
- [ ] Tasks are specific and ordered by dependency
- [ ] Each scenario has a test task

## Usage with Other Skills

**write-unit-test skill:**
Functional Specifications can be directly used with write-unit-test to generate behavioral tests. The Preconditions/Workflow/Postconditions format maps to PreDB/Execute/PostDB pattern.

## Reference

See `references/issue-example.md` for a complete example showing:
- Multiple scenarios with different precondition states
- Proper use of placeholders
- Technical specifications with schema, class structure, and LLM prompts
- Hierarchical task breakdown
