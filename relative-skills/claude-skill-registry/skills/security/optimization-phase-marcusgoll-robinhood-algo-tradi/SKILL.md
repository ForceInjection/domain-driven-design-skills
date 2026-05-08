---
name: optimization-phase
description: "Standard Operating Procedure for /optimize phase. Covers performance benchmarking, accessibility audit, security review, and code quality checks."
allowed-tools: Read, Bash, Grep, Glob
---

# Optimization Phase: Quick Reference

> **Purpose**: Production readiness validation - performance, security, accessibility, and code quality before deployment.

## Phase Overview

**Inputs**:
- Implemented code (from `/implement` phase)
- `specs/NNN-slug/spec.md` - Success criteria and performance targets

**Outputs**:
- `optimization-report.md` - Performance, security, accessibility results
- `code-review-report.md` - Code quality issues and recommendations

**Expected duration**: 1-2 hours

---

## Quick Start Checklist

**Before you begin**:
- [ ] Implementation phase completed
- [ ] All tests passing
- [ ] Code committed to feature branch

**Core workflow**:
1. ✅ [Performance Benchmarking](resources/performance-benchmarking.md) - API <200ms, page load <2s
2. ✅ [Accessibility Audit](resources/accessibility-audit.md) - WCAG 2.1 AA compliance (if UI feature)
3. ✅ [Security Review](resources/security-review.md) - npm audit, dependency scanning
4. ✅ [Code Quality Review](resources/code-quality-review.md) - DRY violations, test coverage
5. ✅ [Generate Reports](resources/report-generation.md) - optimization-report.md + code-review-report.md

---

## Detailed Resources

### 🎯 Quality Gates (Blocking)
- **[Performance Benchmarking](resources/performance-benchmarking.md)** - API p50/p95, page load targets
- **[Accessibility Audit](resources/accessibility-audit.md)** - Lighthouse CI, axe-core validation
- **[Security Review](resources/security-review.md)** - Dependency vulnerabilities, OWASP top 10

### 📊 Code Quality (Blocking if Critical)
- **[Code Quality Review](resources/code-quality-review.md)** - DRY, KISS, test coverage (80%+)
- **[Code Review Checklist](resources/code-review-checklist.md)** - Pre-commit validation

### 📝 Documentation
- **[Report Generation](resources/report-generation.md)** - optimization-report.md format
- **[Common Mistakes](resources/common-mistakes.md)** - Anti-patterns to avoid

---

## Completion Criteria

**Required (Blocking)**:
- [ ] Performance targets met (API p50 <200ms, p95 <500ms, page load <2s)
- [ ] Test coverage ≥80% (unit + integration)
- [ ] Security scan clean (no critical vulnerabilities)
- [ ] Accessibility WCAG 2.1 AA (if UI feature)
- [ ] No DRY violations (code duplication <3 instances)

**Optional**:
- [ ] Performance optimizations applied (caching, lazy loading)
- [ ] Minor accessibility improvements
- [ ] Code refactoring suggestions documented

---

## Quality Gates

**Gate 1: Pre-Flight Validation** (Blocking)
- [ ] Environment variables configured
- [ ] Production build succeeds
- [ ] No TypeScript/lint errors

**Gate 2: Code Review** (Blocking if critical issues)
- [ ] Test coverage ≥80%
- [ ] Performance benchmarks met
- [ ] Security scan passed
- [ ] Accessibility standards met

---

## Next Phase

After optimization complete:
→ `/preview` - Manual UI/UX testing on local dev server

---

**See also**:
- [reference.md](reference.md) - Comprehensive optimization guide (full text)
- [examples.md](examples.md) - Good vs bad optimization examples
