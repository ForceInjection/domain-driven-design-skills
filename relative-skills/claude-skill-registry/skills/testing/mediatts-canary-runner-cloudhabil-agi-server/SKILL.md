---
name: media/tts-canary-runner
description: Run TTS canary tests, measure audio quality/latency, and rollback on threshold breaches. Use before rolling out new voices or pipelines.
---

# TTS Canary Runner

Capabilities
- run_canary: execute small-sample TTS runs per voice/model.
- evaluate_quality: score latency/artefacts/volume and compare to thresholds.
- trigger_rollback: stop rollout and flag failures if thresholds exceeded.

Dependencies
- reliability-budget
- ops-chief-of-staff (optional scheduling)

Inputs
- voice configs, test scripts, thresholds.

Outputs
- canary report with pass/fail and metrics.
