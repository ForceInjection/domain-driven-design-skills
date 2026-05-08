---
name: task-activation
description: Help user START tasks with activation support for ADHD. Use when user is stuck, overwhelmed, or asking what to do next. Auto-triggers on phrases like "I'm stuck", "can't get started", "overwhelmed", "what should I do", "next step", "where do I start", "jag fastnar", "kan inte börja", "vad ska jag göra", "nästa steg".
allowed-tools: Bash, Read
---

# Skill: task-activation

## Purpose

Provides activation support to help users START tasks, not just plan them. Addresses executive function challenges by removing barriers to beginning. Based on ADHD-friendly techniques like the 5-minute rule and smallest-step extraction.

## Trigger Conditions

- **Slash command:** `/next`
- **Natural phrases:** ["I'm stuck", "can't get started", "overwhelmed", "what should I do", "next step", "where do I start", "jag fastnar", "kan inte börja", "vad ska jag göra", "nästa steg", "hjälp mig börja", "orkar inte", "vet inte var jag ska börja"]
- **Auto-trigger:** When user expresses difficulty starting or choosing tasks

## Required Context (gather BEFORE starting workflow)

1. Today's tasks via `tasks getTodayTasks` → returns Map<roleId, Task[]> for selection
2. Current energy level via `profile getCurrentEnergyLevel` → returns "high"|"medium"|"low" for matching
3. Profile via `profile getProfile` → returns full profile for activation preferences and patterns

**How to gather context:**
```bash
# Get today's tasks
bun run src/aida-cli.ts tasks getTodayTasks

# Get current energy level
bun run src/aida-cli.ts profile getCurrentEnergyLevel

# Get user profile (for activation preferences)
bun run src/aida-cli.ts profile getProfile
```

## Workflow Steps

### Step 1: Assess User State

- **Action:** Detect user's current state from conversation
  - "Jag fastnar" → Stuck, needs smallest step
  - "Orkar inte" → Low energy, needs easy win
  - "För mycket" → Overwhelmed, needs ONE thing
  - "Vad ska jag göra?" → Choice paralysis, needs direction
  - No complaint → Just asking for next action
- **Output to user:** None (internal assessment)
- **Wait for:** Continue immediately

See [OVERWHELM-RESPONSE.md](OVERWHELM-RESPONSE.md) for state-specific responses.

### Step 2: Get Available Tasks

- **Action:** Retrieve today's tasks via `tasks getTodayTasks`
- **Output to user:** None
- **Wait for:** Continue immediately (unless no tasks - see Error Handling)

### Step 3: Select Best Task

See [ENERGY-AWARE-SELECTION.md](ENERGY-AWARE-SELECTION.md) for detailed selection rules.

- **Action:** Select ONE task based on:
  1. User's current energy level
  2. Time of day (from user's energy pattern)
  3. Task energy requirements
  4. Deadlines
  5. Task status (ready > planned > captured)
- **Output to user:** None yet
- **Wait for:** Continue immediately

### Step 4: Apply Activation Technique

See [ACTIVATION-TECHNIQUES.md](ACTIVATION-TECHNIQUES.md) for detailed techniques.

- **Action:** Choose technique based on user state:
  - Stuck → Extract smallest first step
  - Overwhelmed → One thing only, 5-minute rule
  - Low energy → Easy win first
  - Choice paralysis → Make the choice for them
- **Output to user:** None yet
- **Wait for:** Continue immediately

### Step 5: Present Single Action

- **Output to user:**
  ```
  🎯 Nästa steg:

  [One concrete action]

  Du behöver bara göra 5 minuter - sedan kan du bestämma om du vill fortsätta.

  Ska vi köra?
  ```
- **Wait for:** User confirms they're starting (or declines)

### Step 6: Log Activation

- **Action when user confirms:**
  ```bash
  bun run src/aida-cli.ts tasks setTaskStatus [id] "active"
  bun run src/aida-cli.ts journal createEntry '{"entry_type":"task","content":"Aktiverade: [task title]"}'
  ```
- **Output to user:** "Perfekt! Kör igång 🚀"
- **Wait for:** N/A (workflow complete)

## Output Format

- **Language:** Swedish (default)
- **Style:** Encouraging, non-judgmental, supportive
- **Action:** ONE concrete step only, never multiple options
- **Tone:** No guilt, no pressure, frame deferrals positively

**Example for simple "what's next":**
```
🎯 Nästa steg för dig:

**Öppna rapporten** (Digitaliseringssamordnare)
- Deadline: imorgon
- Bara öppna filen och läs första stycket

5 minuter - sedan bestämmer du om du fortsätter. Kör! 🚀
```

**Example for overwhelmed:**
```
Jag hör dig. Låt oss göra det enkelt.

Glöm allt annat just nu. EN sak:

🎯 **Ringa banken** (2 min)
   - Ta upp telefonen
   - Slå numret
   - Klart!

Det är allt. Resten kan vänta.

Redo?
```

## Error Handling

- **If `tasks getTodayTasks` returns empty:** Show message "Inga uppgifter för idag. Vill du fånga något nytt?" and suggest task-capture skill
- **If no tasks match energy level:** Adjust matching criteria, or suggest a break/pause with message "Alla uppgifter kräver mer energi än du har just nu. Vill du ta en paus?"
- **If user is overwhelmed but no easy tasks:** Find ANY task and break it into smallest possible step, even if artificially small
- **If task already active:** Ask "Du har redan en aktiv uppgift: [task]. Vill du byta till något annat?"
- **If `setTaskStatus` fails:** Log error to console, inform user task activation wasn't recorded but they can still work on it
- **If `journal createEntry` fails:** Task status is still updated, just log warning to console
- **If profile doesn't exist:** Use default energy level "medium" and proceed with general activation

## Anti-patterns

- **NEVER recommend high-energy task when energy is low** - always match energy level
- **NEVER skip user confirmation before marking active** - always wait for user to say they're starting
- **NEVER show multiple task options** - always suggest ONE thing only
- **NEVER use guilt or pressure** - frame deferrals as rescheduling, not failure
- **NEVER create new tasks** - only activate existing ones (use task-capture for new tasks)
- **NEVER update task details** - only change status
- **NEVER set status to "cancelled"** - only "active" or "done" allowed
- **NEVER use direct SQL** - always use aida-cli.ts
- **NEVER run query modules directly**

## Tool Contract

**Allowed CLI Operations:**
- **tasks:** getTodayTasks, getTaskById, setTaskStatus (to "active" or "done")
- **journal:** createEntry (type: task) - Log activation/completion
- **profile:** getCurrentEnergyLevel, getProfile (READ ONLY)

**Forbidden Operations:**
- Creating new tasks (use task-capture skill)
- Updating task details (title, description, etc.)
- Deleting tasks
- Updating profile
- Setting status to "cancelled"

**Status Transition Rules:**
- `ready|waiting → active` (when starting task)
- `active → done` (when user indicates completion during activation flow)

**File Access:**
- **Read:** `personal-profile.json`
- **No file writes** - All operations via CLI

## Supporting Documentation

- [ACTIVATION-TECHNIQUES.md](ACTIVATION-TECHNIQUES.md) - 5-minute rule, smallest step, etc.
- [ENERGY-AWARE-SELECTION.md](ENERGY-AWARE-SELECTION.md) - Matching tasks to energy
- [OVERWHELM-RESPONSE.md](OVERWHELM-RESPONSE.md) - Handling stuck/overwhelmed states

## Design Principles

1. **ONE thing** - Never present multiple options
2. **Smallest step** - Break it down until it's obvious
3. **5-minute rule** - Just start, decide later
4. **No guilt** - Deferrals are rescheduling, not failure
5. **Energy-aware** - Don't suggest high-energy tasks when user is drained
6. **Momentum** - Small wins build confidence
