---
name: backend-testing
description: バックエンド（Rust/Tauri）のテスト実装とデバッグを行います。Rustのテスト作成、cargo testの実行、テストエラーの修正、Repository/Service/Facadeレイヤーのテストなどのバックエンドテスト関連タスクに使用します。
allowed-tools: Read, Edit, Write, Bash(cargo test:*), Bash(cargo check:*)
model: sonnet
---

# Backend Testing Skill

Flequit プロジェクトのバックエンドテスト（Rust/Tauri）を実装・実行するスキルです。

## テスト実行コマンド

### 必須: ワーカー数制限

システム負荷を避けるため、**必ず `-j 4` オプションを指定**してください：

```bash
# 全テスト実行
cargo test -j 4

# Storage レイヤーのみ
cargo test --lib -p flequit-storage -j 4

# Business logic レイヤーのみ
cargo test --lib -p flequit-core -j 4

# 特定のテストのみ
cargo test test_name -j 4
```

### 型チェック

```bash
cargo check
```

## プロジェクト構造

### Crate 分離アーキテクチャ

```
src-tauri/
├── Cargo.toml                    # Main crate
├── src/
│   ├── commands/                 # Tauri commands
│   └── lib.rs
│
├── crates/
│   ├── flequit-storage/          # Storage layer
│   │   ├── src/
│   │   │   ├── repositories/     # Repository implementations
│   │   │   │   ├── local_sqlite/ # SQLite
│   │   │   │   └── local_automerge/ # Automerge
│   │   │   ├── models/
│   │   │   └── errors/
│   │   └── tests/                # Storage tests
│   │       ├── integration/
│   │       └── test_utils.rs
│   │
│   └── flequit-core/             # Business logic layer
│       ├── src/
│       │   ├── facades/          # Facade layer
│       │   └── services/         # Service layer
│       └── tests/                # Service/Facade tests
```

## テスト戦略

### 1. Repository Layer テスト

データアクセス層のテスト。実際のデータベースを使用。

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use sqlx::SqlitePool;

    async fn setup_test_db() -> SqlitePool {
        let pool = SqlitePool::connect(":memory:").await.unwrap();
        sqlx::migrate!("../migrations").run(&pool).await.unwrap();
        pool
    }

    #[tokio::test]
    async fn test_find_by_id_existing_task() {
        // Arrange
        let pool = setup_test_db().await;
        let repository = SqliteTaskRepository { pool };

        let task = Task {
            id: TaskId::new(),
            title: "Test Task".to_string(),
            // ...
        };
        repository.save(&task).await.unwrap();

        // Act
        let result = repository.find_by_id(&task.id).await.unwrap();

        // Assert
        assert!(result.is_some());
        assert_eq!(result.unwrap().title, "Test Task");
    }

    #[tokio::test]
    async fn test_find_by_id_nonexistent() {
        // Arrange
        let pool = setup_test_db().await;
        let repository = SqliteTaskRepository { pool };

        // Act
        let result = repository.find_by_id(&TaskId::new()).await.unwrap();

        // Assert
        assert!(result.is_none());
    }
}
```

### 2. Service Layer テスト（Mock使用）

ビジネスロジックのテスト。Repository を mock して単体テスト。

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use mockall::predicate::*;
    use mockall::mock;

    mock! {
        TaskRepo {}

        #[async_trait]
        impl TaskRepository for TaskRepo {
            async fn find_by_id(&self, id: &TaskId) -> Result<Option<Task>>;
            async fn save(&self, task: &Task) -> Result<()>;
        }
    }

    #[tokio::test]
    async fn test_assign_task_success() {
        // Arrange
        let mut mock_repo = MockTaskRepo::new();

        let task_id = TaskId::new();
        let task = Task {
            id: task_id,
            status: TaskStatus::Todo,
            assignee_id: None,
            // ...
        };

        mock_repo
            .expect_find_by_id()
            .with(eq(task_id))
            .times(1)
            .returning(move |_| Ok(Some(task.clone())));

        mock_repo
            .expect_save()
            .times(1)
            .returning(|_| Ok(()));

        let service = TaskService::new(Arc::new(mock_repo));

        // Act
        let result = service.assign_task(&task_id, &user_id).await;

        // Assert
        assert!(result.is_ok());
    }
}
```

### 3. Integration テスト

複数のレイヤーを統合してテスト。

```rust
#[tokio::test]
async fn test_create_task_integration() {
    // Setup
    let pool = setup_test_db().await;
    let repository = SqliteTaskRepository { pool: pool.clone() };
    let service = TaskService::new(Arc::new(repository));

    // Act
    let task = service.create_task(CreateTaskRequest {
        title: "Integration Test".to_string(),
        project_id: ProjectId::new(),
    }).await.unwrap();

    // Assert - Repository から実際に取得できるか確認
    let saved_task = SqliteTaskRepository { pool }
        .find_by_id(&task.id)
        .await
        .unwrap();

    assert!(saved_task.is_some());
    assert_eq!(saved_task.unwrap().title, "Integration Test");
}
```

## Option 値の処理パターン

### 単一 Option 値

```rust
pub async fn get_user_display_name(user_id: &UserId) -> Result<String> {
    if let Some(user) = user_repository.find_by_id(user_id).await? {
        return Ok(user.display_name);
    }

    Err(ServiceError::NotFound("User not found".to_string()))
}
```

### 複数 Option 値

```rust
pub async fn create_task_assignment(
    user_id: &UserId,
    project_id: &ProjectId,
    task_id: &TaskId
) -> Result<TaskAssignment> {
    // 各リソースを並列取得（Option値として受け取る）
    let user = user_repository.find_by_id(user_id).await?;
    let project = project_repository.find_by_id(project_id).await?;
    let task = task_repository.find_by_id(task_id).await?;

    // すべてのOption値を一度に検証
    let (user, project, task) = match (user, project, task) {
        (Some(u), Some(p), Some(t)) => (u, p, t),
        (None, _, _) => return Err(ServiceError::NotFound("User not found".to_string())),
        (_, None, _) => return Err(ServiceError::NotFound("Project not found".to_string())),
        (_, _, None) => return Err(ServiceError::NotFound("Task not found".to_string())),
    };

    // ビジネスロジック処理
    validate_assignment_rules(&user, &project, &task)?;

    Ok(create_assignment(&user, &project, &task))
}
```

## エラーハンドリングパターン

### 階層的エラー型

```rust
// Repository layer
#[derive(Debug, thiserror::Error)]
pub enum RepositoryError {
    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),

    #[error("Serialization error: {0}")]
    Serialization(#[from] serde_json::Error),
}

// Service layer
#[derive(Debug, thiserror::Error)]
pub enum ServiceError {
    #[error("Resource not found: {0}")]
    NotFound(String),

    #[error("Validation failed: {0}")]
    Validation(String),

    #[error("Repository error: {0}")]
    Repository(#[from] RepositoryError),
}

// Command layer
#[derive(Debug, thiserror::Error)]
pub enum CommandError {
    #[error("Invalid input: {0}")]
    InvalidInput(String),

    #[error("Service error: {0}")]
    Service(#[from] ServiceError),
}
```

### コンテキスト付きエラー

```rust
use anyhow::{Context, Result};

pub async fn sync_project(project_id: &ProjectId) -> Result<SyncResult> {
    let local_data = local_repository
        .get_project_data(project_id)
        .await
        .with_context(|| format!("Failed to get local data: {}", project_id))?;

    let remote_changes = remote_service
        .fetch_changes(project_id)
        .await
        .context("Failed to fetch remote changes")?;

    Ok(merge_data(local_data, remote_changes))
}
```

## トランザクション管理

### Facade レイヤーでのトランザクション制御

```rust
pub async fn delete_task<R>(
    repositories: &R,
    project_id: &ProjectId,
    task_id: &TaskId,
) -> Result<bool, String>
where
    R: InfrastructureRepositoriesTrait + TransactionManager<Transaction = DatabaseTransaction>,
{
    // 1. トランザクション開始
    let txn = repositories.begin().await?;

    let sqlite_repos = repositories.sqlite_repositories()?.read().await;

    // 2. トランザクション内で操作実行
    sqlite_repos.subtask
        .delete_by_task_with_txn(&txn, project_id, task_id).await?;
    sqlite_repos.task
        .delete_with_txn(&txn, project_id, task_id).await?;

    drop(sqlite_repos);

    // 3. トランザクションコミット
    repositories.commit(txn).await?;

    // 4. Automerge 操作（トランザクション外）
    repositories.task().delete(project_id, task_id).await?;

    Ok(true)
}
```

### Repository レイヤーでのトランザクション受け取り

```rust
pub async fn delete_with_txn(
    &self,
    txn: &DatabaseTransaction,
    project_id: &ProjectId,
    id: &TaskId,
) -> Result<(), RepositoryError> {
    Entity::delete_by_id((project_id.to_string(), id.to_string()))
        .exec(txn)  // 提供されたトランザクションを使用
        .await?;
    Ok(())
}
```

## ベストプラクティス

### 1. AAA パターン（Arrange-Act-Assert）

```rust
#[tokio::test]
async fn test_example() {
    // Arrange - テストデータとモックを準備
    let repository = setup_repository().await;
    let data = create_test_data();

    // Act - 対象の関数/メソッドを実行
    let result = repository.save(&data).await;

    // Assert - 結果を検証
    assert!(result.is_ok());
}
```

### 2. テストデータの分離

```rust
// test_utils.rs にヘルパー関数を定義
pub fn create_test_task(title: &str) -> Task {
    Task {
        id: TaskId::new(),
        title: title.to_string(),
        status: TaskStatus::Todo,
        created_at: Utc::now(),
        updated_at: Utc::now(),
    }
}

// テストで使用
#[tokio::test]
async fn test_save_task() {
    let task = create_test_task("Test");
    // ...
}
```

### 3. 非同期テストの注意点

```rust
// Good - #[tokio::test] を使用
#[tokio::test]
async fn test_async_function() {
    let result = async_function().await;
    assert!(result.is_ok());
}

// Bad - async を忘れるとコンパイルエラー
#[test]
fn test_async_function() {
    let result = async_function().await; // Error!
}
```

## よくあるエラーと解決方法

### 1. `database is locked`
- 原因: 並列テストでデータベースが競合
- 解決: `-j 4` で並列数を制限、または各テストで独立したDBを使用

### 2. `async_trait` エラー
- 原因: trait の async メソッドに `#[async_trait]` が不足
- 解決: trait 定義に `#[async_trait]` を追加

### 3. Mock の戻り値型エラー
- 原因: Mock の returning で型が一致していない
- 解決: `clone()` を使うか、`move` クロージャで所有権を渡す

## 関連ドキュメント

詳細は以下のドキュメントを参照：
- `docs/en/develop/design/backend-tauri/rust-guidelines.md` - Rust設計ガイドライン
- `docs/en/develop/design/backend-tauri/transaction-management.md` - トランザクション管理
- `docs/en/develop/design/testing.md` - テスト戦略全体
- `docs/en/develop/rules/backend.md` - バックエンドルール
