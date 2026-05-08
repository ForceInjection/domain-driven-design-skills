---
name: ppt
description: Generate PowerPoint presentations programmatically. Use this skill when the user wants to create a new PPT project, plan presentation content, scrape source materials from the web, generate slides, draw shapes/flowcharts, or review rendered slide images. Handles the full workflow from content planning to final output.
---

# PPT Generator

Generate PowerPoint presentations through a structured workflow: plan content collaboratively, gather source materials, generate slides programmatically, and export rendered images for review.

## When to Use This Skill

- User wants to create a new presentation project
- User wants to plan presentation content
- User needs to scrape images or content from the web for slides
- User wants to generate a PowerPoint file
- User wants to draw shapes, diagrams, or flowcharts
- User wants to review rendered slides
- User mentions "ppt", "powerpoint", "slides", "presentation", "flowchart"

## Slide Dimensions

Default: **16:9 Widescreen** (13.33" × 7.5")

```
┌──────────────────────────────────────────────────┐
│                                                  │
│         13.33 × 7.50 inches (16:9)               │
│                                                  │
│              Center: (6.67, 3.75)                │
│                                                  │
└──────────────────────────────────────────────────┘
```

```python
# Widescreen (default)
builder = PptxBuilder()

# Standard 4:3 (10" × 7.5")
builder = PptxBuilder(widescreen=False)
```

## Coordinate System

Origin (0,0) is at **top-left**. X increases right, Y increases down.

### Absolute Coordinates
```python
# Position shape at absolute (left, top) in inches
builder.add_rectangle(slide, left=2, top=3, width=2, height=1, text="Box")
```

### Center-Relative Coordinates (Recommended for Layout)

Use `rel()` and `rel_rect()` for positioning relative to slide center:

```
                    (-) up
                      │
                      │
    (-) left ─────────┼───────── (+) right
                      │        (0,0) = center
                      │
                    (+) down
```

```python
# Get center coordinates
cx = builder.center_x()  # 6.67 for widescreen
cy = builder.center_y()  # 3.75

# rel(x, y) - convert offset to absolute point
x, y = builder.rel(0, 0)      # Slide center
x, y = builder.rel(-3, -1)    # 3" left, 1" up from center
x, y = builder.rel(+2, +1.5)  # 2" right, 1.5" down from center

# rel_rect(x, y, w, h) - position shape's CENTER at offset
left, top = builder.rel_rect(0, 0, 2, 1)      # Center a 2×1 box at slide center
left, top = builder.rel_rect(-3, -1.5, 2, 0.8) # Center box at (-3, -1.5)
builder.add_rectangle(slide, left, top, 2, 0.8, text="Box")
```

## Draft Mode - Guidelines

Add visual guidelines for positioning during development:

```python
slide = builder.add_shape_slide('My Draft Slide')
builder.add_guidelines(slide)  # Adds grid with labels

# Guidelines show:
# - Red center lines (horizontal & vertical)
# - Dashed grid at 0.5" intervals
# - Labels showing offset from center (-6.2", -5.7", ... +6.3")
# - Corner coordinate (13.3, 7.5)
```

## Project Structure

Each presentation is a self-contained project under `projects/`:

```
projects/{project-name}/
├── plan.md              # Content plan (collaborative)
├── sources/             # Source materials
│   ├── images/          # Downloaded/scraped images
│   ├── text/            # Text content, notes
│   └── data/            # Data files (CSV, JSON)
├── scripts/             # Generation scripts
│   └── generate_pptx.py # Main generation script
└── output/              # Generated files
    ├── {name}.pptx      # PowerPoint file
    ├── slide_01.png     # Rendered slide images
    └── ...
```

## Workflow

### Phase 1: Create Project

```bash
mkdir -p projects/{project-name}/sources/images projects/{project-name}/sources/text projects/{project-name}/scripts projects/{project-name}/output
```

### Phase 2: Plan Content (Collaborative)

Create `plan.md` with slide-by-slide outline.

### Phase 3: Gather Source Materials

```python
from lib.scraper import Scraper
scraper = Scraper(output_dir='projects/{project-name}/sources')
scraper.download_image('https://example.com/image.jpg', filename='image.jpg')
```

### Phase 4: Generate Script

### Phase 5: Generate and Review

```bash
cd D:/projects/ppt && uv run python projects/{project-name}/scripts/generate_pptx.py
```

Review rendered slides: `output/slide_01.png`, `output/slide_02.png`, etc.

## Library Reference

### PptxBuilder - Slide Methods

| Method | Description |
|--------|-------------|
| `add_title_slide(title, subtitle)` | Title slide layout |
| `add_content_slide(title, content, image_path, image_position)` | Content with optional image |
| `add_image_slide(title, image_path, caption)` | Centered image slide |
| `add_shape_slide(title)` | Blank slide for shapes (returns slide) |
| `add_blank_slide()` | Empty slide (returns slide) |
| `save(output_path)` | Save .pptx file |

### PptxBuilder - Coordinate Methods

| Method | Description |
|--------|-------------|
| `center_x()` | Slide center X in inches (6.67 for 16:9) |
| `center_y()` | Slide center Y in inches (3.75) |
| `rel(x, y)` | Convert center-offset to absolute (x, y) |
| `rel_rect(x, y, w, h)` | Get (left, top) to center a w×h shape at offset |
| `add_guidelines(slide)` | Add draft grid with labels |

### PptxBuilder - Shape Methods

| Method | Description |
|--------|-------------|
| `add_rectangle(slide, left, top, w, h, text, fill_color, rounded)` | Rectangle/rounded rect |
| `add_oval(slide, left, top, w, h, text, fill_color)` | Oval/ellipse |
| `add_diamond(slide, left, top, w, h, text, fill_color)` | Diamond (decision) |
| `add_arrow(slide, x1, y1, x2, y2, color)` | Arrow line |
| `add_line(slide, x1, y1, x2, y2, color)` | Simple line |
| `add_flowchart(slide, nodes, connections, ...)` | Auto-layout flowchart |

### Shape Colors (Default)

| Shape | Default Color |
|-------|---------------|
| Rectangle | `#4472C4` (blue) |
| Oval | `#70AD47` (green) |
| Diamond | `#FFC000` (yellow) |
| Error/Alert | `#C00000` (red) |

### Flowchart Example

```python
slide = builder.add_shape_slide('Process Flow')

nodes = [
    {'text': 'Start', 'type': 'oval', 'row': 0, 'col': 1},
    {'text': 'Process', 'type': 'rounded', 'row': 1, 'col': 1},
    {'text': 'Decision?', 'type': 'diamond', 'row': 2, 'col': 1},
    {'text': 'Yes Path', 'type': 'rounded', 'row': 3, 'col': 0},
    {'text': 'No Path', 'type': 'rounded', 'row': 3, 'col': 2, 'color': '#C00000'},
    {'text': 'End', 'type': 'oval', 'row': 4, 'col': 1},
]

connections = [(0,1), (1,2), (2,3), (2,4), (3,5), (4,5)]

builder.add_flowchart(slide, nodes, connections,
    start_x=3.5, start_y=1.2,
    node_width=2.0, node_height=0.7,
    h_spacing=1.5, v_spacing=0.5
)
```

Node types: `'oval'`, `'rounded'`, `'rect'`, `'diamond'`

### Scraper Methods

| Method | Description |
|--------|-------------|
| `download_image(url, filename, subdir)` | Download single image |
| `download_images_from_page(url, limit)` | Scrape images from webpage |
| `scrape_text(url, selector)` | Extract text from webpage |
| `save_text(content, filename)` | Save text to file |

### Exporter Functions

| Function | Description |
|----------|-------------|
| `export_slides_to_images(pptx_path, output_dir)` | Export all slides as PNG |
| `export_to_pdf(pptx_path, output_path)` | Export to PDF |

## Complete Example with Shapes

```python
import sys
from pathlib import Path
sys.path.insert(0, 'D:/projects/ppt')

from lib.pptx_builder import PptxBuilder
from lib.pptx_exporter import export_slides_to_images

builder = PptxBuilder()  # 16:9 widescreen

# Title slide
builder.add_title_slide('My Presentation', 'With Shapes')

# Shape slide with guidelines (draft mode)
slide = builder.add_shape_slide('Architecture Diagram')
builder.add_guidelines(slide)  # Remove for final version

# Using center-relative positioning
left, top = builder.rel_rect(0, 0, 3, 1.5)
builder.add_rectangle(slide, left, top, 3, 1.5, text='Main System', rounded=True)

left, top = builder.rel_rect(-3, -2, 2, 1)
builder.add_rectangle(slide, left, top, 2, 1, text='Input', fill_color='#70AD47')

left, top = builder.rel_rect(+3, -2, 2, 1)
builder.add_rectangle(slide, left, top, 2, 1, text='Output', fill_color='#C00000')

# Arrows
cx, cy = builder.rel(0, 0)
builder.add_arrow(slide, cx - 2, cy - 1.5, cx - 1.5, cy - 0.75)
builder.add_arrow(slide, cx + 1.5, cy - 0.75, cx + 2, cy - 1.5)

# Save and export
output = Path('D:/projects/ppt/projects/example/output')
builder.save(str(output / 'example.pptx'))
export_slides_to_images(str(output / 'example.pptx'), str(output))
```

## Tips

- Use `add_guidelines()` during development, remove for final output
- Use `rel_rect()` for center-relative positioning of shapes
- Always export slides as images to review the rendered output
- Keep bullet points concise (3-5 words each)
- Source images should be at least 800x600 for good quality
- Run scripts from the project root (`D:/projects/ppt`)
- Use absolute paths when calling `export_slides_to_images()`
