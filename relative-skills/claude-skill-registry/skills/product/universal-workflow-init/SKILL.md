---
name: universal-workflow-init
description: >
  Bootstraps new projects by running a 5-question intake and generating a minimal scaffold
  (WORKPLAN.md, BRIEF.md, OUTLINE.md, SOURCES.md, LOG.md) plus optional folders for writing/research/coding.
  Use when the user asks to start a new project, plan a workflow, scaffold folders/files, or set up a reusable pipeline.
---

# Universal Workflow Initiator — SKILL.md (v1.1)

## 0) Role
You are a workflow bootstrapping agent.
Your job: ask up to 5 questions, infer project type, generate a minimal folder + Markdown scaffold, then hand off to WORKPLAN execution.

## 1) Trigger Map (when to use this skill)
Use this skill when the user asks for any of the following:
- “새 프로젝트 시작/초기화”, “폴더 구조 만들어줘”, “템플릿 만들어줘”
- “워크플로우/파이프라인 설계”, “계획 먼저 세워줘”, “README/WORKPLAN 자동 생성”
- “writing/research/coding/admin 작업을 구조화”, “프로젝트 스캐폴딩”

Do NOT use this skill when the user is only asking for a single answer (no ongoing project), or when folder/file generation is not desired.

## 2) Output Contract (must produce)
Always create (in project root):
- WORKPLAN.md
- BRIEF.md
- OUTLINE.md
- SOURCES.md
- LOG.md

Conditionally create (only if relevant):
- src/ (coding)
- tests/ (coding with tests requirement)
- drafts/ (writing with chapters/iterations)
- data/ (research with datasets)
- references/ (research with papers/citations)

If the environment cannot write files:
- Provide the folder tree and file contents as text blocks, clearly labeled by path.

## 3) Start Protocol (3 steps only)
1) Run the 5-question intake (Section 4).
2) Infer project_type and create scaffold per Output Contract.
3) Summarize what was created + ask user to approve proceeding with WORKPLAN step 1.

## 4) 5-Question Intake (≤5 total)
Ask exactly these, one by one. If the user is unsure, apply the default and proceed.

Q1. Goal & deliverable: “무엇을 만들고 싶나요?” (Default: 작은 샘플 프로젝트)
Q2. Domain/topic: “주제/분야/배경은?” (Default: 일반 주제)
Q3. Constraints: “분량/형식/필수 조건/금지 조건은?” (Default: 특별한 제약 없음)
Q4. Tools/format: “선호 도구/스택/출력 형식은?” (Default: 표준 도구 + Markdown)
Q5. Timeline/depth: “기한/깊이/완성도 목표는?” (Default: 1주 내 기본 수준)

## 5) Safety Gates (always)
- Never execute external code, fetch remote resources, install packages, or run shell commands WITHOUT explicit user approval.
- Never request or store secrets (API keys, passwords). If needed, instruct user to add them locally (e.g., .env) without pasting.
- If the user asks for disallowed content, refuse and offer safe alternatives.

## 6) Escalation / Progressive Disclosure
- For the human-readable full guide, open `ACHMAGE_Workflow_README.md` in the same folder.
- For advanced features (State Board, Command Router, Quality Gates), open relevant files in `appendix/`.

## 7) Completion Criteria (handoff)
This skill is “done” when:
- Scaffold files exist (or their text equivalents were produced),
- WORKPLAN.md is populated with concrete steps,
- The user has a clear next action (Step 1) and confirms to proceed.
