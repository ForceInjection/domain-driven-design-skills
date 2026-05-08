---
name: research-trigger
description: Natural language wrapper for research command - automatically triggers /research when users ask questions requiring deep research, best practices lookup, or multi-source information gathering
schema_version: 1.0
---

# research-trigger

**Type:** ANALYSIS-ONLY
**DAIC Modes:** DISCUSS, ALIGN, IMPLEMENT, CHECK (all modes)
**Priority:** High

## Trigger Reference

This skill activates on:
- **Keywords:** "research", "find information", "look up", "investigate", "best practices", "how do I", "what are the options", "search for", "find examples", "discover", "explore"
- **Intent Patterns:** `(research|investigate|find|lookup).*?`, `how.*(do I|implement|use|approach)`, `what.*(options|alternatives|ways to)`, `best practices.*?`, `(search|find|discover).*?(information|examples|docs)`

From: `skill-rules.json` - research-trigger configuration

## Purpose

Automatically trigger the `/research` slash command when users ask questions requiring deep research, best practices lookup, or multi-source information gathering using natural language. Eliminates the need to remember the `/research` syntax.

## Core Behavior

In any DAIC mode:

1. **Question Detection**
   - Detect when user asks research-oriented questions
   - Examples: "How do I implement JWT auth?", "What are best practices for caching?"
   - Automatically invoke `/research` with the question

2. **Intent Classification**
   - Identify research intent patterns:
     - How-to questions ("How do I...")
     - Comparison questions ("What are the options for...")
     - Best practices queries ("Best practices for...")
     - Investigation requests ("Research X", "Investigate Y")

3. **Research Invocation**
   - Call `/research` command with extracted question
   - Pass through to parallel research agents
   - Return comprehensive research findings with citations

## Natural Language Examples

**Triggers this skill:**
- ✓ "Research best practices for error handling"
- ✓ "How do I implement OAuth2?"
- ✓ "What are the options for state management?"
- ✓ "Find information about GraphQL subscriptions"
- ✓ "Investigate performance optimization techniques"
- ✓ "Look up JWT token refresh patterns"
- ✓ "Search for examples of Sentry integration"
- ✓ "Discover alternatives to Express middleware"
- ✓ "What are best practices for API versioning?"

**Does NOT trigger:**
- ✗ "What is the current mode?" (DAIC mode question, not research)
- ✗ "What's in progress?" (project status, not research)
- ✗ "What files changed?" (git status, not research)

## Safety Guardrails

**ANALYSIS-ONLY RULES:**
- ✓ NEVER call write tools (Edit, Write, MultiEdit)
- ✓ Only invokes /research command which is read-only
- ✓ Safe to run in any DAIC mode
- ✓ Provides research findings and recommendations only

**Invocation Rules:**
- Only invoke /research when clear research intent detected
- Extract the full question from user's message
- Handle "how", "what", "why" questions appropriately
- Distinguish research questions from status/info queries

## Implementation Notes

This skill acts as a natural language wrapper around `/research`. The actual research logic lives in `.claude/commands/research.md`, which:
- Classifies query type (breadth-first vs depth-first)
- Launches parallel research subagents
- Synthesizes findings with automatic citations
- Returns comprehensive research report

This skill simply detects the intent and routes to that command.
