---
name: ios-game-testing
description: Test the Nathaniel iOS game in simulator. Use when asked to test the game, verify changes work, run sanity tests, check if a feature works, or when the user says "test this", "run the game", "verify it works", "check in simulator".
allowed-tools: Bash, Read, Glob, Grep, mcp__XcodeBuildMCP__build_sim, mcp__XcodeBuildMCP__build_run_sim, mcp__XcodeBuildMCP__open_sim, mcp__XcodeBuildMCP__boot_sim, mcp__XcodeBuildMCP__list_sims, mcp__XcodeBuildMCP__screenshot, mcp__XcodeBuildMCP__session-set-defaults
---

# iOS Game Testing for Nathaniel

This skill provides reliable testing of the Nathaniel SpriteKit game using the embedded GameCommandServer HTTP API.

## Key Insight: Use GameCommandServer, Not XcodeBuildMCP UI Tools

**IMPORTANT**: The game is a landscape SpriteKit game. XcodeBuildMCP's `tap`, `describe_ui`, and other UI interaction tools have coordinate transformation issues with landscape games.

**Always use the GameCommandServer HTTP API** (port 8765) for UI interaction instead. It works directly with SpriteKit scene coordinates and is far more reliable.

## Quick Start: Test a Feature

```bash
# 1. Build and run (sets up session defaults automatically)
# Use XcodeBuildMCP to build and launch

# 2. Wait for game to load, then check server health
curl -s http://localhost:8765/health

# 3. Get current game state
curl -s http://localhost:8765/state | jq .

# 4. Navigate and interact using actions (preferred) or taps
curl -s http://localhost:8765/action -X POST -H "Content-Type: application/json" -d '{"name":"startGame"}'
```

## Testing Workflow

### Step 1: Setup Simulator and Build

```bash
# Set session defaults for XcodeBuildMCP
mcp__XcodeBuildMCP__session-set-defaults:
  projectPath: /Users/ruairi/dev/Nathaniel/Nathaniel.xcodeproj
  scheme: Nathaniel iOS
  simulatorId: <UUID from list_sims with iOS 26.1+>
  useLatestOS: true

# Build and run
mcp__XcodeBuildMCP__build_run_sim
```

**Simulator Requirements**: Use iOS 26.1+ simulators (iPhone 17 Pro, etc.)

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
# Returns: all tappable elements with frame coordinates
```

**Tap at coordinates (scene coordinates, not screen):**
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

Use XcodeBuildMCP screenshot for visual verification (this works fine):

```bash
mcp__XcodeBuildMCP__screenshot
```

Or get base64 screenshot from GameCommandServer:
```bash
curl -s http://localhost:8765/screenshot | jq -r .data | base64 -d > screenshot.png
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
- `targetEnemy` (params: index) - Target enemy by index

### OptionsScene / CreditsScene
- `back` - Return to main menu

## Common Test Scenarios

### Test Character Toggle Button
```bash
# Navigate to level 1
curl -s http://localhost:8765/action -X POST -d '{"name":"startGame"}'
sleep 1
curl -s http://localhost:8765/action -X POST -d '{"name":"level_1"}'
sleep 2

# Check initial state (should be Nathaniel selected)
curl -s http://localhost:8765/state | jq '.playerPosition, .hermesPosition'

# Get nodes to find toggle button
curl -s http://localhost:8765/nodes | jq '.[] | select(.name | contains("toggle"))'

# Tap the toggle button (find coordinates from nodes)
# Or tap in the HUD area where the toggle button should be
```

### Test Camera Follows Character
```bash
# Get initial camera position (check state)
curl -s http://localhost:8765/state

# Select Hermes (should animate camera to Hermes)
curl -s http://localhost:8765/action -X POST -d '{"name":"selectHermes"}'

# Wait for animation
sleep 0.5

# Check state again - camera should have moved toward Hermes
curl -s http://localhost:8765/state
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `curl: Connection refused` | App not running or GameCommandServer not started (DEBUG builds only) |
| Actions return "not found" | Wrong scene - check `state.scene` first |
| Taps don't work | Verify coordinates are in scene space (use `/nodes` to get frames) |
| Build fails | Check simulator UUID is iOS 26.1+, run `list_sims` |

## Important Notes

- GameCommandServer only runs in **DEBUG builds**
- Scene coordinates: origin (0,0) is bottom-left, scene size is 1366x1024
- Bundle ID: `com.ruarfff.Nathaniel`
- The game runs in **landscape mode**
