---
name: play-sound
description: Cross-platform audio feedback system for task completion and user prompts. Provides non-intrusive sound notifications to improve workflow awareness.
---

# Audio Feedback System

This skill provides cross-platform audio feedback for Claude Code events, helping users stay aware of task progress and interaction points without constantly watching the screen.

## Purpose

Audio cues enhance the development workflow by:
- **Signaling task completion**: Know when long-running tasks finish without monitoring
- **Alerting to prompts**: Be notified when user input is required
- **Maintaining flow**: Stay focused on other work while background tasks complete
- **Reducing context switching**: Less need to check status updates manually

## Sound Types

### Success Sound
- **Event**: Task completed successfully
- **macOS**: Hero.aiff (triumphant sound)
- **Linux**: complete.oga or similar system sound
- **Windows**: 1000Hz beep for 100ms

### Prompt Sound
- **Event**: User input or decision required
- **macOS**: Blow.aiff (blowing sound)
- **Linux**: dialog-warning.oga or bell sound
- **Windows**: 800Hz beep for 150ms

## Implementation

The audio system is implemented in `scripts/play-sound.py`, a Python script that:

1. **Detects the platform** (macOS, Linux, Windows)
2. **Uses native system sounds** when available
3. **Falls back gracefully** if sounds unavailable
4. **Fails silently** to avoid interrupting workflow
5. **Requires no external dependencies** (uses only Python stdlib)

### macOS Implementation
Uses `afplay` command with system sounds from `/System/Library/Sounds/`:
- Hero.aiff for success
- Blow.aiff for prompts
- Falls back to `osascript -e 'beep'` if needed

### Linux Implementation
Searches common sound directories:
- `/usr/share/sounds/freedesktop/stereo/`
- `/usr/share/sounds/ubuntu/stereo/`
- `/usr/share/sounds/gnome/default/alerts/`

Tries multiple tools in order:
1. `paplay` (PulseAudio)
2. `aplay` (ALSA)
3. `beep` command
4. Terminal bell (`\a`)

### Windows Implementation
Uses `winsound` module from Python standard library:
- Different frequencies for different events
- MessageBeep as fallback
- Terminal bell as last resort

## Hook Configuration

Hooks are configured in the plugin's `settings.json`:

```json
{
  "hooks": {
    "SubagentStop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${CLAUDE_PLUGIN_ROOT}/skills/play-sound/scripts/play-sound.py success"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${CLAUDE_PLUGIN_ROOT}/skills/play-sound/scripts/play-sound.py prompt"
          }
        ]
      }
    ]
  }
}
```

## Customization

Users can customize the audio feedback by:

1. **Modifying sound files**: Edit the sound file paths in `play-sound.py`
2. **Adjusting frequencies**: Change the Hz and duration values for Windows
3. **Adding new sound types**: Extend the sound_map dictionaries
4. **Disabling hooks**: Remove or comment out hooks in settings.json

## Cross-Platform Compatibility

The script is designed to work on:
- **macOS**: 10.12+ (all versions with modern system sounds)
- **Linux**: All major distributions (Ubuntu, Fedora, Debian, Arch, etc.)
- **Windows**: Windows 7+ (any version with Python 3.x)

All implementations use sounds/capabilities available by default on the latest OS versions, requiring no additional software installation.

## Silent Failure Philosophy

The audio system fails silently by design:
- If sounds can't be played, workflow continues uninterrupted
- No error messages displayed to the user
- Prevents audio issues from blocking development work
- Graceful degradation through multiple fallback options

## Performance

- **Non-blocking**: Sound playback runs asynchronously
- **Minimal overhead**: Subprocess call takes ~10-50ms
- **No dependencies**: Uses only Python standard library
- **Small footprint**: Script is lightweight and fast

## Testing

Test the sound system manually:

```bash
# Test success sound
python3 ./scripts/play-sound.py success

# Test prompt sound
python3 ./scripts/play-sound.py prompt

# Test default (prompt)
python3 ./scripts/play-sound.py
```

## Related Files

- `scripts/play-sound.py`: Main implementation
- `settings.json`: Hook configuration
- Plugin enabled by default in user's Claude Code settings
