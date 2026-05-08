---
name: full-audit
description: "코드/콘솔/UX/E2E/보안 통합 검수 - 4개 에이전트 협업 (150점 만점)"
allowed-tools: Read, Grep, Glob, Bash, Task, mcp__playwright__*
---

# 종합 검수 스킬 (Full Audit)

> 코드, 콘솔, UX/UI, E2E, 보안 통합 검수

## 트리거

- `/audit` - 종합 검수 시작
- "전체 검수", "풀 오딧", "full audit" 키워드

## 사용 에이전트

| 에이전트 | 모델 | 역할 |
|----------|------|------|
| opus-reviewer | opus | 코드 품질 심층 분석 |
| security-auditor | sonnet | 보안 취약점 스캔 |
| uxui-auditor | sonnet | UX/UI 디자인 검수 |
| e2e-tester | sonnet | E2E 테스트 실행 |

## MCP 서버

- **playwright** - E2E 브라우저 테스트
- **sequential-thinking** - 복잡한 검수 로직 구조화

## 검수 체크리스트

### A. 코드 품질 (30점)
- [ ] TypeScript strict mode
- [ ] any 타입 금지
- [ ] 함수형 프로그래밍
- [ ] 네이밍 컨벤션

### B. 콘솔 에러 (25점)
- [ ] TypeScript 컴파일
- [ ] ESLint 통과
- [ ] React 경고 없음
- [ ] 런타임 에러 없음

### C. UX/UI (35점)
- [ ] 모노크롬 디자인 준수 (15점)
- [ ] 반응형 레이아웃 (10점)
- [ ] 접근성 ARIA (10점)

### D. E2E 테스트 (30점)
- [ ] 페이지 로드
- [ ] 네비게이션
- [ ] 폼 동작

### E. 보안 (30점)
- [ ] 시크릿 스캔
- [ ] Injection 방지
- [ ] OWASP Top 10

## 스크립트 파일

```
.claude/scripts/
├── code-quality-check.py   # 코드 품질 검사
├── console-error-check.py  # 콘솔 에러 검사
└── (추가 예정)
```

## 사용법

```bash
# 전체 검수
/audit

# 빠른 검수
/audit --quick

# 특정 영역만
/audit --code
/audit --console
/audit --uxui
/audit --e2e
/audit --security

# 특정 파일
/audit --file src/components/Hero.tsx
```

## 결과 등급

| 점수 | 등급 | 판정 |
|------|------|------|
| 120+ | A | PASS |
| 100-119 | B | PASS |
| 80-99 | C | 조건부 PASS |
| 60-79 | D | 경고 |
| <60 | F | FAIL |

## 자동 실행

```yaml
PreCommit:
  - /audit --quick

PreMerge:
  - /audit --all

ScheduledAudit:
  - 매일 자정 전체 검수
```

## 보고서 위치

```
.claude/audit-reports/
├── latest.md          # 최신 보고서
├── latest.json        # JSON 형식
└── history/           # 이력
    └── YYYY-MM-DD_HHMMSS.md
```
