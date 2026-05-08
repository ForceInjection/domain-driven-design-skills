---
name: changelog-updater
description: Update CHANGELOG.md and TEST-CHANGELOG.md with new entries following Keep a Changelog format and token optimization principles. Use when adding changes to the changelog, documenting new features, fixes, or optimizations.
allowed-tools: Read, Edit, Grep
---

# Changelog Updater

Updates CHANGELOG.md following the optimized format established in this project.

## When to Use

- After completing features, fixes, or optimizations
- When user requests "update changelog" or "add to changelog"
- When documenting architectural changes or token optimizations

## Format Requirements

### File Structure
```markdown
## [Unreleased]

### Added
**Feature Name** (YYYY-MM-DD)
- Bullet points describing what was added
- Impact metrics if applicable

### Changed
**Change Name** (YYYY-MM-DD)
- Bullet points describing what changed
- Before/after metrics when relevant

### Fixed
**Fix Name** (YYYY-MM-DD)
- Bullet points describing what was fixed
- Files modified and root cause when relevant
```

### Token Optimization Principles

Apply these techniques when writing changelog entries:

| Technique | Example | Benefit |
|-----------|---------|---------|
| **Tables over prose** | Use tables for comparisons/metrics | 60-80% reduction |
| **Pattern statements** | "Philosophy: 'Don't echo back what caller knows'" | 80% reduction |
| **Consolidated redundancy** | Combine similar entries into themed sections | 50-70% reduction |
| **One perfect example** | Show one clear example instead of multiple | 65-70% reduction |
| **Eliminate teaching** | State facts, don't explain basics | 80% reduction |

### Entry Guidelines

**Good entry structure:**
```markdown
**Feature Name - Key Metric** (2025-11-03)
- What was done (1-2 lines)
- Technical details if complex (2-3 lines max)
- Impact: tokens saved, performance gain, etc.
- Files modified: path/to/file.ext:lines
```

**Avoid:**
- Excessive technical detail (put in ai_docs/ instead)
- Redundant explanations
- Multiple paragraphs per bullet
- Teaching basic concepts

## Instructions

### Step 1: Read Current Changelog

```bash
# Read just the Unreleased section
grep -A 100 "## \[Unreleased\]" CHANGELOG.md | head -100
```

### Step 2: Identify Correct Section

- **Added**: New features, capabilities, documentation, tools
- **Changed**: Modifications to existing functionality, optimizations, refactors
- **Fixed**: Bug fixes, error corrections, path updates

### Step 3: Format Entry

Use this template:

```markdown
**Title - Key Metric** (YYYY-MM-DD)
- Primary change description
- Technical implementation (if needed)
- Impact: quantifiable benefit
- Files: modified locations
```

**For token optimizations**, use table format:
```markdown
**Optimization Suite - Total Savings** (YYYY-MM-DD)
| Component | Savings | Type | Impact |
|-----------|---------|------|--------|
| Item 1 | X tokens | Per session | Description |
| Item 2 | Y tokens | One-time | Description |
| **TOTAL** | **Z tokens** | **Per session** | **% of budget** |
```

### Step 4: Add Entry

1. Find the correct section (### Added, ### Changed, or ### Fixed)
2. Add entry at the TOP of that section (after the header)
3. Maintain chronological order (newest first)
4. Ensure proper blank lines between entries

### Step 5: Verify Format

Check:
- [ ] Date is today's date (YYYY-MM-DD)
- [ ] Entry is concise (<10 lines unless complex optimization)
- [ ] Metrics included when applicable
- [ ] No duplicate section headers
- [ ] Proper markdown formatting

## Examples

### Example 1: Feature Addition

```markdown
### Added

**Agent Skills System** (2025-11-03)
- Created changelog-updater skill for consistent CHANGELOG.md updates
- Format: YAML frontmatter + markdown instructions + examples
- Features: Token optimization guidelines, format validation, Keep a Changelog compliance
- Location: .claude/skills/changelog-updater/SKILL.md
```

### Example 2: Optimization

```markdown
### Changed

**Agent Files Token Optimization - 55.7% Reduction** (2025-11-03)
- Rewrote all 31 `.claude/agents/*.md` files from verbose to minimal YAML
- Line reduction: 1,878 → 832 lines (1,046 removed, 55.7% savings)
- Architecture: Metadata only in files, full prompts loaded via MCP
- Impact: ~2,000-2,500 tokens saved per agent file load
```

### Example 3: Bug Fix

```markdown
### Fixed

**Claude Hooks Path References** (2025-11-03)
- Updated config_validator.py path construction (scripts/claude-hooks → .claude/hooks)
- Fixed _find_project_root() traversal logic for new structure
- Files: .claude/hooks/utils/config_validator.py:20,78-83
- Result: Hooks load correctly, file protection active, no startup errors
```

### Example 4: Multi-Component Table

```markdown
### Changed

**Token Optimization Suite - 21-28k Tokens Saved** (2025-11-03)
| Optimization | Savings | Type | Impact |
|--------------|---------|------|--------|
| MCP Tool Descriptions | 10,600 | Startup | 60-70% description reduction |
| Dead Code Prevention | 4,500-7,000 | Per session | Removed unused services |
| MinimalResponseSerializer | 6,000-8,000 | Per session | Eliminated echo responses |
| **TOTAL** | **21,720-26,580** | **Per session** | **10.9-13.3% of 200k budget** |
```

## Best Practices

### Be Concise

**Good**: "Optimized agent files: 1,878 → 832 lines (55.7% reduction)"

**Too verbose**: "We performed a comprehensive optimization of the agent file system by analyzing each of the 31 agent files and rewriting them to use a more concise format that reduced the total line count from 1,878 lines down to 832 lines which represents a 55.7% reduction in file size..."

### Quantify Impact

Always include metrics when available:
- Token savings (per session, one-time, % of budget)
- Line reduction (before → after, % saved)
- Performance gains (time, memory, response size)
- File counts (files modified, lines changed)

### Use Active Voice

**Good**: "Removed EnrichmentService (566 lines)"

**Avoid**: "EnrichmentService was removed (566 lines)"

### Group Related Changes

If multiple related changes happened together, combine them:

**Good** (grouped):
```markdown
**Hooks System Migration** (2025-11-03)
- Migrated from scripts/claude-hooks/ to .claude/hooks/
- Updated all path references in config_validator, pre_tool_use, test paths
- File system protection, documentation enforcement operational
```

**Avoid** (separate):
```markdown
**Hooks Path Update** (2025-11-03)
- Migrated hooks to .claude/hooks/

**Config Validator Fix** (2025-11-03)
- Updated config_validator paths

**Test Paths Update** (2025-11-03)
- Fixed test path references
```

## Validation Checklist

Before finalizing the changelog entry:

- [ ] **Format**: Follows Keep a Changelog structure
- [ ] **Section**: Entry in correct section (Added/Changed/Fixed)
- [ ] **Date**: Uses YYYY-MM-DD format
- [ ] **Concise**: Entry is scannable (<10 lines for most changes)
- [ ] **Metrics**: Includes quantifiable impact when available
- [ ] **Files**: References specific files/lines when relevant
- [ ] **Token Optimized**: Uses tables, patterns, consolidated format
- [ ] **No Duplicates**: Doesn't duplicate existing section headers
- [ ] **Markdown**: Proper formatting (**, -, backticks for code)

## Supporting Files

For detailed guidance, see:
- **[EXAMPLES.md](EXAMPLES.md)** - Real-world examples from this project (189 lines, all patterns covered)
- **[TEMPLATES.md](TEMPLATES.md)** - Copy-paste templates for quick entry creation (267 lines, fill placeholders)
- **[VALIDATION.md](VALIDATION.md)** - Validation commands, checklists, quality checks (212 lines, pre-commit verification)

## Reference

- Keep a Changelog: https://keepachangelog.com/en/1.0.0/
- Semantic Versioning: https://semver.org/spec/v2.0.0.html
- Project token optimization principles: See CHANGELOG.md "Token Optimization Suite" section
