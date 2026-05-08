---
name: maintaining-changelog
description: Updates or creates CHANGELOG.md files for pull request changes. Use when users request changelog updates, or when adding entries for new features, fixes, or breaking changes.
scope: merge_request
---
# Maintaining changelogs

## Workflow

Use this checklist:

```
Changelog Progress
- [ ] Step 1: Check if CHANGELOG.md exists (common names: CHANGELOG.md, CHANGES.md, HISTORY.md)
- [ ] Step 2: If exists, analyze format (sections, categories, entry style)
- [ ] Step 3: If not exists, create using Keep a Changelog format
- [ ] Step 4: Locate unreleased section (Unreleased, Next, Development, HEAD, etc.)
- [ ] Step 5: Check if entry for current PR already exists
- [ ] Step 6: Determine change type from PR diff
- [ ] Step 7: Write or update entry following detected format
- [ ] Step 8: Verify only unreleased section was modified
```

## Format detection

When CHANGELOG.md exists, analyze:

1. **Section headers**: Identify unreleased section name (Unreleased, Next, Development, HEAD, etc.)
2. **Categories**: Note used categories (Added/Changed/Fixed/Deprecated/Removed/Security vs custom)
3. **Entry style**: Bullet format, prefixes, indentation, line length
4. **Version format**: Semantic versioning, date-based, or custom
5. **Date format**: ISO, relative dates, or none

Preserve all detected conventions when adding entries.

## Creating a new changelog

If no CHANGELOG.md exists, create one using Keep a Changelog format:

````markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- [Your new entry here]

### Changed

### Deprecated

### Removed

### Fixed

### Security
````

## Handling existing entries

If an entry for the current PR already exists in the unreleased section:

1. Review the existing entry against current PR changes
2. If outdated or incomplete, update it to reflect latest changes
3. Merge related entries if multiple exist for the same change
4. Preserve the original entry's style and category

## Change type determination

Analyze PR diff and commits to categorize:

- **Added**: New features, capabilities, dependencies
- **Changed**: Modifications to existing functionality
- **Deprecated**: Features marked for removal
- **Removed**: Deleted features or breaking changes
- **Fixed**: Bug fixes, corrections
- **Security**: Security-related fixes or improvements

Use categories that match the existing changelog format.

## Entry writing guidelines

- Write for end users, not developers
- Use imperative mood ("Add feature X" not "Added feature X")
- Be concise and specific
- Reference issue/PR numbers when relevant: `(#123)`
- Group related changes under one entry when appropriate
- One entry per logical change

## Critical constraint

**Only modify the unreleased section** (or equivalent like Next, Development, HEAD).

- Never modify released/versioned entries—these are historical records
- Never add entries to past versions
- If no unreleased section exists, create one at the top (after header/description)
- Verify changes are limited to unreleased section before completing

## Quality guardrails

- Match existing format exactly (categories, style, structure)
- Keep entries concise (one line when possible)
- Use consistent terminology with existing entries
- Verify changelog is valid Markdown after edits
- Ensure entries are user-facing and meaningful

