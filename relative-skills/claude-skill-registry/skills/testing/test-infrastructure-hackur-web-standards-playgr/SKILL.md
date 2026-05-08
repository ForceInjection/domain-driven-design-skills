---
name: Test Infrastructure
description: Reusable test traits, base test cases, and 46 helper methods from tests/Support/ for efficient test authoring
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
---

# Test Infrastructure

Use PCR Card's comprehensive test infrastructure with 46 reusable methods across 5 traits and 2 base test cases.

## When to Use

- Writing new PHPUnit tests
- Writing new Dusk browser tests
- Using test helpers (CreatesUsers, CreatesSubmissions, etc.)
- Making assertions on states, payments, relationships
- Testing Nova resources or API endpoints

## Quick Commands

```bash
# Unit tests (fast, no browser)
./scripts/dev.sh test
./vendor/bin/sail artisan test --testsuite=Unit

# Feature tests
./vendor/bin/sail artisan test --testsuite=Feature

# Browser tests (headed Chrome)
./scripts/dev.sh visible-test
./scripts/dev.sh visible-test tests/Browser/PaymentFlowTest.php

# Specific test
./scripts/dev.sh test:file tests/Unit/PromoCodeTest.php
```

## Test Infrastructure Overview

### Location

**Directory**: `tests/Support/`

**Structure**:

```
tests/Support/
├── README.md                    # Comprehensive usage guide (600 lines)
├── Base/
│   ├── NovaTestCase.php        # Nova 5.x test helpers (400 lines)
│   └── ApiTestCase.php         # API testing with Sanctum (506 lines)
└── Traits/
    ├── CreatesUsers.php        # User factory methods (6 methods)
    ├── CreatesSubmissions.php  # Submission factory methods (6 methods)
    ├── CreatesCards.php        # Card factory methods (7 methods)
    ├── AssertsStates.php       # State assertion helpers (14 methods)
    └── AssertsPayments.php     # Payment assertion helpers (13 methods)
```

**Total**: 2,618 lines, 46 reusable methods

## Reusable Traits

### 1. CreatesUsers (6 methods)

Create test users with specific roles and permissions.

```php
use Tests\Support\Traits\CreatesUsers;

class YourTest extends TestCase
{
    use CreatesUsers;

    public function test_example()
    {
        // Create admin user
        $admin = $this->createAdminUser();

        // Create customer user
        $customer = $this->createCustomerUser();

        // Create user with beta access
        $betaUser = $this->createCustomerUser(['beta_activated_at' => now()]);

        // Create verified user
        $verified = $this->createVerifiedUser();

        // Create technician
        $tech = $this->createTechnicianUser();

        // Acting as user
        $this->actingAs($customer);
    }
}
```

**Available Methods**:
- `createAdminUser(array $attributes = [])` - Admin + Technician roles
- `createTechnicianUser(array $attributes = [])` - Technician role only
- `createCustomerUser(array $attributes = [])` - Customer role only
- `createVerifiedUser(array $attributes = [])` - Email verified customer
- `createBetaUser(array $attributes = [])` - Beta access granted
- `createUserWithRole(string $role, array $attributes = [])` - Custom role

### 2. CreatesSubmissions (6 methods)

Create test submissions with various states and configurations.

```php
use Tests\Support\Traits\CreatesSubmissions;

class YourTest extends TestCase
{
    use CreatesSubmissions;

    public function test_example()
    {
        $user = User::factory()->create();

        // Draft submission
        $draft = $this->createDraftSubmission($user);

        // Submitted submission
        $submitted = $this->createSubmittedSubmission($user);

        // Submission with cards
        $withCards = $this->createSubmissionWithCards($user, 5); // 5 cards

        // Submission with specific state
        $received = $this->createSubmissionInState($user, SubmissionState::RECEIVED);

        // Submission with payment
        $paid = $this->createPaidSubmission($user);
    }
}
```

**Available Methods**:
- `createDraftSubmission(User $user, array $attributes = [])` - Draft state
- `createSubmittedSubmission(User $user, array $attributes = [])` - Submitted state
- `createSubmissionWithCards(User $user, int $count, array $attributes = [])` - With cards
- `createSubmissionInState(User $user, string $state, array $attributes = [])` - Custom state
- `createPaidSubmission(User $user, array $attributes = [])` - With payment
- `createSubmissionWithServices(User $user, array $serviceCodes)` - Specific services

### 3. CreatesCards (7 methods)

Create test cards (SubmissionTradingCard) with states and images.

```php
use Tests\Support\Traits\CreatesCards;

class YourTest extends TestCase
{
    use CreatesCards;

    public function test_example()
    {
        $submission = Submission::factory()->create();

        // Card with specific state
        $card = $this->createCardInState($submission, CardState::ASSESSMENT);

        // Card with images
        $withImages = $this->createCardWithImages($submission, 4); // 4 images

        // Multiple cards
        $cards = $this->createCardsForSubmission($submission, 3); // 3 cards

        // Card with damage assessment
        $damaged = $this->createCardWithDamage($submission, 'scratch', 'severe');
    }
}
```

**Available Methods**:
- `createCardInState(Submission $submission, string $state, array $attributes = [])` - Custom card state
- `createCardWithImages(Submission $submission, int $count, array $attributes = [])` - With images
- `createCardsForSubmission(Submission $submission, int $count)` - Multiple cards
- `createCardWithDamage(Submission $submission, string $type, string $severity)` - Damage assessment
- `createCardInProgress(Submission $submission)` - In-progress state
- `createCardCompleted(Submission $submission)` - Completed state
- `createCardCancelled(Submission $submission)` - Cancelled state

### 4. AssertsStates (14 methods)

Assert submission and card states cleanly.

```php
use Tests\Support\Traits\AssertsStates;

class YourTest extends TestCase
{
    use AssertsStates;

    public function test_example()
    {
        $submission = Submission::factory()->create();
        $card = SubmissionTradingCard::factory()->create();

        // Assert submission states
        $this->assertSubmissionIsDraft($submission);
        $this->assertSubmissionIsSubmitted($submission);
        $this->assertSubmissionIsReceived($submission);
        $this->assertSubmissionIsCompleted($submission);
        $this->assertSubmissionInState($submission, SubmissionState::ASSESSMENT);
        $this->assertSubmissionInStates($submission, [
            SubmissionState::COMPLETED,
            SubmissionState::SHIPPED,
        ]);

        // Assert card states
        $this->assertCardIsAssessment($card);
        $this->assertCardIsInProgress($card);
        $this->assertCardIsQualityCheck($card);
        $this->assertCardIsCompleted($card);
        $this->assertCardInState($card, CardState::QUALITY_CHECK);
        $this->assertCardInStates($card, [
            CardState::COMPLETED,
            CardState::LABEL_SLAB,
        ]);

        // Terminal state
        $this->assertSubmissionIsTerminal($submission);
        $this->assertCardIsTerminal($card);
    }
}
```

### 5. AssertsPayments (13 methods)

Assert payment states, amounts, and promo codes.

```php
use Tests\Support\Traits\AssertsPayments;

class YourTest extends TestCase
{
    use AssertsPayments;

    public function test_example()
    {
        $submission = Submission::factory()->create();
        $promoCode = PromoCode::factory()->create();

        // Payment status
        $this->assertSubmissionIsPaid($submission);
        $this->assertSubmissionIsUnpaid($submission);
        $this->assertSubmissionHasPaymentIntent($submission);

        // Payment amounts
        $this->assertSubmissionTotalEquals($submission, 10000); // $100.00
        $this->assertSubmissionTotalGreaterThan($submission, 5000);
        $this->assertSubmissionTotalLessThan($submission, 20000);

        // Promo codes
        $this->assertSubmissionHasPromoCode($submission, $promoCode);
        $this->assertSubmissionDiscountEquals($submission, 1000); // $10.00

        // Manual payments
        $this->assertSubmissionHasManualPayment($submission);
        $this->assertManualPaymentVerified($manualPayment);
        $this->assertManualPaymentPending($manualPayment);

        // Price changes
        $this->assertSubmissionHasPriceChangeRequest($submission);
    }
}
```

## Base Test Cases

### NovaTestCase (400 lines)

Test Nova resources with authentication and helpers.

```php
use Tests\Support\Base\NovaTestCase;

class YourNovaTest extends NovaTestCase
{
    public function test_can_view_resource()
    {
        $this->actingAsAdmin();

        $response = $this->get('/nova-api/submissions');

        $response->assertStatus(200);
    }

    public function test_can_create_resource()
    {
        $this->actingAsAdmin();

        $response = $this->postJson('/nova-api/submissions', [
            'submission_number' => 'SUB-123',
            'user_id' => 1,
        ]);

        $response->assertCreated();
    }
}
```

**Available Methods**:
- `actingAsAdmin()` - Authenticate as admin
- `actingAsTechnician()` - Authenticate as technician
- `actingAsCustomer()` - Authenticate as customer
- Nova-specific assertion helpers

### ApiTestCase (506 lines)

Test API endpoints with Sanctum authentication.

```php
use Tests\Support\Base\ApiTestCase;

class YourApiTest extends ApiTestCase
{
    public function test_authenticated_request()
    {
        $user = $this->createAuthenticatedUser();

        $response = $this->getJson('/api/submissions', [
            'Authorization' => 'Bearer ' . $user->token,
        ]);

        $response->assertOk();
    }

    public function test_api_validation()
    {
        $user = $this->createAuthenticatedUser();

        $response = $this->postJson('/api/submissions', [
            // Missing required fields
        ], [
            'Authorization' => 'Bearer ' . $user->token,
        ]);

        $response->assertUnprocessable();
    }
}
```

**Available Methods**:
- `createAuthenticatedUser(array $attributes = [])` - User with Sanctum token
- `createApiToken(User $user, array $abilities = ['*'])` - Custom token
- API-specific assertion helpers

## Example Test

### Complete Test Using Infrastructure

```php
<?php

namespace Tests\Unit;

use Tests\TestCase;
use Tests\Support\Traits\CreatesUsers;
use Tests\Support\Traits\CreatesSubmissions;
use Tests\Support\Traits\CreatesCards;
use Tests\Support\Traits\AssertsStates;
use Tests\Support\Traits\AssertsPayments;

class SubmissionWorkflowTest extends TestCase
{
    use CreatesUsers;
    use CreatesSubmissions;
    use CreatesCards;
    use AssertsStates;
    use AssertsPayments;

    public function test_complete_submission_workflow()
    {
        // 1. Create customer
        $customer = $this->createCustomerUser();

        // 2. Create draft submission
        $submission = $this->createDraftSubmission($customer);
        $this->assertSubmissionIsDraft($submission);

        // 3. Add cards
        $cards = $this->createCardsForSubmission($submission, 3);
        $this->assertCount(3, $submission->cards);

        // 4. Transition to submitted
        $submission->state->transitionTo(SubmissionState::SUBMITTED);
        $this->assertSubmissionIsSubmitted($submission);

        // 5. Process payment
        // ... payment logic
        $this->assertSubmissionIsPaid($submission);

        // 6. Transition cards to assessment
        foreach ($cards as $card) {
            $card->card_state->transitionTo(CardState::ASSESSMENT);
            $this->assertCardIsAssessment($card);
        }

        // 7. Complete workflow
        $submission->state->transitionTo(SubmissionState::COMPLETED);
        $this->assertSubmissionIsCompleted($submission);
        $this->assertSubmissionIsTerminal($submission);
    }
}
```

## Test Results (October 2025)

**Phase 1-3 Complete**:
- ✅ State constant migration (42 files, 0 remaining errors)
- ✅ Test infrastructure created (2,618 lines, 46 methods)
- ✅ Unit tests improved (69→92 passing, +33%)

**Current Status**:
- Unit Tests: 92 passing, 165 failing
- Test Infrastructure: 8 files, 46 methods
- Documentation: tests/Support/README.md (600 lines)

## Common Patterns

### Testing State Transitions

```php
use Tests\Support\Traits\{CreatesSubmissions, AssertsStates};

public function test_state_transition()
{
    $submission = $this->createDraftSubmission($user);
    $this->assertSubmissionIsDraft($submission);

    $submission->state->transitionTo(SubmissionState::SUBMITTED);
    $this->assertSubmissionIsSubmitted($submission);
}
```

### Testing Payments

```php
use Tests\Support\Traits\{CreatesSubmissions, AssertsPayments};

public function test_payment_flow()
{
    $submission = $this->createSubmittedSubmission($user);
    $this->assertSubmissionIsUnpaid($submission);

    // Process payment
    $submission->update(['payment_status' => 'paid']);

    $this->assertSubmissionIsPaid($submission);
    $this->assertSubmissionTotalEquals($submission, 10000);
}
```

### Testing Nova Resources

```php
use Tests\Support\Base\NovaTestCase;

class SubmissionResourceTest extends NovaTestCase
{
    public function test_index()
    {
        $this->actingAsAdmin();

        $response = $this->get('/nova-api/submissions');

        $response->assertOk();
    }
}
```

## Documentation Links

- **Usage Guide**: `tests/Support/README.md` (600 lines, 20+ examples)
- **Testing Guide**: `docs/development/TESTING-COMPREHENSIVE.md`
- **Test Reorganization**: `tests/archived/2025-10-22-test-reorganization/`
- **Laravel Testing**: https://laravel.com/docs/12.x/testing
- **PHPUnit**: https://phpunit.de/documentation.html
