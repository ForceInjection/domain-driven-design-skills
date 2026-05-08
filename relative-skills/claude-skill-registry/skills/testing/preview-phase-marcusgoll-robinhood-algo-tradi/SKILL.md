---
name: preview-phase
description: "Standard Operating Procedure for /preview phase. Covers manual UI/UX testing on local dev server before shipping."
allowed-tools: Bash, Read
---

# Preview Phase: Quick Reference

> **Purpose**: Manual UI/UX testing on local dev server to validate user experience before deployment.

## Phase Overview

**Inputs**:
- Optimized code (from `/optimize` phase)
- `specs/NNN-slug/spec.md` - Success criteria and user flows

**Outputs**:
- `release-notes.md` - User-facing feature description
- Manual testing sign-off

**Expected duration**: 30-60 minutes

---

## Quick Start Checklist

**Before you begin**:
- [ ] Optimization phase completed
- [ ] All quality gates passed
- [ ] Local dev server can start

**Core workflow**:
1. ✅ [Start Dev Server](resources/dev-server-setup.md) - npm run dev or equivalent
2. ✅ [Test Happy Path](resources/happy-path-testing.md) - Primary user flows work
3. ✅ [Test Error Scenarios](resources/error-scenario-testing.md) - Validation, network failures
4. ✅ [Test Responsive Design](resources/responsive-testing.md) - Mobile, tablet, desktop (if UI)
5. ✅ [Test Keyboard Navigation](resources/keyboard-testing.md) - Tab order, focus indicators
6. ✅ [Generate Release Notes](resources/release-notes.md) - User-facing documentation

---

## Detailed Resources

### 🎯 Core Testing
- **[Dev Server Setup](resources/dev-server-setup.md)** - Start local environment
- **[Happy Path Testing](resources/happy-path-testing.md)** - Primary user flows
- **[Error Scenario Testing](resources/error-scenario-testing.md)** - Edge cases, failures

### 🖥️ UI/UX Testing (if HAS_UI=true)
- **[Responsive Testing](resources/responsive-testing.md)** - Mobile, tablet, desktop
- **[Keyboard Testing](resources/keyboard-testing.md)** - Accessibility navigation
- **[Browser Testing](resources/browser-testing.md)** - Chrome, Firefox, Safari

### 📝 Documentation
- **[Release Notes](resources/release-notes.md)** - User-facing change documentation
- **[Issue Tracking](resources/issue-tracking.md)** - Log issues found during testing

---

## Completion Criteria

**Required (Manual Gate - Blocking)**:
- [ ] Happy path works end-to-end
- [ ] Error scenarios handled gracefully
- [ ] Responsive design tested (if UI)
- [ ] Keyboard navigation works (if UI)
- [ ] release-notes.md created

**Optional**:
- [ ] Visual regression check (screenshots)
- [ ] Browser compatibility testing
- [ ] Performance profiling in DevTools

---

## Manual Gate

**This is a MANUAL GATE** - Requires human approval before proceeding.

After testing complete:
```bash
# Approve and continue workflow
/feature continue
# or /ship continue (if called from /ship)
```

---

## Next Phase

After preview approval:
→ `/ship` - Deploy to staging/production (model-specific)

---

**See also**:
- [reference.md](reference.md) - Comprehensive preview guide (full text)
- [examples.md](examples.md) - Good vs bad testing examples
