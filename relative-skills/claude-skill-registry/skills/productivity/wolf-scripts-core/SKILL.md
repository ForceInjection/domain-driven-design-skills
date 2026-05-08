---
name: wolf-scripts-core
description: Core automation scripts for archetype selection, evidence validation, quality scoring, and safe bash execution
version: 1.1.0
category: automation
triggers:
  - archetype selection
  - evidence validation
  - quality scoring
  - curator rubric
  - bash validation
dependencies:
  - wolf-archetypes
  - wolf-governance
size: medium
---

# Wolf Scripts Core

Core automation patterns that power Wolf's behavioral adaptation system. These scripts represent battle-tested logic from 50+ phases of development.

## Overview

This skill captures the **essential automation patterns** that run on nearly every Wolf operation:

1. **Archetype Selection** - Automatically determine behavioral profile based on issue/PR characteristics
2. **Evidence Validation** - Validate archetype-specific evidence requirements with conflict resolution
3. **Curator Rubric** - Score issue quality using reproducible 1-10 scoring system
4. **Bash Validation** - Safe bash execution with pattern checking and GitHub CLI validation

## 🎯 Archetype Selection Pattern

### Purpose
Analyzes GitHub issues to determine the appropriate coder agent archetype based on labels, keywords, and patterns.

### Available Archetypes
```javascript
{
  'product-implementer': {
    keywords: ['feature', 'implement', 'add', 'create', 'build', 'develop', 'functionality'],
    patterns: ['user story', 'as a user', 'acceptance criteria', 'business logic']
  },
  'reliability-fixer': {
    keywords: ['bug', 'fix', 'error', 'crash', 'fail', 'broken', 'issue'],
    patterns: ['steps to reproduce', 'error message', 'stack trace', 'regression']
  },
  'security-hardener': {
    keywords: ['security', 'vulnerability', 'exploit', 'auth', 'permission', 'access'],
    patterns: ['cve', 'security scan', 'penetration', 'authentication', 'authorization']
  },
  'perf-optimizer': {
    keywords: ['performance', 'slow', 'optimize', 'speed', 'memory', 'cpu'],
    patterns: ['benchmark', 'profiling', 'latency', 'throughput', 'bottleneck']
  },
  'research-prototyper': {
    keywords: ['research', 'prototype', 'experiment', 'proof of concept', 'explore'],
    patterns: ['investigation', 'feasibility', 'spike', 'technical debt', 'architecture']
  }
}
```

### Scoring Algorithm
1. **Keyword Matching**: `score += matches.length * 2` (weight keywords highly)
2. **Pattern Matching**: `score += matches.length * 3` (weight patterns even higher)
3. **Label Matching**: Labels are included in full text search
4. **Threshold Check**: Requires minimum confidence score to select archetype
5. **Fallback**: If no archetype reaches threshold, defaults to `product-implementer`

### Usage Pattern
```javascript
// Score all archetypes
const scores = scoreArchetypes(title, body, labels);

// Find highest score
const winner = Object.entries(scores)
  .sort((a, b) => b[1] - a[1])[0];

// Confidence check
const confidence = (scores[winner[0]] / totalScore) * 100;
if (confidence < CONFIDENCE_THRESHOLD) {
  // Use fallback or request human review
}
```

### When to Use
- Starting new work items
- Issue triage and routing
- Determining agent behavioral profile
- Validating archetype assignments

**Script Location**: `/agents/shared/scripts/select-archetype.mjs`

---

## 📋 Evidence Validation Pattern

### Purpose
Validates evidence requirements from multiple sources (archetypes, lenses) with priority-based conflict resolution.

### Priority Levels
```javascript
const PRIORITY_LEVELS = {
  DEFAULT: 0,    // Basic requirements
  LENS: 1,       // Overlay lens requirements
  ARCHETYPE: 2,  // Core archetype requirements
  OVERRIDE: 3    // Explicit overrides
};
```

### Conflict Resolution Strategies
1. **Priority-Based**: Higher priority wins
2. **Merge Strategy**: Same priority → union of requirements
3. **Conflict Tracking**: All conflicts logged for audit
4. **Resolution Recording**: Documents why each resolution was made

### Schema Versions (Backward Compatibility)
- **V1 (1.0.0)**: Original format
- **V2 (2.0.0)**: Added priority field
- **V3 (3.0.0)**: Added conflict resolution

### Usage Pattern
```javascript
class EvidenceValidator {
  constructor() {
    this.requirements = new Map();
    this.conflicts = [];
    this.resolutions = [];
  }

  // Add requirements from source
  addRequirements(source, requirements, priority) {
    // Detect conflicts
    // Resolve based on priority or merge
    // Track resolution decision
  }

  // Merge two requirement values
  mergeRequirements(existing, incoming) {
    // Arrays: union
    // Objects: deep merge
    // Numbers: max
    // Booleans: logical OR
    // Strings: concatenate with separator
  }

  // Validate against requirements
  validate(evidence) {
    // Check all requirements met
    // Return validation report
  }
}
```

### When to Use
- Before creating PRs (ensure evidence collected)
- During PR review (validate evidence submitted)
- When combining archetype + lens requirements
- Resolving conflicts between requirement sources

**Script Location**: `/agents/shared/scripts/evidence-validator.mjs`

---

## 🏆 Curator Rubric Pattern

### Purpose
Reproducible 1-10 scoring system for issue quality using weighted rubric across 5 categories.

### Rubric Categories (100 points total)

#### 1. Problem Definition (25 points)
- **Problem Stated** (5pts): Clear problem statement exists
- **User Impact** (5pts): User/system impact described
- **Root Cause** (5pts): Root cause identified or investigated
- **Constraints** (5pts): Constraints and limitations noted
- **Success Metrics** (5pts): Success criteria measurable

#### 2. Acceptance Criteria (25 points)
- **Testable** (8pts): AC is specific and testable
- **Complete** (7pts): Covers happy and edge cases
- **Prioritized** (5pts): Must/should/nice clearly separated
- **Given/When/Then** (5pts): Uses Given/When/Then format

#### 3. Technical Completeness (20 points)
- **Dependencies** (5pts): Dependencies identified
- **Risks** (5pts): Technical risks assessed
- **Architecture** (5pts): Architecture approach defined
- **Performance** (5pts): Performance considerations noted

#### 4. Documentation Quality (15 points)
- **Context** (5pts): Sufficient context provided
- **References** (5pts): Links to related issues/docs
- **Examples** (5pts): Examples or mockups included

#### 5. Process Compliance (15 points)
- **Labels** (5pts): Appropriate labels applied
- **Estimates** (5pts): Effort estimated (S/M/L/XL)
- **Priority** (5pts): Priority clearly indicated

### Score Conversion (100 → 10 scale)
```javascript
function convertTo10Scale(rawScore) {
  return Math.round(rawScore / 10);
}

// Score ranges:
// 90-100 → 10 (Exceptional)
// 80-89  → 8-9 (Excellent)
// 70-79  → 7 (Good)
// 60-69  → 6 (Acceptable)
// 50-59  → 5 (Needs improvement)
// <50    → 1-4 (Poor)
```

### Usage Pattern
```javascript
const rubric = new CuratorRubric();

// Score an issue
const score = rubric.scoreIssue(issueNumber);

// Get detailed breakdown
const breakdown = rubric.getScoreBreakdown(issueNumber);

// Post score as comment
rubric.postScoreComment(issueNumber, score, breakdown);

// Track score history
rubric.saveScoreHistory();
```

### When to Use
- During intake curation
- Before moving issues to pm-ready
- Quality gate enforcement
- Identifying patterns of good/poor curation

**Script Location**: `/agents/shared/scripts/curator-rubric.mjs`

---

## 🛡️ Bash Validation Pattern

### Purpose
Safe bash execution with syntax checking, pattern validation, and GitHub CLI validation.

### Validation Layers
1. **Shellcheck**: Syntax and best practices validation
2. **Pattern Checking**: Custom rules for common anti-patterns
3. **GitHub CLI**: Validate `gh` command usage
4. **Dry Run**: Test commands before execution

### Configuration
```javascript
const config = {
  shellcheck: {
    enabled: true,
    format: 'json',
    severity: ['error', 'warning', 'info']
  },
  patterns: {
    enabled: true,
    customRules: 'bash-patterns.json'
  },
  github: {
    validateCLI: true,
    dryRun: true
  },
  output: {
    format: 'detailed', // or 'json', 'summary'
    exitOnError: true
  }
};
```

### Command Line Options
```bash
# Validate single file
bash-validator.mjs --file script.sh

# Validate directory
bash-validator.mjs --directory ./scripts

# Validate staged files (pre-commit)
bash-validator.mjs --staged

# Validate workflows
bash-validator.mjs --workflows

# Comprehensive scan
bash-validator.mjs --comprehensive

# Update pattern rules
bash-validator.mjs --update-patterns
```

### Severity Levels
- **error**: Critical issues that will cause failures
- **warning**: Potential issues, best practice violations
- **info**: Suggestions for improvement

### Usage Pattern
```javascript
class BashValidator {
  constructor(options) {
    this.options = { ...config, ...options };
    this.results = {
      files: [],
      summary: { total: 0, passed: 0, failed: 0 }
    };
  }

  // Validate file
  validateFile(filepath) {
    // Run shellcheck
    // Check custom patterns
    // Validate GitHub CLI usage
    // Return validation report
  }

  // Aggregate results
  getSummary() {
    // Return summary statistics
  }
}
```

### Common Anti-Patterns Detected
- Unquoted variables
- Missing error handling
- Unsafe command substitution
- Race conditions in pipelines
- Missing shellcheck directives

### When to Use
- Pre-commit hooks for bash scripts
- CI/CD validation of shell scripts
- Workflow validation
- Before executing user-provided bash

**Script Location**: `/agents/shared/scripts/bash-validator.mjs`

---

## Integration Patterns

### Combining Scripts in Workflows

**Example 1: Issue Intake Pipeline**
```javascript
// 1. Score issue quality
const qualityScore = curatorRubric.scoreIssue(issueNumber);

// 2. If quality sufficient, select archetype
if (qualityScore >= 6) {
  const archetype = selectArchetype(issueNumber);

  // 3. Load archetype evidence requirements
  const requirements = loadArchetypeRequirements(archetype);

  // 4. Validate requirements
  const validator = new EvidenceValidator();
  validator.addRequirements(archetype, requirements, PRIORITY_LEVELS.ARCHETYPE);
}
```

**Example 2: PR Validation Pipeline**
```javascript
// 1. Get archetype from PR labels
const archetype = extractArchetypeFromLabels(prLabels);

// 2. Load evidence requirements (archetype + lenses)
const validator = new EvidenceValidator();
validator.addRequirements(archetype, archetypeRequirements, PRIORITY_LEVELS.ARCHETYPE);

// Apply lenses if present
if (hasPerformanceLens) {
  validator.addRequirements('performance-lens', perfRequirements, PRIORITY_LEVELS.LENS);
}

// 3. Validate evidence submitted
const validationReport = validator.validate(prEvidence);

// 4. Block merge if validation fails
if (!validationReport.passed) {
  postComment(prNumber, validationReport.message);
  setStatus('failure');
}
```

**Example 3: Safe Script Execution**
```javascript
// 1. Validate bash script
const bashValidator = new BashValidator();
const validationResult = bashValidator.validateFile(scriptPath);

// 2. Only execute if validation passed
if (validationResult.passed) {
  execSync(scriptPath);
} else {
  console.error('Validation failed:', validationResult.errors);
  process.exit(1);
}
```

---

## Related Skills

- **wolf-archetypes**: Archetype definitions and registry
- **wolf-lenses**: Lens overlay requirements
- **wolf-governance**: Governance policies and quality gates
- **wolf-scripts-agents**: Agent coordination scripts (orchestration, execution)

---

## File Locations

All core scripts are in `/agents/shared/scripts/`:
- `select-archetype.mjs` - Archetype selection logic
- `evidence-validator.mjs` - Evidence validation with conflict resolution
- `curator-rubric.mjs` - Issue quality scoring
- `bash-validator.mjs` - Safe bash execution validation

---

## Best Practices

### Archetype Selection
- ✅ Always check confidence score before auto-assignment
- ✅ Log archetype selection rationale for audit
- ✅ Fall back to human review if low confidence
- ❌ Don't skip label analysis
- ❌ Don't ignore pattern matching

### Evidence Validation
- ✅ Always track conflict resolutions
- ✅ Document why conflicts were resolved specific ways
- ✅ Validate backward compatibility when updating schemas
- ❌ Don't silently drop conflicting requirements
- ❌ Don't ignore priority levels

### Curator Rubric
- ✅ Provide detailed score breakdown with comments
- ✅ Track score history for trend analysis
- ✅ Use consistent scoring criteria
- ❌ Don't auto-approve low-scoring issues
- ❌ Don't skip any rubric categories

### Bash Validation
- ✅ Always validate before execution
- ✅ Use dry-run mode for testing
- ✅ Check comprehensive mode for critical scripts
- ❌ Don't bypass validation for "simple" scripts
- ❌ Don't ignore warnings in production code

---

## Red Flags - STOP

If you catch yourself thinking:

- ❌ **"Skipping automated checks to save time"** - STOP. Automation exists because manual checks fail. Scripts catch what humans miss. Use the automation.
- ❌ **"Manual validation is good enough"** - NO. Manual validation is inconsistent and error-prone. Scripts provide reproducible validation every time.
- ❌ **"Scripts are just helpers, not requirements"** - Wrong. These scripts encode battle-tested logic from 50+ phases. They ARE requirements.
- ❌ **"I can select archetypes manually faster"** - False. Manual selection misses patterns and lacks confidence scoring. Use `select-archetype.mjs`.
- ❌ **"Evidence validation can wait until PR review"** - FORBIDDEN. Waiting until PR review wastes reviewer time. Validate BEFORE creating PR.
- ❌ **"Curator rubric scoring is optional"** - NO. Quality gates depend on rubric scores. All issues must be scored before pm-ready.

**STOP. Use the appropriate automation script BEFORE proceeding.**

## After Using This Skill

**REQUIRED NEXT STEPS:**

```
Integration with Wolf skill chain
```

1. **RECOMMENDED SKILL**: Use **wolf-archetypes** to understand archetype definitions
   - **Why**: Scripts automate archetype selection. Understanding archetypes ensures correct interpretation of results.
   - **When**: After using `select-archetype.mjs` to understand selected archetype's requirements
   - **Tool**: Use Skill tool to load wolf-archetypes

2. **RECOMMENDED SKILL**: Use **wolf-governance** to understand quality gates
   - **Why**: Scripts enforce governance. Understanding gates ensures compliance.
   - **When**: After using `curator-rubric.mjs` or `evidence-validator.mjs`
   - **Tool**: Use Skill tool to load wolf-governance

3. **DURING WORK**: Scripts provide continuous automation
   - Scripts are called throughout workflow (intake, validation, execution)
   - No single "next skill" - scripts integrate into existing chains
   - Use scripts at appropriate workflow stages

### Verification Checklist

Before claiming script-based automation complete:

- [ ] Used appropriate automation script for task (archetype selection, evidence validation, rubric scoring, or bash validation)
- [ ] Validated confidence scores before proceeding (for archetype selection, require >70% confidence)
- [ ] Documented script execution and results in journal or PR description
- [ ] Evidence requirements tracked and validated (for evidence-validator usage)
- [ ] No validation warnings ignored (all errors and warnings addressed)

**Can't check all boxes? Automation incomplete. Return to this skill.**

### Good/Bad Examples: Script Usage

#### Example 1: Archetype Selection

<Good>
**Issue #456: Add rate limiting to API endpoints**
**Labels**: `feature`, `performance`

**Script Execution**:
```bash
$ node select-archetype.mjs --issue 456

Results:
  product-implementer: 45% (keywords: add, feature)
  perf-optimizer: 72% (keywords: performance, rate limiting; patterns: throughput)

Selected: perf-optimizer (confidence: 72%)
✅ Confidence above threshold (70%)
```

**Agent Action**:
✅ Accepted perf-optimizer archetype
✅ Loaded perf-optimizer evidence requirements (benchmarks, profiling, performance tests)
✅ Documented selection rationale in journal
✅ Proceeded with performance-focused implementation

**Why this is correct**:
- Used automation script instead of manual guess
- Validated confidence score before accepting
- Selected archetype matches work characteristics (performance focus)
- Evidence requirements automatically loaded
</Good>

<Bad>
**Issue #457: Fix login button**
**Labels**: `bug`

**Manual Selection**: "It's obviously a bug fix, so reliability-fixer"

**Problems**:
❌ Skipped automation script
❌ No confidence scoring
❌ Missed that issue title/description mention "button doesn't display" (could be CSS issue = maintainability-refactorer)
❌ No evidence requirements loaded
❌ No documentation of selection rationale

**What Should Have Been Done**:
```bash
$ node select-archetype.mjs --issue 457

Results:
  reliability-fixer: 38% (keywords: fix, bug)
  maintainability-refactorer: 54% (patterns: display issue, CSS)

Selected: maintainability-refactorer (confidence: 54%)
⚠️ Low confidence - recommend human review
```

**Outcome**: Agent would have identified this as UI/styling issue, not logic bug.
</Bad>

#### Example 2: Evidence Validation Workflow

<Good>
**PR #789: Optimize database query performance**
**Archetype**: perf-optimizer
**Lenses**: observability

**Script Execution**:
```bash
$ node evidence-validator.mjs --archetype perf-optimizer --lenses observability

Loading requirements...
  ✅ Archetype requirements (priority: 2): benchmarks, profiling, performance tests
  ✅ Observability lens (priority: 1): metrics, monitoring, alerting

Validating evidence...
  ✅ Benchmarks provided: before/after query times
  ✅ Profiling data: flame graph showing bottleneck
  ✅ Performance tests: 47 tests passing, 15% latency improvement
  ✅ Metrics: added query_duration_ms metric
  ✅ Monitoring: added query performance dashboard
  ✅ Alerting: added slow query alert (>500ms)

All requirements met ✅
```

**Agent Action**:
✅ Evidence validator ran before PR creation
✅ All requirements from archetype + lens validated
✅ PR included complete evidence package
✅ Reviewer approved without requesting additional evidence

**Why this is correct**:
- Automated validation caught all requirements
- Combined archetype + lens requirements properly
- Evidence complete before PR review
- No wasted reviewer time
</Good>

<Bad>
**PR #790: Add caching layer**
**Archetype**: perf-optimizer
**Lenses**: security

**Manual Check**: "I added benchmarks, should be good"

**Problems**:
❌ Skipped evidence-validator script
❌ Didn't realize security lens adds requirements (threat model, security scan)
❌ Missing security evidence for caching layer
❌ Missing several perf-optimizer requirements (profiling, comprehensive tests)

**PR Review**:
❌ Reviewer requested: threat model for cache poisoning
❌ Reviewer requested: security scan for cache key vulnerabilities
❌ Reviewer requested: comprehensive performance tests
❌ Reviewer requested: cache eviction profiling

**Outcome**: 3 review cycles, 2 weeks delay, demoralized team

**What Should Have Been Done**:
```bash
$ node evidence-validator.mjs --archetype perf-optimizer --lenses security

❌ Validation failed:
  Missing: Threat model (security lens requirement)
  Missing: Security scan (security lens requirement)
  Missing: Profiling data (archetype requirement)
  Missing: Cache eviction tests (archetype requirement)

Provided: Basic benchmarks only

Evidence incomplete. Address missing requirements before PR creation.
```

**If script had been used**: All requirements identified upfront, evidence collected before PR, single review cycle.
</Bad>

---

**Last Updated**: 2025-11-14
**Phase**: Superpowers Skill-Chaining Enhancement v2.0.0
**Maintainer**: Wolf Automation Team
