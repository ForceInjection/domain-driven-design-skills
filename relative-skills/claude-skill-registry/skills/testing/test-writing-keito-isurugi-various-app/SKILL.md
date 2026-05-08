---
name: test-writing
description: |
  TDD（テスト駆動開発）に基づいたテストコード作成スキル。Red-Green-Refactorサイクルを実践し、
  t-wadaのベストプラクティスに従ってテストファーストで高品質なテストを作成します。
  Backend（Go test）とFrontend（Jest）の両方に対応。
---

# Test Writing Skill

TDDの原則に従って高品質なテストコードを作成するスキル。

## 対応フレームワーク

| 対象 | フレームワーク | 詳細ガイド |
|------|--------------|-----------|
| Backend | Go test + testify | `./agents/backend-test-writer.md` |
| Frontend | Jest + Testing Library | `./agents/frontend-test-writer.md` |

## 判断フロー

```
テストを書く必要がある？
│
├─ 新機能実装 ──────────────────────→ ✅ TDD（テストファースト）
│
├─ バグ修正 ────────────────────────→ ✅ 再現テスト → 修正 → グリーン確認
│
├─ リファクタリング ────────────────→ ✅ 既存テスト確認 or 追加 → 実行
│
├─ 既存コードへのカバレッジ追加 ───→ ✅ テスト追加（後付け）
│
├─ PoC・プロトタイプ ───────────────→ ❌ スキップ可
│
└─ Getter/Setter・単純マッピング ──→ ❌ 価値が低い
```

## TDDサイクル（Red → Green → Refactor）

```
    ┌─────────────────────────────────────────────────┐
    │                                                 │
    ▼                                                 │
┌───────┐     ┌───────┐     ┌───────────┐           │
│  Red  │ ──→ │ Green │ ──→ │ Refactor  │ ──────────┘
│       │     │       │     │           │
│失敗する│     │最小実装│     │コード改善 │
│テスト  │     │で通す │     │テスト維持 │
└───────┘     └───────┘     └───────────┘
```

### Step 1: Red（失敗するテストを書く）

```go
// Backend (Go)
func TestCreateImage_WithValidData_ReturnsImage(t *testing.T) {
    // Arrange
    repo := NewImageRepository(db)
    name := "test.jpg"
    url := "https://example.com/test.jpg"

    // Act
    image, err := repo.Create(name, url)

    // Assert
    assert.NoError(t, err)
    assert.NotZero(t, image.ID)
    assert.Equal(t, name, image.Name)
}
```

```bash
# テスト実行（失敗することを確認）
cd backend && go test -v ./...
# FAIL ← これが正しい状態
```

### Step 2: Green（最小限の実装で通す）

```go
// 最小限のコードでテストを通す
func (r *imageRepository) Create(name, url string) (*Image, error) {
    image := &Image{Name: name, URL: url}
    if err := r.db.Create(image).Error; err != nil {
        return nil, err
    }
    return image, nil
}
```

```bash
# テスト実行（成功することを確認）
cd backend && go test -v ./...
# PASS ← グリーン！
```

### Step 3: Refactor（テストを維持しながら改善）

```go
// テストがグリーンの状態でのみリファクタリング
func (r *imageRepository) Create(name, url string) (*Image, error) {
    if err := r.validateInput(name, url); err != nil {
        return nil, err
    }

    image := &Image{
        Name:      name,
        URL:       url,
        CreatedAt: time.Now(),
    }

    if err := r.db.Create(image).Error; err != nil {
        return nil, fmt.Errorf("failed to create image: %w", err)
    }

    return image, nil
}
```

```bash
# リファクタリング後もグリーンを確認
cd backend && go test -v ./...
# PASS ← 維持されている！
```

## テストケース設計（4カテゴリ必須）

```go
// Backend (Go)
func TestImageRepository(t *testing.T) {
    // ✅ 正常系（Happy Path）
    t.Run("Create_WithValidData_ReturnsImage", func(t *testing.T) {
        // ...
    })

    // ✅ 境界値（Boundary Value）
    t.Run("Create_WithMaxLengthName_Succeeds", func(t *testing.T) {
        // ...
    })

    // ✅ 異常系（Error Cases）
    t.Run("Create_WithEmptyName_ReturnsError", func(t *testing.T) {
        // ...
    })

    // ✅ エッジケース（Edge Cases）
    t.Run("FindByID_WhenNotFound_ReturnsNil", func(t *testing.T) {
        // ...
    })
}
```

```tsx
// Frontend (Jest)
describe("useTodos", () => {
  // ✅ 正常系
  it("should add a new todo", async () => {
    // ...
  });

  // ✅ 境界値
  it("should handle empty title", async () => {
    // ...
  });

  // ✅ 異常系
  it("should set error when API fails", async () => {
    // ...
  });

  // ✅ エッジケース
  it("should handle empty initial todos", () => {
    // ...
  });
});
```

## Backend テスト（Go）

### 基本構造

```go
// domain/image_test.go
package domain_test

import (
    "testing"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
    "your-project/domain"
)

func TestNewImage(t *testing.T) {
    t.Run("WithValidData_ReturnsImage", func(t *testing.T) {
        // Arrange
        name := "test.jpg"
        url := "https://example.com/test.jpg"

        // Act
        image, err := domain.NewImage(name, url)

        // Assert
        require.NoError(t, err)
        assert.Equal(t, name, image.Name)
        assert.Equal(t, url, image.URL)
    })

    t.Run("WithEmptyName_ReturnsError", func(t *testing.T) {
        // Act
        _, err := domain.NewImage("", "https://example.com/test.jpg")

        // Assert
        assert.Error(t, err)
        assert.ErrorIs(t, err, domain.ErrEmptyName)
    })
}
```

### テーブル駆動テスト

```go
func TestValidateURL(t *testing.T) {
    tests := []struct {
        name    string
        url     string
        wantErr bool
    }{
        {"valid http", "http://example.com/image.jpg", false},
        {"valid https", "https://example.com/image.jpg", false},
        {"empty", "", true},
        {"invalid", "not-a-url", true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateURL(tt.url)
            if tt.wantErr {
                assert.Error(t, err)
            } else {
                assert.NoError(t, err)
            }
        })
    }
}
```

### テスト実行コマンド

```bash
# 全テスト実行
cd backend && go test ./...

# 詳細出力
go test -v ./...

# カバレッジ付き
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# 特定テスト
go test -v -run TestCreateImage ./domain/...
```

## Frontend テスト（Jest）

### コンポーネントテスト

```tsx
// src/components/todo/TodoItem.test.tsx
import { render, screen, fireEvent } from "@testing-library/react";
import { TodoItem } from "./TodoItem";

describe("TodoItem", () => {
  const mockTodo = {
    id: "1",
    title: "Test Todo",
    completed: false,
  };

  it("should render todo title", () => {
    render(<TodoItem todo={mockTodo} onToggle={() => {}} />);
    expect(screen.getByText("Test Todo")).toBeInTheDocument();
  });

  it("should call onToggle when checkbox clicked", () => {
    const handleToggle = jest.fn();
    render(<TodoItem todo={mockTodo} onToggle={handleToggle} />);

    fireEvent.click(screen.getByRole("checkbox"));

    expect(handleToggle).toHaveBeenCalledWith("1");
  });
});
```

### カスタムフックテスト

```tsx
// src/hooks/useTodos.test.ts
import { renderHook, act } from "@testing-library/react";
import { useTodos } from "./useTodos";

describe("useTodos", () => {
  it("should initialize with empty todos", () => {
    const { result } = renderHook(() => useTodos());
    expect(result.current.todos).toEqual([]);
  });

  it("should add a new todo", async () => {
    const { result } = renderHook(() => useTodos());

    await act(async () => {
      await result.current.addTodo("New Todo");
    });

    expect(result.current.todos).toHaveLength(1);
    expect(result.current.todos[0].title).toBe("New Todo");
  });
});
```

### テスト実行コマンド

```bash
cd frontend

# 全テスト実行
npm run test

# ウォッチモード
npm run test -- --watch

# カバレッジ
npm run test -- --coverage

# 特定ファイル
npm run test -- useTodos.test.ts
```

## よくある誤り

### ⚠️ テスト間の状態共有

```go
// Bad: パッケージ変数で状態共有
var testDB *gorm.DB // ❌

func TestCreate(t *testing.T) {
    // testDBを使用
}

// Good: 各テストで独立
func TestCreate(t *testing.T) {
    db := setupTestDB(t) // テストごとに作成
    defer cleanupTestDB(t, db)
    // ...
}
```

### ⚠️ モックの過剰使用

```go
// Bad: 全てをモック
func TestUserService(t *testing.T) {
    mockRepo := new(MockRepo)
    mockValidator := new(MockValidator)
    mockLogger := new(MockLogger)
    // 実質何もテストしていない ❌
}

// Good: 境界のみモック
func TestUserService(t *testing.T) {
    db := setupTestDB(t)
    repo := NewRealRepo(db)          // 実際のリポジトリ
    mockEmailClient := new(MockEmail) // 外部サービスのみモック

    service := NewUserService(repo, mockEmailClient)
    // ...
}
```

## カバレッジ目標

| レイヤー | 目標 | 優先度 |
|---------|------|--------|
| Domain層 | 90%+ | 最高 |
| Application層 | 80%+ | 高 |
| Hooks | 80%+ | 高 |
| Utils | 90%+ | 高 |
| Components | 60%+ | 中 |

## 参照ファイル

| ファイル | 説明 |
|---------|------|
| `./agents/backend-test-writer.md` | Backend専門ガイド |
| `./agents/frontend-test-writer.md` | Frontend専門ガイド |
| `.claude/rules/testing-rules.md` | テストルール詳細 |
