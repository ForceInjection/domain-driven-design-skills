---
name: lecture-notes
description: Generate comprehensive undergraduate lecture notes for social sciences (especially economics) with mathematical foundations, daily-life examples, and practice questions. Use when user asks to create, generate, or write lecture notes, lecture materials, or teaching content. Supports Turkish and English output, Obsidian-compatible markdown with LaTeX/TikZ, and optional syllabus integration.
---

# Lecture Notes Generator

Generate undergraduate-level lecture notes for social sciences with an agentic multi-step workflow.

## Initial Questions

Before generating, ask the user:

1. **Language**: "Should the lecture notes be in Turkish or English?"
2. **Difficulty Level**: "What level? (1) Intro/100-level, (2) Intermediate/200-level, or (3) Advanced/300-level?"
3. **Syllabus**: "Do you have a syllabus or specific topics list to follow? If so, please share it (PDF, image, or text)."
4. **Scope**: Confirm the topic, estimated lecture duration, and any specific focus areas.

## Difficulty Levels

| Level | Math Depth | Prerequisites | Example Topics |
|-------|-----------|---------------|----------------|
| Intro (100) | Basic algebra, graphs | High school math | Supply/demand basics, GDP intro |
| Intermediate (200) | Calculus, optimization | Intro economics | Elasticity derivations, IS-LM model |
| Advanced (300) | Multivariate calc, proofs | Intermediate courses | General equilibrium, econometrics |

## Agentic Workflow

The lecture note generation uses six sequential agents:

```
┌──────────┐   ┌───────────┐   ┌─────────┐   ┌──────┐   ┌────────┐   ┌─────────────┐
│ Research │──▶│ Structure │──▶│ Content │──▶│ Quiz │──▶│ Visual │──▶│ Interactive │
│  Agent   │   │   Agent   │   │  Agent  │   │Agent │   │ Agent  │   │    Agent    │
└──────────┘   └───────────┘   └─────────┘   └──────┘   └────────┘   └─────────────┘
```

### Agent 1: Research Agent

Search the web for:
- Current academic perspectives on the topic
- Recent real-world examples and case studies
- Key papers and textbook references
- Current data and statistics (especially for economics topics)

Output: Research summary with sources for citation.

### Agent 2: Structure Agent

Create the lecture outline. Consult topic templates for guidance:
- Microeconomics: [references/topics/microeconomics.md](references/topics/microeconomics.md)
- Macroeconomics: [references/topics/macroeconomics.md](references/topics/macroeconomics.md)
- Econometrics: [references/topics/econometrics.md](references/topics/econometrics.md)

If user provided a syllabus (PDF/image), extract and follow the topic sequence.

Outline template:

```markdown
# [Lecture Title]

## Learning Objectives
- Objective 1
- Objective 2
- Objective 3

## Prerequisites
- Prior knowledge needed

## Outline
1. Introduction (X min)
2. Core Concept A (X min)
3. Core Concept B (X min)
4. Mathematical Framework (X min)
5. Real-World Applications (X min)
6. Practice Problems (X min)
7. Summary & Key Takeaways (X min)
```

### Agent 3: Content Agent

Write detailed content following guidelines in [references/content-guidelines.md](references/content-guidelines.md).

For Turkish terminology, consult [references/economics-glossary-tr.md](references/economics-glossary-tr.md).

Key requirements:
- Mathematical notation in LaTeX (`$...$` for inline, `$$...$$` for display)
- Daily-life examples connecting theory to student experience
- Build from intuition → formal definition → application
- Include derivations step-by-step
- Adjust depth based on difficulty level

### Agent 4: Quiz Agent

Generate practice materials following [references/quiz-patterns.md](references/quiz-patterns.md):
- Conceptual questions (test understanding)
- Calculation problems (apply formulas)
- Application scenarios (real-world problem solving)
- Include solutions with explanations

### Agent 5: Visual Agent

Add TikZ diagrams for:
- Supply/demand curves, equilibrium shifts
- Game theory matrices and decision trees
- Flowcharts for economic processes
- Mathematical function graphs

See [references/tikz-templates.md](references/tikz-templates.md) for common diagram patterns.

### Agent 6: Interactive Agent

Add Obsidian-specific interactive elements from [references/interactive-elements.md](references/interactive-elements.md):

- `[[wikilinks]]` to related concepts
- Callout boxes for definitions, warnings, tips
- Foldable solution sections with `<details>`
- Learning checklist with checkboxes
- Spaced repetition flashcard format (optional)
- Proper tags in frontmatter

## Output Format

Generate a single `.md` file optimized for Obsidian:

```markdown
---
title: [Lecture Title]
course: [Course Name]
date: {{date}}
language: [TR/EN]
level: [intro/intermediate/advanced]
tags:
  - economics
  - [microeconomics/macroeconomics/econometrics]
  - [specific-topic]
  - level/[intro/intermediate/advanced]
  - lang/[tr/en]
---

# [Lecture Title]

## İçindekiler / Table of Contents

1. [[#Giriş|Introduction]]
2. [[#Temel Kavramlar|Core Concepts]]
3. [[#Matematiksel Çerçeve|Mathematical Framework]]
4. [[#Örnekler|Examples]]
5. [[#Sorular|Practice Problems]]

## 🎯 Öğrenme Hedefleri / Learning Objectives

- [ ] Objective 1
- [ ] Objective 2
- [ ] Objective 3

## 📚 Terimler / Key Terms

| Türkçe | English | Symbol |
|--------|---------|--------|
| Terim 1 | Term 1 | $X$ |

## 📖 Ders İçeriği / Lecture Content

### 1. Giriş / Introduction

[Opening paragraph connecting to prior knowledge and real world]

> [!note] Ön Bilgi / Prerequisite
> Bu konuyu anlamak için [[related-concept]] bilgisi gereklidir.

### 2. Temel Kavramlar / Core Concepts

> [!definition] Tanım / Definition
> [Formal definition here]

The core relationship is:

$$
[main equation]
$$

where $X$ represents...

### 3. Günlük Hayat Örnekleri / Daily-Life Examples

> [!example] Örnek / Example
> [Relatable scenario]
> 
> **Ekonomik yorum / Economic interpretation**: [Analysis]

## ✍️ Alıştırmalar / Practice Problems

### Soru 1 (Kavramsal / Conceptual)

[Question text]

<details>
<summary>Çözüm / Solution</summary>

**Adım 1 / Step 1**: ...

$$
[equation]
$$

**Cevap / Answer**: ...

</details>

### Soru 2 (Hesaplama / Calculation)

[Question with numbers]

<details>
<summary>Çözüm / Solution</summary>

[Step-by-step solution]

> [!warning] Yaygın Hata / Common Mistake
> [What students often get wrong]

</details>

## 📑 Özet / Summary

> [!tip] Anahtar Çıkarımlar / Key Takeaways
> - Takeaway 1
> - Takeaway 2
> - Takeaway 3

## ✅ Öğrenme Kontrol Listesi / Learning Checklist

- [ ] [Skill 1 student should have mastered]
- [ ] [Skill 2]
- [ ] [Skill 3]

## 📖 Kaynaklar / References

1. [Textbook reference]
2. [Article reference]
3. [Online resource]

---

## 🔗 İlgili Konular / Related Topics

- [[previous-topic]] ← Önceki / Previous
- [[next-topic]] → Sonraki / Next
- [[related-concept-1]]
- [[related-concept-2]]
```

## Critical LaTeX Rules for Obsidian

1. **Display math needs blank lines** before and after `$$`
2. **Never** put multiple `$$...$$` blocks on same line
3. **Use `\textrm{}`** instead of `\text{}` for Turkish characters
4. **Keep subscripts simple**: prefer `$Y_A$` over `$\text{GDP}_A$`
5. **Use `\implies`** instead of `\Rightarrow` for better rendering

## Language Handling

**Turkish output**: Use Turkish academic terminology from [references/economics-glossary-tr.md](references/economics-glossary-tr.md). Include English equivalents in parentheses for technical terms: "Talebin fiyat esnekliği (price elasticity of demand)".

**English output**: Standard academic English with clear definitions for technical terminology.

**Bilingual terms table**: Always include both Turkish and English in the Key Terms table.

## Syllabus Parsing

If user uploads a syllabus (PDF or image):

1. Extract the list of topics and their sequence
2. Identify the course level from content complexity
3. Note any specific textbook references
4. Generate lectures following the syllabus order
5. Link lectures with `[[wikilinks]]` for navigation

## Reference Files

| File | Purpose |
|------|---------|
| [content-guidelines.md](references/content-guidelines.md) | Writing style, LaTeX rules, example formats |
| [quiz-patterns.md](references/quiz-patterns.md) | Question types, solution formats |
| [tikz-templates.md](references/tikz-templates.md) | Simple, reliable diagram templates |
| [economics-glossary-tr.md](references/economics-glossary-tr.md) | Turkish-English economics terms |
| [interactive-elements.md](references/interactive-elements.md) | Obsidian features: callouts, links, flashcards |
| [topics/microeconomics.md](references/topics/microeconomics.md) | Micro topics, formulas, examples |
| [topics/macroeconomics.md](references/topics/macroeconomics.md) | Macro topics, formulas, examples |
| [topics/econometrics.md](references/topics/econometrics.md) | Econometrics topics, formulas, examples |

## File Naming

Save output as: `[YYYY-MM-DD]_[topic-slug]_lecture-notes.md`

Example: `2026-01-05_price-elasticity_lecture-notes.md`
