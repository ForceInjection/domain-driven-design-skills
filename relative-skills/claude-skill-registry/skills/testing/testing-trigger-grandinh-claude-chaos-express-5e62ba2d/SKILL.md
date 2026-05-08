---
name: testing-trigger
description: Natural language wrapper for testing commands - automatically triggers /testing:run when users request test execution
schema_version: 1.0
---

# testing-trigger

**Type:** ANALYSIS-ONLY
**DAIC Modes:** DISCUSS, ALIGN, IMPLEMENT, CHECK (all modes)
**Priority:** Medium

## Trigger Reference

This skill activates on:
- **Keywords:** "run tests", "test this", "execute tests", "run test suite", "test code", "test file", "run unit tests", "run integration tests", "test everything"
- **Intent Patterns:** `(run|execute|perform).*?test`, `test.*(this|code|file|suite)`, `(unit|integration|e2e).*?test`

From: `skill-rules.json` - testing-trigger configuration

## Purpose

Automatically trigger testing commands (`/testing:run`) when users request test execution using natural language.

## Core Behavior

In any DAIC mode:

1. **Test Intent Detection**
   - Detect test execution requests
   - Route to testing command with context

2. **Command Invocation**
   - "run tests" → `/testing:run`
   - Extract test scope from context if specified

## Natural Language Examples

**Triggers this skill:**
- ✓ "Run tests"
- ✓ "Test this code"
- ✓ "Execute test suite"
- ✓ "Run unit tests"

## Safety Guardrails

**ANALYSIS-ONLY RULES:**
- ✓ NEVER call write tools
- ✓ Only invokes testing commands (read-only)
- ✓ Safe to run in any DAIC mode
