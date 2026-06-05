# Pixel Card UI Design Spec

この文書は、タイトル/ゲーム選択画面とゲーム内UIを、提示スクリーンショットの方向性に合わせて作り直すための開発仕様です。

対象スクリーンショットの印象:

- 暗い緑のカードテーブル背景
- 金色のピクセル装飾
- クリーム色の紙カード風パネル
- 選択中ゲームだけ深緑と金枠で強調
- レトロなピクセルアート、ただしUI構造は読みやすい
- ゲーム一覧、統計、カードデザイン選択、設定/終了が同じ画面で完結

## Goal

初めて見る人が「どのゲームを選ぶか」「今の設定は何か」「どこから開始するか」を一目で理解できる画面にする。

Shengji / Tractor のゲーム中画面も、同じビジュアル言語に合わせる。

## Scope

### Phase A: Game Hub Redesign

最初に実装する対象。

- `scripts/app/game_hub.gd`
- `scripts/app/game_config.gd`
- 必要なら `resources/themes/`
- 必要なら `assets/common/ui/`

### Phase B: Shengji Table Redesign

Phase A の後で実装する対象。

- `scripts/games/shengji/ui/ui_manager.gd`
- `scripts/games/shengji/ui/bidding_ui.gd`
- `scripts/games/shengji/ui/game_over_ui.gd`
- `scripts/games/shengji/table/shengji_table_layout.gd`
- `scripts/games/shengji/player/player.gd`

## Visual Direction

### Style Keywords

- Pixel card lounge
- Dark felt table
- Antique gold
- Paper playing cards
- Decorative but readable
- Retro UI with modern layout discipline

### Do Not Use

- Large modern flat panels with plain blue/gray styling
- Generic rounded SaaS cards
- Heavy gradients
- Purple/blue neon styling
- Floating transparent boxes without visual relationship to the table
- Decorative elements that block card readability

## Color Palette

Use these as base colors.

```text
Background felt:     #071D17
Felt shadow:         #03100D
Panel dark green:    #0E3327
Panel green light:   #164A38
Gold primary:        #F1C45A
Gold dark:           #9B6A25
Gold shadow:         #5D3A14
Paper card:          #F1E7CB
Paper card shadow:   #B8A982
Ink dark:            #2A2419
Muted text:          #B8B4A5
Red accent:          #B64A35
Blue accent:         #21445A
Disabled gray:       #8B8778
```

Color usage:

- Page background is always dark felt.
- Primary actions use gold.
- Selected game uses dark green + gold border.
- Unselected games use paper card panels.
- Settings button can use blue accent.
- Quit button can use red accent.

## Typography

Godot fallback fonts are acceptable at first, but the UI should mimic pixel typography through sizing, color, and spacing.

Recommended:

- Title: 42-56 px, gold, high contrast.
- Section labels / stat labels: 16-20 px, muted text or gold.
- Game card title: 26-34 px.
- Body text: 17-22 px.
- Buttons: 22-30 px.

Rules:

- Do not use viewport-scaled font sizes.
- Keep letter spacing at default.
- Do not use tiny text inside important game cards.
- Button labels must fit in English, Japanese, and Chinese.

## Layout: Game Hub

Base target: `1600 x 900`.

Responsive rule:

- Minimum useful size: `1280 x 720`.
- The main content should stay centered.
- Decorative corner cards can move/crop at smaller sizes.
- Game cards must remain fully readable.

### Main Structure

```text
Full screen dark felt background
  Decorative corner assets
  Header
    App title
    Subtitle
    Stats row
  Game card row
    Shengji selected card
    Hearts card
    Bridge card
    Poker card
  Card design selector
  Footer buttons
    Settings
    Quit
```

### Header

Position:

- Top center.
- Title around y=36-84.
- Subtitle below title.
- Stats row below subtitle.

Content:

```text
世界纸牌游戏 / World Card Games / 世界のカードゲーム
局数 / Plays
胜场 / Wins
胜率 / Win Rate
```

Stats should be compact, not boxed heavily.

### Decorative Corners

Use pixel card/deck illustrations:

- Top left: stacked deck.
- Top right: fanned cards.
- Bottom right: large deck/fan.
- Optional small suit icons in corners.

Implementation options:

1. Use generated PNG assets in `assets/common/ui/pixel_hub/`.
2. Use simple pixel-style drawn `TextureRect`s once assets exist.
3. Temporarily omit complex decorations if assets are missing, but reserve layout space.

Do not implement decorations as complex gameplay cards. They are background art.

### Game Cards

There are 4 main cards.

Selected Shengji card:

- Width: 320-360 px at 1600 width.
- Height: 520-560 px.
- Background: dark green.
- Border: thick gold, 3-5 px.
- Inner decorative corner lines.
- Title in gold.
- Suit icons above title.
- Card fan illustration.
- Metadata: `4 players · 2 teams`.
- Description line.
- Deck mode selector: `x2` and `x4`.
- Primary button: gold `Start`.
- Help button: small text/icon button `How to Play`.

Unselected cards:

- Width: 300-330 px.
- Height: 470-510 px.
- Background: paper card.
- Border: beige/dark paper.
- Title in suit color.
- Game illustration.
- Metadata and description.
- Disabled button: `Coming Soon`.

Spacing:

- Selected card can be slightly lower or larger.
- Cards should form a clean horizontal row.
- Avoid overlapping decorative corners.

### Card Illustration Inside Cards

Each game card should show a small fan of 4-5 cards.

For future work, place these under:

```text
assets/common/ui/game_cards/
  shengji_preview.png
  hearts_preview.png
  bridge_preview.png
  poker_preview.png
```

Until assets are available, use existing card sprites from the active card set.

### Card Design Selector

Position:

- Below game cards, centered.

Content:

```text
Card Design   [Classic] [Illustrated] ...
```

Behavior:

- Must read from `GameConfig.get_card_style_ids()`.
- If a complete card style folder is added under `assets/common/card_sets/`, it should appear automatically.
- Active style uses gold border and dark green fill.
- Inactive style uses dark fill and muted text.

This should stay on the main hub, not inside Settings.

### Footer Buttons

Position:

- Bottom center.

Buttons:

- Settings: blue/dark panel with gear icon.
- Quit: red/dark panel with exit icon.

Buttons should feel physical, with pixel border and shadow.

## Layout: Shengji Game Screen

The gameplay screen should keep the same dark felt/gold/paper language, but prioritize card readability.

### Table

- Background: dark felt, same as hub.
- Optional subtle texture.
- No large opaque rectangle behind hand cards.
- Play area can be suggested by a faint inner border only if it does not make the screen ugly.

### HUD

Top left:

- Compact score plaque.
- Current level.
- Mode: Easy/Hard.
- Trump suit.
- Team scores.

Top center:

- Current turn message.
- Auto width by message length.

Top right:

- Previous trick button.

Player plaques:

- Use Player 1/2/3/4 labels.
- Use team color but keep consistent pixel plaque style.
- Do not use Left/Right/Opposite as primary labels.

### Action Area

Bottom center:

- Primary button: `Play Selected`.
- Bury phase button: `Confirm Bury`.
- Hint text under button.
- Selected count above button during bury phase only.

Do not add thick selection frames around cards.

### Card Selection

Use:

- Raised card position.
- Very subtle glow or shadow.
- Optional small hint dot above rank/suit area.

Do not use:

- Large yellow rectangle around selected cards.
- Dark background strip behind hand cards.
- Wide hit overlays visible to the player.

## Component Style Rules

### Pixel Panel Style

Panel style should have:

- 1-3 px border.
- Dark outer shadow.
- Gold or paper border depending on context.
- Corner decorations can be drawn as separate `ColorRect`s or small `TextureRect`s.

Avoid very large rounded corners. Use 0-6 px radius at most.

### Buttons

Primary:

- Gold fill.
- Dark text.
- Strong border/shadow.

Secondary:

- Dark green/blue fill.
- Gold or muted border.

Disabled:

- Paper gray or muted dark.
- Still readable.

## Localization Requirements

Every visible label must use `GameConfig.text(...)`.

Required text keys if missing:

```text
card_design
card_style_default
card_style_minimal
card_style_illustrated
settings
quit
play_game
how_to_play
coming_soon
plays
wins
win_rate
```

For Shengji:

```text
play
confirm_bury
previous_trick
current_level
game_mode
trump_suit
team_a
team_b
player_name
```

Do not hardcode Chinese/Japanese/English strings in UI files.

## Asset Plan

Preferred structure:

```text
assets/common/ui/
  pixel_hub/
    bg_felt.png
    corner_deck_left.png
    corner_cards_right.png
    corner_deck_bottom_right.png
    gold_sparkle.png
    suit_spade.png
    suit_heart.png
    suit_club.png
    suit_diamond.png
  game_cards/
    shengji_preview.png
    hearts_preview.png
    bridge_preview.png
    poker_preview.png
```

If these assets do not exist yet:

- Create the UI structure with placeholder panels.
- Keep asset loading optional.
- Do not block implementation on artwork.

## Implementation Notes

### Recommended Refactor

Split `game_hub.gd` into helper methods, not separate classes yet.

Suggested helper methods:

```gdscript
create_background()
create_header()
create_stats_row()
create_game_card(game_data, index, selected)
create_card_preview(game_data, selected)
create_deck_mode_toggle(parent)
create_card_style_selector()
create_footer_buttons()
make_pixel_panel_style(...)
make_pixel_button_style(...)
```

This keeps the current dynamic scene construction pattern.

### Existing Behaviors To Preserve

- Settings overlay still opens.
- Help screen still opens.
- Shengji start button still opens `res://scenes/shengji/main.tscn`.
- Card design selector still calls `GameConfig.set_card_style(style_id)`.
- Language changes still refresh visible text.
- New complete card style folders still appear automatically.

## Verification Checklist

### Visual

- At `1600 x 900`, layout matches screenshot direction.
- At `1280 x 720`, no text overlaps or clipped buttons.
- Selected game is clearly the active game.
- Coming soon games are visibly disabled.
- Card design selector is visible on the main screen.
- Settings and Quit are easy to find.

### Functional

- Start launches Shengji.
- How to Play opens help screen.
- Settings opens settings overlay.
- Quit exits.
- Card design selector changes active card style.
- English/Japanese/Chinese labels update correctly.

### Godot Checks

Run:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . res://scenes/title.tscn --quit-after 1
```

The `--quit-after 1` scene check may produce resource cleanup warnings because the app is force-closed quickly. Treat parse/load errors as blockers; treat cleanup warnings separately.

## Acceptance Criteria

The redesign is acceptable when:

- The hub immediately communicates "world card games" and "card table" without reading long text.
- Shengji is clearly playable and selected.
- Unavailable games look intentional, not broken.
- The card design selector is understandable on the main screen.
- The visual style is consistent with the screenshot: dark felt, gold, paper cards, pixel card lounge.
- UI remains readable in all three supported languages.
