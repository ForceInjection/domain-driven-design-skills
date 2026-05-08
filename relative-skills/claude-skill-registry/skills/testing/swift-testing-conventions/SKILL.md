---
name: swift-testing-conventions
description: Testing conventions for Swift/SwiftUI projects using Clean Architecture. Covers Swift Testing framework for unit/integration tests, XCUITest for UI and E2E tests, manual protocol-based mocking, async testing patterns, and test organization. Use when writing tests, reviewing test code, setting up test infrastructure, or discussing testing strategy in Swift projects.
---

# Swift Testing Conventions

Testing conventions for Swift/SwiftUI projects with Clean Architecture (domain + app layers).

## Testing Pyramid

```
        ┌─────────┐
        │   E2E   │  ← {app}E2ETests (XCUITest) - Full user flows
       ┌┴─────────┴┐
       │    UI     │  ← {app}UITests (XCUITest) - Component interactions
      ┌┴───────────┴┐
      │ Integration │  ← Swift Testing - UseCases + real adapters, ViewModels + repos
     ┌┴─────────────┴┐
     │     Unit      │  ← Swift Testing - Entities, UseCases, ViewModels in isolation
     └───────────────┘
```

**Distribution target**: Unit > Integration > UI > E2E

## FIRST Principles

| Principle | Description |
|-----------|-------------|
| **Fast** | Unit tests < 100ms, Integration < 500ms |
| **Independent** | No shared state, any order execution |
| **Repeatable** | Same result every run, no external dependencies |
| **Self-validating** | Pass/fail without manual inspection |
| **Timely** | Written with or before production code |

## File Organization

```
root/
├── domain/
├── domainTests/                     # Swift Testing target
│   ├── {BoundedContext}/
│   │   ├── Entities/                # Entity tests
│   │   ├── UseCases/                # UseCase tests
│   │   └── Stubs/                   # Context-specific stubs
│   └── TestUtils/
│       ├── Builders/                # Entity builders
│       └── Stubs/                   # Shared stubs
├── {app}/
├── {app}Tests/                      # Swift Testing target
│   ├── ViewModels/
│   └── TestUtils/
│       ├── Builders/
│       └── Stubs/
├── {app}UITests/                    # XCUITest target - Component tests
│   ├── Components/
│   ├── Pages/                       # Page Objects
│   └── Helpers/
└── {app}E2ETests/                   # XCUITest target - Flow tests
    ├── Flows/
    ├── Pages/
    └── Helpers/
```

### Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Test file | `{ClassName}Tests.swift` | `SessionViewModelTests.swift` |
| Stub | `{Protocol}Stub.swift` | `SessionRepositoryStub.swift` |
| Builder | `{Entity}Builder.swift` | `SessionBuilder.swift` |
| Page Object | `{Screen}Page.swift` | `HomePage.swift` |

## Test Anatomy (Swift Testing)

### Structure

```swift
import Testing
@testable import Domain

@Suite("SessionUseCase")
struct SessionUseCaseTests {
    
    // MARK: - Dependencies (recreated per test)
    var repository: SessionRepositoryStub
    var monitor: MonitorStub
    var sut: GetSessionUseCase
    
    init() {
        repository = SessionRepositoryStub()
        monitor = MonitorStub()
        sut = GetSessionUseCase(repository: repository, monitor: monitor)
    }
    
    @Test("should return session when repository has active session")
    func shouldReturnSession_whenRepositoryHasActiveSession() async {
        // Given
        let expected = SessionBuilder().withStatus(.active).build()
        repository.getSessionResult = .success(expected)
        
        // When
        let result = await sut.execute()
        
        // Then
        #expect(result == .success(expected))
    }
    
    @Test("should return nil when repository is empty")
    func shouldReturnNil_whenRepositoryIsEmpty() async {
        // Given
        repository.getSessionResult = .success(nil)
        
        // When
        let result = await sut.execute()
        
        // Then
        #expect(try result.get() == nil)
    }
}
```

### Naming Convention

Pattern: `shouldExpectedBehavior_whenCondition()`

```swift
// ✅ Good
func shouldReturnError_whenNetworkFails() async
func shouldUpdateState_whenUserTapsStart()
func shouldCallRepository_whenExecuted() async

// ❌ Bad
func testGetSession()           // No behavior described
func test_session_returns()     // Unclear condition
func itWorks()                  // Meaningless
```

### Assertions

```swift
// Basic
#expect(value == expected)
#expect(value != nil)
#expect(array.isEmpty)

// Optionals
#expect(optional == nil)
let unwrapped = try #require(optional)  // Fails test if nil

// Errors
#expect(throws: ValidationError.self) {
    try sut.validate(invalidInput)
}

// Boolean
#expect(user.isActive)
#expect(!session.isExpired)
```

## Test Doubles

### Types by Layer

| Layer | Test Double | Purpose |
|-------|-------------|---------|
| Domain (Entities, UseCases) | **Stub** | Return predefined data |
| UI (ViewModels) | **Stub** | Return predefined data |
| Infrastructure (Adapters) | **Spy/Mock** | Verify interactions |

### Protocol Stub Pattern

```swift
// Port (in production code)
protocol SessionRepositoryProtocol {
    func getSession() async -> Result<Session?, RepositoryError>
    func saveSession(_ session: Session) async -> Result<Void, RepositoryError>
}

// Stub (in test code)
final class SessionRepositoryStub: SessionRepositoryProtocol {
    // Configurable results
    var getSessionResult: Result<Session?, RepositoryError> = .success(nil)
    var saveSessionResult: Result<Void, RepositoryError> = .success(())
    
    // Call tracking (Spy capability)
    private(set) var saveSessionCalls: [Session] = []
    
    func getSession() async -> Result<Session?, RepositoryError> {
        getSessionResult
    }
    
    func saveSession(_ session: Session) async -> Result<Void, RepositoryError> {
        saveSessionCalls.append(session)
        return saveSessionResult
    }
}
```

### When to Use Each

```swift
// Stub: Testing output based on input
@Test func shouldDisplayError_whenRepositoryFails() async {
    repository.getSessionResult = .failure(.notFound)  // Stub behavior
    
    await sut.loadSession()
    
    #expect(sut.errorMessage != nil)
}

// Spy: Verifying side effects
@Test func shouldSaveSession_whenUserTapsConfirm() async {
    await sut.confirmSession()
    
    #expect(repository.saveSessionCalls.count == 1)  // Spy verification
    #expect(repository.saveSessionCalls.first?.status == .confirmed)
}
```

## Builder Pattern

```swift
final class SessionBuilder {
    private var id: UUID = UUID()
    private var status: SessionStatus = .idle
    private var startDate: Date = Date()
    private var duration: TimeInterval = 3600
    
    func withId(_ id: UUID) -> Self {
        self.id = id
        return self
    }
    
    func withStatus(_ status: SessionStatus) -> Self {
        self.status = status
        return self
    }
    
    func withStartDate(_ date: Date) -> Self {
        self.startDate = date
        return self
    }
    
    func withDuration(_ duration: TimeInterval) -> Self {
        self.duration = duration
        return self
    }
    
    func build() -> Session {
        Session(
            id: id,
            status: status,
            startDate: startDate,
            duration: duration
        )
    }
}

// Usage
let session = SessionBuilder()
    .withStatus(.active)
    .withDuration(1800)
    .build()
```

## Test Isolation

### Swift Testing (struct-based)

Each test gets fresh instances via `init()`:

```swift
@Suite struct ViewModelTests {
    var repository: SessionRepositoryStub
    var sut: SessionViewModel
    
    init() {
        // Fresh instances for each test
        repository = SessionRepositoryStub()
        sut = SessionViewModel(repository: repository)
    }
}
```

### MainActor Isolation

For ViewModels with `@MainActor`:

```swift
@Suite("SessionViewModel")
@MainActor
struct SessionViewModelTests {
    var sut: SessionViewModel
    var repository: SessionRepositoryStub
    
    init() {
        repository = SessionRepositoryStub()
        sut = SessionViewModel(repository: repository)
    }
    
    @Test func shouldUpdateState_whenLoaded() async {
        repository.getSessionResult = .success(SessionBuilder().build())
        
        await sut.load()
        
        #expect(sut.state == .loaded)
    }
}
```

### Test DIContainer

For integration tests requiring DI:

```swift
final class TestDIContainer {
    static func configured(
        sessionRepository: SessionRepositoryProtocol = SessionRepositoryStub(),
        monitor: MonitorProtocol = MonitorStub()
    ) -> DIContainer {
        let container = DIContainer()
        container.register(SessionRepositoryProtocol.self, implementation: sessionRepository)
        container.register(MonitorProtocol.self, implementation: monitor)
        return container
    }
}
```

## Async Testing

### Basic Async

```swift
@Test func shouldFetchData_whenCalled() async {
    let result = await sut.fetchData()
    #expect(result.isSuccess)
}
```

### Async with Throws

```swift
@Test func shouldThrow_whenInvalidInput() async throws {
    await #expect(throws: ValidationError.self) {
        try await sut.process(invalidInput)
    }
}
```

### Testing Published Properties

```swift
@Test func shouldUpdatePublishedState() async {
    // Given
    repository.getSessionResult = .success(SessionBuilder().build())
    
    // When
    await sut.load()
    
    // Then - MainActor ensures @Published updates are visible
    #expect(sut.session != nil)
}
```

### Confirmation (for callbacks/delegates)

```swift
@Test func shouldNotifyDelegate_whenComplete() async {
    await confirmation { confirm in
        sut.onComplete = { confirm() }
        await sut.execute()
    }
}

// With timeout
@Test func shouldComplete_withinTimeout() async {
    await confirmation(timeout: .seconds(2)) { confirm in
        sut.onComplete = { confirm() }
        await sut.start()
    }
}
```

## XCUITest Patterns

### Page Object Pattern

```swift
// Pages/HomePage.swift
struct HomePage {
    let app: XCUIApplication
    
    // MARK: - Elements
    var startButton: XCUIElement {
        app.buttons["start-session-button"]
    }
    
    var sessionStatus: XCUIElement {
        app.staticTexts["session-status-label"]
    }
    
    var settingsButton: XCUIElement {
        app.buttons["settings-button"]
    }
    
    // MARK: - Actions
    @discardableResult
    func tapStart() -> SessionPage {
        startButton.tap()
        return SessionPage(app: app)
    }
    
    func tapSettings() -> SettingsPage {
        settingsButton.tap()
        return SettingsPage(app: app)
    }
    
    // MARK: - Assertions
    func assertSessionStatus(_ expected: String) -> Self {
        XCTAssertEqual(sessionStatus.label, expected)
        return self
    }
}
```

### Accessibility Identifiers

In production code:

```swift
Button("Start Session") {
    viewModel.startSession()
}
.accessibilityIdentifier("start-session-button")

Text(viewModel.statusText)
    .accessibilityIdentifier("session-status-label")
```

### UI Test Structure

```swift
// {app}UITests/Components/StartButtonTests.swift
final class StartButtonTests: XCTestCase {
    var app: XCUIApplication!
    var homePage: HomePage!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        homePage = HomePage(app: app)
    }
    
    func test_startButton_shouldBeVisible_whenAppLaunches() {
        XCTAssertTrue(homePage.startButton.exists)
        XCTAssertTrue(homePage.startButton.isEnabled)
    }
    
    func test_startButton_shouldNavigateToSession_whenTapped() {
        let sessionPage = homePage.tapStart()
        XCTAssertTrue(sessionPage.timerLabel.waitForExistence(timeout: 2))
    }
}
```

### E2E Test Structure

```swift
// {app}E2ETests/Flows/SessionFlowTests.swift
final class SessionFlowTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--e2e-testing", "--reset-state"]
        app.launch()
    }
    
    func test_completeSessionFlow_shouldShowSummary() {
        HomePage(app: app)
            .tapStart()
            .waitForTimerToStart()
            .tapPause()
            .tapStop()
            .assertSummaryVisible()
    }
}
```

### Launch Arguments for Test Modes

```swift
// In App
@main
struct MyApp: App {
    init() {
        #if DEBUG
        if CommandLine.arguments.contains("--ui-testing") {
            configureForUITesting()
        }
        if CommandLine.arguments.contains("--reset-state") {
            resetAllState()
        }
        #endif
    }
}
```

## Anti-Patterns

### ❌ Testing Implementation Details

```swift
// ❌ Bad: Tests internal state
@Test func shouldSetInternalFlag() async {
    await sut.load()
    #expect(sut.internalLoadingFlag == true)  // Implementation detail
}

// ✅ Good: Tests observable behavior
@Test func shouldShowLoading_whenFetching() async {
    let task = Task { await sut.load() }
    #expect(sut.isLoading == true)
    await task.value
}
```

### ❌ Over-Mocking

```swift
// ❌ Bad: Mocking everything
@Test func shouldWork() async {
    let mockA = MockA()
    let mockB = MockB()
    let mockC = MockC()
    let mockD = MockD()
    // 10 more mocks...
}

// ✅ Good: Only mock boundaries
@Test func shouldWork() async {
    let repository = SessionRepositoryStub()  // External boundary only
    let sut = GetSessionUseCase(repository: repository)
}
```

### ❌ Flaky Tests

```swift
// ❌ Bad: Race condition
@Test func shouldUpdate() async {
    sut.startAsync()
    #expect(sut.value == expected)  // May not be updated yet
}

// ✅ Good: Await completion
@Test func shouldUpdate() async {
    await sut.startAsync()
    #expect(sut.value == expected)
}
```

### ❌ Test Interdependence

```swift
// ❌ Bad: Shared mutable state
static var sharedSession: Session?

@Test func test1() { Self.sharedSession = SessionBuilder().build() }
@Test func test2() { #expect(Self.sharedSession != nil) }  // Depends on test1

// ✅ Good: Independent setup
@Test func test1() {
    let session = SessionBuilder().build()
    // use session
}
```

### ❌ Magic Values

```swift
// ❌ Bad: Unexplained values
#expect(result.count == 3)

// ✅ Good: Explicit setup
let items = [item1, item2, item3]
repository.itemsResult = .success(items)
let result = await sut.getItems()
#expect(result.count == items.count)
```

## Workflows

For step-by-step procedures, see [references/workflows.md](references/workflows.md):
- **Write Tests Workflow** — Identify test type → Follow type-specific steps → Verify quality
- **Refactor Test Workflow** — Identify problem → Diagnose root cause → Apply fix → Verify

## References

For templates and utilities, see [references/test-utils.md](references/test-utils.md):
- Protocol Stub template
- Builder template  
- TestDIContainer
- XCUITest helpers
- Common assertions
