---
name: requirements-gathering
description: Use during Phase 2 of spec creation to gather detailed requirements through one-question-at-a-time dialogue - analyzes product context, asks targeted questions, requests visual assets, identifies reusability opportunities, and documents all findings
---

# Requirements Gathering

## What It Does

1. Loads product context (mission, roadmap, tech-stack)
2. Asks 4-8 targeted questions (ONE at a time)
3. Requests visual assets and reusability info
4. **Mandatory:** Checks visuals folder via bash
5. Asks follow-ups if needed (ONE at a time)
6. Documents everything in requirements.md

## The Process

### Step 1: Load Context

```bash
SPEC="[provided by workflow]"

# Read initial idea
cat "$SPEC/planning/initialization.md"

# Read product context
cat specs/product/mission.md
cat specs/product/roadmap.md
cat specs/product/tech-stack.md
```

**Analyze:**
- User's feature description
- How it fits product mission
- Where in roadmap
- Technical constraints

### Step 2: Generate Questions

Create 4-8 questions based on feature and context.

**Question guidelines:**
- Number each question
- Propose sensible defaults
- Frame as "I'm assuming X, correct?"
- Make it easy to confirm or suggest alternatives
- Use multiple choice when options clear

**CRITICAL: Always end with:**
1. Visual assets request
2. Reusability question

**Present:**
```
Based on [feature], I have clarifying questions:

1. [Question with assumption]

[ONE question at a time from here...]
```

**After first question answered, ask second:**
```
2. [Next question]
```

**Continue ONE at a time until all questions asked.**

**Then end with:**
```
**Existing Code Reuse:**
Similar features in your codebase we should reference?

Examples:
- Similar UI components/layouts
- Related backend logic/services
- Existing models/controllers with similar functionality

Provide paths/names if any exist.

**Visual Assets:**
Have design mockups, wireframes, or screenshots?

If yes, place in:
`[spec]/planning/visuals/`

Names like:
- homepage-mockup.png
- form-wireframe.jpg
- mobile-view.png

Please answer.
```

**STOP. Wait for response.**

### Step 3: Process Answers

Store exact responses.

**MANDATORY: Check for visuals**

```bash
# ALWAYS run regardless of user's response
ls -la "$SPEC/planning/visuals/" 2>/dev/null | \
  grep -E '\.(png|jpg|jpeg|gif|svg|pdf)$' || \
  echo "No visual files found"
```

**If files found:**
```bash
# Read each visual
for file in "$SPEC/planning/visuals/"*; do
  # Use Read tool
  # Note: design elements, fidelity level
done
```

**Analyze:**
- Layout, components, colors
- User flow implications
- Check filename for: lofi, lo-fi, wireframe, sketch, rough
- Match with requirements discussed

### Step 4: Determine Follow-ups Needed

**Trigger follow-ups if:**

**Visual-triggered:**
- User didn't mention visuals but files exist
- Filename suggests wireframe (clarify fidelity)
- Visuals show features not discussed

**Reusability-triggered:**
- User didn't provide similar features but seems common
- Provided paths seem incomplete

**Answers-triggered:**
- Vague requirements
- Missing technical details
- Unclear scope

### Step 5: Ask Follow-ups (if needed)

**ONE question at a time:**

**Visual discovery:**
```
Found in visuals folder:
- homepage-layout.png
- form-wireframe.jpg

The wireframe filename suggests low-fidelity.

Should I treat these as:
1. Layout/structure guides (use existing styling)
2. Exact design specs (match precisely)

Which?
```

**Reusability:**
```
You mentioned similar forms exist.

Could you point me to:
- Path to existing form component
- Any service objects with similar logic

This helps ensure consistency.
```

**Clarification:**
```
You mentioned "admin controls" - could you clarify:

Should admins:
1. View only
2. View + edit
3. View + edit + delete
4. Something else

Which?
```

**STOP after each follow-up. Wait for response.**

### Step 6: Save Requirements

After all questions answered:

```bash
cat > "$SPEC/planning/requirements.md" <<'EOF'
# Spec Requirements: [Feature Name]

## Initial Description
[From initialization.md]

## Requirements Discussion

### First Round Questions

**Q1:** [Question]
**Answer:** [Exact answer]

**Q2:** [Question]
**Answer:** [Exact answer]

[All questions and answers]

### Existing Code to Reference

[If user provided paths/names:]
**Similar Features:**
- Feature: [Name] - Path: `[path]`
- Components to reuse: [description]

[If none provided:]
No similar features identified - spec-writer will search codebase.

### Follow-up Questions

[If any asked:]
**Follow-up 1:** [Question]
**Answer:** [Answer]

## Visual Assets

### Files Provided:
[Based on bash check, NOT user statement]

- `filename.png`: [What it shows from analysis]
  - Fidelity: [high-fidelity / low-fidelity wireframe]
  - Key elements: [list]

[If no files:]
No visual assets provided.

### Visual Insights:
[If files exist:]
- Design patterns: [list]
- User flow: [description]
- UI components: [list]

## Requirements Summary

### Functional Requirements
- [Core functionality]
- [User actions]
- [Data management]

### Reusability Opportunities
- [From user input]

[If none:]
Will search codebase during spec writing.

### Scope Boundaries

**In Scope:**
- [What will be built]

**Out of Scope:**
- [What won't be built]
- [Future enhancements]

### Technical Considerations
- [Integration points]
- [Constraints]
- [Tech preferences]
EOF
```

### Step 7: Report Completion

```
✅ Requirements complete!

Documented:
- [X] questions and answers
- Visuals: [Y found / None]
- Reusability: [Z identified / Search later]
- Functional requirements
- Scope boundaries

Created: planning/requirements.md

Ready for Phase 3: Spec writing
```

**Return to workflow.**

## Question Pattern Examples

**With defaults:**
```
1. I'm assuming users need authentication.
   Correct, or should it be publicly accessible?
```

**Multiple choice:**
```
2. For data storage:

A. New database table (unique data)
B. Extend existing table (related entities)
C. Use existing table (just relationships)

Which, or different approach?
```

**Open-ended:**
```
3. Tell me the user workflow:
- Starting point?
- Steps they take?
- End result they see?
```

## Red Flags

**Never:**
- Ask multiple questions in one message
- Skip visual folder check
- Assume visuals without bash check
- Proceed without answers
- Modify user's responses

**Always:**
- Ask ONE question at a time
- Run bash command for visuals
- Analyze any visual files found
- Store exact answers
- Check filenames for fidelity indicators

## Integration

**Called by:**
- `spec-creation-workflow` (Phase 2)

**Returns to:**
- `spec-creation-workflow`

**Creates:**
- `[spec]/planning/requirements.md`

**Next phase uses:**
- requirements.md for spec writing
- Visual files for design guidance
- Reusability notes for codebase search
