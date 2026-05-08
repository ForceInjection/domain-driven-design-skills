---
name: unit-test-ddd
description: Spring Boot Unit 테스트 작성. JUnit5+Mockito, domain 패키지별 구조, entity는 common/entity, service는 {domain}/service. 네이밍 test_{대상}_{시나리오}_{예상결과}. Entity 직접 반환 금지 (DTO만). Fail Fast - 모든 필드/타입/예외 엄격 검증, 예상외 결과는 실패 처리.
allowed-tools: Read, Grep, Glob, Edit, Write
---

# Unit 테스트 작성 (DDD 패턴)

## 참조 문서
- **필수**: [docs/design/testing-strategy.md](../../../docs/design/testing-strategy.md) - 테스트 전략 전체
- **구조**: [CLAUDE.md](../../../CLAUDE.md) - DDD 패키지 구조

## 핵심 원칙

### 패키지 구조
```
app/backend/{service}/src/test/java/
├── {domain}/
│   └── service/
│       └── UserServiceTest.java  # 도메인별 Service 테스트
└── common/
    ├── entity/
    │   └── UserTest.java          # Entity 단위 테스트
    └── repository/
        └── UserRepositoryTest.java # Repository 테스트
```

### 테스트 네이밍
**형식**: `test_{대상}_{시나리오}_{예상결과}`

```java
// ✅ Good
@Test
void test_createUser_withValidData_returnsUserDto() { }

@Test
void test_createUser_withDuplicateEmail_throwsException() { }

// ❌ Bad
@Test
void test1() { }

@Test
void testCreateUser() { }  // 시나리오/결과 누락
```

### AAA 패턴 (Arrange-Act-Assert)
```java
@Test
void test_findById_withExistingId_returnsUser() {
    // Arrange (준비)
    User user = new User("test@example.com");
    when(repository.findById(1L)).thenReturn(Optional.of(user));

    // Act (실행)
    UserDto result = service.findById(1L);

    // Assert (검증)
    assertThat(result.getEmail()).isEqualTo("test@example.com");
    verify(repository, times(1)).findById(1L);
}
```

### 엄격한 검증 원칙 (Strict Validation)

**핵심**: 예상치 못한 모든 결과는 실패로 처리. 검증 생략 금지.

#### ❌ 나쁜 예: 검증 생략
```java
@Test
void test_createUser_bad() {
    UserDto result = service.createUser(request);
    // ID만 확인하고 다른 필드는 검증 안함
    assertThat(result.getId()).isNotNull();
}
```

#### ✅ 좋은 예: 모든 필드 명시적 검증
```java
@Test
void test_createUser_withValidData_returnsCompleteUserDto() {
    // Arrange
    CreateUserRequest request = new CreateUserRequest("test@example.com", "Test User");
    User savedUser = new User(1L, "test@example.com", "Test User");
    when(repository.save(any(User.class))).thenReturn(savedUser);

    // Act
    UserDto result = service.createUser(request);

    // Assert - 모든 필드 검증
    assertThat(result).isNotNull();
    assertThat(result.getId()).isEqualTo(1L);
    assertThat(result.getEmail()).isEqualTo("test@example.com");
    assertThat(result.getName()).isEqualTo("Test User");

    // Mock 호출 검증
    verify(repository, times(1)).save(any(User.class));
    verifyNoMoreInteractions(repository);
}
```

#### ❌ 나쁜 예: 예외만 확인
```java
@Test
void test_createUser_withDuplicateEmail_bad() {
    // 예외만 발생하면 통과
    assertThrows(DuplicateEmailException.class, () -> {
        service.createUser(request);
    });
}
```

#### ✅ 좋은 예: 예외 메시지 및 부작용 검증
```java
@Test
void test_createUser_withDuplicateEmail_throwsDetailedException() {
    // Arrange
    CreateUserRequest request = new CreateUserRequest("duplicate@example.com", "Test");
    when(repository.existsByEmail("duplicate@example.com")).thenReturn(true);

    // Act & Assert
    DuplicateEmailException exception = assertThrows(
        DuplicateEmailException.class,
        () -> service.createUser(request)
    );

    // 예외 메시지 검증
    assertThat(exception.getMessage()).contains("duplicate@example.com");
    assertThat(exception.getMessage()).contains("already exists");

    // 부작용 검증 (DB 저장 시도하지 않았는지)
    verify(repository, times(1)).existsByEmail("duplicate@example.com");
    verify(repository, never()).save(any(User.class));
    verifyNoMoreInteractions(repository);
}
```

#### 핵심 검증 항목
1. **모든 DTO 필드 검증**: null, 값, 타입 확인
2. **Mock 호출 검증**: `verify()`, `times()`, `verifyNoMoreInteractions()`
3. **예외 메시지 검증**: 예외 타입뿐만 아니라 메시지 내용도 확인
4. **부작용 검증**: 실패 시 DB 저장/삭제 등 부작용 없는지 확인
5. **Entity → DTO 변환 검증**: 모든 필드가 올바르게 매핑되었는지 확인

**참고**: 상세한 예제는 [docs/design/testing-strategy.md](../../../docs/design/testing-strategy.md)의 "엄격한 검증 원칙" 섹션 참조

## 체크리스트

### 작성 전
- [ ] 테스트 대상이 domain 패키지에 있는지 확인
- [ ] Entity는 common/entity, Service는 {domain}/service
- [ ] 기존 테스트 파일 있는지 확인 (추가 vs 신규)

### 작성 중
- [ ] JUnit5 `@Test`, Mockito `@Mock`, `@InjectMocks` 사용
- [ ] 네이밍: `test_{대상}_{시나리오}_{예상결과}`
- [ ] AAA 패턴 준수
- [ ] Entity 직접 반환 금지 (DTO 변환)
- [ ] **엄격한 검증**: 모든 DTO 필드, Mock 호출, 예외 메시지 검증
- [ ] **부작용 검증**: 실패 시 DB 저장/삭제 등 부작용 없는지 확인
- [ ] `verifyNoMoreInteractions()` 사용하여 예상치 못한 호출 감지

### 작성 후
- [ ] 실행: `cd app/backend/{service} && ./gradlew test`
- [ ] 모든 테스트 PASS 확인

## 금지사항
- ❌ Layer-based 구조 (controller/, service/ 폴더)
- ❌ Entity 직접 반환 (반드시 DTO 변환)
- ❌ Mock 없이 실제 DB/외부 API 호출
- ❌ 테스트 간 데이터 공유
- ❌ **검증 생략**: 일부 필드만 검증하고 나머지 skip
- ❌ **예외만 확인**: 예외 타입만 보고 메시지/부작용 무시
- ❌ **상정외 동작 허용**: 예상치 못한 결과를 실패로 처리하지 않음

## 실행 명령

```bash
# 전체 서비스 테스트
cd app/backend/user-service && ./gradlew test

# 특정 테스트 클래스만
./gradlew test --tests UserServiceTest

# 특정 메서드만
./gradlew test --tests UserServiceTest.test_createUser_withValidData_returnsUserDto
```