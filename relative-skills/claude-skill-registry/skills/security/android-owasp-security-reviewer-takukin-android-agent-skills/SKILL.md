---
name: android-owasp-security-reviewer
description: |
  AndroidアプリのセキュリティレビューをOWASP Mobile Top 10 2024およびMASVS (Mobile Application Security Verification Standard) の観点で実施し、Markdownレポートを生成する。
  Use when: (1) Androidアプリのセキュリティ監査/レビュー依頼時 (2) 「セキュリティチェック」「脆弱性診断」「OWASP」「MASVS」キーワード時 (3) Androidプロジェクトのコードレビューでセキュリティ観点が必要な時 (4) 金融・医療アプリのセキュリティ評価時
---

# Android OWASP Security Reviewer

AndroidアプリをOWASP Mobile Top 10 2024 + MASVS基準でセキュリティレビューし、Markdownレポートを出力。

## Security Standards

### OWASP Mobile Top 10 2024
脆弱性カテゴリ（M1-M10）による分類。詳細: `references/owasp-mobile-top10-2024.md`

### OWASP MASVS (Mobile Application Security Verification Standard)
検証レベルによる分類:

| Level | 対象 | 概要 |
|-------|------|------|
| **L1** | 全商用アプリ | 基本セキュリティ（HTTPS、暗号化、入力検証） |
| **L2** | 金融・医療アプリ | 高度保護（ルート検知、MFA、HSM鍵管理） |
| **R** | ゲーム・DRM | リバース耐性（難読化、改ざん検知） |

詳細: `references/masvs-checklist.md`

## Workflow

### 1. プロジェクト把握 & レベル決定

```
Glob: **/AndroidManifest.xml, **/build.gradle*, **/*.java, **/*.kt
```

- Androidプロジェクトルート特定
- アプリ種別からMASVSレベル判定:
  - 一般アプリ → L1
  - 金融・医療 → L2
  - ゲーム・DRM → L1 + R

### 2. スキャン実行

#### Phase 1: L1 Critical（全アプリ必須）

```bash
# ハードコード認証情報
Grep: (api[_-]?key|secret|password|token)\s*=\s*["'][^"']+["']

# 平文通信
Grep: http://(?!localhost|127\.0\.0\.1|10\.)

# 証明書検証無効化
Grep: TrustAllCerts|checkServerTrusted.*\{\s*\}|ALLOW_ALL_HOSTNAME

# デバッグモード
Grep: android:debuggable="true"

# 危険なデータ保存
Grep: MODE_WORLD_READABLE|MODE_WORLD_WRITEABLE
```

#### Phase 2: L1 High

```bash
# 弱い暗号
Grep: DES|RC4|MD5|SHA-1(?!.*(256|384|512))

# ログ漏洩
Grep: Log\.(d|v|i|w|e).*(?i)(password|token|key|secret)

# 外部ストレージ
Grep: getExternalStorage|WRITE_EXTERNAL_STORAGE

# WebView脆弱性
Grep: addJavascriptInterface|setAllowFileAccessFromFileURLs
```

#### Phase 3: L2 Checks（金融・医療アプリ）

```bash
# ルート/改ざん検知確認
Grep: SafetyNet|PlayIntegrity|RootBeer

# 高度な鍵管理
Grep: setIsStrongBoxBacked|setUserAuthenticationRequired

# 生体認証
Grep: BiometricPrompt|setDeviceCredentialAllowed
```

#### Phase 4: R Checks（リバース耐性要求時）

```bash
# 難読化設定
Grep: minifyEnabled\s+(true|false)

# デバッガ検知
Grep: Debug\.isDebuggerConnected|android\.os\.Debug

# 署名検証
Grep: GET_SIGNATURES|PackageInfo
```

詳細パターン: `references/android-security-checks.md`

### 3. 検出結果分類

| 項目 | 内容 |
|------|------|
| Severity | Critical / High / Medium / Low / Info |
| OWASP Category | M1-M10 |
| MASVS | L1 / L2 / R |
| Location | ファイルパス:行番号 |
| Evidence | コードスニペット |
| Recommendation | 修正方法 |

### 4. レポート生成

テンプレート: `assets/report-template.md`
出力: `security-review-report.md`

## Quick Reference: Severity by Check

| Check | L1 Severity | L2 Severity | R Severity |
|-------|-------------|-------------|------------|
| HTTP通信 | Critical | Critical | Critical |
| ハードコード鍵 | Critical | Critical | Critical |
| 証明書検証無効 | Critical | Critical | Critical |
| debuggable=true | Critical | Critical | Critical |
| 弱い暗号 | High | Critical | High |
| ログ漏洩 | High | Critical | High |
| 外部ストレージ | High | Critical | High |
| ルート検知なし | Info | High | Critical |
| 難読化なし | Low | Medium | Critical |
| 改ざん検知なし | Info | High | Critical |

## Output Structure

```markdown
# Security Review Report
## Executive Summary
## Compliance Status (L1/L2/R)
## Findings by Severity
## Findings by OWASP Category
## MASVS Compliance Checklist
## Detailed Findings
## Recommendations
## Appendix
```

## Notes

- ソースコードのみ対象（APK解析は対象外）
- 誤検出可能性あり、手動確認推奨
- 依存関係脆弱性は `dependency-check` 等の併用推奨
- L2/R要件はアプリ種別に応じて適用
