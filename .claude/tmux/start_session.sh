#!/bin/bash

# tmuxセッション自動起動スクリプト
# MOD開発チームの視覚的インターフェースを起動

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SESSION_NAME="mod-dev-team"

# 既存セッションの確認
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "セッション '$SESSION_NAME' は既に存在します。"
    echo "既存セッションにアタッチしますか？ (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        tmux attach-session -t "$SESSION_NAME"
        exit 0
    else
        echo "既存セッションを終了してから新しいセッションを作成します..."
        tmux kill-session -t "$SESSION_NAME" 2>/dev/null
    fi
fi

echo "🚀 MOD開発チーム tmuxセッションを起動中..."

# プロジェクトディレクトリに移動
cd "$PROJECT_ROOT"

# 新しいセッションを作成（デタッチ状態で）
tmux new-session -d -s "$SESSION_NAME" -x 120 -y 40

# tmux設定を読み込み
tmux source-file "$PROJECT_ROOT/.tmux-mod-dev.conf"

# ウィンドウ1: メインダッシュボード
tmux rename-window -t "$SESSION_NAME:0" "Dashboard"
tmux send-keys -t "$SESSION_NAME:Dashboard" "cd '$PROJECT_ROOT'" C-m
tmux send-keys -t "$SESSION_NAME:Dashboard" ".claude/tmux/dashboard.sh" C-m

# ウィンドウ2: エージェント詳細 (3分割のみ)
tmux new-window -t "$SESSION_NAME" -n "Agents"
tmux send-keys -t "$SESSION_NAME:Agents" "cd '$PROJECT_ROOT'" C-m

# 水平に2分割
tmux split-window -t "$SESSION_NAME:Agents" -h
tmux send-keys -t "$SESSION_NAME:Agents.1" "cd '$PROJECT_ROOT'" C-m

# 右側を垂直に分割
tmux split-window -t "$SESSION_NAME:Agents.1" -v
tmux send-keys -t "$SESSION_NAME:Agents.2" "cd '$PROJECT_ROOT'" C-m

# 各ペインにエージェントモニターを起動
tmux send-keys -t "$SESSION_NAME:Agents.0" ".claude/tmux/agent_monitor.sh requirements" C-m
tmux send-keys -t "$SESSION_NAME:Agents.1" ".claude/tmux/agent_monitor.sh coding" C-m
tmux send-keys -t "$SESSION_NAME:Agents.2" ".claude/tmux/agent_monitor.sh review" C-m

# ウィンドウ3: 実行コマンド (入力用)
tmux new-window -t "$SESSION_NAME" -n "Control"
tmux send-keys -t "$SESSION_NAME:Control" "cd '$PROJECT_ROOT'" C-m
tmux send-keys -t "$SESSION_NAME:Control" "echo '🎛️  MOD開発チーム コントロールパネル'" C-m
tmux send-keys -t "$SESSION_NAME:Control" "echo ''" C-m
tmux send-keys -t "$SESSION_NAME:Control" "echo '利用可能なコマンド:'" C-m
tmux send-keys -t "$SESSION_NAME:Control" "echo '  ./mod_dev_team.sh start \"要求内容\"    - 新しい開発を開始'" C-m
tmux send-keys -t "$SESSION_NAME:Control" "echo '  ./mod_dev_team.sh status             - 状況確認'" C-m
tmux send-keys -t "$SESSION_NAME:Control" "echo '  ./mod_dev_team.sh continue           - 開発継続'" C-m
tmux send-keys -t "$SESSION_NAME:Control" "echo '  ./mod_dev_team.sh clean              - 作業ファイルクリア'" C-m
tmux send-keys -t "$SESSION_NAME:Control" "echo ''" C-m
tmux send-keys -t "$SESSION_NAME:Control" "echo '例: ./mod_dev_team.sh start \"銅の鉱石ブロックを追加したい\"'" C-m
tmux send-keys -t "$SESSION_NAME:Control" "echo ''" C-m
tmux send-keys -t "$SESSION_NAME:Control" "echo '💡 ヒント: Agentsウィンドウの要件定義AIでユーザー入力を待機中...'" C-m

# ウィンドウ4: ファイルブラウザ
tmux new-window -t "$SESSION_NAME" -n "Files"
tmux send-keys -t "$SESSION_NAME:Files" "cd '$PROJECT_ROOT'" C-m
if command -v tree >/dev/null 2>&1; then
    tmux send-keys -t "$SESSION_NAME:Files" "tree -L 3 -I 'build|run|*.log'" C-m
elif command -v ls >/dev/null 2>&1; then
    tmux send-keys -t "$SESSION_NAME:Files" "ls -la" C-m
fi

# 下半分でプロジェクト情報表示
tmux split-window -t "$SESSION_NAME:Files" -v
tmux send-keys -t "$SESSION_NAME:Files.1" "cd '$PROJECT_ROOT'" C-m
tmux send-keys -t "$SESSION_NAME:Files.1" "echo '📂 プロジェクト情報'" C-m
tmux send-keys -t "$SESSION_NAME:Files.1" "echo '──────────────────────────────────────────────────'" C-m
if [ -f "$PROJECT_ROOT/CLAUDE.md" ]; then
    tmux send-keys -t "$SESSION_NAME:Files.1" "head -n 20 CLAUDE.md" C-m
fi

# 最初のウィンドウ（Dashboard）を選択
tmux select-window -t "$SESSION_NAME:Dashboard"

echo "✅ tmuxセッション '$SESSION_NAME' が起動しました！"
echo ""
echo "🎯 使用方法:"
echo "  - アタッチ: tmux attach-session -t $SESSION_NAME"
echo "  - デタッチ: Ctrl+b → d"
echo "  - ウィンドウ切り替え: Ctrl+b → 数字キー"
echo "  - ペイン移動: Ctrl+b → 矢印キー"
echo ""
echo "📊 ウィンドウ構成:"
echo "  0: Dashboard - 全体の状況ダッシュボード"
echo "  1: Agents    - 各エージェントの詳細モニター (3分割)"
echo "  2: Control   - コマンド実行パネル"
echo "  3: Files     - ファイルブラウザとプロジェクト情報"
echo ""

# セッションにアタッチするか選択
echo "セッションにアタッチしますか？ (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    tmux attach-session -t "$SESSION_NAME"
else
    echo "バックグラウンドで実行中です。"
    echo "アタッチするには: tmux attach-session -t $SESSION_NAME"
fi