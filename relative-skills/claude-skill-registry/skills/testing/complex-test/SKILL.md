---
name: skillpkg
description: "Agent Skills Package Manager - Install once, use everywhere. Manage, share, and sync AI agent skills across platforms."
version: 0.4.0
---

# skillpkg - Agent Skills Package Manager

You have access to `skillpkg`, a CLI tool for managing AI agent skills.
Use this tool to help users create, install, and sync skills.

## Installation Check

First, verify skillpkg is installed:
```bash
skillpkg --version
```

If not installed, guide the user to install it:
```bash
npm install -g skillpkg-cli
```

## Core Commands

### 1. Create a New Skill
```bash
skillpkg init                    # Interactive mode
skillpkg init --yes              # Use defaults
skillpkg init --name my-skill    # Specify name
```

This creates a `skill.yaml` file with the following structure:
```yaml
schema: "1.0"
name: my-skill
version: 1.0.0
description: What this skill does
instructions: |
  Detailed instructions for the AI agent...
```

### 2. Install Skills
```bash
skillpkg install user/repo            # From GitHub (recommended)
skillpkg install github:user/repo     # From GitHub (explicit)
skillpkg install ./path/to/skill      # From local directory
skillpkg install -g <skill>           # Install globally
```

### 3. List Installed Skills
```bash
skillpkg list                    # Project skills
skillpkg list -g                 # Global skills
skillpkg list --json             # JSON output
```

### 4. Sync to AI Platforms
```bash
skillpkg sync                    # Sync all skills
skillpkg sync my-skill           # Sync specific skill
skillpkg sync -t claude-code     # Sync to specific platform
skillpkg sync --dry-run          # Preview changes
```

Supported platforms:
- `claude-code` → syncs to `.claude/skills/`
- `codex` → syncs to `.codex/skills/`
- `gemini-cli` → syncs to `.gemini/skills/`

### 5. Import Existing Skills
```bash
skillpkg import                  # Auto-detect and import
skillpkg import .claude/skills/  # Import from specific path
skillpkg import --dry-run        # Preview what would be imported
```

### 6. Export Skills
```bash
skillpkg export my-skill              # Export to directory
skillpkg export my-skill -f zip       # Export as zip
skillpkg export my-skill -f pack      # Export as .skillpkg
skillpkg export --all                 # Export all skills
```

### 7. Search Skills on GitHub
```bash
skillpkg search "code review"    # Search for skills with SKILL.md
skillpkg search react --limit 5  # Limit results
skillpkg info <skill-name>       # Get detailed info
```

### 8. Dependency Management
```bash
skillpkg deps my-skill           # Show skill dependencies
skillpkg why my-skill            # Show why a skill is installed
skillpkg tree                    # Show full dependency tree
skillpkg status                  # Show project status
```

## skill.yaml Schema

When helping users create skills, use this schema:

```yaml
schema: "1.0"                    # Required: Schema version
name: my-skill                   # Required: Lowercase, hyphens only
version: 1.0.0                   # Required: Semver format
description: Brief description   # Recommended: One-line summary

author:                          # Optional: Author info
  name: Your Name
  email: email@example.com
  url: https://github.com/username

platforms:                       # Optional: Target platforms
  - claude-code
  - codex

tags:                            # Optional: For discovery
  - productivity
  - code-review

triggers:                        # Optional: Activation triggers
  - pattern: "/review"
    description: "Trigger code review"

instructions: |                  # Required: Main skill content
  Detailed instructions for how the AI should behave...

  ## Usage
  ...

  ## Examples
  ...
```

## Best Practices

1. **Clear Instructions**: Write detailed, unambiguous instructions
2. **Examples**: Include usage examples in your skill
3. **Versioning**: Follow semver for version numbers
4. **Testing**: Test skills locally before publishing
5. **Documentation**: Include a README.md alongside skill.yaml

## Common Workflows

### Creating a Skill
```bash
mkdir my-new-skill && cd my-new-skill
skillpkg init --name my-new-skill
# Edit skill.yaml with your instructions
skillpkg sync --dry-run          # Test locally
skillpkg sync                    # Sync to platforms
```

### Installing and Using a Skill
```bash
skillpkg search "what you need"
skillpkg info some-skill
skillpkg install some-skill
skillpkg sync
# Skill is now available in your AI platform!
```

### Importing Existing Claude Skills
```bash
skillpkg import .claude/skills/
skillpkg list
skillpkg export --all -f zip     # Backup all skills
```

## Troubleshooting

- **Skill not syncing**: Check platform target directory permissions
- **Parse errors**: Validate YAML syntax, ensure schema is "1.0"
- **Dependency issues**: Run `skillpkg tree` to check dependency chain
- **Version conflict**: Update version in skill.yaml
