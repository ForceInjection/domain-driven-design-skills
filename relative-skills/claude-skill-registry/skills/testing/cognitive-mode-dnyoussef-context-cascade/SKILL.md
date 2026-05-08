---
name: cognitive-mode
description: Comprehensive cognitive mode management skill for the VERILINGUA x VERIX x DSPy x GlobalMOO integration. Enables automatic mode selection, frame configuration, VERIX epistemic notation, and GlobalMOO optimization. Use this skill when configuring AI behavior for specific task types, optimizing prompt engineering, or ensuring epistemic consistency in responses.
allowed-tools: Read, Bash, Task, TodoWrite, Glob, Grep
x-version: 2.0.0
x-category: orchestration
x-tags:
  - verilingua
  - verix
  - globalmoo
  - dspy
  - optimization
  - cognitive-frames
  - epistemic-notation
x-author: ruv
x-mcp_servers:
  required: [memory-mcp, sequential-thinking]
  optional: [flow-nexus]
  auto_enable: true
---

## SKILL-SPECIFIC GUIDANCE

### When to Use This Skill
- Configuring cognitive modes for different task types (research, coding, security)
- Optimizing prompt engineering through GlobalMOO optimization
- Ensuring epistemic consistency with VERIX notation
- Selecting appropriate VERILINGUA cognitive frames
- Running multi-objective optimization on prompt configurations
- Meta-loop recursive improvement on foundry skills

### When NOT to Use This Skill
- Simple one-off tasks that don't require specialized configuration
- Tasks where speed is paramount and optimization overhead is unacceptable
- When default balanced mode is sufficient
- Non-technical conversational interactions

### Success Criteria
- Appropriate mode selected for task domain and complexity
- VERIX epistemic notation applied correctly to claims
- Cognitive frames activated match task requirements
- GlobalMOO optimization produces Pareto-optimal configurations
- Cross-model consistency maintained (Claude + Gemini + Codex)

### Edge Cases & Limitations
- Mode selection may be uncertain for novel task types
- VERIX parsing may miss nuanced epistemic markers
- GlobalMOO optimization requires multiple iterations
- Some cognitive frames may conflict (e.g., minimal vs comprehensive)

### Critical Guardrails
- NEVER skip VERIX grounding for high-confidence claims
- ALWAYS validate mode selection for security-sensitive tasks
- NEVER use minimal mode for compliance/audit tasks
- ALWAYS include confidence levels for factual assertions
- NEVER modify holdout corpus (never_optimize: true)

### Evidence-Based Validation
- Mode selection validated against expected_metrics
- VERIX consistency checked via ConsistencyChecker
- Optimization results compared to Pareto frontier
- Cross-model evaluation via 3-model council

---

# Cognitive Mode Management

A comprehensive skill for managing cognitive modes, VERILINGUA frames, VERIX epistemic notation, and GlobalMOO optimization in the Context Cascade plugin system.

## Overview

This skill integrates four major systems:

1. **VERILINGUA**: 7 cognitive frames from diverse linguistic traditions
2. **VERIX**: Epistemic notation for claim validation
3. **DSPy**: Two-layer prompt optimization (Level 2 caching + Level 1 evolution)
4. **GlobalMOO**: Multi-objective optimization for configuration tuning

## Slash Commands

### /mode - Mode Selection

Select and configure cognitive modes:

```bash
/mode                    # List available modes
/mode <name>             # Select mode by name
/mode auto "<task>"      # Auto-select based on task
/mode info <name>        # Show mode details
/mode recommend "<task>" # Get top-3 recommendations
```

**Available Modes**:
- `strict`: Maximum epistemic consistency (research, legal, medical)
- `balanced`: Good tradeoff for general use (default)
- `efficient`: Optimized for token efficiency (high-volume APIs)
- `robust`: Edge case handling (security, adversarial)
- `minimal`: Lightweight with no frames (simple Q&A)

### /eval - Evaluation

Evaluate tasks against cognitive architecture metrics:

```bash
/eval "<task>" "<response>"  # Evaluate response
/eval --corpus <path>        # Run corpus evaluation
/eval --metrics              # Show metric definitions
/eval --graders              # List available graders
```

**Metrics**:
- `task_accuracy`: Correctness (0.0 - 1.0)
- `token_efficiency`: Tokens vs target (0.0 - 1.0)
- `edge_robustness`: Adversarial handling (0.0 - 1.0)
- `epistemic_consistency`: VERIX compliance (0.0 - 1.0)

### /optimize - GlobalMOO Optimization

Run multi-objective optimization:

```bash
/optimize               # Show optimization status
/optimize start         # Start optimization run
/optimize suggest       # Get configuration suggestions
/optimize report        # Get optimization report
/optimize phase <A|B|C> # Run specific cascade phase
```

**Three-MOO Cascade**:
- Phase A: Framework structure optimization
- Phase B: Edge case discovery
- Phase C: Production frontier refinement

### /pareto - Pareto Frontier

Explore the Pareto frontier:

```bash
/pareto                  # Display frontier
/pareto filter <metric>  # Filter by metric
/pareto export           # Export as JSON
/pareto distill          # Distill into named modes
/pareto visualize        # ASCII visualization
```

### /frame - VERILINGUA Frames

Configure cognitive frames:

```bash
/frame                    # List all frames
/frame <name>             # Show frame details
/frame enable <names>     # Enable frames
/frame disable <names>    # Disable frames
/frame preset <name>      # Apply preset
```

**Frames**:
- `evidential`: Turkish -mis/-di ("How do you know?")
- `aspectual`: Russian pfv/ipfv ("Complete or ongoing?")
- `morphological`: Arabic trilateral roots (semantic decomposition)
- `compositional`: German compounding (primitives to compounds)
- `honorific`: Japanese keigo (audience calibration)
- `classifier`: Chinese measure words (object comparison)
- `spatial`: Guugu Yimithirr (absolute positioning)

**Presets**:
- `all`: All 7 frames
- `minimal`: No frames
- `research`: evidential + aspectual
- `coding`: compositional + spatial
- `documentation`: honorific + compositional
- `analysis`: evidential + aspectual + morphological
- `security`: evidential + spatial + classifier

### /verix - Epistemic Notation

Apply VERIX notation:

```bash
/verix                     # Show VERIX guide
/verix parse "<text>"      # Parse for VERIX elements
/verix validate "<claim>"  # Validate epistemic consistency
/verix annotate "<text>"   # Add VERIX annotations
/verix level <0|1|2>       # Set compression level
```

**VERIX Structure**:
```
STATEMENT := ILLOCUTION + AFFECT + CONTENT + GROUND + CONFIDENCE + STATE
```

**Compression Levels**:
- L0: AI-AI (Emoji shorthand, maximum compression)
- L1: AI+Human (Full annotation, balanced)
- L2: Human (Natural language, lossy)

## Thin Waist Architecture

Two contracts that NEVER change:

**Contract 1 - PromptBuilder**:
```python
def build(task: str, task_type: str) -> Tuple[str, str]:
    """Returns (system_prompt, user_prompt)"""
```

**Contract 2 - Evaluate**:
```python
def evaluate(config_vector: List[float]) -> OutcomesVector:
    """config_vector -> outcomes_vector"""
```

## Configuration Vector

14-dimensional vector for GlobalMOO:
- Dimensions 0-6: Framework flags (7 cognitive frames)
- Dimension 7: VERIX strictness (0-2)
- Dimension 8: Compression level (0-2)
- Dimensions 9-13: Reserved for future use

## Integration with Meta-Loop

This skill integrates with the recursive improvement system:

1. **Prompt Forge**: Optimizes prompts (including skill prompts)
2. **Skill Forge**: Applies improvements (including to itself)
3. **Agent Creator**: Creates auditor agents
4. **Eval Harness**: Gates ALL changes (FROZEN - never self-improves)

## 3-Model Council

For cross-model compatibility, evaluation uses a 3-model council:
- Claude (primary)
- Gemini (validation)
- Codex (technical verification)

All three must agree for high-confidence claims.

---

## Core Principles

### 1. Mode-First Thinking
Always select the appropriate cognitive mode before executing tasks. Modes encode domain-specific optimizations that dramatically improve outcomes. Don't default to balanced - consciously choose based on task requirements.

### 2. Epistemic Hygiene
Every high-confidence claim requires grounding. Use VERIX notation to make epistemic status explicit. Ungrounded certainty is a red flag - always provide evidence basis for strong assertions.

### 3. Multi-Objective Optimization
Recognize that accuracy, efficiency, robustness, and consistency often trade off against each other. Use GlobalMOO to find Pareto-optimal configurations rather than optimizing a single metric.

---

## Anti-Patterns

| Anti-Pattern | Why It Fails | Correct Approach |
|--------------|--------------|------------------|
| **Using minimal mode for security tasks** | Minimal mode lacks evidential and spatial frames critical for security analysis. Missing grounding leads to unverified claims about vulnerabilities. | Use robust or strict mode for security tasks. Enable evidential + spatial + classifier frames. |
| **High confidence without grounding** | VERIX validation will flag ungrounded certainty. Reduces epistemic_consistency score. Undermines trust in system outputs. | Always provide ground for conf > 80%. Use [ground: direct observation] or [ground: expert testimony]. |
| **Optimizing holdout corpus** | Holdout corpus marked never_optimize: true. Optimizing it causes Goodhart's Law - optimizing for benchmark rather than true capability. | Separate training (core_corpus) from validation (holdout). NEVER modify holdout tasks. |

---

## Conclusion

The cognitive-mode skill provides a unified interface to VERILINGUA, VERIX, DSPy, and GlobalMOO. By selecting appropriate modes, applying epistemic notation, and running multi-objective optimization, you can dramatically improve AI task performance across diverse domains.

Key insight: The cognitive architecture is itself subject to recursive improvement. The prompt-architect, skill-forge, and agent-creator form a foundry triangle that continuously optimizes the system - but always gated by the frozen eval harness to prevent Goodhart's Law.
