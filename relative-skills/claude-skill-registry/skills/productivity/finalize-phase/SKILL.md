---
name: finalize-phase
description: "Standard Operating Procedure for /finalize phase. Covers workflow completion, artifact archival, roadmap updates, and knowledge preservation."
allowed-tools: Read, Write, Edit, Grep, Bash
---

# Finalize Phase: Standard Operating Procedure

> **Training Guide**: Step-by-step procedures for completing feature workflows and preserving knowledge.

**Supporting references**:
- [reference.md](reference.md) - Finalization checklist, archival procedures
- [examples.md](examples.md) - Complete finalization vs rushed cleanup

---

## Phase Overview

**Purpose**: Complete feature workflow, update roadmap, archive artifacts, preserve knowledge.

**Inputs**:
- Deployed feature (production-ready)
- All phase artifacts (spec, plan, tasks, reports)
- Ship report with deployment details

**Outputs**:
- Updated roadmap (moved to "Shipped")
- Archived artifacts
- Updated README (if applicable)
- Cleaned up branches (if applicable)
- Updated `workflow-state.yaml`

**Expected duration**: 10-15 minutes

---

## Execution Steps

### Step 1: Update Roadmap

**Actions**:
1. Move feature from "In Progress" to "Shipped" in roadmap
2. Add completion date, version, and production URL
3. Link to ship report and release notes

**Example**:
```markdown
## Shipped

### Student Progress Dashboard (v1.3.0) - Shipped 2025-10-21
- **Production URL**: https://app.example.com/students/progress
- **Ship Report**: [specs/042-student-progress-dashboard/ship-summary.md]
- **Release Notes**: [v1.3.0]
- **Impact**: Teachers can now track student progress with completion rates and time spent
```

---

### Step 2: Archive Artifacts

**Actions**:
Archive all workflow artifacts in `specs/NNN-slug/`:
- [x] spec.md
- [x] plan.md
- [x] tasks.md
- [x] optimization-report.md
- [x] preview-checklist.md
- [x] ship-summary.md
- [x] release-notes.md
- [x] workflow-state.yaml

---

### Step 3: Update Documentation

**Actions**:
Update README or docs if user-facing feature:
- [ ] README.md: Add feature to feature list
- [ ] docs/: Create user guide (if complex feature)
- [ ] CHANGELOG.md: Add release entry

---

### Step 4: Clean Up Branches

**Actions**:
```bash
# Delete feature branch (if merged)
git branch -d feature/042-student-progress-dashboard

# Delete remote branch (if applicable)
git push origin --delete feature/042-student-progress-dashboard
```

---

### Step 5: Commit Finalization

**Actions**:
```bash
git add .spec-flow/memory/roadmap.md README.md CHANGELOG.md
git commit -m "chore: finalize student-progress-dashboard feature

- Updated roadmap: Moved to Shipped (v1.3.0)
- Updated README: Added progress dashboard to features list
- Updated CHANGELOG: Added v1.3.0 release entry
- Archived all artifacts in specs/042-student-progress-dashboard/
- Cleaned up feature branch

Feature complete - workflow closed
"
```

---

## Common Mistakes

### 🚫 Roadmap Not Updated
**Impact**: Roadmap stale, lost tracking
**Prevention**: Always move to "Shipped" with completion date and links

### 🚫 Incomplete Documentation
**Impact**: Knowledge loss, onboarding friction
**Prevention**: Update README, create user guides, preserve all artifacts

---

## Completion Criteria

**Phase is complete when**:
- [ ] Roadmap updated (moved to "Shipped")
- [ ] All artifacts archived
- [ ] Documentation updated
- [ ] Branches cleaned up
- [ ] Finalization committed

---

_This SOP guides the finalize phase. Refer to reference.md for finalization checklists._
