---
name: next-steps-planner
description: Intelligent planning for what to do next after completing a task in Dashboard Link SaaS development. Use when user asks "what next?", "what should I do now?", "what's the next step?", after completing a feature, after fixing bugs, or when uncertain about priorities. Also use for sprint planning, task prioritization, and development roadmap guidance.
---

# Next Steps Planner

## Overview

Provides intelligent guidance on what to do next in the development lifecycle, ensuring you don't miss critical steps like testing, documentation, deployment, or follow-up tasks.

## After Completing ANY Task

Follow this checklist systematically:

### 1. ✅ Verify the Change Works

**Manual Verification:**
- [ ] Run the affected code/feature
- [ ] Test happy path
- [ ] Test error cases
- [ ] Check edge cases
- [ ] Review console for errors
- [ ] Check network tab for API calls

**Automated Verification:**
```bash
# Lint
pnpm lint

# Type check
pnpm --filter <package-name> typecheck

# Tests
pnpm test

# Build
pnpm build
```

### 2. 📝 Update Documentation

- [ ] Update README if user-facing changes
- [ ] Update API docs if endpoints changed
- [ ] Update architecture docs if structure changed
- [ ] Add/update JSDoc comments
- [ ] Update .env.example if new env vars
- [ ] Update migration guide if breaking changes

### 3. 🧪 Add/Update Tests

- [ ] Unit tests for new functions
- [ ] Integration tests for API endpoints
- [ ] Component tests for React components
- [ ] E2E tests for critical flows (if applicable)

### 4. 🔒 Security Review

- [ ] No hardcoded secrets
- [ ] Input validation in place
- [ ] Authentication/authorization correct
- [ ] RLS policies applied
- [ ] No SQL injection risks
- [ ] XSS prevention in place

### 5. 📊 Performance Check

- [ ] No N+1 queries
- [ ] Proper indexing
- [ ] Efficient algorithms
- [ ] Pagination for large datasets
- [ ] Memoization where needed

### 6. 🎨 Code Quality

- [ ] Follow naming conventions
- [ ] No console.log statements
- [ ] Proper error handling
- [ ] TypeScript types correct
- [ ] Comments only where needed

### 7. 💾 Commit & Push

```bash
git status
git add .
git commit -m "feat: descriptive message"
git push
```

### 8. 🚀 Deploy/Merge

- [ ] Create PR with description
- [ ] Request review
- [ ] Address feedback
- [ ] Merge to main
- [ ] Deploy to staging
- [ ] Test in staging
- [ ] Deploy to production
- [ ] Monitor for issues

## Common "What Next?" Scenarios

### After Fixing a Bug

1. ✅ Verify bug is fixed
2. 🧪 Add test to prevent regression
3. 📝 Update changelog
4. 💾 Commit with "fix:" prefix
5. 🚀 Deploy quickly if critical
6. 📊 Check monitoring for similar issues

### After Adding a New Feature

1. ✅ Verify feature works
2. 🧪 Add comprehensive tests
3. 📝 Update docs and examples
4. 🔒 Security review
5. 📊 Performance review
6. 💾 Commit with "feat:" prefix
7. 🚀 Deploy to staging first
8. 🎯 Plan next feature iteration

### After Refactoring

1. ✅ Verify nothing broke
2. 🧪 Run full test suite
3. 📝 Update architecture docs
4. 📊 Check performance metrics
5. 💾 Commit with "refactor:" prefix
6. 🚀 Deploy carefully
7. 📈 Monitor for regressions

### When Starting a New Day

1. 📧 Check for urgent issues (bugs, alerts)
2. 📝 Review open PRs
3. 🎯 Check project board/backlog
4. 🔍 Run full build to ensure clean state
5. 🎯 Pick highest priority task
6. 📖 Read related docs/code before starting

### When Stuck or Blocked

1. 🤔 Clearly define the problem
2. 📚 Check documentation
3. 🔍 Search for similar issues
4. 🧪 Create minimal reproduction
5. 💬 Ask for help (with context)
6. 🎯 Work on different task while waiting

## Feature Development Priority Matrix

### Critical (Do Now)
- Security vulnerabilities
- Production bugs
- Data integrity issues
- Authentication/authorization bugs

### High Priority (Do Soon)
- Core feature development
- Performance issues
- User-facing bugs
- Database migrations

### Medium Priority (Can Wait)
- Feature enhancements
- Code quality improvements
- Documentation updates
- Technical debt

### Low Priority (Nice to Have)
- Refactoring for cleanliness
- Minor optimizations
- Style improvements
- Extra documentation

## Decision Tree: What to Work On Next?

```
Are there production issues?
├─ YES → Fix immediately
└─ NO → Continue

Are there security vulnerabilities?
├─ YES → Fix immediately
└─ NO → Continue

Are there open PRs waiting for you?
├─ YES → Review and merge
└─ NO → Continue

Are you blocked on current task?
├─ YES → Work on different task or ask for help
└─ NO → Continue current task

Is current task complete?
├─ YES → Follow "After Completing ANY Task" checklist
└─ NO → Continue working on it

What's highest priority in backlog?
├─ Critical → Start immediately
├─ High → Plan and start
├─ Medium → Schedule for later
└─ Low → Defer for now
```

## Sprint/Weekly Planning

### Monday Morning
1. Review last week's completed work
2. Check production metrics/issues
3. Review and prioritize backlog
4. Plan this week's goals
5. Break down large tasks
6. Assign rough time estimates

### Daily
1. Morning: Check for urgent issues
2. Mid-day: Review progress
3. End of day: Update task status, plan tomorrow

### Friday Afternoon
1. Complete in-progress work
2. Write documentation
3. Clean up branches
4. Deploy pending changes
5. Review week's progress

## When Uncertain About Priority

**Ask these questions:**
1. Does this affect users right now? (Security, bugs)
2. Does this unblock other people?
3. Is this time-sensitive?
4. What's the impact if delayed?
5. How long will it take?

**Then prioritize:**
- High impact + Quick → Do now
- High impact + Slow → Plan carefully, start soon
- Low impact + Quick → Do when blocked on other work
- Low impact + Slow → Defer or don't do

## Resources

- See `references/development-workflow.md` for detailed workflow
- See `references/task-templates.md` for common task patterns

## Common Pitfalls

- Skipping testing because "it works on my machine"
- Forgetting documentation updates
- Deploying without staging test
- Not checking for related changes needed
- Committing without reviewing changes
- Merging without testing

## Best Practices

- Always complete the verification checklist
- Update docs as you code, not after
- Write tests before marking task complete
- Deploy to staging before production
- Monitor after deployment
- Keep task sizes small (1-3 days max)
- Don't start new feature while another is incomplete
