---
name: rspec-testing
description: Write and update RSpec tests following BDD principles with behavior-first approach, characteristic-based context hierarchy, and happy path priority. **Activate when:** user mentions RSpec/specs/testing, works with *_spec.rb files, asks to write/add/update/fix tests, or requests test coverage. Ensures tests describe observable behavior, not implementation details.
---

# RSpec Testing Skill

## When to Use This Skill

Use this skill when you need to:
- Create new test files for classes or modules
- Add test coverage for new methods or behaviors
- Update existing tests when adding features or fixing bugs
- Refactor tests to improve clarity or remove duplication
- Fix failing tests after code changes

## When NOT to Use This Skill

Skip this skill for:

**Non-RSpec Frameworks:**
- Minitest, Test::Unit (different syntax and patterns)
- JavaScript testing (Jest, Mocha, Jasmine, Vitest)
- Other language frameworks (pytest, JUnit, etc.)

**Different Test Types:**
- System/E2E tests with Capybara (requires different patterns, more integration-focused)
- Performance/benchmark testing (use `benchmark-ips`, `memory_profiler`)
- Load testing (use Apache Bench, JMeter, k6)

**API Contract Testing:**
- JSON Schema validation — use specialized tools (JSON Schema validators, OpenAPI tools)
- OpenAPI spec generation — use `rspec-openapi` or `rswag`
- Snapshot testing — use dedicated snapshot testing tools

**Quick Exploratory Work:**
- Console/IRB experimentation
- One-off manual verification
- Debugging sessions

**Complementary Skills:**
- For API contracts → Use JSON Schema/OpenAPI tools
- For Rails-specific patterns → May need Rails testing skill
- For complex test doubles → May need mocking/stubbing skill

## Core Principles

1. **Test behavior, not implementation** — Verify observable outcomes (return values, state changes, side effects), never internal method calls or instance variables
2. **One example, one behavior** — Each `it` tests a single observable rule
3. **Characteristic-based contexts** — Organize by conditions affecting behavior (user role, state, input type)
4. **Happy path first** — Write successful scenarios before edge cases and errors
5. **Clear descriptions** — `describe` + `context` + `it` form readable English sentences

## All 28 Rules at a Glance

This guide contains 28 rules total. The 15 most critical rules are detailed below; the rest are available in [REFERENCE.md](REFERENCE.md#additional-rules).

**Behavior and Test Structure:**
1. Test behavior, not implementation — Check observable outcomes, not internal calls
2. Verify what test tests — Break code to ensure test fails (Red-Green-Refactor)
3. One `it` — one behavior — Each test describes one business rule
4. Identify characteristics — Map conditions affecting behavior (role, state, input type)
5. Hierarchy by dependencies — One characteristic per context level
6. Final context audit — Merge duplicate setup, extract identical assertions
7. Happy path before corner cases — Successful scenarios first, then edge cases
8. Positive and negative tests — Check both success and failure
9. Context differences — Each context has unique setup

**Syntax and Readability:**
10. Specify `subject` — Use named subject for clarity
11. Three test phases — Given (let), When (before/action), Then (expect)

**Context and Data Preparation:**
12. Use FactoryBot — Hide unimportant data in factories, use traits for states
13. `attributes_for` for parameters — Generate parameter hashes for API/service calls
14. `build_stubbed` in units — Unit tests use `build_stubbed`, integration tests use `create`
15. Don't program in tests — No loops, conditionals, or complex logic
16. Explicitness over DRY — Clarity > reducing duplication

**Specification Language:**
17. Valid sentence — `describe` + `context` + `it` form grammatically correct English
18. Understandable to anyone — Use business language, not technical jargon
19. Grammar — `describe` (noun), `context` (when/with), `it` (verb in 3rd person)
20. Context language — Use when/with/and/without/but/NOT keywords

**Tools and Support:**
21. Enforce naming with linter — Run RuboCop/Standard to check conventions
22. Don't use `any_instance` — Use dependency injection instead
23. `:aggregate_failures` only for interfaces — One behavior = one `it`
24. Verifying doubles — Use `instance_double`, not `double`
25. Shared examples for contracts — Extract repeating contract checks
26. Request specs over controller specs — Controller specs are deprecated
27. Stabilize time — Use `freeze_time`/`travel_to` + `travel_back`
28. Readable failure output — Use structural matchers, parse JSON before comparison

## Critical Rules (Detailed)

**Freedom Levels:**
- 🔴 **MUST** — Mandatory for new code, violation causes serious issues (fragile tests, coupling, design smells)
  - *Legacy exception: Existing tests can remain as-is if refactoring cost is too high*
- 🟡 **SHOULD** — Strongly recommended, preferred pattern with acceptable variations

### Behavior and Test Structure

**Rule 1: Test behavior, not implementation** 🔴 MUST
- Check observable results: return values, HTTP responses, database state changes, side effects (emails, jobs)
- NEVER check: internal method calls with `receive`, private methods, instance variables
- If test needs `allow(...).to receive` for setup (not verification), that's acceptable

```ruby
# ❌ BAD: Testing implementation
expect(service).to receive(:send_email)
service.process

# ✅ GOOD: Testing behavior
expect { service.process }.to have_enqueued_mail(WelcomeMailer)
```

**Rule 2: Verify what test actually tests** 🔴 MUST
- After writing test, break the code intentionally (return wrong value, comment out logic, change condition)
- Test must fail (Red). If stays green, rewrite it
- This ensures test checks real behavior, not implementation accidents

**Rule 3: One `it` — one behavior** 🟡 SHOULD
- Each `it` describes one business rule with unique description
- Multiple independent side effects = separate `it` blocks
- Exception: interface testing (Rule 23) — use `:aggregate_failures` for related attributes of one object

```ruby
# ❌ BAD: Multiple independent behaviors
it 'processes signup' do
  expect { signup }.to change(User, :count).by(1)
  expect { signup }.to have_enqueued_mail
end

# ✅ GOOD: Separate tests
it('creates user') { expect { signup }.to change(User, :count).by(1) }
it('sends email') { expect { signup }.to have_enqueued_mail }
```

**Rule 4: Identify characteristics** 🔴 MUST
- Characteristic = condition affecting behavior (user role, payment method, order status, input validity)
- List all characteristics, then list states for each (role: admin/customer; validity: valid/invalid)
- Each characteristic state = separate `context`

**Rule 6: Final context audit** 🟡 SHOULD
- Check for duplicate `let`/`before` across sibling contexts → merge common setup to parent
- Check for identical `it` in all leaf contexts → extract to `shared_examples` (Rule 25)

**Rule 7: Happy path before corner cases** 🔴 MUST
- First context = successful scenario (authenticated user, valid input, sufficient balance)
- Then corner cases (unauthenticated, invalid, insufficient)
- Reader sees main scenario first, then exceptions

```ruby
# ❌ BAD: Edge case first
context 'when balance is insufficient' do
  it 'rejects purchase'
end
context 'when balance is sufficient' do  # Happy path buried!
  it 'processes purchase'
end

# ✅ GOOD: Happy path first
context 'when balance is sufficient' do  # Happy path first
  it 'processes purchase'
end
context 'when balance is insufficient' do
  it 'rejects purchase'
end
```

**Rule 9: Context differences** 🟡 SHOULD
- Each nested `context` must have its own setup (`let`, `before`, `subject`)
- Setup should be immediately under context declaration, not far away
- Context description must clearly reflect what distinguishes it from parent

### Syntax and Readability

**Rule 11: Three test phases** 🔴 MUST
- Phase 1 (Given): Data preparation via `let` or factories
- Phase 2 (When): Action via `before` or explicit call in `it`
- Phase 3 (Then): Verification via `expect`
- NEVER mix phases (no data preparation + action + verification in one `before`)

```ruby
# ❌ BAD: Phases mixed in before
before do
  user = create(:user)      # Given
  admin = create(:admin)    # Given
  admin.block(user)         # When - ACTION!
end

# ✅ GOOD: Clear three phases
# Phase 1: Given
let(:user) { create(:user) }
let(:admin) { create(:admin) }

# Phase 2: When
before { admin.block(user) }

# Phase 3: Then
it('marks user as blocked') { expect(user.reload).to be_blocked }
```

**Common anti-patterns:**
- Mixing phases in `before` — see example above
- Mixing phases in `it` — see [REFERENCE.md Pitfall 5](REFERENCE.md#pitfall-5-mixing-phases-in-it)
- For step-by-step refactoring, see [REFERENCE.md Refactoring Patterns](REFERENCE.md#refactoring-patterns)

### Context and Data Preparation

**Rule 13: `attributes_for` for parameters** 🟡 SHOULD
- Use `attributes_for(:model)` when generating parameter hashes (API requests, form objects, service calls)
- Override only critical attributes: `attributes_for(:order, segment: 'b2b')`
- DO NOT use when API interface differs from model attributes

**Rule 14: `build_stubbed` in units** 🟡 SHOULD
- Unit tests (except models): prefer `build_stubbed` (fastest, no DB)
- Integration tests: use `create` (DB interactions needed)
- Decision tree: model test → `create`; service/PORO test → `build_stubbed`

### Specification Language

**Rule 19: Grammar** 🟡 SHOULD
- `describe`: noun or method name (`describe OrderProcessor`, `describe '#calculate'`)
- `context`: use "when/with/and/without/but" + state description
- `it`: verb in 3rd person, present simple tense
  - Action verbs for behavior: `it 'creates order'`, `it 'sends email'`
  - State verbs for resulting state: `it 'has parent'`, `it 'is valid'`, `it 'belongs to user'`
- Avoid "should", "can", "must" — just state behavior directly

**Rule 20: Context language: when / with / and / without / but / NOT** 🔴 MUST

Use specific keywords to structure context hierarchy (follows Gherkin logic):

- **`when`** — Opens branch with base characteristic: `context 'when user has card'`
- **`with`** — Adds positive state (happy path): `context 'with verified email'`
- **`and`** — Continues happy path: `context 'and balance covers price'`
- **`without` / `but`** — Introduces corner cases: `context 'but balance is insufficient'`
- **`NOT`** (in CAPS) — Emphasizes negative state: `context 'when user does NOT have card'`

**Sequence:** `when` → `with` → `and` → `but`/`without` → `it`

**Example:**
```ruby
context 'when user has card' do
  context 'with verified email' do
    it 'charges the card'

    context 'but balance is insufficient' do
      it 'does NOT charge the card'
    end
  end
end
```

**For detailed examples of when/with/and/but/without/NOT patterns, see [REFERENCE.md](REFERENCE.md).**

### Tools and Support

**Rule 22: Don't use `any_instance`** 🔴 MUST
- NEVER use `allow_any_instance_of` or `expect_any_instance_of`
- Use dependency injection instead: pass collaborators as parameters
- Refactor code if it requires `any_instance` — it's a design smell

**Rule 27: Stabilize time** 🟡 SHOULD
- Use `ActiveSupport::Testing::TimeHelpers`: `freeze_time`, `travel_to`, `travel`
- ALWAYS add `after { travel_back }` when using non-block form
- Use `Time.zone.now`/`Time.current`, not `Time.now`
- In factories, use blocks for time: `created_at { 1.day.ago }`

**Rule 28: Readable failure output** 🟡 SHOULD
- Use structural matchers (`match_array`, `include`, `have_attributes`)
- NEVER compare JSON as strings — parse first, then use structural expectations
- Parse complex data before comparison (`JSON.parse`, `response.parsed_body`)
- Failure output should instantly explain expected vs actual behavior

## Common Patterns

Quick reference for key patterns. For extended examples, see [REFERENCE.md Extended Examples](REFERENCE.md#extended-examples).

### Characteristic Hierarchy (Rules 4-5)

```ruby
describe '#calculate_discount' do
  context 'when segment is b2c' do              # Level 1: basic characteristic
    context 'with premium subscription' do      # Level 2: depends on segment
      it('applies 20% discount') { expect(discount).to eq(0.20) }
    end
    context 'without premium subscription' do
      it('applies 5% discount') { expect(discount).to eq(0.05) }
    end
  end
end
```

### FactoryBot Strategy (Rule 14)

```ruby
# Model test → create
let(:user) { create(:user, :premium) }

# Service/PORO unit test → build_stubbed
let(:user) { build_stubbed(:user, :premium) }

# Integration test → create
let(:user) { create(:user, :premium) }
```

## Validation Workflow Checklist

After writing or updating tests, copy this checklist and track progress:

```markdown
**Prerequisites Check:**
- [ ] In project root (Gemfile exists): `test -f Gemfile`
- [ ] Bundler installed: `gem install bundler` (if missing)
- [ ] Dependencies installed: `bundle check || bundle install`
- [ ] RSpec configured: `bundle exec rspec --version`
- [ ] Linter available: RuboCop or Standard (optional but recommended)

**Validation Steps:**
- [ ] Run linter on test file: `bundle exec rubocop spec/path/to/file_spec.rb`
- [ ] Fix all linter offenses → 0 offenses
- [ ] Run tests: `bundle exec rspec spec/path/to/file_spec.rb`
- [ ] All tests green ✅
- [ ] **Verify Red (Rule 2):** Break code intentionally (comment out logic, change condition)
- [ ] Tests fail when code broken (Red phase) ✅
- [ ] Restore code
- [ ] Tests pass again (Green phase) ✅

**Final Quality Check:**
- [ ] Test descriptions form valid English sentences
- [ ] Happy path tests come first in each context group
- [ ] Each context has unique setup (`let` or `before`)
- [ ] No programming logic in tests (loops, conditionals)
- [ ] Using `build_stubbed` in unit tests (not `create`)
```

**Important:** NEVER modify Gemfile automatically. If RSpec/linter/FactoryBot missing, ask user first.

## Quick Checklist

Before considering tests complete:

### Structure and Behavior
- [ ] Tests describe **behavior** (observable outcomes), not implementation
- [ ] Each `it` tests **one behavior** with unique description
- [ ] **Happy path comes first** in each context group
- [ ] Each context has **unique setup** (`let` or `before`)
- [ ] `subject` defined **at top level** only

### Final Context Audit (Rule 6)
- [ ] No duplicate `let`/`before` across siblings (lift to parent if found)
- [ ] No identical `it` in ALL leaves (extract to `shared_examples` if found)
- [ ] All characteristic states have corresponding contexts

### Language and Style
- [ ] Descriptions form **valid English sentences**
- [ ] Context names use **when/with/and/without/but/NOT**
- [ ] Three phases: Preparation → Action → Verification
- [ ] FactoryBot hides unimportant data details
- [ ] `build_stubbed` in unit tests (except models)
- [ ] No programming in tests (loops, conditionals, complex logic)

### Tools and Verification
- [ ] Verifying doubles (`instance_double`) not `double`
- [ ] Time stabilized (`freeze_time`/`travel_to` + `travel_back`)
- [ ] **Linter: 0 offenses**
- [ ] **All tests: green**
- [ ] **Rule 2: Tests fail when code broken**

## Decision Trees

Quick guides for common decisions. [See REFERENCE.md](REFERENCE.md#decision-trees) for detailed trees with examples.

**New file vs update?** New method in existing class → update same file. New class → new file.

**`create` vs `build_stubbed`?** Model/integration tests → `create`. Service/PORO unit tests → `build_stubbed`.

**One `it` vs `:aggregate_failures`?** Independent side effects → separate `it`. Multiple attributes of one object → `have_attributes`.

**When to extract `shared_examples`?** Multiple classes with same contract, or identical `it` in ALL leaf contexts.

## Quick Anti-Patterns Reference

Quick diagnostic for common mistakes:

| ❌ Anti-Pattern | ✅ Correct Pattern | Rule | Link |
|----------------|-------------------|------|------|
| `expect(service).to receive(:method)` | Test observable outcome (return value, DB change, enqueued job) | Rule 1 | [Details](#rule-1-test-behavior-not-implementation) |
| Multiple behaviors in one `it` | Separate `it` blocks for each behavior | Rule 3 | [Details](#rule-3-one-it--one-behavior) |
| Mix Given+When in `before` | Separate phases: `let` (Given), `before` (When) | Rule 11 | [Details](#rule-11-three-test-phases), [Pitfall 2](REFERENCE.md#pitfall-2-mixing-phases-in-before) |
| Mix phases in `it` | Keep `it` only for Then (verification) phase | Rule 11 | [Pitfall 5](REFERENCE.md#pitfall-5-mixing-phases-in-it) |
| Edge case context first | Happy path context first, then edge cases | Rule 7 | [Details](#rule-7-happy-path-before-corner-cases) |
| Context without unique setup | Add `let`/`before` to each context showing what distinguishes it | Rule 9 | [Details](#rule-9-context-differences) |
| `any_instance_of(Class)` | Dependency injection with collaborator as parameter | Rule 22 | [Details](#rule-22-dont-use-any_instance) |
| Compare JSON as strings | Parse first (`JSON.parse`, `response.parsed_body`), use structural matchers | Rule 28 | [Details](#rule-28-readable-failure-output) |
| `create` in unit tests | `build_stubbed` for unit tests (except models) | Rule 14 | [Details](#rule-14-build_stubbed-in-units) |
| Test stays green when code broken | Test behavior (observable outcomes), not implementation | Rules 1, 2 | [Troubleshooting](#problem-test-stays-green-when-code-is-broken-rule-2-violation) |

## Troubleshooting

Common problems and how to fix them. For extended examples, see [REFERENCE.md Common Pitfalls](REFERENCE.md#common-pitfalls-and-solutions).

### Problem: Test stays green when code is broken (Rule 2 violation)

**Symptoms:** Commented out code doesn't fail tests

**Cause:** Testing implementation (method calls), not behavior (observable outcomes)

**Fix:**
```ruby
# ❌ Remove this
expect(service).to receive(:send_email)

# ✅ Add this
expect { service.process }.to have_enqueued_mail(WelcomeMailer)
# OR check DB change:
expect { service.process }.to change(User, :count).by(1)
```

### Problem: Linter complains about context naming

**Symptoms:** RuboCop/Standard errors about context descriptions

**Cause:** Not using `when/with/and/without/but` keywords (Rule 20)

**Fix:**
- Identify the characteristic first (user role? input validity? feature state?)
- Name context with proper keyword:
  - `when` — opens branch with base characteristic
  - `with` — adds positive state (happy path)
  - `and` — continues happy path with more positive states
  - `without` / `but` — introduces corner cases
  - `NOT` (in CAPS) — emphasizes negative state

### Problem: Too many expectations in one `it`

**Symptoms:** Test checks multiple unrelated things

**Cause:** Mixing independent side effects (violates Rule 3)

**Fix:** Split into separate tests:
```ruby
# ❌ One test for multiple behaviors
it 'processes signup' do
  expect { signup }.to change(User, :count).by(1)
  expect { signup }.to have_enqueued_mail
  expect(response).to have_http_status(:created)
end

# ✅ Separate tests
it('creates user') { expect { signup }.to change(User, :count).by(1) }
it('sends email') { expect { signup }.to have_enqueued_mail }
it('returns success') { expect(response).to have_http_status(:created) }
```

**Exception:** Checking multiple attributes of ONE object is fine with `have_attributes`:
```ruby
it 'returns user profile' do
  expect(profile).to have_attributes(name: 'John', email: 'john@example.com')
end
```

### Problem: Don't know where to start with new test

**Solution:** Follow this sequence:

1. **Identify what to test**: Only public methods, ignore private
2. **List characteristics**: What conditions affect behavior? (user role, state, input type)
3. **Map characteristic states**: For each characteristic, list all states (role: admin/user; validity: valid/invalid)
4. **Create context hierarchy**: One characteristic = one context level, happy path first
5. **Write one test**: Start with simplest happy path case
6. **Verify by breaking code**: Comment out logic, test must fail

**See [REFERENCE.md: Writing a New Test from Scratch](REFERENCE.md#writing-a-new-test-from-scratch) for detailed walkthrough.**

### Problem: Missing gems or RSpec not configured

**Solution:**
1. Check if you're in project root: `test -f Gemfile`
2. Check if dependencies installed: `bundle check`
3. If missing, inform user: "Project needs [gem name]. Should I add it to Gemfile?"
4. **NEVER modify Gemfile automatically** — always ask user first

**For more problems, see [REFERENCE.md Common Pitfalls](REFERENCE.md#common-pitfalls-and-solutions).**

## Additional Resources

For detailed guidance, workflows, and extended examples:

- **[REFERENCE.md](REFERENCE.md)** — Detailed workflows, decision trees, extended examples, common pitfalls
  - [Writing a New Test from Scratch](REFERENCE.md#writing-a-new-test-from-scratch)
  - [Updating an Existing Test](REFERENCE.md#updating-an-existing-test)
  - [Extended Examples](REFERENCE.md#extended-examples)
  - [Decision Trees](REFERENCE.md#decision-trees) (detailed with examples)
  - [Common Pitfalls and Solutions](REFERENCE.md#common-pitfalls-and-solutions)
