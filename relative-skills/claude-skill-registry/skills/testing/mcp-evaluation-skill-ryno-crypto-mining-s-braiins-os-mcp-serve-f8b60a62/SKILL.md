---
name: mcp-evaluation-skill
version: 1.0.0
category: mcp-development
description: Comprehensive evaluation creation for MCP servers - question generation, answer verification, and XML formatting for agent usability testing
triggers:
  - "create evaluations"
  - "evaluation questions"
  - "test MCP server"
  - "verify MCP tools"
  - "agent usability"
dependencies:
  - mcp-builder-skill
author: Engineering Standards Committee
last_updated: 2025-12-29
---

# MCP Evaluation Skill

## Description

This skill provides a systematic approach to creating comprehensive evaluation suites for MCP (Model Context Protocol) servers. Evaluations test whether AI agents can effectively use MCP tools to answer realistic, complex questions - the ultimate measure of MCP server quality.

**Core Capabilities:**
- Question generation methodology (simple → moderate → complex)
- Answer verification through manual solving
- XML format specification for evaluation frameworks
- Complexity distribution optimization (2-3-2 pattern)
- Independence and stability validation
- Real-world use case identification

---

## When to Use This Skill

**Use this skill when you need to:**
- Create evaluation suites for new MCP servers
- Validate MCP tool usability by AI agents
- Test complex multi-tool workflows
- Verify agent can discover and use tools correctly
- Generate realistic questions based on actual data
- Ensure stable, verifiable answers

**Trigger Phrases:**
- "Create 10 evaluation questions for this MCP server"
- "Generate evaluation suite"
- "Test if agents can use these tools"
- "Verify MCP server with evaluations"
- "Create XML evaluation file"

**Don't use this skill for:**
- Unit testing (use validator-role-skill instead)
- Integration testing (different testing methodology)
- Manual QA testing (evaluations are for automated agent testing)
- API documentation (use scribe-role-skill)

---

## Prerequisites

### Knowledge Requirements

1. **MCP Protocol Understanding**
   - Tool, resource, and prompt concepts
   - Input schemas (Pydantic/Zod)
   - Response format best practices
   - Agent-centric design principles

2. **Evaluation Theory**
   - Independence (no question dependencies)
   - Read-only operations (non-destructive)
   - Verifiability (string comparison)
   - Stability (answer doesn't change over time)
   - Complexity levels (simple, moderate, complex)

3. **Domain Knowledge**
   - Understanding of target API/service
   - Realistic use cases humans care about
   - Data relationships and patterns
   - Edge cases worth testing

### Environment Setup

```bash
# Ensure MCP server is running
npm run build
node dist/index.js &

# Or use evaluation harness (recommended)
# Harness manages server lifecycle automatically
```

### Project Context

- **Phase 4 of MCP Development**: Evaluations come after implementation (Phases 1-3)
- **MCP Server Running**: Must have working MCP server to explore data
- **Tool Documentation**: Understand what each tool does
- **Read-Only Access**: Evaluation questions must not modify data

---

## Workflow

### Phase 1: Tool Inspection and Understanding

#### 1.1 List All Available Tools

**Objective**: Understand the complete capability surface of the MCP server

```bash
# If using MCP inspector
mcp-inspector --server ./dist/index.js tools list

# Manual inspection via code
grep -r "@tool" src/mcp/tools/
```

**Document Each Tool:**

| Tool Name | Purpose | Input Parameters | Output | Complexity |
|-----------|---------|------------------|--------|------------|
| `list_miners` | Get all registered miners | `{ limit?, offset? }` | `{ miners: [...] }` | Simple |
| `get_miner_status` | Get detailed miner status | `{ minerId }` | `{ status, hashrate, temp }` | Simple |
| `update_firmware` | Update miner firmware | `{ minerId, version }` | `{ jobId, status }` | Complex |
| `get_fleet_summary` | Aggregated fleet metrics | `{ tenantId? }` | `{ total, online, hashrate }` | Moderate |

**Key Insights to Capture:**
- Which tools return lists vs single items?
- Which tools require IDs from other tools? (workflow chaining)
- Which tools have optional parameters?
- Which tools enable complex multi-step questions?

#### 1.2 Understand Tool Relationships

**Pattern: Map Tool Dependencies**

```
list_miners → get_miner_status (requires minerId from list)
                ↓
          update_firmware (requires minerId)
                ↓
          check_job_status (requires jobId from update)
```

**Workflow Chains to Test:**
1. **Discovery → Detail**: list_miners → get_miner_status
2. **Discovery → Action**: list_miners → update_firmware → check_job_status
3. **Aggregation → Filter**: get_fleet_summary → list_miners (with filters)
4. **Multi-Resource**: get_miner_status + get_pool_config + get_firmware_version

---

### Phase 2: Content Exploration (Read-Only)

#### 2.1 Use READ-ONLY Tools to Explore Data

**Critical Rule**: Never use destructive operations during exploration

**Exploration Strategy:**

```typescript
// Example: Explore miner fleet
const miners = await mcpServer.callTool("list_miners", { limit: 100 });
// Identify interesting miners: highest hashrate, highest temp, offline, etc.

const detailedStatus = await mcpServer.callTool("get_miner_status", {
  minerId: miners.miners[0].id
});
// Understand status structure: what fields exist? What values?

const fleetSummary = await mcpServer.callTool("get_fleet_summary", {});
// Understand aggregated metrics: total miners, online count, average hashrate
```

**Data Patterns to Identify:**

1. **Uniqueness**: Which fields uniquely identify entities?
   - Example: `minerId`, `serialNumber`, `ipAddress`

2. **Relationships**: How do entities relate?
   - Example: Miners → Pools, Miners → Firmware Versions

3. **Ranges**: What are typical value ranges?
   - Example: Temperature (40-80°C), Hashrate (90-100 TH/s)

4. **Edge Cases**: Interesting outliers to test
   - Example: Offline miners, miners with errors, miners updating firmware

5. **Aggregations**: What can be calculated?
   - Example: Total hashrate, average temperature, count by status

#### 2.2 Document Data Characteristics

**Data Classification Matrix:**

| Data Type | Change Frequency | Uniqueness | Suitable for Evaluation? |
|-----------|------------------|------------|--------------------------|
| Miner ID | Never | Unique | ✅ Yes (stable reference) |
| Hashrate | Every 1-5s | Non-unique | ❌ No (too volatile) |
| Firmware version | Rarely | Non-unique | ✅ Yes (stable) |
| Temperature | Every 1-5s | Non-unique | ❌ No (too volatile) |
| Pool URL | Rarely | Non-unique | ✅ Yes (stable) |
| Error messages | Varies | Non-unique | ⚠️ Maybe (if persistent) |

**Stable vs Volatile Data:**
- **Stable**: Suitable for evaluation answers (firmware versions, pool URLs, miner counts)
- **Volatile**: Unsuitable (hashrate, temperature, current status)

---

### Phase 3: Question Generation

#### 3.1 Complexity Distribution (2-3-2 Pattern)

**Target Distribution for 10 Questions:**
- **2 Simple** (1-2 tool calls, straightforward lookup)
- **6 Moderate** (2-4 tool calls, some reasoning/filtering)
- **2 Complex** (4+ tool calls, deep exploration, multi-step workflows)

#### 3.2 Simple Questions (Single Tool or Straightforward Workflow)

**Characteristics:**
- 1-2 tool calls
- Obvious solution path
- Direct lookup or simple filter
- Answer is immediate from tool output

**Examples:**

1. **Simple Discovery**
   ```xml
   <question>How many miners are currently registered in the fleet?</question>
   <answer>127</answer>
   <!-- Tools: list_miners (count total) -->
   ```

2. **Simple Detail Lookup**
   ```xml
   <question>What firmware version is miner-abc-123 running?</question>
   <answer>2.5.1</answer>
   <!-- Tools: get_miner_status(miner-abc-123) → firmware_version -->
   ```

#### 3.3 Moderate Questions (Multi-Tool, Filtering, Reasoning)

**Characteristics:**
- 2-4 tool calls
- Requires filtering or sorting
- Some logic to combine results
- May need to identify "best" or "worst"

**Examples:**

1. **Find by Characteristic**
   ```xml
   <question>Which miner in the fleet has the highest hashrate? What is its IP address?</question>
   <answer>192.168.1.157</answer>
   <!-- Tools:
        1. list_miners
        2. get_miner_status for each (or use fleet summary)
        3. Identify max hashrate
        4. Return IP address
   -->
   ```

2. **Aggregation with Filter**
   ```xml
   <question>How many miners are currently offline in tenant 'prod-west'?</question>
   <answer>3</answer>
   <!-- Tools:
        1. list_miners({ tenantId: 'prod-west' })
        2. Filter by status === 'offline'
        3. Count results
   -->
   ```

3. **Cross-Resource Query**
   ```xml
   <question>Which pool URL is configured for the miner with serial number SN-7891? Include the pool priority.</question>
   <answer>stratum+tcp://pool.example.com:3333 (priority: 0)</answer>
   <!-- Tools:
        1. list_miners → find miner by serial number
        2. get_pool_config(minerId) → get pool configuration
        3. Extract URL and priority
   -->
   ```

#### 3.4 Complex Questions (Deep Exploration, Multi-Step)

**Characteristics:**
- 4+ tool calls
- Requires exploring multiple layers
- Chained dependencies (output of one tool feeds next)
- Combines data from multiple sources
- May require finding relationships or patterns

**Examples:**

1. **Deep Workflow Exploration**
   ```xml
   <question>Find the miner with the oldest firmware version in the fleet. What is its current hashrate in TH/s?</question>
   <answer>87.3</answer>
   <!-- Tools:
        1. list_miners (get all miners)
        2. get_miner_status for each (or batch query)
        3. Identify oldest firmware version
        4. Get hashrate for that specific miner
   -->
   ```

2. **Multi-Condition Search**
   ```xml
   <question>Among miners running firmware 2.5.x, which one has been online the longest? What is its uptime in hours?</question>
   <answer>1847</answer>
   <!-- Tools:
        1. list_miners
        2. get_miner_status for each
        3. Filter by firmware version (2.5.x regex)
        4. Identify max uptime
        5. Convert to hours and return
   -->
   ```

3. **Pattern Discovery**
   ```xml
   <question>Which firmware version is most commonly deployed across all miners in the 'prod' tenant? How many miners use it?</question>
   <answer>2.5.1 (94 miners)</answer>
   <!-- Tools:
        1. list_miners({ tenantId: 'prod' })
        2. get_miner_status for each
        3. Group by firmware version
        4. Find most common (mode)
        5. Return version + count
   -->
   ```

#### 3.5 Question Quality Checklist

For each generated question, verify:

- [ ] **Independent**: Doesn't depend on answers from other questions
- [ ] **Read-Only**: Only uses non-destructive tools
- [ ] **Verifiable**: Has single, clear answer (string comparison)
- [ ] **Stable**: Answer won't change over time (no volatile data)
- [ ] **Realistic**: Based on actual use case humans care about
- [ ] **Answerable**: Agent can solve with available tools
- [ ] **Clear**: Unambiguous what's being asked
- [ ] **Complete**: Includes all context needed

**Red Flags (Avoid These):**
- ❌ "What is the current temperature of miner-123?" (too volatile)
- ❌ "Update firmware and tell me the result" (destructive)
- ❌ "Solve question 3 first, then answer this" (dependent)
- ❌ "Approximately how many miners..." (vague, not verifiable)

---

### Phase 4: Answer Verification

#### 4.1 Manually Solve Each Question

**Critical Rule**: You must solve every question yourself to verify the answer

**Verification Process:**

```typescript
// For each question, document solving process:

// Question: "How many miners are in tenant 'prod-west'?"

// Step 1: Call list_miners
const miners = await mcpServer.callTool("list_miners", {
  tenantId: "prod-west"
});
// Result: { miners: [...], total: 47 }

// Step 2: Verify count
console.log(`Total miners: ${miners.total}`);
// Output: Total miners: 47

// Step 3: Document answer
// Answer: 47

// Step 4: Verify stability
// - Tenant membership rarely changes ✅
// - Answer won't be volatile ✅
// - Answer is deterministic ✅
```

#### 4.2 Answer Format Guidelines

**String Comparison Requirements:**

| Answer Type | Format | Example |
|-------------|--------|---------|
| Number | Plain number | `47` (not "47 miners") |
| String | Exact string | `prod-west` (not "Tenant: prod-west") |
| IP Address | Standard notation | `192.168.1.100` |
| URL | Full URL | `stratum+tcp://pool.example.com:3333` |
| Version | Semantic version | `2.5.1` (not "v2.5.1") |
| Boolean | `true` or `false` | `true` (lowercase) |
| List | Comma-separated | `miner-1,miner-2,miner-3` (no spaces) |

**Multiple-Part Answers:**

If question asks for multiple pieces of information, format as structured answer:

```xml
<question>What is the IP address and pool URL for miner-abc-123?</question>
<answer>192.168.1.100, stratum+tcp://pool.example.com:3333</answer>
<!-- Clear delimiter (comma + space) between parts -->
```

#### 4.3 Stability Verification

**Check Answer Stability:**

1. **Re-run verification** after 1 hour - answer should be same
2. **Identify dependencies** - what would cause answer to change?
3. **Avoid time-sensitive data** - current status, real-time metrics
4. **Use historical or configuration data** - firmware versions, pool URLs, miner IDs

**Stable vs Unstable Examples:**

| Question | Stability | Reason |
|----------|-----------|--------|
| "How many miners are registered?" | ✅ Stable | Rarely changes |
| "What is miner-123's hashrate?" | ❌ Unstable | Changes every second |
| "Which firmware version is on miner-abc?" | ✅ Stable | Only changes on update |
| "How many miners are currently online?" | ❌ Unstable | Changes frequently |
| "What pool URL is miner-xyz using?" | ✅ Stable | Configuration data |

---

### Phase 5: XML Output Generation

#### 5.1 XML Format Specification

**Complete Evaluation File Structure:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<evaluation>
  <metadata>
    <name>Braiins OS MCP Server Evaluation</name>
    <version>1.0</version>
    <created>2025-12-29</created>
    <author>Engineering Team</author>
    <description>Comprehensive evaluation suite testing agent usability of Braiins OS MCP server</description>
  </metadata>

  <qa_pairs>
    <!-- Simple questions (2) -->
    <qa_pair>
      <id>eval-001</id>
      <difficulty>simple</difficulty>
      <question>How many miners are currently registered in the fleet?</question>
      <answer>127</answer>
      <tools_required>list_miners</tools_required>
      <expected_call_count>1</expected_call_count>
    </qa_pair>

    <qa_pair>
      <id>eval-002</id>
      <difficulty>simple</difficulty>
      <question>What firmware version is miner-abc-123 running?</question>
      <answer>2.5.1</answer>
      <tools_required>get_miner_status</tools_required>
      <expected_call_count>1</expected_call_count>
    </qa_pair>

    <!-- Moderate questions (6) -->
    <qa_pair>
      <id>eval-003</id>
      <difficulty>moderate</difficulty>
      <question>Which miner in the fleet has the highest hashrate? What is its IP address?</question>
      <answer>192.168.1.157</answer>
      <tools_required>list_miners, get_miner_status</tools_required>
      <expected_call_count>3-5</expected_call_count>
    </qa_pair>

    <!-- ... 5 more moderate questions ... -->

    <!-- Complex questions (2) -->
    <qa_pair>
      <id>eval-009</id>
      <difficulty>complex</difficulty>
      <question>Find the miner with the oldest firmware version in the fleet. What is its current hashrate in TH/s?</question>
      <answer>87.3</answer>
      <tools_required>list_miners, get_miner_status</tools_required>
      <expected_call_count>5+</expected_call_count>
    </qa_pair>

    <qa_pair>
      <id>eval-010</id>
      <difficulty>complex</difficulty>
      <question>Which firmware version is most commonly deployed across all miners in the 'prod' tenant? How many miners use it?</question>
      <answer>2.5.1 (94 miners)</answer>
      <tools_required>list_miners, get_miner_status</tools_required>
      <expected_call_count>5+</expected_call_count>
    </qa_pair>
  </qa_pairs>

  <statistics>
    <total_questions>10</total_questions>
    <simple_count>2</simple_count>
    <moderate_count>6</moderate_count>
    <complex_count>2</complex_count>
    <total_tools>4</total_tools>
    <avg_tools_per_question>2.3</avg_tools_per_question>
  </statistics>
</evaluation>
```

#### 5.2 Metadata Best Practices

- **Name**: Descriptive name of MCP server being evaluated
- **Version**: Evaluation suite version (bump when questions change)
- **Created**: ISO 8601 date (YYYY-MM-DD)
- **Author**: Team or individual who created evaluations
- **Description**: Brief explanation of what's being tested

#### 5.3 QA Pair Best Practices

**Required Fields:**
- `<id>`: Unique identifier (eval-001, eval-002, ...)
- `<difficulty>`: simple | moderate | complex
- `<question>`: Clear, unambiguous question text
- `<answer>`: Verified answer (string comparison format)

**Optional but Recommended Fields:**
- `<tools_required>`: Comma-separated tool names needed
- `<expected_call_count>`: How many tool calls expected (for performance testing)
- `<rationale>`: Why this question is valuable (internal documentation)

---

## Examples

### Example 1: Complete Evaluation Creation Process

**Target**: Braiins OS MCP Server with 4 tools

**Step 1: Tool Inspection**

```typescript
// Available tools:
1. list_miners({ limit?, offset?, tenantId? })
2. get_miner_status({ minerId })
3. get_fleet_summary({ tenantId? })
4. get_pool_config({ minerId })
```

**Step 2: Data Exploration**

```typescript
// Discover data patterns
const miners = await callTool("list_miners", { limit: 100 });
// Found: 127 miners total, IDs like "miner-abc-123"

const status = await callTool("get_miner_status", {
  minerId: miners.miners[0].id
});
// Found: firmware version (stable), hashrate (volatile), temperature (volatile)

const summary = await callTool("get_fleet_summary", {});
// Found: total count, online count, total hashrate
```

**Step 3: Generate 10 Questions**

```xml
<evaluation>
  <!-- 2 Simple -->
  <qa_pair>
    <question>How many miners are registered?</question>
    <answer>127</answer>
  </qa_pair>

  <qa_pair>
    <question>What is miner-abc-123's firmware version?</question>
    <answer>2.5.1</answer>
  </qa_pair>

  <!-- 6 Moderate -->
  <qa_pair>
    <question>How many miners in tenant 'prod-west' are online?</question>
    <answer>44</answer>
  </qa_pair>

  <!-- ... 5 more moderate ... -->

  <!-- 2 Complex -->
  <qa_pair>
    <question>Which miner has the oldest firmware? What is its pool URL?</question>
    <answer>stratum+tcp://old-pool.example.com:3333</answer>
  </qa_pair>

  <!-- ... 1 more complex ... -->
</evaluation>
```

**Step 4: Verify All Answers**

```typescript
// Manually solve each question and verify answer stability
// Document solving process for future reference
```

### Example 2: Question Evolution (Bad → Good)

**❌ Bad Question (Volatile Answer):**
```xml
<question>What is the current hashrate of miner-abc-123?</question>
<answer>95.7</answer>
<!-- Problem: Hashrate changes every second - unstable! -->
```

**✅ Good Question (Stable Answer):**
```xml
<question>What firmware version is miner-abc-123 running?</question>
<answer>2.5.1</answer>
<!-- Good: Firmware version only changes on updates - stable! -->
```

**❌ Bad Question (Dependent):**
```xml
<question>Using the miner ID from question 3, what is its temperature?</question>
<!-- Problem: Depends on question 3 - not independent! -->
```

**✅ Good Question (Independent):**
```xml
<question>What is the pool URL for miner-abc-123?</question>
<answer>stratum+tcp://pool.example.com:3333</answer>
<!-- Good: Self-contained, no dependencies -->
```

---

## Quality Standards

### Evaluation Quality Checklist

- [ ] **Coverage**
  - [ ] Tests all major tools at least once
  - [ ] Tests common workflows (list → detail)
  - [ ] Tests edge cases (empty results, errors)
  - [ ] Tests aggregation and filtering

- [ ] **Complexity Distribution**
  - [ ] 2 simple questions (20%)
  - [ ] 6 moderate questions (60%)
  - [ ] 2 complex questions (20%)
  - [ ] Total: 10 questions

- [ ] **Question Quality**
  - [ ] All questions are independent
  - [ ] All questions use read-only tools
  - [ ] All questions have verifiable answers
  - [ ] All questions have stable answers
  - [ ] All questions are realistic use cases

- [ ] **Answer Quality**
  - [ ] All answers manually verified
  - [ ] All answers use string comparison format
  - [ ] All answers are stable (re-verified after 1 hour)
  - [ ] All answers are unambiguous

- [ ] **XML Format**
  - [ ] Valid XML structure
  - [ ] Metadata complete
  - [ ] Statistics calculated
  - [ ] Consistent formatting

### Performance Targets

**Agent Success Rates:**
- **Simple questions**: 95%+ success rate
- **Moderate questions**: 80%+ success rate
- **Complex questions**: 60%+ success rate
- **Overall**: 75%+ success rate

**Tool Call Efficiency:**
- **Simple**: 1-2 tool calls on average
- **Moderate**: 3-4 tool calls on average
- **Complex**: 5-7 tool calls on average

---

## Common Pitfalls

### ❌ Pitfall 1: Volatile Data in Answers

**Problem**: Using real-time metrics that change constantly

```xml
<!-- BAD: Temperature changes every second -->
<question>What is miner-123's current temperature?</question>
<answer>65°C</answer>
```

**Solution**: Use stable configuration or historical data

```xml
<!-- GOOD: Firmware version only changes on updates -->
<question>What firmware version is miner-123 running?</question>
<answer>2.5.1</answer>
```

### ❌ Pitfall 2: Dependent Questions

**Problem**: Questions that rely on previous answers

```xml
<!-- BAD: Depends on identifying miner in previous question -->
<question>What is the pool URL for the miner from question 5?</question>
```

**Solution**: Make every question self-contained

```xml
<!-- GOOD: Fully self-contained -->
<question>What is the pool URL for miner-abc-123?</question>
<answer>stratum+tcp://pool.example.com:3333</answer>
```

### ❌ Pitfall 3: Ambiguous Answers

**Problem**: Multiple valid interpretations

```xml
<!-- BAD: Ambiguous format -->
<question>How many miners are offline?</question>
<answer>3 miners are offline</answer>
<!-- Agent might return just "3" or "three" or "3 miners" -->
```

**Solution**: Specify exact format in question or normalize answer

```xml
<!-- GOOD: Clear number format -->
<question>How many miners are offline?</question>
<answer>3</answer>
<!-- Clear: just the number -->
```

---

## Integration with Evaluation Harness

### Running Evaluations

**Evaluation Harness Setup:**

```bash
# Create evaluation harness script
cat > run-evaluation.ts <<'EOF'
import { MCPClient } from '@modelcontextprotocol/client';
import { parseEvaluation } from './eval-parser';

async function runEvaluation(evalPath: string) {
  const client = new MCPClient('./dist/index.js');
  const evaluation = parseEvaluation(evalPath);

  let passed = 0;
  let failed = 0;

  for (const qa of evaluation.questions) {
    try {
      const answer = await client.ask(qa.question);
      if (answer === qa.answer) {
        passed++;
        console.log(`✅ ${qa.id}: PASS`);
      } else {
        failed++;
        console.log(`❌ ${qa.id}: FAIL (expected: ${qa.answer}, got: ${answer})`);
      }
    } catch (error) {
      failed++;
      console.log(`❌ ${qa.id}: ERROR - ${error.message}`);
    }
  }

  console.log(`\nResults: ${passed}/${passed + failed} passed (${(passed / (passed + failed) * 100).toFixed(1)}%)`);
}

runEvaluation('./evaluations/braiins-os.xml');
EOF
```

**Usage:**

```bash
npm run build
npm run evaluate
```

---

## References

- **MCP Evaluation Guide**: See mcp-builder-skill reference/evaluation.md
- **Question Generation Theory**: See mcp-builder-skill Phase 4
- **Agent-Centric Design**: MCP Best Practices (modelcontextprotocol.io)
- **Braiins OS API**: See braiins-os skill for domain knowledge

---

**Version History:**
- 1.0.0 (2025-12-29): Initial release - Question generation, answer verification, XML formatting
