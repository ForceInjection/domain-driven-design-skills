---
name: xunit-mtp
description: use this skill when creating new or reviewing xunit v3 test projects using Microsoft Testing Platform (MTP) to ensure best patterns, practices, and proper configuration
---

# xUnit v3 with Microsoft Testing Platform (MTP) - Best Practices

this skill provides guidance for creating and reviewing xunit v3 test projects that use Microsoft Testing Platform (MTP) for modern, performant test execution.

## when to use this skill

- creating new xunit v3 test projects
- reviewing existing xunit test projects for MTP compatibility
- migrating from xunit v2 or VSTest to xunit v3 with MTP
- troubleshooting xunit v3 MTP project configurations

## project setup requirements

### minimum version requirements

- **.NET 8 SDK** later
- **xunit.v3** (3.1.0+)
- **Microsoft.Testing.Platform** (2.0.0+) for best `dotnet test` integration

### essential MSBuild properties

all xunit v3 MTP projects must include:

```xml
<PropertyGroup>
  <!-- required: makes the test project executable -->
  <OutputType>Exe</OutputType>

  <!-- required: enables MTP for command-line execution -->
  <UseMicrosoftTestingPlatformRunner>true</UseMicrosoftTestingPlatformRunner>

  <!-- recommended: enables `dotnet test` support -->
  <TestingPlatformDotnetTestSupport>true</TestingPlatformDotnetTestSupport>

  <!-- recommended: shows test failures per test (has performance impact) -->
  <TestingPlatformShowTestsFailure>true</TestingPlatformShowTestsFailure>

  <!-- standard test project flags -->
  <IsPackable>false</IsPackable>
  <IsTestProject>true</IsTestProject>
</PropertyGroup>
```

### recommended package references

#### for .NET 8+ projects

```xml
<ItemGroup>
  <!-- core xunit v3 packages -->
  <PackageReference Include="xunit.v3" Version="3.1.0" />
  <PackageReference Include="xunit.runner.visualstudio" Version="3.1.5" />

  <!-- code coverage support -->
  <PackageReference Include="Microsoft.Testing.Extensions.CodeCoverage" Version="17.10.1" />

  <!-- optional: TRX reporting -->
  <PackageReference Include="Microsoft.Testing.Extensions.TrxReport" Version="1.7.0" />
</ItemGroup>
```

#### global usings

```xml
<ItemGroup>
  <Using Include="Xunit" />
</ItemGroup>
```

## project structure best practices

### directory organization

```
SolutionRoot/
├── src/
│   └── YourProject/
└── tests/
    └── YourProject.Tests/          # test project
        ├── YourProject.Tests.csproj
        ├── testconfig.json         # MTP configuration (optional)
        ├── UnitTests/              # organize by test type
        ├── IntegrationTests/
        └── Fixtures/               # shared test fixtures
```

### test organization patterns

```csharp
namespace YourProject.Tests.UnitTests;

// organize tests by the class they're testing
public class CalculatorTests
{
    // use descriptive test method names that explain the scenario
    [Fact]
    public void Add_WithPositiveNumbers_ReturnsCorrectSum()
    {
        // arrange
        var calculator = new Calculator();

        // act
        var result = calculator.Add(2, 3);

        // assert
        Assert.Equal(5, result);
    }

    // use theory for parameterized tests
    [Theory]
    [InlineData(2, 3, 5)]
    [InlineData(-1, 1, 0)]
    [InlineData(0, 0, 0)]
    public void Add_WithVariousInputs_ReturnsCorrectSum(int a, int b, int expected)
    {
        var calculator = new Calculator();
        var result = calculator.Add(a, b);
        Assert.Equal(expected, result);
    }
}
```

## configuration best practices

### testconfig.json (optional)

for MTP-specific configuration, create a `testconfig.json` file:

```json
{
  "Microsoft.Testing.Platform": {
    "TelemetryOptOut": true,
    "ExitProcessOnUnhandledException": false
  }
}
```

### environment variables

```bash
# disable telemetry
TESTINGPLATFORM_TELEMETRY_OPTOUT=1

# enable diagnostic logging
TESTINGPLATFORM_DIAGNOSTIC=1
TESTINGPLATFORM_DIAGNOSTIC_OUTPUT_DIRECTORY=/path/to/logs
```

## running tests

### command-line execution

```bash
# run the test project directly as an executable
dotnet run --project YourProject.Tests

# or after building
./bin/Debug/net8.0/YourProject.Tests

# with MTP options
dotnet run --project YourProject.Tests -- --minimum-expected-tests 10
```

### using dotnet test

```bash
# standard execution
dotnet test

# with code coverage
dotnet test --coverage --coverage-output-format cobertura

# with TRX reporting
dotnet test -- --report-trx

# filter tests
dotnet test --filter "FullyQualifiedName~Calculator"
```

### Visual Studio integration

- requires Visual Studio 2022 (17.14.16+)
- test explorer automatically detects MTP tests
- no additional configuration needed

## migration from VSTest/xUnit v2

### migration checklist

1. **update package references**:
   - replace `xunit` with `xunit.v3`
   - remove `Microsoft.NET.Test.Sdk` (optional, but recommended)

2. **add MSBuild properties**:
   - add `<OutputType>Exe</OutputType>`
   - add `<UseMicrosoftTestingPlatformRunner>true</UseMicrosoftTestingPlatformRunner>`
   - add `<TestingPlatformDotnetTestSupport>true</TestingPlatformDotnetTestSupport>`

3. **update code coverage**:
   - replace `coverlet.collector` with `Microsoft.Testing.Extensions.CodeCoverage`
   - update coverage commands to use `--coverage` instead of `/p:CollectCoverage=true`

4. **update CI/CD pipelines**:
   - MTP projects work with standard `dotnet test` commands
   - update coverage and reporting commands as needed

### backward compatibility

during migration, you can maintain both VSTest and MTP support:

- keep `Microsoft.NET.Test.Sdk` package reference
- use conditional MSBuild properties
- gradually migrate as development environments update

## common issues and solutions

### issue: tests don't run in dotnet test

**solution**: ensure `TestingPlatformDotnetTestSupport` is set to `true` in the project file.

### issue: coverage not collected

**solution**: add `Microsoft.Testing.Extensions.CodeCoverage` package and use `--coverage` flag.

### issue: tests not discovered in Visual Studio

**solution**: ensure Visual Studio 2022 version is 17.14.16 or later, and rebuild the solution.

### issue: performance issues with TestingPlatformShowTestsFailure

**solution**: this property has a performance impact. disable it for large test suites:
```xml
<TestingPlatformShowTestsFailure>false</TestingPlatformShowTestsFailure>
```

## code review checklist

when reviewing xunit v3 MTP projects, verify:

- [ ] `OutputType` is set to `Exe`
- [ ] `UseMicrosoftTestingPlatformRunner` is set to `true`
- [ ] `TestingPlatformDotnetTestSupport` is set to `true` (if using dotnet test)
- [ ] package references are up to date (xunit.v3 3.1.0+ )
- [ ] tests follow naming conventions and organizational patterns
- [ ] async tests properly use `async Task` instead of `async void`
- [ ] theory tests have appropriate test data
- [ ] test isolation is maintained (no shared mutable state)
- [ ] proper use of fixtures for expensive setup/teardown
- [ ] appropriate assertions are used

## additional resources

- [Microsoft Testing Platform documentation](https://learn.microsoft.com/en-us/dotnet/core/testing/microsoft-testing-platform-intro)
- [xUnit.net v3 documentation](https://xunit.net/docs/getting-started/v3/microsoft-testing-platform)
- [Migration guide from VSTest to MTP](https://learn.microsoft.com/en-us/dotnet/core/testing/migrating-vstest-microsoft-testing-platform)
- [Unit testing best practices](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices)
