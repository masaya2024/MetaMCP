#!/bin/bash

echo "=== 1. 環境変数チェック ==="
echo "META_TOKEN: ${META_TOKEN:+OK}"
echo "META_SECRET: ${META_SECRET:+OK}"
echo "META_CLIENT: ${META_CLIENT:+OK}"
echo "META_ACCOUNT: ${META_ACCOUNT:+OK}"
echo "SPREADSHEET_ID: ${SPREADSHEET_ID:+OK}"
echo "GOOGLE_PROJECT_ID: ${GOOGLE_PROJECT_ID:+OK}"
echo "GOOGLE_SERVICE_ACCOUNT_JSON: ${GOOGLE_SERVICE_ACCOUNT_JSON:+OK}"
echo "SITICH_TOKEN: ${SITICH_TOKEN:+OK}"
echo "=== チェック完了 ==="

echo ""
echo "=== 2. MCPパッケージ事前インストール ==="
npm install -g meta-ads-mcp || true
npm install -g mcp-gsheets@latest || true
npm install -g @_davideast/stitch-mcp || true
echo "=== MCPパッケージインストール完了 ==="

echo ""
echo "=== 3. バナー生成用依存インストール ==="
npm install --production || true
npx playwright install chromium || true
echo "=== 依存インストール完了 ==="

echo ""
echo "=== 4. MCPサーバー登録 ==="
claude mcp add meta-ads \
  -e META_ACCESS_TOKEN="$META_TOKEN" \
  -e META_APP_SECRET="$META_SECRET" \
  -e META_APP_ID="$META_CLIENT" \
  -- npx -y meta-ads-mcp 2>&1 || true
echo "meta-ads 登録完了"

claude mcp add mcp-gsheets \
  -e GOOGLE_PROJECT_ID="$GOOGLE_PROJECT_ID" \
  -e GOOGLE_SERVICE_ACCOUNT_KEY="$GOOGLE_SERVICE_ACCOUNT_JSON" \
  -- npx -y mcp-gsheets@latest 2>&1 || true
echo "mcp-gsheets 登録完了"

claude mcp add stitch \
  -e STITCH_API_KEY="$SITICH_TOKEN" \
  -- npx -y @_davideast/stitch-mcp proxy 2>&1 || true
echo "stitch 登録完了"

echo ""
echo "=== 5. MCP登録確認 ==="
claude mcp list 2>&1 || true

echo ""
echo "=== セットアップ完了 ==="
