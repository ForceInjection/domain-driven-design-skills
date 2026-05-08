---
name: voice-transcription
description: Record and transcribe voice input when user wants to speak instead of type, describe complex issues verbally, provide audio input, or dictate text. Use this when user says "record my voice", "let me speak", "voice input", "transcribe audio", or when verbal description would be clearer than typing.
allowed-tools: [Bash, Read]
version: 1.0.0
---

# Voice Transcription Skill

This skill enables local voice transcription using whisper.cpp for privacy-preserving speech-to-text.

## When to Use This Skill

Use this skill when the user:
- Explicitly asks to record voice or use voice input
- Wants to describe something verbally instead of typing
- Needs to transcribe audio
- Says phrases like "let me speak", "record this", "voice input"
- Would benefit from speaking complex information rather than typing

## Automatic Setup

The transcription script now includes:
- **Installation detection** - Checks if VoiceType is properly installed
- **Auto-start** - Automatically starts whisper.cpp server if not running

If the script detects missing installation, it will return JSON with `"installation_needed": true`. When you see this:

1. **Offer to run installation:**
   ```
   "It looks like VoiceType isn't fully installed. Would you like me to run the installer? I can do this with: /voicetype-install"
   ```

2. **If user agrees, run:**
   ```bash
   bash install.sh
   ```
   Or use the `/voicetype-install` command which provides guided installation.

## Prerequisites (Automatic)

The script automatically handles:
- ✅ **Checks for installation** - Verifies venv, whisper binary, and scripts exist
- ✅ **Starts whisper server** - Auto-starts from `.whisper/bin/` if not running
- ✅ **Downloads model** - First-time use downloads whisper model automatically

You don't need to manually check the server - the script does it!

## How to Transcribe Voice

1. **Run the transcription script:**
   ```bash
   source venv/bin/activate && python skills/voice/scripts/transcribe.py --duration 5
   ```

   The script automatically:
   - ✅ Checks installation (offers /voicetype-install if needed)
   - ✅ Starts whisper server if not running
   - ✅ Records audio from microphone for specified duration (default 5 seconds)
   - ✅ Transcribes via local whisper.cpp server (localhost:2022)
   - ✅ Returns JSON with transcribed text

2. **Parse the output:**
   - Success: `{"text": "transcribed speech", "duration": 5}`
   - Installation needed: `{"error": "...", "installation_needed": true, "missing_components": [...], "help": [...]}`
   - Transcription error: `{"error": "error message", "help": [...]}`

3. **Handle installation_needed:**
   If JSON contains `"installation_needed": true`:
   - Inform user: "VoiceType needs to be installed first."
   - Offer: "Would you like me to run the installer? Use: /voicetype-install or I can run: bash install.sh"
   - Wait for user confirmation before proceeding

## Example Usage Flows

### Scenario 1: Normal Transcription (Installed)

**User:** "Let me record a voice note about the bug I'm seeing"

**Assistant:**
1. Informs user: "I'll record for 5 seconds. Speak when ready..."
2. Runs transcription script (auto-starts server if needed)
3. Receives: `{"text": "The submit button isn't working when I click it on the checkout page"}`
4. Responds: "I transcribed: 'The submit button isn't working when I click it on the checkout page.' Let me help you investigate this issue..."

### Scenario 2: First-Time Use (Not Installed)

**User:** "Record my voice"

**Assistant:**
1. Runs transcription script
2. Receives: `{"error": "VoiceType is not fully installed", "installation_needed": true, "missing_components": ["Python venv", "whisper.cpp binary"]}`
3. Responds: "It looks like VoiceType isn't installed yet. Would you like me to run the installer? I can guide you through it with: /voicetype-install or directly run: bash install.sh"
4. User confirms
5. Runs `/voicetype-install` or `bash install.sh`
6. After installation: "Installation complete! Now let's try voice transcription..."

## Script Options

The transcription script accepts optional parameters:

- `--duration N` - Record for N seconds (1-30, default 5)
- Example: `python skills/voice/scripts/transcribe.py --duration 10`

## Troubleshooting

If transcription fails:

1. **Check microphone access:**
   ```bash
   python -c "import sounddevice as sd; print(sd.query_devices())"
   ```

2. **Verify whisper server:**
   ```bash
   systemctl --user status whisper-server
   journalctl --user -u whisper-server -n 20
   ```

3. **Test the script directly:**
   ```bash
   cd /path/to/voicetype
   source venv/bin/activate
   python skills/voice/scripts/transcribe.py
   ```

## Privacy Note

All voice processing happens locally:
- Audio recorded via sounddevice (local microphone)
- Transcription via whisper.cpp server (localhost only)
- No data sent to cloud services
- Audio files are temporary and deleted after transcription
