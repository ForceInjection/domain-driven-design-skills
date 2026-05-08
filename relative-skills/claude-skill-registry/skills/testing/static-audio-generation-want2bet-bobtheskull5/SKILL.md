---
name: static-audio-generation
description: Generate and manage static audio files for Bob The Skull using ElevenLabs TTS. Use when creating greetings, startup messages, error responses, or test audio. Handles generation, naming, directory structure, and cross-repo syncing.
allowed-tools: Read, Edit, Bash, Glob
---

# Static Audio Generation Skill

Generate pre-recorded audio files using ElevenLabs TTS for instant playback (no API latency, reduced cost, offline support).

## When to Use This Skill

- **"Generate greeting audio"** - Create greeting responses
- **"Add new startup message"** - System status audio
- **"Create test audio files"** - Testing wake word/STT
- **"Sync audio to BobFast5"** - Cross-repo audio management
- **"Generate static TTS"** - Any pre-recorded phrases

## Quick Reference

### Directory Structure

```
audio/static/
├── greetings/          # Greeting responses ("Yes wizard?", "I'm listening")
│   ├── yes_wizard.mp3
│   ├── im_listening.mp3
│   └── greetings.txt   # Index file
├── startup/            # Startup/shutdown/error messages
│   ├── initializing.mp3
│   ├── startup_complete.mp3
│   └── startup.txt     # Index file
└── testing/            # Test audio for wake word/STT testing
    ├── wake_up_bob.mp3
    ├── hey_bob.mp3
    └── what_time_is_it.mp3
```

### Generation Commands

```bash
# Generate all greetings (from predefined list)
python generate_greeting_audio.py

# Generate all startup/shutdown/error messages
python generate_startup_audio.py

# Generate all static audio (comprehensive)
python generate_static_audio.py
```

### Naming Convention

**Rule**: Lowercase, underscores, descriptive
- "Yes wizard?" → `yes_wizard.mp3`
- "I'm listening" → `im_listening.mp3`
- "Startup complete. Listening for wake words." → `startup_complete_listening_for_wake_words.mp3`

**Normalization function** ([tts/static_audio.py](../../tts/static_audio.py)):
```python
from tts.static_audio import normalize_phrase_to_filename
filename = normalize_phrase_to_filename("Yes wizard?")  # → "yes_wizard"
```

## Generation Workflows

### Workflow 1: Generate Greetings

**Script**: [generate_greeting_audio.py](../../generate_greeting_audio.py)

```python
# 1. Define greetings list (edit script)
GREETINGS = [
    "Yes wizard?",
    "What do you need boss?",
    "I'm listening",
    "Yes?"
]

# 2. Run generation
python generate_greeting_audio.py

# Output:
# audio/static/greetings/yes_wizard.mp3
# audio/static/greetings/what_do_you_need_boss.mp3
# audio/static/greetings/im_listening.mp3
# audio/static/greetings/yes.mp3
# audio/static/greetings/greetings.txt (index)
```

**When to add new greetings**:
- Adding personality variety
- Testing different responses
- Supporting new conversation states

### Workflow 2: Generate Startup Messages

**Script**: [generate_startup_audio.py](../../generate_startup_audio.py)

```python
# 1. Define messages (edit script)
STARTUP_PHRASES = [
    "Initializing",
    "Found eye controller",
    "Startup complete. Listening for wake words.",
]

SHUTDOWN_PHRASES = ["Shutting down"]
ERROR_PHRASES = ["Configuration error"]

# 2. Run generation
python generate_startup_audio.py

# Output: audio/static/startup/*.mp3
```

**When to add startup messages**:
- New component initialization feedback
- Debugging startup sequence
- User experience improvements

### Workflow 3: Generate Test Audio

**Purpose**: Audio files for automated testing (wake word, STT, full pipeline)

**Test audio types**:
1. **Wake word triggers**: "Wake up Bob", "Hey Bob"
2. **Commands**: "What time is it?", "Tell me a joke"
3. **Conversations**: Full conversation test sequences

**Generation options**:

**Option A: Use ElevenLabs (Bob's voice)**
```python
# Add to generate_static_audio.py or create test-specific script
TEST_PHRASES = [
    "Wake up Bob",
    "Hey Bob",
    "What time is it?",
    "Tell me a joke",
    "Can you speak louder?",
    "What is the weather like today?",
    "Goodbye Bob"
]

# Generate to audio/static/testing/
```

**Option B: Record yourself**
```bash
# Record 3 seconds
arecord -d 3 -f S16_LE -r 16000 -c 1 audio/static/testing/wake_up_bob.wav

# Convert to MP3 (optional)
ffmpeg -i wake_up_bob.wav -b:a 32k wake_up_bob.mp3
```

**Option C: Use espeak (quick but robotic)**
```bash
espeak "Wake up Bob" --stdout | \
    sox -t wav - -r 16000 -c 1 -b 16 audio/static/testing/wake_up_bob.wav
```

### Workflow 4: Cross-Repo Sync (BobTheSkull5 → BobFast5)

**When**: After generating new audio files for testing on vision system

**Method 1: Manual copy (Windows)**
```bash
# Copy specific category
copy audio\static\testing\*.mp3 ..\BobFast5\audio\static\testing\

# Or use xcopy for directory sync
xcopy audio\static\testing ..\BobFast5\audio\static\testing\ /Y /S
```

**Method 2: Use cross-repo-sync skill**
```bash
# See cross-repo-sync skill for safe patterns
```

**Method 3: Deploy to Pi (includes audio)**
```bash
# deploy_to_pi.bat doesn't currently copy audio/ directory
# Add manual step or extend deployment script
pscp -pw peacock7 -r audio/static knarl@192.168.1.44:/home/knarl/BobTheSkull5/audio/
```

## ElevenLabs Configuration

### Voice Settings (from BobConfig.py)

```python
ELEVEN_LABS_VOICE_ID = "nPczCjzI2devNBz1zQrb"  # Brian (default Bob voice)
ELEVEN_LABS_MODEL = "eleven_turbo_v2_5"
TTS_STABILITY = 0.71
TTS_SIMILARITY_BOOST = 0.5
TTS_STYLE = 0.0
TTS_USE_SPEAKER_BOOST = True
```

### Voice Selection Guide

**Brian (default)**: Deep, authoritative, sarcastic personality
**Use for**: Greetings, conversation responses, personality-driven content

**Alternative voices** (if needed):
- Calmer voice for error messages
- Different voice for testing/debugging distinction

### Cost Optimization

**Strategy**: Generate once, reuse forever
- Greetings used hundreds of times → synthesize once saves $$$
- Startup messages on every boot → pre-generate
- Test audio → generate once, test infinite times

**Cost per file**: ~$0.18 per 1000 characters (turbo_v2_5)
- Average greeting: ~15 characters = $0.0027 per file
- Generate 10 greetings once = $0.027
- Use 1000 times = **$0.00003 per use** (vs $0.0027 per dynamic TTS)

## Common Use Cases

### Use Case 1: Add New Greeting Variant

```bash
# 1. Edit generate_greeting_audio.py
GREETINGS = [
    "Yes wizard?",
    "What do you need boss?",
    "I'm listening",
    "Yes?",
    "Speak wizard",  # NEW
]

# 2. Generate
python generate_greeting_audio.py

# 3. Verify
ls audio/static/greetings/
# Should see: speak_wizard.mp3

# 4. Update state_machine.py to use new greeting (if needed)
# Edit GREETINGS list in state_machine/state_machine.py

# 5. Test playback
# Use test_audio_output.py or manually play
```

### Use Case 2: Generate Test Suite Audio

```python
# Create generate_test_audio.py
#!/usr/bin/env python3
from pathlib import Path
from dotenv import load_dotenv
from elevenlabs import ElevenLabs, VoiceSettings
from BobConfig import BobConfig
from tts.static_audio import normalize_phrase_to_filename

load_dotenv()
config = BobConfig()
config.load_from_env()

OUTPUT_DIR = Path("audio/static/testing")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

TEST_PHRASES = [
    "Wake up Bob",
    "Hey Bob",
    "What time is it?",
    "Tell me a joke",
    "Can you speak louder?",
    "What is the weather like today?",
    "Goodbye Bob"
]

client = ElevenLabs(api_key=config.ELEVEN_LABS_API_KEY)

for phrase in TEST_PHRASES:
    filename = f"{normalize_phrase_to_filename(phrase)}.mp3"
    filepath = OUTPUT_DIR / filename

    print(f"Generating: {phrase} → {filename}")

    audio_generator = client.text_to_speech.convert(
        voice_id=config.ELEVEN_LABS_VOICE_ID,
        text=phrase,
        model_id=config.ELEVEN_LABS_MODEL,
        voice_settings=VoiceSettings(
            stability=config.TTS_STABILITY,
            similarity_boost=config.TTS_SIMILARITY_BOOST,
            style=config.TTS_STYLE,
            use_speaker_boost=config.TTS_USE_SPEAKER_BOOST
        )
    )

    audio_data = b"".join(audio_generator)
    filepath.write_bytes(audio_data)
    print(f"  ✓ Saved ({len(audio_data)/1024:.1f} KB)\n")
```

### Use Case 3: Batch Regenerate All Audio

```bash
# Regenerate everything (after voice change or quality update)
python generate_greeting_audio.py
python generate_startup_audio.py
python generate_static_audio.py

# Verify total file count
find audio/static -name "*.mp3" | wc -l

# Check total size
du -sh audio/static
```

## Troubleshooting

### Error: "ELEVEN_LABS_API_KEY not found"

**Problem**: API key not in environment

**Solution**:
```bash
# Check .env file
cat .env | grep ELEVEN_LABS_API_KEY

# Should show:
# BOBTHESKULL_ELEVEN_LABS_API_KEY=sk_...

# If missing, add it:
echo "BOBTHESKULL_ELEVEN_LABS_API_KEY=sk-your-key-here" >> .env
```

### Error: "Audio generation failed"

**Problem**: API rate limit or network issue

**Solution**:
```bash
# Check API quota at elevenlabs.io dashboard
# Wait 1 minute and retry
# Or add retry logic with delay
```

### Files generated but playback fails

**Problem**: Incorrect audio format or corrupted file

**Solution**:
```bash
# Check file size (should be >1KB for typical greeting)
ls -lh audio/static/greetings/

# Test playback directly
mpv audio/static/greetings/yes_wizard.mp3

# Regenerate specific file if corrupted
```

### Filename normalization incorrect

**Problem**: Special characters in phrase causing issues

**Solution**:
```python
# Check normalization
from tts.static_audio import normalize_phrase_to_filename
print(normalize_phrase_to_filename("Your phrase here"))

# Should convert:
# - Spaces → underscores
# - Punctuation → removed
# - Uppercase → lowercase
# Example: "Yes, wizard?" → "yes_wizard"
```

## Pro Tips

1. **Generate in batches** - Create all related audio at once (all greetings, all startup messages)

2. **Test before deploying** - Play generated files locally before syncing to Pi

3. **Version control audio** - Commit generated MP3 files to git (they're small and rarely change)

4. **Use index files** - `greetings.txt` and `startup.txt` document what's available

5. **Consistent voice settings** - Don't change TTS settings mid-project or you'll need to regenerate everything

6. **Organize by category** - Use subdirectories (`greetings/`, `startup/`, `testing/`) for clarity

7. **Name descriptively** - `startup_complete_listening_for_wake_words.mp3` better than `startup_msg_3.mp3`

8. **Test audio duration** - Keep greetings short (1-2 seconds) for responsive feel

9. **Create test variants** - Generate same phrase with different emphases for testing

10. **Document custom scripts** - If you create `generate_test_audio.py`, add it to repo

## Integration with Other Skills

**Works well with:**
- **cross-repo-sync** - Syncing audio between BobTheSkull5 and BobFast5
- **audio-injection-testing** - Using generated test audio for automated testing
- **pi-deployment** - Deploying audio files to Raspberry Pi

## Time Savings

**Without skill:**
- 10-15 minutes per audio file (setup, generation, naming, placement, verification)
- Frequent errors in naming/directory structure
- Manual cross-repo copying with mistakes

**With skill:**
- 3-5 minutes per audio file (documented process)
- Consistent naming via normalization function
- Clear cross-repo sync patterns

**Estimated time savings: 2-3x faster**

## References

**Generation Scripts:**
- [generate_greeting_audio.py](../../generate_greeting_audio.py)
- [generate_startup_audio.py](../../generate_startup_audio.py)
- [generate_static_audio.py](../../generate_static_audio.py)

**Supporting Code:**
- [tts/static_audio.py](../../tts/static_audio.py) - Static audio playback and normalization
- [BobConfig.py](../../BobConfig.py) - ElevenLabs configuration

**Audio Directories:**
- `audio/static/greetings/` - Greeting responses
- `audio/static/startup/` - Startup/shutdown/error messages
- `audio/static/testing/` - Test audio files
