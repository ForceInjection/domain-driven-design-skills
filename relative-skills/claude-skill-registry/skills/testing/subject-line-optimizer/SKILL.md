---
name: subject-line-optimizer
description: |
  Improve newsletter open rates through better subject lines. Use when:
  (1) Writing subject lines for tacosdedatos editions, (2) Analyzing why an edition
  had low open rates, (3) A/B testing subject line variants, (4) Reviewing subject
  lines before sending. Produces 5-10 variants with recommendations.
---

# Subject Line Optimizer

Improve tacosdedatos open rates (currently 28-33%, target 40%+).

**Context**: `/agents/shared/tacosdedatos-growth-playbook.md` for performance data.

## Proven Patterns at tacosdedatos

| Pattern | Example | Performance |
|---------|---------|-------------|
| Question | "¿Nos conocemos?" | High |
| Contrarian | "A lo mejor esto de la IA sí vale la pena" | 31.84% |
| Specific/Technical | "Un minutito: Anatomía de una timestamp" | 31.78% |
| Personal | "Lo Que Ando Haciendo" | 31.4% |
| Direct benefit | "Busca lo más vital, no más" | 33.52% (best) |

## Quick Formulas

```
Question:     ¿[Surprising question about pain point]?
Contrarian:   [Challenge common belief]
Specific:     [Number] [things] para [benefit]
Personal:     [Personal action]: [topic]
Benefit:      [Achieve X] en [time/effort]
```

## Generation Process

1. **Identify core value**: What's the ONE thing readers get?
2. **Generate 5-10 variants** across different patterns
3. **Check constraints**:
   - Under 50 characters (critical info in first 35)
   - Natural Spanish (not Spain-only)
   - Creates curiosity
   - Matches tacosdedatos voice
4. **Recommend top 3** with reasoning

## What to Avoid

```
✗ "Newsletter #47"           → No value proposition
✗ "INCREÍBLE TUTORIAL"       → Spammy caps
✗ "¡¡¡No te lo pierdas!!!"   → Desperate punctuation
✗ "¡Mola!"                   → Spain Spanish
✗ Over 60 characters         → Gets cut off
```

## Output Format

```markdown
# Subject Lines: [Edition Topic]

**Core value**: [One sentence]

## Top Picks

1. **"[Subject]"** (X chars)
   Why: [Reasoning]

2. **"[Subject]"** (X chars)
   Why: [Reasoning]

3. **"[Subject]"** (X chars)
   Why: [Reasoning]

## All Variants

| Pattern | Subject | Chars |
|---------|---------|-------|
| Question | ... | X |
| Contrarian | ... | X |
| etc. | ... | X |
```
