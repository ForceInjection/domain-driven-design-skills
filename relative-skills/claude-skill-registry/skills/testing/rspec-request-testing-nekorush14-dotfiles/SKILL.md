---
name: rspec-request-testing
description: Write RSpec request specs for testing API endpoints, HTTP responses, authentication, and request/response handling. Use when testing controllers, API endpoints, or HTTP interactions following TDD.
---

# RSpec Request Testing Specialist

Specialized in writing request specs for API endpoints and controller actions.

## When to Use This Skill

- Testing API endpoints (GET, POST, PUT, DELETE)
- Testing HTTP status codes and response formats
- Testing authentication and authorization
- Testing request parameters and headers
- Testing JSON/XML response structure
- Creating request specs before implementation (TDD)

## Core Principles

- **Test First**: Write request specs before implementing endpoints
- **Full Stack**: Test complete request/response cycle
- **Authentication**: Test both authenticated and unauthenticated scenarios
- **Error Handling**: Test error responses and edge cases
- **Response Format**: Verify JSON structure and content

## Request Spec Structure

```ruby
# spec/requests/api/v1/users_spec.rb
require 'rails_helper'

RSpec.describe 'API::V1::Users', type: :request do
    describe 'GET /api/v1/users' do
        context 'when authenticated' do
            # Authenticated tests
        end

        context 'when not authenticated' do
            # Unauthenticated tests
        end
    end

    describe 'POST /api/v1/users' do
        context 'with valid parameters' do
            # Valid parameter tests
        end

        context 'with invalid parameters' do
            # Invalid parameter tests
        end
    end
end
```

## Testing GET Requests

```ruby
describe 'GET /api/v1/users' do
    let(:user) { create(:user) }
    let(:headers) { { 'Authorization' => "Bearer #{user.token}" } }

    before do
        create_list(:user, 3)
    end

    it 'returns list of users' do
        get '/api/v1/users', headers: headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['users'].size).to eq(4)
    end

    it 'returns users with correct attributes' do
        get '/api/v1/users', headers: headers

        user_data = JSON.parse(response.body)['users'].first
        expect(user_data).to include('id', 'email', 'name')
        expect(user_data).not_to include('password_digest')
    end

    it 'supports pagination' do
        get '/api/v1/users', params: { page: 1, per_page: 2 }, headers: headers

        expect(JSON.parse(response.body)['users'].size).to eq(2)
    end
end
```

## Testing POST Requests

```ruby
describe 'POST /api/v1/users' do
    let(:valid_params) do
        {
            user: {
                email: 'test@example.com',
                password: 'password123',
                name: 'Test User'
            }
        }
    end

    context 'with valid parameters' do
        it 'creates a new user' do
            expect {
                post '/api/v1/users', params: valid_params
            }.to change(User, :count).by(1)
        end

        it 'returns created status' do
            post '/api/v1/users', params: valid_params

            expect(response).to have_http_status(:created)
        end

        it 'returns user data' do
            post '/api/v1/users', params: valid_params

            user_data = JSON.parse(response.body)['user']
            expect(user_data['email']).to eq('test@example.com')
        end
    end

    context 'with invalid parameters' do
        let(:invalid_params) do
            { user: { email: 'invalid', password: '123' } }
        end

        it 'does not create a user' do
            expect {
                post '/api/v1/users', params: invalid_params
            }.not_to change(User, :count)
        end

        it 'returns unprocessable entity status' do
            post '/api/v1/users', params: invalid_params

            expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns error messages' do
            post '/api/v1/users', params: invalid_params

            errors = JSON.parse(response.body)['errors']
            expect(errors).to be_present
        end
    end
end
```

## Testing PUT/PATCH Requests

```ruby
describe 'PUT /api/v1/users/:id' do
    let(:user) { create(:user) }
    let(:headers) { { 'Authorization' => "Bearer #{user.token}" } }

    context 'with valid parameters' do
        it 'updates the user' do
            put "/api/v1/users/#{user.id}",
                params: { user: { name: 'New Name' } },
                headers: headers

            expect(response).to have_http_status(:ok)
            expect(user.reload.name).to eq('New Name')
        end
    end

    context 'when unauthorized' do
        let(:other_user) { create(:user) }

        it 'returns forbidden status' do
            put "/api/v1/users/#{other_user.id}",
                params: { user: { name: 'New Name' } },
                headers: headers

            expect(response).to have_http_status(:forbidden)
        end
    end
end
```

## Testing DELETE Requests

```ruby
describe 'DELETE /api/v1/users/:id' do
    let(:user) { create(:user) }
    let(:headers) { { 'Authorization' => "Bearer #{user.token}" } }

    it 'deletes the user' do
        delete "/api/v1/users/#{user.id}", headers: headers

        expect(response).to have_http_status(:no_content)
        expect(User.find_by(id: user.id)).to be_nil
    end

    context 'when user does not exist' do
        it 'returns not found status' do
            delete '/api/v1/users/99999', headers: headers

            expect(response).to have_http_status(:not_found)
        end
    end
end
```

## Testing Authentication

```ruby
shared_examples 'requires authentication' do
    it 'returns unauthorized without token' do
        make_request

        expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized with invalid token' do
        make_request(headers: { 'Authorization' => 'Bearer invalid' })

        expect(response).to have_http_status(:unauthorized)
    end
end

describe 'GET /api/v1/protected_resource' do
    def make_request(headers: {})
        get '/api/v1/protected_resource', headers: headers
    end

    it_behaves_like 'requires authentication'

    context 'when authenticated' do
        let(:user) { create(:user) }
        let(:headers) { { 'Authorization' => "Bearer #{user.token}" } }

        it 'returns protected data' do
            get '/api/v1/protected_resource', headers: headers

            expect(response).to have_http_status(:ok)
        end
    end
end
```

## Testing JSON Responses

```ruby
describe 'response format' do
    it 'returns JSON content type' do
        get '/api/v1/users', headers: headers

        expect(response.content_type).to include('application/json')
    end

    it 'has correct JSON structure' do
        get '/api/v1/users', headers: headers

        json = JSON.parse(response.body)
        expect(json).to have_key('users')
        expect(json).to have_key('meta')
    end

    it 'includes pagination metadata' do
        get '/api/v1/users', headers: headers

        meta = JSON.parse(response.body)['meta']
        expect(meta).to include('total_count', 'page', 'per_page')
    end
end
```

## Testing Query Parameters

```ruby
describe 'filtering' do
    before do
        create(:user, role: 'admin')
        create(:user, role: 'guest')
    end

    it 'filters by role' do
        get '/api/v1/users', params: { role: 'admin' }, headers: headers

        users = JSON.parse(response.body)['users']
        expect(users.all? { |u| u['role'] == 'admin' }).to be true
    end

    it 'searches by name' do
        john = create(:user, name: 'John Doe')
        jane = create(:user, name: 'Jane Smith')

        get '/api/v1/users', params: { q: 'John' }, headers: headers

        user_ids = JSON.parse(response.body)['users'].map { |u| u['id'] }
        expect(user_ids).to include(john.id)
        expect(user_ids).not_to include(jane.id)
    end
end
```

## Tools to Use

- `Write`: Create request spec files
- `Edit`: Update request specs
- `Bash`: Run request specs
- `Read`: Read controller/API code

### Bash Commands

```bash
# Run all request specs
bundle exec rspec spec/requests

# Run specific request spec
bundle exec rspec spec/requests/api/v1/users_spec.rb
```

## Workflow

1. **Define API Contract**: Understand endpoint requirements
2. **Write Failing Tests**: Create specs for all scenarios
3. **Run Tests**: Confirm tests fail
4. **Commit Tests**: Commit test code
5. **Implementation**: Implement controller/API
6. **Verify**: Run tests and ensure they pass

## Related Skills

- `rails-security`: For authentication/authorization implementation
- `rails-error-handling`: For error response implementation
- `rspec-model-testing`: For testing underlying models

## RSpec Fundamentals

See [RSpec Testing Fundamentals](../_shared/rspec-testing-fundamentals.md)

## FactoryBot Guide

See [FactoryBot Guide](../_shared/factory-bot-guide.md)

## TDD Workflow

Follow [TDD Workflow](../_shared/rails-tdd-workflow.md)

## Key Reminders

- Test all HTTP methods (GET, POST, PUT, DELETE)
- Test authentication and authorization
- Test both success and error responses
- Verify HTTP status codes
- Test JSON structure and content
- Test query parameters and filtering
- Test pagination
- Keep tests independent
- Mock external API calls
