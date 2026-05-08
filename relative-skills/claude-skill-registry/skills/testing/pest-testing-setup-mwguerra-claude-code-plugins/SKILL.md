---
name: pest-testing-setup
description: Set up Pest testing with Orchestra Testbench for Laravel packages
allowed-tools: Bash(python3:*), Bash(composer:*), Write, Read, Glob
---

# PestPHP Testing Setup Skill

Adds complete PestPHP testing infrastructure to an existing Laravel package.

## Usage

When the user wants to add testing to an existing package:

```bash
python3 ${SKILL_DIR}/scripts/setup_pest_testing.py <vendor/package-name> [options]
```

## Options

- `--filament` - Include Filament/Livewire testing utilities
- `--with-coverage` - Add code coverage configuration
- `--with-ci` - Add GitHub Actions CI workflow

## Examples

### Basic testing setup
```bash
python3 ${SKILL_DIR}/scripts/setup_pest_testing.py mwguerra/my-package
```

### With Filament support
```bash
python3 ${SKILL_DIR}/scripts/setup_pest_testing.py mwguerra/filament-blog --filament
```

### Full setup with CI
```bash
python3 ${SKILL_DIR}/scripts/setup_pest_testing.py mwguerra/my-package --with-coverage --with-ci
```

## What Gets Created/Updated

### Files Created

1. **phpunit.xml** - PHPUnit configuration
   - Code coverage for `src/` directory
   - Unit and Feature test suites
   - Testing environment variables
   - APP_KEY for Laravel testing

2. **tests/Pest.php** - PestPHP configuration
   - TestCase binding for all tests
   - Custom expectations setup
   - Helper functions section

3. **tests/TestCase.php** - Orchestra TestCase
   - Package service provider registration
   - Testing database configuration
   - Environment setup
   - Migration handling

4. **tests/Unit/ExampleTest.php** - Sample unit test
   - Environment verification
   - Service provider registration test
   - Basic package functionality test

5. **tests/Feature/.gitkeep** - Feature tests directory

6. **.github/workflows/tests.yml** (if --with-ci)
   - GitHub Actions workflow
   - Multi-PHP version testing
   - Code coverage reporting

### composer.json Updates

```json
{
  "require-dev": {
    "orchestra/testbench": "^10.0",
    "pestphp/pest": "^3.8",
    "pestphp/pest-plugin-laravel": "^3.1"
  },
  "autoload-dev": {
    "psr-4": {
      "Vendor\\PackageName\\Tests\\": "tests/"
    }
  },
  "scripts": {
    "test": "pest",
    "test-coverage": "pest --coverage"
  }
}
```

**Note**: Uses latest versions for Laravel 11/12 compatibility:
- **Orchestra Testbench ^10.0** - For Laravel 11 & 12
- **PestPHP ^3.8** - Latest stable
- **Pest Plugin Laravel ^3.1** - Latest stable

## Running Tests

After setup:

```bash
# Navigate to package
cd packages/vendor/package-name

# Install dependencies (including dev)
composer install

# Run all tests
./vendor/bin/pest

# Run with coverage
./vendor/bin/pest --coverage

# Run specific test file
./vendor/bin/pest tests/Unit/ExampleTest.php

# Run filtered tests
./vendor/bin/pest --filter="service provider"

# Run in parallel
./vendor/bin/pest --parallel
```

## Writing Tests

### Basic Test Structure
```php
test('it does something', function () {
    // Arrange
    $data = ['key' => 'value'];
    
    // Act
    $result = processData($data);
    
    // Assert
    expect($result)->toBeTrue();
});
```

### Testing Service Provider
```php
test('service is registered', function () {
    expect($this->app->bound('my-service'))->toBeTrue();
});
```

### Testing Commands
```php
test('command runs successfully', function () {
    $this->artisan('my-package:command')
        ->expectsOutput('Success!')
        ->assertSuccessful();
});
```

### Testing with Database
```php
uses(RefreshDatabase::class);

test('it creates model', function () {
    $model = MyModel::create(['name' => 'Test']);
    
    expect($model)->toBeInstanceOf(MyModel::class);
    $this->assertDatabaseHas('my_models', ['name' => 'Test']);
});
```

### Testing Livewire Components (Filament)
```php
use Livewire\Livewire;

test('component renders', function () {
    Livewire::test(MyComponent::class)
        ->assertSee('Expected text')
        ->assertStatus(200);
});
```

## Best Practices

1. **One assertion per test** - Keep tests focused
2. **Descriptive names** - Test names should describe behavior
3. **Arrange-Act-Assert** - Structure tests clearly
4. **Test edge cases** - Empty arrays, null values, boundaries
5. **Use datasets** - For testing multiple scenarios
6. **Mock external services** - Don't call real APIs in tests


## Filament testing

When `--filament` is enabled, tests should follow Filament’s guidance:
- Filament components are Livewire components; use `livewire()` / `Livewire::test()`.
- Test Resources via their URLs and their underlying Livewire components.
- Use table/schema/action helpers to assert columns, filters, actions, and notifications.
