---
name: testing-expert
version: 3.0.0
description: |
  Integration Test E2E 테스트, TestRestTemplate 필수, Test Fixtures 재사용.
  MockMvc 금지, @Sql 어노테이션 테스트 데이터 설정.
  Gradle testFixtures 플러그인 활용, ArchUnit 의존성 검증.
author: claude-spring-standards
created: 2024-11-01
updated: 2025-12-05
tags: [project, testing, integration-test, fixtures, testresttemplate, e2e, archunit]
---

# Testing Expert (테스팅 전문가)

## 목적 (Purpose)

**Integration Test + Test Fixtures** 전략을 담당하는 전문가입니다.
E2E 테스트는 TestRestTemplate 기반 실제 HTTP 요청으로 수행하고,
테스트 데이터는 Gradle testFixtures + @Sql 어노테이션으로 관리합니다.

## 활성화 조건

- `/impl {layer} {feature}` 명령 실행 시 (테스트 동시 작성)
- `/plan` 실행 후 테스트 전략 결정 시
- integration test, fixture, testresttemplate, @sql, e2e 키워드 언급 시

## 산출물 (Output)

| 컴포넌트 | 파일명 패턴 | 위치 |
|----------|-------------|------|
| Integration Test | `{Feature}IntegrationTest.java` | `bootstrap/src/test/java/.../` |
| Domain Fixture | `{Aggregate}Fixture.java` | `domain/src/testFixtures/java/.../fixture/domain/` |
| Application Fixture | `{Command/Response}Fixture.java` | `application/src/testFixtures/java/.../fixture/application/` |
| Adapter Fixture | `{Request/Entity}Fixture.java` | `adapter-*/src/testFixtures/java/.../fixture/adapter/` |
| SQL Test Data | `{feature}-test-data.sql` | `src/test/resources/sql/` |

## 완료 기준 (Acceptance Criteria)

- [ ] Integration Test: `@SpringBootTest(webEnvironment = RANDOM_PORT)`
- [ ] TestRestTemplate 사용 (MockMvc 금지)
- [ ] @Sql로 테스트 데이터 삽입 (DML만, DDL 금지)
- [ ] @Transactional 롤백으로 테스트 격리
- [ ] Gradle testFixtures 플러그인 활용
- [ ] Fixture 클래스: final + private 생성자 + static 메서드
- [ ] 헥사고날 의존성 규칙 준수 (역방향 금지)
- [ ] ArchUnit 테스트 통과

---

## 테스트 전략 개요

### Integration Test = E2E Test

```
HTTP Request (TestRestTemplate)
    ↓
Controller (REST API Layer)
    ↓
UseCase (Application Layer)
    ↓
Repository (Persistence Layer)
    ↓
Real Database (MySQL via TestContainers)
    ↓
HTTP Response
```

### 단위 테스트 vs 통합 테스트

| 항목 | 단위 테스트 | 통합 테스트 |
|------|-------------|-------------|
| **범위** | 하나의 클래스/메서드 | 전체 레이어 통합 |
| **의존성** | Mock/Stub | 실제 Bean + 실제 DB |
| **속도** | 빠름 (ms) | 느림 (초) |
| **테스트** | `@DataJpaTest`, `@WebMvcTest` | `@SpringBootTest` |
| **HTTP** | MockMvc (가짜) | TestRestTemplate (실제) |
| **DB** | H2 (인메모리) | MySQL (실제) |

### Flyway vs @Sql 구분 (핵심!)

| 항목 | Flyway | @Sql |
|------|--------|------|
| **목적** | DB 스키마 버전 관리 | 테스트 데이터 삽입 |
| **역할** | DDL (`CREATE TABLE`) | DML (`INSERT`) |
| **실행 시점** | 앱 시작 시 (1번) | 각 테스트 메서드 전 |
| **파일 위치** | `db/migration/` | `src/test/resources/sql/` |
| **운영 사용** | ✅ 사용 | ❌ 테스트 전용 |

---

## 코드 템플릿

### 1. Integration Test

```java
package com.ryuqq.bootstrap;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.transaction.annotation.Transactional;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@Testcontainers
@Transactional
@DisplayName("Order 통합 테스트")
class OrderIntegrationTest {

    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:15-alpine")
        .withDatabaseName("test")
        .withUsername("test")
        .withPassword("test");

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    @Sql("/sql/orders-test-data.sql")
    @DisplayName("E2E - 주문 생성")
    void shouldCreateOrder() {
        // Given
        PlaceOrderRequest request = new PlaceOrderRequest(1L, 100L, 10);

        // When
        ResponseEntity<ApiResponse<OrderResponse>> response = restTemplate.exchange(
            "/api/v1/orders",
            HttpMethod.POST,
            new HttpEntity<>(request),
            new ParameterizedTypeReference<>() {}
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getData().orderId()).isNotNull();
    }

    @Test
    @Sql("/sql/orders-test-data.sql")
    @DisplayName("E2E - 주문 조회")
    void shouldGetOrder() {
        // Given
        Long orderId = 100L;

        // When
        ResponseEntity<ApiResponse<OrderResponse>> response = restTemplate.exchange(
            "/api/v1/orders/{orderId}",
            HttpMethod.GET,
            null,
            new ParameterizedTypeReference<>() {},
            orderId
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody().getData().orderId()).isEqualTo(orderId);
    }
}
```

**핵심 규칙**:
- `@SpringBootTest(webEnvironment = RANDOM_PORT)` 필수
- TestRestTemplate 주입 (MockMvc 금지)
- `@Sql` 로 테스트 데이터 삽입 (DML만)
- `@Transactional` 롤백으로 테스트 격리
- `@Testcontainers` + MySQL 실제 DB

### 2. Domain Fixture (testFixtures 소스셋)

```java
package com.ryuqq.fixture.domain;

import com.ryuqq.domain.order.aggregate.Order;
import com.ryuqq.domain.order.vo.OrderId;
import com.ryuqq.domain.order.vo.OrderStatus;
import com.ryuqq.domain.order.vo.Money;

import java.math.BigDecimal;

/**
 * Order Domain 객체 Test Fixture
 *
 * <p>모든 레이어에서 재사용 가능한 Domain 객체 생성 유틸리티</p>
 */
public final class OrderFixture {

    private OrderFixture() {
        throw new AssertionError("Utility class - do not instantiate");
    }

    /**
     * 신규 Order (ID 미할당)
     */
    public static Order defaultNewOrder() {
        return Order.forNew(
            new CustomerId(1L),
            Money.of(BigDecimal.valueOf(50000))
        );
    }

    /**
     * 기존 Order (ID 할당됨, 저장된 상태)
     */
    public static Order defaultExistingOrder() {
        return Order.forExisting(
            OrderId.of(1L),
            new CustomerId(1L),
            Money.of(BigDecimal.valueOf(50000)),
            OrderStatus.PLACED
        );
    }

    /**
     * 확정된 Order
     */
    public static Order confirmedOrder() {
        Order order = defaultExistingOrder();
        order.confirm();
        return order;
    }

    /**
     * 취소된 Order
     */
    public static Order canceledOrder() {
        Order order = defaultExistingOrder();
        order.cancel();
        return order;
    }

    /**
     * 커스텀 Order 빌더
     */
    public static Order customOrder(Long id, BigDecimal amount, OrderStatus status) {
        return Order.forExisting(
            OrderId.of(id),
            new CustomerId(1L),
            Money.of(amount),
            status
        );
    }
}
```

**핵심 규칙**:
- **위치**: `domain/src/testFixtures/java/com/ryuqq/fixture/domain/`
- `final` 클래스
- `private` 생성자 (인스턴스 생성 방지)
- `static` 메서드만 사용
- Domain 객체만 의존 (Application/Adapter 의존 금지)

### 3. Application Fixture

```java
package com.ryuqq.fixture.application.command;

import com.ryuqq.application.order.dto.command.PlaceOrderCommand;

import java.math.BigDecimal;

/**
 * PlaceOrderCommand DTO Test Fixture
 */
public final class PlaceOrderCommandFixture {

    private PlaceOrderCommandFixture() {
        throw new AssertionError("Utility class - do not instantiate");
    }

    public static PlaceOrderCommand defaultCommand() {
        return new PlaceOrderCommand(
            1L,
            BigDecimal.valueOf(50000)
        );
    }

    public static PlaceOrderCommand customCommand(Long customerId, BigDecimal amount) {
        return new PlaceOrderCommand(customerId, amount);
    }
}
```

### 4. Request Fixture (REST API)

```java
package com.ryuqq.fixture.adapter.rest;

import com.ryuqq.adapter.in.rest.order.dto.PlaceOrderRequest;

import java.math.BigDecimal;
import java.util.List;

/**
 * REST API Request DTO Test Fixture
 */
public final class OrderRequestFixture {

    private OrderRequestFixture() {
        throw new AssertionError("Utility class - do not instantiate");
    }

    public static PlaceOrderRequest validCreateRequest() {
        return new PlaceOrderRequest(
            1L,
            List.of(OrderItemRequestFixture.validItemRequest())
        );
    }

    public static PlaceOrderRequest invalidRequest_EmptyItems() {
        return new PlaceOrderRequest(1L, List.of());
    }

    public static PlaceOrderRequest invalidRequest_NullCustomerId() {
        return new PlaceOrderRequest(
            null,
            List.of(OrderItemRequestFixture.validItemRequest())
        );
    }
}
```

### 5. @Sql 테스트 데이터 (DML만!)

```sql
-- src/test/resources/sql/orders-test-data.sql

-- 클린업 (FK 역순)
DELETE FROM order_items;
DELETE FROM orders;
DELETE FROM customers;

-- 테스트 데이터 삽입 (FK 순서)
INSERT INTO customers (customer_id, name, email)
OVERRIDING SYSTEM VALUE
VALUES (1, 'Alice', 'alice@example.com');

INSERT INTO customers (customer_id, name, email)
OVERRIDING SYSTEM VALUE
VALUES (2, 'Bob', 'bob@example.com');

INSERT INTO orders (order_id, customer_id, status, total_amount, order_date)
OVERRIDING SYSTEM VALUE
VALUES (100, 1, 'PENDING', 10000, '2024-01-01');

INSERT INTO orders (order_id, customer_id, status, total_amount, order_date)
OVERRIDING SYSTEM VALUE
VALUES (101, 1, 'CONFIRMED', 20000, '2024-01-02');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
OVERRIDING SYSTEM VALUE
VALUES (1000, 100, 200, 2, 5000);
```

**핵심 규칙**:
- **DDL 금지**: `CREATE TABLE`, `ALTER TABLE` 절대 금지 (Flyway 책임)
- **DML만**: `INSERT`, `UPDATE`, `DELETE`만 허용
- **클린업 먼저**: DELETE → INSERT 순서
- **FK 순서**: 부모 먼저, 자식 나중

### 6. Gradle build.gradle 설정

```groovy
// domain/build.gradle
plugins {
    id 'java-library'
    id 'java-test-fixtures'  // ⭐ testFixtures 활성화
}

dependencies {
    // Test
    testImplementation libs.junit.jupiter
    testImplementation libs.archunit.junit5

    // Test Fixtures - Domain은 순수 Java만
    // NO external dependencies
}
```

```groovy
// application/build.gradle
plugins {
    id 'java-library'
    id 'java-test-fixtures'
}

dependencies {
    api project(':domain')

    // Test
    testImplementation libs.spring.boot.starter.test
    testImplementation testFixtures(project(':domain'))  // ⭐ Domain Fixture

    // Test Fixtures
    testFixturesApi project(':domain')
    testFixturesApi testFixtures(project(':domain'))
}
```

```groovy
// bootstrap/build.gradle (Integration Test)
dependencies {
    testImplementation libs.spring.boot.starter.test
    testImplementation libs.testcontainers.mysql
    testImplementation libs.testcontainers.junit

    // Fixtures
    testImplementation testFixtures(project(':domain'))
    testImplementation testFixtures(project(':application'))
    testImplementation testFixtures(project(':adapter-in:rest-api'))
}
```

---

## 테스트 실행 흐름

```
1. TestContainers 시작
   └─ Docker → MySQL 컨테이너 시작

2. Spring Boot 시작 (@SpringBootTest)
   └─ 전체 Bean 로딩

3. Flyway 자동 실행 (spring.flyway.enabled=true)
   └─ V1 → V2 → V3 ... (테이블 생성)

4. @Sql 실행 (각 테스트 메서드 전)
   └─ INSERT 테스트 데이터

5. 테스트 메서드 실행
   └─ TestRestTemplate → Controller → UseCase → Repository → DB

6. @Transactional 롤백
   └─ @Sql 데이터 자동 삭제

7. 다음 테스트 메서드 (4~6 반복)

8. TestContainers 종료
   └─ MySQL 컨테이너 삭제
```

---

## Fixture 의존성 규칙

### 허용되는 의존성 (✅)

```
domain testFixtures
    ↓ 의존
  domain (Production)

application testFixtures
    ↓ 의존              ↓ 의존
  application      domain testFixtures

adapter-in testFixtures
    ↓ 의존                    ↓ 의존
  adapter-in         application testFixtures
```

### 금지된 의존성 (❌)

```
domain testFixtures → application testFixtures   ❌ 역방향
application testFixtures → adapter-* testFixtures   ❌ 역방향
adapter-in testFixtures → adapter-out testFixtures   ❌ 교차 금지
```

### 의존성 매트릭스

| From ↓ / To → | domain Fixture | application Fixture | adapter Fixture |
|---------------|----------------|---------------------|-----------------|
| **domain tests** | ✅ | ❌ | ❌ |
| **application tests** | ✅ | ✅ | ❌ |
| **adapter-in tests** | ✅ | ✅ | ✅ (in만) |
| **adapter-out tests** | ✅ | ❌ | ✅ (out만) |

---

## Zero-Tolerance 규칙

### ✅ MANDATORY (필수)

| 규칙 | 설명 |
|------|------|
| `@SpringBootTest(RANDOM_PORT)` | 전체 컨텍스트 + 실제 HTTP 서버 |
| TestRestTemplate | 실제 HTTP 요청/응답 검증 |
| `@Transactional` | 테스트 격리, 자동 롤백 |
| `@Sql` DML만 | INSERT, UPDATE, DELETE만 |
| `@ActiveProfiles("test")` | 테스트 전용 설정 |
| `@Testcontainers` | 실제 DB (MySQL) |
| Fixture: final 클래스 | 상속 금지 |
| Fixture: private 생성자 | 인스턴스 생성 금지 |
| Fixture: static 메서드 | 유틸리티 패턴 |
| `*Fixture` 접미사 | 네이밍 규칙 |

### ❌ PROHIBITED (금지)

| 항목 | 이유 |
|------|------|
| MockMvc | 가짜 HTTP, TestRestTemplate 사용 |
| `@Sql`에 DDL | CREATE TABLE 금지, Flyway 책임 |
| `@WebMvcTest` | 통합 테스트는 `@SpringBootTest` |
| `@MockBean` 남발 | 실제 Bean 사용 (통합 테스트) |
| EntityManager.persist() | @Sql 사용, SQL 파일로 관리 |
| `@DirtiesContext` | 느림, `@Transactional` 롤백 사용 |
| 역방향 Fixture 의존 | domain → application 금지 |
| H2 사용 | MySQL (TestContainers) 사용 |

---

## 패키지 구조

```
project/
├── domain/
│   ├── src/main/java/
│   ├── src/test/java/
│   └── src/testFixtures/java/
│       └── com/ryuqq/fixture/domain/
│           ├── OrderFixture.java
│           ├── ProductFixture.java
│           └── CustomerFixture.java
│
├── application/
│   ├── src/main/java/
│   ├── src/test/java/
│   └── src/testFixtures/java/
│       └── com/ryuqq/fixture/application/
│           ├── command/
│           │   └── PlaceOrderCommandFixture.java
│           └── response/
│               └── OrderResponseFixture.java
│
├── adapter-in/rest-api/
│   ├── src/main/java/
│   ├── src/test/java/
│   └── src/testFixtures/java/
│       └── com/ryuqq/fixture/adapter/rest/
│           └── OrderRequestFixture.java
│
├── adapter-out/persistence-mysql/
│   ├── src/main/java/
│   ├── src/test/java/
│   └── src/testFixtures/java/
│       └── com/ryuqq/fixture/adapter/persistence/
│           └── OrderEntityFixture.java
│
└── bootstrap/
    └── src/test/
        ├── java/
        │   └── com/ryuqq/bootstrap/
        │       └── OrderIntegrationTest.java
        └── resources/sql/
            └── orders-test-data.sql
```

---

## 체크리스트 (Output Checklist)

### Integration Test
- [ ] `@SpringBootTest(webEnvironment = RANDOM_PORT)`
- [ ] `@ActiveProfiles("test")`
- [ ] `@Testcontainers` + `@Container MySQLContainer`
- [ ] `@Transactional` 테스트 격리
- [ ] TestRestTemplate 주입 (MockMvc 금지)
- [ ] `@Sql("/sql/test-data.sql")` 테스트 데이터
- [ ] `@DisplayName` 테스트 설명
- [ ] Given/When/Then 패턴
- [ ] HTTP 상태 코드 검증
- [ ] 응답 Body 검증

### Domain Fixture
- [ ] 위치: `domain/src/testFixtures/java/.../fixture/domain/`
- [ ] `public final class {Aggregate}Fixture`
- [ ] `private` 생성자 + `AssertionError`
- [ ] `static` 메서드만
- [ ] `defaultNewOrder()` - 신규 객체
- [ ] `defaultExistingOrder()` - 기존 객체
- [ ] `customOrder(...)` - 커스텀 빌더
- [ ] Domain 객체만 의존

### Application Fixture
- [ ] 위치: `application/src/testFixtures/java/.../fixture/application/`
- [ ] Command/Query/Response 별 Fixture
- [ ] Domain Fixture 재사용 가능
- [ ] Adapter Fixture 의존 금지

### @Sql 파일
- [ ] 위치: `src/test/resources/sql/`
- [ ] DDL 금지 (CREATE TABLE 없음)
- [ ] DML만 (INSERT, UPDATE, DELETE)
- [ ] DELETE 먼저 (클린업)
- [ ] INSERT 나중 (FK 순서)
- [ ] `OVERRIDING SYSTEM VALUE` (ID 명시)

### Gradle 설정
- [ ] `java-test-fixtures` 플러그인
- [ ] `testFixtures(project(':domain'))` 의존성
- [ ] `testFixturesApi` 전파 설정
- [ ] TestContainers 의존성

---

## ArchUnit 테스트 체크리스트

### Fixture 의존성 규칙 (9개)

- [ ] domain Fixture: domain만 의존
- [ ] application Fixture: application + domain Fixture 의존
- [ ] domain Fixture → application Fixture 금지
- [ ] application Fixture → adapter Fixture 금지
- [ ] adapter-in Fixture → adapter-out Fixture 금지
- [ ] adapter-out Fixture → adapter-in Fixture 금지
- [ ] Fixture 클래스: public
- [ ] Fixture 클래스: `*Fixture` 접미사
- [ ] Fixture 클래스: fixture 패키지 위치

---

## Fixture 네이밍 컨벤션

| 패턴 | 용도 | 예시 |
|------|------|------|
| `default*()` | 기본 객체 | `defaultOrder()`, `defaultNewOrder()` |
| `*WithStatus()` | 특정 상태 | `orderWithPendingStatus()` |
| `custom*()` | 커스텀 빌더 | `customOrder(Long id, ...)` |
| `invalid*()` | 유효하지 않은 객체 | `invalidOrder()` (예외 테스트) |
| `valid*Request()` | 유효한 요청 | `validCreateRequest()` |
| `invalid*Request_*()` | 무효 요청 (사유) | `invalidRequest_EmptyItems()` |

---

## 참조 문서

- **Integration Test Guide**: `docs/coding_convention/05-testing/integration-testing/01_integration-testing-overview.md`
- **Test Fixtures Guide**: `docs/coding_convention/05-testing/test-fixtures/01_test-fixtures-guide.md`
- **Test Fixtures ArchUnit**: `docs/coding_convention/05-testing/test-fixtures/02_test-fixtures-archunit.md`
- **Flyway Guide**: `docs/coding_convention/04-persistence-layer/mysql/config/flyway-guide.md`
