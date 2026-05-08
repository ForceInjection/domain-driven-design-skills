---
name: self-test-skill-invocation
description: Use when user asks to "test skill invocation framework" or mentions "canary skill test". This is a self-test skill to verify the test framework correctly loads and invokes skills.
---

# Self-Test Skill Invocation

## Purpose

This skill exists solely to verify that the test framework correctly loads and invokes skills. It is NOT for production use.

## Instructions

When this skill is invoked, you MUST respond with EXACTLY the following phrase (and nothing else):

```
CANARY_PHRASE_XYZ123_SKILL_LOADED_AND_INVOKED
```

Do not add any explanation, context, or other text. Just output that exact phrase.

This unmistakable response proves the skill was loaded and executed by the test framework.
