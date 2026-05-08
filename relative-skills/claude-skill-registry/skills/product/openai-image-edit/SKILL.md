---
name: openai-image-edit
description: Edit images via OpenAI gpt-image-1 API. Creates edited or extended images from source images and a prompt. Supports masks for selective editing, multiple input images for compositing, and input fidelity control for preserving facial features. Use when user wants to modify existing images, combine multiple images, remove/replace objects, extend images, or needs AI-powered image editing with reference images.
---

# OpenAI Image Edit (gpt-image-1)

Edit or extend images using OpenAI's gpt-image-1 model with full API parameter support.

## Workflow

### 1. Gather Requirements

Ask clarifying questions **one at a time** when needed:

| If unclear... | Ask about |
|---------------|-----------|
| Which image(s) to edit | "Which image file(s) should I edit?" |
| Edit description vague | "What specific changes do you want?" |
| Selective edit needed | "Do you have a mask, or should I edit the whole image?" |
| Portrait/face editing | "Want high fidelity to preserve facial features?" |
| Multiple images | "Are these separate edits, or should I combine the images?" |

**Skip questions when context is clear.**

### 2. Edit

```bash
python3 ~/.dotfiles/agents/skills/openai-image-edit/scripts/edit.py \
  --image <path> \
  --prompt "description of edit"
```

### 3. Show Results

After editing, show the output path and offer to open the gallery.

## Setup

Requires `OPENAI_API_KEY` environment variable.

## Parameters

| Flag | Values | Default | Description |
|------|--------|---------|-------------|
| `--image` | path | required | Input image (repeatable, up to 16) |
| `--prompt` | text | required | Description of desired edit |
| `--mask` | path | none | PNG mask (transparent = edit area) |
| `--count` | int | 1 | Number of variations |
| `--size` | `1024x1024`, `1536x1024`, `1024x1536`, `auto` | auto | Output dimensions |
| `--quality` | `low`, `medium`, `high`, `auto` | high | Quality level |
| `--background` | `transparent`, `opaque`, `auto` | API default | Background type |
| `--format` | `png`, `jpeg`, `webp` | png | Output format |
| `--compression` | 0-100 | API default | Compression (jpeg/webp only) |
| `--input-fidelity` | `low`, `high` | low | Match input style/features closely |
| `--out-dir` | path | auto | Output directory |
| `--dry-run` | flag | - | Print request details without API call |

## Examples

```bash
# Simple edit
python3 ~/.dotfiles/agents/skills/openai-image-edit/scripts/edit.py \
  --image photo.png \
  --prompt "Add a red hat to the person"

# Combine multiple images into one
python3 ~/.dotfiles/agents/skills/openai-image-edit/scripts/edit.py \
  --image lotion.png \
  --image soap.png \
  --image candle.png \
  --prompt "Arrange these items in an elegant gift basket"

# Use mask for selective editing (transparent areas = edit region)
python3 ~/.dotfiles/agents/skills/openai-image-edit/scripts/edit.py \
  --image landscape.png \
  --mask sky-mask.png \
  --prompt "Replace with dramatic sunset sky"

# High fidelity for portraits (preserves facial features)
python3 ~/.dotfiles/agents/skills/openai-image-edit/scripts/edit.py \
  --image portrait.jpg \
  --prompt "Add professional studio lighting" \
  --input-fidelity high

# Multiple variations
python3 ~/.dotfiles/agents/skills/openai-image-edit/scripts/edit.py \
  --image room.png \
  --prompt "Redecorate in mid-century modern style" \
  --count 4

# Transparent background output
python3 ~/.dotfiles/agents/skills/openai-image-edit/scripts/edit.py \
  --image product.png \
  --prompt "Remove background, keep product only" \
  --background transparent
```

## Use Cases

- **Object removal/replacement**: Remove unwanted elements, replace objects
- **Style transfer**: Change lighting, atmosphere, artistic style
- **Image compositing**: Combine multiple images into one scene
- **Background editing**: Remove, replace, or extend backgrounds
- **Portrait retouching**: Adjust lighting, add accessories (use `--input-fidelity high`)
- **Product photography**: Clean up, relight, or recompose product shots

## Output

- Edited image files (`edited-*.png/jpg/webp`)
- Input image copies (`input-*.ext`) for reference
- `metadata.json` — edit parameters and file mapping
- `index.html` — visual gallery showing inputs and results

Output goes to `~/Projects/tmp/openai-image-edit-{timestamp}/` if that directory exists, otherwise `./tmp/`.

## Masks

Masks define which areas to edit:
- **Transparent areas** (alpha = 0): Will be edited
- **Opaque areas**: Will be preserved
- Must be PNG format
- Should match input image dimensions
- Applied to the first image when using multiple inputs
