# Overview

このリポジトリは、構造持続理論に関する `v2` の主理論 spine 2 本、統合版、Route C companion 2 本、および補論群を中心に読むための構成です。

## English Entry Points

- Start here: [`v2/pdf用/ENGLISH_ABSTRACT.pdf`](v2/pdf%E7%94%A8/ENGLISH_ABSTRACT.pdf)
- Longer English note: [`ENGLISH_OVERVIEW.md`](ENGLISH_OVERVIEW.md)

## Japanese Entry Point

全体像を先に掴むための統合版:

- [`v2/0_構造持続理論の統合版.md`](v2/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.md)
- [`v2/pdf用/0_構造持続理論の統合版.pdf`](v2/pdf%E7%94%A8/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.pdf)

## Architecture And Discipline

- [`v2/補論_構造持続理論の構成地図.md`](v2/補論_構造持続理論の構成地図.md)
  主理論 spine、companion papers、補論群、Lean 形式化、実証アンカーを層として読むための構成地図。
- [`v2/補論_構造持続理論の運用規律.md`](v2/補論_構造持続理論の運用規律.md)
  探索的写像、凍結検証、Route / G6 / support / no-support / silence の判定語彙。

## Main Theory Spine

1. [`v2/1_構造持続の最小形式.md`](v2/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.md)
   最小形式。事前固定された構造維持問題に対する表現定理として、構造を維持できる状態集合の縮小から指数型が現れることを与える。現行版では A2 の対数比形を公理的に特徴づけ、適用可能性条件と事後的表現選択による空虚化回避を明示している。
2. [`v2/2_構造持続の収支原理.md`](v2/2_構造持続の収支原理.md)
   構造持続の最小核 `S = M e^{-L}` を、回復を含む `S = M e^{-B}` へ拡張する短い原理论文。

条件つき導出と弱依存境界は、主線から外して [`v2/補論_構造持続の条件つき導出.md`](v2/補論_構造持続の条件つき導出.md) に置いています。

## Route C Companion Anchors

1. [`v2/Companion_RouteC_推論時の構造劣化.md`](v2/Companion_RouteC_推論時の構造劣化.md)
   推論時の未整理矛盾と外部代謝。
2. [`v2/Companion_RouteC_継続学習時の構造的忘却.md`](v2/Companion_RouteC_継続学習時の構造的忘却.md)
   継続学習における前提更新と構造的忘却。

## PDFs

- [`v2/pdf用/1_構造持続の最小形式.pdf`](v2/pdf%E7%94%A8/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.pdf)
- [`v2/pdf用/補論_構造持続の条件つき導出.pdf`](v2/pdf用/補論_構造持続の条件つき導出.pdf)
- [`v2/pdf用/2_構造持続の収支原理.pdf`](v2/pdf用/2_構造持続の収支原理.pdf)
- [`v2/pdf用/Companion_RouteC_推論時の構造劣化.pdf`](v2/pdf用/Companion_RouteC_推論時の構造劣化.pdf)
- [`v2/pdf用/Companion_RouteC_継続学習時の構造的忘却.pdf`](v2/pdf用/Companion_RouteC_継続学習時の構造的忘却.pdf)

Latest OSF mirror (Bernoulli-CSP links are the v1.1 archive snapshot):

- [Project overview](https://osf.io/mdh7b/overview)
- [Bernoulli CSP universality v1.1 theorem map](https://osf.io/mdh7b/files/osfstorage/69e71062e808d300ca9236c9)
- [Bernoulli CSP universality v1.1 update bundle (zip)](https://osf.io/mdh7b/files/osfstorage/69e71087f4653a8fbfb0001a)
- [SAT chain v1.0 theorem map](https://osf.io/mdh7b/files/osfstorage/69e7007ce808d300ca9230f2)
- [SAT chain v1.0 update bundle (zip)](https://osf.io/mdh7b/files/osfstorage/69e7007e01466b7c85fd83fb)
- [Paper 1](https://osf.io/mdh7b/files/osfstorage/69dde399e43067989d1187e1)
- [Conditional derivation supplement](https://osf.io/mdh7b/files/osfstorage/69dde4faa17296e9bb3e7a3b)
- [Route C companion I](https://osf.io/mdh7b/files/osfstorage/69dde3bde1158f542e3e7aec)
- [Route C companion II](https://osf.io/mdh7b/files/osfstorage/69dde3c0cc45911aa117d84c)

## What Is Secondary

以下は補助資料です。

- `v1/`: 旧版アーカイブ
- `v2/補論_*`: 補論

## Data and Proof

- Data: [`DATA.md`](DATA.md)
- Reproduction: [`REPRODUCE.md`](REPRODUCE.md)
- Lean formalization: [`lean/readme.md`](lean/readme.md)
- Reader-facing theorem map: [`lean/PAPER_MAPPING.md`](lean/PAPER_MAPPING.md)

Mixed-CSP の true outside-group rerun は requested set が完了しており、3 名の外部実行者がそれぞれ `12000` 行 primary run、`0` checked core mismatches、support flags 全 true を返している。これは Mixed-CSP package に限った replication closure であり、詳細は [`analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md`](analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md) を参照。

Exp43c q-coloring についても、3 名の外部実行者が同じ frozen package を再実行し、それぞれ `4000` 行 primary run、`0` checked core mismatches、`TIMEOUT = 0`、`MALFORMED = 0`、および同じ qualitative support decision を返している。これは Exp43c package に限った replication closure であり、詳細は [`analysis/exp43_qcoloring/exp43c_true_outside_final_report.md`](analysis/exp43_qcoloring/exp43c_true_outside_final_report.md) を参照。二つの Route A package をまとめた概要は [`analysis/g7_route_a_true_outside_replication_summary.md`](analysis/g7_route_a_true_outside_replication_summary.md) に置いている。

現在の Lean 側は `139 Survival modules`、`sorry = 0`、`axiom = 0` の状態で、最小形式、弱依存、粗視化、停止時刻崩壊、有限状態 Markov 例、SAT/k-SAT Chernoff-KL chain、固定割当 NAE-SAT / XOR-SAT exposure instance、固定 coloring の q-coloring edge exposure instance、finite-alphabet forbidden-pattern CSP instance、hypergraph-coloring specialization、multi-forbidden-pattern witness bridge、exactly-one-SAT witness specialization、exactly-`r` cardinality-SAT family specialization、at-most / at-least threshold cardinality-SAT specialization、numerical sanity checks、さらに Route A 非CSP skeletons（指数型、線形過負荷型、累積容量型、臨界パラメータ型）までを含む。SAT/k-SAT の finite-horizon / iid Bernoulli bad-event exposure は **SAT chain v1.0**、横断的な Bernoulli-CSP 層は **Bernoulli CSP universality v1.2** としてローカルに凍結している。OSF mirror は現時点では v1.1 archive snapshot を指している。
