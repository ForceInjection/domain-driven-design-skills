---
name: setup-brainstorm-integration
description: Install hookify rule to auto-suggest diagrams during design discussions
---

# Setup Brainstorm Integration

This skill installs a hookify rule that prompts you to offer diagrams when users discuss architecture, flows, data models, or other visual topics.

## What It Does

When users mention design-related keywords like "architecture", "workflow", "data model", "wireframe", or "diagram", you'll get a gentle reminder to offer visual-thinking diagrams.

## Installation

Copy the hookify rule to the user's `.claude/` directory:

```bash
cp "$(dirname "$0")/../hookify-rules/brainstorm-diagrams.local.md" ~/.claude/hookify.visual-thinking-brainstorm.local.md
```

Or create it manually by copying this content to `~/.claude/hookify.visual-thinking-brainstorm.local.md`:

```markdown
---
name: visual-thinking-brainstorm
enabled: true
event: prompt
pattern: \b(architecture|workflow|wireflow|data\s*flow|user\s*journey|customer\s*journey|state\s*machine|states?\s*and\s*transitions|data\s*model|ERD|schema|relationships|wireframe|mockup|UI\s*design|screens?|diagram|visualize|draw\s*(this|it|out)?|flow\s*chart|sequence\s*diagram|mind\s*map)\b
---

**Visual Thinking Available**

The user is discussing something that could benefit from a diagram. Consider offering to capture it visually:

"Want me to create a diagram for this? I can make a [flowchart/sequence diagram/mindmap/ERD] and open it in draw.io for you to edit."

**When to offer:**
- Architecture discussions → flowchart or sequence diagram
- User journeys/flows → flowchart
- Data models → ERD or class diagram
- State machines → state diagram
- Brainstorming/ideation → mindmap
- UI discussions → mention draw.io has mockup shapes

**How to create:**
Use the `create_diagram` tool with appropriate type, then offer to export to draw.io.

**Don't be pushy** - offer once per topic. If declined, continue without mentioning again.
```

## Verification

After installation, the rule activates immediately. Test by starting a conversation with design keywords:

- "Let's design the authentication flow"
- "I need to think through the data model"
- "Can we map out the user journey?"

You should see the visual thinking reminder in your context.

## Disabling

To temporarily disable, edit `~/.claude/hookify.visual-thinking-brainstorm.local.md` and set `enabled: false`.

To permanently remove, delete the file.
