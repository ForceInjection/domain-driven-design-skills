---
name: neo4j-cypher
description: Expert guidance for Neo4j Cypher queries and MCP server tools. Use when working with mcp__neo4j__ tools for query execution, schema introspection, and graph operations.
---

<objective>
Master the Neo4j MCP (Model Context Protocol) server tools for efficient graph database development. These tools provide direct integration with Neo4j databases, enabling query execution, schema introspection, and graph exploration without manual connection management.
</objective>

<quick_start>
<common_workflows>
**Execute Cypher queries:**
```
mcp__neo4j__get_schema → Understand structure
mcp__neo4j__execute_query → Run Cypher
```

**Explore graph schema:**
```
mcp__neo4j__get_schema → Get labels, relationships, constraints
```

**Data modeling workflow:**
```
mcp__neo4j__get_schema → Current state
[design changes]
mcp__neo4j__execute_query → Apply constraints/indexes
mcp__neo4j__get_schema → Verify changes
```
</common_workflows>
</quick_start>

<mcp_tools>
<neo4j_mcp_tools>
**Core Neo4j MCP Tools:**

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `mcp__neo4j__execute_query` | Execute Cypher queries (read/write) | All database operations |
| `mcp__neo4j__get_schema` | Get database schema (labels, relationships, constraints) | Before writing queries, understanding structure |

**Tool Usage:**

```
mcp__neo4j__get_schema
→ Returns: node labels, relationship types, property keys, constraints, indexes

mcp__neo4j__execute_query
→ Input: Cypher query string
→ Returns: Query results as JSON
```

**Best Practices:**
- ALWAYS call `get_schema` before writing complex queries
- Use schema info to validate label/relationship names
- Check for existing constraints before creating new ones
- Verify indexes exist for query predicates
</neo4j_mcp_tools>

<advanced_mcp_servers>
**Additional Neo4j MCP Servers (if available):**

| Server | Purpose |
|--------|---------|
| `mcp-neo4j-cypher` | Query execution with natural language support |
| `mcp-neo4j-memory` | Knowledge graph storage across sessions |
| `mcp-neo4j-aura` | Aura cloud instance management |
| `mcp-neo4j-modeler` | Data model validation and visualization |

Check available tools with your MCP client to see which servers are configured.
</advanced_mcp_servers>
</mcp_tools>

<workflows>
<query_workflow>
**Query Development Workflow:**

```
1. Get schema context
   mcp__neo4j__get_schema → Understand labels, relationships

2. Write query using correct names
   - Use exact label names from schema
   - Use correct relationship types
   - Reference indexed properties

3. Execute query
   mcp__neo4j__execute_query → Run Cypher

4. Verify results
   - Check returned structure
   - Validate data types
```
</query_workflow>

<schema_change_workflow>
**Schema Change Workflow:**

```
1. Check current state
   mcp__neo4j__get_schema → Current constraints/indexes

2. Apply changes
   mcp__neo4j__execute_query → CREATE CONSTRAINT/INDEX

3. Verify changes
   mcp__neo4j__get_schema → Confirm new constraints
```
</schema_change_workflow>
</workflows>

<cypher_reference>
## Node Patterns

```cypher
(n)                          -- Any node
(n:Label)                    -- Node with label
(n:Label {prop: value})      -- Node with property
(n:Label:OtherLabel)         -- Multiple labels
```

## Relationship Patterns

```cypher
-[r]->                       -- Directed relationship
-[r:TYPE]->                  -- With type
-[r:TYPE {prop: value}]->    -- With property
-[r:TYPE*1..3]->             -- Variable length (1-3 hops)
-[r]- or -[r]-               -- Undirected
```

## CRUD Operations

```cypher
-- Create
CREATE (n:Person {name: 'Alice'})
CREATE (a)-[:KNOWS]->(b)

-- Read
MATCH (n:Person) RETURN n
MATCH (a)-[:KNOWS]->(b) RETURN a, b

-- Update
MATCH (n:Person {name: 'Alice'})
SET n.age = 30

-- Delete
MATCH (n:Person {name: 'Alice'})
DETACH DELETE n
```

## Merge (Idempotent Create)

```cypher
MERGE (n:Person {id: $id})
ON CREATE SET n.created = datetime()
ON MATCH SET n.updated = datetime()
```

## Filtering

```cypher
WHERE n.age > 18
WHERE n.name STARTS WITH 'A'
WHERE n.name CONTAINS 'ice'
WHERE n.status IN ['active', 'pending']
WHERE (n)-[:KNOWS]->()
WHERE NOT EXISTS { (n)-[:BLOCKED]->() }
```

## Aggregations

```cypher
count(n)
sum(n.value)
avg(n.value)
collect(n.name)           -- List
min(n.value), max(n.value)
```

## Path Queries

```cypher
-- Shortest path
MATCH path = shortestPath((a)-[*]-(b))
RETURN path

-- All shortest paths
MATCH path = allShortestPaths((a)-[*]-(b))
RETURN path
```

## Common Clauses

```cypher
WITH      -- Chain queries, aggregate
ORDER BY  -- Sort results
LIMIT     -- Limit results
SKIP      -- Offset results
UNWIND    -- Expand list to rows
UNION     -- Combine result sets
```

## Indexes and Constraints

```cypher
-- Index
CREATE INDEX idx_name FOR (n:Label) ON (n.prop)

-- Unique constraint
CREATE CONSTRAINT unique_email
FOR (u:User) REQUIRE u.email IS UNIQUE

-- Existence constraint
CREATE CONSTRAINT email_exists
FOR (u:User) REQUIRE u.email IS NOT NULL
```

## Parameters

```cypher
-- Always use parameters (not string interpolation)
MATCH (u:User {email: $email})
RETURN u
```

## Useful Functions

```cypher
-- String
toLower(), toUpper(), trim(), split()

-- Type conversion
toInteger(), toFloat(), toString()

-- Date/Time
date(), datetime(), time(), duration()

-- Collections
size(), head(), tail(), range()

-- Aggregation
count(), sum(), avg(), collect()
```
</cypher_reference>

<anti_patterns>
**Common Mistakes:**

- **Guessing label names** → Always check schema first
- **Skipping schema validation** → Queries fail on wrong names
- **Not checking indexes** → Slow queries without index hints
- **Ignoring constraints** → Duplicate data issues

**Correct Order:**
```
mcp__neo4j__get_schema → [write query] → mcp__neo4j__execute_query → [verify]
```
</anti_patterns>

<success_criteria>
MCP tool usage is correct when:

- `get_schema` called before writing queries to unknown databases
- Query uses exact label/relationship names from schema
- Constraints verified before data modifications
- Results validated against expected structure

**Uncertainty Handling:**
- If schema is unclear, call `get_schema` again
- If query fails, check error message for typos in names
- NEVER guess at label or relationship names
</success_criteria>
