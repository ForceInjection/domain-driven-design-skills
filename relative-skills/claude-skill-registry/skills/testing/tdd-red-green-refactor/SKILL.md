---
name: tdd-red-green-refactor
description: TDD Red-Green-Refactorサイクル実践パターン提供。unit-test Agent活用・テスタブルコード設計原則・テストカバレッジ管理方法。Phase C以降の新機能実装時に使用。
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# TDD Red-Green-Refactor Skill

## 概要

このSkillは、TDD (Test-Driven Development) のRed-Green-Refactorサイクルを実践するためのパターン・チェックリスト・判断基準を提供します。ADR_009テスト指針で確立した品質基準（テストカバレッジ80%以上・Domain層100%）を自動維持します。

## 使用タイミング

Claudeは以下の状況でこのSkillを自律的に使用すべきです：

1. **新機能実装時**
   - 新規ドメインモデル作成時
   - 新規ユースケース実装時
   - 新規APIエンドポイント作成時

2. **バグ修正時**
   - バグ再現テスト作成時
   - 修正後の回帰テスト実行時

3. **リファクタリング時**
   - コード構造変更前のテスト網羅確認
   - リファクタリング後のテスト成功確認

4. **unit-test Agent起動時**
   - unit-test Agentへの指示作成時
   - テストカバレッジ確認時

## Red-Green-Refactorサイクル

### Phase: Red（失敗するテストを書く）

**詳細**: [`patterns/red-phase-pattern.md`](./patterns/red-phase-pattern.md)

**実施手順**:
1. ✅ **要件理解**: 実装すべき機能仕様を明確化
2. ✅ **テストケース設計**: 正常系・異常系・境界値を洗い出し
3. ✅ **テストコード作成**: xUnit + FluentAssertions/FsUnit.xUnit使用
4. ✅ **テスト実行**: 失敗することを確認（Red状態）
5. ✅ **失敗理由確認**: 期待する実装が未作成であることを確認

**チェックポイント**:
- ❌ テストが失敗している（Red状態）
- ✅ テストコードが実装仕様を明確に表現している
- ✅ テストが1つの責務のみをテストしている
- ✅ テストメソッド名がテスト内容を明確に表現している

**典型的な問題**: テストが最初からGreenになる（実装が先行している）

---

### Phase: Green（テストを通す最小実装）

**詳細**: [`patterns/green-phase-pattern.md`](./patterns/green-phase-pattern.md)

**実施手順**:
1. ✅ **最小実装**: テストを通すための最小限のコード作成
2. ✅ **テスト実行**: Green状態になることを確認
3. ✅ **テストカバレッジ確認**: 新規コードが100%カバーされていることを確認
4. ✅ **ビルド確認**: 0 Warning / 0 Error維持

**チェックポイント**:
- ✅ テストが成功している（Green状態）
- ✅ 実装が必要最小限（過剰実装なし）
- ✅ ビルドが成功している（0 Warning / 0 Error）
- ✅ 既存テストが全て成功している（回帰なし）

**典型的な問題**: 過剰実装（テストされていないコードを追加）

---

### Phase: Refactor（コード品質改善）

**詳細**: [`patterns/refactor-phase-pattern.md`](./patterns/refactor-phase-pattern.md)

**実施手順**:
1. ✅ **リファクタリング対象特定**: 重複コード・長いメソッド・命名改善
2. ✅ **リファクタリング実行**: コード構造改善
3. ✅ **テスト再実行**: Green状態維持を確認
4. ✅ **ビルド確認**: 0 Warning / 0 Error維持
5. ✅ **コードレビュー**: Clean Architecture準拠確認

**チェックポイント**:
- ✅ テストが成功している（Green状態維持）
- ✅ コード品質が改善している（可読性・保守性向上）
- ✅ Clean Architecture準拠（レイヤー分離・依存関係方向）
- ✅ F# + C#混在環境での型安全性確保

**典型的な問題**: リファクタリング中にテストが失敗（動作変更してしまった）

---

## unit-test Agent活用パターン

### unit-test Agent起動判断

**起動すべき状況**:
- 新規テストクラス作成時（3個以上のテストメソッド必要時）
- 既存テストクラス拡張時（5個以上のテストメソッド追加時）
- テストカバレッジ不足時（80%未満）

**MainAgentで直接実施すべき状況**:
- 単純なテストメソッド1-2個追加時
- テストメソッド名修正のみ
- アサーション修正のみ

### unit-test Agentへの指示テンプレート

```markdown
unit-test Agent, 以下のテスト作成をお願いします：

**対象**: [テスト対象クラス・メソッド名]
**テストケース**:
1. 正常系: [シナリオ]
2. 異常系: [シナリオ]
3. 境界値: [シナリオ]

**期待するテストカバレッジ**: [%]
**参照ADR**: ADR_009テスト指針
**参照Skill**: tdd-red-green-refactor
```

---

## テスタブルコード設計原則

### 1. 依存性注入（DI）

**F# Domain層**:
```fsharp
// ✅ Good: 純粋関数（外部依存なし）
module UserValidation =
    let validateEmail (email: string) : Result<Email, ValidationError> =
        if String.IsNullOrWhiteSpace(email) then
            Error EmptyEmail
        else
            Ok (Email email)
```

**C# Application層**:
```csharp
// ✅ Good: コンストラクタインジェクション
public class UserService
{
    private readonly IUserRepository _userRepository;

    public UserService(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }
}
```

### 2. インターフェース分離

**C# Infrastructure層**:
```csharp
// ✅ Good: インターフェース定義
public interface IUserRepository
{
    Task<User?> GetByIdAsync(Guid id);
    Task AddAsync(User user);
}

// ✅ Good: テスト時はNSubstituteでモック作成
```

### 3. F#純粋関数の活用

**F# Domain層**:
```fsharp
// ✅ Good: 純粋関数（副作用なし・テスト容易）
module UserDomain =
    let createUser (name: string) (email: Email) : Result<User, DomainError> =
        if String.IsNullOrWhiteSpace(name) then
            Error InvalidUserName
        else
            Ok { Name = name; Email = email }
```

---

## テストカバレッジ管理方法

### カバレッジ目標（ADR_009準拠）

- **全体**: 80%以上
- **Domain層（F#）**: 100%（最優先）
- **Application層（C#）**: 90%以上
- **Infrastructure層（C#）**: 70%以上
- **Web層（Blazor Server）**: 50%以上（UI統合テストで補完）

### カバレッジ測定コマンド

```bash
# カバレッジ測定
dotnet test --collect:"XPlat Code Coverage"

# カバレッジレポート生成（reportgenerator使用）
reportgenerator \
  -reports:**/coverage.cobertura.xml \
  -targetdir:coverage-report \
  -reporttypes:Html
```

### カバレッジ不足時の対応

1. **Domain層カバレッジ < 100%**
   - 🔴 **重大**: 即座にテスト追加（最優先）
   - unit-test Agent起動してテスト網羅

2. **Application層カバレッジ < 90%**
   - 🟡 **警告**: 次Step開始前にテスト追加
   - 統合テストで補完検討

3. **Infrastructure層カバレッジ < 70%**
   - 🟡 **警告**: Phase完了前にテスト追加
   - integration-test Agent起動検討

---

## TDDサイクル実践チェックリスト

### Red Phase チェックリスト

- [ ] 要件仕様を明確に理解した
- [ ] テストケース（正常系・異常系・境界値）を洗い出した
- [ ] テストメソッド名が明確である（`[TestMethod]_[Scenario]_[ExpectedResult]`形式）
- [ ] テストが失敗する（Red状態）ことを確認した
- [ ] 失敗理由が「実装が未作成」であることを確認した

### Green Phase チェックリスト

- [ ] テストを通すための最小実装を作成した
- [ ] テストが成功する（Green状態）ことを確認した
- [ ] 新規コードのテストカバレッジが100%である
- [ ] ビルドが成功した（0 Warning / 0 Error）
- [ ] 既存テストが全て成功した（回帰なし）

### Refactor Phase チェックリスト

- [ ] リファクタリング対象を特定した
- [ ] リファクタリングを実行した
- [ ] テストが成功する（Green状態維持）ことを確認した
- [ ] ビルドが成功した（0 Warning / 0 Error）
- [ ] Clean Architecture準拠を確認した（clean-architecture-guardian Skill使用）
- [ ] コード品質が改善した（可読性・保守性向上）

---

## 参照元ADR・Rules

- **ADR_009**: テスト指針（テストピラミッド・品質基準）
- **テスト戦略ガイド.md**: テスト実行戦略・CI/CD統合
- **組織管理運用マニュアル.md**: unit-test Agent選択・実行パターン

---

## 関連Skills

- **unit-test Skill**: 単体テスト設計・実装・実行（SubAgent）
- **clean-architecture-guardian Skill**: Clean Architecture準拠性チェック（Refactor Phase使用）
- **fsharp-csharp-bridge Skill**: F#↔C#境界のテスト方法

---

**作成日**: 2025-11-01
**Phase B-F2 Step2**: Agent Skills Phase 2展開
**参照ADR**: ADR_009テスト指針
