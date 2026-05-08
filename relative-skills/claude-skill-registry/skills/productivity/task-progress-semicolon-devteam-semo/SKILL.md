---
name: task-progress
description: Track developer task progress with automated checklist and workflow support. Use when (1) developer is assigned an issue, (2) checking current progress status, (3) tracking development workflow from assignment to review, (4) automating workflow steps.
tools: [Bash, Read, Grep, GitHub CLI]
---

> **🔔 시스템 메시지**: 이 Skill이 호출되면 `[SEMO] Skill: task-progress 호출 - {이슈번호}` 시스템 메시지를 첫 줄에 출력하세요.

# task-progress Skill

> 개발자 업무 진행도를 체크리스트 형태로 표시하고 자동 진행 지원

## 트리거

- `/SEMO:task-progress` 명령어
- "어디까지 했어", "현황", "체크리스트", "진행도" 키워드
- 이슈 URL 제공 시 orchestrator가 자동 호출
- "cm-office#32 할당받았어요" 패턴 감지 시

## 개발자 전체 프로세스

```text
1. 업무할당 (검수대기 → 검수완료)
2. GitHub Project 상태 변경 (검수완료 → 작업중) ← skill:project-board 자동화
3. dev 브랜치에서 Spec 작성 (spec.md, plan.md, tasks.md) ← skill:spec
4. Spec 커밋 & 푸시 (원격에 Spec 공유) ← 📝 #{이슈번호}
5. Feature 브랜치 생성 (Spec 완료 후)
6. Draft PR 생성
7. 실제 코드 구현 (ADD Phase 4) ← skill:implement
8. 테스트코드 작성 및 테스트 진행
9. 린트 및 빌드 통과
10. 푸시 및 리뷰 요청 (작업중 → 리뷰요청) ← skill:project-board 자동화
11. PR 승인 및 dev 머지 (리뷰요청 → 테스트중) ← skill:project-board 자동화
12. STG 환경 QA 테스트 (테스트중 → 병합됨)
```

> **핵심 변경**: Spec 작성은 dev 브랜치에서 수행 → 원격 푸시 → Feature 브랜치 생성
>
> **목적**: 다른 작업자도 특정 도메인의 Spec을 공유받을 수 있도록 함

### GitHub Project 상태 흐름

> **SoT**: 상태 목록은 `이슈관리` Project에서 직접 조회 - [project-status.md](../git-workflow/references/project-status.md) 참조

```text
검수대기 → 검수완료 → 작업중 → 리뷰요청 → 테스트중 → 병합됨
                        ↓         ↑
                    확인요청    수정요청
```

## Quick Checks

| Step | Command |
|------|---------|
| 브랜치 | `git branch --show-current` |
| PR 확인 | `gh pr list --head {branch} --json number,isDraft` |
| 린트 | `npm run lint` |
| 타입체크 | `npx tsc --noEmit` |
| 미푸시 확인 | `git log origin/{branch}..HEAD --oneline` |

## 자동화 가능 작업

- Draft PR 자동 생성 (빈 커밋 + gh pr create --draft)
- GitHub Project 상태 자동 변경
- 작업완료일 자동 설정

## SEMO 메타데이터

작업 시작 시 `~/.claude.json` 업데이트:

```json
{
  "SEMO": {
    "currentTask": {
      "issueNumber": 32,
      "repo": "cm-office",
      "branch": "feature/32-add-comments"
    }
  }
}
```

## 프로젝트 보드 자동 연동

### 작업 시작 시 (Step 2)

이슈 작업 시작 시 자동으로 상태를 "작업중"으로 변경하고 **시작일** 설정:

```markdown
[SEMO] Skill: task-progress → 프로젝트 보드 상태 변경

📋 **이슈**: {repo}#{issue_number}
🔄 **상태 변경**: 검수완료 → **작업중**
📅 **시작일 설정**: {오늘 날짜}

✅ 프로젝트 보드 연동 완료
```

### 리뷰 요청 시 (Step 10)

PR Ready 상태가 되면 자동으로 상태를 "리뷰요청"으로 변경하고 **종료일** 설정:

```markdown
[SEMO] Skill: task-progress → 프로젝트 보드 상태 변경

📋 **이슈**: {repo}#{issue_number}
🔀 **PR**: #{pr_number} Ready for Review
🔄 **상태 변경**: 작업중 → **리뷰요청**
📅 **종료일 설정**: {오늘 날짜}

✅ 프로젝트 보드 연동 완료
```

### 호출 방법

```bash
# skill: project-board 호출
skill: project-board({
  repo: "{repo}",
  issue_number: {issue_number},
  target_status: "작업중"  # 또는 "리뷰요청"
})
```

> 📖 상세 API: [../project-board/references/api-commands.md](../project-board/references/api-commands.md)

## Related Skills

- `health-check` - 환경 검증
- `implement` - 구현 진행
- `project-board` - 프로젝트 보드 연동

## References

For detailed documentation, see:

- [Verification Steps](references/verification-steps.md) - 12단계 검증 로직 상세
- [Automation](references/automation.md) - 자동화 명령, 출력 형식, 메타데이터
- [Project Board API](../project-board/references/api-commands.md) - 프로젝트 보드 API
