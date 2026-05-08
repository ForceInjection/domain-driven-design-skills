---
name: voiceover
description: Generates audio narration from a text file using Chatterbox TTS. Use when the user wants to generate voiceover/audio from ANY text file.
license: Apache-2.0
compatibility: Requires Python with torch, scipy, numpy, pyloudnorm, and chatterbox installed. GPU recommended.
metadata:
  author: chatterbox
  version: "4.0"
---

# Voiceover

Generates voiceover audio from a text file using Chatterbox TTS with voice cloning.

## When to use this skill

**USE THIS SKILL** when the user wants to:
- Generate a voiceover/narration from ANY text file
- Create audio content with voice cloning
- Says "voiceover", "generate audio", "create narration"
- Has already created a script (via `create-script` skill) and wants audio

**IMPORTANT**: If the user provides raw content AND says "voiceover", use the `create-script` skill FIRST to create the text file, THEN use this skill.

## CLI Usage

The script accepts command-line arguments:

```
uv run scripts/voiceover_script.py -i <input.txt> -o <output.wav> [-v <voice.wav>]
```

| Argument | Default | Description |
|----------|---------|-------------|
| `-i, --input` | `article.txt` | Input text file |
| `-o, --output` | `<input>.wav` | Output WAV file (auto-generated if omitted) |
| `-v, --voice` | `clone.wav` | Voice reference for cloning |

## Instructions

### Step 1: Identify the input file

Determine which text file to convert:
- Check what file was just created by `create-script` skill
- Or use the file the user specifies
- Verify the file exists before proceeding

### Step 2: Determine output filename

- **Match the input filename's slug exactly** (e.g., if input is `entry-009.txt`, output should be `entry-009.wav`)
- If a custom output name is requested, use it

### Step 3: Launch in background

Use `nohup` with `uv run` and CLI arguments to run detached:

```bash
nohup uv run scripts/voiceover_script.py -i <input_file> -o <output_file> > voiceover.log 2>&1 &
```

**Note**: If you omit `-o`, the output will auto-generate as `<input_name>.wav`

### Step 4: Verify it started

Wait briefly and check the log:

```bash
sleep 2 && cat voiceover.log
```

Expected output:
```
Using device: cuda
Loading model...
Fetching 10 files: 100%|██████████| 10/10 [00:00<?, ?it/s]
```

### Step 5: Inform the user

Tell the user:
1. The voiceover generation has been launched in the background
2. **Input file**: [the file being converted]
3. **Output file**: [the wav file that will be created]
4. **Estimated time**: ~1-2 minutes per 100 words (GPU), longer on CPU
5. Monitor progress with: `tail -f voiceover.log`

## Examples

### Example 1: Custom input file
```bash
nohup uv run scripts/voiceover_script.py -i opencode_skills_video.txt > voiceover.log 2>&1 &
```
Output: `opencode_skills_video.wav` (auto-generated)

### Example 2: Custom input and output
```bash
nohup uv run scripts/voiceover_script.py -i my_script.txt -o final_audio.wav > voiceover.log 2>&1 &
```

### Example 3: Different voice reference
```bash
nohup uv run scripts/voiceover_script.py -i script.txt -v different_voice.wav > voiceover.log 2>&1 &
```

## Output

The script produces a WAV file with:
- 24kHz sample rate
- Normalized to -19 LUFS
- 0.5 second gaps between chunks

## File Requirements

Before running, ensure these files exist in the project directory:
- Your input text file
- Voice reference file (default: `clone.wav`)
