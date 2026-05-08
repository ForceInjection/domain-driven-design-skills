---
name: rust-backend-testing
description: Guides Rust backend test development with testcontainers, mockall, and axum-test. Use when writing integration tests, mocking dependencies, testing HTTP handlers, or setting up test infrastructure for Axum/SQLx projects.
---

<objective>
Provide expert guidance for testing Rust backend applications. Covers integration testing with real databases via testcontainers, trait-based mocking with mockall, and HTTP handler testing with axum-test.
</objective>

<essential_principles>
1. **Test at the Right Level** - Unit (mockall), Integration (testcontainers), API (axum-test)
2. **Trait-Based Design** - Define services behind traits for mockability
3. **Real Dependencies Over Mocks** - Prefer testcontainers for database tests
4. **Test Isolation** - Each test independent, use transactions or fresh containers
</essential_principles>

<patterns>
<pattern name="testcontainers">
**PostgreSQL with Testcontainers**

```rust
use testcontainers::{runners::AsyncRunner, GenericImage, ImageExt};
use testcontainers::core::{IntoContainerPort, WaitFor};

async fn setup_postgres() -> Result<(impl std::any::Any, PgPool), Box<dyn std::error::Error>> {
    let container = GenericImage::new("postgres", "15-alpine")
        .with_exposed_port(5432.tcp())
        .with_env_var("POSTGRES_PASSWORD", "test")
        .with_env_var("POSTGRES_DB", "testdb")
        .with_wait_for(WaitFor::message_on_stderr("ready to accept connections"))
        .start()
        .await?;

    let port = container.get_host_port_ipv4(5432).await?;
    let url = format!("postgres://postgres:test@localhost:{}/testdb", port);
    let pool = PgPool::connect(&url).await?;
    sqlx::migrate!("./migrations").run(&pool).await?;

    Ok((container, pool))
}
```
</pattern>

<pattern name="mockall">
**Trait Mocking with mockall**

```rust
use mockall::{automock, predicate::*};

#[automock]
pub trait UserRepository: Send + Sync {
    async fn find_by_id(&self, id: i64) -> Result<Option<User>, DbError>;
}

#[tokio::test]
async fn test_user_service() {
    let mut mock = MockUserRepository::new();
    mock.expect_find_by_id()
        .with(eq(1))
        .returning(|_| Ok(Some(User { id: 1, name: "Test".into() })));

    let service = UserService::new(Arc::new(mock));
    let user = service.get_user(1).await.unwrap();
    assert_eq!(user.name, "Test");
}
```
</pattern>

<pattern name="axum_test">
**HTTP Handler Testing**

```rust
use axum_test::TestServer;

#[tokio::test]
async fn test_get_user() {
    let app = create_router(state);
    let server = TestServer::new(app).unwrap();

    let response = server.get("/users/1").await;
    response.assert_status_ok();

    let user: User = response.json();
    assert_eq!(user.name, "Test");
}
```
</pattern>
</patterns>

<success_criteria>
- [ ] Unit tests cover business logic with mocked dependencies
- [ ] Integration tests verify database operations with real PostgreSQL
- [ ] API tests confirm handler behavior end-to-end
- [ ] Tests are isolated and can run in any order
- [ ] cargo test passes with no flaky tests
</success_criteria>
