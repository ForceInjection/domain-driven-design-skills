---
name: use-zfeats
description: Plan and execute complex features using markdown checklists. Use when the user asks to "plan a feature", "create a checklist", or "break down a task".
allowed-tools: Read, Write, Edit, Glob, Bash
---

# Use zfeats for plans

## Instructions
1) Create or open a zfeats markdown file named after the feature (kebab-case) under `zfeats/` (e.g., `zfeats/new-feature.md`).
2) At the top, add a short context/goal, then enumerate steps as checkbox lines only: `- [ ] step detail` (no unchecked bullets without boxes).
3) Steps should be actionable, scoped, and ordered; avoid vague items. Split big steps until each can be finished in one go.
4) When implementing, work from the checklist in order. After completing a step, immediately update the same file to `- [x] ...` with any brief note if useful.
5) If new work is discovered, append new `- [ ]` items; do not delete history unless invalid—strike or annotate instead.
6) Keep the checklist as the source of truth while coding; ensure code changes correspond to items and mark them done only after verification/tests for that step.
7) When finished, ensure all planned items are `- [x]` or explicitly documented as deferred.

## Example prompts
- "为多平台支持写一份 zfeats 计划并开始执行"
- "把发送队列优化拆分为清单，完成第一步并勾选"
- "查看并更新 zfeats/msg-queue.md 的完成情况"
