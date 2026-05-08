---
name: presentation-tdd
description: 프레젠테이션 계층(Controller, Request/Response DTO) TDD 개발 지침. Outside-In TDD로 인수 테스트부터 시작하여 Controller와 DTO를 구현합니다. API 문서 테스트로 문서화를 완성합니다.
---

# 프레젠테이션 계층 TDD 지침

## TDD 순서

1. **인수 테스트** (실패) → Controller + DTO 구현
2. **API 문서 테스트** → 문서화 완성

## 특이사항

- **Outside-In TDD**: 인수 테스트부터 시작
- **베이스 클래스**: `AcceptanceTestBase` / `ApiDocsTestBase` 상속
- **보안**: `@WithMockOAuth2User` 필수
- **CSRF**: POST/PUT/DELETE에 `.postProcessors(csrf())` 필수

## 핵심 규칙

### Controller 규칙
- 하나의 Controller에 **하나의 API만** 작성
- 모든 엔드포인트는 `/api/`로 시작
- 비즈니스 로직/예외 처리 금지 (Service 책임)

### DTO 명명
- Request: `{Find/Save/Modify/Delete}{도메인}Request`
- Response: `{Find/Save/Modify/Delete}{도메인}Response`
- record 타입 필수

### Controller 명명
- `{Find/Save/Modify/Delete}{도메인}Controller`

## 상세 지침

**[필수] 아래 참조 문서를 모두 읽은 후 작업을 시작하세요:**

- **TDD 사이클**: [tdd-cycle.md](tdd-cycle.md)
- **명명 규칙**: [naming.md](naming.md)
- **아키텍처**: [architecture.md](architecture.md)
- **코딩 스타일**: [coding.md](coding.md)
