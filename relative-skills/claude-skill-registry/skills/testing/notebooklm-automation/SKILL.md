---
name: notebooklm-automation
description: Automate creation of multiple audio overviews in Google NotebookLM using Playwright. Use when the user needs to generate multiple audio podcasts from web sources with different prompts or focus areas, or when batch-creating NotebookLM audio content.
---

# NotebookLM Automation

Automates the creation of multiple audio overviews in Google NotebookLM with different prompts and configurations.

## Overview

This skill uses Playwright to automate NotebookLM's browser interface for:
1. Creating a new notebook
2. Adding website sources
3. Generating multiple audio overviews with custom prompts
4. Downloading all generated audio files

The automation handles the repetitive UI interactions, waiting for generation to complete, and downloading all outputs.

## Workflow

The automation follows these steps:

1. **Prepare input** - Create JSON file with sources and audio overview configurations
2. **Launch automation** - Run the Playwright script
3. **Notebook creation** - Script creates new notebook and adds sources
4. **Audio generation** - Script creates each audio overview with specified prompt and length
5. **Wait for completion** - Script waits ~10 minutes for all audio to generate
6. **Download outputs** - Script downloads all audio files to `/home/claude/`

## Input Format

Create a JSON file with this structure:

```json
{
  "sources": [
    "https://example.com/article1",
    "https://example.com/page2"
  ],
  "audio_overviews": [
    {
      "prompt": "Focus on technical concepts for developers",
      "length": "longer"
    },
    {
      "prompt": "Create executive summary of business impacts",
      "length": "default"
    }
  ]
}
```

### Field Specifications

**sources**: Array of website URLs to use as source material
- Must be publicly accessible URLs
- NotebookLM will crawl and index these pages

**audio_overviews**: Array of audio overview configurations
- **prompt**: Text describing what the AI should focus on in this episode
- **length**: Either `"default"` or `"longer"` (never use `"shorter"`)

See `references/example_input.json` for a complete example.

## Usage

### Basic Usage

```bash
python scripts/generate_audio_overviews.py input.json
```

This runs with visible browser so you can monitor progress and handle Google authentication if needed.

### Headless Mode

```bash
python scripts/generate_audio_overviews.py input.json --headless
```

Run browser in headless mode (requires existing authentication).

### Custom Timeout

```bash
python scripts/generate_audio_overviews.py input.json --timeout 900
```

Set custom timeout for audio generation (in seconds). Default is 600 seconds (10 minutes).

## Prerequisites

### Required Software

Install Playwright and dependencies:

```bash
pip install playwright
playwright install chromium
```

### Google Account Setup

- Must have access to NotebookLM (https://notebooklm.google.com)
- First run will require Google authentication
- Browser state is not persisted between runs

## Output

Audio files are downloaded to `/home/claude/` with NotebookLM's default naming:
- Format: MP3
- Naming: Typically includes date/timestamp

The script reports download success for each file and provides summary at completion.

## Troubleshooting

### Common Issues

**Authentication Required**
- Run without `--headless` flag
- Sign in to Google when prompted
- Consider using persistent browser context for repeated use

**Selectors Not Found**
- NotebookLM's UI may have changed
- See `references/troubleshooting.md` for selector update guidance
- Run without `--headless` to observe actual UI

**Timeout During Generation**
- Audio generation takes ~5-10 minutes per overview
- Increase timeout with `--timeout` flag
- Script will attempt downloads even after timeout

**Sources Not Loading**
- Verify URLs are accessible and public
- Check for NotebookLM error messages in browser
- Some content may be blocked or require authentication

### Getting Help

For selector updates and detailed troubleshooting, read `references/troubleshooting.md`.

## Limitations

- Requires manual Google authentication on first run
- Browser automation may be fragile if NotebookLM's UI changes significantly
- Cannot create more than ~10 audio overviews at once (NotebookLM limitation)
- Sources must be publicly accessible websites
- Generation time increases with number of sources and overview length
