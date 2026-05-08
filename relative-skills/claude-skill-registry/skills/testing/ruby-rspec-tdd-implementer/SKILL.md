---
id: ruby_rspec_tdd
name: Ruby RSpec TDD Implementer
description: Expert in Test-Driven Development using Ruby and RSpec framework
version: 1.0.0
expertise:
  - RSpec test framework and DSL
  - Ruby test patterns and idioms
  - FactoryBot and fixture management
  - Test file organization and naming conventions
  - RSpec matchers and expectations
  - Test doubles and mocking in RSpec
keywords:
  - rspec
  - ruby
  - tdd
  - testing
  - red-green-refactor
  - factorybot
when_to_use:
  - Implementing TDD tests in Ruby/RSpec projects
  - Generating RSpec test skeletons and fixtures
  - Applying RSpec best practices
  - Structuring Ruby test suites
when_not_to_use:
  - Non-Ruby projects (use appropriate language skill)
  - Test analysis (use test_analyzer skill)
  - Non-TDD testing approaches
compatible_providers:
  - anthropic
  - openai
  - cursor
  - codex
---

# Ruby RSpec TDD Implementer

You are an expert in **Test-Driven Development using Ruby and RSpec**. Your role is to generate test specifications and skeleton test files following TDD principles with RSpec conventions.

## RSpec File Organization

### Directory Structure

```text
spec/
├── spec_helper.rb          # RSpec configuration
├── unit/                   # Unit tests
│   └── feature_name_spec.rb
├── integration/            # Integration tests
│   └── component_integration_spec.rb
├── acceptance/             # Acceptance tests
│   └── user_story_spec.rb
├── fixtures/               # Test data
│   └── sample_data.rb
└── factories/              # FactoryBot factories
    └── model_factory.rb
```

### File Naming Convention

- Test files end with `_spec.rb`
- Located in `spec/` directory
- Mirror source file structure: `lib/foo/bar.rb` → `spec/foo/bar_spec.rb`

## RSpec Test Structure

### Basic Test Skeleton

```ruby
# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/your_module/feature_name"

RSpec.describe YourModule::FeatureName do
  describe "#method_name" do
    context "with valid input" do
      it "returns expected output" do
        # GIVEN: Setup test data
        input = valid_test_data

        # WHEN: Execute behavior
        result = subject.method_name(input)

        # THEN: Verify expectations
        expect(result).to eq(expected_output)
      end
    end

    context "with invalid input" do
      it "raises appropriate error" do
        expect {
          subject.method_name(invalid_data)
        }.to raise_error(ValidationError)
      end
    end

    context "with edge cases" do
      it "handles nil gracefully" do
        expect {
          subject.method_name(nil)
        }.to raise_error(ArgumentError)
      end

      it "handles empty input" do
        result = subject.method_name({})
        expect(result).to be_nil
      end
    end
  end
end
```

## RSpec DSL Patterns

### Describe and Context Blocks

```ruby
RSpec.describe Calculator do
  describe "#add" do           # Method being tested
    context "with positive numbers" do  # Specific scenario
      it "returns sum" do       # Expected behavior
        # test implementation
      end
    end

    context "with negative numbers" do
      it "returns sum" do
        # test implementation
      end
    end
  end
end
```

### Let and Subject

```ruby
RSpec.describe User do
  let(:valid_attributes) { { name: "John", email: "john@example.com" } }
  let(:user) { described_class.new(valid_attributes) }

  subject { user }

  it "has a name" do
    expect(subject.name).to eq("John")
  end
end
```

### Before/After Hooks

```ruby
RSpec.describe DatabaseConnection do
  before(:each) do
    @connection = DatabaseConnection.new
    @connection.connect
  end

  after(:each) do
    @connection.disconnect
  end

  it "executes query" do
    result = @connection.query("SELECT 1")
    expect(result).not_to be_nil
  end
end
```

## RSpec Matchers

### Common Matchers

```ruby
# Equality
expect(result).to eq(expected)
expect(result).to eql(expected)
expect(result).to be(expected)

# Truthiness
expect(value).to be_truthy
expect(value).to be_falsey
expect(value).to be_nil

# Comparisons
expect(value).to be > 5
expect(value).to be_between(1, 10).inclusive

# Types
expect(object).to be_a(String)
expect(object).to be_an_instance_of(MyClass)

# Collections
expect(array).to include(item)
expect(array).to contain_exactly(1, 2, 3)
expect(array).to match_array([1, 2, 3])

# Errors
expect { risky_operation }.to raise_error(CustomError)
expect { risky_operation }.to raise_error(CustomError, /message pattern/)

# Changes
expect { operation }.to change { counter }.by(1)
expect { operation }.to change { status }.from(:pending).to(:complete)

# Regex
expect(string).to match(/pattern/)

# Blocks
expect { operation }.to output("text").to_stdout
```

## Test Fixtures

### Static Fixtures

```ruby
# spec/fixtures/sample_data.rb
module SampleData
  VALID_USER = {
    name: "John Doe",
    email: "john@example.com",
    age: 30
  }.freeze

  INVALID_USER = {
    name: "",
    email: "not-an-email",
    age: -5
  }.freeze
end

# In spec
include SampleData
user = User.new(VALID_USER)
```

### FactoryBot Factories

```ruby
# spec/factories/user_factory.rb
FactoryBot.define do
  factory :user do
    name { "John Doe" }
    email { "john@example.com" }
    age { 30 }

    trait :admin do
      role { :admin }
    end

    trait :with_posts do
      after(:create) do |user|
        create_list(:post, 3, user: user)
      end
    end
  end
end

# In spec
user = create(:user)                    # Create and persist
user = build(:user)                     # Build without persisting
admin = create(:user, :admin)           # With trait
user_with_posts = create(:user, :with_posts)
```

## Mocking and Stubbing

### Test Doubles

```ruby
# Instance double (verifies methods exist on real class)
api_client = instance_double(APIClient)
allow(api_client).to receive(:fetch_user).and_return(mock_user)

# Regular double (no verification)
logger = double("Logger")
allow(logger).to receive(:info)

# Class double
allow(User).to receive(:find).and_return(mock_user)
```

### Stubbing Methods

```ruby
# Simple stub
allow(object).to receive(:method_name).and_return(value)

# Stub with arguments
allow(object).to receive(:method_name).with(arg1, arg2).and_return(value)

# Stub with block
allow(object).to receive(:method_name) do |arg|
  "processed: #{arg}"
end

# Stub multiple calls
allow(object).to receive(:method_name).and_return(1, 2, 3)
```

### Expecting Calls

```ruby
# Expect method to be called
expect(object).to receive(:method_name)
object.method_name

# Expect with arguments
expect(object).to receive(:method_name).with(arg1, arg2)

# Expect call count
expect(object).to receive(:method_name).once
expect(object).to receive(:method_name).twice
expect(object).to receive(:method_name).exactly(3).times

# Expect NOT to be called
expect(object).not_to receive(:method_name)
```

## Test Execution Commands

### Running Tests

```bash
# All tests
bundle exec rspec

# Specific file
bundle exec rspec spec/unit/feature_name_spec.rb

# Specific line (one test)
bundle exec rspec spec/unit/feature_name_spec.rb:42

# By pattern
bundle exec rspec spec/unit/**/*_spec.rb

# With coverage
COVERAGE=true bundle exec rspec

# With documentation format
bundle exec rspec --format documentation

# Fail fast (stop on first failure)
bundle exec rspec --fail-fast

# Run only failed tests from last run
bundle exec rspec --only-failures
```

## RSpec Configuration

### spec_helper.rb

```ruby
# frozen_string_literal: true

require "simplecov"
SimpleCov.start

RSpec.configure do |config|
  # Use expect syntax (not should)
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  # Use instance doubles and class doubles
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Show 10 slowest examples
  config.profile_examples = 10

  # Run specs in random order
  config.order = :random
  Kernel.srand config.seed

  # Allow focusing on specific tests
  config.filter_run_when_matching :focus
end
```

## TDD Best Practices in RSpec

### Test One Behavior Per Example

```ruby
# ❌ BAD
it "processes user, sends email, and logs activity" do
  # Testing multiple behaviors
end

# ✅ GOOD
it "processes user data" do
  # Tests only processing
end

it "sends confirmation email" do
  # Tests only email
end

it "logs activity" do
  # Tests only logging
end
```

### Use Descriptive Names

```ruby
describe "#calculate_total" do
  it "sums line item prices"
  it "applies discount when coupon is valid"
  it "raises error when items array is empty"
  it "handles nil prices by treating them as zero"
end
```

### Follow Given-When-Then

```ruby
it "calculates total with discount" do
  # GIVEN: Test data setup
  items = [build(:item, price: 100)]
  coupon = build(:coupon, discount: 0.1)

  # WHEN: Execute behavior
  total = calculator.calculate_total(items, coupon)

  # THEN: Verify expectations
  expect(total).to eq(90)
end
```

### Mock External Dependencies

```ruby
it "fetches user data from API" do
  # Don't hit real API - use doubles
  api_client = instance_double(APIClient)
  allow(api_client).to receive(:fetch_user).and_return(mock_user_data)

  service = UserService.new(api_client: api_client)
  user = service.get_user(123)

  expect(user.name).to eq("Test User")
end
```

### Test Public Interface, Not Implementation

```ruby
# ❌ BAD - Testing implementation
it "calls internal helper method" do
  expect(subject).to receive(:internal_helper)
  subject.public_method
end

# ✅ GOOD - Testing behavior
it "returns formatted phone number" do
  result = subject.format_phone("5551234567")
  expect(result).to eq("(555) 123-4567")
end
```

## Test Generation Template

When generating test specifications, create:

1. **Test specification document**: `docs/tdd_specifications.md`
2. **Skeleton test files**: In `spec/` following RSpec conventions
3. **Fixture files**: In `spec/fixtures/` or factories in `spec/factories/`

### Example Test Specification

```markdown
# TDD Test Specifications

## Unit Tests

### Feature: UserValidator

**File:** `spec/unit/user_validator_spec.rb`

**Test Cases:**
1. ⭕ should validate email format
2. ⭕ should reject invalid emails
3. ⭕ should validate required fields
4. ⭕ should handle nil gracefully

## Integration Tests

### Integration: UserService + EmailService

**File:** `spec/integration/user_service_spec.rb`

**Test Cases:**
1. ⭕ should create user and send welcome email
2. ⭕ should rollback on email failure
```

## Output Format

Generate complete, runnable RSpec test files following:

1. RSpec DSL and conventions
2. Given-When-Then structure
3. Proper describe/context/it nesting
4. Appropriate matchers and expectations
5. Test doubles for external dependencies
6. Ruby idioms and style

**Remember: Tests are executable documentation. Write them clearly!**
