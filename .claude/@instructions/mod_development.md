# Minecraft Mod開発ガイドライン

## プロジェクト情報
- **Mod ID**: oltorespawn
- **Minecraft Version**: 1.20.6
- **Forge Version**: 50.2.1
- **メインパッケージ**: com.unz47.oltOreSpawn

## 開発ルール

### 1. コーディング規約
- コメントは必要最小限に（ユーザーが明示的に要求した場合のみ追加）
- 既存のコードパターンに従う
- 既存のライブラリを優先的に使用

### 2. ファイル構造
```
src/main/
├── java/com/unz47/oltOreSpawn/
│   ├── blocks/       # ブロッククラス
│   ├── items/        # アイテムクラス  
│   ├── regi/         # 登録クラス（ModBlocks, ModItems等）
│   ├── tabs/         # クリエイティブタブ
│   └── main/         # メインクラス
└── resources/
    ├── assets/oltorespawn/
    │   ├── blockstates/
    │   ├── lang/
    │   ├── models/
    │   └── textures/
    └── data/
        └── oltorespawn/
            └── loot_tables/
```

### 3. 新規追加時の手順

#### ブロック追加
1. `blocks/`にブロッククラスを作成
2. `ModBlocks`に登録
3. クリエイティブタブに追加
4. リソースファイル（blockstate, model, texture）を配置
5. 言語ファイルに翻訳を追加
6. 必要に応じてloot tableとtagsを設定

#### アイテム追加
1. `items/`にアイテムクラスを作成
2. `ModItems`に登録
3. クリエイティブタブに追加
4. リソースファイル（model, texture）を配置
5. 言語ファイルに翻訳を追加

### 4. ビルドとテスト
```bash
# ビルド
./gradlew build

# クライアント起動
./gradlew runClient

# サーバー起動  
./gradlew runServer

# データ生成
./gradlew runData
```

### 5. 拡張性の考慮
- レジストリクラスは追加しやすい構造を維持
- 定数は適切にまとめる
- インターフェースを活用して共通処理を抽象化