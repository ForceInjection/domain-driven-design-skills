---
name: react-component
description: React 컴포넌트와 관련 파일들(hook, style, test)을 생성합니다. 사용자가 "컴포넌트 만들어", "새로운 React 컴포넌트", "컴포넌트 생성"과 같은 요청을 할 때 사용합니다.
---

# React 컴포넌트 생성 스킬

이 스킬은 React 컴포넌트와 관련된 파일들을 일관된 구조로 생성합니다.

## 생성되는 파일들

1. **컴포넌트 파일**: `index.tsx`
2. **스타일 파일**: `styles.module.css`
3. **Hook 파일**: `hooks/*.hook.ts` (필요시)
4. **테스트 파일**: `tests/*.spec.ts` (Playwright 사용)

## 컴포넌트 구조

```
component-name/
├── index.tsx
├── styles.module.css
├── hooks/
│   └── *.hook.ts
└── tests/
    └── *.spec.ts
```

## 코딩 컨벤션

- TypeScript 사용
- CSS Modules 사용
- 명확한 props 타입 정의
- 설명적인 변수명 사용
- 재사용 가능한 컴포넌트 설계
