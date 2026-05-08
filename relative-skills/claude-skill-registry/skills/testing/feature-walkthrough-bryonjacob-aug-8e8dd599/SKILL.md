---
name: feature-walkthrough
description: Generate polished walkthrough videos from Playwright test suites. Runs thematically connected tests with video recording, creates title cards, slows footage for readability, and concatenates into a final demo video.
---

# Feature Walkthrough Video Generation

Generate polished demo videos from Playwright test suites. Perfect for showcasing features, onboarding flows, or creating documentation videos.

## Prerequisites

Required tools (verify before starting):
- **Playwright** - Already configured in the project
- **ffmpeg** - Video processing
- **ImageMagick** - Title card generation

```bash
# Verify prerequisites
which ffmpeg && which convert
```

## Working Directory

All intermediate files are stored in `/tmp/walkthrough/{session-id}/` to:
- Preserve context between Claude sessions
- Avoid accidentally checking artifacts into source control
- Allow inspection of intermediate files for debugging

```
/tmp/walkthrough/{session-id}/
  config.json           # Session configuration
  playwright-video.config.ts  # Generated Playwright config
  recordings/           # Raw Playwright video output
  build/               # Intermediate processing files
    *.png              # Title card images
    *.mp4              # Title card videos + slowed clips
    concat_list.txt    # ffmpeg concat manifest
  {output-name}.mp4    # Final video (copied to user's output dir)
```

## Workflow Phases

### Phase 1: Discovery & Configuration

1. **Identify test suite**
   - Ask user which tests to include (spec file, glob pattern, or specific tests)
   - Run `npx playwright test --list` to enumerate available tests
   - Confirm test selection with user

2. **Gather configuration**
   - Output directory (required - where final video goes)
   - Output filename (default: derived from feature name)
   - Slowdown factor (default: 10x - tests run fast, demos need to be watchable)
   - Title card duration (default: 3 seconds)
   - Main title and subtitle for intro card
   - Per-test titles/subtitles (or auto-generate from test names)

3. **Create session**
   - Generate session-id slug from feature description
   - Create `/tmp/walkthrough/{session-id}/` directory structure
   - Write `config.json` with all settings

### Phase 2: Test Execution with Video Recording

1. **Generate Playwright config**

   Create a temporary config that enables video recording:

   ```typescript
   import { defineConfig, devices } from '@playwright/test'

   export default defineConfig({
     // Inherit from project's existing config where possible
     fullyParallel: false,  // Sequential for predictable ordering
     retries: 0,            // No retries - we want clean recordings
     workers: 1,            // Single worker for consistent capture
     reporter: [['list']],
     use: {
       video: 'on',         // Always record (not just on failure)
       trace: 'off',        // Reduce overhead
     },
     projects: [
       {
         name: 'chromium',
         use: { ...devices['Desktop Chrome'] },
       },
     ],
     outputDir: '/tmp/walkthrough/{session-id}/recordings/',
     timeout: 120 * 1000,   // Generous timeout for recording
   })
   ```

2. **Run selected tests**
   ```bash
   npx playwright test {test-pattern} --config=/tmp/walkthrough/{session-id}/playwright-video.config.ts
   ```

3. **Verify recordings exist**
   - Check each test directory for `video.webm`
   - Report any missing recordings
   - Map test names to video files for ordering

### Phase 3: Video Processing

1. **Detect video dimensions**
   ```bash
   ffprobe -v error -select_streams v:0 -show_entries stream=width,height \
     -of csv=p=0 {first-video}.webm
   ```
   Store dimensions for title card generation.

2. **Convert WebM to MP4**
   ```bash
   for webm in recordings/**/video.webm; do
     mp4="${webm%.webm}.mp4"
     ffmpeg -i "$webm" -c:v libx264 -c:a aac -y "$mp4" 2>/dev/null
   done
   ```

3. **Create title cards with ImageMagick**

   Main intro title (larger text):
   ```bash
   convert -size {WIDTH}x{HEIGHT} xc:'#1e293b' \
     -font DejaVu-Sans-Bold -pointsize 48 -fill white -gravity center \
     -annotate +0-20 "{MAIN_TITLE}" \
     -font DejaVu-Sans -pointsize 20 -fill '#94a3b8' \
     -annotate +0+40 "{SUBTITLE}" \
     build/title_main.png
   ```

   Section titles:
   ```bash
   convert -size {WIDTH}x{HEIGHT} xc:'#1e293b' \
     -font DejaVu-Sans-Bold -pointsize 36 -fill white -gravity center \
     -annotate +0-30 "{SECTION_TITLE}" \
     -font DejaVu-Sans -pointsize 20 -fill '#94a3b8' \
     -annotate +0+30 "{SECTION_SUBTITLE}" \
     build/title_{NN}.png
   ```

4. **Convert title cards to video clips**
   ```bash
   ffmpeg -loop 1 -i build/title_{NN}.png \
     -c:v libx264 -t {TITLE_DURATION} -pix_fmt yuv420p -r 30 \
     build/title_{NN}.mp4 -y 2>/dev/null
   ```

5. **Slow down test recordings**
   ```bash
   ffmpeg -i recordings/{test}/video.mp4 \
     -filter:v "setpts={SLOWDOWN_FACTOR}*PTS" -r 30 \
     build/slow_{NN}.mp4 -y 2>/dev/null
   ```

### Phase 4: Concatenation

1. **Create concat manifest**
   ```
   file 'title_main.mp4'
   file 'title_01.mp4'
   file 'slow_01.mp4'
   file 'title_02.mp4'
   file 'slow_02.mp4'
   ...
   ```

2. **Concatenate with ffmpeg**
   ```bash
   cd build && ffmpeg -f concat -safe 0 -i concat_list.txt \
     -c:v libx264 -preset medium -crf 23 \
     "../{OUTPUT_NAME}.mp4" -y
   ```

3. **Copy to output directory**
   ```bash
   cp /tmp/walkthrough/{session-id}/{OUTPUT_NAME}.mp4 {USER_OUTPUT_DIR}/
   ```

### Phase 5: Report & Cleanup

1. **Report results**
   ```
   Feature Walkthrough Complete

   Output: {USER_OUTPUT_DIR}/{OUTPUT_NAME}.mp4
   Duration: {DURATION} seconds
   Tests included: {COUNT}

   Working files preserved at: /tmp/walkthrough/{session-id}/
   (Safe to delete when satisfied with output)
   ```

2. **Preserve working directory**
   - Keep `/tmp/walkthrough/{session-id}/` for debugging
   - User can manually delete when satisfied

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `slowdown_factor` | 10 | Multiply video duration (tests run too fast to watch) |
| `title_duration` | 3 | Seconds to display each title card |
| `bg_color` | `#1e293b` | Title card background (dark slate) |
| `title_color` | `white` | Main title text color |
| `subtitle_color` | `#94a3b8` | Subtitle text color (muted) |
| `title_font` | `DejaVu-Sans-Bold` | Font for titles |
| `subtitle_font` | `DejaVu-Sans` | Font for subtitles |
| `video_quality` | 23 | CRF value (18-28, lower = better quality) |

## Test Selection Strategies

**By spec file:**
```bash
/feature-walkthrough tests/integration/onboarding.spec.ts
```

**By grep pattern:**
```bash
/feature-walkthrough --grep "checkout"
```

**By specific test names:**
```bash
/feature-walkthrough "login flow" "signup flow" "password reset"
```

## Title Generation

**Auto-generate from test names:**
- Test: `should complete checkout flow` → Title: "Complete Checkout Flow"
- Test: `displays validation errors on empty form` → Title: "Form Validation Errors"

**Manual override:**
User can provide custom titles per test for clearer demos.

## Error Handling

### Test Failures
- If a test fails, still process its video (shows what happened)
- Report which tests failed in final summary
- User decides whether to include failed test videos

### Missing Videos
- Skip tests that didn't produce video files
- Report missing recordings
- Continue with available videos

### Font Issues
- Fall back to default fonts if specified fonts unavailable
- Warn user about font substitution

## Quality Checks

Before marking complete:
- [ ] All selected tests ran
- [ ] All video files converted successfully
- [ ] Title cards match video dimensions
- [ ] Final video plays without errors
- [ ] Output copied to user's specified directory
- [ ] Duration reported accurately

## Example Session

```
User: /feature-walkthrough for the new onboarding feature, output to ~/Videos

Claude:
1. Found tests/integration/onboarding.spec.ts with 5 tests
2. Tests to record:
   - should show phone entry form
   - should validate phone number
   - should send OTP
   - should verify identity
   - should show approval screen

   Proceed with these tests?

User: yes, use "Onboarding Flow Demo" as the main title

Claude:
[Runs tests with video recording]
[Processes videos]

Feature Walkthrough Complete

Output: ~/Videos/onboarding-flow-demo.mp4
Duration: 4 minutes 32 seconds
Tests included: 5

Working files preserved at: /tmp/walkthrough/onboarding-flow-demo/
```

## Useful ffmpeg Commands

```bash
# Get video info
ffprobe -v error -show_format -show_streams video.mp4

# Get duration
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 video.mp4

# Get dimensions
ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 video.mp4

# Extract single frame
ffmpeg -i video.mp4 -ss 00:00:05 -frames:v 1 frame.png

# Add fade in/out
ffmpeg -i input.mp4 -vf "fade=t=in:st=0:d=1,fade=t=out:st=4:d=1" output.mp4
```
