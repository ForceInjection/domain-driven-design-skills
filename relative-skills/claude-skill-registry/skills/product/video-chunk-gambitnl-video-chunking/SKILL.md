---
name: video-chunk
description: Process D&D session videos through the complete chunking pipeline. Use when the user requests to process, chunk, transcribe, or analyze a D&D session video file.
---

# Video Chunking Skill

Process a D&D session video file through the complete chunking pipeline.

## What This Skill Does

This skill orchestrates the complete video processing workflow:

1. **Extract Audio**: Uses FFmpeg to extract audio from the video file
2. **Transcribe**: Uses Whisper to transcribe the audio to text with speaker diarization
3. **Classify**: Uses Ollama to classify dialogue as in-character (IC) or out-of-character (OOC)
4. **Extract Knowledge**: Identifies NPCs, locations, quests, items, and other campaign elements
5. **Chunk**: Splits content into semantic segments based on topics and speaker changes
6. **Generate Outputs**: Creates data files, transcripts, and metadata

## Prerequisites

Before running this skill, ensure:
- FFmpeg is available and accessible
- Ollama is running locally with an appropriate model
- PyAnnote speaker diarization models are downloaded
- Input video file path is provided
- Sufficient disk space for processing

## Usage

When invoked, this skill will:
1. Verify all dependencies are available using the `check_pipeline_health` MCP tool
2. Run the processing pipeline via `python cli.py process <video_file>`
3. Monitor progress and report status
4. Handle errors gracefully and provide diagnostic information

## Example Invocations

- "Process the session video at videos/session_001.mp4"
- "Chunk this D&D recording: recordings/adventure_ep5.mkv"
- "Transcribe and analyze this session file"

## Command Reference

```bash
# Process a video file
python cli.py process <video_file> [--party default] [--session-id custom_id]

# Using Gradio UI
python app.py
```

## Error Handling

Common issues and solutions:
- **FFmpeg not found**: Check FFmpeg installation with `ffmpeg -version`
- **Ollama connection failed**: Ensure Ollama is running (`ollama serve`)
- **Out of memory**: Process shorter videos or reduce batch sizes
- **Transcription errors**: Check audio quality and Whisper model availability
- **Diarization failures**: Verify PyAnnote models are downloaded

## Output

The skill produces:
- Session data JSON with segments, speakers, and classifications
- Campaign knowledge JSON with NPCs, locations, quests, etc.
- Transcript files in human-readable format
- Processing logs with timestamps and diagnostics
- Output directory: `output/YYYYMMDD_HHMMSS_sessionid/`
