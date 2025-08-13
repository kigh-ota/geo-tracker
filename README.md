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
  - Python + FastAPI
- 3. ダミー位置情報送信クライアント作成: mock-client/
  - モック API と結合テスト
- 4. 実機 iOS アプリで位置情報を定期取得・送信: ios/
  - ngrok でモック API をインターネット公開して結合
- 5. DB(PostgreSQL)対応 API サーバー作成: api/
  - iOS アプリと結合テスト

## 分析

TBD。候補

- 行動パターンの自動可視化
- 生活習慣アラート
- 訪問記録の保存と検索
- 移動効率の向上
