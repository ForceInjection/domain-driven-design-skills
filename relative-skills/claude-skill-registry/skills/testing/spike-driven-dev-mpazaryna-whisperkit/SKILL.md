---
name: spike-driven-dev
description: Guide for spike-driven development methodology. Use when starting new features, testing architecture patterns, integrating unfamiliar APIs/data sources, or validating technical feasibility before full implementation. Emphasizes TDD, real data validation, and risk reduction through minimal proofs-of-concept.
---

# Spike-Driven Development

## The Railroad Spike Principle

When building a railroad, the **first spike** establishes direction, validates the foundation, proves feasibility, and defines the repeatable pattern. In software, a spike ticket serves the same purpose: prove the approach works with ONE component before building everything.

**Before building anything complex**:
1. Drive one spike (build one minimal component with TDD)
2. Make sure it holds (test with real data, verify architecture)
3. Then build the railroad (replicate pattern across full feature)

## When to Use This Skill

Create a spike ticket when:
- Starting a new feature with unfamiliar patterns
- Integrating with external APIs or data sources
- Testing architecture assumptions (e.g., model designs, framework capabilities)
- Building something for the first time
- The main ticket has >10 subtasks

**For detailed decision criteria**, see [decision-criteria.md](references/decision-criteria.md)

## Spike Workflow

### 1. Identify the Spike Need (15 minutes)

Ask these questions about the upcoming work:
- Have I built this exact thing before?
- Am I making assumptions about data structures or APIs?
- Could failure require redesigning multiple components?
- Is the main ticket complex with many subtasks?

If YES to any → Create a spike ticket first.

### 2. Define Spike Scope (30 minutes)

**Keep it minimal**:
- Time-boxed: 4-8 hours maximum
- Scope-limited: ONE file, ONE component, ONE feature
- Test-driven: Write tests FIRST
- Real data: Use production-like data, not mocks
- Platform-tested: Verify on all targets (macOS + iOS)

**Example scopes**:
- "Test SwiftData model with nested Codable + real JSON"
- "Implement ONE API endpoint with authentication"
- "Build ONE detail view with platform config pattern"

### 3. Execute with TDD (4-6 hours)

**Follow this sequence strictly**:

**Step 1: Write Tests FIRST (1 hour)**
```swift
func testModelCreation() { /* ... */ }
func testJSONDecoding() { /* ... */ }
func testRealDataLoading() { /* ... */ }
```
Run tests → ❌ FAIL (expected - code doesn't exist)

**Step 2: Implement Minimal Code (1-2 hours)**
- Write minimum code to pass tests
- Focus on architecture, not features
Run tests → ✅ PASS

**Step 3: Test with Real Data (1 hour)**
- Load actual production/external data
- Test edge cases
- Verify platform compatibility

**Step 4: Document Findings (1 hour)**
- Note what worked / what didn't
- Document pattern for replication
- Update main ticket estimate if needed

**For detailed TDD flow**, see [spike-patterns.md](references/spike-patterns.md)

### 4. Evaluate Outcome

**Success**: Tests pass, architecture validated
→ Close spike, proceed with main ticket using proven pattern

**Partial Success**: Tests pass but adjustments needed
→ Document findings, adjust main ticket, possibly create follow-up spike

**Failure**: Tests fail, approach flawed
→ Research alternatives, create new spike with different approach

**All outcomes are wins** - better to discover issues in 6 hours than 6 days.

### 5. Apply to Main Feature

Use the validated pattern to build the full feature with confidence:
- Replicate the proven model/view structure
- Use the same testing approach
- Apply lessons learned from spike
- Build 4-5x faster with validated architecture

## Success Criteria Checklist

Every spike should validate:
- [ ] Tests pass with real data
- [ ] Architecture assumptions proven
- [ ] Platform compatibility verified
- [ ] Pattern documented for replication
- [ ] No technical blockers discovered
- [ ] Effort estimate confirmed/adjusted

## Common Pitfalls to Avoid

❌ **Starting without a spike** when using new patterns
❌ **Skipping tests** - defeats the purpose of validation
❌ **Using mock data only** - doesn't catch real-world issues
❌ **Scope creep** - building more than ONE component
❌ **Fear of throwing away code** - spikes are proofs, not production
❌ **Open-ended exploration** - must have clear success criteria

## Examples and Templates

**For concrete examples** (exercise library, API integration, database migration):
→ See [examples.md](references/examples.md)

**For decision trees and risk analysis**:
→ See [decision-criteria.md](references/decision-criteria.md)

**For spike characteristics and TDD patterns**:
→ See [spike-patterns.md](references/spike-patterns.md)

## Key Takeaways

1. **Never skip spikes for unfamiliar territory** - architectural failures are expensive
2. **Write tests FIRST** - tests guide implementation and ensure testability
3. **Use real data immediately** - mock data hides real-world issues
4. **Time-box strictly** - spikes prove feasibility, not perfection
5. **Document findings** - the pattern must be replicable for the main ticket

**The time spent on a spike is time saved (10x) on the main feature.**
