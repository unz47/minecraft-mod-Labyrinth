#!/bin/bash

# レビューAI実行スクリプト
# Usage: ./run_review.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
COMMUNICATION_DIR="$SCRIPT_DIR/../communication"
INSTRUCTIONS_FILE="$SCRIPT_DIR/instructions/code_reviewer.md"

echo "=== レビューAI開始 ==="

# 実装結果の確認
if [ ! -f "$COMMUNICATION_DIR/coding_output.json" ]; then
    echo "エラー: 実装結果が見つかりません"
    echo "先にコーディングAIを実行してください: .claude/agents/coding/run_coding.sh"
    exit 1
fi

# 要件定義結果の確認
if [ ! -f "$COMMUNICATION_DIR/requirements_output.json" ]; then
    echo "エラー: 要件定義結果が見つかりません"
    exit 1
fi

# タスクIDの取得
TASK_ID=$(cat "$COMMUNICATION_DIR/current_task_id.txt" 2>/dev/null || echo "unknown")
echo "タスクID: $TASK_ID"

# 実装結果の表示
echo "=== レビュー対象の実装 ==="
cat "$COMMUNICATION_DIR/coding_output.json"
echo

# レビュー開始
echo "コードレビューを開始中..."

# Claude Codeを呼び出し
# インストラクションファイルの内容を読み込み
INSTRUCTIONS_CONTENT=$(cat "$INSTRUCTIONS_FILE")

PROMPT="
$INSTRUCTIONS_CONTENT

あなたはレビューAIです。以下の要件定義と実装結果を基にコードレビューを実行してください。

=== 元の要件定義 ===
$(cat "$COMMUNICATION_DIR/requirements_output.json")

=== 実装結果 ===  
$(cat "$COMMUNICATION_DIR/coding_output.json")

=== レビュー指示 ===
1. 実装されたコードの詳細レビューを行ってください
2. 要件定義との適合性を確認してください
3. プロジェクト標準への準拠を確認してください
4. 以下の評価基準に従って判定してください:

PASS条件:
- コンパイルエラーなし
- 要件定義の全項目が実装済み
- 既存のコードパターンに準拠
- 適切なファイル配置
- 言語ファイルの更新完了
- クリエイティブタブへの登録完了

5. レビュー結果を純粋なJSONのみで出力してください。JSONをコードブロックで囲むか、説明文を付けずに出力してください

6. FAIL判定の場合は、修正指示も同じJSON内のrequired_fixesフィールドに含めてください

プロジェクト情報:
- 作業ディレクトリ: $PROJECT_ROOT  
- Mod ID: oltorespawn
- Minecraft Version: 1.20.6
- Forge Version: 50.2.1
"

# Claudeを実行（バックグラウンドでタイムアウト監視）
(
    echo "$PROMPT" | claude --print > "$COMMUNICATION_DIR/review_log.txt" 2>&1
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

# タイムアウトした場合はプロセスを終了してフォールバック実行
if [ $ELAPSED -ge $TIMEOUT ]; then
    kill $CLAUDE_PID 2>/dev/null
    echo "Claude実行がタイムアウトしました（3分）" >> "$COMMUNICATION_DIR/review_log.txt"
    echo "フォールバック レビューを開始します..." >> "$COMMUNICATION_DIR/review_log.txt"
    
    # フォールバック レビューを実行
    "$SCRIPT_DIR/fallback_review.sh" >> "$COMMUNICATION_DIR/review_log.txt" 2>&1
    if [ $? -eq 0 ]; then
        echo "フォールバック レビューが成功しました" >> "$COMMUNICATION_DIR/review_log.txt"
    else
        echo "フォールバック レビューでエラーが発生しました" >> "$COMMUNICATION_DIR/review_log.txt"
    fi
fi

# Claude出力からJSONを抽出してファイルに保存
if [ -s "$COMMUNICATION_DIR/review_log.txt" ]; then
    # JSONブロックを探して抽出
    if grep -q '```json' "$COMMUNICATION_DIR/review_log.txt"; then
        # ```json ブロックからJSONを抽出
        sed -n '/```json/,/```/p' "$COMMUNICATION_DIR/review_log.txt" | sed '1d;$d' > "$COMMUNICATION_DIR/review_output.json"
    else
        # JSONブロックがない場合、JSON形式部分を直接抽出を試行
        grep -E '^\s*{' "$COMMUNICATION_DIR/review_log.txt" -A 100 | head -n 1000 > "$COMMUNICATION_DIR/review_output.json" || true
    fi
    
    # JSONファイルが空でないかチェック
    if [ ! -s "$COMMUNICATION_DIR/review_output.json" ]; then
        # 最後の手段：全体をJSONファイルとして保存を試行
        cp "$COMMUNICATION_DIR/review_log.txt" "$COMMUNICATION_DIR/review_output.json"
    fi
fi

# レビュー結果からフィードバックファイルを生成
if [ -f "$COMMUNICATION_DIR/review_output.json" ]; then
    # required_fixesフィールドから修正指示を抽出
    if command -v jq >/dev/null 2>&1; then
        REQUIRED_FIXES=$(jq -r '.required_fixes[]?' "$COMMUNICATION_DIR/review_output.json" 2>/dev/null)
        if [ -n "$REQUIRED_FIXES" ]; then
            echo "$REQUIRED_FIXES" > "$COMMUNICATION_DIR/review_feedback.txt"
        fi
    fi
fi

# 結果の確認
if [ -f "$COMMUNICATION_DIR/review_output.json" ]; then
    echo "=== レビュー完了 ==="
    echo "出力ファイル: $COMMUNICATION_DIR/review_output.json"
    echo
    
    # レビュー結果の解析
    REVIEW_RESULT=$(cat "$COMMUNICATION_DIR/review_output.json" | grep -o '"review_result": *"[^"]*"' | cut -d'"' -f4)
    
    if [ "$REVIEW_RESULT" = "PASS" ]; then
        echo "🎉 レビュー結果: PASS"
        echo
        echo "=== 最終実装内容の詳細説明 ==="
        cat "$COMMUNICATION_DIR/review_output.json"
        echo
        echo "=== MOD開発完了 ==="
        echo "実装が正常に完了しました。"
        
        # 完了マーカーの作成
        echo "$(date): COMPLETED" > "$COMMUNICATION_DIR/task_completed.txt"
        
    elif [ "$REVIEW_RESULT" = "FAIL" ]; then
        echo "❌ レビュー結果: FAIL"
        echo
        echo "=== 修正が必要な問題 ==="
        cat "$COMMUNICATION_DIR/review_output.json"
        echo
        
        if [ -f "$COMMUNICATION_DIR/review_feedback.txt" ]; then
            echo "=== 修正指示 ==="
            cat "$COMMUNICATION_DIR/review_feedback.txt"
            echo
            echo "コーディングAIで修正を実行してください:"
            echo ".claude/agents/coding/run_coding.sh"
        fi
    else
        echo "エラー: 不明なレビュー結果: $REVIEW_RESULT"
        exit 1
    fi
else
    echo "エラー: レビューの出力ファイルが見つかりません"
    echo "ログ:"
    cat "$COMMUNICATION_DIR/review_log.txt"
    exit 1
fi