---
name: estimate-epic-timeline
description: |
  Estimate Epic timeline by summing all Task points. Use when (1) tasks.md 생성 후,
  (2) Epic 전체 일정 예측 필요, (3) 병렬/순차 작업 및 Critical Path 분석.
tools: [Bash, GitHub CLI]
---

> **시스템 메시지**: `[SEMO] Skill: estimate-epic-timeline 호출 - {Epic 번호}`

# estimate-epic-timeline Skill

> Epic 전체 일정 예측

## Purpose

tasks.md의 모든 Task Point를 합산하여 Epic 전체 일정을 예측합니다.

## Process

1. tasks.md에서 모든 Task의 Point 수집
2. 병렬/순차 작업 구분 (Layer 기반)
3. 총 예상 일정 계산

## 일정 계산 공식

- **1 Point = 0.5일** (4시간)
- **디자인 Task**: 다른 작업과 병렬 가능
- **백엔드 → 프론트**: 순차 작업

## Output Format

```json
{
  "total_points": 23,
  "estimated_days": 11.5,
  "estimated_weeks": 2.3,
  "parallel_tasks": ["디자인 작업"],
  "critical_path": ["백엔드 API", "프론트 연동", "테스트"]
}
```

### Epic 코멘트 추가

```markdown
### 📅 일정 예측

**총 작업량**: 23 Points
**예상 기간**: 11.5일 (약 2.3주)

**병렬 작업**: 디자인 (3 Points)
**순차 작업**: 백엔드 → 프론트 → 테스트

**Critical Path**: 백엔드 API (5 Points) → 프론트 연동 (8 Points) → 테스트 (3 Points)
```

## SEMO Message

```markdown
[SEMO] Skill: estimate-epic-timeline 사용

[SEMO] Reference: docs/wiki/Estimation-Guide 참조
```

## Related

- `ideate` - 아이디어 → Epic 생성
- `generate-spec` - tasks.md 생성 (이 스킬 전에 호출)
- `create-issues` - Task Issue 생성
