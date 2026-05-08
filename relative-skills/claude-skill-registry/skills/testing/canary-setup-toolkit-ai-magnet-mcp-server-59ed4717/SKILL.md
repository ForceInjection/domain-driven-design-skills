---
name: canary-setup
description: Interactive setup workflow for configuring the Magnet MCP server to use the canary environment (project-specific, magnet-app directory only). Use when user says "canary setup", "use canary", "test on canary", "configure canary MCP", or "set up canary environment".
---

# Canary MCP Server Setup

This skill walks users through setting up the Magnet MCP server to use the canary environment (https://canary.magnet.run) with their MCP client (Claude Code, Cursor, Claude Desktop).

**Important:** This setup configures the MCP server to talk to the **Magnet canary environment**, not production or localhost.

## When to Use This Skill

Use this skill when the user requests:
- Setting up the MCP server for the canary environment
- Testing against the canary Magnet instance
- Configuring their MCP client to use canary
- Troubleshooting canary MCP connection issues

## Instructions

### Step 1: Check Prerequisites

Verify the development environment is ready:

```bash
# Check Node.js version (must be >= 22.2.0)
node --version

# Check pnpm is installed
pnpm --version

# Check if dependencies are installed
ls node_modules/.bin/tsc 2>/dev/null && echo "Dependencies installed" || echo "Need to install dependencies"
```

If dependencies are missing, install them:
```bash
pnpm install
```

### Step 2: Confirm Project-Specific Scope

**Important:** This setup configures the MCP server for the `magnet-app` project directory only. The MCP server will NOT be available when working in other directories.

Use AskUserQuestion to confirm the user understands:

Question: "This will configure the MCP server for your magnet-app project directory only. It will NOT be available globally in other projects. Do you understand and want to proceed?"
Options:
- "Yes, I understand it's project-specific" - Continue with setup
- "No, I need global setup" - Inform user that global setup requires manual configuration in ~/.claude/ and is not covered by this skill

If the user needs global setup, explain:
- Global MCP configuration is not officially supported by Claude Code
- They would need to manually configure ~/.claude/settings.json or use the plugins system
- Recommend using project-specific setup for most use cases

### Step 3: Build the MCP Server Project

Build the TypeScript project:
```bash
pnpm build
```

Verify the build succeeded:
```bash
ls -la dist/index.js
```

### Step 4: Check for Existing Environment Configuration

Check if .env file exists with API key:
```bash
if [ -f .env ]; then
  echo ".env file exists"
  grep -q "MAGNET_API_KEY" .env && echo "API key configured" || echo "API key missing"
else
  echo "No .env file found"
fi
```

### Step 5: Gather API Key

Use AskUserQuestion to get the Magnet API key if not already configured. The API key must come from the **canary Magnet instance**.

Question: "Do you have an API key from the Magnet canary environment?"
Options:
- "Yes, I have one" - Prompt them to provide it
- "No, I need to get one" - Direct them to https://canary.magnet.run/settings to generate one

If they provide a key, you can optionally store it for reference:
```bash
echo "MAGNET_API_KEY=<their-key>" > .env
echo "MAGNET_WEB_API_BASE_URL=https://canary.magnet.run" >> .env
```

### Step 6: Detect MCP Client

Use AskUserQuestion to determine which MCP client they're using:

Question: "Which MCP client are you using?"
Options:
- "Claude Code" - Will configure `.mcp.json` file
- "Cursor" - Will configure ~/.cursor/mcp.json
- "Claude Desktop" - Will configure ~/Library/Application Support/Claude/claude_desktop_config.json (macOS)

### Step 7: Find User's magnet-app Directory

**Important:** The default setup location should be the user's `magnet-app` repo, since that's where they'll be doing development work and need the MCP tools available.

```bash
# Common locations to check for magnet-app
ls -d ~/magnet-app 2>/dev/null || \
ls -d ~/Projects/magnet-app 2>/dev/null || \
ls -d ~/Code/magnet-app 2>/dev/null || \
echo "magnet-app not found in common locations"
```

If not found, ask:
Question: "Where is your magnet-app repository located?"

### Step 8: Check Existing MCP Configuration

**Claude Code uses `.mcp.json` files, NOT settings.json for MCP servers.** The settings.json schema does not support the `mcpServers` field.

```bash
# Check for existing .mcp.json in magnet-app
cat ~/magnet-app/.mcp.json 2>/dev/null || echo "No .mcp.json found"
```

**Cursor:**
```bash
cat ~/.cursor/mcp.json 2>/dev/null
```

**Claude Desktop (macOS):**
```bash
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json 2>/dev/null
```

### Step 9: Generate Configuration

Get the absolute path to the MCP server:
```bash
pwd  # Should be /path/to/magnet-mcp-server
```

Create the `.mcp.json` file structure. **Important:** This always points to the canary Magnet API at https://canary.magnet.run.

```json
{
  "mcpServers": {
    "magnet-canary": {
      "command": "node",
      "args": ["/absolute/path/to/magnet-mcp-server/dist/index.js"],
      "env": {
        "MAGNET_API_KEY": "<api-key-here>",
        "MAGNET_WEB_API_BASE_URL": "https://canary.magnet.run"
      }
    }
  }
}
```

For development (rebuilds before running):
```json
{
  "mcpServers": {
    "magnet-canary": {
      "command": "pnpm",
      "args": ["--dir", "/absolute/path/to/magnet-mcp-server", "dev"],
      "env": {
        "MAGNET_API_KEY": "<api-key-here>",
        "MAGNET_WEB_API_BASE_URL": "https://canary.magnet.run"
      }
    }
  }
}
```

### Step 10: Create .mcp.json in magnet-app

Create the `.mcp.json` file in the user's magnet-app directory (the default location).

Ask user:
Question: "How should the canary server be named?"
Options:
- "magnet-canary (recommended)" - Keeps production and local configs separate
- "magnet (replace existing)" - Replaces any existing magnet configuration

**Important:** The `.mcp.json` file is project-specific. It only makes the MCP server available when working in that directory.

### Step 11: Add .mcp.json to .gitignore

**Critical:** The `.mcp.json` file contains the API key and must NOT be committed to git.

Check and update `.gitignore` in the magnet-app directory:
```bash
grep -E "^\.mcp\.json$" ~/magnet-app/.gitignore 2>/dev/null || echo ".mcp.json" >> ~/magnet-app/.gitignore
```

### Step 12: Verify Setup

After updating the configuration, provide next steps:

1. **Restart the MCP client** to load the new configuration
2. **Verify the server loads** by checking available tools
3. **Test a simple command** like listing issues

For Claude Code:
```
Run /mcp to verify the magnet-canary server is connected and shows its tools
```

### Step 13: Troubleshooting

If the server doesn't connect, check:

1. **API Key**: Ensure MAGNET_API_KEY is valid and from the **canary** Magnet instance
2. **Path**: Verify the absolute path to dist/index.js is correct
3. **Build**: Make sure `pnpm build` completed successfully
4. **Node version**: Confirm Node.js >= 22.2.0
5. **Network**: Ensure you can reach https://canary.magnet.run

Common errors:
- "MAGNET_API_KEY is not set" - API key missing or not being passed
- "Cannot find module" - Build not complete or wrong path
- 401/403 errors - API key is invalid or from wrong environment (production vs canary)
- Network errors - Check connectivity to canary.magnet.run

## Examples

### Example 1: First-Time Canary Setup

User: "I want to test the MCP server against canary"

Actions:
1. Check Node.js version and pnpm
2. Run `pnpm install` if needed
3. Run `pnpm build`
4. Ask for API key from canary Magnet instance
5. Detect they're using Claude Code
6. Find their magnet-app directory
7. Create `.mcp.json` in magnet-app with magnet-canary config
8. Add `.mcp.json` to magnet-app's `.gitignore`
9. Instruct to restart Claude Code in magnet-app directory

### Example 2: Adding Canary Alongside Production

User: "I need to also connect to canary for testing"

Actions:
1. Verify build is current (`pnpm build`)
2. Check existing `.mcp.json` in magnet-app
3. Add magnet-canary config alongside existing magnet config
4. Ask them to get an API key from canary if they don't have one
5. Explain they can use both production and canary by using different server names

### Example 3: Troubleshooting Canary Connection

User: "The canary MCP server isn't working"

Actions:
1. Check if dist/index.js exists
2. Verify Node.js version
3. Test running server directly: `MAGNET_WEB_API_BASE_URL=https://canary.magnet.run MAGNET_API_KEY=xxx node dist/index.js`
4. Check API key is from **canary** Magnet instance (not production or local)
5. Verify `.mcp.json` has `MAGNET_WEB_API_BASE_URL` set to `https://canary.magnet.run`
6. Verify `.mcp.json` has correct absolute path to dist/index.js
7. Confirm user restarted Claude Code after config changes

## Notes

- **NOT A GLOBAL SETUP** - This configures the MCP server for the magnet-app project directory only. It will NOT be available in other projects.
- **This skill configures for canary environment** - it always points to https://canary.magnet.run
- **API key must be from canary instance** - production or local API keys won't work
- **Claude Code uses `.mcp.json` files** - NOT `settings.json` for MCP servers
- **`.mcp.json` is project-specific** - it only works when Claude Code is running in that directory
- Always use absolute paths in MCP configuration
- The "magnet-canary" name helps distinguish from production and local
- Restart Claude Code after configuration changes
- Use `pnpm dev` for development builds (rebuilds before running)
- **Always add `.mcp.json` to `.gitignore`** - it contains the API key
