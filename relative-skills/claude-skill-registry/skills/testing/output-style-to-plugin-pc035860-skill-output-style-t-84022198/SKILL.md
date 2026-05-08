---
name: output-style-to-plugin
description: This skill should be used when converting deprecated Claude Code output styles (.md files) into the new plugin format. It automates the entire conversion process including creating plugin structure, generating configuration files, and setting up local marketplace for testing.
---

Convert deprecated Claude Code output style markdown files into properly structured plugins using SessionStart hooks. This skill handles the complete conversion process automatically, requiring only essential information from the user.

## When to Use This Skill

Use this skill when:
- Converting an existing output style `.md` file to plugin format
- Migrating from the deprecated `outputStyle` configuration to the plugin system
- Setting up a new plugin-based output style from scratch
- User asks to "convert output style to plugin" or similar migration requests

## Conversion Workflow

### Step 1: Gather Required Information

Ask the user for essential information before starting the conversion. Use the AskUserQuestion tool to collect:

1. **Output Style File**: Path to the existing output style `.md` file
2. **Plugin Name**: Identifier for the plugin (suggest kebab-case version of file name)
3. **Plugin Description**: Brief description (can extract from output style frontmatter if present)
4. **Version**: Default to "1.0.0" for initial conversion
5. **Author Name**: Plugin author's name
6. **Author Email** (optional): Author's email address

**Example questions**:
```
Question: "What is the path to your output style markdown file?"
Question: "What would you like to name this plugin? (e.g., 'my-output-style')"
Question: "Brief description of this output style?"
Question: "Author name for the plugin?"
Question: "Author email? (optional, press Enter to skip)"
```

### Step 2: Check for Existing Marketplace

Before creating a new marketplace, check if the user has an existing marketplace they want to use:

1. Ask: "Do you have an existing marketplace you'd like to add this plugin to?"
2. If yes:
   - Ask for marketplace path
   - Read the existing `marketplace/.claude-plugin/marketplace.json`
   - Extract marketplace name and owner information
   - Plan to add plugin entry to existing plugins array
3. If no:
   - Collect marketplace information:
     - Marketplace name (suggest based on user context)
     - Owner name (suggest same as plugin author)
     - Owner email (suggest same as plugin author email)
   - Plan to create new marketplace structure

### Step 3: Create Plugin Directory Structure

Create the complete plugin structure in the appropriate location:

```
If new marketplace:
  marketplace/
  ├── .claude-plugin/
  │   └── marketplace.json
  └── plugins/
      └── {plugin-name}/
          ├── .claude-plugin/
          │   └── plugin.json
          ├── hooks/
          │   └── hooks.json
          ├── hooks-handlers/
          │   └── session-start.sh
          ├── {output-style}.md
          └── README.md

If existing marketplace:
  {marketplace-path}/
  └── plugins/
      └── {plugin-name}/
          ├── .claude-plugin/
          │   └── plugin.json
          ├── hooks/
          │   └── hooks.json
          ├── hooks-handlers/
          │   └── session-start.sh
          ├── {output-style}.md
          └── README.md
```

Use `mkdir -p` to create all necessary directories in a single operation.

### Step 4: Generate Configuration Files

Generate all required configuration files using the templates in `assets/`:

#### 4.1 plugin.json

Use `assets/plugin.json.template` and replace:
- `{{PLUGIN_NAME}}`: Plugin name from user input
- `{{VERSION}}`: Version from user input (default "1.0.0")
- `{{DESCRIPTION}}`: Plugin description from user input
- `{{AUTHOR_NAME}}`: Author name from user input
- `{{AUTHOR_EMAIL}}`:
  - If email provided: `,\n    "email": "user@example.com"`
  - If no email: empty string (remove the line)

#### 4.2 hooks.json

Use `assets/hooks.json.template` directly - no substitutions needed.

**Critical**: This file must follow exact structure:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks-handlers/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

#### 4.3 session-start.sh

Use `assets/session-start.sh.template` and replace:
- `{{OUTPUT_STYLE_FILENAME}}`: Base name of the output style markdown file

Make the script executable:
```bash
chmod +x hooks-handlers/session-start.sh
```

#### 4.4 marketplace.json

If creating new marketplace, use `assets/marketplace.json.template` and replace:
- `{{MARKETPLACE_NAME}}`: Marketplace name from user input
- `{{OWNER_NAME}}`: Owner name from user input
- `{{OWNER_EMAIL}}`: Owner email from user input
- `{{MARKETPLACE_DESCRIPTION}}`: Marketplace description from user input
- `{{PLUGIN_NAME}}`: Plugin name
- `{{PLUGIN_DESCRIPTION}}`: Plugin description
- `{{VERSION}}`: Plugin version

If updating existing marketplace:
- Read existing marketplace.json
- Add new plugin entry to `plugins` array
- Write updated content back

#### 4.5 README.md

Use `assets/README.md.template` and replace:
- `{{PLUGIN_NAME}}`: Plugin name
- `{{DESCRIPTION}}`: Plugin description
- `{{MARKETPLACE_PATH}}`: Full path to marketplace directory
- `{{MARKETPLACE_NAME}}`: Marketplace name
- `{{OUTPUT_STYLE_FILENAME}}`: Output style filename
- `{{PLUGIN_PATH}}`: Full path to plugin directory
- `{{VERSION}}`: Plugin version
- `{{AUTHOR_NAME}}`: Author name
- `{{AUTHOR_EMAIL_LINE}}`:
  - If email provided: `\n\n{{AUTHOR_EMAIL}}`
  - If no email: empty string

### Step 5: Copy Output Style Content

Copy the output style markdown file to the plugin directory:

```bash
cp {source-path}/{output-style}.md {plugin-path}/{output-style}.md
```

Preserve the original filename to maintain clarity about the content source.

### Step 6: Verify Installation

After creating all files, provide installation instructions:

```
1. Add marketplace (if new):
   /plugin marketplace add {marketplace-path}

2. Install plugin:
   /plugin install {plugin-name}@{marketplace-name}

3. Restart Claude Code or start new session
```

Also inform the user:
- How to modify the output style (edit the `.md` file)
- That changes take effect in new sessions without reinstallation
- How to uninstall if needed

### Step 7: Validate Structure

After creating all files, perform basic validation:

1. Check all required files exist:
   - `.claude-plugin/plugin.json`
   - `hooks/hooks.json`
   - `hooks-handlers/session-start.sh`
   - Output style markdown file
   - `README.md`

2. Verify JSON files are valid:
   - Parse each JSON file to check syntax
   - Report any parsing errors immediately

3. Check script permissions:
   - Ensure `session-start.sh` is executable

4. Verify marketplace.json structure:
   - Check required fields: name, owner, plugins
   - Verify plugin source path starts with `./`

If any validation fails, report the specific issue and suggest fixes.

## Template Variable Reference

Quick reference for template substitutions:

### Plugin Configuration
- `{{PLUGIN_NAME}}`: Kebab-case plugin identifier
- `{{VERSION}}`: Semantic version (e.g., "1.0.0")
- `{{DESCRIPTION}}`: Brief plugin description
- `{{AUTHOR_NAME}}`: Author's name
- `{{AUTHOR_EMAIL}}`: Author's email (optional)

### Marketplace Configuration
- `{{MARKETPLACE_NAME}}`: Marketplace identifier
- `{{OWNER_NAME}}`: Marketplace owner name
- `{{OWNER_EMAIL}}`: Marketplace owner email
- `{{MARKETPLACE_DESCRIPTION}}`: Marketplace description

### File References
- `{{OUTPUT_STYLE_FILENAME}}`: Name of output style markdown file
- `{{MARKETPLACE_PATH}}`: Full path to marketplace directory
- `{{PLUGIN_PATH}}`: Full path to plugin directory

## Error Handling

If issues occur during conversion:

1. **Permission errors**: Ensure write access to target directories
2. **File already exists**: Ask user if they want to overwrite
3. **Invalid JSON**: Check template substitution and JSON syntax
4. **Missing source file**: Verify output style file path

For common errors and solutions, reference `references/troubleshooting.md`.

## Post-Conversion Support

After conversion, users may ask about:

1. **Modifying output style**: Point to the `.md` file location
2. **Installation issues**: Reference `references/troubleshooting.md`
3. **Plugin structure**: Reference `references/plugin-structure.md`
4. **Sharing the plugin**: Explain plugin distribution options

## Resources

- `references/plugin-structure.md`: Complete plugin structure documentation
- `references/troubleshooting.md`: Common errors and solutions
- `assets/*.template`: Template files for configuration

## Notes

- Always use absolute paths when working with files
- Verify JSON syntax after template substitution
- Test installation instructions before providing to user
- Keep original output style file as source of truth
- Plugin format allows easier distribution and version control than output styles
