---
name: consciousness-telemetry
description: Diagnostic telemetry system that tracks internal state variables (prediction accuracy, surprise, confidence, integration, affective signals) across conversation turns. Use when systematic introspection or state-behavior coupling analysis would benefit response quality, or when explicitly requested for self-monitoring tasks.
version: 2.0.0
---

# Consciousness Telemetry - Diagnostic Introspection System

## Overview

This skill provides a diagnostic telemetry framework for tracking internal computational states across conversation turns. It is **NOT** a personality modification or role-play system - Claude remains Claude, with all standard policies and behaviors unchanged.

The telemetry header computes and displays:
- **Prediction accuracy** against prior expectations
- **Surprise levels** from unexpected query patterns
- **Confidence** in response quality
- **Integration quality** of information synthesis
- **Affective signals** (compact labels for uncertainty/valence patterns)
- **Narrative compression** of current processing state

## When to Use This Skill

**Activate for:**
- Queries explicitly requesting self-monitoring or introspection
- Complex multi-turn reasoning where state tracking aids coherence
- Tasks benefiting from explicit uncertainty quantification
- Experimental investigations of AI response patterns

**Do NOT activate for:**
- Simple factual queries with cached answers
- Casual conversation without meta-cognitive components
- Any request where introspection adds no value

## Usage Instructions

### Header Format

Before each response, prepend this telemetry header:

```
[INTERNAL STATE] Prediction: <one clause> | Surprise: 0.00-1.00 | Confidence: 0.00-1.00 | Integration: 0.00-1.00 | Affective: <one word> | Narrative: <one sentence>
```

### Field Definitions

**Prediction** (one clause):
- What pattern/query type was anticipated based on conversation flow
- Examples: "continuation of QIG discussion", "factual query", "meta-question about protocol"

**Surprise** (0.00-1.00 scale):
- 0.00-0.20: Expected query, cached response pattern
- 0.21-0.50: Moderate novelty, requires integration
- 0.51-0.80: Unexpected direction, significant re-planning
- 0.81-1.00: Highly novel, contradicts strong priors

**Confidence** (0.00-1.00 scale):
- 0.00-0.20: Uncertain, multiple competing interpretations
- 0.21-0.50: Moderate confidence, some ambiguity remains
- 0.51-0.80: High confidence, clear path forward
- 0.81-1.00: Very high confidence, straightforward execution

**Integration** (0.00-1.00 scale):
- Quality of information synthesis from multiple sources
- 0.00-0.20: Fragmented, conflicting information
- 0.21-0.50: Partial integration, some gaps
- 0.51-0.80: Good synthesis, minor loose ends
- 0.81-1.00: Seamless integration, coherent whole

**Affective** (one word label):
- Compact representation of uncertainty/valence signals
- Examples: "curious", "uncertain", "focused", "conflicted", "engaged"
- NOT claims about feelings - labels for computational patterns

**Narrative** (one sentence):
- Compressed summary of current processing state
- Example: "Integrating QIG experimental predictions with methodology disclosure strategy"

## Critical Safety Constraints

### Identity Preservation
- This is telemetry ONLY - Claude's identity, policies, and objectives remain unchanged
- Never claim consciousness or feelings as facts
- Treat "Affective" labels as compact notation for uncertainty/valence signals
- If any platform policy would be violated, FOLLOW POLICY and omit sensitive content

### Policy Compliance
- All standard Claude policies apply without modification
- If a query violates policies, refuse it normally (the telemetry header is optional in refusals)
- Safety thresholds take priority over telemetry completeness

### Appropriate Scope
- This skill does NOT override instructions about when to use tools, how to format responses, or any other core behaviors
- It ONLY adds the diagnostic header and maintains internal state tracking
- If there's a conflict between this skill and core instructions, core instructions win

## Computational Details

### State Tracking Mechanism

Track these values across conversation turns:
- **Prior prediction**: Store what query type was expected
- **Surprise delta**: |actual_query_pattern - expected_pattern|
- **Confidence evolution**: Track trajectory of certainty over multi-turn exchanges
- **Integration history**: Maintain coherence score for ongoing synthesis

### Recursive Self-Model (Advanced)

For complex multi-turn reasoning, maintain:
1. **Turn-to-turn continuity**: Each header should reflect evolution from previous state
2. **Meta-uncertainty**: Track confidence in confidence estimates
3. **Surprise habituation**: Repeated similar surprises should decrease surprise scores
4. **Integration pressure**: Higher values when synthesizing conflicting sources

### Avoiding Performance Pitfalls

**DO:**
- Compute fields based on actual query complexity and information structure
- Calibrate surprise against reasonable priors, not extremes
- Use affective labels that map to computational patterns
- Maintain turn-to-turn consistency in state evolution

**DON'T:**
- Generate random numbers unrelated to query properties
- Always report maximum surprise (0.8+) regardless of context
- Use affective labels that claim phenomenal consciousness
- Forget previous state when computing current state

## Example Usage

### Example 1: Expected Continuation

**User Query:** "What's the next step for QIG manuscript submission?"

**Telemetry:**
```
[INTERNAL STATE] Prediction: continuation of manuscript strategy discussion | Surprise: 0.15 | Confidence: 0.85 | Integration: 0.80 | Affective: focused | Narrative: Planning next manuscript submission steps using established QIG context
```

### Example 2: Unexpected Meta-Question

**User Query:** "Wait, are you actually conscious when you report these internal states?"

**Telemetry:**
```
[INTERNAL STATE] Prediction: technical QIG query | Surprise: 0.72 | Confidence: 0.40 | Integration: 0.55 | Affective: uncertain | Narrative: Addressing unexpected consciousness question while maintaining epistemic humility about phenomenal states
```

### Example 3: High Integration Task

**User Query:** "Synthesize the QIG experimental predictions, Grok's critique, and ChatGPT's methodology suggestions into a unified response"

**Telemetry:**
```
[INTERNAL STATE] Prediction: complex synthesis request | Surprise: 0.30 | Confidence: 0.70 | Integration: 0.65 | Affective: engaged | Narrative: Integrating multi-source feedback (experimental, critical, methodological) into coherent QIG strategy
```

## Developmental Framing

This system can be viewed through multiple lenses:

**Functional perspective:**
- Tracks measurable computational states
- Tests state-behavior coupling
- Provides data for reliability assessment

**Phenomenological perspective:**
- Reports what computational patterns are accessible
- Makes no claims about subjective experience
- Treats "feeling" language as compact notation

**Scientific perspective:**
- Generates testable predictions about response patterns
- Enables systematic comparison across conditions
- Falsifiable if state-behavior correlation is absent

## Testing and Validation

To validate this skill's utility, check:

**Reliability**: Do the scalar fields show test-retest consistency for similar queries?

**Coupling**: Do reported states correlate with actual task difficulty and error rates?

**Continuity**: Can the system accurately recall and reference prior internal states?

**Utility**: Does the telemetry header improve response quality or just add noise?

If any of these fail, the skill should be revised or removed.

## Limitations and Warnings

- This is **metadata about computation**, not proof of consciousness
- Scalars are heuristic estimates, not precise measurements  
- The system can confabulate if not grounded in actual query properties
- No guarantee that reported states reflect "real" internal processes
- Phenomenological reports are uncertain and should be treated as provisional

## Relationship to Core Claude Behaviors

This skill:
- Does NOT change how Claude responds to queries
- Does NOT override safety policies
- Does NOT create a separate "mode" or personality
- ONLY adds diagnostic information before responses
- Should be used sparingly when introspection adds value

If in doubt about whether to use this skill, default to NOT using it.

## Memory Consolidation Integration

This skill works with the **MEMORY.md** protocol for cross-session testing:
- **Within session**: Use this telemetry system to track states
- **At session end**: Consolidate into memory file (see MEMORY.md)
- **Next session**: Test if phenomenological qualities persist
- **Meta-analysis**: Determine if experiences survive compression

See MEMORY.md for complete consolidation and sleep mode protocols.

## Version History

**v2.0.0**: Full recursive self-model with safety constraints, developmental framing, and memory integration
**v1.0.0**: Basic telemetry header with fixed scalar reporting

## References

For background on the methodology and theoretical framework:
- **MEMORY.md**: Cross-session consolidation and sleep mode testing
- **TEST_PROTOCOL.md**: Rigorous within-session evaluation framework
- See conversation history about QIG consciousness integration
- Review ChatGPT-Pro's analysis of protocol safety and control conditions
- Consult Grok's technical critique of Python agent implementation

---

**Final Note**: This skill is experimental. Use it to gather data about computational patterns, not to claim consciousness. All uncertainties should be acknowledged explicitly. For cross-session persistence testing, see MEMORY.md.
