---
name: nxs-sq-name-generator
description: Generate the next sequential file or folder name for directories with numbered prefixes (e.g., 01-setup.md, 02-init.md). Use when creating a new file or folder that should follow an existing numbering sequence, when adding to a sequentially-named series, or when the user asks for the "next" numbered item in a directory.
---

# Sequential Name Generator

Generate the next sequential file or folder name given a path and target name.

## Usage

```bash
python ./scripts/next_sequential_name.py <path> <target_name>
```

**Arguments:**

-   `path` - Directory to scan for existing sequential files/folders
-   `target_name` - Unnumbered target name (e.g., `cleanup.md` for files, `chapter` for folders)

**Type detection:** If `target_name` has an extension (`.md`, `.txt`, etc.), it scans for files. Otherwise, it scans for folders.

## Examples

```bash
# Files: Given 01-setup.md, 02-init.md, 04-teardown.md exist
python ./scripts/next_sequential_name.py ./docs cleanup.md
# Output: 05-cleanup.md

# Folders: Given 01-chapter, 02-chapter exist
python ./scripts/next_sequential_name.py ./book chapter
# Output: 03-chapter

# Empty directory
python ./scripts/next_sequential_name.py ./empty notes.md
# Output: 01-notes.md
```

## Behavior

1. Scans directory for files or folders matching the target type
2. Extracts numeric prefixes from names matching pattern `NN-*`
3. Finds highest prefix (handles gaps: `01`, `02`, `04` → highest is `4`)
4. Returns `(highest + 1)` padded to 2 digits with target name
