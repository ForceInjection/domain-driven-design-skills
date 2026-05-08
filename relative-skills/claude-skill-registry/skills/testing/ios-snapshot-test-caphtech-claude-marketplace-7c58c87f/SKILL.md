---
name: ios-snapshot-test
description: |
  スナップショットテスト支援。swift-snapshot-testing、UI変更検出。
  使用タイミング: (1) UIコンポーネントのリグレッションテスト、(2) デザインシステムの検証、
  (3) 複数デバイス・ダークモード対応の確認、(4) UIリファクタリング時の安全性確保
---

# iOS スナップショットテスト支援スキル

swift-snapshot-testingを使用したUIスナップショットテストをガイドする。

## swift-snapshot-testing

### 導入

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.0")
]

// テストターゲットに追加
.testTarget(
    name: "MyAppTests",
    dependencies: [
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
    ]
)
```

### 基本的なテスト

```swift
import XCTest
import SnapshotTesting
@testable import MyApp

final class ProfileViewSnapshotTests: XCTestCase {
    
    // 記録モードを有効にして初回スナップショット生成
    // isRecording = true
    
    func testProfileView() {
        let view = ProfileView(user: .mock)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testProfileView_darkMode() {
        let view = ProfileView(user: .mock)
        
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
    
    func testProfileView_largeText() {
        let view = ProfileView(user: .mock)
        
        assertSnapshot(
            of: view,
            as: .image(traits: .init(preferredContentSizeCategory: .accessibilityLarge))
        )
    }
}
```

## SwiftUIビューのテスト

### ホスティングコントローラー経由

```swift
import SwiftUI
import SnapshotTesting

final class SwiftUISnapshotTests: XCTestCase {
    
    func testContentView() {
        let view = ContentView()
        let controller = UIHostingController(rootView: view)
        
        // サイズを指定
        controller.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        
        assertSnapshot(of: controller, as: .image)
    }
    
    func testButtonStyles() {
        let view = VStack(spacing: 16) {
            Button("Primary") {}
                .buttonStyle(PrimaryButtonStyle())
            
            Button("Secondary") {}
                .buttonStyle(SecondaryButtonStyle())
            
            Button("Destructive") {}
                .buttonStyle(DestructiveButtonStyle())
        }
        .padding()
        
        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        
        assertSnapshot(of: controller, as: .image)
    }
}
```

### カスタムスナップショット戦略

```swift
extension Snapshotting where Value: SwiftUI.View, Format == UIImage {
    static func swiftUIImage(
        drawHierarchyInKeyWindow: Bool = false,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        size: CGSize? = nil,
        traits: UITraitCollection = .init()
    ) -> Snapshotting {
        return Snapshotting<UIViewController, UIImage>.image(
            drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            size: size,
            traits: traits
        ).pullback { view in
            UIHostingController(rootView: view)
        }
    }
}

// 使用例
func testCustomStrategy() {
    let view = MyCustomView()
    
    assertSnapshot(
        of: view,
        as: .swiftUIImage(size: CGSize(width: 320, height: 480))
    )
}
```

## 複数デバイス対応

### デバイス設定

```swift
struct SnapshotDevice {
    let name: String
    let size: CGSize
    let traits: UITraitCollection
    
    static let iPhone15Pro = SnapshotDevice(
        name: "iPhone15Pro",
        size: CGSize(width: 393, height: 852),
        traits: .init(userInterfaceIdiom: .phone)
    )
    
    static let iPhone15ProMax = SnapshotDevice(
        name: "iPhone15ProMax",
        size: CGSize(width: 430, height: 932),
        traits: .init(userInterfaceIdiom: .phone)
    )
    
    static let iPhoneSE = SnapshotDevice(
        name: "iPhoneSE",
        size: CGSize(width: 375, height: 667),
        traits: .init(userInterfaceIdiom: .phone)
    )
    
    static let iPadPro12_9 = SnapshotDevice(
        name: "iPadPro12_9",
        size: CGSize(width: 1024, height: 1366),
        traits: .init(userInterfaceIdiom: .pad)
    )
    
    static let all: [SnapshotDevice] = [
        .iPhone15Pro, .iPhone15ProMax, .iPhoneSE, .iPadPro12_9
    ]
}
```

### マトリックステスト

```swift
final class MultiDeviceSnapshotTests: XCTestCase {
    
    func testHomeScreen_allDevices() {
        let view = HomeScreen(viewModel: .mock)
        
        for device in SnapshotDevice.all {
            let controller = UIHostingController(rootView: view)
            controller.view.frame = CGRect(origin: .zero, size: device.size)
            
            assertSnapshot(
                of: controller,
                as: .image(traits: device.traits),
                named: device.name
            )
        }
    }
    
    func testHomeScreen_lightAndDark() {
        let view = HomeScreen(viewModel: .mock)
        let device = SnapshotDevice.iPhone15Pro
        
        for style in [UIUserInterfaceStyle.light, .dark] {
            let traits = UITraitCollection(traitsFrom: [
                device.traits,
                UITraitCollection(userInterfaceStyle: style)
            ])
            
            let controller = UIHostingController(rootView: view)
            controller.view.frame = CGRect(origin: .zero, size: device.size)
            
            assertSnapshot(
                of: controller,
                as: .image(traits: traits),
                named: style == .light ? "light" : "dark"
            )
        }
    }
}
```

## 状態別テスト

### ローディング・エラー状態

```swift
final class StateSnapshotTests: XCTestCase {
    
    func testUserList_loading() {
        let view = UserListView(state: .loading)
        assertSnapshot(of: view, as: .swiftUIImage())
    }
    
    func testUserList_loaded() {
        let view = UserListView(state: .loaded(users: User.mockList))
        assertSnapshot(of: view, as: .swiftUIImage())
    }
    
    func testUserList_empty() {
        let view = UserListView(state: .loaded(users: []))
        assertSnapshot(of: view, as: .swiftUIImage())
    }
    
    func testUserList_error() {
        let view = UserListView(state: .error(message: "Network connection failed"))
        assertSnapshot(of: view, as: .swiftUIImage())
    }
}
```

### アニメーション特定フレーム

```swift
func testProgressAnimation_midway() {
    let view = CircularProgressView(progress: 0.5)
    assertSnapshot(of: view, as: .swiftUIImage(), named: "50percent")
}

func testProgressAnimation_complete() {
    let view = CircularProgressView(progress: 1.0)
    assertSnapshot(of: view, as: .swiftUIImage(), named: "complete")
}
```

## CI/CD統合

### スナップショットの管理

```
MyAppTests/
├── __Snapshots__/
│   ├── ProfileViewSnapshotTests/
│   │   ├── testProfileView.1.png
│   │   ├── testProfileView_darkMode.1.png
│   │   └── testProfileView_largeText.1.png
│   └── HomeScreenSnapshotTests/
│       ├── testHomeScreen_iPhone15Pro.1.png
│       └── testHomeScreen_iPadPro12_9.1.png
```

### .gitattributes設定

```gitattributes
# スナップショット画像をLFSで管理
*/__Snapshots__/**/*.png filter=lfs diff=lfs merge=lfs -text
```

### GitHub Actions

```yaml
name: Snapshot Tests

on:
  pull_request:
    paths:
      - '**/*.swift'
      - '**/Assets.xcassets/**'

jobs:
  snapshot-test:
    runs-on: macos-14
    
    steps:
      - uses: actions/checkout@v4
        with:
          lfs: true
      
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app
      
      - name: Run Snapshot Tests
        run: |
          xcodebuild test \
            -workspace MyApp.xcworkspace \
            -scheme MyAppTests \
            -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
      
      - name: Upload Failed Snapshots
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: failed-snapshots
          path: |
            **/Failures/**
            **/__Snapshots__/**
```

## 差分の許容

### perceptualPrecision

```swift
// わずかなアンチエイリアスの差異を許容
assertSnapshot(
    of: view,
    as: .image(perceptualPrecision: 0.98)  // 98%一致で合格
)

// より厳密なチェック
assertSnapshot(
    of: view,
    as: .image(precision: 1.0, perceptualPrecision: 1.0)
)
```

### 動的コンテンツのマスキング

```swift
extension UIView {
    func maskDynamicContent() -> UIView {
        // 日時表示などをマスク
        subviews.filter { $0.accessibilityIdentifier == "timestamp" }
            .forEach { $0.isHidden = true }
        return self
    }
}

func testFeed_maskTimestamps() {
    let view = FeedView(posts: Post.mockList)
    let controller = UIHostingController(rootView: view)
    
    // タイムスタンプをマスクしてスナップショット
    assertSnapshot(
        of: controller.view.maskDynamicContent(),
        as: .image
    )
}
```

## 設計システム検証

### コンポーネントカタログ

```swift
final class DesignSystemSnapshotTests: XCTestCase {
    
    func testColorPalette() {
        let view = VStack(spacing: 8) {
            ForEach(ColorToken.allCases, id: \.self) { token in
                HStack {
                    Rectangle()
                        .fill(token.color)
                        .frame(width: 60, height: 40)
                    Text(token.rawValue)
                        .font(.caption)
                    Spacer()
                }
            }
        }
        .padding()
        
        assertSnapshot(of: view, as: .swiftUIImage(size: CGSize(width: 300, height: 600)))
    }
    
    func testTypography() {
        let view = VStack(alignment: .leading, spacing: 12) {
            Text("Title Large").font(.largeTitle)
            Text("Title").font(.title)
            Text("Title 2").font(.title2)
            Text("Title 3").font(.title3)
            Text("Headline").font(.headline)
            Text("Body").font(.body)
            Text("Callout").font(.callout)
            Text("Subheadline").font(.subheadline)
            Text("Footnote").font(.footnote)
            Text("Caption").font(.caption)
            Text("Caption 2").font(.caption2)
        }
        .padding()
        
        assertSnapshot(of: view, as: .swiftUIImage())
    }
    
    func testIconLibrary() {
        let icons = ["house", "gear", "person", "bell", "heart", "star"]
        
        let view = LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
            ForEach(icons, id: \.self) { icon in
                VStack {
                    Image(systemName: icon)
                        .font(.title)
                    Text(icon)
                        .font(.caption2)
                }
            }
        }
        .padding()
        
        assertSnapshot(of: view, as: .swiftUIImage(size: CGSize(width: 300, height: 200)))
    }
}
```

## ベストプラクティス

### 命名規則

```swift
// ファイル名: {ViewName}SnapshotTests.swift
// テスト名: test{ViewName}_{State}_{Device}_{Theme}

func testProfileView_editing_iPhone15Pro_dark() { }
func testProfileView_viewing_iPadPro_light() { }
```

### テストの構造化

```swift
final class ProfileViewSnapshotTests: XCTestCase {
    
    // MARK: - Default State
    
    func testDefaultState() {
        assertSnapshot(of: makeView(), as: .swiftUIImage())
    }
    
    // MARK: - User Interaction States
    
    func testEditingState() {
        assertSnapshot(of: makeView(isEditing: true), as: .swiftUIImage())
    }
    
    // MARK: - Device Variations
    
    func testOnSmallDevice() {
        assertSnapshot(of: makeView(), as: .swiftUIImage(size: SnapshotDevice.iPhoneSE.size))
    }
    
    // MARK: - Accessibility
    
    func testLargeText() {
        assertSnapshot(
            of: makeView(),
            as: .swiftUIImage(traits: .init(preferredContentSizeCategory: .accessibilityLarge))
        )
    }
    
    // MARK: - Helpers
    
    private func makeView(isEditing: Bool = false) -> some View {
        ProfileView(user: .mock, isEditing: isEditing)
    }
}
```

## チェックリスト

### 導入時
- [ ] swift-snapshot-testingをSPMで追加
- [ ] スナップショットディレクトリをGit管理に含める
- [ ] .gitattributesでLFS設定（必要に応じて）

### テスト作成時
- [ ] 重要なUI状態をカバー（ローディング、エラー、空、データあり）
- [ ] ダークモード対応を確認
- [ ] 主要デバイスサイズでテスト
- [ ] アクセシビリティ設定でテスト

### メンテナンス時
- [ ] 意図的なUI変更時は `isRecording = true` で再生成
- [ ] 差分が出た場合は変更が意図的かレビュー
- [ ] CIでの失敗時はアーティファクトを確認
