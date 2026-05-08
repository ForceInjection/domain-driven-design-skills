---
name: create-use-case
description: Create a new business use case (Request + UseCase + Test) following TDD workflow. Use when user asks to implement new business logic, domain operations, or create commands/queries. Always follow Red-Green-Refactor cycle.
---

# Create Use Case

Generate Request, UseCase, and Test following TDD workflow.

**IMPORTANT**: Always uses `tdd-workflow` skill (MANDATORY)

---

## When to Use

- New business logic
- Domain operations
- Commands (Create, Update, Delete, Rename)
- Queries (Find, List, Search)

---

## Inputs/Outputs

| Input | Example | Output |
|-------|---------|--------|
| bc | Admin | `BC/UseCases/Entity/ActionEntity/` |
| entity | Article | `ActionEntity.php` (UseCase) |
| action | Rename | `ActionEntityRequest.php` (Request) |
| fields | ['name'] | `ActionEntityTest.php` (Test) |

---

## Process

**Follow**: `.claude/skills/tdd-workflow/` (MANDATORY)

| Phase | File | Template |
|-------|------|----------|
| **RED** | Test.php | `.claude/templates/test-unit.php.tpl` |
| **GREEN** | Request.php + UseCase.php | `.claude/templates/request.php.tpl`, `use-case.php.tpl` |
| **REFACTOR** | - | `make cs-fixer && make stan && make ta` |
| **VALIDATE** | - | `make qa` |

---

## Structures

**Request** (interface):
```php
interface ActionEntityRequest {
    public function uuid(): ResourceId;
    public function field(): string;
}
```

**UseCase** (`readonly`, single `execute()`):
```php
final readonly class ActionEntity {
    public function __construct(private EntityRepository $repo) {} // OR Finder
    public function execute(ActionEntityRequest $req): ActionEntityResponse {
        // Business logic
        return new ActionEntityResponse($entity);
    }
}
```

**See**: `docs/QUICK_REF.md#usecase-pattern` for complete structure

**Note**: Project uses Request-Response pattern. Symfony Maker `bin/console make:use-case:create <bc> <name>` generates all 3 files (Request, UseCase, Response).

---

## Rules

**Repository vs Finder**:
- Commands (CUD) → Repository
- Queries (R) → Finder

**See**: `docs/GLOSSARY.md#repository-vs-finder`

**Tests**:
- Use DataBuilder (NOT Foundry)
- Mock: `expects()->once()`

---

## Templates

- `test-unit.php.tpl`
- `request.php.tpl`
- `use-case.php.tpl`

**Location**: `.claude/templates/`

---

## References

- TDD workflow: `.claude/skills/tdd-workflow/`
- Quick pattern: `docs/QUICK_REF.md#usecase-pattern`
- Architecture: `docs/architecture.md#usecase`
