# Project Rules

この文書は、AIまたは開発者がこのプロジェクトを修正・更新するときの基本ルールです。

## Project Identity

- プロジェクト名は `World Card Games`。
- Godot 4.6 系、GL Compatibility renderer を前提にする。
- メインシーンは `res://scenes/title.tscn`。
- 最初の画面はゲーム選択ハブで、現在の実装済みゲームは Shengji / Tractor。
- Hearts、Bridge、Poker はハブ上にあるが、現時点では準備中として扱う。

## Current Product Direction

- 複数の世界のカードゲームを同じアプリ内で遊べる構成にする。
- 共通カード表現、デッキ、サウンド、設定、多言語テキストはゲーム間で再利用する。
- 各ゲーム固有のルール、UI、進行管理は `scripts/<game_name>/` と `scenes/<game_name>/` に閉じ込める。
- 現在の主対象は Shengji / Tractor の安定化と完成度向上。

## Change Principles

- 既存の動作を確認してから編集する。
- 変更は依頼された目的に必要な最小範囲にする。
- 共通ファイルを変更するときは、他ゲームへの影響を必ず確認する。
- `project.godot` の autoload、main scene、display 設定は必要がない限り変更しない。
- `.uid`、`.import`、`.godot/` など Godot が管理するファイルは、Godot が生成した変更以外では手編集しない。
- ユーザーの未コミット変更は戻さない。

## Current Important Files

- `project.godot`: プロジェクト設定、autoload、メインシーン。
- `scenes/title.tscn`: ゲーム選択ハブの入口。
- `scenes/shengji/main.tscn`: Shengji のゲーム入口。
- `scripts/app/game_config.gd`: グローバル設定、多言語テキスト、プレイ統計。
- `scripts/app/game_hub.gd`: ゲーム選択ハブ。
- `scripts/common/cards/card.gd`: 共通カードクラス、カード表示、クリック、選択、アニメーション。
- `scripts/common/deck/deck.gd`: 共通デッキ生成、シャッフル、配札。
- `scripts/common/audio/sound_manager.gd`: 共通サウンド管理とフォールバック音。
- `scripts/games/shengji/flow/game_manager.gd`: Shengji のゲーム進行、フェーズ、配札、入札、プレイ処理。
- `scripts/games/shengji/rules/game_rules.gd`: Shengji の手役、フォロー、勝敗判定に関わるルール。
- `scripts/games/shengji/player/player.gd`: プレイヤーの手札、選択、手札表示。
- `scripts/games/shengji/ai/shengji_ai_logic.gd`: Shengji AI のカード評価と候補評価。
- `scripts/games/shengji/rules/shengji_bidding_rules.gd`: Shengji の入札可否判定。
- `scripts/games/shengji/rules/shengji_card_logic.gd`: Shengji 固有の切り札判定とカード強さ比較。
- `scripts/games/shengji/rules/shengji_scoring.gd`: Shengji の底札倍率、ラウンド結果、ゲーム終了判定。
- `scripts/games/shengji/table/shengji_table_layout.gd`: Shengji のテーブル配置計算。
- `scripts/games/shengji/ui/ui_manager.gd`: Shengji の画面UI。
- `scripts/games/shengji/ui/bidding_ui.gd`: 入札UI。
- `scripts/games/shengji/ui/game_over_ui.gd`: ゲーム終了UI。
- `scripts/customization/`: 将来のユーザーカスタマイズ機能。
- `resources/`: テーマ、テーブルスタイル、カードスタイル、UIレイアウトなどの設定データ。

## Assets

- 共通カード画像は `assets/common/cards/` を使う。
- 共通音声は `assets/common/audio/` を使う。
- ゲーム固有アセットを追加する場合は `assets/games/<game_name>/` に置く。
- UIテーマ、テーブルスタイル、カードスタイル、レイアウトプリセットは `resources/` に置く。
- 旧パス `assets/cards/` や旧共通スクリプトパスを復活させない。必要なら参照側を新パスへ直す。

## Localization

- 画面表示文字列は原則 `GameConfig.text(key)` を使う。
- 新しいUI文言を追加するときは、`en`、`ja`、`zh` の3言語に同じキーを追加する。
- 既存キー名の意味を変えない。意味が違う場合は新しいキーを作る。

## UI Rules

- 1600x900 を基本にしつつ、1280x720 以上で破綻しないレイアウトにする。
- 画面サイズ変更に対応する処理は、既存の `apply_layout()`、viewport size signal、比率計算の流れに合わせる。
- カードの重なり、クリック範囲、選択状態は `Card` と `Player` の既存ロジックを尊重する。
- UIの文字が親要素からはみ出さないように、ラベル幅、フォントサイズ、折り返しを確認する。

## Game Logic Rules

- Shengji のルール変更は `scripts/games/shengji/rules/game_rules.gd` を優先して確認する。
- Shengji のAI判断は `scripts/games/shengji/ai/shengji_ai_logic.gd` を優先して確認する。
- Shengji の入札可否は `scripts/games/shengji/rules/shengji_bidding_rules.gd` を優先して確認する。
- Shengji の切り札判定やカード強さ比較は `scripts/games/shengji/rules/shengji_card_logic.gd` に置く。
- Shengji の得点・レベル進行は `scripts/games/shengji/rules/shengji_scoring.gd` に置く。
- ゲーム進行の変更は `scripts/games/shengji/flow/game_manager.gd` のフェーズとシグナルへの影響を確認する。
- カード状態、切り札判定、点数カード判定を複数箇所に重複実装しない。
- 既存の `Card.Suit`、`Card.Rank`、`GamePhase`、`CardPattern` enum を優先して使う。

## Autoload Rules

現在の autoload:

- `GameConfig`: `res://scripts/app/game_config.gd`
- `SoundManager`: `res://scripts/common/audio/sound_manager.gd`

autoload を増やすのは、複数シーン・複数ゲームで本当に共有する状態やサービスがある場合だけにする。
