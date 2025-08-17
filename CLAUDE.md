# Labyrinth Mod - プロジェクト概要

## 🎮 基本情報
- **Mod名**: Labyrinth
- **Mod ID**: labyrinth
- **Minecraft Version**: 1.20.6
- **Forge Version**: 50.2.1
- **開発者**: unz47
- **パッケージ**: com.unz47.labyrinth

## 📁 プロジェクト構造

### Javaパッケージ構造
```
com.unz47.labyrinth/
├── blocks/          # ブロッククラス
│   └── OrichalcumOreBlock.java
├── items/           # アイテムクラス
│   ├── dim1/ingot/
│   │   └── Ingots.java
│   └── tools/       # ツールクラス
│       ├── EmeraldAxe.java
│       ├── EmeraldHoe.java
│       ├── EmeraldPickaxe.java
│       ├── EmeraldShovel.java
│       ├── EmeraldSword.java
│       └── EmeraldTier.java
├── regi/            # 登録システム
│   ├── ModBlocks.java
│   ├── ModItems.java
│   └── ModCreativeTabs.java
├── tabs/            # クリエイティブタブ
│   ├── LabyrinthDim1Tab.java
│   └── LabyrinthDim2Tab.java
└── main/            # メインクラス
    └── Labyrinth.java
```

## 🔧 現在実装済みの機能

### ブロック
- **Orichalcum Ore** (`orichalcum_ore`)
  - 硬度: 3.0f（ダイヤモンド鉱石と同等）
  - 必要ツール: 鉄以上のツルハシ
  - ドロップ: Basic Ingot
  - 経験値: 3-7

### アイテム
#### インゴット
- **Basic Ingot** (`basic_ingot`)
- **Fire Resistant Ingot** (`fire_resistant_ingot`)
- **Durable Ingot** (`durable_ingot`)

#### ツール (エメラルド)
- **Emerald Pickaxe** (`emerald_pickaxe`)
- **Emerald Axe** (`emerald_axe`)
- **Emerald Hoe** (`emerald_hoe`)
- **Emerald Sword** (`emerald_sword`)
- **Emerald Shovel** (`emerald_shovel`)

### クリエイティブタブ
- **Labyrinth Dim 1**: 第1次元用アイテム
- **Labyrinth Dim 2**: 第2次元用アイテム

## 🚀 ビルドコマンド

```bash
# プロジェクトビルド
./gradlew build

# クライアント起動（テスト用）
./gradlew runClient

# サーバー起動（テスト用）
./gradlew runServer

# データ生成
./gradlew runData

# JARファイル作成
./gradlew jar
```

## 📝 開発メモ

### 新規ブロック追加手順
1. `blocks/`パッケージに新規ブロッククラス作成
2. `ModBlocks.java`に登録追加
3. `LabyrinthDim1Tab`または`Dim2Tab`に追加
4. リソースファイル配置:
   - `blockstates/[block_id].json`
   - `models/block/[block_id].json`
   - `models/item/[block_id].json`
   - `textures/block/[block_id].png`
5. 言語ファイル更新（`en_us.json`, `ja_jp.json`）
6. 必要に応じてloot tableとtagsを設定

### 新規アイテム追加手順
1. `items/`パッケージに新規アイテムクラス作成
2. `ModItems.java`に登録追加
3. クリエイティブタブに追加
4. リソースファイル配置:
   - `models/item/[item_id].json`
   - `textures/item/[item_id].png`
5. 言語ファイル更新

## 🎯 今後の実装予定
- [ ] 追加の鉱石ブロック
- [ ] カスタム次元の実装
- [ ] 新規ツールと武器
- [ ] 鉱石生成設定

## ⚠️ 注意事項
- コメントは最小限に（明示的な要求がある場合のみ）
- 既存のコードパターンに従う
- 拡張性を考慮した設計を心がける

## 📚 参考リンク
- [Minecraft Forge Documentation](https://docs.minecraftforge.net/)
- [Minecraft Wiki](https://minecraft.wiki/)

---
*最終更新: 2025-08-17*
*MOD名変更: OltOreSpawn → Labyrinth*