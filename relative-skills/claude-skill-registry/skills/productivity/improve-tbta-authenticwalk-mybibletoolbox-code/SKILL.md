---
name: improve-tbta
description: Systematically work through TBTA features using the 6-stage STAGES.md workflow. Use when user wants to improve TBTA features, work on TBTA, or continue TBTA feature work.
---

# TBTA Feature Workflow

## Overview

This skill guides systematic work through TBTA (The Bible Translator's Assistant) features using the definitive 6-stage approach from STAGES.md. Each stage uses subagents to prevent context pollution, with rigorous validation throughout.

## When to Use

Use this skill when user says:
- "improve tbta" or "improve tbta features"
- "work on tbta" or "work on the next tbta feature"
- "continue tbta feature work" or "next tbta task"

## Core Workflow: 6-Stage Approach

Follow [/plan/tbta-rebuild-with-llm/features/STAGES.md](../../plan/tbta-rebuild-with-llm/features/STAGES.md) for all feature work. Brief summary:

### Stage 1: Research TBTA Documentation
**Goal**: Review source TBTA PDF, our analysis, generate feature README
**Outputs**: Feature `README.md` with comprehensive understanding
**Key**: Review official TBTA docs + our existing analysis documents

### Stage 2: Language Study
**Goal**: Determine which languages need this feature, update README
**Outputs**: Language family analysis added to README
**Key**: Use `/languages/` directory to identify target language families

### Stage 3: Scholarly and Internet Research
**Goal**: Find academic articles and web resources, update README
**Outputs**: README with latest research findings
**Key**: Build comprehensive understanding before generating test data

### Stage 4: Generate Proper Test Set
**CRITICAL**: This MUST be done in a subagent to prevent seeing answers!
**Goal**: Get 100 verses per value, split into train (40%), test (30%), validate (30%)
**Outputs**: `train.yaml`, `test.yaml`, `validate.yaml` with verse references + TBTA values
**Key**: Subagent clones TBTA data, analyzes frequency, generates balanced samples

### Stage 5: Propose Hypothesis and First Prompt
**Goal**: Review train.yaml, create ANALYSIS.md with 12 approaches, develop PROMPT1.md
**Outputs**: Iterative prompts (PROMPT1.md, PROMPT2.md, ...) until achieving 100% stated values, 95% dominant values
**Key**: Debug with LEARNINGS.md, refine until cannot improve further

### Stage 6: Test Against Validate Set
**CRITICAL**: Use subagent to prevent seeing validation answers!
**Goal**: Test best prompt against validate.yaml, get peer review from 3 subagents
**Outputs**: Final validation results, peer review feedback, completion summary
**Key**: Iterate back to Stage 5 if peer reviewers find issues

---

## Status Tracking

Track progress in feature README.md with checklist matching STAGES.md:

```markdown
## Stage Completion Status

- [x] Stage 1: Research TBTA Documentation
- [x] Stage 2: Language Study
- [x] Stage 3: Scholarly and Internet Research
- [ ] Stage 4: Generate Proper Test Set
- [ ] Stage 5: Propose Hypothesis and First Prompt
- [ ] Stage 6: Test Against Validate Set
```

---

## Implementation Guide

### Starting a New Feature

1. **Create feature directory**: `/plan/tbta-rebuild-with-llm/features/{feature-name}/`
2. **Follow STAGES.md**: Work through each stage systematically
3. **Use subagents**: For Stages 4 and 6 to prevent context pollution
4. **Document learnings**: Update CROSS-FEATURE-LEARNINGS.md with transferable patterns

### Continuing Existing Feature

1. **Read feature README.md**: Check stage completion status
2. **Continue at current stage**: Pick up where previous work left off
3. **Reference STAGES.md**: Follow definitive workflow for current stage
4. **Update README**: Mark stages complete as you finish them

## Stage-Specific Guidance

For detailed instructions on each stage, refer to [STAGES.md](../../plan/tbta-rebuild-with-llm/features/STAGES.md). Key principles:

### Stage 4: Critical - Use Subagent

**NEVER access TBTA data directly during Stage 4!** This stage MUST be done in a subagent:

```python
# Pseudocode for Stage 4 subagent
subagent_task = """
1. Clone/access TBTA data repository
2. Loop through all TBTA files to find instances of this feature
3. Generate frequency counts for each value
4. Sample 100 verses for each value (balanced)
5. Split into train (40%), test (30%), validate (30%)
6. Generate YAML files with verse references + TBTA values
7. Return file paths (DO NOT return the actual data)
"""
```

The main agent should never see the actual TBTA values for test/validate sets until Stage 6.

### Stage 5: Iterative Prompt Development

**Success Criteria**:
- **100% accuracy** on "stated values" (when you give only one answer)
- **95% accuracy** on "dominant values" (when you give primary + rationale)
- God's word is inerrant - less than 100% on stated values is not acceptable

**Process**:
1. Review train.yaml (TBTA values visible for training only)
2. Create ANALYSIS.md with 12 different approaches
3. Develop PROMPT1.md based on best approach
4. Test on train set, record results in LEARNINGS.md
5. Debug errors, refine to PROMPT2.md
6. Iterate until cannot improve further

### Stage 6: Final Validation with Peer Review

**NEVER check TBTA validate data yourself!** Use subagents:

1. **Subagent 1**: Apply best prompt to validate.yaml, return predictions
2. **Subagent 2**: Check predictions against TBTA, calculate accuracy
3. **Subagents 3-5**: Three peer reviewers (assume junior coder wrote this, be critical)
4. **Main agent**: Integrate feedback, decide if returning to Stage 5 or marking complete

---

## Context Management

**Key Principle**: Use subagents to prevent context pollution

1. **Stages 1-3**: Main agent can read/research directly
2. **Stage 4**: MUST use subagent to access TBTA and generate test sets
3. **Stage 5**: Main agent works with train.yaml only (training data visible)
4. **Stage 6**: MUST use subagents for validation and peer review

**Why**: The main agent should NEVER see the actual TBTA values for test/validate sets until final reporting.

---

## Success Criteria

**Per-feature completion**:
- All 6 stages completed
- Stage checklist in README.md marked complete
- Accuracy targets met:
  - **100%** on stated values (single answer)
  - **95%** on dominant values (primary + rationale)
- Peer review passed (3 critical reviewers satisfied)
- Learnings added to CROSS-FEATURE-LEARNINGS.md

**File Structure**:
```
features/{feature}/
├── README.md (with stage checklist)
├── experiments/
│   ├── ANALYSIS.md (12 approaches analyzed)
│   ├── PROMPT1.md, PROMPT2.md, ... (iterative refinement)
│   ├── LEARNINGS.md (debugging notes)
│   ├── train.yaml (40% of data)
│   ├── test.yaml (30% of data)
│   ├── validate.yaml (30% of data)
│   └── VALIDATION-RESULTS.md (final accuracy)
└── [other supporting docs]
```

---

**Skill Status**: Ready for activation
**Next action**: User says "improve tbta"
**Expected**: Agent follows STAGES.md workflow for current/next feature
