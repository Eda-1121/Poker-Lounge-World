# Card Sets

Shared card image sets used by every card game.

- `classic/`: default card artwork.
- `minimal/`: simplified card artwork.

Each set must contain the same file names, for example `spade_02.png`, `heart_14.png`, `small_joker.png`, `big_joker.png`, `card_back.png`, and `card_empty.png`.

Runtime selection is discovered from this folder. A folder appears in the main menu when it contains a complete card set with the required file names.

Known styles can still be listed in `GameConfig.CARD_STYLES` when they need translated display names or an id that differs from the folder name.
