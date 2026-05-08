---
name: e2e-execution
description: Claude Code Web/DesktopでE2Eテストを実行する手順。リモートConvexに接続してPlaywrightテストを実行する方法。
---

# 重要
- 色々書いてますが現状プロキシでconvexがブロックされているので実行不可！！

<!-- # Claude Code Web(Claude Code Desktop)のE2E実行

リモートConvexに接続してE2Eテストを実行する手順です。

## 実行手順

### 1. pnpm install
```bash
pnpm install --frozen-lockfile
```

### 2. 環境変数を.envに書き込む
以下の環境変数を`.env`ファイルに追加（未設定の場合）：
```bash
# Convex
echo "CONVEX_DEPLOY_KEY=$CONVEX_DEPLOY_KEY" >> .env

# Clerk
echo "VITE_CLERK_PUBLISHABLE_KEY=$VITE_CLERK_PUBLISHABLE_KEY" >> .env
echo "CLERK_SECRET_KEY=$CLERK_SECRET_KEY" >> .env

# E2Eテスト用ユーザー
echo "E2E_CLERK_USER=$E2E_CLERK_USER" >> .env
echo "E2E_CLERK_PASSWORD=$E2E_CLERK_PASSWORD" >> .env
echo "E2E_CLERK_USER_B=$E2E_CLERK_USER_B" >> .env
echo "E2E_CLERK_PASSWORD_B=$E2E_CLERK_PASSWORD_B" >> .env
```

### 3. Convex開発サーバーの起動
```bash
npx convex dev &
```

### 4. DBのリセット（テストデータ投入）
```bash
pnpm convex:import
```

### 5. アプリケーションの起動
```bash
pnpm dev &
```

### 6. E2Eテストの実行
```bash
pnpm e2e
```

## 注意事項
- テスト実行前に`pnpm convex:import`でDBをリセットすることを推奨
- AIが制御する場合、sleepやkillは不要（起動完了を確認してから次のステップへ進む）
- 手順2は初回のみ実行（`.env`に既に設定されていればスキップ可能） -->
