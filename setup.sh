#!/bin/bash

echo "=== 1. .env 読み込み ==="
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
  echo ".env 読み込み完了 ($ENV_FILE)"
elif [ -f "/Users/hattori/Downloads/GitHub/MetaMCP/.env" ]; then
  set -a
  source "/Users/hattori/Downloads/GitHub/MetaMCP/.env"
  set +a
  echo ".env 読み込み完了 (フォールバックパス)"
else
  echo "エラー: .env ファイルが見つかりません"
  echo "検索パス: $ENV_FILE"
  echo "カレントディレクトリ: $(pwd)"
  exit 1
fi

echo ""
echo "=== 2. 環境変数チェック ==="
MISSING=0
for VAR in META_TOKEN META_SECRET META_CLIENT META_ACCOUNT SPREADSHEET_ID GOOGLE_PROJECT_ID GOOGLE_SERVICE_ACCOUNT_JSON SITICH_TOKEN; do
  if [ -z "${!VAR}" ]; then
    echo "$VAR: 未設定 ❌"
    MISSING=1
  else
    echo "$VAR: OK ✅"
  fi
done
if [ "$MISSING" -eq 1 ]; then
  echo "エラー: 必須環境変数が不足しています"
  exit 1
fi
echo "=== チェック完了 ==="

echo ""
echo "=== 3. .mcp.json 生成 ==="
PROJECT_DIR="${SCRIPT_DIR}"
python3 -c "
import json, os, sys

project_dir = os.environ.get('PROJECT_DIR', '$PROJECT_DIR')

config = {
    'mcpServers': {
        'meta-ads': {
            'type': 'stdio',
            'command': 'npx',
            'args': ['-y', 'meta-ads-mcp'],
            'env': {
                'META_ACCESS_TOKEN': os.environ['META_TOKEN'],
                'META_APP_SECRET': os.environ['META_SECRET'],
                'META_APP_ID': os.environ['META_CLIENT']
            }
        },
        'mcp-gsheets': {
            'type': 'stdio',
            'command': 'npx',
            'args': ['-y', 'mcp-gsheets@latest'],
            'env': {
                'GOOGLE_PROJECT_ID': os.environ['GOOGLE_PROJECT_ID'],
                'GOOGLE_SERVICE_ACCOUNT_KEY': os.environ['GOOGLE_SERVICE_ACCOUNT_JSON']
            }
        },
        'stitch': {
            'command': 'npx',
            'args': ['-y', '@_davideast/stitch-mcp', 'proxy'],
            'env': {
                'STITCH_API_KEY': os.environ['SITICH_TOKEN']
            }
        }
    }
}

output_path = os.path.join(project_dir, '.mcp.json')
with open(output_path, 'w') as f:
    json.dump(config, f, indent=2)
print(f'出力先: {output_path}')
"
echo ".mcp.json 生成完了"

echo ""
echo "=== 4. MCPパッケージ事前インストール ==="
npm install -g meta-ads-mcp || true
npm install -g mcp-gsheets@latest || true
npm install -g @_davideast/stitch-mcp || true
echo "=== MCPパッケージインストール完了 ==="

echo ""
echo "=== 5. バナー生成用依存インストール ==="
npm install --production || true
npx playwright install chromium || true
echo "=== 依存インストール完了 ==="

echo ""
echo "=== セットアップ完了 ==="
echo "Claude Code をこのディレクトリで起動してください"
