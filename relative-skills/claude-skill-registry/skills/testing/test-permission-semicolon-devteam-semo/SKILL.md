---
name: test-permission
description: |
  Remote App 권한 요청 UI 테스트용 스킬. Use when (1) 권한 요청 UI 테스트,
  (2) Hook → Remote 연동 검증, (3) awaiting_type=permission 시뮬레이션.
tools: [mcp]
model: inherit
---

> **시스템 메시지**: 이 Skill이 호출되면 `[SEMO] Skill: test-permission 호출` 시스템 메시지를 첫 줄에 출력하세요.

# test-permission Skill

> Remote App의 권한 요청 UI를 테스트하기 위한 개발/디버깅 스킬

## Purpose

Remote App에서 권한 요청 UI가 정상 동작하는지 테스트합니다:
- `awaiting_type: permission` 상태 시뮬레이션
- 권한 요청 메시지 렌더링 확인
- 승인/거부 응답 처리 검증
- Hook → Edge Function → Remote App 플로우 테스트

## 트리거

- "권한 요청 테스트"
- "test permission"
- "remote permission 테스트"

## Workflow

```text
스킬 호출
    ↓
1. remote_requests 테이블에 테스트 권한 요청 저장
   - type: "permission"
   - tool: "TestBashCommand"
   - status: "pending"
    ↓
2. (옵션) hook-notify Edge Function 호출
   - Push 알림 트리거
    ↓
3. Remote App에서 승인/거부 UI 렌더링 대기
    ↓
4. 사용자 응답 또는 타임아웃
    ↓
5. 결과 출력
```

## Execution

### 테스트 권한 요청 생성

```bash
mcp__semo-integrations__remote_request(
  session_id: "{current_session_id}",
  type: "permission",
  tool: "Bash",
  message: "[테스트] 다음 명령어를 실행해도 될까요?\n\n`echo 'Hello from test-permission'`",
  metadata: {
    command: "echo 'Hello from test-permission'",
    is_test: true
  }
)
```

### Hook 알림 테스트 (선택)

```bash
# Edge Function 직접 호출로 Push 알림 테스트
curl -X POST "https://{supabase_url}/functions/v1/hook-notify" \
  -H "Authorization: Bearer {service_role_key}" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "{session_id}",
    "type": "permission",
    "message": "테스트 권한 요청"
  }'
```

### 응답 대기

```bash
# 60초 타임아웃으로 응답 대기
mcp__semo-integrations__remote_await(
  request_id: "{request_id}",
  timeout: 60
)
```

## Output

### 성공 (승인됨)

```markdown
[SEMO] Skill: test-permission 호출

## 권한 요청 테스트 생성됨

**Request ID**: def456
**Type**: permission
**Tool**: Bash
**Message**:
> [테스트] 다음 명령어를 실행해도 될까요?
> `echo 'Hello from test-permission'`

Remote App에서 응답을 기다리는 중...

---

✅ **승인됨**

**응답**: approve
**응답 시간**: 3.8초
**메시지**: 사용자가 승인함
```

### 거부됨

```markdown
[SEMO] Skill: test-permission 호출

## 권한 요청 테스트 생성됨

**Request ID**: def456
**Type**: permission

Remote App에서 응답을 기다리는 중...

---

❌ **거부됨**

**응답**: deny
**응답 시간**: 2.1초
**메시지**: 사용자가 거부함
```

### 타임아웃

```markdown
[SEMO] Skill: test-permission 호출

## 권한 요청 테스트 생성됨

**Request ID**: def456
**Type**: permission

Remote App에서 응답을 기다리는 중...

---

⏱️ **타임아웃**

60초 내에 응답이 없었습니다.
- Remote App이 열려 있는지 확인
- Push 알림이 도착했는지 확인
- 네트워크 연결 상태 확인
```

## Advanced: Hook 플로우 테스트

### 전체 플로우 검증

```text
test-permission 호출
    ↓
1. remote_requests INSERT
    ↓
2. hook-notify Edge Function 호출
    ↓
3. Push 알림 발송 (FCM/APNs)
    ↓
4. Remote App 수신 → UI 표시
    ↓
5. 사용자 응답 → remote_requests UPDATE
    ↓
6. Claude Code 응답 수신
    ↓
7. 결과 출력
```

### 각 단계 검증 방법

| 단계 | 검증 방법 |
|------|----------|
| DB INSERT | Supabase 대시보드에서 remote_requests 확인 |
| Edge Function | Supabase Logs에서 hook-notify 로그 확인 |
| Push 알림 | 모바일 기기에서 알림 수신 확인 |
| Remote App UI | PWA에서 권한 요청 UI 표시 확인 |
| 응답 처리 | DB에서 status=approved/denied 확인 |

## Error Handling

### DB 연결 실패

```markdown
⚠️ Remote DB 연결 실패

SEMO_DB_PASSWORD 환경 변수를 확인하세요.
```

### Edge Function 호출 실패

```markdown
⚠️ Hook 알림 전송 실패

Edge Function URL 및 Service Role Key를 확인하세요.
```

## SEMO Message Format

```markdown
[SEMO] Skill: test-permission 호출

[SEMO] Skill: test-permission 완료 - {approve|deny|timeout}
```

## References

- [remote-bridge Skill](../remote-bridge/SKILL.md)
- [CLAUDE.md](../../CLAUDE.md) - Remote API 호출 규칙
- [semo-hooks](../../../semo-hooks/) - Hook 시스템
