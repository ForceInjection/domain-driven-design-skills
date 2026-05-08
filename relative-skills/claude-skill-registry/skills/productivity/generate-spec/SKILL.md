---
name: generate-spec
description: |
  Speckit 워크플로우 통합 실행 (specify → plan → tasks → issues).
  Epic에서 Task Issue 생성까지 원스톱 처리.
  Use when (1) Epic 생성 후 Task 분해, (2) spec 문서 생성, (3) Task Issue 생성.
tools: [Read, Write, Edit, Bash, GitHub CLI]
location: project
triggers:
  - 명세 작성
  - spec 작성
  - 스펙 작성해줘
  - speckit
  - 태스크 만들어줘
  - 태스크 만들어
  - task 생성
  - task 만들어
  - 이슈 만들어줘
  - 이슈 생성해줘
  - 태스크카드 생성해줘
  - 태스크카드 만들어줘
---

> **시스템 메시지**: `[SEMO] Skill: generate-spec 호출 - {기능명/Epic 번호}`

# generate-spec Skill

**Purpose**: Speckit 워크플로우 통합 실행 (Epic → spec → plan → tasks → Task Issues)

## 핵심 원칙

> **Source of Truth**: Task Issue가 Speckit 워크플로우의 진실 소스
> **통합 워크플로우**: spec 생성과 Task Issue 생성을 하나의 스킬에서 처리
> **DDD Layer 기반**: Task를 CONFIG → PROJECT → DATA → TESTS → CODE 순서로 분해

## Workflow Overview

```text
[Epic Issue]
      ↓
Phase 1: /speckit.specify → spec.md
      ↓
Phase 2: /speckit.plan → plan.md
      ↓
Phase 3: /speckit.tasks → tasks.md (DDD Layer 분해)
      ↓
Phase 4: /speckit.issues → Task Issues 생성
      ↓
[구현 시작]
```

## Phase Flow

| Phase | Command | Output | 설명 |
|-------|---------|--------|------|
| 1 | `/speckit.specify` | spec.md | 요구사항 명세 |
| 2 | `/speckit.plan` | plan.md | 구현 계획 |
| 3 | `/speckit.tasks` | tasks.md | DDD Layer 기반 Task 분해 |
| 4 | `/speckit.issues` | Task Issues | GitHub Issue 자동 생성 |

## 🔴 Phase 1: Specify (spec.md)

### Epic Issue 파싱

```bash
# Epic 본문 조회
EPIC_BODY=$(gh issue view $EPIC_NUMBER --repo semicolon-devteam/docs --json body --jq '.body')
EPIC_TITLE=$(gh issue view $EPIC_NUMBER --repo semicolon-devteam/docs --json title --jq '.title')
```

**Epic에서 추출할 정보**:

| 섹션 | spec.md 매핑 |
|------|-------------|
| Problem Statement | Background, Problem Statement |
| Goals | Goals & Non-goals |
| User Scenarios | User Stories |
| Constraints | Technical Constraints |
| Success Metrics | Success Criteria |

### spec.md 생성

```markdown
# {Feature Name} Specification

## Background
{Epic의 Problem Statement - 현재 상황}

## Problem Statement
{Epic의 Problem Statement - 문제점, 영향}

## Goals & Non-goals

### Goals
- **Primary**: {Epic의 Primary Goal}
- **Secondary**: {Epic의 Secondary Goal}

### Non-goals
- {Epic의 Non-goals}

## User Stories
{Epic의 User Scenarios를 User Story 형식으로 변환}

## Technical Constraints
{Epic의 Constraints}

## Acceptance Criteria
{Epic의 Success Metrics 기반 AC}
```

## 🔴 Phase 2: Plan (plan.md)

```markdown
# {Feature Name} Implementation Plan

## Overview
{spec.md 요약}

## Technical Approach
{기술 스택, 아키텍처 결정}

## Dependencies
{외부 의존성, 선행 작업}

## Risk Assessment
{기술적 리스크, 대안}
```

## 🔴 Phase 3: Tasks (tasks.md + DDD Layer 분해)

### DDD Layer 기반 Task 분해

> **Layer 순서**: CONFIG → PROJECT → DATA → TESTS → CODE

| Layer | 버전 | 설명 | 예시 Task |
|-------|------|------|----------|
| CONFIG | v0.1.x | 환경 설정, 의존성 | 패키지 설치, 환경변수 |
| PROJECT | v0.2.x | 프로젝트 구조 | 폴더 구조, 라우팅 |
| DATA | v0.3.x | 데이터 스키마, API | DB 스키마, API 엔드포인트 |
| TESTS | v0.4.x | 테스트 작성 | 유닛 테스트, E2E |
| CODE | v0.5.x | 비즈니스 로직 | UI 컴포넌트, 핵심 기능 |

### Layer별 정보 선별 위임

| Layer | 위임할 Dev Checklist | 위임할 Constraints |
|-------|---------------------|-------------------|
| CONFIG | - | 기술적.의존성 |
| PROJECT | - | 기술적.아키텍처 |
| DATA | 데이터 흐름, 시간/계산 | 기술적.데이터 |
| TESTS | 엣지 케이스 | - |
| CODE | 플랫폼 제약, 도메인 지식 | 기술적.플랫폼 |

### tasks.md 생성

```markdown
# {Feature Name} Tasks

## Task Overview

| ID | Layer | Task | Complexity | Dependencies |
|----|-------|------|------------|--------------|
| T1 | v0.1.x CONFIG | 환경 설정 | S | - |
| T2 | v0.2.x PROJECT | 폴더 구조 생성 | S | T1 |
| T3 | v0.3.x DATA | DB 스키마 정의 | M | T2 |
| T4 | v0.5.x CODE | UI 컴포넌트 구현 | L | T3 |

## Task Details

### T1: [v0.1.x CONFIG] 환경 설정
- **Complexity**: S
- **Dependencies**: -
- **Description**: {상세 설명}
- **Acceptance Criteria**: {AC 목록}
```

## 🔴 Phase 4: Issues (Task Issues 생성)

### Task Issue 본문 템플릿

```markdown
## 📋 {task_description}

## 🔄 Speckit Progress
- [x] specify → [spec.md]({spec_url})
- [x] plan → [plan.md]({plan_url})
- [x] tasks → [tasks.md]({tasks_url})
- [ ] implement

## 🎯 Problem Context
<!-- Epic에서 위임 (이 Task 관련 부분만) -->
{Epic Problem Statement에서 관련 부분}

## 🎯 Goals
- {관련 Primary Goal}

## 👤 User Scenario
| Step | 사용자 액션 | 이 Task의 역할 |
|------|------------|---------------|
| {N} | {액션} | {역할} |

## ⚠️ Constraints
### 기술적 제약
- {이 Layer 관련 제약}

### 개발자 체크리스트
- [ ] {해당 카테고리 항목}

## 🎯 Acceptance Criteria
- [ ] {AC 1}
- [ ] {AC 2}

## 🧪 테스트 요구사항
### 엔지니어 테스트
- [ ] {테스트 케이스}: {예상 결과}

### QA 테스트
| Step | Action | Expected |
|------|--------|----------|
| 1 | {동작} | {결과} |

## 🔗 Dependencies
- Depends on: #{issue}
- Blocks: #{issue}

## 📊 Metadata
| Field | Value |
|-------|-------|
| Layer | {v0.x.x LAYER} |
| Domain | {domain} |
| Epic | #{epic_number} |
```

### GitHub 연동

```bash
# 1. Task Issue 생성
TASK_NUMBER=$(gh issue create \
  --repo semicolon-devteam/{project_repo} \
  --title "[v0.1.x CONFIG] {task_title}" \
  --body "$TASK_BODY" \
  --label "{project_label}" \
  | grep -oE '[0-9]+$')

# 2. Projects에 추가
ISSUE_NODE_ID=$(gh api repos/semicolon-devteam/{project_repo}/issues/$TASK_NUMBER \
  --jq '.node_id')

ITEM_ID=$(gh api graphql -f query='
  mutation($projectId: ID!, $contentId: ID!) {
    addProjectV2ItemById(input: {projectId: $projectId, contentId: $contentId}) {
      item { id }
    }
  }
' -f projectId="PVT_kwDOC01-Rc4AtDz2" -f contentId="$ISSUE_NODE_ID" \
  --jq '.data.addProjectV2ItemById.item.id')

# 3. Issue Type을 Task로 설정
gh api graphql -f query='
  mutation {
    updateIssue(input: {
      id: "'"$ISSUE_NODE_ID"'"
      issueTypeId: "IT_kwDOC01-Rc4BdOub"
    }) {
      issue { id title }
    }
  }
'

# 4. Status를 "검수대기"로 설정
STATUS_RESULT=$(gh api graphql -f query='
query {
  organization(login: "semicolon-devteam") {
    projectV2(number: 1) {
      field(name: "Status") {
        ... on ProjectV2SingleSelectField {
          id
          options { id name }
        }
      }
    }
  }
}')

STATUS_FIELD_ID=$(echo "$STATUS_RESULT" | jq -r '.data.organization.projectV2.field.id')
STATUS_OPTION_ID=$(echo "$STATUS_RESULT" | jq -r '.data.organization.projectV2.field.options[] | select(.name == "검수대기") | .id')

gh api graphql -f query='
  mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $optionId: String!) {
    updateProjectV2ItemFieldValue(input: {
      projectId: $projectId
      itemId: $itemId
      fieldId: $fieldId
      value: { singleSelectOptionId: $optionId }
    }) {
      projectV2Item { id }
    }
  }
' -f projectId="PVT_kwDOC01-Rc4AtDz2" \
  -f itemId="$ITEM_ID" \
  -f fieldId="$STATUS_FIELD_ID" \
  -f optionId="$STATUS_OPTION_ID"
```

## 🔴 Branch Context (필수)

> **Spec 작성은 반드시 dev 브랜치에서 수행합니다.**

| 조건 | 설명 |
|------|------|
| **필수 브랜치** | `dev` |
| **금지 브랜치** | `main`, `master`, `feature/*` |

## Output Format

### Speckit 완료

```markdown
[SEMO] Skill: generate-spec 완료

## 📋 Speckit 결과

### Epic
- 번호: #{epic_number}
- 제목: {epic_title}

### 생성된 파일
- specs/{feature}/spec.md
- specs/{feature}/plan.md
- specs/{feature}/tasks.md

### 생성된 Task Issues

| Layer | Task | Issue |
|-------|------|-------|
| v0.1.x CONFIG | {task_1} | #{issue_1} |
| v0.2.x PROJECT | {task_2} | #{issue_2} |
| v0.3.x DATA | {task_3} | #{issue_3} |
| v0.5.x CODE | {task_4} | #{issue_4} |

### Speckit 상태
모든 Task에 Speckit 체크리스트 포함:
- [x] specify → spec.md
- [x] plan → plan.md
- [x] tasks → tasks.md
- [ ] implement

### 다음 단계
1. **Spec 커밋**: `git add specs/ && git commit -m "📝 Add spec for {feature}"`
2. **구현 시작**: Feature 브랜치에서 구현
```

## Issue Title Format

```text
[v0.1.x CONFIG] Set up project dependencies
[v0.2.x PROJECT] Create folder structure for comments
[v0.3.x DATA] Define comment schema and API
[v0.5.x CODE] Implement comment UI components
```

## Issue Type ID Reference

| Type | ID | 사용 시점 |
|------|-----|----------|
| Task | `IT_kwDOC01-Rc4BdOub` | 일반 태스크 (기본값) |
| Bug | `IT_kwDOC01-Rc4BdOuc` | 버그 리포트 |
| Feature | `IT_kwDOC01-Rc4BdOud` | 기능 요청 |
| Epic | `IT_kwDOC01-Rc4BvVz5` | 에픽 생성 시 |

## Usage

```javascript
// Epic 기반 전체 Speckit 실행 (권장)
skill: generate-spec({ epic: 144 });

// 자연어 트리거
"태스크 만들어줘"
"spec 작성해줘"
"태스크카드 생성해줘"

// 특정 Phase만 실행
skill: generate-spec({ epic: 144, phase: "specify" });
skill: generate-spec({ epic: 144, phase: "tasks" });
```

## Related Skills

- `ideate` - 러프한 아이디어 → Epic (이 스킬 전에 호출)
- `create-epic` - Epic Issue 생성 헬퍼
- `implement` - 구현 단계 (이 스킬 후에 호출)
- `explore-approach` - 기술 불확실성 탐색 (spike)

## References

- [Phase Details](references/phase-details.md) - Phase 1-4 상세
- [Layer Delegation](references/layer-delegation.md) - Layer별 정보 위임 상세
- [Output Format](references/output-format.md) - 완료 리포트 형식
