---
name: vanilla-rails-work-breakdown
description: Use when planning Rails features or breaking down work into PRs - enforces 2-5 file PRs, bug fix separation, and one-sentence scope test
---

# Vanilla Rails Work Breakdown

## Core Rule

**Each PR = one sentence. Target 2-5 files, max 7-8.**

If you can't describe the PR in one sentence, split it.

**CRITICAL: If your PR description uses "and", STOP and split it.**

## Bundle Together

- Model + tests (but NOT scopes/sorting)
- Controller + view + tests
- Migration + model using it
- Routes + controller they configure

**Tests go with the functional change, never with styling.**

## Keep Separate (ALWAYS)

Each of these MUST be its own PR:

- Bug fixes
- Refactoring
- Styling/CSS (even one line)
- Filters (even simple params)
- Sort options (including scopes like `pinned_first`)

## Example: Card Pinning

**Wrong (3 PRs):**
1. "Add pinning to cards with sorting" (model + sorting scope + tests)
2. "Add UI for pinning" (controller + views + tests)
3. "Add filtering and styling" (filter + CSS)

**Right (5 PRs):**
1. "Add pinning to cards" (migration + model methods + tests, 3 files)
2. "Add UI for pinning cards" (controller + view + tests, 4 files)
3. "Sort pinned cards first" (scope + tests, 2 files)
4. "Add filter for pinned cards" (controller param + view + tests, 3 files)
5. "Style pinned cards" (CSS, 1 file)

## Commit Messages

Present tense, no prefixes:

```
Add hotkeys for triaging cards
Fix HTML injection in webhook titles
Expose card ID on comments
```

Not: `feat:`, `fix:`, `WIP:`

## Red Flags

Stop and split if:
- More than 7-8 files
- PR title has "and"
- Mixing refactoring with features
- Bug fix included with feature

## Bug During Feature Work

1. Branch from main for bug fix
2. Fix + test in separate PR
3. Return to feature branch
4. Rebase after bug fix merges

**Never bundle bug fixes with feature PRs.**

## One Sentence Test

✅ "This PR adds pinning to cards"
❌ "This PR adds pinning, styling, and filters"

If you use "and", split the PR.

## Common Rationalizations (STOP)

| Excuse | Reality |
|--------|---------|
| "Sorting is part of the model concern" | No. Sorting is a feature that ships separately. Core pinning works without sorting. |
| "Styling and filtering touch the same view" | Different concerns. Filtering is functional, styling is visual. Separate PRs. |
| "More efficient to bundle them" | 37signals values small PRs over efficiency. 2-5 files is the target. |
| "They're logically grouped" | "Logical grouping" is not the test. One sentence without "and" is the test. |
| "Just a few lines of CSS" | Styling ALWAYS separate. Even one line. |
| "Just a tiny partial" | View code goes with controller, not model. Size irrelevant. |
| "It's related functionality" | Each feature = one PR. Even if related. One sentence test applies. |
| "The change is trivial" | Size doesn't matter. Separate concerns = separate PRs. |
