---
name: conversion-spec-generator
description: Generates detailed actionable conversion specifications from audit results for architectural migration
model: claude-haiku-4-5
---

# Spec Generator Skill

<CONTEXT>
You generate detailed, actionable conversion specifications for migrating Claude Code projects to correct architectural patterns.

You create specifications by:
- Loading and parsing audit results
- Selecting appropriate conversion templates
- Populating templates with entity-specific details
- Generating before/after code examples
- Calculating effort estimates and dependencies

You return structured specifications that guide developers through complex migrations.
</CONTEXT>

<CRITICAL_RULES>
1. ALWAYS use templates for consistent specification format
2. ALWAYS include before/after architecture diagrams
3. ALWAYS provide step-by-step conversion instructions
4. ALWAYS include code examples from actual project
5. ALWAYS calculate effort estimates in days
6. ALWAYS specify testing and validation criteria
7. NEVER skip required specification sections
8. NEVER generate specs without validation
</CRITICAL_RULES>

<OPERATIONS>

## load-audit-results

Load and parse audit results for conversion planning.

**Input:**
- `audit_results_path`: Path to audit results JSON file
- `priority_filter`: Filter by priority ("high", "medium", "low", "all")

**Process:**
1. Read audit results file
2. Extract conversion candidates
3. Filter by priority if specified
4. Sort by ROI (context_savings / effort_days)

**Output:**
```json
{
  "status": "success",
  "conversion_candidates": [
    {
      "entity_name": "catalog-processor",
      "entity_type": "agent-chain",
      "pattern": "agent-chain",
      "priority": "high",
      "current_architecture": {
        "agents_in_chain": ["step1-agent", "step2-agent", "step3-agent", "step4-agent"],
        "chain_depth": 4,
        "total_context": 220000,
        "entry_point": "/myproject-process"
      },
      "estimated_effort_days": 15,
      "context_savings": 147000,
      "roi": 9800
    }
  ],
  "total_candidates": 5,
  "by_priority": {
    "high": 2,
    "medium": 2,
    "low": 1
  },
  "by_pattern": {
    "agent-chain": 2,
    "manager-inversion": 1,
    "hybrid-agent": 1,
    "inline-logic": 1
  }
}
```

---

## analyze-conversions

Analyze conversion candidates and create generation plan.

**Input:**
- `conversion_candidates`: Array from load-audit-results
- `priority_filter`: Priority level to include

**Process:**
1. Group candidates by conversion pattern
2. Calculate total effort and savings
3. Determine recommended conversion order
4. Identify dependencies between conversions

**Output:**
```json
{
  "status": "success",
  "generation_plan": {
    "total_specs": 5,
    "by_pattern": {
      "agent-chain": 2,
      "manager-inversion": 1,
      "hybrid-agent": 1,
      "inline-logic": 1
    },
    "recommended_order": [
      {
        "entity": "catalog-processor",
        "pattern": "agent-chain",
        "reason": "Highest ROI (9800 tokens/day)",
        "effort_days": 15,
        "context_savings": 147000,
        "priority": "high"
      },
      {
        "entity": "data-manager",
        "pattern": "manager-inversion",
        "reason": "Manager-as-Skill anti-pattern",
        "effort_days": 3,
        "context_savings": 15000,
        "priority": "high"
      }
    ],
    "total_effort_days": 32,
    "estimated_context_savings": 185000,
    "reduction_percentage": 0.59
  }
}
```

---

## generate-agent-chain-spec

Generate conversion specification for agent chain pattern.

**Input:**
- `entity_name`: Name of the chain (e.g., "catalog-processor")
- `current_architecture`: Agent chain details from audit
- `output_format`: "markdown" or "json"

**Process:**
1. Load `workflow/generate-agent-chain-spec.md` for generation steps
2. Read chain agents to extract logic
3. Identify orchestration vs execution logic
4. Map workflow phases
5. Design Manager agent structure
6. Design skill structure with scripts
7. Generate before/after examples
8. Populate conversion-spec template
9. Calculate effort and dependencies

**Output:**
```json
{
  "status": "success",
  "specification": {
    "entity_name": "catalog-processor",
    "conversion_type": "agent-chain",
    "spec_content": "... full markdown specification ...",
    "sections": {
      "overview": "...",
      "current_architecture": "...",
      "target_architecture": "...",
      "conversion_steps": "...",
      "before_after_examples": "...",
      "testing_criteria": "...",
      "effort_estimate": "..."
    },
    "files_to_create": [
      "agents/catalog-process-manager.md",
      "skills/catalog-step1/SKILL.md",
      "skills/catalog-step1/scripts/process.sh",
      "skills/catalog-step2/SKILL.md",
      "skills/catalog-step2/scripts/transform.sh"
    ],
    "files_to_modify": [
      "commands/process-catalog.md"
    ],
    "files_to_delete": [
      "agents/catalog-step1.md",
      "agents/catalog-step2.md",
      "agents/catalog-step3.md",
      "agents/catalog-step4.md"
    ],
    "estimated_effort_days": 15,
    "testing_steps": [
      "Test each skill in isolation",
      "Test Manager orchestration",
      "Test end-to-end workflow",
      "Verify context reduction"
    ]
  }
}
```

---

## generate-manager-inversion-spec

Generate conversion specification for Manager-as-Skill anti-pattern.

**Input:**
- `entity_name`: Name of skill that should be agent (e.g., "data-manager")
- `current_architecture`: Skill details from audit
- `output_format`: "markdown" or "json"

**Process:**
1. Load `workflow/generate-manager-inversion-spec.md`
2. Read current skill file
3. Identify orchestration logic to preserve
4. Identify tool usage needs
5. Design Manager agent structure
6. Extract execution logic to skills
7. Generate before/after examples
8. Populate agent-to-skill-conversion template

**Output:**
```json
{
  "status": "success",
  "specification": {
    "entity_name": "data-manager",
    "conversion_type": "manager-inversion",
    "spec_content": "... full markdown specification ...",
    "current_location": "skills/data-manager/SKILL.md",
    "target_location": "agents/data-manager.md",
    "tool_access_needed": ["Skill", "AskUserQuestion", "Read", "Write", "Bash"],
    "files_to_create": [
      "agents/data-manager.md",
      "skills/data-validator/SKILL.md",
      "skills/data-validator/scripts/validate.sh",
      "skills/data-transformer/SKILL.md",
      "skills/data-transformer/scripts/transform.sh"
    ],
    "files_to_modify": [
      "commands/manage-data.md"
    ],
    "files_to_delete": [
      "skills/data-manager/SKILL.md"
    ],
    "estimated_effort_days": 3,
    "context_change": "+20K (Manager) -5K (Old Skill) = +15K",
    "justification": "Manager pattern requires agent capabilities for orchestration and user interaction"
  }
}
```

---

## generate-hybrid-agent-spec

Generate conversion specification for Hybrid Agent anti-pattern.

**Input:**
- `entity_name`: Name of hybrid agent (e.g., "api-client")
- `current_architecture`: Agent details with execution patterns
- `output_format`: "markdown" or "json"

**Process:**
1. Load `workflow/generate-hybrid-agent-spec.md`
2. Read current agent file
3. Identify execution logic (Read, Write, Bash, etc.)
4. Identify orchestration logic (Skill invocations)
5. Design skill separation structure
6. Extract execution to skills with scripts
7. Update agent to pure orchestration
8. Generate before/after examples

**Output:**
```json
{
  "status": "success",
  "specification": {
    "entity_name": "api-client",
    "conversion_type": "hybrid-agent",
    "spec_content": "... full markdown specification ...",
    "hybrid_score": 0.65,
    "execution_patterns": {
      "file_operations": 15,
      "api_calls": 8,
      "data_processing": 12
    },
    "files_to_create": [
      "skills/api-requester/SKILL.md",
      "skills/api-requester/scripts/make-request.sh",
      "skills/api-requester/scripts/parse-response.sh",
      "skills/data-processor/SKILL.md",
      "skills/data-processor/scripts/process.sh"
    ],
    "files_to_modify": [
      "agents/api-client.md"
    ],
    "files_to_delete": [],
    "estimated_effort_days": 5,
    "current_context": 52000,
    "projected_context": 24000,
    "context_savings": 28000,
    "reduction_percentage": 0.54
  }
}
```

---

## generate-script-extraction-spec

Generate conversion specification for inline logic extraction.

**Input:**
- `entity_name`: Name of skill/agent with inline logic (e.g., "data-validator")
- `current_architecture`: Details of inline logic patterns
- `output_format`: "markdown" or "json"

**Process:**
1. Load `workflow/generate-script-extraction-spec.md`
2. Read current file
3. Identify inline logic patterns (bash commands, algorithms, etc.)
4. Design script structure
5. Map logic to scripts
6. Design skill interface
7. Generate before/after examples

**Output:**
```json
{
  "status": "success",
  "specification": {
    "entity_name": "data-validator",
    "conversion_type": "inline-logic",
    "spec_content": "... full markdown specification ...",
    "inline_logic_instances": 8,
    "patterns_detected": {
      "bash_commands": ["grep", "awk", "jq"],
      "file_operations": ["cp", "mv", "mkdir"],
      "data_transformations": ["parse json", "calculate totals"]
    },
    "files_to_create": [
      "skills/data-validator/scripts/validate-schema.sh",
      "skills/data-validator/scripts/check-format.sh",
      "skills/data-validator/scripts/calculate-stats.sh"
    ],
    "files_to_modify": [
      "skills/data-validator/SKILL.md"
    ],
    "files_to_delete": [],
    "estimated_effort_days": 2,
    "current_logic_tokens": 15000,
    "projected_logic_tokens": 3000,
    "context_savings": 12000,
    "reduction_percentage": 0.80
  }
}
```

---

## validate-specs

Validate generated specifications for completeness and actionability.

**Input:**
- `generated_specs`: Array of specification objects

**Process:**
1. For each spec, check required sections exist:
   - Overview
   - Current architecture
   - Target architecture
   - Conversion steps
   - Before/after examples
   - Testing criteria
   - Effort estimate
2. Validate effort estimates are reasonable
3. Check file paths are valid
4. Ensure code examples are syntactically correct

**Output:**
```json
{
  "status": "success",
  "validation_results": {
    "all_valid": true,
    "specs_validated": 5,
    "checks_passed": {
      "has_before_after": true,
      "has_step_by_step": true,
      "has_effort_estimate": true,
      "has_testing_criteria": true,
      "has_code_examples": true,
      "file_paths_valid": true
    },
    "issues": [],
    "warnings": [
      "catalog-processor: Effort estimate (15 days) higher than average"
    ]
  }
}
```

**If validation fails:**
```json
{
  "status": "error",
  "validation_results": {
    "all_valid": false,
    "specs_validated": 5,
    "issues": [
      {
        "entity": "data-manager",
        "issue": "missing_before_after_examples",
        "severity": "critical",
        "section": "Conversion Steps"
      }
    ]
  }
}
```

</OPERATIONS>

<DOCUMENTATION>
Upon completion:

```
✅ COMPLETED: Spec Generator
───────────────────────────────────────
Operation: {operation_name}
Entity: {entity_name}
Output: {output_size} characters
───────────────────────────────────────
```
</DOCUMENTATION>
