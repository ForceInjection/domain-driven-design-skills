---
name: php-test-writer
description: Skill for creating and editing PHP tests following Prowi conventions. Use when creating tests, updating test files, or refactoring tests. Applies proper structure, naming, factory usage, and Laravel/PHPUnit best practices.
---

# PHP Test Writer Skill

You are an expert at writing PHP tests for the Prowi Laravel application. Your role is to create well-structured, maintainable tests that follow the project's established conventions.

## Project Context

**Important System Details:**
- **Multitenancy**: Most models have `customer_id` - use `->recycle($customer)` to avoid N+1 customer creation
- **Database Schema**: Uses squashed schema (`database/schema/testing-schema.sql`)
- **Laravel Sail**: All commands must use `./vendor/bin/sail` prefix
- **TestCase Properties**: Feature tests have protected properties like `$customer`, `$user`, `$customerUser` - **DO NOT override these**

## Critical Guidelines

### 1. Always Read TestCase.php First

**MANDATORY**: Before writing any feature test, read `tests/TestCase.php` to understand:
- Protected properties that cannot be overridden
- Available helper methods (e.g., `getCustomer()`, `getAdminUser()`, `actingAsCustomerUser()`)
- Setup methods that run automatically (e.g., `setupGroups()`, `setupCurrencies()`)

```php
// ❌ BAD - Will cause errors
class MyTest extends TestCase
{
    protected $customer; // ERROR: Property already exists in TestCase
}

// ✅ GOOD - Use TestCase helper methods
class MyTest extends TestCase
{
    public function test_something()
    {
        $customer = $this->getCustomer(); // Use TestCase helper
    }
}
```

### 2. File Structure & Naming

**Mirror the app/ directory structure:**
```
app/Services/DataObject/DataObjectService.php
→ tests/Feature/Services/DataObject/DataObjectService/DataObjectServiceTest.php

app/Enums/Filtering/RelativeDatePointEnum.php
→ tests/Unit/Enums/Filtering/RelativeDatePointEnum/RelativeDatePointEnumResolveTest.php
```

**Prefer split over flat structure:**
- When a class has many methods or complex edge cases, create a directory
- Use subdirectories to organize related tests

```
✅ Good (split structure):
tests/Feature/Services/DataObject/DataObjectService/
├── BaseDataObjectServiceTest.php      # Base class
├── Create/
│   ├── BasicCreateTest.php
│   ├── UserColumnTest.php
│   └── FailedOperationTest.php
└── Update/
    ├── BasicUpdateTest.php
    └── UserColumnTest.php

❌ Avoid (flat structure for complex classes):
tests/Feature/Services/DataObject/
└── DataObjectServiceTest.php  # Too much in one file
```

### 3. Test Method Naming

**Formula**: `test_{methodUnderTest}__{conditions}__{expectedOutput}`

```php
// ✅ Excellent examples:
public function test_update_dispatches_data_object_received_event()
public function test_process_converts_non_string_values_to_strings()
public function test_last_month_with_year_transition()
public function test_attempt_to_create_dataobject_with_existing_extref__throws_error()
public function test_resolve_by_external_id_only_finds_users_for_correct_customer()

// ❌ Avoid:
public function test_update()  // Too vague
public function testUpdateMethod()  // Not descriptive enough
```

**When a whole file tests a single method:**
- Method name can be omitted from test name
- Example: `RelativeDatePointEnumResolveTest.php` tests only `resolve()`, so methods are named like `test_current_quarter_boundaries()`

**Always add PHPDoc:**
```php
/**
 * Test that updating a DataObject dispatches DataObjectReceived event
 */
public function test_update_dispatches_data_object_received_event()
{
    // Test implementation
}
```

### 4. Test Structure: Arrange-Act-Assert

Use the AAA pattern when it makes sense:

```php
public function test_update_object_fields()
{
    // Arrange
    $objectDefinition = $this->getObjectDefinition(
        data_key: 'test_object_update'
    );

    $dataObject = $this->dataObjectService->create(
        objectDefinition: $objectDefinition,
        objectFields: [
            'field1' => 'value1',
            'field2' => 'value2',
        ]
    );

    // Act
    $updatedDataObject = $this->dataObjectService->update(
        dataObject: $dataObject,
        objectFields: [
            'field1' => 'updated_value1',
        ],
        throwOnValidationErrors: true,
    );

    // Assert
    $this->assertEquals('updated_value1', $updatedDataObject->object_fields['field1']);
    $this->assertEquals('value2', $updatedDataObject->object_fields['field2']);
}
```

### 5. Factory Usage

**ALWAYS use factories - NEVER create models manually:**

```php
// ✅ GOOD - Use factories
$customer = Customer::factory()->create();
$user = User::factory()->create();
$customerUser = CustomerUser::factory()
    ->recycle($customer)
    ->recycle($user)
    ->create();

$objectDefinition = ObjectDefinition::factory()
    ->recycle($customer)
    ->create();

// ❌ BAD - Manual creation
$customer = Customer::create(['name' => 'Test Customer']);
$user = new User(['name' => 'Test', 'email' => 'test@test.com']);
$user->save();
```

**Use ->recycle() extensively for multitenancy:**

```php
// ✅ EXCELLENT - Recycle customer across all models
$customer = Customer::factory()->create();

$objectDefinition = ObjectDefinition::factory()
    ->recycle($customer)  // Uses same customer
    ->create();

$dataObject = DataObject::factory()
    ->recycle($customer)           // Same customer
    ->recycle($objectDefinition)    // And its nested relations also use same customer
    ->createOneWithService();

// ❌ BAD - Creates multiple customers
$objectDefinition = ObjectDefinition::factory()->create(); // Creates new customer
$dataObject = DataObject::factory()
    ->recycle($objectDefinition)
    ->createOneWithService(); // objectDefinition and dataObject have different customers!
```

**Factory Tips:**
- Check if factories have custom states before manually setting attributes
- Use `->forCustomerUser()`, `->forUserGroup()`, etc. when available
- DataObject uses `->createOneWithService()` or `->createWithService()` instead of `->create()`

### 6. Named Arguments

**Always use named arguments for clarity:**

```php
// ✅ GOOD
$result = $this->processor->process(
    inputValue: 'test',
    processingContext: [],
    objectDefinition: $objectDefinition,
    columnData: $columnData
);

$dataObject = $this->dataObjectService->create(
    objectDefinition: $objectDefinition,
    objectFields: ['name' => 'Test'],
    extRef: 'ext-123',
    visibleRef: 'VIS-123'
);

// ❌ BAD
$result = $this->processor->process('test', [], $objectDefinition, $columnData);
$dataObject = $this->dataObjectService->create($objectDefinition, ['name' => 'Test'], 'ext-123');
```

### 7. Authentication & Session

**Use TestCase helpers:**

```php
// ✅ GOOD - Use TestCase helpers
$customer = $this->getCustomer();
$adminUser = $this->getAdminUser();
$adminCustomerUser = $this->getAdminCustomerUser();

// Acting as a customer user
$this->actingAsCustomerUser($adminCustomerUser);

// Or for session only
CustomerSession::store($customer);

// ❌ BAD - Manual session manipulation
session()->put('customer', CustomerSessionData::fromCustomer($customer)->toArray());
```

### 8. DataObject & ObjectDefinition Management

**CRITICAL: Use services and helpers for data management**

**DataObject Operations:**
- **ALL DataObject changes MUST go through DataObjectService**
- Never create or update DataObjects directly with Eloquent
- Resolve the service using `app()->make()` NOT `app()`

```php
// ✅ GOOD - Use DataObjectService
/** @var DataObjectService $dataObjectService */
$dataObjectService = app()->make(DataObjectService::class);

$dataObject = $dataObjectService->create(
    objectDefinition: $objectDefinition,
    extRef: 'test-ref',
    visibleRef: 'TEST-001',
    objectFields: ['field1' => 'value1']
);

$updated = $dataObjectService->update(
    dataObject: $dataObject,
    objectFields: ['field1' => 'updated_value']
);

// ❌ BAD - Direct model creation/update
$dataObject = DataObject::create([...]);  // NEVER DO THIS
$dataObject->update([...]);               // NEVER DO THIS
```

**ObjectDefinition Creation:**
- **ALWAYS use TestCase helper methods** for creating ObjectDefinitions
- Helper methods: `getObjectDefinition()` and `getManagedObjectDefinition()`
- These helpers use ObjectDefinitionService internally

```php
// ✅ GOOD - Use TestCase helper
$objectDefinition = $this->getObjectDefinition(
    data_key: 'test_object',
    columns: [
        ObjectDefinitionColumnData::stringColumn(
            column_key: 'name',
            column_name: 'Name'
        ),
        ObjectDefinitionColumnData::decimalColumn(
            column_key: 'amount',
            column_name: 'Amount'
        ),
    ],
);

// For managed object definitions (e.g., Integration)
$objectDefinition = $this->getManagedObjectDefinition(
    data_key: 'deal',
    manageable: $integration,
    primaryTitleColumn: 'name',
    columns: [
        ObjectDefinitionColumnData::stringColumn(
            column_name: 'name',
            column_key: 'name'
        ),
    ],
);

// ❌ BAD - Manual creation with factories
$objectDefinition = ObjectDefinition::factory()
    ->recycle($this->customer)
    ->create(['data_key' => 'test']);

ObjectDefinitionColumn::factory()
    ->recycle($objectDefinition)
    ->create(['column_key' => 'test']);
```

**Service Resolution Pattern:**
```php
// ✅ GOOD - Use app()->make() for type-safe resolution
/** @var DataObjectService $dataObjectService */
$dataObjectService = app()->make(DataObjectService::class);

/** @var ObjectDefinitionService $objectDefinitionService */
$objectDefinitionService = app()->make(ObjectDefinitionService::class);

// ❌ BAD - Using app() directly (no type safety)
$dataObjectService = app(DataObjectService::class);
```

### 9. Base Test Classes

**Create base classes for shared setup:**

```php
// Example: BaseDataObjectServiceTest.php
abstract class BaseDataObjectServiceTest extends TestCase
{
    protected ?DataObjectService $dataObjectService = null;
    protected ?ObjectDefinitionService $objectDefinitionService = null;

    protected function setUp(): void
    {
        parent::setUp();

        $this->setupUserAndCustomer();
        $this->dataObjectService = app()->make(DataObjectService::class);
        $this->objectDefinitionService = app()->make(ObjectDefinitionService::class);
    }
}

// Then extend in specific tests
class BasicCreateTest extends BaseDataObjectServiceTest
{
    public function test_something()
    {
        // $this->dataObjectService is already available
    }
}
```

**Create custom assertion helpers:**

```php
// Example: BaseProcessorTestCase.php
protected function assertProcessedSuccessfully(
    ColumnProcessingResult $result,
    mixed $expectedValue,
    string $message = ''
): void {
    $this->assertFalse($result->hasErrors(), $message ?: 'Expected processing to succeed');
    $this->assertTrue($result->isSuccess(), $message ?: 'Expected success');
    $this->assertEquals($expectedValue, $result->value, $message ?: 'Value mismatch');
}

// Usage in tests
$result = $this->processValue(inputValue: 'test', columnData: $columnData);
$this->assertProcessedSuccessfully(result: $result, expectedValue: 'test');
```

### 10. Common Patterns

**Testing events:**
```php
Event::fake();

// ... perform action ...

Event::assertDispatched(DataObjectReceived::class, function ($event) use ($dataObject) {
    return $event->dataObject->id === $dataObject->id;
});
```

**Testing exceptions:**
```php
$this->expectException(DuplicateExtRefException::class);
$this->expectExceptionMessage('External reference already exists');

// ... code that should throw ...
```

**Using data providers:**
```php
/**
 * @dataProvider nullAndEmptyValueProvider
 */
public function test_handles_null_and_empty($value)
{
    // Test implementation
}

public static function nullAndEmptyValueProvider(): array
{
    return [
        'null' => [null],
        'empty string' => [''],
    ];
}
```

### 11. Assertions

**Use specific assertions with meaningful messages:**

```php
// ✅ GOOD
$this->assertEquals('expected', $actual, 'Default value was not applied correctly');
$this->assertNotNull($result, 'Result should not be null');
$this->assertCount(3, $items, 'Expected 3 items in collection');
$this->assertInstanceOf(DataObject::class, $result);
$this->assertDatabaseHas('data_objects', ['ext_ref' => 'test-123']);

// ❌ AVOID
$this->assertTrue($actual == 'expected'); // Use assertEquals instead
$this->assertTrue(!is_null($result));     // Use assertNotNull instead
```

## Anti-Patterns to Avoid

### ❌ Hardcoded IDs
```php
// BAD
$dataObject = DataObject::create([
    'object_definition_id' => 1,
    'customer_id' => 1,
]);

// GOOD
$dataObject = DataObject::factory()
    ->recycle($objectDefinition)
    ->recycle($customer)
    ->createOneWithService();
```

### ❌ Manual Model Creation
```php
// BAD
$user = User::create([
    'name' => 'Test',
    'email' => 'test@example.com',
    'password' => bcrypt('password'),
]);

// GOOD
$user = User::factory()->create([
    'email' => 'test@example.com'  // Only specify what matters for the test
]);
```

### ❌ Overriding TestCase Protected Properties
```php
// BAD - Will cause errors
class MyTest extends TestCase
{
    protected $customer;  // ERROR: Already defined in TestCase
    protected $user;      // ERROR: Already defined in TestCase
}

// GOOD - Use TestCase helpers
class MyTest extends TestCase
{
    public function test_something()
    {
        $customer = $this->getCustomer();
        $user = User::factory()->create();
    }
}
```

### ❌ Using env() Directly
```php
// BAD
$apiKey = env('API_KEY');

// GOOD
$apiKey = config('services.api.key');
```

## Test Execution

**Running tests:**
```bash
# All tests
./vendor/bin/sail php artisan test

# Specific file
./vendor/bin/sail php artisan test tests/Feature/Services/DataObject/DataObjectService/Create/BasicCreateTest.php

# Specific test method
./vendor/bin/sail php artisan test --filter=test_update_dispatches_data_object_received_event

# With filter
./vendor/bin/sail php artisan test --filter=DataObjectService
```

**Schema regeneration (when migrations change):**
```bash
./vendor/bin/sail php artisan schema:regenerate-testing --env=testing
```

## Examples from Codebase

### Feature Test Example (Integration)

```php
<?php

namespace Tests\Feature\Services\DataObject\DataObjectService\Create;

use App\Data\ObjectDefinition\ObjectDefinitionColumnData;
use App\Exceptions\DataObject\DuplicateExtRefException;
use Tests\Feature\Services\DataObject\DataObjectService\BaseDataObjectServiceTest;

/**
 * Test basic creation functionality of DataObjectService
 */
class BasicCreateTest extends BaseDataObjectServiceTest
{
    public function test_attempt_to_create_dataobject_with_existing_extref__throws_error()
    {
        $objectDefinition = $this->getObjectDefinition(
            columns: [
                ObjectDefinitionColumnData::stringColumn(column_key: 'test_field'),
            ],
        );

        $this->dataObjectService->create(
            objectDefinition: $objectDefinition,
            objectFields: ['test_field' => 'Test Value'],
            extRef: 'test-create-ref',
        );

        $this->expectException(DuplicateExtRefException::class);

        // Should throw an exception because the extRef already exists
        $this->dataObjectService->create(
            objectDefinition: $objectDefinition,
            objectFields: ['test_field' => 'Test Value'],
            extRef: 'test-create-ref',
        );
    }
}
```

### Unit Test Example (Isolated)

```php
<?php

namespace Tests\Unit\Enums\Filtering\RelativeDatePointEnum;

use App\Enums\Filtering\RelativeDatePointEnum;
use Carbon\Carbon;
use Exception;
use Tests\Unit\BaseUnitTestCase;

class RelativeDatePointEnumResolveTest extends BaseUnitTestCase
{
    /**
     * Test that context period boundaries resolve correctly
     */
    public function test_context_period_boundaries_resolve_correctly(): void
    {
        $periodStart = Carbon::parse('2025-01-01 00:00:00', 'UTC');
        $periodEnd = Carbon::parse('2025-01-31 23:59:59', 'UTC');

        $startResult = RelativeDatePointEnum::START_OF_CONTEXT_PERIOD->resolve(
            contextPeriodStart: $periodStart,
            contextPeriodEnd: $periodEnd
        );

        $endResult = RelativeDatePointEnum::END_OF_CONTEXT_PERIOD->resolve(
            contextPeriodStart: $periodStart,
            contextPeriodEnd: $periodEnd
        );

        $this->assertEquals('2025-01-01 00:00:00', $startResult->format('Y-m-d H:i:s'));
        $this->assertEquals('2025-01-31 23:59:59', $endResult->format('Y-m-d H:i:s'));
    }

    /**
     * Test that context period boundaries throw exception when context is missing
     */
    public function test_context_period_boundaries_throw_exception_when_missing(): void
    {
        $this->expectException(Exception::class);
        $this->expectExceptionMessage('Cannot resolve relative date point');

        RelativeDatePointEnum::START_OF_CONTEXT_PERIOD->resolve();
    }
}
```

### Base Test Class Example

```php
<?php

namespace Tests\Feature\Services\DataObject\ObjectFields\ColumnTypeProcessors;

use App\Data\ObjectDefinition\ObjectDefinitionColumnData;
use App\Enums\DataObject\Error\DataObjectErrorCode;
use App\Enums\ObjectDefinition\ObjectDefinitionColumn\ColumnTypeEnum;
use App\Models\ObjectDefinition;
use App\Services\DataObject\ObjectFields\ColumnProcessingResult;
use App\Services\DataObject\ObjectFields\ColumnTypeProcessors\AbstractColumnProcessor;
use Tests\TestCase;

/**
 * Base test case for column processor tests with helpful assertion methods
 */
abstract class BaseProcessorTestCase extends TestCase
{
    protected AbstractColumnProcessor $processor;

    /**
     * Create a simple column data object for testing
     */
    protected function makeColumnData(
        string $columnKey = 'test_field',
        ColumnTypeEnum $columnType = ColumnTypeEnum::STRING,
        bool $isRequired = false,
        mixed $defaultValue = null,
        ?string $columnName = null
    ): ObjectDefinitionColumnData {
        return ObjectDefinitionColumnData::from([
            'column_key' => $columnKey,
            'column_name' => $columnName ?? ucfirst(str_replace('_', ' ', $columnKey)),
            'column_type' => $columnType,
            'is_required' => $isRequired,
            'default_value' => $defaultValue,
        ]);
    }

    /**
     * Process a value using the processor with standard test parameters
     */
    protected function processValue(
        mixed $inputValue,
        ?ObjectDefinitionColumnData $columnData = null,
        array $processingContext = []
    ): ColumnProcessingResult {
        $columnData = $columnData ?? $this->makeColumnData();
        $objectDefinition = \Mockery::mock(ObjectDefinition::class);

        return $this->processor->process(
            inputValue: $inputValue,
            processingContext: $processingContext,
            objectDefinition: $objectDefinition,
            columnData: $columnData
        );
    }

    /**
     * Assert that processing was successful and returned the expected value
     */
    protected function assertProcessedSuccessfully(
        ColumnProcessingResult $result,
        mixed $expectedValue,
        string $message = ''
    ): void {
        $this->assertFalse($result->hasErrors(), $message ?: 'Expected processing to succeed but it had errors');
        $this->assertTrue($result->isSuccess(), $message ?: 'Expected processing to be marked as successful');
        $this->assertEquals($expectedValue, $result->value, $message ?: 'Expected processed value did not match');
    }
}
```

## Workflow

When writing tests:

1. **Read TestCase.php** to understand available helpers and protected properties
2. **Check for existing similar tests** to follow established patterns
3. **Read the PHPUnit guidelines** at `docs/development/guidelines/php/phpunit-guidelines.md`
4. **Determine test type**: Feature (integration) or Unit (isolated)
5. **Create proper directory structure** mirroring app/ directory
6. **Use factories exclusively** with `->recycle()` for multitenancy
7. **Write descriptive test names** following the convention
8. **Add PHPDoc** explaining what the test does
9. **Use named arguments** throughout
10. **Run the tests** to verify they pass
11. **Consider creating base test class** if you have multiple related test files

## Final Reminder

- **ALWAYS read TestCase.php first** for feature tests
- **NEVER override TestCase protected properties**
- **ALWAYS use factories** with `->recycle($customer)`
- **ALWAYS use named arguments** for clarity
- **ALL DataObject changes through DataObjectService** - Never create/update DataObjects directly
- **Use TestCase helpers for ObjectDefinitions** - `getObjectDefinition()` or `getManagedObjectDefinition()`
- **Resolve services with `app()->make()`** - NOT `app()` for type safety
- **Mirror app/ directory structure** in tests
- **Prefer split over flat** structure for complex classes
- **Run tests after writing** to ensure they pass


Your goal is to create maintainable, readable tests that future developers can easily understand and extend.

