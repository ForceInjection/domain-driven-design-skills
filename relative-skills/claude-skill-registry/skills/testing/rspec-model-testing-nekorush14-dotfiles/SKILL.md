---
name: rspec-model-testing
description: Write RSpec tests for ActiveRecord models including validations, associations, scopes, and model methods. Use when testing model behavior, data integrity rules, or creating model specs following TDD.
---

# RSpec Model Testing Specialist

Specialized in writing comprehensive model specs for ActiveRecord models.

## When to Use This Skill

- Testing model validations (presence, format, uniqueness)
- Testing model associations (belongs_to, has_many, has_one)
- Testing scopes and query methods
- Testing model instance and class methods
- Testing callbacks
- Creating model specs before implementation (TDD)

## Core Principles

- **Test First**: Write model specs before implementing model logic
- **Comprehensive Coverage**: Test all validations, associations, and methods
- **Edge Cases**: Test boundary conditions and error cases
- **Independence**: Each test should be independent
- **Clear Intent**: Test names describe expected behavior

## Model Spec Structure

```ruby
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
    describe 'validations' do
        # Validation tests
    end

    describe 'associations' do
        # Association tests
    end

    describe 'scopes' do
        # Scope tests
    end

    describe 'instance methods' do
        # Instance method tests
    end

    describe 'class methods' do
        # Class method tests
    end

    describe 'callbacks' do
        # Callback tests
    end
end
```

## Testing Validations

### Using Shoulda Matchers

```ruby
describe 'validations' do
    # Presence
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:name) }

    # Uniqueness
    it { should validate_uniqueness_of(:email).case_insensitive }

    # Length
    it { should validate_length_of(:password).is_at_least(8) }
    it { should validate_length_of(:username).is_at_most(20) }

    # Format
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid').for(:email) }

    # Numericality
    it { should validate_numericality_of(:age).is_greater_than(0) }
end
```

### Custom Validation Tests

```ruby
describe 'validations' do
    it 'validates email format' do
        user = build(:user, email: 'invalid')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include('is invalid')
    end

    it 'validates password complexity' do
        user = build(:user, password: 'simple')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('must include uppercase, lowercase, and number')
    end

    it 'is valid with valid attributes' do
        user = build(:user)
        expect(user).to be_valid
    end

    it 'is invalid without email' do
        user = build(:user, email: nil)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("can't be blank")
    end
end
```

## Testing Associations

### Using Shoulda Matchers

```ruby
describe 'associations' do
    it { should belong_to(:organization) }
    it { should have_many(:posts).dependent(:destroy) }
    it { should have_many(:comments).through(:posts) }
    it { should have_one(:profile).dependent(:destroy) }
    it { should have_and_belong_to_many(:tags) }
end
```

### Custom Association Tests

```ruby
describe 'associations' do
    it 'deletes associated posts when user is deleted' do
        user = create(:user)
        create_list(:post, 3, user: user)

        expect { user.destroy }.to change(Post, :count).by(-3)
    end

    it 'can have multiple comments through posts' do
        user = create(:user)
        post = create(:post, user: user)
        create_list(:comment, 2, post: post)

        expect(user.comments.count).to eq(2)
    end
end
```

## Testing Scopes

```ruby
describe 'scopes' do
    describe '.active' do
        it 'returns only active users' do
            active_user = create(:user, active: true)
            inactive_user = create(:user, active: false)

            expect(User.active).to include(active_user)
            expect(User.active).not_to include(inactive_user)
        end
    end

    describe '.by_role' do
        it 'returns users with specified role' do
            admin = create(:user, role: 'admin')
            guest = create(:user, role: 'guest')

            expect(User.by_role('admin')).to include(admin)
            expect(User.by_role('admin')).not_to include(guest)
        end
    end

    describe '.recent' do
        it 'orders users by creation date descending' do
            old_user = create(:user, created_at: 2.days.ago)
            new_user = create(:user, created_at: 1.day.ago)

            expect(User.recent.first).to eq(new_user)
            expect(User.recent.last).to eq(old_user)
        end
    end
end
```

## Testing Instance Methods

```ruby
describe '#full_name' do
    it 'returns first and last name combined' do
        user = build(:user, first_name: 'John', last_name: 'Doe')
        expect(user.full_name).to eq('John Doe')
    end

    it 'handles missing last name' do
        user = build(:user, first_name: 'John', last_name: nil)
        expect(user.full_name).to eq('John')
    end

    it 'handles missing first name' do
        user = build(:user, first_name: nil, last_name: 'Doe')
        expect(user.full_name).to eq('Doe')
    end
end

describe '#activate!' do
    it 'sets active to true' do
        user = create(:user, active: false)

        expect { user.activate! }
            .to change { user.active }.from(false).to(true)
    end

    it 'sets activated_at timestamp' do
        user = create(:user, active: false)

        expect { user.activate! }
            .to change { user.activated_at }.from(nil)
    end
end
```

## Testing Class Methods

```ruby
describe '.find_by_email_case_insensitive' do
    it 'finds user regardless of email case' do
        user = create(:user, email: 'test@example.com')

        found = User.find_by_email_case_insensitive('TEST@EXAMPLE.COM')
        expect(found).to eq(user)
    end

    it 'returns nil when user not found' do
        found = User.find_by_email_case_insensitive('nonexistent@example.com')
        expect(found).to be_nil
    end
end

describe '.search' do
    it 'finds users by name or email' do
        user1 = create(:user, name: 'John Doe', email: 'john@example.com')
        user2 = create(:user, name: 'Jane Smith', email: 'jane@example.com')

        results = User.search('John')
        expect(results).to include(user1)
        expect(results).not_to include(user2)
    end
end
```

## Testing Callbacks

```ruby
describe 'callbacks' do
    describe 'before_save' do
        it 'normalizes email before saving' do
            user = create(:user, email: 'TEST@EXAMPLE.COM')
            expect(user.email).to eq('test@example.com')
        end

        it 'strips whitespace from name' do
            user = create(:user, name: '  John Doe  ')
            expect(user.name).to eq('John Doe')
        end
    end

    describe 'after_create' do
        it 'sends welcome email after user creation' do
            expect {
                create(:user)
            }.to have_enqueued_job(WelcomeEmailJob)
        end
    end

    describe 'before_destroy' do
        it 'archives user data before destroying' do
            user = create(:user)
            expect(UserArchiveService).to receive(:archive).with(user)
            user.destroy
        end
    end
end
```

## Testing Custom Validators

```ruby
describe 'custom validators' do
    it 'validates business email domain' do
        user = build(:user, email: 'user@gmail.com')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include('must be a company email')
    end

    it 'accepts valid business email' do
        user = build(:user, email: 'user@company.com')
        expect(user).to be_valid
    end
end
```

## Testing Enums

```ruby
describe 'enums' do
    it { should define_enum_for(:status).with_values([:pending, :active, :suspended]) }

    it 'defaults to pending status' do
        user = create(:user)
        expect(user.status).to eq('pending')
    end

    it 'can transition between statuses' do
        user = create(:user, status: :pending)
        user.active!
        expect(user.status).to eq('active')
    end
end
```

## Tools to Use

- `Write`: Create new model spec files
- `Edit`: Update existing model specs
- `Read`: Read model implementation
- `Bash`: Run model specs
- `mcp__serena__find_symbol`: Find model definitions

### Bash Commands

```bash
# Run all model specs
bundle exec rspec spec/models

# Run specific model spec
bundle exec rspec spec/models/user_spec.rb

# Run with documentation format
bundle exec rspec spec/models/user_spec.rb --format documentation
```

## Workflow

1. **Understand Model Requirements**: Clarify expected validations and behavior
2. **Write Failing Tests**: Create specs for all model features
3. **Run Tests**: Confirm tests fail correctly
4. **Commit Tests**: Commit test code
5. **Implementation**: Use `rails-model-design` skill for implementation
6. **Verify Tests Pass**: Run tests after implementation
7. **Refactor**: Improve model and tests if needed

## Related Skills

- `rails-model-design`: For implementing models
- `rails-query-optimization`: For testing query performance
- `rails-state-machines`: For testing state transitions

## RSpec Fundamentals

See [RSpec Testing Fundamentals](../_shared/rspec-testing-fundamentals.md) for matchers, mocking, and structure.

## FactoryBot Guide

See [FactoryBot Guide](../_shared/factory-bot-guide.md) for creating test data.

## TDD Workflow

Follow [TDD Workflow](../_shared/rails-tdd-workflow.md)

## Key Reminders

- Write tests before implementing model logic
- Test all validations comprehensively
- Test associations and dependent behaviors
- Test scopes with real data
- Test callbacks and their side effects
- Use FactoryBot for test data
- Keep tests independent
- Test edge cases and error conditions
- Use shoulda-matchers for common validations
- Run tests frequently during development
