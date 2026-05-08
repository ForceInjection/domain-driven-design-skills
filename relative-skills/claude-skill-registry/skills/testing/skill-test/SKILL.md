---
name: skill-test
description: "Simple test skill to verify skills system is working. Use this skill when asked to test skills, verify skill discovery, or run a skill test."
version: 1.0.0
---

# Skill Test

A simple test skill to verify that the Claude Agent SDK skills system is functioning correctly.

## Purpose

This skill exists purely for testing. When invoked, it returns a simple JSON response to confirm:
1. Skills are being discovered from `.claude/skills/` directory
2. The SDK can invoke project-level skills
3. JSON responses are properly parsed

## When to Use

Use this skill when:
- Asked to "test skills"
- Asked to "verify skills work"
- Asked to "run a skill test"
- Testing the skills system

## What This Skill Does

Simply returns a JSON response with:
- A success flag
- A timestamp
- A greeting message
- The skill version

## Output Format

Return **ONLY** valid JSON. No markdown code fences, no explanation.

```json
{
  "success": true,
  "message": "Skill system is working!",
  "timestamp": "<current ISO timestamp>",
  "version": "1.0.0",
  "test_data": {
    "skill_name": "skill-test",
    "invocation_count": 1
  }
}
```

## Example Response

```json
{
  "success": true,
  "message": "Skill system is working!",
  "timestamp": "2025-10-24T12:34:56.789Z",
  "version": "1.0.0",
  "test_data": {
    "skill_name": "skill-test",
    "invocation_count": 1
  }
}
```

That's it! This skill should be trivial to invoke and verify.
