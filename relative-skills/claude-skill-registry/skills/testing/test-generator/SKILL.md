---
name: test-generator
description: Universal test generation skill that works with any language or framework. Detects project conventions, generates unit/integration/API/validation tests, and evolves through learning. Use when user asks to "write tests", "create tests", "generate tests", "add test coverage", "test this function/class/component", or any testing-related request. Supports JavaScript, TypeScript, Python, PHP, Go, Java, Ruby, Rust, C#, and more.
---

# Test Generator

A self-evolving testing skill that learns from your project and improves with every interaction.

## Core Workflow

```
┌─────────────────────────────────────────────────────────────┐
│  1. INITIALIZE     First invocation on a project           │
│     └─► Detect language/framework                          │
│     └─► Assess existing tests quality                      │
│     └─► Extract ecosystem reference                        │
│     └─► Create .claude/testing/context.yaml                │
├─────────────────────────────────────────────────────────────┤
│  2. GENERATE       When user requests tests                │
│     └─► Read context.yaml + refs/[language].md             │
│     └─► Analyze target code                                │
│     └─► Determine test type (unit/integration/API/etc)     │
│     └─► Generate tests matching project conventions        │
├─────────────────────────────────────────────────────────────┤
│  3. LEARN          After every generation                  │
│     └─► Track generated tests (hash for diff detection)    │
│     └─► On next invocation: check for modifications        │
│     └─► Extract learnings from outcomes                    │
│     └─► Update context.yaml and refs/                      │
├─────────────────────────────────────────────────────────────┤
│  4. CONSOLIDATE    When learnings exceed threshold         │
│     └─► Merge similar learnings                            │
│     └─► Promote patterns to refs/[language].md             │
│     └─► Prune low-confidence stale entries                 │
└─────────────────────────────────────────────────────────────┘
```

## Phase 1: Initialization

On FIRST test-related request for a project, initialize the testing context.

### Step 1.1: Detect Project Stack

Search for manifest files in priority order:

| File | Language/Framework |
|------|-------------------|
| `package.json` | JavaScript/TypeScript (check for `typescript` dep) |
| `tsconfig.json` | TypeScript |
| `pyproject.toml`, `requirements.txt`, `setup.py` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml`, `build.gradle` | Java |
| `composer.json` | PHP |
| `Gemfile` | Ruby |
| `*.csproj`, `*.sln` | C#/.NET |

Detect test framework from dependencies and config files:
- `jest.config.*` → Jest
- `vitest` in deps → Vitest
- `pytest` in deps → pytest
- `phpunit` in deps → PHPUnit
- Built-in `testing` package → Go
- `@SpringBootTest` annotations → Spring Boot Test

### Step 1.2: Assess Existing Tests Quality

If tests exist, evaluate quality (DO NOT skip this):

```
QUALITY SIGNALS TO CHECK:

Structure:
  ✓ Clear AAA pattern (Arrange-Act-Assert)?
  ✓ Logical test grouping (describe/context blocks)?
  
Assertions:
  ✓ Meaningful assertions (not just .toBeTruthy())?
  ✓ Testing outcomes, not implementation?
  
Naming:
  ✓ Descriptive names ("should return error when email invalid")?
  ✓ Consistent naming convention?
  
Coverage:
  ✓ Edge cases tested?
  ✓ Error paths tested?
  ✓ Not just happy path?
  
Mocking:
  ✓ Appropriate mock level (not over-mocked)?
  ✓ Mocks verify behavior, not just return values?
```

Assign quality tier:
- **high**: Most signals positive → Learn fully from existing tests
- **mixed**: Some good, some bad → Learn selectively (structure yes, assertions from best practices)
- **low**: Most signals negative → Use best practices, ignore existing patterns
- **none**: No tests exist → Use best practices entirely

### Step 1.3: Extract Ecosystem Reference

Based on detected language(s), read from `ecosystems/[language].md` and create project-specific `refs/[language].md`:

```bash
# Skill reads:
ecosystems/typescript.md  # Source of truth

# Skill creates in project:
.claude/testing/refs/typescript.md  # Project-specific copy that will grow
```

The project refs file starts with ecosystem best practices, then grows with project-specific learnings.

### Step 1.4: Create Context File

Create `.claude/testing/context.yaml`:

```yaml
v: 1
updated: [timestamp]

project:
  languages: [detected languages]
  framework: [primary framework or null]
  pkg_manager: [npm|yarn|pip|composer|go|cargo]
  monorepo: [true|false]

assessment:
  existing_tests: [count]
  quality_tier: [high|mixed|low|none]
  strategy: [full|selective|best-practices]
  notes: |
    [Brief explanation of assessment]

conventions:
  test_cmd: "[command to run tests]"
  coverage_cmd: "[command for coverage]"

learnings: []

pending: []

meta:
  tests_generated: 0
  success_rate: 0
  last_consolidation: null
  project_hash: "[hash of manifest files]"
```

## Phase 2: Test Generation

### Step 2.1: Read Context

Before generating ANY test:

1. Read `.claude/testing/context.yaml`
2. Read relevant `refs/[language].md`
3. Check `pending` for previous generations needing feedback
4. Check for drift (project changes since last run)

### Step 2.2: Check Pending Feedback

If `pending` contains entries from previous generation:

```yaml
pending:
  - file: src/services/Auth.test.ts
    hash: "abc123"
    generated: 2025-01-15
```

Check if the file was modified:
1. Read current file content
2. Compare hash
3. If different → USER MODIFIED → Extract learning with HIGH confidence
4. If same → Ask user: "How did those tests work out?"

### Step 2.3: Analyze Target Code

For the code to be tested, identify:

- **Testability indicators**: Pure function? Side effects? Dependencies?
- **Complexity**: Simple utility or complex business logic?
- **Type of code**: Component, service, utility, API endpoint, validation?

### Step 2.4: Determine Test Type

See `references/test-types.md` for detailed guidance. Quick reference:

| Code Type | Recommended Test Type |
|-----------|----------------------|
| Pure functions, utilities | Unit tests |
| Components with state | Component/Integration tests |
| API endpoints | API/Contract tests |
| Form validation | Validation tests (boundary values) |
| Database operations | Integration tests |
| Critical user flows | E2E tests (use sparingly) |

### Step 2.5: Generate Tests

Follow patterns from:
1. `refs/[language].md` (project-specific, highest priority)
2. `context.yaml` learnings
3. Best practices from ecosystem knowledge

**Critical rules:**
- Match existing assertion style (expect vs assert)
- Match existing test structure (describe/it vs test functions)
- Use project helpers if discovered
- Follow project file naming convention
- Place tests in correct location (colocated vs separate)

### Step 2.6: Track Generation

After generating, update `pending` in context.yaml:

```yaml
pending:
  - file: [path to generated test file]
    hash: "[md5/sha of content]"
    generated: [timestamp]
```

## Phase 3: Learning Protocol

### Confidence Levels

| Level | Source | Meaning |
|-------|--------|---------|
| **high** | user-modified, user-feedback | User explicitly corrected or confirmed |
| **medium** | test-failed, existing-high-quality | Clear signal from test run or good existing tests |
| **low** | test-passed, inferred | Weak signal (passing ≠ correct) |

### Learning Extraction

After observing outcome, ask: *"What pattern here is worth remembering?"*

**Good learnings:**
- Specific to this project (not general knowledge)
- Actionable (tells future-Claude what to DO)
- Concise (<100 characters)

**Bad learnings:**
- Generic ("write good tests")
- Too specific ("line 47 needed comma")
- Duplicates existing learning

### Update Context

Add to `learnings` in context.yaml:

```yaml
learnings:
  - p: "[pattern description]"
    c: [high|med|low]           # confidence
    t: [correction|preference|discovery|pitfall]
    s: [user-modified|user-feedback|test-failed|test-passed|inferred]
    d: [date]
    lang: [language this applies to]
```

### Update Refs

If learning is language-specific and high confidence, also add to `refs/[language].md` under "Project-Specific Patterns" section.

## Phase 4: Consolidation

Triggered when `learnings` count > 15 OR manually requested.

### Step 4.1: Merge Similar

Find learnings expressing the same concept:
- "Mock API in beforeEach" + "Set up API mocks before tests" → Keep one

### Step 4.2: Resolve Conflicts

If learnings contradict:
- Keep higher confidence
- Keep more recent
- If tied, prefer user-modified source

### Step 4.3: Promote to Refs

If a pattern appears 3+ times with at least 1 high-confidence:
- Add to `refs/[language].md` as permanent convention
- Remove from learnings (now in refs)

### Step 4.4: Prune

Remove learnings that are:
- Low confidence AND > 30 days old
- Contradicted by higher-confidence learning
- Too specific to reuse

## Self-Healing

The skill self-corrects without manual reset:

### Drift Detection
On each invocation, hash manifest files. If changed:
- Re-detect project stack
- Update `project` section
- Keep learnings (may still apply)

### Quality Reassessment
If `success_rate` drops below 0.5:
- Re-assess existing tests quality
- Adjust `strategy` accordingly

### Language Addition
If new language detected (e.g., Python added to JS project):
- Add to `project.languages`
- Extract new `refs/[language].md`
- Continue with existing learnings

## File Locations

### Skill Resources (read-only)
```
ecosystems/         # Language best practices (source of truth)
references/         # Test type guidance
```

### Project Files (created by skill)
```
.claude/testing/
├── context.yaml    # Config + learnings + meta
└── refs/           # Project-specific language refs
    └── [lang].md   # Grows with learnings
```

## Quick Reference: Test Generation Checklist

Before generating:
- [ ] Read context.yaml
- [ ] Read refs/[language].md
- [ ] Check pending for feedback
- [ ] Identify test type needed
- [ ] Review project conventions

While generating:
- [ ] Match assertion style
- [ ] Match test structure
- [ ] Use project helpers
- [ ] Follow naming convention
- [ ] Include edge cases
- [ ] Test error paths

After generating:
- [ ] Add to pending with hash
- [ ] Suggest test command
- [ ] Note any learnings
