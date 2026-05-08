---
name: status-overview
description: Role and project workload overview. Use when user wants to see their current workload, role balance, or status across roles/projects. Auto-triggers on phrases like "how am I doing", "workload", "what's on my plate", "role balance", "project status", "hur ligger jag till", "arbetsbelastning", "rollbalans".
allowed-tools: Bash, Read
---

# Skill: status-overview

## Purpose

Provides clear visibility into workload across roles and projects. Helps users understand their current balance, identify attention items (overdue, stale), and make informed decisions about where to focus.

## Trigger Conditions

- **Slash command:** `/overview [role]`
- **Natural phrases:** ["how am I doing", "workload", "what's on my plate", "role balance", "project status", "hur ligger jag till", "arbetsbelastning", "rollbalans", "visa status", "hur ser det ut", "översikt"]
- **Auto-trigger:** When user asks about their current status or workload

## Required Context (gather BEFORE starting workflow)

1. Active roles via `roles getActiveRoles` → returns Role[] for overview
2. Overdue tasks via `tasks getOverdueTasks` → returns Task[] for attention flags
3. Stale tasks via `tasks getStaleTasks` → returns Task[] for attention flags
4. Profile via `profile getProfile` → returns full profile (optional, for role balance targets)

**How to gather context:**
```bash
# Get all active roles
bun run src/aida-cli.ts roles getActiveRoles

# Get overdue tasks (attention flags)
bun run src/aida-cli.ts tasks getOverdueTasks

# Get stale tasks (attention flags)
bun run src/aida-cli.ts tasks getStaleTasks

# Get profile (optional, for balance targets)
bun run src/aida-cli.ts profile getProfile
```

## Workflow Steps

### Mode Selection

Determine which mode based on user input:
- **Mode 1:** General overview (no role specified)
- **Mode 2:** Role-specific overview (role name/ID provided)

### Mode 1: General Overview

**Trigger:** `/overview` or "hur ligger jag till"

#### Step 1: Gather Role Data

- **Action:** For each active role, get task counts via `tasks getTasksByRole [role_id]`
- **CLI calls:**
  ```bash
  # For each role from getActiveRoles:
  bun run src/aida-cli.ts tasks getTasksByRole [role_id]
  ```
- **Output to user:** None yet
- **Wait for:** Continue immediately

#### Step 2: Calculate Balance

See [ROLE-BALANCE.md](ROLE-BALANCE.md) for balance calculations.

- **Action:** Calculate percentage of tasks per role vs profile balance targets
- **Output to user:** None yet
- **Wait for:** Continue immediately

#### Step 3: Identify Attention Items

See [ATTENTION-FLAGS.md](ATTENTION-FLAGS.md) for criteria.

- **Action:** Flag overdue tasks, stale tasks, imbalanced roles
- **Output to user:** None yet
- **Wait for:** Continue immediately

#### Step 4: Present Summary

- **Output to user:**
  ```
  📊 Din arbetsbelastning

  [Table with roles, task counts, balance percentages]

  ⚠️ Kräver uppmärksamhet:
  • [attention items]

  Vill du se detaljer för en roll? (/overview [roll])
  ```
- **Wait for:** User may request role-specific view

### Mode 2: Role-Specific Overview

**Trigger:** `/overview Developer` or "hur ligger Developer-rollen till"

#### Step 1: Get Role Details

- **Action:** Fetch role via `roles getRoleById [id]` and tasks via `tasks getTasksByRole [id]`
- **CLI calls:**
  ```bash
  bun run src/aida-cli.ts roles getRoleById [id]
  bun run src/aida-cli.ts tasks getTasksByRole [id]
  bun run src/aida-cli.ts projects getProjectsByRole [id]
  ```
- **Output to user:** None yet
- **Wait for:** Continue immediately

#### Step 2: Group by Status and Project

- **Action:** Count tasks by status (captured, ready, planned, active, done), list projects with task counts
- **Output to user:** None yet
- **Wait for:** Continue immediately

#### Step 3: Identify Role-Specific Attention Items

- **Action:** Flag overdue/stale tasks specific to this role
- **Output to user:** None yet
- **Wait for:** Continue immediately

#### Step 4: Present Role Breakdown

- **Output to user:**
  ```
  📊 [Role Name] - Status

  📈 Uppgifter:
  • Captured: [n]
  • Ready: [n]
  • Planned: [n]
  • Active: [n]
  • Done (denna vecka): [n]

  📁 Projekt:
  • [project] ([n] tasks, [n] aktiva)

  ⚠️ Kräver uppmärksamhet:
  • [attention items]

  🎯 Förslag:
  [actionable suggestions]
  ```
- **Wait for:** N/A (workflow complete)

## Output Format

- **Language:** Swedish (default)
- **Style:** Clear tables, visual indicators (emoji), actionable insights
- **Structure:** Summary first, details on request (drill-down)

**Example general overview:**
```
📊 Din arbetsbelastning just nu

Du har totalt 28 uppgifter fördelade på 4 roller:

🔹 Systemutvecklare: 12 tasks (43%)
🔹 Förälder: 5 tasks (18%)
🔹 Hobbyutvecklare: 8 tasks (29%)
🔹 Ordförande: 3 tasks (10%)

⚠️ Uppmärksamhetspunkter:
• 2 försenade tasks (båda i Systemutvecklare)
• Förälder-rollen under mål (18% vs 25%)

Vill du gå djupare i någon roll?
```

**Example role-specific:**
```
📊 Förälder - Status

📋 Uppgifter (5 totalt):
✅ Captured: 2
✅ Ready: 2
✅ Planned: 1
⏳ Active: 0

Inga försenade eller stale tasks! 👏

📅 Kommande:
• "Boka tandläkartid" - Deadline imorgon

💡 Du har inga aktiva tasks just nu.
Vill du aktivera någon? (/next)
```

## Error Handling

- **If `roles getActiveRoles` returns empty:** Show message "Inga roller finns ännu. Du behöver skapa roller via profile-management först."
- **If no tasks exist:** Show empty state "Inga uppgifter ännu. Vill du fånga något nytt?" and suggest task-capture
- **If role not found (Mode 2):** Show error "Rollen '[name]' hittades inte. Tillgängliga roller: [list]"
- **If `tasks getTasksByRole` fails:** Show error message, skip that role in overview
- **If profile doesn't exist or no balance targets:** Skip balance comparison, just show task counts
- **If no attention items:** Show positive message "Allt ser bra ut! 👏"

## Anti-patterns

- **NEVER show raw task counts without context** - always include interpretation/insights
- **NEVER skip overdue/stale warnings** - these must always be highlighted
- **NEVER present all tasks** - show counts and drill-down options, not full lists
- **NEVER modify data** - this is a read-only skill
- **NEVER create tasks, journal entries, or update profile** - only display information
- **NEVER ignore imbalances** - if role balance differs from targets, mention it
- **NEVER use direct SQL** - always use aida-cli.ts
- **NEVER run query modules directly**

## Tool Contract

**Allowed CLI Operations:**
- **tasks:** getTasksByRole, getOverdueTasks, getStaleTasks, getTodayTasks (READ ONLY)
- **roles:** getActiveRoles, getRoleById (READ ONLY)
- **projects:** getProjectsByRole, getActiveProjects (READ ONLY)
- **profile:** getProfile, getAttribute (READ ONLY)

**Forbidden Operations:**
- Creating tasks
- Modifying task status
- Updating profile
- Creating journal entries
- Any delete operations

**Output Only:**
- Formatted workload summary
- Attention flags (overdue, stale, imbalance warnings)
- No data modifications

**File Access:**
- **Read:** `personal-profile.json`
- **No file writes** - Read-only skill

## Supporting Documentation

- [ROLE-BALANCE.md](ROLE-BALANCE.md) - Balance target calculations
- [ATTENTION-FLAGS.md](ATTENTION-FLAGS.md) - What deserves attention

## Design Principles

1. **Actionable insights** - Don't just show data, interpret it
2. **Highlight problems** - Overdue and stale items need attention
3. **Show balance** - Compare actual vs target role distribution
4. **Enable drill-down** - Overview → Role → Task
5. **No overwhelm** - Summary first, details on request
