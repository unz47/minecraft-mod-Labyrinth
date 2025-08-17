#!/bin/bash

# エージェント個別モニタリングスクリプト
# Usage: ./agent_monitor.sh <agent_name>

AGENT_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMUNICATION_DIR="$SCRIPT_DIR/../agents/communication"

if [ -z "$AGENT_NAME" ]; then
    echo "使用方法: $0 <agent_name>"
    echo "agent_name: requirements | coding | review"
    exit 1
fi

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

clear_screen() {
    clear
    tput cup 0 0
}

show_requirements_monitor() {
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║                             ${PURPLE}🧠 要件定義AI モニター${WHITE}                             ║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    echo -e "${WHITE}📊 状態${NC}"
    echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
    
    if [ -f "$COMMUNICATION_DIR/requirements_output.json" ]; then
        echo -e "  ${GREEN}✅ ステータス${NC}      : ${GREEN}完了${NC}"
        echo -e "  ${BLUE}📅 最終更新${NC}        : $(stat -f "%Sm" "$COMMUNICATION_DIR/requirements_output.json" 2>/dev/null || echo "不明")"
        echo
        
        echo -e "${WHITE}📋 出力内容${NC}"
        echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        if command -v jq >/dev/null 2>&1; then
            cat "$COMMUNICATION_DIR/requirements_output.json" | jq . 2>/dev/null || cat "$COMMUNICATION_DIR/requirements_output.json"
        else
            cat "$COMMUNICATION_DIR/requirements_output.json"
        fi
    else
        echo -e "  ${YELLOW}⏳ ステータス${NC}      : ${YELLOW}入力待機中${NC}"
        echo -e "  ${BLUE}📝 待機内容${NC}        : ユーザー要求の入力を待機中"
        echo
        
        echo -e "${WHITE}💡 開始方法${NC}"
        echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        echo -e "  ${CYAN}│${NC} Controlウィンドウで以下のコマンドを実行:"
        echo -e "  ${CYAN}│${NC} ./mod_dev_team.sh start \"要求内容\""
        echo -e "  ${CYAN}│${NC}"
        echo -e "  ${CYAN}│${NC} 例:"
        echo -e "  ${CYAN}│${NC} ./mod_dev_team.sh start \"銅の鉱石ブロックを追加したい\""
        echo -e "  ${CYAN}│${NC} ./mod_dev_team.sh start \"新しいアイテムを作りたい\""
        echo
        
        if [ -f "$COMMUNICATION_DIR/user_input.txt" ]; then
            echo -e "${WHITE}📥 受信した要求${NC}"
            echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
            cat "$COMMUNICATION_DIR/user_input.txt"
            echo
        fi
    fi
    
    echo
    
    # ログ表示
    if [ -f "$COMMUNICATION_DIR/requirements_log.txt" ]; then
        echo -e "${WHITE}📜 実行ログ (最新10行)${NC}"
        echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        tail -n 10 "$COMMUNICATION_DIR/requirements_log.txt" | while IFS= read -r line; do
            echo -e "  ${CYAN}│${NC} $line"
        done
    fi
}

show_coding_monitor() {
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║                             ${GREEN}💻 コーディングAI モニター${WHITE}                           ║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    echo -e "${WHITE}📊 状態${NC}"
    echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
    
    if [ -f "$COMMUNICATION_DIR/coding_output.json" ]; then
        echo -e "  ${GREEN}✅ ステータス${NC}      : ${GREEN}完了${NC}"
        echo -e "  ${BLUE}📅 最終更新${NC}        : $(stat -f "%Sm" "$COMMUNICATION_DIR/coding_output.json" 2>/dev/null || echo "不明")"
        echo
        
        echo -e "${WHITE}📋 実装結果${NC}"
        echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        if command -v jq >/dev/null 2>&1; then
            cat "$COMMUNICATION_DIR/coding_output.json" | jq . 2>/dev/null || cat "$COMMUNICATION_DIR/coding_output.json"
        else
            cat "$COMMUNICATION_DIR/coding_output.json"
        fi
    elif [ -f "$COMMUNICATION_DIR/requirements_output.json" ]; then
        echo -e "  ${YELLOW}⏳ ステータス${NC}      : ${YELLOW}準備中${NC}"
        echo -e "  ${BLUE}📝 待機理由${NC}        : 要件定義完了、実行待ち"
    else
        echo -e "  ${RED}❌ ステータス${NC}      : ${RED}待機中${NC}"
        echo -e "  ${BLUE}📝 待機理由${NC}        : 要件定義未完了"
    fi
    
    echo
    
    # 修正フィードバック
    if [ -f "$COMMUNICATION_DIR/review_feedback.txt" ]; then
        echo -e "${WHITE}🔄 修正フィードバック${NC}"
        echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        while IFS= read -r line; do
            echo -e "  ${YELLOW}│${NC} $line"
        done < "$COMMUNICATION_DIR/review_feedback.txt"
        echo
    fi
    
    # ログ表示
    if [ -f "$COMMUNICATION_DIR/coding_log.txt" ]; then
        echo -e "${WHITE}📜 実行ログ (最新10行)${NC}"
        echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        tail -n 10 "$COMMUNICATION_DIR/coding_log.txt" | while IFS= read -r line; do
            echo -e "  ${CYAN}│${NC} $line"
        done
    fi
}

show_review_monitor() {
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║                              ${BLUE}🔍 レビューAI モニター${WHITE}                              ║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    echo -e "${WHITE}📊 状態${NC}"
    echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
    
    if [ -f "$COMMUNICATION_DIR/review_output.json" ]; then
        REVIEW_RESULT=$(cat "$COMMUNICATION_DIR/review_output.json" | grep -o '"review_result": *"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "UNKNOWN")
        
        if [ "$REVIEW_RESULT" = "PASS" ]; then
            echo -e "  ${GREEN}✅ ステータス${NC}      : ${GREEN}PASS${NC}"
        elif [ "$REVIEW_RESULT" = "FAIL" ]; then
            echo -e "  ${RED}❌ ステータス${NC}      : ${RED}FAIL${NC}"
        else
            echo -e "  ${YELLOW}⏳ ステータス${NC}      : ${YELLOW}処理中${NC}"
        fi
        
        echo -e "  ${BLUE}📅 最終更新${NC}        : $(stat -f "%Sm" "$COMMUNICATION_DIR/review_output.json" 2>/dev/null || echo "不明")"
        echo
        
        echo -e "${WHITE}📋 レビュー結果${NC}"
        echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        if command -v jq >/dev/null 2>&1; then
            cat "$COMMUNICATION_DIR/review_output.json" | jq . 2>/dev/null || cat "$COMMUNICATION_DIR/review_output.json"
        else
            cat "$COMMUNICATION_DIR/review_output.json"
        fi
    elif [ -f "$COMMUNICATION_DIR/coding_output.json" ]; then
        echo -e "  ${YELLOW}⏳ ステータス${NC}      : ${YELLOW}準備中${NC}"
        echo -e "  ${BLUE}📝 待機理由${NC}        : 実装完了、レビュー実行待ち"
    else
        echo -e "  ${RED}❌ ステータス${NC}      : ${RED}待機中${NC}"
        echo -e "  ${BLUE}📝 待機理由${NC}        : 実装未完了"
    fi
    
    echo
    
    # ログ表示
    if [ -f "$COMMUNICATION_DIR/review_log.txt" ]; then
        echo -e "${WHITE}📜 実行ログ (最新10行)${NC}"
        echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        tail -n 10 "$COMMUNICATION_DIR/review_log.txt" | while IFS= read -r line; do
            echo -e "  ${CYAN}│${NC} $line"
        done
    fi
}

# メインループ
while true; do
    clear_screen
    
    case "$AGENT_NAME" in
        "requirements")
            show_requirements_monitor
            ;;
        "coding")
            show_coding_monitor
            ;;
        "review")
            show_review_monitor
            ;;
        *)
            echo "エラー: 不明なエージェント名: $AGENT_NAME"
            exit 1
            ;;
    esac
    
    echo
    echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "  ${BLUE}🔄 自動更新中...${NC} ${YELLOW}Ctrl+C で終了${NC}"
    echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
    
    sleep 2
done