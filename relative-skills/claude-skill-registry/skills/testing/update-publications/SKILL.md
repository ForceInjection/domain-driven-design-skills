---
name: update-publications
description: Updates the Monarch Initiative publications page with latest data from Google Scholar. Use this when the user asks to update publications, refresh citation metrics, or add new papers to the publications page.
---

# Update Publications Page

This Skill guides you through updating the Monarch Initiative publications page with the latest publications and citation metrics from Google Scholar.

## Google Scholar Profile

The Monarch Initiative Google Scholar profile is:
https://scholar.google.com/citations?hl=en&user=zmUEDj0AAAAJ&view_op=list_works&authuser=1&sortby=pubdate

## Prerequisites

Before starting, ensure the Python environment is set up:

```bash
uv sync --all-extras
```

This installs all dependencies including `scholarly`, `typer`, and `loguru`.

## Step-by-Step Process

### 1. Fetch Latest Metadata

Fetch updated citation metrics from Google Scholar:

```bash
uv run python scripts/get_publications.py fetch-metadata
```

This retrieves total citations, h-index, i10-index, and citations per year, saving to `scripts/metadata.json`.

### 2. Fetch Latest Publications

Fetch the complete publication list (this takes several minutes):

```bash
uv run python scripts/get_publications.py fetch-publications
```

This saves raw publication data to `scripts/scholarly_output.json`.

### 3. Handle Missing Links

Run the update command to check for missing publication links:

```bash
uv run python scripts/get_publications.py update
```

If any publications are missing links, the script will exit with an error listing them. For each missing link:

1. Search online for the publication's official URL (DOI, PubMed, publisher site, arXiv, etc.)
2. Add to the `KNOWN_LINKS` dictionary in `scripts/get_publications.py` (around line 28)
3. Run the update command again

Example addition to KNOWN_LINKS:
```python
KNOWN_LINKS = {
    "Publication Title Here": "https://doi.org/10.1234/example",
    # ... other entries
}
```

### 4. Review Changes

Once the update succeeds, review the changes:

```bash
git diff frontend/src/data/publications.json
```

Note the key metrics:
- Number of new publications
- Citation count changes
- H-index changes
- i10-index changes

### 5. Commit Changes

Commit the updated files following the repository's conventions:

```bash
git add frontend/src/data/publications.json
# Add scripts/get_publications.py if KNOWN_LINKS was updated
git add scripts/get_publications.py

git commit -m "[Month] [Year] Publications update

Updated publications page with latest data from Google Scholar:
- [X] new publications added
- Citation count: [old] → [new]
- H-index: [old] → [new]
- Publications: [old] → [new]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 6. Create Pull Request

Push and create a PR with a detailed summary:

```bash
git push -u origin [branch-name]

gh pr create --title "[Month] [Year] Publications update" --body "
## Summary
- Updated publications page with latest data from Google Scholar
- Added [X] new publications
- Updated citation metrics

## Changes
- Citation count: [old] → [new]
- H-index: [old] → [new]
- Total publications: [old] → [new]

## New Publications
[List new publications]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
"
```

## Files Modified

- `frontend/src/data/publications.json` - Main publications data
- `scripts/metadata.json` - Citation metadata (cached, not typically committed)
- `scripts/scholarly_output.json` - Raw publications (cached, not typically committed)
- `scripts/get_publications.py` - Only if KNOWN_LINKS was updated

## Reference Example

See PR #1217 for a reference example of a publications update.

## Troubleshooting

**Missing Links Error**: Search for the publication online and add its URL to KNOWN_LINKS in the script.

**Rate Limiting**: If Google Scholar blocks requests, wait a few minutes and retry.

**Duplicate Publications**: The script automatically handles duplicates by merging metadata.

## Notes

- Updates are typically done monthly or quarterly
- All publications must have valid links before the update completes
- The script deduplicates and merges publication metadata automatically
- Publications are organized by year in reverse chronological order
