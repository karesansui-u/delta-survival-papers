# Lean 形式検証 ↔ 論文対応棚卸し

棚卸し日: 2026-05-22
対象: `lean/Survival/` 配下 174 ファイル
対応文書: `delta-survival-paper/v2/` 配下の主理論 spine、Route C companions、補論群

## 現在の結論

このファイルを、Lean 形式化と論文本文を結ぶ唯一の reader-facing theorem map とする。
旧 SAT/CSP 専用 map は現行ツリーから外し、git history / OSF snapshot 側の archive として扱う。

現時点の Lean 側は **174 Survival modules** で閉じており、imported `Survival` target には
project-level の `sorry` / `admit` / declared `axiom` を置いていない。条件つき導出補論 §5 が
明示している 5 ファイルを超えて、停止時刻崩壊、martingale concentration、粗視化、有限状態 Markov
microfoundation、SAT/k-SAT Chernoff-KL chain、Bernoulli-CSP 水平展開、Route A 非CSP skeletons、
KL divergence / channel skeleton / BEC-style finite boundary、LLM-style epistemic control bridge、
evidence-packet bridge、toy LLM control instantiation、toy LLM memory use-condition
instantiation、toy software-contract instantiation、toy software evidence-packet instantiation、
dependency-closure budget toy、LLM memory / reasoning strengthening toy、
epistemic-control stack entry point まで含む。

## 証拠の階層

この mapping は「Lean で何が閉じているか」と「論文で何を前面に出すべきか」を分ける。
現時点の強い主証拠は SAT と LLM に集中しており、非CSP例は新規予測ではなく sanity / coverage benchmark
として読む。

| 層 | 位置づけ | 読み方 |
|---|---|---|
| SAT chain v1.0 | 数学的 anchor | random 3-SAT の自然測度、actual path measure、MGF product、Chernoff/KL collapse が有限地平線で閉じている |
| LLM 810 試行 | 経験的 anchor | 文脈長・制約数だけの基準モデルを越え、構造矛盾がより強い崩壊要因になることを示す |
| Epistemic control bridge | 抽象 bridge | LLM の意味論や性能は証明せず、矛盾更新・修復更新・記憶資格・依存再編を既存の finite net-action kernel へ接続する条件つき interface を示す |
| Bernoulli CSP universality v1.2 | template validation | fixed assignment/coloring の iid bad-event exposure に限った水平展開。solver dynamics や依存構造は含めない |
| Numerical sanity checks | tests-as-documentation | 抽象 wrapper が小さな具体例で期待される定数を返すことを reader-facing に確認する。経験的 support ではない |
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
| net-consumption exponential kernel | local net-consumption identity / feasible mass | `feasibleMass_succ_eq_mass_mul_exp_neg_stepNetAction`; `feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction` | proven |
| cumulative net consumption kernel \(m(V^{(n)}) = m(V^{(0)}) e^{-B_n}\) | cumulative net-consumption coordinate | `feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction` | proven |
| repair/resource contribution dominates contraction loss | nonnegative step total production | `expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction` | proven; naming gap only |
| deterministic total production tendency | deterministic step model | `deterministic_expectedCumulative_monotone` | proven |
| coarse-grained typical nondecrease | coarse stochastic compatibility | `coarse_expectedCumulative_monotone_of_micro_nonnegative`; `coarse_expectedCumulative_monotone_of_micro_resourceBounded`; `coarse_expectedCumulative_monotone_of_micro_conditionalAzuma` | proven |
| SAT expected tendency | state-dependent SAT step model | `expectedCumulative_monotone_stepModel`; `expectedCumulative_eq_initial_add_linear` | proven; mapping sufficient |
| Bernoulli-CSP finite drift / collapse tendency | bad-event exposure, drift, Chernoff margin | `drift`; `expectedBadEmission_eq_drift`; `collapseWithChernoffBound_of_linearMargin`; `stoppedCollapseWithChernoffBound_of_linearMargin` | proven; different schema from repair dominance |
| Bernoulli-CSP \(\Sigma\) lower-tail tendency | one-sided cumulative production as \(\Sigma\) | `BernoulliTypicalSigma.bernoulliSigmaLowerTailMeasure_le_chernoffFailureBound_of_interior`; `BernoulliTypicalSigma.bernoulliSigma_lowerBoundWithChernoffBound_of_interior`; `BernoulliTypicalSigma.bernoulliSigma_expectedCumulative_monotone` | proven; finite-path / expectation-level wrapper, not unconditional second law |
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

### Admissible-Map Wrapper Layer

The admissible-map supplement now has a thin Lean entry point for the first two
map layers:

| Paper-side phrase | Lean vocabulary | Lean theorem / object | Status |
|---|---|---|---|
| cumulative log-ratio readout | finite mass sequence readout | `AdmissibleMapInvariants.cumulativeStageLoss` | defined |
| isomorphic mass readouts preserve \(B_n\) | same masses up to horizon | `AdmissibleMapInvariants.iso_invariance` | proven |
| positive gauge readout makes \(B_n\) covariant | stage losses scale by \(\alpha\) | `AdmissibleMapInvariants.positive_gauge_covariance` | proven |
| positive gauge preserves comparisons | positive scalar multiplication is order-preserving | `AdmissibleMapInvariants.positive_gauge_preserves_order` | proven |
| positive gauge preserves nonnegative regime | \(0 \le \alpha B\iff 0\le B\) for \(\alpha>0\) | `AdmissibleMapInvariants.positive_gauge_preserves_nonnegative` | proven |
| exact admissible coarse map | initial / contraction / repair commute with the coarse map | `AdmissibleMapCompatibility.CompatibleCoarseMap` | defined |
| feasible trajectory compatibility | \(π(V_t)=\bar V_t\) along the generated trajectory | `AdmissibleMapCompatibility.feasible_trajectory_commutes` | proven |
| contracted intermediate compatibility | \(π(V_t^-)=\bar V_t^-\) along the trajectory | `AdmissibleMapCompatibility.contraction_commutes_along_trajectory` | proven |
| repaired intermediate compatibility | \(π(R_t(V_t^-))=\bar R_t(\bar V_t^-)\) along the trajectory | `AdmissibleMapCompatibility.repair_commutes_along_trajectory` | proven |
| exact signed-kernel preservation | uniform mass scaling preserves \(B_n\) | `AdmissibleMapCompatibility.cumulative_net_action_preserved_of_uniform_mass_scaling` | proven |
| saturation-defect readout spec | coarse stage loss differs by \(e_t-e_{t+1}\) | `SaturationDefect.SaturationDefectReadout` | defined |
| set-level saturation defect | \(e_\pi(A)=\log(m(\pi^{-1}\pi(A))/m(A))\) | `SaturationDefect.saturationDefectOfCoarseMap` | defined |
| set-level defect instantiates readout spec | positive set masses for \(V_t\) and \(\pi^{-1}\pi(V_t)\) | `SaturationDefect.coarseMap_saturationDefectReadout_of_positive_setMass` | proven |
| coarse cumulative loss with saturation defect | \(B_n^{coarse}=B_n^{micro}+e_0-e_n\) | `SaturationDefect.coarse_cumulativeStageLoss_eq_micro_add_initial_defect_sub_terminal` | proven at readout level |
| conditional coarse monotonicity | \(e_0\le e_n\Rightarrow B_n^{coarse}\le B_n^{micro}\) | `SaturationDefect.coarse_cumulativeStageLoss_le_micro_of_terminal_defect_ge_initial` | proven at readout level |
| defect-controlled contraction loss | contracted-intermediate defect enters contraction loss | `DefectControlledAdmissibleMap.contractionLoss_coarse_eq_micro_add_feasible_defect_sub_contracted_defect` | proven at readout level |
| defect-controlled repair gain | contracted-intermediate defect enters repair gain | `DefectControlledAdmissibleMap.repairGain_coarse_eq_micro_add_next_feasible_defect_sub_contracted_defect` | proven at readout level |
| contracted-defect cancellation | \( \bar b_t=b_t+e_V(t)-e_V(t+1) \) | `DefectControlledAdmissibleMap.stepNetAction_coarse_eq_micro_add_feasible_defect_sub_next_feasible_defect` | proven at readout level |
| cumulative defect-controlled signed action | \( \bar B_n=B_n+e_V(0)-e_V(n) \) | `DefectControlledAdmissibleMap.cumulativeNetAction_coarse_eq_micro_add_initial_defect_sub_terminal` | proven at readout level |
| Bernoulli-CSP \(\Sigma\) observable | cumulative bad-event production as total-production coordinate | `BernoulliTypicalSigma.bernoulliSigma`; `BernoulliTypicalSigma.bernoulliSigmaProcess` | defined |
| Bernoulli-CSP adjacent \(\Sigma\) nondecrease | one-sided bad-event emissions are nonnegative | `BernoulliTypicalSigma.bernoulliSigma_succ_le`; `BernoulliTypicalSigma.bernoulliSigma_initial_le` | proven pathwise for the finite-path observable |
| Bernoulli-CSP expected \(\Sigma\) monotonicity | nonnegative one-step bad-event emissions | `BernoulliTypicalSigma.bernoulliSigma_expectedCumulative_monotone` | proven |
| Bernoulli-CSP \(\Sigma\) lower-tail certificate | interior KL/Chernoff finite-path lower-tail bound | `BernoulliTypicalSigma.bernoulliSigmaLowerTailMeasure_le_chernoffFailureBound_of_interior` | proven under interior margin assumptions |
| Bernoulli-CSP \(\Sigma\) high-probability lower bound | good event with `center-r ≤ Σ_n` and Chernoff failure bound | `BernoulliTypicalSigma.BernoulliSigmaLowerBoundWithFailureBound`; `BernoulliTypicalSigma.bernoulliSigma_lowerBoundWithChernoffBound_of_interior` | proven under finite-path interior assumptions |
| Bernoulli-CSP fixed-time typical growth | same good event has initial-to-time nondecrease and `center-r ≤ Σ_n` | `BernoulliTypicalSigma.BernoulliSigmaTypicalGrowthWithFailureBound`; `BernoulliTypicalSigma.bernoulliSigma_typicalGrowthWithChernoffBound_of_interior` | proven under finite-path interior assumptions |
| Bernoulli-CSP coarse terminal lower-bound transfer | endpoint defect budget \(e_n-e_0\le\delta\) degrades `center-r ≤ Σ_n` to `center-r-δ ≤ Σ̄_n` | `BernoulliTypicalSigma.CoarseBernoulliSigmaLowerBoundWithFailureBound`; `BernoulliTypicalSigma.coarseBernoulliSigma_lowerBoundWithChernoffBound_of_endpointDefectBudget` | proven as fixed-time conditional readout transfer |
| Bernoulli-CSP coarse fixed-time typical growth | coarse monotonicity plus endpoint defect budget transfer the fixed-time certificate | `BernoulliTypicalSigma.CoarseBernoulliSigmaTypicalGrowthWithFailureBound`; `BernoulliTypicalSigma.coarseBernoulliSigma_typicalGrowthWithChernoffBound_of_endpointDefectBudget` | proven as conditional readout-level transfer |
| Bernoulli-CSP admissible-map v0 sufficient package | endpoint identity, endpoint defect budget, and coarse monotonicity as enough conditions for the coarse certificates | `BernoulliAdmissibleMapV0.BernoulliCoarseReadoutV0`; `BernoulliAdmissibleMapV0.BernoulliCoarseReadoutV0.lowerBoundWithChernoffBound_of_interior`; `BernoulliAdmissibleMapV0.BernoulliCoarseReadoutV0.typicalGrowthWithChernoffBound_of_interior` | proven as sufficient readout-level wrapper, not necessary/sufficient admissible-map characterization |
| Bernoulli-CSP \(\Sigma\) collapse wrappers | threshold / collapse / stopped-collapse / hitting-time API | `BernoulliTypicalSigma.bernoulliSigma_*WithChernoffBound_of_linearMargin` | proven under finite-horizon margin assumptions |

This is intentionally not a full category of structural-maintenance problems.
It now includes the exact admissible-map compatibility layer, where initial
regions, contractions, and repairs commute with the coarse map, plus the
finite mass-readout layer needed by the supplement's first claims. The
saturation defect wrapper includes the minimal set-level instantiation for
`eπ(A)=log(m(π⁻¹π(A))/m(A))` under positive mass assumptions. The
defect-controlled wrapper now also proves that contracted-intermediate defects
cancel in the signed net action, leaving only endpoint feasible defects.
`Survival.BernoulliAdmissibleMapV0` packages the Bernoulli endpoint identity,
endpoint defect budget, and coarse monotonicity assumptions as sufficient
conditions for the Phase-4 coarse \(\Sigma\) certificates. It still does not
claim that an arbitrary coarse map is admissible, nor does it prove an
unconditional DPI or a necessary/sufficient admissible-map characterization.
`analysis/phase5_admissible_map_ladder.md` records the ladder from this v0
sufficient package to the still-open set-level and necessary/sufficient
targets. Full set-level admissible coarse-graining and proxy / estimation
validation remain separate tasks.

### Sigma / Total Production Component

The second-law-level roadmap in
`analysis/second_law_level_roadmap.md` separates the path into admissible maps,
\(\Sigma\) / total production, typical nondecrease, limited-class universality,
and eventual cross-class unification. The important current update is that the
\(\Sigma\) component is not speculative: its deterministic and
expectation-level core already has Lean anchors.

This does **not** prove a full second-law analogue. It shows that the
open-system tendency candidate is already formally accessible at the
definition / expectation level, while high-probability and cross-class claims
still require explicit assumptions.

| Paper-side phrase | Lean vocabulary | Lean theorem / object | Status |
|---|---|---|---|
| deterministic expected \(\Sigma\) process | deterministic embedding of total production | `SecondLawTotalProduction.deterministicExpectedSigmaProcess` | defined |
| total production \(\Sigma_n = B_n + C_n\) | cumulative net action plus cumulative resource cost | `SecondLawTotalProduction.sigma_equals_B_plus_C` | proven by definition |
| stepwise \(\Sigma_t = b_t + c_t\) | step net action plus resource cost | `TotalProduction.stepTotalProduction` | defined |
| repair slack \(c_t-r_t\) | cost minus realized gain | `TotalProduction.stepRepairSlack` | defined |
| repair slack is nonnegative under a budget | budgeted repair cannot exceed cost | `TotalProduction.stepRepairSlack_nonneg`; `TotalProduction.cumulativeRepairSlack_nonneg` | proven |
| total production splits as loss plus repair slack | \(\Sigma = L + slack\) | `SecondLawTotalProduction.sigma_equals_L_plus_repair_slack` | proven |
| \(\Sigma\) dominates cumulative contraction loss | repair is not free | `SecondLawTotalProduction.sigma_at_least_L` | proven |
| exact payment recovers loss-only total | cost exactly equals gain | `SecondLawTotalProduction.sigma_equals_L_under_exact_payment` | proven |
| resource budget plus contraction lower bound gives one-step \(\Sigma\) drift | deterministic expected increment | `SecondLawTotalProduction.expected_sigma_drift_lower_bound` | proven |
| uniform contraction lower bound gives expected cumulative lower bound | linear expected \(\Sigma\) lower bound | `SecondLawTotalProduction.expected_cumulative_sigma_lower_bound` | proven |
| nonnegative typical contraction gives expected monotonicity | expectation-level tendency | `SecondLawTotalProduction.expected_sigma_monotone_of_nonnegative_typical_contraction` | proven |
| coarse expected \(\Sigma\) nondecrease under compatibility / resource-boundedness | coarse typical nondecrease | `CoarseTypicalNondecrease.coarse_expectedCumulative_monotone_of_micro_nonnegative`; `CoarseTypicalNondecrease.coarse_expectedCumulative_monotone_of_micro_resourceBounded`; `CoarseTypicalNondecrease.coarse_expectedCumulative_monotone_of_micro_conditionalAzuma` | proven under assumptions |

Reader-facing discipline:

```text
\Sigma_n is the open-system tendency candidate.
Raw B_n can decrease under recovery.
Expectation-level monotonicity and high-probability stopped-collapse are
different schemas and must not be merged without carrying the extra margin and
concentration assumptions.
```

### Phase 6.1 / Foster-Lyapunov Template Note

`analysis/phase6_foster_lyapunov_template.md` records the next limited-class
template after Bernoulli-CSP. `Survival.FosterLyapunovTemplate` now provides a
thin reader-facing wrapper for the Phase-6.1 v1 layer. It maps the
Bernoulli-CSP \(\Sigma\) grammar onto existing Foster-Lyapunov / queueing
anchors without strengthening them:

| Phase-6 role | Lean anchor | Reading discipline |
|---|---|---|
| Lyapunov / load increment | `FosterLyapunovTemplate.lyapunov_increment_eq_consumption_sub_recovery` | pathwise load difference, not recurrence |
| sign guardrail | `FosterLyapunovSignBridge.potentialIncrement_structuralPotential_eq_coreNetChangeFromMass`; `FosterLyapunovSignBridge.outsideSafeNegativeDrift_expectedNetChange_neg`; `FosterLyapunovSignBridge.positive_drift_is_destabilizing_direction` | `φ=-log m` gives `b=φ_next-φ_current`; negative expected net change is stabilizing direction, positive expected net change is destabilizing direction |
| cumulative action | `FosterLyapunovTemplate.lyapunov_cumulativeAction_eq_load_diff` | telescopes to `Z n - Z 0` |
| exponential maintenance update | `FosterLyapunovTemplate.lyapunov_relativeMaintenance_succ_eq_mul_exp_neg_increment` | signed-action coordinate, not a stability theorem |
| queue overload skeleton | `FosterLyapunovTemplate.queue_increment_eq_excessDemand`; `FosterLyapunovTemplate.queue_stable_increment_nonpos`; `FosterLyapunovTemplate.queue_overloaded_increment_pos` | deterministic finite-prefix skeleton |
| conditional-Azuma route | `FosterLyapunovTemplate.expectedSigma_monotone_of_conditionalAzuma`; `FosterLyapunovTemplate.fosterLyapunov_stoppedCollapseWithFailureBound_of_initialExpectedMargin`; `FosterLyapunovTemplate.fosterLyapunov_hittingTimeBeforeHorizonWithFailureBound_of_initialExpectedMargin` | expectation / stopped-collapse route under conditional-Azuma assumptions |
| resource-bounded high-probability route | `FosterLyapunovTemplate.fosterLyapunov_resourceBoundedExpectedSigma_monotone`; `FosterLyapunovTemplate.fosterLyapunov_stoppedCollapseWithFailureBound_of_resourceBoundedExpectedMargin`; `FosterLyapunovTemplate.fosterLyapunov_hittingTimeBeforeHorizonWithFailureBound_of_resourceBoundedExpectedMargin` | high-probability claims require bounded-increment, nonnegative step production, margin, and lower-tail assumptions |
| \(\Sigma\) / total production grammar | `SecondLawTotalProduction.*` | expectation-level tendency candidate |
| coarse expectation route | `FosterLyapunovTemplate.coarseExpectedSigma_monotone_of_conditionalAzuma` | conditional compatibility, not unconditional DPI |
| coarse high-probability transfer | `FosterLyapunovTemplate.coarseFosterLyapunov_stoppedCollapseWithFailureBound_of_microExpectedMargin`; `FosterLyapunovTemplate.coarseFosterLyapunov_hittingTimeBeforeHorizonWithFailureBound_of_microExpectedMargin` | stochastic compatibility plus a resource-bounded coarse model, not unconditional DPI |

The correct interpretation is:

```text
Foster-Lyapunov / queueing is staged as the second limited class template.
It shares the Sigma / drift / concentration / coarse-transfer grammar with
Bernoulli-CSP, but uses its own drift and Azuma-style concentration
assumptions. The v1 layer exposes stopped-collapse / hitting-time
high-probability certificates and coarse high-probability transfer under
explicit assumptions. It is not a positive-recurrence theorem, a
geometric-ergodicity theorem, a Bernoulli-style pathwise nondecrease theorem,
or an unconditional Lyapunov second law.
```

### Phase 6.2 / Repair-Maintenance Template Note

`analysis/phase6_repair_maintenance_template.md` records the third limited-class
template after Bernoulli-CSP and Foster-Lyapunov / queueing.
`Survival.RepairMaintenanceTemplate` gives a thin reader-facing wrapper for the
Phase-6.2 v0 layer. It maps explicit damage / repair flows onto the same
\(\Sigma\) / net-consumption / resource-cost / concentration / coarse-transfer
grammar without strengthening the claims:

| Phase-6 role | Lean anchor | Reading discipline |
|---|---|---|
| net consumption | `RepairMaintenanceTemplate.netConsumption_eq_damage_sub_repair` | finite-prefix \(d_t-r_t\), not stochastic reliability |
| cumulative net consumption | `RepairMaintenanceTemplate.cumulativeNetConsumption_succ` | finite-prefix algebra |
| accumulated damage | `RepairMaintenanceTemplate.damageLevel_eq_initial_plus_cumulativeNetConsumption` | \(D_n=D_0+\sum(d_t-r_t)\) |
| remaining margin | `RepairMaintenanceTemplate.margin_eq_initial_margin_sub_cumulativeNetConsumption` | margin coordinate, not Paper-1 resource term `M` |
| threshold crossing | `RepairMaintenanceTemplate.thresholdCrossed_iff_margin_nonpos`; `RepairMaintenanceTemplate.thresholdCrossed_of_initial_margin_le_cumulativeNetConsumption` | deterministic finite-prefix boundary |
| exponential maintenance update | `RepairMaintenanceTemplate.relativeMaintenance_succ_eq_mul_exp_neg_netConsumption` | signed-action coordinate |
| repair improves damage-only margin | `RepairMaintenanceTemplate.damageOnlyMargin_le_margin_of_repair_nonneg` | requires nonnegative repair |
| \(\Sigma\) / repair-cost grammar | `RepairMaintenanceTemplate.sigma_equals_B_plus_C`; `RepairMaintenanceTemplate.sigma_equals_L_plus_repair_slack`; `RepairMaintenanceTemplate.sigma_at_least_L` | repair is not free; cost moves into `Σ` |
| resource-bounded high-probability route | `RepairMaintenanceTemplate.repairMaintenance_resourceBoundedExpectedSigma_monotone`; `RepairMaintenanceTemplate.repairMaintenance_stoppedCollapseWithFailureBound_of_expectedMargin`; `RepairMaintenanceTemplate.repairMaintenance_hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin` | high-probability claims require a supplied resource-bounded stochastic step model |
| coarse high-probability transfer | `RepairMaintenanceTemplate.coarseRepairMaintenance_stoppedCollapseWithFailureBound_of_microExpectedMargin`; `RepairMaintenanceTemplate.coarseRepairMaintenance_hittingTimeBeforeHorizonWithFailureBound_of_microExpectedMargin` | stochastic compatibility plus a resource-bounded coarse model, not unconditional DPI |

The correct interpretation is:

```text
Repair-Maintenance is staged as the third limited class template. It shares the
Sigma / net-consumption / resource-cost / concentration / coarse-transfer
grammar with the previous two classes, but it does not claim an optimal
maintenance policy, a stochastic reliability theorem for arbitrary repair
processes, Bernoulli-style pathwise nondecrease, or an unconditional repair
law.
```

### Phase 7 v0 / Cross-Class Unification Registry

`analysis/phase7_cross_class_unification_v0.md` records the first Phase-7
cross-class registry after the Bernoulli-CSP, Foster-Lyapunov / queueing, and
Repair-Maintenance templates. `Survival.CrossClassUnificationV0` is deliberately
a registry rather than a generic universal theorem: it machine-registers the
common profile now present in all three limited classes.

| Phase-7 v0 role | Lean anchor | Reading discipline |
|---|---|---|
| registered class enum | `CrossClassUnificationV0.LimitedClassTemplate` | the three current limited templates only |
| registered profile | `CrossClassUnificationV0.profile` | reader-facing registry, not a necessary/sufficient characterization |
| common Phase-7 v0 support | `CrossClassUnificationV0.supportsPhase7V0`; `CrossClassUnificationV0.all_registered_classes_supportPhase7V0` | all registered classes have \(\Sigma\) grammar, expected tendency, high-probability certificate, and coarse transfer |
| Bernoulli pathwise component | `CrossClassUnificationV0.bernoulliCSP_pathwiseNondecrease_registered` | class-specific stronger component |
| non-Bernoulli pathwise non-claim | `CrossClassUnificationV0.fosterLyapunovQueueing_pathwiseNondecrease_not_registered`; `CrossClassUnificationV0.repairMaintenance_pathwiseNondecrease_not_registered` | pathwise nondecrease is not promoted to the cross-class profile |
| class-specific engines | `CrossClassUnificationV0.bernoulliCSP_engine`; `CrossClassUnificationV0.fosterLyapunovQueueing_engine`; `CrossClassUnificationV0.repairMaintenance_engine` | Chernoff/KL, conditional-Azuma, and resource-bounded Azuma are registered engines, not an exhaustive taxonomy |

The correct interpretation is:

```text
Phase 7 v0 closes the common-profile registry:
Bernoulli-CSP, Foster-Lyapunov / queueing, and Repair-Maintenance all share
Sigma grammar, expectation-level tendency, finite-horizon high-probability
certificate route, and conditional coarse transfer.
```

It does **not** prove the generic cross-class theorem yet. Phase 7 v1 should
extract the actual schema, most likely around subadditivity, resource-cost lower
bounds, and defect-controlled admissible maps.

### Phase 7 v1 / Cross-Class Unifying Schema

`analysis/phase7_unifying_schema_v1.md` extracts the first generic schema from
the Phase-7 v0 registry. `Survival.CrossClassUnificationV1` keeps this at the
same modest Lean level: a schema registry, not a theorem over all
structural-maintenance problems.

The main v1 correction is that subadditivity is not promoted as the single
generic core. The shared schema is instead:

```text
ordered Sigma carrier
  + nonnegative tendency driver
  + finite-horizon certificate route
  + admissible-transfer guard
```

| Phase-7 v1 role | Lean anchor | Reading discipline |
|---|---|---|
| tendency driver enum | `CrossClassUnificationV1.TendencyDriver` | one-sided emissions, conditional drift lower bounds, and resource-cost lower bounds are separate engines |
| certificate route enum | `CrossClassUnificationV1.CertificateRoute` | Chernoff/KL, conditional-Azuma, and resource-bounded Azuma are registered routes, not an exhaustive taxonomy |
| transfer guard enum | `CrossClassUnificationV1.TransferGuard` | endpoint-defect budget, stochastic compatibility, and resource-bounded compatibility remain explicit assumptions |
| v1 schema profile | `CrossClassUnificationV1.Phase7V1SchemaProfile`; `CrossClassUnificationV1.schema` | schema extraction, not a universal theorem |
| common v1 support | `CrossClassUnificationV1.supportsPhase7V1Schema`; `CrossClassUnificationV1.all_registered_classes_supportPhase7V1Schema` | all registered classes instantiate the v1 schema |
| v1 extends v0 | `CrossClassUnificationV1.phase7V1Schema_implies_phase7V0` | v1 is an explanation layer on top of the v0 registry |
| pathwise nondecrease discipline | `CrossClassUnificationV1.no_registered_class_requires_pathwiseNondecrease` | Bernoulli-style pathwise nondecrease is not a generic requirement |

### Phase 7 v2 / Interface And Registered Instances

`analysis/phase7_unifying_schema_v2.md` turns the v1 schema into an explicit
interface and records that the three registered limited classes instantiate it.
`Survival.CrossClassUnificationV2` is the first meta-theorem interface for the
cross-class layer.

| Phase-7 v2 role | Lean anchor | Reading discipline |
|---|---|---|
| abstract interface | `CrossClassUnificationV2.AbstractUnifyingSchemaInstance` | obligations a class must supply: Sigma carrier, tendency driver, certificate route, transfer guard, non-pathwise-genericity discipline |
| abstract law-like profile | `CrossClassUnificationV2.AbstractLawLikeLimitedClassProfile`; `CrossClassUnificationV2.abstractLawLikeProfile_of_instance` | interface unpacking, not a theorem over arbitrary domains |
| registered interface | `CrossClassUnificationV2.RegisteredUnifyingSchemaInstance`; `CrossClassUnificationV2.registeredInstanceOf` | specializes the interface to the three currently registered classes |
| class instances | `CrossClassUnificationV2.bernoulliCSP_unifyingSchemaInstance`; `CrossClassUnificationV2.fosterLyapunovQueueing_unifyingSchemaInstance`; `CrossClassUnificationV2.repairMaintenance_unifyingSchemaInstance` | Bernoulli-CSP, Foster-Lyapunov / queueing, and Repair-Maintenance as schema instances |
| registered closure | `CrossClassUnificationV2.all_registered_classes_satisfy_unifyingSchema` | all currently registered limited classes satisfy the v1 schema via v2 instances |

This is the current strongest cross-class Lean statement.  It says the three
registered classes instantiate a common interface.  It still does not claim a
single universal inequality, a physical second law, or admission of arbitrary
future domains.

## Paper 2 / Structural Persistence Balance Mapping

Paper 2 の経路ごとの代数核は、既存の
`Survival/GeneralStateDynamics.lean` が証明している。`Survival/StructuralPersistenceBalancePrinciple.lean`
は、この既存 theorem 群を Structural Persistence Balance の読者向け名称で束ねる薄い wrapper であり、新しい仮定や
新しい普遍法則 claim は追加しない。

重要な前提は positivity である。対数比で loss / gain / net consumption amount を定義するため、Lean 側では
`PositiveTrajectory`、Paper 2 側では positive finite trajectory assumptions の下で
machine-checked と読む。

| Structural Persistence Balance claim | Lean entry point | Underlying theorem / object | Status |
|---|---|---|---|
| net consumption amount \(b_t=d_t-r_t\) | `StructuralPersistenceBalancePrinciple.netConsumptionAmount_eq_consumption_sub_recovery` | `GeneralStateDynamics.stepNetAction` | proven by definition |
| cumulative net consumption amount \(B_n=\sum_{t<n}b_t\) | `StructuralPersistenceBalancePrinciple.cumulativeNetConsumption_eq_sum_netConsumptionAmount` | `GeneralStateDynamics.cumulativeNetAction` | proven by definition |
| local net-consumption identity \(m(V^{t+1})=m(V^t)e^{-b_t}\) | `StructuralPersistenceBalancePrinciple.local_exponential_netConsumption_identity` | `feasibleMass_succ_eq_mass_mul_exp_neg_stepNetAction` | proven under positivity |
| pathwise net-consumption kernel \(m(V^n)=m(V^0)e^{-B_n}\) | `StructuralPersistenceBalancePrinciple.pathwise_netConsumption_exponential_kernel` | `feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction` | proven under positive finite trajectory assumptions |
| loss-only minimum-form recovery | `StructuralPersistenceBalancePrinciple.pureContraction_recovers_loss_only_kernel` | `feasibleMass_eq_initial_mul_exp_neg_cumulativeLoss_of_pureContraction` | proven for pure contraction / zero gain |
| Foster-Lyapunov algebraic embedding | `StructuralPersistenceBalancePrinciple.lyapunov_*` wrappers | `LyapunovBalanceEmbedding.*` | proven as minimal algebraic embedding, not positive recurrence |
| repair / maintenance finite-prefix net-consumption skeleton | `StructuralPersistenceBalancePrinciple.repair_*` wrappers | `RepairMaintenanceBalance.*` | proven finite-prefix skeleton |
| remaining margin \(B-D_n\) | `repair_remainingMargin_eq_initial_margin_sub_cumulative_netConsumption` | `RepairMaintenanceBalance.margin` | proven; this is margin, not Paper 1 resource term `M` |

Paper 2 non-claims remain outside Lean:

- naturality or uniqueness of \(V,m,d_t,r_t\) in arbitrary domains;
- empirical observability of \(r_t\);
- Route C causal mechanism identification;
- Backblaze / C-MAPSS / Scania empirical outcomes;
- Foster-Lyapunov positive recurrence, geometric ergodicity, or optimal maintenance theorem;
- any universal-law declaration.

## M 補論 / Maintenance Component Decomposition Mapping

M 補論の維持能力成分の分解は、
`Survival/MaintenanceComponentDecomposition.lean` で形式化している。
ここで Lean が閉じるのは、「external は第四成分ではなく供給 channel である」
という表現文法と、「M interface 上で観測される効果は三成分 profile によって完全に決まる」
という interface-relative representation theorem である。さらに `ObservationQuotient` により、
M interface 上の任意の valid readout が通る標準商と、その一意 factorization まで形式化する。
各ドメインの proxy 妥当性や \(\Phi\) の universal form は Lean 範囲外に残す。

| M supplement claim | Lean entry point | Status |
|---|---|---|
| maintenance components are exactly buffer / recovery / reconfiguration | `MaintenanceComponent.exhaustive` | proven by finite inductive type elimination |
| supply channels are exactly internal / external | `SupplyChannel.exhaustive` | proven by finite inductive type elimination |
| component profile is determined by three coordinates | `componentProfile_ext` | proven by extensionality over `MaintenanceComponent` |
| supply profile is determined by internal/external × three components | `supplyProfile_ext` | proven by extensionality over channel × component |
| any supply profile decomposes into internal and external component profiles | `fromInternalExternal_internalProfile_externalProfile` | proven by definition |
| internal/external decomposition is unique | `fromInternalExternal_eq_iff` | proven by function extensionality |
| external supply enters effective capacity component-wise | `effectiveProfile` / `effectiveProfile_apply` | proven by definition |
| nonnegative supplies and nonnegative aggregators yield nonnegative effective maintenance | `effectiveMaintenance_nonneg` | proven under explicit nonnegativity-preservation assumptions |
| a raw mechanism admitted to the M interface has a three-component representation | `MaintenanceInterface.everyMechanism_has_threeComponentRepresentation` | proven by interface definition |
| M-observational equivalence is exactly equality of the three component coordinates | `MaintenanceInterface.observationallyEquivalent_iff_three_coordinates` | proven by component-profile extensionality |
| there is no independent fourth observable coordinate inside the M interface | `MaintenanceInterface.noFourthObservableCoordinate` | proven by component-profile extensionality |
| any M-side readout is fixed by the three component coordinates | `MaintenanceInterface.maintenanceReadout_eq_of_same_three_coordinates` | proven by readout factorization through the component profile |
| M-observation classes form a canonical quotient of raw mechanisms | `MaintenanceInterface.ObservationQuotient` | defined as quotient by M-observational equivalence |
| an observation factors through the quotient iff it respects M-equivalence | `MaintenanceInterface.factors_through_observationQuotient_iff_respects_equivalence` | universal property of the quotient |
| every M-side readout factors through the observation quotient | `MaintenanceInterface.maintenanceReadout_factors_through_observationQuotient` | proven from readout factorization through the component profile |
| quotient factorization is unique | `MaintenanceInterface.quotientFactor_unique` | proven by quotient induction |
| the quotient profile is faithful | `MaintenanceInterface.quotientProfile_injective` / `MaintenanceInterface.quotientProfile_eq_iff` | proven by quotient soundness and exactness |
| an extra quantity that distinguishes M-equivalent mechanisms is outside the M interface | `MaintenanceInterface.outsideInterface_if_distinguishes_observationallyEquivalent` | proven as a factorization obstruction |
| an extra quantity that distinguishes mechanisms with the same three coordinates is outside the M interface | `MaintenanceInterface.outsideInterface_if_distinguishes_same_three_coordinates` | proven as a factorization obstruction plus extensionality |
| a candidate mechanism is represented or outside the M interface | `PartialMaintenanceInterface.representable_or_outside` | proven by `Option` case analysis |

M supplement non-claims remain outside Lean:

- naturality or observability of \(M_{\mathrm{buffer}},M_{\mathrm{recovery}},M_{\mathrm{reconfiguration}}\) in arbitrary domains;
- empirical validity of component signals in software / SaaS;
- the best form of \(\gamma_i\), \(A_j\), or \(\Phi\);
- intervention-ranking support in operational data;
- a universal metric for the M-side resource term.

## Lean で閉じている範囲

| 範囲 | 状態 | 読み方 |
|---|---|---|
| Paper 1 + 条件つき導出補論の最小指数核 | 完了 | `LogUniqueness`, `TelescopingExp`, `AxiomsToExp`, `WeakDependence` が主軸 |
| 確率的崩壊・停止時刻 | 完了 | Paper 1 §5 の崩壊閾値を finite-horizon hitting-time / stopped-collapse に拡張 |
| Martingale / Azuma concentration | 完了 | 条件つき導出補論 §4 の抽象 ρ 境界を bounded-increment concentration に格上げ可能 |
| 粗視化・表現安定性 | 完了 | Paper 1 §2 P5 を集合論・total production・stochastic layer で形式化 |
| SAT chain v1.0 | 完了 | actual path measure → non-flat emission → MGF product → Chernoff/KL → collapse |
| Bernoulli CSP universality v1.2 | 完了 | k-SAT / NAE-SAT / XOR-SAT / coloring / forbidden-pattern / cardinality families; `BernoulliTypicalSigma` gives the reader-facing \(\Sigma\) lower-tail / expectation / endpoint-defect coarse-transfer wrapper; `BernoulliAdmissibleMapV0` packages the sufficient readout-level admissible-map conditions for those coarse certificates |
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

1. 条件つき導出補論 §5 の形式検証リストを 5 ファイルから現在の主要層へ更新する。
2. 条件つき導出補論 §4 に martingale / Azuma concentration による厳密化を追加する。
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
| Paper 1 §5 S = Me⁻ᴸ, S_c 閾値 | 構造持続量 | `FullFormula.lean`, `Penalty.lean`, `Basic.lean` | 形式化済（3因子分解まで） |
| Paper 1 §5 崩壊 S < S_c | 崩壊条件 | `CollapseTimeBound.lean`, `StochasticCollapseTimeBound.lean`, `HighProbabilityCollapse.lean` | **確率版まで拡張済（論文未掲載）** |
| 条件つき導出補論 §2 A1/A2/A3 | 三条件の分離 | `AxiomsToExp.lean` | 形式化済・論文掲載 |
| 条件つき導出補論 §3 恒等式 A1–A2 のみ | 独立性不要 | `TelescopingExp.lean` | 形式化済・論文掲載 |
| 条件つき導出補論 §4 弱依存 ρ-境界 | e⁻ᴸ⁽¹⁺ρ⁾ ≤ P ≤ e⁻ᴸ⁽¹⁻ρ⁾ | `WeakDependence.lean`, `RobustSurvival.lean`, `SignedWeakDependence.lean` | 形式化済（signed 拡張は論文未掲載） |
| 条件つき導出補論 §4 真の martingale concentration | 論文に書かれず | `AzumaHoeffding.lean`, `BoundedAzumaConstruction.lean`, `ConditionalMartingale.lean`, `MartingaleDrift.lean`, `ConcentrationInterface.lean`, `ResourceBoundedConditionalAzuma.lean`, `ProbabilityConnection.lean` | **形式化済・論文未掲載（格上げ候補）** |
| 条件つき導出補論 §5 形式検証リスト | 5 ファイル明示 | 同上 | **実態は 30+ ファイル** |
| Paper 2 §5 指数表現の適用 | 経路集合縮小 | Paper 1 同等ファイル群を流用 | 形式化済 |
| Route C companion I §9.2 100ターン長期安定性 | 代謝ありで単調崩壊しない | `TypicalNondecrease.lean`, `ResourceBoundedDynamics.lean`, `ResourceBoundedStochasticCollapse.lean` | **形式化済・論文未掲載** |
| Route C companion II §7 条件 (i) 矛盾解消代謝 | パラメータ更新だけでは不十分 | `FiniteStateMarkovCollapse.lean`, `FiniteStateMarkovRepairChain.lean`, `MarkovRepairFailureExample.lean` | **最小形式モデル形式化済（論文未掲載）** |
| Route C companion II §7 F-v2c / F-multi | 修復・空間分離 | `MinimumRepairRate.lean`, `StochasticMinimumRepairRate.lean`, `CoarseMinimumRepairRate.lean` | 修復率下限として形式化（論文未掲載） |
| 補論 SAT §2.1 第一モーメント法 | E[#SAT] = 2ⁿ e⁻ᴸ | `SATFirstMoment.lean`, `KLDivergence.lean` | 形式化済 |
| 補論 SAT 第二モーメント法 | Paley-Zygmund 下界 | `SATSecondMoment.lean`, `SecondMomentBound.lean`, `CorrelatedSecondMoment.lean`, `PairCorrelation.lean` | 形式化済（相関 sandwich は論文未掲載の補強） |
| 補論 SAT §5.1 感度指数 c | μ_c ∝ eᶜᴸ、α-n 非対称性 | `AsymptoticExponent.lean`, `SensitivityAnalysis.lean` | 形式化済（β=1/2 neutrality は論文未掲載の洞察） |
| 補論 DSMF §11 介入設計 (μ 増加, L 減少) | 修復必要量の下限 | `MinimumRepairRate.lean`, `TotalProduction.lean`, `ResourceBudget.lean`, `ResourceBoundedDynamics.lean` | **形式化済・論文未掲載** |
| 補論 DSMF §5 A_k / L̂ / M 分解 | S = N_eff⁽⁰⁾ × (μ/μ_c) × e⁻ᴸ | `Penalty.lean`, `FullFormula.lean`, `MultiAttractor.lean` | 形式化済 |
| 補論 設計原理 §3 外部代謝層 | 矛盾整理 | `MinimumRepairRate.lean`, `FiniteStateMarkovRepairChain.lean` | 形式層あり |

---

## 2. カテゴリ別ファイル一覧

### A. 論文明示コア（5）— 条件つき導出補論 §5 掲載

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`LogUniqueness.lean`](Survival/LogUniqueness.lean) | `log_ratio_uniqueness`: B1–B4 → f(r) = -k ln r 一意 | Paper 1 §3.1 そのもの |
| [`TelescopingExp.lean`](Survival/TelescopingExp.lean) | `measure_eq_initial_mul_exp_neg_cumulative_loss`: mₙ = m₀·exp(-Σlᵢ) 純代数 | 条件つき導出補論 §3、A3 不要の最小コア |
| [`AxiomsToExp.lean`](Survival/AxiomsToExp.lean) | `joint_survival_eq_exp_neg_delta`: 独立積 → eˡ | Paper 1 §2、条件つき導出補論 §3 |
| [`WeakDependence.lean`](Survival/WeakDependence.lean) | `WeakDependenceSandwich`: ρ-sandwich | 条件つき導出補論 §4 本丸 |
| [`RobustSurvival.lean`](Survival/RobustSurvival.lean) | `robustPotential`: μ·exp(-δ·(1+ρ))、保守的下界 | 条件つき導出補論 §4 拡張 |

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
| [`NumericalSanityChecks.lean`](Survival/NumericalSanityChecks.lean) | k-SAT/NAE/XOR/q-coloring/forbidden-pattern wrappers が `log(8/7)`, `log(4/3)`, `log 2` などを回復 | tests-as-documentation。抽象 interface の小さな具体例であり、新しい empirical support ではない |

### C2. Route A 非CSP core examples（11）

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`SerialReliability.lean`](Survival/SerialReliability.lean) | 直列系信頼度 `R = ∏ p_i` と累積構造消耗量 `L = Σ -log p_i` から `R = exp(-L)`、および `L ≥ -log θ → R ≤ θ` | A08。B3 の独立部分加法性を SAT 以外の教科書的工学例で補強 |
| [`ConstantFractionDecay.lean`](Survival/ConstantFractionDecay.lean) | 一定割合 `q` の残存過程で `q^n = exp(-n(-log q))`、および `L ≥ -log θ → q^n ≤ θ` | A02/A03/A04/A16。放射性崩壊・吸収・一次反応・一次薬物動態の共通指数減衰核 |
| [`BranchingProcessExtinction.lean`](Survival/BranchingProcessExtinction.lean) | 平均子孫数 `m ≤ 1` の分岐過程 expectation skeleton で `m^n = exp(-n(-log m))`、subcritical なら `-log m > 0` | A13。絶滅閾値の期待値レベル最小モデル |
| [`QueueStability.lean`](Survival/QueueStability.lean) | fluid queue で `backlog_n = initial + n(arrival-service)`、安定時は増えず、過負荷時は線形に閾値到達 | A07/A28。処理資源を超えた負荷の累積崩壊 skeleton |
| [`BinarySymmetricChannel.lean`](Survival/BinarySymmetricChannel.lean) | 独立 binary channel で block success `(1-p)^n = exp(-n(-log(1-p)))`、loss 閾値から block failure 下界を導く | A06/A19。通信路・誤り訂正側の指数的復元失敗 skeleton |
| [`LinearCodeErasureAccountingToy.lean`](Survival/LinearCodeErasureAccountingToy.lean) | BEC 線形符号の erasure-rank profile で `a(E)=|E|-rank(H_E)`, compatible mass `2^a`, retained distinguishable mass ratio `2^{-a}`, exact loss `a log 2` を示す | A06/A19。prediction proxy ではなく、消失集合固定後の仕様固定 exact accounting anchor |
| [`FatigueDamage.lean`](Survival/FatigueDamage.lean) | 応力サイクル損傷 `D_n = Σ_{i<n} d_i` が capacity を超えると破断、一定損傷では `D_n = n d` | A23。材料疲労・Miner 則型の累積閾値 skeleton |
| [`RepairMaintenanceBalance.lean`](Survival/RepairMaintenanceBalance.lean) | damage amount `d_t` と repair / maintenance amount `r_t` から `D_n = D_0 + Σ(d_t-r_t)`、`M_n = B-D_n`、`R_{t+1}=R_t exp(-(d_t-r_t))`、非負 repair による margin 改善を形式化 | G4 v2。回復量 \(r_t\) を非CSP open-system reliability / fatigue 側で明示する有限 prefix skeleton |
| [`ConsensusFaultThreshold.lean`](Survival/ConsensusFaultThreshold.lean) | 累積故障数 `F_n = Σ_{i<n} f_i` が fault budget を超えると合意不能、一定故障流では `F_n = n f` | A25。分散合意の故障閾値 skeleton |
| [`MemoryThrashing.lean`](Survival/MemoryThrashing.lean) | working set が physical memory を超えると `faultPressure_n = initial + n(workingSet-memory)` が線形増加し閾値到達 | A27。メモリ階層・スラッシングの working-set overflow skeleton |
| [`BucklingThreshold.lean`](Survival/BucklingThreshold.lean) | load ramp `P_n = P_0 + n ΔP` が critical load `Pcr` に到達/超過すると座屈閾値到達 | A10。機械構造体の critical-load threshold skeleton |
| [`PercolationThreshold.lean`](Survival/PercolationThreshold.lean) | occupation ramp `p_n = p_0 + n Δp` が critical occupation `p_c` に到達/超過すると percolation threshold 到達 | A11/A12。巨大成分・パーコレーション転移の threshold skeleton |

### C3. G6-c formal mapping（2）

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`LyapunovBalanceEmbedding.lean`](Survival/LyapunovBalanceEmbedding.lean) | Lyapunov/load sequence `Z_t` から `b_t = Z_{t+1}-Z_t`, `B_n = Z_n-Z_0`, `R_{t+1}=R_t exp(-b_t)`、queue excess demand への wrapper | G6-c。Foster-Lyapunov / queueing drift を構造持続の収支原理の期待値レベルの傾向へ埋め込む最小代数 skeleton |
| [`FosterLyapunovSignBridge.lean`](Survival/FosterLyapunovSignBridge.lean) | `φ=-log m` なら `b(x,y)=φ(y)-φ(x)=-log(m(y)/m(x))`、outside-safe negative drift は `E[b|x]≤-ε`、positive drift は destabilizing direction、stationary marginal では mean increment が 0 | G6-c sign guardrail。安定化 drift と positive Core net change の符号取り違えを防ぐ有限状態・期待値レベル skeleton |

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

### E. Azuma-Hoeffding / Martingale / Concentration（11）— **論文 条件つき導出補論 §4 の格上げ候補**

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`AzumaHoeffding.lean`](Survival/AzumaHoeffding.lean) | `collapseWithAzumaHoeffdingBound_of_initial_margin`: martingale-like なら初期マージンで exp(-r²/(2V_n)) 崩壊 | 条件つき導出補論 §4 の真の martingale concentration |
| [`BoundedAzumaConstruction.lean`](Survival/BoundedAzumaConstruction.lean) | bounded increments + good event → `AzumaHoeffdingConcentration` 構成 | 標準 Azuma setup |
| [`ConditionalMartingale.lean`](Survival/ConditionalMartingale.lean) | mathlib `Martingale` → `MartingaleLike`（ドリフト=0） | Mathlib 接続 |
| [`MartingaleDrift.lean`](Survival/MartingaleDrift.lean) | `expectedCumulative_eq_initial_of_martingaleLike` | ドリフト言語の foundation |
| [`ConcentrationInterface.lean`](Survival/ConcentrationInterface.lean) | `collapseWithFailureBound_of_expected_center`, `largeDeviationFailureBound` | concentration interface 抽象化 |
| [`ResourceBoundedConditionalAzuma.lean`](Survival/ResourceBoundedConditionalAzuma.lean) | conditional submartingale drift + bounded increments → stopped collapse | 確率的停止時刻崩壊 |
| [`SignedWeakDependence.lean`](Survival/SignedWeakDependence.lean) | `signed_survival_sandwich`: \|B_eff - B_ref\| ≤ ρ\|B_ref\| で exp 境界 | **条件つき導出補論 §4 の signed 厳密化、論文未掲載** |
| [`ProbabilityConnection.lean`](Survival/ProbabilityConnection.lean) | actual probability space → expected cumulative process | 基盤層 |
| [`StochasticTotalProduction.lean`](Survival/StochasticTotalProduction.lean) | random net action + random cost → stochastic process、deterministic embedding | Paper 1 の確率拡張、論文未掲載 |
| [`StochasticTotalProductionAzuma.lean`](Survival/StochasticTotalProductionAzuma.lean) | bounded increment Azuma witness → stopped collapse | total production × Azuma |
| [`StochasticMinimumRepairRate.lean`](Survival/StochasticMinimumRepairRate.lean) | a.e. cost lower bound → expected cost 下界 | 修復率の stochastic 化 |

### F. 崩壊時刻・停止時刻（10）— **論文 Paper 1 §5 の確率的厳密化候補**

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`CollapseTimeBound.lean`](Survival/CollapseTimeBound.lean) | B_n ≥ -log θ → mass ≤ θ | Paper 1 §5 決定論的版 |
| [`StochasticCollapseTimeBound.lean`](Survival/StochasticCollapseTimeBound.lean) | B_n(ω) ≥ -log θ a.s. → 生存率 ≤ θ a.s. | 経路別上界 |
| [`HighProbabilityCollapse.lean`](Survival/HighProbabilityCollapse.lean) | 閾値越え事象 E → E で崩壊 | 失敗確率付き崩壊 |
| [`TypicalNondecrease.lean`](Survival/TypicalNondecrease.lean) | E[drift_t] ≥ 0 → E[cum] monotone | 確率層の基盤 |
| [`CliffWarning.lean`](Survival/CliffWarning.lean) | remainingMargin ≤ stepLoss - stepCost → 次ステップ確定崩壊 | **決定論的事前警告、論文未掲載** |
| [`StochasticCliffWarning.lean`](Survival/StochasticCliffWarning.lean) | `collapseAlmostSurely_next_of_remainingMargin_le_increment_ae` | 確率版事前警告、論文未掲載 |
| [`StoppingTimeCliffWarning.lean`](Survival/StoppingTimeCliffWarning.lean) | `collapseHittingTime_isStoppingTime`、optional stopping | 停止時刻形式化、論文未掲載 |
| [`StoppingTimeCollapseEvent.lean`](Survival/StoppingTimeCollapseEvent.lean) | hittingTime < N の直接イベント境界 | Paper 1 §5 確率版 |
| [`StoppingTimeHighProbabilityCollapse.lean`](Survival/StoppingTimeHighProbabilityCollapse.lean) | 停止値での S < θ の確率境界 | optional stopping × Azuma |
| [`StoppingTimeSharpDecomposition.lean`](Survival/StoppingTimeSharpDecomposition.lean) | τ < N と τ = N の完全分離 | 有限地平線の精密分解 |

### G. 修復率・予算・動力学（14）— **論文 DSMF §11 の形式化**

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`MinimumRepairRate.lean`](Survival/MinimumRepairRate.lean) | mass 保持 θ → cost ≥ loss + log θ | **代謝必要量の下限、論文未掲載** |
| [`TotalProduction.lean`](Survival/TotalProduction.lean) | Σ = A + C の分解 | DSMF §5 基本 |
| [`ResourceBudget.lean`](Survival/ResourceBudget.lean) | cumulativeGain ≤ cumulativeCost | 資源会計の基盤公理 |
| [`ResourceBoundedDynamics.lean`](Survival/ResourceBoundedDynamics.lean) | resource-bounded → Σ 単調 | Route C companion I §9.2 長期安定性、Route C companion II §7 の基礎 |
| [`ResourceBoundedStochasticCollapse.lean`](Survival/ResourceBoundedStochasticCollapse.lean) | initial margin → high-probability stopped collapse | **最重要の高確率層、論文未掲載** |
| [`RepairMaintenanceTemplate.lean`](Survival/RepairMaintenanceTemplate.lean) | repair-maintenance Phase 6.2 v0 wrappers | 第三限定 class template。finite-prefix damage/repair, Σ/resource-cost, resource-bounded certificate, conditional coarse transfer |
| [`GeneralStateDynamics.lean`](Survival/GeneralStateDynamics.lean) | `feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction`: 符号付き指数カーネル | **Paper 1 の暗黙核定理を形式化** |
| [`EpistemicControlBridge.lean`](Survival/EpistemicControlBridge.lean) | `epistemic_control_composition_kernel`: epistemic control spec を `ProblemSpec` に落とす bridge | LLM-style control layer の意味論ではなく、有限 coherent-region interface が net-action kernel を継承することを形式化 |
| [`EvidencePacketBridge.lean`](Survival/EvidencePacketBridge.lean) | `evidence_filter_no_more_loss`, `evidence_invalidations_localized`, `repair_touches_invalidations`, eligibility / witness guard lemmas | implementation artifact schema。provenance, eligibility, contradiction witness, dependency closure, repair coverage を bridge 仮定へ近づけるが、実 workflow の正しさは主張しない |
| [`LLMEpistemicControlToy.lean`](Survival/LLMEpistemicControlToy.lean) | `llmReasoningToy_composition_kernel`, `llmReasoningContradictionWitness_has_two_surfaces`, `staleMemory_not_eligible`, `eligibleMemory_eligible`, `eligibleMemory_no_more_loss`, `premiseUpdate_invalidations_localized`, `repairTouches_downstreamInvalidations` | LLM 推論・長期記憶・継続更新を finite toy surface として bridge に接続。実 LLM 意味論・性能・記憶安全性の証明ではない |
| [`LLMMemoryUseConditionToy.lean`](Survival/LLMMemoryUseConditionToy.lean) | `memory_without_permission_not_eligible`, `deleted_memory_not_eligible`, `out_of_scope_memory_not_eligible`, `unstable_memory_not_eligible`, `action_blocked_memory_not_eligible`, `scopedCorrectionRecord_eligible`, `useConditionMemory_no_more_loss` | LLM 長期記憶の use condition を permission / deletion / scope / stability / action eligibility に分解する有限 toy。任意記憶実装の安全性証明ではない |
| [`SoftwareContractToyRepository.lean`](Survival/SoftwareContractToyRepository.lean) | `toyRepository_composition_kernel`, `toyRepository_coherentMass_zero`, `toyRepository_coherentMass_one`, `toyRepository_coherentMass_two`, `toyClaimAdmission_no_more_loss`, `toyDependencyRewrite_localizes` | software contract surface の最小 toy instantiation。実検出器の正しさではなく、repository contract state が bridge interface に乗ることを示す |
| [`SoftwareEvidencePacketToy.lean`](Survival/SoftwareEvidencePacketToy.lean) | `toyValidatedCandidate_eligible`, `toyUnsupportedCandidate_not_eligible`, `toyWitness_has_two_surfaces`, `toyEvidence_invalidations_localized`, `toyRepair_touches_invalidations`, `toyEvidenceAdmission_no_more_loss` | software toy surface が evidence-packet bridge の provenance / eligibility / witness / dependency / repair / admission guardrails を満たす具体例 |
| [`DependencyClosureBudgetToy.lean`](Survival/DependencyClosureBudgetToy.lean) | `invalidated_ncard_le_closure_ncard`, `invalidated_ncard_le_repair_touched_ncard`, `llm_invalidated_ncard_le_surface_card`, `software_invalidated_ncard_le_surface_card` | sound dependency closure を有限 cardinality budget として読む toy bridge。LLM / software toy surface の invalidation 数を closure、surface 全体、repair touched set で上界づける |
| [`LLMMemoryReasoningStrengtheningToy.lean`](Survival/LLMMemoryReasoningStrengtheningToy.lean) | `revokedScopedMemoryRecord_not_eligible`, `expiredScopedMemoryRecord_not_eligible`, `lifecycleMemory_no_more_loss`, `retrieval_packet_cannot_overwrite_userCorrection_packet`, `reasoningContradictionWitness_minimal`, `llm_composed_repair_kernel` | LLM memory / reasoning toy の追加 guardrails。revocation / freshness, provenance trust order, minimal contradiction witness, and composed repair を finite bridge に接続。実 LLM 安全性や性能の証明ではない |
| [`EpistemicControlStack.lean`](Survival/EpistemicControlStack.lean) | `stack_epistemic_kernel`, `stack_evidence_filter_no_more_loss`, `stack_llm_reasoning_kernel`, `stack_llm_use_condition_memory_no_more_loss`, `stack_software_repository_kernel`, `stack_software_repair_touches_invalidations`, `stack_llm_invalidated_ncard_le_repair_touched_ncard`, `stack_software_invalidated_ncard_le_repair_touched_ncard`, `stack_llm_lifecycle_memory_no_more_loss`, `stack_llm_composed_repair_kernel` | bridge / evidence / LLM toy / memory use-condition / software toy / dependency-budget toy / memory-reasoning strengthening toy の主要定理を一箇所に集約する reader-facing entry point。新しい意味論主張ではない |

### G2. M 側の維持能力成分分解（1）— **M 補論の表現文法**

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`MaintenanceComponentDecomposition.lean`](Survival/MaintenanceComponentDecomposition.lean) | `MaintenanceComponent.exhaustive`, `SupplyChannel.exhaustive`, `componentProfile_ext`, `supplyProfile_ext`, `fromInternalExternal_eq_iff`, `effectiveMaintenance_nonneg`, `MaintenanceInterface.ObservationQuotient`, `MaintenanceInterface.factors_through_observationQuotient_iff_respects_equivalence`, `MaintenanceInterface.quotientProfile_injective`, `PartialMaintenanceInterface.representable_or_outside` | buffer / recovery / reconfiguration と internal / external channel の分離を型レベルで固定。M interface 上の観測効果は三成分 profile によって完全に決まる、という表現定理と標準商の universal property まで形式化 |

### H. マルコフ修復チェーン（3）— **Route C companion II §7 条件 (i) 最小形式モデル**

| ファイル | 主定理 | 評価 |
|---------|-------|------|
| [`FiniteStateMarkovCollapse.lean`](Survival/FiniteStateMarkovCollapse.lean) | 有限状態 Markov chain → stopped collapse bound | Route C companion II §7 最小モデル、論文未掲載 |
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

### 3.1 条件つき導出補論 §5 形式検証リストのアップデート

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

### 3.2 条件つき導出補論 §4 の主張強度を一段上げる提案

**現状の論文本文（§4）:**
> 依存の効果が参照モデルからの相対誤差として ρ（0 ≤ ρ < 1）で抑えられているとする。

これは抽象的な相対誤差仮定に留まっている。

**Lean 側で既に形式化されている代替:**
`AzumaHoeffding.lean` + `BoundedAzumaConstruction.lean` + `ConditionalMartingale.lean` により、段階構造消耗 l_i が bounded increments を満たす conditional martingale なら、Azuma-Hoeffding 不等式から `exp(-r²/(2V_n))` の具体的な指数境界が得られる。

**論文への反映案:**
条件つき導出補論 §4 に「§4.1 真の martingale concentration による厳密化」を追加し、SignedWeakDependence + ConditionalMartingale + AzumaHoeffding を引用することで、弱依存の扱いを「相対誤差 ρ を仮定」から「bounded martingale increments → 具体的 variance proxy」へ格上げできる。

### 3.3 Route C companion II §7 「条件 (i) 矛盾解消代謝」の形式モデル

**現状の論文本文（§7.4）:**
> LoRA ベース継続学習は条件 (ii) を部分的に緩めるが、条件 (i)（矛盾解消代謝機構）を備えていない。

これも言葉による主張に留まっている。

**Lean 側の未反映モデル:**
`FiniteStateMarkovRepairChain.lean` + `MarkovRepairFailureExample.lean` が failure/idle/repair の三状態で最小形式モデルを与えている。さらに `MinimumRepairRate.lean` が「mass 保持 θ → cost ≥ loss + log θ」として**代謝必要量の下限定理**を形式化済み。

**論文への反映案:**
Route C companion II §7.4 に「§7.4.1 最小マルコフ修復チェーンモデル」を追加し、条件 (i) が欠けた場合に mass 保持が指数的に崩壊することを定理化できる。これは LoRA の上書き的振る舞いの定性観察を、**形式モデル上の定理に昇格**させる。

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

これらを合わせると「S_c を θ として τ^θ < N となる確率上界」が Azuma から出る。Paper 1 §5 を Paper 1.5（Paper 1 と 条件つき導出補論 の間）として補強するか、条件つき導出補論 に吸収するか、の設計判断ができる材料。

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

1. **ビルド整合性**: 174 Survival modules は `Survival.lean` の top-level import を通じて一貫して検証する設計である。今後は `PAPER_MAPPING.md` の freeze snapshot ごとに `lake build Survival` の通過状況を併記する。
2. **重複可能性**: `Coarse*` と `Stochastic*` の組合せで似た主張が複数箇所にある可能性。一本化できるものはリファクタ候補。
3. **ArrowOfTime 系の位置づけ**: 補論 SAT §4 らしい H 定理的主張だが、論文本文に対応章が明示されていない。SAT への熱力学的意味付けを追加するか、独立補論として切り出すか、の判断が必要。
4. **論文側の空白**: 上記 3.1–3.6 の未反映分を 条件つき導出補論 と補論 SAT / 設計原理 に反映しないままだと、Lean 資産が **論文強度に寄与しない状態**が続く。特に 3.2（条件つき導出補論 §4 格上げ）と 3.3（Route C companion II §7 マルコフモデル）は、査読者が Route A/B 強度を評価する際に効く。

---

## 5. 推奨される次アクション

優先度順:

1. **条件つき導出補論 §5 の形式検証対象リストを 5 → ~20 ファイルへ拡張**する最小差分 patch を書く（§3.1）。論文強度が既存資産だけで一段上がる。
2. **条件つき導出補論 §4 に真の martingale concentration サブセクションを追加**（§3.2）。`AzumaHoeffding.lean` を引用。
3. **Route C companion II §7.4 に最小マルコフ修復チェーン**を入れる（§3.3）。Route C companion II の主張が形式モデル上の定理で裏付けられる。
4. `lake build Survival` の通過状況と、174 Survival modules の依存グラフを図示。棚卸しの完成度を検証。
5. 補論 SAT の `AsymptoticExponent` / `CorrelatedSecondMoment` / `SensitivityAnalysis` の論文未掲載洞察を、補論 SAT §6 限界節または新規節として追加（§3.4）。

以上。
