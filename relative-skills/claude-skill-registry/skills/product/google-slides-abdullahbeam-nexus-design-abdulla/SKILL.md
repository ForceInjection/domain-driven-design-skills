---
name: google-slides
version: 1.0
description: "Create and manage Google Slides presentations. Load when user mentions 'google slides', 'slides', 'presentation', 'create presentation', 'add slide', or references creating/editing slide decks."
---

# Google Slides

Create, edit, and manage Google Slides presentations via OAuth authentication.

---

## Pre-Flight Check (ALWAYS RUN FIRST)

```bash
python3 00-system/skills/google/google-master/scripts/google_auth.py --check --service slides
```

**Exit codes:**
- **0**: Ready to use - proceed with user request
- **1**: Need to login - run `python3 00-system/skills/google/google-master/scripts/google_auth.py --login`
- **2**: Missing credentials or dependencies - see [../google-master/references/setup-guide.md](../google-master/references/setup-guide.md)

---

## Quick Reference

### List Presentations
```bash
python3 00-system/skills/google/google-slides/scripts/slides_operations.py list
```

### Search Presentations
```bash
python3 00-system/skills/google/google-slides/scripts/slides_operations.py list --query "quarterly"
```

### Get Presentation Info
```bash
python3 00-system/skills/google/google-slides/scripts/slides_operations.py info <presentation_id>
```

### Create Presentation
```bash
python3 00-system/skills/google/google-slides/scripts/slides_operations.py create "Q4 Sales Report"
```

### Read Slide Content
```bash
python3 00-system/skills/google/google-slides/scripts/slides_operations.py read <presentation_id> --slide 1
```

### Add Blank Slide
```bash
python3 00-system/skills/google/google-slides/scripts/slides_operations.py add-slide <presentation_id>
```

### Add Slide with Layout
```bash
python3 00-system/skills/google/google-slides/scripts/slides_operations.py add-slide <presentation_id> --layout title_body
```

### Delete Slide
```bash
python3 00-system/skills/google/google-slides/scripts/slides_operations.py delete-slide <presentation_id> <slide_id>
```

### Add Text Box
```bash
python3 00-system/skills/google/google-slides/scripts/slides_operations.py add-text <presentation_id> <slide_id> "Hello World" --x 100 --y 100
```

### Add Image
```bash
python3 00-system/skills/google/google-slides/scripts/slides_operations.py add-image <presentation_id> <slide_id> "https://example.com/image.png"
```

### Duplicate Presentation
```bash
python3 00-system/skills/google/google-slides/scripts/slides_operations.py duplicate <presentation_id> "Copy of Presentation"
```

### Export to PDF
```bash
python3 00-system/skills/google/google-slides/scripts/slides_operations.py export <presentation_id> ./output.pdf --format pdf
```

### Export to PowerPoint
```bash
python3 00-system/skills/google/google-slides/scripts/slides_operations.py export <presentation_id> ./output.pptx --format pptx
```

---

## Presentation ID

The ID is in the URL:
```
https://docs.google.com/presentation/d/[PRESENTATION_ID]/edit
```

---

## Slide Layouts

| Layout | Description |
|--------|-------------|
| `blank` | Empty slide |
| `title` | Title slide (large centered title) |
| `title_body` | Title with body text |
| `title_two_columns` | Title with two columns |
| `title_only` | Just a title area |
| `section` | Section header |
| `big_number` | Large number display |
| `caption` | Caption only |

---

## Available Operations

| Operation | Function | Description |
|-----------|----------|-------------|
| **List** | `list_presentations()` | List all presentations |
| **Info** | `get_presentation_info()` | Get presentation metadata |
| **Create** | `create_presentation()` | Create new presentation |
| **Read** | `read_slide()` | Get slide content |
| **Add Slide** | `add_slide()` | Add new slide |
| **Delete Slide** | `delete_slide()` | Remove slide |
| **Add Text** | `add_text_box()` | Insert text box |
| **Add Image** | `add_image()` | Insert image |
| **Duplicate** | `duplicate_presentation()` | Copy presentation |
| **Export** | `export_presentation()` | Export to PDF/PPTX |

---

## Positioning

Text boxes and images use points (pt) for positioning:
- `--x` and `--y`: Position from top-left corner
- `--width` and `--height`: Element dimensions

Standard slide is approximately 720 x 540 points.

---

## Common Workflows

### Create Report Presentation
```python
from slides_operations import create_presentation, add_slide, add_text_box

# Create presentation
pres = create_presentation("Monthly Report")
pres_id = pres['id']

# Get first slide ID
info = get_presentation_info(pres_id)
first_slide = info['slides'][0]['id']

# Add title
add_text_box(pres_id, first_slide, "Monthly Performance Report",
             x=100, y=200, width=500, height=60)

# Add more slides
add_slide(pres_id, layout='title_body')
```

### Export for Sharing
```python
from slides_operations import export_presentation

# Export to PDF for email
export_presentation(presentation_id, "./report.pdf", format='pdf')

# Export to PowerPoint for editing
export_presentation(presentation_id, "./report.pptx", format='pptx')
```

---

## Error Handling

See [../google-master/references/error-handling.md](../google-master/references/error-handling.md) for common errors and solutions.

---

## Setup

First-time setup: [../google-master/references/setup-guide.md](../google-master/references/setup-guide.md)

**Quick start:**
1. `pip install google-auth google-auth-oauthlib google-api-python-client`
2. Create OAuth credentials in Google Cloud Console (enable Google Slides API, choose "Desktop app")
3. Add to `.env` file at Nexus root:
   ```
   GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
   GOOGLE_CLIENT_SECRET=your-client-secret
   GOOGLE_PROJECT_ID=your-project-id
   ```
4. Run `python3 00-system/skills/google/google-master/scripts/google_auth.py --login`
