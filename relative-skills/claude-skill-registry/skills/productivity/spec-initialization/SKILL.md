---
name: spec-initialization
description: Use at start of spec creation to initialize folder structure with dated naming and save raw feature idea - creates planning, implementation, and verification folders ready for subsequent phases
---

# Spec Initialization

## What It Does

1. Gets feature description (from roadmap or user)
2. Creates dated folder (YYYY-MM-DD-feature-name)
3. Saves initialization.md with raw idea
4. Sets up empty folders for later phases

## The Process

### Step 1: Get Feature Description

**If description provided by workflow:**
Use that. Skip to Step 2.

**If no description:**

Check roadmap:
```bash
cat specs/product/roadmap.md
NEXT=$(grep -m 1 "^[0-9]*\. \[ \]" specs/product/roadmap.md)
```

**Present:**
```
Next roadmap item:
[Item description]

Options:
1. Create spec for this
2. Different feature (describe it)

Which?
```

**Or if no roadmap:**
```
What feature are you creating a spec for?

Describe in 1-3 sentences:
- What it does
- Who it's for
- Why it's needed
```

**Wait for response.**

### Step 2: Create Folder Structure

```bash
# Get today's date
TODAY=$(date +%Y-%m-%d)

# Convert to kebab-case
# "User Authentication" → "user-authentication"
SPEC_NAME="[kebab-case-from-description]"

# Create dated folder
DATED_NAME="${TODAY}-${SPEC_NAME}"
SPEC_PATH="specs/features/$DATED_NAME"

# Create structure
mkdir -p "$SPEC_PATH/planning"
mkdir -p "$SPEC_PATH/planning/visuals"
mkdir -p "$SPEC_PATH/implementation"
mkdir -p "$SPEC_PATH/verification"
mkdir -p "$SPEC_PATH/verification/screenshots"
```

**Kebab-case rules:**
- Lowercase
- Spaces → hyphens
- Remove special chars
- Remove articles (a, an, the)
- Max 4-5 words

**Examples:**
- "User Authentication System" → `user-authentication-system`
- "Dashboard Analytics" → `dashboard-analytics`
- "Real-time Notifications" → `realtime-notifications`

### Step 3: Save Initialization Document

```bash
cat > "$SPEC_PATH/planning/initialization.md" <<EOF
# Feature Initialization: [Feature Name]

## Date
$(date +%Y-%m-%d)

## Initial Description
[User's exact description - unmodified]

## Source
[Roadmap item #X / User request / New feature]

## Next Steps
- Requirements gathering
- Specification writing
- Tasks breakdown
- Implementation
EOF
```

### Step 4: Report Completion

```
✅ Spec initialized

Structure created:
specs/features/[dated-name]/
├── planning/
│   ├── initialization.md ✅
│   └── visuals/ (ready for mockups)
├── implementation/ (for reports)
└── verification/ (for testing)
    └── screenshots/ (for UI verification)

Spec path: specs/features/[dated-name]

Ready for Phase 2: Requirements gathering
```

**Return spec path to workflow.**

## Edge Cases

**Similar name exists:**
```bash
ls specs/features/ | grep -i "[keywords]"
```

**If found:**
```
⚠️  Found similar spec:
- specs/features/2025-10-15-user-auth/

Is this:
1. Same feature (use existing)
2. Different feature (needs distinct name)

Which?
```

**Very long description (>100 words):**
```
For folder name, I'll use: [short-name]

OK, or prefer different short name?
```

## Red Flags

**Never:**
- Modify user's description when saving
- Skip date prefix in folder name
- Create folders outside specs/features/
- Start requirements without returning to workflow

**Always:**
- Use dated folders (YYYY-MM-DD-name)
- Save exact description
- Create all subfolders
- Return spec path

## Integration

**Called by:**
- `spec-creation-workflow` (Phase 1)

**Returns to:**
- `spec-creation-workflow` with spec path

**Creates:**
- `specs/features/[dated-name]/planning/initialization.md`
- Empty folders for later phases
