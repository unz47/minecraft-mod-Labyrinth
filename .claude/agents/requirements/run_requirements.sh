#!/bin/bash

# 要件定義AI実行スクリプト
# Usage: ./run_requirements.sh "ユーザー要求"

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
COMMUNICATION_DIR="$SCRIPT_DIR/../communication"
INSTRUCTIONS_FILE="$SCRIPT_DIR/instructions/requirements_analyst.md"

# 入力の確認
if [ $# -eq 0 ]; then
    echo "エラー: ユーザー要求を引数として指定してください"
    echo "使用方法: $0 \"新しいブロックを追加したい\""
    exit 1
fi

USER_REQUEST="$1"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TASK_ID="task_$TIMESTAMP"

echo "=== 要件定義AI開始 ==="
echo "タスクID: $TASK_ID"
echo "ユーザー要求: $USER_REQUEST"
echo

# 通信ファイルの準備
mkdir -p "$COMMUNICATION_DIR"
echo "$USER_REQUEST" > "$COMMUNICATION_DIR/user_input.txt"
echo "$TASK_ID" > "$COMMUNICATION_DIR/current_task_id.txt"

# Claude Codeを呼び出し
echo "要件定義を実行中..."

# インストラクションファイルの内容を読み込み
INSTRUCTIONS_CONTENT=$(cat "$INSTRUCTIONS_FILE")

FULL_PROMPT="$INSTRUCTIONS_CONTENT

あなたは要件定義AIです。以下のユーザー要求を分析し、MOD開発用の技術仕様に変換してください。

ユーザー要求: $USER_REQUEST

プロジェクト情報:
- Mod ID: oltorespawn  
- Minecraft Version: 1.20.6
- Forge Version: 50.2.1
- 既存ブロック: Orichalcum Ore
- 既存アイテム: Basic Ingot, Fire Resistant Ingot, Durable Ingot

指定されたJSON形式で要件定義を出力してください。出力は純粋なJSONのみとし、JSONをコードブロックで囲むか、説明文を付けずに出力してください。"

# Claudeを実行（バックグラウンドでタイムアウト監視）
(
    echo "$FULL_PROMPT" | claude --print > "$COMMUNICATION_DIR/requirements_log.txt" 2>&1
) &
CLAUDE_PID=$!

# 最大3分間待機
TIMEOUT=180
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
    if ! kill -0 $CLAUDE_PID 2>/dev/null; then
        # プロセスが終了した
        wait $CLAUDE_PID
        break
    fi
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done

# タイムアウトした場合はプロセスを終了
if [ $ELAPSED -ge $TIMEOUT ]; then
    kill $CLAUDE_PID 2>/dev/null
    echo "Claude実行がタイムアウトしました（3分）" >> "$COMMUNICATION_DIR/requirements_log.txt"
fi

# Claude出力からJSONを抽出してファイルに保存
if [ -s "$COMMUNICATION_DIR/requirements_log.txt" ]; then
    # JSONブロックを探して抽出
    if grep -q '```json' "$COMMUNICATION_DIR/requirements_log.txt"; then
        # ```json ブロックからJSONを抽出
        sed -n '/```json/,/```/p' "$COMMUNICATION_DIR/requirements_log.txt" | sed '1d;$d' > "$COMMUNICATION_DIR/requirements_output.json"
    else
        # JSONブロックがない場合、JSON形式部分を直接抽出を試行
        grep -E '^\s*{' "$COMMUNICATION_DIR/requirements_log.txt" -A 100 | head -n 1000 > "$COMMUNICATION_DIR/requirements_output.json" || true
    fi
    
    # JSONファイルが空でないかチェック
    if [ ! -s "$COMMUNICATION_DIR/requirements_output.json" ]; then
        # 最後の手段：全体をJSONファイルとして保存を試行
        cp "$COMMUNICATION_DIR/requirements_log.txt" "$COMMUNICATION_DIR/requirements_output.json"
    fi
fi

# 結果の確認
if [ -f "$COMMUNICATION_DIR/requirements_output.json" ]; then
    echo "=== 要件定義完了 ==="
    echo "出力ファイル: $COMMUNICATION_DIR/requirements_output.json"
    echo
    echo "=== 要件定義結果 ==="
    cat "$COMMUNICATION_DIR/requirements_output.json"
    echo
    
    # 次のステップ（コーディングAI）の準備
    echo "次: コーディングAI を実行してください"
    echo "コマンド: .claude/agents/coding/run_coding.sh"
else
    echo "エラー: 要件定義の出力ファイルが見つかりません"
    echo "ログ:"
    cat "$COMMUNICATION_DIR/requirements_log.txt"
    exit 1
fi