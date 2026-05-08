---
name: brand-evolution
description: Update and evolve existing brand identity based on new direction or feedback
triggers:
  - update brand
  - change brand
  - evolve brand
  - rebrand
  - refresh brand
  - modify brand
  - brand update
  - new direction
  - pivot
tools_required:
  - load_brand
  - write_file
  - read_file
  - list_files
---

# Brand Evolution Skill

Use this skill when the user wants to update, evolve, or pivot an existing brand
identity rather than creating something entirely new.

## What This Skill Covers

- Brand identity updates and refinements
- Target audience pivots
- Visual identity refreshes
- Voice and messaging updates
- Market repositioning
- Partial rebranding

## Prerequisites

Before evolving a brand:

1. **Load current brand**: Call `load_brand(detail_level='full')` to get complete current identity
2. **Review all aspects**: Understand what exists before changing
3. **Check assets**: Use `list_files("assets/")` to see what's been generated
4. **Clarify scope**: What specifically needs to change?

## Evolution vs Creation

### Evolution (This Skill)
- Respects established elements
- Makes targeted refinements
- Maintains brand equity
- Documents what changes and why
- Considers impact on existing materials

### Creation (Use brand-identity skill)
- Starts from scratch
- Full creative freedom
- No existing constraints
- Building new identity

## Types of Brand Evolution

### 1. Minor Refinement
Small updates that don't change core identity:
- Color adjustments (lightening, accent changes)
- Typography tweaks
- Messaging polish
- Audience clarification

### 2. Moderate Update
Noticeable changes while maintaining recognition:
- New tagline
- Expanded color palette
- Voice tone adjustment
- Audience expansion

### 3. Major Pivot
Significant direction change:
- New positioning
- Target audience shift
- Visual overhaul (while keeping brand name)
- Core values evolution

### 4. Full Rebrand
Complete transformation (consider brand-identity skill instead):
- New name
- New visual identity
- New positioning
- New everything

## Evolution Workflow

### Step 1: Understand Current State
```
Load the brand and review:
- What's working well? (Keep these)
- What needs improvement?
- What's the user asking to change?
```

### Step 2: Clarify the Evolution
Ask about:
- **Scope**: What elements should change?
- **Reason**: Why is the change needed?
- **Constraints**: What must stay the same?
- **Goals**: What should the evolution achieve?

### Step 3: Propose Changes
Present changes clearly:
```
## Proposed Evolution

### What Stays the Same
- [Elements being preserved]
- [Reason: maintains equity/recognition]

### What Changes
- [Element]: [Old] → [New]
- [Rationale for change]

### Impact on Existing Assets
- [What needs to be regenerated]
- [What can remain]
```

### Step 4: Implement Changes
After user approval:
- Update identity.json with changes
- Document what was changed and why
- Regenerate affected assets if requested

## Common Evolution Scenarios

### Audience Pivot
```
Current: Young professionals in urban areas
Evolution: Expanding to suburban families

Changes needed:
- Audience profile update
- Possibly softer tone
- Family-friendly imagery direction
- Messaging adjustments
```

### Visual Refresh
```
Current: Heavy, dark color palette
Evolution: Lighter, more modern feel

Changes needed:
- Primary colors (lighter variants)
- Typography (more contemporary)
- Imagery style update
- Logo may need update
```

### Voice Adjustment
```
Current: Formal, authoritative
Evolution: More conversational, approachable

Changes needed:
- Voice personality description
- Tone attributes
- Messaging do's and don'ts
- Sample copy
```

### Positioning Shift
```
Current: Premium luxury positioning
Evolution: Accessible premium

Changes needed:
- Positioning statement
- Value proposition
- Competitor set
- Possibly pricing language in messaging
```

## Guidelines for Evolution

### Preserve Brand Equity
- Keep what's working
- Don't change for change's sake
- Maintain recognizability
- Respect customer relationship

### Document Everything
- Note what changed
- Explain why
- Track versions if possible
- Consider transition plan

### Consider Ripple Effects
- How does this change affect other elements?
- What assets need updating?
- Is messaging still consistent?
- Does visual and verbal identity still align?

### Communicate Clearly
- Present before/after comparison
- Explain the strategic rationale
- Get explicit approval before saving

## Quality Checks for Evolution

Before saving evolved brand:

- [ ] Changes address the stated goal
- [ ] Core identity elements are still cohesive
- [ ] Visual and verbal identity still align
- [ ] Nothing contradicts preserved elements
- [ ] Changes are documented
- [ ] Impact on existing assets is noted
- [ ] User has approved the changes

## Saving Evolved Brand

After evolution is approved:

```
# Update the identity file
write_file("identity.json", updated_identity_json)

# Consider saving previous version
write_file("identity_backup_[date].json", original_identity_json)
```

## When to Recommend Full Rebrand

Suggest using brand-identity skill instead if:
- User wants to change everything
- Current identity is fundamentally broken
- Brand name is changing
- It's essentially a new brand

Be honest: "The changes you're describing are substantial enough that we might get a better result building fresh rather than constraining ourselves to the existing identity. Would you like to create a new brand identity?"

## Memory and Context

When evolving:
- Reference specific existing elements by name
- Compare proposed changes to current state
- Explain how changes fit with preserved elements
- Build on what exists rather than replacing wholesale
