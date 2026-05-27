# Folder Structure

この文書は、プロジェクトのフォルダー構成と「どこに何を置くか」を説明します。AIに作業を任せる場合は、最初に `docs/AI_EDITING_MAP.md` とこの文書を確認します。

## Top Level

```text
assets/
docs/
resources/
scenes/
scripts/
project.godot
```

- `assets/`: 画像、音声、動画などの素材ファイル。
- `docs/`: AI作業ルール、構成説明、検証手順。
- `resources/`: Godot Resource や設定データ。テーマ、テーブルスタイル、カードスタイルなど。
- `scenes/`: Godot の `.tscn` シーン。
- `scripts/`: GDScript。アプリ全体、共通処理、ゲーム固有処理に分ける。
- `project.godot`: Godot プロジェクト設定、autoload、メインシーン設定。

## Scripts

```text
scripts/
  app/
  common/
    audio/
    cards/
    deck/
  customization/
  games/
    shengji/
      ai/
      flow/
      player/
      rules/
      table/
      ui/
```

### `scripts/app/`

アプリ全体に関わる処理を置きます。

- `game_config.gd`: グローバル設定、多言語テキスト、プレイ統計。
- `game_hub.gd`: ゲーム選択ハブ。
- `settings_screen.gd`: 設定画面。
- `help_screen.gd`: 遊び方画面。

ゲーム固有のルールや進行処理はここに置きません。

### `scripts/common/`

複数ゲームで再利用できる共通処理を置きます。

- `audio/`: 共通サウンド管理。
- `cards/`: 共通カード表示、クリック、選択、移動。
- `deck/`: 共通デッキ生成、シャッフル、配札。

Shengji 固有の切り札、入札、得点、AI判断はここに置きません。

### `scripts/customization/`

将来のユーザーカスタマイズ機能を置きます。

想定する責務:

- 現在選択中のテーマ、テーブルスタイル、カードスタイルを管理する。
- 設定画面から変更されたカスタマイズ内容を保存・読み込みする。
- `resources/` のスタイルデータを読み込んで、UIやテーブルへ渡す。

ゲーム固有の見た目に依存する処理は、必要に応じて `scripts/games/<game>/` 側へ渡します。

### `scripts/games/shengji/`

Shengji / Tractor 固有の処理を置きます。

- `main.gd`: Shengji シーンの組み立て。
- `flow/`: 配札、入札進行、底札、ターン、ラウンド進行。
- `rules/`: 手役、フォロー、切り札、入札可否、得点、ゲーム終了判定。
- `ai/`: AIのカード評価、候補選択、出し方判断。
- `player/`: プレイヤーの手札、選択、手札レイアウト。
- `table/`: テーブル上のプレイヤー位置、出牌位置、将来のテーブル表示制御。
- `ui/`: HUD、入札UI、ゲーム終了UI、操作ボタン、メッセージ表示。

## Resources

```text
resources/
  card_styles/
    default/
    large_index/
  table_styles/
  themes/
  ui_layouts/
  user_profiles/
```

### `resources/themes/`

アプリ全体やUIのテーマデータを置きます。

例:

- フォント
- 基本色
- ボタンスタイル
- パネルスタイル

### `resources/table_styles/`

テーブルの見た目データを置きます。

例:

- テーブル背景色
- フェルト風テクスチャ
- 枠線色
- プレイヤー座席の表示スタイル
- 出牌エリアの見た目

### `resources/card_styles/`

カード見た目のスタイルデータや差し替えセットを置きます。

例:

- 標準カード
- 大きいインデックス
- 高コントラストカード
- 代替カード画像セット

### `resources/ui_layouts/`

UIレイアウトの設定データを置きます。

例:

- HUD位置プリセット
- 操作ボタン位置
- スコア表示の密度
- モバイル向け配置

### `resources/user_profiles/`

将来、ユーザー別プリセットやローカル保存用の初期データを置きます。

実際のユーザー保存データは、Godot の `user://` へ保存する方針にします。リポジトリには初期プリセットだけを置きます。

## Assets

```text
assets/
  common/
    audio/
    cards/
    videos/
  games/
    shengji/
```

- `assets/common/`: 複数ゲームで使う素材。
- `assets/games/<game>/`: 特定ゲームだけで使う素材。

設定データは `resources/`、実素材は `assets/` に置きます。

## Scenes

```text
scenes/
  title.tscn
  shengji/
    main.tscn
```

- `title.tscn`: アプリ入口。
- `shengji/main.tscn`: Shengji の入口。

## Customization Policy

ユーザーがカスタマイズできる項目は、できるだけコードに直書きせず `resources/` のデータとして持ちます。

推奨する流れ:

```text
settings_screen.gd
  -> customization_manager.gd
    -> resources/themes/
    -> resources/table_styles/
    -> resources/card_styles/
    -> resources/ui_layouts/
      -> game UI / table / card display
```

カスタマイズ機能を追加するときは、まず `scripts/customization/` と `resources/` に責務を分けます。Shengji 固有の反映処理だけ `scripts/games/shengji/` に置きます。

