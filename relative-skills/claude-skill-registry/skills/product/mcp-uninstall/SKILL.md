---
name: mcp-uninstall
description: Remove magnet-local and/or magnet-canary MCP server configurations from project and global locations. Use when user says "uninstall mcp", "remove mcp", "delete mcp config", or "clean up mcp".
---

# MCP Server Uninstall

This skill helps users remove Magnet MCP server configurations (magnet-local and/or magnet-canary) from their system.

## When to Use This Skill

Use this skill when the user requests:
- Removing MCP server configurations
- Cleaning up old MCP settings
- Uninstalling the local or canary MCP server
- Resetting their MCP configuration

## Instructions

### Step 1: Ask What to Uninstall

Use AskUserQuestion to determine which configuration(s) to remove:

Question: "Which MCP server configuration do you want to remove?"
Options:
- "magnet-local" - Remove the local development server configuration
- "magnet-canary" - Remove the canary environment server configuration
- "Both" - Remove both local and canary configurations

### Step 2: Scan for Configurations

Check for MCP configurations in project and client-specific locations:

**Project location (magnet-app):**
```bash
# Find magnet-app directory
MAGNET_APP_DIR=$(ls -d ~/magnet-app 2>/dev/null || ls -d ~/Projects/magnet-app 2>/dev/null || ls -d ~/Code/magnet-app 2>/dev/null)

# Check for .mcp.json
if [ -n "$MAGNET_APP_DIR" ] && [ -f "$MAGNET_APP_DIR/.mcp.json" ]; then
  echo "Found project config: $MAGNET_APP_DIR/.mcp.json"
  cat "$MAGNET_APP_DIR/.mcp.json"
fi
```

**Cursor:**
```bash
if [ -f ~/.cursor/mcp.json ]; then
  echo "Found Cursor config: ~/.cursor/mcp.json"
  cat ~/.cursor/mcp.json
fi
```

**Claude Desktop (macOS):**
```bash
if [ -f ~/Library/Application\ Support/Claude/claude_desktop_config.json ]; then
  echo "Found Claude Desktop config"
  cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
fi
```

**Global Claude Code locations (~/.claude/):**
```bash
# Check for global MCP configs
if [ -f ~/.claude/settings.json ]; then
  echo "Found ~/.claude/settings.json"
  grep -l "mcpServers" ~/.claude/settings.json 2>/dev/null && cat ~/.claude/settings.json
fi

if [ -f ~/.claude/settings.local.json ]; then
  echo "Found ~/.claude/settings.local.json"
  cat ~/.claude/settings.local.json
fi
```

### Step 3: Display Findings

Report what was found to the user:
- List each location where the target configuration(s) exist
- Show the current configuration content
- If configuration not found, report "Configuration not found in [location]"

### Step 4: Confirm Removal

Use AskUserQuestion to confirm before making changes:

Question: "Found [config-name] in [locations]. Do you want to remove it?"
Options:
- "Yes, remove it" - Proceed with removal
- "No, cancel" - Abort the operation

### Step 5: Remove Configuration Entries

For each location where the configuration exists:

**Removing from .mcp.json:**
```bash
# Use jq to remove specific server entry (if jq is available)
# Otherwise, use node/JavaScript to parse and modify JSON

# Example with node:
node -e "
const fs = require('fs');
const path = '$MAGNET_APP_DIR/.mcp.json';
const config = JSON.parse(fs.readFileSync(path, 'utf8'));
delete config.mcpServers['magnet-local'];  // or 'magnet-canary'
fs.writeFileSync(path, JSON.stringify(config, null, 2));
console.log('Removed magnet-local from', path);
"
```

**Important behaviors:**
- Only remove the specific server entry, not the entire file
- If `mcpServers` becomes empty after removal, remove the `mcpServers` key
- If the file becomes just `{}`, optionally inform user they can delete the file
- Preserve other configurations in the same file

### Step 6: Report Results

After removal, report:
- Which configurations were removed
- From which locations
- Any configurations that were not found
- Remind user to restart Claude Code to apply changes

Example output:
```
Removed configurations:
- magnet-local from ~/magnet-app/.mcp.json
- magnet-canary from ~/magnet-app/.mcp.json

Not found:
- No global configurations in ~/.claude/

Please restart Claude Code to apply the changes.
```

## Edge Cases

### Configuration Not Found

If the requested configuration doesn't exist:
```
The magnet-local configuration was not found in any of the checked locations:
- ~/magnet-app/.mcp.json (file exists but doesn't contain magnet-local)
- ~/.claude/settings.json (no mcpServers section)

No changes were made.
```

### Last Server in File

If removing the last server entry:
```javascript
// After removal, check if mcpServers is empty
if (Object.keys(config.mcpServers).length === 0) {
  delete config.mcpServers;
  // Inform user: "The mcpServers section is now empty"
}
```

### File Permissions

If unable to modify the file:
```
Error: Unable to modify ~/magnet-app/.mcp.json
Please check file permissions or remove the configuration manually.
```

## Examples

### Example 1: Remove Local Configuration

User: "Remove the local MCP server"

Actions:
1. Confirm they want to remove magnet-local
2. Check ~/magnet-app/.mcp.json - found magnet-local
3. Check ~/.claude/ - no global config
4. Ask for confirmation
5. Remove magnet-local entry from .mcp.json
6. Report success and remind to restart Claude Code

### Example 2: Remove Both Configurations

User: "Clean up all Magnet MCP configurations"

Actions:
1. Ask which to remove → user selects "Both"
2. Scan all locations
3. Find magnet-local and magnet-canary in ~/magnet-app/.mcp.json
4. Confirm removal of both
5. Remove both entries
6. Report what was removed

### Example 3: Configuration Not Found

User: "Remove the canary server"

Actions:
1. Confirm they want to remove magnet-canary
2. Scan locations - magnet-canary not found anywhere
3. Report "Configuration not found, no changes made"

## Notes

- This skill removes configuration entries, not the actual MCP server code
- Always confirm before removing configurations
- Check both project-specific and global locations
- Preserve other configurations in the same files
- Remind users to restart Claude Code after changes
- If jq is not available, use node for JSON manipulation
