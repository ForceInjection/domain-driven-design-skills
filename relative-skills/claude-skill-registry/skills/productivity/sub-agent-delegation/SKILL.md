---
name: sub-agent-delegation
description: Delegate complex tasks to sub-agents for parallel autonomous work. Use when GPU kernel optimization, numerical correctness verification, performance profiling, or long-running validation would benefit from focused independent execution.
---

# Sub-Agent Delegation

## Permissions
- NEVER spawn without explicit permission
- ASK first: "I've identified [TASK] for sub-agent delegation. Should I spawn one?"
- Explain WHY before requesting

## When to Delegate
- GPU kernel optimization with iterative benchmarking
- Numerical correctness verification across test cases
- Performance profiling and analysis
- Parallel investigation of independent code paths
- Long-running validation suites

## Patterns
- **Parallel**: Optimize independent kernels simultaneously (attention to A, MLP to B)
- **Correctness First**: Make tests pass before performance
- **Incremental**: Iterate until target speedup or report blockers

## Kernel Optimization Template
```
Optimize [OPERATION] in [FILE].
Context: [current impl], [bottleneck source], [target HW: 3090/H100], [use case: train/inference]
Requirements:
1. Implement with Triton/CUDA
2. Verify: torch.allclose(atol=1e-5, rtol=1e-5), gradients match autograd
3. Benchmark: warmup=10, bench=100, report min/max/mean/std us
4. Scales: (1,128), (8,512), (32,2048)
Report: correctness status, perf table (scale, baseline_us, opt_us, speedup), memory
```

## Workflow
Setup -> Develop -> Verify -> Benchmark -> Report

## Requirements
- Report measured numbers, never estimates
- Include methodology (warmup, iterations, sync)
- Flag regressions immediately
