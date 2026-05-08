---
name: script-bugfix
description: Debug and fix complex scripts by isolating side effects, extracting core logic into a controlled environment, validating behavior there, then reintegrating with minimal changes. Use this when scripts lack unit tests and are hard to reason about due to IO, environment, or orchestration complexity.
---

This skill guides safe and effective bug fixing in complex, side-effect-heavy scripts (especially shell scripts) by **reducing cognitive load and state space before attempting a fix**.

The goal is not to refactor the whole system, but to **locate the root cause** by temporarily transforming the problem into a no-side-effect form.

## Core Principle

**Isolate side effects → Fix core logic → Minimize integration**

Treat debugging as a process of **complexity reduction**, not trial-and-error.

## When to Use

Use this skill when:
- The script performs IO, calls external commands, mutates environment, or depends on timing.
- There is little or no unit test coverage.
- Bugs are hard to reproduce or reason about in the full system.
- Only a specific logic slice actually needs fixing.

## Method

First, identify the **core logic** that likely contains the bug. This is the part that transforms inputs into decisions or outputs, not the part that touches the outside world.

Next, **isolate side effects**:
- Do not debug inside the live system.
- Create a local, controlled environment (e.g. an internal folder) where side effects are replaced with mocks, stubs, or fixed inputs.
- Make behavior deterministic and repeatable.

Then, **extract the logic**:
- Move or reimplement the core logic so it can run without real filesystem, network, time, or external commands.
- Pass all dependencies explicitly instead of reading global state.

Now, **debug and fix**:
- Reproduce the bug inside the controlled environment.
- Fix the logic where inputs and outputs are clear.
- Validate correctness through repeated runs, not intuition.

Finally, **reintegrate minimally**:
- Bring the fixed logic back into the original script.
- Change as little orchestration code as possible.
- Avoid unrelated refactors during integration.

## Debugging Mindset

- Reduce the problem’s state space before reasoning.
- Prefer controlled experiments over live-system probing.
- Treat side effects as noise until logic is proven correct.
- Aim for local certainty before global confidence.

This skill prioritizes **root cause clarity over speed**, and **determinism over cleverness**.

