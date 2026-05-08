---
name: audio-injection-testing
description: Test Bob The Skull with virtual audio injection instead of speaking. Use when testing wake word detection, STT accuracy, full conversation pipeline, or automated testing. Covers setup, configuration, injection methods, and troubleshooting.
allowed-tools: Read, Edit, Bash, Glob
---

# Audio Injection Testing Skill

Test Bob using virtual audio devices - inject pre-recorded audio instead of saying "Hey Bob" hundreds of times!

## When to Use This Skill

- **"Test wake word detection"** - Automated wake word testing
- **"Test with audio injection"** - Use virtual microphone
- **"Setup virtual audio"** - Configure test environment
- **"Run automated tests"** - Test conversation pipeline
- **"Debug STT accuracy"** - Test speech recognition

## Quick Reference

### Testing Methods Comparison

| Method | Platform | Manual Testing | Automated Testing | Setup Complexity |
|--------|----------|----------------|-------------------|------------------|
| **Combined Mic (RECOMMENDED)** | Linux | ✅ Yes | ✅ Yes | Medium |
| **Test-Only Virtual Devices** | Linux | ❌ No | ✅ Yes | Low |
| **VB-Audio Virtual Cable** | Windows | ❌ No | ✅ Yes | Low |
| **Direct File Input** | Both | ❌ No | ✅ Yes | High (code changes) |

## Method 1: Combined Microphone (Linux - RECOMMENDED)

**Best for**: Seamless switching between manual and automated testing

### Architecture
```
Real Microphone ──┐
                  ├──> module-loopback ──> null-sink ──> monitor ──> bob_combined_mic
Injected Audio ──┘                         (mixer)                     (Bob reads here)
```

### Setup

```bash
# One-time setup
python3 setup_combined_audio.py

# Output shows device index:
# ========================================
# ✓ Combined microphone ready!
#
# Device name: bob_combined_mic
# Device index: 5  <── Use this in config
# ========================================
```

### Configuration

```bash
# Edit .env
nano .env

# Set audio input device
BOBTHESKULL_AUDIO_INPUT_DEVICE_INDEX=5  # Use index from setup

# Restart Bob
python BobTheSkull.py
```

### Usage

**Manual testing** (just talk normally):
```bash
# Bob hears your voice through combined mic
# No commands needed - your mic is automatically mixed in!
```

**Automated testing** (inject audio):
```bash
# Play single test file
python3 test_wake_word_inject.py play --file audio/static/testing/wake_up_bob.mp3

# Run test sequence with delays
python3 test_wake_word_inject.py test --files \
    audio/static/testing/wake_up_bob.mp3 \
    audio/static/testing/what_time_is_it.mp3 \
    audio/static/testing/goodbye_bob.mp3 \
    --delay 3.0

# Test while monitoring logs
tail -f logs/bob.log &
python3 test_wake_word_inject.py test --files audio/static/testing/*.mp3
```

**Both work simultaneously!** Inject test audio while retaining ability to interrupt manually.

### Cleanup

```bash
# Remove virtual devices
python3 setup_combined_audio.py --cleanup

# Revert Bob's audio config to real microphone
nano .env
# Change BOBTHESKULL_AUDIO_INPUT_DEVICE_INDEX back to original
```

## Method 2: Test-Only Virtual Devices (Linux)

**Best for**: Pure automated testing (no manual fallback needed)

### Setup

```bash
# Create virtual devices
python3 test_wake_word_inject.py setup

# Output:
# ✓ Virtual audio devices created:
#   - Output: bob_test_output
#   - Input: bob_test_mic
```

### Configuration

```bash
# List devices to find index
python3 test_wake_word_inject.py list

# Configure Bob
nano .env
BOBTHESKULL_AUDIO_INPUT_DEVICE_NAME=bob_test_mic
# OR
BOBTHESKULL_AUDIO_INPUT_DEVICE_INDEX=<index>

# Restart Bob
```

### Usage

```bash
# Play audio file (Bob will hear it)
python3 test_wake_word_inject.py play --file audio/static/testing/hey_bob.mp3

# Run test sequence
python3 test_wake_word_inject.py test --files \
    audio/static/testing/wake_up_bob.mp3 \
    audio/static/testing/tell_me_a_joke.mp3 \
    --delay 2.0
```

### Cleanup

```bash
python3 test_wake_word_inject.py cleanup
```

## Method 3: VB-Audio Virtual Cable (Windows)

**Best for**: Windows automated testing

### Setup

1. **Install VB-Audio Virtual Cable**
   - Download: https://vb-audio.com/Cable/
   - Install: Run setup as Administrator
   - Creates "CABLE Input" (playback) and "CABLE Output" (recording)

2. **Configure Bob**
   ```bash
   # Find device index
   python list_audio_devices.py

   # Look for "CABLE Output" in input devices
   # Edit .env
   BOBTHESKULL_AUDIO_INPUT_DEVICE_INDEX=X  # CABLE Output index
   ```

3. **Restart Bob**

### Usage (Windows)

```bash
# Play audio to virtual cable using mpv
mpv --audio-device=wasapi/<CABLE-Input-GUID> audio/static/testing/wake_up_bob.mp3

# Or use Python with PyAudio
python test_audio_injection_windows.py --file audio/static/testing/wake_up_bob.mp3
```

## Creating Test Audio Files

### Option 1: Generate with ElevenLabs (Bob's voice)

**Use static-audio-generation skill** to create test audio:

```python
# Create generate_test_audio.py
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
python generate_test_audio.py
```

### Option 2: Record yourself

```bash
# Linux
arecord -d 3 -f S16_LE -r 16000 -c 1 audio/static/testing/wake_up_bob.wav

# Windows
# Use Audacity or Voice Recorder app
# Export as WAV: 16kHz, mono, 16-bit
```

### Option 3: Use espeak (quick but robotic)

```bash
espeak "Wake up Bob" --stdout | \
    sox -t wav - -r 16000 -c 1 -b 16 audio/static/testing/wake_up_bob.wav
```

### Option 4: Convert existing audio

```bash
# Convert to correct format (16kHz, mono, 16-bit)
sox input.mp3 -r 16000 -c 1 -b 16 audio/static/testing/output.wav

# Or use ffmpeg
ffmpeg -i input.mp3 -ar 16000 -ac 1 audio/static/testing/output.wav
```

## Testing Workflows

### Workflow 1: Wake Word Detection Testing

**Goal**: Verify wake word sensitivity and accuracy

```bash
# 1. Create test files (if not exist)
audio/static/testing/wake_up_bob.mp3       # Primary wake word
audio/static/testing/hey_bob.mp3           # Secondary wake word
audio/static/testing/false_positive_*.mp3  # Should NOT trigger

# 2. Setup virtual audio
python3 setup_combined_audio.py

# 3. Configure Bob with combined mic
nano .env  # Set AUDIO_INPUT_DEVICE_INDEX

# 4. Start Bob
python BobTheSkull.py &

# 5. Run test sequence
python3 test_wake_word_inject.py test --files \
    audio/static/testing/wake_up_bob.mp3 \
    audio/static/testing/hey_bob.mp3 \
    --delay 3.0

# 6. Monitor logs for detections
tail -f logs/bob.log | grep -i "wake word"

# 7. Verify web monitor
# Open: http://localhost:5001
# Check event feed for WakeWordDetectedEvent
```

### Workflow 2: STT Accuracy Testing

**Goal**: Test speech recognition accuracy

```bash
# 1. Create test phrases with known text
audio/static/testing/what_time_is_it.mp3
audio/static/testing/tell_me_a_joke.mp3
audio/static/testing/whats_the_weather.mp3

# 2. Create expected results file
cat > audio/static/testing/expected.txt <<EOF
what_time_is_it.mp3|What time is it?
tell_me_a_joke.mp3|Tell me a joke.
whats_the_weather.mp3|What's the weather like today?
EOF

# 3. Run tests and capture STT results
python3 test_wake_word_inject.py test --files audio/static/testing/*.mp3 --delay 5.0

# 4. Check logs for STT transcriptions
grep "SpeechRecognizedEvent" logs/bob.log

# 5. Compare actual vs expected transcriptions
# Manual verification or automated diff script
```

### Workflow 3: Full Conversation Pipeline Testing

**Goal**: Test wake word → STT → LLM → TTS → response

```bash
# 1. Create conversation test sequence
audio/static/testing/conversation_test_1.mp3  # "Wake up Bob"
audio/static/testing/conversation_test_2.mp3  # Wait for greeting
audio/static/testing/conversation_test_3.mp3  # "What time is it?"
audio/static/testing/conversation_test_4.mp3  # Wait for response
audio/static/testing/conversation_test_5.mp3  # "Thank you"
audio/static/testing/conversation_test_6.mp3  # "Goodbye Bob"

# 2. Run full sequence with appropriate delays
python3 test_wake_word_inject.py test --files \
    audio/static/testing/conversation_test_*.mp3 \
    --delay 8.0  # Longer delay for LLM processing

# 3. Monitor full pipeline
tail -f logs/bob.log | grep -E "WakeWord|SpeechRecognized|LLMResponse|SpeakingComplete"

# 4. Verify state transitions
# Watch web monitor for state machine transitions:
# IDLE → WAKE_LISTENING → GREETING → LISTENING → PROCESSING → SPEAKING → WAKE_LISTENING
```

### Workflow 4: Regression Testing

**Goal**: Ensure changes don't break existing functionality

```bash
# 1. Create comprehensive test suite
audio/static/testing/regression/
├── wake_word_tests/
│   ├── wake_up_bob_1.mp3
│   ├── wake_up_bob_2.mp3
│   └── hey_bob_1.mp3
├── stt_tests/
│   ├── simple_question_1.mp3
│   ├── complex_sentence_1.mp3
│   └── multi_sentence_1.mp3
└── conversation_tests/
    ├── full_interaction_1.mp3
    └── full_interaction_2.mp3

# 2. Create test script
cat > run_regression_tests.sh <<'EOF'
#!/bin/bash
echo "=== Bob The Skull Regression Tests ==="
echo "Wake Word Tests..."
python3 test_wake_word_inject.py test --files audio/static/testing/regression/wake_word_tests/*.mp3 --delay 2.0

echo "STT Tests..."
python3 test_wake_word_inject.py test --files audio/static/testing/regression/stt_tests/*.mp3 --delay 5.0

echo "Conversation Tests..."
python3 test_wake_word_inject.py test --files audio/static/testing/regression/conversation_tests/*.mp3 --delay 10.0

echo "=== Tests Complete ==="
EOF

chmod +x run_regression_tests.sh

# 3. Run before major changes
./run_regression_tests.sh > regression_results_$(date +%Y%m%d_%H%M%S).log

# 4. Run after changes and compare logs
diff regression_results_before.log regression_results_after.log
```

## Platform-Specific Notes

### Linux (PulseAudio)

**Virtual devices**: `module-null-sink` + `module-loopback`
**Setup script**: [setup_combined_audio.py](../../setup_combined_audio.py)
**Injection script**: [test_wake_word_inject.py](../../test_wake_word_inject.py)

**Verify devices**:
```bash
pactl list short sources  # List input devices
pactl list short sinks    # List output devices
```

**Monitor audio flow**:
```bash
# Install PulseAudio Volume Control
sudo apt install pavucontrol

# Run and check "Recording" tab
pavucontrol
```

### Windows (VB-Audio Cable)

**Virtual device**: VB-Audio Virtual Cable
**Download**: https://vb-audio.com/Cable/
**Device names**: "CABLE Input" (output), "CABLE Output" (input)

**List devices**:
```bash
python list_audio_devices.py
```

**Playback to virtual cable**:
```bash
# Use Windows audio API or mpv with WASAPI
mpv --audio-device=wasapi/CABLE-Input audio/static/testing/wake_up_bob.mp3
```

### Raspberry Pi (ALSA Loopback)

**Alternative**: ALSA loopback module (if PulseAudio not available)

```bash
# Load loopback module
sudo modprobe snd-aloop

# Devices created:
# hw:1,0 - Write audio here (playback)
# hw:1,1 - Bob reads from here (capture)

# Configure Bob
BOBTHESKULL_AUDIO_INPUT_DEVICE_NAME=hw:1,1

# Play test audio
aplay -D hw:1,0 audio/static/testing/wake_up_bob.wav
```

## Troubleshooting

### Bob doesn't hear injected audio

**Diagnosis**:
```bash
# Verify virtual device exists
pactl list short sources | grep bob

# Test recording from virtual mic
parecord -d bob_combined_mic test_capture.wav
# Play injected audio while recording
python3 test_wake_word_inject.py play --file audio/static/testing/wake_up_bob.mp3
# Listen to captured audio
paplay test_capture.wav
# Should hear the injected audio
```

**Common causes**:
- Bob using wrong audio device index
- Virtual device not created
- Audio format mismatch

### Audio plays but Bob doesn't detect wake word

**Diagnosis**:
```bash
# Check wake word sensitivity
grep WAKE_WORD_SENSITIVITY .env

# Try lower sensitivity (more sensitive)
BOBTHESKULL_WAKE_WORD_SENSITIVITY=0.3  # Default is 0.5

# Check audio format of test file
ffprobe audio/static/testing/wake_up_bob.mp3

# Should be: 16kHz or 22kHz, mono or stereo, MP3 or WAV
```

**Solutions**:
- Increase audio volume in test file
- Regenerate test audio with clearer pronunciation
- Lower wake word sensitivity threshold

### Virtual device not appearing after setup

**Diagnosis**:
```bash
# Check if PulseAudio is running
pulseaudio --check
echo $?  # Should return 0

# List loaded modules
pactl list short modules | grep bob

# Check system logs
journalctl -xe | grep pulse
```

**Solutions**:
```bash
# Restart PulseAudio
pulseaudio -k
pulseaudio --start

# Rerun setup
python3 setup_combined_audio.py --cleanup
python3 setup_combined_audio.py
```

### Injection audio too quiet or too loud

**Solution**: Adjust playback volume

```bash
# Linux - adjust virtual sink volume
pactl set-sink-volume bob_audio_mixer 150%  # Increase
pactl set-sink-volume bob_audio_mixer 50%   # Decrease

# Or normalize audio file itself
ffmpeg-normalize audio/static/testing/wake_up_bob.mp3 -o wake_up_bob_normalized.mp3
```

## Pro Tips

1. **Use combined mic for development** - Allows quick manual overrides during automated testing

2. **Create diverse test corpus** - Different voices, speeds, accents, background noise levels

3. **Test silence/noise** - Inject silence or white noise to test false positive rate

4. **Automate with CI/CD** - Run regression tests on every commit

5. **Record actual user interactions** - Convert real usage into test cases (with permission)

6. **Test edge cases** - Very quiet audio, loud audio, multiple speakers, music in background

7. **Use delays strategically** - Allow time for state transitions (wake→listen→process→speak)

8. **Monitor state machine** - Web monitor shows state transitions in real-time

9. **Log everything** - Capture full logs during testing for debugging

10. **Parametrize tests** - Create test configs with expected outcomes for automated validation

## Integration with Other Skills

**Works well with:**
- **static-audio-generation** - Generate test audio files with ElevenLabs
- **pi-deployment** - Deploy test audio to Pi for remote testing
- **cross-repo-sync** - Sync test audio between repos

## Time Savings

**Without skill:**
- 15-20 minutes setup per session (figure out virtual audio)
- 30+ minutes creating test audio manually
- Manual testing requires saying phrases repeatedly (exhausting!)

**With skill:**
- 5 minutes setup (documented commands)
- 5-10 minutes creating test audio (documented methods)
- Automated testing runs unattended

**Estimated time savings: 3x faster, infinite test iterations**

## References

**Setup Scripts:**
- [setup_combined_audio.py](../../setup_combined_audio.py) - Combined mic setup (Linux)
- [test_wake_word_inject.py](../../test_wake_word_inject.py) - Audio injection script

**Documentation:**
- [TESTING_AUDIO_INJECTION.md](../../TESTING_AUDIO_INJECTION.md) - Complete guide
- [COMBINED_MIC_QUICKSTART.md](../../COMBINED_MIC_QUICKSTART.md) - Quick setup

**Test Audio:**
- `audio/static/testing/` - Test audio files directory

**Related Tools:**
- [list_audio_devices.py](../../list_audio_devices.py) - List available audio devices
- [test_audio_output.py](../../test_audio_output.py) - Test speaker output
