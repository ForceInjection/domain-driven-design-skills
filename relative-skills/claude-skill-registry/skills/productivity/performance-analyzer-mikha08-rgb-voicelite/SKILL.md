---
name: performance-analyzer
description: Analyze and optimize VoiceLite performance including RAM usage, CPU utilization, transcription latency, and memory leaks. Activates when performance targets are violated or optimization is needed.
---

# Performance Analyzer

Monitor and optimize VoiceLite performance against strict targets.

## When This Skill Activates

- Keywords: "slow", "memory leak", "high CPU", "performance", "optimization"
- Metrics mentioned: RAM, CPU, latency, FPS, responsiveness
- Violations: ">100MB idle", ">300MB active", ">5% CPU idle", "slow transcription"
- After changes to: AudioRecorder, PersistentWhisperService, MainWindow
- User reports: "App is slow", "High memory usage", "Laggy UI"

## VoiceLite Performance Targets

From CLAUDE.md - these are STRICT requirements:

| Metric | Target | Failure Threshold | How to Measure |
|--------|--------|-------------------|----------------|
| **Idle RAM** | <100MB | >150MB | Task Manager or dotMemory after 30s idle |
| **Active RAM** | <300MB | >400MB | During transcription (peak usage) |
| **Idle CPU** | <5% | >10% | Task Manager (30s average) |
| **Transcription Latency** | <200ms | >500ms | Time from speech stop to text injection |
| **Whisper Processing (tiny)** | <0.8s | >2s | 5-second audio sample |
| **Whisper Processing (small)** | <3s | >8s | 5-second audio sample |
| **Startup Time** | <2s | >5s | From launch to tray icon visible |

**All targets are non-negotiable** - VoiceLite must be lightweight and responsive.

## Quick Performance Check

### Manual Task Manager Method

```powershell
# 1. Launch VoiceLite.exe

# 2. Wait 30 seconds (reach idle state)

# 3. Open Task Manager (Ctrl+Shift+Esc)
#    - Details tab → Find VoiceLite.exe
#    - Check "Memory (Private Working Set)"
#      ✓ Should be <100MB
#      ✗ If >150MB → Memory leak investigation needed

# 4. Check CPU usage over 30 seconds
#    ✓ Should average <5%
#    ✗ If >10% → CPU profiling needed

# 5. Test transcription
#    - Record 5 seconds of audio
#    - Check memory spike
#      ✓ Should stay <300MB
#      ✗ If >400MB → Audio buffer leak

# 6. Check whisper process
#    - After recording, check whisper.exe appears briefly
#    - Should disappear after <2s for tiny model
#    ✗ If lingers → Zombie process (disposal issue)
```

### Automated Performance Tests

```csharp
// VoiceLite.Tests/Performance/PerformanceTests.cs

[Fact]
public async Task TranscriptionLatency_ShouldBeLessThan200ms()
{
    // Arrange
    var recorder = new AudioRecorder();
    var whisper = new PersistentWhisperService();

    // Act
    var stopwatch = Stopwatch.StartNew();
    var audio = await recorder.Record5Seconds();
    var text = await whisper.TranscribeAsync(audio);
    stopwatch.Stop();

    // Assert
    stopwatch.ElapsedMilliseconds.Should().BeLessThan(200);
}

[Fact]
public void IdleMemory_ShouldBeLessThan100MB()
{
    // Arrange
    GC.Collect();
    GC.WaitForPendingFinalizers();
    GC.Collect();

    // Act
    var memoryMB = GC.GetTotalMemory(false) / 1024 / 1024;

    // Assert
    memoryMB.Should().BeLessThan(100);
}

[Fact]
public async Task WhisperProcessing_TinyModel_ShouldBeLessThan800ms()
{
    // Arrange
    var service = new PersistentWhisperService("ggml-tiny.bin");
    var test5sAudio = "test_audio_5s.wav";

    // Act
    var stopwatch = Stopwatch.StartNew();
    await service.TranscribeAsync(test5sAudio);
    stopwatch.Stop();

    // Assert
    stopwatch.ElapsedMilliseconds.Should().BeLessThan(800);
}
```

## Memory Profiling with dotMemory

### Installation

```bash
# Download JetBrains dotMemory (free 30-day trial)
# Or use dotMemory CLI for CI/CD
```

### Profiling Workflow

```bash
# 1. Attach to running VoiceLite process
# Tools → Attach to Process → Select VoiceLite.exe

# 2. Take baseline snapshot (idle state)
# Wait 30s, click "Get Snapshot"

# 3. Perform 10 transcriptions

# 4. Take second snapshot

# 5. Compare snapshots
# Look for growing:
# - byte[] arrays (audio buffers not disposed)
# - Process objects (whisper zombies)
# - Event handlers (subscription leaks)
```

### Red Flags in dotMemory

**Growing byte[] arrays**:
```
Snapshot 1: 1.5 MB byte[]
Snapshot 2: 15.2 MB byte[]

→ Audio buffers not being released
→ Check AudioRecorder.Dispose() called
→ Verify _audioBuffer cleared after use
```

**Growing Process objects**:
```
Snapshot 1: 0 Process instances
Snapshot 2: 10 Process instances

→ Whisper.exe processes not disposed
→ Check PersistentWhisperService.TranscribeAsync finally block
→ Ensure process?.Dispose() called
```

**Growing event subscriptions**:
```
Snapshot 1: 5 event handlers
Snapshot 2: 50 event handlers

→ Events subscribed but never unsubscribed
→ Check -= in Dispose methods
→ Example: _audioRecorder.AudioFileReady -= OnAudioFileReady
```

## CPU Profiling with PerfView

### Collect CPU Trace

```bash
# 1. Download PerfView.exe (free, Microsoft)
# https://github.com/microsoft/perfview/releases

# 2. Run as Administrator

# 3. Collect → Collect
# or command line:
PerfView.exe collect -ThreadTime

# 4. Perform actions in VoiceLite (transcriptions)

# 5. Stop collection

# 6. Analyze → CPU Stacks
```

### Analyzing CPU Hotspots

**Look for**:
- **High % in specific method** → Optimization target
- **Tight loops** → Potential infinite loop or inefficiency
- **Excessive GC** → Too many allocations
- **Blocking I/O on UI thread** → Move to background

**Example findings**:
```
Method: AudioRecorder.ProcessBuffer - 45% CPU
→ Buffer processing inefficient
→ Optimization: Use Span<byte> instead of byte[]

Method: GC.Collect - 15% CPU
→ Too many allocations
→ Optimization: Reuse buffers, reduce new object creation
```

## Common Performance Issues

### Issue 1: Memory Leak in AudioRecorder

**Symptom**: RAM grows from 50MB → 200MB+ after 20 recordings

**Diagnosis**:
```csharp
// Check if Dispose is called
public class AudioRecorder : IDisposable
{
    public void Dispose()
    {
        Console.WriteLine("AudioRecorder.Dispose called"); // Add logging
        _waveIn?.Dispose();
        _waveIn = null;
    }
}

// Check if actually disposed after use
using (var recorder = new AudioRecorder())
{
    await recorder.RecordAsync();
} // Should call Dispose here
```

**Fix**: Ensure `using` statement or explicit Dispose() call

### Issue 2: Whisper Zombie Processes

**Symptom**: Multiple whisper.exe processes remain after transcription

**Diagnosis**:
```bash
# Check running whisper processes
tasklist | findstr whisper.exe

# Should be 0 when idle
# If >0 → Disposal issue
```

**Fix**:
```csharp
// PersistentWhisperService.cs
public async Task<string> TranscribeAsync(string path)
{
    Process? process = null;
    try
    {
        process = new Process { /* ... */ };
        process.Start();
        // ...
    }
    finally
    {
        // CRITICAL: Always dispose
        process?.Kill(); // If still running
        process?.Dispose();
    }
}
```

### Issue 3: UI Thread Blocking

**Symptom**: UI freezes during transcription

**Diagnosis**:
```csharp
// Check if long-running work on UI thread
private void OnRecordButtonClick(object sender, RoutedEventArgs e)
{
    // ❌ BAD: Blocks UI thread
    var result = _whisperService.TranscribeAsync(audio).Result;

    // ✅ GOOD: Async/await keeps UI responsive
    var result = await _whisperService.TranscribeAsync(audio);
}
```

**Fix**: Use `async`/`await` throughout, never `.Result` or `.Wait()`

### Issue 4: Large Audio Buffer Allocations

**Symptom**: Memory spikes during recording

**Optimization**:
```csharp
// Before: New allocation every buffer
private void OnDataAvailable(object sender, WaveInEventArgs e)
{
    var buffer = new byte[e.BytesRecorded]; // Allocation!
    Buffer.BlockCopy(e.Buffer, 0, buffer, 0, e.BytesRecorded);
}

// After: Reuse buffer
private readonly byte[] _reusableBuffer = new byte[8192];
private void OnDataAvailable(object sender, WaveInEventArgs e)
{
    Buffer.BlockCopy(e.Buffer, 0, _reusableBuffer, 0, e.BytesRecorded);
}
```

## Whisper Performance Optimization

### Command-Line Flags (v1.0.85-88 Optimizations)

```bash
# Current optimized command (67-73% faster)
whisper.exe \
  -m ggml-tiny.bin \
  -f audio.wav \
  --no-timestamps \
  --language en \
  --beam-size 1 \        # Greedy decoding (fastest)
  --best-of 1 \          # Single pass
  --entropy-thold 3.0 \  # Early stopping
  --no-fallback \        # No secondary attempts
  --max-context 64 \     # Smaller context window
  --flash-attn           # Flash attention (12% faster)

# v1.0.84 command (baseline)
whisper.exe -m ggml-tiny.bin -f audio.wav --no-timestamps --language en
# ~2.5s for 5s audio

# v1.0.88 command (current)
# ~0.7s for 5s audio (67% faster!)
```

### Model Performance Comparison

| Model | Size (Q8_0) | Accuracy | Processing Time (5s audio) |
|-------|-------------|----------|----------------------------|
| **ggml-tiny.bin** | 42MB | 80-85% | 0.7s ✅ |
| **ggml-base.bin** | 78MB | 85-90% | 1.5s ✅ |
| **ggml-small.bin** | 253MB | 90-93% | 3s ✅ |
| **ggml-medium.bin** | 1.5GB | 95-97% | 12s ⚠️ |
| **ggml-large-v3.bin** | 1.6GB | 97-98% | 8s ⚠️ |

## Performance Regression Testing

### CI/CD Performance Tests

```bash
# Run performance tests in CI
dotnet test --filter "Category=Performance"

# Set environment variable for thresholds
PERFORMANCE_STRICT=true dotnet test

# Fail build if performance regresses
```

### Benchmarking Script

```powershell
# benchmark.ps1
$iterations = 10
$results = @()

for ($i = 0; $i -lt $iterations; $i++) {
    $sw = [Diagnostics.Stopwatch]::StartNew()

    # Test transcription
    ./VoiceLite/bin/Release/VoiceLite.exe --test-transcribe test_5s.wav

    $sw.Stop()
    $results += $sw.ElapsedMilliseconds
}

$avg = ($results | Measure-Object -Average).Average
Write-Host "Average transcription time: $avg ms"

if ($avg -gt 800) {
    Write-Error "Performance regression! Target: <800ms, Actual: $avg ms"
    exit 1
}
```

## Optimization Checklist

Before releasing new version:

- [ ] Run performance tests: `dotnet test --filter Performance`
- [ ] Check idle RAM: Task Manager <100MB
- [ ] Check active RAM: Peak <300MB during transcription
- [ ] Profile with dotMemory: No growing byte[] or Process objects
- [ ] Check whisper zombies: `tasklist | findstr whisper` = 0 when idle
- [ ] Test transcription latency: <800ms for tiny model
- [ ] Verify CPU usage: <5% idle, <30% during transcription
- [ ] No UI blocking: Async/await throughout
- [ ] Disposal tests pass: All IDisposable objects properly cleaned up

## Tools Summary

| Tool | Purpose | When to Use |
|------|---------|-------------|
| **Task Manager** | Quick RAM/CPU check | Every build, quick validation |
| **dotMemory** | Memory leak detection | After major changes, before release |
| **PerfView** | CPU profiling | When CPU >10%, optimization needed |
| **Performance Tests** | Automated regression detection | CI/CD, every commit |
| **Benchmark Script** | Transcription speed validation | After whisper command changes |

## Historical Performance Improvements

**v1.0.84 → v1.0.88** (67-73% faster):
- Added `--entropy-thold`, `--no-fallback`, optimal threads (40% faster)
- Upgraded whisper.cpp v1.6.0 → v1.7.6 (20-40% faster)
- Added `--flash-attn` (7-12% faster)
- Q8_0 quantization (same speed, 45% smaller)

**Target**: Maintain sub-800ms transcription for tiny model
