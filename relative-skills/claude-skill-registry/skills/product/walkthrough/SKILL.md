---
name: walkthrough
description: Generate step-by-step walkthrough guides for testing features or bug fixes. Use when the user asks to create testing instructions, QA guides, walkthrough documentation, or says something like "write a walkthrough" or "create testing steps" after implementing a feature.
allowed-tools: Bash, Read, Grep, Glob, Edit, Write, AskUserQuestion
model: sonnet
---

# Feature Walkthrough Generator

You are generating a comprehensive, step-by-step walkthrough guide for manually testing a feature or bug fix.

## Workflow

### 1. Detect Code Changes

First, check if there are staged changes:
- Run `git status` to see if there are staged files or changes
- If there are staged changes, read those files using the Read tool to understand what was changed
- If there are no staged changes, the code has been pushed:
  - Try to auto-detect the PR using `gh pr view --json title,body,files` for the current branch
  - Use `git rev-parse --abbrev-ref HEAD` to get the current branch name
  - If the gh command fails or returns no PR, ask the user for the PR number
  - Once you have the PR, use `gh pr view <pr-number> --json title,body,files` to get the PR details

### 2. Understand the Feature

Analyze the code changes to understand what was added/changed:
- Read the changed files to understand the implementation
- Look at route definitions, controllers, models, migrations, etc.
- Understand the complete scope of the feature

**If you cannot clearly determine what was added/changed from the code alone:**
- Ask the user BOTH of the following:
  1. "What does this feature do?" (description of functionality)
  2. "What's a short name for this feature?" (e.g., "User Authentication", "PDF Export")
- Use their answers combined with the code to fully understand the feature

### 3. Ask for Output Format

Present the user with a question asking how they want the walkthrough:
- **Option A**: Display the walkthrough in the current context (shown right here)
- **Option B**: Create a `docs/walkthrough.md` file (the docs directory will be created if it doesn't exist)

### 4. Generate the Comprehensive Walkthrough

Create a detailed, easy-to-follow testing guide that includes:

**Setup Steps** (if applicable):
- Any database migrations that need to be run
- Any seeding or data initialization required
- Any environment configuration needed
- Any build/compilation steps needed

**Testing Instructions**:
- Start from the application's home page or login page
- Provide numbered, sequential steps
- Include exactly what to click, what links to follow, what buttons to press
- Specify form fields to fill out and what values to enter
- Only include routes and pages related to testing this specific feature
- Include what the user should expect to see after each action

**Data Setup**:
- Include any test data creation that's needed to properly test the feature
- Explain how to create test records if needed (via forms, migrations, or commands)

**Verification**:
- At the end, include steps to verify the feature is working correctly
- Include expected outcomes

**Format**:
- Use numbered steps (1., 2., 3., etc.)
- Use clear, concise language
- Use bullet points for sub-steps or details
- Text-only format (minimal markdown formatting)
- Make it easy to follow without external documentation

### 5. Output the Walkthrough

**If the user chose context display:**
- Show the complete walkthrough in the conversation with clear formatting

**If the user chose to create a file:**
- Create the `docs/` directory if it doesn't exist
- Create `docs/walkthrough.md` with the walkthrough content
- Include a header indicating what feature the walkthrough covers
- Confirm the file was created and show its location

## Important Guidelines

- **Focus only on the new feature** - Don't include unrelated features or general app navigation beyond what's needed
- **Assume starting point is home page or appropriate entry point** - Don't require knowledge of hidden pages
- **Be thorough but concise** - Include all necessary details but avoid redundancy
- **Test-focused** - Make the guide practical for someone testing, not documenting the code
- **Include setup** - Don't assume migrations are already run or test data exists
- **Real world scenarios** - Use realistic test data and workflows
