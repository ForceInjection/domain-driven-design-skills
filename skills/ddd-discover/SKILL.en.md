---
name: ddd-discover
description: "Collaborative domain discovery: produce event flows, command/event candidates, hotspots, and ambiguity lists through event storming or domain storytelling."
lang: en
risk: safe
source: self
tags: "[ddd, discovery, event-storming, domain-storytelling]"
date_added: "2026-05-08"
---

# DDD Discover

> 🌐 中文版本: [Chinese](SKILL.md)

## When to Use

- Need to quickly align on core business processes and domain boundary clues.
- Requirements are already defined (from `ddd-scope` or provided directly by the user), and you need to explore what happens inside the domain.
- When `ddd-contexts` reports "irreconcilable terminology conflicts," re-execute this skill as a backtrack target.

## Input Requirements

- **Required**: Business scenario description (user stories, PRDs, tickets, or output from `ddd-scope` are all acceptable).
- **Optional**: Key stakeholders and external systems, business constraints and non-goals (from `ddd-scope`).

## Process

1. **Enumerate events**: From the perspective of "facts that have occurred," name domain events in **past tense** (e.g., OrderPlaced, PaymentReceived).
2. **Complete commands**: For each event, identify the triggering command, the initiator, and key input data.
3. **Arrange timeline**: Organize events chronologically; identify branches, rollbacks, and exception paths (cover at least 1 main path + 2 exception paths).
4. **Mark hotspots**: Flag high-frequency events, strong consistency points, cross-system boundaries, performance-sensitive points, and compliance checkpoints.
5. **Generate ambiguity list**: Record terminology conflicts, unclear states, and ambiguous ownership; annotate "who must confirm."
6. **Output boundary clues**: Extract preliminary capability groupings and candidate context boundaries from event clusters and hotspot distribution.

## Output

| Artifact               | Structure Requirements                                                                                      |
| :--------------------- | :---------------------------------------------------------------------------------------------------------- |
| Event Flow Table       | Table: sequence, event name (past tense), triggering command, participant, input/output, exception branches |
| Command Candidate List | Table: command, initiator, expected result, idempotency requirement                                         |
| Event Candidate List   | Table: event, key fields, whether cross-context, whether externally published                               |
| Hotspot Annotations    | List: consistency hotspots, integration hotspots, performance hotspots, compliance hotspots                 |
| Ambiguity List         | Table: ambiguity, impact scope, party to confirm, suggested resolution                                      |
| Boundary Clues         | List: preliminary capability groupings and potential context boundaries                                     |

## Validation Checklist

- [ ] Events are named in past tense and are business-readable
- [ ] At least 1 main path + 2 exception/rollback paths are covered
- [ ] Hotspots explicitly mark cross-system boundaries and strong consistency points
- [ ] Each item in the ambiguity list annotates "who must confirm"
- [ ] Boundary clues can be directly consumed by `ddd-subdomains`

## Backtrack Triggers

- This skill is triggered for backtracking by `ddd-contexts`: when > 5 terms have irreconcilable cross-context conflicts, domain understanding is insufficient and rediscovery is needed.

## Example

```text
@ddd-discover
Based on the following scope output, help me perform domain discovery:
- Problem: Order after-sales process is chaotic
- Goals: Support refunds, exchanges, complaint handling
- Non-goals: Does not involve the forward order placement process
Please output the event flow table, command/event candidates, hotspot annotations, and ambiguity list.
```
