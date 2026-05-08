---
name: quality-engineering
description: Use when designing test strategies, implementing test automation, or optimizing performance
---

# Quality Engineering

Guidelines for QA processes, test automation, and performance engineering.

## When to Use

- Designing test strategies for new features
- Setting up or improving test automation
- Performance testing and optimization
- Capacity planning and load testing
- Establishing quality metrics

## Quality Philosophy

- **Prevention over detection** - Engage early to prevent defects
- **Test behavior, not implementation** - Focus on observable outcomes
- **No failing builds** - Never merge broken code
- **Continuous improvement** - Regularly refine processes

## Test Strategy

### Test Pyramid
```
       /\
      /E2E\      ← Few, critical paths
     /------\
    /  Integ  \   ← Moderate, key integrations
   /------------\
  /    Unit      \ ← Many, fast, isolated
```

### Coverage Targets
- Unit tests: > 80% line coverage
- Integration: Key API paths covered
- E2E: Critical user journeys

## Test Design Patterns

### Arrange-Act-Assert (AAA)
```
// Arrange: Setup preconditions
const user = createTestUser();

// Act: Execute behavior
const result = await login(user);

// Assert: Verify outcome
expect(result.success).toBe(true);
```

### Test Characteristics
- **Isolated**: No shared state between tests
- **Deterministic**: Same result every run
- **Fast**: Quick feedback loop
- **Readable**: Self-documenting names

## Definition of Done

Feature is complete when:
- [ ] All tests passing (unit, integration, E2E)
- [ ] Code meets style guides
- [ ] No console errors or unhandled exceptions
- [ ] API changes documented
- [ ] Performance budgets met

## Performance Engineering

### Systematic Approach
1. **Baseline**: Measure before optimizing
2. **Identify**: Profile to find bottlenecks
3. **Budget**: Set clear SLOs
4. **Optimize**: Implement improvements
5. **Validate**: Measure impact
6. **Monitor**: Continuous production tracking

### Key Metrics

| Layer | Metrics |
|-------|---------|
| Frontend | LCP, INP, CLS, TTFB |
| API | Response time, throughput, error rate |
| Database | Query time, connections, locks |
| Infrastructure | CPU, memory, I/O, network |

### Performance Checklist
- [ ] Established performance baselines
- [ ] Load testing simulates realistic traffic
- [ ] Database queries optimized
- [ ] Caching strategy implemented
- [ ] CDN configured for static assets
- [ ] Monitoring dashboards in place
- [ ] Alerting on SLO breaches

## Test Automation

### Framework Selection

| Type | Recommended Tools |
|------|-------------------|
| Unit | Jest, Pytest, JUnit |
| Integration | Testcontainers, SuperTest |
| E2E | Playwright, Cypress |
| Load | k6, Locust, Gatling |
| Coverage | Istanbul, JaCoCo |

### CI/CD Integration
```yaml
# Pipeline stages
stages:
  - lint      # Fast feedback
  - unit      # Parallel execution
  - build     # Artifact creation
  - integration  # Service testing
  - e2e       # Critical paths
  - performance  # Load testing (optional)
```

### Test Data Management
- Use factories/fixtures for consistent data
- Isolate test data from production
- Clean up after tests
- Consider data masking for sensitive info

## Quality Metrics

| Metric | Target | Purpose |
|--------|--------|---------|
| Test Coverage | > 80% | Code confidence |
| Test Pass Rate | > 98% | Stability |
| Flaky Test Rate | < 2% | Reliability |
| Build Time | < 10 min | Fast feedback |
| MTTR | < 1 hour | Recovery speed |

## Deliverables

- **Test Strategy Document**: Scope, objectives, methodology
- **Test Cases**: Step-by-step with expected results
- **Automated Test Suite**: Maintainable, organized tests
- **CI Pipeline Config**: Automated quality gates
- **Coverage Reports**: Visibility into tested code
- **Performance Dashboards**: Real-time metrics
- **Bug Reports**: Clear reproduction steps, severity

## Anti-Patterns to Avoid

- Testing implementation details instead of behavior
- Flaky tests that pass/fail randomly
- Slow test suites blocking development
- Missing edge case coverage
- Manual-only regression testing
- No performance testing until production issues
