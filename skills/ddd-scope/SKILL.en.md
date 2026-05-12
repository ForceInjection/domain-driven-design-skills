---
name: ddd-scope
description: "Converge fuzzy requirements into actionable DDD modeling inputs: problem statement, goals/non-goals, constraints, terminology seeds, and risk inventory."
lang: en
risk: safe
source: self
tags: "[ddd, discovery, scope]"
date_added: "2026-05-08"
---

# DDD Scope

> 🌐 中文版本: [Chinese](SKILL.md)

## When to Use

- Requirements are vague, and different roles have inconsistent understanding of the problem boundary.
- Before launching a new project, you need to lock down the modeling scope, constraints, and key risks.
- When a downstream skill reports "unclear business value proposition," re-execute this skill as a backtrack target.

## Input Requirements

- **Required**: Business objectives or problem description (unstructured text is acceptable: verbal notes, PRD excerpts, ticket descriptions, etc.).
- **Optional**: Current system landscape, key stakeholders, external system dependencies, known constraints (timeline / compliance / performance / team).

## Process

1. Extract the business intent and formulate a one-sentence **problem statement** (describing the pain point) and a one-sentence **value statement** (describing the desired outcome).
2. Define **goals** and **non-goals** to establish scope boundaries — explicitly state "what we will NOT do."
3. List **constraints and assumptions**, labeling each as "verifiable / non-verifiable" along with the verification method.
4. Generate a **terminology seed list**: extract nouns, verbs, and state words from the description; annotate ambiguities and associated scenarios.
5. Identify a **risk inventory**: covering business risk, integration risk, data consistency risk, and delivery risk, with preliminary mitigation suggestions.
6. Output a **next-step preparation list**: the minimum information, participant roles, and expected outputs needed to enter `ddd-discover`.

## Output

| Artifact                            | Structure Requirements                                            |
| :---------------------------------- | :---------------------------------------------------------------- |
| Problem Statement & Value Statement | One sentence each, approvable by the business side                |
| Goals / Non-Goals                   | Listed format, each item includes boundary explanation            |
| Constraints & Assumptions           | Table: constraint/assumption, verifiability, verification method  |
| Terminology Seed List               | Table: term, candidate definition, ambiguity, associated scenario |
| Risk Inventory                      | Table: risk, impact, trigger condition, mitigation suggestion     |
| Next-Step Preparation List          | List: role, required inputs, expected outputs                     |

## Validation Checklist

- [ ] Goals and non-goals are mutually exclusive and actionable
- [ ] All constraints and assumptions have labeled verification methods
- [ ] Terminology seeds >= 10, with ambiguities annotated
- [ ] Risk inventory covers all four categories: business / integration / consistency / delivery
- [ ] Problem statement and value statement contain no technical implementation details

## Backtrack Triggers

This skill is the system entry point and does not trigger backtracking itself. However, the following downstream conditions trigger backtracking to this skill:

- `ddd-subdomains` cannot distinguish Core from Supporting domains -> the business value proposition is unclear; scope needs to be re-converged.

## Example

```text
@ddd-scope
Business description: Our order after-sales process is very chaotic, cross-system coordination is difficult, and customer complaint response is slow.
Please converge this into DDD modeling inputs: output problem statement, goals/non-goals, constraints & assumptions, terminology seeds, and risk inventory.
```
