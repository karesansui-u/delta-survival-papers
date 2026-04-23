# Delta-Survival Papers

Structural Persistence Theory for LLM reasoning degradation, catastrophic forgetting, and long-horizon coherence.

大規模言語モデルの推論劣化・破滅的忘却・長期一貫性を統一的に扱う構造持続理論の理論・実験・形式検証。

## Current Focus / 現在の主対象

このリポジトリの主対象は、`v2` にある 4 本のプレプリントと、レビュー中の Paper 5 draft です。
理論 architecture を追う場合は `v2/1`、`v2/2`、`v2/5` を先に読み、応用層として `v2/3`、`v2/4` へ進む構成です。`v1/` は旧版アーカイブ、補論は補助資料です。

### English Entry Points

英語で最短に入りたい場合は、まず [`v2/pdf用/ENGLISH_ABSTRACT.pdf`](v2/pdf%E7%94%A8/ENGLISH_ABSTRACT.pdf) を読んでください。
もう少し説明が必要なら [`ENGLISH_OVERVIEW.md`](ENGLISH_OVERVIEW.md) を参照してください。

### Japanese Main Track

全体像だけを先に掴みたい場合は、統合版 [`v2/0_構造持続理論の統合版.md`](v2/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.md) から読むこともできます。
PDF は [`v2/pdf用/0_構造持続理論の統合版.pdf`](v2/pdf%E7%94%A8/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.pdf) を参照してください。

## Evidence Status / 証拠の階層

現時点で前面に出すべき主証拠は二つです。LLM 側では 810 試行の構造矛盾実験が、単なる文脈長や制約数の基準モデルを越える追加予測力を与えます。SAT 側では、自然測度・first moment・Chernoff/KL collapse chain が、有限地平線の数学的 anchor として Lean で閉じています。

追加の prospective check として、Exp.39 では `gpt-4.1-nano` に対する 2×2 replication を行い、`32K structural contradiction` が `256K filler-only` より低い正答率を示した（0/30 vs 19/30）。これは文脈長が無害だという主張ではなく、構造矛盾が filler 長だけより強い崩壊要因になりうるという限定された予測を支持する。

既存 Exp.36/39 の trial-level 再解析では、token-only、quality-blind、structure-aware の三つの予測モデルを比較しています。Exp.36 の leave-one-model/context-out と Exp.39 外挿のいずれでも structure-aware model が最良の log loss を示しました。ただし quality-blind baseline も強いため、Exp.40 では「矛盾の有無」ではなく「矛盾の質」の差を固定比較しました。

Exp.40 はこの残った quality-blind baseline を直接叩く事前登録済み検査です。32K に固定し、`scoped / subtle / structural` を各50試行で比較しました。`scoped` は事前に repaired / zero-like として符号化しています。結果は `zero_sanity=50/50`, `scoped=50/50`, `subtle=23/50`, `structural=0/50` で、strong support が通りました。leave-one-target-out の primary log loss でも structure-aware `0.2763` が quality-blind `0.6944` を上回りました。

Exp.42 は Exp.40 の scope-as-repair 効果を四段階に分解しました。結果は `strong_scope=50/50`, `medium_scope=49/50`, `weak_scope=42/50`, `subtle=10/50` です。primary ordering は通りましたが、strong support の 10pt margin は strong/medium の天井効果により未達でした。row-level では exact wrong-sum adoption が `subtle` 25/40 mistakes から `weak_scope` 1/50 (1/8 mistakes)、`medium/strong` 0/50 へ落ち、最小の参照元 attribution が repair の主要成分であることを示唆します。

Route A の有限 CSP 側では、Mixed-SAT/NAE-SAT の事前登録済み primary test が、drift-weighted `L_plus_n` predictor が raw count + `n` baseline を大きく上回ることを示しました（leave-one-mixture-out log loss 0.0970 vs 0.7525）。さらに Exp43c q-coloring primary validation では、freeze 済み threshold-local window 内で `fm_plus_n` が raw / density / CNF-size baselines を上回りました（mean held-out log loss 0.440189 vs best raw baseline 2.804019、84.3% improvement）。q=5 fold は僅差なので大きな効果とは呼ばず、SAT 構文を越えた Route A width support として限定的に扱います。これは独立再現前の universal law 宣言ではなく、Level 2 universality candidate への支持です。

形式層では、Lean M1 gap analysis により、目標定理 4 の期待値レベル tendency schema が既存定理で formally accessible であることを確認しました。さらに G6-c iteration 1 として、Foster-Lyapunov / queueing drift の最小代数的埋め込みを `Survival/LyapunovBalanceEmbedding.lean` で形式化しました。対応表は [`lean/PAPER_MAPPING.md`](lean/PAPER_MAPPING.md) にまとめています。残る formal work は、必要に応じた reader-facing wrapper の追加と、高確率 stopped-collapse schema を期待値版 tendency schema から分離して維持することです。

Route A の非CSP skeletons は、信頼性・減衰・待ち行列・疲労・合意・臨界閾値などの古典例を同じ最小語彙で歪めず表せるかを見る sanity / coverage benchmark です。G4 v1 では queueing / Foster-Lyapunov drift を primary anchor、serial reliability と constant-fraction decay を loss-only control anchors として扱います。G4 v2 では repair / maintenance を持つ reliability / fatigue 系へ進め、`RepairMaintenanceBalance.lean` で補償流 \(g_t\) を非CSP open-system anchor として明示しました。これらは各分野の新しい本命定理を主張するものではなく、今後の operational theorem がどこへ波及しうるかを示すための射程確認として扱います。

## Main Preprints (v2) / メインプレプリント

### Paper 1 — 構造持続の最小形式

最小形式そのもの。事前固定された構造維持問題に対する表現定理として、構造を維持できる状態集合の縮小から残存可能性の指数形を導く。現行版では、A2 は対数比の公理的特徴づけ定理として与えられ、適用可能性条件と事後的表現選択による空虚化回避も明示している。

- Markdown: [`v2/1_構造持続の最小形式.md`](v2/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.md)
- PDF: [`v2/pdf用/1_構造持続の最小形式.pdf`](v2/pdf%E7%94%A8/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.pdf)
- OSF mirror: [paper1_minimal_form_ja_2026-04-14.pdf](https://osf.io/mdh7b/files/osfstorage/69dde399e43067989d1187e1)

### Paper 2 — 構造持続の条件つき導出

最小形式の条件つき導出と、その数学的な位置づけ。A1–A2 の純粋代数的恒等式と、A3 を加えた弱依存下の境界を分離し、Lean では `LogUniqueness.lean`・`TelescopingExp.lean`・`AxiomsToExp.lean`・`WeakDependence.lean` が対応する。

- Markdown: [`v2/2_構造持続の条件つき導出.md`](v2/2_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9D%A1%E4%BB%B6%E3%81%A4%E3%81%8D%E5%B0%8E%E5%87%BA.md)
- PDF: [`v2/pdf用/2_構造持続の条件つき導出.pdf`](v2/pdf%E7%94%A8/2_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9D%A1%E4%BB%B6%E3%81%A4%E3%81%8D%E5%B0%8E%E5%87%BA.pdf)
- OSF mirror: [paper2_conditional_derivation_ja_2026-04-14.pdf](https://osf.io/mdh7b/files/osfstorage/69dde4faa17296e9bb3e7a3b)

### Paper 3 — 構造持続と推論性能の劣化

推論時の未整理矛盾や上書きが、論理一貫性を保てる経路を削るという具体例。現時点の主張は、外部代謝が未整理の矛盾放置より良い、という点に絞っている。

- Markdown: [`v2/3_構造持続と推論性能の劣化.md`](v2/3_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%A8%E6%8E%A8%E8%AB%96%E6%80%A7%E8%83%BD%E3%81%AE%E5%8A%A3%E5%8C%96.md)
- PDF: [`v2/pdf用/3_構造持続と推論性能の劣化.pdf`](v2/pdf%E7%94%A8/3_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%A8%E6%8E%A8%E8%AB%96%E6%80%A7%E8%83%BD%E3%81%AE%E5%8A%A3%E5%8C%96.pdf)
- OSF mirror: [paper3_logical_consistency_ja_2026-04-14.pdf](https://osf.io/mdh7b/files/osfstorage/69dde3bde1158f542e3e7aec)

### Paper 4 — 構造持続と継続学習における破滅的忘却

継続学習における前提更新と依存知識の崩れを、構造持続の別相として扱う。

- Markdown: [`v2/4_構造持続と継続学習における破滅的忘却.md`](v2/4_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%A8%E7%B6%99%E7%B6%9A%E5%AD%A6%E7%BF%92%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B%E7%A0%B4%E6%BB%85%E7%9A%84%E5%BF%98%E5%8D%B4.md)
- PDF: [`v2/pdf用/4_構造持続と継続学習における破滅的忘却.pdf`](v2/pdf%E7%94%A8/4_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%A8%E7%B6%99%E7%B6%9A%E5%AD%A6%E7%BF%92%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B%E7%A0%B4%E6%BB%85%E7%9A%84%E5%BF%98%E5%8D%B4.pdf)
- OSF mirror: [paper4_catastrophic_forgetting_ja_2026-04-14.pdf](https://osf.io/mdh7b/files/osfstorage/69dde3c0cc45911aa117d84c)

### Paper 5 — 構造持続の収支法則と崩壊傾向

損失流と補償流の差し引きを構造収支律として定式化し、pathwise identity、expectation-level tendency、finite-horizon concentration schema、Route A / Route C anchors、既存理論との接続強度を整理するレビュー中の主理論 draft。

- Markdown: [`v2/5_構造持続の収支法則と崩壊傾向.md`](v2/5_構造持続の収支法則と崩壊傾向.md)

## Status / ステータス

| Component | Status |
|---|---|
| v2 Paper 1 | Main preprint |
| v2 Paper 2 | Main preprint |
| v2 Paper 3 | Main preprint |
| v2 Paper 4 | Main preprint |
| v2 Paper 5 | Main preprint draft |
| Lean 4 formalization | Complete (`135 Survival modules`, `sorry = 0`, `axiom = 0`) |
| OSF project | [osf.io/mdh7b/overview](https://osf.io/mdh7b/overview) |
| Raw data and summaries | [DATA.md](DATA.md) |

## Patent Notice / 特許関連

Related structure-preservation mechanisms have already been filed in Japan.
See [`PATENTS.md`](PATENTS.md) for a brief scope note.

## Recommended Reading Order / 推奨読書順

1. [`v2/1_構造持続の最小形式.md`](v2/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.md)
2. [`v2/2_構造持続の条件つき導出.md`](v2/2_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9D%A1%E4%BB%B6%E3%81%A4%E3%81%8D%E5%B0%8E%E5%87%BA.md)
3. [`v2/5_構造持続の収支法則と崩壊傾向.md`](v2/5_構造持続の収支法則と崩壊傾向.md)
4. [`v2/3_構造持続と推論性能の劣化.md`](v2/3_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%A8%E6%8E%A8%E8%AB%96%E6%80%A7%E8%83%BD%E3%81%AE%E5%8A%A3%E5%8C%96.md)
5. [`v2/4_構造持続と継続学習における破滅的忘却.md`](v2/4_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%A8%E7%B6%99%E7%B6%9A%E5%AD%A6%E7%BF%92%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B%E7%A0%B4%E6%BB%85%E7%9A%84%E5%BF%98%E5%8D%B4.md)

## Supplements / 補論・補助資料

補論は主張の中心ではなく、補助的な位置づけです。

- [`v2/補論_計算コストの構造的予測.md`](v2/%E8%A3%9C%E8%AB%96_%E8%A8%88%E7%AE%97%E3%82%B3%E3%82%B9%E3%83%88%E3%81%AE%E6%A7%8B%E9%80%A0%E7%9A%84%E4%BA%88%E6%B8%AC.md)
- [`v2/補論_有限CSPにおける構造持続の予測力.md`](v2/%E8%A3%9C%E8%AB%96_%E6%9C%89%E9%99%90CSP%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E4%BA%88%E6%B8%AC%E5%8A%9B.md)
- [`v2/補論_構造収支律とFoster-Lyapunovドリフトの形式的埋め込み.md`](v2/補論_構造収支律とFoster-Lyapunovドリフトの形式的埋め込み.md)
- [`v2/補論_非CSP古典例における構造収支律の最小アンカー.md`](v2/補論_非CSP古典例における構造収支律の最小アンカー.md)
- [`v2/補論_構造持続における資源項Mの操作的定式化.md`](v2/補論_構造持続における資源項Mの操作的定式化.md)
- [`v2/補論_構造持続写像の標準手順.md`](v2/%E8%A3%9C%E8%AB%96_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E5%86%99%E5%83%8F%E3%81%AE%E6%A8%99%E6%BA%96%E6%89%8B%E9%A0%86.md)
- [`v2/補論_持続的支援知能の設計原理.md`](v2/%E8%A3%9C%E8%AB%96_%E6%8C%81%E7%B6%9A%E7%9A%84%E6%94%AF%E6%8F%B4%E7%9F%A5%E8%83%BD%E3%81%AE%E8%A8%AD%E8%A8%88%E5%8E%9F%E7%90%86.md)

## Repository Structure / リポジトリ構成

```text
delta-survival-paper/
  v2/             main preprints (1-5), supplements, PDF sources
  v1/             older archived versions
  lean/           Lean 4 formal verification
  analysis/       SAT / LLM / frontier experiment analyses
  data/           raw data and summaries
  README.md
  OVERVIEW.md
```

## Formal Verification / 形式検証

Lean formalization is in [`lean/`](lean/). Current status:
`135 Survival modules`, `sorry = 0`, `axiom = 0`.

The current core layering includes:

- `LogUniqueness.lean`: Paper 1 §3 の対数比一意性
- `TelescopingExp.lean`: Paper 2 §3 の A1–A2 望遠鏡積恒等式
- `AxiomsToExp.lean`: 独立制約モデルからの指数形
- `WeakDependence.lean`: 弱依存下の境界
- `SATStateDependentCountChernoffKLAlgebra.lean`: actual 3-SAT clause-exposure path measure から Chernoff/KL collapse bound まで
- `BernoulliCSPPathCollapse.lean` / `KSATChernoffCollapse.lean`: Bernoulli bad-event CSP と random k-SAT への operational collapse wrapper
- `NAESATChernoffCollapse.lean`: fixed-assignment NAE-SAT bad-event exposure への horizontal expansion
- `XORSATChernoffCollapse.lean`: fixed-assignment XOR-SAT bad-event exposure への horizontal expansion
- `QColoringChernoffCollapse.lean`: fixed-coloring q-coloring edge exposure への horizontal expansion
- `ForbiddenPatternCSPChernoffCollapse.lean`: finite-alphabet forbidden-pattern exposure への generic expansion
- `MultiForbiddenPatternCSP.lean`: domain combinatorial witness から forbidden-pattern exposure を生成する bridge
- `HypergraphColoringChernoffCollapse.lean`: fixed-coloring hypergraph coloring exposure の forbidden-pattern specialization
- `CardinalitySATChernoffCollapse.lean`: exactly-`r`-of-`k` cardinality-SAT を multi-forbidden-pattern witness として表現する family-level specialization
- `ThresholdCardinalitySATChernoffCollapse.lean`: at-most / at-least threshold cardinality-SAT を同じ witness bridge に載せる family-level specialization
- `ExactlyOneSATChernoffCollapse.lean`: exactly-one-SAT を multi-forbidden-pattern witness として表現する specialization
- `BernoulliCSPUniversality.lean`: k-SAT / NAE-SAT / XOR-SAT / q-coloring / forbidden-pattern / hypergraph-coloring / cardinality-SAT / threshold-cardinality-SAT CSP を同一 Bernoulli-CSP interface に束ねる wrapper
- `LyapunovBalanceEmbedding.lean`: Foster-Lyapunov / queueing drift を構造収支律の \(a_t,A_n,R_t,\ell_t,g_t\) へ埋め込む G6-c minimal algebraic embedding
- Route A non-CSP skeletons: 10 small Lean modules grouped into four finite-prefix forms: multiplicative/exponential survival, linear overload, cumulative-capacity thresholds, and critical-parameter thresholds. Detailed module-to-claim mapping is kept in [`lean/PAPER_MAPPING.md`](lean/PAPER_MAPPING.md).

The cross-domain Bernoulli-CSP layer is frozen locally as **Bernoulli CSP
universality v1.2**: finite-horizon, iid bad-event exposure with fixed
assignment/coloring semantics, Chernoff-KL failure profiles, and operational
collapse / hitting-time wrappers, now including multi-forbidden witnesses,
cardinality-SAT, and threshold-cardinality-SAT.

The SAT/k-SAT finite-horizon chain is frozen as **SAT chain v1.0**. The primary
reader-facing proof index is [`lean/PAPER_MAPPING.md`](lean/PAPER_MAPPING.md);
the older SAT/CSP theorem maps were retired from the current tree after
consolidation and remain available through git history / OSF snapshots.
OSF mirrors for the previous v1.1 archive snapshot:
[`Bernoulli CSP v1.1 theorem map`](https://osf.io/mdh7b/files/osfstorage/69e71062e808d300ca9236c9),
[`Bernoulli CSP v1.1 update bundle`](https://osf.io/mdh7b/files/osfstorage/69e71087f4653a8fbfb0001a).

For external readers and archive visitors, see [`LEAN_FORMALIZATION_README.md`](LEAN_FORMALIZATION_README.md).

```bash
cd lean && lake exe cache get && lake build
```

## Author / 著者

Akihito Sunagawa

## Citation / 引用

See [`CITATION.cff`](CITATION.cff).

## License

- Papers and prose: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- Code (`lean/`, `analysis/`): [Apache 2.0](LICENSE)
