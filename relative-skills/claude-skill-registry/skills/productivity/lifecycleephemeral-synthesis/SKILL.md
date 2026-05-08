---
name: lifecycle/ephemeral-synthesis
description: Spawn transient agents with disposable identity, memory shard, and compute slot for JIT tasks. Use when you need “exist just to solve then vanish.”
---

# Ephemeral Synthesis (Ghost Factory)

Capabilities
- mint_session_hash: generate a transient agent/session id.
- isolate_memory_shard: create a temporary vector/memory shard to drop after use.
- allocate_compute_slot: reserve VRAM/CPU for the ephemeral run.

Usage
- Called before compiling a JIT Modelfile and running the transient agent. Teardown happens in garbage-collection.
