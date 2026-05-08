---
name: elicitation-methodology
description: Hub skill for requirements elicitation. Provides technique selection, orchestration guidance, LLMREI patterns, and autonomy level configuration. Use when gathering requirements from stakeholders, conducting elicitation sessions, or preparing requirements for specification.
allowed-tools: Read, Glob, Grep, Write, Skill, Task
---

# Elicitation Methodology

Central hub for requirements elicitation methodology, technique selection, and workflow orchestration.

## When to Use This Skill

**Keywords:** requirements gathering, elicitation, stakeholder needs, requirement discovery, user needs, feature requests, interview, requirements session

Invoke this skill when:

- Starting a new requirements elicitation effort
- Selecting appropriate elicitation techniques
- Orchestrating multi-source elicitation
- Configuring autonomy levels for AI assistance
- Understanding LLMREI interview patterns

## Quick Decision Tree

| Scenario | Recommended Approach |
|----------|---------------------|
| Have stakeholders to interview | Use `interview-conducting` skill |
| Have documents/PDFs to mine | Use `document-extraction` skill |
| Working solo, need perspectives | Use `stakeholder-simulation` skill |
| Need domain knowledge | Use `domain-research` skill |
| Checking completeness | Use `gap-analysis` skill |
| Ready for specification | Use `/export` command |

## Elicitation Techniques

### 1. Stakeholder Interviews (LLMREI Pattern)

AI-conducted interviews using research-backed prompting strategies.

**When to use:**

- Direct access to stakeholders
- Complex domains requiring exploration
- Need to capture tacit knowledge

**Technique reference:** See `references/llmrei-patterns.md`

### 2. Document Extraction

Mine requirements from existing documentation.

**When to use:**

- Existing requirements documents
- Meeting transcripts
- Regulatory documents
- Competitor analysis

**Delegate to:** `document-extraction` skill

### 3. Stakeholder Simulation

Multi-persona simulation for solo requirements work.

**When to use:**

- Working without direct stakeholder access
- Need diverse perspectives
- Validating completeness

**Delegate to:** `stakeholder-simulation` skill

### 4. Domain Research

MCP-powered research for domain knowledge.

**When to use:**

- Unfamiliar domain
- Need industry standards
- Competitive analysis
- Technology constraints

**Delegate to:** `domain-research` skill

## Autonomy Levels

### Guided Mode (Human-in-Loop)

```yaml
autonomy: guided
behavior:
  - AI suggests questions, human approves
  - Each requirement validated individually
  - Human controls interview flow
  - Maximum transparency
use_when:
  - Sensitive or regulated domains
  - Learning the elicitation process
  - High-stakes requirements
```

### Semi-Autonomous Mode

```yaml
autonomy: semi-auto
behavior:
  - AI conducts interviews with checkpoints
  - Human validates requirement batches
  - Periodic progress reviews
  - Balance of speed and control
use_when:
  - Standard elicitation projects
  - Moderate domain complexity
  - Trusted AI capabilities
```

### Fully Autonomous Mode

```yaml
autonomy: full-auto
behavior:
  - Complete end-to-end elicitation
  - Human reviews final output only
  - Maximum efficiency
  - AI handles all decisions
use_when:
  - Well-understood domains
  - Time pressure
  - Preliminary discovery
```

## Workflow Orchestration

### Standard Discovery Workflow

```text
1. CONTEXT GATHERING
   ├── Load any existing business context
   ├── Identify available sources (stakeholders, docs, etc.)
   └── Select autonomy level

2. MULTI-SOURCE ELICITATION
   ├── Interviews (if stakeholders available)
   ├── Document extraction (if docs available)
   ├── Domain research (MCP queries)
   └── Stakeholder simulation (if solo mode)

3. SYNTHESIS
   ├── Consolidate requirements from all sources
   ├── Remove duplicates
   ├── Classify by type (functional, NFR, constraint)
   └── Apply MoSCoW prioritization

4. VALIDATION
   ├── Gap analysis
   ├── Completeness checking
   ├── Conflict detection
   └── INVEST scoring

5. OUTPUT
   ├── Save to .requirements/{domain}/
   ├── Generate summary report
   └── Prepare for specification export
```

## Output Format

### Pre-Canonical Requirements

```yaml
# .requirements/{domain}/requirements.yaml
id: REQ-SET-{number}
title: "{Domain} Requirements"
domain: "{domain-name}"
elicitation_date: "{ISO-8601-date}"
autonomy_level: "{guided|semi-auto|full-auto}"

sources:
  - type: interview|document|simulation|research
    reference: "{source-identifier}"
    timestamp: "{ISO-8601-date}"

requirements:
  - id: REQ-{number}
    text: "{requirement statement}"
    source: "{source-type}"
    source_ref: "{specific-reference}"
    priority: must|should|could|wont
    category: functional|non-functional|constraint|assumption
    confidence: high|medium|low
    validation_status: pending|validated|rejected

gaps_identified:
  - category: "{requirement-category}"
    description: "{what's missing}"
    severity: critical|major|minor

metadata:
  total_sources: {number}
  total_requirements: {number}
  gap_count: {number}
  ready_for_specification: true|false
```

## Export Options

After elicitation, requirements can be exported to various specification formats:

```bash
/requirements-elicitation:export --to canonical  # Canonical spec format
/requirements-elicitation:export --to ears       # EARS pattern format
/requirements-elicitation:export --to gherkin    # Gherkin/BDD format
```

## Related Skills

- `interview-conducting` - Detailed LLMREI interview patterns
- `document-extraction` - Document mining techniques
- `stakeholder-simulation` - Persona simulation
- `gap-analysis` - Completeness checking
- `domain-research` - MCP research coordination

## References

- `references/llmrei-patterns.md` - LLMREI prompting strategies
- `references/technique-matrix.md` - Technique selection guidance
- `references/autonomy-levels.md` - Detailed autonomy configuration

---

**Last Updated:** 2025-12-26
