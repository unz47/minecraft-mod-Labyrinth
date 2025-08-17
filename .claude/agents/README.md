# MOD開発チーム マルチエージェントシステム

## 概要
Minecraft MOD開発用の3つのAIエージェントによる自動開発システムです。

## エージェント構成

### 1. 要件定義AI (Requirements Analyst)
- **役割**: ユーザーの曖昧な要求を技術仕様に変換
- **入力**: 自然言語での要求
- **出力**: JSON形式の技術仕様
- **実行**: `.claude/agents/requirements/run_requirements.sh "要求内容"`

### 2. MODコーディングAI (Mod Coder)  
- **役割**: 技術仕様を実際のJavaコード・リソースに実装
- **入力**: 要件定義AIのJSON出力
- **出力**: 実装完了報告とファイルリスト
- **実行**: `.claude/agents/coding/run_coding.sh`

### 3. レビューAI (Code Reviewer)
- **役割**: 実装コードの品質評価とレビュー
- **入力**: 実装結果
- **出力**: PASS/FAIL判定と修正指示
- **実行**: `.claude/agents/review/run_review.sh`

## ワークフロー

```
ユーザー要求
    ↓
要件定義AI → JSON仕様
    ↓  
コーディングAI → 実装
    ↓
レビューAI → 評価
    ↓
PASS → 完了
FAIL → 修正指示 → コーディングAI (ループ)
```

## 視覚的インターフェース (tmux)

### 起動方法
```bash
# 視覚的UIを起動
./start_mod_dev_ui.sh

# 手動起動
.claude/tmux/start_session.sh
```

### ウィンドウ構成
```
┌─────────────────────────────────────────────────────────────────┐
│ ウィンドウ0: Dashboard  │ 全体状況をリアルタイム表示          │
│ ウィンドウ1: Agents     │ 3エージェントの詳細モニター(3分割)  │
│ ウィンドウ2: Control    │ コマンド実行パネル                  │
│ ウィンドウ3: Files      │ ファイルブラウザ + プロジェクト情報  │
└─────────────────────────────────────────────────────────────────┘
```

#### ウィンドウ1: Agents（3分割詳細）
```
┌─────────────────────┬─────────────────────┐
│                     │   コーディングAI    │
│   要件定義AI        │                     │
│                     ├─────────────────────┤
│   入力待機中...     │    レビューAI       │
│                     │                     │
└─────────────────────┴─────────────────────┘
```

## 使用方法

### 基本的な使い方
```bash
# 新しい機能開発を開始
./mod_dev_team.sh start "銅の鉱石ブロックを追加したい"

# 開発状況確認
./mod_dev_team.sh status

# 修正が必要な場合の継続
./mod_dev_team.sh continue

# 作業ファイルのクリア
./mod_dev_team.sh clean
```

### tmux操作
```bash
# セッションアタッチ
tmux attach-session -t mod-dev-team

# ウィンドウ切り替え
Ctrl+b → 0,1,2,3

# ペイン移動（Agentsウィンドウ内）
Ctrl+b → 矢印キー

# デタッチ
Ctrl+b → d
```

### 個別エージェント実行
```bash
# 要件定義のみ
.claude/agents/requirements/run_requirements.sh "新機能の説明"

# コーディングのみ（要件定義後）
.claude/agents/coding/run_coding.sh

# レビューのみ（実装後）
.claude/agents/review/run_review.sh
```

## ディレクトリ構造

```
.claude/agents/
├── requirements/           # 要件定義AI
│   ├── instructions/
│   │   └── requirements_analyst.md
│   └── run_requirements.sh
├── coding/                # コーディングAI
│   ├── instructions/
│   │   └── mod_coder.md
│   └── run_coding.sh
├── review/                # レビューAI
│   ├── instructions/
│   │   └── code_reviewer.md
│   └── run_review.sh
├── communication/         # エージェント間通信
│   ├── agent_send.sh
│   ├── status_check.sh
│   └── [各種出力ファイル]
└── tmux/                  # 視覚的インターフェース
    ├── start_session.sh
    ├── dashboard.sh
    ├── agent_monitor.sh
    └── log_viewer.sh
```

## 通信ファイル

### 出力ファイル
- `requirements_output.json`: 要件定義結果
- `coding_output.json`: 実装結果
- `review_output.json`: レビュー結果
- `review_feedback.txt`: 修正指示（FAIL時）
- `task_completed.txt`: 完了マーカー

### 状態管理
- `current_task_id.txt`: 現在のタスクID
- `communication.log`: エージェント間通信ログ

## 開発例

### 入力例
```bash
./mod_dev_team.sh start "青いダイヤモンドの鉱石を追加して、それを採掘すると青いダイヤモンドアイテムが手に入るようにしたい"
```

### 処理フロー
1. **要件定義AI**: 
   - "青いダイヤモンド鉱石ブロック"の技術仕様を定義
   - "青いダイヤモンドアイテム"の仕様を定義
   - ルートテーブル、必要ツール等を仕様化

2. **コーディングAI**:
   - ブロック・アイテムクラスを実装
   - レジストリに登録
   - リソースファイル作成
   - 言語ファイル更新

3. **レビューAI**:
   - コード品質チェック
   - 要件適合性確認
   - PASS/FAIL判定

## 特徴

- ✅ 完全自動化された開発フロー
- ✅ 品質保証システム内蔵
- ✅ 修正サイクルによる品質向上
- ✅ 既存コードパターンの維持
- ✅ 詳細な進捗管理
- ✅ **視覚的リアルタイム監視**
- ✅ **3分割エージェントモニター**

## 注意事項

- 各エージェントは独立したClaude Codeインスタンスとして動作
- テクスチャファイルは配置場所のみ準備（実際の画像は別途作成）
- 複雑すぎる要求は段階的実装を提案
- レビューで3回以上FAILした場合は手動確認を推奨
- **要件定義AIは入力待機状態で使用方法を表示**