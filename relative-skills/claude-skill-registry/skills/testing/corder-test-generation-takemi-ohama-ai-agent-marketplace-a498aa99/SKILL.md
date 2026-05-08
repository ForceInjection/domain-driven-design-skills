---
name: corder-test-generation
description: |
  Generate unit tests, integration tests, and test fixtures for code. Supports Jest, Mocha, pytest. Use when writing tests or improving test coverage.

  This skill provides automated test generation:
  - Unit tests with AAA pattern (Arrange, Act, Assert)
  - Integration tests for APIs and databases
  - Test fixtures and mocks
  - Edge case identification
  - Test coverage recommendations

  Triggers: "generate tests", "create unit test", "add test coverage", "write tests", "テスト生成", "テストコード作成", "カバレッジ向上"
allowed-tools:
  - Read
  - Write
  - Bash
---

# Corder Test Generation Skill

## 概要

このSkillは、corderエージェントが既存のコードに対してテストを自動生成する際に使用します。Jest、Mocha、pytestなどの主要なテストフレームワークに対応し、ユニットテスト、統合テスト、テストフィクスチャを生成します。

## 主な機能

1. **ユニットテスト生成**: AAA（Arrange-Act-Assert）パターンに従った構造化されたテスト
2. **統合テスト生成**: API、データベース、外部サービスの統合テスト
3. **テストフィクスチャ生成**: モックデータ、スタブ、スパイ
4. **エッジケース識別**: 境界値、null/undefined、エラーケース
5. **カバレッジ推奨**: テストすべき重要な関数/メソッドの特定

## 使用方法

### テンプレート一覧

```
templates/
├── jest-unit-test.test.js       # Jest ユニットテスト
├── mocha-test.test.js           # Mocha テスト
├── pytest-test.py               # pytest
├── test-fixtures.json           # テストデータ
└── integration-test.test.js     # 統合テスト
```

### 使用例

**1. 既存関数のユニットテスト生成**

```javascript
// 元のコード: src/utils/calculator.js
function add(a, b) {
  return a + b;
}

function divide(a, b) {
  if (b === 0) {
    throw new Error('Division by zero');
  }
  return a / b;
}

module.exports = { add, divide };
```

**生成されるテスト**:
```javascript
// tests/utils/calculator.test.js
const { add, divide } = require('../../src/utils/calculator');

describe('calculator', () => {
  describe('add', () => {
    test('should add two positive numbers', () => {
      // Arrange
      const a = 2;
      const b = 3;
      const expected = 5;

      // Act
      const result = add(a, b);

      // Assert
      expect(result).toBe(expected);
    });

    test('should handle negative numbers', () => {
      expect(add(-2, -3)).toBe(-5);
    });

    test('should handle zero', () => {
      expect(add(0, 5)).toBe(5);
      expect(add(5, 0)).toBe(5);
    });
  });

  describe('divide', () => {
    test('should divide two numbers', () => {
      expect(divide(10, 2)).toBe(5);
    });

    test('should throw error when dividing by zero', () => {
      expect(() => divide(10, 0)).toThrow('Division by zero');
    });

    test('should handle negative numbers', () => {
      expect(divide(-10, 2)).toBe(-5);
    });
  });
});
```

**2. API統合テスト生成**

```javascript
// tests/api/users.integration.test.js
const request = require('supertest');
const app = require('../../app');
const db = require('../../models');

describe('Users API', () => {
  beforeAll(async () => {
    await db.sequelize.sync({ force: true });
  });

  afterAll(async () => {
    await db.sequelize.close();
  });

  describe('GET /api/users', () => {
    test('should return all users', async () => {
      const response = await request(app)
        .get('/api/users')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
    });

    test('should support pagination', async () => {
      const response = await request(app)
        .get('/api/users?page=1&limit=10')
        .expect(200);

      expect(response.body.pagination).toBeDefined();
      expect(response.body.pagination.page).toBe(1);
      expect(response.body.pagination.limit).toBe(10);
    });
  });

  describe('POST /api/users', () => {
    test('should create new user', async () => {
      const newUser = {
        name: 'Test User',
        email: 'test@example.com'
      };

      const response = await request(app)
        .post('/api/users')
        .send(newUser)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.name).toBe(newUser.name);
    });

    test('should return 400 for invalid data', async () => {
      const invalidUser = {
        name: 'A', // Too short
        email: 'invalid-email'
      };

      const response = await request(app)
        .post('/api/users')
        .send(invalidUser)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });
  });
});
```

## スクリプト機能

### generate-tests.js

既存のコードを解析し、テストケースのスケルトンを自動生成します。

**使用方法**:
```bash
node scripts/generate-tests.js src/utils/calculator.js
```

**機能**:
- 関数シグネチャの抽出（Serena MCP使用）
- 引数の型推論
- 戻り値の型推論
- エッジケースの提案（null、undefined、境界値）
- テストファイルの自動配置

## テストパターン

### 1. AAA（Arrange-Act-Assert）パターン

```javascript
test('should do something', () => {
  // Arrange: テストデータを準備
  const input = { ... };
  const expected = { ... };

  // Act: テスト対象を実行
  const result = functionUnderTest(input);

  // Assert: 結果を検証
  expect(result).toEqual(expected);
});
```

### 2. エッジケーステスト

```javascript
describe('edge cases', () => {
  test('should handle null input', () => {
    expect(() => func(null)).toThrow();
  });

  test('should handle empty array', () => {
    expect(func([])).toEqual([]);
  });

  test('should handle boundary values', () => {
    expect(func(0)).toBe(...);
    expect(func(-1)).toBe(...);
    expect(func(Number.MAX_VALUE)).toBe(...);
  });
});
```

### 3. モック・スパイ

```javascript
test('should call API', async () => {
  // モック作成
  const mockFetch = jest.fn().mockResolvedValue({
    json: () => ({ data: 'test' })
  });
  global.fetch = mockFetch;

  // 実行
  await fetchData();

  // 検証
  expect(mockFetch).toHaveBeenCalledWith('/api/data');
  expect(mockFetch).toHaveBeenCalledTimes(1);
});
```

## ベストプラクティス

### DO（推奨）

✅ **AAAパターンに従う**: テストの可読性向上
✅ **1テスト = 1アサーション**: テストの意図を明確に
✅ **エッジケースをテスト**: null、empty、boundary値
✅ **独立したテスト**: 実行順序に依存しない
✅ **わかりやすいテスト名**: 何をテストするか明示

### DON'T（非推奨）

❌ **テストの重複**: 同じことを複数回テストしない
❌ **実装の詳細に依存**: 内部変数名等に依存しない
❌ **過剰なモック**: 必要最小限にとどめる
❌ **外部依存**: ネットワーク、データベースはモック
❌ **テストのテスト**: テストコード自体はテストしない

## カバレッジ目標

- **ユニットテスト**: 80%以上
- **クリティカルパス**: 100%
- **エッジケース**: 主要な境界値をカバー

## Progressive Disclosure

このSKILL.mdはメインドキュメント（約250行）です。詳細なテンプレートとスクリプトは `templates/`, `scripts/` ディレクトリ内のファイルを参照してください。

## 関連Skill

- **corder-code-templates**: テスト対象のコード生成
- **qa-code-review-checklist**: テスト品質のレビュー

## 関連リソース

- **templates/**: テストテンプレート集
- **scripts/generate-tests.js**: 自動テスト生成スクリプト
