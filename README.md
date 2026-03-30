# Delta-Survival Papers

Cumulative information loss δ (nats) as a unified coordinate
for structural collapse: theory, experiments, and formal verification.

累積的情報損失 δ（nats）を構造崩壊の統一座標とする理論・実験・形式検証。

## Status / ステータス

| Component | Status |
|---|---|
| Component | Status |
|---|---|
| Paper 1 — Structural Collapse | **Preprint v1.7** ([Zenodo](https://zenodo.org/records/19254667)) |
| Paper 2 — Existence vs Discovery | Preprint ([Zenodo](https://zenodo.org/records/18943573)) |
| Paper 3 — Cognitive Sleep for LLMs | **Preprint v2** ([Zenodo](https://zenodo.org/records/19322371)) |
| Lean 4 — Formal Verification | Complete (`sorry = 0`, `axiom = 0`) |
| OSF Project | [osf.io/mdh7b](https://osf.io/mdh7b/) |

**Key results:**
- Parameter-free prediction of XOR-SAT threshold ratio:
  α\_XOR / α\_random = 5.19×
  (observed 5.04 ± 0.25, CV = 5%).
- Second moment method (Paley–Zygmund) with pair correlation
  g(β) = 3/4 + (1/8)(1−β)³ explains 74% of the gap between
  the first-moment upper bound (α ≈ 5.19) and the true 3-SAT
  threshold (α ≈ 4.27).
- **Exp. 35 — Context rot is δ accumulation:**
  Under δ = 0, 5 high-capability models (4 vendors) maintain 100%
  accuracy up to 128K tokens — zero degradation. Llama 3.1:8b
  plateaus at 36%, confirming that δ = 0 sets an upper bound
  at μ rather than guaranteeing perfection. Under δ > 0, accuracy
  collapses across all 6 models. "Context rot" is driven by
  contradiction accumulation, not context length.

パラメータフリー予測: XOR-SAT閾値比
α\_XOR / α\_random = 5.19倍
（実測 5.04 ± 0.25、CV = 5%）。
第二モーメント法（Paley–Zygmund不等式）とペア相関関数
g(β) = 3/4 + (1/8)(1−β)³ により、
第一モーメント上界（α ≈ 5.19）と真の3-SAT閾値（α ≈ 4.27）の
差の74%を定量的に説明。
**実験35 — コンテキストロットはδの蓄積:**
δ = 0 下では高能力5モデル（4ベンダー）が128Kトークンまで
正答率100%を維持 — 劣化ゼロ。Llama 3.1:8bは36%に留まり、
δ = 0が完璧を保証するのではなくμを上限とすることを確認。
δ > 0 では全6モデルで精度が劣化。
「コンテキストロット」の原因はコンテキスト長ではなく矛盾の蓄積。

---

## What this is about / この研究について

When independent constraints each eliminate a fixed fraction of states,
the survival potential decays as `S = N_eff · (μ/μ_c) · e^(−δ)`.
This is a theorem (from three axioms), not a model choice.
The unit δ (nats) makes the collapse mechanism commensurable
across domains: SAT, LLM reasoning, nuclear stability, percolation.

独立な制約がそれぞれ固定割合の状態を除去するとき、
存続ポテンシャルは `S = N_eff · (μ/μ_c) · e^(−δ)` に従う。
これは3つの公理から導かれる定理であり、モデル選択ではない。
δ（nats）という単位により、
SAT・LLM推論・核安定性・パーコレーションといった
異なるドメインの崩壊メカニズムが同一座標上で比較可能になる。

---

## Papers / 論文

### Paper 1 — Structural Collapse as Information Loss / 構造崩壊と情報損失

**"Structural Collapse as Information Loss:
The Exponential Decay Mechanism under Accumulating Constraints"**

Three axioms (finite state space, fractional elimination, independence)
uniquely determine `S = N_eff · (μ/μ_c) · e^(−δ)`.
Validated on random 3-SAT and LLM reasoning collapse
(11 models, 5 vendors, 4B–70B+ parameters).
Extension to the second moment method with pair correlation function
quantitatively explains the gap between first-moment bound and true threshold.
Information-theoretic grounding established via KL divergence and
channel coding (structural capacity theorem: δ ≤ C\_struct ⟺ survival).
Exp. 35 (δ = 0 control, 6 models × 4 vendors × 500–128K tokens)
establishes that "context rot" is δ accumulation, not length degradation.
Llama 3.1:8b's 36% accuracy under δ = 0 confirms the multiplicative
structure S = μ · e^(−δ): baseline capability μ is the ceiling.

3つの公理（有限状態空間・割合除去・独立性）から
`S = N_eff · (μ/μ_c) · e^(−δ)` が一意に決まることを示し、
SAT および LLM 推論崩壊（11モデル・5ベンダー・4B–70B+パラメータ）で検証。
第二モーメント法とペア相関関数により第一モーメント上界と真の閾値の差を定量的に説明。
KLダイバージェンスおよびチャネルコーディングとの対応を通じた
情報理論的基盤を確立（構造容量定理：δ ≤ C\_struct ⟺ 存続）。
実験35（δ = 0対照群、6モデル×4ベンダー×500–128Kトークン）により、
「コンテキストロット」がδの蓄積であり長さの劣化ではないことを確立。
Llama 3.1:8bのδ = 0下での36%正答率は乗法構造S = μ · e^(−δ)を確認：
ベースライン能力μが天井となる。

- English: [`paper1/paper1_main.tex`](paper1/paper1_main.tex) / [PDF](paper1/paper1_main.pdf)
- 日本語: [`paper1/paper1_main_ja.tex`](paper1/paper1_main_ja.tex) / [PDF](paper1/paper1_main_ja.pdf)

### Paper 2 — Existence vs Discovery / 存在と発見の分離

**"Predicting Computational Cost from the Structural Parameter δ:
Separating Existence from Discovery in Random 3-SAT"**

The same first-moment exponent δ governs both solution existence (c = 1)
and computational discovery cost (μ\_c ∝ e^(cδ), c < 1).
The sensitivity exponent c is solver-dependent
(CDCL ≈ 0.24, WalkSAT ≈ 0.21, Random = 1.0).

同じ δ が解の存在（c = 1）と
計算的発見コスト（μ\_c ∝ e^(cδ), c < 1）の
両方を支配するが、感度が異なる。
感度指数 c はソルバー依存
（CDCL ≈ 0.24、WalkSAT ≈ 0.21、ランダム = 1.0）。

- English: [`paper2/paper2_main.tex`](paper2/paper2_main.tex) / [PDF](paper2/paper2_main.pdf)
- 日本語: [`paper2/paper2_main_ja.tex`](paper2/paper2_main_ja.tex) / [PDF](paper2/paper2_main_ja.pdf)

### Paper 3 — Cognitive Sleep for LLMs / LLMの認知的睡眠

**"Cognitive Sleep for LLMs:
How Contradiction Metabolism Prevents Context Rot"**

Context rot is caused by contradiction accumulation, not context length.
Even Google's 1M-token context window drops 47.8pp under contradictions.
We propose an external metabolism architecture inspired by human sleep
that processes knowledge during idle time.
Validated across 8 models (8B–27B), 11 paired comparisons (sign test p = 0.0107),
and a three-condition experiment (n = 3; ON 73.3% vs OFF 21.1%, Kruskal-Wallis p = 0.027).
Unexpected finding: metabolized systems exceed the contradiction-free baseline
(73.3% vs 56.7%), suggesting knowledge anchoring via contradiction pair preservation.

**v2 additions (Exp35-R):** Frontier model replication with GPT-4o, Gemini 3.1, and Sonnet 4.6
reveals three distinct response patterns: collapse (lightweight models, -89.6pp to -100pp),
resistance (frontier models, within 7pp of baseline), and non-retention (GPT-4o safety policy
suppresses personal information retention). δ_c is model-specific.
Direct fact recall control confirms pipeline vs model separation (Gemini/Sonnet 100% direct, GPT-4o 0%).
Middleware implementation [delta-prune](https://pypi.org/project/delta-prune/) (PyPI) identified as
observational infrastructure for measuring real-world δ density.

コンテキストロットの原因はコンテキスト長ではなく矛盾の蓄積。
Googleの100万トークン窓でも矛盾下では47.8pp劣化する。
人間の睡眠中の記憶整理に着想した外付け代謝アーキテクチャを提案。
8モデル（8B–27B）・11ペア比較（符号検定 p = 0.0107）、
三条件実験（n = 3; ON 73.3% vs OFF 21.1%、Kruskal-Wallis p = 0.027）で検証。
予期しない発見：代謝システムが矛盾ゼロの基準値を超える
（73.3% vs 56.7%）。矛盾ペア保持による知識アンカリング効果を示唆。

**v2追加（Exp35-R）:** GPT-4o・Gemini 3.1・Sonnet 4.6でのフロンティア追試により
三類型を発見：崩壊（軽量モデル、-89.6pp〜-100pp）、耐性（フロンティアモデル、基準値±7pp以内）、
非保持（GPT-4oの安全ポリシーが個人情報保持を抑制）。δ_cはモデル固有。
直接再現テストでパイプライン/モデル分離を実証（Gemini/Sonnet直接100%、GPT-4o 0%）。
ミドルウェア実装 [delta-prune](https://pypi.org/project/delta-prune/)（PyPI）を
現実世界のδ密度測定インフラとして位置づけ。

- English: [`paper3/metabolic_architecture.tex`](paper3/metabolic_architecture.tex) / [PDF](paper3/metabolic_architecture.pdf)
- 日本語: [`paper3/metabolic_architecture_ja.tex`](paper3/metabolic_architecture_ja.tex) / [PDF](paper3/metabolic_architecture_ja.pdf)
- Implementation: [DeltaZero](https://github.com/karesansui-u/delta-zero) / [delta-prune](https://github.com/karesansui-u/delta-prune)

### Lean 4 — Formal Verification / 形式検証

16 modules, 160 verified propositions,
`sorry = 0`, `axiom = 0`.
Covers the Cauchy functional equation, 3-axiom derivation,
Hill number bound, H-theorem, SAT first moment, sensitivity analysis,
the Paley–Zygmund second moment inequality, pair correlation structure,
and δ = D\_KL identity (KLDivergence module).

16モジュール、160個の証明済み命題、
`sorry = 0`、`axiom = 0`。
Cauchy関数方程式、3公理からの導出、Hill数上界、
H定理、SAT第一モーメント、感度解析、
Paley–Zygmund第二モーメント不等式、ペア相関構造、
δ = D\_KL 恒等式（KLDivergenceモジュール）を検証。

- Details / 詳細: [`lean/readme.md`](lean/readme.md)

---

## Repository Structure / リポジトリ構成

```
delta-survival-paper/
  paper1/          Paper 1 tex, figures, PDF (EN/JA)
  paper2/          Paper 2 tex, figures, PDF (EN/JA)
  paper3/          Paper 3 tex, figures, PDF (EN/JA)
  lean/            Lean 4 formal verification (16 modules)
  analysis/
    sat/           SAT experiments & second moment gap analysis (Papers 1 & 2)
    llm/           LLM Double Bind experiments (Paper 1)
    exp35/         δ=0 control — context rot experiments (6 models, 4 vendors)
  README.md
```

---

## Building Lean 4 / Lean 4 ビルド

```bash
cd lean && lake exe cache get && lake build
```

---

## Author / 著者

Akihito Sunagawa

## Citation / 引用

```bibtex
@misc{sunagawa2026structural,
  author = {Sunagawa, Akihito},
  title  = {Structural Collapse as Information Loss:
            The Exponential Decay Mechanism under Accumulating Constraints},
  year   = {2026},
  doi    = {10.5281/zenodo.19228441},
  url    = {https://zenodo.org/records/19228441}
}

@misc{sunagawa2026predicting,
  author = {Sunagawa, Akihito},
  title  = {Predicting Computational Cost from the Structural Parameter δ:
            Separating Existence from Discovery in Random 3-SAT},
  year   = {2026},
  doi    = {10.5281/zenodo.18943573},
  url    = {https://zenodo.org/records/18943573}
}

@misc{sunagawa2026cognitive,
  author = {Sunagawa, Akihito},
  title  = {Cognitive Sleep for LLMs:
            How Contradiction Metabolism Prevents Context Rot},
  year   = {2026},
  doi    = {10.5281/zenodo.19322371},
  url    = {https://zenodo.org/records/19322371}
}
```

## License

- Papers (`paper1/`, `paper2/`, `paper3/`): [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- Code (`lean/`, `analysis/`): [Apache 2.0](LICENSE)
