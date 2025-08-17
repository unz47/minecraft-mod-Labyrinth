#!/bin/bash

# MOD開発チーム 視覚的UI起動スクリプト
# tmuxベースの統合開発環境を起動

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 MOD開発チーム 視覚的UI を起動しています..."
echo

# tmuxがインストールされているかチェック
if ! command -v tmux >/dev/null 2>&1; then
    echo "❌ エラー: tmux がインストールされていません"
    echo "📦 インストール方法:"
    echo "  macOS: brew install tmux"
    echo "  Ubuntu: sudo apt-get install tmux"
    echo "  CentOS: sudo yum install tmux"
    exit 1
fi

# tmux設定の確認
if [ ! -f "$SCRIPT_DIR/.tmux-mod-dev.conf" ]; then
    echo "❌ エラー: tmux設定ファイルが見つかりません"
    echo "📁 期待されるパス: $SCRIPT_DIR/.tmux-mod-dev.conf"
    exit 1
fi

# エージェントディレクトリの確認
if [ ! -d "$SCRIPT_DIR/.claude/agents" ]; then
    echo "❌ エラー: エージェントディレクトリが見つかりません"
    echo "📁 期待されるパス: $SCRIPT_DIR/.claude/agents"
    echo "💡 ヒント: 先にMOD開発チームシステムをセットアップしてください"
    exit 1
fi

# 通信ディレクトリの作成
mkdir -p "$SCRIPT_DIR/.claude/agents/communication"

echo "✅ 前提条件チェック完了"
echo

# tmuxセッション起動
"$SCRIPT_DIR/.claude/tmux/start_session.sh"

exit $?