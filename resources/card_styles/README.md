# Card Styles

カード見た目のプリセット設定を置く場所です。

カード画像そのものは `assets/common/card_sets/` に置きます。ここには将来的に、カードセットごとの表示倍率、アクセシビリティ設定、説明文などのメタデータを置きます。

現在の実装では、`assets/common/card_sets/` に完全なカードセットを追加するとメイン画面の選択肢へ自動表示されます。

翻訳名やフォルダー名と異なるIDが必要な既知スタイルだけ、`scripts/app/game_config.gd` の `CARD_STYLES` に登録します。
