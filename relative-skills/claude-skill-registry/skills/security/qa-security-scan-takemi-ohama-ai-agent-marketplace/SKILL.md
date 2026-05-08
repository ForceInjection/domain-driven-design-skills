---
name: qa-security-scan
description: |
  Security scanning templates and checklists for OWASP Top 10, authentication, authorization, data protection. Use when conducting security testing or vulnerability assessment.

  This skill provides comprehensive security testing:
  - OWASP Top 10 checklist with remediation
  - Authentication and authorization testing
  - Data protection verification
  - Security report generation
  - Integration with Codex CLI MCP for automated scanning

  Triggers: "security scan", "vulnerability check", "OWASP", "security test", "セキュリティスキャン", "脆弱性チェック", "セキュリティテスト"
---

# QA Security Scan Skill

## 概要

このSkillは、qaエージェントがセキュリティスキャンと脆弱性評価を実施する際に使用します。OWASP Top 10に基づいた包括的なチェックリストと、認証・認可・データ保護の検証手順を提供します。

## 主な機能

1. **OWASP Top 10チェックリスト**: 最も重大な脆弱性を体系的に確認
2. **認証・認可テスト**: ログイン、セッション管理、アクセス制御の検証
3. **データ保護確認**: 暗号化、機密情報の扱いを確認
4. **セキュリティレポート生成**: 構造化された脆弱性レポート
5. **Codex CLI MCP統合**: 自動セキュリティスキャン

## 使用方法

### チェックリスト一覧

```
checklists/
├── owasp-top10-checklist.md    # OWASP Top 10
├── auth-checklist.md            # 認証・認可
└── data-protection-checklist.md # データ保護
```

### レポートテンプレート

```
templates/
└── security-report-template.md  # セキュリティレポート
```

## OWASP Top 10 チェックリスト

### 1. インジェクション

**脆弱性の説明**:
信頼できないデータがコマンドやクエリの一部として送信され、攻撃者が意図しないコマンドを実行したり、適切な認可なしにデータにアクセスしたりできる。

**チェック項目**:

- [ ] **SQLインジェクション対策**
  ```javascript
  // ❌ Bad: 文字列連結
  const query = `SELECT * FROM users WHERE id = ${userId}`;

  // ✅ Good: パラメータ化クエリ
  const query = 'SELECT * FROM users WHERE id = ?';
  db.query(query, [userId]);
  ```

- [ ] **コマンドインジェクション対策**
  ```javascript
  // ❌ Bad: ユーザー入力を直接使用
  exec(`ping ${userInput}`);

  // ✅ Good: ホワイトリスト検証 + エスケープ
  if (!/^[a-zA-Z0-9.-]+$/.test(userInput)) {
    throw new Error('Invalid input');
  }
  ```

- [ ] **LDAPインジェクション対策**
  - 特殊文字のエスケープ
  - パラメータ化クエリの使用

- [ ] **NoSQLインジェクション対策**
  ```javascript
  // ❌ Bad: オブジェクトを直接使用
  User.find({ username: req.body.username });

  // ✅ Good: 型検証
  const username = String(req.body.username);
  User.find({ username });
  ```

**修正方法**:
1. パラメータ化クエリ/プリペアドステートメント使用
2. ORMの使用（Sequelize、TypeORM等）
3. 入力値の厳格な検証（ホワイトリスト）
4. エスケープ処理

### 2. 認証の不備

**チェック項目**:

- [ ] **パスワードの安全なハッシュ化**
  ```javascript
  // ❌ Bad: 平文保存、MD5/SHA1
  const hash = md5(password);

  // ✅ Good: bcrypt/Argon2
  const bcrypt = require('bcrypt');
  const hash = await bcrypt.hash(password, 10);
  ```

- [ ] **セッション管理**
  - セッションIDの再生成（ログイン後）
  - セキュアなCookie設定（HttpOnly, Secure, SameSite）
  - セッションタイムアウトの設定

- [ ] **多要素認証（MFA）**
  - 重要な操作でMFA要求
  - TOTPまたはSMS認証

- [ ] **ブルートフォース攻撃対策**
  - レート制限（rate limiting）
  - アカウントロックアウト
  - CAPTCHA

- [ ] **パスワードポリシー**
  - 最小8文字以上
  - 大文字、小文字、数字、記号の組み合わせ
  - 過去のパスワードの再利用禁止

**修正方法**:
1. bcrypt/Argon2でパスワードをハッシュ化
2. JWTトークンまたはセキュアなセッション管理
3. express-rate-limitでレート制限
4. パスワードポリシーの強制

### 3. 機密データの露出

**チェック項目**:

- [ ] **通信の暗号化**
  - HTTPS/TLS 1.2以上の使用
  - HTTP Strict Transport Security (HSTS) ヘッダー

- [ ] **保存時の暗号化**
  ```javascript
  // ✅ Good: AES-256で暗号化
  const crypto = require('crypto');
  const algorithm = 'aes-256-cbc';
  const key = crypto.randomBytes(32);
  const iv = crypto.randomBytes(16);

  function encrypt(text) {
    const cipher = crypto.createCipheriv(algorithm, key, iv);
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return encrypted;
  }
  ```

- [ ] **機密情報のログ出力禁止**
  ```javascript
  // ❌ Bad
  console.log('User password:', password);
  logger.info('Credit card:', creditCard);

  // ✅ Good
  logger.info('User authenticated', { userId: user.id });
  ```

- [ ] **APIキー・シークレットの管理**
  - 環境変数で管理
  - .envファイルは.gitignoreに追加
  - AWS Secrets Manager / HashiCorp Vault 等の使用

**修正方法**:
1. すべての通信をHTTPS化
2. 機密データの暗号化（AES-256）
3. 環境変数で機密情報を管理
4. ログに機密情報を出力しない

### 4. XXE（XML External Entity）

**チェック項目**:

- [ ] **XML パーサーの安全な設定**
  ```javascript
  // ✅ Good: DTD処理を無効化
  const { XMLParser } = require('fast-xml-parser');
  const parser = new XMLParser({
    ignoreAttributes: false,
    processEntities: false  // DTD処理を無効化
  });
  ```

- [ ] **外部エンティティの禁止**
- [ ] **DTD処理の無効化**

**修正方法**:
1. XML パーサーでDTD処理を無効化
2. 外部エンティティの参照を禁止
3. 可能であればJSONを使用

### 5. アクセス制御の不備

**チェック項目**:

- [ ] **認可チェックの実装**
  ```javascript
  // ✅ Good: ミドルウェアで認可チェック
  function requireAdmin(req, res, next) {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  }

  app.delete('/api/users/:id', authMiddleware, requireAdmin, deleteUser);
  ```

- [ ] **ロールベースアクセス制御（RBAC）**
  - ユーザーごとにロール設定
  - リソースごとに必要なロールを定義

- [ ] **オブジェクトレベルの認可**
  ```javascript
  // ❌ Bad: IDだけで削除
  app.delete('/api/posts/:id', async (req, res) => {
    await Post.destroy({ where: { id: req.params.id } });
  });

  // ✅ Good: 所有者チェック
  app.delete('/api/posts/:id', authMiddleware, async (req, res) => {
    const post = await Post.findByPk(req.params.id);
    if (post.userId !== req.user.id) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    await post.destroy();
  });
  ```

- [ ] **IDORの防止**（Insecure Direct Object Reference）

**修正方法**:
1. すべてのAPIエンドポイントで認可チェック
2. ロールベースアクセス制御の実装
3. オブジェクトの所有者確認

### 6. セキュリティ設定ミス

**チェック項目**:

- [ ] **デフォルトパスワードの変更**
- [ ] **不要なサービスの無効化**
- [ ] **セキュリティヘッダーの設定**
  ```javascript
  // ✅ Good: helmet.js でセキュリティヘッダー設定
  const helmet = require('helmet');
  app.use(helmet());
  app.use(helmet.contentSecurityPolicy({
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"]
    }
  }));
  ```

- [ ] **エラーメッセージの適切化**
  ```javascript
  // ❌ Bad: 詳細なエラーを公開
  res.status(500).json({ error: error.stack });

  // ✅ Good: 一般的なエラーメッセージ
  res.status(500).json({ error: 'Internal server error' });
  // 詳細はログに記録
  logger.error('Error details:', error);
  ```

- [ ] **CORSの適切な設定**
  ```javascript
  // ✅ Good: 特定のオリジンのみ許可
  const cors = require('cors');
  app.use(cors({
    origin: 'https://example.com',
    credentials: true
  }));
  ```

**修正方法**:
1. helmet.js でセキュリティヘッダー設定
2. 環境別の設定（開発/本番）
3. エラーメッセージは一般的に、詳細はログに

### 7. XSS（クロスサイトスクリプティング）

**チェック項目**:

- [ ] **HTMLエスケープ**
  ```javascript
  // ❌ Bad: 直接HTMLに挿入
  document.getElementById('output').innerHTML = userInput;

  // ✅ Good: エスケープして挿入
  document.getElementById('output').textContent = userInput;

  // または DOMPurify を使用
  import DOMPurify from 'dompurify';
  const clean = DOMPurify.sanitize(userInput);
  ```

- [ ] **Content-Security-Policy (CSP) 設定**
- [ ] **HTTPOnlyクッキー**
  ```javascript
  // ✅ Good: HTTPOnly, Secure, SameSite
  res.cookie('token', token, {
    httpOnly: true,
    secure: true,
    sameSite: 'strict'
  });
  ```

- [ ] **DOMベースXSS対策**
  - `eval()`, `innerHTML`, `document.write()` を避ける

**修正方法**:
1. すべての出力をエスケープ
2. Content-Security-Policy ヘッダー設定
3. DOMPurifyなどのサニタイゼーションライブラリ使用

### 8-10. その他の脆弱性

**8. 安全でないデシリアライゼーション**
- [ ] 信頼できないデータのデシリアライズ禁止
- [ ] 署名・検証の実装

**9. 既知の脆弱性があるコンポーネント**
- [ ] 依存ライブラリの最新化
- [ ] `npm audit` / `pip-audit` の実行
- [ ] Dependabot / Renovate の利用

**10. ログとモニタリングの不足**
- [ ] セキュリティイベントのログ
- [ ] 異常検知の仕組み
- [ ] 定期的なログレビュー

## 認証・認可チェックリスト

### 認証テスト

- [ ] **ログイン機能**
  - 正しい認証情報でログイン成功
  - 誤った認証情報でログイン失敗
  - パスワード忘れ機能

- [ ] **セッション管理**
  - ログアウト後にセッション無効化
  - セッションタイムアウト
  - 同時ログインの制限

- [ ] **トークン管理（JWT）**
  - トークン有効期限
  - トークンリフレッシュ
  - 署名検証

### 認可テスト

- [ ] **ロールベースアクセス制御**
  - 管理者のみアクセス可能なリソース
  - 一般ユーザーの権限制限

- [ ] **リソース所有者チェック**
  - 自分のリソースのみ編集・削除可能

## セキュリティレポート生成

### テンプレート使用

```markdown
# セキュリティスキャンレポート - [アプリケーション名]

## エグゼクティブサマリー

- スキャン日: 2023-12-15
- スキャン範囲: Web アプリケーション全体
- 重大な脆弱性: 2件
- 警告: 5件
- 情報: 3件

## 重大な脆弱性 🔴

### 1. SQLインジェクション
- **場所**: `/api/users` エンドポイント
- **リスクレベル**: 高
- **説明**: ユーザー入力が直接SQLクエリに連結されている
- **影響**: データベース全体へのアクセス、データ改ざん
- **修正方法**: パラメータ化クエリを使用
  ```javascript
  // 修正前
  const query = `SELECT * FROM users WHERE id = ${userId}`;

  // 修正後
  const query = 'SELECT * FROM users WHERE id = ?';
  db.query(query, [userId]);
  ```
- **優先度**: 最高（即座に修正）

### 2. 認証バイパス
- **場所**: `/admin` パネル
- **リスクレベル**: 高
- **説明**: 管理者パネルに認証チェックがない
- **影響**: 不正アクセス、データ改ざん
- **修正方法**: 認証ミドルウェアを追加
- **優先度**: 最高

## 警告 🟡

### 3. XSS（クロスサイトスクリプティング）
- **場所**: ユーザープロフィールページ
- **リスクレベル**: 中
- **説明**: ユーザー入力がエスケープされずに表示
- **修正方法**: HTMLエスケープまたはDOMPurify使用

## 推奨事項

1. **即座に修正**: 重大な脆弱性2件
2. **1週間以内に修正**: 警告5件
3. **セキュリティヘッダー追加**: helmet.js 使用
4. **依存ライブラリの更新**: npm audit で検出された脆弱性
5. **定期的なセキュリティスキャン**: 月1回の実施

## 次のステップ

1. 重大な脆弱性の修正
2. 修正後の再スキャン
3. ペネトレーションテストの実施
4. セキュリティ監視の強化
```

## Codex CLI MCP統合

```javascript
// Codex でセキュリティスキャン実行
const result = await codex({
  prompt: `
    以下のコードをセキュリティスキャンしてください:
    - OWASP Top 10 の脆弱性
    - 認証・認可の問題
    - 機密情報の露出

    ${codeContent}
  `,
  'approval-policy': 'on-request'
});
```

## ベストプラクティス

### DO（推奨）

✅ **定期的なスキャン**: 月1回以上
✅ **自動化**: CI/CDパイプラインに統合
✅ **重大度の優先順位**: 高→中→低の順で対応
✅ **修正の検証**: 修正後に再スキャン
✅ **開発者教育**: セキュアコーディング研修

### DON'T（非推奨）

❌ **スキャンのみで満足**: 修正まで実施
❌ **警告を無視**: すべての指摘を確認
❌ **本番環境で初スキャン**: 開発段階から実施
❌ **自動化ツールに全依存**: 手動レビューも重要

## Progressive Disclosure

このSKILL.mdはメインドキュメント（約400行）です。詳細なチェックリストは `checklists/` ディレクトリ内のファイルを参照してください。

## 関連Skill

- **qa-code-review-checklist**: 一般的なコード品質レビュー
- **corder-code-templates**: セキュアなコードテンプレート

## 関連リソース

- **checklists/owasp-top10-checklist.md**: OWASP Top 10 詳細チェックリスト
- **checklists/auth-checklist.md**: 認証・認可チェックリスト
- **checklists/data-protection-checklist.md**: データ保護チェックリスト
- **templates/security-report-template.md**: セキュリティレポートテンプレート
