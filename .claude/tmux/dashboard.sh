#!/bin/bash

# ステータスダッシュボード表示スクリプト

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMUNICATION_DIR="$SCRIPT_DIR/../agents/communication"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

clear_screen() {
    clear
    tput cup 0 0
}

show_header() {
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║                           ${CYAN}🤖 MOD開発チーム ダッシュボード${WHITE}                           ║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

show_agents_status() {
    echo -e "${WHITE}📊 エージェント状況${NC}"
    echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
    
    # 要件定義AI
    if [ -f "$COMMUNICATION_DIR/requirements_output.json" ]; then
        echo -e "  ${GREEN}✅ 要件定義AI${NC}     : ${GREEN}完了${NC}"
        echo -e "     ${BLUE}├─${NC} 出力: requirements_output.json"
    else
        echo -e "  ${YELLOW}⏳ 要件定義AI${NC}     : ${YELLOW}待機中${NC}"
    fi
    
    # コーディングAI
    if [ -f "$COMMUNICATION_DIR/coding_output.json" ]; then
        echo -e "  ${GREEN}✅ コーディングAI${NC}   : ${GREEN}完了${NC}"
        echo -e "     ${BLUE}├─${NC} 出力: coding_output.json"
    elif [ -f "$COMMUNICATION_DIR/requirements_output.json" ]; then
        echo -e "  ${YELLOW}⏳ コーディングAI${NC}   : ${YELLOW}準備中${NC}"
    else
        echo -e "  ${RED}❌ コーディングAI${NC}   : ${RED}待機中${NC}"
    fi
    
    # レビューAI
    if [ -f "$COMMUNICATION_DIR/review_output.json" ]; then
        REVIEW_RESULT=$(cat "$COMMUNICATION_DIR/review_output.json" | grep -o '"review_result": *"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "UNKNOWN")
        if [ "$REVIEW_RESULT" = "PASS" ]; then
            echo -e "  ${GREEN}✅ レビューAI${NC}      : ${GREEN}PASS${NC}"
        elif [ "$REVIEW_RESULT" = "FAIL" ]; then
            echo -e "  ${RED}❌ レビューAI${NC}      : ${RED}FAIL${NC}"
        else
            echo -e "  ${YELLOW}⏳ レビューAI${NC}      : ${YELLOW}処理中${NC}"
        fi
        echo -e "     ${BLUE}├─${NC} 出力: review_output.json"
    elif [ -f "$COMMUNICATION_DIR/coding_output.json" ]; then
        echo -e "  ${YELLOW}⏳ レビューAI${NC}      : ${YELLOW}準備中${NC}"
    else
        echo -e "  ${RED}❌ レビューAI${NC}      : ${RED}待機中${NC}"
    fi
    
    echo
}

show_current_task() {
    echo -e "${WHITE}📋 現在のタスク${NC}"
    echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
    
    if [ -f "$COMMUNICATION_DIR/current_task_id.txt" ]; then
        TASK_ID=$(cat "$COMMUNICATION_DIR/current_task_id.txt")
        echo -e "  ${BLUE}🆔 タスクID${NC}        : ${TASK_ID}"
    else
        echo -e "  ${YELLOW}⚠️  タスクID${NC}        : 未設定"
    fi
    
    if [ -f "$COMMUNICATION_DIR/user_input.txt" ]; then
        USER_INPUT=$(cat "$COMMUNICATION_DIR/user_input.txt")
        echo -e "  ${BLUE}📝 ユーザー要求${NC}    : ${USER_INPUT}"
    else
        echo -e "  ${YELLOW}⚠️  ユーザー要求${NC}    : 未設定"
    fi
    
    # 完了状況
    if [ -f "$COMMUNICATION_DIR/task_completed.txt" ]; then
        COMPLETED_TIME=$(cat "$COMMUNICATION_DIR/task_completed.txt")
        echo -e "  ${GREEN}🎉 完了時刻${NC}        : ${COMPLETED_TIME}"
    fi
    
    echo
}

show_feedback() {
    if [ -f "$COMMUNICATION_DIR/review_feedback.txt" ]; then
        echo -e "${WHITE}🔄 修正フィードバック${NC}"
        echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        while IFS= read -r line; do
            echo -e "  ${YELLOW}│${NC} $line"
        done < "$COMMUNICATION_DIR/review_feedback.txt"
        echo
    fi
}

show_recent_logs() {
    echo -e "${WHITE}📜 最新の通信ログ${NC}"
    echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
    
    if [ -f "$COMMUNICATION_DIR/communication.log" ]; then
        tail -n 5 "$COMMUNICATION_DIR/communication.log" | while IFS= read -r line; do
            echo -e "  ${CYAN}│${NC} $line"
        done
    else
        echo -e "  ${YELLOW}⚠️  まだ通信記録がありません${NC}"
    fi
    echo
}

show_next_actions() {
    echo -e "${WHITE}🎯 次のアクション${NC}"
    echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
    
    if [ ! -f "$COMMUNICATION_DIR/requirements_output.json" ]; then
        echo -e "  ${BLUE}▶️  ${NC}要件定義AIを実行"
        echo -e "     ${BLUE}└─${NC} ./mod_dev_team.sh start \"要求内容\""
    elif [ ! -f "$COMMUNICATION_DIR/coding_output.json" ]; then
        echo -e "  ${BLUE}▶️  ${NC}コーディングAIを実行"
        echo -e "     ${BLUE}└─${NC} .claude/agents/coding/run_coding.sh"
    elif [ ! -f "$COMMUNICATION_DIR/review_output.json" ]; then
        echo -e "  ${BLUE}▶️  ${NC}レビューAIを実行"
        echo -e "     ${BLUE}└─${NC} .claude/agents/review/run_review.sh"
    elif [ -f "$COMMUNICATION_DIR/review_feedback.txt" ]; then
        echo -e "  ${BLUE}▶️  ${NC}修正のためコーディングAIを再実行"
        echo -e "     ${BLUE}└─${NC} ./mod_dev_team.sh continue"
    elif [ -f "$COMMUNICATION_DIR/task_completed.txt" ]; then
        echo -e "  ${GREEN}🎉 全て完了しています！${NC}"
        echo -e "     ${BLUE}└─${NC} 新しいタスクを開始する場合は要件定義AIから実行"
    fi
    echo
}

show_footer() {
    echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "  ${BLUE}🔄 自動更新中...${NC} ${YELLOW}Ctrl+C で終了${NC}"
    echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
}

# メインループ
while true; do
    clear_screen
    show_header
    show_agents_status
    show_current_task
    show_feedback
    show_recent_logs
    show_next_actions
    show_footer
    
    sleep 3
done