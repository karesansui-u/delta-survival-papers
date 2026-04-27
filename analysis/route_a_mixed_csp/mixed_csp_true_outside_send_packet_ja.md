# Mixed-CSP 外部再現実行 依頼パック（日本語）

Status: 外部の実行者にそのまま渡すための日本語パック。これは新しい実験計
画ではなく、すでに凍結済みの Mixed-CSP primary package を外部環境で再
実行してもらうための説明文である。

Date: 2026-04-27

## 1. この依頼の要点

この依頼でお願いしたいのは、理論の評価でも改善提案でもなく、

```text
公開済みリポジトリの指定 commit から frozen package をそのまま rerun し、
同じ qualitative support decision が再現するかを確認すること
```

だけです。

言い換えると、

- 研究内容への賛否はこの段階では不要
- predictor や metric の変更は不要
- 新しい実験設計や tuning も不要
- 必要なのは「指定手順どおりに回して、結果を返すこと」

です。

## 2. まず最初に読んでほしい 30 秒版

あなたにお願いしたいことは、次の 5 点です。

1. 指定された published commit から repo を clone する
2. `requirements.txt` から依存関係を入れる
3. official artifacts は上書きせず、別出力先で rerun する
4. smoke / diagnostics / primary / analysis を順番に実行する
5. 出力 hash・row count・support flags・summary・環境メモを返す

もしこれが可能なら、この依頼の本質は理解できています。

## 3. この依頼で「してほしいこと」

してほしいことは、次の通りです。

1. 指定した commit hash の状態を clone する
2. package に書かれた frozen design を変えずに実行する
3. output は `external_outputs` のような別ディレクトリに出す
4. official JSONL / JSON / summary は上書きしない
5. 実行後に以下を返す
   - rerun output の hash
   - row count
   - support flags
   - held-out log-loss summary
   - 実行環境メモ
   - workaround があればその記録

## 4. この依頼で「してほしくないこと」

次のことはしないでください。

1. predictor を追加・削除する
2. threshold や support rule を変える
3. script を勝手に改善する
4. official artifact を直接上書きする
5. 「うまくいくように」 redesign する

この依頼は **replication task** であって、**redesign task** ではありませ
ん。

## 5. 受け取る資料

最低限、次の資料を受け取れば実行できます。

1. `analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md`
2. `analysis/route_a_mixed_csp/mixed_csp_true_outside_handoff_checklist.md`
3. `analysis/route_a_mixed_csp/mixed_csp_primary_official_2026-04-22.jsonl`
4. `analysis/route_a_mixed_csp/mixed_csp_results.json`
5. `analysis/route_a_mixed_csp/mixed_csp_results_summary.md`
6. `requirements.txt`

補助資料としてあると便利なもの:

1. `analysis/route_a_mixed_csp/mixed_csp_true_outside_send_runbook.md`
2. `analysis/g7_true_outside_handoff_overview.md`
3. `analysis/route_a_mixed_csp/mixed_csp_g7_replication_report_template.md`

## 6. 相手に送るときの日本語本文テンプレート

```text
件名: Frozen Mixed-CSP package の外部再現実行のお願い

こんにちは。

構造持続理論プロジェクトの一部として、すでに project-side では再現確認済みの
Mixed-CSP の frozen package があります。

今回お願いしたいのは、理論の評価や改善提案ではなく、
「公開済みリポジトリの指定 commit から clone し、手順どおりに rerun したとき、
同じ qualitative support decision が再現するか」の確認だけです。

お願いしたいこと:
1. 指定 commit から clone
2. requirements を install
3. official artifacts は上書きせず、separate outputs で実行
4. 指定 runbook に従って smoke / diagnostics / primary / analysis を実行
5. 結果として、output hash / row count / support flags / summary /
   環境メモ / workaround を返送

重要なのは、
- redesign しないこと
- predictor や評価条件を変えないこと
- output は official files とは別に保存すること
です。

この段階では raw な理論評価は不要で、再現実行できるかどうかだけで十分です。
また、この段階では raw data の追加提出などは不要です。

必要資料:
- mixed_csp_external_rerun_package.md
- mixed_csp_true_outside_handoff_checklist.md
- mixed_csp_true_outside_send_runbook.md

もし可能でしたら、まず
「この frozen package をあなたの環境で rerun できるか」
を教えてください。

よろしくお願いします。
```

## 7. 実行者向けの手順説明

実行者は、次の順で進めれば十分です。

1. repo を clone する
2. 指定 commit に checkout する
3. `pip install -r requirements.txt`
4. `analysis/route_a_mixed_csp/external_outputs` を作る
5. smoke dry-run
6. smoke execution
7. encoding diagnostics
8. primary dry-run
9. primary execution
10. held-out analysis
11. 出力 hash と summary を返送

詳しいコマンドは
`analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md`
にあります。

## 8. 実行者が LLM にそのまま貼れる依頼文

以下は、実行者が自分の LLM にそのまま貼ってよいテンプレートです。

```text
私は frozen Mixed-CSP rerun package を外部実行する担当です。

目的:
公開済み repo の指定 commit から package を rerun し、
qualitative support decision が再現するか確認したいです。

重要:
- redesign はしない
- predictor / support rule / metric は変えない
- official artifacts は上書きしない
- separate outputs にのみ出力する

やってほしいこと:
1. 受け取った手順書を読んで、実行順を整理する
2. 実行コマンドを順番に並べる
3. 実行後に返すべきもの
   - output hashes
   - row counts
   - support flags
   - held-out log-loss summary
   - environment note
   - workaround note
   をチェックリスト化する
4. 変更提案ではなく、rerun task の支援だけを行う

参照資料:
- analysis/route_a_mixed_csp/mixed_csp_external_rerun_package.md
- analysis/route_a_mixed_csp/mixed_csp_true_outside_handoff_checklist.md
- analysis/route_a_mixed_csp/mixed_csp_true_outside_send_runbook.md

まず最初に、
「この作業で何をしてはいけないか」
と
「返送物は何か」
を箇条書きで確認してください。
```

## 9. 返送してほしいもの

最低限、返送してほしいのは次の 6 つです。

1. rerun JSONL
2. rerun results JSON
3. rerun summary MD
4. 実行環境メモ
5. workaround の有無
6. 一言でよいので「qualitative support decision が再現したか」

## 10. この依頼文が分かりやすいかを確認するためのチェック

相手がこの文書を読んだあと、次の 5 問に答えられれば十分です。

1. これは redesign task ですか、replication task ですか
2. official artifact を上書きしてよいですか
3. output はどこに出すべきですか
4. 返送すべきものは何ですか
5. 何を再現できれば成功ですか

この 5 問に迷わず答えられないなら、送付文か資料のどちらかがまだ曖昧です。

## 11. 一言でのまとめ

```text
これは「理論を評価してほしい」依頼ではなく、
「凍結済み Mixed-CSP package を外部環境でそのまま rerun して、
support decision が再現するか確認してほしい」依頼です。
```
