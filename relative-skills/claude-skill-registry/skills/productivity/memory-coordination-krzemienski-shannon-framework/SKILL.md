---
name: memory-coordination
description: |
  Coordinates Serena MCP knowledge graph operations for Shannon Framework. Enforces standardized
  entity naming (shannon/* namespace), relation creation patterns, search protocols, and observation
  management. Prevents orphaned entities, naming chaos, and broken context lineage. Use when: storing
  specs/waves/goals/checkpoints, querying Shannon history, managing knowledge graph structure,
  ensuring cross-wave context preservation.

skill-type: PROTOCOL
shannon-version: ">=4.0.0"

mcp-requirements:
  required:
    - name: serena
      version: ">=2.0.0"
      purpose: Knowledge graph storage for Shannon context
      fallback: none
      degradation: critical
  recommended: []

required-sub-skills: []
optional-sub-skills: []

allowed-tools: Serena
---

# Memory Coordination

## Overview

**Purpose**: Memory Coordination is Shannon's protocol for structured Serena MCP operations. It enforces standardized entity naming (shannon/* namespace), mandatory relation creation, consistent search patterns, and proper observation management to maintain a clean, queryable knowledge graph across all waves and sessions.

**When to Use**:
- Storing ANY Shannon artifact (spec, wave, goal, checkpoint, SITREP)
- Querying Shannon history (waves, checkpoints, specs)
- Creating entities for Shannon context preservation
- Updating existing entities with new information
- Establishing relations between Shannon entities
- Searching Shannon knowledge graph

**Expected Outcomes**:
- Standardized entity names with shannon/* namespace
- Complete relational graph (no orphaned entities)
- Efficient queries using consistent patterns
- Cross-wave context preservation
- Zero data duplication via observations
- Clean knowledge graph structure

**Duration**: 10-30 seconds per operation

---

## Anti-Rationalization (From Baseline Testing)

**CRITICAL**: Agents systematically rationalize skipping memory-coordination protocols. Below are the 6 most common rationalizations detected in baseline testing, with mandatory counters.

### Rationalization 1: "Entity name seems fine"
**Example**: Agent creates entity named "spec_data" or "MyAnalysis" without shannon/ prefix

**COUNTER**:
- ❌ **NEVER** create Shannon entities without shannon/* namespace
- ✅ ALL Shannon entities MUST start with shannon/
- ✅ Use standard namespaces: shannon/specs/, shannon/waves/, shannon/goals/, shannon/checkpoints/, shannon/sitreps/
- ✅ If name lacks shannon/ prefix, it's WRONG

**Rule**: All Shannon entities have shannon/* namespace. No exceptions.

### Rationalization 2: "Relations not needed for this entity"
**Example**: Agent creates wave entity without relating it to spec

**COUNTER**:
- ❌ **NEVER** create standalone Shannon entities
- ✅ EVERY entity has at least 1 relation (usually to parent or creator)
- ✅ Spec -> spawns -> Wave, Wave -> contains -> Task, Wave -> created_checkpoint -> Checkpoint
- ✅ Orphaned entities = broken context lineage

**Rule**: Create relations. Every entity connects to graph.

### Rationalization 3: "Search query seems reasonable"
**Example**: Agent searches with random queries: "wave", "Wave 1", "waves", "show waves"

**COUNTER**:
- ❌ **NEVER** use free-form search queries for Shannon entities
- ✅ Use EXACT search patterns defined in this skill
- ✅ Search specs: search_nodes("shannon/specs/")
- ✅ Search waves: search_nodes("shannon/waves/")
- ✅ Consistency = efficiency

**Rule**: Use protocol search patterns. Not creative queries.

### Rationalization 4: "Create new entity for update"
**Example**: Agent creates "spec_002" to update "spec_001" instead of adding observations

**COUNTER**:
- ❌ **NEVER** create new entity to update existing entity
- ✅ Use add_observations for updates
- ✅ Creating duplicate entities = data chaos
- ✅ Example: WRONG: create_entities("spec_002"), RIGHT: add_observations("spec_001", ["new info"])

**Rule**: Updates use add_observations, not create_entities.

### Rationalization 5: "Namespace collision unlikely"
**Example**: Agent creates "goal" entity in root namespace (not shannon/goals/)

**COUNTER**:
- ❌ **NEVER** create Shannon entities in root namespace
- ✅ shannon/* namespace prevents collision with user project entities
- ✅ User might have "goal" entity for their app -> collision = corruption
- ✅ shannon/goals/goal_001 = isolated, safe

**Rule**: shannon/* namespace mandatory. Prevents collisions.

### Rationalization 6: "Manual filtering faster than search"
**Example**: Agent calls read_graph() then manually filters for waves

**COUNTER**:
- ❌ **NEVER** read full graph then filter manually
- ✅ Use search_nodes() with namespace prefix (efficient, targeted)
- ✅ read_graph() loads ENTIRE graph (100-1000+ entities)
- ✅ search_nodes("shannon/waves/") returns only waves (5-20 entities)
- ✅ Manual filtering = wasted tokens + time

**Rule**: Use search_nodes with namespace. Never read_graph for queries.

### Detection Signal
**If you're tempted to**:
- Create entity without shannon/ prefix
- Skip creating relations
- Use custom search query
- Create new entity for update
- Use root namespace
- Read full graph then filter

**Then you are rationalizing.** Stop. Apply the protocol. Follow the rules.

---

## When to Use

Use this skill when:
- **Storing Shannon artifacts**: Specs, waves, goals, checkpoints, SITREPs
- **Querying Shannon history**: "Show me all waves", "Find spec for this wave"
- **Creating Shannon entities**: Any Shannon data needs persistence
- **Updating Shannon entities**: Wave status change, checkpoint metadata update
- **Establishing relations**: Link wave to spec, checkpoint to wave, goal to spec
- **Searching Shannon graph**: Find entities by namespace, type, or timestamp
- **Context preservation**: Before wave transitions, session end, context limits
- **SITREP coordination**: Storing multi-agent progress reports

DO NOT use when:
- Storing user project data (use user namespace, not shannon/*)
- Non-Shannon workflows (generic Serena operations)
- Temporary data that doesn't need persistence
- Data that should be in project files instead of knowledge graph

---

## Inputs

**Required:**
- `operation_type` (string): Serena operation to perform
  - Options: `"create"`, `"read"`, `"update"`, `"search"`, `"relate"`, `"delete"`
- `entity_data` (object): Data for the operation
  ```json
  {
    "type": "spec" | "wave" | "goal" | "checkpoint" | "sitrep" | "task",
    "data": {
      "complexity_score": 0.68,
      "domain_percentages": {...},
      "execution_strategy": "wave-based"
    },
    "timestamp": "20250104_143022"
  }
  ```

**Optional (operation-specific):**
- `entity_name` (string): For read/update/delete operations
  - Example: `"shannon/specs/spec_20250104_143022"`
- `search_pattern` (string): For search operations
  - Example: `"shannon/waves/"` (all waves)
  - Example: `"shannon/checkpoints/cp_20250104"` (date-filtered)
- `parent_entity` (string): For create operations (establishes relation)
  - Example: `"shannon/specs/spec_001"` (wave's parent)
- `relation_type` (string): For relate operations
  - Options: `"spawns"`, `"contains"`, `"tracks"`, `"created_checkpoint"`, `"implements"`, `"reports_on"`, `"relates_to"`
- `observations` (array): For create/update operations
  - Example: `["type: spec_analysis", "created: 2025-01-04T14:30:22Z", "complexity_score: 0.68"]`

---

## Core Competencies

### 1. Shannon Namespace Management
- **Namespace Structure**: shannon/specs/, shannon/waves/, shannon/goals/, shannon/checkpoints/, shannon/sitreps/
- **Entity Naming**: Standardized formats with timestamps or IDs
- **Collision Prevention**: shannon/* isolates Shannon entities from user project
- **Queryability**: Namespace prefix enables efficient targeted searches
- **Organization**: Clear hierarchy (specs -> waves -> tasks -> checkpoints)

### 2. Entity CRUD Operations
- **Create**: create_entities with shannon/* namespace, initial observations
- **Read**: search_nodes or open_nodes with specific entity names
- **Update**: add_observations to existing entities (NEVER create new entity)
- **Delete**: delete_entities (rare, only for cleanup or mistakes)
- **Validation**: Verify entity name format before creation

### 3. Relation Management
- **Standard Relations**: spawns, contains, tracks, created_checkpoint, implements, relates_to
- **Mandatory Relations**: EVERY entity connects to at least 1 other entity
- **Relation Naming**: Active voice (spec "spawns" wave, wave "contains" task)
- **Bidirectional Context**: Relations enable traversal (wave -> spec, checkpoint -> wave)
- **Orphan Prevention**: No standalone entities

### 4. Search Patterns
- **Namespace Search**: search_nodes("shannon/specs/") for all specs
- **Specific Entity**: open_nodes(["shannon/specs/spec_001"]) for exact entity
- **Pattern Matching**: search_nodes("shannon/waves/wave_2025") for date-filtered waves
- **Never Full Graph**: Avoid read_graph() except for full visualization
- **Result Limits**: Use search efficiently, narrow queries

### 5. Observation Management
- **Initial Observations**: Include type, creation_date, purpose, metadata
- **Updates**: add_observations for new information (status, progress, notes)
- **No Duplicates**: Never create new entity to update (use observations)
- **Structured Data**: Store JSON or key-value pairs in observations
- **Timestamped**: Include timestamp in observation content

---

## Workflow

### Step 1: Determine Entity Type
**Input**: Data to store (spec, wave, goal, checkpoint, SITREP)

**Processing**:
1. Identify entity type from data structure or user intent
   - If ambiguous, check context:
     * In spec analysis phase? -> shannon/specs/
     * Tracking wave progress? -> shannon/waves/
     * Setting goals? -> shannon/goals/
   - If still unclear, ASK USER: "Should I store this as spec, wave, goal, or checkpoint?"
   - NEVER default to root namespace or random name

2. Map to Shannon namespace:
   - Specification -> shannon/specs/
   - Wave -> shannon/waves/
   - Goal -> shannon/goals/
   - Checkpoint -> shannon/checkpoints/
   - SITREP -> shannon/sitreps/
   - Task -> shannon/tasks/ (usually nested under wave)

3. Generate timestamp (MANDATORY FORMAT):
   - Format: YYYYMMdd_HHmmss
   - Example: 20250104_143022 (2025-01-04 14:30:22)
   - WHY: Sortable (alphabetical = chronological), consistent, query-safe
   ```javascript
   const timestamp = new Date().toISOString()
     .replace(/[-:]/g, '')
     .replace('T', '_')
     .split('.')[0];
   // Result: 20250104_143022
   ```
   - NEVER use: ISO 8601 in name, human-readable dates, Unix timestamps

4. Sanitize entity name:
   - Replace spaces with underscores: "E-commerce / Payment" -> "E-commerce_Payment"
   - Remove forward slashes: "/" -> ""
   - Lowercase: "Gateway" -> "gateway"
   - Final: shannon/specs/e-commerce_payment_gateway_20250104_143022
   - NEVER include spaces or "/" in entity names (breaks queries)

**Output**: Full entity name (e.g., shannon/specs/spec_20250104_143022)

**Duration**: 1 second

### Step 2: Create Entity with Standard Format
**Input**: Entity name, entity type, data

**Processing**:
1. Structure observations as list of strings:
   ```
   [
     "type: [entity_type]",
     "created: [ISO timestamp]",
     "purpose: [description]",
     "[key]: [value]",
     "[serialized JSON if complex data]"
   ]
   ```
2. Call create_entities:
   ```javascript
   create_entities({
     entities: [{
       name: "shannon/specs/spec_20250104_143022",
       entityType: "Specification",
       observations: [
         "type: spec_analysis",
         "created: 2025-01-04T14:30:22Z",
         "complexity_score: 0.68",
         "domain: Frontend 38%, Backend 35%, Database 27%",
         "execution_strategy: wave-based",
         "JSON: {...full analysis...}"
       ]
     }]
   })
   ```
3. Verify creation successful

**Output**: Entity created, entity name

**Duration**: 2-3 seconds

### Step 3: Create Mandatory Relations
**Input**: New entity name, related entities

**Processing**:
1. Identify parent or related entities:
   - Spec -> None (root entity)
   - Wave -> Spec (spawned from)
   - Task -> Wave (contained in)
   - Checkpoint -> Wave (created during)
   - Goal -> Spec (implements)
   - SITREP -> Wave (reports on)

2. Determine relation type (active voice) with VALIDATION:
   **APPROVED RELATION TYPES**:
   - spawns (spec -> wave)
   - contains (wave -> task)
   - created_checkpoint (wave -> checkpoint)
   - implements (goal -> spec)
   - reports_on (sitrep -> wave)
   - tracks (goal -> wave)
   - relates_to (general purpose)

   **VALIDATION** (prevent typos):
   ```javascript
   const approved = ["spawns", "contains", "created_checkpoint",
                     "implements", "reports_on", "tracks", "relates_to"];
   if (!approved.includes(relationType)) {
     throw Error(`Invalid relationType: ${relationType}. Use one of: ${approved.join(', ')}`);
   }
   ```

3. Call create_relations:
   **For SINGLE entity**:
   ```javascript
   create_relations({
     relations: [{
       from: "shannon/specs/spec_001",
       to: "shannon/waves/wave_001",
       relationType: "spawns"
     }]
   })
   ```

   **For BULK operations (50+ entities)**:
   ```javascript
   // Create ALL relations in ONE call (not 50 separate calls)
   create_relations({
     relations: [
       {from: "shannon/waves/wave_001", to: "shannon/tasks/task_001", relationType: "contains"},
       {from: "shannon/waves/wave_001", to: "shannon/tasks/task_002", relationType: "contains"},
       // ... 48 more relations
     ]
   })
   ```

4. Verify relation created

**Output**: Relations established, connected graph

**Duration**: 1-2 seconds

### Step 4: Search Using Standard Patterns
**Input**: Query intent (e.g., "find all waves", "get spec_001", "list checkpoints")

**Processing**:
1. Map intent to search pattern:
   - "All [type]" -> search_nodes("shannon/[type]s/")
   - "Specific entity" -> open_nodes(["shannon/[type]s/[name]"])
   - "Recent [type]" -> search_nodes("shannon/[type]s/[date_pattern]")

2. Execute search with NAMESPACE PRECISION:
   ```javascript
   // CORRECT: Full namespace
   search_nodes("shannon/waves/")
   open_nodes(["shannon/specs/spec_20250104_143022"])

   // CORRECT: Recent checkpoints (2025-01-04)
   search_nodes("shannon/checkpoints/cp_20250104")

   // WRONG: Partial match (might hit user entities)
   search_nodes("spec_")  // ❌ Could match user project entity "spec_data"
   search_nodes("wave")   // ❌ Ambiguous, no namespace

   // WRONG: Root namespace query
   search_nodes("spec_001")  // ❌ Missing shannon/specs/ prefix
   ```

   **RULE**: Always use FULL shannon/* path. Never partial match.

3. Parse results

**Output**: Matching entities with observations

**Duration**: 1-2 seconds

### Step 5: Update via Observations
**Input**: Entity name, new information

**Processing**:
1. **MANDATORY VERIFICATION** (prevent errors):
   ```javascript
   // ALWAYS verify entity exists BEFORE add_observations
   const entity = open_nodes(["shannon/waves/wave_001"]);
   if (!entity || entity.length === 0) {
     throw Error("Cannot update: entity shannon/waves/wave_001 not found");
   }
   ```
   If entity missing:
   - Create it first (if should exist)
   - Report error to user (if unexpected)

2. Structure new observations:
   ```
   [
     "updated: [ISO timestamp]",
     "status: [new status]",
     "[new_key]: [new_value]"
   ]
   ```

3. Call add_observations:
   ```javascript
   add_observations({
     observations: [{
       entityName: "shannon/waves/wave_001",
       contents: [
         "updated: 2025-01-04T15:00:00Z",
         "status: Phase 2 complete",
         "progress: 60%",
         "next_action: Begin Phase 3 implementation"
       ]
     }]
   })
   ```

4. **OBSERVATION LIMITS** (prevent overflow):
   - Maximum ~100 observations per entity (guideline)
   - If approaching limit, consider:
     * Creating checkpoint entity (snapshot current state)
     * Creating sub-entities (wave_001_phase2, wave_001_phase3)
     * Archiving old observations (delete_observations)
   - WHY: Large lists slow queries, hard to parse
   - Better: Structured sub-entities with relations

5. Verify update successful

**Output**: Entity updated with new observations

**Duration**: 2-3 seconds

### Step 6: Validate Graph Structure
**Input**: Recent operations

**Processing**:
1. Check entity naming:
   - All Shannon entities have shannon/* prefix? ✅
   - No typos in namespace (shannon/spec/ instead of shannon/specs/)? ✅

2. Check relations:
   - Every new entity has >=1 relation? ✅
   - Relations use active voice? ✅
   - No orphaned entities? ✅

3. Check operations:
   - Used add_observations for updates (not create_entities)? ✅
   - Used search_nodes (not read_graph) for queries? ✅
   - No duplicate entities? ✅

**Output**: Validation pass/fail, corrections if needed

**Duration**: 5 seconds

---

## MCP Integration

### Required MCPs

**Serena MCP** (MANDATORY)
- **Purpose**: Shannon's primary context preservation mechanism; stores all specs, waves, goals, checkpoints in persistent knowledge graph
- **Usage**:
  ```javascript
  // Create entity
  create_entities({
    entities: [{
      name: "shannon/specs/spec_001",
      entityType: "Specification",
      observations: ["type: spec_analysis", "created: 2025-01-04T14:30:22Z"]
    }]
  })

  // Create relation
  create_relations({
    relations: [{
      from: "shannon/specs/spec_001",
      to: "shannon/waves/wave_001",
      relationType: "spawns"
    }]
  })

  // Search
  const specs = search_nodes("shannon/specs/")
  const wave = open_nodes(["shannon/waves/wave_001"])

  // Update
  add_observations({
    observations: [{
      entityName: "shannon/waves/wave_001",
      contents: ["status: Phase 2 complete", "progress: 60%"]
    }]
  })
  ```
- **Fallback**: NONE (Serena is mandatory for Shannon)
- **Degradation**: CRITICAL (Shannon cannot function without context preservation)
- **Verification**: Test with search_nodes("shannon/") - should return Shannon entities

---

## Examples

### Example 1: Store Spec Analysis
**Input**: Spec analysis complete (complexity 0.68, Frontend 38%, Backend 35%, Database 27%)

**Execution**:
```
Step 1: Determine entity type
  -> Type: Specification
  -> Namespace: shannon/specs/
  -> Entity name: shannon/specs/spec_20250104_143022

Step 2: Create entity
  -> create_entities({
       entities: [{
         name: "shannon/specs/spec_20250104_143022",
         entityType: "Specification",
         observations: [
           "type: spec_analysis",
           "created: 2025-01-04T14:30:22Z",
           "complexity_score: 0.68",
           "interpretation: Complex",
           "domains: Frontend 38%, Backend 35%, Database 27%",
           "execution_strategy: wave-based",
           "recommended_waves: 3-7",
           "recommended_agents: 8-15",
           "timeline: 2-4 days",
           "JSON: {\"complexity_score\":0.68,\"dimensions\":{...},\"domain_percentages\":{...}}"
         ]
       }]
     })

Step 3: Create relations
  -> No parent (spec is root entity)
  -> Relations will be created when waves spawn from this spec

Step 4: Verify creation
  -> open_nodes(["shannon/specs/spec_20250104_143022"])
  -> ✅ Entity exists with all observations
```

**Output**: Spec stored as shannon/specs/spec_20250104_143022, ready to spawn waves

### Example 2: Create Wave from Spec
**Input**: Starting Wave 1 for spec_20250104_143022

**Execution**:
```
Step 1: Determine entity type
  -> Type: Wave
  -> Namespace: shannon/waves/
  -> Entity name: shannon/waves/wave_20250104_150000

Step 2: Create entity
  -> create_entities({
       entities: [{
         name: "shannon/waves/wave_20250104_150000",
         entityType: "Wave",
         observations: [
           "type: wave",
           "wave_number: 1",
           "created: 2025-01-04T15:00:00Z",
           "spec_id: shannon/specs/spec_20250104_143022",
           "phase: Phase 2 - Architecture & Design",
           "status: in_progress",
           "agents: 8",
           "start_time: 2025-01-04T15:00:00Z"
         ]
       }]
     })

Step 3: Create relations
  -> Parent: shannon/specs/spec_20250104_143022
  -> Relation: spec "spawns" wave
  -> create_relations({
       relations: [{
         from: "shannon/specs/spec_20250104_143022",
         to: "shannon/waves/wave_20250104_150000",
         relationType: "spawns"
       }]
     })

Step 4: Verify
  -> open_nodes(["shannon/waves/wave_20250104_150000"])
  -> search_nodes("shannon/waves/") shows wave_20250104_150000
  -> ✅ Wave created and linked to spec
```

**Output**: Wave 1 created, linked to spec via "spawns" relation

### Example 3: Query Wave History
**Input**: User asks "Show me all waves for current project"

**Execution**:
```
Step 1: Map query to search pattern
  -> Intent: All waves
  -> Pattern: search_nodes("shannon/waves/")

Step 2: Execute search
  -> search_nodes("shannon/waves/")
  -> Returns:
     - shannon/waves/wave_20250104_150000
     - shannon/waves/wave_20250104_170000
     - shannon/waves/wave_20250105_090000

Step 3: Fetch details (if needed)
  -> open_nodes([
       "shannon/waves/wave_20250104_150000",
       "shannon/waves/wave_20250104_170000",
       "shannon/waves/wave_20250105_090000"
     ])

Step 4: Parse observations
  -> Wave 1: Phase 2, status: complete
  -> Wave 2: Phase 3, status: complete
  -> Wave 3: Phase 4, status: in_progress

Step 5: Format output
  -> "Wave History:
      - Wave 1 (2025-01-04 15:00): Phase 2 complete
      - Wave 2 (2025-01-04 17:00): Phase 3 complete
      - Wave 3 (2025-01-05 09:00): Phase 4 in progress"
```

**Output**: Complete wave history with status, fetched efficiently using namespace search

### Example 4: Update Wave Status
**Input**: Wave 1 completed Phase 2, moving to Phase 3

**Execution**:
```
Step 1: Identify entity
  -> Entity: shannon/waves/wave_20250104_150000

Step 2: Structure update observations
  -> [
       "updated: 2025-01-04T16:30:00Z",
       "status: complete",
       "phase_completed: Phase 2 - Architecture & Design",
       "next_phase: Phase 3 - Implementation",
       "deliverables: Architecture diagrams, API specs, DB schemas",
       "validation_gate: ✅ Design approved, patterns established"
     ]

Step 3: Add observations (NOT create new entity)
  -> add_observations({
       observations: [{
         entityName: "shannon/waves/wave_20250104_150000",
         contents: [
           "updated: 2025-01-04T16:30:00Z",
           "status: complete",
           "phase_completed: Phase 2 - Architecture & Design",
           "next_phase: Phase 3 - Implementation",
           "deliverables: Architecture diagrams, API specs, DB schemas",
           "validation_gate: ✅ Design approved, patterns established"
         ]
       }]
     })

Step 4: Verify update
  -> open_nodes(["shannon/waves/wave_20250104_150000"])
  -> ✅ Entity has new observations appended
  -> ✅ NO duplicate entity created
```

**Output**: Wave 1 updated with completion status, no data duplication

### Example 5: Create Checkpoint with Relations
**Input**: Create checkpoint at end of Wave 1

**Execution**:
```
Step 1: Determine entity type
  -> Type: Checkpoint
  -> Namespace: shannon/checkpoints/
  -> Entity name: shannon/checkpoints/cp_20250104_163000

Step 2: Create entity
  -> create_entities({
       entities: [{
         name: "shannon/checkpoints/cp_20250104_163000",
         entityType: "Checkpoint",
         observations: [
           "type: checkpoint",
           "created: 2025-01-04T16:30:00Z",
           "wave_id: shannon/waves/wave_20250104_150000",
           "phase: Phase 2 complete",
           "status: Validated",
           "files: [list of checkpoint files]",
           "context: Architecture design complete, moving to implementation"
         ]
       }]
     })

Step 3: Create relations
  -> Parent: shannon/waves/wave_20250104_150000
  -> Relation: wave "created_checkpoint" checkpoint
  -> create_relations({
       relations: [{
         from: "shannon/waves/wave_20250104_150000",
         to: "shannon/checkpoints/cp_20250104_163000",
         relationType: "created_checkpoint"
       }]
     })

Step 4: Verify
  -> open_nodes(["shannon/checkpoints/cp_20250104_163000"])
  -> ✅ Checkpoint created
  -> ✅ Relation exists: wave -> checkpoint
  -> ✅ Can trace checkpoint -> wave -> spec lineage
```

**Output**: Checkpoint created and linked to wave, context lineage preserved

---

## Outputs

Operation result object:

```json
{
  "operation": "create" | "read" | "update" | "search" | "relate" | "delete",
  "success": true,
  "entity_name": "shannon/specs/spec_20250104_143022",
  "entity_type": "Specification",
  "observations": [
    "type: spec_analysis",
    "created: 2025-01-04T14:30:22Z",
    "complexity_score: 0.68",
    "domains: Frontend 40%, Backend 35%, Database 25%"
  ],
  "relations": [
    {
      "from": "shannon/specs/spec_20250104_143022",
      "to": "shannon/waves/wave_20250104_150000",
      "type": "spawns"
    }
  ],
  "validation": {
    "namespace_correct": true,
    "relations_exist": true,
    "format_valid": true,
    "no_duplicates": true
  },
  "lineage": {
    "parent": "shannon/specs/spec_20250104_143022",
    "children": ["shannon/waves/wave_20250104_150000"],
    "depth": 2
  }
}
```

---

## Success Criteria

**Successful when**:
- ✅ All Shannon entities have shannon/* namespace prefix
- ✅ Entity names follow standard format (shannon/[type]s/[name]_[timestamp])
- ✅ Every entity has at least 1 relation (no orphans)
- ✅ Relations use active voice (spawns, contains, tracks)
- ✅ Updates use add_observations (not create_entities)
- ✅ Searches use namespace prefix (search_nodes("shannon/specs/"))
- ✅ No duplicate entities (same data in multiple entities)
- ✅ Graph structure supports lineage queries (checkpoint -> wave -> spec)
- ✅ Observations structured with timestamps and key-value pairs
- ✅ Validation confirms all protocols followed

**Fails if**:
- ❌ Entity created without shannon/ prefix (namespace violation)
- ❌ Entity created without relations (orphaned)
- ❌ Relations use passive voice or unclear naming
- ❌ Update creates new entity instead of add_observations (duplication)
- ❌ Search uses read_graph() for targeted query (inefficiency)
- ❌ Duplicate entities exist for same data
- ❌ Cannot trace lineage (broken relations)
- ❌ Observations unstructured or missing timestamps
- ❌ Namespace collision with user project entities
- ❌ Custom entity naming breaks conventions

**Validation Code**:
```python
def validate_memory_coordination(result):
    """Verify memory coordination followed protocols"""

    # Check: shannon/* namespace
    entity_name = result.get("entity_name", "")
    assert entity_name.startswith("shannon/"), \
        f"VIOLATION: Entity missing shannon/ prefix: {entity_name}"

    # Check: Standard namespace (specs, waves, goals, checkpoints, sitreps, tasks)
    valid_namespaces = ["shannon/specs/", "shannon/waves/", "shannon/goals/",
                        "shannon/checkpoints/", "shannon/sitreps/", "shannon/tasks/"]
    assert any(entity_name.startswith(ns) for ns in valid_namespaces), \
        f"VIOLATION: Invalid namespace: {entity_name}"

    # Check: Relations exist (unless root spec)
    if result.get("operation") == "create" and "specs" not in entity_name:
        relations = result.get("relations", [])
        assert len(relations) >= 1, \
            "VIOLATION: Entity created without relations (orphaned)"

    # Check: Relations use approved types
    approved_relations = ["spawns", "contains", "created_checkpoint",
                          "implements", "reports_on", "tracks", "relates_to"]
    for relation in result.get("relations", []):
        assert relation["type"] in approved_relations, \
            f"VIOLATION: Invalid relation type: {relation['type']}"

    # Check: Observations have timestamps
    observations = result.get("observations", [])
    has_timestamp = any("created:" in obs or "updated:" in obs for obs in observations)
    assert has_timestamp, \
        "VIOLATION: Observations missing timestamp"

    # Check: No duplicate entities (same data in multiple entities)
    validation = result.get("validation", {})
    assert validation.get("no_duplicates") == True, \
        "VIOLATION: Duplicate entities detected"

    # Check: Lineage traceable
    lineage = result.get("lineage", {})
    if "specs" not in entity_name:  # Non-root entities
        assert lineage.get("parent") is not None, \
            "VIOLATION: Cannot trace lineage (broken relations)"

    return True
```

---

## Common Pitfalls

### Pitfall 1: Missing shannon/ Prefix
**Problem**: Agent creates "spec_001" instead of "shannon/specs/spec_001"

**Why It Fails**:
- Namespace collision with user project entities (user might have "spec_001" entity)
- Cannot query all Shannon entities efficiently (search_nodes("shannon/") fails)
- Breaks Shannon isolation from project

**Solution**: ALWAYS prefix with shannon/[type]s/ (specs, waves, goals, checkpoints, sitreps)

**Prevention**: Validation rejects entities without shannon/ prefix

### Pitfall 2: Orphaned Entities
**Problem**: Agent creates wave entity but forgets to link to parent spec

**Why It Fails**:
- Cannot trace wave -> spec lineage
- Cannot answer "which spec spawned this wave?"
- Context restoration impossible

**Solution**: EVERY entity MUST have >=1 relation (except root specs)

**Prevention**: Step 3 mandatory relation creation, validation checks

### Pitfall 3: Update Creates Duplicate
**Problem**: Agent creates "spec_002" to update "spec_001" instead of adding observations

**Why It Fails**:
- Data duplication (two entities with overlapping information)
- Queries return multiple results (which is correct?)
- Graph pollution

**Solution**: Use add_observations for updates, NOT create_entities

**Prevention**: Skill emphasizes update protocol, anti-rationalization section

### Pitfall 4: Inefficient Search
**Problem**: Agent calls read_graph() then manually filters for waves

**Why It Fails**:
- Loads entire graph (100-1000+ entities) when only need 5-20 waves
- Wastes tokens and time
- Unnecessary network traffic

**Solution**: Use search_nodes("shannon/waves/") for targeted query

**Prevention**: Step 4 search patterns, avoid read_graph() for queries

### Pitfall 5: Inconsistent Entity Naming
**Problem**: Agent creates shannon/specs/spec_001, shannon/specs/specification_002, shannon/specs/my_spec_3

**Why It Fails**:
- Inconsistent patterns hard to query (search_nodes("shannon/specs/spec_") misses "specification_")
- Breaks naming conventions
- Confusion about entity type

**Solution**: Standardize: shannon/specs/spec_[timestamp] or shannon/specs/spec_[id]

**Prevention**: Step 1 entity naming protocol, examples show standard format

### Pitfall 6: Missing Timestamps
**Problem**: Agent creates observations without timestamps (["status: complete", "progress: 100%"])

**Why It Fails**:
- Cannot determine WHEN update happened
- Cannot trace progress timeline
- Loses historical context

**Solution**: ALWAYS include timestamp in observations: ["updated: 2025-01-04T16:30:00Z", "status: complete"]

**Prevention**: Step 2 and Step 5 observation format includes timestamps

---

## Validation

**How to verify memory-coordination executed correctly**:

1. **Check Entity Names**:
   - search_nodes("shannon/") returns only Shannon entities ✅
   - All entity names have shannon/[type]s/ prefix ✅
   - No entities in root namespace with Shannon data ✅

2. **Check Relations**:
   - Query entity -> Verify >=1 relation exists ✅
   - Relations use active voice (spawns, contains, tracks) ✅
   - Can trace lineage: checkpoint -> wave -> spec ✅

3. **Check Operations**:
   - Updates used add_observations (not create_entities) ✅
   - No duplicate entities (same data in multiple entities) ✅
   - Searches used namespace prefix (not read_graph()) ✅

4. **Check Observations**:
   - All observations have timestamps ✅
   - Observations structured as key-value or JSON ✅
   - Latest observations at end of list ✅

5. **Test Queries**:
   - search_nodes("shannon/specs/") returns only specs ✅
   - search_nodes("shannon/waves/") returns only waves ✅
   - open_nodes(["shannon/specs/spec_001"]) returns specific spec ✅
   - Queries execute in <2 seconds ✅

6. **Test Lineage**:
   - Given checkpoint -> Can find parent wave ✅
   - Given wave -> Can find parent spec ✅
   - Given wave -> Can find all child tasks ✅
   - Given spec -> Can find all spawned waves ✅

---

## Progressive Disclosure

**SKILL.md** (This file): ~600 lines
- Overview, when to use, expected outcomes
- Anti-rationalization (6 violations with counters)
- 5 core competencies (namespace, CRUD, relations, search, observations)
- 6-step workflow (determine type, create, relate, search, update, validate)
- 5 examples (store spec, create wave, query history, update status, checkpoint)
- Success criteria, common pitfalls, validation

**references/**: No deep references needed (protocol is self-contained)

**Claude loads references/ when**: N/A (all protocol details in SKILL.md)

---

## References

- Serena MCP documentation: https://github.com/cyanheads/serena-mcp
- Shannon context management: shannon-plugin/core/CONTEXT_MANAGEMENT.md
- Checkpoint protocols: shannon-plugin/skills/context-preservation/SKILL.md
- Wave orchestration: shannon-plugin/skills/wave-orchestration/SKILL.md

---

## Metadata

**Version**: 4.0.0
**Last Updated**: 2025-11-04
**Author**: Shannon Framework Team
**License**: MIT
**Status**: Core (Protocol skill, mandatory for Serena MCP operations)
