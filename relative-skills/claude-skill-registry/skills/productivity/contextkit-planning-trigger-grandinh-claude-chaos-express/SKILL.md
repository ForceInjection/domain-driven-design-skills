---
name: contextkit-planning-trigger
description: Natural language wrapper for ContextKit planning commands - automatically triggers /ctxk:plan commands when users request planning assistance
schema_version: 1.0
---

# contextkit-planning-trigger

**Type:** ANALYSIS-ONLY
**DAIC Modes:** DISCUSS, ALIGN, IMPLEMENT, CHECK (all modes)
**Priority:** Medium

## Trigger Reference

This skill activates on:
- **Keywords:** "plan this", "how should I approach", "create plan", "quick plan", "break down into steps", "research tech", "planning", "approach", "strategy", "implementation plan"
- **Intent Patterns:** `(plan|approach|strategy).*(this|feature|task)`, `how.*?(approach|implement|structure)`, `break.*?down.*?steps`, `research.*(tech|technology|options)`, `create.*(plan|strategy)`

From: `skill-rules.json` - contextkit-planning-trigger configuration

## Purpose

Automatically trigger ContextKit planning commands (`/ctxk:plan:quick`, `/ctxk:plan:1-spec`, `/ctxk:plan:2-research-tech`, `/ctxk:plan:3-steps`) when users request planning assistance using natural language.

## Core Behavior

In any DAIC mode:

1. **Planning Intent Detection**
   - Detect planning requests from natural language
   - Route to appropriate ContextKit planning command

2. **Command Routing**
   - **Quick planning:** "plan this feature" → `/ctxk:plan:quick`
   - **Detailed spec:** "create detailed spec" → `/ctxk:plan:1-spec`
   - **Tech research:** "research technology options" → `/ctxk:plan:2-research-tech`
   - **Implementation steps:** "break down into steps" → `/ctxk:plan:3-steps`

## Natural Language Examples

**Triggers this skill:**
- ✓ "Plan this feature"
- ✓ "How should I approach this?"
- ✓ "Break down into steps"
- ✓ "Research tech options"
- ✓ "Create implementation plan"

## Safety Guardrails

**ANALYSIS-ONLY RULES:**
- ✓ NEVER call write tools
- ✓ Only invokes ContextKit planning commands (read-only)
- ✓ Safe to run in any DAIC mode
