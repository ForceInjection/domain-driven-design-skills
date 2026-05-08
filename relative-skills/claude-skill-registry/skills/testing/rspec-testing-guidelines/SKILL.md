---
name: rspec-testing-guidelines
description: RSpec testing patterns, factories, mocks, and test best practices
---

# RSpec Testing Guidelines

## Purpose

Ensure comprehensive, maintainable test coverage using RSpec, FactoryBot, and supporting gems configured for the application.

## When to Use This Skill

- Writing or modifying RSpec tests (model, request, system, etc.)
- Creating or using FactoryBot factories
- Setting up test data or fixtures
- Testing controllers, models, services, or views
- Using shoulda-matchers for cleaner assertions
- Testing Devise authentication flows

## Test Suite Configuration

The app uses:
- **RSpec** for testing framework
- **FactoryBot** for test data
- **SimpleCov** for coverage reporting
- **Shoulda Matchers** for common Rails assertions
- **Capybara + Selenium** for system tests
- **Devise Test Helpers** for authentication

## Quick Start: New Feature Testing Checklist

When adding a new feature:

- [ ] Create factory for new models
- [ ] Write model specs (validations, associations, methods)
- [ ] Write request specs for endpoints
- [ ] Write service/query specs if applicable
- [ ] Write system specs for user flows
- [ ] Verify test coverage with SimpleCov

## Core Testing Principles

### 1. Follow AAA Pattern (Arrange-Act-Assert)

```ruby
RSpec.describe UserRegistrationService do
  describe '#call' do
    # Arrange
    let(:params) { { email: 'test@example.com', password: 'password' } }
    subject(:service) { described_class.new(params) }

    it 'creates a user' do
      # Act
      result = service.call

      # Assert
      expect(result).to be_success
      expect(User.count).to eq(1)
    end
  end
end
```

### 2. Use FactoryBot Effectively

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    name { Faker::Name.name }

    trait :admin do
      role { 'admin' }
    end

    trait :with_posts do
      after(:create) do |user|
        create_list(:post, 3, user: user)
      end
    end
  end
end

# Usage
user = create(:user)                    # Creates and saves
admin = create(:user, :admin)           # With trait
user_with_posts = create(:user, :with_posts)
user_draft = build(:user)               # Builds without saving
attrs = attributes_for(:user)           # Returns hash
```

### 3. Test Behavior, Not Implementation

❌ **Don't** test private methods:
```ruby
# Bad
describe '#normalize_email' do
  it 'downcases email' do
    user.send(:normalize_email)
    expect(user.email).to eq('test@example.com')
  end
end
```

✅ **Do** test public interface:
```ruby
# Good
describe 'email normalization' do
  it 'stores email in lowercase' do
    user = create(:user, email: 'TEST@example.com')
    expect(user.email).to eq('test@example.com')
  end
end
```

### 4. Use Shoulda Matchers for Common Assertions

```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  # Associations
  it { should have_many(:posts) }
  it { should belong_to(:organization) }

  # Validations
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_length_of(:password).is_at_least(8) }

  # Database
  it { should have_db_column(:email).of_type(:string) }
  it { should have_db_index(:email) }
end
```

### 5. Use Contexts for Different Scenarios

```ruby
RSpec.describe UsersController, type: :request do
  describe 'POST /users' do
    context 'when not authenticated' do
      it 'redirects to login' do
        post users_path, params: { user: attributes_for(:user) }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated' do
      before { sign_in create(:user) }

      context 'with valid params' do
        it 'creates a user' do
          expect {
            post users_path, params: { user: attributes_for(:user) }
          }.to change(User, :count).by(1)
        end
      end

      context 'with invalid params' do
        it 'does not create a user' do
          expect {
            post users_path, params: { user: { email: 'invalid' } }
          }.not_to change(User, :count)
        end

        it 'returns unprocessable entity status' do
          post users_path, params: { user: { email: 'invalid' } }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
```

## Test Types and When to Use Them

### Model Specs (`spec/models/`)

Test validations, associations, scopes, and business logic.

```ruby
# spec/models/post_spec.rb
RSpec.describe Post, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:comments) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
  end

  describe 'scopes' do
    describe '.published' do
      let!(:published_post) { create(:post, :published) }
      let!(:draft_post) { create(:post, :draft) }

      it 'returns only published posts' do
        expect(Post.published).to include(published_post)
        expect(Post.published).not_to include(draft_post)
      end
    end
  end

  describe '#publish!' do
    let(:post) { create(:post, :draft) }

    it 'sets published to true' do
      post.publish!
      expect(post).to be_published
    end

    it 'sets published_at' do
      freeze_time do
        post.publish!
        expect(post.published_at).to eq(Time.current)
      end
    end
  end
end
```

### Request Specs (`spec/requests/`)

Test HTTP endpoints, responses, and authentication.

```ruby
# spec/requests/posts_spec.rb
RSpec.describe 'Posts', type: :request do
  let(:user) { create(:user) }

  describe 'GET /posts' do
    it 'returns success' do
      get posts_path
      expect(response).to have_http_status(:success)
    end

    it 'lists posts' do
      posts = create_list(:post, 3, :published)
      get posts_path
      expect(response.body).to include(posts.first.title)
    end
  end

  describe 'POST /posts' do
    context 'when authenticated' do
      before { sign_in user }

      let(:valid_params) do
        { post: attributes_for(:post) }
      end

      it 'creates a post' do
        expect {
          post posts_path, params: valid_params
        }.to change(Post, :count).by(1)
      end

      it 'redirects to the post' do
        post posts_path, params: valid_params
        expect(response).to redirect_to(Post.last)
      end
    end

    context 'when not authenticated' do
      it 'redirects to sign in' do
        post posts_path, params: { post: attributes_for(:post) }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
```

### System Specs (`spec/system/`)

Test complete user flows with JavaScript.

```ruby
# spec/system/user_registration_spec.rb
RSpec.describe 'User Registration', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  it 'allows a user to sign up' do
    visit root_path
    click_link 'Sign Up'

    fill_in 'Email', with: 'newuser@example.com'
    fill_in 'Password', with: 'password123'
    fill_in 'Password confirmation', with: 'password123'
    click_button 'Sign Up'

    expect(page).to have_content('Welcome! You have signed up successfully.')
    expect(page).to have_current_path(root_path)
  end

  it 'shows validation errors' do
    visit new_user_registration_path

    fill_in 'Email', with: 'invalid'
    click_button 'Sign Up'

    expect(page).to have_content('Email is invalid')
  end
end
```

### Service Specs (`spec/services/`)

Test service objects and business logic.

```ruby
# spec/services/order_processor_spec.rb
RSpec.describe OrderProcessor do
  describe '#process' do
    let(:order) { create(:order, :with_items) }
    subject(:processor) { described_class.new(order) }

    context 'with valid order' do
      it 'charges payment' do
        expect(PaymentGateway).to receive(:charge).with(order)
        processor.process
      end

      it 'updates inventory' do
        expect { processor.process }.to change { order.items.first.inventory_count }
      end

      it 'sends confirmation' do
        expect(OrderMailer).to receive(:confirmation).with(order).and_call_original
        processor.process
      end

      it 'returns true' do
        expect(processor.process).to be true
      end
    end

    context 'with payment failure' do
      before do
        allow(PaymentGateway).to receive(:charge).and_raise(PaymentError, 'Card declined')
      end

      it 'returns false' do
        expect(processor.process).to be false
      end

      it 'adds error to order' do
        processor.process
        expect(order.errors[:base]).to include('Card declined')
      end
    end
  end
end
```

## Testing Devise Authentication

```ruby
# In request specs
RSpec.describe 'Protected pages', type: :request do
  describe 'GET /dashboard' do
    context 'when signed in' do
      let(:user) { create(:user) }
      before { sign_in user }

      it 'shows dashboard' do
        get dashboard_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when not signed in' do
      it 'redirects to sign in' do
        get dashboard_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end

# In system specs
RSpec.describe 'User login', type: :system do
  let(:user) { create(:user) }

  it 'allows user to log in' do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    expect(page).to have_content('Signed in successfully')
  end
end
```

## Running Tests

```bash
# All specs
bundle exec rspec

# Specific file
bundle exec rspec spec/models/user_spec.rb

# Specific line
bundle exec rspec spec/models/user_spec.rb:42

# By type
bundle exec rspec spec/models
bundle exec rspec spec/requests
bundle exec rspec spec/system

# With coverage
COVERAGE=true bundle exec rspec
```

## Anti-Patterns

❌ **Don't** use fixtures (use FactoryBot)
❌ **Don't** test framework code (e.g., testing Rails validations work)
❌ **Don't** create tightly coupled tests
❌ **Don't** test multiple things in one test
❌ **Don't** use `before(:all)` (use `before(:each)` or `let`)

## Navigation Guide

- **FactoryBot Patterns** → See `resources/factories.md`
- **Mocking & Stubbing** → See `resources/mocking.md`
- **Test Data Strategies** → See `resources/test-data.md`
- **Coverage & CI** → See `resources/coverage.md`

## Related Skills

- **rails-dev-guidelines** - For implementation patterns to test
- **devise-auth-patterns** - For authentication testing details

---

**Status**: Core skill (~480 lines) | 4 resource files
