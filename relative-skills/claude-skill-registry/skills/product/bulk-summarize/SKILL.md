---
name: bulk-summarize
description: This skill should be used when the user asks to "summarize videos", "summarize podcasts", "research a topic using media", "bulk summarize content", "scan YouTube channels", "scan podcast feeds", "create podcast notes", "digest conference talks", "summarize Apple Podcasts", or mentions video/podcast research, media summarization, or bulk content processing.
version: 0.1.0
---

# Bulk Media Summarizer

A tool for scanning and summarizing media content across YouTube, podcast RSS feeds, SoundCloud, and other sources supported by yt-dlp. Ideal for podcast research, conference talk digests, tutorial compilations, and topic research.

## Prerequisites

Ensure these dependencies are installed:

- **bun**: `curl -fsSL https://bun.sh/install | bash`
- **yt-dlp**: `brew install yt-dlp` or `pip install yt-dlp`
- **summarize**: See https://summarize.sh ([GitHub](https://github.com/steipete/summarize))

## Supported Platforms

| Platform | URL Pattern | Notes |
|----------|-------------|-------|
| YouTube | `youtube.com/@channel`, playlist URLs | Has built-in transcripts, fastest |
| RSS Feeds | Direct feed URLs | Works with any podcast RSS feed |
| SoundCloud | `soundcloud.com/user/...` | Audio-only, auto-transcribed |
| Vimeo | `vimeo.com/...` | Video |
| Twitch | `twitch.tv/videos/...` | VODs and clips |

### Apple Podcasts

Apple Podcasts URLs don't work directly with yt-dlp. Extract the RSS feed URL first:

1. Use WebFetch on the Apple Podcasts URL
2. Find the RSS feed URL in the page (usually in metadata)
3. Use the RSS feed URL in the config

Example:
- Apple URL: `https://podcasts.apple.com/us/podcast/huberman-lab/id1545953110`
- RSS Feed: `https://feeds.megaphone.fm/hubermanlab` (use this in config)

## Core Commands

```bash
bun run /path/to/bulk-summarize.ts [command]
```

| Command | Description |
|---------|-------------|
| `init [name]` | Create starter config file |
| `scan` | Find content matching keywords |
| `summarize` | Process pending items |
| `combine` | Merge all summaries into one document |
| `status` | Check progress for all sources |
| `list` | Show configured sources |
| `reset [source]` | Clear checkpoint data |

### Options

| Option | Description |
|--------|-------------|
| `-c, --config <file>` | Config file (default: bulk-summarize.json) |
| `-s, --source <id>` | Target specific source |
| `-n, --limit <n>` | Limit items to process |
| `-p, --parallel <n>` | Concurrent summarizations (default: 1) |
| `-d, --delay <ms>` | Delay between items (default: 1000) |

## Workflow

### Quick Start

```bash
# 1. Create config
bun run bulk-summarize.ts init my-research.json

# 2. Edit config to add sources

# 3. Scan and process
bun run bulk-summarize.ts -c my-research.json scan
bun run bulk-summarize.ts -c my-research.json summarize
bun run bulk-summarize.ts -c my-research.json combine --output research.md
```

### YouTube Channels

```bash
# Search for channels
yt-dlp "ytsearch10:TOPIC podcast" --flat-playlist \
  --print "%(channel_url)s %(channel)s" 2>/dev/null | sort -u

# Verify channel
yt-dlp --flat-playlist --print "%(playlist_uploader)s" \
  --playlist-end 1 "https://www.youtube.com/@ChannelName/videos"
```

### Podcast RSS Feeds

```bash
# Test RSS feed
yt-dlp --flat-playlist --print "%(title)s" \
  "https://feeds.megaphone.fm/hubermanlab" --playlist-end 3
```

To get RSS feed from Apple Podcasts: use WebFetch on the Apple Podcasts URL and look for the feed URL in the response (typically in page metadata or as a direct link).

## Config Structure

```json
{
  "name": "Project Name",
  "keywords": ["keyword1", "keyword2"],
  "sources": [
    {
      "id": "source-id",
      "name": "Display Name",
      "url": "https://...",
      "type": "channel",
      "enabled": true
    }
  ],
  "settings": {
    "maxVideosPerSource": 50,
    "summaryLength": "xl",
    "summaryPrompt": "Your prompt.\n\nTitle: {title}",
    "outputDir": "summaries"
  }
}
```

### Summary Lengths

| Length | Use Case |
|--------|----------|
| `short` | Quick overview (<15 min content) |
| `medium` | Standard summary |
| `long` | Detailed notes |
| `xl` | Comprehensive coverage |
| `xxl` | Maximum detail (2+ hour content) |

## Audio vs Video Processing

### YouTube (has transcripts)
- Fast processing using existing captions
- Highest accuracy for transcribed content

### Audio Podcasts (RSS, SoundCloud)
- Requires transcription via Whisper
- `summarize` handles this automatically
- Slightly slower due to transcription step
- Quality depends on audio clarity

## Output Structure

```
summaries/
  source-id/
    .checkpoint.json    # Progress tracking
    episode1.md         # Individual summaries
    episode2.md
```

## Troubleshooting

### Source Not Found
```bash
# Test URL directly
yt-dlp --flat-playlist --print "%(title)s" "URL" --playlist-end 3
```

### Transcription Fails
- Audio quality too low
- Non-English content (specify language in summarize)
- Try reducing parallel processing

## Additional Resources

### Reference Files

- **`references/config-templates.md`** - Ready-to-use configs for common use cases
- **`references/prompt-patterns.md`** - Effective prompts by content type
- **`references/platform-guide.md`** - Platform-specific URL formats and tips

### Example Files

- **`examples/podcast-research.json`** - Multi-source podcast research
- **`examples/conference-talks.json`** - Conference playlist digest
- **`examples/multi-platform.json`** - Cross-platform research setup
