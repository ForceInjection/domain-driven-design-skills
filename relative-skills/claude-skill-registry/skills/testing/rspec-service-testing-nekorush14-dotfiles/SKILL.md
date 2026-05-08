---
name: rspec-service-testing
description: Write RSpec tests for service objects testing business logic, transaction handling, and complex workflows. Use when testing service objects, form objects, or multi-step business processes following TDD.
---

# RSpec Service Testing Specialist

Specialized in writing comprehensive specs for service objects and business logic.

## When to Use This Skill

- Testing service object business logic
- Testing multi-step workflows
- Testing transaction behavior and rollbacks
- Testing error handling in services
- Testing Result object patterns
- Creating service specs before implementation (TDD)

## Core Principles

- **Test First**: Write service specs before implementing logic
- **Comprehensive**: Test success, failure, and edge cases
- **Isolation**: Mock external dependencies
- **Transaction Testing**: Verify rollback behavior
- **Result Objects**: Test structured return values

## Service Spec Structure

```ruby
# spec/services/order_processing_service_spec.rb
require 'rails_helper'

RSpec.describe OrderProcessingService do
    describe '#call' do
        let(:order) { create(:order) }
        let(:service) { described_class.new(order) }

        context 'with valid order' do
            # Success scenarios
        end

        context 'with invalid order' do
            # Failure scenarios
        end

        context 'when external service fails' do
            # Error handling tests
        end
    end
end
```

## Testing Service Success

```ruby
describe '#call' do
    let(:user) { create(:user) }
    let(:order) { create(:order, user: user) }
    let(:service) { described_class.new(order) }

    context 'with valid order' do
        before do
            create_list(:order_item, 2, order: order)
        end

        it 'returns success result' do
            result = service.call

            expect(result).to be_success
            expect(result.data).to eq(order)
        end

        it 'updates order status' do
            expect {
                service.call
            }.to change { order.reload.status }.from('pending').to('confirmed')
        end

        it 'charges payment' do
            expect(PaymentGateway).to receive(:charge).with(order)
            service.call
        end

        it 'updates inventory' do
            product = order.products.first
            expect {
                service.call
            }.to change { product.reload.stock }.by(-1)
        end

        it 'sends confirmation email' do
            expect {
                service.call
            }.to have_enqueued_job(OrderConfirmationJob).with(order.id)
        end

        it 'creates transaction log' do
            expect {
                service.call
            }.to change(TransactionLog, :count).by(1)
        end
    end
end
```

## Testing Service Failure

```ruby
context 'with invalid order' do
    let(:order) { create(:order, :empty) }

    it 'returns failure result' do
        result = service.call

        expect(result).to be_failure
        expect(result.error).to be_present
    end

    it 'does not change order status' do
        expect {
            service.call
        }.not_to change { order.reload.status }
    end

    it 'does not charge payment' do
        expect(PaymentGateway).not_to receive(:charge)
        service.call
    end

    it 'returns descriptive error message' do
        result = service.call

        expect(result.error).to include('Order must have items')
    end
end
```

## Testing Error Handling

```ruby
context 'when payment fails' do
    before do
        create_list(:order_item, 2, order: order)
        allow(PaymentGateway).to receive(:charge).and_raise(PaymentError, 'Insufficient funds')
    end

    it 'returns failure result' do
        result = service.call

        expect(result).to be_failure
        expect(result.error_type).to eq(:payment_failed)
    end

    it 'logs error' do
        expect(Rails.logger).to receive(:error).with(/PaymentError/)
        service.call
    end

    it 'does not update order status' do
        expect {
            service.call
        }.not_to change { order.reload.status }
    end
end
```

## Testing Transaction Rollback

```ruby
describe 'transaction rollback' do
    before do
        create_list(:order_item, 2, order: order)
        allow(PaymentGateway).to receive(:charge).and_raise(PaymentError)
    end

    it 'rolls back all changes on error' do
        initial_status = order.status
        initial_stock = order.products.first.stock

        service.call

        expect(order.reload.status).to eq(initial_status)
        expect(order.products.first.reload.stock).to eq(initial_stock)
    end

    it 'does not create transaction log on rollback' do
        expect {
            service.call
        }.not_to change(TransactionLog, :count)
    end
end
```

## Testing Service with Options

```ruby
describe 'service options' do
    it 'uses custom payment method' do
        service = described_class.new(order, payment_method: 'credit_card')

        expect(PaymentGateway).to receive(:charge).with(order, method: 'credit_card')
        service.call
    end

    it 'skips email when skip_email option is true' do
        service = described_class.new(order, skip_email: true)

        expect {
            service.call
        }.not_to have_enqueued_job(OrderConfirmationJob)
    end
end
```

## Testing Multiple Scenarios

```ruby
describe 'payment processing' do
    context 'when amount is under limit' do
        let(:order) { create(:order, total: 100) }

        it 'processes without additional verification' do
            expect(PaymentGateway).not_to receive(:verify)
            service.call
        end
    end

    context 'when amount exceeds limit' do
        let(:order) { create(:order, total: 10000) }

        it 'requires additional verification' do
            expect(PaymentGateway).to receive(:verify).with(order)
            service.call
        end
    end
end
```

## Testing Form Objects

```ruby
# spec/forms/user_registration_form_spec.rb
RSpec.describe UserRegistrationForm do
    describe '#save' do
        let(:valid_params) do
            {
                email: 'test@example.com',
                password: 'password123',
                password_confirmation: 'password123',
                terms_accepted: '1'
            }
        end

        let(:form) { described_class.new(valid_params) }

        context 'with valid parameters' do
            it 'creates a user' do
                expect {
                    form.save
                }.to change(User, :count).by(1)
            end

            it 'creates user profile' do
                expect {
                    form.save
                }.to change(UserProfile, :count).by(1)
            end

            it 'sends welcome email' do
                expect {
                    form.save
                }.to have_enqueued_job(WelcomeEmailJob)
            end

            it 'returns created user' do
                user = form.save
                expect(user).to be_a(User)
                expect(user).to be_persisted
            end
        end

        context 'with invalid parameters' do
            let(:invalid_form) { described_class.new(email: 'invalid') }

            it 'does not create user' do
                expect {
                    invalid_form.save
                }.not_to change(User, :count)
            end

            it 'returns false' do
                expect(invalid_form.save).to be false
            end

            it 'adds validation errors' do
                invalid_form.save
                expect(invalid_form.errors[:email]).to be_present
            end
        end
    end

    describe 'validations' do
        it { should validate_presence_of(:email) }
        it { should validate_presence_of(:password) }
        it { should validate_acceptance_of(:terms_accepted) }
    end
end
```

## Tools to Use

- `Write`: Create service spec files
- `Edit`: Update service specs
- `Bash`: Run service specs
- `Read`: Read service implementation

### Bash Commands

```bash
# Run all service specs
bundle exec rspec spec/services

# Run specific service spec
bundle exec rspec spec/services/order_processing_service_spec.rb
```

## Workflow

1. **Understand Business Logic**: Clarify service requirements
2. **Write Failing Tests**: Create specs for all scenarios
3. **Run Tests**: Confirm tests fail
4. **Commit Tests**: Commit test code
5. **Implementation**: Use `rails-service-objects` skill
6. **Verify**: Run tests and ensure they pass

## Related Skills

- `rails-service-objects`: For service implementation
- `rails-transactions`: For transaction logic
- `rails-error-handling`: For error handling
- `rspec-model-testing`: For testing underlying models

## RSpec Fundamentals

See [RSpec Testing Fundamentals](../_shared/rspec-testing-fundamentals.md)

## FactoryBot Guide

See [FactoryBot Guide](../_shared/factory-bot-guide.md)

## TDD Workflow

Follow [TDD Workflow](../_shared/rails-tdd-workflow.md)

## Key Reminders

- Test both success and failure paths
- Test transaction rollback behavior
- Mock external dependencies (payment, email, APIs)
- Test Result object structure
- Verify side effects (emails, logs, updates)
- Test edge cases and error conditions
- Keep tests independent
- Use descriptive context names
