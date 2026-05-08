---
name: enter-world
description: Launch the Adventure Engine application for an adventure project. Use when the user wants to "enter" a world, "start" or "launch" an adventure session, or begin interactive gameplay. Fires off the application in the background using the current working directory as the adventure project root.
---

# Enter World

Launch the Adventure Engine application to begin an interactive adventure session.

## Usage

1. Ensure the current working directory contains a valid adventure project
2. Run the launcher script which will boot the Adventure Engine application in fire-and-forget mode:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/enter-world/scripts/launch-world.sh" "$PWD"
```

To skip opening a browser (useful for remote/headless servers):

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/enter-world/scripts/launch-world.sh" --no-browser "$PWD"
```

The script launches the application asynchronously - control returns immediately to Claude Code while the adventure application runs independently. Output is written to `.adventure-engine.log` in the project directory.

## Script Location

The launcher script is at: `skills/enter-world/scripts/launch-world.sh`

## What the Script Does

- Validates the adventure project directory
- Starts the backend server using `bun run start`
- Waits for server health check (up to 30 seconds)
- Opens the default browser to `http://localhost:3000` (unless `--no-browser` is specified)
- Logs server PID for later shutdown
- Detaches from the terminal (fire and forget)
- All output is logged to `.adventure-engine.log` in the project directory
