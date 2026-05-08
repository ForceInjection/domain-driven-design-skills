---
name: gyazo-latest-image
description: Gyazo APIを使用して最新の画像を取得して表示するスキル
license: Complete terms in LICENSE.txt
---

# Gyazo Latest Image Skill

## 概要
このスキルは、Gyazo APIを使用してユーザーの最新画像を取得して表示します。Node.jsの標準fetch APIを使用して実装されています。

## 機能
- Gyazo APIで画像一覧を取得
- 最新の画像URLを取得
- 画像情報を表示

## 使用方法

### 前提条件
- Node.js v22以上
- Gyazo APIアクセストークン

### Gyazo APIアクセストークンの取得
1. Gyazoにログイン
2. https://gyazo.com/oauth/applications にアクセス
3. 新しいアプリケーションを登録してアクセストークンを取得

### 環境変数の設定
実行前に以下の環境変数を設定してください:

```bash
export GYAZO_ACCESS_TOKEN="your_access_token_here"
```

### スクリプトの実行
```bash
cd /Users/n0bisuke/ds/2_playground/my-first-skill/gyazo-latest-image
node scripts/fetch_latest.js
```

## API仕様

### Gyazo API エンドポイント
- 画像一覧取得: `GET https://api.gyazo.com/api/images`
- 必要なヘッダー: `Authorization: Bearer {access_token}`

### レスポンス例
```json
[
  {
    "image_id": "abc123",
    "permalink_url": "https://gyazo.com/abc123",
    "url": "https://i.gyazo.com/abc123.png",
    "created_at": "2025-10-21T02:24:35+0000"
  }
]
```

## いつ使用するか
- ユーザーがGyazoの最新画像を確認したい時
- Gyazo APIを使った画像取得の例が必要な時
- スクリーンショット管理ツールとしてGyazoを活用している場合

## 注意事項
- APIアクセストークンは環境変数で管理し、コードに直接記述しないこと
- API利用制限に注意すること
- アクセストークンは第三者と共有しないこと

## トラブルシューティング

### エラー: "GYAZO_ACCESS_TOKEN is not set"
環境変数が設定されていません。上記の手順に従って設定してください。

### エラー: 401 Unauthorized
アクセストークンが無効または期限切れです。新しいトークンを取得してください。

### エラー: "No images found"
Gyazoアカウントに画像がアップロードされていません。