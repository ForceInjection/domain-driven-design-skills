---
name: performance-optimization
description: Performance optimization playbook (measure → diagnose → fix → verify) for this repo (React + R3F + Three.js + Vite). Use when asked to improve FPS, reduce jank, lower draw calls, optimize loading/bundle size, or investigate CPU/GPU/memory bottlenecks.
---

# Performance Optimization (Opt-in)

Use this skill to make performance work repeatable and evidence-driven.

## Workflow (always follow)

1. **Define the symptom + target**
   - Runtime: FPS drops, stutters, GPU/CPU pegged, memory growth.
   - Load time: slow first paint, large bundle, long shader compile.
   - Pick a measurable target (e.g., steady 60 FPS, lower draw calls, smaller JS).

2. **Measure before changing code**
   - Reproduce the issue and capture one of:
     - Browser Performance trace (CPU main thread)
     - R3F/Three stats (FPS, draw calls, triangles)
     - Memory timeline (detached nodes, heap growth)

3. **Classify the bottleneck**
   - **CPU-bound**: heavy JS, too many React renders, expensive per-frame work.
   - **GPU-bound**: too many draw calls, heavy shaders/postprocessing, high DPR.
   - **IO/Load-bound**: big bundles/assets, blocking work on startup.
   - **Memory-bound**: leaks in textures/geometries/materials, retained arrays.

4. **Apply the smallest fix that moves the metric**
   - Prefer fixes that reduce _work per frame_ and _draw calls_.
   - Keep changes surgical and verify the metric improved.

5. **Verify and guard against regressions**
   - Run `npm test`, `npm run lint`, `npm run typecheck`.
   - If you introduced a new helper/heuristic, add a small unit test.

## R3F / Three.js tactics (common wins)

- **Draw calls**: prefer instancing/merging; reduce unique materials.
- **DPR**: cap DPR or use dynamic DPR.
  - If you need dynamic DPR, use the existing `dynamic-res-scaler` skill.
- **Per-frame work**: keep `useFrame` callbacks tiny; avoid allocations inside `useFrame`.
- **Memoization**: cache geometries/materials/textures; reuse vectors/quaternions.
- **Postprocessing**: disable/scale effects on low perf; prefer fewer passes.
- **Shadows**: reduce shadow map size; limit shadow-casting lights.

## React tactics (common wins)

- Avoid state updates every frame; use refs for frame-local values.
- Stabilize props to prevent re-render cascades.
- Split heavy components; lazy-load non-critical UI where appropriate.

## When to load deeper reference material

- For generic perf checklists across frontend/backend/db: read `references/performance-optimization.md`.
- For dynamic DPR in this repo: read the `dynamic-res-scaler` skill.
- For offloading CPU-heavy loops: consider the `js-worker-multithreading` skill.
