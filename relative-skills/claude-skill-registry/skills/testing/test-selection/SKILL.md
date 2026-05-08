---
name: test-selection
description: |
  Remote App 선택형 UI 테스트용 스킬. Use when (1) 선택형 응답 UI 테스트,
  (2) Remote App 연동 검증, (3) awaiting_type=selection 시뮬레이션.
tools: [mcp]
model: inherit
---

> **시스템 메시지**: 이 Skill이 호출되면 `[SEMO] Skill: test-selection 호출` 시스템 메시지를 첫 줄에 출력하세요.

# test-selection Skill

> Remote App의 선택형 UI를 테스트하기 위한 개발/디버깅 스킬

## Purpose

Remote App에서 선택형 응답 UI가 정상 동작하는지 테스트합니다:
- `awaiting_type: selection` 상태 시뮬레이션
- 선택지 옵션 렌더링 확인
- 사용자 선택 응답 처리 검증

## 트리거

- "선택형 테스트"
- "test selection"
- "remote selection 테스트"

## Workflow

```text
스킬 호출
    ↓
1. remote_requests 테이블에 테스트 요청 저장
   - type: "selection"
   - options: ["Option A", "Option B", "Option C"]
   - status: "pending"
    ↓
2. Remote App에서 선택 UI 렌더링 대기
    ↓
3. 사용자 선택 또는 타임아웃
    ↓
4. 결과 출력
```

## Execution

### 테스트 요청 생성

```bash
mcp__semo-integrations__remote_request(
  session_id: "{current_session_id}",
  type: "selection",
  message: "[테스트] 다음 중 하나를 선택하세요:",
  options: ["Option A - 첫 번째 선택지", "Option B - 두 번째 선택지", "Option C - 세 번째 선택지"]
)
```

### 응답 대기

```bash
# 30초 타임아웃으로 응답 대기
mcp__semo-integrations__remote_await(
  request_id: "{request_id}",
  timeout: 30
)
```

## Output

### 성공 (선택 완료)

```markdown
[SEMO] Skill: test-selection 호출

## 선택형 테스트 요청 생성됨

**Request ID**: abc123
**Type**: selection
**Options**:
1. Option A - 첫 번째 선택지
2. Option B - 두 번째 선택지
3. Option C - 세 번째 선택지

Remote App에서 선택을 기다리는 중...

---

✅ **선택 완료**

**선택된 옵션**: Option B - 두 번째 선택지
**응답 시간**: 5.2초
```

### 타임아웃

```markdown
[SEMO] Skill: test-selection 호출

## 선택형 테스트 요청 생성됨

**Request ID**: abc123
**Type**: selection

Remote App에서 선택을 기다리는 중...

---

⏱️ **타임아웃**

30초 내에 응답이 없었습니다.
Remote App 연결 상태를 확인하세요.
```

## Error Handling

### DB 연결 실패

```markdown
⚠️ Remote DB 연결 실패

SEMO_DB_PASSWORD 환경 변수를 확인하세요.
```

### 세션 ID 없음

```markdown
⚠️ 세션 ID를 찾을 수 없습니다.

semo-remote-client가 실행 중인지 확인하세요.
```

## SEMO Message Format

```markdown
[SEMO] Skill: test-selection 호출

[SEMO] Skill: test-selection 완료 - {result}
```

## References

- [remote-bridge Skill](../remote-bridge/SKILL.md)
- [CLAUDE.md](../../CLAUDE.md) - Remote API 호출 규칙
