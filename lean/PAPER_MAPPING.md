# Lean 形式検証 ↔ 論文対応棚卸し

棚卸し日: 2026-04-21
対象: `lean/Survival/` 配下 134 ファイル
対応論文: `delta-survival-paper/v2/` 配下 8 本（Paper 0–4 + 補論 3 本）

## 現在の結論

このファイルを、Lean 形式化と論文本文を結ぶ唯一の reader-facing theorem map とする。
旧 SAT/CSP 専用 map は現行ツリーから外し、git history / OSF snapshot 側の archive として扱う。

現時点の Lean 側は **134 Survival modules / sorry = 0 / axiom = 0** で閉じている。Paper 2 §5 が
明示している 5 ファイルを超えて、停止時刻崩壊、martingale concentration、粗視化、有限状態 Markov
microfoundation、SAT/k-SAT Chernoff-KL chain、Bernoulli-CSP 水平展開、Route A 非CSP skeletons まで
含む。

## 証拠の階層

この mapping は「Lean で何が閉じているか」と「論文で何を前面に出すべきか」を分ける。
現時点の強い主証拠は SAT と LLM に集中しており、非CSP例は新規予測ではなく sanity / coverage benchmark
として読む。

| 層 | 位置づけ | 読み方 |
|---|---|---|
| SAT chain v1.0 | 数学的 anchor | random 3-SAT の自然測度、actual path measure、MGF product、Chernoff/KL collapse が有限地平線で閉じている |
| LLM 810 試行 | 経験的 anchor | 文脈長・制約数だけの基準モデルを越え、構造矛盾がより強い崩壊要因になることを示す |
| Bernoulli CSP universality v1.2 | template validation | fixed assignment/coloring の iid bad-event exposure に限った水平展開。solver dynamics や依存構造は含めない |
| Route A 非CSP skeletons | sanity / coverage benchmark | 古典例を最小語彙で歪めず表せるかの検査。信頼性・材料・待ち行列等の新規本命定理ではない |
| Level B / proxy domains | future work | LLM 以外の高次元・非自然測度ドメインは calibration と実証を要する |

## Target Theorem 4 / Law-of-Tendency Mapping

M1 gap analysis conclusion:

```text
Target theorem 4 is already formally accessible at the expectation level
through existing Lean theorems. The remaining work is reader-facing mapping
and paper-side wording, not a new proof obligation.
```

The paper-side target should be split into two schemas:

1. **Expectation-level tendency**: one-step total production is nonnegative
   (or implied by a resource-bounded assumption), so expected cumulative total
   production is monotone.
2. **High-probability stopped-collapse / non-collapse**: finite-horizon
   collapse or hitting-time bounds follow only after adding concentration,
   bounded-increment, and margin assumptions.

These schemas should not be merged without explicitly carrying the extra
probability assumptions.

| Paper phrase | Lean vocabulary | Lean theorem / object | Status |
|---|---|---|---|
| signed exponential balance | local net action / feasible mass | `feasibleMass_succ_eq_mass_mul_exp_neg_stepNetAction`; `feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction` | proven |
| cumulative signed kernel \(m(V^{(n)}) = m(V^{(0)}) e^{-A_n}\) | cumulative net action | `feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction` | proven |
| repair/resource contribution dominates contraction loss | nonnegative step total production | `expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction` | proven; naming gap only |
| deterministic total production tendency | deterministic step model | `deterministic_expectedCumulative_monotone` | proven |
| coarse-grained typical nondecrease | coarse stochastic compatibility | `coarse_expectedCumulative_monotone_of_micro_nonnegative`; `coarse_expectedCumulative_monotone_of_micro_resourceBounded`; `coarse_expectedCumulative_monotone_of_micro_conditionalAzuma` | proven |
| SAT expected tendency | state-dependent SAT step model | `expectedCumulative_monotone_stepModel`; `expectedCumulative_eq_initial_add_linear` | proven; mapping sufficient |
| Bernoulli-CSP finite drift / collapse tendency | bad-event exposure, drift, Chernoff margin | `drift`; `expectedBadEmission_eq_drift`; `collapseWithChernoffBound_of_linearMargin`; `stoppedCollapseWithChernoffBound_of_linearMargin` | proven; different schema from repair dominance |
| stopped collapse / hitting-time bound | bounded increments, expected margin, concentration | `stoppedCollapseWithFailureBound_of_boundedIncrementData_expectedMargin`; resource/coarse stopped-collapse wrappers | proven under assumptions |

M1 wording discipline:

```text
Do not state "prefix dominance implies nondecrease" unless prefix dominance is
defined stepwise or adjacent-prefix-wise. The Lean layer proves monotonicity
from nonnegative one-step total production or equivalent resource-bounded
assumptions. A merely nonnegative cumulative prefix value is not enough to
imply monotonicity.
```

M2 decision:

```text
M2-A: mapping-only is sufficient.
```

A thin wrapper file may still be added later for readability, but it is not
mathematically required. If added, wrappers should be direct aliases of the
existing theorems, with no new axioms and no strengthened empirical claim.

## Lean で閉じている範囲

| 範囲 | 状態 | 読み方 |
|---|---|---|
| Paper 1/2 の最小指数核 | 完了 | `LogUniqueness`, `TelescopingExp`, `AxiomsToExp`, `WeakDependence` が主軸 |
| 確率的崩壊・停止時刻 | 完了 | Paper 1 §5 の崩壊閾値を finite-horizon hitting-time / stopped-collapse に拡張 |
| Martingale / Azuma concentration | 完了 | Paper 2 §4 の抽象 ρ 境界を bounded-increment concentration に格上げ可能 |
| 粗視化・表現安定性 | 完了 | Paper 1 §2 P5 を集合論・total production・stochastic layer で形式化 |
| SAT chain v1.0 | 完了 | actual path measure → non-flat emission → MGF product → Chernoff/KL → collapse |
| Bernoulli CSP universality v1.2 | 完了 | k-SAT / NAE-SAT / XOR-SAT / coloring / forbidden-pattern / cardinality families |
| Route A 非CSP skeletons | 表現検査として完了 | 指数型、線形過負荷型、累積容量型、臨界パラメータ型の finite-prefix sanity examples |

## 意図的に未着手の範囲

以下は未完成ではなく、現行 freeze の外に置いた範囲である。

- infinite-horizon construction / Ionescu-Tulcea
- almost-sure ergodic theorem / Birkhoff 型主張
- adaptive clause selection / solver dynamics
- XOR-SAT rank/nullity dynamics
- random graph / random hypergraph の依存構造そのもの
- 各非CSP領域の本命定理（Shannon 容量定理、Euler 座屈公式、percolation 極限定理、Byzantine agreement 定理など）

## 論文本文へ反映すべき最重要差分

1. Paper 2 §5 の形式検証リストを 5 ファイルから現在の主要層へ更新する。
2. Paper 2 §4 に martingale / Azuma concentration による厳密化を追加する。
3. Paper 1 §5 に stopping-time collapse / cliff warning / high-probability collapse を反映する。
4. Paper 1 §2 P5 に coarse-graining の形式化を反映する。
5. 補論 SAT / Route A では、SAT chain v1.0 と Bernoulli CSP universality v1.2 を本文の主導線にする。
6. Route A 非CSP examples は、個別列挙ではなく四型分類（指数型、線形過負荷型、累積容量型、臨界パラメータ型）で扱う。

---

## 0. Freeze Snapshot: SAT chain v1.0

SAT/k-SAT 系については、これ以上細かく証明を足すよりも、完成済み core として外部から読める形に固定する段階に入った。現在の凍結範囲は次である。

```text
random SAT/k-SAT problem data
  -> actual finite-horizon path measure
  -> non-flat bad-outcome additive functional
  -> MGF product derived from the path PMF
  -> Chernoff/KL lower-tail profile
  -> collapse / stopped-collapse / hitting-time bounds
```

対応する詳細は本 mapping に統合した。ここでは、何が仮定で、何が derived theorem で、何が意図的な未着手かを明示している。特に、infinite horizon、almost-sure ergodic theorem、adaptive clause selection、solver dynamics、XOR-SAT rank dynamics は v1.0 の範囲外として明示的に切る。

水平展開として、固定割当のもとでの `k`-NAE-SAT / `k`-XOR-SAT bad-event exposure、固定 coloring のもとでの q-coloring edge exposure、generic finite-alphabet forbidden-pattern exposure、さらに hypergraph-coloring specialization を追加した。これは Bernoulli-CSP template の再利用性を検証するための対象であり、solver dynamics、XOR-SAT rank/nullity dynamics、random graph / random hypergraph の依存構造、overlapping constraint dependence は別段階の研究対象として扱う。

v1.2 では `MultiForbiddenPatternCSP` を横断 bridge として含めた。これは個別 domain が
`alphabet`, `arity`, `forbiddenCount`, および `0 < forbiddenCount < alphabet^arity` の witness を
与えれば、既存の forbidden-pattern path measure / Chernoff-KL / collapse wrapper を生成できる bridge
である。Hypergraph coloring は `forbiddenCount = q` の witness 経由でも同じ parameters に戻る。
さらに `ExactlyOneSATChernoffCollapse` を追加し、fixed assignment の random signed `k`-clause で
exactly-one 条件を満たさない `2^k-k` 個の truth patterns を forbidden witness として渡す例を示した。
この場合、bad-event probability は `(2^k-k)/2^k`、drift は `log(2^k/k)` になる。
さらに `CardinalitySATChernoffCollapse` で exactly-`r`-of-`k` family へ一般化した。allowed pattern は
`choose k r` 個なので、bad-event probability は `(2^k - choose k r)/2^k`、drift は
`log(2^k / choose k r)` になる。`BernoulliCSPUniversality.exactlyOneSAT_eq_exactRSAT` により、
exactly-one-SAT はこの family の `r = 1` specialization として接続される。
さらに `ThresholdCardinalitySATChernoffCollapse` で at-most-`r` / at-least-`r` threshold family へ拡張した。
allowed pattern はそれぞれ `sum_{i <= r} choose k i` と `sum_{r <= i <= k} choose k i` であり、
drift は `log(2^k / allowed)` になる。部分二項和が \(0\) と \(2^k\) の間に入ることを証明してから
同じ multi-forbidden witness bridge に渡している。

---

## 1. 論文 ↔ Lean 対応マトリクス

| 論文箇所 | 主張 | 対応 Lean ファイル | 状態 |
|---------|------|------------------|------|
| Paper 1 §2 縮小列・命題 | V⁽⁰⁾ ⊇ ... ⊇ V⁽ⁿ⁾ の命題 | `GeneralStateDynamics.lean`, `TelescopingExp.lean` | 形式化済 |
| Paper 1 §2 P5 表現安定性 | coarse-graining 下の予測不変 | `CoarseGraining.lean`, `ScaleInvariance.lean`, `CoarseTotalProduction.lean` | 形式化済（論文未掲載） |
| Paper 1 §3.1 B1–B4 公理 | 損失尺度 f の公理系 | `LogUniqueness.lean` | 形式化済・論文掲載 |
| Paper 1 §3.2 対数比一意性 | f(r) = -k ln r 一意強制 | `LogUniqueness.lean`, `CauchyExponential.lean` | 形式化済・論文掲載 |
| Paper 1 §4 命題1 望遠鏡積 | m(V⁽ⁿ⁾) = m(V⁽⁰⁾)e⁻ᴸ 恒等式 | `TelescopingExp.lean` | 形式化済・論文掲載 |
| Paper 1 §5 S = Me⁻ᴸ, S_c 閾値 | 構造持続ポテンシャル | `FullFormula.lean`, `Penalty.lean`, `Basic.lean` | 形式化済（3因子分解まで） |
| Paper 1 §5 崩壊 S < S_c | 崩壊条件 | `CollapseTimeBound.lean`, `StochasticCollapseTimeBound.lean`, `HighProbabilityCollapse.lean` | **確率版まで拡張済（論文未掲載）** |
| Paper 2 §2 A1/A2/A3 | 三条件の分離 | `AxiomsToExp.lean` | 形式化済・論文掲載 |
| Paper 2 §3 恒等式 A1–A2 のみ | 独立性不要 | `TelescopingExp.lean` | 形式化済・論文掲載 |
| Paper 2 §4 弱依存 ρ-境界 | e⁻ᴸ⁽¹⁺ρ⁾ ≤ P ≤ e⁻ᴸ⁽¹⁻ρ⁾ | `WeakDependence.lean`, `RobustSurvival.lean`, `SignedWeakDependence.lean` | 形式化済（signed 拡張は論文未掲載） |
| Paper 2 §4 真の martingale concentration | 論文に書かれず | `AzumaHoeffding.lean`, `BoundedAzumaConstruction.lean`, `ConditionalMartingale.lean`, `MartingaleDrift.lean`, `ConcentrationInterface.lean`, `ResourceBoundedConditionalAzuma.lean`, `ProbabilityConnection.lean` | **形式化済・論文未掲載（格上げ候補）** |
| Paper 2 §5 形式検証リスト | 5 ファイル明示 | 同上 | **実態は 30+ ファイル** |
| Paper 3 §5 指数表現の適用 | 経路集合縮小 | Paper 1 同等ファイル群を流用 | 形式化済 |
| Paper 3 §9.2 100ターン長期安定性 | 代謝ありで単調崩壊しない | `TypicalNondecrease.lean`, `ResourceBoundedDynamics.lean`, `ResourceBoundedStochasticCollapse.lean` | **形式化済・論文未掲載** |
| Paper 4 §7 条件 (i) 矛盾解消代謝 | パラメータ更新だけでは不十分 | `FiniteStateMarkovCollapse.lean`, `FiniteStateMarkovRepairChain.lean`, `MarkovRepairFailureExample.lean` | **最小形式モデル形式化済（論文未掲載）** |
| Paper 4 §7 F-v2c / F-multi | 修復・空間分離 | `MinimumRepairRate.lean`, `StochasticMinimumRepairRate.lean`, `CoarseMinimumRepairRate.lean` | 修復率下限として形式化（論文未掲載） |
| 補論 SAT §2.1 第一モーメント法 | E[#SAT] = 2ⁿ e⁻ᴸ | `SATFirstMoment.lean`, `KLDivergence.lean` | 形式化済 |
| 補論 SAT 第二モーメント法 | Paley-Zygmund 下界 | `SATSecondMoment.lean`, `SecondMomentBound.lean`, `CorrelatedSecondMoment.lean`, `PairCorrelation.lean` | 形式化済（相関 sandwich は論文未掲載の補強） |
| 補論 SAT §5.1 感度指数 c | μ_c ∝ eᶜᴸ、α-n 非対称性 | `AsymptoticExponent.lean`, `SensitivityAnalysis.lean` | 形式化済（β=1/2 neutrality は論文未掲載の洞察） |
| 補論 DSMF §11 介入設計 (μ 増加, L 減少) | 修復必要量の下限 | `MinimumRepairRate.lean`, `TotalProduction.lean`, `ResourceBudget.lean`, `ResourceBoundedDynamics.lean` | **形式化済・論文未掲載** |
| 補論 DSMF §5 A_k / L̂ / M 分解 | S = N_eff⁽⁰⁾ × (μ/μ_c) × e⁻ᴸ | `Penalty.lean`, `FullFormula.lean`, `MultiAttractor.lean` | 形式化済 |
| 補論 設計原理 §3 外部代謝層 | 矛盾整理 | `MinimumRepairRate.lean`, `FiniteStateMarkovRepairChain.lean` | 形式層あり |

---

## 2. カテゴリ別ファイル一覧

### A. 論文明示コア（5）— Paper 2 §5 掲載

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`LogUniqueness.lean`](Survival/LogUniqueness.lean) | `log_ratio_uniqueness`: B1–B4 → f(r) = -k ln r 一意 | Paper 1 §3.1 そのもの |
| [`TelescopingExp.lean`](Survival/TelescopingExp.lean) | `measure_eq_initial_mul_exp_neg_cumulative_loss`: mₙ = m₀·exp(-Σlᵢ) 純代数 | Paper 2 §3、A3 不要の最小コア |
| [`AxiomsToExp.lean`](Survival/AxiomsToExp.lean) | `joint_survival_eq_exp_neg_delta`: 独立積 → eˡ | Paper 1 §2、Paper 2 §3 |
| [`WeakDependence.lean`](Survival/WeakDependence.lean) | `WeakDependenceSandwich`: ρ-sandwich | Paper 2 §4 本丸 |
| [`RobustSurvival.lean`](Survival/RobustSurvival.lean) | `robustPotential`: μ·exp(-δ·(1+ρ))、保守的下界 | Paper 2 §4 拡張 |

### B. 基礎・情報理論（7）

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`Basic.lean`](Survival/Basic.lean) | S = E×N×Y 因子分解、`hazard_rate_decreasing` | 論文 Paper 1 の土台 |
| [`CauchyExponential.lean`](Survival/CauchyExponential.lean) | Cauchy 関数方程式 → e⁻ᶜˣ 一意 | Paper 1 §3.2 の裏付け |
| [`FullFormula.lean`](Survival/FullFormula.lean) | `FullHazardRate` with margin ratio g(μ/μ_c) | Paper 1 完全形式化 |
| [`Penalty.lean`](Survival/Penalty.lean) | `FullSurvival` + **死の3モード**定理（同質化・分裂・枯渇） | 3因子を結合。Death theorems は論文未掲載 |
| [`KLDivergence.lean`](Survival/KLDivergence.lean) | δ = D_KL(P_SAT ‖ P_0)、E[D_KL] ≥ δ | Paper 1 の情報理論接続 |
| [`HillNumber.lean`](Survival/HillNumber.lean) | N_eff ≤ N、等号は一様 | N_eff の基本性質 |
| [`FreeEnergy.lean`](Survival/FreeEnergy.lean) | F(δ) = -ln C + δ、存続最大化 ↔ 自由エネルギー最小化 | Landau 型相転移の裏付け |

### C. 補論 SAT（Route A 硬い検証）（7）

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`SATFirstMoment.lean`](Survival/SATFirstMoment.lean) | ∏pᵢ = e⁻ᴸ, I(3-clause) = ln(8/7), α_r/α_x = ln 2/ln(8/7) | 補論 §2.1 直接 |
| [`SATSecondMoment.lean`](Survival/SATSecondMoment.lean) | E[X²] = Σ_d C(n,d) g(d/n)^m 重なり分解 | Route A 下界の鍵 |
| [`SecondMomentBound.lean`](Survival/SecondMomentBound.lean) | Paley-Zygmund: Pr[X>0] ≥ E[X]²/E[X²] | 下界の形式根拠 |
| [`PairCorrelation.lean`](Survival/PairCorrelation.lean) | g(β) = 3/4 + (1-β)³/8、R(1/2) = 1 | 重なり分布の骨格 |
| [`CorrelatedSecondMoment.lean`](Survival/CorrelatedSecondMoment.lean) | secondMoment ∈ [2ⁿ(3/4)ᵐ, 2ⁿ(7/8)ᵐ] | **相関下で sandwich、論文未掲載** |
| [`AsymptoticExponent.lean`](Survival/AsymptoticExponent.lean) | φ(β,α) = h(β) - ln 2 + α ln R(β)、φ(1/2, α)=0 ∀α | **β=1/2 neutrality、論文未掲載洞察** |
| [`SensitivityAnalysis.lean`](Survival/SensitivityAnalysis.lean) | S_mult 零崩壊 vs S_add 非零崩壊 | **乗法/加法モデルの定性差、論文未掲載** |

### C2. Route A 非CSP core examples（10）

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`SerialReliability.lean`](Survival/SerialReliability.lean) | 直列系信頼度 `R = ∏ p_i` と累積損失 `L = Σ -log p_i` から `R = exp(-L)`、および `L ≥ -log θ → R ≤ θ` | A08。B3 の独立部分加法性を SAT 以外の教科書的工学例で補強 |
| [`ConstantFractionDecay.lean`](Survival/ConstantFractionDecay.lean) | 一定割合 `q` の残存過程で `q^n = exp(-n(-log q))`、および `L ≥ -log θ → q^n ≤ θ` | A02/A03/A04/A16。放射性崩壊・吸収・一次反応・一次薬物動態の共通指数減衰核 |
| [`BranchingProcessExtinction.lean`](Survival/BranchingProcessExtinction.lean) | 平均子孫数 `m ≤ 1` の分岐過程 expectation skeleton で `m^n = exp(-n(-log m))`、subcritical なら `-log m > 0` | A13。絶滅閾値の期待値レベル最小モデル |
| [`QueueStability.lean`](Survival/QueueStability.lean) | fluid queue で `backlog_n = initial + n(arrival-service)`、安定時は増えず、過負荷時は線形に閾値到達 | A07/A28。処理資源を超えた負荷の累積崩壊 skeleton |
| [`BinarySymmetricChannel.lean`](Survival/BinarySymmetricChannel.lean) | 独立 binary channel で block success `(1-p)^n = exp(-n(-log(1-p)))`、loss 閾値から block failure 下界を導く | A06/A19。通信路・誤り訂正側の指数的復元失敗 skeleton |
| [`FatigueDamage.lean`](Survival/FatigueDamage.lean) | 応力サイクル損傷 `D_n = Σ_{i<n} d_i` が capacity を超えると破断、一定損傷では `D_n = n d` | A23。材料疲労・Miner 則型の累積閾値 skeleton |
| [`ConsensusFaultThreshold.lean`](Survival/ConsensusFaultThreshold.lean) | 累積故障数 `F_n = Σ_{i<n} f_i` が fault budget を超えると合意不能、一定故障流では `F_n = n f` | A25。分散合意の故障閾値 skeleton |
| [`MemoryThrashing.lean`](Survival/MemoryThrashing.lean) | working set が physical memory を超えると `faultPressure_n = initial + n(workingSet-memory)` が線形増加し閾値到達 | A27。メモリ階層・スラッシングの working-set overflow skeleton |
| [`BucklingThreshold.lean`](Survival/BucklingThreshold.lean) | load ramp `P_n = P_0 + n ΔP` が critical load `Pcr` に到達/超過すると座屈閾値到達 | A10。機械構造体の critical-load threshold skeleton |
| [`PercolationThreshold.lean`](Survival/PercolationThreshold.lean) | occupation ramp `p_n = p_0 + n Δp` が critical occupation `p_c` に到達/超過すると percolation threshold 到達 | A11/A12。巨大成分・パーコレーション転移の threshold skeleton |

### C3. G6-c formal mapping（1）

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`LyapunovBalanceEmbedding.lean`](Survival/LyapunovBalanceEmbedding.lean) | Lyapunov/load sequence `Z_t` から `a_t = Z_{t+1}-Z_t`, `A_n = Z_n-Z_0`, `R_{t+1}=R_t exp(-a_t)`、queue excess demand への wrapper | G6-c。Foster-Lyapunov / queueing drift を構造収支律の expectation-level tendency へ埋め込む最小代数 skeleton |

### D. 表現安定性・粗視化（5）— Paper 1 §2 P5

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`ScaleInvariance.lean`](Survival/ScaleInvariance.lean) | S = N_eff·exp(-δ)·(μ/μ_c) のスケール不変性 | Paper 1 §2 P5 の形式化、論文未掲載 |
| [`CoarseGraining.lean`](Survival/CoarseGraining.lean) | admissible coarse-graining で可達領域 commute | 集合論的に P5 を実装 |
| [`CoarseTotalProduction.lean`](Survival/CoarseTotalProduction.lean) | 粗視化下で total production 保存 | 〃 |
| [`CoarseStochasticTotalProduction.lean`](Survival/CoarseStochasticTotalProduction.lean) | 微視 ae-nonneg → 粗視 monotone | 確率版 P5、論文未掲載 |
| [`CoarseTypicalNondecrease.lean`](Survival/CoarseTypicalNondecrease.lean) | 微視 resource-bounded → 粗視 monotone | 粗視化下の単調性保存 |
| [`CoarseMinimumRepairRate.lean`](Survival/CoarseMinimumRepairRate.lean) | 粗視化下の修復率下限 | DSMF §11 の粗視化版 |
| [`CoarseStochasticStoppingTimeCollapse.lean`](Survival/CoarseStochasticStoppingTimeCollapse.lean) | 粗視 + 停止時刻 + 高確率崩壊 | 積層フレーム、論文未掲載 |

### E. Azuma-Hoeffding / Martingale / Concentration（11）— **論文 Paper 2 §4 の格上げ候補**

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`AzumaHoeffding.lean`](Survival/AzumaHoeffding.lean) | `collapseWithAzumaHoeffdingBound_of_initial_margin`: martingale-like なら初期マージンで exp(-r²/(2V_n)) 崩壊 | Paper 2 §4 の真の martingale concentration |
| [`BoundedAzumaConstruction.lean`](Survival/BoundedAzumaConstruction.lean) | bounded increments + good event → `AzumaHoeffdingConcentration` 構成 | 標準 Azuma setup |
| [`ConditionalMartingale.lean`](Survival/ConditionalMartingale.lean) | mathlib `Martingale` → `MartingaleLike`（ドリフト=0） | Mathlib 接続 |
| [`MartingaleDrift.lean`](Survival/MartingaleDrift.lean) | `expectedCumulative_eq_initial_of_martingaleLike` | ドリフト言語の foundation |
| [`ConcentrationInterface.lean`](Survival/ConcentrationInterface.lean) | `collapseWithFailureBound_of_expected_center`, `largeDeviationFailureBound` | concentration interface 抽象化 |
| [`ResourceBoundedConditionalAzuma.lean`](Survival/ResourceBoundedConditionalAzuma.lean) | conditional submartingale drift + bounded increments → stopped collapse | 確率的停止時刻崩壊 |
| [`SignedWeakDependence.lean`](Survival/SignedWeakDependence.lean) | `signed_survival_sandwich`: \|A_eff - A_ref\| ≤ ρ\|A_ref\| で exp 境界 | **Paper 2 §4 の signed 厳密化、論文未掲載** |
| [`ProbabilityConnection.lean`](Survival/ProbabilityConnection.lean) | actual probability space → expected cumulative process | 基盤層 |
| [`StochasticTotalProduction.lean`](Survival/StochasticTotalProduction.lean) | random net action + random cost → stochastic process、deterministic embedding | Paper 1 の確率拡張、論文未掲載 |
| [`StochasticTotalProductionAzuma.lean`](Survival/StochasticTotalProductionAzuma.lean) | bounded increment Azuma witness → stopped collapse | total production × Azuma |
| [`StochasticMinimumRepairRate.lean`](Survival/StochasticMinimumRepairRate.lean) | a.e. cost lower bound → expected cost 下界 | 修復率の stochastic 化 |

### F. 崩壊時刻・停止時刻（10）— **論文 Paper 1 §5 の確率的厳密化候補**

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`CollapseTimeBound.lean`](Survival/CollapseTimeBound.lean) | A_n ≥ -log θ → mass ≤ θ | Paper 1 §5 決定論的版 |
| [`StochasticCollapseTimeBound.lean`](Survival/StochasticCollapseTimeBound.lean) | A_n(ω) ≥ -log θ a.s. → 生存率 ≤ θ a.s. | 経路別上界 |
| [`HighProbabilityCollapse.lean`](Survival/HighProbabilityCollapse.lean) | 閾値越え事象 E → E で崩壊 | 失敗確率付き崩壊 |
| [`TypicalNondecrease.lean`](Survival/TypicalNondecrease.lean) | E[drift_t] ≥ 0 → E[cum] monotone | 確率層の基盤 |
| [`CliffWarning.lean`](Survival/CliffWarning.lean) | remainingMargin ≤ stepLoss - stepCost → 次ステップ確定崩壊 | **決定論的事前警告、論文未掲載** |
| [`StochasticCliffWarning.lean`](Survival/StochasticCliffWarning.lean) | `collapseAlmostSurely_next_of_remainingMargin_le_increment_ae` | 確率版事前警告、論文未掲載 |
| [`StoppingTimeCliffWarning.lean`](Survival/StoppingTimeCliffWarning.lean) | `collapseHittingTime_isStoppingTime`、optional stopping | 停止時刻形式化、論文未掲載 |
| [`StoppingTimeCollapseEvent.lean`](Survival/StoppingTimeCollapseEvent.lean) | hittingTime < N の直接イベント境界 | Paper 1 §5 確率版 |
| [`StoppingTimeHighProbabilityCollapse.lean`](Survival/StoppingTimeHighProbabilityCollapse.lean) | 停止値での S < θ の確率境界 | optional stopping × Azuma |
| [`StoppingTimeSharpDecomposition.lean`](Survival/StoppingTimeSharpDecomposition.lean) | τ < N と τ = N の完全分離 | 有限地平線の精密分解 |

### G. 修復率・予算・動力学（6）— **論文 DSMF §11 の形式化**

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`MinimumRepairRate.lean`](Survival/MinimumRepairRate.lean) | mass 保持 θ → cost ≥ loss + log θ | **代謝必要量の下限、論文未掲載** |
| [`TotalProduction.lean`](Survival/TotalProduction.lean) | Σ = A + C の分解 | DSMF §5 基本 |
| [`ResourceBudget.lean`](Survival/ResourceBudget.lean) | cumulativeGain ≤ cumulativeCost | 資源会計の基盤公理 |
| [`ResourceBoundedDynamics.lean`](Survival/ResourceBoundedDynamics.lean) | resource-bounded → Σ 単調 | Paper 3 §9.2 長期安定性、Paper 4 §7 の基礎 |
| [`ResourceBoundedStochasticCollapse.lean`](Survival/ResourceBoundedStochasticCollapse.lean) | initial margin → high-probability stopped collapse | **最重要の高確率層、論文未掲載** |
| [`GeneralStateDynamics.lean`](Survival/GeneralStateDynamics.lean) | `feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction`: 符号付き指数カーネル | **Paper 1 の暗黙核定理を形式化** |

### H. マルコフ修復チェーン（3）— **Paper 4 §7 条件 (i) 最小形式モデル**

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`FiniteStateMarkovCollapse.lean`](Survival/FiniteStateMarkovCollapse.lean) | 有限状態 Markov chain → stopped collapse bound | Paper 4 §7 最小モデル、論文未掲載 |
| [`FiniteStateMarkovRepairChain.lean`](Survival/FiniteStateMarkovRepairChain.lean) | statewise-nonneg → 経路別 total production nonneg | failure/idle/repair 三状態 |
| [`MarkovRepairFailureExample.lean`](Survival/MarkovRepairFailureExample.lean) | 有限状態 → resource-bounded | 継続学習での修復/回復具体化 |

### I. 具体例・相転移（4）

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`ConstantDriftExample.lean`](Survival/ConstantDriftExample.lean) | 定常ドリフト → 高確率崩壊 | 最小確率モデル |
| [`ToyRandomWalk.lean`](Survival/ToyRandomWalk.lean) | nonneg increment RW → monotone | 軽量具体例 |
| [`MultiAttractor.lean`](Survival/MultiAttractor.lean) | `uniformBasinSurvival_decreasing_in_m`, `transitionPoint` | 盆地局所生存 |
| [`TransitionTheorem.lean`](Survival/TransitionTheorem.lean) | m* = ln(C_A/C_B)/(I_A - I_B) で盆地転移 | Landau 型の最小 toy transition、論文未掲載 |

### J. 時間方向（3）

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`ArrowOfTime.lean`](Survival/ArrowOfTime.lean) | `survival_h_theorem`: δ 単調減少 | 補論 SAT §4（未明示）対応 |
| [`ArrowOfTimeGeneral.lean`](Survival/ArrowOfTimeGeneral.lean) | 3種以上への Chebyshev 拡張 | 〃 |
| [`ArrowOfTimeNGeneral.lean`](Survival/ArrowOfTimeNGeneral.lean) | 有限 `n` 種への H-theorem-style 一般化 | 〃 |

---

## 3. 論文未反映の価値ある成果（格上げ候補）

### 3.1 Paper 2 §5 形式検証リストのアップデート

**現状の論文本文:**
> 検証対象は以下の通りである。
> - AxiomsToExp.lean
> - WeakDependence.lean
> - RobustSurvival.lean
> - TelescopingExp.lean
> - LogUniqueness.lean

**実際に形式化済みで掲載可能なもの:**
- `CauchyExponential.lean` — Cauchy 関数方程式の連続加法関数線形性。LogUniqueness の下部
- `GeneralStateDynamics.lean` — 符号付き指数カーネル定理
- `SignedWeakDependence.lean` — ρ-境界の signed 厳密化
- `AzumaHoeffding.lean` + 付随 5 ファイル — ρ-境界の martingale concentration 化
- `CoarseGraining.lean` + `ScaleInvariance.lean` + `CoarseTotalProduction.lean` — P5 表現安定性の形式化
- `CollapseTimeBound.lean` + `StochasticCollapseTimeBound.lean` + `HighProbabilityCollapse.lean` — Paper 1 §5 崩壊閾値 S_c の確率的厳密化

これだけで 5 → 約 20 ファイルへ拡張可能。

### 3.2 Paper 2 §4 の主張強度を一段上げる提案

**現状の論文本文（§4）:**
> 依存の効果が参照モデルからの相対誤差として ρ（0 ≤ ρ < 1）で抑えられているとする。

これは抽象的な相対誤差仮定に留まっている。

**Lean 側で既に形式化されている代替:**
`AzumaHoeffding.lean` + `BoundedAzumaConstruction.lean` + `ConditionalMartingale.lean` により、段階損失 l_i が bounded increments を満たす conditional martingale なら、Azuma-Hoeffding 不等式から `exp(-r²/(2V_n))` の具体的な指数境界が得られる。

**論文への反映案:**
Paper 2 §4 に「§4.1 真の martingale concentration による厳密化」を追加し、SignedWeakDependence + ConditionalMartingale + AzumaHoeffding を引用することで、弱依存の扱いを「相対誤差 ρ を仮定」から「bounded martingale increments → 具体的 variance proxy」へ格上げできる。

### 3.3 Paper 4 §7 「条件 (i) 矛盾解消代謝」の形式モデル

**現状の論文本文（§7.4）:**
> LoRA ベース継続学習は条件 (ii) を部分的に緩めるが、条件 (i)（矛盾解消代謝機構）を備えていない。

これも言葉による主張に留まっている。

**Lean 側の未反映モデル:**
`FiniteStateMarkovRepairChain.lean` + `MarkovRepairFailureExample.lean` が failure/idle/repair の三状態で最小形式モデルを与えている。さらに `MinimumRepairRate.lean` が「mass 保持 θ → cost ≥ loss + log θ」として**代謝必要量の下限定理**を形式化済み。

**論文への反映案:**
Paper 4 §7.4 に「§7.4.1 最小マルコフ修復チェーンモデル」を追加し、条件 (i) が欠けた場合に mass 保持が指数的に崩壊することを定理化できる。これは LoRA の上書き的振る舞いの定性観察を、**形式モデル上の定理に昇格**させる。

### 3.4 補論 SAT の論文未掲載洞察

- **`AsymptoticExponent.lean` の β=1/2 neutrality**: φ(1/2, α) = 0 がすべての α で成立 → α_c と α_c^(1) の gap は β ≠ 1/2 の contributions に由来する構造的理由。論文は Paley-Zygmund 下界だけ述べるが、gap の structural reason まで踏み込めば補論 SAT の説明力が一段上がる。
- **`CorrelatedSecondMoment.lean` の相関 sandwich**: secondMoment ∈ [2ⁿ(3/4)ᵐ, 2ⁿ(7/8)ᵐ] を相関性不要で保証。論文は独立性仮定下での結果に見えるが、実は相関下でも下界がロバストに成立。
- **`SensitivityAnalysis.lean` の零崩壊**: S_mult は任意因子=0 で崩壊、S_add は崩壊しない。乗法構造が CDCL/WalkSAT の c 値の違いを説明する候補。

### 3.5 Paper 1 §5 崩壊閾値 S_c の確率的厳密化

**現状の論文本文:**
> S < S_c となるとき構造は失われる。

これだけでは崩壊が「いつ・どの確率で」起きるかの予測は出ない。

**Lean 側の未反映:**
- `CliffWarning.lean` / `StochasticCliffWarning.lean`: 次ステップ崩壊を保証する事前警告条件
- `StoppingTimeCollapseEvent.lean` / `StoppingTimeHighProbabilityCollapse.lean`: τ^θ が停止時刻であり、有限地平線内で θ 越えが起きる確率境界
- `StoppingTimeSharpDecomposition.lean`: τ < N と τ = N の精密分離

これらを合わせると「S_c を θ として τ^θ < N となる確率上界」が Azuma から出る。Paper 1 §5 を Paper 1.5（Paper 1 と Paper 2 の間）として補強するか、Paper 2 に吸収するか、の設計判断ができる材料。

### 3.6 Paper 1 §2 P5 表現安定性の形式化

論文本文は「表現安定性」を適用可能性条件として宣言するだけで、形式的にどこまで実装可能かは示していない。

**Lean 側の未反映:**
- `CoarseGraining.lean`: admissible coarse-graining で可達領域が commute
- `ScaleInvariance.lean`: S = N_eff·exp(-δ)·(μ/μ_c) のスケール不変性
- `CoarseTotalProduction.lean` / `CoarseStochasticTotalProduction.lean`: total production の粗視化下保存
- `CoarseMinimumRepairRate.lean` / `CoarseTypicalNondecrease.lean` / `CoarseStochasticStoppingTimeCollapse.lean`: 粗視化の下で代謝・単調性・停止時刻崩壊が同時に保存

これは P5 を「宣言」から「定理」へ近づける主要な材料。

---

## 4. 気になる点

1. **ビルド整合性**: 134 ファイルは `Survival.lean` の top-level import を通じて一貫して検証する設計である。今後は `PAPER_MAPPING.md` の freeze snapshot ごとに `lake build Survival` の通過状況を併記する。
2. **重複可能性**: `Coarse*` と `Stochastic*` の組合せで似た主張が複数箇所にある可能性。一本化できるものはリファクタ候補。
3. **ArrowOfTime 系の位置づけ**: 補論 SAT §4 らしい H 定理的主張だが、論文本文に対応章が明示されていない。SAT への熱力学的意味付けを追加するか、独立補論として切り出すか、の判断が必要。
4. **論文側の空白**: 上記 3.1–3.6 の未反映分を Paper 2 と補論 SAT / 設計原理 に反映しないままだと、Lean 資産が **論文強度に寄与しない状態**が続く。特に 3.2（Paper 2 §4 格上げ）と 3.3（Paper 4 §7 マルコフモデル）は、査読者が Route A/B 強度を評価する際に効く。

---

## 5. 推奨される次アクション

優先度順:

1. **Paper 2 §5 の形式検証対象リストを 5 → ~20 ファイルへ拡張**する最小差分 patch を書く（§3.1）。論文強度が既存資産だけで一段上がる。
2. **Paper 2 §4 に真の martingale concentration サブセクションを追加**（§3.2）。`AzumaHoeffding.lean` を引用。
3. **Paper 4 §7.4 に最小マルコフ修復チェーン**を入れる（§3.3）。Paper 4 の主張が形式モデル上の定理で裏付けられる。
4. `lake build Survival` の通過状況と、134 ファイルの依存グラフを図示。棚卸しの完成度を検証。
5. 補論 SAT の `AsymptoticExponent` / `CorrelatedSecondMoment` / `SensitivityAnalysis` の論文未掲載洞察を、補論 SAT §6 限界節または新規節として追加（§3.4）。

以上。
