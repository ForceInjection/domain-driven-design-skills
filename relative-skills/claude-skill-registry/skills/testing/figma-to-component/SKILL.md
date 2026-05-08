---
name: figma-to-component
description: Figma 디자인을 분석하여 프로젝트 규칙에 맞는 React 컴포넌트를 자동 생성합니다. Figma URL을 받아서 TDD 방식으로 컴포넌트, 스타일, 테스트, Storybook을 생성합니다.
---

# Figma to Component 스킬

이 스킬은 Figma 디자인 URL을 받아서 프로젝트 규칙에 맞는 완전한 React 컴포넌트를 생성합니다.

## 사용 방법

사용자가 다음과 같은 요청을 할 때 이 스킬을 실행합니다:
- "이 Figma 디자인으로 컴포넌트 만들어줘"
- "Figma URL로 UI 구현해줘"
- "[Figma URL]을 컴포넌트로 변환해줘"

## 워크플로우

### 1단계: Figma 분석 및 디자인 검증
1. 사용자로부터 다음 정보 수집:
   - Figma URL (필수)
   - 컴포넌트 이름 (예: `ProductCard`, `UserProfile`)
   - 생성 위치 (기본값: `src/components/`)
   - 기존 컴포넌트 업데이트 여부

2. Figma URL에서 fileKey와 nodeId 추출:
   - URL 형식: `https://figma.com/design/:fileKey/:fileName?node-id=:int1-:int2`
   - nodeId는 `123-456` 형식을 `123:456`으로 변환

3. Figma 데이터 가져오기 (병렬 실행):
   ```typescript
   // mcp__figma__get_screenshot - 시각적 디자인 확인
   // mcp__figma__get_design_context - 코드 및 스타일 정보
   // mcp__figma__get_metadata - 구조 및 계층 파악
   ```

4. **디자인 철저 분석** (이 단계가 중요!):
   - 전체 레이아웃 구조 파악 (flexbox/grid)
   - 모든 간격(gap) 명시적으로 확인
   - 고정 높이 vs 동적 높이 구분
   - 텍스트 overflow 처리 필요 위치 체크
   - 계층 구조 (어느 요소가 어디 안에 있는지)
   - 그림자, 둥근 모서리 등 시각적 요소

### 2단계: 컴포넌트 구조 생성

생성할 디렉토리 구조:
```
component-name/
├── index.tsx                    # 컴포넌트 구현
├── styles.module.css            # CSS Modules 스타일
├── tests/
│   ├── index.binding.hook.spec.ts   # 데이터 바인딩 테스트
│   └── index.ui.spec.ts             # UI 렌더링 테스트
└── stories/
    └── index.stories.tsx        # Storybook 스토리
```

### 3단계: TDD 방식으로 테스트 작성

**먼저 테스트를 작성합니다** (프로젝트 규칙):

1. **UI 렌더링 테스트** (`index.ui.spec.ts`):
   - Figma 디자인의 주요 요소들이 렌더링되는지 확인
   - data-testid 속성 사용
   - 예시:
   ```typescript
   test('컴포넌트가 올바르게 렌더링됨', async ({ page }) => {
     await page.goto('http://localhost:3000/test-page')
     await expect(page.locator('[data-testid="component-title"]')).toBeVisible()
   })
   ```

2. **데이터 바인딩 테스트** (`index.binding.hook.spec.ts`):
   - Props가 올바르게 표시되는지 확인
   - 사용자 상호작용 테스트

### 4단계: CSS 작성 (일반적인 함정 방지)

**CSS 규칙 (CLAUDE.md 준수)**:
- ✅ CSS Modules만 사용
- ✅ Flexbox 레이아웃만 사용
- ❌ `position: absolute` 금지
- ❌ `:global`, `:root`, `!important` 금지
- ❌ 요구사항에 없는 애니메이션 금지

**필수 체크리스트** (이번 작업에서 발생한 문제 방지):

1. **Grid/Flexbox 레이아웃**:
   - Grid 사용 시 `minmax(0, 1fr)` 사용 (텍스트 overflow 방지)
   - 예: `grid-template-columns: 64px minmax(0, 1fr) 100px 100px`

2. **고정 높이 vs 동적 높이**:
   - 리스트 행처럼 균일해야 하는 경우 `height` 명시
   - 예: `.listRow { height: 44px; }`

3. **텍스트 Overflow 처리**:
   - 잘려야 하는 텍스트에 필수 3종 세트 적용:
   ```css
   overflow: hidden;
   white-space: nowrap;
   text-overflow: ellipsis;
   ```
   - Grid/Flex 자식에는 `min-width: 0` 추가

4. **간격 구조 (Gap)**:
   - 부모에 `gap` 속성 사용 (불필요한 div 제거)
   - Figma의 계층 구조 정확히 파악
   - 예: `main { gap: 8px; }` → 자식 간 8px 간격

5. **계층 구조**:
   - Figma에서 어떤 요소가 어디 안에 있는지 정확히 파악
   - 예: 페이지네이션이 main 안에 있는지 밖에 있는지

**TypeScript 컴포넌트**:
```typescript
/**
 * [컴포넌트명] - Figma 디자인 기반 컴포넌트
 *
 * @description Figma 디자인을 구현한 컴포넌트입니다.
 * @param props - 컴포넌트 속성
 */
export default function ComponentName(props: IComponentProps) {
  // 구현
}

/** 컴포넌트 Props 인터페이스 */
interface IComponentProps {
  // Figma 디자인에서 추출한 props
}
```

**주석 작성 규칙**:
- 모든 주석은 한국어로 작성
- 함수/컴포넌트: JSDoc 형식으로 기능, 파라미터, 반환값 설명
- 복잡한 로직: 동작 원리와 구현 이유 설명
- 수정 사항: `// 수정 이유: [구체적인 이유]` 형식으로 기록

### 5단계: Storybook 스토리 생성

```typescript
import type { Meta, StoryObj } from '@storybook/react'
import Component from '../index'

const meta: Meta<typeof Component> = {
  title: 'Components/ComponentName',
  component: Component,
}

export default meta
type Story = StoryObj<typeof Component>

/** 기본 상태 */
export const Default: Story = {
  args: {
    // Figma에서 추출한 기본 props
  },
}
```

### 6단계: 시각적 검증 및 테스트

**중요**: 코드 작성 후 반드시 시각적 검증을 수행합니다.

1. **스크린샷 캡처 및 Figma 비교**:
   ```bash
   # 개발 서버 시작
   npm run dev

   # Playwright로 스크린샷 캡처
   # 임시 테스트 파일 생성 후 실행
   npx playwright test screenshot-test.spec.ts
   ```

2. **Figma 디자인과 비교 체크리스트**:
   - ✅ 전체 레이아웃 구조
   - ✅ 모든 간격(gap)이 정확한지
   - ✅ 텍스트가 칸을 벗어나지 않는지
   - ✅ 행 높이가 균일한지 (필요한 경우)
   - ✅ 색상, 폰트 크기, 줄 높이
   - ✅ 그림자, 둥근 모서리 등 시각적 요소

3. **차이점 발견 시 즉시 수정**:
   - CSS를 수정하고 다시 스크린샷 캡처
   - 완벽히 일치할 때까지 반복

4. **Playwright 테스트 실행**:
   ```bash
   # 전체 테스트
   npx playwright test src/components/component-name/tests/

   # 개별 테스트
   npx playwright test src/components/component-name/tests/index.ui.spec.ts
   ```

테스트가 통과하고 시각적으로도 Figma와 일치할 때까지 수정합니다.

## 프로젝트 규칙 준수 체크리스트

**디자인 정확도**:
- [ ] Grid/Flexbox에 `minmax(0, 1fr)` 사용 (텍스트 overflow 방지)
- [ ] 고정 높이가 필요한 요소에 `height` 명시
- [ ] 모든 텍스트 컬럼에 overflow 처리 (3종 세트)
- [ ] 간격을 CSS `gap`으로 제어 (불필요한 div 제거)
- [ ] Figma 계층 구조 정확히 반영
- [ ] 시각적으로 Figma와 100% 일치

**코드 품질**:
- [ ] CSS Modules 사용 (position-absolute 없음)
- [ ] Flexbox 레이아웃
- [ ] 한국어 주석 작성
- [ ] TypeScript 타입 정의
- [ ] data-testid 속성 추가
- [ ] Playwright 테스트 작성 (TDD)
- [ ] Storybook 스토리 작성
- [ ] 테스트 통과 확인 (2000ms 미만)
- [ ] 독립적이고 재사용 가능한 컴포넌트

## Figma MCP 도구 사용 가이드

### 스크린샷 가져오기
```typescript
mcp__figma__get_screenshot({
  fileKey: "extracted-file-key",
  nodeId: "123:456",
  clientLanguages: "typescript",
  clientFrameworks: "react,nextjs"
})
```

### 디자인 컨텍스트 가져오기
```typescript
mcp__figma__get_design_context({
  fileKey: "extracted-file-key",
  nodeId: "123:456",
  clientLanguages: "typescript",
  clientFrameworks: "react,nextjs",
  disableCodeConnect: false
})
```

### 메타데이터 가져오기 (구조 파악용)
```typescript
mcp__figma__get_metadata({
  fileKey: "extracted-file-key",
  nodeId: "123:456",
  clientLanguages: "typescript",
  clientFrameworks: "react,nextjs"
})
```

## 에러 처리

1. **Figma URL 형식 오류**: 올바른 URL 형식 안내
2. **권한 오류**: `mcp__figma__whoami` 로 사용자 확인
3. **테스트 실패**: 디버그 정보 제공 및 수정

## 성공 기준

1. ✅ Figma 디자인과 시각적으로 일치
2. ✅ 모든 Playwright 테스트 통과
3. ✅ CSS 규칙 준수 (no position-absolute)
4. ✅ 한국어 주석 완성
5. ✅ Storybook에서 정상 렌더링
6. ✅ TypeScript 타입 에러 없음

## 예시 사용 시나리오

**사용자**: "https://figma.com/design/abc123/Product?node-id=1-2 이 디자인으로 ProductCard 컴포넌트 만들어줘"

**스킬 실행 순서**:
1. URL 파싱 → fileKey: "abc123", nodeId: "1:2"
2. Figma 데이터 가져오기
3. `src/components/product-card/` 디렉토리 생성
4. 테스트 작성 (TDD)
5. 컴포넌트 구현
6. Storybook 스토리 생성
7. 테스트 실행 및 검증
8. 사용자에게 결과 보고

## 참고사항

- 프로젝트의 기존 컴포넌트 스타일과 일관성 유지
- `src/commons/constants/url.ts`의 라우팅 규칙 활용
- GraphQL이 필요한 경우 `graphql/` 폴더 생성
- 폼 컴포넌트는 react-hook-form + zod 사용
