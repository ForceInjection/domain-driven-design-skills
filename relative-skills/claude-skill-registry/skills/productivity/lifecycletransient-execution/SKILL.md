---
name: lifecycle/transient-execution
description: Hot-swap to the ephemeral model, run the atomic task, capture result, and hand it back. Use for spawn→solve→return flows.
---

# Transient Execution

Capabilities
- preload_ephemeral_model: ensure the temp model is loaded.
- execute_atomic_task: run the single prompt/chain.
- capture_result_payload: return answer/artifact to caller.

Inputs
- model_name, prompt/task payload.

Outputs
- result payload, timings, any stderr.
