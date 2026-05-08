---
name: Implement Slider Question
description: Create D3 questions with interactive sliders and live visualization updates. Students adjust continuous values and observe dynamic feedback.
---

# Implement Slider Question

Use this skill when creating questions where students:
- Adjust continuous values using sliders or range inputs
- Observe live updates to visualizations as they change parameters
- Explore relationships between variables interactively

## When to Use This Pattern

**Perfect for:**
- Parameter exploration (adjust slope, intercept, etc.)
- Continuous value adjustments (temperature, speed, ratio)
- Interactive simulations with live feedback
- "Adjust until..." type questions

**Not suitable for:**
- Discrete quantity adjustments (whole numbers) → use [implement-increment-controls-question](../implement-increment-controls-question/SKILL.md)
- Static value entry → use [implement-table-question](../implement-table-question/SKILL.md)
- Selection from fixed options → use [implement-multiple-choice-question](../implement-multiple-choice-question/SKILL.md)

## Components Required

**Copy these from** `.claude/skills/question-types/snippets/`:

### Required
- `cards/standard-card.js` → `createStandardCard()`
- `svg-basics.js` → For visualization rendering

### Optional
- `cards/explanation-card.js` → `createExplanationCard()`
- `cards/video-accordion.js` → `createVideoAccordion()`

## Quick Start

1. **Review the pattern guide**: [PATTERN.md](PATTERN.md)
2. **Study the working example**:
   ```bash
   cat courses/IM-8th-Grade/modules/Unit-3/assignments/161-Proportion-Graphs/questions/11/attachments/chart.js
   ```

## Key Implementation Decisions

1. **Slider ranges** - What are min, max, step values?
2. **Visualization type** - What updates as slider changes? (graph, diagram, numbers)
3. **State structure** - Which slider values to track
4. **Update frequency** - Real-time updates or debounced?

## State Shape

```javascript
function createDefaultState() {
  return {
    sliderValue1: 50,  // Initial slider position
    sliderValue2: 25,
    explanation: ""
  };
}
```

## Core Pattern

```javascript
function renderSlider(container, options) {
  const { min, max, step, value, onChange, label, locked } = options;

  const sliderGroup = container.append("div")
    .style("margin", "20px 0");

  sliderGroup.append("label")
    .style("display", "block")
    .style("margin-bottom", "8px")
    .style("font-weight", "600")
    .text(label);

  const slider = sliderGroup.append("input")
    .attr("type", "range")
    .attr("min", min)
    .attr("max", max)
    .attr("step", step)
    .property("value", value)
    .property("disabled", locked)
    .style("width", "100%")
    .on("input", function() {
      onChange(+this.value);
    });

  const valueDisplay = sliderGroup.append("span")
    .style("margin-left", "10px")
    .style("font-weight", "bold")
    .text(value);

  return { slider, valueDisplay };
}

// Usage:
renderSlider(container, {
  label: "Adjust temperature:",
  min: 0,
  max: 100,
  step: 1,
  value: chartState.temperature,
  onChange: (newValue) => {
    chartState.temperature = newValue;
    updateVisualization();
    sendChartState();
  },
  locked: interactivityLocked
});
```

## Live Visualization Updates

```javascript
function updateVisualization() {
  // Re-render SVG based on current slider values
  svg.selectAll("circle")
    .attr("r", chartState.sliderValue1)
    .attr("fill", getColorFromValue(chartState.sliderValue2));
}

// Call after slider changes:
slider.on("input", function() {
  chartState.value = +this.value;
  updateVisualization();  // ← Live update
  sendChartState();
});
```

## Working Examples

**In codebase:**
- Check for slider-based questions in the curriculum

**In this skill:**

## Common Variations

### Multiple Sliders
```javascript
function createDefaultState() {
  return {
    slope: 1,
    intercept: 0,
    amplitude: 5,
    explanation: ""
  };
}
```

### Slider with Value Labels
```javascript
const sliderContainer = container.append("div");
const valueLabel = sliderContainer.append("span");

slider.on("input", function() {
  const val = +this.value;
  valueLabel.text(val);
  chartState.value = val;
  updateVisualization();
  sendChartState();
});
```

### Styled Range Input
```html
<style>
input[type="range"] {
  -webkit-appearance: none;
  height: 8px;
  border-radius: 4px;
  background: #e5e7eb;
  outline: none;
}
input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #3b82f6;
  cursor: pointer;
}
</style>
```

## Implementation Checklist

- [ ] Defined slider ranges (min, max, step)
- [ ] Created `createDefaultState()` with slider values
- [ ] Rendered slider inputs with labels
- [ ] Implemented `onChange` handlers to update state
- [ ] Created visualization that responds to slider values
- [ ] Called `updateVisualization()` on slider input
- [ ] Added explanation card (if needed)
- [ ] Implemented `setInteractivity()` to disable sliders when locked
- [ ] Implemented `applyInitialState()` to restore slider positions
- [ ] Tested real-time visualization updates
- [ ] Tested state restoration
- [ ] Tested locking/unlocking

## Tips

1. **Provide visual feedback** - Show current value next to slider
2. **Use appropriate step sizes** - Whole numbers for integers, 0.1 for decimals
3. **Label clearly** - Explain what the slider controls
4. **Update efficiently** - For expensive renders, consider debouncing
5. **Show range** - Display min/max values near slider
6. **Test on mobile** - Sliders work on touch but test carefully

## Debouncing for Performance

If visualization updates are expensive:
```javascript
let updateTimeout;
slider.on("input", function() {
  const val = +this.value;
  chartState.value = val;

  // Debounce expensive visualization updates
  clearTimeout(updateTimeout);
  updateTimeout = setTimeout(() => {
    updateVisualization();
  }, 100);

  // Still send state immediately
  sendChartState();
});
```

## Related Skills

- [implement-increment-controls-question](../implement-increment-controls-question/SKILL.md) - For discrete adjustments
- [implement-graph-question](../implement-graph-question/SKILL.md) - For graph-based interactions
- [create-d3-question](../../create-d3-question/SKILL.md) - Parent workflow skill

## Additional Resources

- [PATTERN.md](PATTERN.md) - Detailed pattern guide
- [snippets/svg-basics.js](../snippets/svg-basics.js) - SVG visualization patterns
