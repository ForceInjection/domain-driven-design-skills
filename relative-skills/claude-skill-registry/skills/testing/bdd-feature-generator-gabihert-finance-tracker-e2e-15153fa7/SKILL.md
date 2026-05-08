---
name: bdd-feature-generator
description: Creates BDD feature files for Golang Clean Architecture projects using Gherkin syntax. Use when users need to write .feature files for integration tests, create test scenarios for APIs, or generate Cucumber/Godog test specifications. Specifically for projects that follow Clean Architecture patterns with existing step definitions.
---

# BDD Feature File Generator

Generate `.feature` files for Golang Clean Architecture projects using established BDD patterns and existing step definitions.

## Critical Constraints

- **ONLY use existing step definitions** - Never create new step definitions
- **Follow exact patterns** from existing feature files
- **All feature files** must be created in `/test/integration/features/`
- **Examine existing features** before creating new ones

## When to Use

Activate this skill when:
- Creating BDD feature files for API testing
- Writing Gherkin scenarios for integration tests
- Generating Cucumber/Godog test specifications
- Developing test scenarios for REST endpoints
- Creating validation test suites
- Setting up database state verification tests
- Testing external API integrations
- Validating event publishing (SNS/SQS)

## Workflow

### 1. Gather Requirements

Ask the user for:
- Feature name and purpose
- API endpoint(s) and methods
- Request/response field structures
- Validation rules needed
- Database tables affected
- External API dependencies
- Events to publish/consume
- Error codes and messages

### 2. Analyze Similar Features

Check existing features in `/test/integration/features/` for:
- Similar endpoint patterns (create, update, list, delete)
- Validation scenario structures
- Error handling patterns
- Database setup approaches

### 3. Generate Feature File

#### File Structure
- Location: `/test/integration/features/feature-name.feature`
- Name: Use kebab-case (e.g., `create-user.feature`)
- Always include: `#language: en` and `#utf-8` headers

#### Background Section
Set up common test prerequisites:
- Clear tables and headers
- Environment variables
- AWS secrets
- External API mocks
- Test data preparation
- Authentication headers

#### Scenarios Structure

**Validation Scenarios** (use Scenario Outline):
- Required field validation (empty string and null)
- Invalid value validation
- Format validation (email, phone, etc.)
- Business rule validation

**Success Scenarios**:
- Minimal required fields
- All fields populated
- Database state verification
- External API call verification
- Event publishing verification

**Error Scenarios**:
- Not found (404)
- Unauthorized (401)
- Forbidden (403)
- Conflict/Duplicate (409)
- Internal errors (500)

### 4. Apply Patterns

#### Error Response Structure
```gherkin
Then the status returned should be 400
And the response should contain the field "error.code" equal to "PREFIX-01400"
And the response should contain the field "error.description" equal to "Bad request"
And the response should contain the field "error.error_details.0.attribute" equal to "<attribute>"
And the response should contain the field "error.error_details.0.messages.0" equal to "<message>"
```

#### Error Code Format
- Pattern: `PREFIX-ERRNUM`
- PREFIX: 3-letter module code (e.g., USR, CLI, ORD)
- ERRNUM: 5-digit number (01400, 01404, etc.)

#### Special Values
- `"not nil"` - Assert non-null/non-empty
- `"nil"` - Assert null/empty
- `null` - JSON null in examples
- `""` - Empty string

#### Tags Convention
- Always include `@all`
- Add feature-specific tag
- Add category tags:
  - `@success`
  - `@error`
  - `@contract_fields_validation`
  - `@response_validation`
  - `@database_validation`
  - `@external_api`
  - `@events`

## Quick Reference

### Step Definitions
For complete step definitions, see: [references/step-definitions.md](references/step-definitions.md)

Key categories:
- **Given**: Environment setup, database state, API mocks
- **When**: HTTP requests, event processing
- **Then**: Response validation, database checks, event verification

### Patterns & Examples
For detailed patterns, see: [references/patterns-examples.md](references/patterns-examples.md)

Includes:
- Complete feature file structure
- Common scenario patterns
- Error handling examples
- Naming conventions

### Template
Use the template at: [assets/feature-template.feature](assets/feature-template.feature)

Copy and customize for new features.

## Examples

### Create Entity Feature
```gherkin
@all @create_entity
Feature: Create entity functionality

  Background:
    Given the tables are empty
    And the header is empty
    And the "API_KEY" env var is set to "test-key"

  @create_entity @contract_fields_validation
  Scenario Outline: Create entity failure - bad request
    When I call "POST" "/v1/entities" with the following payload
    """
    {
        "name": <n>,
        "type": <type>
    }
    """
    Then the status returned should be 400
    And the response should contain the field "error.code" equal to "ENT-01400"
    And the response should contain the field "error.error_details.0.attribute" equal to "<attribute>"
    And the response should contain the field "error.error_details.0.messages.0" equal to "<message>"

    Examples:
      | name    | type    | attribute | message                    |
      | ""      | "valid" | name      | REQUIRED_ATTRIBUTE_MISSING |
      | null    | "valid" | name      | REQUIRED_ATTRIBUTE_MISSING |
      | "valid" | ""      | type      | REQUIRED_ATTRIBUTE_MISSING |
```

### List with Pagination
```gherkin
@all @list_entities
Feature: List entities functionality

  @list_entities @pagination
  Scenario: List entities with pagination
    Given the "entities" exists
    """
    [
      {"id": "1", "name": "Entity 1"},
      {"id": "2", "name": "Entity 2"},
      {"id": "3", "name": "Entity 3"}
    ]
    """
    When I call "GET" "/v1/entities?page_size=2&page=1"
    Then the status returned should be 200
    And the response should contain the field "items" array length equal to 2
    And the response should contain the field "pagination.total" equal to "3"
```

## Best Practices

1. **Start with validation scenarios** - Use Scenario Outline for multiple test cases
2. **Test edge cases** - Empty strings, null values, invalid formats
3. **Verify database state** - Check records were created/updated correctly
4. **Mock external dependencies** - Use Given steps for API mocks
5. **Follow naming conventions** - Consistent scenario names and file naming
6. **Reuse patterns** - Copy from similar existing features
7. **Keep scenarios focused** - One concept per scenario
8. **Use meaningful test data** - Realistic values, not "test123"

## Important Notes

- Never create new step definitions - work within existing ones
- Always check `/test/integration/features/` for similar features first
- Maintain consistency with existing error codes and response structures
- Feature files are created BEFORE implementation code
- Use the exact step definition syntax - no variations allowed
