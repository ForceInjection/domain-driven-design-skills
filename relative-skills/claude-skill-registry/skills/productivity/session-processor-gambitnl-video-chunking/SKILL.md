---
name: session-processor
description: Orchestrate end-to-end processing of D&D session videos from upload through knowledge extraction. Use when the user wants a complete automated workflow to process a new session recording.
---

# Session Processor Skill

Automated end-to-end processing workflow for D&D session videos.

## What This Skill Does

This skill provides a comprehensive, guided workflow for processing D&D session recordings:

1. **Pre-Flight Checks**: Verify all dependencies and system health
2. **Input Validation**: Check video file exists and is valid
3. **Audio Extraction**: Extract high-quality audio for transcription
4. **Transcription**: Generate text transcription with speaker diarization
5. **Classification**: Identify in-character vs out-of-character dialogue
6. **Knowledge Extraction**: Extract NPCs, locations, quests, and other entities
7. **Output Generation**: Create formatted transcripts and data files
8. **Post-Processing**: Generate summaries and update campaign knowledge
9. **Quality Checks**: Verify outputs are complete and valid

## How It Works

The skill orchestrates multiple pipeline components in sequence, handling errors gracefully and providing status updates at each stage.

### Processing Stages

```
Input Video
    ↓
[1] System Health Check
    ↓
[2] Audio Extraction (FFmpeg)
    ↓
[3] Transcription (Whisper)
    ↓
[4] Speaker Diarization (PyAnnote)
    ↓
[5] IC/OOC Classification (Ollama)
    ↓
[6] Knowledge Extraction (LLM)
    ↓
[7] Output Generation
    ↓
[8] Knowledge Base Update
    ↓
Complete Session Package
```

## Usage

### Basic Processing
User: "Process this session video: recordings/session_12.mp4"
User: "Run the pipeline on session_013.mkv"
User: "Transcribe and analyze episode5.mp4"

### With Custom Parameters
User: "Process session_14.mp4 using the 'main_campaign' party config"
User: "Analyze session_15.mp4 with session ID 'arc2_ep3'"

### Batch Processing
User: "Process all videos in the recordings/ folder"
User: "Re-process sessions 10 through 15"

## Prerequisites

The skill automatically checks for:
- ✅ FFmpeg installation and accessibility
- ✅ Ollama running with appropriate model
- ✅ PyAnnote diarization models downloaded
- ✅ Sufficient disk space (estimated based on video size)
- ✅ Input video file exists and is readable
- ✅ Party configuration file (if specified)

## Command Reference

```bash
# Basic processing
python cli.py process <video_file>

# With party configuration
python cli.py process <video_file> --party default

# With custom session ID
python cli.py process <video_file> --session-id custom_id

# Using Gradio UI
python app.py
# Then upload video and configure options in the UI
```

## MCP Tool Integration

Leverages multiple MCP tools:

- **check_pipeline_health**: Verify all dependencies before starting
- **list_available_models**: Confirm Ollama models are ready
- **validate_party_config**: Check party configuration file
- **list_processed_sessions**: View recently processed sessions
- **get_campaign_knowledge_summary**: Review extracted knowledge

## Processing Workflow Detail

### Stage 1: Pre-Flight Checks (30 seconds)

Verifies:
- FFmpeg version and capabilities
- Ollama service status and loaded models
- PyAnnote models availability
- Disk space (needs ~3x video file size)
- GPU availability (optional, speeds up processing)

### Stage 2: Audio Extraction (1-2 minutes per hour of video)

Extracts audio using FFmpeg:
```bash
ffmpeg -i <video> -vn -acodec pcm_s16le -ar 16000 -ac 1 audio.wav
```

Parameters:
- Sample rate: 16kHz (optimal for Whisper)
- Channels: Mono (sufficient for speech)
- Format: WAV PCM (uncompressed quality)

### Stage 3: Transcription (5-10 minutes per hour of video)

Uses Faster-Whisper for speech-to-text:
- Model: base, small, medium, or large (configurable)
- Language: Auto-detected or specified
- Timestamps: Word-level and segment-level

### Stage 4: Speaker Diarization (3-5 minutes per hour of video)

Uses PyAnnote.audio to identify speakers:
- Detects number of speakers
- Assigns speaker labels (SPEAKER_00, SPEAKER_01, etc.)
- Maps speakers to party members when possible

### Stage 5: IC/OOC Classification (2-4 minutes per hour of video)

Uses Ollama to classify dialogue:
- In-Character (IC): Dialogue spoken as D&D characters
- Out-of-Character (OOC): Rules discussions, meta-talk, breaks

Model prompt includes:
- Party member names and character names
- Context from surrounding dialogue
- Speaker information

### Stage 6: Knowledge Extraction (3-5 minutes per hour of video)

Identifies campaign entities:
- **NPCs**: Named characters mentioned in IC dialogue
- **Locations**: Places, cities, dungeons, landmarks
- **Quests**: Missions, objectives, tasks
- **Items**: Equipment, treasure, magical artifacts
- **Factions**: Organizations, guilds, kingdoms

### Stage 7: Output Generation (30 seconds)

Creates output files in `output/YYYYMMDD_HHMMSS_sessionid/`:
```
sessionid_data.json          # Complete session data
sessionid_transcript.txt     # Human-readable transcript
sessionid_knowledge.json     # Extracted entities
sessionid_metadata.json      # Processing metadata
```

### Stage 8: Knowledge Base Update (15 seconds)

Merges extracted entities into global campaign knowledge base:
- Deduplicates entities
- Updates appearance counts
- Links related entities
- Updates quest statuses

### Stage 9: Quality Checks (15 seconds)

Validates:
- All output files created successfully
- Session data is well-formed JSON
- Transcription has reasonable word count
- Knowledge extraction found entities
- No processing errors logged

## Processing Time Estimates

For a typical 2-hour D&D session video:

| Stage | Time | Notes |
|-------|------|-------|
| Pre-flight | 30s | System checks |
| Audio extraction | 2min | Depends on video codec |
| Transcription | 10min | With medium Whisper model |
| Diarization | 6min | Depends on speaker count |
| Classification | 5min | Using local Ollama |
| Knowledge extraction | 6min | Depends on dialogue density |
| Output generation | 30s | File writing |
| KB update | 15s | Merging entities |
| Quality checks | 15s | Validation |
| **Total** | **~30min** | For 2hr video |

With GPU acceleration, total time can be reduced to ~15-20 minutes.

## Output Structure

### Session Data JSON
```json
{
  "session_id": "session_012",
  "date": "2024-11-03",
  "duration_seconds": 7245,
  "party": "default",
  "segments": [
    {
      "index": 0,
      "start": 12.5,
      "end": 18.3,
      "speaker": "SPEAKER_01",
      "text": "You enter the dark forest...",
      "ic_ooc": "IC",
      "confidence": 0.95
    }
  ],
  "speakers": {
    "SPEAKER_00": "DM",
    "SPEAKER_01": "Alice",
    "SPEAKER_02": "Bob"
  },
  "statistics": {
    "total_segments": 845,
    "ic_segments": 634,
    "ooc_segments": 211,
    "unique_speakers": 5
  }
}
```

### Knowledge Extraction JSON
```json
{
  "session_id": "session_012",
  "extraction_date": "2024-11-03",
  "entities": {
    "npcs": [
      {
        "name": "Lord Blackthorn",
        "first_mentioned_at": "00:15:32",
        "mention_count": 7,
        "context": "Primary antagonist seeking ancient artifact"
      }
    ],
    "locations": [...],
    "quests": [...],
    "items": [...],
    "factions": [...]
  }
}
```

## Error Handling

The skill handles errors gracefully at each stage:

### Audio Extraction Fails
- Checks if video file is readable
- Tries alternative codecs
- Suggests re-encoding video if necessary
- Provides FFmpeg error diagnostics

### Transcription Fails
- Verifies audio quality
- Tries smaller Whisper model
- Suggests processing in chunks
- Checks for GPU/memory issues

### Diarization Fails
- Attempts with different speaker count settings
- Falls back to single speaker if necessary
- Warns about speaker accuracy limitations

### Classification Fails
- Checks Ollama service status
- Retries with exponential backoff
- Falls back to rule-based classification
- Continues processing with warnings

### Knowledge Extraction Fails
- Logs error but continues pipeline
- Uses partial extraction results
- Allows manual extraction later

## Monitoring and Progress

The skill provides real-time updates:

```
[1/9] Running pre-flight checks...
      ✅ FFmpeg: v6.0 (OK)
      ✅ Ollama: Running (model: mistral)
      ✅ Disk space: 45GB free (OK)
      ✅ Input video: session_12.mp4 (1.2GB, valid)

[2/9] Extracting audio from video...
      Progress: ████████████████░░░░ 80% (ETA: 30s)

[3/9] Transcribing audio (this may take several minutes)...
      Model: medium | Language: en
      Progress: ████████░░░░░░░░░░░░ 40% (ETA: 6min)

... (continues for each stage)

[9/9] Processing complete! ✅
      Session ID: session_012
      Output directory: output/20241103_143052_session_012/
      Processing time: 28 minutes 43 seconds

      Summary:
      - Duration: 2h 4min
      - Segments: 845 (634 IC, 211 OOC)
      - Speakers: 5 (DM + 4 players)
      - NPCs found: 12
      - Locations found: 5
      - Quests mentioned: 3
```

## Best Practices

1. **Check System Health First**: Always verify dependencies before processing
2. **Use Consistent Naming**: Name sessions consistently (e.g., `session_NNN.ext`)
3. **Specify Party Config**: Use `--party` flag for accurate speaker mapping
4. **Monitor Resource Usage**: Close other applications during processing
5. **Process Regularly**: Don't batch too many sessions (harder to debug issues)
6. **Review Outputs**: Manually check quality of first few processed sessions
7. **Back Up Raw Recordings**: Keep original videos before processing

## Troubleshooting

### Pipeline Stalls/Hangs
- Check system resources (CPU, memory, disk)
- Kill and restart Ollama if classification hangs
- Verify no antivirus interference
- Check logs for specific error messages

### Low Quality Transcription
- Ensure audio is clear (test with audio player)
- Try larger Whisper model (medium or large)
- Check for background noise in recording
- Verify 16kHz sampling rate

### Poor Speaker Diarization
- Confirm distinct speaker voices in recording
- Try adjusting speaker count parameter
- Check party configuration has correct member names
- Manually review and correct speaker labels

### Incorrect IC/OOC Classification
- Review Ollama model performance
- Check party/character names in configuration
- Consider re-training or fine-tuning classifier
- Manually correct classifications in output

## Integration with Other Skills

- **video-chunk**: Alternative name/interface for same functionality
- **test-pipeline**: Verify pipeline components before processing
- **debug-ffmpeg**: Troubleshoot audio extraction issues
- **campaign-analyzer**: Analyze knowledge extracted from sessions
- **party-validator**: Ensure party config is correct before processing

## Advanced Options

### Custom Processing Pipeline
```python
# In Python script
from src.pipeline import Pipeline

pipeline = Pipeline(
    transcribe_model="medium",
    classify_model="mistral",
    extract_knowledge=True,
    party_config="data/party_default.json"
)

result = pipeline.process("session_12.mp4")
```

### Partial Re-processing
```bash
# Re-run only knowledge extraction
python cli.py extract-knowledge --session session_012

# Re-run classification
python cli.py classify --session session_012
```

### Export Options
```bash
# Export to different formats
python cli.py export --session session_012 --format srt
python cli.py export --session session_012 --format vtt
python cli.py export --session session_012 --format docx
```

## Example Workflow

```
User: "I have a new session recording at recordings/arc2_session5.mp4.
       Please process it using the main_campaign party config."

Assistant uses session-processor skill:
1. Runs health check via check_pipeline_health MCP tool
2. Validates party config via validate_party_config MCP tool
3. Confirms video file exists and is readable
4. Executes: python cli.py process recordings/arc2_session5.mp4 --party main_campaign
5. Monitors progress and reports updates
6. Validates outputs when complete
7. Uses get_campaign_knowledge_summary to show extracted entities
8. Provides summary and output directory location

Result: Fully processed session ready for review and analysis
```
