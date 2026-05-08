---
name: file-organizer
description: "Comprehensive file organization workflow for SORT/ directory. Validates filenames, renames to CLAUDE.md standards, relocates to correct directories, runs OPSEC agents, and generates detailed reports. Main orchestrator for automated file organization pipeline."
license: Proprietary. See LICENSE in repository root
---

# File Organizer

## Overview

This is the **main orchestrator skill** for the comprehensive file organization workflow. It coordinates all utility skills (filename-validator, file-renamer, file-relocator) and OPSEC agents (data-breach-agent, organization-sanitation-agent) to provide a complete, automated solution for organizing files from the SORT/ directory.

## When to Use This Skill

- **Primary use case**: Organizing files from SORT/ directory
- After receiving new media or documentation assets
- During repository cleanup and standardization
- As part of periodic maintenance workflows
- When integrating external contributions

## Complete Workflow Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    FILE ORGANIZER WORKFLOW                   │
└─────────────────────────────────────────────────────────────┘

  1. SCAN SORT/          → Inventory all files
          ↓
  2. VALIDATE            → filename-validator skill
          ↓
  3. ANALYZE             → Extract metadata, categorize
          ↓
  4. INTERACTIVE         → Prompt user for unclear files
          ↓
  5. RENAME              → file-renamer skill
          ↓
  6. RELOCATE            → file-relocator skill
          ↓
  7. OPSEC CHECK         → data-breach-agent
          ↓
  8. ORGANIZATION        → organization-sanitation-agent
          ↓
  9. REPORT              → Generate comprehensive report
          ↓
  10. COMPLETE           → Summary and next steps
```

## Phase-by-Phase Execution

### Phase 1: Scan and Inventory

**Goal:** Discover all files in SORT/ directory and create initial inventory

**Actions:**

```bash
# Find all files in SORT/
find SORT/ -type f > sort_inventory.txt

# Count files by type
echo "Image files: $(find SORT/ -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.svg" \) | wc -l)"
echo "Document files: $(find SORT/ -type f \( -name "*.pdf" -o -name "*.docx" \) | wc -l)"
echo "Markdown files: $(find SORT/ -type f -name "*.md" | wc -l)"
echo "Other files: $(find SORT/ -type f ! \( -name "*.png" -o -name "*.jpg" -o -name "*.svg" -o -name "*.pdf" -o -name "*.docx" -o -name "*.md" \) | wc -l)"
```

**Output:**

```markdown
## Phase 1: Scan and Inventory

**SORT/ Directory Contents:**
- Total files: 25
- Image files: 15 (.png, .jpg, .svg)
- Document files: 7 (.pdf, .docx)
- Markdown files: 2 (.md)
- Other files: 1

**Files Discovered:**
1. Bear_Market_Strategy__When_Competitors_Exit.png
2. TerraHash Logo Final.PNG
3. Smart DIP Buying Banner.jpg
4. PRD - Smart Contract Implementation.pdf
5. ...

**Status:** ✅ Inventory complete
```

### Phase 2: Filename Validation

**Goal:** Use filename-validator skill to identify non-compliant files

**Invoke Skill:**

```markdown
Use the filename-validator skill to validate all files in SORT/
```

**Expected Output:**

- List of valid files (already compliant)
- List of invalid files with specific issues
- Categorization of violations (uppercase, spaces, missing components, etc.)

**Decision Point:**

- If all files valid → Skip to Phase 6 (Relocate)
- If some invalid → Continue to Phase 3

### Phase 3: Content Analysis and Metadata Extraction

**Goal:** Analyze file contents to assist with categorization and renaming

**For Images:**

```bash
# Get image dimensions
identify -format "%f: %wx%h\n" SORT/*.png SORT/*.jpg SORT/*.svg 2>/dev/null

# Example output:
# Bear_Market_Strategy.png: 1920x1080
# TerraHash_Logo.PNG: 512x512
```

**For Documents:**

```bash
# Extract first page text to understand content
pdftotext -l 1 "SORT/document.pdf" - | head -20

# Or for DOCX
pandoc "SORT/document.docx" -t plain | head -20
```

**For All Files:**

```python
def analyze_file_for_components(filename, file_type, content_preview=None):
    """
    Use AI to suggest components based on filename and content
    """

    filename_lower = filename.lower()
    suggestions = {}

    # Organization detection
    if 'terrahash' in filename_lower or 'ths' in filename_lower:
        suggestions['org'] = 'ths'
        suggestions['product'] = 'stack'
    elif 'ryno' in filename_lower:
        suggestions['org'] = 'ryno'
        suggestions['product'] = 'crypto'

    # Type/category detection from filename
    type_keywords = {
        'logo': 'logo',
        'banner': 'banner',
        'diagram': 'diagram',
        'infographic': 'infographic',
        'icon': 'icon',
        'screenshot': 'screenshot',
        'prd': 'prd',
        'guide': 'guide',
        'api': 'api-docs',
        'spec': 'specs',
        'whitepaper': 'whitepaper'
    }

    for keyword, category in type_keywords.items():
        if keyword in filename_lower:
            if file_type == 'image':
                suggestions['type'] = category
            else:
                suggestions['category'] = category
            break

    # Version detection
    import re
    version_patterns = [
        r'v(\d+)[-.]?(\d+)?[-.]?(\d+)?',
        r'version\s*(\d+)',
        r'final',
        r'draft'
    ]

    for pattern in version_patterns:
        match = re.search(pattern, filename_lower)
        if match:
            if pattern == r'final':
                suggestions['version'] = 'v1-0'
            elif pattern == r'draft':
                suggestions['version'] = 'v0-1'
            else:
                major = match.group(1)
                minor = match.group(2) or '0'
                patch = match.group(3) or '0'
                suggestions['version'] = f'v{major}-{minor}-{patch}'
            break

    # If no version found, default
    if 'version' not in suggestions:
        suggestions['version'] = 'v1-0'

    # Descriptor/title extraction
    # Remove known components and clean up remaining text
    descriptor = filename_lower
    for keyword in ['terrahash', 'ths', 'ryno', 'crypto', 'stack', 'mining',
                   'logo', 'banner', 'diagram', 'prd', 'guide', 'final', 'draft']:
        descriptor = descriptor.replace(keyword, '')

    # Clean up
    descriptor = re.sub(r'[^a-z0-9\s]', '', descriptor)
    descriptor = re.sub(r'\s+', '-', descriptor.strip())
    descriptor = descriptor[:50]  # Limit length

    if descriptor:
        suggestions['descriptor'] = descriptor

    return suggestions
```

**Output:**

```markdown
## Phase 3: Content Analysis

**File:** Bear_Market_Strategy__When_Competitors_Exit.png
- **Dimensions:** 1920x1080
- **AI Suggestions:**
  - org: ths
  - product: stack
  - descriptor: bear-market-strategy
  - type: infographic
  - version: v1-0

**File:** TerraHash Logo Final.PNG
- **Dimensions:** 512x512
- **AI Suggestions:**
  - org: terrahash
  - product: stack
  - descriptor: logo
  - type: icon
  - version: v1-0

**Status:** ✅ Analysis complete for 25 files
```

### Phase 4: Interactive Prompts

**Goal:** Get user input for files where components cannot be determined automatically

**For each unclear file, use AskUserQuestion:**

```markdown
**User Input Required**

We need your help categorizing these files:

**File 1:** Unclear_Diagram.png (1920x1080)

Please provide:
1. **Organization:** ryno, ths, or terrahash
2. **Product:** crypto, stack, or mining
3. **Descriptor:** (e.g., "architecture", "workflow", "comparison")
4. **Type:** banner, logo, icon, infographic, diagram, screenshot

AI Suggestions: org=ths, product=stack, type=diagram
```

**Implementation:**

```python
def prompt_user_for_file(filename, file_type, ai_suggestions):
    """
    Use AskUserQuestion tool to get user input
    """

    if file_type == 'image':
        questions = [{
            "question": f"How should we categorize: {filename}?",
            "header": "File Category",
            "multiSelect": False,
            "options": [
                {
                    "label": "Ryno Crypto Services",
                    "description": "org=ryno, product=crypto"
                },
                {
                    "label": "TerraHash Stack",
                    "description": "org=ths, product=stack"
                },
                {
                    "label": "TerraHash Mining",
                    "description": "org=terrahash, product=mining"
                }
            ]
        }, {
            "question": "What type of image is this?",
            "header": "Image Type",
            "multiSelect": False,
            "options": [
                {"label": "Banner", "description": "Wide marketing banner"},
                {"label": "Logo/Icon", "description": "Branding or icon"},
                {"label": "Diagram", "description": "Technical diagram"},
                {"label": "Infographic", "description": "Data visualization"}
            ]
        }]

    # Similar for documents...

    return questions
```

**Handling User Input:**

- If user provides all required info → Proceed with full rename
- If user provides partial info → Use AI suggestions for missing components
- If user skips → Move file to SORT/NEEDS_REVIEW/ for later

**Output:**

```markdown
## Phase 4: User Input Collection

**Files Requiring Input:** 3

**Resolved:**
- ✅ unclear-diagram.png → User selected: ths/stack, type=diagram
- ✅ mystery-doc.pdf → User selected: ryno/crypto, category=guide

**Deferred:**
- ⏭️  ambiguous-file.dat → Moved to SORT/NEEDS_REVIEW/

**Status:** ✅ User input collected
```

### Phase 5: Batch Rename

**Goal:** Use file-renamer skill to rename all non-compliant files

**Invoke Skill:**

```markdown
Use the file-renamer skill to rename all files in SORT/ according to CLAUDE.md standards
```

**Process:**

1. For each file with validation issues:
   - Combine AI suggestions + user input
   - Construct compliant filename
   - Validate new filename
   - Execute rename (use git mv when possible)
   - Verify rename successful

**Output:**

```markdown
## Phase 5: Batch Rename

**Files Renamed:** 18
**Files Skipped:** 5 (already compliant)
**Errors:** 0

**Rename Operations:**

1. ✅ Bear_Market_Strategy__When_Competitors_Exit.png
   → ths-stack-bear-market-strategy-infographic-1920x1080-v1-0.png

2. ✅ TerraHash Logo Final.PNG
   → terrahash-stack-logo-icon-512x512-v1-0.png

3. ✅ Smart DIP Buying Banner.jpg
   → ryno-crypto-smart-dip-buying-banner-1920x1080-v1-0.jpg

4. ✅ PRD - Smart Contract Implementation.pdf
   → ryno-crypto-prd-smart-contract-implementation-v1-0.pdf

**Rename Log:** SORT/rename_log_20251121_103000.txt

**Status:** ✅ Batch rename complete
```

### Phase 6: Batch Relocate

**Goal:** Use file-relocator skill to move files to correct directories

**Invoke Skill:**

```markdown
Use the file-relocator skill to relocate all files from SORT/ to their proper destinations
```

**Process:**

1. For each renamed file:
   - Determine destination based on filename pattern
   - Create destination directory if needed
   - Check for conflicts
   - Execute relocation (use git mv)
   - Verify file at destination

**Output:**

```markdown
## Phase 6: Batch Relocate

**Files Relocated:** 20
**Directories Created:** 2
**Conflicts Resolved:** 1

**Relocations by Destination:**

### assets/images/ryno-crypto/ (8 files)
- ✅ ryno-crypto-logo-icon-512x512-v1-0.png
- ✅ ryno-crypto-smart-dip-buying-banner-1920x1080-v1-0.jpg
- ✅ ryno-crypto-architecture-diagram-2560x1440-v1-0.svg

### assets/images/terrahash-stack/ (5 files)
- ✅ terrahash-stack-logo-icon-512x512-v1-0.png
- ✅ ths-stack-bear-market-strategy-infographic-1920x1080-v1-0.png

### prd/active/ (4 files)
- ✅ ryno-crypto-prd-smart-contract-implementation-v1-0.pdf
- ✅ ths-stack-prd-tokenomics-v2-0.pdf

### docs/guides/ (3 files)
- ✅ terrahash-mining-guide-overview-v1-0.pdf

**New Directories Created:**
- assets/diagrams/infographics/
- docs/research/

**Status:** ✅ Batch relocation complete
```

### Phase 7: Data Breach Detection

**Goal:** Run data-breach-agent to ensure no sensitive information

**Invoke Agent:**

```markdown
Execute data-breach-agent.md to scan for sensitive data
```

**What It Checks:**

- Financial data (budgets, revenue, costs)
- AI/ML models and training data
- Treasury addresses and private keys
- NOC operational data
- Partnership agreements
- Proprietary algorithms

**If Issues Found:**

- ❌ BLOCK commit
- Generate OPSEC_ALERT.md
- Generate RECOVERY_PLAN.md
- Provide sanitization instructions

**If Clean:**

- ✅ PASS - No sensitive data detected

**Output:**

```markdown
## Phase 7: Data Breach Detection

**Agent:** data-breach-agent
**Status:** ✅ PASS

**Scan Results:**
- Files scanned: 20
- Sensitive data found: 0
- Open source compliance: 78% (within threshold)

**Details:**
- No financial data detected
- No API keys or secrets found
- No proprietary algorithms exposed
- Open source / proprietary balance: COMPLIANT

**Status:** ✅ Data breach check passed
```

### Phase 8: Organization Sanitation

**Goal:** Run organization-sanitation-agent for final validation

**Invoke Agent:**

```markdown
Execute organization-sanitation-agent.md in full mode
```

**What It Validates:**

- Directory structure compliance
- File naming convention adherence
- Content placement accuracy
- Missing documentation
- Metadata completeness

**Modes:** audit, rename, redact, relocate, full

**For This Workflow:** Use **full mode** (all checks)

**Output:**

```markdown
## Phase 8: Organization Sanitation

**Agent:** organization-sanitation-agent
**Mode:** full
**Status:** ✅ PASS

**Validation Results:**

### Directory Structure
- ✅ All required directories present
- ✅ No unauthorized directories created
- ✅ Subdirectories properly nested

### File Naming
- ✅ 20/20 files comply with naming conventions
- ✅ All components present and valid
- ✅ Versioning properly formatted

### File Placement
- ✅ All images in correct directories
- ✅ All documents in correct categories
- ✅ No misplaced files detected

### Content Validation
- ✅ No sensitive data in public files
- ✅ License information present
- ✅ Metadata complete

**Report Generated:** ORGANIZATION_AUDIT_REPORT.md

**Status:** ✅ Organization sanitation complete
```

### Phase 9: Generate Comprehensive Report

**Goal:** Create detailed report of entire organization operation

**Report Structure:**

```markdown
# File Organization Report

**Date:** 2025-11-21T10:30:00Z
**Operation ID:** org-20251121-103000
**Duration:** 5 minutes 23 seconds

---

## Executive Summary

- **Files Processed:** 25
- **Files Renamed:** 18
- **Files Relocated:** 20
- **Files Skipped:** 3
- **Errors:** 0
- **OPSEC Status:** ✅ PASS
- **Organization Status:** ✅ PASS

---

## Phase 1: Scan and Inventory

[Details from Phase 1]

---

## Phase 2: Filename Validation

[Details from Phase 2]

---

## Phase 3: Content Analysis

[Details from Phase 3]

---

## Phase 4: User Input

[Details from Phase 4]

---

## Phase 5: Batch Rename

[Details from Phase 5]

---

## Phase 6: Batch Relocation

[Details from Phase 6]

---

## Phase 7: Data Breach Detection

[Details from Phase 7]

---

## Phase 8: Organization Sanitation

[Details from Phase 8]

---

## Files Organized

### Images → assets/images/
1. ryno-crypto-logo-icon-512x512-v1-0.png
2. ryno-crypto-smart-dip-buying-banner-1920x1080-v1-0.jpg
3. ths-stack-bear-market-strategy-infographic-1920x1080-v1-0.png
4. terrahash-stack-logo-icon-512x512-v1-0.png
5. ...

### Documents → prd/, docs/
1. ryno-crypto-prd-smart-contract-implementation-v1-0.pdf
2. ths-stack-prd-tokenomics-v2-0.pdf
3. terrahash-mining-guide-overview-v1-0.pdf
4. ...

---

## Quality Metrics

- **Naming Compliance:** 100% (20/20 files)
- **Directory Structure:** ✅ Compliant
- **OPSEC Compliance:** ✅ PASS
- **Organization Quality:** ✅ Excellent

---

## Next Steps

1. ✅ Review organized files in their new locations
2. ✅ Verify all files accessible and uncorrupted
3. 🔲 Create git commit (pending user approval)
4. 🔲 Push to remote repository (pending user approval)
5. 🔲 Delete SORT/ directory (pending confirmation)
6. 🔲 Update README.md if needed

---

## Logs and Artifacts

- **Rename Log:** SORT/rename_log_20251121_103000.txt
- **Relocation Log:** relocation_log_20251121_103000.txt
- **OPSEC Report:** ORGANIZATION_AUDIT_REPORT.md
- **Rollback Script:** rollback_relocation_20251121_103000.sh
- **This Report:** FILE_ORGANIZATION_REPORT_20251121_103000.md

---

## Rollback Information

If you need to undo this organization:

```bash
# Rollback relocation
./rollback_relocation_20251121_103000.sh

# Rollback renames
# See: SORT/rename_log_20251121_103000.txt
```

---

**Operation Status:** ✅ SUCCESS

All files successfully organized according to CLAUDE.md standards.
OPSEC compliance verified. Ready for commit.

```

**Save Report:**
```bash
# Save comprehensive report
cat > "FILE_ORGANIZATION_REPORT_$(date +%Y%m%d_%H%M%S).md" << 'EOF'
[report content]
EOF
```

### Phase 10: Completion and Next Steps

**Goal:** Provide clear summary and actionable next steps

**Output:**

```markdown
## ✅ File Organization Complete

**Summary:**
- 20 files successfully organized
- All files comply with CLAUDE.md standards
- OPSEC checks passed
- Ready for git commit

**What Changed:**
- Renamed 18 files to proper naming convention
- Relocated 20 files to correct directories
- Created 2 new subdirectories
- Generated comprehensive documentation

**SORT/ Directory Status:**
- Original files: 25
- Organized: 20
- Needs review: 3 (in SORT/NEEDS_REVIEW/)
- Remaining: 2 (README, .gitkeep)

**Next Steps:**

1. **Review Changes** (Recommended)
   - Check files in new locations
   - Verify filenames are accurate
   - Ensure content is correct

2. **Create Git Commit** (Required)
   - Stage all changes
   - Create descriptive commit message
   - See suggested message below

3. **Push to Remote** (Required)
   - Push to origin
   - Verify GitHub shows changes

4. **Clean Up** (Optional)
   - Delete SORT/ directory (keep NEEDS_REVIEW if applicable)
   - Archive logs and reports
   - Update README.md if needed

**Suggested Commit Message:**

```

feat(organization): organize 20 files from SORT/ directory

- Renamed 18 files to comply with CLAUDE.md standards
- Relocated files to proper directories (assets/, prd/, docs/)
- Created subdirectories: assets/diagrams/infographics/, docs/research/
- Verified OPSEC compliance (data-breach-agent: PASS)
- Validated organization (organization-sanitation-agent: PASS)

Images organized:

- 8 files → assets/images/ryno-crypto/
- 5 files → assets/images/terrahash-stack/
- 2 files → assets/diagrams/

Documents organized:

- 4 files → prd/active/
- 3 files → docs/guides/

See FILE_ORGANIZATION_REPORT_20251121_103000.md for full details.

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>

```

**Commands to Execute:**

```bash
# Stage all changes
git add assets/ prd/ docs/ SORT/

# Commit with message
git commit -m "$(cat <<'EOF'
feat(organization): organize 20 files from SORT/ directory

[full message above]
EOF
)"

# Push to remote
git push origin main
```

**Files for Your Records:**

- 📄 FILE_ORGANIZATION_REPORT_20251121_103000.md (comprehensive report)
- 📄 ORGANIZATION_AUDIT_REPORT.md (OPSEC validation)
- 📄 rename_log_20251121_103000.txt (rename details)
- 📄 relocation_log_20251121_103000.txt (relocation details)
- 🔧 rollback_relocation_20251121_103000.sh (rollback script)

---

**Thank you for using file-organizer! 🎉**

```

## Error Handling and Recovery

### Critical Errors

**If rename fails:**
- Stop workflow
- Keep original files in SORT/
- Report error with details
- Do not proceed to relocation

**If relocation fails:**
- Files remain in SORT/ with new names
- Can retry relocation
- Rollback script available

**If OPSEC check fails:**
- ❌ BLOCK entire workflow
- Generate OPSEC_ALERT.md
- Provide sanitization instructions
- Require manual intervention

### Recovery Procedures

**Undo relocation:**
```bash
./rollback_relocation_[timestamp].sh
```

**Undo renaming:**

```bash
# Use rename log to reverse
while read line; do
    new_name=$(echo $line | cut -d' ' -f1)
    old_name=$(echo $line | cut -d' ' -f3)
    git mv "$new_name" "$old_name"
done < rename_log.txt
```

**Complete rollback:**

```bash
# If changes committed but not pushed
git reset --hard HEAD~1

# If changes not committed
git reset --hard HEAD
git clean -fd
```

## Quality Assurance

Before marking organization complete:

- ✅ All files scanned and inventoried
- ✅ Validation completed for all files
- ✅ User input collected for unclear files
- ✅ All files renamed according to standards
- ✅ All files relocated to correct directories
- ✅ Data breach check passed
- ✅ Organization sanitation passed
- ✅ Comprehensive report generated
- ✅ Rollback scripts created
- ✅ No files lost or corrupted
- ✅ Git history preserved (used git mv)
- ✅ Next steps clearly documented

## Integration with Commands

This skill is typically invoked by:

- `/sort-files` command (primary use case)
- `/cleanup` command
- Pre-commit hooks (for validation)
- Manual invocation for troubleshooting

## Configuration Options

Can be customized via environment variables or parameters:

```bash
# Skip phases
SKIP_VALIDATION=false
SKIP_USER_INPUT=false
SKIP_RENAME=false
SKIP_RELOCATE=false
SKIP_OPSEC=false

# Behavior
INTERACTIVE_MODE=true
AUTO_COMMIT=false
AUTO_PUSH=false
DRY_RUN=false

# Logging
VERBOSE=true
LOG_LEVEL=INFO
```

## Performance Considerations

**For large file sets (100+ files):**

- Process in batches of 25
- Show progress indicators
- Provide time estimates
- Allow pausing/resuming

**For small file sets (< 10 files):**

- Complete workflow in single pass
- Minimal user interaction
- Quick turnaround

---

**Related Documentation:**

- CLAUDE.md (Repository standards - source of truth)
- .claude/skills/filename-validator/skill.md (Phase 2)
- .claude/skills/file-renamer/skill.md (Phase 5)
- .claude/skills/file-relocator/skill.md (Phase 6)
- .claude/agents/data-breach-agent.md (Phase 7)
- .claude/agents/organization-sanitation-agent.md (Phase 8)
- .claude/commands/sort-files.md (Primary command interface)
