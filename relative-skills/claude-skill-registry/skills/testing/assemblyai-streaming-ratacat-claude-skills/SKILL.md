---
name: assemblyai-streaming
description: This skill should be used when working with AssemblyAI’s Speech-to-Text and LLM Gateway APIs, especially for streaming/live transcription, meeting notetakers, and voice agents that need low-latency transcripts and audio analysis.
license: MIT
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Python
metadata:
  skill-version: "1.0.0"
  upstream-docs: "https://www.assemblyai.com/docs"
  focus: "streaming-stt, meeting-notetaker, voice-agent, llm-gateway"
---

# AssemblyAI Streaming & Live Transcription Skill

## Overview

Use this skill to build and maintain code that talks to AssemblyAI’s:

- **Streaming Speech-to-Text (STT)** via WebSockets (`wss://streaming.assemblyai.com/v3/ws`)
- **Async / pre-recorded STT** via REST (`https://api.assemblyai.com/v2/transcript`)
- **LLM Gateway** for applying Claude/GPT/Gemini-style models to transcripts (`https://llm-gateway.assemblyai.com`)

The emphasis is on **streaming/live transcription**, **meeting notetakers**, and **voice agents**, while still covering async workflows and post-processing.

This skill assumes a Claude Code environment with access to Python (preferred) and Bash.

---

## When to Use

Use this skill when:

- Implementing **real-time transcription** from a microphone, telephony stream, or audio file.
- Building a **live meeting notetaker** (Zoom/Teams/Meet), especially with summaries, action items, and highlights.
- Implementing a **voice agent** where latency and natural turn-taking matter.
- Migrating from other STT providers (OpenAI/Deepgram/Google/AWS/etc.) to AssemblyAI.
- Applying **LLMs to audio** via LLM Gateway for summaries, Q&A, topic tagging, or custom prompts.

Do **not** use this skill when:

- The task is generic HTTP client usage with no AssemblyAI-specific logic.
- The request clearly targets a different STT vendor.
- The environment cannot safely store or use an API key.

---

## AssemblyAI Mental Model

### 1. Products to care about

1. **Pre-recorded Speech-to-Text (Async)**
   - REST API: `POST /v2/transcript` → `GET /v2/transcript/{id}`
   - Designed for files from URLs, uploads, S3, etc.
   - Supports extra models: summarization, topic detection, sentiment, PII redaction, chapters, etc.

2. **Streaming Speech-to-Text**
   - WebSocket: `wss://streaming.assemblyai.com/v3/ws`
   - Low-latency, immutable transcripts (~300ms).
   - Turn detection built in; fits voice agents and live captioning.

3. **LLM Gateway**
   - REST API: `POST /v1/chat/completions` at `https://llm-gateway.assemblyai.com`
   - Unified access to multiple LLMs (Claude, GPT, Gemini, etc.).
   - Designed for “LLM over transcripts” workflows.

### 2. Key model knobs (Async)

- `speech_models`: `["slam-1", "universal"]` etc.
  - **Slam-1**: best English accuracy + keyterms_prompt, good for medical/technical conversations.
  - **Universal**: multilingual coverage; good default if language is unknown.
- `language_code` vs `language_detection`:
  - Use `language_code` when the language is known.
  - Use `language_detection: true` when unknown; optionally set `language_confidence_threshold`.
- `keyterms_prompt`:
  - Domain words/phrases to boost (med terms, product names, etc.).
- Extra intelligence: `summarization`, `iab_categories`, `content_safety`, `entity_detection`, `auto_chapters`, `sentiment_analysis`, `speaker_labels`, `auto_highlights`, `redact_pii`, etc.

### 3. Key model knobs (Streaming)

Connection URL:

- US: `wss://streaming.assemblyai.com/v3/ws`
- EU: `wss://streaming.eu.assemblyai.com/v3/ws`

Important query parameters:

- `sample_rate` (required): e.g. `16000`
- `format_turns` (bool): return formatted final transcripts; **avoid** for low-latency voice agents.
- `speech_model`: `universal-streaming-english` (default) or `universal-streaming-multi`.
- `keyterms_p

rompt`: JSON-encoded list of terms, e.g. `["AssemblyAI", "Slam-1", "Keanu Reeves"]`.
- Turn detection:
  - `end_of_turn_confidence_threshold` (0.0–1.0, default ~0.4)
  - `min_end_of_turn_silence_when_confident` (ms, default ~400)
  - `max_turn_silence` (ms, default ~1280)

Headers:

- Use either `Authorization: <API_KEY>` or a short-lived `token` query parameter issued by your backend.

Messages:

- Client sends:
  - Binary audio chunks (50–1000ms each).
  - Optional JSON messages: `{"type": "UpdateConfig", ...}`, `{"type": "Terminate"}`, `{"type": "ForceEndpoint"}`.
- Server sends:
  - `Begin` event with `id`, `expires_at`.
  - `Turn` events with:
    - `transcript` (immutable partials/finals),
    - `utterance` (complete semantic chunk),
    - `end_of_turn` (bool),
    - `turn_is_formatted` (bool),
    - `words` array with timestamps/confidences.
  - `Termination` event with summary stats.

### 4. Regions and data residency

- Async:
  - US: `https://api.assemblyai.com`
  - EU: `https://api.eu.assemblyai.com`
- Streaming:
  - US: `wss://streaming.assemblyai.com/v3/ws`
  - EU: `wss://streaming.eu.assemblyai.com/v3/ws`

Always keep base URLs consistent per project; don’t mix US/EU endpoints for the same data.

---

## Security & API Keys

- Always require an AssemblyAI API key and keep it **out of source** in Claude Code output:
  - Use environment variables: `ASSEMBLYAI_API_KEY`.
  - Or placeholders (`"<YOUR_API_KEY>"`) in snippets.
- For browser/client code:
  - Do **not** embed the API key.
  - Instruct the user to generate **temporary streaming tokens** on their backend and pass only the token into the WebSocket connection.
- Never print real keys in logs or comments.

---

## High-Level Workflow Patterns

### Decision tree

1. **Is the audio live?**
   - Yes → Use **Streaming STT**.
   - No → Use **Async STT**.

2. **Is latency critical (<1s) for responses?**
   - Yes → Streaming with `format_turns=false` and careful turn detection.
   - No → Async, then Summarization/Chapters/etc.

3. **Do transcripts leave the backend?**
   - Yes → Consider `redact_pii` (and optionally `redact_pii_audio`) before sharing.
   - No → Use raw transcripts as needed.

4. **Need LLM-based processing (Q&A, structured summaries)?**
   - Yes → Pipe transcripts into **LLM Gateway** via `chat/completions`.

---

## How Claude Should Work with This Skill

### General principles

- Prefer **official AssemblyAI SDKs** (Python/JS) when available; fall back to `requests`/`websocket-client` only if SDK cannot be installed.
- Always:
  - Validate HTTP responses and WebSocket status.
  - Surface useful error messages (`status`, `error` fields in transcript JSON).
  - Respect documented min/max chunk sizes (50–1000ms of audio per binary message).
- For voice-agent code, optimize for:
  - Immutable partials (`transcript`) and `utterance` field.
  - Minimal latency, avoid extra formatting passes.

---

## Recipe 1 – Minimal Streaming from Microphone (Python SDK)

> Goal: Stream mic audio to AssemblyAI and print transcripts in real time.

Use this when the environment has Python and `assemblyai` + `pyaudio` installed, and the user wants a quick streaming demo.

```python
import assemblyai as aai
from assemblyai.streaming import v3 as aai_stream
import pyaudio

API_KEY = "<YOUR_API_KEY>"

aai.settings.api_key = API_KEY

SAMPLE_RATE = 16000
CHUNK_MS = 50
FRAMES_PER_BUFFER = int(SAMPLE_RATE * (CHUNK_MS / 1000.0))

def main():
    client = aai_stream.StreamingClient(
        aai_stream.StreamingClientOptions(
            api_key=API_KEY,
            api_host="streaming.assemblyai.com",  # or "streaming.eu.assemblyai.com"
        )
    )

    def on_begin(_client, event: aai_stream.BeginEvent):
        print(f"Session started: {event.id}, expires at {event.expires_at}")

    def on_turn(_client, event: aai_stream.TurnEvent):
        # Use immutable transcript text
        text = (event.transcript or "").strip()
        if not text:
            return
        # Use formatted finals only for display; keep unformatted for LLMs
        if event.turn_is_formatted:
            print(f"[FINAL] {text}")
        else:
            print(f"[PARTIAL] {text}", end="\r")

    def on_terminated(_client, event: aai_stream.TerminationEvent):
        print(f"\nTerminated. Audio duration={event.audio_duration_seconds}s")

    def on_error(_client, error: aai_stream.StreamingError):
        print(f"\nStreaming error: {error}")

    client.on(aai_stream.StreamingEvents.Begin, on_begin)
    client.on(aai_stream.StreamingEvents.Turn, on_turn)
    client.on(aai_stream.StreamingEvents.Termination, on_terminated)
    client.on(aai_stream.StreamingEvents.Error, on_error)

    client.connect(
        aai_stream.StreamingParameters(
            sample_rate=SAMPLE_RATE,
            format_turns=False,  # better latency for voice agents
        )
    )

    pa = pyaudio.PyAudio()
    stream = pa.open(
        format=pyaudio.paInt16,
        channels=1,
        rate=SAMPLE_RATE,
        input=True,
        frames_per_buffer=FRAMES_PER_BUFFER,
    )

    try:
        print("Speak into your microphone (Ctrl+C to stop)...")
        def audio_gen():
            while True:
                yield stream.read(FRAMES_PER_BUFFER, exception_on_overflow=False)
        client.stream(audio_gen())
    except KeyboardInterrupt:
        pass
    finally:
        client.disconnect(terminate=True)
        stream.stop_stream()
        stream.close()
        pa.terminate()

if __name__ == "__main__":
    main()
