# AI Development Framework

この `docs/` は、AIまたは開発者がこの Godot プロジェクトを安全に修正・更新するための作業フレームワークです。

## Documents

- `PROJECT_RULES.md`: プロジェクト全体の方針、禁止事項、重要ファイル、共通ルール。
- `ARCHITECTURE.md`: 現在のディレクトリ構造、責務分担、シーンとシグナルの関係。
- `AI_WORKFLOW.md`: AIが作業前・作業中・作業後に従う標準手順。
- `VERIFICATION.md`: 修正後に確認するチェックリスト。
- `TASK_TEMPLATE.md`: AIへ依頼するときのテンプレート。

## Recommended Use

AIへ依頼するときは、まず `TASK_TEMPLATE.md` の形式で目的と触ってよい範囲を書きます。

AIは作業前に次を確認します。

1. `PROJECT_RULES.md`
2. `ARCHITECTURE.md`
3. 依頼に関係するコード
4. `VERIFICATION.md`

大きな変更や新機能では、作業前に影響範囲を説明してから編集します。小さな修正では、既存構造を確認したうえで最小範囲を直接修正します。

