# Geo Tracker

- iOS 端末から位置情報を定期的に送信し記録・分析するシステム
- 自分個人用

## ディレクトリ構成

- apps/
  - mock-api/
  - api/
  - mock-client/
  - ios/
- shared/
  - openapi.yml

## 開発手順

- 1. API 契約の定義: openapi.yml
  - 最低限：Ingestion API（データの取り込み）
- 2. モック API サーバー作成: mock-api/
  - DB なし、受信データをログ出力
  - TypeScript + Node.js
  - スキーマ駆動開発：openapi-typescript で型情報を最初に生成し、それを活用して開発を行う
- 3. 実機 iOS アプリで位置情報を定期取得・送信: ios/
  - Product Name: GeoTrackerClient
  - スキーマ駆動開発：swift-openapi-generator を使って OpenAPI 定義から自動生成したファイルを活用し、アプリ開発を行う
  - ngrok でモック API をインターネット公開して結合テスト
- 4. DB(PostgreSQL)対応 API サーバー作成: api/
  - スキーマ駆動開発：openapi-typescript で型情報を最初に生成し、それを活用して開発を行う
  - Supabase Edge Functions へのデプロイを想定した実装

## iOS アプリ (/apps/ios)

### 機能

- 位置情報の取得・送信
- 権限管理（バックグラウンド位置取得対応）
- UI
  - トラッキングの開始/終了
  - 情報送信履歴ログ

## 分析

TBD。候補

- 行動パターンの自動可視化
- 生活習慣アラート
- 訪問記録の保存と検索
- 移動効率の向上

## 開発コマンド

### mock-api

```bash
cd apps/mock-api
pnpm generate:types  # OpenAPI定義から型を生成
pnpm dev            # 開発サーバー起動 (localhost:8000)
pnpm test           # テスト実行
```

### iOS (GeoTrackerClient)

```bash
cd apps/ios/GeoTrackerClient

# OpenAPIからSwiftコードを生成
swift run swift-openapi-generator generate \
  Sources/GeoTrackerClient/openapi.yml \
  --mode types --mode client \
  --access-modifier public \
  --output-directory Sources/GeoTrackerClient

# ビルド
swift build

# Xcodeで開く
open GeoTrackerClient.xcodeproj
```
