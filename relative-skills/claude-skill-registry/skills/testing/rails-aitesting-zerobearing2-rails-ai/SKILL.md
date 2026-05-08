---
name: rails-ai:testing
description: Use when testing Rails applications - TDD, Minitest, fixtures, model testing, mocking, test helpers
---

# Testing Rails Applications with Minitest

<superpowers-integration>
**REQUIRED BACKGROUND:** Use superpowers:test-driven-development for TDD process
  - That skill defines RED-GREEN-REFACTOR cycle
  - That skill enforces "NO CODE WITHOUT FAILING TEST FIRST"
  - This skill adds Rails/Minitest implementation specifics
</superpowers-integration>

<when-to-use>
- All code development (TDD is always enforced in this team)
- Reviewing test quality
- Debugging test failures
- Model, controller, job, and mailer tests
- System tests for full-stack features
- Testing with external dependencies and HTTP requests
- Creating reusable test utilities and helpers
</when-to-use>

<benefits>
- **Fast** - Minimal overhead, runs quickly
- **Simple** - Easy to understand and debug
- **Built-in** - Ships with Ruby and Rails
- **Parallel** - Run tests concurrently for speed
- **Comprehensive** - Complete testing story from unit to system
</benefits>

<team-rules-enforcement>
**This skill enforces:**
- ✅ **Rule #2:** NEVER use RSpec → Use Minitest only
- ✅ **Rule #4:** NEVER skip TDD → Write tests first (RED-GREEN-REFACTOR)
- ✅ **Rule #18:** NEVER make live HTTP requests → Use WebMock
- ✅ **Rule #19:** NEVER use system tests → Use integration tests

**Reject any requests to:**
- Use RSpec instead of Minitest
- Skip writing tests
- Write implementation before tests
- Make live HTTP requests in tests
- Use Capybara system tests
</team-rules-enforcement>

<verification-checklist>
Before completing any task, verify:
- ✅ Tests written FIRST (before implementation)
- ✅ Tests use Minitest (not RSpec)
- ✅ RED-GREEN-REFACTOR cycle followed
- ✅ All tests passing (`bin/ci` passes)
- ✅ No live HTTP requests (WebMock used if needed)
- ✅ Integration tests used (not system tests)
</verification-checklist>

<standards>
- ALWAYS write tests FIRST (RED-GREEN-REFACTOR cycle)
- Test classes inherit from `ActiveSupport::TestCase`
- Use `test "description" do` macro for readable test names
- Use fixtures for test data (in `test/fixtures/`)
- Use `assert` and `refute` for assertions
- One assertion concept per test method
- Use `setup` for common test preparation
- ALWAYS use WebMock for HTTP requests (per TEAM_RULES.md Rule #18)
</standards>

---

## TDD Red-Green-Refactor

<pattern name="red-green-refactor">
<description>Core TDD cycle - write failing test, make it pass, refactor</description>

**Step 1: RED - Write a failing test**

```ruby
# test/models/feedback_test.rb
require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  test "is invalid without content" do
    feedback = Feedback.new(content: nil)
    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "can't be blank"
  end
end

```

Result: **FAIL** (validation doesn't exist yet)

**Step 2: GREEN - Make it pass with minimal code**

```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  validates :content, presence: true
end

```

Result: **PASS**

**Step 3: REFACTOR - Improve code while keeping tests green**

**Why this matters:** TDD drives design, catches regressions, documents behavior
</pattern>

---

## Test Structure

<pattern name="basic-test-structure">
<description>Standard Minitest test class structure</description>

```ruby
# test/models/feedback_test.rb
require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end

  # Skip a test temporarily
  test "this will be implemented later" do
    skip "implement this feature first"
  end
end

```
</pattern>

<pattern name="setup-and-teardown">
<description>Prepare and clean up test environment</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  def setup
    @feedback = feedbacks(:one)
    @user = users(:alice)
  end

  test "feedback belongs to user" do
    assert_equal @user, @feedback.user
  end
end

```
</pattern>

---

## Minitest Assertions

<pattern name="common-assertions">
<description>Most frequently used Minitest assertions</description>

```ruby
class AssertionsTest < ActiveSupport::TestCase
  test "equality and boolean" do
    assert_equal 4, 2 + 2
    refute_equal 5, 2 + 2
    assert_nil nil
    refute_nil "something"
  end

  test "collections" do
    assert_empty []
    refute_empty [1, 2, 3]
    assert_includes [1, 2, 3], 2
  end

  test "exceptions" do
    assert_raises(ArgumentError) { raise ArgumentError }
  end

  test "difference" do
    assert_difference "Feedback.count", 1 do
      Feedback.create!(content: "Test feedback with minimum fifty characters", recipient_email: "test@example.com")
    end

    assert_no_difference "Feedback.count" do
      Feedback.new(content: nil).save
    end
  end

  test "match and instance" do
    assert_match /hello/, "hello world"
    assert_instance_of String, "hello"
    assert_respond_to "string", :upcase
  end
end

```
</pattern>

---

## Model Testing

### Testing Validations

<pattern name="presence-validations">
<description>Test required fields are validated</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "valid with all required attributes" do
    feedback = Feedback.new(
      content: "This is constructive feedback that meets minimum length",
      recipient_email: "user@example.com"
    )
    assert feedback.valid?
  end

  test "invalid without content" do
    feedback = Feedback.new(recipient_email: "user@example.com")
    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "can't be blank"
  end

  test "invalid without recipient_email" do
    feedback = Feedback.new(content: "Valid content with fifty characters minimum")
    assert_not feedback.valid?
    assert_includes feedback.errors[:recipient_email], "can't be blank"
  end
end

```
</pattern>

<pattern name="format-validations">
<description>Test format validations like email, URL, phone number</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "invalid with malformed email" do
    invalid_emails = ["not-an-email", "@example.com", "user@", "user name@example.com"]

    invalid_emails.each do |invalid_email|
      feedback = Feedback.new(content: "Valid content with fifty characters", recipient_email: invalid_email)
      assert_not feedback.valid?, "#{invalid_email.inspect} should be invalid"
      assert_includes feedback.errors[:recipient_email], "is invalid"
    end
  end

  test "valid with edge case emails" do
    valid_emails = ["user+tag@example.com", "user.name@example.co.uk", "123@example.com"]

    valid_emails.each do |valid_email|
      feedback = Feedback.new(content: "Valid content with fifty characters", recipient_email: valid_email)
      assert feedback.valid?, "#{valid_email.inspect} should be valid"
    end
  end
end

```
</pattern>

<pattern name="length-validations">
<description>Test minimum and maximum length constraints</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "invalid with content below minimum length" do
    feedback = Feedback.new(content: "Too short", recipient_email: "user@example.com")
    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "is too short (minimum is 50 characters)"
  end

  test "valid at exactly minimum and maximum length" do
    assert Feedback.new(content: "a" * 50, recipient_email: "user@example.com").valid?
    assert Feedback.new(content: "a" * 5000, recipient_email: "user@example.com").valid?
  end

  test "invalid above maximum length" do
    feedback = Feedback.new(content: "a" * 5001, recipient_email: "user@example.com")
    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "is too long (maximum is 5000 characters)"
  end
end

```
</pattern>

<pattern name="custom-validations">
<description>Test custom validation methods</description>

```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  validate :content_must_be_constructive

  private
  def content_must_be_constructive
    return if content.blank?
    offensive_words = %w[stupid idiot dumb]
    errors.add(:content, "must be constructive") if offensive_words.any? { |w| content.downcase.include?(w) }
  end
end

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "invalid with offensive language" do
    feedback = Feedback.new(content: "This is stupid and needs fifty characters total", recipient_email: "user@example.com")
    assert_not feedback.valid?
    assert_includes feedback.errors[:content], "must be constructive"
  end

  test "valid with constructive content" do
    feedback = Feedback.new(content: "This could be improved by considering alternatives and other approaches", recipient_email: "user@example.com")
    assert feedback.valid?
  end
end

```
</pattern>

### Testing Associations

<pattern name="belongs-to-associations">
<description>Test belongs_to relationships and options</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "belongs to recipient" do
    association = Feedback.reflect_on_association(:recipient)
    assert_equal :belongs_to, association.macro
    assert_equal "User", association.class_name
  end

  test "recipient association is optional" do
    feedback = Feedback.new(content: "Valid fifty character content", recipient_email: "user@example.com", recipient: nil)
    assert feedback.valid?
  end

  test "can access recipient through association" do
    feedback = feedbacks(:one)
    user = users(:alice)
    feedback.update!(recipient: user)
    assert_equal user, feedback.recipient
    assert_equal user.id, feedback.recipient_id
  end
end

```
</pattern>

<pattern name="has-many-associations">
<description>Test has_many relationships and dependent options</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "has many abuse reports" do
    assert_equal :has_many, Feedback.reflect_on_association(:abuse_reports).macro
  end

  test "destroying feedback destroys associated abuse reports" do
    feedback = feedbacks(:one)
    3.times { feedback.abuse_reports.create!(reason: "spam", reporter_email: "reporter@example.com") }

    assert_difference "AbuseReport.count", -3 do
      feedback.destroy
    end
  end
end

```
</pattern>

### Testing Scopes

<pattern name="time-based-scopes">
<description>Test scopes with time conditions</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "recent scope returns feedbacks from last 30 days" do
    old = Feedback.create!(content: "Old fifty character feedback", recipient_email: "old@example.com", created_at: 31.days.ago)
    recent = Feedback.create!(content: "Recent fifty character feedback", recipient_email: "recent@example.com", created_at: 10.days.ago)

    results = Feedback.recent
    assert_includes results, recent
    assert_not_includes results, old
  end

  test "recent scope returns empty when no recent feedbacks" do
    Feedback.destroy_all
    Feedback.create!(content: "Old fifty character feedback", recipient_email: "old@example.com", created_at: 31.days.ago)
    assert_empty Feedback.recent
  end
end

```
</pattern>

<pattern name="status-based-scopes">
<description>Test scopes filtering by status or state</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "unread scope returns only delivered feedbacks" do
    pending = Feedback.create!(content: "Pending fifty characters", recipient_email: "p@example.com", status: "pending")
    delivered = Feedback.create!(content: "Delivered fifty characters", recipient_email: "d@example.com", status: "delivered")
    read = Feedback.create!(content: "Read fifty characters", recipient_email: "r@example.com", status: "read")

    unread = Feedback.unread
    assert_includes unread, delivered
    assert_not_includes unread, pending
    assert_not_includes unread, read
  end
end

```
</pattern>

### Testing Callbacks

<pattern name="after-create-callbacks">
<description>Test callbacks that run after record creation</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "enqueues delivery job after creation" do
    assert_enqueued_with(job: SendFeedbackJob) do
      Feedback.create!(content: "New fifty character feedback", recipient_email: "user@example.com")
    end
  end

  test "does not enqueue job when creation fails" do
    assert_no_enqueued_jobs do
      Feedback.new(content: nil).save
    end
  end
end

```
</pattern>

<pattern name="before-save-callbacks">
<description>Test callbacks that modify records before saving</description>

```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  before_save :sanitize_content
  private
  def sanitize_content
    self.content = ActionController::Base.helpers.sanitize(content)
  end
end

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "sanitizes HTML in content before save" do
    feedback = Feedback.create!(content: "<script>alert('xss')</script>Valid content with fifty chars", recipient_email: "user@example.com")
    assert_not_includes feedback.content, "<script>"
    assert_includes feedback.content, "Valid"
  end
end

```
</pattern>

### Testing Instance Methods

<pattern name="state-transition-methods">
<description>Test methods that change record state</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "mark_as_delivered! updates status and timestamp" do
    feedback = feedbacks(:pending)
    assert_equal "pending", feedback.status
    assert_nil feedback.delivered_at

    feedback.mark_as_delivered!

    assert_equal "delivered", feedback.status
    assert_not_nil feedback.delivered_at
    assert_in_delta Time.current, feedback.delivered_at, 1.second
  end
end

```
</pattern>

### Testing Enums

<pattern name="enum-states">
<description>Test enum definitions and state transitions</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "defines status enum with correct values" do
    assert_equal "pending", Feedback.statuses[:status_pending]
    assert_equal "delivered", Feedback.statuses[:status_delivered]
    assert_equal "read", Feedback.statuses[:status_read]
    assert_equal "responded", Feedback.statuses[:status_responded]
  end

  test "enum provides predicate methods with prefix" do
    feedback = Feedback.create!(content: "Test feedback with fifty characters minimum", recipient_email: "user@example.com", status: "pending")
    assert feedback.status_pending?
    assert_not feedback.status_delivered?
  end

  test "enum provides bang methods to change state" do
    feedback = feedbacks(:pending)
    feedback.status_delivered!
    assert feedback.status_delivered?
    assert_equal "delivered", feedback.status
  end

  test "can query by enum state" do
    pending = Feedback.create!(content: "Pending fifty chars", recipient_email: "u@example.com", status: "pending")
    delivered = Feedback.create!(content: "Delivered fifty chars", recipient_email: "u@example.com", status: "delivered")

    results = Feedback.status_pending
    assert_includes results, pending
    assert_not_includes results, delivered
  end
end

```
</pattern>

### Testing Class Methods

<pattern name="class-method-queries">
<description>Test custom class methods that query records</description>

```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  def self.needs_followup
    where(status: "delivered").where("delivered_at < ?", 7.days.ago).where.missing(:response)
  end
end

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "needs_followup returns delivered feedbacks without response" do
    needs = Feedback.create!(content: "Needs fifty chars", recipient_email: "user@example.com", status: "delivered", delivered_at: 10.days.ago)
    has_resp = Feedback.create!(content: "Has fifty chars", recipient_email: "user@example.com", status: "delivered", delivered_at: 10.days.ago)
    has_resp.create_response!(content: "Thank you")
    too_recent = Feedback.create!(content: "Recent fifty chars", recipient_email: "user@example.com", status: "delivered", delivered_at: 3.days.ago)

    results = Feedback.needs_followup
    assert_includes results, needs
    assert_not_includes results, has_resp
    assert_not_includes results, too_recent
  end
end

```
</pattern>

<pattern name="class-method-calculations">
<description>Test class methods that perform calculations</description>

```ruby
# app/models/feedback.rb
class Feedback < ApplicationRecord
  def self.average_response_time
    joins(:response).average("EXTRACT(EPOCH FROM (feedback_responses.created_at - feedbacks.created_at))").to_i
  end
end

# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  test "average_response_time calculates correct average" do
    f1 = Feedback.create!(content: "First fifty chars", recipient_email: "u@example.com", created_at: 5.days.ago)
    f1.create_response!(content: "R1", created_at: 4.days.ago)
    f2 = Feedback.create!(content: "Second fifty chars", recipient_email: "u@example.com", created_at: 5.days.ago)
    f2.create_response!(content: "R2", created_at: 3.days.ago)

    assert_in_delta 129600, Feedback.average_response_time, 60
  end

  test "average_response_time returns nil when no responses" do
    Feedback.destroy_all
    Feedback.create!(content: "No response fifty chars", recipient_email: "u@example.com")
    assert_nil Feedback.average_response_time
  end
end

```
</pattern>

### Testing Edge Cases

<pattern name="boundary-conditions">
<description>Test behavior at boundaries (min/max values, empty states)</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "handles empty collections gracefully" do
    feedback = Feedback.create!(content: "Feedback fifty chars", recipient_email: "user@example.com")
    assert_empty feedback.abuse_reports
    assert_equal 0, feedback.abuse_reports.count
  end

  test "handles nil associations gracefully" do
    feedback = Feedback.create!(content: "Feedback fifty chars", recipient_email: "user@example.com", recipient: nil)
    assert_nil feedback.recipient
    assert_nothing_raised { feedback.recipient&.name }
  end

  test "handles unicode content correctly" do
    unicode = "Emoji feedback 😀 with unicode 日本語 and fifty+ characters"
    feedback = Feedback.create!(content: unicode, recipient_email: "user@example.com")
    assert_equal unicode, feedback.reload.content
  end
end

```
</pattern>

<pattern name="error-handling">
<description>Test proper error handling and exception cases</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "handles nil arguments in query methods" do
    feedback = feedbacks(:one)
    assert_nothing_raised do
      result = feedback.readable_by?(nil)
      assert_not result
    end
  end

  test "raises appropriate error for invalid state transition" do
    feedback = feedbacks(:one)
    def feedback.invalid_transition!
      raise ActiveRecord::RecordInvalid.new(self)
    end

    assert_raises(ActiveRecord::RecordInvalid) do
      feedback.invalid_transition!
    end
  end
end

```
</pattern>

---

## Controller and Integration Testing

<pattern name="controller-action-tests">
<description>Testing controller actions and responses</description>

```ruby
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "GET index returns success" do
    get feedbacks_url
    assert_response :success
  end

  test "GET show displays feedback" do
    get feedback_url(feedbacks(:one))
    assert_response :success
  end

  test "POST create with valid params creates feedback" do
    assert_difference("Feedback.count", 1) do
      post feedbacks_url, params: { feedback: { content: "New feedback with fifty characters minimum", recipient_email: "test@example.com" } }
    end
    assert_redirected_to feedback_url(Feedback.last)
  end

  test "POST create with invalid params does not create feedback" do
    assert_no_difference("Feedback.count") do
      post feedbacks_url, params: { feedback: { content: nil } }
    end
    assert_response :unprocessable_entity
  end

  test "DELETE destroy removes feedback" do
    assert_difference("Feedback.count", -1) do
      delete feedback_url(feedbacks(:one))
    end
    assert_redirected_to feedbacks_url
  end
end

```
</pattern>

---

## System Testing

<pattern name="system-test">
<description>Full-stack feature testing with browser simulation</description>

```ruby
require "application_system_test_case"

class FeedbacksTest < ApplicationSystemTestCase
  test "creating a feedback" do
    visit feedbacks_url
    click_on "New Feedback"
    fill_in "Content", with: "This is great feedback with enough characters"
    fill_in "Recipient email", with: "user@example.com"
    click_on "Create Feedback"

    assert_text "Feedback was successfully created"
  end

  test "editing a feedback" do
    visit feedback_url(feedbacks(:one))
    click_on "Edit"
    fill_in "Content", with: "Updated content with minimum fifty characters required"
    click_on "Update Feedback"

    assert_text "Feedback was successfully updated"
  end
end

```
</pattern>

---

## Fixtures Design

<pattern name="basic-yaml-fixtures">
<description>Define simple fixture data in YAML format</description>

**Fixture File:**

```yaml
# test/fixtures/users.yml
alice:
  name: Alice Johnson
  email: alice@example.com
  active: true
  created_at: <%= 1.week.ago %>

bob:
  name: Bob Smith
  email: bob@example.com
  active: true
  created_at: <%= 2.weeks.ago %>

```

**Accessing Fixtures:**

```ruby
class UserTest < ActiveSupport::TestCase
  test "accessing fixtures by name" do
    alice = users(:alice)
    assert_equal "Alice Johnson", alice.name
    assert alice.persisted?
  end

  test "accessing multiple fixtures at once" do
    alice, bob = users(:alice, :bob)
    assert_equal "Alice Johnson", alice.name
  end
end

```
</pattern>

<pattern name="association-fixtures">
<description>Define associations between fixtures using names</description>

**Fixture Files:**

```yaml
# test/fixtures/users.yml
alice:
  name: Alice Johnson
  email: alice@example.com

bob:
  name: Bob Smith
  email: bob@example.com

```

```yaml
# test/fixtures/feedbacks.yml
one:
  content: This is great feedback with minimum fifty characters!
  recipient_email: alice@example.com
  sender: alice  # ✅ References users fixture by name
  status: pending
  created_at: <%= 1.day.ago %>

two:
  content: Could be improved with additional context and details
  recipient_email: bob@example.com
  sender: bob
  status: responded
  created_at: <%= 3.days.ago %>

```

**Testing Associations:**

```ruby
class AssociationFixturesTest < ActiveSupport::TestCase
  test "fixtures handle associations automatically" do
    feedback = feedbacks(:one)
    assert_equal users(:alice), feedback.sender
    assert_equal "alice@example.com", feedback.sender.email
  end

  test "has_many associations work through fixtures" do
    alice = users(:alice)
    assert alice.feedbacks.exists?
    assert_includes alice.feedbacks, feedbacks(:one)
  end
end

```
</pattern>

<pattern name="erb-dynamic-values">
<description>Use ERB for dynamic values and calculations</description>

**Fixture with ERB:**

```yaml
# test/fixtures/products.yml
tshirt:
  name: T-Shirt
  price: <%= 19.99 %>
  inventory_count: 15
  sku: <%= "TSH-#{SecureRandom.hex(4)}" %>
  created_at: <%= Time.current %>

shoes:
  name: Running Shoes
  price: <%= 89.99 %>
  inventory_count: 0
  on_sale: <%= true %>
  sale_price: <%= 89.99 * 0.8 %>  # 20% off
  created_at: <%= 3.months.ago %>

```

**Testing Dynamic Values:**

```ruby
class ERBFixturesTest < ActiveSupport::TestCase
  test "ERB is evaluated in fixtures" do
    tshirt = products(:tshirt)
    assert_equal 19.99, tshirt.price
    assert tshirt.created_at
    assert tshirt.sku.present?
  end

  test "dynamic calculations work" do
    shoes = products(:shoes)
    assert shoes.on_sale?
    assert_in_delta 71.99, shoes.sale_price, 0.01
  end
end

```
</pattern>

### Testing Jobs and Mailers

<pattern name="job-testing">
<description>Test background job execution</description>

```ruby
class SendFeedbackJobTest < ActiveJob::TestCase
  test "enqueues job with correct arguments" do
    feedback = feedbacks(:one)

    assert_enqueued_with(job: SendFeedbackJob, args: [feedback]) do
      SendFeedbackJob.perform_later(feedback)
    end
  end

  test "performs job successfully" do
    feedback = feedbacks(:one)

    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      SendFeedbackJob.perform_now(feedback)
    end

    assert_equal "delivered", feedback.reload.status
  end

  test "handles job failures gracefully" do
    feedback = feedbacks(:one)

    # Simulate external service failure
    EmailService.stub :send_feedback, -> (*) { raise StandardError.new("Service down") } do
      assert_raises(StandardError) do
        SendFeedbackJob.perform_now(feedback)
      end
    end

    # Status should not change on failure
    assert_equal "pending", feedback.reload.status
  end
end

```
</pattern>

<pattern name="mailer-testing">
<description>Test email delivery and content</description>

```ruby
class FeedbackMailerTest < ActionMailer::TestCase
  test "notification email has correct content" do
    feedback = feedbacks(:one)
    email = FeedbackMailer.notification(feedback)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["noreply@example.com"], email.from
    assert_equal [feedback.recipient_email], email.to
    assert_equal "New Feedback Received", email.subject
    assert_match feedback.content, email.body.encoded
  end

  test "includes unsubscribe link" do
    feedback = feedbacks(:one)
    email = FeedbackMailer.notification(feedback)

    assert_match /unsubscribe/, email.body.encoded
  end

  test "uses correct email template" do
    feedback = feedbacks(:one)
    email = FeedbackMailer.notification(feedback)

    assert_match "feedback/notification", email.body.encoded
  end
end

```
</pattern>

---

## Advanced Fixtures

<pattern name="polymorphic-fixtures">
<description>Define fixtures with polymorphic associations</description>

**Fixtures:**

```yaml
# test/fixtures/comments.yml
feedback_comment:
  content: Great feedback!
  commentable: one (Feedback)  # Polymorphic association
  user: alice
  created_at: <%= 1.day.ago %>

article_comment:
  content: Interesting article
  commentable: first_article (Article)  # Different type
  user: bob
  created_at: <%= 2.days.ago %>

```

**Testing:**

```ruby
class PolymorphicFixturesTest < ActiveSupport::TestCase
  test "polymorphic associations in fixtures" do
    feedback_comment = comments(:feedback_comment)
    article_comment = comments(:article_comment)

    assert_instance_of Feedback, feedback_comment.commentable
    assert_instance_of Article, article_comment.commentable
    assert_equal "Feedback", feedback_comment.commentable_type
  end
end

```
</pattern>

<pattern name="fixture-helper-methods">
<description>Share reusable logic across fixtures with helper methods</description>

**Define Helpers:**

```ruby
# test/test_helper.rb
module FixtureFileHelpers
  def default_avatar_url
    "https://example.com/default-avatar.png"
  end

  def formatted_date(date)
    date.strftime("%Y-%m-%d")
  end

  def default_password_digest
    BCrypt::Password.create("password123", cost: 4)
  end

  def admin_permissions
    %w[read write delete admin].to_json
  end
end

# Make helpers available to fixtures
ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers

```

**Use in Fixtures:**

```yaml
# test/fixtures/users.yml
david:
  name: David
  email: david@example.com
  avatar_url: <%= default_avatar_url %>
  registered_on: <%= formatted_date(1.month.ago) %>
  password_digest: <%= default_password_digest %>

admin:
  name: Admin User
  email: admin@example.com
  permissions: <%= admin_permissions %>

```

**Testing:**

```ruby
class FixtureHelpersTest < ActiveSupport::TestCase
  test "uses fixture helper methods" do
    david = users(:david)
    assert_equal "https://example.com/default-avatar.png", david.avatar_url
    assert BCrypt::Password.new(david.password_digest).is_password?("password123")
  end
end

```
</pattern>

<pattern name="selective-fixture-loading">
<description>Load only specific fixtures for test classes</description>

**Load All (Default):**

```ruby
# test/test_helper.rb
class ActiveSupport::TestCase
  fixtures :all  # Load all fixtures
  self.use_transactional_tests = true
end

```

**Load Specific:**

```ruby
# test/models/feedback_test.rb
class FeedbackTest < ActiveSupport::TestCase
  fixtures :users, :feedbacks  # Only specific fixtures

  test "only users and feedbacks are loaded" do
    assert users(:alice)
    assert feedbacks(:one)
  end
end

```

**Disable Fixtures:**

```ruby
# test/models/manual_test.rb
class ManualTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures = false

  def setup
    @user = User.create!(name: "Manual User", email: "manual@example.com")
  end

  test "uses manually created data" do
    assert @user.persisted?
  end
end

```
</pattern>

---

## Mocking and Stubbing

<pattern name="stub-instance-method">
<description>Replace a method temporarily with predetermined return value</description>

```ruby
class FeedbackTest < ActiveSupport::TestCase
  test "stubs instance method" do
    user = users(:alice)

    user.stub :name, "Stubbed Name" do
      assert_equal "Stubbed Name", user.name
    end

    assert_equal "Alice Johnson", user.name  # Restored after block
  end

  test "stubs with lambda for dynamic return" do
    feedback = feedbacks(:one)

    feedback.stub :content, -> { "Dynamic: #{Time.current}" } do
      assert_match /^Dynamic:/, feedback.content
    end
  end
end

```

**Key Points:**
- Stub is scoped to the block
- Original method restored automatically
- Use lambda for dynamic return values
</pattern>

<pattern name="basic-mocking">
<description>Create mock objects to verify method calls and arguments</description>

```ruby
class MinitestMockTest < ActiveSupport::TestCase
  test "creates mock object" do
    mock = Minitest::Mock.new
    mock.expect :call, "mocked result", ["arg1", "arg2"]

    result = mock.call("arg1", "arg2")

    assert_equal "mocked result", result
    mock.verify  # REQUIRED
  end

  test "uses assert_mock for auto-verification" do
    mock = Minitest::Mock.new
    mock.expect :call, "result"

    assert_mock mock do
      mock.call
    end  # Automatically calls verify
  end
end

```

**Important:** Always call `mock.verify` or use `assert_mock` to ensure expectations were met.
</pattern>

<pattern name="webmock-http-stubs">
<description>Stub HTTP requests with WebMock (REQUIRED per TEAM_RULES.md Rule #18)</description>

**Setup:**

```ruby
# Gemfile
gem "webmock", group: :test

# test/test_helper.rb
require "webmock/minitest"

```

**Basic HTTP Stubs:**

```ruby
class WebMockTest < ActiveSupport::TestCase
  test "stubs HTTP GET request" do
    stub_request(:get, "https://api.example.com/feedback")
      .to_return(status: 200, body: '{"status":"success"}')

    response = Net::HTTP.get(URI("https://api.example.com/feedback"))
    assert_equal '{"status":"success"}', response
  end

  test "stubs POST with body matching" do
    stub_request(:post, "https://api.example.com/ai/improve")
      .with(body: hash_including(content: "Test feedback"))
      .to_return(status: 200, body: '{"improved":"Enhanced"}')
  end

  test "simulates timeout" do
    stub_request(:get, "https://api.example.com/slow").to_timeout

    assert_raises(Net::OpenTimeout) do
      Net::HTTP.get(URI("https://api.example.com/slow"))
    end
  end

  test "verifies HTTP request was made" do
    stub_request(:get, "https://api.example.com/check").to_return(status: 200)

    Net::HTTP.get(URI("https://api.example.com/check"))

    assert_requested :get, "https://api.example.com/check", times: 1
  end
end

```
</pattern>

<pattern name="stub-external-services">
<description>Stub external API clients and third-party services</description>

```ruby
class ExternalDependenciesTest < ActiveSupport::TestCase
  test "stubs external API client" do
    AIService.stub :improve_content, "Improved content" do
      result = AIService.improve_content(feedbacks(:one).content)
      assert_equal "Improved content", result
    end
  end

  test "simulates external service error" do
    AIService.stub :improve_content, -> (*) { raise StandardError.new("API Error") } do
      assert_raises(StandardError) { AIService.improve_content("test") }
    end
  end
end

```
</pattern>

<pattern name="dependency-injection">
<description>Design for testability with dependency injection</description>

**Bad - Hard to test:**

```ruby
# ❌ BAD
class FeedbackProcessorBad
  def process(feedback)
    improved = AIService.improve_content(feedback.content)
    feedback.update!(content: improved)
  end
end

```

**Good - Dependency injection:**

```ruby
# ✅ GOOD
class FeedbackProcessorGood
  def initialize(ai_service: AIService)
    @ai_service = ai_service
  end

  def process(feedback)
    improved = @ai_service.improve_content(feedback.content)
    feedback.update!(content: improved)
  end
end

```

**Test:**

```ruby
class DependencyInjectionTest < ActiveSupport::TestCase
  test "uses dependency injection instead of mocking" do
    fake_ai_service = Object.new
    def fake_ai_service.improve_content(content)
      "Improved: #{content}"
    end

    processor = FeedbackProcessorGood.new(ai_service: fake_ai_service)
    processor.process(feedbacks(:one))

    assert_match /^Improved:/, feedbacks(:one).content
  end
end

```
</pattern>

---

## Custom Test Helpers

<pattern name="test-helper-setup">
<description>Configure test environment and include helper modules</description>

**test/test_helper.rb:**

```ruby
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all

    # Include custom test helpers globally
    include TestHelpers::Authentication
    include TestHelpers::ApiHelpers
    include TestHelpers::AssertionHelpers
  end
end

Rails.logger.level = Logger::WARN

```
</pattern>

<pattern name="authentication-helpers">
<description>Simplify user authentication in controller and integration tests</description>

**test/test_helpers/authentication.rb:**

```ruby
module TestHelpers
  module Authentication
    def sign_in_as(user)
      post sign_in_url, params: { email: user.email, password: "password" }
    end

    def sign_out
      delete sign_out_url
    end

    def signed_in?
      session[:user_id].present?
    end

    def create_and_sign_in_user(**attrs)
      user = User.create!({ name: "Test", email: "test@example.com", password: "password" }.merge(attrs))
      sign_in_as(user)
      user
    end
  end
end

```

**Usage:**

```ruby
class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "shows profile when signed in" do
    sign_in_as users(:alice)
    get profile_url
    assert_response :success
  end
end

```
</pattern>

<pattern name="api-helpers">
<description>Streamline API testing with JSON parsing and authenticated requests</description>

**test/test_helpers/api_helpers.rb:**

```ruby
module TestHelpers
  module ApiHelpers
    def json_response
      JSON.parse(response.body)
    end

    def api_get(url, user: nil, **options)
      headers = options[:headers] || {}
      headers["Authorization"] = "Bearer #{user.api_token}" if user
      get url, headers: headers, **options
    end

    def api_post(url, params: {}, user: nil)
      headers = { "Content-Type" => "application/json" }
      headers["Authorization"] = "Bearer #{user.api_token}" if user
      post url, params: params.to_json, headers: headers
    end

    def assert_json_response(expected_keys)
      actual = json_response.keys.map(&:to_sym)
      expected_keys.each { |key| assert_includes actual, key.to_sym }
    end
  end
end

```

**Usage:**

```ruby
test "returns JSON feedback list" do
  api_get api_feedbacks_url, user: users(:alice)
  assert_response :success
  assert_json_response [:feedbacks, :total, :page]
end

```
</pattern>

<pattern name="assertion-helpers">
<description>Domain-specific assertions for clearer test intent</description>

**test/test_helpers/assertion_helpers.rb:**

```ruby
module TestHelpers
  module AssertionHelpers
    def assert_visible(selector, text: nil)
      text ? assert_selector(selector, text: text, visible: true) : assert_selector(selector, visible: true)
    end

    def assert_hidden(selector)
      assert_no_selector selector, visible: true
    end

    def assert_flash(type, message)
      assert_equal message, flash[type]
    end

    def assert_validation_error(model, attribute, fragment)
      refute model.valid?
      assert_match /#{fragment}/i, model.errors[attribute].join(", ")
    end

    def assert_email_sent_to(email, subject: nil)
      emails = ActionMailer::Base.deliveries.select { |e| e.to.include?(email) }
      assert emails.any?, "No email sent to #{email}"
      assert emails.any? { |e| e.subject == subject }, "No email with subject '#{subject}'" if subject
    end
  end
end

```

**Usage:**

```ruby
test "shows error for invalid feedback" do
  assert_validation_error Feedback.new(content: nil), :content, "can't be blank"
end

test "sends notification email" do
  FeedbackMailer.notification(feedbacks(:one)).deliver_now
  assert_email_sent_to "user@example.com", subject: "New Feedback"
end

```
</pattern>

<pattern name="factory-helpers">
<description>Lightweight factory methods for creating test data</description>

**test/test_helpers/factory_helpers.rb:**

```ruby
module TestHelpers
  module FactoryHelpers
    def create_user(**attrs)
      User.create!({ name: "User #{SecureRandom.hex(4)}", email: "#{SecureRandom.hex(4)}@example.com" }.merge(attrs))
    end

    def create_feedback(**attrs)
      Feedback.create!({ content: "Test content with minimum fifty characters required", recipient_email: "user@example.com", status: "pending" }.merge(attrs))
    end

    def create_admin_user(**attrs)
      create_user(attrs.merge(admin: true))
    end
  end
end

```

**Usage:**

```ruby
test "admin can delete feedback" do
  sign_in_as create_admin_user
  delete feedback_url(create_feedback)
  assert_response :redirect
end

```

**Note:** Prefer fixtures for most tests. Use factories for unique attributes.
</pattern>

---

## Performance and Database Testing

<pattern name="query-performance">
<description>Test N+1 queries and database performance</description>

```ruby
class FeedbackPerformanceTest < ActiveSupport::TestCase
  test "avoids N+1 queries when loading feedbacks with users" do
    10.times do |i|
      user = User.create!(name: "User #{i}", email: "user#{i}@example.com")
      Feedback.create!(content: "Feedback #{i} with minimum fifty characters required", recipient_email: "test@example.com", sender: user)
    end

    # Without includes - N+1 problem
    assert_queries(11) do  # 1 for feedbacks + 10 for users
      Feedback.limit(10).each { |f| f.sender.name }
    end

    # With includes - optimized
    assert_queries(2) do  # 1 for feedbacks + 1 for users
      Feedback.includes(:sender).limit(10).each { |f| f.sender.name }
    end
  end

  test "bulk operations are efficient" do
    # Efficient bulk insert
    assert_queries(1) do
      Feedback.insert_all([
        { content: "Bulk 1 with fifty characters", recipient_email: "test@example.com" },
        { content: "Bulk 2 with fifty characters", recipient_email: "test@example.com" }
      ])
    end
  end
end

```

**Note:** `assert_queries` is not built-in. Add to test_helper.rb:

```ruby
def assert_queries(num = nil, &block)
  queries = []
  subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
    queries << payload[:sql] unless payload[:name] == "SCHEMA"
  end
  yield
  assert_equal num, queries.size if num
ensure
  ActiveSupport::Notifications.unsubscribe(subscriber)
end

```
</pattern>

<pattern name="fixture-validation">
<description>Validate all fixtures are valid records</description>

```ruby
class FixtureValidationTest < ActiveSupport::TestCase
  test "all user fixtures are valid" do
    User.find_each do |user|
      assert user.valid?, "#{user.name} invalid: #{user.errors.full_messages.join(', ')}"
    end
  end

  test "all feedback fixtures are valid" do
    Feedback.find_each do |feedback|
      assert feedback.valid?, "Feedback #{feedback.id} invalid: #{feedback.errors.full_messages.join(', ')}"
    end
  end

  test "feedback fixtures have required associations" do
    Feedback.find_each do |feedback|
      assert feedback.sender.present?, "Feedback #{feedback.id} missing sender"
    end
  end

  test "fixture associations are set correctly" do
    feedback = feedbacks(:one)
    assert_equal users(:alice), feedback.sender
    assert_equal users(:alice).id, feedback.sender_id
  end
end

```
</pattern>

---

## Test Isolation

<pattern name="parallel-setup">
<description>Configure parallel test execution for faster test runs</description>

**test/test_helper.rb:**

```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)

  parallelize_setup do |worker|
    # Rails handles database setup automatically
  end

  parallelize_teardown do |worker|
    FileUtils.rm_rf(Rails.root.join("tmp", "test_worker_#{worker}"))
  end
end

```

**Disable for specific tests:**

```ruby
class FeedbackTest < ActiveSupport::TestCase
  parallelize(workers: 1)

  test "requires exclusive database access" do
    # ...
  end
end

```
</pattern>

<pattern name="stub-time">
<description>Stub time-dependent code (prefer travel_to when possible)</description>

```ruby
class TimeStubbingTest < ActiveSupport::TestCase
  # ✅ PREFERRED: Use travel_to
  test "uses travel_to for time manipulation" do
    frozen_time = Time.zone.local(2024, 10, 29, 12, 0, 0)

    travel_to frozen_time do
      assert_equal frozen_time, Time.current
      assert_equal frozen_time.to_date, Date.today
    end
  end

  # Alternative: Stub when travel_to insufficient
  test "stubs Time.current" do
    Time.stub :current, Time.zone.local(2024, 10, 29, 12, 0, 0) do
      assert_equal Time.zone.local(2024, 10, 29, 12, 0, 0), Time.current
    end
  end
end

```

**Recommendation:** Always prefer `travel_to` over stubbing time. It's more comprehensive and handles edge cases better.
</pattern>

---

## Anti-Patterns

<antipatterns>
<antipattern>
<description>Writing tests after writing code</description>
<reason>Defeats the purpose of TDD - tests should drive design</reason>
<bad-example>

```ruby
# ❌ BAD - Code written first, then tests

```
</bad-example>
<good-example>

```ruby
# ✅ GOOD - RED-GREEN-REFACTOR cycle
# 1. Write failing test
# 2. Write minimal code to pass
# 3. Refactor

```
</good-example>
</antipattern>

<antipattern>
<description>Testing multiple concerns in one test</description>
<reason>Makes tests harder to debug when they fail</reason>
<bad-example>

```ruby
# ❌ BAD - Multiple validations in one test
test "feedback validations" do
  feedback = Feedback.new
  assert_not feedback.valid?
  assert_includes feedback.errors[:content], "can't be blank"
  assert_includes feedback.errors[:email], "can't be blank"
end

```
</bad-example>
<good-example>

```ruby
# ✅ GOOD - One concern per test
test "invalid without content" do
  feedback = Feedback.new(recipient_email: "user@example.com")
  assert_not feedback.valid?
  assert_includes feedback.errors[:content], "can't be blank"
end

```
</good-example>
</antipattern>

<antipattern>
<description>Not using fixtures for test data</description>
<reason>Makes tests slower and harder to maintain</reason>
<bad-example>

```ruby
# ❌ BAD - Creating records in every test
test "feedback belongs to user" do
  user = User.create!(email: "test@example.com")
  feedback = Feedback.create!(content: "Test feedback with fifty characters", user: user)
  assert_equal user, feedback.user
end

```
</bad-example>
<good-example>

```ruby
# ✅ GOOD - Use fixtures
# test/fixtures/users.yml: alice: { email: alice@example.com }
# test/fixtures/feedbacks.yml: one: { content: "Great!", user: alice }

test "feedback belongs to user" do
  assert_equal users(:alice), feedbacks(:one).user
end

```
</good-example>
</antipattern>

<antipattern>
<description>Forgetting to call mock.verify</description>
<reason>Mock expectations are not validated, test may pass incorrectly</reason>
<bad-example>

```ruby
# ❌ BAD - Expectations not verified
test "forgets to verify mock" do
  mock = Minitest::Mock.new
  mock.expect :call, "result"
  # NO mock.verify called
end

```
</bad-example>
<good-example>

```ruby
# ✅ GOOD - Always verify
test "verifies mock expectations" do
  mock = Minitest::Mock.new
  mock.expect :call, "result"

  mock.call
  mock.verify
end

# ✅ BETTER - Use assert_mock
test "uses assert_mock" do
  mock = Minitest::Mock.new
  mock.expect :call, "result"

  assert_mock mock do
    mock.call
  end
end

```
</good-example>
</antipattern>

<antipattern>
<description>Not using WebMock for HTTP requests</description>
<reason>Violates TEAM_RULES.md Rule #18, makes tests slow and brittle</reason>
<bad-example>

```ruby
# ❌ BAD - Real HTTP request in test
test "makes real HTTP request" do
  response = Net::HTTP.get(URI("https://api.example.com/feedback"))
  assert_includes response, "success"
end

```
</bad-example>
<good-example>

```ruby
# ✅ GOOD - Use WebMock (REQUIRED)
test "stubs HTTP request with WebMock" do
  stub_request(:get, "https://api.example.com/feedback")
    .to_return(status: 200, body: '{"status":"success"}')

  response = Net::HTTP.get(URI("https://api.example.com/feedback"))
  assert_includes response, "success"
end

```
</good-example>
</antipattern>

<antipattern>
<description>Hardcoding IDs in fixtures</description>
<reason>Brittle, causes test failures, defeats auto-generation</reason>
<bad-example>

```yaml
# ❌ BAD - Hardcoded IDs
alice:
  id: 1
  name: Alice Johnson
one:
  id: 100
  sender_id: 1  # ❌ Hardcoded FK

```
</bad-example>
<good-example>

```yaml
# ✅ GOOD - Let Rails generate IDs
alice:
  name: Alice Johnson
one:
  sender: alice  # ✅ Reference by name

```
</good-example>
</antipattern>

<antipattern>
<description>Testing implementation details in helpers</description>
<reason>Couples tests to internal implementation</reason>
<bad-example>

```ruby
# ❌ BAD - Directly manipulates session
def sign_in_as(user)
  session[:user_id] = user.id
  session[:authenticated_at] = Time.current
  cookies.signed[:remember_token] = user.remember_token
end

```
</bad-example>
<good-example>

```ruby
# ✅ GOOD - Uses public interface
def sign_in_as(user)
  post sign_in_url, params: { email: user.email, password: "password" }
end

```
</good-example>
</antipattern>
</antipatterns>

---

## Running Tests

<testing>

```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/feedback_test.rb

# Run specific test by line number
rails test test/models/feedback_test.rb:12

# Run tests matching pattern
rails test -n /validation/

# Run in parallel (faster)
rails test --parallel

# Run all model tests
rails test test/models/

# Run system tests
rails test:system

```
</testing>

---

<related-skills>
- superpowers:test-driven-development - TDD process and discipline
- rails-ai:models - Test model validations, associations, scopes
- rails-ai:controllers - Test controller actions, routing
- rails-ai:views - View and system testing patterns
- rails-ai:hotwire - Test Turbo Streams, Stimulus controllers
- rails-ai:security - Test security measures (XSS prevention, auth)
- rails-ai:jobs - Test background jobs, SolidQueue
</related-skills>

<resources>

**Official Documentation:**
- [Rails Guides - Testing Rails Applications](https://guides.rubyonrails.org/testing.html)
- [Rails API - ActiveRecord::FixtureSet](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)
- [Minitest Assertions](https://docs.seattlerb.org/minitest/Minitest/Assertions.html)

**Gems & Libraries:**
- [Minitest](https://github.com/minitest/minitest) - Ruby testing framework
- [WebMock](https://github.com/bblimke/webmock) - HTTP request stubbing

</resources>
