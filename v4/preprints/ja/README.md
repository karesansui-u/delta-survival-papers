# Japanese Preprints

このディレクトリは、構造持続理論の日本語プレプリントを集約する場所です。

## Current

- `構造持続理論.md`
  - 理論編。構造持続理論そのものの価値、M/L 分離、支えフロンティア、持続・崩壊・回復・介入の読み方を説明する。
  - Lean 側の有限 stochastic workload frontier、grid / bracket / generated riskFrontier、resource-conserving protocol class の現在地も本文に反映する。
- `PREPRINT_LEAN_ARTIFACT_ja.md`
  - Lean アーティファクト編。Lean が何を保証し、何を保証しないかを説明する。
- `M_補論.md`
  - M側補論。名目資源 `R` と有効資源 `M` の分離、M側の Lean 形式化、現在の support / no-support / 未決を整理する。
  - `M` は名目資源 `R` ではなく、target、horizon、assumptions、path、certificate、lifecycle によって資格づけられた temporal effective support claim の現在射影である。M側の exact finite anchor は、同じ raw resource や単純和を持っていても qualified support gate / path / license が違えば claim に使える `M` が変わりうることを示す anti-collapse witness であり、M の経験的予測性能を主張するものではない。
  - M側の有限 benchmark は QSA と SRE-H1 で一段進んだ。同じまたは統制された raw `R`・`L`/damage 条件を持つ matched pair で、qualified support gate / path / license だけを変えた readout が primary / fresh の両方で positive な finite-benchmark support signal になり、外部 Windows/Python 環境でも primary / fresh の decision が再現された(`externally_rerun_reproduced`)。ただしこれは frozen code / package の計算再現性であり、外部実データによる経験的検証ではない。
- `L_補論.md`
  - L側補論。Mixed-SAT/NAE-SAT によって、`L_mass` が raw count へ縮退しない有限 CSP 読みを整理する。

## Evidence / Validation Layer

このディレクトリの主要文書は whitepaper / supplement 層です。理論の主張、Lean アーティファクトの役割、M側補論の現在地を説明します。

ただし、このリポジトリの重要な信用源は、whitepaper だけではありません。どの読みが支持され、どの読みが支持されず、どの実行が無効で、どの対象では沈黙したのかを残す evidence / validation 層も同じくらい重要です。

現在の主な導線:

- `docs/theory/COUPLED_REPAIR_TRADEOFF_SIMULATION.md`
  - 結合制約の exact witness。射影では可能に見えるが、同じ選択では同時に満たせない有限面を記録する。
- `docs/theory/COUPLED_PROXY_RESIDUAL_SIMULATION.md`
  - 結合制約の lossy proxy 面。正解をそのまま特徴量にせず、単体 summary と交互作用 baseline の上に、弱い結合 proxy が残差信号を持つかを見る。
- `data/coupled_repair_tradeoff_summary.csv`
  - exact witness の結果。
- `data/coupled_proxy_residual_summary.csv`
  - lossy proxy / matched residual の結果。
- `scripts/simulate_coupled_repair_tradeoff.py`
  - exact witness を再生成するスクリプト。
- `scripts/simulate_coupled_proxy_residual.py`
  - lossy proxy 面を再生成するスクリプト。
- `docs/lean/PROOF_AUDIT.md`
  - Lean 側の theorem / def projection の監査表。
- `scripts/proof_audit.sh`
  - 構造持続モジュールの監査スクリプト。

読み方:

- `support` は、その frozen surface と評価条件の下で支持された、という意味に限る。
- `no-support` は失敗ではなく、理論の境界を狭くするための記録である。
- `invalid` は実行条件や protocol に問題があり、支持・不支持として読まない。
- `silence` は、その面では読みが立たなかった、または強い判定へ進めないことを意味する。

この層の目的は、構造持続理論を「都合よく説明できる比喩」にしないことです。支持された読みだけでなく、支持されなかった読みも同じ台帳に残します。

現時点の要約としては、仕様固定の L 側では finite CSP などが比較的硬い支持を持ちます。LLM 推論劣化は推定レイヤーの支持です。M 側には、`R != M` を示す exact finite anti-collapse anchor があり、その上に QSA と SRE-H1 の finite-benchmark support signal があります。これらは同じまたは統制された raw `R`・`L`/damage 条件のもとで qualified support の差が readout に残ることを示し、外部 Windows/Python 環境でも primary / fresh の decision が再現されました(`externally_rerun_reproduced`)。ただし、これは frozen code / package の計算再現性であり、外部実データによる経験的検証、SRE-H1-Full admission、一般 external SRE support、real-domain typicality ではありません。つまり M は、形式面では L と同じ typed accounting interface に載りますが、経験面ではまだ L と同じ包括的な実証ステータスを持つ軸ではありません。しかし、R と区別しないと会計が壊れる軸であり、finite benchmark によって一部の readout には support signal が追加されました。結合層は exact witness と lossy proxy residual surface を分けて扱っています。この区別を混ぜないことが重要です。

## Build

PDF は次で生成します。

```bash
python3 preprints/ja/build_whitepaper_preprints.py
```

出力先:

```text
preprints/ja/pdf/
```

## Archive

`archive/` には、現在の正本ではない旧草稿・作業メモを置きます。

削除せずに退避している理由は、文言や構成の履歴をあとから参照できるようにするためです。不要であることが確定したものだけ、別途削除対象にします。
