---
name: product-planning
description: Use when specs/product/ is empty or incomplete to create mission.md, roadmap.md and tech-stack.md through incremental brainstorming and validation.
---

# Product Planning

## What It Does

Creates product foundation through collaborative dialogue:
1. Explore product vision, mission and technical stack via existing documentation
2. Explores product vision via brainstorming
3. Extracts mission, users, problems, features
4. Creates development roadmap with priorities
5. Documents technical stack
6. Saves to `specs/product/` folder

## The Process

### Step 1: Check Existing Documentation

```bash
ls -la specs/product/ 2>/dev/null

for file in mission.md roadmap.md tech-stack.md; do
  [ -f "specs/product/$file" ] && echo "Found: $file"
done
```

**If files exist:**
```
Found: [list files]

Options:
1. Review and update
2. Start fresh (backs up existing)

Your preference?
```

**If option 1 (review and update) selected:**
Use the current files as context for Step 2

**If option 2 (Start fresh) selected:**

```bash
# Create backup with timestamp
BACKUP_DIR="specs/product.backup.$(date +%Y%m%d-%H%M%S)"
if [ -d "specs/product" ]; then
  if ! cp -r specs/product "$BACKUP_DIR"; then
    echo "Warning: Could not create backup. Proceeding anyway."
  else
    echo "✅ Backed up existing docs to $BACKUP_DIR"
  fi
fi
```

### Step 2: Brainstorm Product Vision

**Use brainstorming approach** - not rigid questions:

```
Let's explore your product vision.

Start with the big picture - what are you building?
```

**Wait for response.**

**Then explore naturally:**
- Who needs this? (users)
- What problem does it solve? (pain points)
- What makes it different? (differentiators)
- What can users do? (features)
- How will you build it? (tech stack)

**ONE question at a time. Follow the conversation.**

**Present multiple choice when helpful:**
```
For your target users, which sounds right:

1. Individual developers (personal projects)
2. Small teams 2-10 people (collaboration)
3. Enterprise teams (complex workflows)
4. Mix of these (describe)
```

**Or open-ended for exploration:**
```
Tell me about your users:
- Who are they?
- When do they use your product?
- What frustrates them today?
```

**Continue until you understand:**
- Core product concept
- Target users (1-2 personas)
- Main problem being solved
- Key features (3-8 minimum)
- Success criteria
- Technical approach

### Step 3: Present Mission Document

**Announce:**
```
Based on our conversation, here's the mission document.

I'll show section by section - let me know if anything needs adjustment.
```

**Present in chunks (150-200 words each):**

**Section 1: Pitch**
```
## Pitch
[Product] is a [type] that helps [users] [solve problem]
by providing [value proposition].

[2-3 sentences expanding on this]

Does this capture your vision?
```

**Wait. Adjust if needed.**

**Section 2: Users**
```
## Users

### Primary Customers
[2-3 customer segments]

### User Personas
**[Persona]** ([context])
- Role: [description]
- Pain Points: [problems]
- Goals: [outcomes]

Accurate?
```

**Wait. Adjust if needed.**

**Continue for remaining sections:**
- The Problem
- Key Features (grouped logically)

### Step 4: Save Mission Document

```bash
mkdir -p specs/product

cat > specs/product/mission.md <<'EOF'
# Product Mission

[Approved content from Step 3]
EOF
```

### Step 5: Create a Development Roadmap

**Propose feature ordering:**
```
Development roadmap - features ordered by:
- Technical dependencies
- Value delivery path
- MVP to full product

1. [ ] [Feature] — [Description] `[Effort]`
   Why first: [Reasoning]

2. [ ] [Feature] — [Description] `[Effort]`
   Why next: [Reasoning]

[Continue for all features]

Does this ordering make sense?
```

**Effort scale:**
- `XS`: 1 day
- `S`: 2-3 days
- `M`: 1 week
- `L`: 2 weeks
- `XL`: 3+ weeks

**Wait. Adjust if needed.**

### Step 6: Save Roadmap

```bash
cat > specs/product/roadmap.md <<'EOF'
# Product Roadmap

[Approved roadmap from Step 5]

> Notes
> - Ordered by dependencies and value
> - Each item is complete, testable feature
> - Check off as specs are implemented
EOF
```

### Step 7: Document Tech Stack

**Ask about technical approach:**
First check if there's any existing tech stack information in CLAUDE.md or project docs that should be considered.

```
Tech stack - do you have preferences?

1. Use my usual stack (check global CLAUDE.md)
2. This project uses: [specify]
3. Ask about each layer

Which?
```

**If option 3, ask naturally:**
```
Frontend framework?
1. React + TypeScript
2. Vue + TypeScript
3. Other (specify)
```

**Continue through layers as needed.**

**Present tech stack:**
```
## Frontend
[Technologies with purpose]

## Backend
[Technologies with purpose]

## Database
[Technologies with purpose]

Complete and accurate?
```

### Step 8: Save Tech Stack

```bash
cat > specs/product/tech-stack.md <<'EOF'
# Tech Stack

[Approved tech stack from Step 7]
EOF
```

### Step 9: Completion

```
🎉 Product documentation complete!

Created:
✅ specs/product/mission.md
✅ specs/product/roadmap.md
✅ specs/product/tech-stack.md

Ready to create first spec: [First roadmap item]

Continue?
```

## Validation Pattern

After each section:
```
[Present content]

Does this look right?

✓ Yes, continue
✎ Adjust [explain what]
⟲ Rethink this section
```

**If adjustment needed:**
- Ask clarifying question
- Present revised version
- Validate again

## Red Flags

**Never:**
- Batch multiple questions in one message
- Present entire document at once
- Proceed without validation
- Skip brainstorming - jump to templates

**Always:**
- Explore vision naturally first
- ONE question at a time
- Validate each section before next
- Adapt to conversation flow

## Integration

**Called by:**
- `sdd-orchestrator` when no product docs exist

**May use:**
- Brainstorming patterns (not formal skill call, just the approach)

**Returns to:**
- `sdd-orchestrator` after docs created

**Creates:**
- `specs/product/mission.md`
- `specs/product/roadmap.md`
- `specs/product/tech-stack.md`
