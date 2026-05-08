---
name: sinatra-security
description: Security best practices for Sinatra applications including input validation, CSRF protection, and authentication patterns. Use when hardening applications or conducting security reviews.
---

# Sinatra Security Skill

## Tier 1: Quick Reference - Essential Security

### CSRF Protection

```ruby
# Enable Rack::Protection
use Rack::Protection

# Or specifically CSRF
use Rack::Protection::AuthenticityToken
```

### XSS Prevention

```ruby
# In ERB templates - always escape by default
<%= user.bio %>          # Escaped (safe)
<%== user.bio %>         # Raw (dangerous!)

# In JSON responses - use proper JSON encoding
require 'json'
json({ name: user.name }.to_json)
```

### SQL Injection Prevention

```ruby
# BAD: String interpolation
DB["SELECT * FROM users WHERE email = '#{email}'"]

# GOOD: Parameterized queries
DB["SELECT * FROM users WHERE email = ?", email]

# GOOD: Hash conditions
User.where(email: email)
```

### Secure Sessions

```ruby
use Rack::Session::Cookie,
  secret: ENV['SESSION_SECRET'],  # Long random string
  same_site: :strict,
  httponly: true,
  secure: production?
```

### Input Validation

```ruby
helpers do
  def validate_email(email)
    email.to_s.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def validate_integer(value)
    Integer(value)
  rescue ArgumentError, TypeError
    nil
  end
end

post '/users' do
  halt 400, 'Invalid email' unless validate_email(params[:email])
  # Process...
end
```

### Authentication Check

```ruby
helpers do
  def authenticate!
    halt 401, json({ error: 'Unauthorized' }) unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end

before '/admin/*' do
  authenticate!
end
```

---

## Tier 2: Detailed Instructions - Security Implementation

### Comprehensive CSRF Protection

**Configuration:**
```ruby
class Application < Sinatra::Base
  # Enable CSRF protection
  use Rack::Protection::AuthenticityToken,
    except: [:json],  # Skip for JSON APIs with token auth
    allow_if: -> (env) {
      # Skip for API endpoints with bearer token
      env['HTTP_AUTHORIZATION']&.start_with?('Bearer ')
    }

  # Manual CSRF token generation
  helpers do
    def csrf_token
      session[:csrf] ||= SecureRandom.hex(32)
    end

    def csrf_tag
      "<input type='hidden' name='authenticity_token' value='#{csrf_token}'>"
    end

    def verify_csrf_token
      token = params[:authenticity_token] || request.env['HTTP_X_CSRF_TOKEN']
      halt 403, 'Invalid CSRF token' unless token == session[:csrf]
    end
  end

  # Include in forms
  post '/users' do
    verify_csrf_token unless request.content_type == 'application/json'
    # Process...
  end
end
```

**In Views:**
```erb
<form method="POST" action="/users">
  <%= csrf_tag %>
  <!-- form fields -->
</form>
```

**For AJAX:**
```javascript
// Include CSRF token in AJAX requests
fetch('/users', {
  method: 'POST',
  headers: {
    'X-CSRF-Token': document.querySelector('[name=csrf_token]').value,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
});
```

### XSS Prevention Strategies

**Template Escaping:**
```ruby
# ERB - escape by default
<div><%= user_input %></div>

# Explicitly raw (only for trusted content)
<div><%== trusted_html %></div>

# Sanitize user HTML
require 'sanitize'

helpers do
  def sanitize_html(html)
    Sanitize.fragment(html, Sanitize::Config::RELAXED)
  end
end

# In template
<div><%= sanitize_html(user_bio) %></div>
```

**JSON Responses:**
```ruby
# Always use proper JSON encoding
get '/api/users/:id' do
  user = User.find(params[:id])

  # BAD: Manual JSON construction
  # "{ \"name\": \"#{user.name}\" }"  # XSS if name contains quotes

  # GOOD: Use JSON library
  content_type :json
  { name: user.name, bio: user.bio }.to_json
end
```

**Content Security Policy:**
```ruby
class Application < Sinatra::Base
  before do
    headers 'Content-Security-Policy' => [
      "default-src 'self'",
      "script-src 'self' https://cdn.example.com",
      "style-src 'self' 'unsafe-inline'",
      "img-src 'self' data: https:",
      "font-src 'self'",
      "connect-src 'self'",
      "frame-ancestors 'none'"
    ].join('; ')
  end
end
```

### SQL Injection Prevention

**Parameterized Queries:**
```ruby
# Sequel
# BAD
DB["SELECT * FROM users WHERE name = '#{name}'"]

# GOOD
DB["SELECT * FROM users WHERE name = ?", name]
DB["SELECT * FROM users WHERE name = :name", name: name]

# ActiveRecord
# BAD
User.where("email = '#{email}'")

# GOOD
User.where(email: email)
User.where("email = ?", email)
User.where("email = :email", email: email)
```

**Input Validation:**
```ruby
helpers do
  def validate_sql_param(param, type: :string)
    case type
    when :integer
      Integer(param)
    when :boolean
      [true, 'true', '1', 1].include?(param)
    when :string
      param.to_s.gsub(/['";\\]/, '')  # Remove dangerous chars
    else
      param
    end
  rescue ArgumentError
    halt 400, 'Invalid parameter'
  end
end

get '/users/:id' do
  id = validate_sql_param(params[:id], type: :integer)
  user = User.find(id)
  json user.to_hash
end
```

### Authentication Patterns

**Password Authentication:**
```ruby
require 'bcrypt'

class User
  include BCrypt

  def password=(new_password)
    @password_hash = Password.create(new_password)
  end

  def password_hash
    @password_hash
  end

  def authenticate(password)
    Password.new(password_hash) == password
  end
end

# Registration
post '/register' do
  user = User.new(
    email: params[:email],
    name: params[:name]
  )
  user.password = params[:password]
  user.save

  session[:user_id] = user.id
  redirect '/dashboard'
end

# Login
post '/login' do
  user = User.find_by(email: params[:email])

  if user&.authenticate(params[:password])
    session[:user_id] = user.id
    session[:logged_in_at] = Time.now.to_i

    redirect '/dashboard'
  else
    halt 401, 'Invalid credentials'
  end
end
```

**Token-Based Authentication:**
```ruby
require 'jwt'

class TokenAuth
  SECRET = ENV['JWT_SECRET']

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET, 'HS256')
  end

  def self.decode(token)
    body = JWT.decode(token, SECRET, true, algorithm: 'HS256')[0]
    HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end

# Middleware
class JWTAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    auth_header = env['HTTP_AUTHORIZATION']
    token = auth_header&.split(' ')&.last

    if payload = TokenAuth.decode(token)
      env['current_user_id'] = payload[:user_id]
      @app.call(env)
    else
      [401, { 'Content-Type' => 'application/json' },
       ['{"error": "Unauthorized"}']]
    end
  end
end

# Login endpoint
post '/api/login' do
  user = User.find_by(email: params[:email])

  if user&.authenticate(params[:password])
    token = TokenAuth.encode(user_id: user.id)
    json({ token: token, user: user.to_hash })
  else
    halt 401, json({ error: 'Invalid credentials' })
  end
end

# Protected routes
class API < Sinatra::Base
  use JWTAuth

  helpers do
    def current_user
      @current_user ||= User.find(request.env['current_user_id'])
    end
  end

  get '/profile' do
    json current_user.to_hash
  end
end
```

**API Key Authentication:**
```ruby
class APIKeyAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    api_key = env['HTTP_X_API_KEY']

    if valid_api_key?(api_key)
      user = User.find_by(api_key: api_key)
      env['current_user'] = user
      @app.call(env)
    else
      [401, { 'Content-Type' => 'application/json' },
       ['{"error": "Invalid API key"}']]
    end
  end

  private

  def valid_api_key?(key)
    key && User.exists?(api_key: key, active: true)
  end
end

use APIKeyAuth

# Generate API keys
helpers do
  def generate_api_key
    SecureRandom.hex(32)
  end
end

post '/api/keys' do
  authenticate!
  api_key = generate_api_key
  current_user.update(api_key: api_key)
  json({ api_key: api_key })
end
```

### Authorization Patterns

**Role-Based Access Control:**
```ruby
class User
  ROLES = [:guest, :user, :admin, :superadmin]

  def has_role?(role)
    ROLES.index(self.role) >= ROLES.index(role)
  end

  def can?(action, resource)
    case role
    when :admin, :superadmin
      true
    when :user
      action == :read || resource.user_id == id
    else
      action == :read
    end
  end
end

helpers do
  def authorize!(action, resource)
    unless current_user&.can?(action, resource)
      halt 403, json({ error: 'Forbidden' })
    end
  end
end

# Usage
get '/posts/:id' do
  post = Post.find(params[:id])
  authorize!(:read, post)
  json post.to_hash
end

delete '/posts/:id' do
  post = Post.find(params[:id])
  authorize!(:delete, post)
  post.destroy
  status 204
end
```

**Permission-Based Authorization:**
```ruby
class Permission
  ACTIONS = {
    posts: [:create, :read, :update, :delete],
    users: [:read, :update, :delete],
    comments: [:create, :read, :delete]
  }

  def self.check(user, action, resource_type)
    return false unless user

    permissions = user.permissions
    permissions.include?("#{resource_type}:#{action}") ||
      permissions.include?("#{resource_type}:*") ||
      permissions.include?("*:*")
  end
end

helpers do
  def can?(action, resource_type)
    Permission.check(current_user, action, resource_type)
  end

  def authorize!(action, resource_type)
    unless can?(action, resource_type)
      halt 403, json({ error: 'Forbidden' })
    end
  end
end

post '/posts' do
  authorize!(:create, :posts)
  # Create post
end
```

### Rate Limiting

**Using Rack::Attack:**
```ruby
require 'rack/attack'

class Rack::Attack
  # Throttle login attempts
  throttle('login/ip', limit: 5, period: 60) do |req|
    req.ip if req.path == '/login' && req.post?
  end

  # Throttle API requests by API key
  throttle('api/key', limit: 100, period: 60) do |req|
    req.env['HTTP_X_API_KEY'] if req.path.start_with?('/api')
  end

  # Throttle by IP
  throttle('req/ip', limit: 300, period: 60) do |req|
    req.ip
  end

  # Block known bad actors
  blocklist('block bad IPs') do |req|
    BadIP.blocked?(req.ip)
  end

  # Custom response
  self.throttled_responder = lambda do |env|
    [
      429,
      { 'Content-Type' => 'application/json' },
      [{ error: 'Rate limit exceeded' }.to_json]
    ]
  end
end

use Rack::Attack
```

### Secure File Uploads

```ruby
require 'securerandom'

class FileUploadHandler
  ALLOWED_TYPES = {
    'image/jpeg' => '.jpg',
    'image/png' => '.png',
    'image/gif' => '.gif',
    'application/pdf' => '.pdf'
  }

  MAX_SIZE = 5 * 1024 * 1024  # 5MB

  def self.process(file)
    # Validate file presence
    return { error: 'No file provided' } unless file

    # Validate file size
    if file[:tempfile].size > MAX_SIZE
      return { error: 'File too large' }
    end

    # Validate content type
    content_type = file[:type]
    unless ALLOWED_TYPES.key?(content_type)
      return { error: 'Invalid file type' }
    end

    # Sanitize filename
    original_name = File.basename(file[:filename])
    sanitized_name = original_name.gsub(/[^a-zA-Z0-9\._-]/, '')

    # Generate unique filename
    extension = ALLOWED_TYPES[content_type]
    unique_name = "#{SecureRandom.hex(16)}#{extension}"

    # Save file
    upload_dir = 'uploads'
    FileUtils.mkdir_p(upload_dir)
    path = File.join(upload_dir, unique_name)

    File.open(path, 'wb') do |f|
      f.write(file[:tempfile].read)
    end

    { success: true, path: path, filename: unique_name }
  end
end

post '/upload' do
  result = FileUploadHandler.process(params[:file])

  if result[:error]
    halt 400, json({ error: result[:error] })
  else
    json({ url: "/uploads/#{result[:filename]}" })
  end
end
```

---

## Tier 3: Resources & Examples

### Security Headers

**Comprehensive Security Headers:**
```ruby
class SecurityHeaders
  HEADERS = {
    'X-Frame-Options' => 'DENY',
    'X-Content-Type-Options' => 'nosniff',
    'X-XSS-Protection' => '1; mode=block',
    'Referrer-Policy' => 'strict-origin-when-cross-origin',
    'Permissions-Policy' => 'geolocation=(), microphone=(), camera=()',
    'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains'
  }

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    headers.merge!(HEADERS)
    [status, headers, body]
  end
end

use SecurityHeaders
```

### OWASP Security Checklist

See `assets/owasp-checklist.md` for complete checklist covering:

1. **Injection Prevention**
   - SQL Injection
   - Command Injection
   - LDAP Injection
   - XML Injection

2. **Broken Authentication**
   - Password policies
   - Session management
   - Multi-factor authentication
   - Account lockout

3. **Sensitive Data Exposure**
   - Encryption at rest
   - Encryption in transit (HTTPS)
   - Secure key storage
   - Data minimization

4. **XML External Entities (XXE)**
   - XML parser configuration
   - Disable external entity processing

5. **Broken Access Control**
   - Authentication on all protected routes
   - Authorization checks
   - IDOR prevention
   - CORS configuration

6. **Security Misconfiguration**
   - Remove default credentials
   - Disable directory listing
   - Error message handling
   - Keep dependencies updated

7. **Cross-Site Scripting (XSS)**
   - Output encoding
   - Input validation
   - Content Security Policy
   - HTTPOnly cookies

8. **Insecure Deserialization**
   - Validate serialized data
   - Use safe serialization formats
   - Sign serialized data

9. **Using Components with Known Vulnerabilities**
   - Regular dependency updates
   - Security audits (bundle audit)
   - Monitor CVE databases

10. **Insufficient Logging & Monitoring**
    - Log security events
    - Monitor for attacks
    - Alerting systems
    - Log rotation and retention

### Security Testing Examples

**Testing Authentication:**
```ruby
RSpec.describe 'Authentication' do
  describe 'POST /login' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    it 'succeeds with valid credentials' do
      post '/login', { email: 'test@example.com', password: 'password123' }.to_json,
        'CONTENT_TYPE' => 'application/json'

      expect(last_response).to be_ok
      expect(json_response).to have_key('token')
    end

    it 'fails with invalid password' do
      post '/login', { email: 'test@example.com', password: 'wrong' }.to_json,
        'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(401)
    end

    it 'prevents brute force attacks' do
      6.times do
        post '/login', { email: 'test@example.com', password: 'wrong' }.to_json,
          'CONTENT_TYPE' => 'application/json'
      end

      expect(last_response.status).to eq(429)  # Rate limited
    end
  end
end
```

**Testing Authorization:**
```ruby
RSpec.describe 'Authorization' do
  let(:user) { create(:user) }
  let(:admin) { create(:user, role: :admin) }
  let(:post) { create(:post, user: user) }

  describe 'DELETE /posts/:id' do
    it 'allows owner to delete' do
      delete "/posts/#{post.id}", {}, auth_header(user.token)
      expect(last_response.status).to eq(204)
    end

    it 'allows admin to delete' do
      delete "/posts/#{post.id}", {}, auth_header(admin.token)
      expect(last_response.status).to eq(204)
    end

    it 'denies other users' do
      other_user = create(:user)
      delete "/posts/#{post.id}", {}, auth_header(other_user.token)
      expect(last_response.status).to eq(403)
    end

    it 'requires authentication' do
      delete "/posts/#{post.id}"
      expect(last_response.status).to eq(401)
    end
  end
end
```

### Additional Resources

- **Security Middleware:** `assets/security-middleware.rb`
- **Authentication Patterns:** `assets/auth-patterns.rb`
- **OWASP Checklist:** `assets/owasp-checklist.md`
- **Security Audit Template:** `references/security-audit-template.md`
- **Penetration Testing Guide:** `references/penetration-testing.md`
