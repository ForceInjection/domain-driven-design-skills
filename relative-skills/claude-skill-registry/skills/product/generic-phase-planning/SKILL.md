---
name: Generic Phase Planning
description: Template-based phase planning for any project. Use when user requests to start a new phase, create implementation plan, or begin major feature development. Ensures master plan consultation and structured planning workflow.
allowed-tools: Read, Glob, WebFetch
version: 1.0.0
---

# Generic Phase Planning

## Purpose
Provides universal phase planning workflow with template-based approach, ensuring all critical planning elements are addressed before implementation begins.

## When This Activates
- User says "start phase", "start new phase", "plan phase"
- User requests "create implementation plan", "plan implementation"
- User mentions "begin feature development", "start feature"
- User attempts implementation without documented plan

## Prerequisites
- [ ] Project has master plan or planning documentation
- [ ] Previous phase complete (if applicable)
- [ ] Project configuration available

## Configuration Required

**Projects must provide these paths:**
- `${PROJECT_MASTER_PLAN_PATH}` - Path to project master plan
- `${PROJECT_DOCS_PATH}` - Documentation directory for plans
- `${PROJECT_PHASE_FORMAT}` - Phase naming convention

**Example Configuration (provided by project-specific skill):**
```
PROJECT_MASTER_PLAN_PATH: Documentation/General/MASTER_PROJECT_PLAN.md
PROJECT_DOCS_PATH: Documentation/PhaseX/Plans/
PROJECT_PHASE_FORMAT: PHASE_[X]_[NAME]_PLAN.md
```

---

## Steps

### Step 1: Check for Project Configuration
**Actions:**
- Look for project-specific phase-planning skill in `.claude/skills/phase-planning/`
- If exists: Load project configuration
- If not exists: Request configuration from user

**Validation:**
- [ ] Configuration paths provided
- [ ] Paths exist in project

**Error Handling:**
If configuration missing:
  → Prompt user: "This project needs phase planning configuration. Please provide:
     - Master plan location
     - Documentation path
     - Phase naming format"

---

### Step 2: Consult Master Plan (if configured)
**Actions:**
- Read `${PROJECT_MASTER_PLAN_PATH}` if provided
- Identify current project phase
- Verify prerequisites for next phase
- Check previous phase completion status

**Validation:**
- [ ] Master plan accessible
- [ ] Current phase identified
- [ ] Prerequisites documented

**Error Handling:**
If master plan missing:
  → Warning: "Master plan not found. Proceeding with basic planning."

---

### Step 3: Verify Prerequisites
**Use Checklist:** [checklists/prerequisites-checklist.md](checklists/prerequisites-checklist.md)

**Check:**
- [ ] Previous phase complete (if applicable)
- [ ] Previous phase has completion report (if required)
- [ ] Dependencies resolved
- [ ] Resources available
- [ ] Team aligned on objectives

**Error Handling:**
If prerequisites not met:
  → Block: "Prerequisites not met. Address the following before planning:
     - [List unmet prerequisites]"

---

### Step 4: Load Phase Plan Template
**Actions:**
- Read [templates/phase-plan-template.md](templates/phase-plan-template.md)
- Prepare template for population

**Template Includes:**
- Executive Summary
- Objectives
- Prerequisites
- Deliverables
- Success Criteria
- Risks & Mitigation
- Timeline
- Micro Save Points

---

### Step 5: Gather Phase Information
**Collect from user:**
- Phase name/number
- Primary objectives (3-5 objectives)
- Key deliverables
- Estimated duration
- Success criteria
- Known risks
- Resource requirements

**Interactive:**
Ask user for each element, provide examples if needed

---

### Step 6: Populate Template
**Actions:**
- Replace all placeholders in template:
  - `{{PHASE_NAME}}`
  - `{{PHASE_NUMBER}}`
  - `{{OBJECTIVES}}`
  - `{{DELIVERABLES}}`
  - `{{TIMELINE}}`
  - `{{RISKS}}`
  - etc.
- Format for readability
- Add project-specific sections (if configured)

---

### Step 7: Define Micro Save Points
**Actions:**
- Break phase into 30-45 minute work increments
- Define concrete deliverable for each save point
- Ensure each is independently testable
- Number sequentially

**Example:**
```
MSP-1: Create database schema definition
MSP-2: Implement user table with migrations
MSP-3: Add authentication endpoints
...
```

---

### Step 8: Present Plan for Approval
**Actions:**
- Display complete phase plan
- Highlight key elements (objectives, timeline, risks)
- Request user approval

**User Options:**
- Approve: Proceed to Step 9
- Modify: Return to Step 5 for adjustments
- Cancel: Exit planning

---

### Step 9: Write Phase Plan (if configured)
**Actions:**
- If `${PROJECT_DOCS_PATH}` configured:
  - Write plan to `${PROJECT_DOCS_PATH}/${PHASE_NAME}_PLAN.md`
  - Confirm file written
- If not configured:
  - Provide plan as text output
  - Suggest manual save location

**Validation:**
- [ ] File written successfully
- [ ] File readable
- [ ] All sections present

---

### Step 10: Update Master Plan (if applicable)
**Actions:**
- If master plan exists and project has update protocol:
  - Note new phase in master plan status
  - Link to phase plan
  - Update current phase indicator
- If not:
  - Skip this step

---

## Output

**Primary Output:**
- Complete phase plan document with all sections
- Either written to file or provided as text

**Secondary Outputs:**
- Master plan updated (if configured)
- Prerequisites verification report
- Next steps guidance

---

## Error Handling

### Common Errors

**1. Missing Configuration**
- **Cause:** No project-specific skill found
- **Response:** Request configuration from user
- **Recovery:** Use basic template without project paths

**2. Master Plan Not Found**
- **Cause:** Path incorrect or file moved
- **Response:** Warning message, continue without master plan
- **Recovery:** Proceed with basic planning

**3. Prerequisites Not Met**
- **Cause:** Previous phase incomplete
- **Response:** Block planning, list unmet prerequisites
- **Recovery:** User must address prerequisites first

**4. Template Loading Failed**
- **Cause:** Template file missing
- **Response:** Use inline basic template
- **Recovery:** Generate plan with standard sections

---

## Integration Points

**Invoked By:**
- User request for new phase/implementation
- Project workflows at phase boundaries

**Invokes:**
- May trigger prerequisite validation workflows
- May update master plan via master-plan-update skill (if exists)

**Works With:**
- completion-report skill (verifies previous phase complete)
- Project-specific phase-planning skill (provides configuration)

---

## Examples

### Example 1: CA Lobby Phase Planning

**User Says:**
```
"Let's start planning Phase 2g"
```

**Skill Activates:**
1. Finds CA Lobby phase-planning skill in `.claude/skills/phase-planning/`
2. Loads configuration:
   - PROJECT_MASTER_PLAN_PATH: Documentation/General/MASTER_PROJECT_PLAN.md
   - PROJECT_DOCS_PATH: Documentation/Phase2/Plans/
3. Reads master plan, verifies Phase 2f complete
4. Checks for Phase 2f completion report
5. Loads phase plan template
6. Gathers Phase 2g information from user
7. Populates template with CA Lobby-specific sections
8. Writes to Documentation/Phase2/Plans/PHASE_2G_PLAN.md
9. Updates master plan with new phase

---

### Example 2: Generic Project (No Configuration)

**User Says:**
```
"Plan the authentication feature implementation"
```

**Skill Activates:**
1. No project-specific skill found
2. Requests basic configuration from user:
   - "Where should I save the plan?"
   - "Do you have a master plan to reference?"
3. Uses basic template
4. Gathers feature information
5. Generates plan as text output
6. User manually saves plan

---

## Supporting Files

- [templates/phase-plan-template.md](templates/phase-plan-template.md) - Standard phase plan template
- [checklists/prerequisites-checklist.md](checklists/prerequisites-checklist.md) - Prerequisites verification

---

## Notes

**For Project-Specific Skills:**
- Extend this generic skill with `extends: generic-skills/phase-planning`
- Provide configuration values
- Add project-specific sections to template
- Customize validation rules as needed

**Best Practices:**
- Always verify prerequisites before planning
- Ensure previous phase complete
- Define concrete, testable deliverables
- Break into micro save points (30-45 min increments)
- Get user approval before proceeding to implementation

---

## Changelog

### Version 1.0.0 (2025-10-20)
- Initial release
- Template-based planning workflow
- Configurable for any project
- Prerequisites verification
- Micro save point methodology

---

**End of Skill**
