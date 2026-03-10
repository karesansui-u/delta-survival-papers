# Delta-Survival Papers

Cumulative information loss $\delta$ (nats) as a unified coordinate
for structural collapse: theory, experiments, and formal verification.

累積的情報損失 $\delta$（nats）を構造崩壊の統一座標とする理論・実験・形式検証。

## Status / ステータス

| Component | Status |
|---|---|
| Paper 1 — Structural Collapse | **Accepted** |
| Paper 2 — Existence vs Discovery | Draft |
| Lean 4 — Formal Verification | Complete (`sorry = 0`, `axiom = 0`) |

**Key result:** Parameter-free prediction of XOR-SAT threshold ratio
$\alpha_{\text{XOR}}/\alpha_{\text{random}} = 5.19\times$
(observed $5.04 \pm 0.25$, CV = 5%).

パラメータフリー予測: XOR-SAT閾値比
$\alpha_{\text{XOR}}/\alpha_{\text{random}} = 5.19$倍
（実測 $5.04 \pm 0.25$、CV = 5%）。

---

## What this is about / この研究について

When independent constraints each eliminate a fixed fraction of states,
the survival potential decays as $S = N_{\text{eff}} \cdot e^{-\delta}$.
This is a theorem (from three axioms), not a model choice.
The unit $\delta$ (nats) makes the collapse mechanism commensurable
across domains: SAT, LLM reasoning, nuclear stability, percolation.

独立な制約がそれぞれ固定割合の状態を除去するとき、
存続ポテンシャルは $S = N_{\text{eff}} \cdot e^{-\delta}$ に従う。
これは3つの公理から導かれる定理であり、モデル選択ではない。
$\delta$（nats）という単位により、
SAT・LLM推論・核安定性・パーコレーションといった
異なるドメインの崩壊メカニズムが同一座標上で比較可能になる。

---

## Papers / 論文

### Paper 1 — Structural Collapse as Information Loss / 構造崩壊と情報損失

**"Structural Collapse as Information Loss:
The Exponential Decay Mechanism under Accumulating Constraints"**

Three axioms (finite state space, fractional elimination, independence)
uniquely determine $S = N_{\text{eff}} \cdot e^{-\delta}$.
Validated on random 3-SAT, LLM reasoning collapse, nuclear stability,
and 3D percolation.

3つの公理（有限状態空間・割合除去・独立性）から
$S = N_{\text{eff}} \cdot e^{-\delta}$ が一意に決まることを示し、
SAT・LLM・原子核・パーコレーションで検証。

- English: [`paper1/paper1_main.tex`](paper1/paper1_main.tex) / [PDF](paper1/paper1_main.pdf)
- 日本語: [`paper1/paper1_main_ja.tex`](paper1/paper1_main_ja.tex) / [PDF](paper1/paper1_main_ja.pdf)

### Paper 2 — Existence vs Discovery / 存在と発見の分離

**"Predicting Computational Cost from the Structural Parameter $\delta$:
Separating Existence from Discovery in Random 3-SAT"**

The same first-moment exponent $\delta$ governs both solution existence ($c = 1$)
and computational discovery cost ($\mu_c \propto e^{c\delta}$, $c < 1$).
The sensitivity exponent $c$ is solver-dependent
(CDCL $\approx 0.24$, WalkSAT $\approx 0.21$, Random $= 1.0$).

同じ $\delta$ が解の存在（$c = 1$）と
計算的発見コスト（$\mu_c \propto e^{c\delta}$, $c < 1$）の
両方を支配するが、感度が異なる。
感度指数 $c$ はソルバー依存
（CDCL $\approx 0.24$、WalkSAT $\approx 0.21$、ランダム $= 1.0$）。

- English: [`paper2/paper2_main.tex`](paper2/paper2_main.tex) / [PDF](paper2/paper2_main.pdf)
- 日本語: [`paper2/paper2_main_ja.tex`](paper2/paper2_main_ja.tex) / [PDF](paper2/paper2_main_ja.pdf)

### Lean 4 — Formal Verification / 形式検証

11 modules, 98 verified propositions (88 theorems + 10 lemmas),
`sorry = 0`, `axiom = 0`.
Covers the Cauchy functional equation, 3-axiom derivation,
Hill number bound, H-theorem, SAT first moment, and sensitivity analysis.

11モジュール、98個の証明済み命題（定理88 + 補題10）、
`sorry = 0`、`axiom = 0`。
Cauchy関数方程式、3公理からの導出、Hill数上界、
H定理、SAT第一モーメント、感度解析を検証。

- Details / 詳細: [`lean/readme.md`](lean/readme.md)

---

## Repository Structure / リポジトリ構成

```
delta-survival-paper/
  paper1/          Paper 1 tex, figures, PDF (EN/JA)
  paper2/          Paper 2 tex, figures, PDF (EN/JA)
  lean/            Lean 4 formal verification (11 modules)
  analysis/
    sat/           SAT experiments (Papers 1 & 2)
    llm/           LLM Double Bind experiments (Paper 1)
  README.md
```

---

## Building / ビルド

```bash
# Paper 1 (English)
cd paper1 && pdflatex paper1_main.tex && pdflatex paper1_main.tex

# Paper 1 (日本語) — XeLaTeX required
cd paper1 && xelatex paper1_main_ja.tex && xelatex paper1_main_ja.tex

# Paper 2
cd paper2 && pdflatex paper2_main.tex && pdflatex paper2_main.tex

# Lean 4
cd lean && lake exe cache get && lake build
```

---

## Author / 著者

Akihito Sunagawa

## Citation / 引用

```bibtex
@article{sunagawa2026structural,
  author  = {Sunagawa, Akihito},
  title   = {Structural Collapse as Information Loss:
             The Exponential Decay Mechanism under Accumulating Constraints},
  year    = {2026},
  url     = {https://codeberg.org/delta-survival/papers}
}
```

## License

- Papers (`paper1/`, `paper2/`): [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- Code (`lean/`, `analysis/`): [Apache 2.0](LICENSE)
