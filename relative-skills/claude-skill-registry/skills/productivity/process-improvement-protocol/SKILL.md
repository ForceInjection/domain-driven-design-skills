---
name: process-improvement-protocol
description: Use when user types /improve or frustration patterns detected - systematic intervention for reducing user frustration and improving workflow effectiveness through root cause analysis, evidence-based fixes, and effectiveness tracking
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, Task, TodoWrite]
---

# Process Improvement Protocol

## Overview

Systematic intervention system that detects frustration, analyzes root causes, implements fixes, and tracks effectiveness over time.

**Core principle:** Data-driven behavioral change. Success = days between frustration incidents increasing over time.

**Announce at start:** "🛟 Process Improvement Protocol initiated! Saving my context for later."

## Phase 0: Plugin Path Discovery (ALWAYS RUN FIRST)

**CRITICAL**: Before any file operations, discover where this plugin is installed.

The plugin must work regardless of installation method:
- Local testing: `/path/to/process-improvement/`
- Marketplace install: `~/.claude/plugins/marketplaces/process-improvement/`
- Legacy location: `~/.claude/process-improvement/` (deprecated)

**Path Discovery Strategy**:

```bash
# Determine plugin root directory
# Priority: CLAUDE_PLUGIN_ROOT env var > marketplace location > current directory
if [ -n "$CLAUDE_PLUGIN_ROOT" ]; then
  PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
elif [ -d ~/.claude/plugins/marketplaces/process-improvement ]; then
  PLUGIN_ROOT=~/.claude/plugins/marketplaces/process-improvement
elif [ -d ~/.claude/process-improvement ]; then
  # Legacy fallback
  PLUGIN_ROOT=~/.claude/process-improvement
else
  # Assume local development
  PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

# Export data directory for all file operations
export PLUGIN_DATA="$PLUGIN_ROOT/data"

# Verify data directory exists, create if missing
mkdir -p "$PLUGIN_DATA"/{sessions,deferred-incidents,fixes-registry}

# Verify required files exist, create if missing
touch "$PLUGIN_DATA/incidents.jsonl"
[ -f "$PLUGIN_DATA/days-without-incident.json" ] || echo '{"last_incident":null,"days_since_last":0,"longest_streak":0}' > "$PLUGIN_DATA/days-without-incident.json"
```

**Usage**: All file operations in this skill use `${PLUGIN_DATA}/filename` instead of absolute paths.

## Trigger Conditions

### Primary Trigger
User types `/improve [timeframe]` command

**Time frame parameter** (optional):
- `week` - Analyze last 7 days
- `month` - Analyze last 30 days (default)
- `year` - Analyze last 365 days
- `all` - Analyze entire history

If no time frame specified, default to `month`.

**Parse time frame:**
```bash
# Extract from command arguments
timeframe="${1:-month}"  # Default to month if not specified

case "$timeframe" in
  week)  days=7 ;;
  month) days=30 ;;
  year)  days=365 ;;
  all)   days=99999 ;;  # Effectively all time
  *)     days=30 ;;     # Default to month for invalid input
esac
```

### Auto-Detection (Frustration Phrase Library)

Check user message for ANY of these phrases:
- "Stop"
- "I keep asking"
- "Did you actually"
- "You didn't test"
- "You didn't..."
- "I didn't ask for..."
- "How many times"
- "Again?"
- "Still not working"

**If detected**, offer choice:
```
🛟 I detected a potential frustration pattern. Would you like to:
1. Run Process Improvement Protocol now
2. Defer this and continue working (I'll save the context)
```

If user chooses option 2 (defer):
- Save context to `${PLUGIN_DATA}/deferred-incidents/YYYY-MM-DD-HHMMSS.json`
- Include: timestamp, trigger phrase, last user message, current todos, files being edited
- Continue with original work
- Skill will check for deferred incidents on next /improve run

## Phase 1: Context Preservation

### 1. Acknowledge

Display which time frame is being analyzed:

```
🛟 Process Improvement Protocol initiated! Saving my context for later.

Analyzing: Last [7 days|30 days|365 days|all time] of conversations
```

Replace bracketed text with actual time frame based on parameter.

### 2. Save Resume State

Create `${PLUGIN_DATA}/sessions/YYYY-MM-DD-HHMMSS-resume.json`:

```json
{
  "timestamp": "2025-11-21T17:45:00Z",
  "current_todos": [...],  // from TodoWrite
  "last_user_message": "...",
  "working_on": "...",  // brief summary
  "files_being_edited": [...]
}
```

### 3. Display Streak

Read `${PLUGIN_DATA}/days-without-incident.json` and calculate days since last incident:

```
Days since last frustration incident: X

[If X < 7]: Definitely still learning here. Let's get to it!
[If X >= 7]: Oof! We had a good streak going. Let's get back on track!
```

## Phase 2: Quick Context Analysis

### 1. Analyze Current Conversation

Check for obvious patterns:
- Testing skipped? (claims of "complete" or "working" without evidence)
- Review skipped? (spec/plan written without review agent)
- Rationalization detected? ("should work", "logic is correct")
- Hallucination? (claiming features exist that don't)
- Repeated request? (user asked for same thing 2+ times)

### 2. Check Deferred Incidents

Read `${PLUGIN_DATA}/deferred-incidents/*.json`

If any found:
```
Current issue: [describe current frustration]

I also found X deferred incidents from earlier sessions that may be related:
- [incident 1 summary]
- [incident 2 summary]

Analyzing all together.
```

### 3. Load Historical Context

Read files within the specified time frame:
- `${PLUGIN_DATA}/incidents.jsonl` (filter by timestamp and `days` parameter)
- `${PLUGIN_DATA}/successful-fixes.md` (what worked before)
- `${PLUGIN_DATA}/patterns-detected.md` (known failure modes)
- `${PLUGIN_DATA}/fixes-registry/*.md` (filter by file modification date using `days` parameter)

**Filter incidents.jsonl by time frame:**
```bash
# Only load incidents within the specified time frame
jq -c --arg cutoff_days "$days" \
  'select((now - (.timestamp | fromdate)) / 86400 <= ($cutoff_days | tonumber))' \
  "${PLUGIN_DATA}/incidents.jsonl"
```

Check for similar past incidents (within time frame) and their solutions.

## Phase 3: Deep Investigation

### Skill-Based Analysis

Using available context, perform analysis:

1. **Pattern matching**: Does this match a known failure mode from patterns-detected.md?
2. **Historical check**: Has this happened before? What fixed it then? Did that fix last?
3. **Regression check**: Were fixes previously applied but now broken/removed?
4. **Root cause**: Why did this actually happen? (Be specific, not generic)

### Generate Solution Options

Create 2-3 solution options with:
- **What**: Specific implementation (file edits, config changes, skill creation)
- **Why it should work**: Evidence-based reasoning (similar past fixes, proven patterns)
- **Drawbacks**: Honest assessment
- **Expected effectiveness**: Based on historical data if available

### Recommend Best Option

Select the most likely to solve this based on evidence, with reasoning.

### Optional: Spawn Agent for Complex Cases

If analysis requires:
- Deep investigation across many historical conversations
- Research (WebSearch for solutions)
- Comparing multiple historical patterns

Spawn general-purpose agent with full context package.

## Phase 4: Present & Implement

### 1. Present Findings

```
## Root Cause Analysis
[What happened + why + is this a pattern?]

## Historical Context
[Has this happened before? What fixed it then? Did that fix last?]

## Solution Options

### Option A: [Name]
**What**: [Specific implementation]
**Why it should work**: [Evidence-based reasoning]
**Drawbacks**: [Honest assessment]
**Expected effectiveness**: [Based on historical data]

### Option B: [Name]
...

## Recommendation
**Recommended**: Option [X]
**Reasoning**: [Why this one, with evidence]
**Success criteria**: [How we'll know if it worked]
```

### 2. User Selects or Approves

User chooses option (or approves recommendation).

### 3. Implement Fix Immediately

Apply the selected fix:
- Update configuration files (e.g., `actually_works_plus_superpowers.md`)
- Create new skill if needed (in `~/.claude/skills/user/`)
- Add enforcement hook if needed (in `~/.claude/hooks/`)
- Create entry in `${PLUGIN_DATA}/fixes-registry/YYYY-MM-DD-fix-name.md` with:
  - Date implemented
  - Problem it solves
  - What was changed (file paths)
  - Expected impact
  - How to verify it's working

### 4. Log to incidents.jsonl

Append new line to `${PLUGIN_DATA}/incidents.jsonl`:

```json
{"timestamp":"2025-11-21T17:45:00Z","days_since_last":7,"severity":"major_win","pattern":"Testing skipped","root_cause":"Agent claimed 'production-ready' without testing","solution_implemented":"Added BLOCKER section to actually_works.md requiring TodoWrite + verification skill","fix_file":"fixes-registry/2025-11-21-testing-protocol-blocker.md","expected_impact":"Zero untested 'complete' claims","effectiveness_1week":null,"effectiveness_2week":null,"status":"active"}
```

### 5. Update days-without-incident.json

```json
{
  "last_incident": "2025-11-21T17:45:00Z",
  "days_since_last": 0,
  "longest_streak": 14
}
```

### 6. User Acceptance

```
I hope this will improve our process and this frustration will hopefully not recur again.
We'll track our performance over time and revisit if needed.

Ready to get back to our earlier task?
1. Yes
2. Keep discussing improvements
```

If option 1: Continue to Phase 5 (Resume)
If option 2: Continue improvement conversation

## Phase 5: Resume Work

Display saved context from `${PLUGIN_DATA}/sessions/YYYY-MM-DD-HHMMSS-resume.json`:

```
We're done with Process Improvement Protocol. Here's where we were:

**What you were working on**: [working_on from resume.json]
**Active TODOs**:
  - [list from current_todos]
**Files being edited**:
  - [list from files_being_edited]
**Last thing you said**:
  [last_user_message]

Please let me know how you'd like to proceed - continue with the above, or start something new?
```

User manually decides next action.

## Effectiveness Tracking (Weekly /improve Run)

When `/improve` runs (weekly or user-initiated), check for pending effectiveness measurements:

### 1. Load Pending Checks

```bash
# Find incidents needing 1-week check
jq -c 'select(.effectiveness_1week == null and
  (now - (.timestamp | fromdate)) >= 604800)' "${PLUGIN_DATA}/incidents.jsonl"

# Find incidents needing 2-week check
jq -c 'select(.effectiveness_2week == null and
  (now - (.timestamp | fromdate)) >= 1209600)' "${PLUGIN_DATA}/incidents.jsonl"
```

### 2. Count Pattern Occurrences

For each pending check, grep conversations within time frame:

```bash
# Example: Count "review agent" mentions within time frame
pattern_keywords="review agent|Plan agent|code-reviewer"
project_dir=$(echo ~/.claude/projects/-Users-gserafini-git-src-* | head -1)

# Use the parsed $days variable from trigger time frame
occurrences=$(find "$project_dir" -name "*.jsonl" -type f -mtime -${days} \
  -exec grep -l "$pattern_keywords" {} \; | wc -l)
```

### 3. Calculate Success Rate

```
success_rate = 1 - (occurrences_after / occurrences_before)

status = success_rate >= 0.8 ? 'highly_effective' :
         success_rate >= 0.5 ? 'moderately_effective' :
         success_rate >= 0.2 ? 'minimally_effective' : 'ineffective'
```

### 4. Update incidents.jsonl

Update the incident entry with effectiveness data.

### 5. Report to User

```
📊 Effectiveness Check Results:

Fix: [fix name] (1 week ago)
- Before: X occurrences/week
- After: Y occurrences/week
- Success rate: Z%
- Status: [Highly effective ✅ / Needs refinement ⚠️]
- Recommendation: [Keep as-is / Refine / Replace]
```

## Common Mistakes

**Skipping context preservation**
- **Problem**: Lose work in progress when investigating frustration
- **Fix**: Always save resume.json FIRST before analyzing

**Generic root cause**
- **Problem**: "Agent made a mistake" doesn't help prevent recurrence
- **Fix**: Be specific - what EXACTLY went wrong? Why?

**No historical check**
- **Problem**: Repeat the same failed fixes
- **Fix**: Always check if this happened before and what was tried

**Implementing without user approval**
- **Problem**: User loses control, may disagree with approach
- **Fix**: Present options, get explicit approval before implementing

**No effectiveness tracking**
- **Problem**: Fixes live forever even if they don't work
- **Fix**: Always log to incidents.jsonl with null effectiveness fields for later measurement

## Red Flags

**Never:**
- Implement fixes without user approval
- Skip logging to incidents.jsonl
- Proceed without saving resume context
- Give generic "I'll do better" responses without specific fixes
- Skip effectiveness measurement for past fixes

**Always:**
- Save context FIRST (sessions/resume.json)
- Check for deferred incidents
- Present specific, evidence-based options
- Implement fixes immediately when approved
- Log everything to incidents.jsonl
- Track effectiveness over time

## Integration

**Invoked by:**
- User typing `/improve` command
- Frustration keyword auto-detection

**May invoke:**
- General-purpose Task agent for complex investigation (optional)

**Updates:**
- ${PLUGIN_DATA}/incidents.jsonl (append only)
- ${PLUGIN_DATA}/days-without-incident.json (overwrite)
- ${PLUGIN_DATA}/sessions/*.json (create new)
- ${PLUGIN_DATA}/deferred-incidents/*.json (create when deferred)
- ${PLUGIN_DATA}/fixes-registry/*.md (create per fix)
- ${PLUGIN_DATA}/successful-fixes.md (manual curation based on effectiveness)
- ${PLUGIN_DATA}/patterns-detected.md (manual curation of common issues)
