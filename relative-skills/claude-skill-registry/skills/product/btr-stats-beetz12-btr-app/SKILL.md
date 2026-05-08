---
name: btr-stats
description: Display LOCAL BTR statistics (NOT ByteRover/brv). Use when the user asks "how much time saved", "context statistics", "usage metrics", "BTR statistics", "BTR metrics", "BTR usage", or wants to see the value of their context library.
allowed-tools: Read, Bash
---

# BTR Stats

## ⚠️ CRITICAL: BTR ≠ ByteRover

**This skill uses `btr` (local context tree), NOT `brv` (ByteRover CLI).**

| Command | Tool | Syntax |
|---------|------|--------|
| ✓ CORRECT | `btr` | `btr query "search term"` / `btr list` / `btr stats` |
| ✗ WRONG | `brv` | Different tool, different syntax, requires auth |

**PREFER MCP tools when available:**
- `mcp__btr__query_context` - For searching
- `mcp__btr__list_contexts` - For browsing
- `mcp__btr__get_stats` - For statistics

Only use Bash `btr` commands if MCP tools are unavailable.

Show analytics and ROI metrics for your context library.

## Quick Start

```bash
btr stats [--format json|table]
```

## Metrics Displayed

- **Total Contexts**: Number of stored knowledge items
- **Contexts by Domain**: Distribution across domains
- **Most Retrieved**: Top 10 most frequently accessed contexts
- **Total Retrievals**: How many times contexts have been used
- **Estimated Time Saved**: Based on usage count x avg retrieval time (15 min)

## Example Output

```
BTR Statistics
====================

Total Contexts:     42
Total Domains:      8
Total Retrievals:   156

Estimated Time Saved: 39 hours

Top Domains:
  auth:       12 contexts (45 retrievals)
  api:        10 contexts (38 retrievals)
  database:    8 contexts (29 retrievals)

Most Retrieved:
  1. auth/jwt-validation (23 retrievals)
  2. api/rate-limiting (18 retrievals)
  3. database/connection-pooling (15 retrievals)
```

## Command Options

### Basic Statistics

```bash
btr stats
```

Shows overall statistics in a human-readable table format.

### JSON Output

```bash
btr stats --format json
```

Outputs structured JSON for programmatic use or dashboards.

### Time Period Filter

```bash
btr stats --period 30d   # Last 30 days
btr stats --period 7d    # Last 7 days
btr stats --period 1y    # Last year
```

### Domain-Specific Stats

```bash
btr stats --domain auth
```

Shows detailed statistics for a specific domain.

## Understanding ROI Metrics

### Time Saved Calculation

The time saved estimate is calculated as:

```
Time Saved = Total Retrievals x Average Time to Find Info Manually

Where:
- Average Time to Find Info Manually = 15 minutes (default)
- This accounts for searching docs, Stack Overflow, or reimplementing
```

### Value Proposition

| Retrievals | Time Saved | Equivalent Value* |
|------------|------------|-------------------|
| 10         | 2.5 hours  | $250              |
| 50         | 12.5 hours | $1,250            |
| 100        | 25 hours   | $2,500            |
| 500        | 125 hours  | $12,500           |

*Based on $100/hour developer cost

## Advanced ROI Calculation

For detailed ROI analysis with customizable parameters, run the Python script:

```bash
python .claude/skills/btr-stats/scripts/calculate-roi.py
```

Options:
- `--hourly-rate`: Developer hourly rate (default: $100)
- `--avg-time`: Average manual search time in minutes (default: 15)
- `--format`: Output format (json, csv, markdown)

## Tracking Tips

1. **Consistent Retrieval**: Use `btr query` to ensure retrievals are tracked

2. **Review Regularly**: Check stats monthly to identify valuable patterns

3. **Prune Unused**: Remove contexts with zero retrievals after 90 days

4. **Enhance Popular**: Add more detail to frequently-accessed contexts

## Integration with Dashboards

Export stats for external dashboards:

```bash
# Daily export to JSON
btr stats --format json > /path/to/metrics/btr-$(date +%Y%m%d).json

# Append to CSV log
btr stats --format csv >> /path/to/metrics/btr-stats.csv
```
