---
name: julien-workflow-check-loaded-skills
description: Check which Claude skills are loaded globally and project-level. Displays loaded skills by category (Hostinger, Anthropic, custom), counts, and helps troubleshoot missing skills.
license: Apache-2.0
allowed-tools:
  - Bash
  - Read
metadata:
  author: "Julien"
  version: "1.0.0"
  category: "workflow"
  keywords: ["skills", "debug", "workflow", "loaded", "discovery", "troubleshoot"]
triggers:
  - "loaded skills"
  - "check skills"
  - "list skills"
  - "available skills"
  - "what skills"
  - "skills chargées"
  - "vérifier skills"
  - "lister skills"
  - "skills disponibles"
  - "quelles skills"
  - "which skills are loaded"
  - "show my skills"
---

# Check Loaded Skills

This skill helps you verify which Claude Code skills are currently loaded in your project.

## When to Use This Skill

Use this skill when you need to:
- **Verify loaded skills** before invoking infrastructure or workflow skills
- **Debug missing skills** when a skill you expect isn't available
- **Check skill hierarchy** between global (~/.claude/skills/) and project-level (.claude/skills/)
- **Discover available skills** to understand what's in your environment
- **Troubleshoot skill conflicts** when project-level skills override globals

## What This Skill Does

The skill runs a comprehensive check of your skill environment:

1. **Lists global skills** from `~/.claude/skills/`
2. **Lists project-level skills** from `.claude/skills/` (if any)
3. **Categorizes skills** by author/type:
   - Hostinger infrastructure skills (julien-infra-hostinger-*)
   - Anthropic official skills (anthropic-*)
   - Custom/personal skills (julien-*, google-services-*)
4. **Shows counts** for each category
5. **Identifies conflicts** if project-level skills override globals

## Usage

### Via Slash Command (Recommended)
```bash
/check-loaded-skills
```

### Via Direct Invocation
Ask Claude to check loaded skills and Claude will invoke this skill automatically.

Examples:
- "Check which skills are loaded"
- "Show me available skills"
- "List Hostinger skills"
- "Are all my infrastructure skills loaded?"

## Output Format

```
═══════════════════════════════════════════════════════
🔍 SKILLS CHARGÉS - Current Project
═══════════════════════════════════════════════════════

📦 SKILLS GLOBAUX (~/.claude/skills/)
───────────────────────────────────────────────────────
Total: 28 skills

🏢 Skills Hostinger-specific:
  ✓ julien-infra-hostinger-database
  ✓ julien-infra-hostinger-deployment
  ✓ julien-infra-hostinger-docker
  ✓ julien-infra-hostinger-maintenance
  ✓ julien-infra-hostinger-nginx
  ✓ julien-infra-hostinger-space-reclaim
  ✓ julien-infra-hostinger-ssh

🤖 Skills Anthropic: 9
  ✓ anthropic-design-canvas
  ✓ anthropic-office-docx
  [...]

📁 SKILLS PROJECT-LEVEL (.claude/skills/)
───────────────────────────────────────────────────────
✅ Aucun skill project-level
   → Utilise uniquement les skills globaux

═══════════════════════════════════════════════════════
✅ Vérification terminée
═══════════════════════════════════════════════════════
```

## Skill Resolution Hierarchy

Claude loads skills in this order:
1. **Global skills** (`~/.claude/skills/`) - Lower priority
2. **Project-level skills** (`.claude/skills/`) - Higher priority (overrides globals)

If a skill exists in both locations, the project-level version takes precedence.

## Troubleshooting

**Problem**: Expected skill not showing up

**Solutions**:
1. Check if skill exists in marketplace: `ls -1 "path/to/marketplace/skills/"`
2. Verify sync to global: `ls -1 ~/.claude/skills/`
3. Re-sync from marketplace: `/sync-personal-skills`
4. Check for typos in skill name

**Problem**: Skill shows in global but not working

**Possible causes**:
- Skill has incorrect YAML frontmatter
- Skill references missing files
- Permissions issue on script files

**Solution**: Check skill SKILL.md file for correct format

## Skill Chaining

### Skills Required Before
- None (diagnostic skill, entry point)

### Input Expected
- None required
- Optional: specific skill name to search for

### Output Produced
- **Format**: Console output with categorized skill list
- **Side effects**: None (read-only)
- **Duration**: < 5 seconds

### Compatible Skills After
**Recommandés:**
- **julien-workflow-sync-personal-skills**: If skills are missing, sync from marketplace
- **julien-dev-tools-skill-creator-pro**: If need to create new skill

**Optionnels:**
- **julien-dev-tools-skill-reviewer**: Review quality of loaded skills

### Called By
- Direct user invocation: "Check loaded skills", "List my skills"
- Debugging workflows when skills aren't triggering
- Pre-deployment verification

### Tools Used
- `Bash` (usage: run check-loaded-skills.sh script)
- `Read` (usage: read skill directories)

### Visual Workflow

```
User: "Check which skills are loaded"
    ↓
[THIS SKILL]
    ├─► List ~/.claude/skills/
    ├─► List .claude/skills/ (if exists)
    ├─► Categorize by author
    └─► Show counts + conflicts
    ↓
Skills report displayed
    ↓
[If missing skills]
    └─► sync-personal-skills
```

### Usage Example

**Scenario**: Verify Hostinger skills are loaded before deployment

**Command**: "Are my Hostinger skills loaded?"

**Result**:
- Lists 7 Hostinger infrastructure skills
- Confirms all loaded from ~/.claude/skills/
- No project-level overrides

## Technical Details

**Script**: `scripts/check-loaded-skills.sh`
**Requirements**: Bash shell (Git Bash on Windows)
**Permissions**: Read-only (no modifications)
