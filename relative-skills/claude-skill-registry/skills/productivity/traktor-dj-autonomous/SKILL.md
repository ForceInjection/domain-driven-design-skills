---
name: traktor-dj-autonomous
description: Complete autonomous DJ system for Traktor Pro 3 with MIDI control, intelligent track selection, energy flow management, and professional mixing workflows. Use when working on DJ automation, Traktor integration, autonomous music mixing, or building DJ agents that need real-time performance capabilities.
---

# Traktor DJ Autonomous System

## Overview

This skill provides a complete autonomous DJ system that controls Traktor Pro 3 via MIDI. The system performs professional DJ workflows including:

- **Real-time MIDI control** - Direct Traktor communication via loopMIDI (Windows)
- **Intelligent track selection** - LLM-enhanced music discovery with energy flow analysis
- **Autonomous mixing** - Automated transitions with phrase-perfect timing
- **Browser navigation** - Visual and MIDI-based library exploration
- **Professional workflow compliance** - Follows validated DJ best practices

## When to Use This Skill

Invoke this skill when:
- Setting up autonomous DJ systems
- Integrating with Traktor Pro 3
- Building music automation workflows
- Creating DJ agents or performance systems
- Troubleshooting MIDI or mixing issues

## System Architecture

### Core Components

1. **MIDI Communication** (`traktor_midi_driver.py`)
   - 100+ verified Control Change (CC) mappings
   - Direct Traktor control via loopMIDI "Traktor MIDI Bus 1"
   - <10ms latency for real-time performance

2. **Generated Modules** (all in `autonomous_dj/generated/`)
   - `deck_operations.py` - Playback control with MASTER/SYNC logic
   - `mixer_operations.py` - Volume, crossfader, EQ control
   - `transport_operations.py` - Tempo, sync, beatmatching
   - `loop_operations.py` - Beat-perfect loop control
   - `hotcue_operations.py` - 32-HOTCUE system management
   - `fx_operations.py` - Effects routing and control
   - `mix_executor.py` - Automated transition execution
   - `timing_analyzer.py` - Phrase detection and timing
   - `energy_analyzer.py` - Energy flow analysis
   - `track_selector.py` - Intelligent track compatibility
   - `track_metadata.py` - Collection.nml metadata extraction
   - `browser_navigator.py` - MIDI browser navigation
   - `llm_integration.py` - OpenRouter + LangChain integration
   - `persistent_memory.py` - ChromaDB knowledge base
   - `traktor_vision.py` - **NEW!** Screenshot capture and visual UI analysis

3. **Main Event Loop** (`live_performer.py`)
   - 500ms monitoring cycle
   - Hot-reload capability for setlists
   - Atomic state management

### Critical DJ Workflow Rules

**RULE #1: MASTER vs SYNC Decision**
```
First track (empty session):
✅ Set MASTER manually (no reference yet)
❌ Do NOT enable SYNC (nothing to sync to)
✅ High volume fader (85%)
✅ Position crossfader to deck side

Second track onwards (with deck playing):
❌ Do NOT manually set MASTER (AUTO handles it)
✅ Enable SYNC (matches BPM automatically)
✅ Start with LOW volume (0-20%)
✅ During transition: volume up → AUTO transfers MASTER
```

**RULE #2: Pre-Playback Mixer Setup**
Configure mixer BEFORE pressing play:
1. Position crossfader (A → LEFT, B → RIGHT)
2. Volume faders ready (playing: 85%, incoming: 0-20%)
3. EQ neutral (12 o'clock)
4. THEN press play

**RULE #3: AUTO Mode Default**
- Traktor's AUTO mode automatically transfers MASTER based on volume fader position
- Highest volume fader = MASTER deck
- During transitions: volume movements trigger automatic MASTER handoff
- **Do NOT send manual MASTER commands during transitions**

## Quick Start

### Prerequisites Verification

```python
# 1. Check MIDI setup
import rtmidi
midi_in = rtmidi.MidiIn()
ports = midi_in.get_ports()
print(ports)  # Should include "Traktor MIDI Bus 1"

# 2. Verify Traktor is running and configured
# - Open Traktor Pro 3
# - Preferences → Controller Manager → Generic MIDI
# - Input: Traktor MIDI Bus 1
# - Output: Traktor MIDI Bus 1
# - MIDI Channel: All

# 3. Check audio driver (CRITICAL)
# - Audio Setup → Audio Device: ASIO (NOT WASAPI)
# - WASAPI blocks MIDI - use ASIO4ALL or native ASIO
```

### Basic Usage Examples

**Play First Track:**

```python
from autonomous_dj.generated import deck_operations

# Load and play track with proper workflow
deck_operations.initialize_deck_operations()
result = deck_operations.play_deck('A', first_track=True)
print(result)
```

**Autonomous Track Loading:**
```python
from autonomous_dj_loop import autonomous_dj_next_track

# Automatically discover, navigate, and load next track
autonomous_dj_next_track(
    deck='A',
    genre_folder='Techno',
    current_track=None,
    current_browser_position=1
)
```

**Full Autonomous Workflow:**
```python
from autonomous_dub_track_loader import AutonomousDubTrackLoader

# Complete MIDI-based workflow (13.1s execution)
loader = AutonomousDubTrackLoader()
loader.run_complete_workflow(
    target_folder='Dub',
    scroll_down_count=4
)
```

## Key Modules Reference

### traktor_midi_driver.py
The **SOURCE OF TRUTH** for all CC mappings. Contains 100+ verified Control Change values.

Critical CC mappings:
```python
# Deck Control
DECK_A_PLAY_PAUSE = 47
DECK_B_PLAY_PAUSE = 48
DECK_A_LOAD_TRACK = 43
DECK_B_LOAD_TRACK = 44

# Volume
DECK_A_VOLUME = 65
DECK_B_VOLUME = 60

# MASTER/SYNC
DECK_A_TEMPO_MASTER = 33
DECK_A_SYNC_ON = 69
DECK_B_SYNC_ON = 70

# EQ
DECK_A_EQ_LOW = 36
DECK_A_EQ_MID = 35
DECK_A_EQ_HIGH = 34

# Browser Navigation
BROWSER_SCROLL_TREE_INC = 72  # Navigate folder tree down
BROWSER_SCROLL_TREE_DEC = 73  # Navigate folder tree up
BROWSER_EXPAND_COLLAPSE = 64  # Expand/collapse folder
BROWSER_SCROLL_LIST = 74      # Scroll track list
```

**CRITICAL TIMING**: Traktor requires 1.5-2 seconds between browser commands.
Fast commands (<1s) are ignored by Traktor.

### traktor_vision.py - Visual UI Analysis (NEW!)

The **VISION SYSTEM** for "seeing" Traktor's UI state. Captures screenshots and enables Claude's multimodal analysis for autonomous navigation.

**Key Capabilities**:
- Screenshot capture (Windows PowerShell / macOS screencapture)
- Prepares images for Claude's visual analysis
- Extracts UI state from screenshots
- Guides MIDI navigation decisions
- Verification of command execution

**Vision-Guided Workflow**:
```python
from autonomous_dj.generated.traktor_vision import TraktorVisionSystem

# Initialize vision system
vision = TraktorVisionSystem()

# Step 1: Capture Traktor screenshot
screenshot_path = vision.capture_traktor_window()

# Step 2: Prepare for Claude analysis
metadata = vision.prepare_for_analysis()
# Returns: screenshot path + analysis instructions for Claude

# Step 3: Claude analyzes the image (multimodal)
# Claude sees: selected folder, highlighted track, deck status, etc.

# Step 4: Get MIDI command recommendations
analysis = {  # From Claude's visual analysis
    "selected_folder": "Dub",
    "track_highlighted": True,
    "track_number": 3,
    "ready_to_load": True
}
recommendations = vision.analyze_browser_position(analysis)
# Returns: MIDI commands to execute based on visual state

# Step 5: Execute MIDI commands + verify with new screenshot
```

**When to Use Vision**:
- ✅ Before MIDI navigation (know current folder/track)
- ✅ After MIDI commands (verify they executed correctly)
- ✅ When navigation is "blind" (don't know current position)
- ✅ For intelligent decision-making (which folder to navigate to)
- ✅ To verify deck states visually (MASTER, SYNC, playing status)

**Vision Analysis Loop**:
```
1. Screenshot → 2. Claude Analyzes → 3. Decide MIDI Command → 
4. Execute Command → 5. Screenshot (verify) → Repeat
```

**What Claude Can See** from screenshots:
- Browser: Selected folder, highlighted track, track list position
- Decks: Playing/stopped, MASTER/SYNC enabled, loaded tracks
- Mixer: Volume faders, crossfader position, EQ settings
- Tracks: Name, artist, BPM, genre, key
- UI: Active view, error messages, ready states

**Cross-Platform Support**:
- Windows: PowerShell screen capture
- macOS: screencapture command
- Screenshots saved to: `data/screenshots/`

**Example: Vision-Guided Track Loading**:
```python
# Complete workflow with vision
vision = TraktorVisionSystem()
midi = TraktorMIDIDriver()

# 1. Capture current state
screenshot = vision.capture_traktor_window()

# 2. Claude analyzes (you use view tool on screenshot)
# Claude says: "Folder 'Dub' selected, track 3 highlighted"

# 3. Load the highlighted track
midi.send_cc(TraktorCC.DECK_A_LOAD_TRACK, 127)

# 4. Verify with new screenshot
verify_screenshot = vision.capture_traktor_window()
# Claude verifies: "Track loaded successfully on Deck A"
```

**Performance**:
- Screenshot capture: ~100-500ms
- No MIDI latency impact (vision is separate step)
- Old screenshots auto-cleanup (keeps last 10)


### Configuration Management

**NEVER hardcode CC values or system settings.** Always use config files.

Location: `config/traktor_midi_mapping.json`

Usage pattern:
```python
from config.config_loader import get_config

config = get_config()
play_cc = config.get_cc('deck_a', 'play_pause')  # Returns 47
volume_cc = config.get_cc('deck_a', 'volume')    # Returns 65
```

### LLM Integration

The system uses OpenRouter for intelligent decision-making:

```python
from autonomous_dj.generated.llm_integration import LLMIntegration

llm = LLMIntegration()
response = await llm.get_next_track_suggestion(
    current_track={'bpm': 126, 'genre': 'Techno'},
    energy_target='peak',
    available_tracks=['track1.mp3', 'track2.mp3']
)
```

Features:
- Persistent memory via ChromaDB vector database
- Conversation history tracking
- Token/cost monitoring in `data/llm_logs.json`
- Automatic learning from successful mixes

### Intelligent Track Selection

The system now includes automatic harmonic mixing using Camelot Wheel.

**User Commands**:
- "Find a compatible track"
- "Load a compatible track on Deck B"
- "Trova una traccia compatibile"

**Implementation**:
- File: `autonomous_dj/workflow_controller.py`
- Method: `_action_find_compatible_track()`
- Dependencies: `camelot_matcher.py`, `midi_navigator.py`

**Workflow**:
1. Vision AI extracts BPM/Key from current deck
2. `find_compatible_tracks()` queries SQLite database
3. Camelot Wheel rules: same number, ±1 number, BPM ±6%
4. MIDI navigator scrolls to best match
5. Safety checks + load to target deck

**Database**:
- File: `tracks.db` (SQLite)
- Generated by: `collection_parser_xml.py`
- Source: Traktor's `collection.nml` file
- Must have BPM and Key analyzed in Traktor

**Testing**:
- Run: `python test_intelligent_integration.py`
- Verifies: imports, database, Camelot logic, matching, parsing

## Troubleshooting

### MIDI Not Working

**Problem**: Traktor ignores MIDI commands
**Solution**:
1. Check Audio Device setting in Traktor
2. Must be ASIO (NOT WASAPI)
3. WASAPI blocks MIDI processing
4. Install ASIO4ALL if no native ASIO driver

**Verification**:
```bash
python verify_midi_setup.py
```

### Browser Navigation Too Fast

**Problem**: Browser doesn't respond to navigation commands
**Solution**: Ensure 1.5-2s delay between commands
```python
# ❌ Wrong: Commands too fast
for i in range(3):
    scroll_down(1)
    time.sleep(0.5)  # TOO FAST

# ✅ Correct: Proper timing
for i in range(3):
    scroll_down(1)
    time.sleep(1.5)  # Traktor can process
```


### Deck States Conflict

**Problem**: Both decks show MASTER active
**Solution**: Use deck_operations to check and fix states
```python
from autonomous_dj.generated.deck_operations import get_deck_state

state_a = get_deck_state('A')
state_b = get_deck_state('B')
print(f"Deck A MASTER: {state_a.get('master')}")
print(f"Deck B MASTER: {state_b.get('master')}")
```

## Advanced Features

### Autonomous DJ Loop

The system can run completely autonomously with continuous track selection:

```python
# Start autonomous performer with continuous loop
python autonomous_dj/live_performer_autonomous.py --autonomous
```

Features:
- Automatic timing detection (<32 bars remaining trigger)
- Intelligent track selection with energy progression
- Visual browser navigation with selection verification
- Complete mix execution with DJ workflow compliance

### Persistent Memory System

ChromaDB-based knowledge base for learning:

Location: `data/memory/chroma_db/`

What it stores:
- Successful mix decisions
- Track compatibility patterns
- Energy flow strategies
- User preferences

### datapizza-ai Observability

Performance monitoring with ContextTracing:

```python
from autonomous_dj.generated.observability import trace_operation

with trace_operation("mix_transition"):
    # Your operation here
    execute_mix(deck_a, deck_b)
```

Metrics tracked:
- Operation duration
- Token usage
- MIDI latency (enforced <10ms)

## Project Structure

```
traktor/
├── autonomous_dj/
│   ├── generated/              # All agent-generated modules
│   │   ├── deck_operations.py
│   │   ├── mixer_operations.py
│   │   ├── llm_integration.py
│   │   └── ... (17 modules total)
│   ├── live_performer.py      # Main event loop
│   └── background_intelligence.py  # Strategy layer
│
├── config/
│   ├── traktor_midi_mapping.json   # CC mappings (source of truth)
│   └── config_loader.py            # Configuration loader
│
├── data/
│   ├── state.json              # Current system state
│   ├── memory/                 # Persistent knowledge
│   └── llm_logs.json          # LLM usage tracking
│
└── traktor_midi_driver.py     # MIDI communication layer
```


## Best Practices

### 1. Always Follow DJ Workflow Rules
Read and enforce rules from `DJ_WORKFLOW_RULES.md`:
- MASTER vs SYNC decision logic
- Pre-playback mixer setup
- Energy flow management

### 2. Use Configuration, Not Hardcoded Values
```python
# ❌ Wrong
send_cc(47, 127)  # What does 47 mean?

# ✅ Right
play_cc = config.get_cc('deck_a', 'play_pause')
send_cc(play_cc, 127)  # Clear intent
```

### 3. ONE SOURCE OF TRUTH Principle
- CC Mappings: `traktor_midi_driver.py`
- Project State: This SKILL.md
- Workflow Rules: `DJ_WORKFLOW_RULES.md`
- Generated Code: `autonomous_dj/generated/`

### 4. Module Development Pattern
1. Agent generates module → `autonomous_dj/generated/`
2. Module is PERMANENT (no regeneration unless bugfix)
3. live_performer.py imports and uses module
4. Knowledge persists across sessions

### 5. Testing Strategy
- One-time discovery tests → Save to JSON knowledge base
- Module testing → Use pytest in `tests/` directory
- No temporary test files in root

## Dependencies

Required packages (install via pip):
```
rtmidi>=1.4.9        # MIDI communication
pygame>=2.1.0        # Windows MIDI backend
python-osc>=1.8.0    # OSC protocol (if needed)
```

Optional for LLM features:
```
openai>=1.0.0        # OpenRouter API
langchain>=0.1.0     # LLM orchestration
chromadb>=0.4.0      # Vector database
datapizza-ai>=0.0.2  # Observability
```

## Security Considerations

- Never commit API keys to version control
- Use `.env` file for sensitive configuration
- MIDI commands run with system privileges
- Review all generated code before execution

## Next Steps

For detailed migration from old project:
1. Copy all files from `autonomous_dj/generated/` 
2. Copy `traktor_midi_driver.py` (CC mappings)
3. Copy `config/` directory (configuration)
4. Copy `DJ_WORKFLOW_RULES.md` (workflow rules)
5. Review and adapt `live_performer.py` for your setup

For additional documentation, see:
- `references/cc-mappings.md` - Complete CC mapping reference
- `references/workflow-rules.md` - Detailed DJ workflow guide
- `references/troubleshooting.md` - Common issues and solutions

---

## 🛡️ SAFETY LAYER (NEW - 2025-10-24)

### Overview

Complete safety layer implemented to prevent audio spikes, clipping, and workflow violations. **CRITICAL for production use!**

### Implementation Files

- **`traktor_safety_checks.py`** (495 lines) - Core safety layer class
- **`SAFETY_LAYER_TEST_RESULTS.json`** - Complete test results and configuration
- **`INTERACTION_MODE_TOGGLE_VS_DIRECT.md`** - Critical Interaction Mode analysis
- **Test suite**: `test_safety_checks.py`, `test_scenario1_complete_toggle.py`, `test_scenario2_complete.py`

### Critical Discoveries

**Interaction Mode Configuration**:
- **Crossfader (CC 56)**: MUST be "Direct" mode (absolute values 0-127)
- **Play/Pause (CC 47/48)**: Works with "Toggle" mode (impulse 127->0)
- **Volume/EQ (CC 34-36, 50-52, 60, 65)**: MUST be "Direct" mode

**Safety Features**:
1. ✅ Pre-load volume check (prevents audio spikes)
2. ✅ Post-load EQ reset (neutral sound)
3. ✅ MASTER/SYNC logic (prevents tempo chaos)
4. ✅ Crossfader positioning (double protection)
5. ✅ Opposite deck protection (no interference)
6. ✅ Emergency silence (immediate cutoff)
7. ✅ Automated transitions (smooth crossfades)

### Usage

```python
from traktor_safety_checks import TraktorSafetyChecks

safety = TraktorSafetyChecks(midi_driver)

# Load first track safely
safety.pre_load_safety_check('A', opposite_deck_playing=False)
midi.load_to_deck_a()
safety.post_load_safety_setup('A', is_first_track=True)
safety.prepare_for_playback('A', is_first_track=True)
safety.play_deck_toggle('A')  # Toggle mode support

# Load second track (protecting first)
safety.pre_load_safety_check('B', opposite_deck_playing=True)
midi.load_to_deck_b()
safety.post_load_safety_setup('B', is_first_track=False)
safety.prepare_for_playback('B', is_first_track=False)
safety.play_deck_toggle('B')

# Automated smooth transition
safety.safe_volume_transition(from_deck='A', to_deck='B')
```

### Test Results

**Scenario 1** (First Track Load): ✅ **PASSED**
- All safety checks executed correctly
- Volume, EQ, MASTER/SYNC, crossfader verified
- Audio clean, no spikes

**Scenario 2** (Second Track Load): ✅ **READY**
- Opposite deck protection verified
- SYNC logic correct

**Browser Navigation**: ✅ **PASSED**
- CC 72/73/74 work independently
- No interference with mixer controls

### CRITICAL Configuration

In Traktor Controller Manager, ensure:
- Generic MIDI device active (NOT Generic Keyboard)
- Crossfader Position → Interaction Mode: **Direct**
- Play/Pause → Interaction Mode: **Toggle** (with state tracking)
- All Volume/EQ → Interaction Mode: **Direct**

**DO NOT use Toggle mode for crossfader/volume** - causes unpredictable behavior!

---

**Version**: 1.1.0
**Last Updated**: 2025-10-24
**Status**: ✅ Production Ready with Safety Layer
