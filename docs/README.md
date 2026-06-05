# AI Development Framework

この `docs/` は、AIまたは開発者がこの Godot プロジェクトを安全に修正・更新するための作業フレームワークです。

## Documents

- `PROJECT_RULES.md`: プロジェクト全体の方針、禁止事項、重要ファイル、共通ルール。
- `ARCHITECTURE.md`: 現在のディレクトリ構造、責務分担、シーンとシグナルの関係。
- `FOLDER_STRUCTURE.md`: フォルダーごとの用途、配置ルール、カスタマイズ用フォルダーの説明。
- `SHENGJI_RULES.md`: 現在実装されている Shengji / Tractor のゲームルール整理。
- `SHENGJI_RULE_DECISIONS.md`: Shengji / Tractor の未決定ルールを順番に決めるための決定表。
- `SHENGJI_STANDARD_IMPLEMENTATION_PLAN.md`: 決定済みStandardルールを実装へ反映するための作業計画。
- `PIXEL_CARD_UI_DESIGN_SPEC.md`: スクリーンショットを基準にしたピクセルカード風UIリデザイン仕様。
- `SHENGJI_TABLE_UI_REDESIGN_SPEC.md`: 対局画面をピクセルカード風テーブルUIへ作り直すための仕様。
- `AI_WORKFLOW.md`: AIが作業前・作業中・作業後に従う標準手順。
- `AI_EDITING_MAP.md`: 依頼内容から最初に確認・編集する場所を決める対応表。
- `VERIFICATION.md`: 修正後に確認するチェックリスト。
- `TASK_TEMPLATE.md`: AIへ依頼するときのテンプレート。

## Recommended Use

AIへ依頼するときは、まず `TASK_TEMPLATE.md` の形式で目的と触ってよい範囲を書きます。

AIは作業前に次を確認します。

1. `PROJECT_RULES.md`
2. `ARCHITECTURE.md`
3. `FOLDER_STRUCTURE.md`
4. 依頼に関係するコード
5. `VERIFICATION.md`

大きな変更や新機能では、作業前に影響範囲を説明してから編集します。小さな修正では、既存構造を確認したうえで最小範囲を直接修正します。
