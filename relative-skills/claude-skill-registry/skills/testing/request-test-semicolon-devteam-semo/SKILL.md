---
name: request-test
description: |
  테스트 요청 메시지 생성 및 전송. Use when (1) Issue 테스트 요청,
  (2) QA에게 테스트 알림, (3) 환경 정보 포함 메시지 생성.
tools: [Bash, Read, Slack]
model: inherit
---

> **시스템 메시지**: 이 Skill이 호출되면 `[SEMO] Skill: request-test 호출 - #{issue_number}` 시스템 메시지를 첫 줄에 출력하세요.

# request-test Skill

> 테스트 요청 메시지를 환경 정보와 함께 자동 생성

## Purpose

Issue에 대한 테스트 요청 시 환경 정보(URL 등)를 자동으로 첨부하여 QA/테스터에게 전달합니다.

## 트리거

- "#{issue} 테스트 요청해줘"
- "테스트 요청" + issue 번호
- 명시적 호출: `skill:request-test`

## 🔴 필수 참조

| 항목 | 파일/API |
|------|----------|
| **환경 정보** | `.claude/memory/projects.md` > 환경 정보 섹션 |
| **테스터 정보** | `semo-core/_shared/team-members.md` |
| **프로젝트 채널** | Slack API 동적 조회 (레포명 기반 채널 매칭) |

## Quick Start

```bash
# 1. Issue 정보 조회
ISSUE=$(gh issue view 482 --repo semicolon-devteam/cm-land --json title,url,state)
TITLE=$(echo "$ISSUE" | jq -r '.title')
URL=$(echo "$ISSUE" | jq -r '.url')

# 2. 레포지토리에서 환경 URL 결정
# cm-land → stg: https://stg.cm-land.com
# cm-office → stg: https://stg.cm-office.com

# 3. 메시지 생성 및 Slack 전송
```

## Workflow

```
테스트 요청
    ↓
1. Issue 정보 조회 (gh issue view)
    ↓
2. 레포지토리 확인 → 환경 URL 매핑
    ↓
3. 레포지토리명으로 Slack 채널 동적 조회 (Slack API)
    ↓
4. 테스터 GitHub ID → Slack Name 매핑 (team-members.md)
    ↓
5. Slack User ID 조회 (slack_lookup_user)
    ↓
6. 메시지 생성 (테스터 멘션 포함)
    ↓
7. 프로젝트 채널로 Slack 전송
    ↓
완료
```

## 🔴 프로젝트 채널 동적 조회 (NON-NEGOTIABLE)

> **⚠️ 하드코딩된 채널 매핑 대신 Slack API를 통해 채널을 동적으로 조회합니다.**

### 채널 매칭 로직

```text
레포지토리명: cm-labor-union
    ↓
1차 시도: #cm-labor-union (레포명 그대로)
    ↓
2차 시도: #{repo} 형식 변환 (하이픈 유지)
    ↓
Fallback: #_협업 (채널 없을 경우)
```

### MCP 도구 사용

```bash
# Slack 채널 목록에서 레포지토리명과 일치하는 채널 검색
# semo-integrations MCP를 통해 Supabase 또는 직접 Slack API 호출

# 방법 1: Slack conversations.list API 활용
# Bot이 참여한 채널 중 레포명과 일치하는 채널 찾기

# 방법 2: 채널명 직접 전송 시도 → 실패 시 Fallback
mcp__semo-integrations__slack_send_message(
  channel: "#cm-labor-union",  # 레포명으로 채널 시도
  text: "테스트 메시지"
)
# 성공 → 해당 채널 사용
# 실패 (channel_not_found) → #_협업으로 Fallback
```

### 채널 검색 우선순위

| 순서 | 채널명 패턴                    | 예시                         |
|------|-------------------------------|------------------------------|
| 1    | `#{repo}` (레포명 그대로)      | `#cm-labor-union`            |
| 2    | `#_{repo}` (언더스코어 접두사) | `#_cm-labor-union`           |
| 3    | `#_협업` (Fallback)           | 항상 존재하는 기본 채널       |

## 환경 URL 매핑

| 레포지토리 | 환경 | URL |
|-----------|------|-----|
| cm-land | dev | https://dev.cm-land.com |
| cm-land | stg | https://stg.cm-land.com |
| cm-land | prd | https://cm-land.com |
| cm-office | dev | https://dev.cm-office.com |
| cm-office | stg | https://stg.cm-office.com |
| cm-office | prd | https://cm-office.com |
| cm-labor-union | - | Vercel Preview (PR별) |

> **기본값**: stg 환경 (QA 테스트 기준)

## 🔴 Fallback 규칙

> **채널을 찾을 수 없거나 참조 파일이 없어도 워크플로우가 중단되지 않도록 기본값을 사용합니다.**

| 항목 | Fallback 규칙 |
|------|--------------|
| **프로젝트 채널** | Slack API 조회 실패 → `#_협업` 사용 |
| **테스터** | 지정 없음 → `Goni (kokkh)` 기본 QA 담당자 |
| **환경 URL** | 매핑 없음 → Issue URL만 표시 (환경 URL 생략) |

### Fallback 적용 예시

```text
레포지토리: unknown-repo
    ↓
1차 시도: #unknown-repo → channel_not_found
    ↓
2차 시도: #_unknown-repo → channel_not_found
    ↓
Fallback: #_협업 채널 사용
    ↓
메시지에 "[Fallback: 프로젝트 채널 미발견]" 표시
```

## 환경 선택 규칙

| Issue Status | 권장 환경 | 이유 |
|--------------|----------|------|
| 리뷰요청 | stg | 코드 리뷰 후 STG 배포 예정 |
| 테스트중 | stg | QA 테스트 진행 |
| 작업중 | dev | 개발 중 확인 |

## 🔴 Slack 실제 멘션 (NON-NEGOTIABLE)

> **⚠️ 텍스트 `@이름`이 아닌 실제 Slack 멘션 `<@SLACK_USER_ID>` 사용 필수!**

### 멘션 변환 프로세스

```bash
# 1. GitHub ID → Slack Display Name (team-members.md 참조)
# kokkh → Goni

# 2. Slack User ID 조회 (MCP 도구 사용)
mcp__semo-integrations__slack_lookup_user(name: "Goni")
# 반환값 예시: { "user_id": "U12345678", "display_name": "Goni" }

# 3. 실제 멘션 형식으로 메시지 생성
# ❌ 잘못된 예: "@Goni" (텍스트만 표시됨, 멘션 안 됨)
# ✅ 올바른 예: "<@U12345678>" (실제 멘션됨, 알림 발송)
```

### 멘션 포함 메시지 전송

```bash
# MCP 도구를 사용하여 메시지 전송
mcp__semo-integrations__slack_send_message(
  channel: "#프로젝트채널",
  text: "<@U12345678> [이슈제목] 테스트 요청드립니다\n\n📍 테스트 환경: STG\n🔗 URL: https://stg.example.com\n📋 이슈: https://github.com/..."
)
```

## 메시지 템플릿

### 기본 템플릿

```
<@{SLACK_USER_ID}> [{issue_title}] 테스트 요청드립니다

📍 테스트 환경: {env}
🔗 URL: {env_url}
📋 이슈: {issue_url}
```

### 출력 예시

```
<@U12345678> [글로벌 검색 기능 오류] 테스트 요청드립니다

📍 테스트 환경: STG
🔗 URL: https://stg.cm-land.com
📋 이슈: https://github.com/semicolon-devteam/cm-land/issues/482
```

> Slack에서 `<@U12345678>`은 **@Goni**로 렌더링되며 실제 알림이 발송됩니다.

## 입력 파라미터

| 파라미터 | 필수 | 설명 | 기본값 |
|---------|------|------|--------|
| issue | O | Issue 번호 또는 URL | - |
| repo | △ | 레포지토리 | Issue URL에서 추출 |
| env | X | 테스트 환경 | stg |
| tester | X | 테스터 멘션 | @Goni (kokkh) |
| channel | X | Slack 채널 | 프로젝트 채널 → Fallback: #_협업 |

## 사용 예시

### 기본 사용

```
사용자: "#482 테스트 요청해줘"

[SEMO] Skill: request-test 호출 - #482

✅ 테스트 요청 메시지 전송 완료

📢 채널: #_협업
📝 메시지:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@Goni [글로벌 검색 기능 오류] 테스트 요청드립니다

📍 테스트 환경: STG
🔗 URL: https://stg.cm-land.com
📋 이슈: https://github.com/semicolon-devteam/cm-land/issues/482
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 환경 지정

```
사용자: "#482 dev 환경에서 테스트 요청해줘"

→ 📍 테스트 환경: DEV
→ 🔗 URL: https://dev.cm-land.com
```

### 테스터 지정

```
사용자: "#482 @Garden 테스트 요청해줘"

→ @Garden [글로벌 검색 기능 오류] 테스트 요청드립니다...
```

## Error Handling

### Issue를 찾을 수 없는 경우

```
⚠️ Issue #482를 찾을 수 없습니다.

레포지토리를 지정해주세요:
- "cm-land #482 테스트 요청"
- "#482 테스트 요청 (cm-land)"
```

### 환경 정보가 없는 경우

```
⚠️ {repo}의 환경 정보가 등록되어 있지 않습니다.

`.claude/memory/projects.md`에 환경 정보를 추가해주세요.
```

## SEMO Message Format

```markdown
[SEMO] Skill: request-test 호출 - #{issue_number}

[SEMO] Skill: request-test 완료 - Slack 전송됨
```

## References

- [환경 정보](/.claude/memory/projects.md#환경-정보)
- [프로젝트 채널 매핑](../../../../semo-system/semo-core/_shared/project-channels.md)
- [팀원 매핑](../../../../semo-system/semo-core/_shared/team-members.md)
- [notify-slack Skill](../../../core/skills/notify-slack/SKILL.md)
