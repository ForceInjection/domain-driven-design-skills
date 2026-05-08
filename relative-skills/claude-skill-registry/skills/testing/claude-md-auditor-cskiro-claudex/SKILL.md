---
name: claude-md-auditor
version: 0.2.1
description: Use PROACTIVELY when reviewing CLAUDE.md configurations, onboarding new projects, or before committing memory file changes. Validates against official Anthropic documentation, community best practices, and LLM context optimization research. Detects security violations, anti-patterns, and compliance issues. Not for runtime behavior testing or imported file validation.
---

# CLAUDE.md Auditor

Validates and scores CLAUDE.md files against three authoritative sources with actionable remediation guidance.

## When to Use

- **Audit before committing** CLAUDE.md changes
- **Onboard new projects** and validate memory configuration
- **Troubleshoot** why Claude isn't following standards
- **CI/CD integration** for automated validation gates

## Validation Sources

### 1. Official Anthropic Guidance
- Memory hierarchy (Enterprise > Project > User)
- "Keep them lean" requirement
- Import syntax and limitations (max 5 hops)
- What NOT to include (secrets, generic content)
- **Authority**: Highest (requirements from Anthropic)

### 2. Community Best Practices
- 100-300 line target range
- 80/20 rule (essential vs. supporting content)
- Organizational patterns and maintenance cadence
- **Authority**: Medium (recommended, not mandatory)

### 3. Research-Based Optimization
- "Lost in the middle" positioning (Liu et al., 2023)
- Token budget optimization
- Attention pattern considerations
- **Authority**: Medium (evidence-based)

## Output Modes

### Mode 1: Audit Report (Default)

Generate comprehensive markdown report:

```
Audit my CLAUDE.md file using the claude-md-auditor skill.
```

**Output includes**:
- Overall health score (0-100)
- Category scores (security, compliance, best practices)
- Findings grouped by severity (CRITICAL → LOW)
- Specific remediation steps with line numbers

### Mode 2: JSON Report

Machine-readable format for CI/CD:

```
Generate JSON audit report for CI pipeline integration.
```

**Use for**: Automated quality gates, metrics tracking

### Mode 3: Refactored File

Generate production-ready CLAUDE.md:

```
Audit my CLAUDE.md and generate a refactored version following best practices.
```

**Output**: CLAUDE_refactored.md with optimal structure and research-based positioning

## Quick Examples

### Security-Focused Audit
```
Run a security-focused audit on my CLAUDE.md to check for secrets.
```

Checks for: API keys, tokens, passwords, connection strings, private keys

### Multi-Tier Audit
```
Audit CLAUDE.md files in my project hierarchy (Enterprise, Project, User tiers).
```

Checks each tier and reports conflicts between them.

## Score Interpretation

**Overall Health (0-100)**:
- 90-100: Excellent (minor optimizations only)
- 75-89: Good (some improvements recommended)
- 60-74: Fair (schedule improvements)
- 40-59: Poor (significant issues)
- 0-39: Critical (immediate action required)

**Category Targets**:
- Security: 100 (any issue is critical)
- Official Compliance: 80+
- Best Practices: 70+

## Finding Severities

- **CRITICAL**: Security risk (fix immediately)
- **HIGH**: Compliance issue (fix this sprint)
- **MEDIUM**: Improvement opportunity (next quarter)
- **LOW**: Minor optimization (backlog)

## Reference Documentation

Detailed validation criteria and integration examples:

- `reference/official-guidance.md` - Complete Anthropic documentation compilation
- `reference/best-practices.md` - Community-derived recommendations
- `reference/research-insights.md` - Academic research findings
- `reference/anti-patterns.md` - Catalog of common mistakes
- `reference/ci-cd-integration.md` - Pre-commit, GitHub Actions, VS Code examples

## Limitations

- Cannot automatically fix security issues (requires manual remediation)
- Cannot test if Claude actually follows the standards
- Cannot validate imported files beyond path existence
- Cannot detect circular imports

## Success Criteria

A well-audited CLAUDE.md achieves:
- Security Score: 100/100
- Official Compliance: 80+/100
- Overall Health: 75+/100
- Zero CRITICAL findings
- < 3 HIGH findings

---

**Version**: 1.0.0 | **Last Updated**: 2025-10-26
