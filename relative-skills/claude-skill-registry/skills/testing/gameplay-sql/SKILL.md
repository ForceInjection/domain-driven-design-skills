---
name: gameplay-sql
description: >-
  Test game mechanics via SQL. Use game_* tools for gameplay flow.
allowed-tools:
  - game_start
  - game_state
  - game_turn
  - game_submit
  - game_find_place
  - game_summary
---

# SQL Gameplay

Test the game through database tools.

> **Announce:** "I'm using gameplay-sql to test via database."

## Game Tools

| Tool | Purpose |
|------|---------|
| `game_start` | Start a new game |
| `game_state` | See current question/guess/candidates |
| `game_turn` | Answer yes/no/not_sure |
| `game_submit` | Submit correct place (give up) |
| `game_find_place` | Search places by name |
| `game_summary` | Review completed session (history + result) |

## Complete Game Flow

### 1. Start a Game

```
game_start(description: "A medieval castle on a hilltop in Poland")
```

Returns: session_id, initial question, top candidates

### 2. Check State (optional)

```
game_state(session_id: "abc123...")
```

Returns: current status, question or guess, top candidates

### 3. Answer Questions

```
game_turn(session_id: "abc123...", answer: "yes")
game_turn(session_id: "abc123...", answer: "no")
game_turn(session_id: "abc123...", answer: "not_sure")
```

Returns: new state after answer

### 4a. If Game Guesses Correctly

```
game_turn(session_id: "abc123...", answer: "yes")
```

Game ends with status: won

### 4b. If Game Gives Up or Guesses Wrong

First, find the correct place:
```
game_find_place(name: "Wawel")
```

Then submit it:
```
game_submit(session_id: "abc123...", osm_id: "way/123456")
```

## Example Session

```
> game_start(description: "A famous tower in Paris")

SESSION: 7f3a2b1c-...

status   | question                          | candidate_count
---------+-----------------------------------+----------------
active   | Is this place in Western Europe?  | 15

TOP CANDIDATES:
place           | confidence
----------------+-----------
Eiffel Tower    | 45%
Notre-Dame      | 22%
Arc de Triomphe | 12%

> game_turn(session_id: "7f3a2b1c-...", answer: "yes")

status | question                    | guess
-------+-----------------------------+------
active | Is it a metal structure?    | 

TOP CANDIDATES:
place           | confidence
----------------+-----------
Eiffel Tower    | 68%
Notre-Dame      | 15%

> game_turn(session_id: "7f3a2b1c-...", answer: "yes")

status | question | guess        | guess_confidence
-------+----------+--------------+-----------------
active |          | Eiffel Tower | 89%

> game_turn(session_id: "7f3a2b1c-...", answer: "yes")

status | 
-------+
won    |
```

## Status Values

- `active` - Game in progress
- `won` - Correct guess confirmed
- `ended` - Game over (gave up or max turns)

## Answer Values

- `yes` - Confirm question or guess
- `no` - Deny question or guess  
- `not_sure` - Skip question (only for questions, not guesses)

## Review Completed Game

```
game_summary(session_id: "abc123...")
```

Returns: description, result (won/lost), place name, trait count, and full question history.
