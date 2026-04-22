# 構造収支律 Draft Plan

Status: design draft. The main preprint draft has started at
`v2/5_構造持続の収支法則と崩壊傾向.md`; §1-8 currently establish the minimal
balance identity, signed exponential kernel, expectation-level tendency,
finite-horizon concentration schema, Route A anchors, Route C anchors, and
existing-theory differences, and close with limitations / next steps.

Purpose:

この draft は、構造持続理論を「M の分解」ではなく、損失流と補償流の収支として再集約するための設計メモである。M 分解はこの収支律を現実ドメインで測るための operational mapping として補論へ下げ、普遍理論の中核は次の balance identity に置く。

\[
  a_t = \ell_t - g_t,\qquad
  A_n = \sum_{t<n} a_t,\qquad
  m(V_n)=m(V_0)\exp(-A_n).
\]

ここで $\ell_t$ は構造損失流、$g_t$ は補償・修復・資源流、$a_t$ は net action である。日本語では **構造収支律**、英語では **structural balance law** と呼ぶ。「均衡法則」は equilibrium と誤読されやすいため使わない。

## 1. Core Claim To Test

主張の核は、開いた構造系が持続するには、損失流を補償する流れが必要であり、その差し引きが累積作用として残存可能性を指数的に支配する、という点である。

Three regimes:

| regime | condition | tendency |
|---|---|---|
| collapse tendency | $\mathbb{E}[a_t] > 0$ | loss dominates compensation |
| stationary / maintenance | $\mathbb{E}[a_t] \approx 0$ | compensation balances loss |
| recovery tendency | $\mathbb{E}[a_t] < 0$ | compensation exceeds loss |

この表は equilibrium の主張ではない。$a_t$ の符号で崩壊・維持・回復の傾向を分ける収支の主張である。

## 2. Source Anchors

- `v2/補論_構造持続の集合値力学的表現と符号付き指数核.md`: $a_t=\ell_t^- - g_t$ と signed exponential kernel の既存 formalism。
- `lean/UNIVERSALITY_GAP_MAP.md`: expectation-level tendency が Lean 既存定理へ写ることの M1 mapping。
- `lean/PAPER_MAPPING.md`: verified theorem map。
- `v2/補論_有限CSPにおける構造持続の予測力.md`: Mixed-CSP の finite-horizon concentration / feasibility evidence。
- `v2/3_構造持続と推論性能の劣化.md`: LLM における scope-as-repair / external metabolism の Route C anchor。
- `v2/4_構造持続と継続学習における破滅的忘却.md`: 継続学習における repair / adaptation 分離の Route C anchor。
- `v2/補論_構造持続における資源項Mの操作的定式化.md`: 補償流・資源流を実ドメインへ写す operational mapping。

## 3. Proposed Main Paper Shape

Tentative title:

```text
構造持続の収支法則と崩壊傾向
— 損失流と補償流の累積作用 —
```

Draft sections:

1. 問題設定: 閉じた収縮系から開いた補償系へ。
2. 最小収支恒等式: $\ell_t$, $g_t$, $a_t$, $A_n$, exponential identity。
3. 期待値レベルの傾向律: $\mathbb{E}[a_t]$ の符号による collapse / maintenance / recovery。
4. 有限時間・高確率境界: bounded increments, Azuma / Chernoff, hitting-time bounds。
5. Route A anchors: SAT / Mixed-CSP / finite CSP での collapse tendency。
6. Route C anchors: Paper 3 / Paper 4 の repair / external metabolism / adaptation indicators。
7. 既存理論との差分: 非平衡熱力学、Prigogine、queueing Lyapunov drift、確率制御との同じ点と違う点。
8. 限界: 無限地平線、因果的 repair identification、M-mode の universal metric は未主張。

## 4. Non-Goals

- M mode decomposition を普遍法則の中核にしない。
- 単一の $\Phi$, $\rho_i$, $A_j$ を全ドメインで正しいとは主張しない。
- software / SaaS を Route A と呼ばない。
- empirical pilot なしに intervention-ranking を実証済みとは呼ばない。
- high-probability stopped-collapse を expectation-level tendency と混同しない。
- 熱力学の再発見に見える書き方を避ける。差分は、対象構造・測度・制約列・時間地平を事前固定する operational discipline に置く。

## 5. Immediate Next Edits

1. `v2/5_構造持続の収支法則と崩壊傾向.md` §1-8 をレビューし、重複・節番号・cross-reference を整える。
2. Exp43 q-coloring cross-q feasibility の preregistration draft を設計する。
3. §7 の G6-a/b/c（analogy / correspondence / formal reduction）整理を、Lean theorem map / roadmap に反映する。
4. Paper 0 統合版の architecture を、Paper 1 -> Paper 2 -> 構造収支律 -> Paper 3/4 -> M 補論、という依存順に更新する。
5. M 補論は「補償流・資源流の測定層」として参照し、主理論の代替として扱わない。
