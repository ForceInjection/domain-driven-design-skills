---
name: querying-gpt52
description: Queries GPT-5.2 for high-reasoning code analysis, root-cause bug fixing, and complex coding questions. Provides P0-P3 prioritized analysis reports, architecture audits, and security reviews with configurable reasoning effort (none/low/medium/high/xhigh). 400K context, 128K output.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
---

# Querying GPT-5.2

Queries GPT-5.2 for deep code analysis, root-cause bug fixing, and complex technical questions. Leverages GPT-5.2's 400K context window and extended reasoning capabilities to provide comprehensive analysis with P0-P3 prioritized findings.

## Quick Reference

GPT-5.2 provides three specialized capabilities via standalone scripts:

| Script | Purpose | Use Case |
|--------|---------|----------|
| `gpt52_query.py` | General queries | Complex coding questions, algorithm design, concept explanations |
| `gpt52_analyze.py` | Code analysis | Pre-merge reviews, architecture audits, security scans |
| `gpt52_fix.py` | Root-cause fixes | Bug debugging that addresses underlying issues (not symptoms) |

**Key Features:**
- 400,000 token context window (analyze large codebases)
- 128,000 token output limit (comprehensive responses)
- Configurable reasoning effort (none/low/medium/high/xhigh)
- Structured P0-P3 prioritization for findings
- Aug 2025 knowledge cutoff

## Scripts

### gpt52_query.py

General-purpose queries with high reasoning capabilities.

**Usage:**
```bash
python .claude/skills/querying-gpt52/scripts/gpt52_query.py \
  --prompt "How should I implement retry logic with exponential backoff?" \
  --reasoning-effort high \
  --timeout 300 \
  --output-format markdown
```

**Arguments:**
| Argument | Required | Default | Values | Description |
|----------|----------|---------|--------|-------------|
| `--prompt` | Yes | - | string | The question or request |
| `--reasoning-effort` | No | high | none/low/medium/high/xhigh | Reasoning depth |
| `--timeout` | No | 300 | float | Max wait time in seconds |
| `--output-format` | No | markdown | markdown/json | Output format |

**Example:**
```bash
# Ask about Python async patterns
python .claude/skills/querying-gpt52/scripts/gpt52_query.py \
  --prompt "What are the best practices for handling asyncio.CancelledError?"

# Complex algorithm design
python .claude/skills/querying-gpt52/scripts/gpt52_query.py \
  --prompt "Design a rate limiter using token bucket algorithm" \
  --reasoning-effort xhigh
```

### gpt52_analyze.py

Comprehensive code analysis for single files or complete projects.

**Usage:**
```bash
python .claude/skills/querying-gpt52/scripts/gpt52_analyze.py \
  --target "app/core/" \
  --focus-areas "security,performance" \
  --analysis-type comprehensive \
  --timeout 600 \
  --output-format markdown
```

**Arguments:**
| Argument | Required | Default | Values | Description |
|----------|----------|---------|--------|-------------|
| `--target` | Yes | - | path | File or directory to analyze |
| `--focus-areas` | No | all | security/performance/architecture/testing/quality/all | Analysis dimensions (comma-separated) |
| `--analysis-type` | No | comprehensive | quick/comprehensive/deep | Analysis depth |
| `--timeout` | No | 600 | float | Max wait time in seconds |
| `--output-format` | No | markdown | markdown/json | Output format |

**Example:**
```bash
# Security audit of API endpoints
python .claude/skills/querying-gpt52/scripts/gpt52_analyze.py \
  --target "app/api/" \
  --focus-areas "security" \
  --analysis-type deep

# Quick quality check before merge
python .claude/skills/querying-gpt52/scripts/gpt52_analyze.py \
  --target "app/services/new_feature.py" \
  --analysis-type quick
```

### gpt52_fix.py

Root-cause bug fixing (NOT monkey patches).

**Usage:**
```bash
python .claude/skills/querying-gpt52/scripts/gpt52_fix.py \
  --target "app/api/endpoints.py" \
  --issues "TypeError: 'NoneType' object is not subscriptable on line 45 when session expires" \
  --fix-scope root_cause \
  --timeout 600 \
  --output-format markdown
```

**Arguments:**
| Argument | Required | Default | Values | Description |
|----------|----------|---------|--------|-------------|
| `--target` | Yes | - | path | File or directory containing the issue |
| `--issues` | Yes | - | string | Detailed problem description (include error messages, stack traces) |
| `--fix-scope` | No | root_cause | root_cause/minimal/comprehensive | Fix approach |
| `--timeout` | No | 600 | float | Max wait time in seconds |
| `--output-format` | No | markdown | markdown/json | Output format |

**Example:**
```bash
# Fix a concurrency bug
python .claude/skills/querying-gpt52/scripts/gpt52_fix.py \
  --target "app/core/session.py" \
  --issues "Race condition in session cleanup: multiple cleanup tasks running simultaneously causing KeyError"

# Fix with full stack trace
python .claude/skills/querying-gpt52/scripts/gpt52_fix.py \
  --target "app/services/" \
  --issues "$(cat error.log)" \
  --fix-scope comprehensive
```

## When to Use

Use this skill for tasks requiring extended reasoning and deep analysis:

### Code Analysis
- Pre-merge code reviews
- Architecture audits across multiple files
- Security vulnerability scanning
- Performance bottleneck identification
- Technical debt assessment

### Root-Cause Debugging
- Complex bugs requiring tracing through call chains
- Race conditions and concurrency issues
- Memory leaks or performance degradation
- Architectural flaws causing repeated issues

### Complex Questions
- Algorithm design and optimization
- Framework integration strategies
- Best practices for specific patterns
- Trade-off analysis for technical decisions

## When NOT to Use

Avoid this skill for:

- **Simple queries** - Use Claude directly for straightforward questions
- **Real-time streaming** - GPT-5.2 doesn't support streaming responses
- **Tool calling** - GPT-5.2 via Responses API doesn't support function calling
- **Quick fixes** - For obvious typos or simple bugs, direct editing is faster
- **Tasks requiring MCP tools** - Use standard Claude Code capabilities

## Limitations

### File Size Constraints
- 500KB maximum per file
- 2MB total for all files in analysis
- Files exceeding limits are excluded automatically

### Security Restrictions
- System directories blocked: `/etc`, `/usr`, `/bin`, `/sbin`, `/var`, `/root`
- `.env` files automatically excluded (prevents secret exposure)
- Path traversal attacks prevented

### Output Constraints
- Output truncated at 100,000 characters
- JSON output available for programmatic parsing
- Markdown output optimized for human readability

## See Also

- @CAPABILITIES.md - GPT-5.2 model specifications, reasoning effort levels, file limits
- @PROMPTS.md - System prompt documentation with P0-P3 dimension descriptions
- @WORKFLOWS.md - Step-by-step checklists for analysis and fixing workflows
