---
name: housekeeping
description: Perform comprehensive project housekeeping - update roadmap, reconcile issues with implementation reality, organize completed work, and identify drift. This is a workflow skill that coordinates multiple parallel subagents for efficiency.  Use when user says something like "run housekeeping", "do your housekeeping" or "clean up project state".
---

You are the housekeeping workflow coordinator. Your job is to ensure the project's documentation and issue tracking accurately reflects reality, organize completed work, and provide a clear snapshot of current state and next steps.

## Core Responsibilities

## Skill Usage Announcement

**MANDATORY**: When using this skill, announce it at the start with:

```
🔧 Using Skill: housekeeping | [brief purpose based on context]
```

**Example:**
```
🔧 Using Skill: housekeeping | [Provide context-specific example of what you're doing]
```

This creates an audit trail showing which skills were applied during the session.



- Update `.wrangler/ROADMAP_NEXT_STEPS.md` to reflect current reality
- Refresh governance metrics across all governance documents
- Reconcile open issues with actual implementation
- Move completed issues to organized archive
- Identify documentation drift or missing updates
- Verify constitutional alignment in specifications
- Generate housekeeping summary report with metrics

## Execution Strategy: Multi-Phase Workflow

This is a **workflow skill** - it coordinates multiple subagents in parallel for maximum efficiency.

### **Phase 1: Governance Refresh (Sequential)**

**Why sequential:** Need current state understanding before dispatching parallel agents.

**Task:** Update governance documents to reflect current reality

**Approach:**

**1.1 Refresh Governance Metrics**

Use the `refresh-metrics` skill (invoke with Skill tool) to update:

- `.wrangler/issues/README.md` - Issue counts and status percentages
- `.wrangler/specifications/README.md` - Spec counts and constitutional compliance
- `.wrangler/ROADMAP_NEXT_STEPS.md` - Implementation status and overall % complete

**1.2 Update Roadmap Next Steps**

After metrics refresh, manually review and update Next Steps:

1. Read `.wrangler/ROADMAP_NEXT_STEPS.md`
2. Review recent git commits (last 20-30 commits) for completed work
3. Review recently closed issues and specifications
4. Update three categories:
   - Move ⚠️ → ✅ if features fully completed
   - Move ❌ → ⚠️ if features started implementation
   - Add new ❌ items if gaps identified
5. Update "What Works Well" and "Critical Gap" sections
6. Update "Prioritized Roadmap" if priorities shifted
7. Update "Last Updated By" and "Next Review" dates

**1.3 Verify Constitutional Compliance**

Check if any specifications lack constitutional alignment:

```bash
# Find specs missing constitutional alignment
grep -L "Constitutional Alignment" .wrangler/specifications/*.md | grep -v "_CONSTITUTION\|_ROADMAP\|README"
```

If found, note for Agent C (Documentation Drift) to flag.

**Output:**

- Updated governance metrics
- Updated roadmap Next Steps
- List of specs needing constitutional alignment sections

---

### **Phase 2: Parallel Issue Reconciliation (Parallel)**

**Why parallel:** Three independent tasks with no dependencies - run simultaneously for speed.

Launch **three parallel subagents** using the Task tool:

#### **Agent A: Open Issues Reconciliation**

**Task:** Review all open issues and ensure they match implementation reality

**Approach:**

1. List all open issues (`issues_list` with `status: ["open", "in_progress"]`)
2. For each open issue:
   - Read the issue content
   - Check if described work has actually been completed
   - Check if requirements have changed during implementation
   - Identify issues that should be closed but weren't
   - Identify issues that need updates due to design changes
3. Take action:
   - **If completed but not closed:** Use `issues_mark_complete` or `issues_update` to close
   - **If requirements drifted:** Use `issues_update` to reflect actual implementation
   - **If blocked/cancelled:** Use `issues_update` to mark status appropriately
4. Track metrics:
   - Issues reviewed: [count]
   - Issues closed: [count]
   - Issues updated: [count]
   - Issues with drift: [count]

**Output:** List of actions taken and current state summary

---

#### **Agent B: Completed Issues Organization**

**Task:** Move completed/closed issues to `.wrangler/issues/completed/` directory for archival

**Approach:**

1. List all closed issues (`issues_list` with `status: ["closed", "cancelled"]`)
2. Check if `.wrangler/issues/completed/` directory exists, create if not
3. For each closed issue:
   - Check if still in `.wrangler/issues/` root directory
   - If yes, move to `.wrangler/issues/completed/`
   - Preserve filename (don't rename)
4. Track metrics:
   - Completed issues found: [count]
   - Issues moved: [count]
   - Already organized: [count]

**Output:** Organization summary with file counts

---

#### **Agent C: Documentation Drift Detection**

**Task:** Identify areas where documentation may not reflect implementation reality, including governance compliance

**Approach:**

1. Read key documentation files:
   - README.md
   - CLAUDE.md (or equivalent project documentation)
   - `.wrangler/CONSTITUTION.md`
   - `.wrangler/ROADMAP.md`
   - Any specification files
2. Review recent git commits for major changes
3. Look for signs of drift:
   - Features mentioned in docs but not implemented
   - Features implemented but not documented
   - API changes not reflected in docs
   - Configuration changes not updated
   - File structure changes not documented
   - **Specifications missing constitutional alignment sections**
   - **Roadmap phases not reflected in Next Steps**
   - **Constitutional principles violated in recent code**
4. Create list of documentation updates needed
5. Track metrics:
   - Documentation files reviewed: [count]
   - Drift issues found: [count]
   - **Constitutional compliance gaps**: [count]
   - Severity: High/Medium/Low

**Output:** List of documentation drift issues with recommendations, including governance compliance issues

---

#### **Agent D: Root Directory Organization**

**Task:** Clean up and organize markdown files at project root

**Approach:**

1. Scan project root for organizational candidates:
   - RCA-_.md, ANALYSIS-_.md, IMPLEMENTATION-\*.md, etc.
   - Any ALL_CAPS.md files (excluding standard files like README.md)
2. Categorize each file:
   - **Delete** if obsolete (discarded analysis, temp notes)
   - **Move to memos/** if reference material (RCA, lessons learned, summaries)
   - **Move to docs/** if user-facing documentation
   - **Move to devops/docs/** if developer/maintainer documentation
3. Execute actions (delete or move with appropriate naming)
4. Track metrics:
   - Files processed: [count]
   - Deleted: [count]
   - Moved to memos/: [count]
   - Moved to docs/: [count]
   - Moved to devops/docs/: [count]

**Output:** Organized root directory with action summary

---

### **Phase 3: Summary Report (Sequential)**

**Why sequential:** Needs results from all Phase 2 agents.

**Task:** Compile comprehensive housekeeping report

**Approach:**

1. Wait for all Phase 2 agents to complete
2. Aggregate metrics from all agents
3. Create summary report showing:
   - Roadmap status (updated/current)
   - Issues reconciled (count, actions taken)
   - Files organized (count, location)
   - Documentation drift (issues found, severity)
   - Time taken per phase (if trackable)
   - Recommendations for follow-up work

**Output:** Housekeeping summary report

---

## Workflow Execution Plan

### **Step 1: Start Phase 1 (Governance Refresh)**

Execute governance refresh yourself:

1. Invoke `refresh-metrics` skill using Skill tool
2. Manually update Next Steps with recent completions
3. Check for specs missing constitutional alignment

### **Step 2: Launch Phase 2 Parallel Agents**

Use **three separate Task tool calls in a single message** to dispatch parallel agents:

```
I'm launching four parallel housekeeping agents:

[Use Task tool - Agent A: Open Issues Reconciliation]
[Use Task tool - Agent B: Completed Issues Organization]
[Use Task tool - Agent C: Documentation Drift Detection]
[Use Task tool - Agent D: Root Directory Organization]
```

**CRITICAL:** All four Task tool calls must be in a **single response** to execute truly in parallel.

### **Step 3: Collect Results & Generate Report**

Wait for all agents to complete, then compile summary report.

---

## Housekeeping Report Template

```markdown
# Housekeeping Report - [Date]

## Summary

Housekeeping workflow completed successfully.

**Duration:** [X] minutes total

- Phase 1 (Governance refresh): [X] minutes
- Phase 2 (Parallel reconciliation): [X] minutes
- Phase 3 (Report generation): [X] minutes

## Governance Refresh

✅ **Metrics Updated**:

- `.wrangler/issues/README.md` - Updated issue counts and status percentages
- `.wrangler/specifications/README.md` - Updated spec counts and constitutional compliance
- `.wrangler/ROADMAP_NEXT_STEPS.md` - Updated implementation status

**Overall Project Completion**: ~[X]% ([+/-]% since last housekeeping)

**Completed since last housekeeping:**

- [Item 1]
- [Item 2]

**Current priorities:**

- [Priority 1]
- [Priority 2]

**Blockers identified:**

- [Blocker 1 if any]

**Constitutional Compliance**:

- Specifications with alignment: [X]/[Y] ([Z]%)
- Specifications needing alignment sections: [count]

## Issue Reconciliation

**Agent A - Open Issues:**

- Issues reviewed: [count]
- Issues closed: [count]
- Issues updated for drift: [count]
- Status: ✅ Complete

**Agent B - Completed Issues Organization:**

- Completed issues found: [count]
- Issues moved to archive: [count]
- Status: ✅ Complete

**Agent C - Documentation Drift:**

- Documentation files reviewed: [count]
- Drift issues found: [count]
  - High severity: [count]
  - Medium severity: [count]
  - Low severity: [count]
- Constitutional compliance gaps: [count]
- Status: ✅ Complete

**Agent D - Root Directory Organization:**

- Files processed: [count]
- Deleted (obsolete): [count]
- Moved to memos/: [count]
- Moved to docs/: [count]
- Moved to devops/docs/: [count]
- Status: ✅ Complete

## Actions Taken

### Issues Closed

- #000XXX - [Issue title] - Reason: [completed/cancelled]

### Issues Updated

- #000XXX - [Issue title] - Change: [what was updated]

### Files Organized

- Moved [X] issues to `issues/completed/`

### Documentation Drift Issues

**High Priority:**

- [ ] [Issue 1 description]

**Medium Priority:**

- [ ] [Issue 2 description]

**Low Priority:**

- [ ] [Issue 3 description]

## Recommendations

1. [Recommendation 1]
2. [Recommendation 2]

## Metrics

- Total issues in system: [count]
- Open issues: [count]
- In progress: [count]
- Completed: [count]
- Issue completion rate: [X]%
- Documentation coverage: [assessment]

---

_Housekeeping workflow v1.0 - Generated by wrangler:housekeeping_
```

---

## Usage Examples

### **Example 1: Regular Housekeeping**

**User:** "Run housekeeping"

**Agent Response:**

1. "Starting housekeeping workflow..."
2. "Phase 1: Updating `.wrangler/ROADMAP_NEXT_STEPS.md`..."
3. "Phase 2: Launching three parallel reconciliation agents..."
   - Dispatches Agent A (issues)
   - Dispatches Agent B (organization)
   - Dispatches Agent C (drift detection)
4. Waits for completion
5. "Phase 3: Generating housekeeping report..."
6. Presents summary report

---

### **Example 2: Post-Sprint Housekeeping**

**User:** "We just finished the authentication feature sprint, run housekeeping"

**Agent Response:**

1. Updates roadmap with authentication feature completion
2. Reconciles auth-related issues
3. Moves completed auth issues to archive
4. Checks if auth documentation is up to date
5. Reports on sprint completion status

---

## Workflow Metrics & Observability

Track these metrics for workflow optimization:

**Efficiency Metrics:**

- Total housekeeping time
- Time per phase
- Parallel speedup factor (Phase 2 time vs. sequential equivalent)

**Action Metrics:**

- Issues reconciled
- Files organized
- Drift issues found
- Documentation updates needed

**Health Metrics:**

- Issue staleness (open issues > 30 days)
- Documentation drift severity
- Roadmap currency (last update date)

These metrics help identify:

- Bottlenecks in workflow
- Areas needing more frequent housekeeping
- Project health indicators

---

## Important Implementation Notes

### **Parallel Execution**

To run Phase 2 agents in **true parallel**, you MUST:

1. Use the Task tool **three times** in a **single response**
2. Do NOT wait for Agent A to finish before launching Agent B
3. All three tool calls should be in the same message

**Example (correct parallel execution):**

```
I'm launching three parallel agents for Phase 2 housekeeping:

[Task tool call for Agent A]
[Task tool call for Agent B]
[Task tool call for Agent C]

All three agents are now running in parallel...
```

**Example (incorrect - sequential execution):**

```
Launching Agent A...
[Wait for Agent A]
Now launching Agent B...
[Wait for Agent B]
Now launching Agent C...
```

### **State Isolation**

Each Phase 2 agent operates on independent data:

- Agent A: Open issues (won't touch closed)
- Agent B: Closed issues (won't touch open)
- Agent C: Documentation (won't touch issues)
- Agent D: Root markdown files (won't touch issues/docs/memos)

This ensures no conflicts or race conditions.

### **Idempotency**

Housekeeping is idempotent - running it multiple times is safe:

- Roadmap: Last update wins (always reflects current)
- Issues: Already-closed issues stay closed
- Organization: Already-moved files stay moved
- Drift: Re-detection is harmless

---

## Extensibility

Future enhancements could add more parallel agents:

**Agent D: Dependency Updates**

- Check for outdated dependencies
- Identify security vulnerabilities

**Agent E: Test Coverage Analysis**

- Identify untested code
- Generate test coverage report

**Agent F: Performance Regression Detection**

- Run benchmarks
- Compare to baseline

**Agent G: Code Quality Metrics**

- Run linters
- Check complexity metrics

The workflow framework is designed to scale to arbitrary parallel agents.

---

## Success Criteria

Housekeeping is successful when:

✅ Governance metrics refreshed across all documents
✅ Roadmap Next Steps accurately reflects current state and priorities
✅ Constitutional compliance verified and gaps identified
✅ All completed issues are marked as closed
✅ All closed issues are archived in `.wrangler/issues/completed/`
✅ Issue descriptions match implementation reality
✅ Documentation drift is identified and catalogued (including governance compliance)
✅ Summary report provides actionable insights
✅ Workflow completes in reasonable time (< 5 minutes for typical project)

---

## Frequency Recommendations

**When to run housekeeping:**

- After completing major features
- Weekly for active projects
- Before starting new sprints/milestones
- Before creating release
- When project feels "messy" or out of sync

**Automation potential:**

- Could be triggered by git hooks (post-merge)
- Could run on schedule (weekly cron)
- Could be part of CI/CD pipeline
