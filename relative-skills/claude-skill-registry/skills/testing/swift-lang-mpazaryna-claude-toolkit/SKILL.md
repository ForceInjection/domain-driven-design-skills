---
name: swift-lang
description: |
  Swift language mastery skill covering advanced language features beyond UI.
  Use when working with macros, concurrency (async/await, actors), networking,
  Swift Testing, generics, memory optimization, or result builders. Not for SwiftUI patterns - see swift-ui.
---

# swift-lang

Advanced Swift language features for building robust, performant code.

## Scope

This skill covers **Swift language internals** - the deep features that make you a better Swift developer. For SwiftUI implementation patterns, see `swift-ui`.

## Routing

Based on what you're building, load the appropriate reference:

### Macros
**When**: Creating compile-time code generation, reducing boilerplate, building DSLs
**References**:
- `references/macros/freestanding.md` - ExpressionMacro, DeclarationMacro
- `references/macros/attached.md` - PeerMacro, AccessorMacro, MemberMacro, ExtensionMacro, BodyMacro

**Macro Types Overview:**
| Type | Category | Purpose |
|------|----------|---------|
| ExpressionMacro | Freestanding | Return an expression (like a global function) |
| DeclarationMacro | Freestanding | Declare variables, structs, functions |
| PeerMacro | Attached | Add sibling declarations |
| AccessorMacro | Attached | Add get/set to properties |
| MemberMacro | Attached | Add members to types |
| MemberAttributeMacro | Attached | Add attributes to members |
| ExtensionMacro | Attached | Add protocol conformance |
| BodyMacro | Attached | Replace function body |

### Concurrency
**When**: async/await patterns, actor isolation, Sendable conformance, data race prevention
**References**:
- `references/concurrency/async-await.md` - Structured concurrency patterns
- `references/concurrency/actors.md` - Actor isolation, @MainActor
- `references/concurrency/sendable.md` - Sendable conformance, crossing isolation boundaries

### Testing
**When**: Writing tests with Swift Testing framework, test strategies
**References**:
- `references/testing/swift-testing.md` - @Test, #expect, traits, parameterized tests
- `references/testing/strategies.md` - What to test, dependency injection for testing

### Generics
**When**: Protocol design, associated types, existentials, type erasure
**References**:
- `references/generics/protocols.md` - Associated types, primary associated types
- `references/generics/existentials.md` - `any` vs `some`, type erasure patterns

### Optimization
**When**: Memory management, performance profiling, reducing allocations
**References**:
- `references/optimization/memory.md` - ARC, weak/unowned, copy-on-write
- `references/optimization/performance.md` - Instruments, allocation patterns

### Result Builders
**When**: Building custom DSLs, understanding @ViewBuilder internals
**References**:
- `references/result-builders/custom-dsl.md` - Building your own @resultBuilder

### Networking
**When**: Making HTTP requests, API clients, async data fetching
**References**:
- `references/networking/async-networking.md` - URLSession with async/await, API client patterns

**Key Patterns:**
- Async/await with URLSession
- Actor-based API clients
- Authentication and retry logic
- Concurrent requests with `async let`
- Error handling and cancellation

## Quick Reference

### Macro Package Setup

```swift
// Package.swift for macro development
// swift-tools-version: 5.9
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MyMacros",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "MyMacros", targets: ["MyMacros"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .macro(
            name: "MyMacrosMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(name: "MyMacros", dependencies: ["MyMacrosMacros"]),
    ]
)
```

### Concurrency Essentials

```swift
// Structured concurrency
func fetchData() async throws -> Data {
    try await withThrowingTaskGroup(of: Data.self) { group in
        // Add tasks to group
    }
}

// Actor isolation
@MainActor
class ViewModel: ObservableObject {
    @Published var items: [Item] = []
}

// Sendable conformance
struct Config: Sendable {
    let apiKey: String
}
```

### Swift Testing

```swift
import Testing

@Test("User authentication succeeds with valid credentials")
func validLogin() async throws {
    let auth = AuthService()
    let result = try await auth.login(user: "test", pass: "valid")
    #expect(result.isAuthenticated)
}

@Test(arguments: ["", "ab", "toolong123"])
func invalidUsername(_ username: String) {
    #expect(!Validator.isValidUsername(username))
}
```

## Anti-Patterns

- Force unwrapping in production code
- Ignoring actor isolation warnings
- Using `nonisolated(unsafe)` without understanding implications
- Massive macro implementations (split into helpers)
- Testing implementation details instead of behavior

## Related Skills

- **swift-ui** - SwiftUI view patterns and architecture
- **design-review** - App Store submission prep
