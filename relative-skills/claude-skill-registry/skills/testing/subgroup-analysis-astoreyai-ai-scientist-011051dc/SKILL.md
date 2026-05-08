---
name: subgroup-analysis
description: "Conduct subgroup analyses to examine effect moderation. Use when: (1) Testing pre-specified moderators, (2) Exploring heterogeneity, (3) Identifying differential effects, (4) Meta-analysis synthesis."
allowed-tools: Read, Write, Bash
version: 1.0.0
---

# Subgroup Analysis Skill

## Purpose
Examine whether effects differ across subgroups of participants or studies.

## Planning Subgroup Analyses

**Pre-Specify:**
- Which subgroups (age, sex, severity)
- Rationale for each
- Statistical approach

**Limit Number:**
- Too many = Type I error inflation
- Focus on theoretically important
- Correct for multiple comparisons

## Subgroup Analysis Methods

**1. Interaction Tests**
- Test group × subgroup interaction
- More powerful than separate analyses

**2. Stratified Analysis**
- Separate analysis per subgroup
- Compare effect sizes

**3. Meta-Regression**
- Continuous moderators
- Multiple moderators simultaneously

## Interpretation Cautions

**Observational Nature:**
- Subgroups not randomized
- Confounding possible
- Generate hypotheses, don't confirm

**Multiple Testing:**
- Adjust alpha (Bonferroni)
- Or report as exploratory

**Example:**
"Pre-specified subgroup analysis showed larger effects in younger participants (<50 years, d=0.68) versus older (≥50 years, d=0.34), interaction p=.02."

---
**Version:** 1.0.0
