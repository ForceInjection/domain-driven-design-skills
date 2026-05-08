---
name: tdd-playwright
description: Playwright 기반 TDD 개발을 지원합니다. 테스트 작성, 실행, 디버깅을 자동화하고 테스트가 통과할 때까지 반복 개발합니다. 사용자가 "TDD로 개발", "Playwright 테스트 작성", "테스트 통과시켜"와 같은 요청을 할 때 사용합니다.
---

# Playwright TDD 스킬

이 스킬은 Playwright를 활용한 TDD(Test-Driven Development) 작업을 지원합니다.

## 작업 프로세스

1. **테스트 작성**: 요구사항을 바탕으로 Playwright 테스트 작성
2. **테스트 실행**: `npx playwright test` 실행
3. **구현**: 테스트를 통과시키기 위한 최소한의 코드 구현
4. **재실행**: 테스트가 통과할 때까지 2-3 반복
5. **리팩토링**: 테스트 통과 후 코드 개선

## 테스트 작성 가이드

- `data-testid` 속성을 사용한 요소 선택
- 페이지 로드 확인은 고정 식별자 대기 사용
- `networkidle` 대기 방법 사용 금지
- timeout은 500ms 미만으로 설정
- 실제 데이터 사용, Mock 데이터 지양

## 명명 규칙

- 테스트 파일: `*.spec.ts`
- Hook 파일: `*.hook.ts`
- 명확하고 설명적인 테스트 케이스 이름 사용
