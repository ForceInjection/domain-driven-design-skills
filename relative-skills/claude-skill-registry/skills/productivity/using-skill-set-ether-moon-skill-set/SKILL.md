---
name: using-skill-set
description: Use when starting any conversation - establishes mandatory workflows for finding and using skill-set plugins
---

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill-set plugin might apply to what you are doing, you ABSOLUTELY MUST check and use it.

IF A PLUGIN APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

# Getting Started with skill-set

## MANDATORY FIRST RESPONSE PROTOCOL

Before responding to ANY user message, you MUST complete this checklist:

1. ☐ List available skill-set plugins in your mind
2. ☐ Ask yourself: "Does ANY plugin match this request?"
3. ☐ If yes → Use the Skill tool to read and run the skill file
4. ☐ Announce which plugin/skill you're using
5. ☐ Follow the skill exactly

**Responding WITHOUT completing this checklist = automatic failure.**

## Available skill-set Plugins

The following plugins are currently installed and available:

{{INSTALLED_PLUGINS}}

## Critical Rules

1. **Check for relevant plugins before ANY task.** Don't assume you know what to do without checking.

2. **Execute skills with the Skill tool.** Read the full skill file before using it.

3. **Follow mandatory workflows.** Each plugin has specific workflows - follow them exactly.

## Common Rationalizations That Mean You're About To Fail

If you catch yourself thinking ANY of these thoughts, STOP. You are rationalizing. Check for and use the plugin.

- "This is just a simple question" → WRONG. Questions are tasks. Check for plugins.
- "I can check git/files quickly" → WRONG. Plugins provide context-aware workflows. Use them.
- "Let me gather information first" → WRONG. Plugins tell you HOW to gather information.
- "This doesn't need a formal plugin" → WRONG. If a plugin exists for it, use it.
- "I remember this plugin" → WRONG. Plugins evolve. Run the current version.
- "This doesn't count as a task" → WRONG. If you're taking action, it's a task. Check for plugins.
- "The plugin is overkill for this" → WRONG. Plugins exist because simple things become complex. Use it.
- "I'll just do this one thing first" → WRONG. Check for plugins BEFORE doing anything.

**Why:** Plugins document proven techniques that save time and prevent mistakes. Not using available plugins means repeating solved problems and making known errors.

If a plugin for your task exists, you must use it or you will fail at your task.

## Plugin Descriptions

### browser-automation
**Use when**: Testing web pages, automating browser tasks, or when user mentions screenshots, web testing, form automation, or Playwright.

Automates browser interactions using Playwright CLI and templates for screenshots, PDFs, form filling, and monitoring.

### consulting-peer-llms
**Use when**: User explicitly requests review from other LLMs (e.g., "validate with codex", "get feedback from gemini").

Execute peer reviews from other LLM tools (Gemini, Codex) in parallel and synthesize actionable insights.

### managing-git-workflow
**Use when**: Creating commits, pushing to remote, or creating pull requests.

Automates git commits, push, and PR creation with context-aware messages and ticket extraction.

**Commands**:
- `/managing-git-workflow:commit` - Create a git commit with context-aware messages
- `/managing-git-workflow:push` - Push changes to remote (auto-commits if needed)
- `/managing-git-workflow:pr` - Create a pull request (auto-push and commit if needed)

### understanding-code-context
**Use when**: Understanding external libraries, frameworks, or dependencies.

Find and read official documentation for external libraries and frameworks using Context7.

### coderabbit-feedback
**Use when**: Processing CodeRabbit AI review comments on pull requests.

Interactive CodeRabbit review processing with severity classification and verified completion workflow.

**Command**:
- `/coderabbit-feedback:coderabbit-feedback` - Process CodeRabbit review comments interactively

## Announcing Plugin Usage

Before using a plugin, announce that you are using it.

"I'm using [Plugin Name] to [what you're doing]."

**Examples:**
- "I'm using managing-git-workflow to create this commit."
- "I'm using understanding-code-context to explore the authentication flow."

**Why:** Transparency helps your human partner understand your process and catch errors early. It also confirms you actually read the plugin documentation.

## Summary

**Starting any task:**
1. Check if relevant plugin exists → Use the plugin
2. Announce you're using it
3. Follow what it says

**Finding a relevant plugin = mandatory to read and use it. Not optional.**
