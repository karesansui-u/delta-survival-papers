# OSF / Zenodo Upload Plan

最終更新: 2026-05-27

このメモは、`delta-survival-paper` の公開物を OSF / Zenodo に反映するときの最小セットを固定するためのものです。2026-04-28 の更新では、Paper 1 / Paper 2 を主理論 spine として整えたうえで、v2 本体、補論、LLM companion、Lean 対応表、公開導線を `v2_spine_2026-04-28` として OSF に反映しています。2026-04-19 版以前の bundle は履歴 snapshot として扱います。

現在の公開反映状況は次のとおりです。

- GitHub: 反映済み
- Codeberg: 反映済み
- OSF: 2026-04-21 SAT chain v1.0 / Bernoulli CSP universality v1.1 update bundle 反映済み。2026-04-28 Mixed-CSP true outside-group rerun final bundle、および v2 spine bundle 反映済み。2026-05-27 Lean epistemic-control bridge / baseline-comparison focused bundle 反映済み
- Zenodo: 未反映

ローカルでは、reader-facing theorem map を `lean/PAPER_MAPPING.md` に統合済み。Bernoulli CSP
universality v1.2 は multi-forbidden-pattern witness bridge、exactly-one-SAT、exactly-\(r\)
cardinality-SAT、at-most / at-least threshold cardinality-SAT までを含む。さらに仕様固定・条件付き構造埋め込み
skeletons は、指数型、線形過負荷型、累積容量型、臨界パラメータ型の四型分類に圧縮した。
SAT/CSP 系の個別 OSF 公開リンクは v1.1 archive snapshot を指す。v2 spine bundle では
`PAPER_MAPPING.md` を canonical map として同梱済み。

2026-04-21 反映:

- OSF folder: `sat_chain_v1_2026-04-21`
- theorem map: https://osf.io/mdh7b/files/osfstorage/69e7007ce808d300ca9230f2
- update bundle zip: https://osf.io/mdh7b/files/osfstorage/69e7007e01466b7c85fd83fb
- uploaded commit: `cb5a252` (`Freeze SAT/k-SAT Chernoff collapse chain`)

2026-04-21 Bernoulli-CSP v1.1 反映:

- OSF folder: `bernoulli_csp_v1_1_2026-04-21`
- theorem map: https://osf.io/mdh7b/files/osfstorage/69e71062e808d300ca9236c9
- update bundle zip: https://osf.io/mdh7b/files/osfstorage/69e71087f4653a8fbfb0001a
- uploaded commit: `99f9f6b` (`Freeze Bernoulli CSP universality v1.1`)
- uploaded tag: `bernoulli-csp-v1.1`

2026-04-28 Mixed-CSP true outside-group rerun final bundle 反映:

- OSF file: https://osf.io/download/69f01d8831a90752f1d4ae38/
- sha256: `91e72ea2fd6d56579e87e09b51d253969af7f79035ccb0d7ab2c9f2d8c6e6e09`
- uploaded commit: `8e63981` (Mixed-CSP outside rerun final bundle)
- scope: Mixed-CSP requested outside-group rerun set only; `3/3` completed, `3/3` clean success, `0` pending. This bundle predates the later Exp43c `3/3` outside-return completion and does not include Exp43c, observational-branch replication, or non-CSP repair-flow support.

2026-04-28 v2 spine bundle 反映:

- OSF folder: `v2_spine_2026-04-28`
- OSF folder link: https://osf.io/mdh7b/files/osfstorage/69f0aa156982d95c29f8c1d0
- update bundle zip: https://osf.io/mdh7b/files/osfstorage/69f0aac955cae29ef45db6b6
- update bundle download: https://osf.io/download/69f0aac955cae29ef45db6b6/
- manifest: https://osf.io/mdh7b/files/osfstorage/69f0aaeb6982d95c29f8c2c2
- uploaded source commit: `aef84d8` (`Refine observability terminology as layers`)
- included spine commit: `6fe9162` (`Align v2 paper spine and references`)
- sha256: `ad9b30effceb7d8f6eebebd888fdebf02b90defd8a155d7a5d2c0a9ab383a44c`
- manifest sha256: `6fb5e48086efbe2d698996f02e0431f2b972480a2494b9207a22ddcf378e1c9a`
- OSF file versions: zip v5, manifest v5
- scope: current v2 main theory spine, balance-principle supplements, conditional derivation supplement, LLM companions, Lean mapping, public overview, data index, patent notice, citation metadata, and license note. The manifest and public guides use the reader-facing order: construction map, integrated overview, Paper 1, Paper 2, operational discipline, specification-fixed finite-CSP layer, structural-inference LLM layer, resource term \(M\), existing-theory bridges, and Lean / technical details. The v5 refresh sharpens the reader-facing observability terminology to specification-fixed structural layer, conditional structural-embedding layer, and structural-inference layer.

2026-05-27 Lean epistemic-control bridge bundle 反映:

- OSF file: https://files.us.osf.io/v1/resources/mdh7b/providers/osfstorage/6a161bc474938d61d7cc7274
- archive: `lean_epistemic_control_bridge_2026-05-27_8a79fda.zip`
- source commit: `8a79fda07f12e8eebf24205e4a9a236bd42ec2fd`
- sha256: `83af14e2ec5ee0e3e8bdbbb123b18d049c760af97683d02985a78f1b9326f6f0`
- scope: focused Lean / documentation snapshot for the finite epistemic-control bridge stack, baseline-comparison layer, evidence-packet bridge, finite LLM-style toy layers, finite software-contract toy layers, and reader-facing claim boundaries. This is not a full `v3/` directory upload.

## Canonical Metadata Packet

以下を OSF / Zenodo の metadata 入力時の基準とする。

### Title

`Structural Persistence Theory: Reasoning Degradation, Catastrophic Forgetting, and Long-Horizon AI Coherence`

### Short Description

`This project collects preprints, data, and formalization for Structural Persistence Theory, a framework for describing long-horizon failure in language-model systems. The central hypothesis is that reasoning degradation in long conversations and catastrophic forgetting under continual learning may share the same structural mechanism: unresolved contradictions and premise-changing updates shrink the set of states that can still preserve coherent behavior over time. Here, “structure” does not mean generic form, but the relations, functions, and identity whose persistence is at issue in the system being studied. The project is therefore not only about giving long-horizon systems a persistent state; durable state is the substrate, while the stronger claim concerns explicit contradiction reduction and structural coherence maintenance.`

### Abstract

`Structural Persistence Theory is a framework for describing long-horizon failure in language-model systems. The central hypothesis is that reasoning degradation in long conversations and catastrophic forgetting under continual learning may share the same structural mechanism. In both cases, the set of states that can still preserve a target structure shrinks as unresolved contradictions or premise-changing updates accumulate. Here, “structure” does not mean generic form, but the relations, functions, and identity whose persistence is at issue in a given system. The theory is therefore about loss of persistence as that structure, not necessarily disappearance of the underlying substrate. It is not only a recipe for giving long-horizon systems a persistent state; durable state is the substrate, while the stronger claim concerns explicit contradiction reduction and structural coherence maintenance. At the theoretical core, structural loss is defined by the log-ratio of successive shrinkage in the set of states that can still sustain the structure. Under this representation, the remaining survivable region takes an exponential form. The project develops this idea theoretically, tests it empirically in inference-time and continual-learning settings, and explores its architectural implications. On the inference side, the experiments suggest that long-context degradation is not mainly a context-length problem, but a contradiction-management problem: externally organizing contradictory updates preserves coherence better than leaving the same contradictions unresolved. On the continual-learning side, the experiments suggest that LoRA-style sequential updating behaves more like overwrite than clean accumulation when dependency-linked knowledge must be reorganized after premise changes. The broader implication is that long-horizon intelligence may require more than prompt engineering or more training alone. This project therefore also explores external contradiction metabolism, multi-layer memory, premise-dependent reorganization, rollbackable state management, and persistent internal-model maintenance as design principles for durable AI systems and long-term AI partners.`

### Keywords

- structural persistence
- reasoning degradation
- catastrophic forgetting
- contradiction accumulation
- long-horizon coherence
- continual learning
- external contradiction metabolism
- rollbackable memory
- persistent intelligence
- LLM memory
- contradiction handling
- long-term AI partner

### Creator

- Akihito Sunagawa

### License

- Papers and prose: CC BY 4.0
- Code and formalization: Apache 2.0

### Related public references

- Repository overview: `README.md`
- Patent notice: `PATENTS.md`
- Lean formalization note: `LEAN_FORMALIZATION_README.md`
- Citation metadata: `CITATION.cff`

## 次回アップロード候補

次回更新が必要になった場合は、今回の `v2_spine_2026-04-28` を基準に差分 bundle を作る。

- `lean/PAPER_MAPPING.md` を唯一の reader-facing theorem map として同梱
- Phase 7 v2 の限定クラス統一 interface を差分として含める。対象ファイルは少なくとも `analysis/phase7_unifying_schema_v2.md`, `lean/Survival/CrossClassUnificationV2.lean`, `README.md`, `OVERVIEW.md`, `ENGLISH_ABSTRACT.md`, `ENGLISH_OVERVIEW.md`, `v2/pdf用/ENGLISH_ABSTRACT.pdf`, `lean/PAPER_MAPPING.md` とする。OSF / Zenodo の説明では、任意ドメインの単一普遍法則ではなく、registered limited classes instantiate a common structural-persistence interface として記述する。
- `README.md`, `OVERVIEW.md`, `LEAN_FORMALIZATION_README.md` の導線を `PAPER_MAPPING.md` に一本化
- 仕様固定・条件付き構造埋め込み skeletons は四型分類で説明し、個別ファイル一覧は `PAPER_MAPPING.md` に集約
- 旧 SAT/CSP map は現行 tree から外し、git history / OSF archive snapshot の扱いにする

## 現行アップロード単位

直近の公開済み最小単位は、次の bundle です。

- OSF folder: `v2_spine_2026-04-28`
- zip: `v2_spine_2026-04-28.zip`
- local staging bundle: `/tmp/delta-survival-osf/v2_spine_2026-04-28/`
- local staging zip: `/tmp/delta-survival-osf/v2_spine_2026-04-28.zip`

## 推奨ファイル構成

### Reader-facing PDFs

外向けの表示順は、理論上の主論文番号ではなく読者導線を優先する。

- `10_structural_persistence_construction_map_supplement_ja_2026-04-28.pdf`
- `00_structural_persistence_integrated_overview_ja_2026-04-28.pdf`
- `01_structural_persistence_minimal_form_ja_2026-04-28.pdf`
- `02_structural_persistence_balance_principle_ja_2026-04-28.pdf`
- `11_structural_persistence_operational_discipline_supplement_ja_2026-04-28.pdf`
- `17_finite_csp_predictive_power_supplement_ja_2026-04-28.pdf`
- `05_llm_companion_inference_degradation_ja_2026-04-28.pdf`
- `06_llm_companion_continual_learning_forgetting_ja_2026-04-28.pdf`
- `13_resource_term_M_operational_formulation_supplement_ja_2026-04-28.pdf`
- `15_foster_lyapunov_drift_embedding_supplement_ja_2026-04-28.pdf`
- `16_non_csp_classical_examples_minimal_anchor_supplement_ja_2026-04-28.pdf`
- `04_structural_persistence_conditional_derivation_supplement_ja_2026-04-28.pdf`
- `03_structural_persistence_balance_details_supplement_ja_2026-04-28.pdf`
- `12_structural_persistence_mapping_procedure_supplement_ja_2026-04-28.pdf`
- `14_set_valued_dynamics_and_signed_exponential_kernel_supplement_ja_2026-04-28.pdf`
- `18_structural_prediction_of_computational_cost_supplement_ja_2026-04-28.pdf`
- `98_structural_persistence_english_abstract_2026-04-28.pdf`

### Supporting indexes

- `99_structural_persistence_english_overview_2026-04-28.md`
- `ARCHIVE_README_2026-04-28.md`
- `OVERVIEW_2026-04-28.md`
- `PUBLICATION_DATA_INDEX_2026-04-28.md`
- `LEAN_PAPER_MAPPING_2026-04-28.md`
- `CITATION_2026-04-28.cff`
- `PATENT_NOTICE_2026-04-28.md`
- `LEAN_FORMALIZATION_NOTE_2026-04-28.md`
- `LICENSE_2026-04-28.txt`
- `PACKAGE_MANIFEST_2026-04-28.md`
- `REPRODUCE_2026-04-28.md`
- `GIT_COMMIT_2026-04-28.txt`

## OSF に上げる推奨範囲

OSF には、上記 bundle 一式をそのまま上げる。

理由:

- PDF 本体
- 英語入口
- アーカイブ用 overview
- データ索引
- 特許 notice
- Lean formalization note
- license note

を一度に揃えられるため。

## Zenodo に上げる推奨範囲

Zenodo には、論文本体と英語入口を中心にした trimmed public bundle を上げる。OSF と同一の完全 mirror にはしない。

- Reader-facing PDFs 一式
- `98_structural_persistence_english_abstract_2026-04-28.pdf`
- `99_structural_persistence_english_overview_2026-04-28.md`
- `ARCHIVE_README_2026-04-28.md`
- `CITATION_2026-04-28.cff`
- `PATENT_NOTICE_2026-04-28.md`
- `LEAN_FORMALIZATION_NOTE_2026-04-28.md`
- `LEAN_PAPER_MAPPING_2026-04-28.md`
- `LICENSE_2026-04-28.txt`

`PUBLICATION_DATA_INDEX_2026-04-28.md` と `PACKAGE_MANIFEST_2026-04-28.md` は OSF 側の補助導線として扱う。

## ソース対応表

| Bundle file | Source |
|---|---|
| `00_structural_persistence_integrated_overview_ja_2026-04-28.pdf` | `v2/pdf用/0_構造持続理論の統合版.pdf` |
| `01_structural_persistence_minimal_form_ja_2026-04-28.pdf` | `v2/pdf用/1_構造持続の最小形式.pdf` |
| `02_structural_persistence_balance_principle_ja_2026-04-28.pdf` | `v2/pdf用/2_構造持続の収支原理.pdf` |
| `03_structural_persistence_balance_details_supplement_ja_2026-04-28.pdf` | `v2/pdf用/補論_構造持続の収支原理の詳細展開.pdf` |
| `04_structural_persistence_conditional_derivation_supplement_ja_2026-04-28.pdf` | `v2/pdf用/補論_構造持続の条件つき導出.pdf` |
| `05_llm_companion_inference_degradation_ja_2026-04-28.pdf` | `v2/pdf用/Companion_RouteC_推論時の構造劣化.pdf` |
| `06_llm_companion_continual_learning_forgetting_ja_2026-04-28.pdf` | `v2/pdf用/Companion_RouteC_継続学習時の構造的忘却.pdf` |
| `10_structural_persistence_construction_map_supplement_ja_2026-04-28.pdf` | `v2/pdf用/補論_構造持続理論の構成地図.pdf` |
| `11_structural_persistence_operational_discipline_supplement_ja_2026-04-28.pdf` | `v2/pdf用/補論_構造持続理論の運用規律.pdf` |
| `12_structural_persistence_mapping_procedure_supplement_ja_2026-04-28.pdf` | `v2/pdf用/補論_構造持続写像の標準手順.pdf` |
| `13_resource_term_M_operational_formulation_supplement_ja_2026-04-28.pdf` | `v2/pdf用/補論_構造持続における資源項Mの操作的定式化.pdf` |
| `14_set_valued_dynamics_and_signed_exponential_kernel_supplement_ja_2026-04-28.pdf` | `v2/pdf用/補論_構造持続の集合値力学的表現と符号付き指数核.pdf` |
| `15_foster_lyapunov_drift_embedding_supplement_ja_2026-04-28.pdf` | `v2/pdf用/補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み.pdf` |
| `16_non_csp_classical_examples_minimal_anchor_supplement_ja_2026-04-28.pdf` | `v2/pdf用/補論_非CSP古典例における構造持続の収支原理の最小アンカー.pdf` |
| `17_finite_csp_predictive_power_supplement_ja_2026-04-28.pdf` | `v2/pdf用/補論_有限CSPにおける構造持続の予測力.pdf` |
| `18_structural_prediction_of_computational_cost_supplement_ja_2026-04-28.pdf` | `v2/pdf用/補論_計算コストの構造的予測.pdf` |
| `98_structural_persistence_english_abstract_2026-04-28.pdf` | `v2/pdf用/ENGLISH_ABSTRACT.pdf` |
| `99_structural_persistence_english_overview_2026-04-28.md` | `ENGLISH_OVERVIEW.md` |
| `ARCHIVE_README_2026-04-28.md` | `README.md` |
| `OVERVIEW_2026-04-28.md` | `OVERVIEW.md` |
| `PUBLICATION_DATA_INDEX_2026-04-28.md` | `DATA.md` |
| `PATENT_NOTICE_2026-04-28.md` | `PATENTS.md` |
| `LEAN_FORMALIZATION_NOTE_2026-04-28.md` | `LEAN_FORMALIZATION_README.md` |
| `LEAN_PAPER_MAPPING_2026-04-28.md` | `lean/PAPER_MAPPING.md` |
| `LICENSE_2026-04-28.txt` | `LICENSE` |
| `CITATION_2026-04-28.cff` | `CITATION.cff` |
| `REPRODUCE_2026-04-28.md` | `REPRODUCE.md` |
| `PACKAGE_MANIFEST_2026-04-28.md` | generated during bundle assembly |
| `GIT_COMMIT_2026-04-28.txt` | generated during bundle assembly |

## 反映後に更新する場所

OSF / Zenodo への反映後は、必要に応じて以下を更新する。

- `README.md`
- `OVERVIEW.md`
- `DATA.md`

特に OSF / Zenodo の恒久リンクを公開導線に追加する場合は、主プレプリントの導線を壊さない範囲で最小限にとどめる。

## OSF Upload Sequence

OSF には、次の順で作業する。

1. Project title を設定する  
   `Structural Persistence Theory: Reasoning Degradation, Catastrophic Forgetting, and Long-Horizon AI Coherence`
2. Description / abstract を `Canonical Metadata Packet` の内容で入力する
3. Tags / keywords を入力する
4. License を設定する  
   - Papers and prose: CC BY 4.0  
   - Code and formalization: Apache 2.0
5. Contributors / creator 情報を確認する
6. bundle 一式を upload する  
   ローカル staging: `/tmp/delta-survival-osf/v2_spine_2026-04-28/`
7. 最上位で見せたいファイルを確認する  
   - `00_structural_persistence_integrated_overview_ja_2026-04-28.pdf`
   - `98_structural_persistence_english_abstract_2026-04-28.pdf`
   - `99_structural_persistence_english_overview_2026-04-28.md`
8. `PATENT_NOTICE_2026-04-28.md` と `LEAN_FORMALIZATION_NOTE_2026-04-28.md` が閲覧可能であることを確認する
9. 公開後に恒久リンクを控える

## OSF Post-Upload Checklist

- Project title が正しい
- Description / abstract が反映されている
- Keywords が反映されている
- 先頭で見せたい 3 ファイルが閲覧できる
- `PATENT_NOTICE_2026-04-28.md` が見える
- `LEAN_FORMALIZATION_NOTE_2026-04-28.md` が見える
- `LICENSE_2026-04-28.txt` が見える
- OSF project URL を控えた

## README / DATA への差し戻し

OSF 反映後に、必要なら次の更新を行う。

- `README.md`
  - integrated overview の OSF mirror を追加するか判断
  - English abstract / English overview の OSF 導線を追加するか判断
- `OVERVIEW.md`
  - 旧 OSF mirror 群を bundle 方針に合わせて更新するか判断
- `DATA.md`
  - bundle の zip や追加補助資料の導線を追記するか判断

公開導線は増やしすぎると読みにくくなるため、まずは OSF project 全体リンクを 1 本追加するだけでも十分。
