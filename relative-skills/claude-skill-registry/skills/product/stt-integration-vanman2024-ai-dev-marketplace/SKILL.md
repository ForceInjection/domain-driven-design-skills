---
name: stt-integration
description: ElevenLabs Speech-to-Text transcription workflows with Scribe v1 supporting 99 languages, speaker diarization, and Vercel AI SDK integration. Use when implementing audio transcription, building STT features, integrating speech-to-text, setting up Vercel AI SDK with ElevenLabs, or when user mentions transcription, STT, Scribe v1, audio-to-text, speaker diarization, or multi-language transcription.
allowed-tools: Bash, Read, Write, Edit
---

# stt-integration

This skill provides comprehensive guidance for implementing ElevenLabs Speech-to-Text (STT) capabilities using the Scribe v1 model, which supports 99 languages with state-of-the-art accuracy, speaker diarization for up to 32 speakers, and seamless Vercel AI SDK integration.

## Core Capabilities

### Scribe v1 Model Features
- **Multi-language support**: 99 languages with varying accuracy levels
- **Speaker diarization**: Up to 32 speakers with identification
- **Word-level timestamps**: Precise synchronization for video/audio alignment
- **Audio event detection**: Identifies sounds like laughter and applause
- **High accuracy**: Optimized for accuracy over real-time processing

### Supported Formats
- **Audio**: AAC, AIFF, OGG, MP3, Opus, WAV, WebM, FLAC, M4A
- **Video**: MP4, AVI, Matroska, QuickTime, WMV, FLV, WebM, MPEG, 3GPP
- **Limits**: Max 3 GB file size, 10 hours duration

## Skill Structure

### Scripts (scripts/)
1. **transcribe-audio.sh** - Direct API transcription with curl
2. **setup-vercel-ai.sh** - Install and configure @ai-sdk/elevenlabs
3. **test-stt.sh** - Test STT with sample audio files
4. **validate-audio.sh** - Validate audio file format and size
5. **batch-transcribe.sh** - Process multiple audio files

### Templates (templates/)
1. **stt-config.json.template** - STT configuration template
2. **vercel-ai-transcribe.ts.template** - Vercel AI SDK TypeScript template
3. **vercel-ai-transcribe.py.template** - Vercel AI SDK Python template
4. **api-transcribe.ts.template** - Direct API TypeScript template
5. **api-transcribe.py.template** - Direct API Python template
6. **diarization-config.json.template** - Speaker diarization configuration

### Examples (examples/)
1. **basic-stt/** - Basic STT with direct API
2. **vercel-ai-stt/** - Vercel AI SDK integration
3. **diarization/** - Speaker diarization examples
4. **multi-language/** - Multi-language transcription
5. **webhook-integration/** - Async transcription with webhooks

## Usage Instructions

### 1. Setup Vercel AI SDK Integration

```bash
# Install dependencies
bash scripts/setup-vercel-ai.sh

# Verify installation
npm list @ai-sdk/elevenlabs
```

### 2. Basic Transcription

```bash
# Transcribe a single audio file
bash scripts/transcribe-audio.sh path/to/audio.mp3 en

# Validate audio before transcription
bash scripts/validate-audio.sh path/to/audio.mp3

# Batch transcribe multiple files
bash scripts/batch-transcribe.sh path/to/audio/directory en
```

### 3. Test STT Implementation

```bash
# Run comprehensive tests
bash scripts/test-stt.sh
```

### 4. Use Templates

```typescript
// Read Vercel AI SDK template
Read: templates/vercel-ai-transcribe.ts.template

// Customize for your use case
// - Set language code
// - Configure diarization
// - Enable audio event tagging
// - Set timestamp granularity
```

### 5. Explore Examples

```bash
# Basic STT example
Read: examples/basic-stt/README.md

# Vercel AI SDK example
Read: examples/vercel-ai-stt/README.md

# Speaker diarization example
Read: examples/diarization/README.md
```

## Language Support

### Excellent Accuracy (≤5% WER)
30 languages including: English, French, German, Spanish, Italian, Japanese, Portuguese, Dutch, Polish, Russian

### High Accuracy (>5-10% WER)
19 languages including: Bengali, Mandarin Chinese, Tamil, Telugu, Vietnamese, Turkish

### Good Accuracy (>10-25% WER)
30 languages including: Arabic, Korean, Thai, Indonesian, Hebrew, Czech

### Moderate Accuracy (>25-50% WER)
19 languages including: Amharic, Khmer, Lao, Burmese, Nepali

## Configuration Options

### Provider Options (Vercel AI SDK)
- **languageCode**: ISO-639-1/3 code (e.g., 'en', 'es', 'ja')
- **tagAudioEvents**: Enable sound detection (default: true)
- **numSpeakers**: Max speakers 1-32 (default: auto-detect)
- **diarize**: Enable speaker identification (default: true)
- **timestampsGranularity**: 'none' | 'word' | 'character' (default: 'word')
- **fileFormat**: 'pcm_s16le_16' | 'other' (default: 'other')

### Best Practices
1. **Specify language code** when known for better performance
2. **Use pcm_s16le_16** format for lowest latency with uncompressed audio
3. **Enable diarization** for multi-speaker content
4. **Set numSpeakers** for better accuracy when speaker count is known
5. **Use webhooks** for files >8 minutes for async processing

## Common Patterns

### Pattern 1: Simple Transcription
Use direct API or Vercel AI SDK for single-language, single-speaker transcription.

### Pattern 2: Multi-Speaker Transcription
Enable diarization and set numSpeakers for interviews, meetings, podcasts.

### Pattern 3: Multi-Language Support
Detect language automatically or specify when known for content in 99 languages.

### Pattern 4: Video Transcription
Extract audio from video formats and transcribe with timestamps for subtitles.

### Pattern 5: Webhook Integration
Process long files asynchronously using webhook callbacks for results.

## Integration with Other ElevenLabs Skills

- **tts-integration**: Combine STT → processing → TTS for voice translation workflows
- **voice-cloning**: Transcribe existing voice samples before cloning
- **dubbing**: Use STT as first step in dubbing pipeline

## Troubleshooting

### Audio Format Issues
```bash
# Validate audio format
bash scripts/validate-audio.sh your-audio.mp3
```

### Language Detection Problems
- Specify languageCode explicitly instead of auto-detection
- Ensure audio quality is sufficient for chosen language

### Diarization Not Working
- Verify numSpeakers is set correctly (1-32)
- Check that diarize: true is configured
- Ensure audio has clear speaker separation

### File Size/Duration Limits
- Max 3 GB file size
- Max 10 hours duration
- Files >8 minutes are chunked automatically

## Script Reference

All scripts are located in `skills/stt-integration/scripts/`:

1. **transcribe-audio.sh** - Main transcription script with curl
2. **setup-vercel-ai.sh** - Install @ai-sdk/elevenlabs package
3. **test-stt.sh** - Comprehensive test suite
4. **validate-audio.sh** - Audio format and size validation
5. **batch-transcribe.sh** - Batch processing for multiple files

## Template Reference

All templates are located in `skills/stt-integration/templates/`:

1. **stt-config.json.template** - JSON configuration
2. **vercel-ai-transcribe.ts.template** - TypeScript with Vercel AI SDK
3. **vercel-ai-transcribe.py.template** - Python with Vercel AI SDK
4. **api-transcribe.ts.template** - TypeScript with direct API
5. **api-transcribe.py.template** - Python with direct API
6. **diarization-config.json.template** - Diarization settings

## Example Reference

All examples are located in `skills/stt-integration/examples/`:

1. **basic-stt/** - Basic transcription workflow
2. **vercel-ai-stt/** - Vercel AI SDK integration
3. **diarization/** - Speaker identification
4. **multi-language/** - Multi-language support
5. **webhook-integration/** - Async processing

---

**Skill Location**: `plugins/elevenlabs/skills/stt-integration/`
**Version**: 1.0.0
**Last Updated**: 2025-10-29
