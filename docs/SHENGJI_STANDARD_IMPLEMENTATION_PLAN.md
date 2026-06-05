# Shengji Standard Implementation Plan

この文書は、決定済みの Standard ルールを現在の Godot 実装へ反映するための作業計画です。
実装前にこの順番で進め、各段階でゲームが壊れていないことを確認します。

## Goal

Shengji / Tractor を Standard ルール寄りに整える。

- 2 decks = Easy mode
- 4 decks = Hard mode
- どちらも正式対応
- ルール判定、UI、おすすめカード、AI判断を同じルールエンジンに寄せる

## Decided Rules

- 叫牌は1枚から可能。
- より多い枚数なら他プレイヤーが上書き可能。
- 同じチームも上書き可能。
- Joker 叫牌あり。
- Joker 叫牌は No Trump round。
- No Trump では level cards と jokers だけが trump。
- 叫牌は配牌中と配牌後の最終機会で可能。
- 通常 trump 強さは Big Joker > Small Joker > trump-suit level card > other level cards > regular trump-suit cards。
- No Trump では4花色の level card は同じ強さ。
- Tractor は現在レベルを飛ばして連続扱いにする。
- Joker pair は Tractor に含めない。
- Easy mode は Pair Tractor のみ。
- Hard mode は Pair / Triple / Quadruple Tractor を許可。
- Throw は正式採用。
- Throw が失敗した場合、出せる一番小さい有効構造を強制的に出す。
- Pair があれば必ず Pair でフォローする。
- Tractor があれば必ず Tractor でフォローする。
- Tractor がない場合、持っている Pair をできるだけ出す。
- 同じ構造だけがトリックに勝てる。
- Easy mode の底牌は8枚。
- Hard mode の底牌は12枚。
- 底牌倍率は構造ベース。
- AI は最初から強い判断を目指す。

## Phase 1: Rule Model Cleanup

Status: Implemented.

目的: ルールの状態をコード上で明確にする。

### Target Files

- `scripts/app/game_config.gd`
- `scripts/games/shengji/flow/game_manager.gd`
- `scripts/games/shengji/rules/shengji_card_logic.gd`
- `scripts/games/shengji/rules/game_rules.gd`

### Tasks

1. Easy / Hard mode をルール上の正式な mode として扱う。
2. デック数から mode を取得できるようにする。
3. 底牌枚数を mode から取得する。
4. trump suit に No Trump 状態を表せる値を追加する。
5. trump 判定を `trump_suit == no_trump` に対応させる。

### Verification

- 2デックでは底牌8枚。
- 4デックでは底牌12枚。
- No Trump では通常花色が trump にならない。
- level card と Joker は No Trump でも trump になる。

## Phase 2: Bidding

Status: Implemented.

目的: 決定済みの叫牌ルールを実装する。

### Target Files

- `scripts/games/shengji/rules/shengji_bidding_rules.gd`
- `scripts/games/shengji/flow/game_manager.gd`
- `scripts/games/shengji/ui/bidding_panel.gd`
- `scripts/games/shengji/ai/shengji_ai_logic.gd`

### Tasks

1. 通常花色は1枚から叫牌可能にする。
2. Joker 叫牌を追加する。
3. Joker 叫牌を No Trump として扱う。
4. 同じチームでも、枚数が多ければ上書き可能にする。
5. 配牌中と配牌後の最終叫牌を維持する。
6. UIに No Trump / Joker bid を表示する。
7. AI が Joker bid と上書きを判断できるようにする。

### Verification

- 1枚の level card で叫牌できる。
- より多い枚数で上書きできる。
- 同じチームも上書きできる。
- Joker bid で No Trump になる。
- No Trump 表示がUIに出る。

## Phase 3: Pattern Detection

Status: Implemented.

目的: Single / Pair / Triple / Quadruple / Tractor / Throw を正しく識別する。

### Target Files

- `scripts/games/shengji/rules/game_rules.gd`
- `scripts/games/shengji/rules/shengji_card_logic.gd`

### Tasks

1. Pattern model を拡張する。
2. Pair だけでなく Triple / Quadruple を表せるようにする。
3. Easy mode では Pair Tractor のみ許可する。
4. Hard mode では Triple / Quadruple Tractor を許可する。
5. Tractor の連続判定で現在レベルを飛ばす。
6. Joker pair を Tractor から除外する。
7. No Trump 時の level card 同士を同じ強さとして扱う。

### Verification

- Easy mode で Triple / Quadruple Tractor が無効。
- Hard mode で Triple / Quadruple Tractor が有効。
- Joker pair を含む Tractor が無効。
- Level 5 で 4-4 + 6-6 が Tractor になる。

## Phase 4: Follow Obligations

Status: Implemented.

目的: Standard のフォロー義務を実装する。

### Target Files

- `scripts/games/shengji/rules/game_rules.gd`
- `scripts/games/shengji/flow/game_manager.gd`
- `scripts/games/shengji/ai/shengji_ai_logic.gd`

### Tasks

1. リード構造を詳細に保存する。
2. Single フォローを維持する。
3. Pair があれば Pair フォローを強制する。
4. Tractor があれば Tractor フォローを強制する。
5. Tractor がない場合、Pair をできるだけ出すようにする。
6. Pair も足りない場合、同じ種類のカードを可能な限り出す。
7. 残り枚数だけ任意カードで補う。
8. 人間プレイヤーの不正選択を拒否する。
9. AI とおすすめカードも同じフォロー判定を使う。

### Verification

- Pair を持っているのに Single 2枚で逃げられない。
- Tractor を持っているのに Pairだけで逃げられない。
- Tractor がない時は Pair をできるだけ出す。
- AI が不正フォローをしない。

## Phase 5: Throw

Status: Implemented.

目的: Throw / 甩牌を正式実装する。

### Target Files

- `scripts/games/shengji/rules/game_rules.gd`
- `scripts/games/shengji/flow/game_manager.gd`
- `scripts/games/shengji/ui/hand_ui.gd`
- `scripts/games/shengji/ai/shengji_ai_logic.gd`

### Tasks

1. Throw を複数の component に分解する。
2. 各 component が Single / Pair / Triple / Quadruple / Tractor のどれかを判定する。
3. 相手が同じ種類で上回れる component を持っているか判定する。
4. 全 component が安全なら Throw 成立。
5. 失敗した場合、選択カード内の一番小さい有効構造を強制的に出す。
6. UIに Throw 失敗メッセージを表示する。
7. AI が成功する Throw を選び、失敗Throwを避けるようにする。

### Verification

- 成立する Throw は出せる。
- 相手が上回れる component がある Throw は失敗する。
- 失敗時に最小構造だけが出される。
- UIが理由を表示する。

## Phase 6: Trick Comparison

Status: Implemented.

目的: 同じ構造だけが勝てる比較に変更する。

### Target Files

- `scripts/games/shengji/rules/game_rules.gd`

### Tasks

1. リード構造と違う構造は勝てないようにする。
2. 同じ構造の場合だけ強さを比較する。
3. Trump は non-trump に勝つ。
4. Non-trump の別花色はリードに勝てない。
5. No Trump 時の level card 同士は同じ強さとして扱う。
6. Throw 成立時の勝敗を component 構造に基づいて比較する。

### Verification

- Pair リードに Single 2枚では勝てない。
- Tractor リードに Pairだけでは勝てない。
- Trump 構造なら non-trump 構造に勝てる。

## Phase 7: Bottom Cards And Multiplier

Status: Implemented.

目的: 底牌枚数と倍率を Standard ルールへ変更する。

### Target Files

- `scripts/games/shengji/flow/game_manager.gd`
- `scripts/games/shengji/rules/shengji_scoring.gd`
- `scripts/games/shengji/ui/bury_panel.gd`

### Tasks

1. Easy mode の底牌を8枚にする。
2. Hard mode の底牌を12枚にする。
3. 埋底UIが必要枚数に応じて変わるようにする。
4. 底牌倍率を構造ベースに変更する。
5. Single / Throw は x2。
6. Pair / Triple / Quadruple は x4。
7. Tractor は連続数に応じて x8, x16, x32 と増やす。

### Verification

- 2デックでは8枚埋底。
- 4デックでは12枚埋底。
- Pairで底を取ると x4。
- 2連 Tractorで底を取ると x8。

## Phase 8: AI Strength

Status: Implemented.

目的: AIを最初から強い判断に近づける。

### Target Files

- `scripts/games/shengji/ai/shengji_ai_logic.gd`
- `scripts/games/shengji/rules/game_rules.gd`

### Tasks

1. AI が合法手候補を全て取得できるようにする。
2. 候補を点数、勝率、手札維持、次トリックを考慮して評価する。
3. 叫牌時に手札の trump potential を評価する。
4. 埋底時に守備/攻撃の方針を考慮する。
5. Throw の成功可否を判断する。
6. おすすめカードも AI 評価と同じロジックを使う。

### Verification

- AI がルール違反をしない。
- AI が明らかに損なカードを優先しない。
- おすすめカードが合法で、意図が分かる選択になる。

## Phase 9: UI And Localization

目的: Standard ルールの表示をUIと翻訳に反映する。

Status: Implemented.

### Target Files

- `scripts/games/shengji/ui/*.gd`
- localization resources

### Tasks

1. Easy / Hard 表示を明確にする。
2. No Trump 表示を追加する。
3. Joker bid 表示を追加する。
4. Throw 失敗メッセージを追加する。
5. 埋底必要枚数を表示する。
6. 英語、日本語、中国語の表記を揃える。

### Verification

- 英語UIで未翻訳がない。
- 日本語UIで中国語が混ざらない。
- 中国語UIで英語が不自然に残らない。
- Throw失敗理由が読める。

## Recommended Order

1. Phase 1: Rule Model Cleanup
2. Phase 2: Bidding
3. Phase 3: Pattern Detection
4. Phase 4: Follow Obligations
5. Phase 6: Trick Comparison
6. Phase 7: Bottom Cards And Multiplier
7. Phase 5: Throw
8. Phase 8: AI Strength
9. Phase 9: UI And Localization

Throw は大きい変更なので、基本の構造判定とフォロー判定を先に安定させてから実装する。

## Open Technical Notes

- `game_rules.gd` は役判定、フォロー、比較の責務が重くなっているため、必要なら pattern analyzer と follow validator に分割する。
- AI とおすすめカードは、独自判定を持たずに Rule API を使う形へ寄せる。
- UIはルール判定を持たず、Rule API の結果と理由だけを表示する。
