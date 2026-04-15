# OSF / Zenodo Upload Plan

最終更新: 2026-04-16

このメモは、`delta-survival-paper` の公開物を OSF / Zenodo に反映するときの最小セットを固定するためのものです。
現在の公開反映状況は次のとおりです。

- GitHub: 反映済み
- Codeberg: 反映済み
- OSF: 未反映
- Zenodo: 未反映

## 推奨アップロード単位

最新の最小公開単位は、次の bundle です。

- ローカル bundle: `/Users/sunagawa/Project/delta-survival-export/osf_zenodo_latest_2026-04-16/`
- zip: `/Users/sunagawa/Project/delta-survival-export/osf_zenodo_latest_2026-04-16.zip`

## 推奨ファイル構成

### Core PDFs

- `00_structural_persistence_integrated_overview_ja_2026-04-16.pdf`
- `01_structural_persistence_minimal_form_ja_2026-04-16.pdf`
- `02_structural_persistence_conditional_derivation_ja_2026-04-16.pdf`
- `03_structural_persistence_reasoning_degradation_ja_2026-04-16.pdf`
- `04_structural_persistence_catastrophic_forgetting_ja_2026-04-16.pdf`
- `90_structural_prediction_of_computational_cost_ja_2026-04-16.pdf`
- `98_structural_persistence_english_abstract_2026-04-16.pdf`

### Supporting indexes

- `99_structural_persistence_english_overview_2026-04-16.md`
- `README_repository_overview_2026-04-16.md`
- `DATA_index_2026-04-16.md`
- `CITATION.cff`
- `BUNDLE_MANIFEST.md`

## OSF に上げる推奨範囲

OSF には、上記 bundle 一式をそのまま上げる。

理由:

- PDF 本体
- 英語入口
- リポジトリ overview
- データ索引

を一度に揃えられるため。

## Zenodo に上げる推奨範囲

Zenodo には、まず次の最小セットを上げる。

- Core PDFs 一式
- `98_structural_persistence_english_abstract_2026-04-16.pdf`
- `99_structural_persistence_english_overview_2026-04-16.md`
- `CITATION.cff`

`DATA_index_2026-04-16.md` は添えてもよいが、Zenodo の主役は本文群と英語入口に置く。

## ソース対応表

| Bundle file | Source |
|---|---|
| `00_structural_persistence_integrated_overview_ja_2026-04-16.pdf` | `v2/pdf用/0_構造持続理論の統合版.pdf` |
| `01_structural_persistence_minimal_form_ja_2026-04-16.pdf` | `v2/pdf用/1_構造持続の最小形式.pdf` |
| `02_structural_persistence_conditional_derivation_ja_2026-04-16.pdf` | `v2/pdf用/2_構造持続の条件つき導出.pdf` |
| `03_structural_persistence_reasoning_degradation_ja_2026-04-16.pdf` | `v2/pdf用/3_構造持続と推論性能の劣化.pdf` |
| `04_structural_persistence_catastrophic_forgetting_ja_2026-04-16.pdf` | `v2/pdf用/4_構造持続と継続学習における破滅的忘却.pdf` |
| `90_structural_prediction_of_computational_cost_ja_2026-04-16.pdf` | `v2/pdf用/補論_計算コストの構造的予測.pdf` |
| `98_structural_persistence_english_abstract_2026-04-16.pdf` | `v2/pdf用/ENGLISH_ABSTRACT.pdf` |
| `99_structural_persistence_english_overview_2026-04-16.md` | `ENGLISH_OVERVIEW.md` |
| `README_repository_overview_2026-04-16.md` | `README.md` |
| `DATA_index_2026-04-16.md` | `DATA.md` |

## 反映後に更新する場所

OSF / Zenodo への反映後は、必要に応じて以下を更新する。

- `README.md`
- `OVERVIEW.md`
- `DATA.md`

特に OSF / Zenodo の恒久リンクを公開導線に追加する場合は、主プレプリントの導線を壊さない範囲で最小限にとどめる。
