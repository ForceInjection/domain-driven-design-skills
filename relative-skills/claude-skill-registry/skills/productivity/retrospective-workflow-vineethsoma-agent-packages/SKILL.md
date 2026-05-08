---
name: retrospective-workflow
description: Systematic post-story retrospective process with automated metrics gathering, structured feedback collection, and Agent Package Manager handoff generation
---

# Retrospective Workflow

Facilitate structured retrospectives after story completion to capture learnings and drive continuous improvement.

## What This Provides

### Templates
- **retro-process.md**: Complete retrospective facilitation guide
- Retro document template with metrics, successes, improvements
- YAML handoff spec template for Agent Package Manager

### Scripts
- **init-retrospective.sh**: Initialize retro directory structure
- **gather-retro-metrics.sh**: Collect commits, tests, coverage, duration
- **validate-retro.sh**: Verify completeness before handoff

### Prompts
- **/facilitate-retrospective**: AI-guided retro facilitation
- **/create-handoff-spec**: Generate YAML for Agent Package Manager

## When to Use

**Trigger**: After story merge to main
**Owner**: Retro Specialist
**Duration**: 30-45 minutes

## Quick Start

```bash
# 1. Initialize retrospective
./scripts/init-retrospective.sh us-001

# 2. Gather metrics automatically
./scripts/gather-retro-metrics.sh us-001

# 3. Facilitate retro (use prompt)
/facilitate-retrospective us-001

# 4. Validate before handoff
./scripts/validate-retro.sh us-001
```

## Directory Structure

```
specs/{feature}/stories/us-{number}/retro/
├── retro.md          # Retrospective document
└── handoff.yml       # Agent Package Manager handoff spec
```

## Integration

**Triggers**: Feature Lead after story merge
**Output**: Handoff to Agent Package Manager for primitive updates
**Tracks**: `.memory/retro-log.md` for historical learnings

## Validation

Retro is complete when:
- ✅ All metrics filled (no [Fill] placeholders)
- ✅ Successes and improvements documented
- ✅ Action items have owners and targets
- ✅ Handoff YAML valid syntax
- ✅ Changes list version bumps required
