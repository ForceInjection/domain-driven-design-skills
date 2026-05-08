---
name: create-functional-test
description: Create functional test for HTTP controllers and LiveComponents. Use when testing web endpoints, form submissions, API responses, or LiveComponent interactions. Tests make HTTP requests and verify responses/DOM.
---

# Create Functional Test

Generate functional test for HTTP controllers and LiveComponents.

---

## When to Use

- HTTP endpoints (GET/POST/PUT/DELETE)
- Form submissions
- LiveComponents
- API responses

---

## Inputs/Outputs

| Input | Example | Output |
|-------|---------|--------|
| controller_class | GetArticlesController | `BC/Tests/Adapters/Controller/.../ControllerNameTest.php` |
| route | /admin/articles | - |
| method | GET, POST | - |
| fixtures | ['ArticleFactory' => 5] | - |

---

## Process

| Step | Action |
|------|--------|
| **Create** | Use template: `test-functional.php.tpl` |
| **Run** | `php bin/phpunit path/to/Test.php` |
| **Validate** | `make cs-fixer && make stan && make ta` |

---

## Structure

**Functional Test** (extends `BaseFunctionalTestCase`):
```php
final class ControllerNameTest extends BaseFunctionalTestCase {
    use Factories;

    public function testMethodName(): void {
        // Setup with Foundry (auto-persists)
        EntityFactory::createOne(['name' => 'Test']);

        // Request (use $this->client, NOT static::createClient())
        $this->client->request('GET', '/route');

        // Assertions
        self::assertResponseIsSuccessful();
        self::assertSelectorExists('.element');
    }
}
```

**See**: `docs/GLOSSARY.md#functional-test` for detailed definition

---

## Rules

**Setup**:
- Use Foundry (NOT DataBuilder)
- Foundry auto-persists and commits
- NO manual `repository->save()` or `$em->flush()`

**Assertions**:
- HTTP: `assertResponseIsSuccessful()`, `assertResponseRedirects()`, `assertResponseStatusCodeSame(404)`
- DOM: `assertSelectorExists('.class')`, `assertSelectorTextContains('h1', 'Title')`, `assertSelectorCount(3, '.item')`

**CRITICAL**:
- Use `$this->client` (NOT `static::createClient()`)
- Extends `BaseFunctionalTestCase`
- Use trait `Factories`
- Performance: ~550ms/test (DB purge + HTTP request)

---

## Templates

- `test-functional.php.tpl`

**Location**: `.claude/templates/`

---

## References

- Functional test definition: `docs/GLOSSARY.md#functional-test`
- Testing strategy: `docs/testing.md#functional`
- Base test case: `src/Shared/Tests/BaseFunctionalTestCase.php`
