# Architecture

この文書は、現在のプロジェクト構造と、今後の追加・修正で守るべき境界をまとめたものです。

## High Level Flow

```text
project.godot
  -> scenes/title.tscn
    -> scripts/app/game_hub.gd
      -> scenes/shengji/main.tscn
        -> scripts/games/shengji/main.gd
          -> UIManager
          -> GameManager
          -> Player nodes
          -> Card nodes
```

## Directory Layout

```text
assets/
  common/
    cards/
    audio/
    videos/
  games/

scenes/
  title.tscn
  shengji/
    main.tscn

scripts/
  app/
    game_config.gd
    game_hub.gd
    help_screen.gd
    settings_screen.gd
  common/
    audio/
      sound_manager.gd
    cards/
      card.gd
    deck/
      deck.gd
  games/
    shengji/
      main.gd
      ai/
        shengji_ai_logic.gd
      flow/
        game_manager.gd
      player/
        player.gd
      rules/
        game_rules.gd
        shengji_bidding_rules.gd
        shengji_card_logic.gd
        shengji_scoring.gd
      table/
        shengji_table_layout.gd
      ui/
        bidding_ui.gd
        game_over_ui.gd
        ui_manager.gd
```

## Ownership Boundaries

### Common Layer

`scripts/common/` はゲームをまたいで使う層です。

- `cards/card.gd`: カードのデータ、表示、クリック、ホバー、選択、移動、表裏表示。
- `deck/deck.gd`: デッキ生成、シャッフル、配札。
- `audio/sound_manager.gd`: 効果音再生、音声ファイルがない場合のフォールバック音。

共通層に特定ゲームのルールを入れないでください。Shengji 固有の切り札・フォロー・トラクター判定は `scripts/games/shengji/` に置きます。

### App Layer

`scripts/app/game_config.gd` と `scripts/app/game_hub.gd` はアプリ全体の層です。

- `GameConfig` は設定、言語、統計、グローバルテキストを持つ。
- `game_hub.gd` はゲーム一覧、利用可能状態、ゲーム起動、設定/ヘルプ表示を扱う。

ゲーム固有の進行状態を `GameConfig` に入れないでください。永続化が必要な場合も、まず保存仕様を決めてから追加します。

### Shengji Layer

`scripts/games/shengji/` は Shengji / Tractor 固有の層です。

- `main.gd`: Shengji シーンの組み立て、UIManager と GameManager の接続。
- `flow/game_manager.gd`: フェーズ、配札、入札、底札、ターン、ラウンド進行。
- `rules/game_rules.gd`: ルール判定、手役判定、フォロー可否、有効手の探索。
- `rules/shengji_bidding_rules.gd`: 入札可否の判定。
- `rules/shengji_card_logic.gd`: Shengji 固有の切り札判定とカード強さ比較。
- `rules/shengji_scoring.gd`: 底札倍率、ラウンド結果、ゲーム終了判定。
- `ai/shengji_ai_logic.gd`: AIのカード評価、候補評価、候補リスト補助。
- `player/player.gd`: プレイヤー状態、手札、カード選択、手札レイアウト。
- `table/shengji_table_layout.gd`: Shengji テーブル上のプレイヤー位置と出牌位置。
- `ui/ui_manager.gd`: HUD、操作ボタン、メッセージ、スコア表示。
- `ui/bidding_ui.gd`: 入札UI。
- `ui/game_over_ui.gd`: 終了UI。

## Scene Construction Pattern

現在の Shengji は、`.tscn` にすべてのUIを固定配置するより、`main.gd` が `UIManager` と `GameManager` を動的に作る構成です。

この構成で作業する場合:

- 既存の動的生成パターンに合わせる。
- ノード名を参照している箇所を変更するときは `has_node()` / `get_node()` の利用箇所を確認する。
- シグナル接続は `main.gd` の接続関係を壊さない。

## Signal Relationships

主な接続:

- `GameConfig.language_changed` -> ハブ、Shengji main、UI更新系。
- `GameConfig.play_hints_changed` -> Shengji game manager。
- `UIManager.play_cards_pressed` -> `GameManager._on_play_cards_pressed`
- `UIManager.bury_cards_pressed` -> `GameManager._on_bury_cards_pressed`
- `BiddingUI.bid_made` -> `GameManager._on_player_bid_made`
- `BiddingUI.bid_passed` -> `GameManager._on_player_bid_passed`
- `GameOverUI.restart_game` -> `GameManager.restart_game`
- `GameOverUI.quit_game` -> `main.gd` quit handler
- `Player.selection_changed` -> UI selected count update

シグナル名や引数を変更する場合は、接続元と接続先を同時に確認してください。

## Adding A New Game

新ゲーム追加時の基本手順:

1. `scenes/<game_name>/main.tscn` を作る。
2. `scripts/games/<game_name>/` に `main.gd`、必要な `flow/`、`rules/`、`ai/`、`player/`、`table/`、`ui/` を作る。
3. 共通カード・デッキを使える場合は `scripts/common/` を再利用する。
4. `scripts/app/game_config.gd` に表示テキストを3言語で追加する。
5. `scripts/app/game_hub.gd` の `GAMES` に項目を追加または有効化する。
6. ゲーム固有アセットは `assets/games/<game_name>/` に置く。

## Do Not Mix These Responsibilities

- UI表示文言: `GameConfig` のテキストキー。
- カードの基本表示とクリック: `Card`。
- デッキ生成: `Deck`。
- Shengji のAIカード評価: `ShengjiAiLogic`。
- Shengji の入札可否判定: `ShengjiBiddingRules`。
- Shengji 固有の切り札判定とカード比較: `ShengjiCardLogic`。
- Shengji ルール判定: `GameRules`。
- Shengji の得点・レベル進行: `ShengjiScoring`。
- Shengji のテーブル配置計算: `ShengjiTableLayout`。
- Shengji の進行状態: `GameManager`。
- プレイヤーの手札と選択: `Player`。
- 画面上のHUDとボタン: `UIManager` / 専用UIクラス。
