---
name: rails-workflow
description: Ruby on Rails framework workflow guidelines. Activate when working with Rails projects, Gemfile with rails, rake tasks, or Rails-specific patterns.
location: user
---

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

# Rails Workflow

## Tool Grid

| Task | Tool | Command |
|------|------|---------|
| Lint | StandardRB + standard-rails | `bundle exec standardrb` |
| Security | Brakeman | `bundle exec brakeman` |
| Test | RSpec Rails | `bundle exec rspec` |
| Console | Rails | `bundle exec rails console` |
| Server | Rails | `bundle exec rails server` |
| Routes | Rails | `bundle exec rails routes` |

## Rails 8.x Features

### Built-in Authentication
```bash
bundle exec rails generate authentication
```
Creates User with `password_digest`, Session controller, and authentication concern. You SHOULD use built-in auth for new projects.

### Solid Queue (Background Jobs)
Database-backed, no Redis required. Rails 8 default.
```ruby
config.active_job.queue_adapter = :solid_queue
```

### Solid Cache & Solid Cable
Database-backed caching and Action Cable adapter:
```ruby
config.cache_store = :solid_cache_store  # production.rb
adapter: solid_cable  # cable.yml
```

## Controller Patterns

Controllers MUST delegate business logic to service objects:
```ruby
# GOOD - Thin controller
def create
  result = Orders::CreateService.call(order_params, current_user)
  result.success? ? redirect_to(result.order) : render(:new, status: :unprocessable_entity)
end
```

### Strong Parameters
You MUST use strong parameters. NEVER use `params.permit!` in production:
```ruby
def user_params
  params.require(:user).permit(:name, :email, address_attributes: [:street, :city])
end
```

## Service Objects

Services MUST follow a consistent pattern:
```ruby
module Orders
  class CreateService
    Result = Struct.new(:success?, :order, :errors, keyword_init: true)

    def self.call(...) = new(...).call

    def initialize(params, user)
      @params, @user = params, user
    end

    def call
      order = Order.new(@params.merge(user: @user, status: :pending))
      order.save ? Result.new(success?: true, order:) : Result.new(success?: false, order:, errors: order.errors)
    end
  end
end
```

Naming: `CreateService`, `UpdateService`, `ProcessService`, `SyncService`

## Model Organization

Models SHOULD follow this order:
```ruby
class User < ApplicationRecord
  # 1. Constants
  ROLES = %w[admin member guest].freeze

  # 2. Associations
  belongs_to :organization
  has_many :posts, dependent: :destroy

  # 3. Validations
  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: ROLES }

  # 4. Callbacks (use sparingly)
  after_create :send_welcome_email

  # 5. Scopes
  scope :active, -> { where(active: true) }
  scope :admins, -> { where(role: "admin") }

  # 6. Class methods
  # 7. Instance methods
end
```

For complex queries, extract to query objects in `app/queries/`.

## Security

### Brakeman
You MUST run Brakeman before deployment. All warnings MUST be resolved:
```bash
bundle exec brakeman --no-pager
```

### Common Patterns
```ruby
# SQL injection prevention - use parameterized queries
User.where("email = ?", params[:email])  # GOOD
User.where("email = '#{params[:email]}'")  # BAD

# XSS - Rails auto-escapes. Use sanitize for HTML content
<%= sanitize @user.bio %>
```

## Background Jobs

```ruby
class ProcessOrderJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 5
  discard_on ActiveRecord::RecordNotFound

  def perform(order_id)
    Orders::ProcessService.call(Order.find(order_id))
  end
end
```

## Action Cable

```ruby
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end

# Broadcasting
NotificationsChannel.broadcast_to(user, { type: "new_message", content: message.body })
```

## View Components

```ruby
class ButtonComponent < ViewComponent::Base
  def initialize(text:, variant: :primary)
    @text, @variant = text, variant
  end

  def call
    tag.button(@text, class: "btn btn-#{@variant}")
  end
end
```

## Hotwire / Stimulus

### Turbo Frames
```erb
<%= turbo_frame_tag "user_stats", src: user_stats_path, loading: :lazy %>
```

### Turbo Streams
```ruby
respond_to do |format|
  format.turbo_stream
  format.html { redirect_to @post }
end
```
```erb
<%= turbo_stream.prepend "comments", @comment %>
```

### Stimulus Controllers
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output"]

  validate() {
    this.outputTarget.textContent = this.inputTarget.value.length > 0 ? "Valid" : "Required"
  }
}
```
```erb
<div data-controller="form">
  <input data-form-target="input" data-action="input->form#validate">
  <span data-form-target="output"></span>
</div>
```

## Testing

### Model Specs
```ruby
RSpec.describe User, type: :model do
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to have_many(:posts).dependent(:destroy) }
end
```

### Request Specs
```ruby
RSpec.describe "Posts", type: :request do
  it "creates a post" do
    sign_in(user)
    expect { post posts_path, params: { post: valid_attributes } }.to change(Post, :count).by(1)
  end
end
```

## Database

You MUST use reversible migrations:
```ruby
class AddStatusToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :status, :string, default: "pending", null: false
    add_index :orders, :status
  end
end
```

## File Structure

```
app/
  channels/
  components/
  controllers/
  jobs/
  models/
  queries/
  services/
  views/
config/
  solid_queue.yml
  cable.yml
spec/
  factories/
  models/
  requests/
  services/
```
