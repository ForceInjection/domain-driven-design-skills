---
name: mcs-control
description: Control vehicle with natural language. Use when user wants to warm up/cool down the car, lock/unlock doors, start/stop engine, check battery/fuel/location/status, or control charging. Translates phrases like "warm up the car" into mcs CLI commands.
---

# MCS Vehicle Control Skill

Translates natural language vehicle control requests into `mcs` CLI commands.

## Command Mappings

### Climate Control
| Natural Language | Command |
|------------------|---------|
| "warm up the car", "heat the car", "turn on heating" | `mcs climate on` |
| "cool down the car", "turn on AC", "start the AC" | `mcs climate on` |
| "set temperature to X", "make it X degrees" | `mcs climate set --temp X` |
| "turn off climate", "stop heating", "turn off AC" | `mcs climate off` |
| "defrost the windshield", "turn on defrosters" | `mcs climate set --front-defroster` |

### Door Locks
| Natural Language | Command |
|------------------|---------|
| "lock the car", "lock the doors", "lock it" | `mcs lock` |
| "unlock the car", "unlock the doors", "open the locks" | `mcs unlock` |

### Engine Control
| Natural Language | Command |
|------------------|---------|
| "start the car", "start the engine", "turn on the car" | `mcs start` |
| "stop the engine", "turn off the car", "kill the engine" | `mcs stop` |

### Charging (EV/PHEV)
| Natural Language | Command |
|------------------|---------|
| "start charging", "charge the car", "plug it in" | `mcs charge start` |
| "stop charging", "stop the charge" | `mcs charge stop` |

### Status Queries
| Natural Language | Command |
|------------------|---------|
| "what's the status", "show status", "how's the car" | `mcs status` |
| "check the battery", "battery level", "how much charge" | `mcs status` (show battery section) |
| "check fuel", "fuel level", "how much gas" | `mcs status` (show fuel section) |
| "where is my car", "find my car", "car location" | `mcs status` (show location) |
| "check tire pressure", "how are the tires" | `mcs status` (show tires section) |
| "are the doors locked", "door status" | `mcs status` (show doors section) |

## Execution Guidelines

1. **Run the command** using the Bash tool
2. **Show the output** to the user in a friendly format
3. **For control commands**, the CLI will confirm the action completed
4. **For status queries**, highlight the relevant information

## Confirmation Flags

Control commands support `--confirm` to wait for vehicle confirmation:
- `--confirm` - Wait for vehicle to report state change (default: enabled)
- `--confirm=false` - Don't wait for confirmation
- `--confirm-wait 3m` - Custom timeout (default: 2 minutes)

Use `--confirm` for important actions where the user wants to be sure it worked.

## Examples

### Example 1: Warming up the car
User: "It's freezing, can you warm up the car?"
```bash
mcs climate on
```

### Example 2: Checking battery before a trip
User: "How much battery do I have left?"
```bash
mcs status
```
Then show the battery level and range from the output.

### Example 3: Securing the car
User: "Lock the car and make sure it's locked"
```bash
mcs lock --confirm
```

### Example 4: Setting specific temperature
User: "Set the car to 24 degrees"
```bash
mcs climate set --temp 24
```

## Error Handling

- If the command fails, show the error message to the user
- Common issues:
  - "not configured" - User needs to set up ~/.config/mcs/config.toml
  - "token expired" - Will auto-refresh, retry the command
  - "vehicle not responding" - Vehicle may be in low-signal area

## JSON Output

For programmatic access, add `--json` flag to status:
```bash
mcs status --json
```
