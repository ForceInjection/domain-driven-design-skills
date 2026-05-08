---
name: playwright-wrapper
description: >
  Playwright 브라우저 자동화 래퍼. MCP 대신 CLI 직접 호출.
  E2E 테스트, 스크린샷, 웹 자동화에 사용.
version: 1.0.0

triggers:
  keywords:
    - "playwright"
    - "브라우저 테스트"
    - "E2E 테스트"
    - "스크린샷"
    - "웹 자동화"
  file_patterns:
    - "**/*.spec.ts"
    - "**/e2e/**"
  context:
    - "E2E 테스트 실행"
    - "브라우저 자동화"

capabilities:
  - run_e2e_tests
  - take_screenshot
  - browser_automation

model_preference: sonnet
auto_trigger: false
token_budget: 800
---

# Playwright Wrapper

Playwright CLI를 직접 호출하여 브라우저 자동화를 수행합니다.

## 사용 시나리오

- E2E 테스트 실행
- 웹페이지 스크린샷
- 폼 자동 입력 테스트
- 브라우저 자동화 스크립트

## 명령어

### E2E 테스트 실행

```bash
# 전체 테스트
npx playwright test

# 특정 파일
npx playwright test tests/e2e/auth.spec.ts

# UI 모드
npx playwright test --ui

# 헤드리스 모드 (기본)
npx playwright test --headed
```

### 스크린샷 촬영

```bash
# 단일 페이지 스크린샷
npx playwright screenshot https://example.com screenshot.png

# 전체 페이지
npx playwright screenshot --full-page https://example.com full.png
```

### 코드 생성 (녹화)

```bash
# 브라우저에서 작업 녹화 → 코드 생성
npx playwright codegen https://example.com
```

### PDF 생성

```bash
npx playwright pdf https://example.com page.pdf
```

## 테스트 작성 예시

```typescript
// tests/e2e/example.spec.ts
import { test, expect } from '@playwright/test';

test('로그인 테스트', async ({ page }) => {
  await page.goto('https://example.com/login');
  await page.fill('#email', 'test@example.com');
  await page.fill('#password', 'password');
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL('/dashboard');
});
```

## 설정 파일

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  timeout: 30000,
  use: {
    headless: true,
    screenshot: 'only-on-failure',
  },
});
```

## 관련 커맨드

| 커맨드 | 용도 |
|--------|------|
| `/check` | 테스트 포함 전체 검사 |
| `/tdd` | TDD 워크플로우 |

## MCP 플러그인 활성화 (필요시)

대화형 브라우저 제어가 필요한 경우:

```bash
claude plugin enable playwright@claude-plugins-official
# 세션 재시작 필요
```
