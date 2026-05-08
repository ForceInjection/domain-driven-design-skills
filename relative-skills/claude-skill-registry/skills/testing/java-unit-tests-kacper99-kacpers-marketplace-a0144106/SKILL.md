---
name: java-unit-tests
description: Comprehensive guidance for writing high-quality unit tests in Java projects using JUnit 5 and AssertJ. Use when writing unit tests, creating test classes, or need guidance on mocking strategies, assertions, test builders, or JUnit 5 best practices. Requires JUnit 5, AssertJ, and Mockito dependencies.
---

# Java Unit Testing Skill

## Overview
This skill provides comprehensive guidance for writing high-quality unit tests in Java projects using JUnit 5 and AssertJ. It enforces best practices for test structure, mocking strategy, and assertion patterns.

## Core Principles

### Test Structure
- Use `lower_snake_case` for test method names
- Annotate test phases with `// given`, `// when`, `// then` comments
- One logical assertion per test (multiple chained AssertJ assertions are acceptable)
- Tests should be self-contained and independent
- Use `@BeforeEach` sparingly - prefer test-scoped setup in the given phase
- Inline simple construction as `private final` fields when the class under test doesn't need setup

### Mocking Strategy
**Critical Rules:**
- **NEVER mock domain objects** - Domain objects should be real instances
- **Fake over mock** - If a dependency is a functional interface or single-method interface, create a fake implementation instead of mocking
- **Mock external dependencies** - Services, repositories, and infrastructure components should be mocked
- Use static `mock()` methods, not `@Mock` or `@InjectMocks` annotations
- Inline simple construction as `private final` fields instead of using `@BeforeEach`
- **Be explicit in `when()` blocks** - Use specific parameter values instead of `any()` matchers when the parameter matters to the test

### Assertion Guidelines
- **Always use AssertJ** - Never use JUnit assertions
- Chain assertions fluently for readability
- Use soft assertions when validating multiple conditions on the same object
- Prefer specific assertions over generic ones (e.g., `hasSize()` over `satisfies()`)
- Use `assertThatCode()` for verifying no exception is thrown
- Leverage `usingRecursiveComparison()` for complex object equality
- Use `extracting()` with multiple fields for cleaner assertions
- Consider custom assertions for domain-specific validation

### Test Data Management
- Check for existing test builders or fixtures before creating domain objects
- If no builder exists for commonly used domain objects, create one using the Builder pattern
- Use meaningful test data that clarifies the test's intent
- Avoid test data pollution - use minimal data needed for the test

### Test Organization
- Use `@Nested` classes to group related test scenarios and improve readability
- Nested classes provide better structure for testing different states or contexts
- Each nested class can have its own setup specific to that scenario

## Implementation Guide

### 1. Basic Test Structure

```java
class ServiceUnderTestTest {
    
    private final ExternalService externalService = mock(ExternalService.class);
    private final ServiceUnderTest serviceUnderTest = new ServiceUnderTest(externalService);
    
    @Test
    void should_return_processed_result_when_input_is_valid() {
        // given
        var input = new Input("valid-data");
        when(externalService.process(input)).thenReturn("processed");
        
        // when
        var result = serviceUnderTest.execute(input);
        
        // then
        assertThat(result)
            .isNotNull()
            .extracting(Result::getValue)
            .isEqualTo("processed");
    }
}
```

### 2. Faking Functional Interfaces

Instead of mocking:
```java
// ❌ DON'T
@Mock
private Validator<String> validator;

@Test
void test_validation() {
    when(validator.validate("test")).thenReturn(ValidationResult.valid());
    // ...
}
```

Create a fake:
```java
// ✅ DO
@Test
void should_accept_valid_input() {
    // given
    Validator<String> validator = input -> 
        input.length() > 5 ? ValidationResult.valid() : ValidationResult.invalid("Too short");
    var service = new ServiceUnderTest(validator);
    
    // when
    var result = service.process("valid-input");
    
    // then
    assertThat(result).isNotNull();
}
```

### 3. Domain Objects - Never Mock

```java
// ❌ DON'T
@Mock
private User user;

@Test
void test_user_processing() {
    when(user.getName()).thenReturn("John");
    when(user.getAge()).thenReturn(30);
    // ...
}
```

```java
// ✅ DO - Use real domain objects
@Test
void should_process_adult_user() {
    // given
    var user = User.builder()
        .name("John")
        .age(30)
        .build();
    
    // when
    var result = service.processUser(user);
    
    // then
    assertThat(result.isAdult()).isTrue();
}
```

### 4. Test Builders

Create builders for complex domain objects:

```java
public class OrderTestBuilder {
    private String orderId = "default-id";
    private List<OrderItem> items = new ArrayList<>();
    private OrderStatus status = OrderStatus.PENDING;
    private LocalDateTime createdAt = LocalDateTime.now();
    
    public static OrderTestBuilder anOrder() {
        return new OrderTestBuilder();
    }
    
    public OrderTestBuilder withId(String orderId) {
        this.orderId = orderId;
        return this;
    }
    
    public OrderTestBuilder withItems(OrderItem... items) {
        this.items = Arrays.asList(items);
        return this;
    }
    
    public OrderTestBuilder withStatus(OrderStatus status) {
        this.status = status;
        return this;
    }
    
    public OrderTestBuilder completed() {
        this.status = OrderStatus.COMPLETED;
        return this;
    }
    
    public Order build() {
        return new Order(orderId, items, status, createdAt);
    }
}

// Usage in tests
@Test
void should_calculate_total_for_completed_order() {
    // given
    var order = anOrder()
        .withItems(
            new OrderItem("item-1", Money.of(10.00)),
            new OrderItem("item-2", Money.of(20.00))
        )
        .completed()
        .build();
    
    // when
    var total = service.calculateTotal(order);
    
    // then
    assertThat(total).isEqualTo(Money.of(30.00));
}
```

### 5. AssertJ Chaining

```java
@Test
void should_return_filtered_and_sorted_users() {
    // given
    var users = List.of(
        new User("Alice", 30),
        new User("Bob", 25),
        new User("Charlie", 35)
    );
    
    // when
    var result = service.getAdultUsersSortedByAge(users);
    
    // then
    assertThat(result)
        .hasSize(3)
        .extracting(User::getName)
        .containsExactly("Bob", "Alice", "Charlie");
}

@Test
void should_create_valid_response_with_all_fields() {
    // given
    var request = new Request("data");
    
    // when
    var response = service.handle(request);
    
    // then
    assertThat(response)
        .isNotNull()
        .satisfies(r -> {
            assertThat(r.getStatus()).isEqualTo(Status.SUCCESS);
            assertThat(r.getMessage()).isNotEmpty();
            assertThat(r.getTimestamp()).isBeforeOrEqualTo(LocalDateTime.now());
        });
}
```

### 6. Testing Exceptions

```java
@Test
void should_throw_exception_when_input_is_invalid() {
    // given
    var invalidInput = new Input(null);
    
    // when / then
    assertThatThrownBy(() -> service.process(invalidInput))
        .isInstanceOf(InvalidInputException.class)
        .hasMessage("Input cannot be null")
        .hasNoCause();
}

@Test
void should_throw_exception_with_proper_context() {
    // given
    var input = new Input("invalid");
    
    // when / then
    assertThatExceptionOfType(ValidationException.class)
        .isThrownBy(() -> service.validate(input))
        .withMessageContaining("invalid")
        .satisfies(ex -> {
            assertThat(ex.getErrorCode()).isEqualTo("VALIDATION_FAILED");
            assertThat(ex.getFields()).contains("input");
        });
}
```

### 7. Parameterized Tests

```java
@ParameterizedTest
@MethodSource("provideInvalidInputs")
void should_reject_invalid_inputs(String input, String expectedError) {
    // when / then
    assertThatThrownBy(() -> service.process(input))
        .isInstanceOf(ValidationException.class)
        .hasMessageContaining(expectedError);
}

private static Stream<Arguments> provideInvalidInputs() {
    return Stream.of(
        Arguments.of(null, "cannot be null"),
        Arguments.of("", "cannot be empty"),
        Arguments.of("   ", "cannot be blank")
    );
}

@ParameterizedTest
@CsvSource({
    "10, 20, 30",
    "5, 15, 20",
    "100, 200, 300"
})
void should_sum_two_numbers(int a, int b, int expected) {
    // when
    var result = calculator.add(a, b);
    
    // then
    assertThat(result).isEqualTo(expected);
}
```

### 8. Verification Patterns

```java
@Test
void should_call_external_service_with_correct_parameters() {
    // given
    var request = new Request("data");
    
    // when
    service.processRequest(request);
    
    // then
    verify(externalService).process(argThat(arg -> 
        arg.getData().equals("data") && 
        arg.getTimestamp() != null
    ));
}

@Test
void should_not_call_service_when_cache_hit() {
    // given
    var key = "cached-key";
    when(cache.get(key)).thenReturn(Optional.of("cached-value"));
    
    // when
    service.getValue(key);
    
    // then
    verify(externalService, never()).fetchValue(key);
}
```

**Verification Best Practices:**
- Prefer `verify()` with argument matchers over capturing arguments
- Use `argThat()` for complex argument validation instead of `ArgumentCaptor`
- Only capture arguments when you need to perform multiple assertions on them

### Stubbing Strategy: Explicit vs Lenient

**General Rule: Be explicit in `when()` blocks** - Use specific parameter values instead of `any()` when the parameter value matters to your test.

```java
// ✅ BETTER - Explicit expectations
@Test
void should_fetch_customer_by_specific_id() {
    // given
    var customerId = "customer-123";
    var customer = aCustomer().withId(customerId).build();
    when(customerRepository.findById(customerId)).thenReturn(Optional.of(customer));
    
    // when
    var result = service.getCustomer(customerId);
    
    // then
    assertThat(result).isEqualTo(customer);
    // No verify() needed - the when() already validates the correct parameter
}

// ❌ WORSE - Lenient stubbing requires verification
@Test
void should_fetch_customer_by_specific_id() {
    // given
    var customerId = "customer-123";
    var customer = aCustomer().withId(customerId).build();
    when(customerRepository.findById(any())).thenReturn(Optional.of(customer)); // Too lenient
    
    // when
    var result = service.getCustomer(customerId);
    
    // then
    assertThat(result).isEqualTo(customer);
    verify(customerRepository).findById(customerId); // Now we need verification
}
```

**Benefits of being explicit:**

1. **Catches bugs earlier** - If your code passes wrong parameters, the test fails immediately with "unexpected method call"
2. **Self-documenting** - The `given` section clearly shows expected inputs
3. **Less noise** - No redundant `verify()` calls just to check parameters
4. **Clearer intent** - Shows you care about _what_ is passed, not just _that_ something was called

**When to use `any()`:**

Use `any()` only when the parameter truly doesn't matter for the test scenario:

```java
// ✅ Appropriate use of any() - parameter content doesn't affect the test
@Test
void should_log_all_requests_regardless_of_content() {
    // given
    when(logger.log(any())).thenReturn(true);
    
    // when
    service.handleRequest(request1);
    service.handleRequest(request2);
    
    // then
    verify(logger, times(2)).log(any()); // We only care it was called twice
}

// ✅ Testing behavior that applies to any input
@Test
void should_sanitize_all_user_inputs() {
    // given
    when(sanitizer.clean(any())).thenAnswer(inv -> inv.getArgument(0) + "-cleaned");
    
    // when
    var result1 = service.process("input1");
    var result2 = service.process("input2");
    
    // then
    assertThat(result1).endsWith("-cleaned");
    assertThat(result2).endsWith("-cleaned");
}
```

**For complex parameters, use `argThat()` instead:**

```java
// ✅ Use argThat() when you care about specific fields
@Test
void should_save_order_with_correct_customer_id() {
    // given
    var customerId = "customer-123";
    var request = new OrderRequest(customerId, items);
    
    // when
    service.createOrder(request);
    
    // then
    verify(orderRepository).save(argThat(order ->
        order.getCustomerId().equals(customerId) &&
        order.getStatus() == OrderStatus.PENDING
    ));
}
```

### 9. Testing Collections

```java
@Test
void should_return_users_with_expected_properties() {
    // given
    var filter = new UserFilter(minAge = 18);
    
    // when
    var users = service.findUsers(filter);
    
    // then
    assertThat(users)
        .isNotEmpty()
        .allSatisfy(user -> assertThat(user.getAge()).isGreaterThanOrEqualTo(18))
        .extracting(User::getName)
        .containsExactlyInAnyOrder("Alice", "Bob", "Charlie");
}

@Test
void should_group_items_by_category() {
    // given
    var items = List.of(
        new Item("A", Category.FOOD),
        new Item("B", Category.ELECTRONICS),
        new Item("C", Category.FOOD)
    );
    
    // when
    var grouped = service.groupByCategory(items);
    
    // then
    assertThat(grouped)
        .containsOnlyKeys(Category.FOOD, Category.ELECTRONICS)
        .hasEntrySatisfying(Category.FOOD, 
            foodItems -> assertThat(foodItems).hasSize(2))
        .hasEntrySatisfying(Category.ELECTRONICS,
            electronicItems -> assertThat(electronicItems).hasSize(1));
}
```

### 10. Nested Tests for Organization

```java
@Nested
@DisplayName("When processing valid orders")
class ValidOrderProcessing {
    
    @Test
    void should_accept_order_with_items() {
        // given
        var order = anOrder().withItems(someItems()).build();
        
        // when
        var result = service.process(order);
        
        // then
        assertThat(result.isSuccess()).isTrue();
    }
    
    @Test
    void should_send_confirmation_email() {
        // given
        var order = anOrder().build();
        
        // when
        service.process(order);
        
        // then
        verify(emailService).sendConfirmation(order.getCustomerEmail());
    }
}

@Nested
@DisplayName("When processing invalid orders")
class InvalidOrderProcessing {
    
    @Test
    void should_reject_empty_order() {
        // given
        var order = anOrder().withItems().build();
        
        // when / then
        assertThatThrownBy(() -> service.process(order))
            .isInstanceOf(EmptyOrderException.class);
    }
}
```

## Using Context7 MCP for Documentation

When writing tests, use the context7 MCP to fetch current documentation:

```
// Query JUnit 5 features
context7:search("JUnit 5 parameterized tests")

// Query AssertJ assertions
context7:search("AssertJ collection assertions")

// Query Mockito verification
context7:search("Mockito argument matchers")
```

## Test Coverage and Quality Guidelines

### Coverage Principles
- **Test edge cases and boundary conditions explicitly** - Don't just test the happy path
- **Write tests for error paths, not just happy paths** - Verify exception handling and error scenarios
- **Cover null handling, empty collections, and invalid states** - These are common sources of bugs
- **Test boundary values** - For numeric inputs, test min, max, zero, negative values
- **Test state transitions** - Verify objects behave correctly as they move through different states

### What to Test
```java
// ✅ Test boundary conditions
@Test
void should_handle_empty_list() {
    // given
    var emptyList = List.of();
    
    // when
    var result = service.process(emptyList);
    
    // then
    assertThat(result).isEmpty();
}

@Test
void should_handle_single_item() {
    // given
    var singleItem = List.of(item);
    
    // when
    var result = service.process(singleItem);
    
    // then
    assertThat(result).hasSize(1);
}

// ✅ Test null handling
@Test
void should_throw_exception_when_required_field_is_null() {
    // given
    var invalidRequest = new Request(null, "value");
    
    // when / then
    assertThatThrownBy(() -> service.process(invalidRequest))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("required field cannot be null");
}

// ✅ Test error paths
@Test
void should_handle_external_service_failure_gracefully() {
    // given
    when(externalService.call()).thenThrow(new ServiceException("Service down"));
    
    // when
    var result = service.processWithFallback();
    
    // then
    assertThat(result.isSuccess()).isFalse();
    assertThat(result.getErrorMessage()).contains("Service unavailable");
}

// ✅ Test state transitions
@Test
void should_transition_from_pending_to_completed() {
    // given
    var order = anOrder().withStatus(OrderStatus.PENDING).build();
    
    // when
    order.complete();
    
    // then
    assertThat(order.getStatus()).isEqualTo(OrderStatus.COMPLETED);
    assertThat(order.getCompletedAt()).isNotNull();
}

@Test
void should_not_allow_completing_cancelled_order() {
    // given
    var order = anOrder().withStatus(OrderStatus.CANCELLED).build();
    
    // when / then
    assertThatThrownBy(() -> order.complete())
        .isInstanceOf(IllegalStateException.class)
        .hasMessageContaining("Cannot complete cancelled order");
}
```

## Checklist Before Writing Tests

1. ✅ Identify all dependencies - which should be mocked vs faked vs real?
2. ✅ Check for existing test builders or fixtures
3. ✅ Ensure domain objects are never mocked
4. ✅ Use AssertJ for all assertions
5. ✅ Follow given/when/then structure
6. ✅ Use `lower_snake_case` for test names
7. ✅ Verify tests are independent and don't share state
8. ✅ Ensure test names clearly describe the scenario and expected outcome

## Common Pitfalls to Avoid

- ❌ Mocking domain objects
- ❌ Using JUnit assertions instead of AssertJ
- ❌ Mocking functional interfaces instead of faking them
- ❌ Over-mocking - only mock what crosses architectural boundaries
- ❌ Testing implementation details instead of behavior
- ❌ Sharing mutable state between tests
- ❌ Using `CamelCase` or `camelCase` for test method names
- ❌ Missing or incorrect given/when/then annotations
- ❌ Creating complex domain objects when builders exist
- ❌ Using `any()` in `when()` blocks when you should be explicit about expected parameters
- ❌ Adding `verify()` calls just to check parameters that should have been explicit in `when()`

## Examples of Complete Test Classes

### Service with Repository and Domain Objects

```java
class OrderServiceTest {
    
    private final OrderRepository orderRepository = mock(OrderRepository.class);
    private final PaymentGateway paymentGateway = mock(PaymentGateway.class);
    private final OrderService orderService = new OrderService(orderRepository, paymentGateway);
    
    @Test
    void should_create_and_save_order_successfully() {
        // given
        var orderRequest = new OrderRequest(
            "customer-123",
            List.of(new OrderItem("product-1", 2))
        );
        var savedOrder = anOrder()
            .withId("order-456")
            .withCustomerId("customer-123")
            .build();
        
        when(orderRepository.save(any(Order.class))).thenReturn(savedOrder);
        
        // when
        var result = orderService.createOrder(orderRequest);
        
        // then
        assertThat(result)
            .isNotNull()
            .satisfies(order -> {
                assertThat(order.getId()).isEqualTo("order-456");
                assertThat(order.getCustomerId()).isEqualTo("customer-123");
                assertThat(order.getStatus()).isEqualTo(OrderStatus.PENDING);
            });
        
        verify(orderRepository).save(argThat(order ->
            order.getCustomerId().equals("customer-123") &&
            order.getItems().size() == 1
        ));
    }
    
    @Test
    void should_process_payment_and_update_order_status() {
        // given
        var order = anOrder()
            .withId("order-789")
            .withStatus(OrderStatus.PENDING)
            .build();
        var paymentRequest = new PaymentRequest("order-789", order.getTotal());
        
        when(orderRepository.findById("order-789")).thenReturn(Optional.of(order));
        when(paymentGateway.processPayment(paymentRequest)).thenReturn(
            new PaymentResult(true, "transaction-123")
        );
        
        // when
        orderService.processPayment("order-789");
        
        // then
        verify(orderRepository).save(argThat(saved ->
            saved.getStatus() == OrderStatus.PAID &&
            saved.getPaymentTransactionId().equals("transaction-123")
        ));
    }
}
```

### Testing with Functional Interface (Fake, not Mock)

```java
class ValidationServiceTest {
    
    @Test
    void should_validate_email_format() {
        // given
        EmailValidator emailValidator = email -> 
            email.contains("@") && email.contains(".");
        
        var service = new ValidationService(emailValidator);
        var validEmail = "user@example.com";
        var invalidEmail = "invalid-email";
        
        // when
        var validResult = service.validateEmail(validEmail);
        var invalidResult = service.validateEmail(invalidEmail);
        
        // then
        assertThat(validResult.isValid()).isTrue();
        assertThat(invalidResult.isValid()).isFalse();
    }
    
    @Test
    void should_apply_custom_business_rule() {
        // given
        BusinessRule<Order> minimumOrderRule = order ->
            order.getTotal().compareTo(Money.of(10.00)) >= 0;
        
        var service = new OrderValidationService(minimumOrderRule);
        var validOrder = anOrder().withTotal(Money.of(15.00)).build();
        var invalidOrder = anOrder().withTotal(Money.of(5.00)).build();
        
        // when
        var validResult = service.validate(validOrder);
        var invalidResult = service.validate(invalidOrder);
        
        // then
        assertThat(validResult.isValid()).isTrue();
        assertThat(invalidResult.isValid()).isFalse();
        assertThat(invalidResult.getError())
            .contains("minimum order");
    }
}
```
