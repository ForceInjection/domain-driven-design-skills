---
name: apodc
description: Download NASA's Astronomy Picture of the Day (user)
user_invocable: true
---

# APOD - Astronomy Picture of the Day Downloader

## Overview
This skill downloads the latest Astronomy Picture of the Day (APOD) from NASA's website and saves it to your Desktop along with metadata.

## Instructions

When the user requests to download APOD or get today's astronomy picture:

1. Run the download script:
   ```bash
   python3 ${CLAUDE_PLUGIN_ROOT}/skills/apod/download_apod.py
   ```

2. The script will:
   - Fetch the latest APOD from https://apod.nasa.gov/apod/astropix.html
   - Download the high-resolution image
   - Save it to `~/Desktop/APOD/APOD_YYYY-MM-DD.{ext}`
   - Create a metadata file `~/Desktop/APOD/APOD_YYYY-MM-DD.txt` with title, description, and date

3. Report the result to the user, including:
   - Success/failure status
   - File paths where the image and metadata were saved
   - Any errors encountered

## Requirements

The following Python packages must be installed:
```bash
pip install requests beautifulsoup4
```

## Special Cases

- **Videos**: If APOD is a video (YouTube embed), the script will notify the user and skip the download
- **Network errors**: Clear error messages will be displayed if the website is unreachable
- **Existing files**: If today's APOD has already been downloaded, it will be overwritten

## Examples

**User request**: "Download today's APOD"
**Action**: Run the script and report that the image was saved to ~/Desktop/APOD/APOD_2025-12-19.png

**User request**: "Get the astronomy picture of the day"
**Action**: Run the script and confirm the download with file locations

**User request**: "Fetch NASA's picture of the day"
**Action**: Run the script and show the image title and save location
