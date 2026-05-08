---
name: test-case-designer
description: Designs comprehensive test cases for PHP/CakePHP applications, categorizing them into unit, integration, and system tests with proper documentation format
---

# Test Case Designer

A specialized skill for designing test cases that ensure comprehensive coverage of requirements and functionality in PHP/CakePHP applications.

## Core Responsibilities

### 1. Test Case Structure

**Standard Test Case Format:**
```yaml
Test Case:
  id: TC-[number]
  requirement_id: REQ-[number]
  type: unit|integration|system|e2e
  priority: high|medium|low

  description: [What is being tested]

  preconditions:
    - [Required setup]
    - [Initial state]

  test_steps:
    1. [Action to perform]
    2. [Next action]

  expected_results:
    - [Expected outcome]
    - [Verification point]

  postconditions:
    - [Cleanup needed]
    - [State after test]

  test_data:
    - [Required test data]
```

### 2. Test Categorization

**Unit Tests:**
```php
/**
 * 単体テスト設計
 *
 * 対象: Individual methods/functions
 * 目的: Logic verification in isolation
 * モック: External dependencies
 */
Unit Test Criteria:
  - Single class/method focus
  - No database access
  - No external API calls
  - Fast execution (< 100ms)
  - Deterministic results
```

**Integration Tests:**
```php
/**
 * 結合テスト設計
 *
 * 対象: Component interactions
 * 目的: Verify integrations work
 * 実行: With real dependencies
 */
Integration Test Criteria:
  - Multiple components
  - Database interactions
  - Service integrations
  - Realistic scenarios
```

**System Tests:**
```php
/**
 * システムテスト設計
 *
 * 対象: End-to-end workflows
 * 目的: Full feature validation
 * 環境: Production-like
 */
System Test Criteria:
  - Complete user workflows
  - All components integrated
  - Performance validation
  - Security verification
```

### 3. CakePHP Test Format

**PHPUnit Test Structure:**
```php
/**
 * [機能名]のテスト
 *
 * 保証対象:
 * 1. [具体的な保証内容1]
 * 2. [具体的な保証内容2]
 * 失敗時の損失:
 * - [ビジネスへの影響]
 * - [ユーザーへの影響]
 */
public function test[MethodName](): void
{
    // Arrange (準備)
    // テストデータのセットアップ

    // Act (実行)
    // テスト対象の実行

    // Assert (検証)
    // 結果の確認
}
```

### 4. Test Case Design Patterns

**Boundary Value Analysis:**
```yaml
Input: age (1-120)
Test Cases:
  - TC-001: age = 0 (below minimum)
  - TC-002: age = 1 (minimum)
  - TC-003: age = 60 (typical)
  - TC-004: age = 120 (maximum)
  - TC-005: age = 121 (above maximum)
```

**Equivalence Partitioning:**
```yaml
Input: user_type
Partitions:
  - admin: Full access
  - user: Limited access
  - guest: Read-only

Test Cases:
  - TC-001: Admin can delete
  - TC-002: User cannot delete
  - TC-003: Guest cannot modify
```

**State Transition:**
```yaml
States: draft → submitted → approved → completed

Test Cases:
  - TC-001: draft to submitted (valid)
  - TC-002: draft to approved (invalid)
  - TC-003: approved to submitted (invalid)
  - TC-004: approved to completed (valid)
```

### 5. Test Documentation Template

```markdown
# Test Design Document: [Feature]

## Test Scope
### In Scope
- [What will be tested]

### Out of Scope
- [What won't be tested]

## Test Strategy
### Unit Tests
| Test ID | Description | Type | Priority |
|---------|-------------|------|----------|
| UT-001 | Validate email format | Unit | High |
| UT-002 | Calculate order total | Unit | High |

### Integration Tests
| Test ID | Description | Components | Priority |
|---------|-------------|------------|----------|
| IT-001 | User login flow | Auth + DB | High |
| IT-002 | Order processing | Order + Payment | High |

### System Tests
| Test ID | Description | Workflow | Priority |
|---------|-------------|----------|----------|
| ST-001 | Complete purchase | End-to-end | High |
| ST-002 | User registration | Full flow | Medium |

## Test Data Requirements
### Database State
- Users: 10 test users with various roles
- Products: 50 test products
- Orders: 100 test orders in various states

### Test Fixtures
```php
protected $fixtures = [
    'app.Users',
    'app.Products',
    'app.Orders',
    'app.OrderItems'
];
```

## Risk-Based Testing
### High Risk Areas
- Payment processing
- User authentication
- Data security

### Medium Risk Areas
- Reporting features
- Email notifications

### Low Risk Areas
- Static content display
- Help documentation
```

## Test Case Generation Process

### Step 1: Requirement Analysis
```
For each requirement:
1. Identify testable conditions
2. Determine test type needed
3. Define success criteria
4. Identify edge cases
```

### Step 2: Test Case Creation
```
For each condition:
1. Create positive test case (happy path)
2. Create negative test cases (error paths)
3. Create boundary test cases
4. Create performance test cases (if applicable)
```

### Step 3: Test Data Design
```
For each test case:
1. Define input data
2. Define expected output
3. Define database state
4. Define external dependencies
```

### Step 4: Test Prioritization
```
Priority Matrix:
         Impact
        High  Low
Risk High  P1   P2
     Low   P2   P3

P1: Must test (blocking)
P2: Should test (important)
P3: Could test (nice to have)
```

## CakePHP Specific Test Cases

### Controller Tests
```php
/**
 * Controller action test template
 */
public function testIndex(): void
{
    // 保証対象1: 認証が必要
    $this->get('/users');
    $this->assertRedirect('/login');

    // 保証対象2: 認証後アクセス可能
    $this->session(['Auth.User.id' => 1]);
    $this->get('/users');
    $this->assertResponseOk();

    // 保証対象3: データ表示
    $this->assertResponseContains('User List');
}
```

### Model Tests
```php
/**
 * Model validation test template
 */
public function testValidation(): void
{
    // 保証対象1: 必須フィールド
    $user = $this->Users->newEmptyEntity();
    $user = $this->Users->patchEntity($user, []);
    $this->assertFalse($this->Users->save($user));
    $this->assertNotEmpty($user->getErrors());

    // 保証対象2: 正常データ
    $user = $this->Users->patchEntity($user, [
        'email' => 'test@example.com',
        'password' => 'SecurePass123'
    ]);
    $this->assertTrue($this->Users->save($user));
}
```

### Component Tests
```php
/**
 * Component behavior test template
 */
public function testComponentMethod(): void
{
    // 保証対象1: 正常系
    $result = $this->Component->process($validData);
    $this->assertTrue($result);

    // 保証対象2: 異常系
    $result = $this->Component->process($invalidData);
    $this->assertFalse($result);
}
```

## Test Coverage Criteria

### Code Coverage Targets
```yaml
Minimum Coverage:
  - Unit Tests: 80%
  - Integration Tests: 60%
  - Overall: 70%

Critical Components:
  - Authentication: 95%
  - Payment Processing: 95%
  - Data Validation: 90%
```

### Requirement Coverage
```yaml
Functional Requirements:
  - All MUST requirements: 100%
  - All SHOULD requirements: 80%
  - All COULD requirements: 50%

Non-Functional Requirements:
  - Performance: All critical paths
  - Security: All auth points
  - Usability: Key workflows
```

## Output Examples

### Example 1: Login Test Design
```yaml
Test Suite: User Authentication

Unit Tests:
  - UT-001: Password hashing algorithm
  - UT-002: Token generation
  - UT-003: Session validation

Integration Tests:
  - IT-001: Database authentication
  - IT-002: LDAP authentication
  - IT-003: OAuth authentication

System Tests:
  - ST-001: Complete login flow
  - ST-002: Password reset flow
  - ST-003: Two-factor authentication
```

### Example 2: Order Processing Test Design
```yaml
Test Suite: Order Management

Unit Tests:
  - UT-001: Calculate item total
  - UT-002: Apply discount rules
  - UT-003: Validate inventory

Integration Tests:
  - IT-001: Create order with payment
  - IT-002: Update inventory on order
  - IT-003: Send order notifications

System Tests:
  - ST-001: Complete purchase workflow
  - ST-002: Order cancellation workflow
  - ST-003: Return/refund workflow
```

## Best Practices

1. **Test Early**: Design tests with requirements
2. **Test Independence**: Each test should run standalone
3. **Clear Naming**: Test names describe what they test
4. **One Assert**: One logical assertion per test
5. **Fast Feedback**: Prioritize fast-running tests
6. **Maintainable**: Keep tests simple and readable

Remember: Good test design catches bugs before they reach production.