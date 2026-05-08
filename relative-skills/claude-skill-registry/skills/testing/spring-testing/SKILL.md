---
name: spring-testing
description: Test Spring Boot applications - MockMvc, TestContainers, test slices, integration testing
sasmp_version: "1.3.0"
bonded_agent: 06-spring-testing
bond_type: PRIMARY_BOND
version: "2.0.0"
updated: "2024-12-30"
---

# Spring Testing Skill

Master testing Spring Boot applications with MockMvc, TestContainers, test slices, and comprehensive testing strategies.

## Overview

This skill covers the complete testing pyramid for Spring Boot applications from unit tests to integration tests.

## Parameters

| Name | Type | Required | Default | Validation |
|------|------|----------|---------|------------|
| `test_type` | enum | ✗ | unit | unit \| integration \| e2e |
| `slice` | enum | ✗ | - | web \| data \| json |
| `mock_strategy` | enum | ✗ | mockito | mockito \| mockbean \| wiremock |

## Topics Covered

### Core (Must Know)
- **Test Slices**: `@WebMvcTest`, `@DataJpaTest`, `@JsonTest`
- **MockMvc**: Controller testing without full server
- **Mockito**: Mocking dependencies

### Intermediate
- **TestContainers**: Real database testing with Docker
- **WireMock**: External service mocking
- **Security Testing**: `@WithMockUser`

### Advanced
- **Contract Testing**: Spring Cloud Contract
- **Performance Testing**: Response time assertions
- **Custom Test Slices**: Building reusable test configurations

## Code Examples

### WebMvcTest
```java
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Test
    void shouldReturnUser() throws Exception {
        when(userService.findById(1L)).thenReturn(new UserResponse(1L, "John"));

        mockMvc.perform(get("/api/users/{id}", 1L))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value(1))
            .andExpect(jsonPath("$.name").value("John"));
    }

    @Test
    void shouldReturn400WhenInvalid() throws Exception {
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\":\"\"}"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.errors.name").exists());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void shouldAllowAdminAccess() throws Exception {
        mockMvc.perform(get("/api/admin/users"))
            .andExpect(status().isOk());
    }
}
```

### DataJpaTest with TestContainers
```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = Replace.NONE)
@Testcontainers
class UserRepositoryTest {

    @Container
    @ServiceConnection
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    void shouldFindByEmail() {
        User user = new User("john@test.com", "John");
        entityManager.persistAndFlush(user);

        Optional<User> found = userRepository.findByEmail("john@test.com");

        assertThat(found).isPresent()
            .hasValueSatisfying(u -> assertThat(u.getName()).isEqualTo("John"));
    }
}
```

### Integration Test
```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@Testcontainers
class OrderIntegrationTest {

    @Container
    @ServiceConnection
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private OrderRepository orderRepository;

    @BeforeEach
    void setUp() {
        orderRepository.deleteAll();
    }

    @Test
    void shouldCreateOrder() {
        CreateOrderRequest request = new CreateOrderRequest("item1", 2);

        ResponseEntity<OrderResponse> response = restTemplate
            .postForEntity("/api/orders", request, OrderResponse.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody().id()).isNotNull();
        assertThat(orderRepository.findAll()).hasSize(1);
    }
}
```

### WireMock for External Services
```java
@SpringBootTest
@WireMockTest(httpPort = 8089)
class PaymentServiceTest {

    @Autowired
    private PaymentService paymentService;

    @Test
    void shouldProcessPayment() {
        stubFor(post("/payments")
            .willReturn(okJson("{\"transactionId\":\"TXN-123\",\"status\":\"SUCCESS\"}")));

        PaymentResult result = paymentService.charge(new BigDecimal("99.99"));

        assertThat(result.transactionId()).isEqualTo("TXN-123");
        assertThat(result.status()).isEqualTo("SUCCESS");
    }
}
```

## Troubleshooting

### Failure Modes

| Issue | Diagnosis | Fix |
|-------|-----------|-----|
| Context not loading | Missing config | Add `@TestConfiguration` |
| MockBean not working | Wrong package | Check component scan |
| TestContainers timeout | Docker not running | Start Docker daemon |

### Debug Checklist

```
□ Check test annotations (@SpringBootTest, @WebMvcTest)
□ Verify MockBean setup
□ Confirm TestContainers are starting
□ Check application-test.yml is loaded
□ Enable debug logging for tests
```

## Test Configuration
```yaml
# application-test.yml
spring:
  jpa:
    show-sql: true
logging:
  level:
    org.springframework.test: DEBUG
    org.testcontainers: DEBUG
```

## Usage

```
Skill("spring-testing")
```

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2024-12-30 | TestContainers 1.19+, WireMock 3.x patterns |
| 1.0.0 | 2024-01-01 | Initial release |
