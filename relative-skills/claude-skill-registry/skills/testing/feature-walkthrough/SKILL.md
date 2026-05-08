---
name: feature-walkthrough
description: Generate polished walkthrough videos from Playwright test suites. Runs thematically connected tests with video recording, creates title cards, slows footage for readability, and concatenates into a final demo video.
---

# Feature Walkthrough Video Generation

Generate polished demo videos from Playwright test suites. Perfect for showcasing features, onboarding flows, or creating documentation videos.

## Prerequisites

Required tools:
- **Playwright** - Test runner with video recording
- **ffmpeg** - Video processing and concatenation
- **ImageMagick** - Title card generation

```bash
# Verify prerequisites
which ffmpeg && which convert && npx playwright --version
```

## Working Directory

All artifacts stored in `/tmp/walkthrough/{session-id}/`:

```
/tmp/walkthrough/{session-id}/
  config.json                    # Session configuration
  playwright-video.config.ts     # Generated Playwright config
  recordings/                    # Raw Playwright video output
  build/                         # Intermediate files (title cards, slowed clips)
  {output-name}.mp4              # Final video (copied to user's output dir)
```

This location preserves context between sessions and avoids accidental commits.

## Playwright Video Config

Enable recording with sequential execution:

```typescript
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  fullyParallel: false,  // Sequential for predictable ordering
  retries: 0,            // No retries - clean recordings
  workers: 1,            // Single worker for consistent capture
  reporter: [['list']],
  use: {
    video: 'on',         // Always record
    trace: 'off',        // Reduce overhead
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
  outputDir: '/tmp/walkthrough/{session-id}/recordings/',
  timeout: 120 * 1000,   // Generous timeout for recording
})
```

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `slowdown_factor` | 10 | Multiply video duration (tests run too fast to watch) |
| `title_duration` | 3 | Seconds per title card |
| `bg_color` | `#1e293b` | Title card background (dark slate) |
| `title_color` | `white` | Main title text color |
| `subtitle_color` | `#94a3b8` | Subtitle text color (muted) |
| `video_quality` | 23 | CRF value (18-28, lower = better) |

## ffmpeg Reference

**Get video dimensions:**
```bash
ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 video.webm
```

**WebM to MP4:**
```bash
ffmpeg -i video.webm -c:v libx264 -c:a aac -y video.mp4 2>/dev/null
```

**Title card image to video (3 seconds):**
```bash
ffmpeg -loop 1 -i title.png -c:v libx264 -t 3 -pix_fmt yuv420p -r 30 title.mp4 -y 2>/dev/null
```

**Slow down video (10x):**
```bash
ffmpeg -i input.mp4 -filter:v "setpts=10*PTS" -r 30 slowed.mp4 -y 2>/dev/null
```

**Concatenate clips:**
```bash
# Create concat_list.txt:
# file 'title_main.mp4'
# file 'title_01.mp4'
# file 'slow_01.mp4'
# ...

ffmpeg -f concat -safe 0 -i concat_list.txt -c:v libx264 -preset medium -crf 23 output.mp4 -y
```

## ImageMagick Title Cards

**Main title card:**
```bash
convert -size {WIDTH}x{HEIGHT} xc:'#1e293b' \
  -font DejaVu-Sans-Bold -pointsize 48 -fill white -gravity center \
  -annotate +0-20 "{MAIN_TITLE}" \
  -font DejaVu-Sans -pointsize 20 -fill '#94a3b8' \
  -annotate +0+40 "{SUBTITLE}" \
  title_main.png
```

**Section title card:**
```bash
convert -size {WIDTH}x{HEIGHT} xc:'#1e293b' \
  -font DejaVu-Sans-Bold -pointsize 36 -fill white -gravity center \
  -annotate +0-30 "{SECTION_TITLE}" \
  -font DejaVu-Sans -pointsize 20 -fill '#94a3b8' \
  -annotate +0+30 "{SECTION_SUBTITLE}" \
  title_01.png
```

## Test Selection

**By spec file:**
```bash
npx playwright test tests/integration/onboarding.spec.ts --config=...
```

**By grep pattern:**
```bash
npx playwright test --grep "checkout" --config=...
```

**List available tests first:**
```bash
npx playwright test --list --grep "{pattern}"
```

## Title Generation

Auto-generate from test names:
- `should complete checkout flow` -> "Complete Checkout Flow"
- `displays validation errors on empty form` -> "Form Validation Errors"

User can override with custom titles per test.

## Error Handling

**Test failures:** Still process the video - shows what happened. Report which tests failed.

**Missing videos:** Skip tests without recordings. Continue with available clips.

**Font issues:** Fall back to default fonts. Warn about substitution.

## Quality Checklist

- [ ] All selected tests ran
- [ ] All video files converted successfully
- [ ] Title cards match video dimensions
- [ ] Final video plays without errors
- [ ] Output copied to user's specified directory
