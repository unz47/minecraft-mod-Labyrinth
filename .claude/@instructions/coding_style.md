# コーディングスタイルガイド

## 基本原則
1. **既存のパターンを優先**: 新規コードは既存のコードスタイルに合わせる
2. **コメント最小化**: 明示的に要求されない限りコメントは追加しない
3. **拡張性重視**: 将来の追加・変更を考慮した設計

## Java規約

### 命名規則
- クラス名: PascalCase（例: `OrichalcumOreBlock`）
- メソッド名: camelCase（例: `registerBlock`）
- 定数: UPPER_SNAKE_CASE（例: `MOD_ID`）
- パッケージ名: lowercase（例: `com.unz47.oltorespawn`）

### クラス構造
```java
public class ExampleBlock extends Block {
    // 定数
    // static フィールド
    // インスタンスフィールド
    // コンストラクタ
    // publicメソッド
    // protectedメソッド
    // privateメソッド
}
```

### インポート
- ワイルドカードインポートは避ける
- 未使用のインポートは削除
- 標準ライブラリ → Minecraft/Forge → 自作クラスの順

## リソースファイル規約

### JSONフォーマット
- インデント: スペース2つ
- 末尾カンマなし
- キーはダブルクォートで囲む

### ファイル命名
- 小文字とアンダースコア（snake_case）
- ブロック/アイテムIDと一致させる

## Git規約

### コミットメッセージ
- 簡潔で明確な説明
- 日本語または英語（プロジェクトに合わせる）
- 例: "Add orichalcum ore block with basic properties"

### ブランチ戦略
- main: 安定版
- develop: 開発版
- feature/*: 機能追加
- fix/*: バグ修正