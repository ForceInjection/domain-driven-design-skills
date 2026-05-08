---
name: cross-repo-sync
description: Sync files between BobTheSkull5 and BobFast5 repositories, especially audio files and shared components. Use when syncing audio, copying static files, or managing dual-repo workflow.
allowed-tools: Read, Bash, Glob
---

# Cross-Repository Sync

Handles syncing files between BobTheSkull5 and BobFast5 repositories, particularly audio files and shared components.

## When to Use

- Syncing audio files between repos
- Copying static assets (greetings, startup audio, testing audio)
- Updating shared components
- Managing the dual-repo workflow
- Deploying to Raspberry Pi

## Repository Structure

**BobTheSkull5** (Main repo):
- Full system with MQTT, distributed architecture
- Web configuration interface
- All components and services

**BobFast5** (Legacy/Testing repo):
- Simpler architecture
- Used for quick audio testing
- Shares audio files with BobTheSkull5

## Common Sync Paths

### Audio Files

**Greetings:**
```
From: BobTheSkull5/audio/static/greetings/
To:   BobFast5/audio/static/greetings/
```

**Startup:**
```
From: BobTheSkull5/audio/static/startup/
To:   BobFast5/audio/static/startup/
```

**Testing:**
```
From: BobTheSkull5/audio/static/testing/
To:   BobFast5/audio/static/testing/
```

## Sync Commands

### Windows (cmd)

**Copy single file:**
```batch
copy "BobTheSkull5\audio\static\testing\filename.mp3" "BobFast5\audio\static\testing\"
```

**Copy all files in directory:**
```batch
xcopy "BobTheSkull5\audio\static\greetings\*.mp3" "BobFast5\audio\static\greetings\" /Y
```

**Sync entire audio tree:**
```batch
xcopy "BobTheSkull5\audio\static" "BobFast5\audio\static" /E /Y
```

### Git Bash / WSL

**Copy single file:**
```bash
cp "BobTheSkull5/audio/static/testing/filename.mp3" "BobFast5/audio/static/testing/"
```

**Copy all MP3s:**
```bash
cp BobTheSkull5/audio/static/greetings/*.mp3 BobFast5/audio/static/greetings/
```

**Sync with rsync:**
```bash
rsync -av BobTheSkull5/audio/static/ BobFast5/audio/static/
```

## Safe Sync Workflow

1. **Check current directory:**
   ```bash
   pwd  # Should be in parent directory containing both repos
   ls   # Should see both BobTheSkull5 and BobFast5
   ```

2. **Verify source files exist:**
   ```bash
   ls BobTheSkull5/audio/static/testing/*.mp3
   ```

3. **Verify destination directory exists:**
   ```bash
   ls BobFast5/audio/static/testing/
   ```

4. **Perform sync with confirmation:**
   ```batch
   # Windows - shows files before copying
   dir "BobTheSkull5\audio\static\testing\*.mp3"
   xcopy "BobTheSkull5\audio\static\testing\*.mp3" "BobFast5\audio\static\testing\" /Y
   ```

5. **Verify sync succeeded:**
   ```bash
   ls BobFast5/audio/static/testing/
   ```

## Audio Generation Workflow

When generating new audio files:

1. **Generate in BobTheSkull5:**
   ```bash
   cd BobTheSkull5
   python generate_greeting_audio.py
   # or
   python generate_startup_audio.py
   ```

2. **Verify generated files:**
   ```bash
   ls audio/static/greetings/  # Check new files exist
   ```

3. **Sync to BobFast5:**
   ```bash
   cd ..  # Go to parent directory
   cp BobTheSkull5/audio/static/greetings/*.mp3 BobFast5/audio/static/greetings/
   ```

4. **Test in BobFast5:**
   ```bash
   cd BobFast5
   # Run tests or play audio
   ```

## Deploy to Pi Workflow

The [deploy_to_pi.bat](file:///c:/Users/Knarl/Code/BobTheSkull5/deploy_to_pi.bat) script handles syncing to Raspberry Pi:

```batch
# From BobTheSkull5 directory
deploy_to_pi.bat
```

This copies:
- All Python files
- Configuration files (requirements, .env.bob)
- Setup scripts
- Component directories (events, wake_word, stt, llm, tts, state_machine, vision, hardware, web)

## What NOT to Sync

**Never copy these:**
- `.git/` directories
- Virtual environments (`venv/`, `.venv/`)
- `__pycache__/` directories
- `.pyc` files
- Local configuration (`.env`, `config.yaml`)
- Database files (`*.db`, `*.sqlite`)
- Log files (`logs/`)
- Face data (`facedata/`)
- Embeddings (`EmbeddingsDB/`, `LongTermDB/`)

## Selective Sync Pattern

**Only sync specific audio categories:**

```batch
REM Greetings only
xcopy "BobTheSkull5\audio\static\greetings\*.mp3" "BobFast5\audio\static\greetings\" /Y

REM Testing files only
xcopy "BobTheSkull5\audio\static\testing\*.mp3" "BobFast5\audio\static\testing\" /Y

REM Startup sounds only
xcopy "BobTheSkull5\audio\static\startup\*.mp3" "BobFast5\audio\static\startup\" /Y
```

## Bi-directional Sync Caution

**Usually sync is one-way:** BobTheSkull5 → BobFast5

**Reverse sync** (BobFast5 → BobTheSkull5) is rare and should be done carefully:
- Only for audio testing results
- Only for experimental audio files
- Never for code changes (different architectures)

## Common Sync Scenarios

### After generating new greetings:
```bash
cd /c/Users/Knarl/Code
cp BobTheSkull5/audio/static/greetings/*.mp3 BobFast5/audio/static/greetings/
```

### After generating test audio:
```bash
cd /c/Users/Knarl/Code
cp BobTheSkull5/audio/static/testing/*.mp3 BobFast5/audio/static/testing/
```

### Before deploying to Pi:
```bash
cd /c/Users/Knarl/Code/BobTheSkull5
cmd /c deploy_to_pi.bat
```

### Full audio sync:
```bash
cd /c/Users/Knarl/Code
rsync -av --include='*.mp3' --include='*.wav' --include='*/' --exclude='*' \
  BobTheSkull5/audio/static/ BobFast5/audio/static/
```

## Automation Script Example

```batch
@echo off
REM sync_audio.bat - Sync all audio files
REM Usage: sync_audio.bat

echo Syncing audio files from BobTheSkull5 to BobFast5...

echo [1/3] Syncing greetings...
xcopy "%CD%\BobTheSkull5\audio\static\greetings\*.mp3" "%CD%\BobFast5\audio\static\greetings\" /Y /Q

echo [2/3] Syncing startup sounds...
xcopy "%CD%\BobTheSkull5\audio\static\startup\*.mp3" "%CD%\BobFast5\audio\static\startup\" /Y /Q

echo [3/3] Syncing testing audio...
xcopy "%CD%\BobTheSkull5\audio\static\testing\*.mp3" "%CD%\BobFast5\audio\static\testing\" /Y /Q

echo.
echo Sync complete!
pause
```

## Verification Commands

**Check file counts match:**
```bash
# Linux/Git Bash
diff <(ls BobTheSkull5/audio/static/greetings/) <(ls BobFast5/audio/static/greetings/)

# Windows PowerShell
Compare-Object (Get-ChildItem BobTheSkull5\audio\static\greetings) (Get-ChildItem BobFast5\audio\static\greetings)
```

**Check file sizes match:**
```bash
# Linux/Git Bash
ls -lh BobTheSkull5/audio/static/greetings/*.mp3
ls -lh BobFast5/audio/static/greetings/*.mp3
```

## Troubleshooting

**"File not found" error:**
- Check current working directory with `pwd` or `cd`
- Verify source path exists: `ls BobTheSkull5/audio/static/testing/`
- Use tab completion to verify paths

**"Permission denied" error:**
- Files may be in use (close audio players)
- Check file permissions
- Run command prompt as Administrator (Windows)

**Files don't appear after copy:**
- Check destination directory: `ls BobFast5/audio/static/testing/`
- Verify copy command succeeded (check exit code)
- Try absolute paths instead of relative

**Wrong files copied:**
- Double-check source and destination paths
- Use `/Y` flag to overwrite without prompting
- Test with single file first before bulk copy

## Pro Tips

1. **Always run from parent directory** containing both repos
2. **Use tab completion** to avoid typos in paths
3. **Verify before bulk operations** - test with one file first
4. **Check file counts** after sync to ensure completeness
5. **Use wildcards carefully** - `*.mp3` not `*` to avoid copying unwanted files
6. **Keep audio in sync** - sync immediately after generation
7. **Document custom sync scripts** if you create automation
