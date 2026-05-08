---
name: fastapi-ddd-guidelines
description: DDDアーキテクチャでFastAPIのバックエンドを新規実装または既存コードベースをリファクタリングする際のガイド。レイヤー構成（domain/application/infrastructure/controller）、依存方向、責務境界、pydantic/sqlalchemy(sqlmodel)/alembic/pytestの前提、セッション管理（Dependsで1リクエスト1セッション、必要時UoW）を含む。
---

# FastAPI DDD Guidelines

## 目的
- FastAPIでDDD構成のバックエンドを設計/実装/リファクタリングする手順と判断基準を提供する
- レイヤー責務と依存方向を明確化する
- セッション管理とトランザクション境界を標準化する

## 使い方
1) 依頼内容が「新規実装」か「リファクタリング」かを明確化する
2) 必要に応じて `references/` を読む（下記参照）
3) レイヤー構成・依存方向・責務の合意を作成する
4) 具体的なディレクトリ構成・実装方針・コード例を示す

## 参照ファイル
- レイヤー責務と依存方向のルール: `references/layers.md`
- セッション管理/UoW/トランザクション: `references/session-uow.md`
- 実装テンプレ/ディレクトリ構成例: `references/templates.md`

## 実行ガイド
- まず `references/layers.md` を読み、責務/依存方向/配置ルールを回答の土台にする
- セッションやトランザクション境界を求められる場合は `references/session-uow.md` を読む
- 新規実装やリファクタリングで具体的な構成が必要なら `references/templates.md` を読む
- 出力は日本語、簡潔かつ具体的に
