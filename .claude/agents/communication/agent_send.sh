#!/bin/bash

# エージェント間通信スクリプト
# Usage: ./agent_send.sh <from_agent> <to_agent> <message_file>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FROM_AGENT="$1"
TO_AGENT="$2"
MESSAGE_FILE="$3"

if [ $# -ne 3 ]; then
    echo "使用方法: $0 <from_agent> <to_agent> <message_file>"
    echo "例: $0 requirements coding requirements_output.json"
    exit 1
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
COMMUNICATION_LOG="$SCRIPT_DIR/communication.log"

# 通信ログに記録
echo "[$TIMESTAMP] $FROM_AGENT -> $TO_AGENT: $MESSAGE_FILE" >> "$COMMUNICATION_LOG"

# メッセージファイルが存在することを確認
if [ ! -f "$SCRIPT_DIR/$MESSAGE_FILE" ]; then
    echo "エラー: メッセージファイルが見つかりません: $SCRIPT_DIR/$MESSAGE_FILE"
    exit 1
fi

echo "通信完了: $FROM_AGENT から $TO_AGENT へ $MESSAGE_FILE を送信"