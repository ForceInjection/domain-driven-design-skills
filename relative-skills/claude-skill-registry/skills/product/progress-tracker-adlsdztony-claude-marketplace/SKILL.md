---
name: progress-tracker
description: This skill should be used when the user asks to "track feature completion", "check progress", "verify all features pass", "count passing tests", "show completion status", or "update feature_list.json". Use for managing and querying the progress of autonomous coding projects.
version: 1.0.0
---

# Progress Tracker Skill

This skill provides guidance for tracking and managing progress in autonomous coding projects using the `.spec/feature_list.json` file as the single source of truth.

## Overview

Progress tracking in autonomous coding projects centers on `.spec/feature_list.json`, which contains all test cases that need to be implemented. Each feature has a `"passes"` field that indicates completion status.

## Feature List Structure

`.spec/feature_list.json` is an array of test cases:

```json
[
  {
    "id": 1,
    "category": "functional",
    "description": "User can login with email and password",
    "steps": [
      "Navigate to /login",
      "Enter email and password",
      "Click submit button",
      "Verify redirect to dashboard"
    ],
    "passes": false
  }
]
```

### Fields

- **id**: Unique identifier (integer)
- **category**: "functional" or "style"
- **description**: What the feature/test verifies
- **steps**: Detailed test steps
- **passes**: Completion status (false = not done, true = verified)

## Checking Progress

### Count Total Features

Count all features in the list:
```bash
cat .spec/feature_list.json | jq '. | length'
```

Or with grep:
```bash
cat .spec/feature_list.json | grep '"id":' | wc -l
```

### Count Passing Features

Count features with `"passes": true`:
```bash
cat .spec/feature_list.json | jq '[.[] | select(.passes == true)] | length'
```

Or with grep:
```bash
cat .spec/feature_list.json | grep '"passes": true' | wc -l
```

### Count Remaining Features

Count features with `"passes": false`:
```bash
cat .spec/feature_list.json | grep '"passes": false' | wc -l
```

### Calculate Percentage

```bash
PASSING=$(cat .spec/feature_list.json | jq '[.[] | select(.passes == true)] | length')
TOTAL=$(cat .spec/feature_list.json | jq '. | length')
echo "scale=1; $PASSING * 100 / $TOTAL" | bc
```

## Display Progress Summary

Generate a human-readable progress summary:

```markdown
=== Development Progress ===

Total Features: 30
✓ Completed: 15 (50%)
○ Remaining: 15 (50%)

Category Breakdown:
  Functional: 10/20 (50%)
  Style: 5/10 (50%)

Feature Breakdown by Status:
  - Authentication: 3/3 (100%)
  - User Interface: 7/10 (70%)
  - Data Management: 3/5 (60%)
  - API Integration: 2/7 (29%)
```

## Updating Progress

### Mark Feature as Passing

After implementing and verifying a feature, update the `"passes"` field:

**CRITICAL:** Only modify the `"passes"` field. Never:
- Remove features
- Edit descriptions
- Modify steps
- Reorder features

```json
{
  "id": 1,
  "category": "functional",
  "description": "User can login with email and password",
  "steps": [...],
  "passes": true  // ← Only change this field
}
```

### When to Mark as Passing

Only mark a feature as `"passes": true` AFTER:

1. Implementation is complete
2. Browser automation verification is done
3. Screenshots captured showing it works
4. All test steps pass
5. No console errors
6. UI matches requirements

### Verification Process

Before marking as passing, verify:

1. **Navigate to the relevant page** in a real browser
2. **Perform each test step** with Playwright or Chrome DevTools MCP
3. **Take screenshots** at each step
4. **Check for errors** in browser console
5. **Verify visual appearance** matches spec
6. **Test edge cases** mentioned in steps

## Finding Features by Status

### Find Next Feature to Implement

Find the first feature with `"passes": false`:

```bash
cat .spec/feature_list.json | jq '[.[] | select(.passes == false)] | .[0]'
```

### Find All Passing Features

```bash
cat .spec/feature_list.json | jq '[.[] | select(.passes == true)]'
```

### Find Features by Category

Find all functional features:
```bash
cat .spec/feature_list.json | jq '[.[] | select(.category == "functional")]'
```

Find all style features:
```bash
cat .spec/feature_list.json | jq '[.[] | select(.category == "style")]'
```

## Progress Notes

Maintain `.spec/claude-progress.txt` with session notes:

```markdown
# Session - [Date]

## Accomplished
- Implemented feature #1: User login
- Implemented feature #2: Password reset

## Tests Completed
- Test #1 now passing
- Test #2 now passing

## Issues Found and Fixed
- Fixed login form validation
- Fixed redirect after login

## Next Session
- Implement feature #3: User profile
- Implement feature #4: Settings page

## Current Status
15/30 tests passing (50%)
```

## Category Breakdown

Track progress by feature category:

```bash
# Functional features
FUNC_PASSING=$(cat .spec/feature_list.json | jq '[.[] | select(.category == "functional" and .passes == true)] | length')
FUNC_TOTAL=$(cat .spec/feature_list.json | jq '[.[] | select(.category == "functional")] | length')

# Style features
STYLE_PASSING=$(cat .spec/feature_list.json | jq '[.[] | select(.category == "style" and .passes == true)] | length')
STYLE_TOTAL=$(cat .spec/feature_list.json | jq '[.[] | select(.category == "style")] | length')
```

## Integration with Git

Each completed feature should be committed:

```bash
git add .spec/feature_list.json
git commit -m "Implement [feature name] - verified end-to-end

- Added [specific changes]
- Tested with browser automation
- Updated .spec/feature_list.json: marked test #X as passing
"
```

## Common Queries

### "What's the progress?"

Run `/show-progress` or manually check:

```bash
echo "Total: $(cat .spec/feature_list.json | jq 'length')"
echo "Passing: $(cat .spec/feature_list.json | jq '[.[] | select(.passes == true)] | length')"
echo "Remaining: $(cat .spec/feature_list.json | jq '[.[] | select(.passes == false)] | length')"
```

### "What should I work on next?"

Find the first non-passing feature:

```bash
cat .spec/feature_list.json | jq '[.[] | select(.passes == false)] | .[0]'
```

### "Are all features complete?"

Check if all features pass:

```bash
REMAINING=$(cat .spec/feature_list.json | jq '[.[] | select(.passes == false)] | length')
if [ "$REMAINING" -eq 0 ]; then
  echo "✓ All features complete!"
else
  echo "○ $REMAINING features remaining"
fi
```

## Troubleshooting

### feature_list.json Doesn't Exist

Initialize project first:
```bash
/start-project spec="Your project spec"
```

### No Features Are Passing

Normal for new projects. Begin implementation:
```bash
/continue
```

### All Features Pass

Project is complete! Review and deploy.

### Features Fail After Passing

Previous session may have introduced bugs. Fix before implementing new features:
1. Run failing test
2. Identify regression
3. Fix the issue
4. Mark as "passes": false until fixed
5. Re-verify and mark as "passes": true

## Best Practices

1. **Always verify before marking** - Never mark as passing without thorough testing
2. **One feature at a time** - Focus on quality over speed
3. **Keep feature list immutable** - Only change "passes" field
4. **Document progress** - Update claude-progress.txt each session
5. **Commit frequently** - Each completed feature gets a commit
6. **Fix regressions first** - Before implementing new features

## Additional Resources

### Reference Files

For detailed feature validation processes and browser verification workflows, consult:
- **`references/feature-validation.md`** - Comprehensive feature validation guide with testing strategies
- **`references/verification-workflows.md`** - Step-by-step verification procedures

### Utility Scripts

The `scripts/` directory contains helper scripts:
- **`scripts/check-progress.py`** - Automated progress checking with detailed output
- **`scripts/update-progress.py`** - Safe progress updates with validation

### Related Skills

- **`browser-verification`** - Detailed browser automation testing guidance
