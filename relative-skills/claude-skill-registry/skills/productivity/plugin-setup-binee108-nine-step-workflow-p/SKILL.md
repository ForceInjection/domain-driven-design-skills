---
name: plugin-setup
description: Interactive plugin setup wizard for first-time configuration. Use when user requests plugin setup, initial configuration, or asks for help setting up the nine-step workflow plugin.
---

# Plugin Setup Wizard

Guide users through initial plugin configuration using interactive questions. This skill helps users configure the plugin for their project with recommended settings.

## When to Use

Activate this skill when:
- User asks for "plugin setup" or "configure plugin"
- User mentions "initial setup" or "getting started"
- User says "help me set up" or "configuration help"
- First time using the plugin in a project
- User wants to customize plugin settings

## Setup Process

### Step 1: Welcome and Context

Present a brief welcome message:
```
Welcome to Nine-Step Workflow Plugin setup!
I'll help you configure the plugin for your project with a few quick questions.
```

### Step 2: Load Interactive Questions Skill

```
Use Skill("interactive-questions") to structure all configuration questions.
```

### Step 3: Ask Configuration Questions

Use the `interactive-questions` skill to ask these questions in sequence:

#### Question 1: Project Type

```
What type of project are you working on?

Options:
- Backend API (Python/Node.js/etc.)
- Frontend Application (React/Vue/Angular)
- Full-stack Application (Both backend and frontend)
- Other (CLI tools, libraries, etc.)
```

**Purpose**: Determines which agents and workflows to prioritize.

#### Question 2: Issue Tracker Integration

```
Do you use an issue tracker for this project?

Options:
- GitHub Issues (Recommended for GitHub projects)
- GitLab Issues
- Jira
- Linear
- None (Manual workflow only)
```

**Purpose**: Configures issue management integration.

#### Question 3: Git Worktree Strategy

```
How should the plugin handle feature branches?

Options:
- Git Worktree (Recommended - Isolated workspaces)
- Regular Branches (Traditional workflow)
- Manual (I'll manage branches myself)
```

**Purpose**: Determines branch and workspace management strategy.

#### Question 4: Testing Framework

```
What testing framework does your project use?

Options:
- pytest (Python)
- Jest (JavaScript/TypeScript)
- JUnit (Java)
- RSpec (Ruby)
- Other/None (Will be prompted during testing)
```

**Purpose**: Configures test execution commands.

#### Question 5: Documentation Level

```
How detailed should the documentation be?

Options:
- Comprehensive (Full docstrings, extensive comments)
- Balanced (Key functions documented, essential comments)
- Minimal (Only complex logic documented)
```

**Purpose**: Sets documentation standards for the documentation-manager agent.

#### Question 6: Code Review Strictness

```
How strict should code reviews be?

Options:
- Strict (Block on any issues, enforce all standards)
- Moderate (Require fixes for critical issues only)
- Lenient (Provide suggestions, allow overrides)
```

**Purpose**: Configures code-reviewer agent thresholds.

### Step 4: Generate Configuration

Based on responses, create `.claude/settings.json` with:

```json
{
  "plugins": [
    {
      "name": "nine-step-workflow",
      "enabled": true,
      "config": {
        "projectType": "<user-response>",
        "issueTracker": "<user-response>",
        "gitStrategy": "<user-response>",
        "testingFramework": "<user-response>",
        "documentationLevel": "<user-response>",
        "reviewStrictness": "<user-response>"
      }
    }
  ]
}
```

### Step 5: Create Project Configuration Files

#### 5.1: Create CLAUDE.md

Generate a project-specific `CLAUDE.md` file with:
- Project structure overview
- Coding standards
- Testing procedures
- Security guidelines
- Deployment procedures

**Template**:
```markdown
# Project Configuration for Claude Code

## Project Type
{projectType}

## Development Workflow

### Issue Tracking
- System: {issueTracker}
- Command: {issueTrackerCommand}

### Git Strategy
- Method: {gitStrategy}
- Branch Prefix: feature/
- Worktree Location: .worktree/

### Testing
- Framework: {testingFramework}
- Test Command: {testCommand}
- Coverage Target: 80%

### Documentation Standards
- Level: {documentationLevel}
- Format: Markdown for features, Docstrings for code

### Code Review
- Strictness: {reviewStrictness}
- Required Approvals: 1 (automated via code-reviewer agent)

## File Structure
[Auto-detected or user-provided]

## Build & Deploy
[User-provided or defaults]
```

#### 5.2: Create Feature Catalog

Create `docs/FEATURE_CATALOG.md`:
```markdown
# Feature Catalog

This file tracks all features in the project using the @FEAT tagging system.

## Features

(Will be populated as features are developed)

## How to Use

Each feature should be tagged in code:
```python
# @FEAT:feature-name @COMP:component @TYPE:type
```

## Status Legend
- 🟢 Stable
- 🟡 In Development
- 🔴 Deprecated
```

#### 5.3: Create Plan Directory

```bash
mkdir -p .plan
echo "# Implementation Plans" > .plan/README.md
echo "This directory stores feature implementation plans." >> .plan/README.md
```

#### 5.4: Create Worktree Directory (if Git Worktree selected)

```bash
mkdir -p .worktree
echo "*" > .worktree/.gitignore
echo "!.gitignore" >> .worktree/.gitignore
```

### Step 6: Install Verification

Verify the setup:
```bash
# Check plugin is enabled
claude plugin list

# Verify files created
ls -la .claude/settings.json
ls -la CLAUDE.md
ls -la docs/FEATURE_CATALOG.md
ls -la .plan/
```

### Step 7: Next Steps Guidance

Provide the user with next steps:

```markdown
✅ Setup Complete!

## Configuration Summary
- Project Type: {projectType}
- Issue Tracker: {issueTracker}
- Git Strategy: {gitStrategy}
- Testing Framework: {testingFramework}
- Documentation Level: {documentationLevel}
- Review Strictness: {reviewStrictness}

## Files Created
- .claude/settings.json (Plugin configuration)
- CLAUDE.md (Project guidelines)
- docs/FEATURE_CATALOG.md (Feature tracking)
- .plan/ (Implementation plans directory)
{- .worktree/ (Git worktree directory) [if applicable]}

## What's Next?

1. **Start Your First Feature**:
   ```
   /workflow-exec "Your feature description"
   ```
   or
   ```
   /workflow-exec issue #42
   ```

2. **Customize Further**:
   - Edit `CLAUDE.md` to add project-specific guidelines
   - Review `.claude/settings.json` for advanced options

3. **Learn More**:
   - Type `/help` to see all workflow commands
   - Check README.md for detailed documentation
   - Visit GitHub: https://github.com/binee108/nine-step-workflow-plugin

## Quick Start Example

```
Hey Claude, I need to add user authentication to my app.
```

The plugin will:
1. Create an implementation plan
2. Get your approval
3. Execute the 9-step workflow
4. Guide you through each quality gate
```

### Step 8: Commit Configuration (Optional)

Ask if user wants to commit the configuration:

```
Would you like to commit these configuration files to your repository?

Options:
- Yes, commit now (Recommended for team projects)
- No, I'll commit manually later
```

If yes:
```bash
git add .claude/settings.json CLAUDE.md docs/FEATURE_CATALOG.md .plan/
git commit -m "Configure nine-step-workflow plugin

- Add plugin configuration
- Create project guidelines (CLAUDE.md)
- Initialize feature catalog
- Set up plan directory

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Advanced Configuration

For users who want more control, provide these options:

### Custom Agent Selection

Ask: "Would you like to customize which agents are active?"

Then use `interactive-questions` to show agent list with checkboxes.

### Custom Quality Gates

Ask: "Would you like to customize quality gate thresholds?"

Then configure:
- Code review pass criteria
- Test coverage requirements
- Documentation completeness
- Security scan settings

### Custom Hooks

Ask: "Would you like to set up custom hooks?"

Then help create `hooks/hooks.json` with user preferences.

## Error Handling

If setup fails at any step:

1. **Identify the failure point**
2. **Provide clear error message**
3. **Offer recovery options**:
   - Retry the failed step
   - Skip and continue
   - Abort and cleanup partial setup

Example:
```
❌ Failed to create CLAUDE.md (Permission denied)

Options:
1. Retry with sudo
2. Skip CLAUDE.md creation (you can create it manually)
3. Abort setup

Which would you like to do?
```

## Best Practices

1. **Always load `interactive-questions` skill first** for consistent UX
2. **Provide context** for each question (why it matters)
3. **Show examples** in option descriptions
4. **Validate responses** before proceeding
5. **Create backups** before modifying existing files
6. **Provide clear success/failure messages**
7. **Enable easy re-configuration** (just run setup again)

## Examples

### Example 1: Basic Setup

```
User: "I need help setting up the plugin"