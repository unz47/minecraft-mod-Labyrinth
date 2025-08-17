#!/bin/bash

# ワークフロー状態確認スクリプト
# Usage: ./status_check.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== MOD開発ワークフロー状態確認 ==="
echo

# タスクIDの確認
if [ -f "$SCRIPT_DIR/current_task_id.txt" ]; then
    TASK_ID=$(cat "$SCRIPT_DIR/current_task_id.txt")
    echo "現在のタスクID: $TASK_ID"
else
    echo "タスクID: 未設定"
fi
echo

# 各段階の完了状況確認
echo "=== 実行状況 ==="

# 1. 要件定義
if [ -f "$SCRIPT_DIR/requirements_output.json" ]; then
    echo "✅ 要件定義AI: 完了"
    echo "   出力: requirements_output.json"
else
    echo "❌ 要件定義AI: 未実行"
fi

# 2. コーディング  
if [ -f "$SCRIPT_DIR/coding_output.json" ]; then
    echo "✅ コーディングAI: 完了"
    echo "   出力: coding_output.json"
else
    echo "❌ コーディングAI: 未実行"
fi

# 3. レビュー
if [ -f "$SCRIPT_DIR/review_output.json" ]; then
    REVIEW_RESULT=$(cat "$SCRIPT_DIR/review_output.json" | grep -o '"review_result": *"[^"]*"' | cut -d'"' -f4)
    if [ "$REVIEW_RESULT" = "PASS" ]; then
        echo "✅ レビューAI: 完了 (PASS)"
    elif [ "$REVIEW_RESULT" = "FAIL" ]; then
        echo "⚠️  レビューAI: 完了 (FAIL - 修正が必要)"
    fi
    echo "   出力: review_output.json"
else
    echo "❌ レビューAI: 未実行"
fi

# 4. 全体完了状況
if [ -f "$SCRIPT_DIR/task_completed.txt" ]; then
    echo "🎉 全体ステータス: 完了"
    echo "   完了時刻: $(cat "$SCRIPT_DIR/task_completed.txt")"
else
    echo "🔄 全体ステータス: 進行中"
fi

echo

# 修正フィードバックの有無
if [ -f "$SCRIPT_DIR/review_feedback.txt" ]; then
    echo "⚠️  修正フィードバック有り:"
    echo "$(cat "$SCRIPT_DIR/review_feedback.txt")"
    echo
fi

# 通信ログの表示（最新5件）
if [ -f "$SCRIPT_DIR/communication.log" ]; then
    echo "=== 最新の通信ログ ==="
    tail -n 5 "$SCRIPT_DIR/communication.log"
else
    echo "=== 通信ログ ==="
    echo "まだ通信記録がありません"
fi

echo
echo "=== 次のアクション ==="

if [ ! -f "$SCRIPT_DIR/requirements_output.json" ]; then
    echo "1. 要件定義AIを実行: .claude/agents/requirements/run_requirements.sh \"要求内容\""
elif [ ! -f "$SCRIPT_DIR/coding_output.json" ]; then
    echo "2. コーディングAIを実行: .claude/agents/coding/run_coding.sh"
elif [ ! -f "$SCRIPT_DIR/review_output.json" ]; then
    echo "3. レビューAIを実行: .claude/agents/review/run_review.sh"
elif [ -f "$SCRIPT_DIR/review_feedback.txt" ]; then
    echo "4. 修正のためコーディングAIを再実行: .claude/agents/coding/run_coding.sh"
elif [ -f "$SCRIPT_DIR/task_completed.txt" ]; then
    echo "全て完了しています。新しいタスクを開始する場合は要件定義AIから実行してください。"
fi