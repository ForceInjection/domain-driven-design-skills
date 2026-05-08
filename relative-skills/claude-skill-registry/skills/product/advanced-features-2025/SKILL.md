---
name: advanced-features-2025
description: "Complete guide to 2025 Claude Code plugin features: Agent Skills, Hooks, MCP integration, and repository-level configuration. PROACTIVELY activate for: (1) Agent Skills implementation, (2) Hook automation setup, (3) MCP server integration, (4) Team plugin distribution, (5) Advanced plugin architecture. Provides: Agent Skills patterns, hook event types, MCP configuration, repository setup, context optimization strategies. Ensures production-ready 2025 plugin capabilities."
license: MIT
---

## Quick Reference

| Feature | Configuration Location | Key Pattern |
|---------|----------------------|-------------|
| Agent Skills | `skills/*/SKILL.md` | Progressive disclosure: frontmatter → body → linked files |
| Hooks | `hooks/hooks.json` or `plugin.json` | Event-based: PreToolUse, PostToolUse, SessionStart, etc. |
| MCP Servers | `plugin.json` or `.mcp.json` | `"command": "...", "args": [...]` |
| Team Config | `.claude/settings.json` | `extraKnownMarketplaces` + `plugins.enabled` |

| Hook Event | When It Fires | Common Use |
|------------|---------------|------------|
| `PreToolUse` | Before tool execution | Validation, preparation |
| `PostToolUse` | After tool execution | Testing, cleanup, linting |
| `SessionStart` | Session begins | Logging, initialization |
| `SessionEnd` | Session terminates | Cleanup, state save |
| `UserPromptSubmit` | After user prompt | Preprocessing, logging |

| Environment Variable | Purpose |
|---------------------|---------|
| `${CLAUDE_PLUGIN_ROOT}` | Resolves to plugin's absolute path |
| `${TOOL_INPUT_*}` | Access tool input parameters in hooks |

## When to Use This Skill

Use for **advanced plugin features**:
- Implementing Agent Skills with progressive disclosure
- Setting up hook automation (testing, linting, validation)
- Configuring MCP server integration
- Team plugin distribution via repository configuration
- Performance optimization and context efficiency
- Migrating legacy plugins to 2025 patterns

**For basic plugin creation**: see `plugin-master` skill

---

## 🚨 CRITICAL GUIDELINES

### Windows File Path Requirements

**MANDATORY: Always Use Backslashes on Windows for File Paths**

When using Edit or Write tools on Windows, you MUST use backslashes (`\`) in file paths, NOT forward slashes (`/`).

**Examples:**
- ❌ WRONG: `D:/repos/project/file.tsx`
- ✅ CORRECT: `D:\repos\project\file.tsx`

This applies to:
- Edit tool file_path parameter
- Write tool file_path parameter
- All file operations on Windows systems


### Documentation Guidelines

**NEVER create new documentation files unless explicitly requested by the user.**

- **Priority**: Update existing README.md files rather than creating new documentation
- **Repository cleanliness**: Keep repository root clean - only README.md unless user requests otherwise
- **Style**: Documentation should be concise, direct, and professional - avoid AI-generated tone
- **User preference**: Only create additional .md files when user specifically asks for documentation


---

# Advanced Plugin Features (2025)

Comprehensive guide to cutting-edge Claude Code plugin capabilities introduced in 2025.

## Agent Skills

**What are Agent Skills?**
Skills that Claude autonomously invokes based on task context, enabling dynamic knowledge loading and context-efficient workflows through progressive disclosure architecture.

### Key Characteristics (2025)

- **Automatic Discovery**: Skills are discovered from `skills/` directory upon plugin installation
- **Context-Driven**: Claude loads Skills only when relevant to the current task
- **Progressive Disclosure**: Three-tier information structure (frontmatter → SKILL.md body → linked files)
- **Dynamic Loading**: Reduces context usage by loading only necessary components
- **Unbounded Capacity**: With filesystem access, agents can bundle effectively unlimited content

### Creating Agent Skills

**Directory Structure:**
```
plugin-root/
└── skills/
    ├── skill-name-1/
    │   └── SKILL.md
    └── skill-name-2/
        ├── SKILL.md
        ├── examples/
        └── resources/
```

**SKILL.md Format:**
```markdown
---
name: skill-name
description: "Complete [domain] system. PROACTIVELY activate for: (1) [use cases]. Provides: [capabilities]."
license: MIT
---

# Skill Title

## Overview
High-level summary always loaded

## Core Concepts
Key information organized for quick scanning

## Examples
Concrete usage patterns

## Best Practices
Proven approaches and patterns
```

### Agent Skills Best Practices (2025)

**Evaluation-Driven Development:**
- Start by identifying capability gaps through representative tasks
- Observe where agents struggle, then build skills addressing specific shortcomings
- Avoid anticipating needs upfront - respond to actual failures

**Structural Scalability:**
- When SKILL.md becomes unwieldy, split content into separate files and reference them
- Keep mutually exclusive contexts in distinct paths to reduce token consumption
- Code should serve dual purposes: executable tools AND documentation
- Split large skills into focused components as needed

**Iterative Refinement:**
- Collaborate with Claude during development
- Ask Claude to capture successful approaches into reusable context
- Request self-reflection on failure modes to reveal actual information needs

**DO:**
- Use descriptive, action-oriented names
- Write comprehensive activation descriptions with numbered use cases
- Include concrete examples and code snippets
- Organize content with clear headers for scanning
- Keep individual skills focused on single domains

**DON'T:**
- Create overly broad skills that cover too many topics
- Duplicate content across multiple skills
- Skip the frontmatter metadata
- Use generic descriptions that don't specify activation scenarios

### Context Efficiency Strategy (2025)

Agent Skills achieve unbounded capacity through:

1. **Progressive Disclosure**: Three-tier structure (frontmatter loaded at startup → SKILL.md body when determining relevance → additional files only when needed)
2. **Lazy Loading**: Only loaded when task matches activation criteria
3. **Filesystem Retrieval**: With code execution capabilities, agents retrieve only necessary components instead of loading entire skills
4. **Focused Scope**: Each skill covers specific domain/capability
5. **Structured Content**: Headers enable Claude to scan efficiently
6. **Optimized Metadata**: Name and description fields directly influence triggering accuracy

**Example Activation Pattern:**
```
User task: "Deploy to production"
→ Claude scans skill metadata (frontmatter only)
→ Identifies deployment-workflows skill as relevant
→ Loads SKILL.md body to confirm match
→ Retrieves only needed sections/files
→ Unloads when task complete
```

**Result**: Effectively unlimited bundled content without context window constraints.

## Hooks

**What are Hooks?**
Automatic triggers that execute actions at specific events during Claude Code's workflow.

### Hook Event Types (2025)

**Tool Lifecycle:**
- `PreToolUse`: Before any tool execution (validation, preparation)
- `PostToolUse`: After tool execution (testing, cleanup, notifications)

**Session Lifecycle:**
- `SessionStart`: When Claude Code session begins
- `SessionEnd`: When session terminates
- `PreCompact`: Before context compaction (cleanup, state save)

**User Interaction:**
- `UserPromptSubmit`: After user submits prompt (logging, preprocessing)
- `Notification`: When notifications are displayed
- `Stop`: When user stops execution
- `SubagentStop`: When subagent terminates

### Hook Configuration

**Inline in plugin.json:**
```json
{
  "name": "my-plugin",
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/lint.sh"
          }
        ]
      }
    ]
  }
}
```

**Separate hooks.json:**
```json
{
  "PostToolUse": [
    {
      "matcher": "Write",
      "hooks": [
        {
          "type": "command",
          "command": "./scripts/format.sh",
          "env": {
            "FILE_PATH": "${TOOL_INPUT_FILE_PATH}"
          }
        }
      ]
    }
  ],
  "SessionStart": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "echo 'Session started at $(date)' >> session.log"
        }
      ]
    }
  ]
}
```

### Hook Matchers

**Tool Matchers:**
Match specific tools using regex patterns:
- `Write` - File write operations
- `Edit` - File edit operations
- `Write|Edit` - Either write or edit
- `Bash` - Shell command execution
- `.*` - Any tool (use sparingly)

**Matcher Best Practices:**
- Be specific to avoid unnecessary executions
- Use `|` for multiple tools
- Test matchers thoroughly
- Document why each matcher is used

### Common Hook Patterns

**Automated Testing:**
```json
{
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/run-tests.sh",
          "description": "Run tests after code changes"
        }
      ]
    }
  ]
}
```

**Code Formatting:**
```json
{
  "PostToolUse": [
    {
      "matcher": "Write",
      "hooks": [
        {
          "type": "command",
          "command": "prettier --write ${TOOL_INPUT_FILE_PATH}"
        }
      ]
    }
  ]
}
```

**Session Logging:**
```json
{
  "SessionStart": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/log-session.sh"
        }
      ]
    }
  ]
}
```

**Validation:**
```json
{
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate-bash.sh"
        }
      ]
    }
  ]
}
```

## MCP Server Integration

**What is MCP?**
Model Context Protocol enables Claude to interact with external tools, APIs, and services through standardized server interfaces.

### MCP Configuration (2025)

**Inline in plugin.json (Recommended for Distribution):**
```json
{
  "name": "my-plugin",
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@company/mcp-server"],
      "env": {
        "API_KEY": "${API_KEY}",
        "SERVER_URL": "https://api.example.com"
      }
    },
    "local-server": {
      "command": "${CLAUDE_PLUGIN_ROOT}/bin/server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"]
    }
  }
}
```

**Separate .mcp.json:**
```json
{
  "mcpServers": {
    "database-server": {
      "command": "node",
      "args": ["${CLAUDE_PLUGIN_ROOT}/mcp/db-server.js"],
      "env": {
        "DB_CONNECTION": "${DATABASE_URL}"
      }
    }
  }
}
```

### MCP Best Practices

**DO:**
- Use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths
- Document required environment variables in README
- Provide sensible defaults for optional configuration
- Test MCP servers in isolation before integration
- Include error handling in server implementations

**DON'T:**
- Hardcode absolute paths (breaks portability)
- Expose secrets in plugin.json (use environment variables)
- Assume environment variables are always set
- Skip validation of MCP server responses

### MCP Use Cases

**API Integration:**
```json
{
  "mcpServers": {
    "stripe-api": {
      "command": "npx",
      "args": ["-y", "@stripe/mcp-server"],
      "env": {
        "STRIPE_API_KEY": "${STRIPE_API_KEY}"
      }
    }
  }
}
```

**Database Access:**
```json
{
  "mcpServers": {
    "postgres": {
      "command": "${CLAUDE_PLUGIN_ROOT}/bin/pg-server",
      "args": ["--connection", "${DATABASE_URL}"]
    }
  }
}
```

**Custom Tooling:**
```json
{
  "mcpServers": {
    "internal-tools": {
      "command": "python",
      "args": ["${CLAUDE_PLUGIN_ROOT}/mcp/tools_server.py"],
      "env": {
        "TOOLS_CONFIG": "${CLAUDE_PLUGIN_ROOT}/config/tools.json"
      }
    }
  }
}
```

## Repository-Level Plugin Configuration

**What is it?**
Automatic marketplace and plugin installation for team members when they trust a repository folder.

### Configuration File Location

Create `.claude/settings.json` at repository root:
```
repo-root/
├── .claude/
│   └── settings.json
├── src/
└── README.md
```

### Settings Format

```json
{
  "extraKnownMarketplaces": [
    "company-org/internal-plugins",
    "JosiahSiegel/claude-plugin-marketplace"
  ],
  "plugins": {
    "enabled": [
      "deployment-helper@company-org",
      "test-master@JosiahSiegel",
      "code-review-helper"
    ]
  }
}
```

### Team Distribution Workflow

1. **Repository Maintainer:**
   - Create `.claude/settings.json`
   - Configure required marketplaces and plugins
   - Commit to version control
   - Document in README that team should trust folder

2. **Team Member:**
   - Clone repository
   - Open in Claude Code
   - Trust folder when prompted
   - Automatic installation occurs

3. **Updates:**
   - Maintainer updates settings.json
   - Team members pull changes
   - Claude Code applies updated configuration

### Best Practices

**Start Minimal:**
```json
{
  "extraKnownMarketplaces": ["company/tools"],
  "plugins": {
    "enabled": ["essential-plugin@company"]
  }
}
```

**Document Requirements:**
Add to README:
```markdown
## Claude Code Setup

This repository uses Claude Code plugins for standardized workflows.

### First Time Setup
1. Install Claude Code
2. Clone this repository
3. Open in Claude Code
4. Trust this repository folder when prompted

Plugins will be installed automatically.
```

**Security Considerations:**
- Only trust repositories from known sources
- Review settings.json before trusting
- Use organizational repositories for internal plugins
- Document why each plugin is required

## Environment Variables

### Standard Variables (2025)

**${CLAUDE_PLUGIN_ROOT}:**
Resolves to plugin's absolute installation path.

**Usage:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
          }
        ]
      }
    ]
  },
  "mcpServers": {
    "local-server": {
      "command": "${CLAUDE_PLUGIN_ROOT}/bin/server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"]
    }
  }
}
```

**Why Use It:**
- Ensures portability across different installation locations
- Works on all platforms (Windows, Mac, Linux)
- Simplifies plugin distribution
- Enables relative path resolution

### Custom Environment Variables

**In Hooks:**
```json
{
  "hooks": [
    {
      "type": "command",
      "command": "${CLAUDE_PLUGIN_ROOT}/scripts/deploy.sh",
      "env": {
        "ENVIRONMENT": "${DEPLOY_ENV}",
        "API_KEY": "${API_KEY}",
        "CUSTOM_VAR": "value"
      }
    }
  ]
}
```

**In MCP Servers:**
```json
{
  "mcpServers": {
    "api-server": {
      "command": "npx",
      "args": ["-y", "@company/mcp-server"],
      "env": {
        "API_URL": "${COMPANY_API_URL}",
        "AUTH_TOKEN": "${COMPANY_AUTH_TOKEN}"
      }
    }
  }
}
```

**Best Practices:**
- Document all required environment variables in README
- Provide .env.example template
- Use sensible defaults when possible
- Validate environment variables in scripts
- Never hardcode secrets

## Complete Plugin Example (2025 Best Practices)

```
deployment-automation/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── deploy-staging.md
│   └── deploy-production.md
├── agents/
│   └── deployment-expert.md
├── skills/
│   ├── deployment-workflows/
│   │   └── SKILL.md
│   └── kubernetes-patterns/
│       └── SKILL.md
├── hooks/
│   └── hooks.json
├── scripts/
│   ├── validate-deployment.sh
│   └── run-tests.sh
├── .claude/
│   └── settings.json
└── README.md
```

**plugin.json:**
```json
{
  "name": "deployment-automation",
  "version": "2.0.0",
  "description": "Complete deployment automation system. PROACTIVELY activate for: (1) ANY deployment task, (2) Production releases, (3) Rollback operations, (4) Deployment validation, (5) Kubernetes workflows. Provides: automated deployment, rollback safety, validation hooks, multi-environment support. Ensures safe, reliable deployments.",
  "author": {
    "name": "Your Company",
    "email": "[email protected]"
  },
  "keywords": ["deployment", "kubernetes", "production", "automation", "cicd"],
  "license": "MIT",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate-deployment.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/run-tests.sh"
          }
        ]
      }
    ]
  },
  "mcpServers": {
    "kubernetes": {
      "command": "kubectl",
      "args": ["proxy"],
      "env": {
        "KUBECONFIG": "${KUBECONFIG}"
      }
    }
  }
}
```

**hooks/hooks.json:**
```json
{
  "SessionStart": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "echo 'Deployment session started' >> deployment.log"
        }
      ]
    }
  ]
}
```

**.claude/settings.json:**
```json
{
  "extraKnownMarketplaces": ["company/internal-tools"],
  "plugins": {
    "enabled": ["deployment-automation@company"]
  }
}
```

## Migration from Legacy Plugins

### Key Changes in 2025

**1. Component Discovery:**
- **Old**: Manual registration in plugin.json
- **New**: Automatic discovery from standard directories

**2. Skills → Agent Skills:**
- **Old**: Static skills loaded in context
- **New**: Dynamic Agent Skills loaded on-demand

**3. Hooks:**
- **Old**: Limited hook support
- **New**: Comprehensive event system (PreToolUse, PostToolUse, SessionStart, etc.)

**4. MCP Integration:**
- **Old**: External configuration required
- **New**: Inline in plugin.json or .mcp.json

**5. Repository Configuration:**
- **Old**: Manual plugin installation per developer
- **New**: Automatic installation via .claude/settings.json

### Migration Checklist

- [ ] Update plugin.json to version 2.x.x
- [ ] Convert static skills to Agent Skills with proper frontmatter
- [ ] Add hooks for automated workflows
- [ ] Configure MCP servers inline if applicable
- [ ] Create .claude/settings.json for team distribution
- [ ] Update README with 2025 installation instructions
- [ ] Test on all platforms (Windows, Mac, Linux)
- [ ] Use ${CLAUDE_PLUGIN_ROOT} for all internal paths
- [ ] Validate with latest Claude Code version

## Debugging Advanced Features

### Debug Mode

```bash
claude --debug
```

**Shows:**
- Plugin loading status
- Agent Skills discovery and activation
- Hook registration and execution
- MCP server initialization
- Environment variable resolution

### Common Issues

**Agent Skills not loading:**
- Verify SKILL.md exists in skills/skill-name/ directory
- Check frontmatter has name and description fields
- Ensure description includes activation criteria

**Hooks not executing:**
- Verify event type is valid (PreToolUse, PostToolUse, etc.)
- Check matcher pattern matches tool name
- Confirm script has execute permissions
- Validate ${CLAUDE_PLUGIN_ROOT} resolves correctly

**MCP server not starting:**
- Check command and args are correct
- Verify required environment variables are set
- Test MCP server independently
- Review server logs for errors

**Repository settings not applying:**
- Confirm .claude/settings.json is at repository root
- Verify repository folder is trusted
- Check marketplace names are correct
- Ensure plugins exist in specified marketplaces

## Additional Resources

- Official Plugin Reference: https://docs.claude.com/en/docs/claude-code/plugins-reference
- Marketplace Guide: https://docs.claude.com/en/docs/claude-code/plugin-marketplaces
- Agent Skills Engineering: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- MCP Documentation: https://docs.claude.com/en/docs/claude-code/mcp
- Community Plugins: https://claudecodemarketplace.com/

## Conclusion

2025 plugin features enable:
- **Context Efficiency**: Agent Skills load knowledge dynamically
- **Automation**: Hooks trigger workflows automatically
- **Integration**: MCP connects external tools seamlessly
- **Team Standardization**: Repository-level configuration ensures consistency

Apply these patterns to create production-ready, scalable plugins that leverage the full power of Claude Code's 2025 capabilities.
