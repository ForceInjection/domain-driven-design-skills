---
name: e2e-tester
description: Execute end-to-end test scenarios for the D&D 5E terminal game using terminal-control MCP. This skill should be used when the user requests running test scenarios, creating new test scenarios, or debugging game functionality through automated testing. Requires terminal-control MCP server to be installed and running.
---

# E2E Tester

## Overview

Execute natural language test scenarios for the D&D 5E terminal game by controlling the game through terminal-control MCP, simulating human player interaction, and documenting findings. Both humans and AI can follow the test scenarios, making them useful for manual and automated testing.

## Requirements

**CRITICAL:** This skill requires the `terminal-control` MCP server to be installed and running.

Required MCP tools:
- `mcp__terminal-control__open_terminal` - Start terminal session
- `mcp__terminal-control__send_input` - Send commands to game
- `mcp__terminal-control__get_screen_content` - Read game output
- `mcp__terminal-control__exit_terminal` - Close terminal session

Game entry point: `python -m dnd_engine.main_v2`

## Workflow Decision Tree

When the user makes a testing request, determine the appropriate action:

**User says: "Run the [scenario_name] test"**
→ Execute existing scenario workflow (Step 1)

**User says: "Create a test for [feature]"**
→ Create new scenario workflow (Step 2)

**User says: "Debug [specific issue]"**
→ Create targeted test scenario, then execute (Step 2 → Step 1)

## Step 1: Execute Existing Test Scenario

### 1.1 Read the Scenario File

Read the test scenario from `tests/scenarios/[scenario_name].md`.

### 1.2 Open Terminal Session

Open terminal in project directory:
```
mcp__terminal-control__open_terminal
- shell: bash
- working_directory: /Users/joec/git/rpggame
```

### 1.3 Start the Game

Send command to start game (always include `\n` to execute):
```
mcp__terminal-control__send_input
- session_id: <session_id>
- input_text: "python -m dnd_engine.main_v2\n"
```

Wait 2-3 seconds for game initialization.

### 1.4 Execute Scenario Steps

For each step in the scenario:

1. **Send input** based on the step's instruction
2. **Wait** 1-2 seconds for game to process
3. **Read output** using `get_screen_content` with `content_mode: "since_input"`
4. **Verify** expected outcomes match actual results
5. **Document** any discrepancies, bugs, or unexpected behavior

**Common game commands:**
- Main menu: `1` (New Campaign), `2` (Load Game), `3` (Character Vault), `4` (Exit)
- Navigation: `n`, `s`, `e`, `w` or `north`, `south`, `east`, `west`
- Combat: `attack <number>`, `cast <spell> <target>`, `use <item>`, `flee`
- Information: `look`, `search`, `inventory` or `i`, `status`
- Meta: `help`, `save`, `quit`

**Important notes:**
- Always include `\n` at end of commands to execute them
- Add delays between commands (1-3 seconds) to let game process
- Use `content_mode: "since_input"` to see output since last command
- DEBUG mode may show LLM prompts - this is intentional, not a bug

### 1.5 Document Results

Create `tests/scenarios/RESULTS_[scenario_name].md` with:

```markdown
# Test Results: [Scenario Name]

**Date:** YYYY-MM-DD
**Duration:** X minutes
**Outcome:** PASS / FAIL / PARTIAL

## Expected Outcomes

- ✅ [Outcome that passed]
- ❌ [Outcome that failed]
- ✅ [Another outcome]

## Issues Discovered

### Issue 1: [Title]
- **Severity:** Critical / High / Medium / Low
- **Description:** [What happened]
- **Steps to reproduce:** [How to trigger]
- **Impact:** [Effect on gameplay]
- **Expected behavior:** [What should happen]

### Issue 2: [Title]
[Same structure]

## What Worked Well

- ✓ [Thing that worked]
- ✓ [Another success]

## Recommendations

- [Suggestion for improvement]
- [Another recommendation]
```

### 1.6 Clean Up

Close the terminal session:
```
mcp__terminal-control__exit_terminal
- session_id: <session_id>
```

### 1.7 Report to User

Provide summary of:
- Test outcome (pass/fail/partial)
- Number of issues found
- Key findings
- Path to detailed results file

## Step 2: Create New Test Scenario

### 2.1 Understand Test Objective

Clarify with user if needed:
- What feature or functionality to test?
- What game state is required (new game, existing save, specific dungeon)?
- What are the success criteria?
- Are there specific edge cases to cover?

### 2.2 Write Scenario File

Create `tests/scenarios/[scenario_name].md` using the template from `references/test_scenario_template.md`.

**Template structure:**
- Objective (what this verifies)
- Prerequisites (game state needed)
- Setup Steps (how to prepare)
- Test Actions (what to do)
- Expected Outcomes (success criteria with ✓)
- Failure Conditions (what indicates failure with ✗)
- Notes (timing, edge cases, extensions)

**Writing guidelines:**
- Be specific about commands to type
- Include expected outputs where relevant
- Define clear pass/fail criteria
- Keep scenarios focused on one aspect
- Make steps executable by both human and AI

### 2.3 Execute the New Scenario

Immediately execute the newly created scenario using Step 1 workflow to validate it works.

## Common Patterns

### Pattern 1: Combat Testing
```
1. Load game or create party
2. Enter dungeon
3. Engage enemies
4. Test: attack, spells, items, flee
5. Verify: damage calculation, turn order, death mechanics
```

### Pattern 2: Navigation Testing
```
1. Load game with active party
2. Enter dungeon
3. Navigate all rooms (n/s/e/w)
4. Verify: room descriptions, connections, auto-save
5. Test edge cases: locked doors, dead ends
```

### Pattern 3: Character Management
```
1. Access character vault
2. Create/modify characters
3. Test: leveling, equipment, spells
4. Verify: stat calculations, inventory updates
```

### Pattern 4: Bug Reproduction
```
1. Set up minimal state to trigger bug
2. Execute exact steps that cause issue
3. Document behavior vs expected
4. Test variations to understand scope
```

## Resources

### references/test_scenario_template.md

Contains the standardized template for creating new test scenarios. This template ensures scenarios are:
- Structured consistently
- Executable by both humans and AI
- Clear in success/failure criteria
- Comprehensive in coverage

Use this template when creating new test scenarios in Step 2.2.
