# SEP.md — セットアップ手順書

## 1. 必要なアカウント・認証情報

### Meta Marketing API
- Meta for Developersでアプリを作成
- 必要な値：
  - `META_ACCESS_TOKEN` — アクセストークン
  - `META_APP_SECRET` — アプリシークレット
  - `META_APP_ID` — アプリID
  - `META_ACCOUNT` — 広告アカウントID

### Google Cloud
- GCPプロジェクトを作成
- Google Sheets API を有効化
- サービスアカウントを作成し、JSON鍵ファイルをダウンロード
- スプレッドシートにサービスアカウントの`client_email`を編集者として共有

---

## 2. スプレッドシートのセットアップ

### スプレッドシートID
```
.envのSPREADSHEET_IDを参照
```

### 6シートの自動作成
1. スプレッドシートを開く
2. **拡張機能 > Apps Script** を開く
3. `scripts/setupSheets.gs` の内容を貼り付けて `setupAllSheets` を実行
4. 権限を承認

### シート一覧

| シート名 | 列構成 |
|---------|--------|
| 実績ログ_キャンペーン | キャンペーンID, キャンペーン名, METAステータス, 日付, impressions, clicks, spend, conversions, CTR, CPA, CVR, CPM, 備考 |
| 実績ログ_クリエイティブ | 広告ID, 広告名, キャンペーン名, 広告セット名, 日付, impressions, clicks, spend, conversions, CTR, CPA, CVR, CPM, 備考 |
| クリエイティブ・マスタ | 広告ID, 広告名, 種類, メイン訴求, サブ訴求, ターゲット属性, 見出し（30文字）, 説明文（90文字）, メインテキスト, バナー構成/動画台本, 特徴, ステータス, 作成日, デザインURL, AI識別タグ |
| 運用変更ログ | 日付, 対象キャンペーン・広告セット, 変更種別, 変更内容, 理由・仮説, 学習状態, 結果_7日後 |
| 承認・FBログ | 提案日, 提案タイトル, 判定, FB詳細（理由）, 当時の状況, 決定アクション |
| ナレッジDB | 更新日, 訴求軸・要素, 成功要因（勝ち）, 失敗要因（負け）, 次回の黄金ルール, 適用条件 |

---

## 3. ローカル環境の設定

### .env ファイル
```
# Google Sheets
SPREADSHEET_ID=（スプレッドシートID）

# Meta MCP
META_ACCOUNT=（広告アカウントID）
META_CLIENT=（アプリID）
META_SECRET=（アプリシークレット）
META_TOKEN=（アクセストークン）

# Google Cloud
GOOGLE_PROJECT_ID=（GCPプロジェクトID）
GOOGLE_APPLICATION_CREDENTIALS=./service-account.json
```

### MCP サーバー登録コマンド

```bash
# Meta MCP
claude mcp add meta-ads \
  -e META_ACCESS_TOKEN=（META_TOKENの値） \
  -e META_APP_SECRET=（META_SECRETの値） \
  -e META_APP_ID=（META_CLIENTの値） \
  -- npx -y meta-ads-mcp

# Google Sheets MCP
# GOOGLE_SERVICE_ACCOUNT_KEY にはサービスアカウントJSONを1行化した文字列を渡す
# 1行化コマンド: cat service-account.json | jq -c .
claude mcp add mcp-gsheets \
  -e GOOGLE_PROJECT_ID=（プロジェクトID） \
  -e "GOOGLE_SERVICE_ACCOUNT_KEY=（1行化したJSON文字列）" \
  -- npx -y mcp-gsheets@latest
```

### 環境変数名の対応表

| .env の変数名 | MCP が要求する変数名 | 対象MCP |
|--------------|---------------------|---------|
| META_TOKEN | META_ACCESS_TOKEN | meta-ads |
| META_SECRET | META_APP_SECRET | meta-ads |
| META_CLIENT | META_APP_ID | meta-ads |
| GOOGLE_PROJECT_ID | GOOGLE_PROJECT_ID | mcp-gsheets |
| （service-account.json） | GOOGLE_SERVICE_ACCOUNT_KEY（JSON文字列） | mcp-gsheets |

### 接続確認
```bash
claude mcp list
```
全て `✓ Connected` になればOK。

---

## 4. スケジューラー（クラウド環境）の設定

### 設定URL
```
https://claude.ai/code/scheduled/new
```

### 環境名
```
Default
```

### ネットワークアクセス
```
Trusted
```

### 環境変数
```
SPREADSHEET_ID=（スプレッドシートID）
META_ACCOUNT=（広告アカウントID）
META_CLIENT=（アプリID）
META_SECRET=（アプリシークレット）
META_TOKEN=（アクセストークン）
GOOGLE_PROJECT_ID=（GCPプロジェクトID）
GOOGLE_SERVICE_ACCOUNT_JSON=（service-account.jsonを jq -c . で1行化した文字列）
```

### セットアップスクリプト
```bash
#!/bin/bash

# Google サービスアカウントJSONを環境変数から復元
echo "$GOOGLE_SERVICE_ACCOUNT_JSON" > /tmp/service-account.json

# MCP サーバーを登録
claude mcp add meta-ads -e META_ACCESS_TOKEN=$META_TOKEN -e META_APP_SECRET=$META_SECRET -e META_APP_ID=$META_CLIENT -- npx -y meta-ads-mcp
claude mcp add mcp-gsheets -e GOOGLE_PROJECT_ID=$GOOGLE_PROJECT_ID -e "GOOGLE_SERVICE_ACCOUNT_KEY=$GOOGLE_SERVICE_ACCOUNT_JSON" -- npx -y mcp-gsheets@latest
```

### トリガー設定
```
リポジトリ: MetaMCP
頻度: 毎日 09:00 JST
プロンプト: PROMPT.md の内容を使用
```

---

## 5. ファイル構成

```
MetaMCP/
├── .env                      # 環境変数（git管理外）
├── .gitignore                # .env, service-account.json を除外
├── .mcp.json                 # MCP設定（環境変数参照）
├── CLAUDE.md                 # Claudeへの指示書（実行手順・ルール）
├── PROMPT.md                 # スケジュールトリガー用プロンプト
├── SEP.md                    # セットアップ手順書（このファイル）
├── service-account.json      # GCPサービスアカウント鍵（git管理外）
└── scripts/
    ├── setupSheets.gs        # スプレッドシート初期セットアップ用GAS
    └── setup-sheets.md       # シート列構成の定義書
```

---

## 6. トラブルシューティング

| 問題 | 原因 | 対処 |
|------|------|------|
| meta-ads が `META_ACCESS_TOKEN: Missing` | 環境変数名の不一致 | `META_ACCESS_TOKEN`（`META_TOKEN`ではない）で登録 |
| mcp-gsheets が `No authentication method provided` | 認証情報が未設定 | `GOOGLE_SERVICE_ACCOUNT_KEY` にJSON文字列を渡す（ファイルパスではない） |
| mcp-gsheets が `getaddrinfo EAI_AGAIN` | DNS解決失敗 | ネットワークアクセスが「Trusted」か確認。クラウド環境の一時的なDNS障害の場合はリトライ |
| meta-ads が `Failed to connect` | トークン期限切れ | Meta for Developersで新しいトークンを生成 |
| Sheets書き込みエラー | サービスアカウントに権限なし | スプレッドシートの共有設定で`client_email`を編集者に追加 |
| `claude mcp add` で `Invalid environment variable format` | `-e KEY`形式は不可 | `-e KEY=value` 形式で指定する |
| GitHub push rejected (secret scanning) | SEP.mdに秘密鍵が含まれている | 秘密鍵はプレースホルダーに置き換え、.envにのみ実値を記載 |
