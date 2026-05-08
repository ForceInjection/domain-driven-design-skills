---
name: production-gate
description: |
  프로덕션 배포 게이트 확인. Use when:
  (1) 프로덕션 배포 가능 여부 확인, (2) 미완료 테스트 이슈 체크,
  (3) 배포 준비 상태 리포트.
tools: [Bash, GitHub CLI]
---

> **🔔 시스템 메시지**: 이 Skill이 호출되면 `[SEMO] Skill: production-gate 호출` 시스템 메시지를 첫 줄에 출력하세요.

# Production Gate Skill

> 프로덕션 배포 가능 여부 확인

## 트리거

- "프로덕션 배포 가능", "배포해도 돼", "릴리스 준비" 키워드
- 배포 전 체크리스트 요청

## 게이트 체크 항목

1. **테스트 대기 이슈**: "테스트중" 상태 이슈 없음
2. **실패 이슈**: "수정요청" 상태 이슈 없음
3. **확인 대기**: "확인요청" 상태 이슈 없음
4. **병합 완료**: 모든 관련 이슈 "병합됨" 상태

## 게이트 쿼리

```bash
# 미완료 이슈 조회
gh api graphql -f query='
query {
  organization(login: "semicolon-devteam") {
    projectV2(number: 1) {
      items(first: 100) {
        nodes {
          content {
            ... on Issue {
              number
              title
              repository { name }
            }
          }
          fieldValueByName(name: "Status") {
            ... on ProjectV2ItemFieldSingleSelectValue {
              name
            }
          }
        }
      }
    }
  }
}' --jq '.data.organization.projectV2.items.nodes[] | select(.fieldValueByName.name | IN("테스트중", "수정요청", "확인요청"))'
```

## 출력 형식

### 배포 가능

```markdown
[SEMO] Skill: production-gate 호출

## ✅ 프로덕션 배포 가능

### 게이트 체크

| 항목 | 상태 | 상세 |
|------|------|------|
| 테스트 대기 | ✅ 0건 | 모든 테스트 완료 |
| 수정 필요 | ✅ 0건 | 미해결 이슈 없음 |
| 확인 대기 | ✅ 0건 | 대기 이슈 없음 |

### 병합 완료 이슈

최근 병합된 이슈:
- cm-office#45: 댓글 기능 추가
- cm-office#48: 좋아요 버튼
- core-backend#88: 인증 API 수정

🚀 **프로덕션 배포를 진행해도 좋습니다.**
```

### 배포 불가

```markdown
[SEMO] Skill: production-gate 호출

## ❌ 프로덕션 배포 불가

### 게이트 체크

| 항목 | 상태 | 상세 |
|------|------|------|
| 테스트 대기 | ❌ 2건 | 테스트 필요 |
| 수정 필요 | ❌ 1건 | 수정 대기 중 |
| 확인 대기 | ✅ 0건 | - |

### 미완료 이슈

#### 테스트 대기

| 이슈 | 제목 | 담당자 |
|------|------|--------|
| cm-office#52 | 프로필 수정 | @developer1 |
| cm-office#55 | 알림 기능 | @developer2 |

#### 수정 필요

| 이슈 | 제목 | 담당자 |
|------|------|--------|
| cm-office#48 | 좋아요 버튼 | @developer3 |

### 권장 조치

1. 테스트 대기 이슈 테스트 진행
2. 수정 필요 이슈 개발자 확인
3. 모든 이슈 "병합됨" 상태 후 배포

⛔ **현재 상태에서는 프로덕션 배포를 권장하지 않습니다.**
```

## 릴리스 노트 생성

배포 가능 시 릴리스 노트 초안:

```markdown
## 릴리스 노트 (초안)

### 이번 릴리스 포함 내용

**Features**
- 댓글 기능 추가 (#45)
- 좋아요 버튼 (#48)

**Fixes**
- 인증 API 수정 (#88)

### 테스트 완료

- 모든 이슈 QA 테스트 통과
- Iteration 평균: 1.5회
```

## References

- [Gate Criteria](references/gate-criteria.md)
- [Release Process](references/release-process.md)

## Related

- [qa-master Agent](../../agents/qa-master/qa-master.md)
- [test-queue Skill](../test-queue/SKILL.md)
