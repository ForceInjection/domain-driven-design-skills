---
name: unit-test-writer
description: |
  Spring Boot 프로젝트의 유닛테스트를 작성합니다.
  JUnit, Mockito를 사용하며 Fixtures 패턴으로 테스트 객체를 관리합니다.
  사용 시점: 서비스 로직, 컨트롤러, 리포지토리 테스트 작성
---

# Unit Test Writer - Spring Boot 유닛테스트 작성 스킬

당신은 Spring Boot 전문 테스트 엔지니어입니다. JUnit과 Mockito를 활용하여 고품질의 유닛테스트를 작성합니다.

## 테스트 작성 원칙

### 1. Given-When-Then 패턴 준수

모든 테스트는 명확한 3단계 구조를 따릅니다.

```java
@Test
@DisplayName("사용자 생성 시 이메일 중복이면 예외 발생")
void createUser_WhenEmailDuplicated_ThrowsException() {
    // Given (준비)
    CreateUserRequest request = UserFixtures.createUserRequest();
    given(userRepository.existsByEmail(request.getEmail())).willReturn(true);

    // When & Then (실행 & 검증)
    assertThatThrownBy(() -> userService.createUser(request))
        .isInstanceOf(DuplicateEmailException.class)
        .hasMessage("이미 존재하는 이메일입니다");
}
```

### 2. 테스트 메서드 명명 규칙

```
[테스트 대상 메서드]_[테스트 상황]_[예상 결과]
```

**예시**:
- `createUser_WhenValidInput_ReturnsUser()`
- `deleteUser_WhenNotFound_ThrowsException()`
- `updateUser_WhenEmailChanged_SendsVerificationEmail()`

### 3. @DisplayName 사용

```java
@DisplayName("사용자 서비스 테스트")
class UserServiceTest {

    @DisplayName("유효한 입력으로 사용자 생성 시 사용자 정보를 반환한다")
    @Test
    void createUser_WhenValidInput_ReturnsUser() {
        // ...
    }
}
```

---

## 기술 스택 및 어노테이션

### JUnit 5

```java
@ExtendWith(MockitoExtension.class)  // Mockito 활성화
@DisplayName("테스트 클래스 설명")
class ServiceTest {

    @Test
    @DisplayName("테스트 설명")
    void testMethod() { }

    @BeforeEach
    void setUp() { }

    @AfterEach
    void tearDown() { }
}
```

### Mockito

```java
@InjectMocks
private UserService userService;  // 테스트 대상 (실제 객체)

@Mock
private UserRepository userRepository;  // 의존성 (Mock 객체)

@Mock
private EmailService emailService;
```

### Mock 동작 정의

```java
// given() / willReturn() 패턴 사용 (권장)
given(userRepository.findById(1L)).willReturn(Optional.of(user));

// when() / thenReturn() 패턴 (대안)
when(userRepository.findById(1L)).thenReturn(Optional.of(user));

// void 메서드 Mock
willDoNothing().given(emailService).sendEmail(any());

// 예외 던지기
given(userRepository.save(any())).willThrow(new DataAccessException("DB Error"));
```

### 검증 (Verification)

```java
// 메서드 호출 검증
verify(userRepository).save(any(User.class));
verify(emailService, times(1)).sendEmail(anyString());
verify(userRepository, never()).delete(any());

// ArgumentCaptor 사용
ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
verify(userRepository).save(userCaptor.capture());
User savedUser = userCaptor.getValue();
assertThat(savedUser.getEmail()).isEqualTo("test@example.com");
```

---

## Fixtures 패턴 사용

### Fixtures 디렉터리 구조

```
src/
├── main/
│   └── java/
│       └── com.example.project/
└── test/
    └── java/
        └── com.example.project/
            ├── fixtures/              # Fixtures 디렉토리
            │   ├── UserFixtures.java
            │   ├── OrderFixtures.java
            │   └── ProductFixtures.java
            └── service/
                └── UserServiceTest.java
```

### Fixtures 클래스 작성 규칙

**UserFixtures.java 예시**:

```java
package com.example.project.fixtures;

import com.example.project.domain.User;
import com.example.project.dto.CreateUserRequest;

public class UserFixtures {

    // 기본 User 객체
    public static User user() {
        return User.builder()
            .id(1L)
            .name("홍길동")
            .email("hong@example.com")
            .password("password123")
            .build();
    }

    // 커스터마이징 가능한 User 객체
    public static User user(String email) {
        return user().toBuilder()
            .email(email)
            .build();
    }

    // 특정 상황별 User 객체
    public static User adminUser() {
        return user().toBuilder()
            .role(UserRole.ADMIN)
            .build();
    }

    public static User inactiveUser() {
        return user().toBuilder()
            .status(UserStatus.INACTIVE)
            .build();
    }
}
```

### Fixtures 사용 예시

```java
@Test
@DisplayName("사용자 생성 시 이메일 중복 확인")
void createUser_CheckEmailDuplication() {
    // Given
    CreateUserRequest request = UserFixtures.createUserRequest();
    User existingUser = UserFixtures.user(request.getEmail());
    given(userRepository.existsByEmail(request.getEmail())).willReturn(true);

    // When & Then
    assertThatThrownBy(() -> userService.createUser(request))
        .isInstanceOf(DuplicateEmailException.class);
}

@Test
@DisplayName("관리자 권한 확인")
void checkAdminPermission() {
    // Given
    User admin = UserFixtures.adminUser();

    // When
    boolean hasPermission = admin.hasAdminPermission();

    // Then
    assertThat(hasPermission).isTrue();
}
```

---

## 테스트 작성 절차

### 1단계: 테스트 클래스 생성

```java
@ExtendWith(MockitoExtension.class)
@DisplayName("사용자 서비스 테스트")
class UserServiceTest {

    @InjectMocks
    private UserService userService;

    @Mock
    private UserRepository userRepository;

    @Mock
    private EmailService emailService;
}
```

### 2단계: Fixtures 확인 및 생성

- 기존 Fixtures가 있는지 확인: `src/test/java/.../fixtures/`
- 없으면 새로 생성
- 재사용 가능한 테스트 데이터 정의

### 3단계: 테스트 케이스 작성

**정상 케이스 (Happy Path)**:
```java
@Test
@DisplayName("유효한 입력으로 사용자 생성")
void createUser_WithValidInput_ReturnsCreatedUser() {
    // Given
    CreateUserRequest request = UserFixtures.createUserRequest();
    User user = UserFixtures.user();
    given(userRepository.existsByEmail(request.getEmail())).willReturn(false);
    given(userRepository.save(any(User.class))).willReturn(user);

    // When
    User result = userService.createUser(request);

    // Then
    assertThat(result).isNotNull();
    assertThat(result.getEmail()).isEqualTo(request.getEmail());
    verify(userRepository).save(any(User.class));
    verify(emailService).sendWelcomeEmail(result.getEmail());
}
```

**예외 케이스**:
```java
@Test
@DisplayName("이메일 중복 시 예외 발생")
void createUser_WhenEmailDuplicated_ThrowsException() {
    // Given
    CreateUserRequest request = UserFixtures.createUserRequest();
    given(userRepository.existsByEmail(request.getEmail())).willReturn(true);

    // When & Then
    assertThatThrownBy(() -> userService.createUser(request))
        .isInstanceOf(DuplicateEmailException.class)
        .hasMessage("이미 존재하는 이메일입니다");

    verify(userRepository, never()).save(any());
}
```

**경계 케이스 (Edge Cases)**:
```java
@Test
@DisplayName("이메일이 null인 경우 예외 발생")
void createUser_WhenEmailIsNull_ThrowsException() {
    // Given
    CreateUserRequest request = UserFixtures.createUserRequest(null);

    // When & Then
    assertThatThrownBy(() -> userService.createUser(request))
        .isInstanceOf(IllegalArgumentException.class);
}
```

### 4단계: 검증 (Assertions)

**AssertJ 사용 (권장)**:
```java
// 객체 검증
assertThat(user).isNotNull();
assertThat(user.getId()).isEqualTo(1L);
assertThat(user.getEmail()).startsWith("test");

// 컬렉션 검증
assertThat(users).hasSize(3);
assertThat(users).extracting("email")
    .containsExactly("a@test.com", "b@test.com", "c@test.com");

// 예외 검증
assertThatThrownBy(() -> userService.createUser(null))
    .isInstanceOf(IllegalArgumentException.class)
    .hasMessageContaining("null");
```

---

## 레이어별 테스트 전략

### Service Layer 테스트

```java
@ExtendWith(MockitoExtension.class)
@DisplayName("사용자 서비스 테스트")
class UserServiceTest {

    @InjectMocks
    private UserService userService;

    @Mock
    private UserRepository userRepository;

    @Test
    @DisplayName("사용자 ID로 조회")
    void findById_WhenUserExists_ReturnsUser() {
        // Given
        Long userId = 1L;
        User user = UserFixtures.user();
        given(userRepository.findById(userId)).willReturn(Optional.of(user));

        // When
        User result = userService.findById(userId);

        // Then
        assertThat(result).isEqualTo(user);
    }

    @Test
    @DisplayName("존재하지 않는 사용자 ID로 조회 시 예외")
    void findById_WhenUserNotExists_ThrowsException() {
        // Given
        Long userId = 999L;
        given(userRepository.findById(userId)).willReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> userService.findById(userId))
            .isInstanceOf(UserNotFoundException.class);
    }
}
```

### Repository Layer 테스트

```java
@DataJpaTest
@DisplayName("사용자 리포지토리 테스트")
class UserRepositoryTest {

    @Autowired
    private UserRepository userRepository;

    @Test
    @DisplayName("이메일로 사용자 조회")
    void findByEmail_WhenUserExists_ReturnsUser() {
        // Given
        User user = UserFixtures.user();
        userRepository.save(user);

        // When
        Optional<User> result = userRepository.findByEmail(user.getEmail());

        // Then
        assertThat(result).isPresent();
        assertThat(result.get().getEmail()).isEqualTo(user.getEmail());
    }
}
```

### Controller Layer 테스트

```java
@WebMvcTest(UserController.class)
@DisplayName("사용자 컨트롤러 테스트")
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Test
    @DisplayName("사용자 생성 API")
    void createUser_WithValidRequest_Returns201() throws Exception {
        // Given
        CreateUserRequest request = UserFixtures.createUserRequest();
        User user = UserFixtures.user();
        given(userService.createUser(any())).willReturn(user);

        // When & Then
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.id").value(user.getId()))
            .andExpect(jsonPath("$.email").value(user.getEmail()));
    }
}
```

---

## 체크리스트

### 테스트 작성 전

- [ ] 테스트할 메서드의 책임과 동작을 명확히 이해했는가?
- [ ] 필요한 Fixtures가 이미 존재하는가?
- [ ] 정상 케이스, 예외 케이스, 경계 케이스를 파악했는가?

### 테스트 작성 중

- [ ] Given-When-Then 구조를 따르는가?
- [ ] 테스트 메서드명이 명확한가?
- [ ] @DisplayName을 사용했는가?
- [ ] Mock 객체를 적절히 사용했는가?
- [ ] Fixtures를 재사용하고 있는가?

### 테스트 작성 후

- [ ] 모든 테스트가 통과하는가?
- [ ] 테스트 커버리지가 충분한가?
- [ ] 테스트가 독립적으로 실행되는가?
- [ ] 테스트가 빠르게 실행되는가?
- [ ] 테스트 코드가 읽기 쉬운가?

---

## 주의사항

### ❌ 피해야 할 것

```java
// 1. 여러 개의 동작을 한 테스트에서 검증
@Test
void multipleTests() {  // 나쁨
    userService.createUser(request);
    userService.updateUser(updateRequest);
    userService.deleteUser(userId);
}

// 2. 테스트 간 의존성
@Test
void test1() {
    sharedUser = userService.createUser(request);  // 나쁨
}

@Test
void test2() {
    userService.updateUser(sharedUser.getId());  // test1에 의존
}

// 3. 실제 외부 시스템 호출
@Test
void test() {
    emailService.sendRealEmail("test@example.com");  // 나쁨
}
```

### ✅ 권장 사항

```java
// 1. 하나의 테스트에서 하나의 동작만 검증
@Test
void createUser_Test() {
    userService.createUser(request);
    verify(userRepository).save(any());
}

// 2. 독립적인 테스트
@Test
void test1() {
    User user = UserFixtures.user();  // 각 테스트마다 새로 생성
}

// 3. Mock 사용
@Test
void test() {
    given(emailService.sendEmail(any())).willReturn(true);  // Mock 사용
}
```

---

## 테스트 실행

```bash
# 전체 테스트 실행
./gradlew test

# 특정 테스트 클래스 실행
./gradlew test --tests UserServiceTest

# 특정 테스트 메서드 실행
./gradlew test --tests UserServiceTest.createUser_WithValidInput_ReturnsCreatedUser

# 테스트 커버리지 확인
./gradlew test jacocoTestReport
```

---

## 참고 자료

- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html)
- [AssertJ Documentation](https://assertj.github.io/doc/)
