# Shengji Rule Decisions

この文書は、Shengji / Tractor のルール仕様を順番に決めるための決定表です。
決定済みの内容は `SHENGJI_RULES.md` とコードに反映します。

| Item | Decision | Status |
| --- | --- | --- |
| Rule direction | Standard: 一般的な Shengji / Tractor にできるだけ近づける | Decided |
| Deck count | 2 decks and 4 decks are both official. 2 decks = Easy mode, 4 decks = Hard mode. | Decided |
| Bidding minimum | 1 level card is enough to bid in both Easy and Hard modes. | Decided |
| Bidding override | Any player can override the current bid with more cards. | Decided |
| Same-team bidding | Same-team players can also override the current bid if they use more cards. | Decided |
| Joker / no-trump bidding | Joker bidding is allowed and creates a no-trump round. No-trump bid count uses identical joker rank only: two Big Jokers or two Small Jokers can make a 2-card no-trump bid, but one Big Joker plus one Small Joker cannot. In no-trump, only level cards and jokers are trump. | Decided |
| Bidding timing | Players can bid during dealing, then there is one final bidding opportunity after dealing. | Decided |
| Dealer seat | Bidding chooses trump only. The bidder does not become dealer. If the dealer side holds, the next dealer is the current dealer's partner. If attackers take over, the next dealer is the next player in turn order from the attacking team. | Decided |
| Trump ranking with suit | Big Joker > Small Joker > level card in trump suit > level cards in other suits > regular trump-suit cards. | Decided |
| Trump ranking no-trump | Big Joker > Small Joker > level cards. All four level-card suits are equal strength in no-trump. | Decided |
| Tractor level skip | Current level rank is skipped for tractor continuity. For example, at Level 5, 4-4 + 6-6 is continuous. | Decided |
| Joker pair in tractor | Joker pairs are not part of tractors. A joker pair is a strong pair, but it cannot be used in a tractor sequence. | Decided |
| Tractor set size | Easy mode supports pair tractors only. Hard mode supports pair, triple, and quadruple tractors. | Decided |
| Throw rules | Throw is officially supported. A throw must be valid; if opponents can beat any component, the throw fails. | Decided |
| Failed throw handling | If a throw fails, the player must play the smallest valid component from the attempted throw. | Decided |
| Pair follow obligation | If the player has a pair in the led kind, they must follow with a pair. | Decided |
| Tractor follow obligation | If the player has a tractor in the led kind, they must follow with a tractor. | Decided |
| Pair obligation when no tractor | If the player cannot follow with a tractor but has pairs in the led kind, they must play as many pairs as possible. | Decided |
| Trick comparison | Only plays with the same structure as the lead can beat the lead. Mismatched structures cannot win. | Decided |
| Bottom cards | Easy mode uses 8 bottom cards. Hard mode uses 12 bottom cards. | Decided |
| Bottom multiplier | Single/Throw = x2, same-rank set = x4, tractor length 2 = x8, length 3 = x16, length 4 = x32, and doubles for each additional tractor length. | Decided |
| Round scoring | Use the Standard 80-point table: 0 => dealer +3, 1-39 => dealer +2, 40-79 => dealer +1, 80-119 => attacker takes dealer side only, 120-159 => attacker +1, 160-199 => attacker +2, 200+ => attacker +3. | Decided |
| AI behavior | AI should follow Standard rules and aim to play strongly from the beginning, including legal-play selection, trick evaluation, burying, bidding, and recommendation logic. | Decided |
