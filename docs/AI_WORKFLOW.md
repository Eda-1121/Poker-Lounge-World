# AI Workflow

AIがこのプロジェクトを修正・更新するときの標準手順です。

## Before Editing

1. `git status --short` を確認し、既存の未コミット変更を把握する。
2. 依頼内容に関係するファイルを `rg` と `sed` で読む。
3. `docs/PROJECT_RULES.md` と `docs/ARCHITECTURE.md` に反する変更にならないか確認する。
4. 変更対象、影響範囲、検証方法を短く整理する。
5. 既存コードやアセットを削除・移動する必要がある場合は、ユーザーの意図を確認する。

## Editing Rules

- 既存パターンに合わせて修正する。
- 目的に直接関係ないリファクタリングを混ぜない。
- ファイル移動や名前変更は参照更新まで含めて行う。
- Godot が生成する `.uid`、`.import`、`.godot/` は手作業で整形しない。
- GDScript は既存の型注釈、signal、enum、class_name の使い方に合わせる。
- 文字列をUIに直書きする前に `GameConfig.text()` の利用を検討する。

## Suggested Task Breakdown

### Small Bug Fix

1. 再現箇所を探す。
2. 原因ファイルを読む。
3. 最小修正を入れる。
4. Godot headless 起動または該当シーン起動で確認する。
5. 変更内容と検証結果を報告する。

### UI Change

1. 対象UIクラスを読む。
2. 画面サイズ計算、フォントサイズ、配置ロジックを確認する。
3. 1280x720 と 1600x900 で破綻しない寸法にする。
4. 言語切り替えで長い文字列がはみ出さないか確認する。
5. 可能ならスクリーンショットで確認する。

### Game Rule Change

1. `scripts/shengji/game_rules.gd` を先に読む。
2. `scripts/shengji/game_manager.gd` の呼び出し側を確認する。
3. 既存の enum と helper を使う。
4. 代表的なカード組み合わせを手動またはスクリプトで検証する。
5. 変更したルールの制限事項を報告する。

### New Shared Feature

1. 本当に複数ゲームで使うか確認する。
2. 共通層に置く責務か、ゲーム固有層に置く責務か決める。
3. `scripts/common/` に入れる場合、Shengji 固有名や固有ルールを混ぜない。
4. 既存ゲームが壊れていないか確認する。

## Standard Commands

プロジェクト確認:

```sh
git status --short
rg --files
```

Godot headless 起動確認:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --quit
```

Mono版が必要な場合:

```sh
/Applications/Godot_mono.app/Contents/MacOS/Godot --headless --path . --quit
```

## Reporting Format

作業完了時は、次を短く報告する。

- 変更したファイル
- 何を変えたか
- 実行した検証
- 残っているリスクや未確認点

## Request Template For The User

AIへ依頼するときは、できるだけこの形式を使う。

```md
## 目的

## 期待する動作

## 変更してよい範囲

## 変更してほしくない範囲

## 関連する画面・ゲーム

## 検証したい内容
```

