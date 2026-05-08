---
name: Rails Conventions
description: This skill should be used when the user is working in a Rails 7+ application and asks about "Rails conventions", "naming conventions", "Rails structure", "Hotwire patterns", "Turbo frames", "Stimulus controllers", "Rails directory structure", "Rails best practices", or needs guidance on idiomatic Rails patterns for production systems.
version: 1.0.0
---

# Rails 7+ Conventions for Production Systems

Production-focused guidance for Rails 7+ conventions, naming patterns, directory structure, and modern frontend integration with Hotwire.

## Core Naming Conventions

### Models

- **Class names**: Singular, CamelCase (`User`, `OrderItem`, `PaymentTransaction`)
- **Table names**: Plural, snake_case (`users`, `order_items`, `payment_transactions`)
- **Foreign keys**: Singular model name + `_id` (`user_id`, `order_id`)
- **Join tables**: Alphabetical order, plural (`categories_products`, `roles_users`)

### Controllers

- **Class names**: Plural, CamelCase + Controller (`UsersController`, `Api::V1::OrdersController`)
- **Files**: Plural, snake_case (`users_controller.rb`, `api/v1/orders_controller.rb`)
- **RESTful actions**: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`

### Routes

Prefer resourceful routes over custom routes:

```ruby
# Production pattern
resources :orders do
  resources :line_items, shallow: true
  member do
    post :cancel
    post :refund
  end
  collection do
    get :pending
  end
end

# API versioning
namespace :api do
  namespace :v1 do
    resources :orders, only: [:index, :show, :create]
  end
end
```

### Views and Partials

- **Views**: `app/views/controller_name/action.html.erb`
- **Partials**: Prefix with underscore `_partial.html.erb`
- **Shared partials**: `app/views/shared/_partial.html.erb`
- **Component partials**: `app/views/components/_button.html.erb`

## Directory Structure

### Standard Rails 7 Layout

```
app/
├── assets/
│   └── stylesheets/
├── channels/           # ActionCable channels
├── controllers/
│   ├── concerns/       # Controller concerns
│   └── api/           # API controllers
├── helpers/
├── javascript/
│   └── controllers/   # Stimulus controllers
├── jobs/              # ActiveJob classes
├── mailers/
├── models/
│   └── concerns/      # Model concerns
├── views/
│   ├── layouts/
│   ├── shared/
│   └── components/    # View components (if using)
config/
├── initializers/
├── locales/
└── environments/
db/
├── migrate/
└── seeds.rb
lib/
├── tasks/             # Rake tasks
└── templates/         # Generator templates
spec/ or test/
```

### Service Objects

Place in `app/services/` with clear naming:

```ruby
# app/services/orders/create_service.rb
module Orders
  class CreateService
    def initialize(user:, cart:)
      @user = user
      @cart = cart
    end

    def call
      # Implementation
    end
  end
end

# Usage: Orders::CreateService.new(user: current_user, cart: @cart).call
```

### Query Objects

Place in `app/queries/`:

```ruby
# app/queries/orders/pending_query.rb
module Orders
  class PendingQuery
    def initialize(relation = Order.all)
      @relation = relation
    end

    def call
      @relation.where(status: :pending)
               .where("created_at > ?", 24.hours.ago)
               .includes(:line_items, :user)
    end
  end
end
```

## Hotwire Patterns (Rails 7+)

### Turbo Frames

Use for partial page updates without full navigation:

```erb
<%# Index page with inline editing %>
<%= turbo_frame_tag "orders" do %>
  <% @orders.each do |order| %>
    <%= turbo_frame_tag dom_id(order) do %>
      <%= render order %>
    <% end %>
  <% end %>
<% end %>

<%# Edit form that replaces the frame %>
<%= turbo_frame_tag dom_id(@order) do %>
  <%= render "form", order: @order %>
<% end %>
```

### Turbo Streams

Use for real-time updates and multi-element updates:

```ruby
# Controller action
def create
  @order = Order.create(order_params)

  respond_to do |format|
    format.turbo_stream
    format.html { redirect_to orders_path }
  end
end
```

```erb
<%# create.turbo_stream.erb %>
<%= turbo_stream.prepend "orders", @order %>
<%= turbo_stream.update "order_count", Order.count %>
```

### Stimulus Controllers

Naming convention: `controller-name_controller.js`

```javascript
// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  static values = { open: Boolean }

  toggle() {
    this.openValue = !this.openValue
  }

  openValueChanged() {
    this.menuTarget.classList.toggle("hidden", !this.openValue)
  }
}
```

```erb
<div data-controller="dropdown" data-dropdown-open-value="false">
  <button data-action="click->dropdown#toggle">Menu</button>
  <div data-dropdown-target="menu" class="hidden">
    <!-- Menu content -->
  </div>
</div>
```

## Configuration Patterns

### Credentials (Rails 7+)

```bash
# Edit credentials
bin/rails credentials:edit

# Environment-specific
bin/rails credentials:edit --environment production
```

Access pattern:

```ruby
Rails.application.credentials.dig(:aws, :access_key_id)
Rails.application.credentials.stripe[:secret_key]
```

### Environment Configuration

```ruby
# config/environments/production.rb
Rails.application.configure do
  config.force_ssl = true
  config.log_level = :info
  config.active_job.queue_adapter = :sidekiq
end
```

### Initializers

Name by feature, not gem:

```ruby
# config/initializers/stripe.rb (not payments.rb)
Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
```

## Production Patterns

### Strong Parameters

```ruby
def order_params
  params.require(:order).permit(
    :shipping_address_id,
    :notes,
    line_items_attributes: [:id, :product_id, :quantity, :_destroy]
  )
end
```

### Callbacks Best Practices

Avoid callback chains for business logic. Prefer service objects:

```ruby
# Avoid
class Order < ApplicationRecord
  after_create :send_confirmation, :update_inventory, :notify_warehouse
end

# Prefer
class Orders::CreateService
  def call
    Order.transaction do
      order = Order.create!(params)
      OrderMailer.confirmation(order).deliver_later
      Inventory::DeductService.new(order).call
      Warehouse::NotifyJob.perform_later(order.id)
      order
    end
  end
end
```

### Scopes

Define commonly used queries as scopes:

```ruby
class Order < ApplicationRecord
  scope :recent, -> { where("created_at > ?", 30.days.ago) }
  scope :pending, -> { where(status: :pending) }
  scope :with_items, -> { includes(:line_items) }
  scope :for_user, ->(user) { where(user: user) }
end
```

## Additional Resources

### Reference Files

For detailed patterns and examples:
- **`references/hotwire-patterns.md`** - Advanced Turbo and Stimulus patterns
- **`references/api-conventions.md`** - API versioning, serialization, authentication patterns
