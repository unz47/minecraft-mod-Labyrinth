#!/bin/bash

# MODコーディングAI実行スクリプト
# Usage: ./run_coding.sh [retry_flag]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
COMMUNICATION_DIR="$SCRIPT_DIR/../communication"
INSTRUCTIONS_FILE="$SCRIPT_DIR/instructions/mod_coder.md"

echo "=== MODコーディングAI開始 ==="

# 要件定義結果の確認
if [ ! -f "$COMMUNICATION_DIR/requirements_output.json" ]; then
    echo "エラー: 要件定義結果が見つかりません"
    echo "先に要件定義AIを実行してください: .claude/agents/requirements/run_requirements.sh"
    exit 1
fi

# レビューからの修正指示があるかチェック
REVIEW_FEEDBACK=""
if [ -f "$COMMUNICATION_DIR/review_feedback.txt" ]; then
    REVIEW_FEEDBACK=$(cat "$COMMUNICATION_DIR/review_feedback.txt")
    echo "レビューフィードバックを検出しました"
    echo "フィードバック: $REVIEW_FEEDBACK"
    echo
fi

# タスクIDの取得
TASK_ID=$(cat "$COMMUNICATION_DIR/current_task_id.txt" 2>/dev/null || echo "unknown")
echo "タスクID: $TASK_ID"

# 要件定義結果の表示
echo "=== 実装対象の要件 ==="
cat "$COMMUNICATION_DIR/requirements_output.json"
echo

# 実装開始
echo "コード実装を開始中..."

# Claude Codeを呼び出し
# インストラクションファイルの内容を読み込み
INSTRUCTIONS_CONTENT=$(cat "$INSTRUCTIONS_FILE")

PROMPT="
$INSTRUCTIONS_CONTENT

あなたはMODコーディングAIです。以下の要件定義に基づいてMinecraft MODの実装を行ってください。

=== 要件定義 ===
$(cat "$COMMUNICATION_DIR/requirements_output.json")

=== レビューフィードバック ===
$REVIEW_FEEDBACK

=== 指示 ===
1. 要件定義の内容を完全に実装してください
2. 既存のコードパターンに従ってください  
3. 実装を行い、完了時に以下の形式でJSONを出力してください。出力は純粋なJSONのみとし、JSONをコードブロックで囲むか、説明文を付けずに出力してください:

{
  \"implementation_status\": \"SUCCESS\",
  \"created_files\": [\"ファイルパス1\", \"ファイルパス2\"],
  \"modified_files\": [\"ファイルパス1\", \"ファイルパス2\"],
  \"completion_message\": \"実装完了の詳細説明\"
}

4. コンパイルエラーが発生しないことを確認してください
5. 全ての必要なリソースファイルを作成してください

プロジェクト情報:
- 作業ディレクトリ: $PROJECT_ROOT
- Mod ID: oltorespawn
- Minecraft Version: 1.20.6
- Forge Version: 50.2.1
"

# Claudeを実行（バックグラウンドでタイムアウト監視）
(
    echo "$PROMPT" | claude --print > "$COMMUNICATION_DIR/coding_log.txt" 2>&1
) &
CLAUDE_PID=$!

# 最大5分間待機
TIMEOUT=300
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

# タイムアウトした場合はプロセスを終了してフォールバック実行
if [ $ELAPSED -ge $TIMEOUT ]; then
    kill $CLAUDE_PID 2>/dev/null
    echo "Claude実行がタイムアウトしました（5分）" >> "$COMMUNICATION_DIR/coding_log.txt"
    echo "フォールバック実装を開始します..." >> "$COMMUNICATION_DIR/coding_log.txt"
    
    # フォールバック実装を実行
    "$SCRIPT_DIR/fallback_implementation.sh" >> "$COMMUNICATION_DIR/coding_log.txt" 2>&1
    if [ $? -eq 0 ]; then
        echo "フォールバック実装が成功しました" >> "$COMMUNICATION_DIR/coding_log.txt"
    else
        echo "フォールバック実装でエラーが発生しました" >> "$COMMUNICATION_DIR/coding_log.txt"
    fi
fi

# Claude出力からJSONを抽出してファイルに保存
if [ -s "$COMMUNICATION_DIR/coding_log.txt" ]; then
    # JSONブロックを探して抽出
    if grep -q '```json' "$COMMUNICATION_DIR/coding_log.txt"; then
        # ```json ブロックからJSONを抽出
        sed -n '/```json/,/```/p' "$COMMUNICATION_DIR/coding_log.txt" | sed '1d;$d' > "$COMMUNICATION_DIR/coding_output.json"
    else
        # JSONブロックがない場合、JSON形式部分を直接抽出を試行
        grep -E '^\s*{' "$COMMUNICATION_DIR/coding_log.txt" -A 100 | head -n 1000 > "$COMMUNICATION_DIR/coding_output.json" || true
    fi
    
    # JSONファイルが空でないかチェック
    if [ ! -s "$COMMUNICATION_DIR/coding_output.json" ]; then
        # 最後の手段：全体をJSONファイルとして保存を試行
        cp "$COMMUNICATION_DIR/coding_log.txt" "$COMMUNICATION_DIR/coding_output.json"
    fi
fi

# 結果の確認
if [ -f "$COMMUNICATION_DIR/coding_output.json" ]; then
    echo "=== 実装完了 ==="
    echo "出力ファイル: $COMMUNICATION_DIR/coding_output.json"
    echo
    echo "=== 実装結果 ==="
    cat "$COMMUNICATION_DIR/coding_output.json"
    echo
    
    # レビューフィードバックファイルをクリア（新しい実装が完了したため）
    rm -f "$COMMUNICATION_DIR/review_feedback.txt"
    
    # 次のステップ（レビューAI）の準備
    echo "次: レビューAI を実行してください"
    echo "コマンド: .claude/agents/review/run_review.sh"
else
    echo "エラー: 実装の出力ファイルが見つかりません"
    echo "ログ:"
    cat "$COMMUNICATION_DIR/coding_log.txt"
    exit 1
fi