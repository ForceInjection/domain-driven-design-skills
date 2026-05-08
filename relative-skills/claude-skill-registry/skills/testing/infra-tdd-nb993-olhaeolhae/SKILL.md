---
name: infra-tdd
description: 인프라 계층(JpaEntity, Adapter, Repository) TDD 개발 지침. Red-Green-Refactor 사이클을 통해 테스트 주도 개발을 수행합니다. 실제 DB(Testcontainer)를 사용하며 Mocking하지 않습니다.
---

# 인프라 계층 TDD 지침

## TDD 순서

1. **JpaEntity** - 변환 메서드 테스트 → 구현 → 리팩토링
2. **Repository** - 인터페이스 정의 (테스트 불필요)
3. **Adapter** - 테스트 → 구현 → 리팩토링

## 특이사항

- **Mocking 미사용**: 실제 DB(Testcontainer) 사용
- **베이스 클래스**: `AdapterTestBase` 상속
- **sut 패턴**: 테스트 대상을 `sut` 변수로 선언
- **테스트 데이터**: `newXxx() + from()` 패턴 사용

## 핵심 규칙

### JpaEntity 명명
- 클래스명: `{도메인}JpaEntity` (예: `FamilyJpaEntity`)
- 기본 생성자: `protected`
- 그 외 생성자: `private`
- setter 사용 금지

### 변환 메서드
- 도메인→엔티티: `static from(Domain domain)`
- 엔티티→도메인: `toXxx()` (예: `toFamily()`)

### Adapter 명명
- 클래스명: `{도메인}Adapter`
- 여러 Port 인터페이스 구현 가능

## 상세 지침

**[필수] 아래 참조 문서를 모두 읽은 후 작업을 시작하세요:**

- **TDD 사이클**: [tdd-cycle.md](tdd-cycle.md)
- **명명 규칙**: [naming.md](naming.md)
- **아키텍처**: [architecture.md](architecture.md)
- **코딩 스타일**: [coding.md](coding.md)
