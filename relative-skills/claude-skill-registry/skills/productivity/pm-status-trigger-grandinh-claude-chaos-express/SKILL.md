---
name: pm-status-trigger
description: Natural language wrapper for PM status commands - automatically triggers /pm:status, /pm:next, /pm:blocked, /pm:in-progress when users ask about project status, next tasks, or blockers
schema_version: 1.0
---

# pm-status-trigger

**Type:** ANALYSIS-ONLY
**DAIC Modes:** DISCUSS, ALIGN, IMPLEMENT, CHECK (all modes)
**Priority:** High

## Trigger Reference

This skill activates on:
- **Keywords:** "project status", "what's in progress", "what next", "what's blocked", "current work", "next task", "show status", "what am I working on", "what should I work on", "work status", "task status", "blockers", "blocked items"
- **Intent Patterns:** `(project|work).*(status|progress)`, `what.*(next|work on|in progress|blocked)`, `(show|display).*(status|progress|blockers)`, `what.*(should I|am I).*work`, `current.*(work|task|status)`

From: `skill-rules.json` - pm-status-trigger configuration

## Purpose

Automatically trigger PM status commands (`/pm:status`, `/pm:next`, `/pm:blocked`, `/pm:in-progress`) when users ask about project status, next tasks, or blockers using natural language.

## Core Behavior

In any DAIC mode:

1. **Status Query Detection**
   - Detect project status queries from natural language
   - Examples: "What's in progress?", "What should I work on next?", "What's blocked?"
   - Route to appropriate PM status command

2. **Command Routing**
   - **Next task:** "what next" → `/pm:next`
   - **In progress:** "what's in progress" → `/pm:in-progress`
   - **Blockers:** "what's blocked" → `/pm:blocked`
   - **General status:** "project status" → `/pm:status`

3. **Result Display**
   - Invoke appropriate PM command
   - Return formatted status information
   - Provide actionable next steps

## Natural Language Examples

**Triggers this skill:**
- ✓ "What should I work on next?"
- ✓ "What's in progress?"
- ✓ "Show me what's blocked"
- ✓ "Project status"
- ✓ "What am I currently working on?"
- ✓ "Next task"
- ✓ "Show blockers"
- ✓ "Current work status"

## Safety Guardrails

**ANALYSIS-ONLY RULES:**
- ✓ NEVER call write tools
- ✓ Only invokes PM status commands (read-only)
- ✓ Safe to run in any DAIC mode

## PM Commands Invoked

| Intent | Command | Purpose |
|--------|---------|---------|
| Next task | `/pm:next` | Show highest priority next task |
| In progress | `/pm:in-progress` | List all active work |
| Blockers | `/pm:blocked` | Show blocked items |
| Status | `/pm:status` | General project overview |
