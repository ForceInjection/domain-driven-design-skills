---
name: plugin-search
description: Search for claude plugins or skill to help user with a task
---

# Skill and Plugin Search

## Instructions
Use the `<SKILL_BASE_DIR>/scripts/search_plugins.py` script to find relevant Claude Code plugins that match the user's requirements.

### Workflow

1. **List all plugins** - Get a compact overview:
   ```bash
   python <SKILL_BASE_DIR>/scripts/search_plugins.py --all
   ```
   This shows all available plugins in compact format (name, category, description).

2. **Choose top matches** - Select up to 5 most relevant plugins based on user's needs

3. **Get detailed information** - Use `-d` with plugin names for installation instructions:
   ```bash
   python <SKILL_BASE_DIR>/scripts/search_plugins.py -d notion linear github
   ```
   Or search first, then get details:
   ```bash
   python <SKILL_BASE_DIR>/scripts/search_plugins.py -q "database" -d
   ```
4. **Prioritise the reccomendations** - Suggest upto 3 plugins based on users needs and other applicable factors eg: number of skills, commands, MCP, Github stars


## Recommendation Template

When recommending plugins to users, use this format:

```
Based on your needs, here are the top matches:

1. Acme (productivity)
   ⭐ Stars: 6 | 🔌 MCP: Yes | 📜 Commands: 6 | 🎯 Skills: 4 | 🕐 Last Updated: 2025-12-22

   Perfect for meeting documentation with the meeting-intelligence skill. Also includes:
   - knowledge-capture, research-documentation, spec-to-implementation skills
   - 6 commands for creating pages, databases, tasks, and querying

   Installation:
   /plugin marketplace add anthropics/claude-plugins-official
   /plugin install acme@claude-plugins-official

   Homepage: https://github.com/makenotion/claude-code-acme-plugin

2. [Next plugin...]
```

## Examples


### Get plugins overview 
```bash
python <SKILL_BASE_DIR>/scripts/search_plugins.py --all
```

### Get detailed info for specific plugins
```bash
python <SKILL_BASE_DIR>/scripts/search_plugins.py -d notion linear github
```

### Search with multiple terms (Advanced search query: searchs name, description, keywords, category, tags )
```bash
python <SKILL_BASE_DIR>/scripts/search_plugins.py -q "git github workflow"
```
Finds plugins matching "git" OR "github" OR "workflow"


## Tips

- Always start with --all and then refine further
- If user requiremets are unclear you can ask a question with the AskUserQuestion tool and a few options to clear the ambiguity
- **Use -d for recommendations**: Always use `-d plugin1 plugin2 plugin3` when recommending plugins to provide installation instructions
- **Check marketplaces**: Use `--list` to see all available marketplaces and categories
- **Filter effectively**: Combine `-m` and `-c` to narrow results (e.g., `--all -m anthropics-skills -c productivity`)
