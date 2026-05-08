---
name: macos-game-testing
description: Test the Nathaniel macOS game. Use when asked to test the macOS version, verify changes work on Mac, run sanity tests on desktop, or when the user says "test macOS", "run on mac", "verify mac build".
allowed-tools: Bash, Read, Glob, Grep, mcp__XcodeBuildMCP__build_macos, mcp__XcodeBuildMCP__build_run_macos, mcp__XcodeBuildMCP__get_mac_app_path, mcp__XcodeBuildMCP__launch_mac_app, mcp__XcodeBuildMCP__stop_mac_app, mcp__XcodeBuildMCP__list_schemes, mcp__XcodeBuildMCP__session-set-defaults
---

# macOS Game Testing for Nathaniel

This skill provides reliable testing of the Nathaniel SpriteKit game on macOS using the embedded GameCommandServer HTTP API.

## Key Insight: Use GameCommandServer for All Interaction

The game uses SpriteKit with custom scene coordinates. Unlike iOS Simulator, there are no reliable external UI automation tools for macOS SpriteKit games.

**Always use the GameCommandServer HTTP API** (port 8765) for:
- Navigating menus
- Clicking buttons
- Getting game state
- Interacting with gameplay
- Taking screenshots

XcodeBuildMCP is used only for: building, running, and stopping the app.

## Quick Start: Test a Feature

```bash
# 1. Build and run the macOS app
mcp__XcodeBuildMCP__build_run_macos

# 2. Wait 2-3 seconds for app to load, then check server health
curl -s http://localhost:8765/health

# 3. Get current game state
curl -s http://localhost:8765/state | jq .

# 4. Navigate and interact using actions
curl -s http://localhost:8765/action -X POST -H "Content-Type: application/json" -d '{"name":"startGame"}'
```

## Testing Workflow

### Step 1: Setup and Build

```bash
# Set session defaults for XcodeBuildMCP
mcp__XcodeBuildMCP__session-set-defaults:
  projectPath: /Users/ruairi/dev/Nathaniel/Nathaniel.xcodeproj
  scheme: Nathaniel macOS

# Build and run (opens the app automatically)
mcp__XcodeBuildMCP__build_run_macos
```

### Step 2: Wait for GameCommandServer

After the app launches, wait 2-3 seconds, then verify the server is running:

```bash
# Check health - should return {"status":"ok"}
curl -s http://localhost:8765/health
```

If it fails, the app may not have fully launched. Wait and retry.

### Step 3: Navigate to Test Location

Use the HTTP API to navigate through menus:

**Main Menu -> Level Select:**
```bash
curl -s http://localhost:8765/action -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"startGame"}'
```

**Level Select -> Level 1:**
```bash
curl -s http://localhost:8765/action -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"level_1"}'
```

### Step 4: Interact with Game

**Get game state:**
```bash
curl -s http://localhost:8765/state | jq .
# Returns: scene, score, lives, resources, playerPosition, hermesPosition, enemyCount
```

**Get interactive nodes:**
```bash
curl -s http://localhost:8765/nodes | jq .
# Returns: all clickable elements with frame coordinates
```

**Click at coordinates (scene coordinates, not screen):**
```bash
curl -s http://localhost:8765/tap -X POST \
  -H "Content-Type: application/json" \
  -d '{"x": 500, "y": 300}'
```

**Execute named actions:**
```bash
# Select characters
curl -s http://localhost:8765/action -X POST -d '{"name":"selectNathaniel"}'
curl -s http://localhost:8765/action -X POST -d '{"name":"selectHermes"}'

# Toggle between characters (switches and animates camera)
curl -s http://localhost:8765/action -X POST -d '{"name":"toggleCharacter"}'

# Move character
curl -s http://localhost:8765/action -X POST -d '{"name":"moveNathaniel","params":{"x":"500","y":"300"}}'

# Target enemy
curl -s http://localhost:8765/action -X POST -d '{"name":"targetEnemy","params":{"index":"0"}}'
```

### Step 5: Visual Verification

Get screenshot from GameCommandServer and save to file:

```bash
# Save screenshot as PNG file
curl -s http://localhost:8765/screenshot | jq -r .data | base64 -d > /tmp/macos-screenshot.png

# View the screenshot
open /tmp/macos-screenshot.png
```

Or use macOS screencapture for the entire window:

```bash
# Capture the Nathaniel window
screencapture -l $(osascript -e 'tell app "Nathaniel" to id of window 1') /tmp/nathaniel-window.png
```

### Step 6: Stop the App

```bash
mcp__XcodeBuildMCP__stop_mac_app:
  appName: Nathaniel
```

## Available Actions by Scene

### MainMenuScene
- `startGame` - Go to level select
- `options` - Open options
- `credits` - Open credits

### LevelSelectScene
- `level_1` through `level_5` - Start specific level
- `back` - Return to main menu

### GameScene
- `selectNathaniel` - Select Nathaniel
- `selectHermes` - Select Hermes
- `toggleCharacter` - Toggle between Nathaniel and Hermes (animates camera)
- `moveNathaniel` (params: x, y) - Move to position
- `moveHermes` (params: x, y) - Move Hermes to position
- `targetEnemy` (params: index) - Target enemy by index

### OptionsScene / CreditsScene
- `back` - Return to main menu

## DevSettings (DEBUG Builds Only)

Adjust game settings for easier testing:

```bash
# Get current settings
curl -s http://localhost:8765/settings | jq .

# Make player invincible
curl -s http://localhost:8765/settings -X POST \
  -H "Content-Type: application/json" \
  -d '{"playerInvincible": true}'

# Give infinite resources
curl -s http://localhost:8765/settings -X POST \
  -H "Content-Type: application/json" \
  -d '{"infiniteResources": true}'

# Reset all settings to defaults
curl -s http://localhost:8765/settings/reset -X POST
```

## Common Test Scenarios

### Test Menu Navigation
```bash
# Start at main menu
curl -s http://localhost:8765/state | jq '.scene'
# Should be "MainMenuScene"

# Go to level select
curl -s http://localhost:8765/action -X POST -d '{"name":"startGame"}'
sleep 0.5
curl -s http://localhost:8765/state | jq '.scene'
# Should be "LevelSelectScene"

# Go back
curl -s http://localhost:8765/action -X POST -d '{"name":"back"}'
sleep 0.5
curl -s http://localhost:8765/state | jq '.scene'
# Should be "MainMenuScene"
```

### Test Gameplay
```bash
# Navigate to level 1
curl -s http://localhost:8765/action -X POST -d '{"name":"startGame"}'
sleep 0.5
curl -s http://localhost:8765/action -X POST -d '{"name":"level_1"}'
sleep 2

# Check initial state
curl -s http://localhost:8765/state | jq '{scene, lives, enemyCount}'

# Select Hermes and move
curl -s http://localhost:8765/action -X POST -d '{"name":"selectHermes"}'
curl -s http://localhost:8765/action -X POST -d '{"name":"moveHermes","params":{"x":"600","y":"400"}}'
```

### Test Character Toggle
```bash
# In GameScene, toggle between characters
curl -s http://localhost:8765/action -X POST -d '{"name":"toggleCharacter"}'
sleep 0.5
# Take screenshot to verify camera moved
curl -s http://localhost:8765/screenshot | jq -r .data | base64 -d > /tmp/after-toggle.png
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `curl: Connection refused` | App not running or GameCommandServer not started (DEBUG builds only) |
| Actions return "not found" | Wrong scene - check `state.scene` first |
| Clicks don't register | Verify coordinates are in scene space (use `/nodes` to get frames) |
| Build fails | Check Xcode is installed, try `xcodebuild -version` |
| App won't stop | Use `pkill -f Nathaniel` or Activity Monitor |

## Important Notes

- GameCommandServer only runs in **DEBUG builds**
- Scene coordinates: origin (0,0) is bottom-left, scene size is 1366x1024
- Bundle ID: `com.ruarfff.Nathaniel`
- The game runs in **landscape mode** (window is wider than tall)
- Port 8765 is shared between iOS Simulator and macOS - only run one at a time
