---
name: amcs-fixer
description: Apply targeted fixes to failing artifacts based on validation issues. Improves hook density, singability, rhyme tightness, section completeness, and profanity compliance with minimal changes. Use after VALIDATE fails (≤3 iterations) to address specific quality issues before re-composing.
---

# AMCS Fixer

Applies minimal, targeted improvements to artifacts that fail validation. Analyzes the issues list from VALIDATE and makes surgical fixes to the lowest-scoring component (lyrics, style, or producer notes) without unnecessary rewrites.

## When to Use

Invoke this skill after VALIDATE returns `pass: false`. The orchestrator enforces a maximum of 3 fix iterations per run.

## Input Contract

```yaml
inputs:
  - name: issues
    type: array[string]
    required: true
    description: List of validation failures from VALIDATE
  - name: style
    type: amcs://schemas/style-1.0.json
    required: true
    description: Current style specification
  - name: lyrics
    type: string
    required: true
    description: Current lyrics with section markers
  - name: producer_notes
    type: amcs://schemas/producer-notes-1.0.json
    required: true
    description: Current production notes
  - name: blueprint
    type: amcs://schemas/blueprint-1.0.json
    required: true
    description: Genre-specific rules and constraints
  - name: scores
    type: object
    required: false
    description: Score breakdown from VALIDATE (for prioritization)
  - name: seed
    type: integer
    required: true
    description: Determinism seed (use seed+6 for this node)
```

## Output Contract

```yaml
outputs:
  - name: patched_style
    type: amcs://schemas/style-1.0.json
    description: Fixed style specification (if style issues detected)
  - name: patched_lyrics
    type: string
    description: Fixed lyrics (if lyrics issues detected)
  - name: patched_producer_notes
    type: amcs://schemas/producer-notes-1.0.json
    description: Fixed producer notes (if producer issues detected)
  - name: fixes_applied
    type: array[string]
    description: List of fixes applied (e.g., "Duplicated chorus hook for hook density")
```

## Determinism Requirements

- **Seed**: `run_seed + 6` for any LLM-based fixes
- **Temperature**: 0.2 (minimal variation for targeted fixes)
- **Top-p**: 0.9
- **Retrieval**: None
- **Hashing**: Hash patched artifacts for provenance

## Constraints & Policies

- **Max 3 iterations**: Enforced by orchestrator
- **Minimal changes**: Only fix what's broken, don't rewrite entire artifacts
- **Target lowest score**: Prioritize fixing the component with the lowest score
- **Preserve structure**: Don't remove sections or drastically change arrangement
- **Blueprint compliance**: All fixes must respect blueprint rules

## Fix Strategies by Issue Type

### 1. Low Hook Density (< 0.7)

**Problem**: Not enough hook repetition across sections.

**Strategy**:
1. Identify primary hook phrase from chorus
2. Duplicate hook in pre-chorus or bridge
3. Add hook callback in final chorus
4. Condense multi-line hooks into single memorable line

**Implementation**:
```
Original Chorus:
Family time is here again
Christmas love throughout the year

Fixed Chorus:
Family time is what we need  <-- condensed hook
Love and joy in every deed   <-- condensed hook

Added to Bridge:
Family time is what we need  <-- hook callback
```

**LLM Prompt** (if needed):
```
System: Apply MINIMAL fixes to increase hook density. Identify the primary hook phrase from the chorus and add 1-2 strategic repetitions in other sections (pre-chorus, bridge, or final chorus). Do NOT rewrite the entire song. Temperature: 0.2

User: Increase hook density. Current: 0.45. Target: 0.7+
Chorus: [current chorus]
Full lyrics: [current lyrics]
```

### 2. Weak Singability (< 0.8)

**Problem**: Inconsistent syllable counts or unnatural phrasing.

**Strategy**:
1. Identify sections with high syllable variance
2. Adjust lines to match target syllable count (mean ± 1)
3. Remove tongue-twisters or awkward phrasing
4. Ensure natural breath points

**Implementation**:
```
Original Verse:
Gathering 'round on Christmas Eve (9 syllables)
The kids decorate, we all believe (9 syllables)
Family time is what we need now (9 syllables)
Together sharing love somehow (8 syllables)

Fixed Verse:
Gathering 'round on Christmas Eve (9 syllables)
The kids decorate, we all believe (9 syllables)
Family time is what we need (8 syllables)
Together sharing love and deed (8 syllables)
```

**LLM Prompt**:
```
System: Apply MINIMAL fixes to improve singability. Adjust syllable counts to be consistent (within ±1 syllable of mean). Preserve meaning and rhyme scheme. Do NOT rewrite unaffected lines. Temperature: 0.2

User: Fix singability in [Section]. Target syllable count: 8-9 per line.
Current lines:
[lines with syllable counts]
```

### 3. Weak Rhyme Tightness (< 0.75)

**Problem**: Rhyme scheme not followed or poor rhyme quality.

**Strategy**:
1. Identify lines that should rhyme but don't
2. Replace end words with better rhymes
3. Adjust preceding words if needed for natural flow
4. Preserve meaning and theme

**Implementation**:
```
Rhyme scheme: ABAB

Original:
Walking through the snowy night (A)
Children singing songs of joy (B)
Stars are shining very bright (A) ✓
Gifts for every girl and man (C) ✗ should rhyme with B

Fixed:
Walking through the snowy night (A)
Children singing songs of joy (B)
Stars are shining very bright (A) ✓
Families celebrate with joy (B) ✓
```

**LLM Prompt**:
```
System: Apply MINIMAL fixes to improve rhyme scheme adherence. Replace end words that break the rhyme scheme with appropriate rhymes. Preserve line meaning and syllable count. Temperature: 0.2

User: Fix rhyme scheme [ABAB] in [Section].
Lines with rhyme issues:
[lines with expected rhyme pairs]
```

### 4. Missing Required Sections (< 1.0)

**Problem**: Blueprint requires sections that are missing from lyrics.

**Strategy**:
1. Identify missing sections (e.g., Bridge)
2. Generate minimal section content matching theme
3. Insert in appropriate structural position
4. Update producer notes with section metadata

**Implementation**:
```
Missing: Bridge

Generated Bridge:
[Bridge]
Together we can share the light
Making memories through the night
Family bonds that hold us tight
Christmas magic burning bright
```

**LLM Prompt**:
```
System: Generate a [Section] that fits the existing song theme and structure. Use the same rhyme scheme and syllable pattern as other sections. Keep it concise (4-8 lines). Temperature: 0.2

User: Generate missing [Bridge] section.
Theme: [song theme]
Rhyme scheme: AABB
Syllables: 8-9 per line
Existing sections:
[relevant context from verse/chorus]
```

### 5. Profanity Detected (explicit=false)

**Problem**: Banned terms found when explicit content not allowed.

**Strategy**:
1. Identify lines with banned terms
2. Replace with clean alternatives
3. Preserve meaning and rhyme
4. Mark replacements with [[REDACTED]] if no good alternative

**Implementation**:
```
Original:
What the hell is going on?

Fixed:
What on earth is going on?

OR (if no alternative):
What the [[REDACTED]] is going on?
```

**LLM Prompt**:
```
System: Replace profanity with clean alternatives. Preserve meaning, rhyme, and syllable count. Use creative substitutions that maintain impact. Temperature: 0.2

User: Remove profanity from:
[lines with banned terms]
Banned terms: [list]
```

## Implementation Guidance

### Step 1: Parse Issues List

Extract issue types and affected components:

```python
def _parse_issues(issues: List[str]) -> Dict[str, Any]:
    parsed = {
        "hook_density": False,
        "singability": False,
        "rhyme_tightness": False,
        "section_completeness": False,
        "profanity": False,
        "details": {}
    }

    for issue in issues:
        if "hook density" in issue.lower():
            parsed["hook_density"] = True
            # Extract current score
            match = re.search(r"(\d+\.\d+)", issue)
            if match:
                parsed["details"]["hook_density_score"] = float(match.group(1))

        elif "singability" in issue.lower():
            parsed["singability"] = True

        elif "rhyme" in issue.lower():
            parsed["rhyme_tightness"] = True

        elif "missing required sections" in issue.lower():
            parsed["section_completeness"] = True
            # Extract missing sections
            match = re.search(r":\s*(.+)$", issue)
            if match:
                parsed["details"]["missing_sections"] = [
                    s.strip() for s in match.group(1).split(",")
                ]

        elif "profanity" in issue.lower():
            parsed["profanity"] = True
            # Extract banned terms
            match = re.search(r":\s*(.+)$", issue)
            if match:
                parsed["details"]["banned_terms"] = [
                    s.strip() for s in match.group(1).split(",")
                ]

    return parsed
```

### Step 2: Prioritize Fixes

Use scores to determine which issue to fix first:

```python
def _prioritize_fixes(parsed_issues: Dict[str, Any], scores: Dict[str, float]) -> List[str]:
    priorities = []

    # Profanity is highest priority (blocking)
    if parsed_issues["profanity"]:
        priorities.append("profanity")

    # Section completeness (structural)
    if parsed_issues["section_completeness"]:
        priorities.append("section_completeness")

    # Sort remaining by score (lowest first)
    remaining = []
    if parsed_issues["hook_density"]:
        remaining.append(("hook_density", scores.get("hook_density", 0)))
    if parsed_issues["singability"]:
        remaining.append(("singability", scores.get("singability", 0)))
    if parsed_issues["rhyme_tightness"]:
        remaining.append(("rhyme_tightness", scores.get("rhyme_tightness", 0)))

    remaining.sort(key=lambda x: x[1])  # Lowest score first
    priorities.extend([issue for issue, _ in remaining])

    return priorities
```

### Step 3: Apply Fixes

For each priority issue, apply appropriate fix:

```python
async def _apply_fix(
    issue_type: str,
    lyrics: str,
    style: Dict[str, Any],
    producer_notes: Dict[str, Any],
    details: Dict[str, Any],
    seed: int
) -> Tuple[str, Dict, Dict, str]:
    """Apply fix for specific issue type.

    Returns:
        (patched_lyrics, patched_style, patched_producer_notes, fix_description)
    """

    if issue_type == "hook_density":
        return await _fix_hook_density(lyrics, style, seed)

    elif issue_type == "singability":
        return await _fix_singability(lyrics, seed)

    elif issue_type == "rhyme_tightness":
        return await _fix_rhyme_tightness(lyrics, seed)

    elif issue_type == "section_completeness":
        missing = details.get("missing_sections", [])
        return await _fix_missing_sections(lyrics, producer_notes, missing, seed)

    elif issue_type == "profanity":
        banned = details.get("banned_terms", [])
        return await _fix_profanity(lyrics, banned, seed)

    return lyrics, style, producer_notes, "No fix applied"
```

### Step 4: Validate Fixes Don't Introduce New Issues

After applying each fix, run basic checks:

```python
def _validate_fix(
    patched_lyrics: str,
    original_lyrics: str,
    blueprint: Dict[str, Any]
) -> List[str]:
    """Ensure fix didn't introduce new problems.

    Returns:
        List of new issues found (empty if clean)
    """
    issues = []

    # Check that required sections weren't removed
    required_sections = blueprint.get("rules", {}).get("required_sections", [])
    for section in required_sections:
        if f"[{section}]" not in patched_lyrics:
            issues.append(f"Fix removed required section: {section}")

    # Check that lyrics didn't shrink drastically
    original_lines = len([l for l in original_lyrics.split("\n") if l.strip()])
    patched_lines = len([l for l in patched_lyrics.split("\n") if l.strip()])
    if patched_lines < original_lines * 0.7:
        issues.append(f"Fix removed too many lines: {original_lines} → {patched_lines}")

    return issues
```

### Step 5: Return Patched Artifacts

```python
return {
    "patched_lyrics": patched_lyrics,
    "patched_style": patched_style,
    "patched_producer_notes": patched_producer_notes,
    "fixes_applied": fixes_applied,
    "_hash": compute_hash(patched_lyrics + str(patched_style))
}
```

## Examples

### Example 1: Fix Low Hook Density

**Input**:
```json
{
  "issues": ["Low hook density: 0.45 (target 0.7)"],
  "lyrics": "[Verse]\nWalking through the snow\n...\n[Chorus]\nChristmas time is here\nJoy and love appear\n...",
  "scores": {"hook_density": 0.45}
}
```

**Output**:
```json
{
  "patched_lyrics": "[Verse]\nWalking through the snow\nChristmas time is here  <-- hook added\n...\n[Chorus]\nChristmas time is here\nJoy and love appear\n...\n[Bridge]\nChristmas time is here  <-- hook callback\n...",
  "patched_style": {...},
  "patched_producer_notes": {...},
  "fixes_applied": ["Duplicated chorus hook in verse and bridge for hook density"]
}
```

### Example 2: Fix Missing Section

**Input**:
```json
{
  "issues": ["Missing required sections: Bridge"],
  "lyrics": "[Verse]\n...\n[Chorus]\n...",
  "blueprint": {"rules": {"required_sections": ["Verse", "Chorus", "Bridge"]}}
}
```

**Output**:
```json
{
  "patched_lyrics": "[Verse]\n...\n[Chorus]\n...\n[Bridge]\nTogether we can share the light\nMaking memories through the night\n...",
  "patched_producer_notes": {
    "section_meta": {
      "Bridge": {"tags": ["reflective", "moderate energy"]}
    }
  },
  "fixes_applied": ["Generated missing Bridge section"]
}
```

## Common Pitfalls

1. **Over-Fixing**: Rewriting entire sections instead of targeted fixes
2. **Breaking Rhyme Scheme**: Fixing one issue but breaking rhymes
3. **Changing Theme**: Introducing content inconsistent with song theme
4. **Removing Sections**: Accidentally removing required sections during fixes
5. **Infinite Loop**: Fix introduces new issue that causes validation to fail again
6. **Ignoring Blueprint**: Fixes that violate blueprint rules (tempo, lexicon)
7. **Non-Determinism**: Using high temperature or non-seeded generation

## Related Skills

- **VALIDATE**: Produces issues list consumed by this skill
- **COMPOSE**: Re-runs after fixes applied to regenerate prompt
- **LYRICS**: Original lyrics generation (for reference)

## References

- PRD: `docs/project_plans/PRDs/claude_code_orchestration.prd.md` (section 3.7)
- PRD: `docs/project_plans/PRDs/blueprint.prd.md` (rubric specification)
- Blueprint Examples: `docs/hit_song_blueprint/AI/*.md`
