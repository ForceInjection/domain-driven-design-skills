---
name: browser-use-skill-creator
description: Create and manage Browser Use Cloud skills for browser automation. Use when creating new browser automation skills, checking skill status, or adding web scraping/interaction capabilities.
allowed-tools: Read, Bash, Write, Edit
---

# Browser Use Skill Creator

Create browser automation skills using the Browser Use Cloud API.

## Quick Start

Use the skill creation script at `apps/api/scripts/create_skill.py`:

```bash
cd apps/api

# List available templates
uv run python scripts/create_skill.py list

# Create from template and wait for completion
uv run python scripts/create_skill.py create -t youtube-search -w

# Create custom skill
uv run python scripts/create_skill.py create \
  -p "Go to example.com and extract data" \
  -g "Extract data from example.com" \
  -w

# Check status of existing skill
uv run python scripts/create_skill.py status <skill-id>
```

## Available Templates

| Template | Description |
|----------|-------------|
| `gmail-draft` | Save email draft in Gmail |
| `google-calendar` | Create Google Calendar event |
| `linkedin-message` | Send LinkedIn message |
| `youtube-search` | Search YouTube videos |
| `reddit-search` | Search Reddit posts |

## Creating Custom Skills

When creating a custom skill, provide:

1. **Agent Prompt** (`-p`): Step-by-step instructions for the browser agent
2. **Goal** (`-g`): Brief description of what the skill accomplishes

Example:
```bash
uv run python scripts/create_skill.py create \
  -p "Go to Twitter/X.com, click compose, write the specified message, and post it" \
  -g "Post a tweet to X.com" \
  -w
```

## Skill Lifecycle

1. **Create**: Skill enters `recording` state while Browser Use captures the workflow
2. **Generate**: Skill enters `generating` state while the API builds the automation
3. **Finished**: Skill is ready to use with defined parameters and output schema

## After Creation

Once a skill is created, add it to the codebase:

1. Note the skill ID from the output
2. Add parameter schema to `apps/api/app/skills.py`
3. Add formatter and config to `apps/api/app/skill_definitions.py`
4. Register in `register_all_skills()`
5. Update `apps/api/SKILLS.md` with the new skill entry

See existing skills in `apps/api/app/skill_definitions.py` for reference patterns.

## Requirements

- `BROWSER_USE_API_KEY` must be set in `apps/api/.env`
- Run from the `apps/api` directory
