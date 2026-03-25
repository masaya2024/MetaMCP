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

if [ -z "$META_TOKEN" ] || [ -z "$SPREADSHEET_ID" ] || [ -z "$GOOGLE_PROJECT_ID" ]; then
  echo "WARNING: 一部の環境変数が未設定ですが、続行します"
fi
echo "=== チェック完了 ==="

echo ""
echo "=== 2. Node.js依存インストール ==="
npm install --production || true
npx playwright install chromium || true
echo "=== インストール完了 ==="

echo ""
echo "=== 3. MCPサーバー登録 ==="
claude mcp add meta-ads \
  -e META_ACCESS_TOKEN="$META_TOKEN" \
  -e META_APP_SECRET="$META_SECRET" \
  -e META_APP_ID="$META_CLIENT" \
  -- npx -y meta-ads-mcp || true

claude mcp add mcp-gsheets \
  -e GOOGLE_PROJECT_ID="$GOOGLE_PROJECT_ID" \
  -e GOOGLE_SERVICE_ACCOUNT_KEY="$GOOGLE_SERVICE_ACCOUNT_JSON" \
  -- npx -y mcp-gsheets@latest || true

claude mcp add stitch \
  -e STITCH_API_KEY="$SITICH_TOKEN" \
  -- npx -y @_davideast/stitch-mcp proxy || true

echo "=== MCPサーバー登録完了 ==="
echo "=== セットアップ完了 ==="
