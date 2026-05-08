---
name: android-testing
description: |
  Provides Android testing patterns and templates for JUnit5, MockK, Turbine,
  and Compose UI testing. Use when writing tests, implementing TDD, validating
  code coverage, or reviewing test quality. Use when user mentions:
  테스트, TDD, 단위 테스트, UI 테스트, 커버리지, 목(mock), 테스트 작성,
  테스트 템플릿, ViewModel 테스트, UseCase 테스트, Compose 테스트.
allowed-tools: Read, Glob, Grep
---

# Android Testing Guide

JUnit5, MockK, Turbine, Compose UI Testing을 사용한 테스트 가이드입니다.

## Testing Stack

| Type | Framework | Purpose |
|------|-----------|---------|
| **Unit** | JUnit5 + MockK | ViewModel, UseCase, Repository |
| **Flow** | Turbine | StateFlow, Channel testing |
| **Coroutines** | kotlinx-coroutines-test | runTest, advanceUntilIdle |
| **UI** | Compose Testing | Composable rendering, interaction |
| **Integration** | Hilt Testing | DI integration |

## Coverage Target

- **Overall**: 80%+
- **Domain Layer**: 90%+ (pure business logic)
- **Presentation Layer**: 70%+ (ViewModel, state logic)
- **Data Layer**: 60%+ (repository, mapper)

## Quick Test Commands

```bash
# All tests
./gradlew test

# Module tests
./gradlew :feature:home:testDebugUnitTest
./gradlew :core:domain:test

# With coverage
./gradlew testDebugUnitTestCoverage

# Single test class
./gradlew test --tests "*.HomeViewModelTest"
```

## Test Templates

테스트 함수 이름은 되도록 한국어로 작성 해주세요.

### ViewModel Test
ViewModel 테스트는 state 변화와 effect 발생을 검증합니다.

**상세 템플릿:** [templates/viewmodel-test.md](templates/viewmodel-test.md)

### UseCase Test
UseCase 테스트는 비즈니스 로직과 repository 호출을 검증합니다.

**상세 템플릿:** [templates/usecase-test.md](templates/usecase-test.md)

### Compose UI Test
Compose 테스트는 UI 렌더링과 사용자 상호작용을 검증합니다.

**상세 템플릿:** [templates/compose-test.md](templates/compose-test.md)

## Test Naming Convention

```kotlin
// Pattern: `given_when_then` or `should_when`
@Test
fun `loadData should update state with results when useCase succeeds`()

@Test
fun `should show error message when loading fails`()

@Test
fun `given empty list when render then show empty state`()
```

## Common Test Setup

### Dependencies (build.gradle.kts)

```kotlin
testImplementation("org.junit.jupiter:junit-jupiter:5.10.0")
testImplementation("io.mockk:mockk:1.13.8")
testImplementation("app.cash.turbine:turbine:1.0.0")
testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
testImplementation("androidx.compose.ui:ui-test-junit4")
debugImplementation("androidx.compose.ui:ui-test-manifest")
```

### Test Rule Setup

```kotlin
@ExtendWith(MockKExtension::class)
class ViewModelTest {

    @MockK
    private lateinit var useCase: SomeUseCase

    @MockK
    private lateinit var repository: SomeRepository

    private lateinit var viewModel: SomeViewModel

    @BeforeEach
    fun setup() {
        viewModel = SomeViewModel(useCase)
    }

    @AfterEach
    fun tearDown() {
        clearAllMocks()
    }
}
```

## Best Practices

### DO
- Test behavior, not implementation
- Use meaningful test names
- One assertion per test (when possible)
- Test edge cases and error scenarios
- Use Turbine for Flow testing

### DON'T
- Test private methods directly
- Mock everything (test real logic when possible)
- Write flaky tests
- Skip error case testing
- Use Thread.sleep() (use advanceUntilIdle)
