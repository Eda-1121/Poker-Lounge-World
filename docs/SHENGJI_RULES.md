# Shengji / Tractor Rules

この文書は、現在の Godot 実装に合わせた Shengji（升级 / Tractor）のルール整理です。
将来ルールを変更する場合は、先にこの文書を更新し、その後で該当スクリプトを修正します。

## Rule Direction

このゲームは、一般的な Shengji / Tractor にできるだけ近い Standard ルールを目標にする。
一時的に簡易実装が残る場合でも、最終的には正式ルールに近づける前提で整理する。

## Source Files

- `scripts/games/shengji/flow/game_manager.gd`: ラウンド進行、配牌、叫牌、埋底、プレイ、スコア計算の制御。
- `scripts/games/shengji/rules/game_rules.gd`: 役判定、フォロー可否、トリック勝敗、カード点数集計。
- `scripts/games/shengji/rules/shengji_card_logic.gd`: 主牌判定とカード強さ比較。
- `scripts/games/shengji/rules/shengji_bidding_rules.gd`: 叫牌の更新可否。
- `scripts/games/shengji/rules/shengji_scoring.gd`: 底牌倍率、レベル上昇、ゲーム終了判定。

## Players And Teams

- プレイヤーは4人。
- Player 1 と Player 3 が Team A。
- Player 2 と Player 4 が Team B。
- ゲームは2デックと4デックの両方を正式対応する。
- 2デックは Easy mode として扱う。
- 4デックは Hard mode として扱う。
- ディーラーはそのラウンドの主チーム側のプレイヤーとして扱う。

## Cards And Points

- 各デックは通常カード52枚とジョーカー2枚を使う。
- 点数カードは次の通り。
  - 5: 5 points
  - 10: 10 points
  - K: 10 points
  - その他: 0 points
- トリックで出されたカードの点数は、そのトリックの勝者チームに入る。

## Level And Game End

- 両チームは Level 2 から開始する。
- 現在レベルと同じランクのカードは level card として扱う。
- A は Level 14 として扱う。
- どちらかのチームが Level 14 以上になるとゲーム終了。

## Round Flow

1. 新しいラウンドを開始する。
2. デックを作成してシャッフルする。
3. 底牌として8枚を分ける。
4. ディーラーから順番に1枚ずつ配る。
5. 配牌中に level card を持っているプレイヤーは叫牌できる。
6. 配牌終了後、まだ上書き可能な叫牌があれば最終叫牌の機会を出す。
7. 有効な叫牌がない場合は、ディーラーチームの Spades がデフォルト主花色になる。
8. 叫牌したプレイヤーが新しいディーラーになる。
9. ディーラーは底牌8枚を手札に加え、不要な8枚を埋底する。
10. ディーラーから最初のトリックを開始する。
11. 各トリックの勝者が次のトリックをリードする。
12. 全員の手札がなくなったら、最後のトリック勝者に応じて底牌点数を加算する。
13. ラウンド結果に基づき、チームレベルと次のディーラーを更新する。

## Trump Rules

次のカードは trump として扱う。

- 主花色のカード。
- 現在レベルと同じランクのカード。
- Big Joker と Small Joker。

Trump 内の強さは現在の実装では次の優先順になる。

1. Big Joker
2. Small Joker
3. 現在レベルの主花色カード
4. 現在レベルの他花色カード
5. 主花色の通常カード

通常カード同士はランクが高い方が強い。
非 trump の異なる花色は、リード花色でない限りトリックに勝てない。

No Trump round の trump 強さは次の通り。

1. Big Joker
2. Small Joker
3. 現在レベルのカード

No Trump round では、4花色の現在レベルカードは同じ強さとして扱う。

## Bidding

- 叫牌は現在レベルのカードを使う。
- Easy mode と Hard mode の両方で、同じ花色の level card を1枚以上持っていれば叫牌できる。
- 他プレイヤーは、現在の叫牌より多い枚数を出せる場合に上書きできる。
- 同じチームのプレイヤーも、現在の叫牌より多い枚数なら上書きできる。
- Joker での叫牌も可能。
- Joker で叫牌した場合は No Trump round になる。
- No Trump 叫牌では、同じ種類の Joker だけを枚数として数える。
- Big Joker 2枚は No Trump の2枚叫牌として扱える。
- Small Joker 2枚も No Trump の2枚叫牌として扱える。
- Big Joker 1枚 + Small Joker 1枚は、No Trump の2枚叫牌としては扱えない。
- No Trump round では、花色 trump は存在せず、現在レベルのカードと Joker だけが trump になる。
- Joker での叫牌も、現在の叫牌枚数より多い場合だけ上書きできる。
- 相手チームが上書きする場合も、現在の枚数より多い必要がある。
- 叫牌は配牌中に行える。
- 配牌終了後、最後にもう一度上書き可能な叫牌の機会がある。
- 叫牌が確定すると、その花色が trump suit になる。
- 叫牌したプレイヤーがそのラウンドのディーラーになる。

## Play Patterns

現在の実装で認識する出し方は次の4種類。

### Single

- 1枚のカード。

### Pair

- 同じランク、同じ花色の2枚。
- 複数デックで同一カードが2枚ある場合に成立する。

### Tractor

- 同じ枚数セットが連続した形。
- Easy mode では Pair Tractor のみを使う。
- Hard mode では Pair Tractor、Triple Tractor、Quadruple Tractor を使える。
- Easy mode の Tractor 枚数は偶数である必要がある。
- Hard mode の Tractor は、2枚組、3枚組、4枚組のいずれかで揃っている必要がある。
- 各セットは同じランク、同じ花色である必要がある。
- 全てのセットは trump か non-trump のどちらかに揃っている必要がある。
- Non-trump の Tractor は同じ花色で揃っている必要がある。
- 現在レベルのランクを含むセットは Tractor に使えない。
- Tractor の連続判定では、現在レベルのランクを飛ばして扱う。
- 例えば Level 5 の場合、4-4 + 6-6 は連続した Tractor として扱う。
- Joker pair は Tractor に含めない。
- Joker pair は強い Pair として扱うが、連続する Tractor の一部にはできない。

### Throw

- Throw は正式に採用する。
- 同じ種類の複数の強いカードやセットをまとめてリードできる。
- Throw するカードは、相手が同じ種類でより強いカードやセットを持っていない場合に成立する。
- 相手が Throw の一部を上回れる場合、その Throw は失敗扱いにする。
- Throw が失敗した場合、プレイヤーは選んだカード群の中から出せる一番小さい有効構造を強制的に出す。
- 現在の実装では Throw 判定がまだ簡易的なため、Standard ルールに合わせて強化する必要がある。

## Follow Rules

- フォローする枚数は、リードされた枚数と同じでなければならない。
- リードが trump の場合、可能なら trump を出す必要がある。
- リードが non-trump の場合、可能なら同じ花色の non-trump を出す必要がある。

### Following A Single

- 同じ種類のカードを持っていれば、その種類を1枚出す必要がある。
- 持っていなければ任意の1枚を出せる。

### Following A Pair

- 同じ種類の Pair を持っていれば、必ず Pair で出す必要がある。
- Pair はないが同じ種類のカードが2枚以上ある場合、その種類から2枚出す必要がある。
- 同じ種類のカードが1枚だけある場合、その1枚を含める必要がある。
- 同じ種類のカードがなければ任意の2枚を出せる。

### Following A Tractor

- 同じ種類の Tractor を持っていれば、必ず Tractor で出す必要がある。
- 同じ種類の Tractor がないが Pair を持っている場合、持っている Pair をできるだけ出す必要がある。
- Pair も足りない場合、同じ種類のカードを可能な限り出す必要がある。
- それでも枚数が足りない場合、残りは任意のカードで補う。
- 現在の実装ではこの判定がまだ簡易的なため、Standard ルールに合わせて強化する必要がある。

### Following A Throw

- Throw に対しては、可能な限りリードされた種類と構造に従ってフォローする。
- 現在の実装では、Throw のフォロー制約がまだ簡易的なため、Standard ルールに合わせて強化する必要がある。

## Trick Winner

- Trump は non-trump に勝つ。
- Non-trump 同士で花色が違う場合、リード花色側が勝つ。
- リードされた構造と同じ構造だけが、そのリードに勝てる。
- 構造が違う出し方は、どれだけ強いカードを含んでいてもリードには勝てない。
- 同じ役の場合は、その出し方の中で最も強いカードを比較する。
- トリック勝者のチームが、そのトリック内の点数カードを獲得する。
- トリック勝者が次のリードプレイヤーになる。

## Bottom Cards

- Easy mode は底牌8枚。
- Hard mode は底牌12枚。
- ディーラーは底牌を手札に加えた後、同じ枚数を選んで埋底する。
- 最後のトリック終了時、最後のトリック勝者によって底牌点数が加算される。
- 最後のトリック勝者がディーラーチームの場合、ディーラーチームが底牌点数を得る。
- 最後のトリック勝者が相手チームの場合、相手チームが底牌点数を得る。

## Bottom Multiplier

最後のトリックで勝った出し方の構造によって底牌倍率が決まる。

- Single または単牌扱いの Throw: x2
- Pair / Triple / Quadruple などの同ランクセット: x4
- 2連 Tractor: x8
- 3連 Tractor: x16
- 4連 Tractor: x32
- 以降、Tractor の連続数が1つ増えるごとに2倍する。

Hard mode の Triple Tractor / Quadruple Tractor でも、倍率はセット枚数ではなく連続数で決める。
例えば `7-7-7 + 8-8-8` は2連 Tractor なので x8。

## Round Scoring

ラウンド終了時、攻撃側の獲得点でレベル上昇と次ディーラーを決める。

| Attacker Points | Result |
| --- | --- |
| 200 or more | Attacker team +3 levels, attacker becomes next dealer side |
| 160-199 | Attacker team +2 levels, attacker becomes next dealer side |
| 120-159 | Attacker team +1 level, attacker becomes next dealer side |
| 80-119 | Attacker becomes next dealer side, no level advance |
| 40-79 | Dealer team +1 level, dealer side keeps dealer |
| 1-39 | Dealer team +2 levels, dealer side keeps dealer |
| 0 | Dealer team +3 levels, dealer side keeps dealer |

## Current Implementation Notes

- UI表示は英語をデフォルトとし、日本語と中国語を追加言語として扱う。
- Player 表記は位置名ではなく Player 1 / Player 2 / Player 3 / Player 4 を使う。
- 2デックは Easy mode、4デックは Hard mode として正式対応する。
- カードデザインは共通カードセットから自動検出する。
- AI は Standard ルールを守るだけでなく、叫牌、埋底、トリック、カード推薦で強い判断を目指す。
- Easy mode は底牌8枚、Hard mode は底牌12枚に対応している。
- 底牌倍率は構造ベースに対応している。
- Throw はまだ Standard ルールより簡易的な実装になっている。
