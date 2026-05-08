---
name: file-organizer
description: Organises files and folders by understanding context, finding duplicates, suggesting structures, and automating cleanup. Use when user mentions messy Downloads, can't find files, duplicate files, folder structure problems, cleanup tasks, or asks to organise/sort/tidy files and directories.
---

# File Organizer

Helps maintain clean, logical file structures without manual overhead.

## Workflow

### 1. Scope the Task

Ask if unclear:
- Which directory? (Downloads, Documents, specific path?)
- Main problem? (Chaos, duplicates, no structure, can't find things?)
- Anything to avoid? (Active projects, sensitive folders?)
- How aggressive? (Conservative vs comprehensive?)

### 2. Analyse Current State

Use Desktop Commander to survey:

```powershell
# Overview
Get-ChildItem -Path $targetPath -Recurse | Measure-Object

# File types breakdown
Get-ChildItem -Path $targetPath -Recurse -File | Group-Object Extension | Sort-Object Count -Descending

# Largest files
Get-ChildItem -Path $targetPath -Recurse -File | Sort-Object Length -Descending | Select-Object -First 20 FullName, @{N='SizeMB';E={[math]::Round($_.Length/1MB,2)}}

# Old files (not modified in 6 months)
Get-ChildItem -Path $targetPath -Recurse -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddMonths(-6) }
```

Summarise: total files, type breakdown, size distribution, obvious issues.

### 3. Identify Organisation Patterns

Group by what makes sense for the content:

**By Type**: Documents, Images, Videos, Archives, Code, Spreadsheets, Installers
**By Purpose**: Work/Personal, Active/Archive, Project-specific, Reference, Temporary
**By Date**: Current year, Previous years, Ancient (archive candidates)

### 4. Find Duplicates (when requested)

```powershell
# Find by identical hash
Get-ChildItem -Path $targetPath -Recurse -File | Get-FileHash | Group-Object Hash | Where-Object { $_.Count -gt 1 }

# Find by name
Get-ChildItem -Path $targetPath -Recurse -File | Group-Object Name | Where-Object { $_.Count -gt 1 }
```

For each duplicate set: show paths, sizes, dates, recommend which to keep. **Always confirm before deleting.**

### 5. Propose Organisation Plan

Present before making changes:

```markdown
## Current State
- X files across Y folders
- [Size] total
- Issues: [list]

## Proposed Structure
[Show folder tree]

## Changes
1. Create folders: [list]
2. Move files: [summary by category]
3. Archive: [old files]
4. Delete: [duplicates - with confirmation]

## Needs Your Decision
- [Ambiguous files]

Ready to proceed?
```

### 6. Execute

After approval:
- Create folder structure first
- Move files systematically
- Log all operations
- **Confirm before any deletion**
- Stop and ask if anything unexpected

### 7. Summarise

```markdown
## Complete

- Created X folders
- Organised Y files  
- Freed Z GB (duplicates)
- Archived W old files

## New Structure
[Folder tree]

## Maintenance Tips
- Weekly: Sort new downloads
- Monthly: Review completed projects
- Quarterly: Check for duplicates
```

## Common Patterns

**Downloads Cleanup**: Sort by type (docs→Documents, images→Pictures, installers→separate), archive old files.

**Project Organisation**: Separate Active from Archive, consolidate duplicates, consistent naming.

**Duplicate Removal**: Hash-based detection, keep newest/best-named, confirm each deletion.

**Photo Organisation**: By EXIF date or file date into Year/Month structure.

## Key Rules

1. **Never delete without confirmation** - even obvious duplicates
2. **Preserve modification dates** when moving
3. **Stop on unexpected situations** - don't assume
4. **Log operations** for potential undo
5. **Archive before delete** when in doubt
