---
name: laravel-tester
description:
    Generates modern maintainable Laravel applications unit and feature
    (integration) tests with a focus on performance by default and for best
    testing style practices.
---

# Laravel Tester

## Instructions

### Models Testing Policy

- DO NOT create unit tests for Laravel Eloquent models.
- Rationale:
    - Laravel's Eloquent ORM is extensively tested by the Laravel team
    - Testing basic CRUD operations, relationships, and standard functionality
      provides no value
    - Models are excluded from code coverage metrics (see phpunit.xml)
- What NOT to test:
    - Basic relationships (hasOne, hasMany, belongsTo, etc.)
    - Simple CRUD operations (create, update, delete, find)
    - Standard Eloquent functionality
    - Factory creation without custom logic
    - Basic fillable/guarded attributes
    - Standard casting functionality
- Exceptions — What TO test:
    - Custom business logic methods
    - Complex accessors/mutators with business rules
    - Custom scopes with specific logic
    - Observer behavior and side effects
    - Mass assignment protection (if critical)
- Where to test model functionality instead:
    - Feature tests via HTTP endpoints and workflows
    - Integration tests for model interactions
    - Observer tests for event handlers
    - Action/Service tests for business logic

### Framework

- **Pest PHP** - Modern testing framework with BDD-style syntax
- **Mutation Testing** with Infection for test quality assurance
- **Architectural Testing** to enforce code structure rules

### Test Structure

```
tests/
├── Feature/          # Integration tests
│   ├── Auth/
│   ├── MentorPrograms/
│   └── Pages/
├── Unit/             # Unit tests
│   ├── Actions/
│   ├── Models/
│   ├── Observers/
│   └── Support/
├── Pest.php         # Pest configuration
└── TestCase.php     # Base test case
```

### Running Tests

All tests must be run in a Docker container. Feature tests do not need to
mutate.

#### With Docker

```bash
# Run all tests
docker compose exec app ./vendor/bin/pest

# Run with coverage
docker compose exec app ./vendor/bin/pest --coverage

# Run mutation testing
docker compose exec app ./vendor/bin/pest --mutate --covered-only --parallel --min=100

# Run specific test file
docker compose exec app ./vendor/bin/pest tests/Unit/ExampleTest.php
```

#### Local Environment

```bash
# Ensure test database is configured in .env.testing
./vendor/bin/pest
./vendor/bin/pest --coverage
./vendor/bin/pest --mutate --covered-only --parallel --min=100
```

### Test Configuration

- **Database**: Uses RefreshDatabase trait for clean test state
- **Environment**: Configured in phpunit.xml with testing-specific settings
- **Coverage**: Reports generated in `coverage/` directory
- **Memory Limit**: 512M for test execution

### Writing Tests

#### Basic Test Structure

```php
<?php

declare(strict_types=1);

// For mutation testing (optional)
mutates(YourClass::class);

describe('Feature Description', function (): void {
    beforeEach(function (): void {
        // Setup code
        $this->user = User::factory()->create();
    });

    it('describes what it tests', function (): void {
        $result = someFunction();

        expect($result)->toBe('expected_value');
    });
});
```

#### Testing Actions (Laravel Actions Pattern)

```php
it('handles the action correctly', function (): void {
    $action = new YourAction();
    $result = $action->handle($request, $parameters);

    expect($result)
        ->toBeInstanceOf(RedirectResponse::class)
        ->and($result->getTargetUrl())
        ->toBe(route('expected.route'));
});
```

### Architectural Testing

The project enforces architectural rules via `tests/Unit/ArchTest.php`:

- No debugging functions in production code
- Models must extend Eloquent Model
- Page actions must have 'Page' suffix
- Enums must be proper enum classes

### Common Commands

```bash
# Code quality checks
./vendor/bin/phpstan analyse
./vendor/bin/pint --test
./vendor/bin/rector process --dry-run

# Fix code issues
./vendor/bin/pint
./vendor/bin/rector process

# Generate IDE helpers
php artisan ide-helper:generate
php artisan ide-helper:models

# Clear caches
php artisan config:clear
php artisan cache:clear
php artisan view:clear
```

### Code Quality Tools

1. **Laravel Pint** - Code formatting based on Laravel preset with strict rules
2. **PHPStan (Level 5)** - Static analysis with Larastan for Laravel-specific
   checks
3. **Rector** - Automated code modernization for PHP 8.4 and Laravel 12.0
4. **Cognitive Complexity** - Limits complexity (class: 85, function: 8)

### Development Tools

- **Telescope**: Laravel debugging assistant (enabled in testing)
- **Log Viewer**: Web-based log viewing interface
- **IDE Helpers**: Comprehensive IDE support with auto-generated helpers
- **Xdebug**: Available in Docker development environment

## Pest

### Testing

- If you need to verify a feature is working, write or update a Unit / Feature
  test.

### Pest Tests

- All tests must be written using Pest. Use
  `php artisan make:test --pest <name>`.
- You must not remove any tests or test files from the tests directory without
  approval. These are not temporary or helper files - these are core to the
  application.
- Tests should test all of the happy paths, failure paths, and weird paths.
- Tests live in the `tests/Feature` and `tests/Unit` directories.
- Pest tests look and behave like this:
  <code-snippet name="Basic Pest Test Example" lang="php"> it('is true',
  function () { expect(true)->toBeTrue(); }); </code-snippet>

### Running Tests

- Run the minimal number of tests using an appropriate filter before finalizing
  code edits.
- To run all tests: `php artisan test`.
- To run all tests in a file: `php artisan test tests/Feature/ExampleTest.php`.
- To filter on a particular test name: `php artisan test --filter=testName`
  (recommended after making a change to a related file).
- When the tests relating to your changes are passing, ask the user if they
  would like to run the entire test suite to ensure everything is still passing.

### Pest Assertions

- When asserting status codes on a response, use the specific method like
  `assertForbidden` and `assertNotFound` instead of using `assertStatus(403)` or
  similar, e.g.:
  <code-snippet name="Pest Example Asserting postJson Response" lang="php">
  it('returns all', function () { $response = $this->postJson('/api/docs', []);

    $response->assertSuccessful(); }); </code-snippet>

### Mocking

- Mocking can be very helpful when appropriate.
- When mocking, you can use the `Pest\Laravel\mock` Pest function, but always
  import it via `use function Pest\Laravel\mock;` before using it.
  Alternatively, you can use `$this->mock()` if existing tests do.
- You can also create partial mocks using the same import or self method.

### Datasets

- Use datasets in Pest to simplify tests which have a lot of duplicated data.
  This is often the case when testing validation rules, so consider going with
  this solution when writing tests for validation rules.

<code-snippet name="Pest Dataset Example" lang="php">
it('has emails', function (string $email) {
    expect($email)->not->toBeEmpty();
})->with([
    'james' => 'james@laravel.com',
    'taylor' => 'taylor@laravel.com',
]);
</code-snippet>

## Pest 4

- Pest v4 is a huge upgrade to Pest and offers: browser testing, smoke testing,
  visual regression testing, test sharding, and faster type coverage.
- Browser testing is incredibly powerful and useful for this project.
- Browser tests should live in `tests/Browser/`.
- Use the `search-docs` tool for detailed guidance on utilizing these features.

### Browser Testing

- You can use Laravel features like `Event::fake()`, `assertAuthenticated()`,
  and model factories within Pest v4 browser tests, as well as `RefreshDatabase`
  (when needed) to ensure a clean state for each test.
- Interact with the page (click, type, scroll, select, submit, drag-and-drop,
  touch gestures, etc.) when appropriate to complete the test.
- If requested, test on multiple browsers (Chrome, Firefox, Safari).
- If requested, test on different devices and viewports (like iPhone 14 Pro,
  tablets, or custom breakpoints).
- Switch color schemes (light/dark mode) when appropriate.
- Take screenshots or pause tests for debugging when appropriate.

### Example Tests

<code-snippet name="Pest Browser Test Example" lang="php">
it('may reset the password', function () {
    Notification::fake();

    $this->actingAs(User::factory()->create());

    $page = visit('/sign-in'); // Visit on a real browser...

    $page->assertSee('Sign In')
        ->assertNoJavascriptErrors() // or ->assertNoConsoleLogs()
        ->click('Forgot Password?')
        ->fill('email', 'nuno@laravel.com')
        ->click('Send Reset Link')
        ->assertSee('We have emailed your password reset link!')

    Notification::assertSent(ResetPassword::class);

}); </code-snippet>

<code-snippet name="Pest Smoke Testing Example" lang="php">
$pages = visit(['/', '/about', '/contact']);

$pages->assertNoJavascriptErrors()->assertNoConsoleLogs(); </code-snippet>

## Test Enforcement

- Every change must be programmatically tested. Write a new test or update an
  existing test, then run the affected tests to make sure they pass.
- Run the minimum number of tests needed to ensure code quality and speed. Use
  `php artisan test` with a specific filename or filter.

## Laravel Pint Code Formatter

- You must run `vendor/bin/pint --dirty` before finalizing changes to ensure
  your code matches the project's expected style.
- Do not run `vendor/bin/pint --test`, simply run `vendor/bin/pint` to fix any
  formatting issues.
