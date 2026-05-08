---
name: youtube
description: Work with video and audio links. Activate when user shares a YouTube link, video URL, or any media link - regardless of the task (download, info, convert, extract, list, or explore). Uses yt-dlp for all operations.
allowed-tools: Bash, Read, Task, Glob, Grep
---

# yt-dlp Video Downloader Skill

Expert at using `yt-dlp` CLI for downloading and processing videos from YouTube and other platforms.

## Availability

Before any operation, verify yt-dlp is installed: `yt-dlp --version`

If not installed, just quit, user will handle the installation manually.

## Documentation Access

The full `yt-dlp` documentation is extensive. When you need to look up specific options or features:

1. Fetch the docs:
   ```bash
   curl -s https://raw.githubusercontent.com/yt-dlp/yt-dlp/refs/heads/master/README.md -o /tmp/yt-dlp-docs.md
   ```

2. Use a **subagent** to search the docs (preserves context window):
   ```
   Task tool with subagent_type="general-purpose":
   "Read /tmp/yt-dlp-docs.md and find information about [SPECIFIC TOPIC].
   Return only the relevant options and examples."
   ```

## Workflow

1. **Simple requests** → Execute directly with known options
2. **Complex/unfamiliar requests** → Fetch docs → Subagent search → Execute

## Guidelines

1. **Check installation first** - verify yt-dlp is available
2. **Delegate doc searches** - use subagent for extensive docs
3. **Show the command** - always display the command being run
4. **Handle errors** - explain common issues (geo-restrictions, age-gates, etc.)
