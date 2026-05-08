---
name: rspec-rails
description: Write Ruby on Rails specs with RSpec following best practices for unit tests, request specs, feature specs, and job specs. Use when writing or modifying RSpec test files for Rails applications.
---

# Writing Ruby on Rails Specs with RSpec

When writing RSpec tests for Ruby on Rails applications, follow these guidelines to ensure comprehensive, maintainable, and well-structured test coverage.

## Core Principles

### 1. Test Coverage Strategy

- **No controller tests in most cases** if we have `spec/request` and/or Capybara feature specs that already test the same thing
- **Add a unit test for every new method added** to models, services, and lib classes
- **Test behavior, not implementation** - focus on inputs and outputs
- **Keep tests isolated** - each test should be independent

### 2. File Structure

Organize specs to mirror application structure:

```
spec/
├── models/           # Model unit tests
├── lib/              # Library/service object tests
├── jobs/             # Background job tests
├── features/         # Capybara integration tests
├── requests/         # Request specs (instead of controller specs)
├── factories/        # FactoryBot factories
└── support/          # Test helpers and shared examples
```

## RSpec Structure and Patterns

### Using `subject`

Always use `subject` for the class or method under test. Prefer named subjects
for clarity:

```ruby
# Good - named subject
subject(:fact) do
  described_class.new(
    organization: organization,
    subject: task
  )
end

# Good - simple subject
subject { described_class.new(task) }

# Also acceptable for job specs
subject(:perform_asana_job) do
  AsanaJob.new.perform(sync_record.id)
end
```

### Using `context` Extensively

Use `context` blocks to separate different input states and test scenarios. This
creates clear test organization and makes it easy to understand what's being
tested.

Rules:
- every state in `context` should have a corresponding `let` variable
  inside the `context` block that corresponds to its value.

#### Boolean States

For boolean conditions, always test both states:

```ruby
let(:user) { create(:user, admin: admin_role) }

context 'when user is admin' do
  let(:admin_role) { true }

  it 'allows access to admin panel' do
    # test admin behavior
  end
end

context 'when user is not admin' do
  let(:admin_role) { false }

  it 'denies access to admin panel' do
    # test non-admin behavior
  end
end
```

#### Multiple States

Use context blocks for different scenarios:

```ruby
let(:user) { create(:user, role: role) }

context 'when user is admin' do
  let(:role) { :admin }

  it 'allows access to admin panel' do
    # test admin behavior
  end
end

context 'when user is superadmin' do
  let(:role) { superadmin }

  it 'allows access to admin panel' do
    # test superadmin behavior
  end
end

context 'when user is viewer' do
  let(:role) { viewer }

  it 'denies access to admin panel' do
    # test non-admin behavior
  end
end
```

### Nesting Contexts Reasonably

Nest contexts to represent state changes and dependencies, but don't overdo it. Aim for 2-3 levels maximum in most cases.

```ruby
context 'when post is published' do
  let(:post) { create(:post, status: status) }

  before do
    create(:comment, post: post, author: user)
  end

  it 'sends notification to author' do
    expect(subject.notify).to eq(true)
  end

  context 'when post is later unpublished' do
    before do
      post.update!(published_at: nil)
    end

    it 'does not send further notifications' do
      expect(subject.notify).to eq(false)
    end

    context 'when post is republished' do
      before do
        post.update!(published_at: Time.current)
      end

      it 'resumes sending notifications' do
        expect(subject.notify).to eq(true)
      end
    end
  end
end
```

### Using `describe` for Methods

When unit testing a method, use `describe` with the method name:

```ruby
# For instance methods, use #
describe '#timeline' do
  it 'saves records for each analysis' do
    expect(analyses.timeline(task)).to eq(expected_result)
  end
end

# For class methods, use .
describe '.syncable' do
  it 'returns projects in which membership is not paused' do
    expect(Project.syncable).to match_array([project1, project2])
  end
end

# For ActiveRecord scopes, nest under 'scopes'
describe 'scopes' do
  describe '.with_analyses_and_expected_ordering' do
    it 'returns tasks in the expected order' do
      expect(Task.with_analyses_and_expected_ordering.map(&:name)).to eq(
        [wip_task, previously_wip_task, new_task].map(&:name)
      )
    end
  end
end
```

## Dependency Injection and State

### Prefer Constructor Injection

Prefer state that is injected via constructors when that state is inherent to the class:

```ruby
# Good - state injected in constructor
subject(:fact) do
  described_class.new(
    organization: organization,
    subject: task
  )
end

let(:task) { ... }

# Good - for transformations
subject { described_class.new(task) }
```

### Use `let` for Test Data

Use `let` and `let!` appropriately:
- `let` for lazy-loaded data (only created when referenced)
- `let!` for data that must exist before the test runs, like for testing model
  scopes

```ruby
# Lazy-loaded, created only when referenced
let(:organization) { create(:organization) }
let(:project) { create(:project, id: 101) }

# Created immediately before each test
let!(:previously_wip_task) do
  create(:task, name: 'previously_wip_task').tap do |task|
    create(:analysis, :previously_wip, subject: task)
  end
end
```

## Test Types

### Model Specs

Focus on validations, scopes, and model methods:

```ruby
RSpec.describe Project, type: :model do
  describe 'scopes' do
    describe '#syncable' do
      let!(:project_with_user_membership) { create(:project, :with_user_memberships) }
      let!(:project_without_user_membership) { create(:project, :asana) }

      it 'returns projects with active memberships' do
        expect(Project.syncable).to match_array([project_with_user_membership])
      end
    end
  end
end
```

Rules:
- Don't test validations. That is already tested in Rails itself.

### Feature Specs (Capybara)

Use for end-to-end user flows:

```ruby
RSpec.feature 'UserAuthentication' do
  let(:user) { create(:user) }

  describe 'devise' do
    before do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'
    end

    context 'when user login with existing account' do
      it 'redirects to dashboard page' do
        expect(page).to have_content('People')
      end
    end

    context 'when user logout from session' do
      it 'redirects to login page' do
        click_link 'Sign out'
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end
end
```

### Job Specs

Test background jobs with clear contexts for different commands/states:

```ruby
RSpec.describe NotificationJob do
  subject(:perform_job) do
    NotificationJob.new.perform(notification_id)
  end

  let(:notification) { create(:notification, status: status) }
  let(:notification_id) { notification.id }
  let(:mailer) { instance_double(UserMailer) }

  before do
    allow(UserMailer).to receive(:new).and_return(mailer)
  end

  describe '#perform' do
    context 'when notification is pending' do
      let(:status) { :pending }

      it 'sends email to user' do
        expect(mailer).to receive(:send_notification).with(notification)

        perform_job
        expect(notification.reload).to be_sent
      end
    end

    context 'when notification is already sent' do
      let(:status) { :sent }

      it 'does not send duplicate email' do
        expect(mailer).not_to receive(:send_notification)
        perform_job
      end
    end
  end
end
```

### Library/Service Object Specs

Test domain logic and transformations:

```ruby
RSpec.describe Posts::PublishService do
  subject { described_class.new(post, user) }

  let(:now) { Time.zone.parse('2020-01-01T12:00:00Z') }
  let(:post) { create(:post, :draft, title: title) }
  let(:user) { create(:user, :author) }

  before do
    travel_to(now)
  end

  describe '#publish' do
    context 'when post is valid' do
      let(:title) { 'My Blog Post' }

      it 'sets published_at timestamp' do
        expect do
          subject.publish
        end.to change { post.reload.published_at }.from(nil).to(now)
      end

      it 'creates an audit log entry' do
        expect do
          subject.publish
        end.to change { AuditLog.count }.by(1)
      end
    end

    context 'when post is missing required fields' do
      let(:title) { nil }

      it 'does not publish the post' do
        expect do
          subject.publish
        end.not_to change { post.reload.published_at }
      end
    end
  end
end
```

## Best Practices

### Time Travel

Use `travel_to` for time-dependent tests:

```ruby
# Bad - setting values inline which makes harder to read
before do
  travel_to(Time.zone.parse('2020-01-01 12:00:00'))
end

# Good - setting values as reusable let
let(:now) { '2020-01-01 12:00:00' }

before do
  travel_to(Time.zone.parse(now))
end
```

### Expectations

- Use `expect().to` syntax, never `should`
- Be specific with matchers: `match_array`, `eq`, `be_present`, `be_blank`
- Test both positive and negative cases
- Use `change` matcher for state changes
- Prefer `eq` over `be`. Make tests explicit.

```ruby
# Good - specific matcher
expect(Project.syncable).to match_array([project1, project2])

# Good - testing state change
expect do
  subject.transform
end.to change { task.reload.events.count }.by(1)

# Good - testing error
expect { perform_asana_job }.to raise_error StandardError
```

### Mocking and Stubbing

Create test doubles for external dependencies:

```ruby
let(:client) { instance_double(::Asana::Client) }

before do
  allow(::Asana::Client).to receive(:new).and_return(client)
  expect(stub(Piezo::Asana::Tasks, client: client))
    .to receive(:import_all)
    .with(remote_project_id: syncable.remote_id)
end
```

Rules:
- ALWAYS use `instance_double` or `class_double` for test doubles over
  `double` or `mock`

### Comments

Add explanatory comments when the test setup or behavior needs context:

```ruby
# Notice we didn't have an initial event, only when the user removed
# the task from the WIP section.
context 'when user moves the task out of the WIP section' do
  # ...
end

# Specific ids to avoid matching with other model ids
let(:project) { create(:project, id: 101) }
```

Rules:
- use comments sparingly, and focus on WHY, not WHAT

### Factory Usage

Use factories with traits and overrides for better description of values:

```ruby
# Basic factory
let(:user) { create(:user) }

# With traits
let(:project) { create(:project, :with_user_memberships) }
let(:analysis) { create(:analysis, :previously_wip, subject: task) }

# With overrides
let(:task) do
  create(
    :task,
    remote_created_at: Time.parse('2020-01-01T10:00:00Z'),
    workspace: project.workspace
  )
end

# Building associations
let!(:task) do
  create(:task, name: 'task_name').tap do |task|
    create(:analysis, :wip, subject: task)
  end
end
```

## Workflow

When writing specs:

1. **Start with the describe block** for the class under test
2. **Define subject** - what you're testing
3. **Set up let blocks** for test data
4. **Use contexts** to separate different scenarios
5. **Write descriptive test names** that explain the expected behavior
6. **Test edge cases** - empty collections, nil values, boundary conditions
7. **Keep tests focused** - one assertion per test when possible
8. **Run tests frequently** to ensure they pass

## Common Patterns

### Testing Idempotency

```ruby
expect do
  subject.transform
  subject.transform # idempotent
end.to change { task.reload.events.count }.by(1)
```

### Testing Scopes with Multiple States

```ruby
let!(:active_record) { create(:record, :active) }
let!(:inactive_record) { create(:record, :inactive) }

it 'returns only active records' do
  expect(Record.active).to match_array([active_record])
end
```

### Testing Complex State Transitions

```ruby
context 'when transitioning from state A to state B' do
  before do
    # Set up state A
  end

  context 'when condition X is true' do
    # Nested context for specific transition scenario
  end

  context 'when condition X is false' do
    # Alternative scenario
  end
end
```

Remember: Write tests that are clear, focused, and maintainable. Future
developers (including yourself) should be able to understand what's being tested
and why just by reading the test structure.
