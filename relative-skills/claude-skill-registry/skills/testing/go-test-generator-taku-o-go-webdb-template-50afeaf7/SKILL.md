---
name: go-test-generator
description: Goのテストコードを生成する際に使用。テーブル駆動テスト、testify/assert使用、命名規則TestStructName_MethodNameを適用。Goのユニットテスト、統合テストを書く場合に使用。
allowed-tools: Read, Glob
---

# Go テスト生成パターン

このプロジェクトのGoテスト実装パターンを定義します。

## 命名規則

- **ファイル名**: `*_test.go`
- **関数名**: `TestStructName_MethodName` または `TestFunctionName`
- **パッケージ名**: `{package}_test` (外部テスト) または `{package}` (内部テスト)

## 使用ライブラリ

```go
import (
    "testing"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)
```

- `assert`: テスト失敗しても続行
- `require`: テスト失敗で即座に中断

## 参照ファイル

テスト実装の参照:
- `server/internal/repository/user_repository_test.go` - Repository テスト
- `server/internal/db/sharding_test.go` - シャーディングテスト
- `server/test/integration/` - 統合テスト

テストユーティリティ:
- `server/test/testutil/` - テストヘルパー

## コードパターン

### 1. 基本的なテスト

```go
func TestStructName_MethodName(t *testing.T) {
    // Arrange
    expected := "expected value"

    // Act
    actual := SomeFunction()

    // Assert
    assert.Equal(t, expected, actual)
}
```

### 2. シャーディング対応のテスト

```go
func TestUserRepository_Create(t *testing.T) {
    // テスト用GroupManagerのセットアップ
    groupManager := testutil.SetupTestGroupManager(t, 4, 8)
    defer testutil.CleanupTestGroupManager(groupManager)

    repo := repository.NewUserRepository(groupManager)
    ctx := context.Background()

    req := &model.CreateUserRequest{
        Name:  "Test User",
        Email: "test@example.com",
    }

    user, err := repo.Create(ctx, req)
    assert.NoError(t, err)
    assert.NotNil(t, user)
    assert.NotZero(t, user.ID)
}
```

### 3. テーブル駆動テスト

```go
func TestHashBasedSharding_GetShardID(t *testing.T) {
    tests := []struct {
        name       string
        shardCount int
        key        int64
        wantMin    int
        wantMax    int
    }{
        {
            name:       "single shard",
            shardCount: 1,
            key:        12345,
            wantMin:    1,
            wantMax:    1,
        },
        {
            name:       "multiple shards",
            shardCount: 4,
            key:        12345,
            wantMin:    1,
            wantMax:    4,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            sharding := db.NewHashBasedSharding(tt.shardCount)
            got := sharding.GetShardID(tt.key)

            assert.GreaterOrEqual(t, got, tt.wantMin)
            assert.LessOrEqual(t, got, tt.wantMax)
        })
    }
}
```

### 4. エラーケースのテスト

```go
func TestUserRepository_GetByID_NotFound(t *testing.T) {
    groupManager := testutil.SetupTestGroupManager(t, 4, 8)
    defer testutil.CleanupTestGroupManager(groupManager)

    repo := repository.NewUserRepository(groupManager)
    ctx := context.Background()

    // 存在しないIDでテスト
    user, err := repo.GetByID(ctx, 999)
    assert.Error(t, err)
    assert.Nil(t, user)
}
```

### 5. require vs assert の使い分け

```go
func TestUserRepository_Update(t *testing.T) {
    groupManager := testutil.SetupTestGroupManager(t, 4, 8)
    defer testutil.CleanupTestGroupManager(groupManager)

    repo := repository.NewUserRepository(groupManager)
    ctx := context.Background()

    // 前提条件の確認には require を使用（失敗時は即座に中断）
    created, err := repo.Create(ctx, createReq)
    require.NoError(t, err)

    // 本テストの検証には assert を使用
    updated, err := repo.Update(ctx, created.ID, updateReq)
    assert.NoError(t, err)
    assert.Equal(t, "Updated Name", updated.Name)
}
```

## テスト実行コマンド

```bash
# 全テスト実行
cd server && APP_ENV=develop go test ./...

# 特定パッケージのテスト
cd server && APP_ENV=develop go test ./internal/repository/...

# 詳細出力
cd server && APP_ENV=develop go test -v ./...

# カバレッジ
cd server && APP_ENV=develop go test -cover ./...
```
