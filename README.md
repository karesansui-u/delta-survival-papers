# Delta-Survival Papers

Structural Persistence Theory for LLM reasoning degradation, catastrophic forgetting, and long-horizon coherence.

大規模言語モデルの推論劣化・破滅的忘却・長期一貫性を統一的に扱う構造持続理論の理論・実験・形式検証。

## Current Focus / 現在の主対象

このリポジトリの主対象は、`v3` にある公開運用版です。`v3` は、構成地図、統合版、Core Paper、主理論 spine、数学的基礎、ドメイン registry、証拠 ledger、共同運用テンプレートを分けた構造です。`v2` は preprint bundle と PDF 生成物を含む安定アーカイブとして残します。

仕様固定構造層、条件付き構造埋め込み層、構造推定層は、異なる理論ではなく、同一の構造持続核を異なる観測レベルで扱うための層です。

| 外向け名 | 読み方 |
|---|---|
| 仕様固定構造層 | 構造、測度（状態集合の大きさを測るものさし）、境界を仕様から直接固定できる層 |
| 条件付き構造埋め込み層 | 既存理論のドリフト / 差分 / 停止境界を条件付きに写す橋渡し |
| 構造推定層 | 構造を直接数えず、観測・推定指標と凍結検証で推定する現実系の標準入口 |

- 外向け導線: [`v3/01_theory/00_map.md`](v3/01_theory/00_map.md) -> [`v3/01_theory/01_overview.md`](v3/01_theory/01_overview.md) -> [`v3/01_theory/02_core.md`](v3/01_theory/02_core.md)
- 主理論 spine: [`v3/01_theory/10_paper1_minimal_form.md`](v3/01_theory/10_paper1_minimal_form.md) -> [`v3/01_theory/11_paper2_balance_principle.md`](v3/01_theory/11_paper2_balance_principle.md)
- ドメイン registry: [`v3/03_domains/registry.tsv`](v3/03_domains/registry.tsv)
- 主張境界: [`v3/CLAIMS.md`](v3/CLAIMS.md)
- 共同運用: [`v3/CONTRIBUTING.md`](v3/CONTRIBUTING.md)
- 証拠階層: [`analysis/current_evidence_map.md`](analysis/current_evidence_map.md)

`v1/` は旧版アーカイブ、`v2/` は preprint bundle、`v3/` は今後の公開運用版です。

### English Entry Points

英語で最短に入りたい場合は、まず Core / Paper 1 / Paper 2 の英語版を読んでください。

- Core English Markdown: [`v3/01_theory/en/02_core_en.md`](v3/01_theory/en/02_core_en.md)
- Core English PDF: [`v2/pdf用/02_core_en.pdf`](v2/pdf%E7%94%A8/02_core_en.pdf)
- Paper 1 English PDF: [`v2/pdf用/10_paper1_minimal_form_en.pdf`](v2/pdf%E7%94%A8/10_paper1_minimal_form_en.pdf)
- Paper 2 English PDF: [`v2/pdf用/11_paper2_balance_principle_en.pdf`](v2/pdf%E7%94%A8/11_paper2_balance_principle_en.pdf)

短い要約だけなら [`v2/pdf用/ENGLISH_ABSTRACT.pdf`](v2/pdf%E7%94%A8/ENGLISH_ABSTRACT.pdf) も使えます。もう少し説明が必要なら [`ENGLISH_OVERVIEW.md`](ENGLISH_OVERVIEW.md) を参照してください。

### Japanese Main Track

全体像だけを先に掴みたい場合は、まず [`v3/01_theory/00_map.md`](v3/01_theory/00_map.md) を読み、その後で [`v3/01_theory/01_overview.md`](v3/01_theory/01_overview.md) と [`v3/01_theory/02_core.md`](v3/01_theory/02_core.md) に進むのが最も迷いにくい導線です。
PDF は [`v2/pdf用/補論_構造持続理論の構成地図.pdf`](v2/pdf用/補論_構造持続理論の構成地図.pdf) と [`v2/pdf用/0_構造持続理論の統合版.pdf`](v2/pdf%E7%94%A8/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.pdf) を参照してください。

## Evidence Status / 証拠の階層

現時点の証拠階層は [`analysis/current_evidence_map.md`](analysis/current_evidence_map.md) に整理しています。README では現在地だけを示します。

- 仕様固定構造層: SAT / Mixed-CSP / q-coloring では、自然測度・有限時間の崩壊境界・事前固定された経験的検証が揃いつつあります。現時点で最も硬い経験的入口は、Mixed-CSP と Exp43c q-coloring の二つの凍結済み検証パッケージです。Mixed-CSP は外部実行者 3 名が各 12,000 行の primary run、0 checked core mismatches、support flags reproduced を返し、Exp43c q-coloring は外部実行者 3 名が各 4,000 行の primary run、0 checked core mismatches、TIMEOUT 0、MALFORMED 0、同じ qualitative support decision を返しています。これは理論全体の証明ではありません。しかし、仕様固定構造層における法則側座標の、最初の強い外部再現足場です。
- 構造推定層: LLM 推論実験では、文脈長だけではなく構造矛盾の質が崩壊を予測することを、複数の preregistered / prospective checks で検査しています。
- Formal layer: Lean 4 側は `151 Survival modules`, `sorry = 0`, `axiom = 0` で、主な theorem-to-paper mapping は [`lean/PAPER_MAPPING.md`](lean/PAPER_MAPPING.md) にまとめています。階層的不変量による統一枠組みへ何を積むかは [`analysis/second_law_level_roadmap.md`](analysis/second_law_level_roadmap.md) に、Phase 5 の admissible-map ladder は [`analysis/phase5_admissible_map_ladder.md`](analysis/phase5_admissible_map_ladder.md) に、Phase 6.1 の Foster-Lyapunov / queueing template は [`analysis/phase6_foster_lyapunov_template.md`](analysis/phase6_foster_lyapunov_template.md) に、Phase 6.2 の Repair-Maintenance template は [`analysis/phase6_repair_maintenance_template.md`](analysis/phase6_repair_maintenance_template.md) に、Phase 7 v0 の cross-class registry は [`analysis/phase7_cross_class_unification_v0.md`](analysis/phase7_cross_class_unification_v0.md) に、Phase 7 v1/v2 の unifying schema は [`analysis/phase7_unifying_schema_v1.md`](analysis/phase7_unifying_schema_v1.md) と [`analysis/phase7_unifying_schema_v2.md`](analysis/phase7_unifying_schema_v2.md) に分けて整理しています。
- 限定クラス統一: Phase 7 v2 は、Bernoulli-CSP、Foster-Lyapunov / queueing、Repair-Maintenance の三つの登録済み限定クラスが、順序つき \(\Sigma\) carrier、非負傾向の駆動構造、有限時間証明経路、許容写像による転送条件からなる共通インターフェースを満たすことを Lean 側で登録しています。これは任意ドメインに対する単一普遍不等式ではなく、登録済みクラスに対する拡張可能な共通インターフェース閉包です。
- Non-CSP: Backblaze / C-MAPSS / Scania などは support / weakening / no-support を分けて記録し、同一 archive 内の rescue を避けています。

## Core and Companion Papers (v2) / 主理論核と companion papers

### Core Paper — 構造持続の最小核と収支原理

外部読者向けに Paper 1 / Paper 2 を一本の導線として読むための統合短論文です。新しい理論核ではなく、分冊版の最小形式と収支原理を、`S = M e^{-L}` から `S = M e^{-B}` へつなぐ読者向け導線です。Paper 1 を自明な前提として扱うのではなく、構造喪失を維持可能領域の縮小として定式化する第一の非自明な主張として読むための入口でもあります。厳密な公理・定理・限界は Paper 1 / Paper 2 を基準とします。

- Markdown: [`v2/Core_構造持続の最小核と収支原理.md`](v2/Core_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E6%A0%B8%E3%81%A8%E5%8F%8E%E6%94%AF%E5%8E%9F%E7%90%86.md)
- PDF: [`v2/pdf用/Core_構造持続の最小核と収支原理.pdf`](v2/pdf%E7%94%A8/Core_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E6%A0%B8%E3%81%A8%E5%8F%8E%E6%94%AF%E5%8E%9F%E7%90%86.pdf)

### Paper 1 — 構造持続の最小形式

最小形式そのもの。ここでいう「最小」は当たり前という意味ではなく、事前固定された構造維持問題に対する第一の非自明な表現定理を指します。構造を維持できる状態集合の縮小から残存可能性の指数形を導き、A2 は対数比の公理的特徴づけ定理として与えられ、適用可能性条件と事後的表現選択による空虚化回避も明示している。

- Markdown: [`v2/1_構造持続の最小形式.md`](v2/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.md)
- PDF: [`v2/pdf用/1_構造持続の最小形式.pdf`](v2/pdf%E7%94%A8/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.pdf)
- OSF mirror: [paper1_minimal_form_ja_2026-04-14.pdf](https://osf.io/mdh7b/files/osfstorage/69dde399e43067989d1187e1)

### Supplement — 構造持続の条件つき導出

最小形式の条件つき導出と、その数学的な位置づけ。A1–A2 の純粋代数的恒等式と、A3 を加えた弱依存下の境界を分離する技術補論。主線を読むだけなら後回しでよい。

- Markdown: [`v2/補論_構造持続の条件つき導出.md`](v2/補論_構造持続の条件つき導出.md)
- PDF: [`v2/pdf用/補論_構造持続の条件つき導出.pdf`](v2/pdf用/補論_構造持続の条件つき導出.pdf)
- OSF mirror: [conditional_derivation_supplement_ja_2026-04-14.pdf](https://osf.io/mdh7b/files/osfstorage/69dde4faa17296e9bb3e7a3b)

### Paper 2 — 構造持続の収支原理

主理論 spine の第二層。構造持続の最小核 `S = M e^{-L}` を、回復を含む `S = M e^{-B}` へ拡張する短い原理论文です。仕様固定構造層、構造推定層、条件付き構造埋め込み層の詳細は補論へ分離しています。

- Markdown: [`v2/2_構造持続の収支原理.md`](v2/2_構造持続の収支原理.md)
- PDF: [`v2/pdf用/2_構造持続の収支原理.pdf`](v2/pdf用/2_構造持続の収支原理.pdf)

### LLM Companion I — 推論時の構造劣化

構造推定層の companion anchor 1。主理論 spine そのものではなく、未整理矛盾や external metabolism が消耗側 / 回復側指標として観測量を予測するかを検査する観測的アンカーです。

推論時の未整理矛盾や上書きが、論理一貫性を保てる経路を削るという具体例。現時点の主張は、外部代謝が未整理の矛盾放置より良い、という点に絞っている。

- Markdown: [`v2/Companion_RouteC_推論時の構造劣化.md`](v2/Companion_RouteC_推論時の構造劣化.md)
- PDF: [`v2/pdf用/Companion_RouteC_推論時の構造劣化.pdf`](v2/pdf用/Companion_RouteC_推論時の構造劣化.pdf)
- OSF mirror: [llm_companion_inference_ja_2026-04-14.pdf](https://osf.io/mdh7b/files/osfstorage/69dde3bde1158f542e3e7aec)

### LLM Companion II — 継続学習時の構造的忘却

構造推定層の companion anchor 2。主理論 spine の証明ではなく、前提更新と依存再編の失敗がどのように structural forgetting として現れるかを観測的に示す companion layer です。

継続学習における前提更新と依存知識の崩れを、構造持続の別相として扱う。

- Markdown: [`v2/Companion_RouteC_継続学習時の構造的忘却.md`](v2/Companion_RouteC_継続学習時の構造的忘却.md)
- PDF: [`v2/pdf用/Companion_RouteC_継続学習時の構造的忘却.pdf`](v2/pdf用/Companion_RouteC_継続学習時の構造的忘却.pdf)
- OSF mirror: [llm_companion_continual_learning_ja_2026-04-14.pdf](https://osf.io/mdh7b/files/osfstorage/69dde3c0cc45911aa117d84c)

## Status / ステータス

| Component | Status |
|---|---|
| v2 Core Paper | Reader-facing integration paper |
| v2 Paper 1 | Main preprint |
| v2 Paper 2 | Main preprint / balance principle |
| Conditional derivation | Supplement |
| LLM Companion I | Companion preprint |
| LLM Companion II | Companion preprint |
| Lean 4 formalization | Complete (`151 Survival modules`, `sorry = 0`, `axiom = 0`) |
| OSF project | [osf.io/mdh7b/overview](https://osf.io/mdh7b/overview) |
| Raw data and summaries | [DATA.md](DATA.md) |

## Patent Notice / 特許関連

Related structure-preservation mechanisms have already been filed in Japan.
See [`PATENTS.md`](PATENTS.md) for a brief scope note.

## Recommended Reading Order / 推奨読書順

### Public-facing route

これは外向けの表示順です。論理依存順ではなく、読者が迷わず全体像から主理論、運用、応用、深部補論へ降りていくための順番です。

1. 構成地図: [`v2/補論_構造持続理論の構成地図.md`](v2/補論_構造持続理論の構成地図.md)
2. 統合版: [`v2/0_構造持続理論の統合版.md`](v2/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.md)
3. Core Paper: [`v2/Core_構造持続の最小核と収支原理.md`](v2/Core_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E6%A0%B8%E3%81%A8%E5%8F%8E%E6%94%AF%E5%8E%9F%E7%90%86.md)
4. 最小形式: [`v2/1_構造持続の最小形式.md`](v2/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.md)
5. 収支原理: [`v2/2_構造持続の収支原理.md`](v2/2_構造持続の収支原理.md)
6. 運用規律: [`v2/補論_構造持続理論の運用規律.md`](v2/補論_構造持続理論の運用規律.md)
7. 仕様固定構造層 / 有限CSP: [`v2/補論_有限CSPにおける構造持続の予測力.md`](v2/%E8%A3%9C%E8%AB%96_%E6%9C%89%E9%99%90CSP%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E4%BA%88%E6%B8%AC%E5%8A%9B.md)
8. 構造推定層 / LLM: [`v2/Companion_RouteC_推論時の構造劣化.md`](v2/Companion_RouteC_推論時の構造劣化.md), [`v2/Companion_RouteC_継続学習時の構造的忘却.md`](v2/Companion_RouteC_継続学習時の構造的忘却.md)
9. 資源項 \(M\): [`v2/補論_構造持続における資源項Mの操作的定式化.md`](v2/補論_構造持続における資源項Mの操作的定式化.md)
10. 既存理論 bridge: [`v2/補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み.md`](v2/補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み.md), [`v2/補論_非CSP古典例における構造持続の収支原理の最小アンカー.md`](v2/補論_非CSP古典例における構造持続の収支原理の最小アンカー.md)
11. Lean / 詳細補論: [`lean/PAPER_MAPPING.md`](lean/PAPER_MAPPING.md), [`v2/補論_構造持続の条件つき導出.md`](v2/補論_構造持続の条件つき導出.md), [`v2/補論_構造持続における許容写像と階層的不変量.md`](v2/補論_構造持続における許容写像と階層的不変量.md), [`v2/補論_構造持続の収支原理の詳細展開.md`](v2/補論_構造持続の収支原理の詳細展開.md)

### Logical dependency order

1. [`v2/1_構造持続の最小形式.md`](v2/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.md)
2. [`v2/2_構造持続の収支原理.md`](v2/2_構造持続の収支原理.md)
3. [`v2/補論_構造持続の条件つき導出.md`](v2/補論_構造持続の条件つき導出.md)

## Supplements / 補論・補助資料

補論は主張の中心ではなく、補助的な位置づけです。ただし構成地図と運用規律は、読者導線と誤読防止のために前に出しています。

- [`v2/補論_構造持続理論の構成地図.md`](v2/補論_構造持続理論の構成地図.md)
- [`v2/補論_構造持続理論の運用規律.md`](v2/補論_構造持続理論の運用規律.md)
- [`v2/補論_有限CSPにおける構造持続の予測力.md`](v2/%E8%A3%9C%E8%AB%96_%E6%9C%89%E9%99%90CSP%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E4%BA%88%E6%B8%AC%E5%8A%9B.md)
- [`v2/補論_構造持続における資源項Mの操作的定式化.md`](v2/補論_構造持続における資源項Mの操作的定式化.md)
- [`v2/補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み.md`](v2/補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み.md)
- [`v2/補論_非CSP古典例における構造持続の収支原理の最小アンカー.md`](v2/補論_非CSP古典例における構造持続の収支原理の最小アンカー.md)
- [`v2/補論_構造持続の条件つき導出.md`](v2/補論_構造持続の条件つき導出.md)
- [`v2/補論_構造持続の収支原理の詳細展開.md`](v2/補論_構造持続の収支原理の詳細展開.md)
- [`v2/補論_構造持続写像の標準手順.md`](v2/%E8%A3%9C%E8%AB%96_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E5%86%99%E5%83%8F%E3%81%AE%E6%A8%99%E6%BA%96%E6%89%8B%E9%A0%86.md)
- [`v2/補論_構造持続の集合値力学的表現と符号付き指数核.md`](v2/補論_構造持続の集合値力学的表現と符号付き指数核.md)
- [`v2/補論_構造持続における許容写像と階層的不変量.md`](v2/補論_構造持続における許容写像と階層的不変量.md)
- [`v2/補論_計算コストの構造的予測.md`](v2/%E8%A3%9C%E8%AB%96_%E8%A8%88%E7%AE%97%E3%82%B3%E3%82%B9%E3%83%88%E3%81%AE%E6%A7%8B%E9%80%A0%E7%9A%84%E4%BA%88%E6%B8%AC.md)

## Repository Structure / リポジトリ構成

```text
delta-survival-paper/
  v2/             core papers, companion papers, supplements, PDF sources
  v1/             older archived versions
  lean/           Lean 4 formal verification
  analysis/       SAT / LLM / frontier experiment analyses
  data/           raw data and summaries
  README.md
  OVERVIEW.md
```

## Formal Verification / 形式検証

Lean formalization is in [`lean/`](lean/). Current status:
`151 Survival modules`, `sorry = 0`, `axiom = 0`.

The current core layering includes:

- `LogUniqueness.lean`: Paper 1 §3 の対数比一意性
- `TelescopingExp.lean`: 条件つき導出補論 §3 の A1–A2 望遠鏡積恒等式
- `AxiomsToExp.lean`: 独立制約モデルからの指数形
- `WeakDependence.lean`: 弱依存下の境界
- `SATStateDependentCountChernoffKLAlgebra.lean`: actual 3-SAT clause-exposure path measure から Chernoff/KL collapse bound まで
- `BernoulliCSPPathCollapse.lean` / `KSATChernoffCollapse.lean`: Bernoulli bad-event CSP と random k-SAT への operational collapse wrapper
- `BernoulliTypicalSigma.lean`: Bernoulli-CSP の cumulative production を \(\Sigma\) として読む reader-facing lower-tail / good-event lower-bound / typical-growth / endpoint-defect coarse-transfer / expectation wrapper
- `BernoulliAdmissibleMapV0.lean`: Bernoulli-CSP coarse \(\Sigma\) transfer を発火させる endpoint identity / defect budget / coarse monotonicity の十分条件 wrapper
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
- `NumericalSanityChecks.lean`: k-SAT / NAE-SAT / XOR-SAT / q-coloring / forbidden-pattern wrappers が小さな具体例で `log(8/7)`, `log(4/3)`, `log 2` などを回復する documented sanity layer
- `LyapunovBalanceEmbedding.lean`: Foster-Lyapunov / queueing drift を構造持続の収支原理の \(b_t,B_n,R_t,d_t,r_t\) へ埋め込む G6-c minimal algebraic embedding
- `FosterLyapunovTemplate.lean`: Phase 6.1 の reader-facing wrapper。Lyapunov / queueing / conditional-Azuma / resource-bounded high-probability / coarse-transfer anchors を束ねるが、positive recurrence, geometric ergodicity, Bernoulli-style pathwise nondecrease, unconditional Lyapunov second law は主張しない。
- Phase 6.1 template: [`analysis/phase6_foster_lyapunov_template.md`](analysis/phase6_foster_lyapunov_template.md) records how the Bernoulli-CSP \(\Sigma\) template should transfer to Foster-Lyapunov / queueing without claiming positive recurrence, geometric ergodicity, pathwise monotonicity, or an unconditional Lyapunov second law.
- `RepairMaintenanceTemplate.lean`: Phase 6.2 の reader-facing wrapper。damage / repair finite-prefix algebra, \(\Sigma\) / repair-cost grammar, resource-bounded stopped-collapse / hitting-time certificate route, and conditional coarse transfer を束ねるが、stochastic reliability theorem, optimal maintenance policy, Bernoulli-style pathwise nondecrease, unconditional repair law は主張しない。
- Phase 6.2 template: [`analysis/phase6_repair_maintenance_template.md`](analysis/phase6_repair_maintenance_template.md) records repair-maintenance as the third limited class template after Bernoulli-CSP and Foster-Lyapunov / queueing.
- `CrossClassUnificationV0.lean`: Phase 7 v0 の registry。Bernoulli-CSP / Foster-Lyapunov / Repair-Maintenance の三つが \(\Sigma\) grammar, expectation-level tendency, high-probability certificate, conditional coarse transfer を共有することを機械登録するが、generic universal theorem や necessary/sufficient characterization は主張しない。
- Phase 7 v0 registry: [`analysis/phase7_cross_class_unification_v0.md`](analysis/phase7_cross_class_unification_v0.md) records the first cross-class profile after the three limited templates.
- `CrossClassUnificationV1.lean`: Phase 7 v1 の schema extraction。ordered \(\Sigma\) carrier, nonnegative tendency driver, finite-horizon certificate route, admissible-transfer guard を共通形として登録するが、subadditivity や Bernoulli-style pathwise nondecrease を generic requirement にはしない。
- Phase 7 v1 schema: [`analysis/phase7_unifying_schema_v1.md`](analysis/phase7_unifying_schema_v1.md) records the first generic statement candidate after the v0 registry.
- `CrossClassUnificationV2.lean`: Phase 7 v2 の interface / registered-instance closure。v1 schema を interface として切り出し、三つの登録済み limited class が instance として載ることを機械登録する。
- Phase 7 v2 common interface: [`analysis/phase7_unifying_schema_v2.md`](analysis/phase7_unifying_schema_v2.md) records the common-interface registration after the v1 schema extraction.
- 仕様固定・条件付き構造埋め込み skeletons: 11 small Lean modules grouped into five finite-prefix forms: multiplicative/exponential survival, linear overload, cumulative-capacity thresholds, critical-parameter thresholds, and explicit repair / maintenance balance. Detailed module-to-claim mapping is kept in [`lean/PAPER_MAPPING.md`](lean/PAPER_MAPPING.md).

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
