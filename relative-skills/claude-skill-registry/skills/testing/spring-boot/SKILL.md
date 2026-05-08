---
name: spring-boot
description: Comprehensive Spring Boot 3.x best practices for building scalable, maintainable enterprise applications with Jakarta EE. Use this skill when creating Spring Boot applications, designing REST APIs, implementing security, writing tests, or architecting Spring Boot projects. Covers Controller-Service-Repository patterns, validation, error handling, testing strategies, performance optimization, and production-ready configurations.
version: 1.0.0
---

# Spring Boot 3.x Best Practices

This skill provides comprehensive guidance for building production-ready Spring Boot 3.x applications using Jakarta EE (JDK 17+). It covers architectural patterns, REST API development, security, testing, and performance optimization for enterprise applications.

## When to Use This Skill

Invoke this skill when:
- Creating or architecting Spring Boot applications
- Designing REST APIs with Spring MVC
- Implementing Spring Security and authentication
- Writing tests for Spring Boot applications
- Optimizing performance and configuring Spring Boot
- Organizing project structure and packages
- Handling exceptions and validation
- Working with JPA and data access

## Core Architectural Principles

### Layered Architecture (Controller-Service-Repository)

Spring Boot applications should follow the classic layered architecture pattern:

```
Controller Layer (HTTP concerns only)
    ↓
Service Layer (Business logic and orchestration)
    ↓
Repository Layer (Data access operations)
    ↓
Database
```

**Key Principles:**
- **Controllers**: Thin layer handling HTTP request/response mapping only
- **Services**: Contain all business logic and orchestrate data access
- **Repositories**: Handle only data access with Spring Data JPA
- **DTOs**: Use Data Transfer Objects for API contracts, never expose entities

**Never blur these boundaries:**
- Controllers should NOT contain business logic
- Services should NOT handle HTTP concerns
- Repositories should NOT contain business rules

### Package Organization

For small to medium applications, organize by layer:
```
com.example.app
├── controller/
├── service/
├── repository/
├── model/ (or entity/)
├── dto/
├── config/
├── exception/
└── util/
```

For larger applications, organize by feature/domain:
```
com.example.app
├── user/
│   ├── Usercontroller.java
│   ├── UserService.java
│   ├── UserRepository.java
│   ├── User.java
│   └── UserDTO.java
├── order/
│   ├── OrderController.java
│   ├── OrderService.java
│   └── OrderRepository.java
├── config/
└── shared/
    ├── exceptions/
    └── dtos/
```

Feature-based organization scales better as applications grow.

## Essential Best Practices

### 1. Jakarta EE Namespace (Spring Boot 3.x Critical)

Spring Boot 3.x uses Jakarta EE instead of Java EE. All imports must use `jakarta.*`:

```java
// CORRECT for Spring Boot 3.x
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.validation.constraints.NotNull;
import jakarta.servlet.http.HttpServletRequest;

// WRONG - javax.* is for Spring Boot 2.x
import javax.persistence.Entity;  // Don't use!
```

**Common Jakarta EE imports:**
- `jakarta.persistence.*` - JPA annotations
- `jakarta.validation.*` - Bean validation
- `jakarta.servlet.*` - Servlet API
- `jakarta.transaction.*` - Transactions
- `jakarta.inject.*` - Dependency injection

### 2. Controller Best Practices

**Keep controllers thin:**
```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    // Constructor injection (required for testing)
    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUser(@PathVariable Long id) {
        // Controller only handles HTTP concerns
        return ResponseEntity.ok(userService.findById(id));
    }

    @PostMapping
    public ResponseEntity<UserDTO> createUser(@Valid @RequestBody CreateUserRequest request) {
        // Delegate business logic to service
        UserDTO created = userService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
}
```

**Controller responsibilities:**
- Map HTTP methods to service calls
- Handle request/response status codes
- Return proper HTTP status (200, 201, 204, 400, 404, etc.)
- Validate input with `@Valid`
- Nothing else - no business logic!

### 3. Service Layer Best Practices

**Services contain business logic:**
```java
@Service
@Transactional
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public UserDTO findById(Long id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return UserMapper.toDTO(user);
    }

    public UserDTO create(CreateUserRequest request) {
        // Business logic validation
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("Email already exists");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        User saved = userRepository.save(user);
        return UserMapper.toDTO(saved);
    }
}
```

**Service responsibilities:**
- Implement business rules
- Validate business constraints
- Orchestrate multiple repository calls
- Handle transactions with `@Transactional`
- Throw business exceptions

### 4. Repository Pattern

**Use Spring Data JPA repositories:**
```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    @Query("SELECT u FROM User u WHERE u.email = :email")
    Optional<User> findByEmailCustom(@Param("email") String email);
}
```

**Repository best practices:**
- Extend `JpaRepository` for basic CRUD
- Use query methods for simple queries (`findByEmail`, `existsByEmail`)
- Use `@Query` for complex queries
- Never put business logic in repositories
- Consider DTO projections for read-only queries

### 5. DTO Pattern

**Never expose entities directly to APIs:**
```java
// Entity (for database)
@Entity
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String email;
    private String password;  // Sensitive data!
    private LocalDateTime createdAt;

    // Relationships, lazy loading, etc.
}

// DTO (for API)
public class UserDTO {
    private Long id;
    private String email;
    private LocalDateTime createdAt;

    // No password, no JPA annotations
    // Only what the API needs
}
```

**Why use DTOs:**
- Hide sensitive data (passwords, internal fields)
- Control API contract independently from database
- Avoid JPA lazy loading issues
- Prevent infinite recursion in JSON
- Decouple API from database schema

**Map entities to DTOs:**
```java
public class UserMapper {
    public static UserDTO toDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setEmail(user.getEmail());
        dto.setCreatedAt(user.getCreatedAt());
        return dto;
    }

    public static User toEntity(CreateUserRequest request) {
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(request.getPassword());
        return user;
    }
}
```

Or use mapping libraries like MapStruct or ModelMapper.

### 6. Exception Handling

**Global exception handler with `@ControllerAdvice`:**
```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFound(ResourceNotFoundException ex) {
        ErrorResponse error = new ErrorResponse(
            HttpStatus.NOT_FOUND.value(),
            ex.getMessage(),
            LocalDateTime.now()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
            errors.put(error.getField(), error.getDefaultMessage())
        );

        ErrorResponse error = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Validation failed",
            LocalDateTime.now(),
            errors
        );
        return ResponseEntity.badRequest().body(error);
    }
}
```

**Custom exception classes:**
```java
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}

public class DuplicateResourceException extends RuntimeException {
    public DuplicateResourceException(String message) {
        super(message);
    }
}
```

**Standard HTTP status codes:**
- `200 OK` - Successful retrieval
- `201 CREATED` - Successful creation
- `204 NO CONTENT` - Successful deletion
- `400 BAD REQUEST` - Validation errors
- `401 UNAUTHORIZED` - Authentication required
- `403 FORBIDDEN` - Insufficient permissions
- `404 NOT FOUND` - Resource not found
- `409 CONFLICT` - Duplicate resource
- `500 INTERNAL SERVER ERROR` - Server errors

### 7. Input Validation

**Use Bean Validation on DTOs:**
```java
public class CreateUserRequest {

    @NotNull(message = "Email is required")
    @Email(message = "Email must be valid")
    @NotBlank(message = "Email cannot be blank")
    private String email;

    @NotNull(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    @Pattern(regexp = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).*$",
             message = "Password must contain uppercase, lowercase, and number")
    private String password;

    @NotNull(message = "Name is required")
    @Size(min = 2, max = 50, message = "Name must be between 2 and 50 characters")
    private String name;

    // Getters and setters
}
```

**Enable validation in controllers:**
```java
@PostMapping
public ResponseEntity<UserDTO> create(@Valid @RequestBody CreateUserRequest request) {
    // @Valid triggers validation
    return ResponseEntity.ok(userService.create(request));
}
```

**Common validation annotations:**
- `@NotNull` - Field cannot be null
- `@NotBlank` - String cannot be null or empty
- `@NotEmpty` - Collection cannot be empty
- `@Size(min, max)` - String/collection size
- `@Min`, `@Max` - Numeric bounds
- `@Email` - Email format
- `@Pattern` - Regex pattern
- `@Past`, `@Future` - Date validation

### 8. Configuration

**Use `application.yml` for configuration:**
```yaml
spring:
  application:
    name: myapp
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: ${DB_USERNAME:user}
    password: ${DB_PASSWORD:pass}
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: validate  # Never use update in production
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true

server:
  port: 8080
  error:
    include-message: always
    include-binding-errors: always

logging:
  level:
    com.example.myapp: DEBUG
    org.springframework.web: INFO
```

**Use configuration properties:**
```java
@ConfigurationProperties(prefix = "app")
public class AppConfig {
    private String name;
    private Security security = new Security();

    // Getters and setters

    public static class Security {
        private String jwtSecret;
        private Long jwtExpiration = 86400L;  // Default value

        // Getters and setters
    }
}

// Enable with @ConfigurationPropertiesScan
```

**Use profiles for environments:**
```yaml
# application-dev.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb_dev

# application-prod.yml
spring:
  datasource:
    url: jdbc:postgresql://prod-server:5432/mydb_prod
```

Run with profile: `java -jar app.jar --spring.profiles.active=prod`

### 9. Testing

**Unit tests for services:**
```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UserService userService;

    @Test
    void findById_ShouldReturnUser_WhenUserExists() {
        // Given
        User user = new User();
        user.setId(1L);
        user.setEmail("test@example.com");

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        UserDTO result = userService.findById(1L);

        // Then
        assertNotNull(result);
        assertEquals("test@example.com", result.getEmail());
        verify(userRepository).findById(1L);
    }

    @Test
    void findById_ShouldThrowException_WhenUserNotFound() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.empty());

        // When/Then
        assertThrows(ResourceNotFoundException.class, () -> userService.findById(1L));
    }
}
```

**Integration tests for controllers:**
```java
@SpringBootTest
@AutoConfigureMockMvc
class UserControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private UserService userService;

    @Test
    void getUser_ShouldReturn200_WhenUserExists() throws Exception {
        // Given
        UserDTO userDTO = new UserDTO(1L, "test@example.com");
        when(userService.findById(1L)).thenReturn(userDTO);

        // When/Then
        mockMvc.perform(get("/api/users/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value(1))
            .andExpect(jsonPath("$.email").value("test@example.com"));
    }
}
```

**Test slicing for faster tests:**
```java
@WebMvcTest(UserController.class)  // Only load web layer
class UserControllerWebTest {
    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;
    // Test only web layer, faster than @SpringBootTest
}

@DataJpaTest  // Only load JPA layer
class UserRepositoryTest {
    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private UserRepository userRepository;
    // Test only repository
}
```

### 10. Security Best Practices

**Enable Spring Security:**
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            );
        return http.build();
    }
}
```

**Security best practices:**
- Never store passwords in plain text - use `PasswordEncoder`
- Use JWT for stateless authentication
- Validate all input (including path variables)
- Use parameterized queries to prevent SQL injection
- Enable CSRF protection for web apps, disable for APIs
- Use HTTPS in production
- Implement rate limiting
- Log security events
- Never expose stack traces to clients

### 11. Performance Optimization

**Enable caching:**
```java
@Configuration
@EnableCaching
public class CacheConfig {
    @Bean
    public CacheManager cacheManager() {
        return new ConcurrentMapCacheManager("users", "products");
    }
}

@Service
public class UserService {
    @Cacheable(value = "users", key = "#id")
    public UserDTO findById(Long id) {
        // Result cached automatically
    }

    @CacheEvict(value = "users", key = "#id")
    public void deleteUser(Long id) {
        // Cache cleared on delete
    }
}
```

**Database optimization:**
- Use `@EntityGraph` to solve N+1 queries
- Use DTO projections for read-only queries
- Enable connection pooling (HikariCP is default)
- Use pagination for large datasets: `Pageable`
- lazy load relationships, but be careful with LazyInitializationException
- Index frequently queried columns

**Async processing:**
```java
@Configuration
@EnableAsync
public class AsyncConfig {
    // Configure thread pool
}

@Service
public class EmailService {
    @Async
    public void sendEmail(String to, String subject) {
        // Runs asynchronously
    }
}
```

## Progressive Disclosure

This SKILL.md provides the core guidance for Spring Boot development. For detailed information on specific topics, refer to the reference files:

- **[references/project-structure.md](references/project-structure.md)** - Detailed package organization and architecture patterns
- **[references/rest-api-patterns.md](references/rest-api-patterns.md)** - REST API design, controller patterns, HTTP status codes
- **[references/data-layer.md](references/data-layer.md)** - JPA entities, repository patterns, transactions
- **[references/security.md](references/security.md)** - Spring Security, JWT, OAuth2, secure coding
- **[references/validation.md](references/validation.md)** - Bean validation, custom validators, error handling
- **[references/testing.md](references/testing.md)** - Unit tests, integration tests, test slicing
- **[references/configuration.md](references/configuration.md)** - Configuration properties, profiles, externalized config
- **[references/performance.md](references/performance.md)** - Caching, optimization, monitoring

For working code examples, see:
- **[examples/controller-service-repo/](examples/controller-service-repo/)** - Complete CRUD example
- **[examples/exception-handling/](examples/exception-handling/)** - Exception handling patterns
- **[examples/security-config/](examples/security-config/)** - Security configuration

For complete project templates, see **[assets/templates/](assets/templates/)** for starter projects.

## Quick Reference

### Common Annotations

**Controllers:**
- `@RestController` - REST API controller
- `@RequestMapping` - Base path for controller
- `@GetMapping`, `@PostMapping`, etc. - HTTP method mapping
- `@PathVariable`, `@RequestParam`, `@RequestBody` - Bind parameters

**Services:**
- `@Service` - Service layer component
- `@Transactional` - Transaction boundary

**Repositories:**
- `@Repository` - Data access component
- `@Entity`, `@Id`, `@GeneratedValue` - JPA entity
- `@Query` - Custom query

**Validation:**
- `@Valid` - Trigger validation
- `@NotNull`, `@NotBlank`, `@Email`, `@Size` - Bean validation

**Configuration:**
- `@Configuration` - Configuration class
- `@Bean` - Bean definition
- `@ConfigurationProperties` - Type-safe configuration

### Dependencies

Essential Spring Boot dependencies (use `start.spring.io`):

```xml
<!-- Core -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<!-- Data -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- Validation -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>

<!-- Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- Testing -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

## Common Pitfalls to Avoid

1. **Using `javax.*` imports** - Spring Boot 3.x requires `jakarta.*`
2. **Exposing entities to API** - Always use DTOs
3. **Business logic in controllers** - Keep controllers thin
4. **N+1 query problems** - Use `@EntityGraph` or JOIN FETCH
5. **LazyInitializationException** - Use `@Transactional` or fetch eagerly
6. **Hardcoded configuration** - Use application.yml and profiles
7. **Swallowing exceptions** - Handle and log properly
8. **Not testing** - Write unit and integration tests
9. **Using `ddl-auto: update`** - Use Flyway/Liquibase for migrations
10. **Password in plain text** - Always use password encoding

Remember: This skill provides the foundation. Always refer to the [reference files](references/) for detailed guidance on specific topics.
