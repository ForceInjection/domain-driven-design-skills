---
name: ruby-testing
description: Ruby/RSpec testing guidelines and workflow following project conventions. Use when writing or improving Ruby tests.
allowed-tools: Grep, Glob, Read, Write, Edit, Bash(bundle exec rspec:*), Bash(bin/rspec:*), Bash(rg:*)
---

# Ruby Testing

## Overview

Provides workflow for writing RSpec tests following project conventions: test behavior not implementation, use FactoryBot with traits, separate test phases clearly, and avoid common anti-patterns.

## Core Principles

**Test behavior, not code:**
- Focus on WHAT the code does, not HOW it does it
- Test public interfaces and observable outcomes
- **NEVER test private methods directly**

**Test structure:**
- Setup → Exercise → Verify → Teardown
- Separate phases with blank lines (no phase comments)
- Self-contained tests

## Workflow

### Step 1: Search for Existing Test Files and Factories

Before writing anything:

1. Use Grep to find existing test files:
   ```bash
   rg "describe.*ClassName" spec/
   ```

2. **Search for existing factories** before creating new ones:
   ```bash
   rg "factory.*:model_name" spec/factories/
   ```

3. If factory exists, read it to understand available traits:
   ```ruby
   # Check for traits like :with_user, :published, etc.
   ```

### Step 2: Structure the Test File

**For new specs (APPLIES ONLY TO NEW SPECS):**

```ruby
RSpec.describe ClassName do
  # Define helper methods at top if needed, avoid single line helpers
  def prepare_tester_with_preferences
    user = build(:user, name: "Test")
    build(:preferences, user: )
    # Other repeating operations
  end

  describe "#method_name" do
    context "when condition" do
      it "describes expected behavior" do
        # Test phases here
      end
    end

    context "when different condition" do
      # More tests
    end
  end
end
```

**Conventions for new specs:**
- **NO `let` or `let!`** - define variables directly: `user = build(:user)`
- **NO `before` or `after` hooks** - use named methods instead
- **context naming**: Start with "when" or "with", nested with "and", max 2 levels deep
- **it blocks**: Describe expected behavior clearly
- **For classes with only `#call` or `.call`, omit the method describe block**

**For existing specs:**
- Follow the existing file's patterns (`let`, `before`, etc. are okay if already used)
- Maintain consistency within the file

### Step 3: Write Test - Setup Phase

1. Create test data using FactoryBot with appropriate method:

   **Prefer `build` (default, no DB):**
   ```ruby
   user = build(:user)
   post = build(:post, :published, author: user)
   ```
   Use for: validations, testing unsaved state, before_save callbacks

   **Use `build_stubbed` when you need id/timestamps without DB:**
   ```ruby
   user = build_stubbed(:user)  # Has stubbed id and timestamps
   ```
   Use for: when id needed (URLs, associations), read operations, maximum performance

   **Use `create` only when DB persistence is required:**
   ```ruby
   user = create(:user)  # Persisted to DB
   ```
   Use for: DB queries, counting records, uniqueness validations, actual persistence testing

2. **Use traits** when available (`:published`, `:with_comments`, etc.)

3. **Use only relevant attributes for factories:**
   ```ruby
   # Good
   user = build(:user, email: "test@example.com")

   # Bad - unnecessary attributes
   user = build(:user, email: "test@example.com", name: "John", age: 30)
   ```

4. Stub external dependencies:
   ```ruby
   allow(UserCreator).to receive(:create).and_return(user)
   ```

**Blank line after setup phase**

### Step 4: Write Test - Exercise Phase

Execute the code under test:

```ruby
result = MyService.call(user)
```

**For tests that change data stores** (database, cache), wrap in lambda:

```ruby
action = -> { MyService.call(user) }
```

**Blank line after exercise phase**

### Step 5: Write Test - Verify Phase

**For regular tests:**
```ruby
expect(result).to be_successful
expect(result.value).to eq(expected_value)
```

**For tests with data store changes:**
```ruby
expect(&action).to change(User, :count).by(1)
expect(&action).to change { user.reload.status }.from("pending").to("active")
```

**For verifying method calls - use `have_called`:**
```ruby
# First stub the method
allow(UserCreator).to receive(:create)

# Then call the code
MyService.call

# Then verify with have_called
expect(UserCreator).to have_called(:create).with(email: "test@example.com")
```

**NEVER use:**
- `expect(...).to receive(...)` - use `allow` then `have_called` instead
- `allow_any_instance_of` - stub specific instances instead

**Blank line after verify phase (if teardown exists)**

### Step 6: Review Against Anti-Patterns

Before finishing, check:

- [ ] Not testing private methods
- [ ] Not using `allow_any_instance_of`
- [ ] Not using `expect().to receive` (use `have_called` instead)
- [ ] Phases separated with blank lines
- [ ] No phase comments (setup, exercise, verify should be obvious from structure)
- [ ] Using existing factories (searched before creating new ones)
- [ ] Using factory traits appropriately
- [ ] For new specs: no `let`/`let!`, no `before`/`after` hooks
- [ ] context naming follows "when"/"with"/"and" pattern
- [ ] Max 2 context nesting levels
