# Task Template

AIへ作業を依頼するときは、このテンプレートを使うと精度が上がります。

```md
## 目的

例: Shengji の手札表示でカードが重なりすぎる問題を直したい。

## 期待する動作

例: 1280x720 でもすべての手札カードがクリックでき、最後のカードまで見える。

## 変更してよい範囲

例:
- scripts/shengji/player.gd
- scripts/common/card.gd

## 変更してほしくない範囲

例:
- project.godot
- assets/common/cards/
- Shengji のルール判定

## 関連する画面・ゲーム

例:
- Shengji / Tractor
- プレイ中の人間プレイヤー手札

## 検証したい内容

例:
- Godot headless 起動でエラーがない
- 1280x720 で手札が画面外にはみ出さない
- カード選択と解除ができる
```

## Short Request Example

```md
## 目的
Shengji の入札メッセージを日本語でも自然にしたい。

## 期待する動作
入札中、現在の入札、パスの表示が3言語で正しく出る。

## 変更してよい範囲
- scripts/game_config.gd
- scripts/shengji/bidding_ui.gd

## 変更してほしくない範囲
- ゲームルール
- 配札処理

## 関連する画面・ゲーム
- Shengji / Tractor の入札フェーズ

## 検証したい内容
- en/ja/zh のキーが揃っている
- 表示文字列がはみ出さない
```

