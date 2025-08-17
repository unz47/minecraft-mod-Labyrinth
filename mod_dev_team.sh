#!/bin/bash

# MOD開発チーム - メイン実行スクリプト  
# Usage: ./mod_dev_team.sh [command] [arguments]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$SCRIPT_DIR/.claude/agents"
COMMUNICATION_DIR="$AGENTS_DIR/communication"

# ヘルプ表示
show_help() {
    echo "=== MOD開発チーム コマンド ==="
    echo
    echo "使用方法:"
    echo "  ./mod_dev_team.sh <command> [arguments]"
    echo
    echo "利用可能なコマンド:"
    echo "  start \"要求内容\"     - 新しいMOD機能の開発を開始"
    echo "  status               - 現在の開発状況を確認"
    echo "  continue             - 中断された開発を継続"
    echo "  clean                - 作業ファイルをクリア"
    echo "  help                 - このヘルプを表示"
    echo
    echo "例:"
    echo "  ./mod_dev_team.sh start \"銅の鉱石ブロックを追加して\""
    echo "  ./mod_dev_team.sh status"
    echo "  ./mod_dev_team.sh continue"
    echo
    echo "=== 開発フロー ==="
    echo "1. 要件定義AI: ユーザー要求を技術仕様に変換"
    echo "2. コーディングAI: 技術仕様を実装"
    echo "3. レビューAI: 実装をレビュー・評価"
    echo "4. (必要に応じて) 修正サイクル"
    echo
}

# 開発開始
start_development() {
    local user_request="$1"
    
    if [ -z "$user_request" ]; then
        echo "エラー: 要求内容を指定してください"
        echo "例: ./mod_dev_team.sh start \"新しいブロックを追加したい\""
        exit 1
    fi
    
    echo "🚀 MOD開発チーム開始"
    echo "要求: $user_request"
    echo
    
    # 既存の作業ファイルをクリア
    clean_workspace
    
    # 1. 要件定義AI実行
    echo "Phase 1/3: 要件定義AI実行中..."
    "$AGENTS_DIR/requirements/run_requirements.sh" "$user_request"
    
    if [ $? -ne 0 ]; then
        echo "❌ 要件定義で問題が発生しました"
        exit 1
    fi
    
    # 2. コーディングAI実行  
    echo "Phase 2/3: コーディングAI実行中..."
    "$AGENTS_DIR/coding/run_coding.sh"
    
    if [ $? -ne 0 ]; then
        echo "❌ コーディングで問題が発生しました"
        exit 1
    fi
    
    # 3. レビューAI実行
    echo "Phase 3/3: レビューAI実行中..."
    "$AGENTS_DIR/review/run_review.sh"
    
    if [ $? -ne 0 ]; then
        echo "❌ レビューで問題が発生しました" 
        exit 1
    fi
    
    # 結果確認
    check_final_status
}

# 開発継続
continue_development() {
    echo "🔄 開発継続中..."
    
    # 現在の状況を確認
    "$COMMUNICATION_DIR/status_check.sh"
    echo
    
    # 修正フィードバックがある場合はコーディングから再開
    if [ -f "$COMMUNICATION_DIR/review_feedback.txt" ]; then
        echo "修正フィードバックに基づいてコーディングAIを再実行します..."
        "$AGENTS_DIR/coding/run_coding.sh"
        
        if [ $? -eq 0 ]; then
            echo "レビューAIを再実行します..."
            "$AGENTS_DIR/review/run_review.sh"
        fi
    else
        echo "継続する作業がありません。"
    fi
    
    check_final_status
}

# 最終状況確認
check_final_status() {
    if [ -f "$COMMUNICATION_DIR/task_completed.txt" ]; then
        echo
        echo "🎉 開発完了!"
        echo "実装内容の詳細:"
        echo "$(cat "$COMMUNICATION_DIR/review_output.json" | grep -A 20 '"implementation_details"')"
    elif [ -f "$COMMUNICATION_DIR/review_feedback.txt" ]; then
        echo
        echo "⚠️  修正が必要です"
        echo "修正を継続するには: ./mod_dev_team.sh continue"
    else
        echo
        echo "❓ 状況が不明です。status コマンドで確認してください。"
    fi
}

# 作業ファイルクリア
clean_workspace() {
    echo "🧹 作業ファイルをクリア中..."
    
    rm -f "$COMMUNICATION_DIR/requirements_output.json"
    rm -f "$COMMUNICATION_DIR/coding_output.json" 
    rm -f "$COMMUNICATION_DIR/review_output.json"
    rm -f "$COMMUNICATION_DIR/review_feedback.txt"
    rm -f "$COMMUNICATION_DIR/user_input.txt"
    rm -f "$COMMUNICATION_DIR/current_task_id.txt"
    rm -f "$COMMUNICATION_DIR/task_completed.txt"
    rm -f "$COMMUNICATION_DIR/"*_log.txt
    
    echo "クリア完了"
}

# 状況確認
show_status() {
    "$COMMUNICATION_DIR/status_check.sh"
}

# メイン処理
case "${1:-help}" in
    "start")
        start_development "$2"
        ;;
    "continue")
        continue_development
        ;;
    "status")
        show_status
        ;;
    "clean")
        clean_workspace
        ;;
    "help"|*)
        show_help
        ;;
esac