---
name: extract-voice
description: Use when the user wants to analyze writing samples to extract voice patterns, create voice-replicating prompts, or refine content generation prompts to match a specific writing style
---

# Voice Extractor Skill Guide

## Purpose
Extract voice patterns from writing samples and generate production-ready prompts that replicate the author's unique style, tone, and structural patterns.

## When to Use
- User provides writing samples and wants to replicate that voice
- User needs to create social media content prompts matching their style
- User wants to analyze what makes their writing distinctive
- User needs to refine existing prompts to produce more authentic output

## Process

### Phase 1: Voice Analysis

1. **Collect Samples**: Request 5-10 writing samples from the user (more variety = better extraction)

2. **Analyze Patterns**: For each sample, identify:

   **Structural Patterns**
   - Opening styles (personal story, direct address, observation, question, analogy)
   - Paragraph flow and transitions
   - Closing patterns (call to action, reflection, open question, statement)
   - Average length and length variation

   **Tonal Patterns**
   - Primary tones (inspirational, conversational, instructional, philosophical, humorous)
   - Emotional arc within posts
   - Formality level

   **Linguistic Fingerprints**
   - Signature phrases or sentence structures
   - Punctuation habits (em dashes, ellipses, question chains)
   - Arrow syntax usage (->)
   - List formatting preferences
   - Emoji/symbol usage (or absence)

   **Content Patterns**
   - How topics are introduced
   - Personal experience integration
   - Technical vs emotional balance
   - Multi-topic handling strategies

3. **Create Voice Analysis Document**: Generate a structured analysis file containing:
   ```
   ## VOICE DNA
   Core traits that appear in 80%+ of samples

   ## STRUCTURAL FORMATS
   List distinct formats with examples

   ## OPENING ROTATION
   All unique opening styles identified

   ## TONAL PALETTE
   Tones and when each appears

   ## LINGUISTIC MARKERS
   Signature elements to preserve

   ## ANTI-PATTERNS
   What this voice NEVER does
   ```

### Phase 2: Prompt Generation

1. **Draft Initial Prompt** with sections:
   - Role/persona definition
   - Voice DNA (immutable traits)
   - Structural toolkit (multiple format options, NOT rigid formula)
   - Tone matching guidance
   - Length flexibility ranges
   - Anti-patterns (what to avoid)
   - 3-5 voice examples directly from samples

2. **Key Principles**:
   - Provide OPTIONS not requirements for structure
   - Include actual examples from the source material
   - Specify what the voice NEVER does
   - Allow length variation based on content
   - Handle multi-topic inputs gracefully

### Phase 3: Iterative Refinement

1. **Run Experiments**: Use codex skill with gpt-5 to test prompts
2. **Create Experiment Folders**: `example-1/`, `example-2/`, etc.
3. **Each Folder Contains**:
   - `PROMPT.md` - The prompt version being tested
   - `INPUT.txt` - Test input(s)
   - `OUTPUT.txt` - Generated output
   - `NOTES.md` - What worked/didn't work

4. **Iterate Until**:
   - Outputs show structural variety (not all same format)
   - Opening styles rotate naturally
   - Multi-topic handling feels cohesive
   - Tone matches content appropriately
   - Length adapts to complexity

## Output Artifacts

### Required Deliverables
1. `VOICE_ANALYSIS.md` - Complete voice pattern breakdown
2. `FINAL_PROMPT.md` - Production-ready prompt
3. `experiment-N/` folders - All iteration history

### Optional Deliverables
- `PREPROCESSING_REQUIREMENTS.md` - If input cleaning needed
- `PROBLEMS.md` - Issues identified and solved
- `EXAMPLES.md` - Additional voice examples for reference

## Common Issues and Solutions

| Problem | Solution |
|---------|----------|
| All outputs start the same | Add opening rotation with 10+ styles |
| Rigid structure every time | Replace step-by-step formula with format OPTIONS |
| Multi-topics feel forced | Provide integration strategies (common thread, numbered list, comparison) |
| Output too long/short | Add length ranges per format type |
| Conversational responses ("Here's...") | Add anti-conversational directives and forbidden phrases |
| Lost voice authenticity | Include more actual examples in prompt |

## Quick Start Template

When user provides samples, respond with:

```
I'll analyze your writing samples to extract your voice patterns.

**Analyzing:**
1. Structural patterns (openings, flow, closings)
2. Tonal patterns (primary tones, emotional arc)
3. Linguistic fingerprints (signature phrases, punctuation)
4. Content patterns (topic handling, personal integration)

After analysis, I'll create:
- Voice Analysis document
- Production-ready prompt
- Experiment iterations to verify quality

Shall I proceed with the analysis?
```

## Integration with Codex

When testing prompts:
1. Use codex skill with gpt-5 model, medium reasoning effort
2. Test with varied inputs (single topic, multi-topic, different lengths)
3. Verify variety across multiple generations
4. Store all experiments for reference

Resume syntax for continued refinement:
```bash
echo "Generate post about [topic]" | codex exec --skip-git-repo-check resume --last 2>/dev/null
```
