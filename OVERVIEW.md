# Overview

このリポジトリは、構造持続理論に関する `v2` の構成地図、統合版、主理論 spine 2 本、運用規律、仕様固定構造層 / 構造推定層の検証アンカー、および補論群を中心に読むための構成です。

仕様固定構造層、条件付き構造埋め込み層、構造推定層は強弱の直線的序列ではなく、同一の構造持続核を異なる観測可能性のもとで扱うための層です。

| 外向け名 | 旧内部名 | 読み方 |
|---|---|---|
| 仕様固定構造層 | Route A | 構造、測度、境界を仕様から直接固定できる |
| 条件付き構造埋め込み層 | Route B | 既存理論の drift / 差分 / 停止境界を条件付きに写す |
| 構造推定層 | Route C | 構造を直接数えず、代理指標と凍結検証で推定する |

## English Entry Points

- Start here: [`v2/pdf用/ENGLISH_ABSTRACT.pdf`](v2/pdf%E7%94%A8/ENGLISH_ABSTRACT.pdf)
- Longer English note: [`ENGLISH_OVERVIEW.md`](ENGLISH_OVERVIEW.md)

## Recommended Public Order

外向けには、次の順に読むのが最も迷いにくいです。これは表示順であり、理論上の主論文番号は `v2/1` -> `v2/2` のままです。

1. 構成地図: [`v2/補論_構造持続理論の構成地図.md`](v2/補論_構造持続理論の構成地図.md)
2. 統合版: [`v2/0_構造持続理論の統合版.md`](v2/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.md)
3. 最小形式: [`v2/1_構造持続の最小形式.md`](v2/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.md)
4. 収支原理: [`v2/2_構造持続の収支原理.md`](v2/2_構造持続の収支原理.md)
5. 運用規律: [`v2/補論_構造持続理論の運用規律.md`](v2/補論_構造持続理論の運用規律.md)
6. 仕様固定構造層 / 有限CSP: [`v2/補論_有限CSPにおける構造持続の予測力.md`](v2/%E8%A3%9C%E8%AB%96_%E6%9C%89%E9%99%90CSP%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E4%BA%88%E6%B8%AC%E5%8A%9B.md)
7. 構造推定層 / LLM: [`v2/Companion_RouteC_推論時の構造劣化.md`](v2/Companion_RouteC_推論時の構造劣化.md), [`v2/Companion_RouteC_継続学習時の構造的忘却.md`](v2/Companion_RouteC_継続学習時の構造的忘却.md)
8. 資源項 \(M\): [`v2/補論_構造持続における資源項Mの操作的定式化.md`](v2/補論_構造持続における資源項Mの操作的定式化.md)
9. 既存理論 bridge: [`v2/補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み.md`](v2/補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み.md), [`v2/補論_非CSP古典例における構造持続の収支原理の最小アンカー.md`](v2/補論_非CSP古典例における構造持続の収支原理の最小アンカー.md)
10. Lean / 詳細補論: [`lean/PAPER_MAPPING.md`](lean/PAPER_MAPPING.md), [`v2/補論_構造持続の条件つき導出.md`](v2/補論_構造持続の条件つき導出.md), [`v2/補論_構造持続における許容写像と階層的不変量.md`](v2/補論_構造持続における許容写像と階層的不変量.md), [`v2/補論_構造持続の収支原理の詳細展開.md`](v2/補論_構造持続の収支原理の詳細展開.md)

## Japanese Entry Point

全体像を先に掴むための入口:

- [`v2/補論_構造持続理論の構成地図.md`](v2/補論_構造持続理論の構成地図.md)
- [`v2/0_構造持続理論の統合版.md`](v2/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.md)
- [`v2/pdf用/補論_構造持続理論の構成地図.pdf`](v2/pdf用/補論_構造持続理論の構成地図.pdf)
- [`v2/pdf用/0_構造持続理論の統合版.pdf`](v2/pdf%E7%94%A8/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.pdf)

## Architecture And Discipline

- [`v2/補論_構造持続理論の構成地図.md`](v2/補論_構造持続理論の構成地図.md)
  主理論 spine、companion papers、補論群、Lean 形式化、実証アンカーを層として読むための構成地図。
- [`v2/補論_構造持続理論の運用規律.md`](v2/補論_構造持続理論の運用規律.md)
  探索的写像、凍結検証、構造観測可能性の層 / G6 / support / no-support / silence の判定語彙。

## Main Theory Spine

1. [`v2/1_構造持続の最小形式.md`](v2/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.md)
   最小形式。事前固定された構造維持問題に対する表現定理として、構造を維持できる状態集合の縮小から指数型が現れることを与える。現行版では A2 の対数比形を公理的に特徴づけ、適用可能性条件と事後的表現選択による空虚化回避を明示している。
2. [`v2/2_構造持続の収支原理.md`](v2/2_構造持続の収支原理.md)
   構造持続の最小核 `S = M e^{-L}` を、回復を含む `S = M e^{-B}` へ拡張する短い原理论文。

条件つき導出と弱依存境界は、主線から外して [`v2/補論_構造持続の条件つき導出.md`](v2/補論_構造持続の条件つき導出.md) に置いています。

## LLM Companion Anchors

1. [`v2/Companion_RouteC_推論時の構造劣化.md`](v2/Companion_RouteC_推論時の構造劣化.md)
   推論時の未整理矛盾と外部代謝。
2. [`v2/Companion_RouteC_継続学習時の構造的忘却.md`](v2/Companion_RouteC_継続学習時の構造的忘却.md)
   継続学習における前提更新と構造的忘却。

## PDFs

- [`v2/pdf用/補論_構造持続理論の構成地図.pdf`](v2/pdf用/補論_構造持続理論の構成地図.pdf)
- [`v2/pdf用/0_構造持続理論の統合版.pdf`](v2/pdf%E7%94%A8/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.pdf)
- [`v2/pdf用/1_構造持続の最小形式.pdf`](v2/pdf%E7%94%A8/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.pdf)
- [`v2/pdf用/2_構造持続の収支原理.pdf`](v2/pdf用/2_構造持続の収支原理.pdf)
- [`v2/pdf用/補論_構造持続理論の運用規律.pdf`](v2/pdf用/補論_構造持続理論の運用規律.pdf)
- [`v2/pdf用/補論_有限CSPにおける構造持続の予測力.pdf`](v2/pdf用/補論_有限CSPにおける構造持続の予測力.pdf)
- [`v2/pdf用/Companion_RouteC_推論時の構造劣化.pdf`](v2/pdf用/Companion_RouteC_推論時の構造劣化.pdf)
- [`v2/pdf用/Companion_RouteC_継続学習時の構造的忘却.pdf`](v2/pdf用/Companion_RouteC_継続学習時の構造的忘却.pdf)
- [`v2/pdf用/補論_構造持続における資源項Mの操作的定式化.pdf`](v2/pdf用/補論_構造持続における資源項Mの操作的定式化.pdf)
- [`v2/pdf用/補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み.pdf`](v2/pdf用/補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み.pdf)
- [`v2/pdf用/補論_非CSP古典例における構造持続の収支原理の最小アンカー.pdf`](v2/pdf用/補論_非CSP古典例における構造持続の収支原理の最小アンカー.pdf)
- [`v2/pdf用/補論_構造持続の条件つき導出.pdf`](v2/pdf用/補論_構造持続の条件つき導出.pdf)
- [`v2/pdf用/補論_構造持続における許容写像と階層的不変量.pdf`](v2/pdf用/補論_構造持続における許容写像と階層的不変量.pdf)
- [`v2/pdf用/補論_構造持続の収支原理の詳細展開.pdf`](v2/pdf用/補論_構造持続の収支原理の詳細展開.pdf)

Latest OSF mirror (Bernoulli-CSP links are the v1.1 archive snapshot):

- [Project overview](https://osf.io/mdh7b/overview)
- [Bernoulli CSP universality v1.1 theorem map](https://osf.io/mdh7b/files/osfstorage/69e71062e808d300ca9236c9)
- [Bernoulli CSP universality v1.1 update bundle (zip)](https://osf.io/mdh7b/files/osfstorage/69e71087f4653a8fbfb0001a)
- [SAT chain v1.0 theorem map](https://osf.io/mdh7b/files/osfstorage/69e7007ce808d300ca9230f2)
- [SAT chain v1.0 update bundle (zip)](https://osf.io/mdh7b/files/osfstorage/69e7007e01466b7c85fd83fb)
- [Paper 1](https://osf.io/mdh7b/files/osfstorage/69dde399e43067989d1187e1)
- [Conditional derivation supplement](https://osf.io/mdh7b/files/osfstorage/69dde4faa17296e9bb3e7a3b)
- [LLM companion I](https://osf.io/mdh7b/files/osfstorage/69dde3bde1158f542e3e7aec)
- [LLM companion II](https://osf.io/mdh7b/files/osfstorage/69dde3c0cc45911aa117d84c)

## What Is Secondary

以下は補助資料です。

- `v1/`: 旧版アーカイブ
- その他の `v2/補論_*`: 深部補論・技術補論

## Data and Proof

- Data: [`DATA.md`](DATA.md)
- Reproduction: [`REPRODUCE.md`](REPRODUCE.md)
- Lean formalization: [`lean/readme.md`](lean/readme.md)
- Reader-facing theorem map: [`lean/PAPER_MAPPING.md`](lean/PAPER_MAPPING.md)
- Hierarchical-invariants roadmap: [`analysis/second_law_level_roadmap.md`](analysis/second_law_level_roadmap.md)

Mixed-CSP の true outside-group rerun は requested set が完了しており、3 名の外部実行者がそれぞれ `12000` 行 primary run、`0` checked core mismatches、support flags 全 true を返している。これは Mixed-CSP package に限った replication closure であり、詳細は [`analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md`](analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md) を参照。

Exp43c q-coloring についても、3 名の外部実行者が同じ frozen package を再実行し、それぞれ `4000` 行 primary run、`0` checked core mismatches、`TIMEOUT = 0`、`MALFORMED = 0`、および同じ qualitative support decision を返している。これは Exp43c package に限った replication closure であり、詳細は [`analysis/exp43_qcoloring/exp43c_true_outside_final_report.md`](analysis/exp43_qcoloring/exp43c_true_outside_final_report.md) を参照。二つの仕様固定構造層 package をまとめた概要は [`analysis/g7_route_a_true_outside_replication_summary.md`](analysis/g7_route_a_true_outside_replication_summary.md) に置いている。

現在の Lean 側は `145 Survival modules`、`sorry = 0`、`axiom = 0` の状態で、最小形式、弱依存、粗視化、停止時刻崩壊、有限状態 Markov 例、SAT/k-SAT Chernoff-KL chain、Bernoulli-CSP \(\Sigma\) lower-tail / good-event lower-bound / typical-growth wrapper、固定割当 NAE-SAT / XOR-SAT exposure instance、固定 coloring の q-coloring edge exposure instance、finite-alphabet forbidden-pattern CSP instance、hypergraph-coloring specialization、multi-forbidden-pattern witness bridge、exactly-one-SAT witness specialization、exactly-`r` cardinality-SAT family specialization、at-most / at-least threshold cardinality-SAT specialization、numerical sanity checks、さらに仕様固定・条件付き構造埋め込み skeletons（指数型、線形過負荷型、累積容量型、臨界パラメータ型）までを含む。SAT/k-SAT の finite-horizon / iid Bernoulli bad-event exposure は **SAT chain v1.0**、横断的な Bernoulli-CSP 層は **Bernoulli CSP universality v1.2** としてローカルに凍結している。OSF mirror は現時点では v1.1 archive snapshot を指している。
