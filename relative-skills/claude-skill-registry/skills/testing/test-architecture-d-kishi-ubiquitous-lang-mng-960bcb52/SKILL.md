---
name: test-architecture
description: テストアーキテクチャ自律適用Skill。ADR_020レイヤー×テストタイプ分離方式・命名規則・参照関係原則・新規テストプロジェクト作成チェックリスト適用。unit-test/integration-test Agent作業時・新規テストプロジェクト作成時に使用。
allowed-tools: Read, mcp__serena__find_symbol, mcp__serena__get_symbols_overview, Grep
---

# Test Architecture Skill

## 概要

このSkillは、ADR_020テストアーキテクチャ決定に基づく**レイヤー×テストタイプ分離方式**の自律的適用を提供します。新規テストプロジェクト作成時の必須確認事項・命名規則・参照関係原則・Issue #40再発防止策を組み込み、unit-test/integration-test Agent作業時の品質保証を実現します。

---

## 使用タイミング

Claudeは以下の状況でこのSkillを自律的に使用すべきです：

### 1. 新規テストプロジェクト作成時（最重要）

**タイミング**:
- unit-test/integration-test Agent選択時
- 新規テストプロジェクト作成指示を受けた時
- tests/配下に新規ディレクトリ・プロジェクトファイル作成前

**必須確認事項**:
1. ADR_020テストアーキテクチャ決定確認
2. テストアーキテクチャ設計書確認（プロジェクト構成図・命名規則・参照関係原則）
3. 新規プロジェクト作成チェックリスト実行
4. 命名規則厳守（`UbiquitousLanguageManager.{Layer}.{TestType}.Tests`）
5. 参照関係原則遵守

### 2. unit-test/integration-test Agent作業開始時

**タイミング**:
- SubAgent組み合わせパターン選択時
- TDD Red-Green-Refactorサイクル開始時
- テスト実装作業開始時

**必須確認事項**:
1. 既存テストプロジェクト構成確認
2. テストタイプ別参照関係確認
3. テストカバレッジ目標確認（97%）

### 3. テストアーキテクチャ違反検出時

**タイミング**:
- ビルドエラー発生時（参照関係違反）
- 命名規則違反検出時
- レイヤー混在・テストタイプ混在検出時

**必須確認事項**:
1. Issue #40類似問題の再発防止チェック
2. ADR_020準拠性確認
3. テストアーキテクチャ設計書との整合性確認

---

## ADR_020テストアーキテクチャ決定（重要ポイント）

### レイヤー×テストタイプ分離方式

**原則**: 1プロジェクト = 1レイヤー × 1テストタイプ

**テストプロジェクト命名規則**（厳守）:
```
UbiquitousLanguageManager.{Layer}.{TestType}.Tests

例:
- UbiquitousLanguageManager.Domain.Unit.Tests
- UbiquitousLanguageManager.Application.Integration.Tests
- UbiquitousLanguageManager.Web.E2E.Tests
```

**Layer選択**:
- **Domain**: ドメインモデル・Value Objects・Domain Services
- **Application**: Use Cases・Application Services
- **Contracts**: DTOs・Type Converters（F#↔C#境界）
- **Infrastructure**: Repositories・EF Core・外部連携
- **Web**: Blazor Components・Pages・Web Services

**TestType選択**:
- **Unit**: 単体テスト（テスト対象レイヤーのみ参照）
- **Integration**: 統合テスト（複数レイヤー・DB・外部連携）
- **UI**: UIコンポーネントテスト（Blazor bUnit使用）
- **E2E**: エンドツーエンドテスト（Playwright使用）

---

## 参照関係原則（ADR_020準拠）

### Unit Tests参照関係

**原則**: テスト対象レイヤーのみ参照（最小化原則）

**Domain.Unit.Tests（F#）**:
```xml
<ItemGroup>
  <!-- ADR_020準拠: Unit Tests原則 - テスト対象レイヤーのみ参照 -->
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Domain\UbiquitousLanguageManager.Domain.fsproj" />
</ItemGroup>
```

**Application.Unit.Tests（F#）**:
```xml
<ItemGroup>
  <!-- Application層はDomain層に依存するため、両方参照 -->
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Application\UbiquitousLanguageManager.Application.fsproj" />
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Domain\UbiquitousLanguageManager.Domain.fsproj" />
</ItemGroup>
```

**Contracts.Unit.Tests（C#）**:
```xml
<ItemGroup>
  <!-- Contracts層はApplication・Domain層に依存するため、3層参照 -->
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Contracts\UbiquitousLanguageManager.Contracts.csproj" />
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Application\UbiquitousLanguageManager.Application.fsproj" />
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Domain\UbiquitousLanguageManager.Domain.fsproj" />
</ItemGroup>
```

### Integration Tests参照関係

**原則**: 必要な依存層のみ参照（WebApplicationFactory使用時は全層参照）

**Infrastructure.Integration.Tests（C#）**:
```xml
<ItemGroup>
  <!-- 統合テスト: 全層参照（WebApplicationFactory使用のため） -->
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Infrastructure\UbiquitousLanguageManager.Infrastructure.csproj" />
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Application\UbiquitousLanguageManager.Application.fsproj" />
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Domain\UbiquitousLanguageManager.Domain.fsproj" />
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Web\UbiquitousLanguageManager.Web.csproj" />
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Contracts\UbiquitousLanguageManager.Contracts.csproj" />
</ItemGroup>
```

### E2E Tests参照関係

**原則**: 全層参照可・Playwright使用

**Web.E2E.Tests（C#）**:
```xml
<ItemGroup>
  <!-- E2Eテスト: 全層参照 -->
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Web\UbiquitousLanguageManager.Web.csproj" />
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Infrastructure\UbiquitousLanguageManager.Infrastructure.csproj" />
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Application\UbiquitousLanguageManager.Application.fsproj" />
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Domain\UbiquitousLanguageManager.Domain.fsproj" />
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Contracts\UbiquitousLanguageManager.Contracts.csproj" />
</ItemGroup>
```

---

## 新規テストプロジェクト作成チェックリスト

### 事前確認チェックリスト

**新規テストプロジェクト作成前に以下を必ず確認すること**:

- [ ] **ADR_020テストアーキテクチャ決定確認**: `/Doc/07_Decisions/ADR_020_テストアーキテクチャ決定.md`
- [ ] **テストアーキテクチャ設計書確認**: `/Doc/02_Design/テストアーキテクチャ設計書.md`
- [ ] **新規プロジェクト作成ガイドライン確認**: `/Doc/08_Organization/Rules/新規テストプロジェクト作成ガイドライン.md`
- [ ] **既存テストプロジェクトとの重複確認**: 同一レイヤー・同一テストタイプのプロジェクト存在確認
- [ ] **レイヤー・テストタイプの分類明確化**: Layer（Domain/Application/Contracts/Infrastructure/Web）とTestType（Unit/Integration/UI/E2E）の明確化

### プロジェクト作成チェックリスト

**詳細**: [`rules/new-test-project-checklist.md`](./rules/new-test-project-checklist.md)

- [ ] **プロジェクト作成コマンド実行**: F#（`dotnet new xunit -lang F#`）またはC#（`dotnet new xunit`）
- [ ] **命名規則確認**: `UbiquitousLanguageManager.{Layer}.{TestType}.Tests`
- [ ] **言語・SDK選択確認**: レイヤー別言語原則（Domain/Application=F#, Contracts/Infrastructure/Web=C#）
- [ ] **参照関係設定**: ADR_020参照関係原則に準拠
- [ ] **NuGetパッケージ追加**: テストタイプ別標準パッケージ追加

### ビルド・実行確認チェックリスト

- [ ] **ソリューションファイル更新**: `dotnet sln add tests/{ProjectName}`
- [ ] **ソリューション一覧確認**: `dotnet sln list`で新規プロジェクト確認
- [ ] **新規プロジェクト個別ビルド成功**: `dotnet build tests/{ProjectName}`（0 Warning/0 Error）
- [ ] **ソリューション全体ビルド成功**: `dotnet build`（既存プロジェクトへの影響なし）
- [ ] **新規プロジェクト個別テスト実行成功**: `dotnet test tests/{ProjectName}`
- [ ] **ソリューション全体テスト実行成功**: `dotnet test`（既存テスト100%維持）

### Issue #40再発防止チェックリスト

**Issue #40教訓**: テストアーキテクチャ再構成（7プロジェクト分割）

- [ ] **EnableDefaultCompileItems=false設定禁止**: .csproj/.fsprojに存在しないこと確認
- [ ] **F#/C#混在回避**: F#プロジェクトにC#ファイルを含めない
- [ ] **テストタイプ混在回避**: 1プロジェクト内に複数テストタイプを混在させない
- [ ] **レイヤー混在回避**: 1プロジェクト内に複数レイヤーのテストを混在させない
- [ ] **レイヤー別分離確認**: 1プロジェクト = 1レイヤー × 1テストタイプ
- [ ] **参照関係最小化**: Unit Testsはテスト対象レイヤーのみ参照
- [ ] **命名規則準拠**: `{ProjectName}.{Layer}.{TestType}.Tests`形式厳守

---

## テストアーキテクチャ適用パターン

### Pattern 1: Domain層Unit Tests作成

**シナリオ**: Domain層（F#）の単体テスト作成

**Step-by-Step**:
1. **事前確認**: ADR_020 + テストアーキテクチャ設計書確認
2. **プロジェクト作成**: `dotnet new xunit -lang F# -n UbiquitousLanguageManager.Domain.Unit.Tests -o tests/UbiquitousLanguageManager.Domain.Unit.Tests`
3. **命名規則確認**: `UbiquitousLanguageManager.Domain.Unit.Tests`
4. **参照関係設定**: Domain層のみ参照
5. **NuGetパッケージ追加**: xunit + FsUnit.xUnit + coverlet.collector
6. **ビルド確認**: `dotnet build tests/UbiquitousLanguageManager.Domain.Unit.Tests`
7. **ソリューション追加**: `dotnet sln add tests/UbiquitousLanguageManager.Domain.Unit.Tests`

**詳細**: [`rules/test-project-naming-convention.md`](./rules/test-project-naming-convention.md)

---

### Pattern 2: Infrastructure層Integration Tests作成

**シナリオ**: Infrastructure層（C#）の統合テスト作成

**Step-by-Step**:
1. **事前確認**: ADR_020 + テストアーキテクチャ設計書確認
2. **プロジェクト作成**: `dotnet new xunit -n UbiquitousLanguageManager.Infrastructure.Integration.Tests -o tests/UbiquitousLanguageManager.Infrastructure.Integration.Tests`
3. **命名規則確認**: `UbiquitousLanguageManager.Infrastructure.Integration.Tests`
4. **参照関係設定**: 全層参照（WebApplicationFactory使用）
5. **NuGetパッケージ追加**: xunit + Microsoft.AspNetCore.Mvc.Testing + Testcontainers.PostgreSql
6. **ビルド確認**: `dotnet build tests/UbiquitousLanguageManager.Infrastructure.Integration.Tests`
7. **ソリューション追加**: `dotnet sln add tests/UbiquitousLanguageManager.Infrastructure.Integration.Tests`

**詳細**: [`rules/test-project-reference-rules.md`](./rules/test-project-reference-rules.md)

---

### Pattern 3: Web層E2E Tests作成

**シナリオ**: Web層（C#）のE2Eテスト作成（Playwright使用）

**Step-by-Step**:
1. **事前確認**: ADR_020 + テストアーキテクチャ設計書 + Playwright MCP確認
2. **プロジェクト作成**: `dotnet new xunit -n UbiquitousLanguageManager.Web.E2E.Tests -o tests/UbiquitousLanguageManager.Web.E2E.Tests`
3. **命名規則確認**: `UbiquitousLanguageManager.Web.E2E.Tests`
4. **参照関係設定**: 全層参照
5. **NuGetパッケージ追加**: xunit + Microsoft.Playwright + Microsoft.AspNetCore.Mvc.Testing
6. **Playwright MCP統合**: data-testid属性設計
7. **ビルド確認**: `dotnet build tests/UbiquitousLanguageManager.Web.E2E.Tests`
8. **ソリューション追加**: `dotnet sln add tests/UbiquitousLanguageManager.Web.E2E.Tests`

**詳細**: [`rules/new-test-project-checklist.md`](./rules/new-test-project-checklist.md)

---

## テストアーキテクチャ違反検出・修正パターン

### 違反例1: 命名規則違反

**検出**:
```bash
❌ UbiquitousLanguageManager.DomainTests
❌ UbiquitousLanguageManager.Tests
❌ Domain.Unit.Tests
```

**修正**:
```bash
✅ UbiquitousLanguageManager.Domain.Unit.Tests
```

**理由**: ADR_020命名規則 `{ProjectName}.{Layer}.{TestType}.Tests` 厳守

---

### 違反例2: 参照関係違反

**検出**:
```xml
<!-- Domain.Unit.Tests が Application層を参照（違反） -->
<ItemGroup>
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Domain\UbiquitousLanguageManager.Domain.fsproj" />
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Application\UbiquitousLanguageManager.Application.fsproj" />
</ItemGroup>
```

**修正**:
```xml
<!-- Domain.Unit.Tests は Domain層のみ参照 -->
<ItemGroup>
  <ProjectReference Include="..\..\src\UbiquitousLanguageManager.Domain\UbiquitousLanguageManager.Domain.fsproj" />
</ItemGroup>
```

**理由**: ADR_020参照関係原則（Unit Testsはテスト対象レイヤーのみ参照）

---

### 違反例3: レイヤー混在

**検出**:
```
tests/UbiquitousLanguageManager.Domain.Unit.Tests/
  ├── DomainTests/  （Domain層テスト）
  └── ApplicationTests/  （Application層テスト・混在）
```

**修正**:
```
tests/UbiquitousLanguageManager.Domain.Unit.Tests/
  └── DomainTests/  （Domain層テストのみ）

tests/UbiquitousLanguageManager.Application.Unit.Tests/
  └── ApplicationTests/  （Application層テスト）
```

**理由**: 1プロジェクト = 1レイヤー × 1テストタイプ原則

---

## 言語選択原則

### レイヤー別言語選択

| Layer | 言語 | 理由 |
|-------|------|------|
| Domain | F# | ドメインロジックはF#で実装 |
| Application | F# | ユースケースはF#で実装 |
| Contracts | C# | DTOs・Type ConvertersはC#で実装 |
| Infrastructure | C# | EF Core・RepositoriesはC#で実装 |
| Web | C# | Blazor ServerはC#で実装 |

### SDK選択原則

| TestType | SDK | 理由 |
|----------|-----|------|
| Unit | `Microsoft.NET.Sdk` | 標準テスト（デフォルト） |
| Integration | `Microsoft.NET.Sdk` | 標準テスト |
| UI (bUnit) | `Microsoft.NET.Sdk.Razor` | **Blazor Componentテストのため必須** |
| E2E (Playwright) | `Microsoft.NET.Sdk` | 標準テスト |

---

## NuGetパッケージ標準セット

### F# Unit Tests標準パッケージ

```bash
dotnet add package xunit
dotnet add package xunit.runner.visualstudio
dotnet add package Microsoft.NET.Test.Sdk
dotnet add package FsUnit.xUnit
dotnet add package coverlet.collector
```

### C# Unit Tests標準パッケージ

```bash
dotnet add package xunit
dotnet add package xunit.runner.visualstudio
dotnet add package Microsoft.NET.Test.Sdk
dotnet add package FluentAssertions
dotnet add package Moq
dotnet add package coverlet.collector
```

### Integration Tests標準パッケージ

```bash
dotnet add package Microsoft.AspNetCore.Mvc.Testing
dotnet add package Microsoft.EntityFrameworkCore.InMemory
dotnet add package Testcontainers.PostgreSql
```

### E2E Tests（Playwright）標準パッケージ

```bash
dotnet add package Microsoft.Playwright
dotnet add package Microsoft.AspNetCore.Mvc.Testing
```

---

## 品質目標

### テストカバレッジ目標

```yaml
目標カバレッジ:
  - 単体テスト: 97%以上（Phase B1達成実績）
  - 統合テスト: 85%以上（Phase B2達成実績）

測定方法:
  - dotnet test --collect:"XPlat Code Coverage"
```

### ビルド品質目標

```yaml
目標品質:
  - 0 Warning / 0 Error（厳守）
  - ビルド時間最小化（不要な参照削除）
```

---

## 関連Skills

- **tdd-red-green-refactor Skill**: TDD実践パターン（unit-test Agent活用）
- **playwright-e2e-patterns Skill**: Playwright MCP活用E2Eテスト作成パターン
- **subagent-patterns Skill**: unit-test/integration-test Agent組み合わせパターン
- **clean-architecture-guardian Skill**: Clean Architecture準拠性チェック

---

## 参照元ADR・Rules

- **ADR_020**: `/Doc/07_Decisions/ADR_020_テストアーキテクチャ決定.md` - レイヤー×テストタイプ分離方式決定
- **新規テストプロジェクト作成ガイドライン**: `/Doc/08_Organization/Rules/新規テストプロジェクト作成ガイドライン.md` - 詳細手順・チェックリスト
- **テストアーキテクチャ設計書**: `/Doc/02_Design/テストアーキテクチャ設計書.md` - プロジェクト構成図・参照関係

---

**作成日**: 2025-11-01
**Phase B-F2 Step2**: Agent Skills Phase 2展開
**参照**: ADR_020, 新規テストプロジェクト作成ガイドライン, Issue #40教訓
