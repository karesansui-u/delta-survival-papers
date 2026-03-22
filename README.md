# Delta-Survival Papers

Cumulative information loss δ (nats) as a unified coordinate
for structural collapse: theory, experiments, and formal verification.

累積的情報損失 δ（nats）を構造崩壊の統一座標とする理論・実験・形式検証。

## Status / ステータス

| Component | Status |
|---|---|
| Paper 1 — Structural Collapse | **Accepted** |
| Paper 2 — Existence vs Discovery | Preprint |
| Lean 4 — Formal Verification | Complete (`sorry = 0`, `axiom = 0`) |

**Key results:**
- Parameter-free prediction of XOR-SAT threshold ratio:
  α\_XOR / α\_random = 5.19×
  (observed 5.04 ± 0.25, CV = 5%).
- Second moment method (Paley–Zygmund) with pair correlation
  g(β) = 3/4 + (1/8)(1−β)³ explains 74% of the gap between
  the first-moment upper bound (α ≈ 5.19) and the true 3-SAT
  threshold (α ≈ 4.27).

パラメータフリー予測: XOR-SAT閾値比
α\_XOR / α\_random = 5.19倍
（実測 5.04 ± 0.25、CV = 5%）。
第二モーメント法（Paley–Zygmund不等式）とペア相関関数
g(β) = 3/4 + (1/8)(1−β)³ により、
第一モーメント上界（α ≈ 5.19）と真の3-SAT閾値（α ≈ 4.27）の
差の74%を定量的に説明。

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

3つの公理（有限状態空間・割合除去・独立性）から
`S = N_eff · (μ/μ_c) · e^(−δ)` が一意に決まることを示し、
SAT および LLM 推論崩壊（11モデル・5ベンダー・4B–70B+パラメータ）で検証。
第二モーメント法とペア相関関数により第一モーメント上界と真の閾値の差を定量的に説明。
KLダイバージェンスおよびチャネルコーディングとの対応を通じた
情報理論的基盤を確立（構造容量定理：δ ≤ C\_struct ⟺ 存続）。

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

### Lean 4 — Formal Verification / 形式検証

15 modules, 152 verified propositions,
`sorry = 0`, `axiom = 0`.
Covers the Cauchy functional equation, 3-axiom derivation,
Hill number bound, H-theorem, SAT first moment, sensitivity analysis,
the Paley–Zygmund second moment inequality, and pair correlation structure.

15モジュール、152個の証明済み命題、
`sorry = 0`、`axiom = 0`。
Cauchy関数方程式、3公理からの導出、Hill数上界、
H定理、SAT第一モーメント、感度解析、
Paley–Zygmund第二モーメント不等式、ペア相関構造を検証。

- Details / 詳細: [`lean/readme.md`](lean/readme.md)

---

## Repository Structure / リポジトリ構成

```
delta-survival-paper/
  paper1/          Paper 1 tex, figures, PDF (EN/JA)
  paper2/          Paper 2 tex, figures, PDF (EN/JA)
  lean/            Lean 4 formal verification (15 modules)
  analysis/
    sat/           SAT experiments & second moment gap analysis (Papers 1 & 2)
    llm/           LLM Double Bind experiments (Paper 1)
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
  doi    = {10.5281/zenodo.19053901},
  url    = {https://zenodo.org/records/19053901}
}

@misc{sunagawa2026predicting,
  author = {Sunagawa, Akihito},
  title  = {Predicting Computational Cost from the Structural Parameter δ:
            Separating Existence from Discovery in Random 3-SAT},
  year   = {2026},
  doi    = {10.5281/zenodo.18943573},
  url    = {https://zenodo.org/records/18943573}
}
```

## License

- Papers (`paper1/`, `paper2/`): [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- Code (`lean/`, `analysis/`): [Apache 2.0](LICENSE)
