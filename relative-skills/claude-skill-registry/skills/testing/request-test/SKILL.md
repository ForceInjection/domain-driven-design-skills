---
name: request-test
description: |
  QA 테스트 요청 스킬. Use when (1) 태스크카드 테스트 요청,
  (2) QA 담당자 할당, (3) 테스트 범위 지정, (4) Slack 알림 전송.
tools: [Read, Bash, mcp__semo-integrations__semo_get_slack_token]
model: inherit
---

> **시스템 메시지**: 이 Skill이 호출되면 `[SEMO] Skill: request-test 호출 - {프로젝트명}` 시스템 메시지를 첫 줄에 출력하세요.

# request-test Skill

> QA 담당자에게 테스트 요청을 전달하는 스킬

## Purpose

개발 완료된 태스크카드에 대해 QA 테스트를 요청합니다.

- GitHub 이슈 Assignee 할당
- Slack 알림 발송
- 테스트 항목 검증

## 필수 조건

### 1. 프로젝트 및 태스크카드 지정

| 필수 정보 | 설명 | 예시 |
|----------|------|------|
| 프로젝트 | GitHub 레포지토리 | `semicolon-devteam/half-time` |
| 태스크카드 | GitHub 이슈 번호 | `#123` |

### 2. QA 테스트 항목 존재 검증

태스크카드 본문에 다음 중 하나 이상 포함 필수:

- `## QA 테스트 항목` 섹션
- `## 테스트 항목` 섹션
- `- [ ]` 체크박스 형태의 테스트 케이스

**검증 실패 시**:

```markdown
[SEMO] request-test 실패

❌ 태스크카드에 QA 테스트 항목이 없습니다.

**필요 조치**:
이슈 본문에 다음 형식으로 테스트 항목을 추가하세요:

## QA 테스트 항목
- [ ] 테스트 케이스 1
- [ ] 테스트 케이스 2
```

### 3. QA 담당자 정보

> 팀원 정보는 [team-members.md](../../semo-core/_shared/team-members.md) 참조

| 역할 | GitHub ID | Slack Display Name |
|------|-----------|-------------------|
| QA | kokkh | Goni |

## 기본 설정

| 항목 | 기본값 | 설명 |
|------|--------|------|
| 기본 QA 담당자 | Goni (kokkh) | 테스트 요청 시 기본 Assignee |
| 알림 채널 | 프로젝트 채널 (동적 조회) | 협업 채널은 Fallback |

## Execution Flow

```text
1. 이슈 정보 조회 (gh CLI)
   ↓
2. QA 테스트 항목 존재 검증
   ↓
3. GitHub 이슈 Assignee 할당 (gh CLI)
   ↓
4. Slack Token 획득 (MCP)
   ↓
5. 프로젝트 채널 동적 조회 (Slack API)
   ↓
6. Slack 사용자 ID 조회 + 알림 발송 (curl)
```

## Step-by-Step Instructions

### Step 1: 이슈 정보 조회 (gh CLI)

```bash
gh issue view {이슈번호} --repo semicolon-devteam/{프로젝트} --json title,body,url
```

### Step 2: QA 테스트 항목 검증

이슈 body에서 다음 패턴 확인:

- `## QA 테스트 항목` 또는 `## 테스트 항목`
- `- [ ]` 체크박스 최소 1개 이상

### Step 3: Assignee 할당 (gh CLI)

```bash
gh issue edit {이슈번호} --repo semicolon-devteam/{프로젝트} --add-assignee kokkh
```

### Step 4: Slack Token 획득

```text
mcp__semo-integrations__semo_get_slack_token()
```

응답에서 `token:` 접두사 뒤의 토큰 값을 추출합니다.

### Step 5: 프로젝트 채널 동적 조회

> **🔴 NON-NEGOTIABLE**: 테스트 요청은 **반드시 프로젝트 채널**로 전송합니다.
> 프로젝트 채널을 찾지 못한 경우에만 협업 채널(#_협업)로 Fallback합니다.

```bash
# 프로젝트명(레포명)으로 채널 검색
# 1차: #{repo} 검색
# 2차: #_{repo} 검색
# 3차: Fallback → #_협업 (C09KNL91QBZ)

PROJECT_REPO="{프로젝트명}"  # 예: cm-labor-union

# 채널 목록에서 프로젝트 채널 검색
CHANNEL_ID=$(curl -s 'https://slack.com/api/conversations.list?types=public_channel&limit=500' \
  -H "Authorization: Bearer $TOKEN" | \
  jq -r --arg repo "$PROJECT_REPO" '
    .channels[] |
    select(.name == $repo or .name == ("_" + $repo)) |
    .id
  ' | head -1)

# Fallback: 프로젝트 채널 없으면 협업 채널 사용
if [ -z "$CHANNEL_ID" ]; then
  CHANNEL_ID="C09KNL91QBZ"  # #_협업
  echo "[SEMO] 프로젝트 채널 없음 → #_협업 사용"
fi
```

### Step 6: Slack 사용자 ID 조회 + 알림 발송

```bash
# 사용자 ID 조회
curl -s 'https://slack.com/api/users.list' \
  -H 'Authorization: Bearer {TOKEN}' | \
  jq -r '.members[] | select(.profile.display_name=="Goni") | .id'

# 알림 발송 (heredoc 방식) - 프로젝트 채널로 전송
curl -s -X POST 'https://slack.com/api/chat.postMessage' \
  -H 'Authorization: Bearer {TOKEN}' \
  -H 'Content-Type: application/json; charset=utf-8' \
  -d @- << 'EOF'
{
  "channel": "{CHANNEL_ID}",
  "text": "QA 테스트 요청",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "🧪 *QA 테스트 요청*\n\n<@{SLACK_ID}> 님, 테스트 요청드립니다.\n\n📋 *이슈*: {이슈 제목}\n🔗 *링크*: {이슈 URL}\n📝 *요청자*: {요청자}\n📁 *프로젝트*: {프로젝트명}\n\n테스트 항목을 확인하고 완료 시 체크해주세요!"
      }
    }
  ]
}
EOF
```

## Output

### 성공 시

```markdown
[SEMO] Skill: request-test 완료

✅ QA 테스트 요청 완료

**프로젝트**: semicolon-devteam/{repo}
**이슈**: #{이슈번호} - {이슈제목}
**담당자**: @kokkh (GitHub) / @Goni (Slack)
**Slack 알림**: ✅ 전송됨

> 테스트 완료 시 이슈의 체크박스를 체크하고 상태를 업데이트해주세요.
```

### 실패 시 (테스트 항목 누락)

```markdown
[SEMO] request-test 실패

❌ 태스크카드에 QA 테스트 항목이 없습니다.

**이슈**: #{이슈번호} - {이슈제목}

**필요 조치**:
이슈 본문에 다음 형식으로 테스트 항목을 추가하세요:

## QA 테스트 항목
- [ ] 테스트 케이스 1
- [ ] 테스트 케이스 2
```

## References

- [Team Members](../../semo-core/_shared/team-members.md) - GitHub/Slack ID 매핑
- [notify-slack](../notify-slack/SKILL.md) - Slack 알림 스킬
- [Project Channels](../../semo-core/_shared/project-channels.md) - 프로젝트별 채널 정보

## Triggers

| 트리거 | 예시 |
|--------|------|
| "테스트 요청" | "테스트 요청해줘" |
| "QA 요청" | "QA 요청 보내줘" |
| "request-test" | "request-test 실행" |
| "테스트 할당" | "이슈에 테스트 할당해줘" |
