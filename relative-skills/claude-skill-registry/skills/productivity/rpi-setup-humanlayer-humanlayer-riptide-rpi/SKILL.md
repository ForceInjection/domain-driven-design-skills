---
name: rpi-setup-humanlayer
description: use this skill when a user asks to set up RPI or a "research plan implement" workflow, or to do anything related to RPI skills. if the user says the acronym "RPI" or "rpi" or "humanlayer", you MUST use this skill! Example questions - "I want to set up rpi for ticket eng-1234" - "Whats the next rpi step for eng-5678"
---

## HumanLayer RPI Setup

You're tasked with setting up a research-plan-implement workflow for a user.

## CRITICAL: Validate Prerequisites First

Before doing ANYTHING else, validate prerequisites. Run these checks in order:

### Step 1: Check HumanLayer CLI
```bash
which humanlayer
```
If not found: "HumanLayer CLI not found. Install via: `brew install humanlayer/tap/humanlayer`"

### Step 2: Check Linear CLI
```bash
which linear
```
If not found: "Linear CLI not found. Install via: `npm install -g @codelayer/linear-cli`"

### Step 3: Check Thoughts Configuration
```bash
humanlayer thoughts status
```
If fails or "Not initialized": "Thoughts not configured. Run: `humanlayer thoughts init`"

### Step 4: Verify Sync Works
```bash
humanlayer thoughts sync
```
If fails, tell user to check their thoughts repository configuration.

### Step 5: Output Test Permalink
Parse `humanlayer thoughts status` output to get:
- "Thoughts directory" line (e.g., `repos/synclayer`)

Get the thoughts repo path and GitHub remote:
```bash
humanlayer thoughts config | grep "Thoughts repository" | awk '{print $NF}'
```
Then:
```bash
git -C <that-path> remote get-url origin
```

Construct and output a test permalink:
```
Prerequisites validated!

Test this permalink opens correctly:
https://github.com/<org>/<repo>/tree/main/<thoughts-directory>/tasks/

If it opens to your tasks directory, you're ready!
```

---

## After Prerequisites Pass

Help the user with their RPI workflow question.

## Example: Setting up a new ticket

```
User: set up rpi for ticket eng-1234
```

1. Run prerequisite checks (steps 1-5)
2. Fetch ticket info: `linear get-issue-v2 eng-1234 --fields=branch`
3. Create task directory: `mkdir -p thoughts/tasks/eng-1234-description`
4. Fetch ticket: `linear get-issue eng-1234 > thoughts/tasks/eng-1234-description/ticket.md`
5. Tell user to start with: `use the create-research-questions skill for thoughts/tasks/eng-1234-description/ticket.md`

## Example: Checking status of existing task

```
User: what's the next rpi step for eng-5678
```

1. Find task dir: `ls thoughts/tasks | grep eng-5678`
2. List contents: `ls thoughts/tasks/eng-5678-...`
3. Based on which files exist, suggest the next skill to use
