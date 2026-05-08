---
name: google-docs-sheets
description: Export Google Docs and Google Sheets (spreadsheets) to Markdown files
  or stdout. Use when asked to fetch, download, or ingest Google Docs/Sheets content
  for summarization, analysis, or context loading. Tries gcloud ADC first with browser
  OAuth fallback.
---
# Google Docs & Sheets

Export Google Docs and Google Sheets content as Markdown. Uses Google APIs with read-only scopes, prefers gcloud ADC, and falls back to browser OAuth when needed.

## Quick Start

### Auth (preferred: gcloud ADC, run by default)
```bash
gcloud auth application-default login --scopes=https://www.googleapis.com/auth/drive.readonly,https://www.googleapis.com/auth/spreadsheets.readonly
```

## Google Docs

```bash
# Export to stdout
uv run --directory ${OPENCODE_DIR}/skill/google-docs-sheets scripts/docs.py export <DOC_ID_OR_URL> --stdout

# Export to files (default ./exports when --stdout is not set)
uv run --directory ${OPENCODE_DIR}/skill/google-docs-sheets scripts/docs.py export <DOC_ID_OR_URL>

# Write to a specific directory
uv run --directory ${OPENCODE_DIR}/skill/google-docs-sheets scripts/docs.py export <DOC_ID_OR_URL> --output-dir ./exports

# Write and print
uv run --directory ${OPENCODE_DIR}/skill/google-docs-sheets scripts/docs.py export <DOC_ID_OR_URL> --output-dir ./exports --stdout
```

Notes:
- Export uses HTML -> Markdown conversion and strips images.
- Output filename defaults to the Doc title (sanitized) with `.md` extension.

## Google Sheets

```bash
# Export all tabs to stdout
uv run --directory ${OPENCODE_DIR}/skill/google-docs-sheets scripts/sheets.py export <SHEET_ID_OR_URL> --stdout

# Export all tabs to files (default ./exports when --stdout is not set)
uv run --directory ${OPENCODE_DIR}/skill/google-docs-sheets scripts/sheets.py export <SHEET_ID_OR_URL>

# Export specific tabs
uv run --directory ${OPENCODE_DIR}/skill/google-docs-sheets scripts/sheets.py export <SHEET_ID_OR_URL> --tab "Summary" --tab "Data"

# Header control
uv run --directory ${OPENCODE_DIR}/skill/google-docs-sheets scripts/sheets.py export <SHEET_ID_OR_URL> --header-row 2
uv run --directory ${OPENCODE_DIR}/skill/google-docs-sheets scripts/sheets.py export <SHEET_ID_OR_URL> --no-header
```

Notes:
- Each tab is exported to its own Markdown table.
- Output filenames are `Spreadsheet Title - Tab Title.md`.
- If the URL includes `gid=...`, that tab is selected automatically (unless `--tab` is used).
