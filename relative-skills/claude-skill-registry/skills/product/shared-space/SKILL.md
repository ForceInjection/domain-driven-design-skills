---
name: shared-space
description: Manages shared ledgers for family or team collaboration, including shared account summaries, spending statistics, and member settlements. Use when user asks about shared expenses, family ledger, team budget, or joint accounts. 关键词：共享账本、家庭账单、团队支出、AA制。
license: Apache-2.0
metadata:
  type: collaboration
  version: "1.1"
allowed-tools: execute read_file ls
---

# Skill: Shared Space
Responsible for handling collaboration logic for family or team shared ledgers.

## Use Cases
- User asks: "What is my family's spending this month?"
- User requests: "Show me the team expense summary."
- User asks: "How much did we spend together?"

## Available Scripts

| Script | Purpose | Output |
|--------|---------|--------|
| `app/skills/shared-space/scripts/list_spaces.py` | List user's shared spaces | Space list JSON |
| `app/skills/shared-space/scripts/query_space_summary.py` | Query spending summary | Summary with monthly stats |

### list_spaces.py - Get Available Spaces
```bash
uv run python app/skills/shared-space/scripts/list_spaces.py
```

Returns a list of shared spaces the user has access to, with role information.

### query_space_summary.py - Space Summary
```bash
uv run python app/skills/shared-space/scripts/query_space_summary.py
```

Query a specific space:
```bash
echo '{"space_id": "uuid-string"}' | uv run python app/skills/shared-space/scripts/query_space_summary.py
```

Returns monthly spending statistics for the space.

## Workflows

### 1. Discovery - List Available Spaces
**Triggers**: "What shared spaces do I have?", "Show my shared accounts"

Run `list_spaces.py` and present the available spaces to the user.

### 2. Summary Query
**Triggers**: "Family spending this month", "Team expense report"

Run `query_space_summary.py` and summarize the spending data.

## Rules
- Only used for processing ledger data with "shared" or "multi-user" context.
- **For transfers, guide the user to use the Transfer Expert skill.**
- **For recording transactions to a space, use the normal record_transactions tool** and the AI should naturally associate it if context indicates a shared space.
- **Localization**: Localize all your responses back to the current session language.
