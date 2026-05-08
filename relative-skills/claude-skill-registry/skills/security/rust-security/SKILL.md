---
name: rust-security
description: Rust security best practices and vulnerability prevention. Use when handling user input, authentication, cryptography, secrets management, network security, or conducting security reviews.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Rust Security Best Practices

Comprehensive guide for writing secure Rust code.

## Dependency Security

### Audit Dependencies

```bash
# Install and run cargo-audit
cargo install cargo-audit
cargo audit

# Check for unmaintained crates
cargo audit --deny unmaintained

# Generate lockfile advisories
cargo audit --json > audit-report.json

# Deny specific advisories in CI
cargo audit --deny RUSTSEC-2023-0001
```

### Cargo.toml Security

```toml
[package]
# Pin exact versions for security-critical deps
rust-version = "1.85"

[dependencies]
# Use caret for flexibility, but audit regularly
ring = "0.17"
rustls = "0.23"

# Avoid yanked versions
# cargo update will warn about these

[features]
# Disable default features, enable only what you need
default = []
```

### cargo-deny Configuration

```toml
# deny.toml
[advisories]
db-path = "~/.cargo/advisory-db"
vulnerability = "deny"
unmaintained = "warn"
yanked = "deny"

[licenses]
allow = ["MIT", "Apache-2.0", "BSD-3-Clause"]
copyleft = "deny"

[bans]
multiple-versions = "warn"
deny = [
    # Known problematic crates
    { name = "openssl" },  # Prefer rustls
]

[sources]
unknown-registry = "deny"
unknown-git = "deny"
```

## Input Validation

### String Validation

```rust
use std::borrow::Cow;

/// Validates and sanitizes user input.
pub fn validate_username(input: &str) -> Result<Cow<'_, str>, ValidationError> {
    // Length limits
    if input.is_empty() {
        return Err(ValidationError::Empty);
    }
    if input.len() > 64 {
        return Err(ValidationError::TooLong { max: 64 });
    }
    
    // Character whitelist
    if !input.chars().all(|c| c.is_ascii_alphanumeric() || c == '_' || c == '-') {
        return Err(ValidationError::InvalidCharacters);
    }
    
    // Reserved names
    const RESERVED: &[&str] = &["admin", "root", "system", "null"];
    if RESERVED.contains(&input.to_lowercase().as_str()) {
        return Err(ValidationError::Reserved);
    }
    
    Ok(Cow::Borrowed(input))
}
```

### Path Traversal Prevention

```rust
use std::path::{Path, PathBuf};

/// Safely joins a user-provided path to a base directory.
pub fn safe_join(base: &Path, user_path: &str) -> Result<PathBuf, SecurityError> {
    // Reject absolute paths
    let user_path = Path::new(user_path);
    if user_path.is_absolute() {
        return Err(SecurityError::AbsolutePathRejected);
    }
    
    // Reject path traversal
    for component in user_path.components() {
        match component {
            std::path::Component::ParentDir => {
                return Err(SecurityError::PathTraversal);
            }
            std::path::Component::Normal(_) => {}
            _ => return Err(SecurityError::InvalidPathComponent),
        }
    }
    
    let full_path = base.join(user_path);
    
    // Verify the result is still under base
    let canonical = full_path.canonicalize()
        .map_err(|_| SecurityError::PathResolutionFailed)?;
    let base_canonical = base.canonicalize()
        .map_err(|_| SecurityError::PathResolutionFailed)?;
    
    if !canonical.starts_with(&base_canonical) {
        return Err(SecurityError::PathEscape);
    }
    
    Ok(canonical)
}
```

### SQL Injection Prevention

```rust
use sqlx::{query, query_as, PgPool};

// BAD - string interpolation
async fn bad_query(pool: &PgPool, user_id: &str) {
    let query = format!("SELECT * FROM users WHERE id = '{}'", user_id);
    // VULNERABLE TO SQL INJECTION
}

// GOOD - parameterized queries
async fn good_query(pool: &PgPool, user_id: &str) -> Result<User, Error> {
    query_as!(User, "SELECT * FROM users WHERE id = $1", user_id)
        .fetch_one(pool)
        .await
        .map_err(Error::from)
}

// GOOD - using sqlx macros (compile-time checked)
async fn safe_query(pool: &PgPool, user_id: Uuid) -> Result<User, Error> {
    sqlx::query_as!(
        User,
        r#"SELECT id, name, email FROM users WHERE id = $1"#,
        user_id
    )
    .fetch_one(pool)
    .await
    .map_err(Error::from)
}
```

### Command Injection Prevention

```rust
use std::process::Command;

// BAD - shell interpolation
fn bad_command(filename: &str) {
    Command::new("sh")
        .arg("-c")
        .arg(format!("cat {}", filename))  // VULNERABLE
        .output();
}

// GOOD - direct argument passing
fn good_command(filename: &str) -> std::io::Result<Vec<u8>> {
    let output = Command::new("cat")
        .arg(filename)  // Passed as single argument, no shell interpretation
        .output()?;
    Ok(output.stdout)
}

// BETTER - avoid shell entirely when possible
fn read_file(filename: &str) -> std::io::Result<Vec<u8>> {
    std::fs::read(filename)
}
```

## Authentication & Authorization

### Password Hashing

```rust
use argon2::{
    password_hash::{rand_core::OsRng, PasswordHash, PasswordHasher, PasswordVerifier, SaltString},
    Argon2,
};

/// Hashes a password using Argon2id.
pub fn hash_password(password: &str) -> Result<String, AuthError> {
    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();
    
    argon2
        .hash_password(password.as_bytes(), &salt)
        .map(|hash| hash.to_string())
        .map_err(|_| AuthError::HashingFailed)
}

/// Verifies a password against a hash.
pub fn verify_password(password: &str, hash: &str) -> Result<bool, AuthError> {
    let parsed_hash = PasswordHash::new(hash)
        .map_err(|_| AuthError::InvalidHash)?;
    
    Ok(Argon2::default()
        .verify_password(password.as_bytes(), &parsed_hash)
        .is_ok())
}
```

### Token Generation

```rust
use rand::{rngs::OsRng, RngCore};
use base64::{engine::general_purpose::URL_SAFE_NO_PAD, Engine};

/// Generates a cryptographically secure random token.
pub fn generate_token(length: usize) -> String {
    let mut bytes = vec![0u8; length];
    OsRng.fill_bytes(&mut bytes);
    URL_SAFE_NO_PAD.encode(&bytes)
}

/// Generates a session ID.
pub fn generate_session_id() -> String {
    generate_token(32)  // 256 bits of entropy
}

/// Generates a CSRF token.
pub fn generate_csrf_token() -> String {
    generate_token(32)
}
```

### Constant-Time Comparison

```rust
use subtle::ConstantTimeEq;

/// Compares two tokens in constant time to prevent timing attacks.
pub fn secure_compare(a: &[u8], b: &[u8]) -> bool {
    if a.len() != b.len() {
        return false;
    }
    a.ct_eq(b).into()
}

// For string tokens
pub fn secure_compare_str(a: &str, b: &str) -> bool {
    secure_compare(a.as_bytes(), b.as_bytes())
}
```

## Secrets Management

### Secure String Handling

```rust
use secrecy::{ExposeSecret, Secret};
use zeroize::Zeroize;

/// A password that is zeroized on drop.
pub struct Password(Secret<String>);

impl Password {
    pub fn new(password: String) -> Self {
        Self(Secret::new(password))
    }
    
    pub fn expose(&self) -> &str {
        self.0.expose_secret()
    }
}

// For custom types
#[derive(Zeroize)]
#[zeroize(drop)]
pub struct ApiKey {
    key: String,
}

impl Drop for ApiKey {
    fn drop(&mut self) {
        self.zeroize();
    }
}
```

### Environment Variables

```rust
use secrecy::Secret;
use std::env;

/// Loads secrets from environment variables.
pub struct Secrets {
    pub database_url: Secret<String>,
    pub api_key: Secret<String>,
    pub jwt_secret: Secret<String>,
}

impl Secrets {
    pub fn from_env() -> Result<Self, ConfigError> {
        Ok(Self {
            database_url: Secret::new(
                env::var("DATABASE_URL")
                    .map_err(|_| ConfigError::MissingEnv("DATABASE_URL"))?
            ),
            api_key: Secret::new(
                env::var("API_KEY")
                    .map_err(|_| ConfigError::MissingEnv("API_KEY"))?
            ),
            jwt_secret: Secret::new(
                env::var("JWT_SECRET")
                    .map_err(|_| ConfigError::MissingEnv("JWT_SECRET"))?
            ),
        })
    }
}

// NEVER log secrets
impl std::fmt::Debug for Secrets {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("Secrets")
            .field("database_url", &"[REDACTED]")
            .field("api_key", &"[REDACTED]")
            .field("jwt_secret", &"[REDACTED]")
            .finish()
    }
}
```

## Cryptography

### Use High-Level Libraries

```rust
// GOOD - use established, audited libraries
use ring::rand::SecureRandom;
use ring::aead::{Aad, LessSafeKey, Nonce, UnboundKey, AES_256_GCM};

pub struct Encryptor {
    key: LessSafeKey,
}

impl Encryptor {
    pub fn new(key_bytes: &[u8; 32]) -> Result<Self, CryptoError> {
        let unbound_key = UnboundKey::new(&AES_256_GCM, key_bytes)
            .map_err(|_| CryptoError::InvalidKey)?;
        Ok(Self {
            key: LessSafeKey::new(unbound_key),
        })
    }
    
    pub fn encrypt(&self, plaintext: &[u8], nonce: &[u8; 12]) -> Result<Vec<u8>, CryptoError> {
        let nonce = Nonce::assume_unique_for_key(*nonce);
        let mut in_out = plaintext.to_vec();
        
        self.key
            .seal_in_place_append_tag(nonce, Aad::empty(), &mut in_out)
            .map_err(|_| CryptoError::EncryptionFailed)?;
        
        Ok(in_out)
    }
}
```

### TLS Configuration

```rust
use rustls::{ClientConfig, RootCertStore};
use std::sync::Arc;

/// Creates a secure TLS client configuration.
pub fn create_tls_config() -> Result<Arc<ClientConfig>, TlsError> {
    let mut root_store = RootCertStore::empty();
    
    // Use webpki-roots for trusted CAs
    root_store.extend(webpki_roots::TLS_SERVER_ROOTS.iter().cloned());
    
    let config = ClientConfig::builder()
        .with_root_certificates(root_store)
        .with_no_client_auth();
    
    Ok(Arc::new(config))
}

// For reqwest
use reqwest::Client;

pub fn create_secure_client() -> Result<Client, reqwest::Error> {
    Client::builder()
        .use_rustls_tls()
        .min_tls_version(reqwest::tls::Version::TLS_1_2)
        .https_only(true)
        .build()
}
```

## Rate Limiting & DoS Prevention

### Rate Limiter

```rust
use std::collections::HashMap;
use std::sync::Mutex;
use std::time::{Duration, Instant};

pub struct RateLimiter {
    requests: Mutex<HashMap<String, Vec<Instant>>>,
    max_requests: usize,
    window: Duration,
}

impl RateLimiter {
    pub fn new(max_requests: usize, window: Duration) -> Self {
        Self {
            requests: Mutex::new(HashMap::new()),
            max_requests,
            window,
        }
    }
    
    pub fn check(&self, key: &str) -> Result<(), RateLimitError> {
        let mut requests = self.requests.lock().unwrap();
        let now = Instant::now();
        let cutoff = now - self.window;
        
        let timestamps = requests.entry(key.to_string()).or_default();
        
        // Remove old timestamps
        timestamps.retain(|&t| t > cutoff);
        
        if timestamps.len() >= self.max_requests {
            return Err(RateLimitError::TooManyRequests);
        }
        
        timestamps.push(now);
        Ok(())
    }
}
```

### Request Size Limits

```rust
use axum::{
    body::Body,
    extract::Request,
    middleware::Next,
    response::Response,
};
use http::StatusCode;

const MAX_BODY_SIZE: u64 = 1024 * 1024; // 1 MB

pub async fn limit_body_size(
    request: Request,
    next: Next,
) -> Result<Response, StatusCode> {
    let content_length = request
        .headers()
        .get(http::header::CONTENT_LENGTH)
        .and_then(|v| v.to_str().ok())
        .and_then(|v| v.parse::<u64>().ok());
    
    if let Some(length) = content_length {
        if length > MAX_BODY_SIZE {
            return Err(StatusCode::PAYLOAD_TOO_LARGE);
        }
    }
    
    Ok(next.run(request).await)
}
```

## Logging Security

### Safe Logging

```rust
use tracing::{info, warn, error, instrument};

// BAD - logs sensitive data
fn bad_login(username: &str, password: &str) {
    info!("Login attempt: user={}, pass={}", username, password);
}

// GOOD - redact sensitive fields
#[instrument(skip(password), fields(username = %username))]
fn good_login(username: &str, password: &str) -> Result<(), AuthError> {
    info!("Login attempt");
    // ... authentication logic
    Ok(())
}

// Use skip for sensitive parameters
#[instrument(skip(api_key, request_body))]
async fn api_call(
    endpoint: &str,
    api_key: &str,
    request_body: &[u8],
) -> Result<Response, Error> {
    info!("API call to {}", endpoint);
    // ...
}

// Redact in error messages
#[derive(Debug, thiserror::Error)]
pub enum AuthError {
    #[error("Invalid credentials")]  // Don't say which one
    InvalidCredentials,
    
    #[error("Account locked")]
    AccountLocked,
}
```

## Security Headers

```rust
use axum::{
    middleware::Next,
    response::Response,
    http::{Request, header},
};

pub async fn security_headers<B>(
    request: Request<B>,
    next: Next<B>,
) -> Response {
    let mut response = next.run(request).await;
    let headers = response.headers_mut();
    
    // Prevent XSS
    headers.insert(
        header::X_CONTENT_TYPE_OPTIONS,
        "nosniff".parse().unwrap(),
    );
    
    // Prevent clickjacking
    headers.insert(
        header::X_FRAME_OPTIONS,
        "DENY".parse().unwrap(),
    );
    
    // HSTS
    headers.insert(
        header::STRICT_TRANSPORT_SECURITY,
        "max-age=31536000; includeSubDomains".parse().unwrap(),
    );
    
    // CSP
    headers.insert(
        header::CONTENT_SECURITY_POLICY,
        "default-src 'self'".parse().unwrap(),
    );
    
    response
}
```

## Security Checklist

### Before Release
- [ ] `cargo audit` - no known vulnerabilities
- [ ] `cargo deny check` - license and dependency review
- [ ] All user input validated and sanitized
- [ ] SQL queries parameterized
- [ ] No shell command interpolation
- [ ] Secrets not in code or logs
- [ ] TLS 1.2+ enforced
- [ ] Rate limiting enabled
- [ ] Security headers configured
- [ ] Error messages don't leak internals

### Crate Recommendations
| Purpose | Recommended Crate |
|---------|------------------|
| Password hashing | `argon2` |
| Cryptography | `ring`, `rustls` |
| TLS | `rustls` (not openssl) |
| Secrets | `secrecy`, `zeroize` |
| Random | `rand` with `OsRng` |
| Timing-safe compare | `subtle` |
| HTTP client | `reqwest` with rustls |
| SQL | `sqlx` with compile-time checks |
