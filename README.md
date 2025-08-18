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

### 環境設定

iOSアプリは以下の環境変数で設定を変更できます:

| 環境変数名 | 説明 | デフォルト値 |
|------------|------|------------|
| `API_SERVER_URL` | APIサーバーのURL（完全なURL） | `http://localhost:8000/v1` |
| `API_AUTHORIZATION_TOKEN` | Authorization HTTPヘッダーに含めるBearerトークン | なし |

#### 設定方法

**開発時（Xcodeから実行）:**
- Xcodeのスキーマで環境変数を設定

**実機単体起動時（Xcodeから切断後）:**
1. 初回セットアップ時に以下の設定ファイルを作成：
   ```bash
   # 開発用設定
   cp apps/ios/GeoTrackerClient/Config/Development.xcconfig.template \
      apps/ios/GeoTrackerClient/Config/Development.xcconfig
   
   # 本番用設定  
   cp apps/ios/GeoTrackerClient/Config/Production.xcconfig.template \
      apps/ios/GeoTrackerClient/Config/Production.xcconfig
   ```

2. 作成した`.xcconfig`ファイルの値を実際のAPIサーバー情報に変更

3. Xcodeで以下の設定：
   - プロジェクト設定 > Info タブ > Custom iOS Target Properties に項目追加：
     - `API_SERVER_URL`: `$(API_SERVER_URL)`
     - `API_AUTHORIZATION_TOKEN`: `$(API_AUTHORIZATION_TOKEN)`
   - プロジェクト設定 > Build Settings タブ > Configurations で作成した`.xcconfig`ファイルを指定

**注意：** `.xcconfig`ファイルは機密情報を含むためGitから除外されています。各開発者・環境で個別に設定してください。

#### 設定例

```bash
# APIサーバーのURLを変更
export API_SERVER_URL="https://api.example.com/v1"

# Authorizationヘッダーを追加
export API_AUTHORIZATION_TOKEN="your-bearer-token-here"
```

Xcodeでの設定:
1. Product > Scheme > Edit Scheme...
2. Run > Arguments > Environment Variables
3. 環境変数を追加

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
