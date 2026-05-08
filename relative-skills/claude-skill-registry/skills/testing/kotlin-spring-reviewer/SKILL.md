---
name: kotlin-spring-reviewer
description: |
  WHEN: Spring Boot + Kotlin, Ktor backend review, coroutine-based server, WebFlux/R2DBC pattern checks
  WHAT: Spring Kotlin idioms + Coroutines integration + WebFlux patterns + Data class usage + Test strategies
  WHEN NOT: Android → kotlin-android-reviewer, KMP shared code → kotlin-multiplatform-reviewer
---

# Kotlin Spring Reviewer Skill

## Purpose
Reviews Spring Boot + Kotlin and Ktor backend projects for Kotlin idioms, Coroutines integration, WebFlux, and data class best practices.

## When to Use
- Spring Boot + Kotlin project code review
- Ktor server project review
- "WebFlux", "R2DBC", "Coroutines server" mentions
- Projects with `spring-boot` or `ktor` in `build.gradle.kts`

## Project Detection
- `org.springframework.boot` plugin in `build.gradle.kts`
- `io.ktor` dependency in `build.gradle.kts`
- `application.yml` or `application.properties`
- `Application.kt` main class

## Workflow

### Step 1: Analyze Project
```
**Framework**: Spring Boot 3.2.x
**Kotlin**: 1.9.x
**Build Tool**: Gradle (Kotlin DSL)
**Dependencies**:
  - Spring WebFlux (reactive)
  - Spring Data R2DBC
  - Kotlinx Coroutines
```

### Step 2: Select Review Areas
**AskUserQuestion:**
```
"Which areas to review?"
Options:
- Full Kotlin Spring pattern check (recommended)
- Kotlin idiom usage
- Coroutines/WebFlux integration
- Data class/DTO design
- Test strategies
multiSelect: true
```

## Detection Rules

### Kotlin Idioms
| Check | Recommendation | Severity |
|-------|----------------|----------|
| Java-style getter/setter | Use Kotlin property | LOW |
| if-based null check | Use ?.let, ?:, avoid !! | MEDIUM |
| if-else chain | Use when expression | LOW |
| Missing extension functions | Utility → extension function | LOW |
| Missing scope functions | Use apply, let, run, also | LOW |

```kotlin
// BAD: Java style
class User {
    private var name: String? = null
    fun getName(): String? = name
    fun setName(name: String?) { this.name = name }
}

// GOOD: Kotlin property
class User {
    var name: String? = null
}

// BAD: Java-style null check
fun process(user: User?) {
    if (user != null) {
        if (user.name != null) {
            println(user.name)
        }
    }
}

// GOOD: Kotlin null-safe operators
fun process(user: User?) {
    user?.name?.let { println(it) }
}

// BAD: if-else chain
fun getStatus(code: Int): String {
    if (code == 200) return "OK"
    else if (code == 404) return "Not Found"
    else return "Unknown"
}

// GOOD: when expression
fun getStatus(code: Int): String = when (code) {
    200 -> "OK"
    404 -> "Not Found"
    else -> "Unknown"
}
```

### Spring + Kotlin Patterns
| Check | Recommendation | Severity |
|-------|----------------|----------|
| @Autowired field injection | Constructor injection | HIGH |
| lateinit var abuse | Constructor injection or lazy | MEDIUM |
| Missing open class | Use all-open plugin | HIGH |
| data class @Entity | Use regular class | HIGH |

```kotlin
// BAD: Field injection
@Service
class UserService {
    @Autowired
    private lateinit var userRepository: UserRepository
}

// GOOD: Constructor injection (Kotlin default)
@Service
class UserService(
    private val userRepository: UserRepository
)

// BAD: data class as JPA Entity
@Entity
data class User(
    @Id val id: Long,
    val name: String
)  // equals/hashCode issues

// GOOD: Regular class with explicit equals/hashCode
@Entity
class User(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null,
    var name: String
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is User) return false
        return id != null && id == other.id
    }
    override fun hashCode(): Int = javaClass.hashCode()
}
```

**Gradle Plugin Check:**
```kotlin
// build.gradle.kts
plugins {
    kotlin("plugin.spring")  // all-open for Spring
    kotlin("plugin.jpa")     // no-arg for JPA entities
}
```

### Coroutines Integration
| Check | Recommendation | Severity |
|-------|----------------|----------|
| runBlocking in controller | Use suspend function | CRITICAL |
| GlobalScope in server | Use structured concurrency | CRITICAL |
| Missing Dispatcher | Specify IO/Default | MEDIUM |
| Missing exception handling | Use CoroutineExceptionHandler | HIGH |

```kotlin
// BAD: runBlocking in controller
@GetMapping("/users")
fun getUsers(): List<User> = runBlocking {
    userService.getUsers()
}

// GOOD: suspend function (WebFlux/Coroutines)
@GetMapping("/users")
suspend fun getUsers(): List<User> =
    userService.getUsers()

// BAD: GlobalScope in service
@Service
class UserService {
    fun processAsync() {
        GlobalScope.launch {
            // Dangerous: Not cancelled on app shutdown
        }
    }
}

// GOOD: Structured concurrency
@Service
class UserService(
    private val applicationScope: CoroutineScope
) {
    fun processAsync() = applicationScope.launch {
        // Properly cancelled on app shutdown
    }
}
```

### WebFlux + Coroutines
| Check | Recommendation | Severity |
|-------|----------------|----------|
| Direct Mono/Flux usage | Convert to suspend/Flow | MEDIUM |
| awaitSingle abuse | Use coRouter DSL | LOW |
| Blocking call | Use Dispatchers.IO | CRITICAL |

```kotlin
// OK: Direct Mono/Flux
@GetMapping("/user/{id}")
fun getUser(@PathVariable id: Long): Mono<User> =
    userRepository.findById(id)

// BETTER: Kotlin Coroutines
@GetMapping("/user/{id}")
suspend fun getUser(@PathVariable id: Long): User? =
    userRepository.findById(id).awaitSingleOrNull()

// BEST: coRouter DSL (functional endpoints)
@Configuration
class RouterConfig {
    @Bean
    fun routes(handler: UserHandler) = coRouter {
        "/api/users".nest {
            GET("", handler::getAll)
            GET("/{id}", handler::getById)
            POST("", handler::create)
        }
    }
}

class UserHandler(private val service: UserService) {
    suspend fun getAll(request: ServerRequest): ServerResponse =
        ServerResponse.ok().bodyAndAwait(service.getAll())
}
```

### Ktor Patterns
| Check | Recommendation | Severity |
|-------|----------------|----------|
| Excessive routing nesting | Split into modules | MEDIUM |
| No DI | Use Koin/Kodein | MEDIUM |
| Missing error handling | Use StatusPages plugin | HIGH |
| Missing serialization | Use ContentNegotiation | HIGH |

```kotlin
// BAD: All routes in one file
fun Application.module() {
    routing {
        get("/users") { /* ... */ }
        get("/users/{id}") { /* ... */ }
        get("/products") { /* ... */ }
        // ... 100 more
    }
}

// GOOD: Split into modules
fun Application.module() {
    configureRouting()
    configureSerialization()
    configureDI()
}

fun Application.configureRouting() {
    routing {
        userRoutes()
        productRoutes()
    }
}

fun Route.userRoutes() {
    route("/users") {
        get { /* ... */ }
        get("/{id}") { /* ... */ }
        post { /* ... */ }
    }
}
```

### Data Class Design
| Check | Recommendation | Severity |
|-------|----------------|----------|
| var in DTO | Use val (immutable) | MEDIUM |
| Excessive nullable | Use defaults or required | LOW |
| Missing validation | Use @field:Valid, init {} | MEDIUM |

```kotlin
// BAD: Mutable DTO
data class CreateUserRequest(
    var name: String?,
    var email: String?
)

// GOOD: Immutable + validation
data class CreateUserRequest(
    @field:NotBlank
    val name: String,

    @field:Email
    val email: String
) {
    init {
        require(name.length <= 100) { "Name too long" }
    }
}
```

## Response Template
```
## Kotlin Spring Code Review Results

**Project**: [name]
**Spring Boot**: 3.2.x | **Kotlin**: 1.9.x
**Stack**: WebFlux + R2DBC + Coroutines

### Kotlin Idioms
| Status | File | Issue |
|--------|------|-------|
| LOW | UserService.kt | Java-style null check → ?.let recommended |

### Spring Patterns
| Status | File | Issue |
|--------|------|-------|
| HIGH | ProductService.kt | @Autowired field injection → constructor injection |
| HIGH | User.kt | data class @Entity → regular class |

### Coroutines
| Status | File | Issue |
|--------|------|-------|
| CRITICAL | ReportService.kt | runBlocking in controller |
| HIGH | BatchJob.kt | GlobalScope usage |

### Recommended Actions
1. [ ] Verify kotlin-spring, kotlin-jpa plugins
2. [ ] runBlocking → suspend function conversion
3. [ ] GlobalScope → applicationScope injection
4. [ ] data class Entity → regular class change
```

## Best Practices
1. **Constructor Injection**: Use default constructor instead of @Autowired
2. **Immutability**: val, data class (except Entity)
3. **Coroutines**: suspend functions, structured concurrency
4. **Kotlin DSL**: coRouter, bean { }
5. **Testing**: MockK, Kotest, @SpringBootTest

## Integration
- `code-reviewer` skill: General code quality
- `kotlin-multiplatform-reviewer` skill: KMP server sharing
- `security-scanner` skill: API security checks

## Notes
- Based on Spring Boot 3.x + Kotlin 1.9+
- WebFlux/R2DBC reactive stack support
- Ktor 2.x support
