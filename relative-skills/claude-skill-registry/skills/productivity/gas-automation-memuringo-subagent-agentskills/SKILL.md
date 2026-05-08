---
name: gas-automation
description: Google Apps Script開発スキル。GAS作成、スプレッドシート自動化、Google API連携時に使用。
---

# Google Apps Script開発スキル

## 基本方針
- JSDoc形式のコメント必須
- try-catchでエラーハンドリング
- ログ出力: console.log / Logger.log
- トリガー設定を考慮した設計

## 標準テンプレート

```javascript
/**
 * メイン処理
 * @description 処理の説明
 */
function main() {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = ss.getSheetByName('シート名');

    // 処理

    console.log('処理完了');
  } catch (e) {
    console.error('エラー: ' + e.message);
    throw e;
  }
}
```

## よく使うパターン

### スプレッドシート操作
```javascript
// 最終行取得
const lastRow = sheet.getLastRow();

// 範囲取得
const range = sheet.getRange(row, col, numRows, numCols);

// 値の一括取得/設定
const values = range.getValues();
range.setValues(values);
```

### 外部API連携
```javascript
/**
 * 外部APIを呼び出す
 * @param {string} url - APIエンドポイント
 * @returns {Object} レスポンスデータ
 */
function fetchApi(url) {
  const options = {
    method: 'get',
    headers: {
      'Content-Type': 'application/json'
    },
    muteHttpExceptions: true
  };

  const response = UrlFetchApp.fetch(url, options);
  return JSON.parse(response.getContentText());
}
```

## 実行時間制限対策
- 6分制限を意識した分割処理
- PropertiesServiceで状態保存
- トリガーでの継続実行

```javascript
/**
 * 処理状態を保存
 * @param {number} lastIndex - 最後に処理したインデックス
 */
function saveProgress(lastIndex) {
  const props = PropertiesService.getScriptProperties();
  props.setProperty('lastIndex', lastIndex.toString());
}

/**
 * 処理状態を取得
 * @returns {number} 最後に処理したインデックス
 */
function getProgress() {
  const props = PropertiesService.getScriptProperties();
  const lastIndex = props.getProperty('lastIndex');
  return lastIndex ? parseInt(lastIndex, 10) : 0;
}
```

## トリガー設定
```javascript
/**
 * 時間ベースのトリガーを設定
 */
function createTimeTrigger() {
  ScriptApp.newTrigger('main')
    .timeBased()
    .everyHours(1)
    .create();
}
```

## Examples

- 「スプレッドシートのデータを自動処理したい」→ getValues/setValuesパターンを提供
- 「毎日決まった時間に実行したい」→ トリガー設定のテンプレートを提供
- 「外部APIからデータを取得したい」→ UrlFetchAppパターンを提供
- 「処理が6分で止まる」→ 分割処理＋PropertiesService保存パターンを提供

## Guidelines

- すべての関数にJSDoc形式のコメントを付ける
- try-catchで例外処理を必ず実装
- 6分の実行時間制限を意識した設計にする
- 状態保存にはPropertiesServiceを使用
- ログ出力はconsole.logまたはLogger.logを使用
- スプレッドシート操作はgetValues/setValuesで一括処理（セル単位アクセスは遅い）
- API呼び出しにはmuteHttpExceptions: trueを設定してエラーハンドリング
