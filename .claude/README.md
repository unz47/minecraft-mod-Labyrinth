# MOD開発チーム - エージェントAIコーディングシステム

3つのAIエージェントが連携してMinecraft Modの開発を自動化するシステム

## 🤖 エージェント構成

### 1. 要件定義AI (`requirements`)
- **役割**: ユーザー要求を技術仕様に変換
- **入力**: 自然言語による機能要求
- **出力**: JSON形式の技術仕様書

### 2. コーディングAI (`coding`) 
- **役割**: 技術仕様を実際のコードに実装
- **入力**: 要件定義AIからのJSON仕様
- **出力**: Java/JSONファイル群とステータス報告

### 3. レビューAI (`review`)
- **役割**: 実装されたコードの品質評価
- **入力**: コーディングAIの実装結果
- **出力**: PASS/FAIL判定と修正指示

## 🚀 使用方法

### 基本的な使い方

```bash
# MOD開発開始
./mod_dev_team.sh start "要求内容"

# 例：
./mod_dev_team.sh start "銅の鉱石ブロックを追加して"
./mod_dev_team.sh start "エメラルドのツールセットを作って"
./mod_dev_team.sh start "自動製錬機能付きのかまどを実装して"
```

### 進行状況確認

```bash
# 現在の状況確認
./mod_dev_team.sh status

# 中断された開発を継続
./mod_dev_team.sh continue

# 作業ファイルをクリア
./mod_dev_team.sh clean
```

### tmuxによる視覚的監視

```bash
# tmuxセッション起動
./.claude/tmux/start_session.sh

# ダッシュボードのみ表示
./.claude/tmux/dashboard.sh
```

## 🖥️ tmux画面構成

セッション起動後、以下の4つのウィンドウが利用可能：

- **Dashboard** (Ctrl+b → 0): 全体の状況ダッシュボード
- **Agents** (Ctrl+b → 1): 各エージェントの詳細モニター（3分割）
- **Control** (Ctrl+b → 2): コマンド実行パネル
- **Files** (Ctrl+b → 3): ファイルブラウザとプロジェクト情報

## 📁 ファイル構造

```
.claude/
├── agents/                    # AIエージェント
│   ├── requirements/          # 要件定義AI
│   │   ├── instructions/      # AI指示書
│   │   └── run_requirements.sh
│   ├── coding/               # コーディングAI
│   │   ├── instructions/     # AI指示書
│   │   └── run_coding.sh
│   ├── review/               # レビューAI
│   │   ├── instructions/     # AI指示書
│   │   └── run_review.sh
│   └── communication/        # エージェント間通信
│       ├── status_check.sh   # 状況確認
│       ├── agent_send.sh     # 通信ヘルパー
│       ├── *_output.json     # 各段階の出力
│       ├── *_log.txt         # 実行ログ
│       └── communication.log # 通信ログ
├── tmux/                     # tmux関連
│   ├── start_session.sh      # セッション起動
│   ├── dashboard.sh          # ダッシュボード
│   ├── agent_monitor.sh      # エージェントモニター
│   └── log_viewer.sh         # ログビューア
├── claude.json              # ワークスペース設定
├── ignore                   # 除外ファイル設定
└── settings.local.json      # ローカル設定
```

## 🔧 開発フロー

1. **要求入力**: ユーザーが自然言語で機能要求を入力
2. **要件定義**: 要件定義AIが技術仕様を作成
3. **実装**: コーディングAIが実際のコードを生成
4. **レビュー**: レビューAIが品質チェック
5. **修正**: 必要に応じて修正サイクル
6. **完了**: 全ての基準を満たした時点で完了

## ⚙️ 設定ファイル

### `.claude/settings.local.json`
- プロジェクト固有の設定
- 実行権限とコマンド制限
- Mod開発環境設定

### `CLAUDE.md`
- プロジェクト全体の指示書
- コーディング規約
- 実装パターン

## 🛠️ トラブルシューティング

### よくある問題

1. **権限エラー**: スクリプトに実行権限を付与
   ```bash
   chmod +x .claude/agents/*/*.sh
   chmod +x .claude/tmux/*.sh
   chmod +x mod_dev_team.sh
   ```

2. **Claude実行エラー**: claudeコマンドがパスに含まれているか確認
   ```bash
   which claude
   ```

3. **tmuxセッションエラー**: 既存セッションを削除
   ```bash
   tmux kill-session -t mod-dev-team
   ```

## 📋 対応機能

現在対応している機能カテゴリ：

- ✅ ブロック追加（鉱石、装飾ブロック等）
- ✅ アイテム追加（インゴット、ツール、食物等）
- ✅ クリエイティブタブ管理
- ✅ リソースファイル自動生成
- ✅ 言語ファイル更新
- ✅ レジストリシステム統合

## 🎯 今後の拡張予定

- [ ] カスタム次元サポート
- [ ] GUI/コンテナブロック
- [ ] エンティティとモブ
- [ ] ワールド生成機能
- [ ] データパック統合

---

**注意**: このシステムはMinecraft Forge 1.20.6環境向けに最適化されています。