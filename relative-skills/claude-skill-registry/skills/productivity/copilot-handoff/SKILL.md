---
name: copilot-handoff
description: Create Copilot-optimized task specifications for handoff between Claude and GitHub Copilot. Use when planning implementation tasks that Copilot will complete. Optimizes comment format, provides rich context, includes checklists and examples.
allowed-tools: Read, Edit, Write, Glob, Grep
---

# Copilot Handoff Skill

Create detailed task specifications optimized for GitHub Copilot to consume and implement.

## When to Use This Skill

- **"Create a Copilot task spec for..."** - Generate implementation specs
- **"Handoff to Copilot"** - Prepare task for Copilot implementation
- **"Plan for Copilot"** - Design with Copilot autocomplete in mind
- **"Write implementation guide"** - Detailed specs with examples

## Quick Reference

### Handoff Workflow

```
1. User: "I need to add X feature"
2. Claude: Analyzes requirements, identifies files, creates spec
3. Claude: Writes Copilot-optimized comments/stubs in code
4. User: Opens files, positions cursor, Copilot autocompletes
5. Claude: Reviews completed implementation (optional)
```

### What Makes a Good Copilot Spec

**Copilot reads:**
- ✅ Comments in open files
- ✅ Surrounding code context
- ✅ Type annotations and patterns
- ✅ TODO/FIXME markers
- ✅ Docstrings and examples

**Copilot doesn't read:**
- ❌ Closed files (unless recently opened)
- ❌ External documentation
- ❌ Git history
- ❌ Your conversation with Claude

**Strategy**: Pack all context into comments where cursor will be positioned.

## Specification Template Formats

### Format 1: Inline Task Block (Best for Single Changes)

**Use when**: Adding one parameter, method, or small change

```python
# ============================================================================
# TASK: Add VISION_FACE_CONFIDENCE_THRESHOLD Parameter
# ============================================================================
#
# PURPOSE:
#   Control minimum confidence threshold for face detection to filter low-confidence detections
#
# SPECIFICATIONS:
#   Type: float
#   Default: 0.5
#   Valid Range: 0.0 to 1.0 (0.0 = accept all, 1.0 = only perfect matches)
#   Help Text: "Minimum confidence score for face detection"
#
# PATTERN TO FOLLOW:
#   Look at VISION_FACE_STABILITY_SECONDS above (line 134)
#   Use same naming: VISION_FACE_CONFIDENCE_THRESHOLD: float = 0.5
#   Add inline comment explaining range
#
# USAGE:
#   Used in: vision/face_detector.py line 156 (process_frame method)
#   Compared against: face_detection_result.confidence
#
# IMPLEMENTATION:
#   Step 1: Add parameter below with type annotation
#   Step 2: Include inline comment with range explanation
#   Step 3: Follow existing parameter spacing/alignment
#
# ============================================================================

# Face Detection Configuration
VISION_FACE_STABILITY_SECONDS: float = 2.0  # Face must be detected for this long to activate
VISION_FACE_DEBOUNCE_SECONDS: float = 3.0  # Face must be absent for this long to deactivate

# TODO: Add VISION_FACE_CONFIDENCE_THRESHOLD here (float, default 0.5, range 0.0-1.0)
# <Cursor position - Copilot autocompletes>
```

### Format 2: Method Implementation Spec

**Use when**: Implementing a complete method with algorithm

```python
# ============================================================================
# TASK: Implement calculate_face_confidence() Method
# ============================================================================
#
# PURPOSE:
#   Calculate confidence score for detected face based on size, quality, and clarity
#
# ALGORITHM:
#   1. Calculate face size factor:
#      - Extract w, h from face_bbox (x, y, w, h)
#      - face_area = w * h
#      - size_factor = min(1.0, (face_area / 307200.0) * 2.0)  # 307200 = 640*480
#   2. Combine with frame quality:
#      - weighted_score = (size_factor * 0.7) + (frame_quality * 0.3)
#   3. Clamp result to [0.0, 1.0]
#
# INPUTS:
#   face_bbox: tuple - (x, y, w, h) bounding box coordinates
#   frame_quality: float - Overall frame quality score (0.0-1.0)
#
# OUTPUTS:
#   float - Confidence score between 0.0 and 1.0
#
# EDGE CASES:
#   - Invalid bbox (w<=0 or h<=0): return 0.0
#   - frame_quality out of range: clamp to [0.0, 1.0]
#   - Negative coordinates: still calculate area (only w,h matter)
#
# EXAMPLE:
#   >>> calculate_face_confidence((100, 100, 320, 240), 0.8)
#   0.73  # (0.7 * 0.5 + 0.3 * 0.8) where face is 50% of 640x480 frame
#
# SIMILAR CODE:
#   See calculate_motion_confidence() in motion_detector.py:245-267
#   Uses same weighted average pattern
#
# ============================================================================

def calculate_face_confidence(
    self,
    face_bbox: tuple,
    frame_quality: float
) -> float:
    """
    Calculate confidence score for detected face.

    Combines face size and frame quality into weighted confidence score.
    Larger faces and higher quality frames produce higher confidence.

    Args:
        face_bbox: (x, y, w, h) bounding box coordinates
        frame_quality: Overall frame quality score (0.0-1.0)

    Returns:
        Confidence score between 0.0 and 1.0

    Example:
        >>> calculate_face_confidence((100, 100, 320, 240), 0.8)
        0.73
    """
    # TODO: Implement confidence calculation following algorithm above
    # Step 1: Extract w, h and calculate size_factor
    # Step 2: Calculate weighted_score with frame_quality
    # Step 3: Clamp result and return
    # <Cursor position - Copilot implements>
```

### Format 3: Multi-File Checklist (Best for Complex Changes)

**Use when**: Changes span multiple files (like adding config parameter)

**Create file: `tasks/add_face_confidence_param.md`**

```markdown
# Task: Add Face Confidence Parameter

## Overview
Add VISION_FACE_CONFIDENCE_THRESHOLD parameter to filter low-confidence face detections.

## Implementation Checklist

### [ ] 1. BobConfig.py (lines 133-137)
**Location**: After VISION_FACE_USE_STABILITY_FILTER

**Add**:
```python
VISION_FACE_CONFIDENCE_THRESHOLD: float = 0.5  # Minimum confidence for face detection (0.0-1.0)
```

**Pattern**: Follow existing VISION_FACE_* parameters
**Type**: float, default 0.5, range 0.0-1.0

---

### [ ] 2. vision/face_detector.py (line 156)
**Location**: In process_frame() method, after face detection

**Add**:
```python
# Filter by confidence threshold
if face_result.confidence < self.config.VISION_FACE_CONFIDENCE_THRESHOLD:
    continue  # Skip low-confidence detections
```

**Pattern**: Similar to existing threshold checks
**Context**: Inside loop over detected faces

---

### [ ] 3. web/config_manager.py - get_vision_settings() (line 805)
**Location**: In 'performance' section

**Add**:
```python
'face_confidence_threshold': self.config.VISION_FACE_CONFIDENCE_THRESHOLD,
```

**Pattern**: Follow existing face_* keys
**Type**: Return float value directly

---

### [ ] 4. web/config_manager.py - save_vision_settings() (line 945)
**Location**: In performance section regex updates

**Add**:
```python
if 'face_confidence_threshold' in perf:
    content = re.sub(
        r'VISION_FACE_CONFIDENCE_THRESHOLD:\s*float\s*=\s*[\d.]+',
        f'VISION_FACE_CONFIDENCE_THRESHOLD: float = {float(perf["face_confidence_threshold"])}',
        content
    )
    changes_made.append(f"VISION_FACE_CONFIDENCE_THRESHOLD = {perf['face_confidence_threshold']}")
```

**Pattern**: Follow existing VISION_FACE_* regex patterns
**Validation**: Ensure float conversion

---

### [ ] 5. web/templates/config_vision.html - Form Field (line 388)
**Location**: In Performance section, after face_debounce_seconds

**Add**:
```html
<div class="form-group">
    <label for="face_confidence_threshold">Face Confidence Threshold</label>
    <input type="number" id="face_confidence_threshold" name="face_confidence_threshold"
           min="0.0" max="1.0" step="0.05">
    <span class="form-help">Minimum confidence score for face detection (0.0 = accept all, 1.0 = only certain)</span>
</div>
```

**Pattern**: Follow existing form-group structure
**Validation**: min=0.0, max=1.0, step=0.05

---

### [ ] 6. web/templates/config_vision.html - Populate JS (line 501)
**Location**: In populateForm() function

**Add**:
```javascript
document.getElementById('face_confidence_threshold').value =
    settings.performance.face_confidence_threshold || 0.5;
```

**Pattern**: Follow existing face_* field population
**Default**: 0.5 if not present

---

### [ ] 7. web/templates/config_vision.html - Submit JS (line 537)
**Location**: In form submission object, performance section

**Add**:
```javascript
face_confidence_threshold: parseFloat(document.getElementById('face_confidence_threshold').value),
```

**Pattern**: Follow existing parseFloat() pattern
**Validation**: Ensure float conversion

---

## Verification Steps

1. Start Bob and check logs for config loading
2. Open http://localhost:5001/config/vision
3. Verify face_confidence_threshold field appears
4. Change value and save
5. Check BobConfig.py updated correctly
6. Test face detection with different thresholds
7. Verify low-confidence faces are filtered

## Related Files
- BobConfig.py:134 - Parameter definition
- vision/face_detector.py:156 - Usage in detection
- web/config_manager.py:805,945 - Backend handling
- web/templates/config_vision.html:388,501,537 - Frontend UI
```

## Common Task Types

### Task Type 1: Add Configuration Parameter

**What I provide:**
```python
# ============================================================================
# TASK CHECKLIST: Add [PARAMETER_NAME]
# ============================================================================
# [1] BobConfig.py - Define parameter
# [2] [usage_file].py - Use parameter in logic
# [3] config_manager.py - get_settings() method
# [4] config_manager.py - save_settings() method
# [5] config_[name].html - Form field
# [6] config_[name].html - JavaScript populate
# [7] config_[name].html - JavaScript submit
# ============================================================================

# Add parameter here following pattern above
# Type: [type], Default: [value], Range: [range]
```

**See also:** config-pattern skill for full implementation

### Task Type 2: Add Detector Method

**What I provide:**
```python
# ============================================================================
# TASK: Implement process_frame() for [DetectorName]
# ============================================================================
# DETECTOR TYPE: [Motion/Face/Object/Gesture]
# INPUT: frame (np.ndarray), timestamp (float)
# OUTPUT: List[DetectionResult] or None
#
# ALGORITHM:
#   [Step-by-step algorithm]
#
# SIMILAR CODE: [reference to existing detector]
# ============================================================================

def process_frame(self, frame: np.ndarray, timestamp: float):
    """[Docstring with examples]"""
    # TODO: Implement following algorithm above
```

### Task Type 3: Add State Machine Transition

**What I provide:**
```python
# ============================================================================
# TASK: Add Transition from [STATE_A] to [STATE_B]
# ============================================================================
# TRIGGER EVENT: [EventName]
# CONDITIONS: [List of conditions that must be true]
# ACTIONS ON ENTRY: [What to do when entering STATE_B]
# ACTIONS ON EXIT: [What to do when leaving STATE_A]
#
# SIMILAR TRANSITION: [STATE_X] -> [STATE_Y] (line [N])
# ============================================================================

# Add transition here following pattern
```

### Task Type 4: Implement LLM Tool

**What I provide:**
```python
# ============================================================================
# TASK: Implement [tool_name] Tool
# ============================================================================
# PURPOSE: [What the tool does for Bob]
# INPUTS: [Parameter list with types]
# OUTPUTS: [Return value]
# API CALLS: [External APIs needed, if any]
# ERROR HANDLING: [What to do on failure]
#
# TOOL SCHEMA:
#   {
#       "name": "tool_name",
#       "description": "...",
#       "parameters": {...}
#   }
#
# SIMILAR TOOL: [existing tool name] in llm/tools.py:[line]
# ============================================================================

def tool_name(param1: str, param2: int) -> dict:
    """[Docstring]"""
    # TODO: Implement tool logic
```

## Pro Tips for Writing Copilot Specs

### 1. **Be Specific About Location**
```python
# BAD: "Add parameter somewhere"
# GOOD: "Add parameter after line 134, following VISION_FACE_DEBOUNCE_SECONDS pattern"
```

### 2. **Provide Type Information**
```python
# BAD: "Add threshold parameter"
# GOOD: "Add VISION_MOTION_THRESHOLD: float = 10.0  # Range: 0.1-100.0"
```

### 3. **Reference Similar Code**
```python
# GOOD: "Follow pattern from VISION_FACE_STABILITY_SECONDS above (line 134)"
# GOOD: "See calculate_motion_confidence() in motion_detector.py:245-267"
```

### 4. **Include Examples**
```python
# GOOD:
# Example:
#   >>> calculate_confidence((100, 100, 320, 240), 0.8)
#   0.73
```

### 5. **Specify Edge Cases**
```python
# GOOD:
# Edge Cases:
#   - Empty list: return None
#   - Invalid value: raise ValueError with clear message
#   - Negative numbers: clamp to 0
```

### 6. **Use Clear Markers**
```python
# GOOD: Use TODO at cursor position
# TODO: Add parameter here
# <Cursor position>

# GOOD: Use clear section headers
# ============================================================================
# [Stands out visually]
# ============================================================================
```

### 7. **Provide Algorithm Steps**
```python
# GOOD:
# Algorithm:
#   Step 1: Extract dimensions (w, h from bbox)
#   Step 2: Calculate area (w * h)
#   Step 3: Normalize to [0, 1] (area / max_area)
#   Step 4: Return weighted score
```

## Claude ↔ Copilot Coordination Patterns

### Pattern 1: Claude Plans, Copilot Implements

**Best for**: Well-defined features with clear specifications

1. **User**: "Add face confidence filtering"
2. **Claude**: Creates detailed spec with algorithm
3. **Claude**: Writes commented stubs in code
4. **User**: Opens files, Copilot autocompletes
5. **Claude**: Reviews implementation (optional)

### Pattern 2: Copilot Implements, Claude Reviews

**Best for**: Quick implementations where speed matters

1. **User**: Uses Copilot to quickly implement feature
2. **User**: "Claude, review this implementation"
3. **Claude**: Checks for bugs, edge cases, pattern violations
4. **User**: Applies fixes (with Claude or Copilot)

### Pattern 3: Iterative Refinement

**Best for**: Complex changes needing multiple passes

1. **Claude**: Creates initial spec
2. **Copilot**: Implements 80% of it
3. **User**: Identifies gaps or issues
4. **Claude**: Refines spec for remaining 20%
5. **Copilot**: Completes implementation

## Task Complexity Guide

### Simple Tasks (Copilot alone is fine)
- Adding single line of code
- Changing variable name
- Simple refactoring
- Following obvious pattern

### Medium Tasks (Use this skill)
- Adding configuration parameter
- Implementing method with algorithm
- Multi-file coordinated change
- Following established pattern

### Complex Tasks (Claude should do it)
- Novel architecture decisions
- Cross-cutting refactoring
- Debugging complex issues
- Requires tool use (git, bash, etc.)

## Example Workflows

### Workflow 1: Add Config Parameter (Step-by-Step)

**User**: "Claude, create a Copilot task spec to add VISION_FACE_RECOGNITION_ENABLED parameter"

**Claude response**:
```python
# I'll add the spec to BobConfig.py. Open the file and position your cursor after line 137.

# ============================================================================
# TASK: Add VISION_FACE_RECOGNITION_ENABLED Parameter
# ============================================================================
# PURPOSE: Toggle face recognition on/off independently of face detection
# TYPE: bool
# DEFAULT: True
# USAGE: vision/face_detector.py:175 (controls recognition vs detection-only)
# PATTERN: Follow VISION_FACE_USE_STABILITY_FILTER above (line 135)
# ============================================================================

VISION_FACE_USE_STABILITY_FILTER: bool = True  # Enable face stability filtering

# TODO: Add VISION_FACE_RECOGNITION_ENABLED here (bool, default True)
# <Position cursor here>
```

**User**: Opens BobConfig.py, positions cursor, Copilot suggests:
```python
VISION_FACE_RECOGNITION_ENABLED: bool = True  # Enable face recognition (vs detection-only)
```

**User**: "Claude, what's next?"

**Claude**: "Now open vision/face_detector.py and find line 175 where face recognition happens. I'll add a spec there..."

### Workflow 2: Implement Algorithm (Complete Example)

**User**: "Claude, I need to calculate motion intensity. Create a Copilot spec."

**Claude**:
```python
# I'll add this to motion_detector.py. Open the file and scroll to the MotionDetector class.

# ============================================================================
# TASK: Implement calculate_motion_intensity() Method
# ============================================================================
#
# PURPOSE:
#   Calculate normalized motion intensity from motion contours
#
# ALGORITHM:
#   1. Sum areas of all contours:
#      total_area = sum(cv2.contourArea(c) for c in contours)
#   2. Normalize by frame size:
#      frame_area = frame.shape[0] * frame.shape[1]
#      intensity = (total_area / frame_area) * 100.0  # As percentage
#   3. Clamp to reasonable range:
#      return min(100.0, max(0.0, intensity))
#
# INPUTS:
#   contours: List[np.ndarray] - Motion contours from findContours()
#   frame: np.ndarray - Original frame (for dimensions)
#
# OUTPUTS:
#   float - Motion intensity as percentage (0.0-100.0)
#
# EDGE CASES:
#   - Empty contours list: return 0.0
#   - Invalid frame: return 0.0
#   - Negative area (shouldn't happen): clamp to 0.0
#
# EXAMPLE:
#   >>> contours = [np.array([[100,100],[120,100],[120,120],[100,120]])]
#   >>> frame = np.zeros((480, 640, 3), dtype=np.uint8)
#   >>> calculate_motion_intensity(contours, frame)
#   0.13  # (400 pixels / 307200 pixels * 100)
#
# ============================================================================

def calculate_motion_intensity(
    self,
    contours: List[np.ndarray],
    frame: np.ndarray
) -> float:
    """
    Calculate normalized motion intensity from motion contours.

    Args:
        contours: List of motion contours from cv2.findContours()
        frame: Original frame for dimension reference

    Returns:
        Motion intensity as percentage (0.0-100.0)

    Example:
        >>> calculate_motion_intensity(contours, frame)
        0.13  # 0.13% of frame showing motion
    """
    # TODO: Implement motion intensity calculation
    # Step 1: Sum contour areas
    # Step 2: Normalize by frame size
    # Step 3: Convert to percentage and clamp
    # <Position cursor here>
```

**User**: Positions cursor, Copilot implements based on spec.

## Integration with Other Skills

**Works well with:**
- **config-pattern** - I create checklist, Copilot implements each step
- **detector-plugin** - I scaffold detector, Copilot fills in logic
- **web-config-page** - I spec UI changes, Copilot implements HTML/JS
- **event-flow** - I design event flow, Copilot adds handlers

**Replaces manual work:**
- Figuring out what to write in comments
- Searching for similar code patterns
- Writing complete specifications
- Coordinating multi-file changes

## Common Mistakes to Avoid

### Mistake 1: Too Little Context
❌ **Bad**:
```python
# TODO: Add threshold parameter
```

✅ **Good**:
```python
# TODO: Add VISION_MOTION_THRESHOLD: float = 10.0 (range 0.1-100.0)
# Follow pattern from VISION_FACE_STABILITY_SECONDS above
```

### Mistake 2: No Pattern Reference
❌ **Bad**:
```python
# Add the parameter here
```

✅ **Good**:
```python
# Add parameter here, following VISION_FACE_* pattern above (lines 133-137)
# Use same type annotation style and inline comment format
```

### Mistake 3: Missing Edge Cases
❌ **Bad**:
```python
# Calculate average
```

✅ **Good**:
```python
# Calculate average
# Edge cases:
#   - Empty list: return 0.0
#   - Single item: return that item
#   - All zeros: return 0.0
```

### Mistake 4: Vague Types
❌ **Bad**:
```python
# Add threshold (float)
```

✅ **Good**:
```python
# Add VISION_MOTION_THRESHOLD: float = 10.0
# Type: float (percentage)
# Range: 0.1-100.0 (validated in config_manager)
```

## Time Savings

**Without skill:**
- 20-30 minutes figuring out what specs to write
- Trial and error with Copilot suggestions
- Missing context leads to wrong implementations

**With skill:**
- 5 minutes for Claude to generate spec
- Copilot gets it right first time
- Clear checklist prevents missed steps

**Estimated time savings: 4-6x faster for medium tasks**

## References

**Related Skills:**
- [config-pattern](.claude/skills/config-pattern/SKILL.md) - Config parameter workflow
- [detector-plugin](.claude/skills/detector-plugin/SKILL.md) - Detector implementation
- [web-config-page](.claude/skills/web-config-page/SKILL.md) - Web UI implementation

**Tools:**
- GitHub Copilot in VS Code
- Claude Code for analysis and planning
