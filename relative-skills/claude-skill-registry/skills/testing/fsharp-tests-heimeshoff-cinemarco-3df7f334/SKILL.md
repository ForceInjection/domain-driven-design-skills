---
name: fsharp-tests
description: |
  Write comprehensive tests using Expecto for F# applications.
  Use when: "add tests", "write tests", "test X", "unit test", "testing", "verify",
  "Expecto", "test coverage", "TDD", "property test", "async test", "test case".
  Creates tests in src/Tests/ for domain logic, validation, persistence, and state.
  Focus on pure functions (domain) and validation rules for best coverage.
allowed-tools: Read, Edit, Write, Grep, Bash
---

# F# Testing with Expecto

## When to Use This Skill

Activate when:
- User requests "add tests for X", "test Y"
- Implementing any new feature (always write tests)
- Need to verify domain logic
- Testing validation rules
- Testing API contracts
- Testing state transitions (Elmish)

## Test Project Structure

```
src/Tests/
├── Shared.Tests/
│   ├── DomainTests.fs
│   ├── ValidationTests.fs
│   ├── Program.fs
│   └── Shared.Tests.fsproj
│
├── Server.Tests/
│   ├── DomainTests.fs
│   ├── ValidationTests.fs
│   ├── PersistenceTests.fs
│   ├── Program.fs
│   └── Server.Tests.fsproj
│
└── Client.Tests/
    ├── StateTests.fs
    ├── Program.fs
    └── Client.Tests.fsproj
```

## Project Setup

### Test Project File
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <IsPackable>false</IsPackable>
    <GenerateProgramFile>false</GenerateProgramFile>
  </PropertyGroup>

  <ItemGroup>
    <Compile Include="DomainTests.fs" />
    <Compile Include="ValidationTests.fs" />
    <Compile Include="Program.fs" />
  </ItemGroup>

  <ItemGroup>
    <PackageReference Include="Expecto" Version="10.2.1" />
    <PackageReference Include="Expecto.FsCheck" Version="10.2.1" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="../../Server/Server.fsproj" />
    <ProjectReference Include="../../Shared/Shared.fsproj" />
  </ItemGroup>
</Project>
```

### Program.fs
```fsharp
module Program

open Expecto

[<EntryPoint>]
let main args =
    runTestsInAssembly defaultConfig args
```

## Testing Domain Logic

```fsharp
module DomainTests

open Expecto
open Shared.Domain

[<Tests>]
let tests =
    testList "Domain Logic" [
        testCase "processNewTodo trims title" <| fun () ->
            let request = { Title = "  Test  "; Description = None; Priority = Low }
            let result = Domain.processNewTodo request
            Expect.equal result.Title "Test" "Should trim whitespace"

        testCase "completeTodo changes status" <| fun () ->
            let todo = { baseTodo with Status = Active }
            let result = Domain.completeTodo todo
            Expect.equal result.Status Completed "Should be completed"

        testCase "completeTodo updates timestamp" <| fun () ->
            let before = System.DateTime.UtcNow
            let todo = { baseTodo with UpdatedAt = before }
            let result = Domain.completeTodo todo
            Expect.isGreaterThan result.UpdatedAt before "Should update timestamp"

        testCase "calculateTotal sums correctly" <| fun () ->
            let items = [
                { Item = "A"; Price = 10.0m; Quantity = 2 }
                { Item = "B"; Price = 5.0m; Quantity = 3 }
            ]
            let total = Domain.calculateTotal items
            Expect.equal total 35.0m "Should sum correctly"
    ]
```

## Testing Validation

```fsharp
module ValidationTests

open Expecto
open Validation

[<Tests>]
let tests =
    testList "Validation" [
        testCase "Valid todo passes" <| fun () ->
            let todo = {
                Id = 1
                Title = "Valid Title"
                Description = Some "Description"
                Priority = Medium
                Status = Active
                CreatedAt = System.DateTime.UtcNow
                UpdatedAt = System.DateTime.UtcNow
            }
            let result = validateTodoItem todo
            Expect.isOk result "Should pass validation"

        testCase "Empty title fails" <| fun () ->
            let todo = { validTodo with Title = "" }
            let result = validateTodoItem todo
            Expect.isError result "Should fail validation"

        testCase "Title too long fails" <| fun () ->
            let todo = { validTodo with Title = String.replicate 101 "a" }
            let result = validateTodoItem todo
            Expect.isError result "Should fail validation"

        testCase "Multiple errors accumulated" <| fun () ->
            let todo = { validTodo with Title = ""; Id = -1 }
            match validateTodoItem todo with
            | Error errors ->
                Expect.isGreaterThan errors.Length 1 "Should have multiple errors"
                Expect.contains errors "Title is required" "Should mention title"
            | Ok _ ->
                failtest "Should have failed validation"
    ]
```

## Testing Result Types

```fsharp
[<Tests>]
let resultTests =
    testList "Result Handling" [
        testCase "Successful operation returns Ok" <| fun () ->
            let result = Operation.performAction validInput
            Expect.isOk result "Should succeed"

            match result with
            | Ok value ->
                Expect.equal value.Status Success "Should be successful"
            | Error _ ->
                failtest "Should not fail"

        testCase "Invalid input returns Error" <| fun () ->
            let result = Operation.performAction invalidInput
            Expect.isError result "Should fail"

            match result with
            | Error msg ->
                Expect.stringContains msg "invalid" "Should mention invalid input"
            | Ok _ ->
                failtest "Should not succeed"
    ]
```

## Testing Async Operations

```fsharp
[<Tests>]
let asyncTests =
    testList "Async Operations" [
        testCaseAsync "getAllTodos returns list" <| async {
            let! result = Persistence.getAllTodos()
            Expect.isNotNull result "Should return list"
        }

        testCaseAsync "getTodoById returns todo" <| async {
            let! result = Persistence.getTodoById 1
            match result with
            | Some todo ->
                Expect.equal todo.Id 1 "Should have correct ID"
            | None ->
                failtest "Should find todo"
        }

        testCaseAsync "getTodoById returns None for nonexistent" <| async {
            let! result = Persistence.getTodoById 99999
            Expect.isNone result "Should not find todo"
        }
    ]
```

## Testing State Transitions (Elmish)

```fsharp
module StateTests

open Expecto
open State
open Types

[<Tests>]
let tests =
    testList "State Management" [
        testCase "Init creates correct initial state" <| fun () ->
            let model, cmd = State.init()
            Expect.equal model.Todos NotAsked "Should start as NotAsked"
            Expect.equal model.NewTodoTitle "" "Should have empty title"

        testCase "LoadTodos sets Loading state" <| fun () ->
            let model = { initialModel with Todos = NotAsked }
            let newModel, _ = State.update LoadTodos model
            Expect.equal newModel.Todos Loading "Should set to Loading"

        testCase "TodosLoaded with Ok sets Success" <| fun () ->
            let model = { initialModel with Todos = Loading }
            let todos = [ todo1; todo2 ]
            let newModel, _ = State.update (TodosLoaded (Ok todos)) model

            match newModel.Todos with
            | Success loadedTodos ->
                Expect.equal loadedTodos todos "Should contain loaded todos"
            | _ ->
                failtest "Should be Success state"

        testCase "TodosLoaded with Error sets Failure" <| fun () ->
            let model = { initialModel with Todos = Loading }
            let newModel, _ = State.update (TodosLoaded (Error "Failed")) model

            match newModel.Todos with
            | Failure msg ->
                Expect.equal msg "Failed" "Should contain error message"
            | _ ->
                failtest "Should be Failure state"

        testCase "UpdateNewTodoTitle updates model" <| fun () ->
            let model = initialModel
            let newModel, _ = State.update (UpdateNewTodoTitle "New Title") model
            Expect.equal newModel.NewTodoTitle "New Title" "Should update title"
    ]
```

## Property-Based Testing

```fsharp
open FsCheck

[<Tests>]
let propertyTests =
    testList "Property Tests" [
        testProperty "Trimming is idempotent" <| fun (s: string) ->
            let trimmed = s.Trim()
            trimmed.Trim() = trimmed

        testProperty "Adding then removing returns original count" <| fun (items: int list) (newItem: int) ->
            let withItem = newItem :: items
            let afterRemoval = withItem |> List.filter (fun x -> x <> newItem)
            afterRemoval.Length <= items.Length + 1
    ]
```

## Test Fixtures

```fsharp
module TestData =
    let validTodo = {
        Id = 1
        Title = "Test Todo"
        Description = Some "Description"
        Priority = Medium
        Status = Active
        CreatedAt = System.DateTime(2024, 1, 1)
        UpdatedAt = System.DateTime(2024, 1, 1)
    }

    let createTodo id title =
        { validTodo with Id = id; Title = title }

    let testTodos = [
        createTodo 1 "First"
        createTodo 2 "Second"
        createTodo 3 "Third"
    ]

[<Tests>]
let tests =
    testList "Using Test Data" [
        testCase "Uses valid todo" <| fun () ->
            let result = Domain.processTodo TestData.validTodo
            Expect.isOk result "Should process valid todo"
    ]
```

## Running Tests

```bash
# Run all tests
dotnet test

# Run specific test project
dotnet test src/Tests/Server.Tests/

# Run with watch mode
dotnet test --watch

# Run with filter
dotnet test --filter "FullyQualifiedName~Validation"

# Verbose output
dotnet test --logger "console;verbosity=detailed"
```

## Best Practices

### ✅ Do
- Test domain logic thoroughly (it's pure)
- Test validation rules
- Use descriptive test names
- Test edge cases and error conditions
- Keep tests independent
- Use test fixtures for common data
- Test state transitions

### ❌ Don't
- Test implementation details
- Make tests dependent on order
- Skip testing error cases
- Make tests dependent on external services
- Write slow tests without async
- Forget boundary conditions

## Verification Checklist

- [ ] Test project created and configured
- [ ] Domain logic tests written
- [ ] Validation tests written
- [ ] Edge cases tested
- [ ] Error conditions tested
- [ ] Async operations tested
- [ ] State transitions tested (if frontend)
- [ ] All tests pass
- [ ] Tests are independent
- [ ] Descriptive test names

## Related Skills

- **fsharp-backend** - Testing backend logic
- **fsharp-frontend** - Testing state management
- **fsharp-validation** - Testing validation
- **fsharp-persistence** - Testing persistence

## Related Documentation

- `/docs/06-TESTING.md` - Detailed testing guide
