---
name: bootstrapping-github-projects
description: Automates GitHub Projects V2 setup with standardized workflow boards. Creates custom fields (Status/Value/Effort), configures automations, generates semantic repository labels, and aligns project name with repository. Use when users ask to "set up a project board", "create GitHub project", "bootstrap project planning", "initialize project management", or mention "GitHub Projects V2", "project tracking", or "kanban board setup". Requires GitHub CLI with project scope.
---

# Bootstrapping GitHub Projects

Bootstrap a GitHub Projects V2 board with standardized custom fields, views, and automations using a proven project management template.

## What you should do

When invoked, set up a GitHub project using the automation script. Manual steps are only required for view creation (no API support).

### Automated setup (Primary approach)

Run the automation script from the repository root. The script auto-detects the repository from git context:

```bash
# Auto-detect repository from current git directory
./core/skills/gh-project-setup/scripts/setup-project.sh

# Or specify repository explicitly (if not in git directory)
./core/skills/gh-project-setup/scripts/setup-project.sh owner/repo [project-name]
```

The script automatically:
- ✅ Detects repository from git remote (or uses provided argument)
- ✅ Verifies GitHub authentication and project scope
- ✅ Gets current user as owner
- ✅ Creates project (derives name from repo if not provided)
- ✅ Creates/updates custom fields (Status, Value, Effort)
- ✅ Links repository to project
- ✅ Creates semantic repository labels
- ✅ Saves configuration to `.github/project-config.json`

**Configuration file location**: The config is saved to `.github/project-config.json` (NOT `docs/`):
- Standard GitHub-specific configuration directory
- Alongside workflows, issue templates, and other automation
- Separates infrastructure config from user documentation
- Used by `gh-project-manage` skill for efficient automation

**Manual step required**: Create views via web UI (no API available)

---

## Manual setup

For step-by-step instructions or if the automation script cannot be used, see [MANUAL-SETUP.md](MANUAL-SETUP.md).

## Example workflow

**User invokes skill**: `/gh-project-setup` in Claude Code (from repository root)

**Agent executes**:
1. Run automation script: `./core/skills/gh-project-setup/scripts/setup-project.sh`
2. Script auto-detects repository and handles everything (auth, project, fields, labels, config)
3. Instruct user to create views manually via web UI (provide project URL from script output)
4. Output summary with project URL and next steps (automations, testing)

## Error handling

**Common issues**:

1. **Missing project scope**

   ```bash
   gh auth refresh -h github.com -s project
   ```

2. **Organization not found**
   - Verify org name
   - Check user has admin access

3. **Repository not found**
   - Verify repo exists
   - Check format is `owner/repo`

4. **GraphQL errors**
   - Check API response for specific error messages
   - Verify all IDs are correct format

5. **Field creation fails - Missing description**

   Error: `Expected value to not be null` for `description` field

   **Solution**: Every option MUST include a `description` property:

   ```json
   {"name": "Todo", "color": "GREEN", "description": "Ready to start"}
   ```


6. **Field creation fails - JSON array stringified**

   Error: `Expected "..." to be a key-value object`

   **Solution**: Don't use `-F` flags for JSON arrays. Use `--input` with a JSON file instead.

7. **Cannot update field options**

   **Solution**: Use `updateProjectV2Field` mutation (requires December 2024+ API version)

## Integration with existing tools

**Works with**:
- **`gh-project-manage` skill** - Use generated config for ongoing management
- **`git-project-setup` workflow** - Reference documentation for process
- **`git-issue-create` agent** - Auto-add new issues to project
- **Issue templates** - Update to reference project fields

**Generated config enables**:

```bash
# Example: Add issue to project and set fields using gh-project-manage
gh project item-add <number> --owner <org> --url <issue-url>

# Set fields using IDs from config file
gh project item-edit --id <item-id> --project-id <project-id> \
  --field-id <status-field-id> --single-select-option-id <todo-option-id>
```

## Customization options

If advanced customization is needed after initial setup, use the `gh-project-manage` skill to:
- Update custom field options
- Modify automations
- Change label definitions
- Manage project views

## Best practices

1. **Align project name with repository name** - Matches repository slug for consistency
2. **Always save configuration file** - Essential for future management with `gh-project-manage`
3. **Use `--input` flag for all field mutations** - The `-F` flag doesn't work for JSON arrays
4. **Always include `description` in options** - Required by API schema
5. **Verify auth and project scope upfront** - Check with `gh auth status`
6. **Create standard labels automatically** - Apply semantic color psychology for consistency
7. **Test immediately** - Create test issue and add to project
8. **Capture all field and option IDs** - Store in config file for future automation

## Reference: Standard template

**Custom fields** (semantic colors):
- Status: Backlog (GRAY) → Todo (GREEN) → Doing (BLUE) → Done (PURPLE)
  - Color progression: neutral → ready → active → complete
- Value: Essential (PURPLE) > Useful (BLUE) > Nice-to-have (GREEN)
  - Color hierarchy: highest priority uses most vibrant color
- Effort: Heavy (RED) > Moderate (YELLOW) > Light (GRAY)
  - Color warning: red = significant investment, gray = quick task

**Views**:
- Status board (primary workflow view)
- Table (detailed planning view)
- Value board (prioritization view)
- Effort board (capacity planning view)

**Automations**:
- Auto-add sub-issues
- Auto-close on PR merge
- Set Status=Done on item closed
- Set Status=Done on PR merged

**Label color philosophy**:
- Warm colors (red-orange): Urgency and attention-required items
- Cool colors (blue-cyan): Technical infrastructure and routine work
- Greens: Quality and success indicators
- Purples: Refinement and improvement work
- Grays: Neutral configuration and documentation

For detailed color assignment guidance, see [LABEL-COLORS.md](LABEL-COLORS.md).

**Planning philosophy**:
- Value/Effort guide prioritization (not arbitrary priority labels)
- Status reflects work state, dependencies reflect constraints
- Backlog is for triage, Todo is ready queue
- Done means merged and deployed

## API reference and troubleshooting

For detailed API information, limitations, and technical notes, see [REFERENCE.md](REFERENCE.md):
- GitHub CLI `-F` flag limitations and workarounds
- Required field properties and schemas
- `updateProjectV2Field` mutation details (December 2024+)
- GraphQL mutation reference
- Available colors for field options
- View creation limitations
- Built-in automation capabilities