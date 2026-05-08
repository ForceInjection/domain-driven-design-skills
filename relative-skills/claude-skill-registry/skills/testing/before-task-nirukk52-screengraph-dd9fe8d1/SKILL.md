---
name: before-task
description: Comprehensive discovery before starting any spec or major task. Searches Graphiti, recommends vibe/MCPs, surfaces patterns.
---

# @before-task - Comprehensive Discovery

**Use BEFORE:**
- `/speckit.specify` (creating new spec)
- Starting any major feature/bug fix
- Beginning new work streams

**DO NOT use during implementation** (too heavy, use @during-task instead)

---

## What It Does

```
1. Search Graphiti for similar past work (group_id="screengraph")
   - Past specs in this domain
   - Implementation patterns
   - Known gotchas and workarounds
   
2. Get MCP orchestrator recommendations
   - Which vibe to use
   - Top 3 MCPs prioritized
   - Relevant skills available
   
3. Surface actionable context
   - Files to review
   - Architecture patterns
   - Past decisions
   - Starting points
```

**Token cost**: ~2500 tokens  
**Frequency**: Once per spec/major-task  
**ROI**: Prevents wrong direction = saves hours

---

## Execution

### Graphiti Searches (Parallel)

```typescript
// Search 1: Past specs in domain
search_memory_nodes({
  query: "spec [domain] [feature-type]",
  group_ids: ["screengraph"],
  max_nodes: 10
});

// Search 2: Implementation patterns
search_memory_nodes({
  query: "[domain] implementation patterns best practices",
  group_ids: ["screengraph"],
  max_nodes: 10
});

// Search 3: Known gotchas
search_memory_facts({
  query: "[technology] gotchas workarounds issues",
  group_ids: ["screengraph"],
  max_facts: 10
});
```

### MCP Recommendations

```typescript
suggest_mcps({
  task: "[user's task description]",
  include_examples: false  // Brief mode
});
```

---

## Output Format

```markdown
## 🎯 Before-Task Context: [Task]

### 📚 Similar Past Work
- [Spec/solution 1 with key learnings]
- [Spec/solution 2 with gotchas]
- [Pattern 3 from past implementation]

### 🎭 Recommended Setup
**Vibe**: [vibe_name] (skills: [skill1, skill2])
**MCPs**: 
1. [MCP 1] - [purpose]
2. [MCP 2] - [purpose]
3. [MCP 3] - [purpose]

### 📁 Files to Review
- [file 1] - [why relevant]
- [file 2] - [why relevant]

### ⚠️ Known Gotchas
- [Gotcha 1 with workaround]
- [Gotcha 2 with workaround]

### 🚀 Suggested Approach
1. [Step 1 based on past patterns]
2. [Step 2]
3. [Step 3]

### 📖 Resources (if needed)
- [Relevant documentation or Context7 libraries]
```

---

## Integration

### With Spec-Kit
```bash
# Discovery phase
@before-task Research [feature idea]

# Review results
# If similar spec exists → Adapt
# If new → Proceed

/speckit.specify "[feature]"
```

### With Standard Tasks
```bash
# Before major work
@before-task Fix [complex bug]

# Review context
# Create branch
git checkout -b bug-[description]

# Implement using recommended vibe + MCPs
```

---

## When NOT to Use

❌ During implementation of subtasks (use @during-task)  
❌ For trivial tasks (use @during-task)  
❌ Multiple times in same session (context doesn't change that fast)

---

**Purpose**: Load comprehensive context ONCE at the start. Everything else builds from this foundation.


