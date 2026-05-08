---
name: atlas-iterative
description: Iterative 3-phase workflow with peer review cycle for changes needing validation (15-30 min)
---

# Atlas Iterative Workflow

## When to Use This Skill

**Perfect for:**
- Styling improvements that need validation
- Simple UI tweaks requiring quality checks
- Straightforward refactors
- Changes where you know what to do but want peer eyes
- Modifications that don't need research/planning

**Time estimate**: 15-30 minutes (including review cycles)

**Success criteria**:
- Change validated in < 30 minutes
- Peer review approved
- Tests pass
- No major refactoring needed

## The 3 Phases

```
Phase 1: Make Change           → Implement change
Phase 2: Peer Review (Cycle)   → Review → Fix → Repeat until pass
Phase 3: Deploy                → Test + deploy
```

---

## Phase 1: Make Change

**Goal**: Implement the change you know needs to happen.

### Steps:

1. **Understand what needs changing**
   - The requirement is clear (no research needed)
   - You know which file(s) to change
   - Approach is straightforward

2. **Make the change**
   - Implement the modification
   - Follow project conventions
   - Add comments if needed

3. **Self-verify**
   - Visual check (if UI)
   - Logic check (if code)
   - Convention check (StackMap-specific rules)

### Implementation Checklist:

- [ ] Change implemented in 1-2 files
- [ ] StackMap conventions followed:
  - [ ] Field naming (text/icon, not name/emoji)
  - [ ] Store methods (not direct setState)
  - [ ] Typography component (not direct fontWeight)
  - [ ] No gray text (#000 only)
- [ ] Change verified locally
- [ ] No console.logs left behind

### Examples:

**Example 1: Button spacing**
```javascript
// Before
<View style={{ padding: 8 }}>
  <Button />
</View>

// After (better spacing)
<View style={{ padding: 16 }}>
  <Button />
</View>
```

**Example 2: Extract helper function**
```javascript
// Before (validation inline)
const isValid = email.includes('@') && email.length > 5

// After (extracted)
const validateEmail = (email) => {
  return email.includes('@') && email.length > 5
}
const isValid = validateEmail(email)
```

---

## Phase 2: Peer Review (Iterative Cycle)

**Goal**: Get peer feedback, address issues, repeat until approved.

### The Review Cycle:

```
1. Submit for review
2. Receive feedback
3. Address feedback
4. Re-submit
5. Repeat until PASS
```

### Steps:

1. **Self-review first**
   ```bash
   # Run quick checks
   npm run typecheck
   npm run lint
   ```

2. **Submit for peer review**
   - Explain what changed and why
   - Highlight areas you're uncertain about
   - Request specific feedback if needed

3. **Receive feedback**
   - Read all feedback carefully
   - Ask clarifying questions if unclear
   - Prioritize blocking issues

4. **Address feedback**
   - Fix all blocking issues
   - Consider suggestions
   - Update code based on feedback

5. **Re-submit**
   - Explain what you changed
   - Confirm all issues addressed
   - Run validation again

### Review Checklist:

**Before submitting:**
- [ ] Type checking passes
- [ ] Linting passes (or only warnings)
- [ ] Self-reviewed for obvious issues
- [ ] StackMap conventions verified

**During review:**
- [ ] Understand all feedback
- [ ] Track which issues addressed
- [ ] Test after each fix
- [ ] Document non-obvious decisions

**Review pass criteria:**
- [ ] No blocking issues
- [ ] Code quality acceptable
- [ ] Edge cases considered
- [ ] StackMap conventions followed

### Common Review Feedback:

**Feedback 1: Missing edge case**
```javascript
// Review: "What if activities array is empty?"

// Before
const firstActivity = activities[0]

// After
const firstActivity = activities.length > 0 ? activities[0] : null
if (!firstActivity) return null
```

**Feedback 2: Convention violation**
```javascript
// Review: "Should use store-specific method"

// Before
useAppStore.setState({ users: newUsers })

// After
useUserStore.getState().setUsers(newUsers)
```

**Feedback 3: Accessibility**
```javascript
// Review: "Gray text violates accessibility rules"

// Before
<Text style={{ color: '#666666' }}>Secondary text</Text>

// After
<Text style={{ color: '#000000' }}>Secondary text</Text>
```

### Using Peer-Reviewer Agent:

If the atlas-agent-peer-reviewer skill is available:

```
"Review my changes: [brief description]

Files changed:
- /path/to/file1.js
- /path/to/file2.js

What I changed:
[Explanation]

Please check for:
- Edge cases
- StackMap conventions
- Code quality
"
```

The peer-reviewer agent will provide structured feedback with a verdict:
- 🔴 **REJECTED**: Must fix issues and resubmit
- ⚠️ **CONDITIONAL PASS**: Minor issues, can address after merge
- ✅ **PASS**: Approved, proceed to deploy

---

## Phase 3: Deploy

**Goal**: Deploy the approved changes.

### Steps:

1. **Final validation**
   ```bash
   npm run typecheck
   npm test
   ```

2. **Update PENDING_CHANGES.md**
   ```markdown
   ## Title: Improve button spacing for better UX
   ### Changes Made:
   - Updated button padding from 8px to 16px
   - Applied consistently across login and signup screens
   - Peer reviewed and approved
   ```

3. **Deploy to QUAL**
   ```bash
   ./scripts/deploy.sh qual --all
   ```

4. **Verify deployment**
   - Check deployment output
   - Test in QUAL environment
   - Confirm change is live

### Deployment Checklist:

- [ ] PENDING_CHANGES.md updated
- [ ] All tests pass
- [ ] Type checking passes
- [ ] Peer review approved
- [ ] Deployed using script
- [ ] Change verified in QUAL

---

## Escalation Criteria

**Escalate to Standard workflow if:**
- Affects more than 2 files
- Tests fail (need new tests)
- Complex edge cases emerge
- Needs architectural decisions
- Uncertain about approach

**Escalate to Full workflow if:**
- Security implications discovered
- Cross-platform coordination needed
- Formal requirements become necessary

### How to Escalate:

```
"Escalating to Standard workflow. Found 4 files need changes and complex edge cases require planning."
```

Then restart from Phase 1 of Standard workflow.

---

## Common Iterative Workflow Tasks

### 1. Style/Layout Improvements

**Use case**: Adjust spacing, alignment, sizing for better UX

**Pattern**:
- Phase 1: Adjust styles
- Phase 2: Get visual feedback from reviewer
- Phase 3: Deploy

**Time**: 15-20 minutes

---

### 2. Component Refactoring

**Use case**: Extract logic, improve code organization

**Pattern**:
- Phase 1: Refactor code
- Phase 2: Reviewer checks for edge cases, naming
- Phase 3: Deploy

**Time**: 20-25 minutes

---

### 3. UI Tweaks

**Use case**: Update animations, transitions, visual effects

**Pattern**:
- Phase 1: Implement tweak
- Phase 2: Reviewer checks cross-platform compatibility
- Phase 3: Deploy

**Time**: 15-25 minutes

---

## Anti-Patterns (Don't Do This)

### ❌ Anti-Pattern 1: Skipping Review

```
"Change looks good to me, deploying immediately"
```

**Problem**: Purpose of Iterative is validation. Without review, use Quick workflow.

**Solution**: Complete the review cycle or use Quick workflow if validation not needed.

---

### ❌ Anti-Pattern 2: Ignoring Feedback

```
Reviewer: "Missing edge case"
You: "Looks fine to me, merging anyway"
```

**Problem**: Defeats purpose of peer review.

**Solution**: Address all blocking feedback or escalate to discuss with team.

---

### ❌ Anti-Pattern 3: Scope Creep

```
Started: "Adjust button padding"
Now doing: "Adjust padding + refactor button component + add new props"
```

**Problem**: No longer iterative, too complex.

**Solution**: Escalate to Standard workflow or split into multiple tasks.

---

## Iterative Workflow Checklist

### Phase 1: Make Change
- [ ] Requirement is clear (no research needed)
- [ ] Know which file(s) to change
- [ ] Change implemented in 1-2 files
- [ ] Self-verified (visual/logic check)
- [ ] StackMap conventions followed

### Phase 2: Peer Review (Cycle)
- [ ] Self-review first (typecheck, lint)
- [ ] Submitted for peer review
- [ ] Received feedback
- [ ] Addressed all blocking issues
- [ ] Re-submitted if needed
- [ ] Received PASS verdict

### Phase 3: Deploy
- [ ] Final validation passed
- [ ] PENDING_CHANGES.md updated
- [ ] Deployed using script
- [ ] Verified in environment

### Red Flags (Escalate):
- ⚠️ Affects 3+ files
- ⚠️ Tests failing
- ⚠️ Review reveals architectural issues
- ⚠️ Approach uncertain
- ⚠️ Complex edge cases

---

## Example: Complete Iterative Workflow

### Task: "Improve card layout spacing for better visual hierarchy"

#### Phase 1: Make Change (10 minutes)

```javascript
// File: src/components/ActivityCard.js

// Before
const styles = StyleSheet.create({
  card: {
    padding: 12,
    margin: 8
  },
  title: {
    fontSize: 16,
    marginBottom: 4
  }
})

// After (improved spacing)
const styles = StyleSheet.create({
  card: {
    padding: 16,      // More breathing room
    margin: 12        // Better separation between cards
  },
  title: {
    fontSize: 18,     // Larger, more prominent
    marginBottom: 8   // Better separation from subtitle
  }
})
```

**Self-verify**: Looks better visually ✅

#### Phase 2: Peer Review - Cycle 1 (5 minutes)

**Submit**: "Updated card spacing for better hierarchy. Please review."

**Feedback received**:
- ⚠️ "Check Android - percentage widths might be affected"
- ⚠️ "Verify on small screens (iPhone SE)"

**Address feedback**:
```javascript
// Tested on Android simulator - widths still work ✅
// Tested on iPhone SE - spacing looks good ✅
```

**Re-submit**: "Tested on Android and small screens, all good."

#### Phase 2: Peer Review - Cycle 2 (3 minutes)

**Feedback received**:
- ✅ "PASS - Looks good, spacing is consistent"

#### Phase 3: Deploy (2 minutes)

**Update PENDING_CHANGES.md**:
```markdown
## Title: Improve activity card spacing for better visual hierarchy
### Changes Made:
- Increased card padding from 12px to 16px
- Increased card margin from 8px to 12px
- Increased title font size from 16px to 18px
- Increased title bottom margin from 4px to 8px
- Tested on Android and iOS small screens
- Peer reviewed and approved
```

**Deploy**:
```bash
./scripts/deploy.sh qual --all
# ✅ Deployed successfully
```

**Total time: 20 minutes** ✅

---

## Success Indicators

### You've succeeded when:
- ✅ Completed in < 30 minutes
- ✅ Peer review approved
- ✅ Tests pass
- ✅ Change improves code/UX
- ✅ No scope creep

### You should have escalated if:
- ⚠️ Took > 30 minutes
- ⚠️ Multiple review cycles with blocking issues
- ⚠️ Affects 3+ files
- ⚠️ Architectural concerns raised

---

## Quick Reference

### Iterative Workflow Commands:
```bash
# Validation
npm run typecheck
npm run lint

# Deploy
./scripts/deploy.sh qual --all
```

### Time Allocation:
- **Phase 1**: 5-15 minutes (make change)
- **Phase 2**: 5-10 minutes (review cycles)
- **Phase 3**: 2-5 minutes (deploy)
- **Total**: 15-30 minutes

### Decision:
- **Know what to change, want validation** → Iterative ✅
- **Trivial, no validation needed** → Quick
- **Need research/planning** → Standard
- **Complex, formal process** → Full

---

## Summary

The Iterative workflow adds **peer validation** to simple changes. Use it when:
- You know what needs to change (no research)
- Approach is straightforward (no planning)
- But you want quality validation before deploying

**Key advantage**: Catches edge cases and convention violations early through structured review.

Remember: If review reveals complexity, **escalate to Standard workflow** rather than forcing it through Iterative.
