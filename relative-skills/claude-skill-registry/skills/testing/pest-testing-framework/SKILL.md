---
name: Pest Testing Framework
description: Integration with the Pest PHP testing framework for writing and running tests
color: pink
---

- Running tests: `php ./vendor/bin/pest`
- Running specific tests: `php ./vendor/bin/pest tests/MyTest.php`

## Overview

Pest is an elegant PHP testing framework with a focus on simplicity. It's built on top of PHPUnit but provides a more expressive and developer-friendly syntax.

## Running Tests

### Basic Commands

```bash
# Run all tests
php ./vendor/bin/pest

# Run tests in a specific directory
php ./vendor/bin/pest tests/Unit

# Run a specific test file
php ./vendor/bin/pest tests/HeroComponentsTest.php

# Run tests with coverage
php ./vendor/bin/pest --coverage

# Run tests with coverage and minimum threshold
php ./vendor/bin/pest --coverage --min=80

# Run tests in parallel (faster execution)
php ./vendor/bin/pest --parallel

# Run tests with verbose output
php ./vendor/bin/pest -v

# Run tests and stop on first failure
php ./vendor/bin/pest --stop-on-failure

# Run tests matching a filter
php ./vendor/bin/pest --filter="HeroComponents"
```

## Test Structure

### Basic Test File

```php
<?php

// tests/ExampleTest.php

test('example test', function () {
    expect(true)->toBeTrue();
});

it('can perform assertions', function () {
    $result = 2 + 2;
    expect($result)->toBe(4);
});
```

### Organized Tests with describe()

```php
<?php

describe('HeroComponents', function () {
    it('renders correctly', function () {
        // Test implementation
    });

    it('handles empty state', function () {
        // Test implementation
    });
});
```

### Using beforeEach() and afterEach()

```php
<?php

beforeEach(function () {
    // Setup code that runs before each test
    $this->user = createUser();
});

afterEach(function () {
    // Cleanup code that runs after each test
    $this->user = null;
});

test('user can login', function () {
    expect($this->user)->not->toBeNull();
});
```

## Common Expectations

### Value Assertions

```php
expect($value)->toBe($expected);           // Strict equality (===)
expect($value)->toEqual($expected);        // Loose equality (==)
expect($value)->toBeTrue();
expect($value)->toBeFalse();
expect($value)->toBeNull();
expect($value)->toBeEmpty();
expect($value)->toBeGreaterThan(5);
expect($value)->toBeLessThan(10);
```

### Type Assertions

```php
expect($value)->toBeInt();
expect($value)->toBeString();
expect($value)->toBeArray();
expect($value)->toBeObject();
expect($value)->toBeInstanceOf(MyClass::class);
```

### Array/Collection Assertions

```php
expect($array)->toHaveCount(3);
expect($array)->toContain('value');
expect($array)->toHaveKey('key');
expect($array)->each->toBeString();
```

### String Assertions

```php
expect($string)->toStartWith('Hello');
expect($string)->toEndWith('World');
expect($string)->toContain('test');
expect($string)->toMatch('/regex/');
```

### Negation

```php
expect($value)->not->toBe('wrong');
expect($array)->not->toBeEmpty();
```

## Datasets

Use datasets to run the same test with different inputs:

```php
<?php

it('can add numbers', function (int $a, int $b, int $expected) {
    expect($a + $b)->toBe($expected);
})->with([
    [1, 2, 3],
    [5, 5, 10],
    [10, 20, 30],
]);

// Named datasets
it('validates email', function (string $email) {
    expect(isValidEmail($email))->toBeTrue();
})->with([
    'valid email' => 'test@example.com',
    'another valid' => 'user@domain.co.uk',
]);
```

## HTTP Requests

Pest provides methods to test HTTP endpoints by simulating requests and asserting on responses.

### Basic GET Requests

```php
<?php

it('loads the homepage', function () {
    $this->get('/')
        ->assertOk();
});

// Can be chained in a fluent style
it('returns json data')
    ->get('/api/data')
    ->assertOk()
    ->assertJson(['status' => 'success']);
```

### POST Requests

```php
<?php

it('posts to an action', function () {
    $this->post('/post-data', ['foo' => 'bar'])
        ->assertOk()
        ->assertSee('"foo":"bar"');
});

// Post JSON data
it('posts json to an action', function () {
    $response = $this->postJson('/post-data', ['foo' => 'bar'])
        ->assertHeader('content-type', 'application/json')
        ->assertOk();

    expect($response->json()->json())->foo->toBe('bar');
});
```

### Authenticated Requests

Use `actingAs()` to make requests as a specific user:

```php
<?php

use markhuot\craftpest\factories\User;

it('allows authenticated users to access protected pages', function () {
    $user = User::factory()->create();

    $this->actingAs($user)
        ->get('/admin/settings')
        ->assertOk();
});

// Shorthand for admin users
it('allows admins to access settings')
    ->actingAsAdmin()
    ->get('/admin/settings')
    ->assertOk();
```

### Common Response Assertions

```php
<?php

// Status codes
->assertOk()                      // 200
->assertCreated()                 // 201
->assertForbidden()               // 403
->assertNotFound()                // 404

// Content assertions
->assertSee('text')               // Response contains text
->assertDontSee('text')           // Response doesn't contain text

// JSON assertions
->assertJson(['key' => 'value'])          // Contains JSON subset
->assertExactJson(['key' => 'value'])     // Exact JSON match
->assertJsonPath('foo', 'bar')            // Assert value at path
->assertJsonCount(2)                       // Assert JSON array count
->assertJsonStructure(['foo', 'bar'])     // Assert JSON structure
->assertJsonFragment(['baz' => 'qux'])    // Contains JSON fragment
->assertJsonMissing(['missing'])          // JSON doesn't contain value
->assertJsonMissingPath('qux')            // Path doesn't exist

// Header assertions
->assertHeader('x-foo')                   // Header exists
->assertHeader('x-foo', 'bar')            // Header has value
->assertHeaderMissing('x-qux')            // Header doesn't exist

// Cookie assertions
->assertCookie('cookieName')                      // Cookie exists
->assertCookie('cookieName', 'cookieValue')       // Cookie has value
->assertCookieMissing('foo')                      // Cookie doesn't exist
->assertCookieExpired('cookieName')               // Cookie is expired
->assertCookieNotExpired('cookieName')            // Cookie is valid

// Other assertions
->assertDownload('file.jpg')              // Response is a download
->assertCacheTag('foo', 'baz')            // Response has cache tags
```

### Working with Response Data

```php
<?php

it('processes json response data', function () {
    $response = $this->get('/api/users');

    // Access JSON data
    $data = $response->json();
    expect($data)->toHaveKey('users');

    // Access response content
    $content = $response->content;
    expect($content)->toContain('expected text');
});
```

### Testing Forms and Links

```php
<?php

it('clicks links and follows redirects', function () {
    $this->get('/links')
        ->querySelector('a')
        ->click()
        ->assertOk()
        ->assertSee('Hello World');
});
```

### Best Practices for HTTP Testing

1. **Test Your Logic, Not the Framework**: Focus on custom validation, rendering logic, or business rules rather than testing if Craft CMS works

2. **Use Meaningful Assertions**: Assert on the actual behavior that matters to your application

3. **Clean URLs**: Use relative URLs starting with `/` for consistency

4. **Chain Assertions**: Take advantage of fluent chaining for readable tests

Example of a well-focused HTTP test:

```php
<?php

it('validates that blog posts require a title', function () {
    $this->actingAsAdmin()
        ->post('/actions/entries/save', [
            'sectionId' => 1,
            'typeId' => 1,
            'title' => '', // Empty title
            'slug' => 'test-post',
        ])
        ->assertSessionHasErrors('title');
});
```

## Rendering Templates Directly

Use `->renderTemplate()` to render Twig templates directly without the overhead of a full HTTP request. This is faster and more focused than `->get()` when you only need to test template output.

### Basic Template Rendering

```php
<?php

it('renders a template', function () {
    $this->renderTemplate('pages/home')
        ->assertSee('Welcome');
});

// Can be chained in a fluent style
it('renders the hero component')
    ->renderTemplate('_components/hero')
    ->assertSee('Hero Content');
```

### Passing Variables to Templates

Pass variables as the second parameter, just like you would in Twig:

```php
<?php

it('renders a template with variables', function () {
    $this->renderTemplate('_components/card', [
        'title' => 'My Card Title',
        'description' => 'Card description text',
    ])
        ->assertSee('My Card Title')
        ->assertSee('Card description text');
});

// Pass complex data
it('renders a list with entries', function () {
    $entries = Entry::factory()
        ->section('posts')
        ->count(3)
        ->create();

    $this->renderTemplate('_partials/entry-list', [
        'entries' => $entries,
    ])
        ->assertSee($entries[0]->title)
        ->assertSee($entries[1]->title)
        ->assertSee($entries[2]->title);
});
```

### All HTTP Assertions Work

Since `renderTemplate()` returns a `TestableResponse` object (same as `->get()` and `->post()`), all the same assertions are available:

```php
<?php

it('uses various assertions on rendered templates', function () {
    $response = $this->renderTemplate('_components/hero', [
        'heading' => 'Welcome',
        'showCta' => true,
    ]);

    // Content assertions
    $response->assertSee('Welcome');
    $response->assertDontSee('Hidden Content');

    // Access the raw content
    expect($response->content)->toContain('<h1>');
});
```

### DOM Selection and Testing

Use `->querySelector()` to select and test specific elements. Because Pest's browser testing uses Playwright under the hood we should use `data-testid` attributes for reliable selection in complex templates. This also allows Playwright to find the same elements during browser tests. For example, in your Twig template:

```twig
<button data-testid="submit-button" class="btn-primary">Submit</button>
```

Then in your Pest test:

```php
<?php
it('selects and tests specific elements using data-testid', function () {
    $this->renderTemplate('_components/button', ['type' => 'primary'])
        ->querySelector('[data-testid="submit-button"]')
        ->assertSee('Submit')
        ->assertAttribute('class', 'btn-primary');
});
````

You can also query any standard CSS selector, but be cautious with this because CSS classes may change as the site evolves or dynamically as JavaScript modifies the DOM. Using `data-testid` attributes provides a stable way to select elements specifically for testing purposes.

```php
<?php

it('selects and tests specific elements', function () {
    $this->renderTemplate('_components/navigation')
        ->querySelector('nav ul')
        ->assertSee('Home')
        ->assertSee('About');
});

it('tests element attributes', function () {
    $this->renderTemplate('_components/button', ['type' => 'primary'])
        ->querySelector('button')
        ->assertAttribute('class', 'btn-primary');
});

it('tests nested elements')
    ->renderTemplate('_layouts/page')
    ->querySelector('header h1')
    ->assertSee('Page Title');
```

### Snapshot Testing

Templates work great with snapshot testing:

```php
<?php

it('matches template snapshot', function () {
    $this->renderTemplate('_components/card', [
        'title' => 'Test Card',
        'content' => 'Test content',
    ])
        ->assertMatchesSnapshot();
});

it('matches element snapshot', function () {
    $this->renderTemplate('_partials/footer')
        ->querySelector('.copyright')
        ->assertMatchesSnapshot();
});
```

### When to Use renderTemplate() vs get()

**Use `->renderTemplate()` when:**
- ✅ Testing template logic in isolation
- ✅ Testing components or partials that don't have their own routes
- ✅ You need faster tests (no HTTP overhead)
- ✅ Testing pure template rendering without controllers or routing

**Use `->get()` when:**
- ✅ Testing full request/response cycles
- ✅ Testing routing, controllers, or middleware
- ✅ Testing with authentication or session state
- ✅ The route performs logic before rendering

**Use browser testing (`visit()` or `visitTemplate()`) when:**
- ✅ Testing JavaScript interactions
- ✅ Testing visual properties (CSS, layout, spacing)
- ✅ Testing dynamic behavior that requires a browser

See **[Browser Testing Documentation](browser-testing.md)** for comprehensive information on browser testing with `visit()` and `visitTemplate()`.

### Best Practices

1. **Test Template Logic, Not Framework Features**: Focus on your custom Twig logic, conditionals, loops, and output

    ```php
    <?php

    // ✅ Good - Testing custom conditional logic
    it('shows CTA when flag is enabled', function () {
        $this->renderTemplate('_components/hero', ['showCta' => true])
            ->assertSee('Call to Action');

        $this->renderTemplate('_components/hero', ['showCta' => false])
            ->assertDontSee('Call to Action');
    });

    // ❌ Bad - Just testing that Twig works
    it('renders a template', function () {
        $this->renderTemplate('_components/hero')
            ->assertSee('Hero');
    });
    ```

2. **Use for Component Testing**: Perfect for testing reusable components in isolation

    ```php
    <?php

    it('renders alert component with different types', function ($type, $expected) {
        $this->renderTemplate('_components/alert', ['type' => $type])
            ->assertSee($expected);
    })->with([
        ['success', 'alert-success'],
        ['error', 'alert-error'],
        ['warning', 'alert-warning'],
    ]);
    ```

3. **Combine with Factories**: Use factories to create realistic test data

    ```php
    <?php

    it('renders entry card with all fields', function () {
        $entry = Entry::factory()
            ->section('articles')
            ->title('Test Article')
            ->description('Article description')
            ->featuredImage($imageId)
            ->create();

        $this->renderTemplate('_components/entry-card', ['entry' => $entry])
            ->assertSee('Test Article')
            ->assertSee('Article description')
            ->querySelector('img')
            ->assertAttribute('src');
    });
    ```

4. **Template Paths**: Use relative paths from your templates directory

    ```php
    <?php

    // Correct paths
    $this->renderTemplate('pages/home')           // templates/pages/home.twig
    $this->renderTemplate('_components/hero')      // templates/_components/hero.twig
    $this->renderTemplate('_partials/nav')         // templates/_partials/nav.twig
    ```

## Factories

See **[Factories Documentation](factories.md)** for comprehensive information on creating test data with factories, including:

- Basic entry creation with `Entry::factory()`
- Setting field values and working with different field types
- Advanced techniques like sequences and custom authors
- Complete examples combining multiple field types

## Test Organization

### Pest.php Configuration

The `tests/Pest.php` file is used for global configuration:

```php
<?php

uses()->in('Feature');
uses()->in('Unit');

// Set up global expectations
expect()->extend('toBeWithinRange', function (int $min, int $max) {
    return $this->toBeGreaterThanOrEqual($min)
        ->toBeLessThanOrEqual($max);
});
```

## Working with Existing Tests

When modifying or creating tests:

1. **Read existing tests first**: Always use the Read tool to examine current test files to understand patterns and conventions used in the project

2. **Match existing style**: Follow the same structure, naming conventions, and assertion patterns used in the codebase

3. **Run tests after changes**: Always run the test suite after making modifications to ensure nothing breaks

4. **Check for test configuration**: Look for `phpunit.xml` or `pest.xml` files that may contain important configuration

## Debugging Tests

### Dumping Values

```php
test('debugging example', function () {
    $value = ['key' => 'value'];

    \markhuot\craftpest\helpers\test\dump($value);  // Output value and continue
    \markhuot\craftpest\helpers\test\dd($value);    // Output value and die

    expect($value)->toHaveKey('key');
});
```

### Using --filter

```bash
# Run only tests with "HeroComponents" in the name
php ./vendor/bin/pest --filter="HeroComponents"

# Run tests in a specific file
php ./vendor/bin/pest tests/HeroComponentsTest.php
```

### Verbose Output

```bash
# Show more details about test execution
php ./vendor/bin/pest -v
php ./vendor/bin/pest -vv
php ./vendor/bin/pest -vvv
```

## Test Coverage

### Generating Coverage Reports

```bash
# HTML coverage report (opens in browser)
php ./vendor/bin/pest --coverage --coverage-html=coverage

# Terminal coverage report
php ./vendor/bin/pest --coverage

# Enforce minimum coverage
php ./vendor/bin/pest --coverage --min=80
```

## Best Practices

1. **Focus on User Logic, Not Framework Functionality**: Do not write tests that only verify core Craft CMS or Pest functionality. Tests should focus on your custom logic, business rules, or validation.

   **❌ Bad - Testing framework functionality:**

    ```php
    it('can create a hero component entry', function () {
        $entry = Entry::factory()
            ->section('heroComponents')
            ->heading('Test Hero Heading')
            ->description('<p>Test hero description content</p>')
            ->create();

        // These only test that Craft and Pest work, not your code
        expect($entry)->toBeInstanceOf(Entry::class);
        expect($entry->section->handle)->toBe('heroComponents');
        expect((string)$entry->heading)->toBe('Test Hero Heading');
        expect((string)$entry->description)->toContain('Test hero description');
    });
    ```

   **✅ Good - Testing custom validation or business logic:**

    ```php
    it('validates that heading cannot exceed 100 characters', function () {
        $entry = Entry::factory()
            ->section('heroComponents')
            ->heading(str_repeat('a', 101))
            ->create();

        expect($entry->getErrors('heading'))->not->toBeEmpty();
    });

    it('renders hero component with formatted output', function () {
        $entry = Entry::factory()
            ->section('heroComponents')
            ->heading('Test Heading')
            ->create();

        $output = renderHeroComponent($entry);

        expect($output)->toContain('<h1>Test Heading</h1>');
        expect($output)->toContain('hero-component-wrapper');
    });
    ```

   Only create entries with factories as setup for testing your actual logic. If you're not testing custom validation, rendering logic, or business rules, you probably don't need the test.

2. **Test Naming**: Use descriptive test names that explain what is being tested

    ```php
    it('renders hero component with correct title and description', function () {
        // ...
    });
    ```

3. **Single Assertion Per Test**: When possible, test one thing at a time

    ```php
    it('has a title', function () {
        expect($component->title)->not->toBeNull();
    });

    it('has a description', function () {
        expect($component->description)->not->toBeNull();
    });
    ```

4. **Use Datasets for Similar Tests**: Reduce code duplication with datasets

    ```php
    it('validates input', function ($input, $expected) {
        expect(validate($input))->toBe($expected);
    })->with([
        ['valid', true],
        ['invalid', false],
    ]);
    ```

5. **Arrange-Act-Assert Pattern**: Structure tests clearly

    ```php
    it('creates a user', function () {
        // Arrange
        $data = ['name' => 'John', 'email' => 'john@example.com'];

        // Act
        $user = createUser($data);

        // Assert
        expect($user->name)->toBe('John');
        expect($user->email)->toBe('john@example.com');
    });
    ```

6. **Clean Up After Tests**: Use `afterEach()` or `afterAll()` to clean up resources

7. **Skip Tests When Needed**: Use `skip()` to temporarily disable tests
    ```php
    it('has a pending feature', function () {
        // Test implementation
    })->skip('Waiting for API changes');
    ```

## Common Issues

### Memory Limit

For large test suites, you may need to increase PHP memory limit:

```bash
php -d memory_limit=512M ./vendor/bin/pest
```

### Xdebug

If tests are slow, check if Xdebug is enabled. Disable it for faster execution:

```bash
php -d xdebug.mode=off ./vendor/bin/pest
```

## Additional Resources

- Official Pest Documentation: https://pestphp.com
- Craft specific Documentation: https://craft-pest.com
- Expectation API: https://pestphp.com/docs/expectations
