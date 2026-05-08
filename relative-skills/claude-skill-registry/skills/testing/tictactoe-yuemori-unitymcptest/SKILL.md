---
name: tictactoe
description: Tic Tac Toe game development for Unity. Use for game logic, AI implementation, MVVM architecture, and UI development specific to this project.
---

# Tic Tac Toe Game Development Skill

Unity 6 での Tic Tac Toe（三目並べ）AI 対戦ゲーム開発のためのスキル定義。

## When to Use This Skill

このスキルは以下の作業時にトリガーされる：

- TicTacToe ゲームのロジック実装
- 盤面管理、勝敗判定、ターン管理
- AI 対戦ロジックの実装
- MVVM + Clean Architecture に基づく UI 実装
- VContainer/R3 を使用した DI・イベント実装

## Project Overview

### Game Specification

- **ゲームモード**: AI 対戦オンリー（難易度なし）
- **先手後手**: ランダム決定
- **UI**: 2D uGUI（PC 向け、マウス操作）
- **演出**: アニメーション、効果音あり
- **スコア/リプレイ**: なし

### Tech Stack

- **Engine**: Unity 6000.3.2f1
- **DI**: VContainer
- **Reactive**: R3 (Reactive Extensions)
- **UI**: uGUI (Canvas)
- **Architecture**: MVVM + Clean Architecture
- **Deployment**: WebGL → GitHub Pages

## Quick Reference

### Directory Structure

```
Assets/TicTacToe/
├── Scenes/
│   └── TicTacToeScene.unity
├── Prefabs/UI/
│   ├── BoardPanel.prefab
│   ├── CellButton.prefab
│   ├── ResultPanel.prefab
│   └── TurnIndicator.prefab
├── Scripts/
│   ├── Core/                    # Domain Layer
│   │   ├── Domain/              # Entities, Value Objects
│   │   ├── Repositories/        # Data Containers
│   │   ├── Services/            # Facades (Transaction Boundary)
│   │   └── Strategies/          # AI Algorithms
│   ├── Presentation/            # MVVM Layer
│   │   ├── Board/               # BoardView, BoardViewModel
│   │   ├── Cell/                # CellView, CellViewModel
│   │   ├── Result/              # ResultView, ResultViewModel
│   │   ├── TurnIndicator/       # TurnIndicatorView, TurnIndicatorViewModel
│   │   └── Mediators/           # GameMediator
│   ├── Infrastructure/          # DI, Factories
│   │   ├── Installers/
│   │   └── Factories/
│   └── EntryPoints/
├── Tests/
│   ├── EditMode/
│   └── PlayMode/
├── Audio/SE/
├── Art/Sprites/
└── Animations/
```

### Namespace Convention

```csharp
namespace TicTacToe.Core.Domain { }
namespace TicTacToe.Core.Repositories { }
namespace TicTacToe.Core.Services { }
namespace TicTacToe.Core.Strategies { }
namespace TicTacToe.Presentation.Board { }
namespace TicTacToe.Presentation.Cell { }
namespace TicTacToe.Presentation.Mediators { }
namespace TicTacToe.Infrastructure.Installers { }
```

### Key Patterns

#### Domain Models

```csharp
// CellState.cs
public enum CellState { Empty, X, O }

// PlayerType.cs
public enum PlayerType { Human, AI }

// BoardPosition.cs
public readonly struct BoardPosition
{
    public int Row { get; }
    public int Column { get; }
}
```

#### Service Pattern

```csharp
// GameService.cs - Facade / Transaction Boundary
public class GameService
{
    private readonly BoardRepository _boardRepository;
    private readonly IAIStrategy _aiStrategy;

    public IObservable<GameResult> OnGameEnd { get; }
    public IObservable<PlayerType> OnTurnChanged { get; }

    public void PlaceMark(BoardPosition position) { }
    public void StartNewGame() { }
}
```

#### MVVM Pattern

```csharp
// ViewModel
public class CellViewModel : IDisposable
{
    public IReadOnlyReactiveProperty<CellState> State { get; }
    public IObservable<Unit> OnClicked { get; }
}

// View
public class CellView : MonoBehaviour
{
    [Inject] private CellViewModel _viewModel;
    [SerializeField] private Button _button;
    [SerializeField] private Image _markImage;
}
```

#### AI Strategy

```csharp
public interface IAIStrategy
{
    BoardPosition DecideMove(IReadOnlyList<CellState> board, CellState aiMark);
}

public class RandomAIStrategy : IAIStrategy { }
// Future: MinimaxAIStrategy, etc.
```

## Reference Files

- **[architecture.md](references/architecture.md)** - 設計方針・アーキテクチャ決定
- **[domain_model.md](references/domain_model.md)** - ドメインモデル定義
- **[implementation_guide.md](references/implementation_guide.md)** - 実装ガイド・手順

## WebGL Deployment (GitHub Pages)

### Build Settings

- **圧縮形式**: Disabled（GitHub Pages 互換）
- **解像度**: 960x600
- **メモリ**: 256MB
- **Color Space**: Linear

### Build Helper

`Assets/TicTacToe/Editor/WebGLBuildHelper.cs` でビルド自動化：

```
TicTacToe/WebGL/1. Setup Build Settings     → シーン設定
TicTacToe/WebGL/2. Configure WebGL Player Settings → プレイヤー設定
TicTacToe/WebGL/3. Switch to WebGL Platform → プラットフォーム切替
TicTacToe/WebGL/4. Build WebGL              → ビルド実行
```

### Deploy Workflow (git worktree)

```bash
# 1. worktree作成（gh-pagesブランチ用）
git worktree add ../UnityTest-gh-pages gh-pages

# 2. ビルドファイルをコピー
cd ../UnityTest-gh-pages
rm -rf Build TemplateData index.html
cp -r ../UnityTest/Build/WebGL/* .

# 3. コミット & プッシュ
git add -A
git commit -m "Deploy WebGL build"
git push origin gh-pages

# 4. worktree削除
cd ../UnityTest
git worktree remove ../UnityTest-gh-pages
```

### Public URL

**https://yuemori.github.io/UnityMCPTest/**

### WebGL Known Issues

| 問題                     | 原因                                   | 解決策                         |
| ------------------------ | -------------------------------------- | ------------------------------ |
| AI turns not progressing | `Task.Delay()` WebGL 非対応            | `Observable.Timer()` (R3) 使用 |
| Brotli decode error      | GitHub Pages `Content-Encoding` 未設定 | 圧縮形式 `Disabled` を使用     |

## Integration with Other Skills

- **claude_skill_unity**: Unity 汎用パターン、MonoBehaviour ライフサイクル
- **Serena Memory**: 実装進捗、セッション引き継ぎ

## Notes

- VContainer/R3 は要パッケージ追加
- UI は全て Prefab 化（Scene に直接配置しない）
- テストは Core 層を中心に作成
- WebGL では`System.Threading.Tasks`の使用を避け、R3 Observable を使用
