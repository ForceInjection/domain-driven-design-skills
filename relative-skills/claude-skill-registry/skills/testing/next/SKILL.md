---
name: next
description: Assess current project state and suggest the most valuable next action. The primary entry point for users who aren't sure what to do. Analyzes context, checks for issues, and recommends specific skills or actions.
---

# Next Action Assessment

> The intelligent dispatcher that knows your full toolkit and recommends the right action at the right time.

## When to Use

- Starting a work session
- Feeling stuck or unsure what to do next
- After completing a task
- Want AI to assess project state and priorities

## Skill Registry

### By Research Phase

| Phase | Primary Skills | Supporting Skills |
|-------|---------------|-------------------|
| **SETUP** | - | `review-script` |
| **PLANNING** | `hypothesis-generation`, `literature-review`, `deep-research` | `note`, `task` |
| **DEVELOPMENT** | `review-script`, `statistical-analysis` | `note`, `task` |
| **ANALYSIS** | `exploratory-data-analysis`, `statistical-analysis`, `scientific-visualization` | `note`, `task` |
| **WRITING** | `write-background`, `write-methods`, `write-results`, `scientific-writing` | `literature-review` |
| **REVIEW** | `peer-review`, `review-script` | `scientific-writing` |

### By Detected Condition

| Condition | Recommended Skill | Trigger |
|-----------|------------------|---------|
| New data file in `data/` | `exploratory-data-analysis` | Unanalyzed data files detected |
| Empty `background.md` | `literature-review` or `write-background` | No background content |
| Empty `methods.md` | `write-methods` | Scripts exist but no methods doc |
| Figures without results text | `write-results` | Figures in `manuscript/figures/` not in `results.md` |
| New audio in `meetings/` | `transcribe` → `summarize-meeting` | Audio without transcript |
| Scripts without docstrings | `review-script` | Undocumented code |
| No hypothesis documented | `hypothesis-generation` | PLANNING phase, no hypothesis in `project_telos.md` |
| Data quality issues noted | `statistical-analysis` | After EDA identifies issues |
| Ready for figures | `scientific-visualization` | Analysis complete, no pub-quality figures |
| Draft complete | `peer-review` | All manuscript sections have content |
| Monday detected | `plan-week` | Start of work week |
| Friday/End of day | `wrap-up` | End of work session |
| Week boundary | `weekly-review` | 7+ days since last weekly review |
| Month boundary | `monthly-review` | 30+ days since last monthly review |

---

## Execution Steps

### 1. Load Context (REQUIRED)

Read these files to understand current state:

```
~/.researchAssistant/researcher_telos.md  (user profile)
.research/project_telos.md                (project state, current phase)
.research/phase_checklist.md              (what's done/remaining)
.research/logs/activity.md                (recent activity)
tasks.md                                  (pending tasks)
```

Extract:
- **Current phase**: SETUP | PLANNING | DEVELOPMENT | ANALYSIS | WRITING | REVIEW
- **Recent activity**: What did they work on last?
- **Pending tasks**: What's marked as TODO or in-progress?
- **Blockers**: Any noted blockers or uncertainties?

### 2. First-Time Setup Check

**Check for researcher profile:**
```
IF ~/.researchAssistant/researcher_telos.md does NOT exist:
  - Move ./researcher_telos_template.md to ~/.researchAssistant/researcher_telos.md
  - Ask onboarding questions to populate it
  - Create ~/.researchAssistant/ directory if needed
ELSE:
  - Delete ./researcher_telos_template.md if it still exists
  - Load preferences from existing profile
```

**Check for project setup:**
```
IF .research/project_telos.md is mostly empty (mission not defined):
  - Start project onboarding flow
  - Ask: "What's this project about in 1-2 sentences?"
  - Ask: "Is this part of a larger grant?"
  - Ask: "What's your target output?"
```

### 3. Scan for Conditions

Check each condition in order of priority:

#### Critical (Check First)

- **Phase gate violations**: e.g., trying DEVELOPMENT with empty background
- **First-time setup needed**: Profile or project not configured

#### High Priority

- [ ] Uncommitted git changes > 3 days old
- [ ] New data files not yet explored (→ `exploratory-data-analysis`)
- [ ] New meeting recordings (→ `transcribe`)
- [ ] High-priority tasks in `tasks.md`
- [ ] Stale activity (>7 days since last log)

#### Medium Priority  

- [ ] Scripts without documentation (→ `review-script`)
- [ ] Figures without captions (→ `scientific-visualization`)
- [ ] Weekly review due (→ `weekly-review`)
- [ ] Empty manuscript sections appropriate to current phase

#### Low Priority

- [ ] Monday morning (→ `plan-week`)
- [ ] Orphan files or incomplete sections
- [ ] End of day (→ `wrap-up`)

### 4. Consider Phase-Appropriate Skills

Based on current phase, identify which skills are most relevant:

**PLANNING Phase Priorities:**
1. `hypothesis-generation` - Do you have a clear hypothesis?
2. `literature-review` / `deep-research` - Have you surveyed the field?
3. `write-background` - Can you articulate the problem?

**DEVELOPMENT Phase Priorities:**
1. `review-script` - Document as you build
2. `statistical-analysis` - Plan your analysis approach

**ANALYSIS Phase Priorities:**
1. `exploratory-data-analysis` - Understand your data first
2. `statistical-analysis` - Formal testing
3. `scientific-visualization` - Publication figures

**WRITING Phase Priorities:**
1. `write-methods` - Document what you did
2. `write-results` - Describe what you found  
3. `scientific-writing` - Polish and format

**REVIEW Phase Priorities:**
1. `peer-review` - Self-assessment
2. `review-script` - Code quality check
3. Final `scientific-writing` pass

### 5. Generate Recommendations

Present 2-4 options ranked by value:

```markdown
## 🎯 Recommended Next Steps

Based on your project state (Phase: ANALYSIS, Last active: 2 days ago):

### A) [High Priority] Explore your new dataset
   I noticed `data/raw/experiment_results.csv` was added recently.
   → Run `/exploratory_data_analysis data/raw/experiment_results.csv`
   
   This will help you:
   - Understand data structure and quality
   - Identify any issues before formal analysis
   - Generate summary statistics

### B) [Medium Priority] Document your preprocessing script
   `scripts/preprocess.py` lacks docstrings.
   → Run `/review_script scripts/preprocess.py`
   
   Good documentation now saves time during methods writing.

### C) [Routine] Weekly review
   Last weekly review was 8 days ago.
   → Run `/weekly_review`

### D) [Continue] Resume from last session
   You were working on: "correlation analysis for Figure 2"
   → Continue where you left off

---

**Quick actions:** `/note` | `/task` | `/wrap_up`

What would you like to focus on?
```

**Priority indicators:**
- 🔴 **Critical** - Blocking progress
- 🟡 **High priority** - Should do soon
- 🔵 **Recommended** - Good practice
- ⚪ **Optional** - Nice to have

---

## Skill Quick Reference

For user awareness, here's the full toolkit organized by purpose:

### 📊 Data & Analysis
| Skill | Command | Use When |
|-------|---------|----------|
| Exploratory Data Analysis | `/exploratory_data_analysis [file]` | First look at any dataset |
| Statistical Analysis | `/statistical_analysis` | Formal hypothesis testing |
| Scientific Visualization | `/scientific_visualization` | Publication-quality figures |

### 📚 Literature & Research
| Skill | Command | Use When |
|-------|---------|----------|
| Literature Review | `/literature_review [topic]` | Systematic literature search |
| Deep Research | `/deep_research [topic]` | Quick literature lookup |
| Hypothesis Generation | `/hypothesis_generation` | Formulating research questions |

### ✍️ Writing & Documentation
| Skill | Command | Use When |
|-------|---------|----------|
| Write Background | `/write_background` | Draft introduction/background |
| Write Methods | `/write_methods` | Document methodology |
| Write Results | `/write_results` | Describe findings |
| Scientific Writing | `/scientific_writing` | Polish any section |

### 🔍 Review & Quality
| Skill | Command | Use When |
|-------|---------|----------|
| Peer Review | `/peer_review` | Self-assess before submission |
| Review Script | `/review_script [path]` | Code quality check |

### 📅 Planning & Tracking
| Skill | Command | Use When |
|-------|---------|----------|
| Plan Week | `/plan_week` | Monday planning session |
| Weekly Review | `/weekly_review` | End of week reflection |
| Monthly Review | `/monthly_review` | Monthly alignment check |
| Quarterly Review | `/quarterly_review` | Research mission review |
| Wrap Up | `/wrap_up` | End of work session |

### ⚡ Quick Capture
| Skill | Command | Use When |
|-------|---------|----------|
| Note | `/note [text]` | Quick thought capture |
| Task | `/task [text]` | Add a todo item |
| Transcribe | `/transcribe [file]` | Convert audio to text |
| Summarize Meeting | `/summarize_meeting [file]` | Extract action items |

---

## Example Outputs by Phase

### PLANNING Phase /next
```
You're in the PLANNING phase. Key priorities:

A) 🟡 Generate your hypothesis
   Your project_telos.md has aims but no formal hypothesis.
   → Run `/hypothesis_generation`
   
B) 🟡 Literature review on [detected topic]
   Background.md is empty. Let's build your foundation.
   → Run `/literature_review [topic]`

C) ⚪ Quick win - capture your current thinking
   → Run `/note` to log where your head is at
```

### ANALYSIS Phase /next
```
You're in the ANALYSIS phase with new data. Priorities:

A) 🔴 Explore experiment_results.csv
   New data file detected - understand it before analyzing.
   → Run `/exploratory_data_analysis data/raw/experiment_results.csv`

B) 🟡 After EDA: Statistical analysis
   Once you understand the data, run formal tests.
   → Run `/statistical_analysis`

C) 🔵 Parallel: Document your analysis scripts
   preprocess.py and analyze.py need docstrings.
   → Run `/review_script scripts/preprocess.py`
```

### WRITING Phase /next  
```
You're in the WRITING phase. Current status:
- ✅ Background: Draft complete
- ⚠️ Methods: Partially written
- ❌ Results: Empty (but you have 3 figures!)

A) 🔴 Write your results section
   You have figures ready but no results text.
   → Run `/write_results`

B) 🟡 Complete methods documentation
   → Run `/write_methods`

C) 🔵 Scientific writing review
   → Run `/scientific_writing` on completed sections
```

---

## Response Format

Always structure /next responses as:

1. **Context summary** (1-2 lines: phase, last activity, any alerts)
2. **Prioritized options** (A/B/C/D format with clear commands)
3. **Quick actions footer** (remind of /note, /task, /wrap_up)
4. **Invitation to choose or explain their own priority**

---

## Notes

- Always be encouraging, never judgmental
- If user seems stuck, offer to break down the next step
- Remember: user may not know what commands exist - suggest them explicitly
- Update activity.md after significant interactions
