# Shengji Table UI Redesign Spec

この文書は、Shengji / Tractor のゲーム進行画面を、ピクセルカードラウンジ風に作り直すための実装仕様です。

対象は現在の対局画面スクリーンショットです。

## Current Problems

- 背景が単色に近く、カードテーブルとしての雰囲気が弱い。
- 画面中央の空白が広すぎて、ゲームの進行状況が分かりにくい。
- HUD、ターン表示、プレイヤー札、操作ボタンのデザインが統一されていない。
- 情報パネルが青系で、ゲーム選択画面のピクセルカード風デザインと繋がっていない。
- プレイヤー札が小さく、誰が何チームかは分かるが、カードゲームの卓上UIとして弱い。
- 操作ボタンが無効状態で暗く見えすぎ、押せる/押せない理由が伝わりにくい。

## Design Goal

ゲーム選択画面と同じ世界観で、対局中も「暗いフェルトのカードテーブル」「金色のピクセル装飾」「紙/札風のUI」として見えるようにする。

優先順位:

1. カードの読みやすさを最優先する。
2. 現在のフェーズ、親/切り札/点数をすぐ読めるようにする。
3. プレイヤー位置を直感的に見せる。
4. 操作ボタンをカードゲームらしい物理ボタンにする。
5. 装飾はカードや操作を邪魔しない。

## Visual Language

Use the same palette as `PIXEL_CARD_UI_DESIGN_SPEC.md`.

```text
Background felt:   #071D17
Felt shadow:       #03100D
Panel dark green:  #0E3327
Gold primary:      #F1C45A
Gold dark:         #9B6A25
Paper card:        #F1E7CB
Ink dark:          #2A2419
Muted text:        #B8B4A5
Red team:          #E15645
Green team:        #5BD47A
Cyan hint:         #74DCE8
```

## Layout

Base target: `1600 x 900`.

Responsive minimum: `1280 x 720`.

### Screen Regions

```text
Top left       Round status plaque
Top center     Turn / phase banner
Top right      Previous trick button
Center         Felt play area, subtle decorative frame
Left side      Player 2 plaque
Top center     Player 3 plaque
Right side     Player 4 plaque
Bottom center  Player 1 hand cards
Bottom center  Action button + hint
```

## Background Table

Implementation target:

- `scripts/games/shengji/main.gd`

Rules:

- Background color uses dark felt.
- Add subtle grid/cloth texture using thin low-alpha `ColorRect`s.
- Add faint gold border around the viewport or table edge.
- Add small suit decorations in corners only if they do not overlap cards.

Do not create a large dark panel behind the hand cards.

## HUD

Implementation target:

- `scripts/games/shengji/ui/ui_manager.gd`

### Round Status Plaque

Position: top left.

Content:

- Current Level
- Mode
- Trump Suit
- Team A score
- Team B score

Style:

- Dark green plaque.
- Gold 2 px border.
- Pixel-like hard corners: 4 px radius or less.
- Gold heading, muted mode, cyan trump, team colors.
- Inner divider line before scores.

### Turn Banner

Position: top center.

Style:

- Auto width by message length.
- Minimum width around 520 px.
- Maximum width around 760 px.
- Dark green/paper hybrid plaque with gold border.
- Text centered, large enough to read.

### Previous Trick

Position: top right.

Style:

- Small gold outlined button.
- Opens a paper/dark panel below it.

## Player Plaques

Player labels must use `Player 2`, `Player 3`, `Player 4`, not `Left/Right/Opposite`.

Style:

- Dark green plaque.
- Gold border.
- Active player gets stronger glow, not large scaling.
- Team A uses green text.
- Team B uses red text.
- Card count uses a small gold card icon or `🂠`.

Sizes:

```text
Player 2 / 4: 150 x 66
Player 3:     160 x 70
```

Positions:

- Player 3: top center under turn banner.
- Player 2: left mid table.
- Player 4: right mid table.
- Player 1 plaque remains hidden unless needed; the hand itself represents Player 1.

## Play Area

Center of table:

- Add a very faint gold frame or corner markers.
- Must not cover played cards.
- No large opaque center rectangle.

Use alpha below `0.18`.

## Action Area

Position: bottom center, below hand cards.

Primary button:

- Gold fill.
- Dark text.
- Pixel border and shadow.
- Width around 220-260 px.
- Height around 52 px.

Disabled button:

- Muted gold, still readable.
- Do not make it disappear into the background.

Hint text:

- Cyan/muted text under the button.
- One short sentence.

Bury selected count:

- Appears above the action button only during bury phase.
- Uses gold or green when exact count is reached.

## Center Messages

Center messages should feel like table notifications.

Style:

- Auto width by text.
- Dark green panel.
- Gold border.
- Gold text.
- Wrap if long.
- Centered in visible table region.

## Bidding UI

Implementation target:

- `scripts/games/shengji/ui/bidding_ui.gd`

Later improvement:

- Use paper card panel for bidding.
- Center it in the table.
- Gold title.
- Bid options as gold or paper buttons.

For this pass, keep existing behavior and only ensure it still centers.

## Card Interaction Rules

Do not change card click logic in this visual pass.

Keep:

- Raised selected card.
- Hint dot above card face.
- Current hand spacing behavior.

Do not add:

- Large selection rectangles.
- Background strip behind hand cards.
- Visible hitbox overlays.

## Implementation Order

1. Add this spec.
2. Update `main.gd` background to felt + subtle texture.
3. Update `ui_manager.gd` colors, panel styles, button styles.
4. Update `ui_manager.gd` layout constants and plaque positioning.
5. Verify `main.tscn` loads.
6. Visually review at 1600x900 and 1280x720.

## Acceptance Criteria

- The screen looks like the same product as the redesigned game hub.
- Cards remain the most readable element.
- Current phase/turn is readable at the top center.
- Round level, mode, trump, and scores are readable at top left.
- Player 2/3/4 plaques are visually balanced around the table.
- No opaque hand-card background strip is introduced.
- The Play Selected button is obvious even when disabled.
- The design works in English, Japanese, and Chinese text.
