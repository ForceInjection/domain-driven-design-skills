---
name: test-data-strategy
description: Plan comprehensive test data management including synthetic data generation, data anonymization, versioning, and environment-specific strategies.
allowed-tools: Read, Write, Glob, Grep, Task, WebSearch, WebFetch
---

# Test Data Strategy

## When to Use This Skill

Use this skill when:

- **Test Data Strategy tasks** - Working on plan comprehensive test data management including synthetic data generation, data anonymization, versioning, and environment-specific strategies
- **Planning or design** - Need guidance on Test Data Strategy approaches
- **Best practices** - Want to follow established patterns and standards

## Overview

Effective test data management ensures tests have the right data at the right time while protecting sensitive information and maintaining data quality across environments.

## Test Data Types

| Type | Source | Use Case | Privacy Risk |
|------|--------|----------|--------------|
| **Synthetic** | Generated | Unit/Integration tests | None |
| **Subset** | Production sample | Performance testing | Medium |
| **Masked** | Anonymized production | Realistic scenarios | Low |
| **Production Clone** | Full copy | Pre-prod validation | High |
| **Baseline** | Curated reference | Regression testing | Low |

## Test Data Strategy Template

```markdown
# Test Data Strategy: [Project Name]

## 1. Data Requirements

### By Test Level
| Level | Data Source | Volume | Refresh |
|-------|-------------|--------|---------|
| Unit | Synthetic | Minimal | On-demand |
| Integration | Synthetic/Subset | Moderate | Per run |
| System | Masked production | Realistic | Weekly |
| Performance | Scaled synthetic | Production-like | Per release |

### By Feature Area
| Feature | Critical Data | Volume Required | Sensitivity |
|---------|---------------|-----------------|-------------|
| Authentication | User accounts | 1000 | High |
| Payments | Transactions | 10000 | High |
| Reporting | Historical data | 1M records | Medium |

## 2. Data Generation Strategy

### Synthetic Data Tools
- **Unit Tests**: AutoFixture, Bogus
- **Integration**: TestContainers + Seed
- **Performance**: Bulk generators

### Generation Rules
| Entity | Key Fields | Generation Logic |
|--------|------------|------------------|
| User | Email | `{guid}@test.example.com` |
| Order | Amount | `Random(1, 10000)` |
| Date | Timestamp | `Random(now-1y, now)` |

## 3. Data Anonymization

### PII Fields
| Field | Original | Anonymization Method |
|-------|----------|---------------------|
| Name | John Smith | Faker generated |
| Email | john@acme.com | `hash@domain.test` |
| Phone | 555-123-4567 | `555-xxx-xxxx` |
| SSN | 123-45-6789 | `xxx-xx-xxxx` |
| Address | 123 Main St | Faker address |
| DOB | 1985-03-15 | Shift by random days |

### Anonymization Rules
- Preserve data relationships
- Maintain referential integrity
- Keep statistical properties
- Remove unique identifiers

## 4. Environment Strategy

### Dev Environment
- Source: 100% synthetic
- Refresh: On-demand
- Volume: Minimal

### QA Environment
- Source: Masked production subset
- Refresh: Weekly
- Volume: 10% of production

### Staging Environment
- Source: Masked production clone
- Refresh: Before each release
- Volume: 100% of production

### Performance Environment
- Source: Scaled synthetic
- Refresh: Before performance runs
- Volume: 150% of production

## 5. Data Versioning

### Baseline Management
- Version baseline data sets
- Track data schema changes
- Maintain backward compatibility
- Document data dependencies

### Refresh Procedures
1. Trigger: [Manual/Scheduled/Event]
2. Source: [Production/Backup/Generator]
3. Transform: [Anonymization steps]
4. Load: [Target environment]
5. Validate: [Verification checks]

## 6. Compliance Requirements

### GDPR Compliance
- [ ] No real EU citizen data in non-prod
- [ ] Right to erasure supported
- [ ] Data minimization applied
- [ ] Consent tracking anonymized

### HIPAA Compliance
- [ ] PHI fully de-identified
- [ ] Safe Harbor method applied
- [ ] Audit logs maintained
- [ ] Access controls verified
```

## Synthetic Data Generation (.NET)

### Using Bogus

```csharp
using Bogus;

public class TestDataGenerator
{
    public static Faker<Customer> CustomerFaker => new Faker<Customer>()
        .RuleFor(c => c.Id, f => f.Random.Guid())
        .RuleFor(c => c.FirstName, f => f.Person.FirstName)
        .RuleFor(c => c.LastName, f => f.Person.LastName)
        .RuleFor(c => c.Email, (f, c) => f.Internet.Email(c.FirstName, c.LastName))
        .RuleFor(c => c.Phone, f => f.Phone.PhoneNumber())
        .RuleFor(c => c.DateOfBirth, f => f.Date.Past(50, DateTime.Now.AddYears(-18)))
        .RuleFor(c => c.Address, f => new Address
        {
            Street = f.Address.StreetAddress(),
            City = f.Address.City(),
            State = f.Address.StateAbbr(),
            Zip = f.Address.ZipCode()
        });

    public static Faker<Order> OrderFaker(Customer customer) => new Faker<Order>()
        .RuleFor(o => o.Id, f => f.Random.Guid())
        .RuleFor(o => o.CustomerId, customer.Id)
        .RuleFor(o => o.OrderDate, f => f.Date.Recent(30))
        .RuleFor(o => o.Total, f => f.Finance.Amount(10, 1000))
        .RuleFor(o => o.Status, f => f.PickRandom<OrderStatus>());
}
```

### Using AutoFixture

```csharp
using AutoFixture;
using AutoFixture.Xunit2;

public class CustomerTests
{
    [Theory, AutoData]
    public void CreateCustomer_WithValidData_Succeeds(Customer customer)
    {
        // AutoFixture generates valid Customer automatically
        var result = _service.Create(customer);
        Assert.True(result.IsSuccess);
    }

    [Theory, AutoData]
    public void ProcessOrder_CalculatesCorrectTotal(
        [Frozen] Customer customer,
        Order order,
        List<OrderItem> items)
    {
        // Frozen ensures customer is reused
        // Order and items are auto-generated
        order.Items = items;
        var total = _calculator.Calculate(order);
        Assert.Equal(items.Sum(i => i.Quantity * i.Price), total);
    }
}
```

### Seeding Test Databases

```csharp
public class TestDatabaseSeeder
{
    public static async Task SeedAsync(AppDbContext context)
    {
        // Clear existing data
        await context.Database.ExecuteSqlRawAsync("DELETE FROM Orders");
        await context.Database.ExecuteSqlRawAsync("DELETE FROM Customers");

        // Generate test data
        var customers = TestDataGenerator.CustomerFaker.Generate(100);
        await context.Customers.AddRangeAsync(customers);

        foreach (var customer in customers)
        {
            var orders = TestDataGenerator.OrderFaker(customer).Generate(5);
            await context.Orders.AddRangeAsync(orders);
        }

        await context.SaveChangesAsync();
    }
}
```

## Data Anonymization Techniques

| Technique | Description | Use Case |
|-----------|-------------|----------|
| **Substitution** | Replace with fake data | Names, emails |
| **Shuffling** | Rearrange within column | Salaries, dates |
| **Masking** | Partial hiding | SSN (xxx-xx-1234) |
| **Generalization** | Reduce precision | Age ranges, zip prefix |
| **Nulling** | Remove entirely | Unnecessary fields |
| **Tokenization** | Replace with token | Cross-reference needs |
| **Hashing** | One-way transform | Identifiers |

### .NET Anonymization Example

```csharp
public class DataAnonymizer
{
    public Customer Anonymize(Customer source)
    {
        return new Customer
        {
            Id = source.Id, // Preserve for relationships
            FirstName = _faker.Person.FirstName,
            LastName = _faker.Person.LastName,
            Email = $"{Guid.NewGuid():N}@test.example.com",
            Phone = MaskPhone(source.Phone),
            SSN = "xxx-xx-" + source.SSN.Substring(7, 4),
            DateOfBirth = ShiftDate(source.DateOfBirth),
            Address = new Address
            {
                Street = _faker.Address.StreetAddress(),
                City = source.Address.City, // Preserve geography
                State = source.Address.State,
                Zip = source.Address.Zip.Substring(0, 3) + "00"
            }
        };
    }

    private string MaskPhone(string phone)
    {
        // Keep area code, mask rest
        return Regex.Replace(phone, @"(\d{3})\d{3}(\d{4})", "$1-xxx-$2");
    }

    private DateTime ShiftDate(DateTime date)
    {
        // Shift by random days within ±30
        return date.AddDays(_random.Next(-30, 30));
    }
}
```

## Test Data Patterns

### Builder Pattern

```csharp
public class CustomerBuilder
{
    private Customer _customer = new();

    public CustomerBuilder WithName(string first, string last)
    {
        _customer.FirstName = first;
        _customer.LastName = last;
        return this;
    }

    public CustomerBuilder WithPremiumStatus()
    {
        _customer.IsPremium = true;
        _customer.PremiumSince = DateTime.Now.AddYears(-1);
        return this;
    }

    public CustomerBuilder WithOrders(int count)
    {
        _customer.Orders = TestDataGenerator.OrderFaker(_customer).Generate(count);
        return this;
    }

    public Customer Build() => _customer;
}

// Usage
var customer = new CustomerBuilder()
    .WithName("Test", "User")
    .WithPremiumStatus()
    .WithOrders(5)
    .Build();
```

### Object Mother Pattern

```csharp
public static class TestCustomers
{
    public static Customer ValidCustomer() => new()
    {
        Id = Guid.NewGuid(),
        FirstName = "Test",
        LastName = "User",
        Email = "test@example.com",
        Status = CustomerStatus.Active
    };

    public static Customer PremiumCustomer() => new()
    {
        Id = Guid.NewGuid(),
        FirstName = "Premium",
        LastName = "User",
        Email = "premium@example.com",
        IsPremium = true,
        Status = CustomerStatus.Active
    };

    public static Customer InactiveCustomer() => new()
    {
        Id = Guid.NewGuid(),
        Status = CustomerStatus.Inactive
    };
}
```

## Integration Points

**Inputs from**:

- Data model → Test data structure
- Privacy requirements → Anonymization rules
- `test-strategy-planning` skill → Data volume needs

**Outputs to**:

- Test automation → Data fixtures
- `performance-test-planning` skill → Load data
- Environment provisioning → Seed scripts
