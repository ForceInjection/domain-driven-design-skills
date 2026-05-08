---
name: create-game-assets
description: Generate game assets (sprites, UI icons, backgrounds, tilesets) using DALL-E 3 from a YAML specification file. Use when user asks to create game art, generate sprites, or make game graphics.
---

# Create Game Assets Skill

## When to Use This Skill

- User asks to generate game assets, sprites, or game art
- User wants to create UI icons, character sprites, backgrounds, or tilesets
- User mentions DALL-E or AI image generation for games
- User has a YAML asset specification file

## Prerequisites

- `OPENAI_API_KEY` environment variable must be set
- Node.js installed
- Run `npm install` in the skill folder first

## How It Works

1. Ask user what game assets they need (characters, items, backgrounds, style)
2. Create an `assets.yaml` specification file based on their requirements
3. Review the spec with `--dry-run` to preview prompts
4. Run the generator to create images via DALL-E 3
5. Images are saved organized by type with metadata

## Procedure

```bash
# Navigate to the skill script
cd ~/projects/ai-tools/skills/create-game-assets

# Install dependencies (first time only)
npm install

# Preview what will be generated
npx tsx src/index.ts --spec /path/to/assets.yaml --dry-run

# Generate the assets
npx tsx src/index.ts --spec /path/to/assets.yaml --output /path/to/output
```

## Asset Specification Format

Create a YAML file like this:

```yaml
project: my-game
style: pixel-art-16bit  # or: hand-drawn, vector, 3d-render, realistic
outputDir: ./assets

assets:
  - type: character
    name: player
    description: "Knight in silver armor, front view"
    size: 1024x1024
    variants: 2

  - type: ui-icon
    name: health-potion
    description: "Red potion in glass bottle"

  - type: background
    name: forest
    description: "Magical forest with glowing mushrooms"
    size: 1792x1024
```

## Asset Types

- `character` - Players, NPCs, enemies (centered, full body)
- `ui-icon` - Inventory items, buttons, status icons
- `background` - Level backgrounds, title screens
- `tileset` - Seamless tiles for game maps

## Style Presets

- `pixel-art-16bit` - Retro 16-bit pixel art
- `hand-drawn` - Illustrated sketch style
- `vector` - Clean flat vector graphics
- `3d-render` - 3D rendered with soft lighting
- `realistic` - Photorealistic textures

## Output

```
outputDir/
├── characters/
│   ├── player-1.png
│   └── player.meta.json
├── ui-icons/
│   └── health-potion.png
└── manifest.json
```

## Examples

**User**: "Generate pixel art sprites for my platformer game"

**Expected behavior**:
1. Ask what assets they need (characters, enemies, items, backgrounds)
2. Ask about art style preference (pixel-art-16bit, hand-drawn, vector, etc.)
3. Ask for descriptions of each asset
4. Create `assets.yaml` with all specifications
5. Run dry-run to preview prompts
6. Generate images after user approval

**User**: "I need a knight character, slime enemy, and health potion for my RPG"

**Expected behavior**:
1. Ask about preferred style
2. Create `assets.yaml`:
```yaml
project: rpg-game
style: pixel-art-16bit
outputDir: ./assets

assets:
  - type: character
    name: knight
    description: "Knight in silver armor with sword and shield, heroic pose"
    size: 1024x1024
    variants: 2

  - type: character
    name: slime-enemy
    description: "Green slime monster with angry expression"
    size: 1024x1024

  - type: ui-icon
    name: health-potion
    description: "Red healing potion in glass bottle"
    size: 1024x1024
```
3. Show dry-run preview
4. Generate after approval

**User**: "Use create-game-assets to generate assets from my spec.yaml"

**Expected behavior**:
1. Read the existing spec.yaml file
2. Show dry-run preview
3. Generate images to specified output directory
