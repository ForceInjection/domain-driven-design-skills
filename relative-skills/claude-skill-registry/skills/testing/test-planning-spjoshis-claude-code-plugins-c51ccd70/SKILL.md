---
name: test-planning
description: Master test planning with test strategies, test plans, scope definition, and comprehensive testing approaches.
---

# Test Planning

Create comprehensive test plans and strategies that ensure thorough quality coverage and efficient testing execution.

## When to Use This Skill

- Project initiation
- Release planning
- Defining test scope
- Resource allocation
- Risk assessment
- Quality gate definition
- Test environment planning
- Estimating testing effort

## Core Concepts

### 1. Test Plan Template

```markdown
# Test Plan: E-Commerce Checkout

## 1. Introduction
**Purpose**: Validate checkout functionality for v2.0 release
**Scope**: Payment processing, order creation, email confirmation

## 2. Test Items
- Checkout flow (guest and registered users)
- Payment gateway integration
- Order management system
- Email notification service

## 3. Features to Test
- Add to cart
- Apply coupon codes
- Calculate shipping
- Process payment
- Create order
- Send confirmation email

## 4. Features NOT to Test
- Product catalog (tested separately)
- User registration (existing feature)

## 5. Test Approach
- **Functional Testing**: Manual + automated
- **Integration Testing**: Payment gateway, email service
- **Security Testing**: PCI compliance, data encryption
- **Performance Testing**: 100 concurrent checkouts
- **Usability Testing**: 5 user sessions

## 6. Entry/Exit Criteria
**Entry**:
- Code complete and deployed to test environment
- Test data prepared
- Test environment stable

**Exit**:
- 100% P0/P1 test cases executed
- 0 critical bugs
- <5 medium bugs
- Performance benchmarks met

## 7. Test Deliverables
- Test cases (150 cases)
- Test execution reports
- Defect reports
- Test summary report

## 8. Environment
- Test: test.example.com
- Staging: staging.example.com
- Test payment gateway: Stripe test mode

## 9. Schedule
- Test prep: Week 1
- Execution: Weeks 2-3
- Regression: Week 4
- Sign-off: End of Week 4

## 10. Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| Payment gateway downtime | High | Use test mode, backup plan |
| Environment instability | Med | Daily smoke tests |
| Resource availability | Med | Cross-training |
```

## Best Practices

1. **Align with requirements** - Trace to specs
2. **Risk-based approach** - Prioritize critical areas
3. **Clear scope** - What's in, what's out
4. **Realistic estimates** - Based on complexity
5. **Define metrics** - Coverage, defect density
6. **Entry/exit criteria** - Clear quality gates
7. **Stakeholder review** - Get approval
8. **Living document** - Update as needed

## Resources

- **IEEE 829**: Test plan standard
- **ISTQB**: Test planning guidelines
