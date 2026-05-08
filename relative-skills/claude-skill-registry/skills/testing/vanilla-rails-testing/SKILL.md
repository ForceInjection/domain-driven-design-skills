---
name: vanilla-rails-testing
description: Use when writing Rails tests - enforces fixtures-only, integration-style controller tests, Current context setup, simple naming, and Minitest syntax
---

# Vanilla Rails Testing

**Counter-intuitive patterns from 37signals.** These are NOT standard Rails community practices.

**Core principle:** Fixtures over factories. Always. Integration tests for controllers. Minitest, not RSpec.

## The Iron Law

**NO FACTORYBOT. NO RSPEC. NO DATA CREATION IN TESTS.**

If you write `create(:model)`, `FactoryBot`, `let`, `describe`, `it`, `expect`, or `before_each` → DELETE IT.

## Fixtures Only

```ruby
# ✅ GOOD - Reference fixtures
test "close card" do
  cards(:logo).close
  assert cards(:logo).closed?
end

# ❌ BAD - Never create data
test "close card" do
  card = create(:card)  # DELETE THIS
  card.close
end

# ❌ BAD - Never use FactoryBot
let(:card) { create(:card) }  # DELETE THIS

# ❌ BAD - Never use RSpec
describe Card do  # DELETE THIS
  it "closes" do  # DELETE THIS
```

**Reference fixtures by symbol:** `cards(:logo)`, `users(:david)`, `boards(:writebook)`, `sessions(:kevin)`

**Why fixtures?** They're real data, loaded once, fast, and force you to think about realistic scenarios.

**Q: What if the fixture I need doesn't exist?**
**A:** Add it to the fixtures file. Never create data in tests.

## Controller Tests Use Integration Style

```ruby
# ✅ GOOD - ActionDispatch::IntegrationTest
class Cards::ClosuresControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :kevin
  end

  test "create" do
    post card_closure_path(cards(:logo)), as: :turbo_stream
    assert_response :success
  end
end

# ❌ BAD - Never use ActionController::TestCase
class Cards::ClosuresControllerTest < ActionController::TestCase  # DELETE THIS
  post :create, params: { card_id: card.id }  # DELETE THIS
end
```

**Why integration style?** Tests the full request cycle including routing, middleware, and response rendering.

## Model Tests Require Current.session

```ruby
# ✅ GOOD - Set Current.session in setup
class Card::CloseableTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  test "close records user" do
    cards(:logo).close(user: users(:kevin))
    assert_equal users(:kevin), cards(:logo).closed_by
  end
end

# ❌ BAD - Missing Current.session
class Card::CloseableTest < ActiveSupport::TestCase
  # Missing setup - tests may fail or behave incorrectly
  test "close records user" do
    cards(:logo).close(user: users(:kevin))
  end
end
```

**Why Current.session?** Models often rely on `Current.session` for user context, event recording, and authorization.

**Always set it, even if you think it's not needed.**

## Simple Test Names

```ruby
# ✅ GOOD - Concise, clear
test "create"
test "close records user"
test "reopen creates event"

# ❌ BAD - Verbose, repetitive
test "should create a new card when given valid parameters"
test "should mark the card as closed when user closes it"
it "should record the user who closed the card"  # Also wrong syntax
```

**Why simple names?** File and test method name provide enough context. No need to repeat.

## Use Minitest Syntax

```ruby
# ✅ GOOD - Minitest assertions
test "close" do
  assert cards(:logo).close
  assert cards(:logo).closed?
  assert_not cards(:shipping).open?
end

# ✅ GOOD - Exception testing
assert_raises ActiveRecord::RecordNotFound do
  Card.find("nonexistent")
end

# ❌ BAD - RSpec syntax
it "should close" do  # DELETE THIS
  expect(card.close).to be_truthy  # DELETE THIS
  expect(card.closed?).to be true  # DELETE THIS
end

# ❌ BAD - RSpec describe/context
describe "#close" do  # DELETE THIS
  context "when card is open" do  # DELETE THIS
```

**Use:** `test`, `setup`, `assert`, `assert_equal`, `assert_not`, `assert_difference`, `assert_changes`, `assert_raises`

**NEVER use:** `it`, `describe`, `context`, `before_each`, `let`, `expect`, `refute` (use `assert_not` instead)

## assert_difference for State Changes

```ruby
# ✅ GOOD - Single change with lambda syntax
assert_difference -> { Card.count }, +1 do
  post board_cards_path(boards(:writebook))
end

# ✅ GOOD - Multiple changes
assert_difference({
  -> { cards(:logo).events.count } => +1,
  -> { Event.count } => +1
}) do
  cards(:logo).close(user: users(:kevin))
end

# ❌ BAD - RSpec expect/to change
expect {  # DELETE THIS
  card.close
}.to change { Event.count }.by(1)  # DELETE THIS
```

**Why lambda syntax?** Evaluates the expression in the block's context, capturing state changes correctly.

## assert_changes for Boolean Toggles

```ruby
# ✅ GOOD - Boolean state changes
assert_changes -> { cards(:logo).reload.closed? }, from: false, to: true do
  post card_closure_path(cards(:logo)), as: :turbo_stream
end

# ❌ BAD - Manual before/after checks
closed_before = card.closed?  # Too verbose
card.close
assert_not_equal closed_before, card.reload.closed?
```

## System Tests (Capybara)

System tests follow the same rules:

```ruby
# ✅ GOOD - ApplicationSystemTestCase with fixtures
class SmokeTest < ApplicationSystemTestCase
  test "create a card" do
    sign_in_as(users(:david))
    visit board_url(boards(:writebook))
    click_on "Add a card"
    # ...
  end
end

# ❌ BAD - Creating data in system tests
test "create a card" do
  user = create(:user)  # DELETE THIS
  sign_in_as(user)
end
```

## Stubbing and Mocking

Use mocha for stubbing, webmock for HTTP requests:

```ruby
# ✅ GOOD - Mocha for stubbing
TestMailer.stubs(:goes_boom).raises(Net::SMTPSyntaxError)

# ✅ GOOD - WebMock for HTTP
stub_request(:post, webhook.url).to_return(status: 200)

# ❌ BAD - RSpec mocks
allow(TestMailer).to receive(:goes_boom)  # DELETE THIS
```

## Common Rationalizations (All Wrong)

| Excuse | Reality |
|--------|---------|
| "FactoryBot is standard Rails practice" | Not in vanilla Rails. Fixtures only. |
| "RSpec is more expressive" | Minitest is simpler. Use it. |
| "Creating test data makes tests clearer" | Fixtures make tests realistic. No creation. |
| "ActionController::TestCase is for controllers" | Integration tests cover more. Use those. |
| "Current.session isn't needed here" | Models rely on it. Always set it. |
| "Verbose names document the test" | File name + method name = enough context. |
| "let makes setup DRY" | setup method does the same. No let. |
| "describe/context organizes tests" | Class and file organization is enough. |
| "I'll just create one record since fixture missing" | Add the fixture. Never create in tests. |
| "refute is more idiomatic Minitest" | Use assert_not for consistency. |

## Red Flags - STOP and Rewrite

Seeing any of these? DELETE THE CODE and start over:

- `create(:model)`, `build(:model)`, or `FactoryBot`
- `let`, `describe`, `it`, `context`, `before_each`, `subject`
- `expect(...).to` or `.should`
- `ActionController::TestCase`
- Model test without `Current.session = sessions(:fixture)`
- Test names starting with "should"
- Data creation in tests (`User.create`, `Card.new`, `Board.build`)
- `refute` (use `assert_not`)

## Quick Reference

| Pattern | Use | Never Use |
|---------|-----|-----------|
| **Test framework** | Minitest | RSpec |
| **Test data** | Fixtures (`cards(:logo)`) | Factories (`create(:card)`) |
| **Controller tests** | `ActionDispatch::IntegrationTest` | `ActionController::TestCase` |
| **System tests** | `ApplicationSystemTestCase` | Any other base class |
| **Model setup** | `Current.session = sessions(:david)` | Nothing (missing context) |
| **Test blocks** | `test "name"` | `it "should..."`, `describe` |
| **Setup** | `setup do` | `before_each`, `let`, `subject` |
| **Assertions** | `assert`, `assert_not` | `expect`, `should`, `refute` |
| **Test names** | `test "create"` | `it "should create..."` |
| **Stubbing** | `mocha` (`.stubs`) | RSpec mocks (`allow`, `expect`) |
| **HTTP mocking** | `webmock` | VCR, other tools |

## Real Example Comparison

### ❌ What NOT to Write (Common Mistakes)
```ruby
require "rails_helper"

RSpec.describe Card, type: :model do
  let(:board) { create(:board) }
  let(:card) { create(:card, board: board) }
  let(:user) { create(:user) }

  describe "#close" do
    it "should mark card as closed when user closes it" do
      expect {
        card.close(user: user)
      }.to change { card.reload.closed? }.from(false).to(true)

      expect(card.closed_by).to eq(user)
    end

    context "when already closed" do
      let(:card) { create(:card, :closed) }

      it "should not create duplicate events" do
        expect {
          card.close(user: user)
        }.not_to change { Event.count }
      end
    end
  end
end
```

### ✅ What to Write (Vanilla Rails)
```ruby
require "test_helper"

class Card::CloseableTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  test "close" do
    assert_not cards(:logo).closed?

    cards(:logo).close(user: users(:kevin))

    assert cards(:logo).closed?
    assert_equal users(:kevin), cards(:logo).closed_by
  end

  test "close creates event" do
    assert_difference -> { cards(:logo).events.count }, +1 do
      cards(:logo).close(user: users(:kevin))
    end
  end
end
```

## The Bottom Line

**Vanilla Rails is deliberately simple:**
- Fixtures, not factories
- Integration tests, not controller unit tests
- Minitest, not RSpec
- Current.session for model tests
- Simple names, minimal ceremony
- Always use fixtures, even if you need to create new ones

**If the Rails community does it differently, that's fine. We don't.**

Follow these patterns exactly. No exceptions, no "better" alternatives.
