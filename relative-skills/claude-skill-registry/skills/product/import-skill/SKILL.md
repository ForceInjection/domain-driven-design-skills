---
name: import-skill
description: Import a skill from Notion (or other source) into local Nexus. Load when user mentions "import skill", "download skill", "add skill to nexus", "pull skill from notion", or selects a skill to import after querying.
---

# Import Skill to Nexus

Download skill content from Notion and create it locally in `03-skills/`.

## Purpose

This is an atomic building block that takes skill content (from Notion or other sources) and creates a proper skill folder structure in Nexus. It handles:

- Downloading the skill file from Notion
- Extracting/creating the SKILL.md
- Creating the folder structure
- **Auto-backup of existing skills** before overwriting
- **Batch import** of multiple skills at once
- Checking for existing skills (prompt to overwrite)

**Typically used after `query-notion-db`** when user selects a skill to import.

---

## Safeguards

### Pre-Flight Check (ALWAYS Run First)

Before ANY import operation, verify Notion setup:

```bash
python ../../notion-master/scripts/check_notion_config.py
```

**If configuration missing:**
- Option A: Run setup wizard: `python ../../notion-master/scripts/setup_notion.py`
- Option B: See [../../notion-master/references/setup-guide.md](../../notion-master/references/setup-guide.md)

**Expected output if configured:**
```
✅ ALL CHECKS PASSED
You're ready to use Notion skills
```

### Automatic Backup

When importing a skill that already exists locally, the script automatically creates a backup:

```
[BACKUP] Existing skill backed up to: my-skill_20251210-134523
```

**Backup location**: `03-skills/.backup/`

**To disable backup**: Use `--no-backup` flag (not recommended)

### Content Validation

Before importing, validate the skill:

1. **File exists** → Check Skill property has attachment
2. **Valid YAML** → Verify `name:` and `description:` in header
3. **No malicious content** → Basic sanity check on file content

```
Validating skill content...

✅ File attached: {filename}
✅ Valid YAML header
✅ Content looks safe

Ready to import.
```

### Local Conflict Detection

Before overwriting local skill:

```
⚠️ Local skill "{skill-name}" exists

Local version:  Modified {date}
Notion version: Created by {owner} on {date}

Options:
1. Overwrite local with Notion version (backup created automatically)
2. Keep local version
3. Compare side-by-side

Choose (1-3):
```

### Prohibited Operations

| Operation | Status | Notes |
|-----------|--------|-------|
| Import single skill | ✅ Allowed | With backup if exists |
| Batch import | ✅ Allowed | Multiple page IDs supported |
| Import without file | ❌ Blocked | Skill must have attachment |
| Import invalid SKILL.md | ⚠️ Recover | Auto-create from Notion properties |

---

## Workflow

### Step 1: Receive Skill Data

From `query-notion-db` or user input, receive:
- **Skill name** (e.g., "beam-list-agents")
- **Notion page ID** (for downloading attached file)
- **Description** (for creating SKILL.md if needed)

### Step 2: Check for Existing Skill

```bash
# Check if skill already exists
ls 03-skills/{skill-name}/SKILL.md
```

**If exists:**
```
⚠️ Skill "{skill-name}" already exists locally.

Options:
1. Overwrite - Replace with version from Notion (backup created)
2. Skip - Keep local version

What would you like to do?
```

### Step 3: Download and Extract Skill

**Use the download script (handles all formats automatically):**
```bash
python ../../notion-master/scripts/download_skill.py <page_id>
```

**For batch import (multiple skills):**
```bash
python ../../notion-master/scripts/download_skill.py <page_id1> <page_id2> <page_id3>
```

The script automatically:
1. Fetches page properties from Notion
2. Downloads the attached skill file
3. Creates backup of existing skill (if any)
4. Detects file format and extracts appropriately
5. Creates proper skill folder structure in `03-skills/`

**Optional parameters:**
```bash
# Batch import multiple skills
python download_skill.py abc123 def456 ghi789

# Custom output directory
python download_skill.py abc123 --output-dir 03-skills

# Skip backup (not recommended)
python download_skill.py abc123 --no-backup

# JSON output for programmatic use
python download_skill.py abc123 --json
```

**Supported formats:**
- **JSON bundle** (`.skill.json`) - Preferred format, contains all skill files with base64-encoded contents
- **ZIP archive** (`.zip`) - Legacy format, extracts folder structure
- **Single file** (`.txt`, `.md`) - Simple skills with just SKILL.md

**Example output (single skill):**
```
[INFO] Fetching page: 2c52cadf-bbbc-81ae-b81a-fd0600bc0122
[INFO] Skill: setup-linear-onboarding-template (v1.0)
[INFO] Downloading: setup-linear-onboarding-template.skill.json
[OK] Downloaded: 27,107 bytes
[INFO] Extracting skill...
  ✓ SKILL.md
  ✓ scripts/format_template.py
  ✓ references/client-name-template.md

[SUCCESS] Skill extracted to: 03-skills/setup-linear-onboarding-template
[SUCCESS] Files: 3

Skill structure:
  SKILL.md
  references/client-name-template.md
  scripts/format_template.py
```

**Example output (batch import):**
```
==================================================
[BATCH] Importing 3 skills
==================================================

[1/3] Processing...
----------------------------------------
[INFO] Fetching page: abc123
[INFO] Skill: skill-one (v1.0)
...
[SUCCESS] Skill extracted to: 03-skills/skill-one

[2/3] Processing...
----------------------------------------
[INFO] Fetching page: def456
[BACKUP] Existing skill backed up to: skill-two_20251210-134523
...
[SUCCESS] Skill extracted to: 03-skills/skill-two

[3/3] Processing...
----------------------------------------
[ERROR] Page not found: ghi789

==================================================
[BATCH COMPLETE]
  ✓ Success: 2
  ✗ Failed: 1
    - ghi789
==================================================
```

### Step 4: Validate Structure

Required structure:
```
03-skills/{skill-name}/
└── SKILL.md          # Required - skill definition
└── references/       # Optional - supporting docs
└── scripts/          # Optional - automation scripts
└── assets/           # Optional - images, templates
```

**Validate SKILL.md has required YAML header:**
```yaml
---
name: skill-name
description: Load when user mentions "trigger phrase"...
version: 1.0
---
```

### Step 5: Confirm Success

```
✅ Skill imported successfully!

📁 Location: 03-skills/{skill-name}/
📊 Version: 1.0
📄 Files:
   - SKILL.md
   - scripts/format_template.py
   - references/guide.md
🔒 Backup: .backup/skill-name_20251210-134523 (if existed)

💡 Try it: Say "{trigger phrase}" to use this skill
```

---

## Input Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| page_id(s) | Yes | One or more Notion page IDs |
| --output-dir | No | Custom output directory (default: 03-skills) |
| --no-backup | No | Skip backup of existing skills |
| --json | No | Output results as JSON |

---

## Backup System

### Automatic Backups

When you import a skill that already exists locally, the script:
1. Creates `03-skills/.backup/` directory (if doesn't exist)
2. Copies existing skill to `.backup/{skill-name}_{timestamp}`
3. Proceeds with import

**Backup naming**: `{skill-name}_YYYYMMDD-HHMMSS`

**Example**:
```
03-skills/.backup/
├── my-skill_20251210-134523/
├── my-skill_20251209-091234/
└── other-skill_20251208-160045/
```

### Restore from Backup

To restore a backup:
```bash
# Remove current version
rm -rf 03-skills/my-skill

# Restore from backup
cp -r 03-skills/.backup/my-skill_20251210-134523 03-skills/my-skill
```

### Cleanup Old Backups

Backups are not auto-deleted. Periodically clean up:
```bash
# Remove backups older than 30 days
find 03-skills/.backup -type d -mtime +30 -exec rm -rf {} +
```

---

## Example Usage

### Import from Notion Query Results

```
User: "Show me skills for Linear integration"

AI: [Runs query-notion-db with Integration=Linear filter]

Found 2 skills:
1. setup-linear-onboarding-template (v1.0) - Fill Linear template projects
2. generate-linear-project-update (v1.0) - Create weekly status updates

Which would you like to import? (1, 2, or both)

User: "both"

AI: [Runs download_skill.py with both page IDs]

==================================================
[BATCH] Importing 2 skills
==================================================

[1/2] Processing...
✅ Imported: setup-linear-onboarding-template
📁 Location: 03-skills/setup-linear-onboarding-template/
📄 Files: 3

[2/2] Processing...
✅ Imported: generate-linear-project-update
📁 Location: 03-skills/generate-linear-project-update/
📄 Files: 1

==================================================
[BATCH COMPLETE]
  ✓ Success: 2
==================================================
```

### Import with Existing Skill

```
User: "Import beam-list-agents"

AI: ⚠️ Skill "beam-list-agents" already exists locally.

    Local version: Modified 2025-12-08
    Notion version: v1.2 by Jack Li on 2025-12-10

    Options:
    1. Overwrite - Replace with Notion version (backup created)
    2. Skip - Keep local version

User: "1"

AI: [BACKUP] Existing skill backed up to: beam-list-agents_20251210-135623

    ✅ Imported: beam-list-agents (v1.2)
    📁 Location: 03-skills/beam-list-agents/
    🔒 Backup: .backup/beam-list-agents_20251210-135623
```

---

## Error Handling

**Common errors:**

| Error | Cause | Solution |
|-------|-------|----------|
| No file attached | Notion page has no Skill file | Ask user to attach file in Notion first |
| Invalid SKILL.md | Missing YAML header | Create minimal header from Notion properties |
| Download failed | Expired URL or network issue | Retry with fresh page query |
| Extract failed | Corrupt zip or wrong format | Check file format, try manual download |
| Page not found | Invalid page ID | Verify page ID from query results |

**For detailed troubleshooting:**
- See [../../notion-master/references/error-handling.md](../../notion-master/references/error-handling.md)

### Auto-Recovery: Create SKILL.md from Notion Properties

If downloaded file doesn't contain valid SKILL.md, create one from Notion data:

```yaml
---
name: {skill-name}
description: {description from Notion}
version: {version from Notion or "1.0"}
---

# {Skill Name}

{Description from Notion}

## Purpose

{Purpose from Notion, or "Imported from Beam Nexus Skills database"}

---

*Imported from Notion on {date}*
```

---

## Integration with Other Skills

**Typically called after:**
- `query-notion-db` - User selects skill(s) from query results

**Can be followed by:**
- Testing the imported skill
- `export-skill-to-notion` - If user modifies and wants to push changes back

---

## Notes

- **Preferred format**: JSON bundles (`.skill.json`) containing all skill files with base64-encoded contents - preserves full skill structure including scripts/, references/, and assets/ folders
- **Legacy format**: ZIP archives (`.zip`) - still supported for backward compatibility
- **Simple format**: Single `.txt` or `.md` files - for skills with just SKILL.md
- **Version tracking**: Version is extracted from Notion and displayed during import
- **Auto-backup**: Existing skills are automatically backed up to `03-skills/.backup/` before overwriting
- **Batch import**: Pass multiple page IDs to import several skills at once
- Notion file URLs expire after 1 hour - download immediately after query
- The download script creates skill folder directly in `03-skills/` by default
- Always validate SKILL.md format before confirming success

---

## Version Format Standard

Skills use semantic versioning: `MAJOR.MINOR` or `MAJOR.MINOR.PATCH`

| Valid | Invalid |
|-------|---------|
| `1.0` | `v1.0` (no "v" prefix) |
| `1.1` | `1` (needs MAJOR.MINOR) |
| `2.0` | `latest` (must be numeric) |
| `1.0.0` | `1.0.0.0` (too many segments) |

**Version meaning**:
- **MAJOR** (`2.0`): Breaking changes, complete rewrites
- **MINOR** (`1.1`, `1.2`): Bug fixes, improvements, new features

See [database-schema.md](../../notion-master/references/database-schema.md) for full versioning rules.
