---
name: bun-test
description: Bunを用いたテストを作成・編集します。テストを作成する際、ファイル「*.test.ts」を編集する際に呼び出します。
---

# Rules

- データベース操作などの副作用があるファイルのテストは作成しない
- `bun:test`から`test`と`expect`のみを使用する
- テストタイトルは日本語を使用する
- ファイル名形式は`*.test.ts`
- 同じディレクトリにテストファイルを配置する
- 1つのテストには1つのアサーションのみ
- 意味のある変数名を使用（省略しない）

# Sample code

```typescript
import { test, expect } from "bun:test"
import { calculateSum } from "./calculate-sum"

test("2つの正の数値を足し算できる", () => {
  const result = calculateSum({ first: 2, second: 3 })
  expect(result).toBe(5)
})

test("負の数値を含む計算ができる", () => {
  const result = calculateSum({ first: -5, second: 10 })
  expect(result).toBe(5)
})

test("ゼロを含む計算ができる", () => {
  const result = calculateSum({ first: 0, second: 0 })
  expect(result).toBe(0)
})
```
