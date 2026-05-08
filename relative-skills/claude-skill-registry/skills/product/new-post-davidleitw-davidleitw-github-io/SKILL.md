---
name: new-post
description: Create a new blog post. Use when user says "new post", "新文章", "新增文章", or wants to start writing a new article.
allowed-tools: Bash(date:*), Write, Read, AskUserQuestion
---

# Create New Blog Post

## Process

1. 詢問用戶文章主題或內容方向
2. 根據用戶輸入生成暫定標題和檔名
3. 詢問用戶想要的 tags（可選）
4. 在 `/home/davidleitw/Desktop/davidleitw.github.io/blog/content/post/` 建立新的 markdown 檔案

## Template

```yaml
---
title: "{暫定標題}"
date: {當前時間，格式: 2022-01-01T00:00:00+08:00}
author: davidlei
draft: true
tags:
    - {tag1}
    - {tag2}
categories: ["{category}"]
description: ""
---

## 前言

{在這裡開始寫作}
```

## Notes

- `draft: true` 表示這是草稿，不會被 deploy
- `description` 留空，deploy 時會提醒補上
- 檔名建議使用英文小寫加底線，例如 `linux_fork_01.md`
- 當用戶準備發布時，將 `draft` 改為 `false`

## After creation

告訴用戶：
- 檔案已建立的路徑
- 可以開始編輯內容
- 完成後記得將 `draft: false` 並補上 `description`
- 使用 `/deploy` 發布
