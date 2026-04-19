# OSF / Zenodo Upload Plan

最終更新: 2026-04-19

このメモは、`delta-survival-paper` の公開物を OSF / Zenodo に反映するときの最小セットを固定するためのものです。2026-04-19 の更新では、Paper 1 §3 の対数比の一意性定理（A2 の特徴づけ）と Lean 側の `LogUniqueness.lean` の反映に伴い、bundle を `2026-04-19` に差し替えています。2026-04-16 版は `osf_zenodo_latest_2026-04-16/` としてローカルには残しています。

現在の公開反映状況は次のとおりです。

- GitHub: 反映済み
- Codeberg: 反映済み
- OSF: 未反映
- Zenodo: 未反映

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

## 推奨アップロード単位

最新の最小公開単位は、次の bundle です。

- ローカル bundle: `/Users/sunagawa/Project/delta-survival-export/osf_zenodo_latest_2026-04-19/`
- zip: `/Users/sunagawa/Project/delta-survival-export/osf_zenodo_latest_2026-04-19.zip`

## 推奨ファイル構成

### Core PDFs

- `00_structural_persistence_integrated_overview_ja_2026-04-19.pdf`
- `01_structural_persistence_minimal_form_ja_2026-04-19.pdf`
- `02_structural_persistence_conditional_derivation_ja_2026-04-19.pdf`
- `03_structural_persistence_reasoning_degradation_ja_2026-04-19.pdf`
- `04_structural_persistence_catastrophic_forgetting_ja_2026-04-19.pdf`
- `90_structural_prediction_of_computational_cost_ja_2026-04-19.pdf`
- `98_structural_persistence_english_abstract_2026-04-19.pdf`

### Supporting indexes

- `99_structural_persistence_english_overview_2026-04-19.md`
- `ARCHIVE_README_2026-04-19.md`
- `PUBLICATION_DATA_INDEX_2026-04-19.md`
- `CITATION.cff`
- `PATENT_NOTICE_2026-04-19.md`
- `LEAN_FORMALIZATION_NOTE_2026-04-19.md`
- `LICENSE_2026-04-19.txt`
- `PACKAGE_MANIFEST_2026-04-19.md`

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

- Core PDFs 一式
- `98_structural_persistence_english_abstract_2026-04-19.pdf`
- `99_structural_persistence_english_overview_2026-04-19.md`
- `ARCHIVE_README_2026-04-19.md`
- `CITATION.cff`
- `PATENT_NOTICE_2026-04-19.md`
- `LEAN_FORMALIZATION_NOTE_2026-04-19.md`
- `LICENSE_2026-04-19.txt`

`PUBLICATION_DATA_INDEX_2026-04-19.md` と `PACKAGE_MANIFEST_2026-04-19.md` は OSF 側の補助導線として扱う。

## ソース対応表

| Bundle file | Source |
|---|---|
| `00_structural_persistence_integrated_overview_ja_2026-04-19.pdf` | `v2/pdf用/0_構造持続理論の統合版.pdf` |
| `01_structural_persistence_minimal_form_ja_2026-04-19.pdf` | `v2/pdf用/1_構造持続の最小形式.pdf` |
| `02_structural_persistence_conditional_derivation_ja_2026-04-19.pdf` | `v2/pdf用/2_構造持続の条件つき導出.pdf` |
| `03_structural_persistence_reasoning_degradation_ja_2026-04-19.pdf` | `v2/pdf用/3_構造持続と推論性能の劣化.pdf` |
| `04_structural_persistence_catastrophic_forgetting_ja_2026-04-19.pdf` | `v2/pdf用/4_構造持続と継続学習における破滅的忘却.pdf` |
| `90_structural_prediction_of_computational_cost_ja_2026-04-19.pdf` | `v2/pdf用/補論_計算コストの構造的予測.pdf` |
| `98_structural_persistence_english_abstract_2026-04-19.pdf` | `v2/pdf用/ENGLISH_ABSTRACT.pdf` |
| `99_structural_persistence_english_overview_2026-04-19.md` | `ENGLISH_OVERVIEW.md` |
| `ARCHIVE_README_2026-04-19.md` | `README.md` |
| `PUBLICATION_DATA_INDEX_2026-04-19.md` | `DATA.md` |
| `PATENT_NOTICE_2026-04-19.md` | `PATENTS.md` |
| `LEAN_FORMALIZATION_NOTE_2026-04-19.md` | `LEAN_FORMALIZATION_README.md` |
| `LICENSE_2026-04-19.txt` | `LICENSE` |
| `PACKAGE_MANIFEST_2026-04-19.md` | generated during bundle assembly |

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
   ローカル: `/Users/sunagawa/Project/delta-survival-export/osf_zenodo_latest_2026-04-19/`
7. 最上位で見せたいファイルを確認する  
   - `00_structural_persistence_integrated_overview_ja_2026-04-19.pdf`
   - `98_structural_persistence_english_abstract_2026-04-19.pdf`
   - `99_structural_persistence_english_overview_2026-04-19.md`
8. `PATENT_NOTICE_2026-04-19.md` と `LEAN_FORMALIZATION_NOTE_2026-04-19.md` が閲覧可能であることを確認する
9. 公開後に恒久リンクを控える

## OSF Post-Upload Checklist

- Project title が正しい
- Description / abstract が反映されている
- Keywords が反映されている
- 先頭で見せたい 3 ファイルが閲覧できる
- `PATENT_NOTICE_2026-04-19.md` が見える
- `LEAN_FORMALIZATION_NOTE_2026-04-19.md` が見える
- `LICENSE_2026-04-19.txt` が見える
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
