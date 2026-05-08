---
name: excalidraw-diagram
description: Generate Excalidraw diagrams. Use when the user asks to create a diagram, visualize a concept, or illustrate technical architectures.
---

# Excalidraw Diagram Generation

## Workflow

1. Write excalidraw JSON to `<name>.excalidraw`
2. Render: `python -m excalidraw_renderer <name>.excalidraw -o <name>.png`

## File Structure

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "claude",
  "elements": [...],
  "appState": {
    "viewBackgroundColor": "#ffffff"
  }
}
```

## Available Shapes

- `rectangle`, `ellipse`, `diamond`, `line`, `arrow`, `text`

## Shape Properties

```json
{
  "id": "unique_id",
  "type": "rectangle",
  "x": 100,
  "y": 100,
  "width": 150,
  "height": 80,
  "strokeColor": "#1e1e1e",
  "backgroundColor": "#a5d8ff",
  "fillStyle": "solid",
  "strokeWidth": 2,
  "strokeStyle": "solid",
  "roughness": 0
}
```

### Text Elements

```json
{
  "id": "label1",
  "type": "text",
  "x": 110,
  "y": 110,
  "width": 130,
  "height": 60,
  "text": "Multi-line\ntext here",
  "fontSize": 16,
  "fontFamily": 5,
  "textAlign": "center",
  "strokeColor": "#1e1e1e"
}
```

**fontFamily:** 1=hand-drawn, 2=normal, 5=monospace (use for technical diagrams)

### Arrow/Line Elements

```json
{
  "id": "arrow1",
  "type": "arrow",
  "x": 100,
  "y": 100,
  "width": 0,
  "height": 50,
  "strokeColor": "#1971c2",
  "strokeWidth": 2,
  "roughness": 0,
  "points": [[0, 0], [0, 50]]
}
```

### Dashed Frames

```json
{
  "id": "frame1",
  "type": "rectangle",
  "strokeColor": "#2f9e44",
  "backgroundColor": "transparent",
  "strokeStyle": "dashed",
  "roughness": 0
}
```

## Color Palette

| Color | Stroke | Fill |
|-------|--------|------|
| Green | #2f9e44 | #b2f2bb |
| Orange | #f08c00 | #ffd8a8, #ffec99 |
| Red | #e03131 | #ffc9c9 |
| Blue | #1971c2 | #a5d8ff, #d0ebff |
| Purple | #9c36b5 | #e599f7, #eebefa |
| Grey | #868e96 | #dee2e6, #e9ecef |

## Spacing Guidelines

- Title fontSize: 28-36
- Section headers: 20-24
- Body text: 12-16
- Minimum padding inside boxes: 10px
- Gap between sections: 20-30px
- Dashed frame padding: 20px inside content

## Arrow Labeling Rules

1. Arrows point AT things, not along them - perpendicular to target
2. Arrow tip touches the target
3. Text and arrow must not overlap

## Iteration Log

1. **fontFamily**: Use 5 (monospace) for technical diagrams, not 1 (hand-drawn).
2. **Text in shapes**: Create separate text elements inside boxes for reliable rendering.
3. **roughness**: Set to 0 for clean technical diagrams.
