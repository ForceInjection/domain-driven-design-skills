---
name: tuning/parameter-optimizer
description: Optimize Ollama PARAMETER values (temperature, num_ctx, top_k, top_p, repeat_penalty, stop sequences) per task. Use to translate tuning directives into runtime presets.
---

# Parameter Optimizer

Capabilities
- set_cognitive_temperature: adjust creativity vs. determinism.
- define_context_window: set num_ctx based on doc size/task.
- configure_stop_sequences: define stop tokens to bound outputs.
- penalize_repetition: adjust repeat_penalty to avoid loops.

Dependencies
- embedding-repair (diag logging)
- reliability-budget (optional SLO tuning)

Outputs
- parameter preset dict for Ollama run/create.
