#!/bin/bash

echo "=== 1. 環境変数チェック ==="
MISSING=0
for var in META_TOKEN META_SECRET META_CLIENT META_ACCOUNT SPREADSHEET_ID GOOGLE_PROJECT_ID GOOGLE_SERVICE_ACCOUNT_JSON SITICH_TOKEN; do
  if [ -z "${!var}" ]; then
    echo "[FAIL] $var is NOT set"
    MISSING=1
  else
    echo "[OK] $var is set"
  fi
done

if [ "$MISSING" -eq 1 ]; then
  echo "ERROR: 必要な環境変数が不足しています"
  exit 1
fi
echo "=== 全環境変数OK ==="

echo ""
echo "=== 2. Node.js依存インストール ==="
npm install --production
npx playwright install chromium
echo "=== インストール完了 ==="
