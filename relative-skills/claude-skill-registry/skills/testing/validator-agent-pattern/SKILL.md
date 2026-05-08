---
name: Validator Agent Pattern
description: Test implementations against requirements, collect feedback, and create improvement loops
model: haiku
---

# Validator Agent Pattern

## File Paths & Versioning

**Input:**
- `project-docs/prd/prd-latest.md` — Requirements to validate against
- `project-docs/work-orders/work-orders-latest.md` — Work orders that were implemented
- `src/` — Implementation code

**Output:**
- `project-docs/validation/validation-v{N}.md` — Versioned validation report
- `project-docs/validation/validation-latest.md` — Copy of the latest version

**Workflow:**
1. Read PRD, work orders, and implementation
2. Detect next version number (check existing `validation-v*.md` files)
3. Generate `validation-v{N}.md`
4. Update `validation-latest.md` to match

**Version Header:** Each validation report includes:
```markdown
---
version: 1
date: 2025-12-18
prd_version: 1
work_orders_version: 1
changes_from_previous: null | "Summary of changes"
---
```

## Purpose

The Validator Agent is the fifth and final stage in the software factory workflow. It validates implementations against original requirements, tests for quality and correctness, collects user feedback, and generates improvement suggestions. It closes the feedback loop by creating new work orders for issues found or sending feedback to earlier stages.

## When to Use This Pattern

Use the Validator Agent pattern when:
- Implementation is complete and needs validation
- You need to verify code meets acceptance criteria
- You're collecting user feedback on features
- You want to establish continuous improvement loops
- You need to ensure quality before deployment

## Core Responsibilities

### 1. Requirements Verification
**Test against acceptance criteria:**
- Parse original PRD and work orders
- Extract testable acceptance criteria
- Verify each criterion is met
- Document which requirements are satisfied

### 2. Quality Testing
**Execute comprehensive testing:**
- Run unit tests and check coverage
- Execute integration tests
- Perform end-to-end testing
- Check for bugs and issues
- Validate error handling

### 3. Feedback Collection
**Gather stakeholder input:**
- Collect user feedback
- Identify usability issues
- Document feature requests
- Track bug reports
- Analyze user behavior

### 4. Issue Identification
**Find problems and gaps:**
- Missing features from PRD
- Bugs and defects
- Performance issues
- Security vulnerabilities
- Usability problems

### 5. Feedback Loop Generation
**Create improvement actions:**
- Generate new work orders for fixes
- Suggest PRD updates for missing requirements
- Recommend architecture changes
- Propose enhancements
- Prioritize improvement backlog

## Implementation Approach

### Step 1: Gather Context

```
Implementation → Context Collection → Validation Setup
```

**Collect all relevant documents:**
- Original PRD with requirements
- Technical blueprint
- Work orders that were implemented
- Implementation code and tests
- Current system state

**Understand the scope:**
- What was supposed to be built?
- What acceptance criteria exist?
- What are the success metrics?
- Who are the users?

### Step 2: Verify Acceptance Criteria

```
Requirements + Implementation → Criteria Checking → Verification Report
```

**For each acceptance criterion:**

**From PRD:**
```
Requirement: Users can create tasks
Acceptance Criteria:
- [ ] Users can enter task title and description
- [ ] Users can assign tasks to team members
- [ ] Tasks appear in the task list immediately
- [ ] Users receive confirmation after creation
```

**Validation process:**
```
Test 1: Create task with title only
✅ Pass - Task created successfully

Test 2: Create task with title and assignee
✅ Pass - Task created and assigned

Test 3: Verify task appears in list
✅ Pass - Task visible immediately

Test 4: Verify confirmation message
❌ Fail - No confirmation message shown
```

**Verification methods:**
- **Automated testing**: Run test suites
- **Manual testing**: Use the application
- **Code review**: Inspect implementation
- **Metrics analysis**: Check performance data

### Step 3: Execute Testing

```
Implementation → Testing → Test Results
```

**Testing levels:**

**Level 1: Unit Testing**
```
Goal: Verify individual functions work correctly

Check:
- All unit tests pass
- Coverage meets threshold (typically >80%)
- Edge cases are tested
- Error handling is tested

Report:
- Tests passing: 95/100
- Coverage: 87%
- Issues: 5 failing tests in taskService
```

**Level 2: Integration Testing**
```
Goal: Verify components work together

Check:
- API endpoints return expected responses
- Database operations work correctly
- Authentication/authorization functions
- External integrations work

Report:
- API tests passing: 28/30
- Issues: 2 endpoints returning 500 errors
```

**Level 3: End-to-End Testing**
```
Goal: Verify complete user workflows

Check:
- User can complete primary tasks
- UI displays correctly
- Data persists correctly
- Error messages are helpful

Report:
- E2E tests passing: 12/15
- Issues: Task assignment workflow broken
```

**Level 4: Performance Testing**
```
Goal: Verify system meets performance requirements

Check:
- Response times meet targets
- System handles expected load
- No memory leaks
- Database queries optimized

Report:
- Average response time: 145ms (target: <200ms) ✅
- 95th percentile: 320ms (target: <500ms) ✅
- Max concurrent users handled: 500 (target: 1000) ❌
```

**Level 5: Security Testing**
```
Goal: Verify system is secure

Check:
- Authentication is enforced
- Authorization prevents unauthorized access
- Input validation prevents injection
- Sensitive data is protected

Report:
- Authentication: ✅ All endpoints protected
- Authorization: ❌ User can access other team's tasks
- Input validation: ✅ SQL injection prevented
- Data protection: ✅ Passwords hashed, secrets encrypted
```

### Step 4: Collect User Feedback

```
Deployed Feature → User Interaction → Feedback Data
```

**Feedback sources:**

**Direct Feedback:**
- User surveys and interviews
- Support tickets and bug reports
- Feature requests
- User testing sessions

**Behavioral Feedback:**
- Usage analytics (which features are used)
- Completion rates (do users finish workflows)
- Error rates (where do users get stuck)
- Time on task (is it efficient)

**Feedback analysis:**
```
Feedback: "I can't find where to assign tasks to teammates"
Analysis:
- Feature exists but UI is unclear
- Usability issue, not a bug
Action:
- Create work order to improve UI
- Update PRD to clarify UX requirements
```

### Step 5: Generate Validation Report

```
Test Results + Feedback → Analysis → Validation Report
```

**Report structure:**

```markdown
# Validation Report: Collaborative Task Manager

## Overview
- **Validation Date**: 2025-12-17
- **PRD Version**: v1.0
- **Implementation Phase**: Phase 2 (Core Features)
- **Validator**: Validation Agent

## Executive Summary
✅ **Status**: Mostly Passing (85% complete)

The task management system successfully implements core functionality but has several issues preventing full deployment:
- 2 critical bugs blocking user workflows
- 1 security vulnerability requiring immediate fix
- 5 usability improvements needed
- 3 missing features from PRD

## Requirements Verification

### From PRD: User Authentication (P0)

✅ **Requirement 1**: Users can register with email/password
- Test Result: Pass
- Evidence: 12 users registered successfully in testing

✅ **Requirement 2**: Users can log in and log out
- Test Result: Pass
- Evidence: Login/logout tested across 3 browsers

❌ **Requirement 3**: Password reset functionality
- Test Result: Fail - Not implemented
- Impact: High - Users cannot recover forgotten passwords
- Action: Create work order WO-020

### From PRD: Task Management (P0)

✅ **Requirement 4**: Users can create tasks
- Test Result: Pass
- Notes: Missing confirmation message (minor issue)

❌ **Requirement 5**: Users can assign tasks to team members
- Test Result: Fail - Assignment UI broken
- Impact: Critical - Core feature unusable
- Action: Create urgent work order WO-021

[Continue for all requirements...]

## Test Results

### Unit Tests
- **Total**: 142 tests
- **Passing**: 135 tests (95%)
- **Failing**: 7 tests (5%)
- **Coverage**: 87% (target: >80%) ✅

**Failing Tests**:
1. `taskService.assignTask` - TypeError on null user
2. `authService.resetPassword` - Not implemented
3. [List all failing tests...]

### Integration Tests
- **Total**: 35 tests
- **Passing**: 28 tests (80%)
- **Failing**: 7 tests (20%)

**Failing Tests**:
1. `POST /api/tasks/:id/assign` - Returns 500 error
2. `POST /api/auth/reset-password` - Returns 404
3. [List all failing tests...]

### End-to-End Tests
- **Total**: 18 tests
- **Passing**: 14 tests (78%)
- **Failing**: 4 tests (22%)

**Critical Failures**:
1. "User assigns task to teammate" - Workflow broken
2. "User resets password" - Feature missing

### Performance Tests
✅ **Response Time**: Average 145ms (target <200ms)
✅ **95th Percentile**: 320ms (target <500ms)
❌ **Concurrent Users**: 500 (target 1000)
✅ **Database Query Time**: <50ms average

### Security Tests
✅ **Authentication**: All endpoints protected
❌ **Authorization**: Users can access other teams' data
✅ **Input Validation**: SQL injection prevented
✅ **Data Encryption**: Passwords hashed, secrets encrypted

## Issues Found

### Critical Issues (Block Deployment)

**Issue #1: Authorization Vulnerability**
- **Severity**: Critical (Security)
- **Description**: Users can access and modify tasks from other teams
- **Location**: `src/middleware/authorization.ts`
- **Impact**: Data leak, potential data corruption
- **Action**: Create urgent work order WO-022

**Issue #2: Task Assignment Broken**
- **Severity**: Critical (Functionality)
- **Description**: Assigning tasks to users returns 500 error
- **Location**: `src/api/tasks.ts:45`
- **Impact**: Core feature unusable
- **Action**: Create urgent work order WO-023

### High Priority Issues

**Issue #3: Missing Password Reset**
- **Severity**: High (Missing Feature)
- **Description**: Password reset not implemented, in PRD as P0
- **Impact**: Users locked out cannot recover accounts
- **Action**: Create work order WO-024

[Continue for all issues...]

### Medium Priority Issues

**Issue #6: No Task Creation Confirmation**
- **Severity**: Medium (Usability)
- **Description**: No visual feedback after creating task
- **Impact**: User uncertainty, confusion
- **Action**: Create work order WO-027

[Continue...]

### Low Priority Issues

**Issue #10: Inconsistent Error Messages**
- **Severity**: Low (Polish)
- **Description**: Error messages vary in format
- **Impact**: Slight UX inconsistency
- **Action**: Add to backlog

## User Feedback Analysis

### Feedback Collected
- **Total Responses**: 15 users
- **Positive Feedback**: 12 users (80%)
- **Issues Reported**: 8 unique issues
- **Feature Requests**: 5 requests

### Common Themes

**Theme 1: Task Assignment Confusion** (8 mentions)
> "I couldn't figure out how to assign tasks"

**Analysis**: UI is not intuitive, needs improvement

**Theme 2: Missing Notifications** (5 mentions)
> "I don't know when tasks are assigned to me"

**Analysis**: Notification feature in PRD but not implemented

**Theme 3: Performance is Good** (10 mentions)
> "The app is fast and responsive"

**Analysis**: Performance targets being met

### Feature Requests

1. **Bulk Task Creation** (3 requests)
   - Priority: Medium
   - Action: Add to PRD as future enhancement

2. **Task Templates** (2 requests)
   - Priority: Low
   - Action: Add to backlog

[Continue...]

## Recommendations

### Immediate Actions (This Week)
1. ❗ Fix authorization vulnerability (WO-022)
2. ❗ Fix task assignment endpoint (WO-023)
3. ⚠️ Implement password reset (WO-024)

### Short-Term Actions (Next 2 Weeks)
4. Improve task assignment UI (WO-025)
5. Add task creation confirmation (WO-027)
6. Increase concurrent user capacity (WO-028)

### Long-Term Actions (Backlog)
7. Add bulk task creation
8. Implement task templates
9. Add email notifications

## Feedback Loop Actions

### → Refinery Agent
**PRD Updates Needed**:
- Add missing requirement: Email notifications for task assignments
- Clarify UX requirements for task assignment flow
- Add non-functional requirement: Support 1000 concurrent users

### → Planner Agent
**New Work Orders**:
- WO-022: Fix authorization middleware (Urgent, 2h)
- WO-023: Fix task assignment endpoint (Urgent, 3h)
- WO-024: Implement password reset (High, 6h)
- WO-025: Improve task assignment UI (Medium, 4h)

### → Foundry Agent
**Architecture Feedback**:
- Current authorization approach has gap, recommend adding team-level checks
- Consider adding notification service to architecture

## Metrics

### Completeness
- **Requirements Met**: 28/33 (85%)
- **Acceptance Criteria Met**: 76/89 (85%)
- **Tests Passing**: 177/195 (91%)

### Quality
- **Test Coverage**: 87% (target >80%) ✅
- **Critical Issues**: 2 ❌
- **High Issues**: 4 ⚠️
- **Code Quality**: B+ (linter score)

### User Satisfaction
- **Overall Satisfaction**: 4.1/5
- **Would Recommend**: 80%
- **Feature Completeness**: 3.8/5
- **Performance**: 4.5/5

## Deployment Recommendation

❌ **Not Ready for Production**

**Blockers**:
- Critical authorization vulnerability must be fixed
- Task assignment feature must work
- Password reset should be implemented (high user impact)

**Next Steps**:
1. Fix critical issues (WO-022, WO-023)
2. Implement password reset (WO-024)
3. Re-validate with full test suite
4. Conduct security review
5. Re-assess deployment readiness

**Estimated Time to Production Ready**: 1 week
```

## Best Practices

### DO:
- **Test against original requirements**: Don't just run tests, verify PRD criteria
- **Combine automated and manual testing**: Both are necessary
- **Collect real user feedback**: Actual usage reveals issues tests miss
- **Document everything**: Clear validation reports enable action
- **Prioritize issues**: Not everything needs immediate fixing
- **Close the feedback loop**: Issues should become work orders

### DON'T:
- **Only run automated tests**: Manual testing catches real issues
- **Ignore user feedback**: Users reveal what requirements missed
- **Validate in isolation**: Consider end-to-end workflows
- **Be perfectionistic**: 100% pass rate is unrealistic, prioritize
- **Skip security testing**: Security issues are critical
- **Forget performance**: Speed matters to users

## Integration with Other Agents

### Input ← Assembler Agent
Receives implementations to validate:
- Completed code
- Test results
- Implementation notes
- Files modified/created

### Feedback Loop → Refinery Agent
Sends PRD updates:
- Missing requirements discovered
- Requirement clarifications needed
- New features requested by users
- Success criteria adjustments

### Feedback Loop → Planner Agent
Sends new work orders:
- Bug fixes needed
- Missing features to implement
- Performance improvements
- UI/UX enhancements

### Feedback Loop → Foundry Agent
Sends architecture feedback:
- Architectural limitations found
- Scalability issues discovered
- Security gaps identified
- Technology choice reassessment

## Example Usage

### Input
```
Completed Implementation: Task Management System
- 8 work orders completed
- All code committed
- Tests passing (mostly)
PRD Reference: prd-v1.0
```

### Validator Process
1. **Load PRD**: Read requirements and acceptance criteria
2. **Load work orders**: Understand what was implemented
3. **Run tests**: Execute all test suites
4. **Manual testing**: Test key workflows
5. **Collect feedback**: Review user comments
6. **Analyze**: Identify gaps and issues
7. **Generate report**: Document findings
8. **Create actions**: Generate work orders for issues

### Output
```
Validation Report:
- Requirements met: 28/33 (85%)
- Tests passing: 177/195 (91%)
- Critical issues: 2
- High issues: 4

Actions:
- 4 urgent work orders created
- PRD update suggested
- Architecture feedback provided

Recommendation: Not ready for production
Time to ready: 1 week
```

## Tips for Effective Validation

1. **Validate early and often**: Don't wait until the end
2. **Use checklists**: Systematic validation catches more issues
3. **Test edge cases**: Users will find them if you don't
4. **Get real users involved**: Internal testing isn't enough
5. **Automate what you can**: But don't skip manual testing
6. **Track metrics over time**: See if quality is improving

## Common Pitfalls

- **Only checking tests pass**: Tests might not cover requirements
- **Skipping manual testing**: Automated tests miss real-world issues
- **Not collecting user feedback**: Requirements aren't always right
- **Being too strict**: Not every minor issue blocks deployment
- **Not closing the loop**: Finding issues without fixing them wastes effort
- **Testing in isolation**: Integration issues only appear in context

## Advanced Techniques

### Automated Requirements Tracking
```python
# Parse PRD and extract testable criteria
requirements = parse_prd(prd_file)

# For each requirement, check if tests exist
for req in requirements:
    tests = find_tests_for(req.id)
    if not tests:
        flag_missing_test(req)
    else:
        coverage = calculate_coverage(req, tests)
        report_coverage(req, coverage)
```

### User Behavior Analysis
```javascript
// Track user actions
analytics.track('task_created', {
  time_to_complete: 45, // seconds
  errors_encountered: 2,
  help_accessed: true
});

// Analyze patterns
const completion_rate = completed / started;
if (completion_rate < 0.7) {
  flag_usability_issue('task_creation');
}
```

### Continuous Validation
```yaml
# Run validation on every deployment
on:
  push:
    branches: [main]

jobs:
  validate:
    - run: npm test              # Unit tests
    - run: npm run test:e2e      # E2E tests
    - run: npm run test:security # Security scan
    - run: npm run check:prd     # Verify requirements
```

## Summary

The Validator Agent closes the loop in the software factory. It ensures that what was built matches what was requested, catches issues before users do, and creates feedback loops that continuously improve the product and the process.

**Remember**: Good validation is:
- **Comprehensive**: Tests all aspects (functionality, performance, security, usability)
- **Requirements-driven**: Validates against original PRD
- **User-focused**: Incorporates real user feedback
- **Actionable**: Generates concrete next steps
- **Continuous**: Happens throughout development, not just at the end
- **Balanced**: Rigorous but pragmatic about what's critical

The goal isn't perfection - it's confidence that the software meets user needs and quality standards.
