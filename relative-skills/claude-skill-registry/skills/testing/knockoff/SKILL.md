---
name: knockoff
description: KnockOff source-generated test stubs. Use when creating interface stubs for unit tests, migrating from Moq, understanding the duality pattern (user methods vs callbacks), configuring stub behavior, verifying invocations, or working with interface spy handlers for tracking calls.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(dotnet:*)
---

# KnockOff - Source-Generated Test Stubs

## Overview

KnockOff is a Roslyn Source Generator that creates test stubs for interfaces. Unlike Moq's runtime proxy generation, KnockOff generates compile-time code for type-safe, debuggable stubs.

### Key Differentiator: The Duality

KnockOff provides **two complementary patterns** for customizing stub behavior:

| Pattern | When | Scope | Use Case |
|---------|------|-------|----------|
| **User Methods** | Compile-time | All tests | Consistent defaults |
| **Callbacks** | Runtime | Per-test | Test-specific overrides |

<!-- snippet: skill:SKILL:duality-pattern -->
```csharp
// Pattern 1: User method (compile-time default)
[KnockOff]
public partial class SkServiceKnockOff : ISkService
{
    protected int GetValue(int id) => id * 2;  // Default for all tests
}

// Pattern 2: Callback (runtime override)
// knockOff.ISkService.GetValue.OnCall = (ko, id) => id * 100;  // Override for this test
```
<!-- /snippet -->

**Priority Order**: Callback → User method → Default

## Installation

```bash
dotnet add package KnockOff
```

## Quick Start

### 1. Create KnockOff Stub

<!-- snippet: skill:SKILL:quick-start-interface -->
```csharp
public interface ISkDataService
{
    string Name { get; set; }
    string? GetDescription(int id);
    int GetCount();
}
```
<!-- /snippet -->

<!-- snippet: skill:SKILL:quick-start-stub -->
```csharp
[KnockOff]
public partial class SkDataServiceKnockOff : ISkDataService
{
    private readonly int _count;

    public SkDataServiceKnockOff(int count = 42) => _count = count;

    // Define behavior for non-nullable method
    protected int GetCount() => _count;

    // GetDescription not defined - returns null by default
}
```
<!-- /snippet -->

### 2. Use in Tests

```csharp
[Fact]
public void Test_DataService()
{
    var knockOff = new DataServiceKnockOff(count: 100);
    IDataService service = knockOff;

    // Property - uses generated backing field
    service.Name = "Test";
    Assert.Equal("Test", service.Name);
    Assert.Equal(1, knockOff.IDataService.Name.SetCount);

    // Nullable method - returns null, call is still verified
    var description = service.GetDescription(5);
    Assert.Null(description);
    Assert.True(knockOff.IDataService.GetDescription.WasCalled);
    Assert.Equal(5, knockOff.IDataService.GetDescription.LastCallArg);

    // Non-nullable method - returns constructor value
    Assert.Equal(100, service.GetCount());
}
```

## Interface Spy Properties

Each interface gets its own spy property for tracking and configuration:

<!-- snippet: skill:SKILL:interface-spy-access -->
```csharp
[KnockOff]
public partial class SkSpyExampleKnockOff : ISkUserService, ISkPropertyStore, ISkEventSource { }

// Access patterns:
// knockOff.ISkUserService.GetUser       // Method handler
// knockOff.ISkPropertyStore.StringIndexer // Indexer handler
// knockOff.ISkEventSource.DataReceived  // Event handler
```
<!-- /snippet -->

### Multiple Interfaces

When implementing multiple interfaces, each has a separate spy:

<!-- snippet: skill:SKILL:multiple-interfaces -->
```csharp
[KnockOff]
public partial class SkDataContextKnockOff : ISkRepository, ISkUnitOfWork { }

// Access via interface spy properties:
// knockOff.ISkRepository.Save.WasCalled
// knockOff.ISkUnitOfWork.Commit.WasCalled

// Use AsXxx() for explicit casting:
// ISkRepository repo = knockOff.AsSkRepository();
// ISkUnitOfWork uow = knockOff.AsSkUnitOfWork();
```
<!-- /snippet -->

## OnCall API

**Callbacks use property assignment** with `OnCall =`:

<!-- snippet: skill:SKILL:oncall-patterns -->
```csharp
[KnockOff]
public partial class SkOnCallKnockOff : ISkOnCallService { }

// No parameters
// knockOff.ISkOnCallService.Clear.OnCall = (ko) => { };

// Single parameter
// knockOff.ISkOnCallService.GetById.OnCall = (ko, id) => new SkUser { Id = id };

// Multiple parameters - individual params, not tuples
// knockOff.ISkOnCallService.Find.OnCall = (ko, name, active) =>
//     users.Where(u => u.Name == name && u.Active == active).ToList();

// Void method
// knockOff.ISkOnCallService.Save.OnCall = (ko, entity) => { /* logic */ };
```
<!-- /snippet -->

**Out/Ref parameters** - use explicit delegate type:

<!-- snippet: skill:SKILL:oncall-out-ref -->
```csharp
[KnockOff]
public partial class SkParserKnockOff : ISkParser { }

// Out/Ref parameters - use explicit delegate type:
// knockOff.ISkParser.TryParse.OnCall =
//     (ISkParser_TryParseHandler.TryParseDelegate)((ko, string input, out int result) =>
//     {
//         return int.TryParse(input, out result);
//     });
```
<!-- /snippet -->

## Smart Default Return Values

KnockOff returns sensible defaults for unconfigured methods instead of throwing:

| Return Type | Default Value | Example |
|-------------|---------------|---------|
| Value types | `default` | `int` → `0`, `bool` → `false` |
| Nullable refs | `null` | `string?` → `null` |
| Types with `new()` | `new T()` | `List<T>` → empty list |
| Collection interfaces | concrete type | `IList<T>` → `new List<T>()` |
| Other non-nullable | throws | `string`, `IDisposable` |

<!-- snippet: skill:SKILL:smart-defaults -->
```csharp
[KnockOff]
public partial class SkSmartDefaultKnockOff : ISkSmartDefaultService { }

// var knockOff = new SkSmartDefaultKnockOff();
// ISkSmartDefaultService service = knockOff;

// No configuration needed:
// var count = service.GetCount();       // 0 (value type)
// var items = service.GetItems();       // new List<string>() (has new())
// var list = service.GetIList();        // new List<string>() (IList<T> -> List<T>)
// var optional = service.GetOptional(); // null (nullable ref)

// Only throws for types that can't be safely defaulted:
// service.GetDisposable();  // throws - can't instantiate IDisposable
```
<!-- /snippet -->

**Collection Interface Mapping:**

| Interface | Concrete Type |
|-----------|---------------|
| `IEnumerable<T>`, `ICollection<T>`, `IList<T>` | `List<T>` |
| `IReadOnlyList<T>`, `IReadOnlyCollection<T>` | `List<T>` |
| `IDictionary<K,V>`, `IReadOnlyDictionary<K,V>` | `Dictionary<K,V>` |
| `ISet<T>` | `HashSet<T>` |

## Stub Minimalism

**Only stub what the test needs.** Don't implement every interface member.

```csharp
// GOOD - minimal stub, most methods just work with smart defaults
[KnockOff]
public partial class UserServiceKnockOff : IUserService
{
    // Only define methods needing custom behavior
    protected User GetUser(int id) => new User { Id = id };
    // GetCount returns 0, GetUsers() returns new List<User>(), etc.
}
```

## Handler Types

| Member Type | Tracking | Callbacks |
|-------------|----------|-----------|
| Method | `CallCount`, `WasCalled`, `LastCallArg(s)`, `AllCalls` | `OnCall` |
| Property | `GetCount`, `SetCount`, `LastSetValue` | `OnGet`, `OnSet` |
| Indexer | `GetCount`, `SetCount`, `LastGetKey`, `AllGetKeys`, `LastSetEntry`, `AllSetEntries` | `OnGet`, `OnSet` |
| Event | `SubscribeCount`, `UnsubscribeCount`, `RaiseCount`, `WasRaised`, `LastRaiseArgs`, `AllRaises` | `Raise()`, `Reset()`, `Clear()` |

### Reset

```csharp
knockOff.IService.GetUser.Reset();  // Clears tracking AND callbacks
// After reset: CallCount=0, OnCall=null
// Falls back to user method or default
```

## Customization Patterns

### User Methods (Compile-Time)

Define protected methods matching interface signatures:

<!-- snippet: skill:SKILL:customization-user-method -->
```csharp
[KnockOff]
public partial class SkRepoKnockOff : ISkRepoService
{
    protected SkUser? GetById(int id) => new SkUser { Id = id };
    protected Task<SkUser?> GetByIdAsync(int id) => Task.FromResult<SkUser?>(new SkUser { Id = id });
}
```
<!-- /snippet -->

Rules:
- Must be `protected`
- Must match method signature exactly
- Only works for methods (not properties/indexers)

### Callbacks (Runtime)

#### Method Callbacks

<!-- snippet: skill:SKILL:customization-callbacks-method -->
```csharp
[KnockOff]
public partial class SkCallbackMethodKnockOff : ISkCallbackService { }

// Void method
// knockOff.ISkCallbackService.DoWork.OnCall = (ko) => { /* custom logic */ };

// Return method (single param)
// knockOff.ISkCallbackService.GetById.OnCall = (ko, id) =>
//     new SkUser { Id = id, Name = "Mocked" };

// Return method (multiple params) - individual parameters
// knockOff.ISkCallbackService.Search.OnCall = (ko, query, limit, offset) =>
//     results.Skip(offset).Take(limit).ToList();
```
<!-- /snippet -->

#### Property Callbacks

<!-- snippet: skill:SKILL:customization-callbacks-property -->
```csharp
// knockOff.ISkCallbackService.CurrentUser.OnGet = (ko) =>
//     new SkUser { Name = "TestUser" };

// knockOff.ISkCallbackService.CurrentUser.OnSet = (ko, value) =>
// {
//     capturedUser = value;
//     // Note: Value does NOT go to backing field
// };
```
<!-- /snippet -->

#### Indexer Callbacks

<!-- snippet: skill:SKILL:customization-callbacks-indexer -->
```csharp
[KnockOff]
public partial class SkCallbackIndexerKnockOff : ISkCallbackPropertyStore { }

// knockOff.ISkCallbackPropertyStore.StringIndexer.OnGet = (ko, key) => key switch
// {
//     "admin" => adminConfig,
//     "guest" => guestConfig,
//     _ => null
// };

// knockOff.ISkCallbackPropertyStore.StringIndexer.OnSet = (ko, key, value) =>
// {
//     // Custom logic
//     // Note: Value does NOT go to backing dictionary
// };
```
<!-- /snippet -->

### Priority Order

```
1. Callback (if set) → takes precedence
2. User method (if defined) → fallback for methods
3. Smart default:
   - Properties: backing field (initialized via smart defaults)
   - Methods: smart default (value types→default, new()→new T(), etc.)
   - Indexers: backing dictionary, then smart default
   - Void methods: execute silently
```

## Verification Patterns

### Call Tracking

<!-- snippet: skill:SKILL:verification-call-tracking -->
```csharp
[KnockOff]
public partial class SkVerificationKnockOff : ISkVerificationService { }

// Basic
// Assert.True(knockOff.ISkVerificationService.GetUser.WasCalled);
// Assert.Equal(3, knockOff.ISkVerificationService.GetUser.CallCount);

// Arguments (single param)
// Assert.Equal(42, knockOff.ISkVerificationService.GetUser.LastCallArg);
// Assert.Equal([1, 2, 42], knockOff.ISkVerificationService.GetUser.AllCalls);

// Arguments (multiple params - named tuple)
// var args = knockOff.ISkVerificationService.Create.LastCallArgs;
// Assert.Equal("Test", args?.name);
// Assert.Equal(100, args?.value);

// Destructuring
// if (knockOff.ISkVerificationService.Create.LastCallArgs is var (name, value))
// {
//     Assert.Equal("Test", name);
// }
```
<!-- /snippet -->

### Property Tracking

<!-- snippet: skill:SKILL:verification-property-tracking -->
```csharp
// Assert.Equal(2, knockOff.ISkVerificationService.Name.GetCount);
// Assert.Equal(3, knockOff.ISkVerificationService.Name.SetCount);
// Assert.Equal("LastValue", knockOff.ISkVerificationService.Name.LastSetValue);
```
<!-- /snippet -->

### Indexer Tracking

<!-- snippet: skill:SKILL:verification-indexer-tracking -->
```csharp
[KnockOff]
public partial class SkVerificationIndexerKnockOff : ISkVerificationPropertyStore { }

// Assert.Equal("key1", knockOff.ISkVerificationPropertyStore.StringIndexer.LastGetKey);
// Assert.Equal(["key1", "key2"], knockOff.ISkVerificationPropertyStore.StringIndexer.AllGetKeys);

// var setEntry = knockOff.ISkVerificationPropertyStore.StringIndexer.LastSetEntry;
// Assert.Equal("key", setEntry?.key);
// Assert.Equal(value, setEntry?.value);
```
<!-- /snippet -->

## Backing Storage

### Properties

<!-- snippet: skill:SKILL:backing-properties -->
```csharp
[KnockOff]
public partial class SkBackingServiceKnockOff : ISkBackingService { }

// Direct access to backing field (interface-prefixed)
// knockOff.ISkBackingService_NameBacking = "Pre-populated value";

// Without OnGet, getter returns backing field
// Assert.Equal("Pre-populated value", service.Name);
```
<!-- /snippet -->

### Indexers

<!-- snippet: skill:SKILL:backing-indexers -->
```csharp
[KnockOff]
public partial class SkBackingPropertyStoreKnockOff : ISkBackingPropertyStore { }

// Pre-populate backing dictionary (interface-prefixed)
// knockOff.ISkBackingPropertyStore_StringIndexerBacking["key1"] = value1;
// knockOff.ISkBackingPropertyStore_StringIndexerBacking["key2"] = value2;

// Without OnGet, getter checks backing dictionary
// Assert.Equal(value1, store["key1"]);
```
<!-- /snippet -->

**Important**: `Reset()` does NOT clear backing storage.

## Supported Features

| Feature | Status |
|---------|--------|
| Properties (get/set, get-only, set-only) | Supported |
| Void methods | Supported |
| Methods with return values | Supported |
| Methods with parameters | Supported |
| Method overloads (separate handlers) | Supported |
| Out parameters | Supported |
| Ref parameters | Supported |
| Async methods (Task, Task<T>, ValueTask, ValueTask<T>) | Supported |
| Generic interfaces (concrete types) | Supported |
| Generic methods (via `.Of<T>()` pattern) | Supported |
| Multiple interfaces | Supported |
| Interface inheritance | Supported |
| Indexers | Supported |
| Events | Supported |
| Nested classes | Supported |
| User method detection | Supported |
| OnCall/OnGet/OnSet callbacks | Supported |
| Named tuple argument tracking | Supported |

## Common Patterns

### Conditional Returns

<!-- snippet: skill:SKILL:pattern-conditional -->
```csharp
[KnockOff]
public partial class SkPatternServiceKnockOff : ISkPatternService { }

// knockOff.ISkPatternService.GetUser.OnCall = (ko, id) => id switch
// {
//     1 => new SkUser { Name = "Admin" },
//     2 => new SkUser { Name = "Guest" },
//     _ => null
// };
```
<!-- /snippet -->

### Throwing Exceptions

<!-- snippet: skill:SKILL:pattern-exceptions -->
```csharp
// knockOff.ISkPatternService.Connect.OnCall = (ko) =>
//     throw new TimeoutException("Connection failed");

// knockOff.ISkPatternService.SaveAsync.OnCall = (ko, entity) =>
//     Task.FromException<int>(new DbException("Save failed"));
```
<!-- /snippet -->

### Sequential Returns

<!-- snippet: skill:SKILL:pattern-sequential -->
```csharp
// var results = new Queue<int>([1, 2, 3]);
// knockOff.ISkPatternService.GetNext.OnCall = (ko) => results.Dequeue();
```
<!-- /snippet -->

### Async Methods

<!-- snippet: skill:SKILL:pattern-async -->
```csharp
[KnockOff]
public partial class SkAsyncPatternRepositoryKnockOff : ISkAsyncPatternRepository { }

// knockOff.ISkAsyncPatternRepository.GetUserAsync.OnCall = (ko, id) =>
//     Task.FromResult<SkUser?>(new SkUser { Id = id });

// knockOff.ISkAsyncPatternRepository.SaveAsync.OnCall = (ko, entity) =>
//     Task.FromResult(1);
```
<!-- /snippet -->

### Events

<!-- snippet: skill:SKILL:pattern-events -->
```csharp
[KnockOff]
public partial class SkEventPatternSourceKnockOff : ISkEventPatternSource { }

// var knockOff = new SkEventPatternSourceKnockOff();
// ISkEventPatternSource source = knockOff;

// Subscribe tracking
// source.DataReceived += (s, e) => Console.WriteLine(e);
// Assert.Equal(1, knockOff.ISkEventPatternSource.DataReceived.SubscribeCount);
// Assert.True(knockOff.ISkEventPatternSource.DataReceived.HasSubscribers);

// Raise events from tests
// knockOff.ISkEventPatternSource.DataReceived.Raise("test data");
// Assert.True(knockOff.ISkEventPatternSource.DataReceived.WasRaised);
// Assert.Equal(1, knockOff.ISkEventPatternSource.DataReceived.RaiseCount);

// Action-style events
// knockOff.ISkEventPatternSource.ProgressChanged.Raise(75);

// Reset vs Clear
// knockOff.ISkEventPatternSource.DataReceived.Reset();  // Clears tracking, keeps handlers
// knockOff.ISkEventPatternSource.DataReceived.Clear();  // Clears tracking AND handlers
```
<!-- /snippet -->

### Generic Methods

Generic methods use the `.Of<T>()` pattern for type-specific configuration:

<!-- snippet: skill:SKILL:pattern-generics -->
```csharp
[KnockOff]
public partial class SkGenericSerializerKnockOff : ISkGenericSerializer { }

// var knockOff = new SkGenericSerializerKnockOff();
// ISkGenericSerializer service = knockOff;

// Configure behavior per type argument
// knockOff.ISkGenericSerializer.Deserialize.Of<SkUser>().OnCall = (ko, json) =>
//     JsonSerializer.Deserialize<SkUser>(json)!;

// knockOff.ISkGenericSerializer.Deserialize.Of<SkOrder>().OnCall = (ko, json) =>
//     new SkOrder { Id = 123 };

// Per-type call tracking
// service.Deserialize<SkUser>("{...}");
// service.Deserialize<SkUser>("{...}");
// service.Deserialize<SkOrder>("{...}");

// Assert.Equal(2, knockOff.ISkGenericSerializer.Deserialize.Of<SkUser>().CallCount);
// Assert.Equal(1, knockOff.ISkGenericSerializer.Deserialize.Of<SkOrder>().CallCount);

// Aggregate tracking across all type arguments
// Assert.Equal(3, knockOff.ISkGenericSerializer.Deserialize.TotalCallCount);
// Assert.True(knockOff.ISkGenericSerializer.Deserialize.WasCalled);

// See which types were called
// var types = knockOff.ISkGenericSerializer.Deserialize.CalledTypeArguments;
// // [typeof(SkUser), typeof(SkOrder)]

// Multiple type parameters
// knockOff.ISkGenericSerializer.Convert.Of<string, int>().OnCall = (ko, s) => s.Length;
```
<!-- /snippet -->

### Method Overloads

When an interface has overloaded methods, each overload gets its own handler with a **numeric suffix** (1-based):

<!-- snippet: skill:SKILL:pattern-overloads -->
```csharp
[KnockOff]
public partial class SkOverloadedServiceKnockOff : ISkOverloadedService { }

// var knockOff = new SkOverloadedServiceKnockOff();
// ISkOverloadedService service = knockOff;

// Each overload has its own handler (1-based numbering)
// knockOff.ISkOverloadedService.Process1.CallCount;  // Calls to Process(string)
// knockOff.ISkOverloadedService.Process2.CallCount;  // Calls to Process(string, int)
// knockOff.ISkOverloadedService.Process3.CallCount;  // Calls to Process(string, int, bool)

// Set callbacks for each overload
// knockOff.ISkOverloadedService.Process1.OnCall = (ko, data) => { /* 1-param */ };
// knockOff.ISkOverloadedService.Process2.OnCall = (ko, data, priority) => { /* 2-param */ };
// knockOff.ISkOverloadedService.Process3.OnCall = (ko, data, priority, async) => { /* 3-param */ };
```
<!-- /snippet -->

Methods without overloads don't get a suffix:
```csharp
knockOff.IEmailService.SendEmail.CallCount;  // Single method - no suffix
```

### Nested Classes

KnockOff stubs can be nested inside test classes:

<!-- snippet: skill:SKILL:pattern-nested -->
```csharp
public partial class SkUserServiceTests  // Must be partial!
{
    [KnockOff]
    public partial class SkRepoNestedKnockOff : ISkRepository { }

    // In test method:
    // var knockOff = new SkRepoNestedKnockOff();
    // ...
}
```
<!-- /snippet -->

**Critical:** All containing classes must be `partial`. This is a C# requirement—the generator produces partial class wrappers that must merge with your declarations.

```csharp
// ❌ Won't compile
public class MyTests
{
    [KnockOff]
    public partial class ServiceKnockOff : IService { }
}

// ✅ Correct
public partial class MyTests
{
    [KnockOff]
    public partial class ServiceKnockOff : IService { }
}
```

Works at any nesting depth—just ensure every class in the hierarchy is `partial`.

### Out Parameters

Methods with `out` parameters are fully supported. Out parameters are outputs, not inputs, so they're excluded from tracking but included in callbacks.

<!-- snippet: skill:SKILL:pattern-out-params -->
```csharp
[KnockOff]
public partial class SkOutParamParserKnockOff : ISkOutParamParser { }

// var knockOff = new SkOutParamParserKnockOff();
// ISkOutParamParser parser = knockOff;

// Callback requires explicit delegate type for out/ref
// knockOff.ISkOutParamParser.TryParse.OnCall =
//     (ISkOutParamParser_TryParseHandler.TryParseDelegate)((ko, string input, out int result) =>
//     {
//         if (int.TryParse(input, out result))
//             return true;
//         result = 0;
//         return false;
//     });

// Call the method
// var success = parser.TryParse("42", out var value);
// Assert.True(success);
// Assert.Equal(42, value);

// Tracking only includes INPUT params (not out params)
// Assert.Equal("42", knockOff.ISkOutParamParser.TryParse.LastCallArg);
// Assert.Equal(1, knockOff.ISkOutParamParser.TryParse.CallCount);
```
<!-- /snippet -->

### Ref Parameters

Methods with `ref` parameters track the **input value** (before any callback modification).

<!-- snippet: skill:SKILL:pattern-ref-params -->
```csharp
[KnockOff]
public partial class SkRefProcessorKnockOff : ISkRefProcessor { }

// var knockOff = new SkRefProcessorKnockOff();
// ISkRefProcessor processor = knockOff;

// Callback can modify ref params - explicit delegate type required
// knockOff.ISkRefProcessor.Increment.OnCall =
//     (ISkRefProcessor_IncrementHandler.IncrementDelegate)((ko, ref int value) =>
//     {
//         value = value * 2;  // Double it
//     });

// int x = 5;
// processor.Increment(ref x);
// Assert.Equal(10, x);  // Modified by callback

// Tracking captures INPUT value (before modification)
// Assert.Equal(5, knockOff.ISkRefProcessor.Increment.LastCallArg);
```
<!-- /snippet -->

## Moq Migration Quick Reference

| Moq | KnockOff |
|-----|----------|
| `new Mock<IService>()` | `new ServiceKnockOff()` |
| `mock.Object` | Cast or `knockOff.AsService()` |
| `.Setup(x => x.Method())` | `IService.Method.OnCall = (ko, ...) => ...` |
| `.Returns(value)` | `OnCall = (ko) => value` |
| `.ReturnsAsync(value)` | `OnCall = (ko) => Task.FromResult(value)` |
| `.Callback(action)` | Logic inside `OnCall` callback |
| `.Verify(Times.Once)` | `Assert.Equal(1, IService.Method.CallCount)` |
| `It.IsAny<T>()` | Implicit (callback receives all args) |
| `It.Is<T>(pred)` | Check in callback body |

## Additional Resources

For detailed guidance, see:
- [Customization Patterns](customization-patterns.md) - Deep dive on user methods vs callbacks
- [Handler API Reference](handler-api.md) - Complete API for all handler types
- [Moq Migration](moq-migration.md) - Step-by-step migration patterns

## Skill Sync Status

All code examples in this skill are sourced from compiled, tested samples in the KnockOff repository.

| Repository | Samples Location | Sync Script |
|------------|------------------|-------------|
| [KnockOff](https://github.com/yourusername/KnockOff) | `src/Tests/KnockOff.Documentation.Samples/Skills/` | `scripts/extract-snippets.ps1` |

To update skill files after modifying samples:
```powershell
.\scripts\extract-snippets.ps1 -Update
```
