# AI Editing Map

この文書は、AIが依頼内容から最初に確認する場所を決めるための対応表です。

## App-Wide Requests

- ゲーム一覧、タイトル画面、ゲーム起動: `scripts/app/game_hub.gd`
- 設定、言語、共通テキスト、プレイ統計: `scripts/app/game_config.gd`
- 設定画面: `scripts/app/settings_screen.gd`
- 遊び方画面: `scripts/app/help_screen.gd`
- 起動シーン、autoload、表示設定: `project.godot`

## Shared Systems

- カードの見た目、クリック、ホバー、選択、移動、表裏表示: `scripts/common/cards/card.gd`
- デッキ生成、シャッフル、任意枚数の配札: `scripts/common/deck/deck.gd`
- 効果音、音声フォールバック: `scripts/common/audio/sound_manager.gd`
- 共通カード画像: `assets/common/cards/`
- 共通音声: `assets/common/audio/`

共通層には、Shengji 固有ルール、入札、得点、AI判断を入れない。

## Shengji Requests

- シーン開始、UIとゲーム進行の接続: `scripts/games/shengji/main.gd`
- フェーズ進行、配札、底札、ターン進行、ラウンド進行: `scripts/games/shengji/flow/game_manager.gd`
- 手役、フォロー、トラクター、有効手、勝敗比較: `scripts/games/shengji/rules/game_rules.gd`
- 入札できるかどうか: `scripts/games/shengji/rules/shengji_bidding_rules.gd`
- 切り札判定、カード強さ比較: `scripts/games/shengji/rules/shengji_card_logic.gd`
- 得点、底札倍率、レベル進行、ゲーム終了判定: `scripts/games/shengji/rules/shengji_scoring.gd`
- AIのカード評価、出すカード候補、候補スコア: `scripts/games/shengji/ai/shengji_ai_logic.gd`
- プレイヤー手札、カード選択、手札レイアウト: `scripts/games/shengji/player/player.gd`
- テーブル上のプレイヤー位置、出牌位置: `scripts/games/shengji/table/shengji_table_layout.gd`
- HUD、スコア、操作ボタン、中央メッセージ: `scripts/games/shengji/ui/ui_manager.gd`
- 入札UI: `scripts/games/shengji/ui/bidding_ui.gd`
- ゲーム終了UI: `scripts/games/shengji/ui/game_over_ui.gd`

## Common Request Routing

- 「カードをクリックできない」: `card.gd` と `player.gd`
- 「手札が重なる、はみ出る」: `player.gd`、必要なら `card.gd`
- 「切り札の強さがおかしい」: `shengji_card_logic.gd`
- 「フォロー判定がおかしい」: `game_rules.gd`
- 「トラクター判定がおかしい」: `game_rules.gd`
- 「入札できる/できない条件がおかしい」: `shengji_bidding_rules.gd`
- 「AIの出し方がおかしい」: `shengji_ai_logic.gd` と `game_manager.gd` の AI 呼び出し部分
- 「得点やレベルアップがおかしい」: `shengji_scoring.gd`
- 「プレイヤーや出牌位置がおかしい」: `shengji_table_layout.gd`
- 「ボタンやメッセージ表示がおかしい」: `ui_manager.gd`
- 「翻訳や表示文言がおかしい」: `game_config.gd`

## Editing Rule

AIは最初にこの文書で対象領域を決め、次に `PROJECT_RULES.md` と `ARCHITECTURE.md` で責務境界を確認する。依頼対象が複数領域にまたがる場合は、変更前に影響範囲を整理する。

