---
name: test-conventions
description: 테스트 작성 시 컨벤션 자동 적용
globs:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/__tests__/**"
  - "**/test/**"
  - "**/tests/**"
---

# 테스트 컨벤션 가이드

이 가이드는 언어와 프레임워크에 관계없이 적용되는 테스트 작성 원칙입니다.

## 테스트 구조

### AAA 패턴 (Arrange-Act-Assert)

모든 테스트는 세 단계로 구성:

```
1. Arrange (준비)
   - 테스트에 필요한 데이터/객체 생성
   - Mock/Stub 설정

2. Act (실행)
   - 테스트 대상 함수/메서드 호출

3. Assert (검증)
   - 기대 결과와 실제 결과 비교
```

### 테스트 그룹화

```
[테스트 대상]
  └── [기능/메서드]
        ├── 정상 케이스
        ├── 경계값 케이스
        └── 에러 케이스
```

## 필수 테스트 케이스

### 1. 정상 케이스 (Happy Path)
- 기본 동작 확인
- 다양한 유효 입력값

### 2. 경계값 테스트 (Edge Cases)
- 빈 값: null, undefined, 빈 문자열, 빈 배열
- 최소/최대값
- 경계 조건 (off-by-one 확인)

### 3. 에러 케이스 (Error Cases)
- 잘못된 입력 타입
- 범위 초과 값
- 예외 상황 처리

## 네이밍 규칙

### 테스트 이름 패턴

```
should [예상 동작] when [조건]
```

예시:
- "should return empty list when no items exist"
- "should throw error when input is null"
- "should calculate total correctly when discount applied"

### 피해야 할 이름
- "test1", "works", "should work" 등 의미 없는 이름
- 구현 세부사항에 의존하는 이름

## Mock 사용 원칙

### Mock 대상
- 외부 API 호출
- 데이터베이스 연결
- 파일 시스템 접근
- 시간 관련 함수

### Mock 지양
- 내부 구현 세부사항
- 같은 모듈 내 함수
- 테스트 대상 자체

## 테스트 품질

### 독립성
- 각 테스트는 다른 테스트에 의존하지 않음
- 테스트 순서에 상관없이 동일한 결과
- 테스트 간 공유 상태 금지

### 결정성
- 동일 입력 → 항상 동일 결과
- 랜덤 값 사용 시 시드 고정
- 시간 의존적 테스트는 Mock 사용

### 가독성
- 테스트 코드도 깨끗하게 유지
- 매직 넘버 대신 명명된 상수 사용
- 복잡한 설정은 헬퍼 함수로 추출
