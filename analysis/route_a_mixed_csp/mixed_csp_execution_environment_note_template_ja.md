# 実行環境メモ テンプレート

このファイルは、Mixed-CSP 再現実行の返送時にそのまま埋めて返すためのテン
プレートです。

## 1. 実行環境

- OS:
- Python version:
- `pip install -r requirements.txt` は成功したか:
- もし分かれば SAT solver / 依存ライブラリ version:

## 2. 実行メモ

- 手順書どおりに最後まで実行できたか:
- 途中でエラーが出たか:
- 回避策を使ったか:
- 回避策を使った場合の内容:

## 3. 結果ファイル

- `mixed_csp_primary_external.jsonl` を返送したか:
- `mixed_csp_primary_external_results.json` を返送したか:
- `mixed_csp_primary_external_summary.md` を返送したか:

## 4. 支持フラグ

`mixed_csp_primary_external_results.json` の `support` を見て、そのまま転記
してください。

- `support.primary_supported`:
- `support.strong_support`:
- `support.theory_pure_support`:
- `support.encoding_guardrail_passed`:

## 5. 一言の結論

次のルールで 1 行だけ書いてください。

- 上の 4 つがすべて `true` なら:
  `4つの支持フラグがすべて true だったので再現した`
- 1 つでも `false` があれば:
  `4つの支持フラグのうち少なくとも1つが false だったので再現しなかった`

記入欄:

