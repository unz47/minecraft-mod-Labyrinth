#!/bin/bash

# ログビューアスクリプト
# 各種ログファイルをリアルタイムで表示

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMUNICATION_DIR="$SCRIPT_DIR/../agents/communication"
LOG_TYPE="$1"

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

show_help() {
    echo "ログビューア - 使用方法"
    echo "  $0 <log_type>"
    echo ""
    echo "利用可能なログタイプ:"
    echo "  communication  - エージェント間通信ログ"
    echo "  requirements   - 要件定義AIログ"
    echo "  coding         - コーディングAIログ"
    echo "  review         - レビューAIログ"
    echo "  all            - すべてのログを統合表示"
}

show_communication_log() {
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║                           ${CYAN}📡 エージェント間通信ログ${WHITE}                            ║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    LOG_FILE="$COMMUNICATION_DIR/communication.log"
    
    if [ -f "$LOG_FILE" ]; then
        echo -e "${BLUE}ファイル:${NC} $LOG_FILE"
        echo -e "${BLUE}監視開始:${NC} $(date)"
        echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        
        # 既存ログを表示
        if [ -s "$LOG_FILE" ]; then
            echo -e "${YELLOW}=== 既存のログ ===${NC}"
            cat "$LOG_FILE" | while IFS= read -r line; do
                echo -e "${CYAN}│${NC} $line"
            done
            echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        fi
        
        # リアルタイム監視
        echo -e "${GREEN}=== リアルタイム監視中... ===${NC}"
        tail -f "$LOG_FILE" | while IFS= read -r line; do
            timestamp=$(date '+%H:%M:%S')
            echo -e "${GREEN}[$timestamp]${NC} ${CYAN}│${NC} $line"
        done
    else
        echo -e "${YELLOW}⚠️  通信ログファイルが見つかりません: $LOG_FILE${NC}"
        echo -e "${BLUE}💡 ヒント: MOD開発チームが動作すると自動的に作成されます${NC}"
        
        # ファイル作成を監視
        echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        echo -e "${GREEN}ファイル作成を監視中...${NC}"
        while [ ! -f "$LOG_FILE" ]; do
            sleep 1
        done
        echo -e "${GREEN}✅ ログファイルが作成されました！${NC}"
        show_communication_log
    fi
}

show_agent_log() {
    local agent_name="$1"
    local display_name="$2"
    local log_file="$COMMUNICATION_DIR/${agent_name}_log.txt"
    
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║                              ${PURPLE}$display_name${WHITE}                               ║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    if [ -f "$log_file" ]; then
        echo -e "${BLUE}ファイル:${NC} $log_file"
        echo -e "${BLUE}最終更新:${NC} $(stat -f "%Sm" "$log_file" 2>/dev/null || echo "不明")"
        echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        
        # 既存ログを表示
        if [ -s "$log_file" ]; then
            echo -e "${YELLOW}=== 既存のログ ===${NC}"
            cat "$log_file" | while IFS= read -r line; do
                echo -e "${CYAN}│${NC} $line"
            done
            echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        fi
        
        # リアルタイム監視
        echo -e "${GREEN}=== リアルタイム監視中... ===${NC}"
        tail -f "$log_file" | while IFS= read -r line; do
            timestamp=$(date '+%H:%M:%S')
            echo -e "${GREEN}[$timestamp]${NC} ${CYAN}│${NC} $line"
        done
    else
        echo -e "${YELLOW}⚠️  ログファイルが見つかりません: $log_file${NC}"
        echo -e "${BLUE}💡 ヒント: ${agent_name}AIが実行されると自動的に作成されます${NC}"
        
        # ファイル作成を監視
        echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
        echo -e "${GREEN}ファイル作成を監視中...${NC}"
        while [ ! -f "$log_file" ]; do
            sleep 1
        done
        echo -e "${GREEN}✅ ログファイルが作成されました！${NC}"
        show_agent_log "$agent_name" "$display_name"
    fi
}

show_all_logs() {
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║                            ${RAINBOW}🌈 統合ログビューア${WHITE}                             ║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # 全ログファイルのパス
    declare -A log_files=(
        ["COMM"]="$COMMUNICATION_DIR/communication.log"
        ["REQ"]="$COMMUNICATION_DIR/requirements_log.txt"
        ["CODE"]="$COMMUNICATION_DIR/coding_log.txt"
        ["REV"]="$COMMUNICATION_DIR/review_log.txt"
    )
    
    # 既存ログの表示
    echo -e "${YELLOW}=== 既存のログ ===${NC}"
    for prefix in "COMM" "REQ" "CODE" "REV"; do
        log_file="${log_files[$prefix]}"
        if [ -f "$log_file" ] && [ -s "$log_file" ]; then
            echo -e "${WHITE}[$prefix]${NC} --- $(basename "$log_file") ---"
            cat "$log_file" | while IFS= read -r line; do
                case "$prefix" in
                    "COMM") echo -e "${CYAN}[$prefix]${NC} $line" ;;
                    "REQ")  echo -e "${PURPLE}[$prefix]${NC} $line" ;;
                    "CODE") echo -e "${GREEN}[$prefix]${NC} $line" ;;
                    "REV")  echo -e "${BLUE}[$prefix]${NC} $line" ;;
                esac
            done
            echo
        fi
    done
    
    echo -e "${WHITE}────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${GREEN}=== リアルタイム統合監視中... ===${NC}"
    
    # リアルタイム監視（複数ファイル）
    (
        for prefix in "COMM" "REQ" "CODE" "REV"; do
            log_file="${log_files[$prefix]}"
            if [ -f "$log_file" ]; then
                tail -f "$log_file" 2>/dev/null | while IFS= read -r line; do
                    timestamp=$(date '+%H:%M:%S')
                    case "$prefix" in
                        "COMM") echo -e "${GREEN}[$timestamp]${NC} ${CYAN}[$prefix]${NC} $line" ;;
                        "REQ")  echo -e "${GREEN}[$timestamp]${NC} ${PURPLE}[$prefix]${NC} $line" ;;
                        "CODE") echo -e "${GREEN}[$timestamp]${NC} ${GREEN}[$prefix]${NC} $line" ;;
                        "REV")  echo -e "${GREEN}[$timestamp]${NC} ${BLUE}[$prefix]${NC} $line" ;;
                    esac
                done &
            fi
        done
        wait
    )
}

# メイン処理
case "${LOG_TYPE:-help}" in
    "communication")
        show_communication_log
        ;;
    "requirements")
        show_agent_log "requirements" "📋 要件定義AI ログ"
        ;;
    "coding")
        show_agent_log "coding" "💻 コーディングAI ログ"
        ;;
    "review")
        show_agent_log "review" "🔍 レビューAI ログ"
        ;;
    "all")
        show_all_logs
        ;;
    "help"|*)
        show_help
        ;;
esac