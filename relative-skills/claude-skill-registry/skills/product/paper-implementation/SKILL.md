---
name: paper-implementation
description: Implement research papers from arxiv. Use when the user provides an arxiv link, asks to implement a paper, or wants to reproduce research results.
---

# Paper Implementation

## Input
Require arxiv link (not PDF). Fetch LaTeX: `https://arxiv.org/e-print/XXXX.XXXXX` (.tar.gz with .tex files)

## Phases

### 1. Discovery
Parse LaTeX for: architecture, algorithms, hyperparameters, loss functions, datasets.
Search existing GitHub implementations. Note ambiguities.

Gather: Scope (train/inference/finetune)? Scale (model size, compute)? Baseline codebase? Priority (accuracy/speed/memory)? Validation method?

### 2. Verification
If repo exists: audit against LaTeX source. Check architecture, hyperparameters, training procedure. Identify discrepancies.

### 3. Refinement
Present findings, ask questions, iterate until execution steps are perfectly clear.

### 4. Implementation
Build/modify code. Write correctness tests. Profile performance.

### 5. Optimization (optional)
Profile with nsight-systems/torch.profiler. Write custom CUDA/Triton kernels. Benchmark with measurements.

## Compute Strategy
- Local 3090: quick tests, debugging, small validation
- VP H100s: training runs, large experiments (ask before provisioning)

## On arxiv link
1. Parse LaTeX source
2. Search existing implementations
3. Present structured questions
4. Wait for answers, refine, then proceed autonomously
