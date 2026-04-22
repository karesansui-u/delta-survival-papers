# ROADMAP: 構造収支律と Route A 強化

Status: working roadmap for humans / other LLMs.

Purpose:

このメモは、構造持続理論を「普遍理論候補」として強化するための次ステップを、他の LLM / agent が読んでも迷わないように整理する。現時点の方針は、M 分解を universal core にしないこと。core は **構造収支律 / structural balance law** に置き、M 分解は補償流・資源流を実ドメインで測る operational mapping layer として扱う。

注意: `v2/data/` はローカル作業メモ置き場で、`.gitignore` 対象である。コミットしたい場合は `git add -f v2/data/ROADMAP_構造収支律とRouteA強化.md` が必要。

## 1. 現在地

Architecture:

```text
Core theory candidate:
  構造収支律 / structural balance law

Operational supplement:
  M mode decomposition / intervention-ranking protocol
```

現在の正確な評価:

```text
普遍理論として確立した: no
普遍理論候補の骨格を強化中: yes
```

重要な discipline:

- universal-law declaration はしない。
- SAT / Mixed-CSP / LLM / 継続学習は Level 2 universality candidate の内部 anchor として扱う。
- Level 3 universal law には、独立再現、異質ドメイン、既存理論との formal mapping が必要。

## 2. 普遍理論に近づけるための Gate

ここでいう「普遍理論に近づく」とは、単に応用例を増やすことではない。次の順で、理論核・形式化・予測力・外部再現性を積み上げることを指す。

| Gate | 目的 | 通ったら何が強くなるか |
|---|---|---|
| G1. Core law | 構造収支律を main theory として書く | 分類ではなく一般形式になる |
| G2. Formal spine | Lean theorem map / wrapper で主張と定理を対応づける | 数学的骨格が検証可能になる |
| G3. Route A width | SAT 以外の独立 family に通す | SAT 専用ではないと言える |
| G4. Non-CSP anchors | 信頼性・減衰・待ち行列・反応系などに還元する | 情報・計算系だけの理論ではないと言える |
| G5. Prospective prediction | 事前登録された新ドメイン予測を当てる | 事後説明ではなく予測理論になる |
| G6. Formal mapping to existing theories | 熱力学・情報理論・Lyapunov drift 等との写像を示す | 既存普遍理論との関係が明確になる |
| G7. Independent replication | 外部研究者が再現・批判・拡張する | Level 3 universal-law credibility の入口に立つ |

Current state:

| Gate | Status |
|---|---|
| G1 | draft complete。`v2/5_構造持続の収支法則と崩壊傾向.md` §1-8 が作成済み |
| G2 | expectation-level tendency と high-probability schema は §3-4 に対応済み。詳細 theorem map の polish は未整理 |
| G3 | Lean 上は q-coloring / XOR / NAE / cardinality まで水平展開済み。empirical primary は Mixed-CSP が中心 |
| G4 | non-CSP Lean skeleton はあるが SAT-chain-level anchor ではない |
| G5 | LLM / Mixed-CSP の内部 prospective はある。外部・異質ドメインでは未達 |
| G6 | §7 で G6-a/b/c の整理と queueing / Foster-Lyapunov の G6-c 候補を記述済み。theorem transfer と non-CSP 追加例は未整理 |
| G7 | 未達。外部再現待ち |

Gate interaction:

Gates are cumulative and can be advanced by a single work item. For example, a preregistered q-coloring experiment can advance both G3 (SAT 以外の Route A width) and G5 (prospective prediction). Similarly, a non-CSP theorem map can advance both G4 (古典例 anchor) and G6 (existing-theory mapping) if it gives an actual formal reduction.

Most important immediate pair:

```text
G1 + G2:
  構造収支律を main paper 化し、
  Lean theorem map と対応づける。
```

次に効く empirical pair:

```text
G3:
  q-coloring を SAT 以外に見える Route A width extension として通す。

G4:
  reliability / decay / queueing などの non-CSP skeleton を、単なる例示から
  balance-law reduction として整理する。
```

「これができたら確実」に最も近い bundle:

```text
1. 構造収支律 paper が完成する。
2. その主要 claim が Lean theorem map に接続される。
3. q-coloring など SAT 以外の Route A empirical/prospective test が通る。
4. non-CSP の古典例 2-3 個に formal mapping できる。
5. そのうち少なくとも 1 つが外部再現される。
```

この bundle は Level 2 をかなり強くするためのもの。Level 3 universal-law credibility に近づくには、さらに G6 の強い版と G7 が必要になる。

この bundle が通れば、まだ「普遍法則が確立した」とは言わないが、かなり強く次のように言える。

```text
構造持続理論は、形式化された構造収支律を核に持ち、
複数の独立 family と古典例に写る universal-law candidate である。
```

## 3. 主要ファイル

読む順番:

1. `analysis/structural_balance_law_draft_plan.md`
   - 構造収支律の draft plan。
2. `v2/5_構造持続の収支法則と崩壊傾向.md`
   - 構造収支律の main draft。§1-8 は作成済み。
3. `v2/補論_構造持続における資源項Mの操作的定式化.md`
   - M 分解を補論として再配置した integrated draft。
4. `v2/補論_有限CSPにおける構造持続の予測力.md`
   - Mixed-SAT/NAE-SAT empirical Route A anchor。
5. `lean/PAPER_MAPPING.md`
   - Lean theorem map。
6. `lean/UNIVERSALITY_GAP_MAP.md`
   - expectation-level tendency の M1 mapping。
7. `analysis/universality_next_decisions.md`
   - current gates and next options。
8. `analysis/HANDOFF_2026-04-22.md`
   - 最新 handoff。

## 4. Step 1: 構造収支律 Paper をレビューして固定候補にする

Goal:

`v2/5_構造持続の収支法則と崩壊傾向.md` は作成済み。M 補論ではなく、この paper が次の main-theory slot を取る。次に行うのは、§1-8 の整合レビュー、必要な小修正、freeze / commit 判断である。

Tentative title:

```text
構造持続の収支法則と崩壊傾向
— 損失流と補償流の累積作用 —
```

Core identity:

\[
  a_t = \ell_t - g_t,\qquad
  A_n = \sum_{t<n} a_t,\qquad
  m(V_n)=m(V_0)\exp(-A_n).
\]

Interpretation:

- $\ell_t$: loss flow / 構造損失流。
- $g_t$: compensation, repair, support, resource flow / 補償・修復・資源流。
- $a_t$: net action / 正味作用。
- $A_n$: cumulative action / 累積作用。

Minimal sections:

1. 問題設定: loss-only 収縮から open-system compensation へ。
2. 最小収支恒等式: $a_t$, $A_n$, signed exponential kernel。
3. expectation-level tendency: $\mathbb{E}[a_t]$ の符号で collapse / maintenance / recovery を分ける。
4. high-probability bounds: bounded increments / MGF があると Azuma / Chernoff / hitting-time bounds が出る。
5. Route A anchors: SAT, Mixed-CSP, finite CSP。
6. Route C anchors: Paper 3 / Paper 4 の repair / external metabolism / adaptation。
7. 既存理論との差分: thermodynamics, stochastic thermodynamics, queueing Lyapunov drift, control, information theory。
8. 限界: universal law ではなく universal-law candidate。

Do not:

- 「均衡法則」と訳さない。日本語は「収支律」。
- M mode decomposition を core にしない。
- software / SaaS を Route A と呼ばない。
- high-probability stopped-collapse を expectation-level tendency と混同しない。

## 5. Step 2: Lean theorem map / wrapper を整理する

Goal:

構造収支律 paper の主張を Lean の既存 theorem map に対応づける。新 theorem を無理に大量追加するより、既存定理が何を支えるかを明示する。

Minimum mapping:

| Paper claim | Lean / existing source |
|---|---|
| loss-only exponential identity | `LogUniqueness.lean`, `TelescopingExp.lean`, `AxiomsToExp.lean` |
| signed action / repair-flow identity | `補論_構造持続の集合値力学的表現と符号付き指数核.md` and related Lean mappings |
| expectation-level tendency | `lean/UNIVERSALITY_GAP_MAP.md`, `lean/PAPER_MAPPING.md` |
| finite-horizon collapse / hitting-time schema | Azuma / Chernoff / stopping-time modules |
| SAT / Bernoulli-CSP concrete anchors | `SATStateDependentCountChernoffKLAlgebra.lean`, `BernoulliCSPUniversality.lean` |

Success criterion:

```text
The paper can say: the expectation-level tendency layer is formally mapped to
existing Lean theorems; high-probability bounds require explicit concentration
or MGF assumptions.
```

Do not:

- Claim Lean has proved every empirical Route C statement.
- Claim M decomposition has a universal metric.
- Hide assumptions needed for concentration / MGF.

## 6. Step 3: Route A width extension, first target q-coloring

Recommendation:

Do **q-coloring before Cardinality-SAT**.

Reason:

- q-coloring looks visibly different from SAT.
- It connects to graph coloring, statistical physics, and combinatorial optimization.
- It weakens the objection "this is just SAT formalization".
- Cardinality-SAT is useful, but still looks SAT-family-adjacent.

Existing Lean support:

- `QColoringBernoulliTemplate.lean`
- `QColoringEdgeExposureProcess.lean`
- `QColoringChernoffCollapse.lean`
- `BernoulliCSPUniversality.lean`

Mathematical setup:

```text
state space: [q]^n
constraint: edge (u,v) forbids same color
single-edge survival ratio: 1 - 1/q
drift: ell_q = -log(1 - 1/q)
L = m * ell_q
```

Important guardrail:

単一 q 固定では `L = constant * m` なので raw edge count と縮退する。primary empirical test は単一 fixed-q family だけで行わない。

Recommended empirical design:

```text
name: Exp43 q-coloring cross-q feasibility
q values: 3, 4, 5
endpoint: colorable / uncolorable
primary predictor: L plus log_state or threshold-normalized L
baselines: raw edge count + n + q, density + n + q, optionally encoding-size diagnostic
primary split: leave-one-q-out or leave-one-threshold-band-out
primary metric: held-out log loss / Brier score
```

Current draft:

```text
v2/data/exp43_qcoloring_preregistration_draft.md
```

Status: draft only, not frozen.

Pilot harness:

```text
analysis/exp43_qcoloring/
```

Status: draft harness; tests and dry-run pass with `python3`. Use
`analysis/exp43_qcoloring/config/smoke_config.json` for the first solver-path
check after PySAT is available. Do not run primary data until preregistration
freeze.

Need care:

- q ごとに colorability threshold が違う。
- density grid は固定値ではなく threshold 近傍を使うのが安全。
- primary は solver cost ではなく feasibility / colorability。
- solver metadata は diagnostic として残してよいが、primary にしない。

Passing signal:

```text
q-coloring の cross-q / threshold-normalized test で、structure-aware L predictor
が raw edge count / density baseline を held-out で上回る。
```

Interpretation if passed:

```text
Route A は SAT / NAE-SAT mixed CSP だけでなく、graph-coloring family にも広がる。
これは Bernoulli-CSP universality class の幅を強化する。
```

Still not allowed:

```text
universal law established
```

## 7. Step 4: Cardinality-SAT as stress extension

Do this after q-coloring.

Role:

- Bernoulli-CSP template の stress test。
- drift と CNF encoding size の交絡を壊しやすい。
- exact-one / threshold cardinality constraints は strong diagnostic になる。

Existing Lean support:

- `CardinalitySATChernoffCollapse.lean`
- `ThresholdCardinalitySATChernoffCollapse.lean`
- `ExactlyOneSATChernoffCollapse.lean`
- `MultiForbiddenPatternCSP.lean`

Why second:

Cardinality-SAT is mathematically useful but rhetorically still SAT-like. q-coloring should be the first "SAT 以外に見える" empirical Route A extension.

## 8. Step 5: Beyond Internal Strength

These are needed for Level 3 universal-law credibility:

1. Independent replication by outside researchers.
2. Non-computational / non-CSP anchors, e.g. reliability engineering, queueing, reaction kinetics, percolation, biology.
3. Formal mapping to existing theories:
   - thermodynamics / nonequilibrium thermodynamics;
   - Shannon information theory;
   - queueing Lyapunov drift;
   - stochastic control drift conditions;
   - reliability theory.

G6 pass levels:

| Level | 内容 | 評価 |
|---|---|---|
| G6-a analogy | 既存理論との語彙的類似を述べる | introductory motivation only |
| G6-b correspondence | $\ell_t$, $g_t$, $a_t$ などの項目対応表を作る | useful but not decisive |
| G6-c formal reduction / embedding | 構造収支律から既存理論の一部を導く、または既存理論の drift / balance 条件を構造収支律の特例として埋め込む | minimum pass for Level 3 credibility |

Important:

G6-a / G6-b はすでに前書きや比較節でできる。Level 3 に効くのは G6-c のみ。たとえば queueing Lyapunov drift、reliability product law、constant-fraction decay、または stochastic control drift condition のどれかを、構造収支律の特例または逆向きの embedding として明示できれば G6-c の候補になる。

Existing non-CSP skeletons:

- `SerialReliability.lean`
- `ConstantFractionDecay.lean`
- `BranchingProcessExtinction.lean`
- `QueueStability.lean`
- `FatigueDamage.lean`
- `BucklingThreshold.lean`
- `PercolationThreshold.lean`
- `ConsensusFaultThreshold.lean`

Current status:

These are coverage / sanity skeletons, not yet full SAT-chain-level anchors.

## 9. Exact Next Action For Another LLM

If another LLM continues, do this:

```text
1. Read analysis/structural_balance_law_draft_plan.md.
2. Read this roadmap.
3. Read v2/5_構造持続の収支法則と崩壊傾向.md §1-8.
4. Review / freeze v2/data/exp43_qcoloring_preregistration_draft.md.
5. Keep M decomposition as a supplement reference only.
6. Do not claim universal law established, even if Exp43 passes.
```

Suggested commit message when ready:

```text
Reclassify M operationalization as supplement and plan structural balance law
```

If including this roadmap despite `v2/data/` being ignored:

```bash
git add -f v2/data/ROADMAP_構造収支律とRouteA強化.md
```
