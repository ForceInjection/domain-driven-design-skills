---
name: module-improve
description: Version management, bug fixes, feature additions for VCV Rack modules
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Task # For deep-research (Tier 3) and module-testing (regression tests)
preconditions:
  - Module status must be ✅ Working OR 📦 Installed
  - Module must NOT be 🚧 In Development
---

# module-improve Skill

**Purpose:** Make changes to completed VCV Rack modules with versioning, backups, changelog automation, and root cause investigation.

**Integration with deep-research:**

This skill can receive pre-computed research findings from the deep-research skill. When user runs `/research` to investigate a problem and then chooses "Apply solution", deep-research outputs a directive that the main conversation (orchestrator) recognizes and acts on by invoking this skill. Phase 0.45 detects the research findings in conversation history and skips investigation, proceeding directly to implementation approval.

**Workflow:**
1. User: `/research [problem]` → deep-research investigates
2. deep-research: Presents findings with "Apply solution" option
3. User: Selects "Apply solution"
4. deep-research: Outputs directive: "Next step: Invoke module-improve skill."
5. Main conversation (orchestrator): Sees directive, uses Skill tool to invoke module-improve
6. module-improve: Detects research in history (Phase 0.45), extracts findings, skips investigation
7. module-improve: Implements with versioning, backups, testing

**Note:** This is the standard handoff protocol. When the orchestrator sees "Invoke module-improve skill" in deep-research output, it will automatically invoke this skill. The routing is explicit and always executed.

## Precondition Checking

**Before starting, verify:**

1. Read MODULES.md:

```bash
grep "^### $MODULE_NAME$" MODULES.md
```

2. Check status:
   - If status = ✅ Working or 📦 Installed → OK to proceed
   - If status = 🚧 In Development → BLOCK with message:
     ```
     [ModuleName] is still in development (Stage [N]).
     Complete the workflow first with /continue [ModuleName].
     Cannot use /improve on in-progress modules.
     ```
   - If status = 💡 Ideated → BLOCK with message:
     ```
     [ModuleName] is not implemented yet (Status: 💡 Ideated).
     Use /implement [ModuleName] to build it first.
     ```
   - If not found → BLOCK with message:
     ```
     Module [ModuleName] not found in MODULES.md.
     ```

## Phase 0: Specificity Detection

**Check if request is specific:**

Request IS specific if it has:

- Feature name (e.g., "polyphonic CV input", "frequency knob", "clipping indicator")
- Action (e.g., "add", "remove", "fix", "change from X to Y")
- Acceptance criteria (e.g., "range -10V to +10V", "16 channels", "respond to 1V/oct")

Request IS vague if lacking above:

- "improve the filter"
- "better modulation"
- "UI feels cramped"
- "make it sound warmer"

**Assess specificity:**

- **Specific enough (1-2 clarification questions max):** Proceed to Phase 0.3 (4-question clarification batch)
- **Vague:** Present choice using AskUserQuestion:

```
Question:
  question: "Your request needs more detail. How should I proceed?"
  header: "Approach"
  options:
    - label: "Brainstorm approaches together", description: "I'll ask questions to explore options"
    - label: "Implement something reasonable", description: "I'll investigate and propose a solution"

Handle responses:
- Option 1 → Invoke module-ideation skill in improvement mode, then return here when ready
- Option 2 → Proceed to Phase 0.45 (Research Detection)
```

## Phase 0.3: Clarification Questions (For Specific Requests)

**If request is specific enough, ask 4 clarification questions using AskUserQuestion:**

**Question Priority Tiers:**

- **Tier 1 (Critical):** Current behavior, proposed solution, breaking changes
- **Tier 2 (Implementation):** Testing approach, backward compatibility, version impact
- **Tier 3 (Context):** Rationale, success metrics, alternative approaches

**Generate exactly 4 questions based on what's missing:**

```
Question 1:
  question: "Current behavior that needs changing?"
  header: "Problem"
  options:
    - label: "Describe the issue", description: "Explain what's wrong or limited"
    - label: "Show example", description: "Provide specific example"
    - label: "Already described", description: "Skip this question"
    - label: "Other", description: "Different approach"

Question 2:
  question: "Proposed solution?"
  header: "Fix"
  options:
    - label: "Add new feature", description: "Extend functionality"
    - label: "Modify existing", description: "Change current behavior"
    - label: "Remove/replace", description: "Take something out"
    - label: "Other", description: "Different solution"

Question 3:
  question: "Testing approach?"
  header: "Verification"
  options:
    - label: "Load test patch", description: "Use existing patch"
    - label: "A/B compare", description: "Before/after comparison"
    - label: "Measure performance", description: "CPU/timing metrics"
    - label: "Other", description: "Different testing method"

Question 4:
  question: "Breaking changes acceptable?"
  header: "Compatibility"
  options:
    - label: "Yes", description: "Can break existing patches"
    - label: "Must maintain compatibility", description: "No breaking changes"
    - label: "Only if worth it", description: "Evaluate trade-offs"
    - label: "Other", description: "Different constraint"
```

**After receiving answers:**

1. Merge with initial request
2. Proceed to decision gate

## Phase 0.4: Decision Gate (For Specific Requests)

**Use AskUserQuestion with 3 options after clarification questions:**

```
Question:
  question: "Ready to implement this improvement?"
  header: "Next step"
  options:
    - label: "Yes, implement it", description: "Proceed with implementation"
    - label: "Ask me 4 more questions", description: "Need more clarification"
    - label: "Let me add more context first", description: "Provide additional details"

Route based on answer:
- Option 1 → Proceed to Phase 0.45 (Research Detection)
- Option 2 → Return to Phase 0.3 (re-analyze gaps, generate next 4 questions)
- Option 3 → Collect free-form text, merge with context, return to Phase 0.3
```

## Phase 0.45: Research Detection

**BEFORE starting investigation, check conversation history for deep-research findings:**

**Scan recent messages for:**

- Routing directive: "Invoke module-improve skill" (signals deep-research handoff)
- Messages from deep-research skill
- Research reports (Level 1/2/3)
- Problem analysis and root cause
- Recommended solutions
- Implementation roadmap

**If deep-research findings found:**

```markdown
✓ Research already completed (deep-research Level N)

**Problem:** [Extracted from research]
**Root Cause:** [Extracted from research]
**Recommended Solution:** [Extracted from research]
**Implementation Steps:** [Extracted from research]

Skipping Phase 0.5 investigation (research already done).

Ready to implement? (y/n): _
```

Wait for user approval, then proceed to Phase 0.9 (Backup Verification).

**If NO research findings found:**

Proceed to Phase 0.5 (Investigation) - perform fresh root cause analysis.

**Why this matters:**

- Avoids duplicate investigation (user already ran /research)
- Preserves expensive research context (Opus + extended thinking)
- Maintains separation: research finds solutions, improve implements them
- Clear handoff: research outputs directive → orchestrator invokes improve (always executed)

## Phase 0.5: Investigation (3-Tier)

**Purpose:** Find root causes, prevent band-aid fixes

**Tier Selection:**

- **Tier 1 (5-10 min):** Cosmetic changes, simple fixes, obvious issues
- **Tier 2 (15-30 min):** Logic errors, parameter issues, integration bugs
- **Tier 3 (30-60 min):** Complex bugs, performance issues, architectural problems

**Tier 1: Basic Code Inspection**

Read relevant source files:

- src/[ModuleName].cpp
- src/[ModuleName].hpp
- plugin.json
- Relevant VCV Rack API usage

Check for:

- Obvious typos or errors
- Known pattern matches
- Simple logic issues

**Tier 2: Root Cause Analysis**

Deeper investigation:

- Trace logic flow from symptom to cause
- Check integration points between components
- Review parameter definitions and voltage ranges
- Examine state management and polyphony handling
- Check threading issues (process vs UI thread)

**Tier 3: Deep Research**

Invoke `deep-research` skill for complex issues:

```
Complex issue detected. Invoking deep-research skill...
```

Use Skill tool to invoke deep-research:
- Provide problem context, module name, stage
- deep-research performs graduated investigation (Levels 1-3)
- Returns structured findings with recommendations
- Continue with Phase 0.5 "Present findings" using research output

**Present findings:**

```markdown
## Investigation Findings

### Problem Analysis

[What's actually wrong and why it's happening]

### Root Cause

[Technical explanation of the underlying issue]

### Affected Files

- modules/[Name]/src/[File]:[Line]
- modules/[Name]/src/[File]:[Line]

### Recommended Approach

[How to fix it properly - not a workaround]

### Alternative Approaches

[Other valid options with trade-offs explained]

### Backward Compatibility

[Will this break existing patches?]

Proceed with recommended approach? (y/n): \_
```

**Wait for approval before implementing.**

If user says no, ask which alternative or if they want different approach.

## Phase 0.9: Backup Verification

**Goal:** Ensure rollback is possible if improvement fails

**Check if backup exists:**

```bash
BACKUP_PATH="backups/${MODULE_NAME}/v${CURRENT_VERSION}/"
if [[ ! -d "$BACKUP_PATH" ]]; then
  echo "⚠️ No backup found for v${CURRENT_VERSION}"
  CREATE_BACKUP=true
fi
```

**Create backup if missing:**

```bash
mkdir -p "backups/${MODULE_NAME}/v${CURRENT_VERSION}/"
cp -r "modules/${MODULE_NAME}/" "backups/${MODULE_NAME}/v${CURRENT_VERSION}/"
echo "✓ Backup created: backups/${MODULE_NAME}/v${CURRENT_VERSION}/"
```

**Verify backup integrity:**

```bash
# Check source files present
test -f "backups/${MODULE_NAME}/v${CURRENT_VERSION}/src/${MODULE_NAME}.cpp"
test -f "backups/${MODULE_NAME}/v${CURRENT_VERSION}/plugin.json"
test -f "backups/${MODULE_NAME}/v${CURRENT_VERSION}/Makefile"

# Verify Makefile is valid
grep -q "RACK_DIR" "backups/${MODULE_NAME}/v${CURRENT_VERSION}/Makefile"

# Dry-run build (optional, faster verification)
cd "backups/${MODULE_NAME}/v${CURRENT_VERSION}/"
make -n
```

**Present verification results:**

```
✓ Backup verified: backups/[ModuleName]/v[CurrentVersion]/

- All source files present
- plugin.json valid
- Makefile present and valid
- Dry-run build successful

Rollback available if needed.
```

## Phase 1: Pre-Implementation Checks

**Load current state:**

1. Read CHANGELOG.md:

```bash
cat modules/[ModuleName]/CHANGELOG.md
```

Extract current version (e.g., v1.2.3).

2. Read MODULES.md entry for additional context.

3. Check recent commits:

```bash
git log --oneline modules/[ModuleName]/ -10
```

**Determine version bump:**

Present choice:

```
Current version: v[X.Y.Z]

What type of change is this?
1. PATCH (v[X.Y.Z] → v[X.Y.Z+1]) - Bug fixes, cosmetic changes
2. MINOR (v[X.Y] → v[X.Y+1]) - New features, enhancements
3. MAJOR (v[X] → v[X+1]) - Breaking changes (patches won't load, inputs/outputs changed)

Choose (1-3): _
```

**If Major version selected, warn:**

```
⚠️ Major version bump will break compatibility.

Breaking changes include:
- Changed input/output configuration (patches won't load)
- Removed parameters (patches will have missing connections)
- Changed CV voltage ranges (existing patches behave differently)
- Changed parameter IDs in plugin.json

Are you sure? This should be rare. (y/n): _
```

Calculate new version based on selection.

## Phase 2: Backup Creation

**Before ANY code changes:**

```bash
mkdir -p backups/
cp -r modules/[ModuleName] backups/[ModuleName]-v[X.Y.Z]-$(date +%Y%m%d-%H%M%S)
```

Confirm backup created:

```
✓ Backup created: backups/[ModuleName]-v[X.Y.Z]-[timestamp]

This backup can be restored if anything goes wrong.
```

## Phase 3: Implementation

**Make the approved changes:**

1. Modify source files according to investigation findings
2. Update build configuration if needed (Makefile)
3. Adjust UI if required (widget changes in src/[ModuleName].cpp)
4. Update parameter definitions if needed (plugin.json)
5. Update SVG panel if visual changes required (res/[ModuleName].svg)

**Follow VCV Rack best practices:**

- Real-time safety in process() method
- No allocations in audio thread
- Thread-safe parameter access
- Proper polyphony handling
- CV voltage standards (-10V to +10V, 1V/oct for pitch)
- Proper input/output port configuration

**Log changes as you go for CHANGELOG.**

## Phase 4: Enhanced CHANGELOG Update

**Update CHANGELOG.md with enhanced format:**

Add new version entry at top with technical details:

```markdown
# Changelog

All notable changes to [ModuleName] will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [X.Y.Z] - [YYYY-MM-DD]

### Added

- [New feature 1]
  - [Detailed description]
  - [User benefit]

### Changed

- [Modified behavior 1]

### Fixed

- [Bug fix 1]
  - Root cause: [Technical explanation]
  - Impact: [What was affected]

### Technical

- Parameter changes:
  - Added: [PARAM_ID] (ID: "paramId", range: [min,max], default: value)
  - Modified: [PARAM_ID] (changed range from X to Y)
  - Removed: [PARAM_ID] (deprecated, use [NEW_PARAM] instead)
- Input/Output changes:
  - Added: [INPUT_ID] (poly/mono, voltage range)
  - Modified: [OUTPUT_ID] (changed voltage range)
  - Removed: [PORT_ID] (deprecated)
- DSP changes:
  - [Description of process() modifications]
  - [Algorithm improvements]
  - [Sample rate handling changes]
- UI changes:
  - [Widget additions/modifications]
  - [Panel layout changes]
  - [SVG panel updates]
- Dependencies:
  - [New Rack API features used]
  - [External library updates]

### Testing

- Regression tests: [✅ X/Y passing | ⚠️ See notes below]
- Baseline version: v[X.Y.Z]
- Test coverage:
  - Polyphony: [Tested configurations]
  - Sample rates: [44.1k, 48k, 96k, 192k results]
  - CV modulation: [Inputs tested]

### Migration Notes (MAJOR versions only)

- v[X-1].x patches compatible: [Yes/No + explanation]
- Breaking changes:
  - [List input/output configuration changes]
  - [List removed parameters]
  - [List voltage range changes]
- Workarounds:
  - [How to adapt existing patches]
  - [Parameter mapping if IDs changed]

## [Previous Version] - [Date]

[Previous entries remain...]
```

**Sections to use:**

- **Added:** New features (with detailed descriptions)
- **Changed:** Changes to existing functionality
- **Fixed:** Bug fixes (with root cause explanations)
- **Removed:** Removed features
- **Technical:** Implementation details (parameters, ports, DSP, UI, dependencies)
- **Testing:** Regression test results and coverage (polyphony, sample rates, CV)
- **Migration Notes:** Breaking changes and workarounds (MAJOR versions only)

**Change type auto-detection:**

- PATCH (v1.0.0 → v1.0.1): Use "Fixed" section primarily
- MINOR (v1.0.0 → v1.1.0): Use "Added" or "Changed" sections
- MAJOR (v1.0.0 → v2.0.0): Include "Migration Notes" section

**Enhanced changelog example:**

```markdown
## [1.1.0] - 2025-11-10

### Added

- Polyphonic CV input (CV_POLY)
  - Supports up to 16 channels
  - Automatically adapts to connected cable channels
  - 1V/oct pitch standard

### Changed

- Improved resonance algorithm for self-oscillation stability

### Technical

- Added input: CV_POLY (ID: "cv_poly", polyphonic, -10V to +10V)
- Modified process() to handle polyphonic channels
- Added per-voice state management
- Updated res/ModuleName.svg panel with new CV input jack

### Testing

- Regression tests: ✅ 5/5 passing (baseline: v1.0.0)
- Polyphony: Tested 1, 4, 8, 16 channels
- Sample rates: 44.1k, 48k, 96k, 192k all passing
- Added test: Polyphonic CV response accuracy

### Migration Notes

- v1.0 patches fully compatible (CV_POLY is new input, doesn't affect existing connections)
- No breaking changes
```

## Phase 5: Build & Test

**1. Build module:**

Invoke `build-automation` skill (full build with installation):

```
Invoking build-automation skill to build and install updated module...
```

build-automation will:

- Run build script: `scripts/build-and-install.sh [ModuleName]` (Makefile-based build)
- Build module for current platform
- Install to ~/Documents/Rack2/plugins-[platform]-[arch]/
- Verify installation

If build succeeds:

- build-automation displays success message with installation paths
- Returns control to module-improve
- Proceed to Phase 5, step 2 (Run tests)

If build fails:

- build-automation presents 4-option failure protocol:
  1. Investigate (troubleshooter agent)
  2. Show build log
  3. Show code
  4. Wait for manual fix
- After resolution and successful retry, returns to module-improve
- Proceed to Phase 5, step 2 (Run tests)

**Note:** Build failure handling is entirely managed by build-automation skill. module-improve does not need custom build error menus.

**2. Run tests:**

Invoke `module-testing` skill:

Present test method choice:

```
Build successful. How would you like to test?

1. Manual testing protocol (polyphony, CV, sample rates)
2. Build verification only (skip testing)
3. Other testing approach

Choose (1-3): _
```

If tests fail, present investigation options.

## Phase 5.5: Regression Testing

**Check:** Does `.claude/skills/module-testing/SKILL.md` exist?

**If NO:** Skip to Phase 6 (add warning to changelog: "Manual regression testing required")

**If YES:** Run regression tests

### Regression Test Process

**1. Determine baseline version:**

- If improving v1.0.0 → v1.1.0, baseline is v1.0.0
- Check if backup exists: `backups/[Module]/v[baseline]/`
- If no backup: Skip regression tests (warn user)

**2. Build baseline version:**

```bash
# Temporarily checkout baseline
cd backups/[Module]/v[baseline]/
make clean
make
```

**3. Run tests on baseline:**

- Invoke module-testing skill on baseline build
- Capture results: BASELINE_RESULTS (polyphony, sample rates, CV response)

**4. Run tests on current version:**

- Invoke module-testing skill on new build
- Capture results: CURRENT_RESULTS

**5. Compare results:**

```typescript
interface RegressionReport {
  baseline_version: string;
  current_version: string;
  tests_run: number;
  baseline_passing: number;
  current_passing: number;
  new_failures: TestCase[]; // Regressions!
  new_passes: TestCase[]; // Fixed bugs
  unchanged: number;
}
```

**6. Present findings:**

#### If No Regressions:

```
✓ Regression tests passed (5/5 tests, no new failures)

What's next?
1. Continue to git workflow (recommended)
2. Review test details
3. Other
```

#### If Regressions Detected:

```
⚠️ Regression detected - new failures found

**Baseline (v1.0.0):** 5/5 tests passing
**Current (v1.1.0):** 3/5 tests passing

**New failures:**
1. Polyphony Test - Module crashes with 16 channels
2. CPU Performance Test - Sample time increased from 0.05ms to 0.15ms

**Recommendation:** Fix regressions before proceeding

What's next?
1. Investigate failures - Debug issues (recommended)
2. View test output - See detailed logs
3. Continue anyway - Accept regressions (not recommended)
4. Rollback changes - Revert to v1.0.0
5. Other
```

### Rollback Mechanism

If user chooses "Rollback changes":

1. Verify backup exists: `backups/[Module]/v[baseline]/`
2. Copy all files from backup to `modules/[Module]/`
3. Rebuild and reinstall
4. Update MODULES.md status
5. Git reset if commits were made
6. Confirm rollback success

```bash
# Rollback script
rm -rf modules/[Module]
cp -r backups/[Module]/v[baseline]/ modules/[Module]/
cd modules/[Module]
make clean
make
make install
```

## Phase 6: Git Workflow

**Stage changes:**

```bash
git add modules/[ModuleName]/
git add backups/[ModuleName]-v[X.Y.Z]-[timestamp]/  # Include backup in git
```

**Commit with conventional format:**

```bash
# Format: improve: [ModuleName] v[X.Y.Z] - [brief description]
# Example: improve: MicroDelay v1.3.0 - add polyphonic CV input

git commit -m "$(cat <<'EOF'
improve: [ModuleName] v[X.Y.Z] - [description]

[Detailed explanation of changes aimed at intentions]
[Root cause of bug if applicable]
[Implementation approach]
[Testing performed]

EOF
)"
```

**Tag release:**

```bash
git tag -a "v[X.Y.Z]" -m "[ModuleName] v[X.Y.Z]"
```

Note: User handles actual git operations, we stage only.

**Confirm git ready:**

```
✓ Changes staged for commit
✓ Tag ready: v[X.Y.Z]

Git commit message:
  improve: [ModuleName] v[X.Y.Z] - [description]

You can commit these changes when ready.
```

## Phase 7: Installation

**Present decision:**

```
Build and tests successful. Install to system folders?

1. Yes, install now (recommended for 📦 Installed modules)
2. No, test from build folder first
3. Skip installation

Choose (1-3): _
```

**If user chooses 1:**

Invoke `module-lifecycle` skill:

```
Installing [ModuleName] v[X.Y.Z]...
```

**Update MODULES.md:**

Update version number:

```markdown
**Version:** [X.Y.Z]
**Last Updated:** [YYYY-MM-DD]
```

If status was ✅ Working and now installed, change to 📦 Installed.

## Phase 8: Completion

**Present decision menu:**

```
✓ [ModuleName] v[X.Y.Z] complete

What's next?
1. Test in VCV Rack (recommended)
2. Make another improvement
3. Create new module
4. Document this change
5. Other

Choose (1-5): _
```

**Handle responses:**

- Option 1 → Provide manual testing guidance
- Option 2 → Ask what to improve, restart workflow
- Option 3 → Suggest `/dream` or `/implement`
- Option 4 → Suggest creating documentation
- Option 5 → Ask what they'd like to do

## Breaking Change Detection

**Automatically detect breaking changes:**

If implementation modifies:

- Input/output port configuration (count, IDs, polyphony)
- Parameter IDs or ranges in plugin.json
- CV voltage ranges
- Module width (HP)

Warn:

```
⚠️ Breaking change detected

This change will cause:
- Existing patches may not load correctly
- CV connections may break
- Module width change requires patch layout adjustment

This requires a MAJOR version bump (v[X].0.0).

Proceed with breaking change? (y/n): _
```

If user confirms, force MAJOR version bump.

## Rollback Support

**If anything goes wrong:**

Provide rollback instructions:

```
To restore backup:

1. Remove modified version:
   rm -rf modules/[ModuleName]

2. Restore backup:
   cp -r backups/[ModuleName]-v[X.Y.Z]-[timestamp] modules/[ModuleName]

3. Rebuild:
   cd modules/[ModuleName]
   make clean
   make
   make install

Backup location: backups/[ModuleName]-v[X.Y.Z]-[timestamp]
```

## Version Bump Logic

**PATCH (v1.2.3 → v1.2.4):**

- Bug fixes
- Performance improvements
- Cosmetic UI changes
- Documentation updates
- No new features
- No breaking changes

**MINOR (v1.2 → v1.3):**

- New features added
- New parameters/inputs/outputs added
- UI enhancements
- Backward compatible
- Existing patches still work

**MAJOR (v1 → v2):**

- Breaking changes
- Port configuration changed
- Parameters changed or removed
- CV voltage ranges changed
- Module width changed
- Requires patch migration
- Should be rare

## Integration Points

**Invoked by:**

- `/improve` command
- Natural language: "Fix [module]", "Add [feature] to [module]"
- `module-ideation` skill (after improvement brief)

**Invokes:**

- `module-ideation` skill (if vague request, user chooses brainstorm)
- `deep-research` skill (Tier 3 investigation)
- `build-automation` skill (building)
- `module-testing` skill (validation)
- `module-lifecycle` skill (installation)

**Updates:**

- CHANGELOG.md (adds version entry)
- MODULES.md (version number, last updated)
- plugin.json (version field)
- Source files (implementation changes)

**Creates:**

- Backup in `backups/[ModuleName]-v[X.Y.Z]-[timestamp]/`
- Git tag `v[X.Y.Z]`

## Error Handling

**Build failure:**
Present investigation menu, wait for user decision.

**Test failure:**
Present investigation menu, don't proceed to installation.

**Breaking change detected:**
Warn user, require confirmation, force MAJOR version.

**Backup creation fails:**
STOP immediately, don't proceed with changes.

**Git operations fail:**
Log warning, continue (non-critical).

## Success Criteria

Improvement is successful when:

- Root cause investigated (not band-aid fix)
- Backup created before changes
- Changes implemented correctly
- CHANGELOG updated with version entry
- plugin.json version updated
- Build succeeds without errors
- Tests pass (polyphony, sample rates, CV)
- Git staged with conventional commit message
- MODULES.md updated
- User knows how to rollback if needed
