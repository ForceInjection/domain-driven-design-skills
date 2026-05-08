---
name: vault-health
description: Comprehensive vault diagnostics and health report. Triggers when user mentions "vault health", "health report", "vault diagnostics".
auto_trigger: true
trigger_keywords:
  - "vault health"
  - "health report"
  - "vault diagnostics"
  - "vault status"
  - "vault report"
  - "how is my vault"
  - "vault overview"
  - "vault checkup"
  - "how's my vault"
  - "vault condition"
  - "knowledge base health"
  - "vault stats"
  - "check vault"
  - "diagnose vault"
  - "vault summary"
allowed-tools: mcp__flywheel__get_vault_stats, mcp__flywheel__find_broken_links
---

# Vault Health

Quick vault diagnostics and health assessment.

## When to Use

Invoke when you want to:
- Check overall vault health
- See broken link count
- Identify top hubs (most connected notes)
- Get recommendations for maintenance

## Process

### 1. Get Vault Statistics
Call `mcp__flywheel__get_vault_stats` to retrieve:
- Total notes
- Total links
- Average links per note
- Orphan count
- Broken link count
- Top connected notes (hubs)
- Tag distribution
- Folder breakdown

### 2. Assess Health
Calculate vault health score based on:
- Broken links percentage (lower is better)
- Orphan percentage (lower is better)
- Average connectivity (higher is better)
- Link growth trend

### 3. Generate Report
Format comprehensive health report:

```
Vault Health Report
═══════════════════════════════════════════════
📊 Overview:
  • Total Notes: 1,000
  • Total Links: 15,000
  • Average Links/Note: 15.0

⚠️ Issues Found:
  • Broken Links: 200 (1.3% of all links)
  • Orphan Notes: 100 (10% of all notes)

🌟 Top Hubs:
  1. [[Project A]] - 150 backlinks
  2. [[Technology X]] - 120 backlinks
  3. [[Daily Workflow]] - 100 backlinks

📈 Vault Health Score: 85% (Good)

💡 Recommendations:
  • Run /vault-fix-links to repair broken links
  • Review /orphans to connect isolated notes
═══════════════════════════════════════════════
```

### 4. Provide Action Items
Link to relevant skills based on issues found:
- Many broken links → Suggest `/vault-fix-links`
- Many orphans → Suggest `/orphans`
- Low connectivity → Suggest `/suggest` for link suggestions

## Health Score Calculation

```
Base Score: 100%

Deductions:
- Broken links: -0.5% per 1% of total links broken
- Orphans: -0.3% per 1% of notes orphaned
- Low connectivity: -10% if avg < 5 links/note

Bonuses:
- High connectivity: +5% if avg > 15 links/note
- Few orphans: +5% if orphan% < 10%
- Few broken: +5% if broken% < 5%

Final Score: 0-100%
  90-100%: Excellent ✅
  75-89%: Good 👍
  60-74%: Fair ⚠️
  <60%: Needs Attention 🚨
```

## Output Format

Always use the branded format:

```
Vault Health Report
═══════════════════════════════════════════════

[Report content here]

═══════════════════════════════════════════════
```

## Performance

- **Speed**: 2-3 seconds (single MCP call)
- **Accuracy**: 100% (direct from Flywheel MCP)
- **Caching**: None needed (live data)
