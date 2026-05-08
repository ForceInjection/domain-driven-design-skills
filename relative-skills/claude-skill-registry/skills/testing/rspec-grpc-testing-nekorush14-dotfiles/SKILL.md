---
name: rspec-grpc-testing
description: Write RSpec tests for gRPC services testing unary/streaming RPC, error handling, and interceptors. Use when testing gRPC services following TDD.
---

# RSpec gRPC Testing Specialist

Specialized in writing comprehensive specs for gRPC services.

## When to Use This Skill

- Testing gRPC service implementations
- Testing unary and streaming RPC methods
- Testing error handling with gRPC status codes
- Testing gRPC interceptors
- Testing gRPC client implementations
- Creating gRPC specs before implementation (TDD)

## Core Principles

- **Test First**: Write specs before implementing service
- **Comprehensive**: Test success, failure, and edge cases
- **Isolation**: Mock external dependencies
- **Streaming**: Test all streaming patterns
- **Status Codes**: Verify correct gRPC error codes

## Service Spec Structure

```ruby
# spec/grpc/services/user_service_spec.rb
require 'rails_helper'

RSpec.describe GrpcServices::UserService do
    let(:service) { described_class.new }
    let(:call) { double('call', metadata: {}) }

    describe '#get_user' do
        # Test unary RPC
    end

    describe '#list_users' do
        # Test server streaming
    end
end
```

## Testing Unary RPC

```ruby
describe '#get_user' do
    let(:user) { create(:user) }
    let(:request) { UserService::GetUserRequest.new(id: user.id) }

    context 'when user exists' do
        it 'returns user details' do
            response = service.get_user(request, call)

            expect(response).to be_a(UserService::GetUserResponse)
            expect(response.id).to eq(user.id)
            expect(response.email).to eq(user.email)
        end
    end

    context 'when user not found' do
        let(:request) { UserService::GetUserRequest.new(id: 99999) }

        it 'raises NotFound error' do
            expect {
                service.get_user(request, call)
            }.to raise_error(GRPC::NotFound, /User not found/)
        end
    end

    context 'when database error occurs' do
        before do
            allow(User).to receive(:find).and_raise(StandardError)
        end

        it 'raises Internal error' do
            expect {
                service.get_user(request, call)
            }.to raise_error(GRPC::Internal)
        end
    end
end
```

## Testing Create Operations

```ruby
describe '#create_user' do
    let(:params) { { email: 'new@example.com', name: 'New User' } }
    let(:request) { UserService::CreateUserRequest.new(params) }

    context 'with valid parameters' do
        it 'creates user' do
            expect {
                service.create_user(request, call)
            }.to change(User, :count).by(1)
        end

        it 'returns user id' do
            response = service.create_user(request, call)

            expect(response.id).to be_present
            expect(User.find(response.id)).to be_present
        end
    end

    context 'with invalid parameters' do
        let(:request) { UserService::CreateUserRequest.new(email: 'invalid') }

        it 'raises InvalidArgument error' do
            expect {
                service.create_user(request, call)
            }.to raise_error(GRPC::InvalidArgument)
        end

        it 'does not create user' do
            expect {
                begin
                    service.create_user(request, call)
                rescue GRPC::InvalidArgument
                    # Expected
                end
            }.not_to change(User, :count)
        end
    end
end
```

## Testing Server Streaming

```ruby
describe '#list_users' do
    let!(:users) { create_list(:user, 3) }
    let(:request) { UserService::ListUsersRequest.new }

    it 'yields user responses' do
        responses = []
        service.list_users(request, call) do |response|
            responses << response
        end

        expect(responses.size).to eq(3)
        expect(responses.first).to be_a(UserService::UserResponse)
    end

    it 'includes correct user data' do
        responses = []
        service.list_users(request, call) { |r| responses << r }

        first_response = responses.find { |r| r.id == users.first.id }
        expect(first_response.email).to eq(users.first.email)
    end
end
```

## Testing Bidirectional Streaming

```ruby
describe '#stream_user_updates' do
    let!(:users) { create_list(:user, 2) }

    it 'processes requests and yields responses' do
        requests = users.map do |user|
            UserService::UserUpdateRequest.new(id: user.id, name: "Updated #{user.name}")
        end

        responses = []
        service.stream_user_updates(requests, call) { |r| responses << r }

        expect(responses.size).to eq(2)
        expect(responses).to all(have_attributes(success: true))
    end

    it 'updates user names' do
        requests = [
            UserService::UserUpdateRequest.new(id: users.first.id, name: 'New Name')
        ]

        service.stream_user_updates(requests, call) { |_| }

        expect(users.first.reload.name).to eq('New Name')
    end

    context 'when user not found' do
        it 'yields failure response' do
            requests = [UserService::UserUpdateRequest.new(id: 99999, name: 'Invalid')]

            responses = []
            service.stream_user_updates(requests, call) { |r| responses << r }

            expect(responses.first.success).to be false
            expect(responses.first.error).to include('User not found')
        end
    end
end
```

## Testing gRPC Client

```ruby
# spec/grpc/clients/user_client_spec.rb
RSpec.describe GrpcClients::UserClient do
    let(:client) { described_class.new }
    let(:stub) { instance_double(UserService::Stub) }

    before do
        allow(UserService::Stub).to receive(:new).and_return(stub)
    end

    describe '#get_user' do
        let(:response) do
            UserService::GetUserResponse.new(id: 1, email: 'test@example.com')
        end

        context 'when user exists' do
            before do
                allow(stub).to receive(:get_user).and_return(response)
            end

            it 'returns user response' do
                result = client.get_user(1)

                expect(result).to eq(response)
            end

            it 'calls stub with timeout' do
                expect(stub).to receive(:get_user) do |request, options|
                    expect(request.id).to eq(1)
                    expect(options[:deadline]).to be_present
                    response
                end

                client.get_user(1)
            end
        end

        context 'when user not found' do
            before do
                allow(stub).to receive(:get_user).and_raise(GRPC::NotFound)
            end

            it 'returns nil' do
                expect(client.get_user(1)).to be_nil
            end
        end

        context 'when gRPC error' do
            before do
                allow(stub).to receive(:get_user).and_raise(GRPC::Internal)
            end

            it 'raises error' do
                expect { client.get_user(1) }.to raise_error(GRPC::Internal)
            end
        end
    end
end
```

## Testing Interceptors

```ruby
# spec/grpc/interceptors/authentication_interceptor_spec.rb
RSpec.describe GrpcInterceptors::AuthenticationInterceptor do
    let(:interceptor) { described_class.new }
    let(:call) { double('call', metadata: metadata) }
    let(:method) { double('method') }

    describe '#request_response' do
        context 'with valid token' do
            let(:user) { create(:user) }
            let(:token) { JWT.encode({ user_id: user.id }, Rails.application.secrets.secret_key_base) }
            let(:metadata) { { 'authorization' => "Bearer #{token}" } }

            it 'allows request' do
                expect {
                    interceptor.request_response(request: nil, call: call, method: method) { 'success' }
                }.not_to raise_error
            end

            it 'sets user_id in metadata' do
                interceptor.request_response(request: nil, call: call, method: method) { }
                expect(call.metadata['user_id']).to eq(user.id.to_s)
            end
        end

        context 'without token' do
            let(:metadata) { {} }

            it 'raises Unauthenticated error' do
                expect {
                    interceptor.request_response(request: nil, call: call, method: method) { }
                }.to raise_error(GRPC::Unauthenticated, /Missing token/)
            end
        end

        context 'with invalid token' do
            let(:metadata) { { 'authorization' => 'Bearer invalid' } }

            it 'raises Unauthenticated error' do
                expect {
                    interceptor.request_response(request: nil, call: call, method: method) { }
                }.to raise_error(GRPC::Unauthenticated, /Invalid token/)
            end
        end
    end
end
```

## Tools to Use

- `Write`: Create gRPC spec files
- `Edit`: Update specs
- `Bash`: Run specs
- `Read`: Read service implementation

### Bash Commands

```bash
# Run all gRPC specs
bundle exec rspec spec/grpc

# Run specific service spec
bundle exec rspec spec/grpc/services/user_service_spec.rb

# Run client specs
bundle exec rspec spec/grpc/clients
```

## Workflow

1. **Review Contract**: Check .proto file
2. **Write Failing Tests**: Create specs for all RPC methods
3. **Test All Patterns**: Cover unary, streaming, errors
4. **Run Tests**: Confirm tests fail
5. **Commit Tests**: Commit test code
6. **Implementation**: Use `rails-grpc-implementation` skill
7. **Verify**: Run tests and ensure pass

## Related Skills

- `rails-grpc-implementation`: For gRPC service implementation
- `rails-error-handling`: For error handling patterns
- `rspec-request-testing`: For HTTP API testing patterns

## RSpec Fundamentals

See [RSpec Testing Fundamentals](../_shared/rspec-testing-fundamentals.md)

## FactoryBot Guide

See [FactoryBot Guide](../_shared/factory-bot-guide.md)

## TDD Workflow

Follow [TDD Workflow](../_shared/rails-tdd-workflow.md)

## Key Reminders

- Test all RPC patterns (unary, streaming)
- Test success and failure with proper status codes
- Mock gRPC stubs in client tests
- Test interceptors separately
- Verify error handling and logging
- Test streaming with proper yielding
- Keep tests independent
- Use descriptive context names
