---
name: accepting-stories
description: Guides product owner through systematic acceptance testing. Use when verifying acceptance criteria, checking story completion, or conducting final review before marking a story as done.
---

# Acceptance Testing

Product owner verifies each acceptance criterion is met.

## Prerequisites

Before starting:
- Developer verification is complete
- Story log shows "Pending Product Owner Review"
- Implementation is accessible (local, deployed, or via PR)

## Testing Process

### 1. Locate Story Log

Find the story document:
```bash
ls docs/stories/**/*.story.md
```

### 2. Review Acceptance Criteria

Read through all criteria to understand scope.

### 3. Test Each Criterion

For each acceptance criterion:

```
Criterion [N] of [Total]:

Given: [precondition]
When:  [action]
Then:  [expected result]

Steps to verify:
1. [Setup step]
2. [Action step]
3. [Verification step]

Result: [ ] Pass  [ ] Fail  [ ] Blocked
Notes: _______________
```

### 4. Record Results

**If PASS**: Check the criterion's checkbox in the story log

**If FAIL**:
- Do not check the checkbox
- Add note describing the failure
- Specify what needs to be fixed

**If BLOCKED**:
- Note the blocker
- Determine if it's a missing prerequisite or external dependency

### 5. Update Story Status

All criteria pass:
```markdown
### Acceptance Checks

**Status: Accepted**

All acceptance criteria verified and passing.
Tested on: [date]
```

Any criteria fail:
```markdown
### Acceptance Checks

**Status: Needs Revision**

Failing criteria:
- Criterion 2: [description of failure]

Required fixes:
- [Specific fix needed]
```

## After Acceptance

- Story can proceed to final commit/push/merge
- Update epic progress table if part of an epic
- Celebrate the completed increment of user value
