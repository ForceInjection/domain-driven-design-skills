---
name: dependency-evaluator
description: Evaluates whether a programming language dependency should be used by analyzing maintenance activity, security posture, community health, documentation quality, dependency footprint, production adoption, license compatibility, API stability, and funding sustainability. Use when users ask "should I use X or Y?", "are there better options for [feature]?", "what's a good library for [task]?", "how do we feel about [dependency]?", or when considering adding a new dependency, evaluating an existing dependency, or comparing/evaluating package alternatives.
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
  - WebFetch
  - WebSearch
---

# Dependency Evaluator Skill

This skill helps evaluate whether a programming language dependency should be added to a project by analyzing multiple quality signals and risk factors.

## Purpose

Making informed decisions about dependencies is critical for project health. A poorly chosen dependency can introduce security vulnerabilities, maintenance burden, and technical debt. This skill provides a systematic framework for evaluating dependencies before adoption.

## When to Use

Activate this skill when users:
- Ask about whether to use a specific package/library
- Want to evaluate a dependency before adding it
- Need to compare alternative packages
- Ask "should I use X library?"
- Want to assess the health of a dependency
- Mention adding a new npm/pip/cargo/gem/etc. package
- Ask about package recommendations for a use case

## Reference Files

This skill uses progressive disclosure - core framework below, detailed guidance in reference files:

| File | When to Consult |
|------|-----------------|
| **[WORKFLOW.md](./WORKFLOW.md)** | Detailed step-by-step evaluation process, performance tips, pitfalls |
| **[SCRIPT_USAGE.md](./SCRIPT_USAGE.md)** | Automated data gathering script (optional efficiency tool) |
| **[COMMANDS.md](./COMMANDS.md)** | Ecosystem-specific commands (npm, PyPI, Cargo, Go, etc.) |
| **[SIGNAL_DETAILS.md](./SIGNAL_DETAILS.md)** | Deep guidance for scoring each of the 10 signals |
| **[ECOSYSTEM_GUIDES.md](./ECOSYSTEM_GUIDES.md)** | Ecosystem-specific norms and considerations |
| **[EXAMPLES.md](./EXAMPLES.md)** | Worked evaluation examples (ADOPT, AVOID, EVALUATE FURTHER) |
| **[ERROR_HANDLING.md](./ERROR_HANDLING.md)** | Fallback strategies when data unavailable or commands fail |

**Quick navigation by ecosystem:**
- **npm** → COMMANDS.md § Node.js + ECOSYSTEM_GUIDES.md § npm
- **PyPI** → COMMANDS.md § Python + ECOSYSTEM_GUIDES.md § PyPI
- **Cargo** → COMMANDS.md § Rust + ECOSYSTEM_GUIDES.md § Cargo
- **Go** → COMMANDS.md § Go + ECOSYSTEM_GUIDES.md § Go
- **Other** → COMMANDS.md for ecosystem-specific commands

## Evaluation Framework

Evaluate dependencies using these ten key signals:

1. **Activity and Maintenance Patterns** - Commit history, release cadence, issue responsiveness
2. **Security Posture** - CVE history, security policies, vulnerability response time
3. **Community Health** - Contributor diversity, PR merge rates, bus factor
4. **Documentation Quality** - API docs, migration guides, examples
5. **Dependency Footprint** - Transitive dependencies, bundle size
6. **Production Adoption** - Download stats, notable users, trends
7. **License Compatibility** - License type, transitive license obligations
8. **API Stability** - Breaking change frequency, semver adherence
9. **Bus Factor and Funding** - Organizational backing, sustainability
10. **Ecosystem Momentum** - Framework alignment, technology trends

**For detailed investigation guidance**, see [SIGNAL_DETAILS.md](./SIGNAL_DETAILS.md).
**For ecosystem-specific commands**, see [COMMANDS.md](./COMMANDS.md).
**For ecosystem considerations**, see [ECOSYSTEM_GUIDES.md](./ECOSYSTEM_GUIDES.md).

## Evaluation Approach

**Goal:** Provide evidence-based recommendations (ADOPT / EVALUATE FURTHER / AVOID) by systematically assessing 10 quality signals.

**Process:** Quick assessment → Data gathering → Scoring → Report generation

See **[WORKFLOW.md](./WORKFLOW.md)** for detailed step-by-step guidance, performance tips, and workflow variants.

### Automated Data Gathering (Recommended)

A Python script (`scripts/dependency_evaluator.py`) automates initial data gathering for supported ecosystems (npm, pypi, cargo, go). The script:
- Runs ecosystem commands automatically
- Fetches GitHub API data
- Outputs structured JSON
- Uses only Python standard library (no external dependencies)
- Saves 10-15 minutes per evaluation

**Default approach:** Try the script first - it provides more complete and consistent data gathering. Only fall back to manual workflow if the script is unavailable or fails.

**Use the script when:** Evaluating npm, PyPI, Cargo, or Go packages (most common ecosystems)
**Use manual workflow when:** Unsupported ecosystem, Python unavailable, or script errors occur

See **[SCRIPT_USAGE.md](./SCRIPT_USAGE.md)** for complete documentation. The skill works perfectly fine without the script using manual workflow.

## Before You Evaluate: Is a Dependency Needed?

**Write it yourself if:** Functionality is <50 lines of straightforward code, or you only need a tiny subset of features.

**Use a dependency if:** Problem is complex (crypto, dates, parsing), correctness is critical, or ongoing maintenance would be significant.

See **[WORKFLOW.md](./WORKFLOW.md)** § Pre-Evaluation for detailed decision framework.

## Output Format

Structure your evaluation report as:

```markdown
## Dependency Evaluation: <package-name>

### Summary
[2-3 sentence overall assessment with recommendation]

**Recommendation**: [ADOPT / EVALUATE FURTHER / AVOID]
**Risk Level**: [Low / Medium / High]
**Blockers Found**: [Yes/No]

### Blockers (if any)
[List any dealbreaker issues - these override all scores]
- ⛔ [Blocker description with specific evidence]

### Evaluation Scores

| Signal | Score | Weight | Notes |
|--------|-------|--------|-------|
| Maintenance | X/5 | [H/M/L] | [specific evidence with dates/versions] |
| Security | X/5 | [H/M/L] | [specific evidence] |
| Community | X/5 | [H/M/L] | [specific evidence] |
| Documentation | X/5 | [H/M/L] | [specific evidence] |
| Dependency Footprint | X/5 | [H/M/L] | [specific evidence] |
| Production Adoption | X/5 | [H/M/L] | [specific evidence] |
| License | X/5 | [H/M/L] | [specific evidence] |
| API Stability | X/5 | [H/M/L] | [specific evidence] |
| Funding/Sustainability | X/5 | [H/M/L] | [specific evidence] |
| Ecosystem Momentum | X/5 | [H/M/L] | [specific evidence] |

**Weighted Score**: X/50 (adjusted for dependency criticality)

### Key Findings

#### Strengths
- [Specific strength with evidence]
- [Specific strength with evidence]

#### Concerns
- [Specific concern with evidence]
- [Specific concern with evidence]

### Alternatives Considered
[If applicable, mention alternatives worth evaluating]

### Recommendation Details
[Detailed reasoning for the recommendation with specific evidence]

### If You Proceed (for ADOPT recommendations)
[Specific advice tailored to risks found]
- Version pinning strategy
- Monitoring recommendations
- Specific precautions based on identified concerns
```

## Scoring Weights

Adjust signal weights based on dependency type:

| Signal | Critical Dep | Standard Dep | Dev Dep |
|--------|-------------|--------------|---------|
| Security | High | Medium | Low |
| Maintenance | High | Medium | Medium |
| Funding | High | Low | Low |
| License | High | High | Medium |
| API Stability | Medium | Medium | High |
| Documentation | Medium | Medium | Medium |
| Community | Medium | Medium | Low |
| Dependency Footprint | Medium | Low | Low |
| Production Adoption | Medium | Medium | Low |
| Ecosystem Momentum | Low | Medium | Low |

**Critical Dependencies**: Auth, security, data handling - require higher bar for all signals

**Standard Dependencies**: Utilities, formatting - balance all signals

**Development Dependencies**: Testing, linting - lower security concerns, focus on maintainability

### Score Interpretation Rules

**Blocker Override**: Any blocker issue → AVOID recommendation regardless of scores

**Critical Thresholds**:
- Security or Maintenance score ≤ 2 → Strongly reconsider regardless of other scores
- Any High-weight signal ≤ 2 → Flag as significant concern in report
- Overall weighted score < 25 → Default to EVALUATE FURTHER or AVOID
- Overall weighted score ≥ 35 → Generally safe to ADOPT (if no blockers)

**Weighting Priority**: Security and Maintenance typically matter more than Documentation or Ecosystem Momentum. A well-documented but unmaintained package is riskier than a poorly-documented but actively maintained one.

## Critical Red Flags (Dealbreakers)

These issues trigger automatic AVOID recommendation:

### Supply Chain Risks
- ⛔ Typosquatting: Package name suspiciously similar to popular package
- ⛔ Compiled binaries without source: Binary blobs without build instructions
- ⛔ Sudden ownership transfer: Recent transfer to unknown maintainer
- ⛔ Install scripts with network calls: Postinstall scripts downloading external code

### Maintainer Behavior
- ⛔ Ransom behavior: Maintainer demanding payment to fix security issues
- ⛔ Protest-ware: Code performing actions based on political/geographic conditions
- ⛔ Intentional sabotage history: Any history of deliberately breaking the package

### Security Issues
- ⛔ Active exploitation: Known vulnerability being actively exploited in wild
- ⛔ Credentials in source: API keys, passwords, or secrets in repository
- ⛔ Disabled security features: Package disables security without clear reason

### Legal Issues
- ⛔ License violation: Package includes code violating its stated license
- ⛔ No license: No license file means all rights reserved (legally risky)
- ⛔ License change without notice: Recent sneaky change to restrictive terms


## Self-Validation Checklist

Before presenting your report, verify:

- [ ] Cited specific versions and dates for all claims?
- [ ] Ran actual commands rather than making assumptions?
- [ ] All scores supported by evidence in "Notes" column?
- [ ] If Security or Maintenance ≤ 2, flagged prominently?
- [ ] If any blocker exists, recommendation is AVOID?
- [ ] Provided at least 2 alternatives if recommending AVOID?
- [ ] "If You Proceed" section tailored to specific risks found?
- [ ] Recommendation aligns with weighted score and blocker rules?

## Evaluation Principles

**Be Evidence-Based:** Cite specific versions, dates, and metrics. Run commands to gather data, never assume.

**Be Balanced:** Acknowledge strengths AND weaknesses. Single issues rarely disqualify (unless blocker).

**Be Actionable:** Provide clear ADOPT/EVALUATE FURTHER/AVOID with alternatives and risk mitigation.

**Be Context-Aware:** Auth libraries need stricter scrutiny than dev tools. Adjust for ecosystem norms (see ECOSYSTEM_GUIDES.md).

See **[WORKFLOW.md](./WORKFLOW.md)** § Common Pitfalls and § Guidelines for detailed best practices.
