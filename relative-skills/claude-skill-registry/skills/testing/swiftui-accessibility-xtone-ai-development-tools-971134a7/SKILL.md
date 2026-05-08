---
name: swiftui-accessibility
description: Accessibility implementation guide for SwiftUI apps. Use when implementing VoiceOver support, adding accessibilityLabel/Hint/Value, supporting Dynamic Type, ensuring color contrast, testing accessibility, or reviewing accessibility in PRs. Covers iOS accessibility APIs, WCAG guidelines, and testing tools.
---

# SwiftUI Accessibility Guide

SwiftUIアプリのアクセシビリティ実装ガイド。

## ディレクトリ構成

```
swiftui-accessibility/
├── SKILL.md (このファイル)
└── references/
    └── accessibility.md
```

## リファレンスファイル

### references/accessibility.md
アクセシビリティ実装ガイド：
- **VoiceOver対応**:
  - accessibilityLabel: 要素の説明
  - accessibilityHint: 操作のヒント
  - accessibilityValue: 現在の値
  - accessibilityTraits: 要素の種類
- **Dynamic Type**: 
  - フォントスケーリング
  - レイアウト対応
- **色のコントラスト**:
  - WCAG基準
  - ダークモード対応
- **モーション**:
  - reduceMotion対応
  - アニメーション代替
- **テストとツール**:
  - Accessibility Inspector
  - VoiceOverテスト方法

## 使用方法

### アクセシビリティ実装時
1. `references/accessibility.md`で実装パターンを確認
2. VoiceOverでテスト
3. Dynamic Typeでレイアウト確認

### PRレビュー時
1. アクセシビリティラベルの有無を確認
2. 画像にaltテキストがあるか確認
3. タップ領域が十分か確認

## クイック実装ガイド

### VoiceOver基本

```swift
// ラベル（必須）
Image(systemName: "heart.fill")
    .accessibilityLabel("お気に入り")

// ヒント（操作説明）
Button("削除") { }
    .accessibilityHint("この項目を削除します")

// 値（現在の状態）
Slider(value: $volume)
    .accessibilityValue("\(Int(volume))パーセント")
```

### Dynamic Type対応

```swift
// 推奨: システムフォント
Text("Hello")
    .font(.body)

// カスタムフォントのスケーリング
Text("Hello")
    .font(.custom("MyFont", size: 16, relativeTo: .body))
```

### reduceMotion対応

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    content
        .animation(reduceMotion ? nil : .default, value: isExpanded)
}
```

## チェックリスト

- [ ] 全てのインタラクティブ要素にaccessibilityLabelがあるか
- [ ] 画像に適切な説明があるか
- [ ] Dynamic Typeでレイアウトが崩れないか
- [ ] 色だけに依存した情報伝達がないか
- [ ] タップ領域は44pt以上あるか

## 関連スキル

- **swiftui-coding-guidelines**: 基本的なベストプラクティス
- **swiftui-code-review-checklist**: PRレビュー時のアクセシビリティチェック
