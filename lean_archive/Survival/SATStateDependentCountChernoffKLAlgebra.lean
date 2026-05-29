import Survival.SATStateDependentCountChernoffKL

/-!
# SAT State-Dependent Count Chernoff KL Algebra Interface

This module tightens the KL-facing interface from
`SATStateDependentCountChernoffKL`.

The global statement

`optimized MGF profile ≤ exp (-n D(q || 1/8))`

is only the right target in the genuine lower-tail regime.  If the deviation
budget is negative, the induced count threshold lies above the mean and the
textbook lower-tail KL exponent should not be claimed.  We therefore add a
margin-clipped KL profile: for `r < 0` it returns the trivial failure bound `1`,
while for `0 ≤ r` it uses the existing support-clipped KL/Chernoff candidate.

The remaining analytic obligation is now localized to the active lower-tail
interior: nonnegative margins below the linear drift center.
-/

namespace Survival.SATStateDependentCountChernoffKLAlgebra

open MeasureTheory
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentClauseExposure
open Survival.SATStateDependentCountThreshold
open Survival.SATStateDependentCountReduction
open Survival.SATStateDependentCountTailUpperBound
open Survival.SATStateDependentCountSupportBound
open Survival.SATStateDependentCountSupportClippedUpperBound
open Survival.SATStateDependentCountChernoffUpperBound
open Survival.SATStateDependentCountChernoffMGF
open Survival.SATStateDependentCountChernoffKL
open Survival.ConcentrationInterface
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- A support-clipped profile additionally guarded by the fact that KL lower-tail
rates are only informative for nonnegative deviation budgets. -/
def nonnegativeMarginSupportClippedFailureBound
    (B : CountFailureProfile) : CountFailureProfile :=
  fun n r =>
    if r < 0 then 1 else supportClippedFailureBound B n r

theorem nonnegativeMarginSupportClippedFailureBound_eq_one_of_neg
    {B : CountFailureProfile} (n : ℕ) {r : ℝ}
    (hr : r < 0) :
    nonnegativeMarginSupportClippedFailureBound B n r = 1 := by
  simp [nonnegativeMarginSupportClippedFailureBound, hr]

theorem nonnegativeMarginSupportClippedFailureBound_eq_support_of_nonneg
    {B : CountFailureProfile} (n : ℕ) {r : ℝ}
    (hr : 0 ≤ r) :
    nonnegativeMarginSupportClippedFailureBound B n r =
      supportClippedFailureBound B n r := by
  have hnot : ¬ r < 0 := not_lt.mpr hr
  simp [nonnegativeMarginSupportClippedFailureBound, hnot]

/-- The support- and margin-clipped SAT KL/Chernoff profile. -/
def satNonnegativeMarginSupportClippedCountChernoffFailureBound :
    CountFailureProfile :=
  nonnegativeMarginSupportClippedFailureBound countChernoffFailureBound

/-- A still-strong global nonnegative-margin KL algebra obligation.  This is
useful as a convenient sufficient condition, but the wrapper below only needs
the smaller interior obligation. -/
def HasNonnegativeMarginOptimizedMGFToKLBound : Prop :=
  ∀ (n : ℕ) (r : ℝ), 0 ≤ r →
    countOptimizedClosedMGFChernoffFailureBound n r ≤
      countChernoffFailureBound n r

/-- The sharp remaining KL algebra obligation: optimized MGF is dominated by
the KL candidate only on the genuine active lower-tail interior.  The exterior
cases are handled by the trivial probability bound and the exact support
envelope. -/
def HasInteriorOptimizedMGFToKLBound : Prop :=
  ∀ (n : ℕ) (r : ℝ), 0 ≤ r → r < (n : ℝ) * random3ClauseDrift →
    countOptimizedClosedMGFChernoffFailureBound n r ≤
      countChernoffFailureBound n r

theorem hasNonnegativeMarginOptimizedMGFToKLBound_of_global
    (hKL : HasOptimizedMGFToKLBound) :
    HasNonnegativeMarginOptimizedMGFToKLBound := by
  intro n r _hr
  exact hKL n r

theorem hasInteriorOptimizedMGFToKLBound_of_nonnegativeMargin
    (hKL : HasNonnegativeMarginOptimizedMGFToKLBound) :
    HasInteriorOptimizedMGFToKLBound := by
  intro n r hr _hinterior
  exact hKL n r hr

theorem hasInteriorOptimizedMGFToKLBound_of_global
    (hKL : HasOptimizedMGFToKLBound) :
    HasInteriorOptimizedMGFToKLBound :=
  hasInteriorOptimizedMGFToKLBound_of_nonnegativeMargin
    (hasNonnegativeMarginOptimizedMGFToKLBound_of_global hKL)

/-- In the active lower-tail interior, the induced count-threshold ratio is
strictly positive. -/
theorem countThresholdRatio_pos_of_nonneg_of_lt_activeDrift
    {n : ℕ} {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * random3ClauseDrift) :
    0 < countThresholdRatio n r := by
  by_cases hn : n = 0
  · subst n
    simp at hlt
    linarith
  · have hnpos_nat : 0 < n := Nat.pos_of_ne_zero hn
    have hnpos : 0 < (n : ℝ) := Nat.cast_pos.mpr hnpos_nat
    have hnum : 0 < (n : ℝ) * random3ClauseDrift - r := by
      linarith
    have hscale : 0 < unsatEmissionScale := unsatEmissionScale_pos
    rw [countThresholdRatio, if_neg hn]
    unfold countThreshold
    exact div_pos (div_pos hnum hscale) hnpos

/-- Nonnegative lower-tail margins force the count-threshold ratio to be at
most the Bernoulli unsatisfied probability `1 / 8`. -/
theorem countThresholdRatio_le_unsatProb_of_nonneg
    {n : ℕ} {r : ℝ}
    (hr : 0 ≤ r) :
    countThresholdRatio n r ≤ (1 / 8 : ℝ) := by
  by_cases hn : n = 0
  · subst n
    simp [countThresholdRatio]
  · have hnpos_nat : 0 < n := Nat.pos_of_ne_zero hn
    have hnpos : 0 < (n : ℝ) := Nat.cast_pos.mpr hnpos_nat
    have hscale : 0 < unsatEmissionScale := unsatEmissionScale_pos
    rw [countThresholdRatio, if_neg hn]
    rw [div_le_iff₀ hnpos]
    unfold countThreshold
    rw [div_le_iff₀ hscale]
    unfold unsatEmissionScale
    nlinarith [hr, random3ClauseDrift_pos]

theorem countThresholdRatio_lt_one_of_nonneg
    {n : ℕ} {r : ℝ}
    (hr : 0 ≤ r) :
    countThresholdRatio n r < 1 := by
  have hle := countThresholdRatio_le_unsatProb_of_nonneg (n := n) (r := r) hr
  exact lt_of_le_of_lt hle (by norm_num : (1 / 8 : ℝ) < 1)

/-- In the SAT lower-tail interior, the formal Bernoulli optimizer is
admissible for lower-tail Chernoff (`t ≤ 0`). -/
theorem satLowerTailTilt_nonpos_of_countThresholdRatio_interior
    {n : ℕ} {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * random3ClauseDrift) :
    satLowerTailTilt (countThresholdRatio n r) ≤ 0 := by
  let q := countThresholdRatio n r
  have hq_pos : 0 < q :=
    countThresholdRatio_pos_of_nonneg_of_lt_activeDrift
      (n := n) (r := r) hr hlt
  have hq_le : q ≤ (1 / 8 : ℝ) :=
    countThresholdRatio_le_unsatProb_of_nonneg (n := n) (r := r) hr
  have hq_lt_one : q < 1 :=
    lt_of_le_of_lt hq_le (by norm_num : (1 / 8 : ℝ) < 1)
  unfold q at hq_pos hq_le hq_lt_one
  unfold satLowerTailTilt bernoulliLowerTailTilt
  apply Real.log_nonpos
  · exact
      div_nonneg
        (mul_nonneg hq_pos.le (by norm_num : 0 ≤ (1 : ℝ) - 1 / 8))
        (mul_nonneg (by norm_num : 0 ≤ (1 / 8 : ℝ))
          (sub_nonneg_of_le hq_lt_one.le))
  · have hden_pos :
        0 < (1 / 8 : ℝ) * (1 - countThresholdRatio n r) := by
      exact mul_pos (by norm_num) (sub_pos.mpr hq_lt_one)
    rw [div_le_iff₀ hden_pos]
    nlinarith

/-- Consequently, on the genuine lower-tail interior the clipped optimizer is
the usual Bernoulli lower-tail tilt. -/
theorem countOptimizingTilt_eq_unclipped_of_interior
    {n : ℕ} {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * random3ClauseDrift) :
    countOptimizingTilt n r =
      satLowerTailTilt (countThresholdRatio n r) :=
  countOptimizingTilt_eq_unclipped_of_nonpos
    (satLowerTailTilt_nonpos_of_countThresholdRatio_interior
      (n := n) (r := r) hr hlt)

/-- Away from `n = 0`, the real count threshold is exactly `n` times its
normalized threshold ratio. -/
theorem countThreshold_eq_nat_mul_countThresholdRatio_of_ne_zero
    (n : ℕ) (r : ℝ) (hn : n ≠ 0) :
    countThreshold n r = (n : ℝ) * countThresholdRatio n r := by
  rw [countThresholdRatio, if_neg hn]
  have hnpos : (n : ℝ) ≠ 0 := by exact_mod_cast hn
  field_simp [hnpos]

/-- At the Bernoulli lower-tail tilt, the SAT one-step unsatisfied-count MGF
has the closed form `(7 / 8) / (1 - q)`. -/
theorem bernoulliUnsatMGF_satLowerTailTilt
    (q : ℝ) (hq0 : 0 < q) (hq1 : q < 1) :
    bernoulliUnsatMGF (satLowerTailTilt q) = (7 / 8 : ℝ) / (1 - q) := by
  unfold bernoulliUnsatMGF satLowerTailTilt bernoulliLowerTailTilt
  have hden_pos : 0 < (1 / 8 : ℝ) * (1 - q) := by
    exact mul_pos (by norm_num) (sub_pos.mpr hq1)
  have harg_pos :
      0 < (q * (1 - (1 / 8 : ℝ))) / ((1 / 8 : ℝ) * (1 - q)) := by
    exact div_pos (mul_pos hq0 (by norm_num)) hden_pos
  have hsub : 1 - q ≠ 0 := ne_of_gt (sub_pos.mpr hq1)
  rw [Real.exp_log harg_pos]
  field_simp [hsub]
  ring

/-- The optimized Bernoulli exponent equals the negative Bernoulli relative
entropy rate. -/
theorem satLowerTailTilt_log_mgf_identity
    (q : ℝ) (hq0 : 0 < q) (hq1 : q < 1) :
    -q * satLowerTailTilt q +
        Real.log (bernoulliUnsatMGF (satLowerTailTilt q)) =
      -bernoulliRelativeEntropyCandidate q (1 / 8 : ℝ) := by
  rw [bernoulliUnsatMGF_satLowerTailTilt q hq0 hq1]
  unfold satLowerTailTilt bernoulliLowerTailTilt
    bernoulliRelativeEntropyCandidate
  have hq_ne : q ≠ 0 := ne_of_gt hq0
  have hsub_pos : 0 < 1 - q := sub_pos.mpr hq1
  have hsub_ne : 1 - q ≠ 0 := ne_of_gt hsub_pos
  have hden_ne : (1 / 8 : ℝ) * (1 - q) ≠ 0 := by positivity
  rw [Real.log_div
    (mul_ne_zero hq_ne (by norm_num : (1 - (1 / 8 : ℝ)) ≠ 0))
    hden_ne]
  rw [Real.log_mul hq_ne (by norm_num : (1 - (1 / 8 : ℝ)) ≠ 0)]
  rw [Real.log_mul (by norm_num : (1 / 8 : ℝ) ≠ 0) hsub_ne]
  rw [Real.log_div (by norm_num : (7 / 8 : ℝ) ≠ 0) hsub_ne]
  rw [Real.log_div hq_ne (by norm_num : (1 / 8 : ℝ) ≠ 0)]
  rw [Real.log_div hsub_ne
    (by norm_num : (1 - (1 / 8 : ℝ)) ≠ 0)]
  norm_num
  ring

/-- The closed MGF Chernoff profile at the Bernoulli lower-tail optimizer is
the exponential of the negative Bernoulli relative entropy rate. -/
theorem optimizedClosedMGFReal_eq_exp_neg_bernoulliRelativeEntropy
    (n : ℕ) (q : ℝ) (hq0 : 0 < q) (hq1 : q < 1) :
    Real.exp (-satLowerTailTilt q * ((n : ℝ) * q)) *
        bernoulliUnsatMGF (satLowerTailTilt q) ^ n =
      Real.exp (-((n : ℝ) *
        bernoulliRelativeEntropyCandidate q (1 / 8 : ℝ))) := by
  let M := bernoulliUnsatMGF (satLowerTailTilt q)
  have hM_eq : M = (7 / 8 : ℝ) / (1 - q) := by
    exact bernoulliUnsatMGF_satLowerTailTilt q hq0 hq1
  have hM_pos : 0 < M := by
    rw [hM_eq]
    exact div_pos (by norm_num) (sub_pos.mpr hq1)
  have hid := satLowerTailTilt_log_mgf_identity q hq0 hq1
  calc
    Real.exp (-satLowerTailTilt q * ((n : ℝ) * q)) *
        bernoulliUnsatMGF (satLowerTailTilt q) ^ n
        = Real.exp (-satLowerTailTilt q * ((n : ℝ) * q)) * M ^ n := by rfl
    _ = Real.exp (-satLowerTailTilt q * ((n : ℝ) * q)) *
          Real.exp ((n : ℝ) * Real.log M) := by
          rw [← Real.exp_log (pow_pos hM_pos n), Real.log_pow]
    _ = Real.exp
          (-satLowerTailTilt q * ((n : ℝ) * q) +
            (n : ℝ) * Real.log M) := by
          rw [← Real.exp_add]
    _ = Real.exp
          ((n : ℝ) * (-q * satLowerTailTilt q + Real.log M)) := by
          congr 1
          ring
    _ = Real.exp
          ((n : ℝ) *
            (-bernoulliRelativeEntropyCandidate q (1 / 8 : ℝ))) := by
          rw [hid]
    _ = Real.exp
          (-((n : ℝ) *
            bernoulliRelativeEntropyCandidate q (1 / 8 : ℝ))) := by
          congr 1
          ring

/-- Bernoulli relative entropy is nonnegative on the probability interior. -/
theorem bernoulliRelativeEntropyCandidate_nonneg
    {q p : ℝ} (hq0 : 0 < q) (hq1 : q < 1)
    (hp0 : 0 < p) (hp1 : p < 1) :
    0 ≤ bernoulliRelativeEntropyCandidate q p := by
  unfold bernoulliRelativeEntropyCandidate
  have hx1 : 0 < q / p := div_pos hq0 hp0
  have hx2 : 0 < (1 - q) / (1 - p) :=
    div_pos (sub_pos.mpr hq1) (sub_pos.mpr hp1)
  have hlog1 := Real.one_sub_inv_le_log_of_pos hx1
  have hlog2 := Real.one_sub_inv_le_log_of_pos hx2
  have hmul1 : q * (1 - (q / p)⁻¹) ≤ q * Real.log (q / p) := by
    exact mul_le_mul_of_nonneg_left hlog1 hq0.le
  have hmul2 :
      (1 - q) * (1 - ((1 - q) / (1 - p))⁻¹) ≤
        (1 - q) * Real.log ((1 - q) / (1 - p)) := by
    exact mul_le_mul_of_nonneg_left hlog2 (sub_nonneg_of_le hq1.le)
  have hterm1 : q * (1 - (q / p)⁻¹) = q - p := by
    field_simp [hq0.ne', hp0.ne']
  have hterm2 :
      (1 - q) * (1 - ((1 - q) / (1 - p))⁻¹) = p - q := by
    have hq : 1 - q ≠ 0 := ne_of_gt (sub_pos.mpr hq1)
    have hp : 1 - p ≠ 0 := ne_of_gt (sub_pos.mpr hp1)
    field_simp [hq, hp]
    ring_nf
  have hsum := add_le_add hmul1 hmul2
  linarith

/-- In the active lower-tail interior, `countChernoffRate` is the unclipped
Bernoulli relative entropy rate. -/
theorem countChernoffRate_eq_of_interior
    {n : ℕ} {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * random3ClauseDrift) :
    countChernoffRate n r =
      (n : ℝ) *
        bernoulliRelativeEntropyCandidate
          (countThresholdRatio n r)
          (1 / 8 : ℝ) := by
  have hn : n ≠ 0 := by
    intro hn0
    subst n
    simp at hlt
    linarith
  have hq0 :=
    countThresholdRatio_pos_of_nonneg_of_lt_activeDrift
      (n := n) (r := r) hr hlt
  have hq1 := countThresholdRatio_lt_one_of_nonneg (n := n) (r := r) hr
  have hD :
      0 ≤ bernoulliRelativeEntropyCandidate
        (countThresholdRatio n r) (1 / 8 : ℝ) := by
    exact bernoulliRelativeEntropyCandidate_nonneg
      hq0 hq1 (by norm_num) (by norm_num)
  unfold countChernoffRate
  rw [if_neg hn]
  exact max_eq_right (mul_nonneg (Nat.cast_nonneg n) hD)

/-- On the genuine lower-tail interior, the optimized MGF profile is exactly
the KL/Chernoff profile. -/
theorem countOptimizedClosedMGFChernoffFailureBound_eq_countChernoffFailureBound_of_interior
    {n : ℕ} {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * random3ClauseDrift) :
    countOptimizedClosedMGFChernoffFailureBound n r =
      countChernoffFailureBound n r := by
  have hn : n ≠ 0 := by
    intro hn0
    subst n
    simp at hlt
    linarith
  let q := countThresholdRatio n r
  have hq0 : 0 < q :=
    countThresholdRatio_pos_of_nonneg_of_lt_activeDrift
      (n := n) (r := r) hr hlt
  have hq1 : q < 1 :=
    countThresholdRatio_lt_one_of_nonneg (n := n) (r := r) hr
  have ht : countOptimizingTilt n r = satLowerTailTilt q := by
    exact countOptimizingTilt_eq_unclipped_of_interior
      (n := n) (r := r) hr hlt
  have hthreshold : countThreshold n r = (n : ℝ) * q := by
    unfold q
    exact countThreshold_eq_nat_mul_countThresholdRatio_of_ne_zero n r hn
  have hrate :
      countChernoffRate n r =
        (n : ℝ) * bernoulliRelativeEntropyCandidate q (1 / 8 : ℝ) := by
    unfold q
    exact countChernoffRate_eq_of_interior (n := n) (r := r) hr hlt
  unfold countOptimizedClosedMGFChernoffFailureBound
    countClosedMGFChernoffFailureBound
    countChernoffFailureBound largeDeviationFailureBound
  rw [ht, hthreshold, hrate]
  exact
    congrArg ENNReal.ofReal
      (optimizedClosedMGFReal_eq_exp_neg_bernoulliRelativeEntropy n q hq0 hq1)

/-- The remaining KL algebra bridge is now discharged on the exact interior
where it is mathematically needed. -/
theorem hasInteriorOptimizedMGFToKLBound :
    HasInteriorOptimizedMGFToKLBound := by
  intro n r hr hlt
  exact
    (countOptimizedClosedMGFChernoffFailureBound_eq_countChernoffFailureBound_of_interior
      (n := n) (r := r) hr hlt).le

/-- Any exact count-tail probability is bounded by the trivial probability
bound `1`. -/
theorem exactCountFailureBound_le_one
    (N n : ℕ) (r : ℝ) :
    exactCountFailureBound N n r ≤ 1 := by
  rw [exactCountFailureBound_eq_countBelowThresholdMeasure]
  exact prob_le_one

/-- The corrected KL profile is a valid count-tail upper bound as soon as the
nonnegative-margin KL algebra bridge is available. -/
theorem hasCountFailureUpperBound_nonnegativeMarginSupportClippedChernoff
    (N : ℕ)
    (hKL : HasInteriorOptimizedMGFToKLBound) :
    HasCountFailureUpperBound N
      satNonnegativeMarginSupportClippedCountChernoffFailureBound := by
  intro n hn r
  by_cases hneg : r < 0
  · rw [satNonnegativeMarginSupportClippedCountChernoffFailureBound,
      nonnegativeMarginSupportClippedFailureBound_eq_one_of_neg n hneg]
    exact exactCountFailureBound_le_one N n r
  · have hr_nonneg : 0 ≤ r := le_of_not_gt hneg
    rw [satNonnegativeMarginSupportClippedCountChernoffFailureBound,
      nonnegativeMarginSupportClippedFailureBound_eq_support_of_nonneg n hr_nonneg]
    by_cases hlow : r < supportFloor n
    · rw [supportClippedFailureBound_eq_one_of_supportFloor_lt
        (B := countChernoffFailureBound) n hlow]
      exact exactCountFailureBound_le_one N n r
    · by_cases hhigh : (n : ℝ) * random3ClauseDrift ≤ r
      · rw [supportClippedFailureBound_eq_zero_of_activeDrift_le
          (B := countChernoffFailureBound) n hhigh]
        rw [exactCountFailureBound_eq_zero_of_activeDrift_le N n r hhigh]
      · rw [supportClippedFailureBound_eq_base_of_interior
          (B := countChernoffFailureBound) n hlow hhigh]
        have hlt_active : r < (n : ℝ) * random3ClauseDrift :=
          lt_of_not_ge hhigh
        exact
          (exactCountFailureBound_le_optimizedClosedMGF_pathPMF
            N hn r).trans (hKL n r hr_nonneg hlt_active)

/-- The support- and margin-aware KL/Chernoff profile is now an unconditional
count-tail upper bound for the actual SAT clause-exposure process. -/
theorem hasCountFailureUpperBound_nonnegativeMarginSupportClippedChernoff_pathPMF
    (N : ℕ) :
    HasCountFailureUpperBound N
      satNonnegativeMarginSupportClippedCountChernoffFailureBound :=
  hasCountFailureUpperBound_nonnegativeMarginSupportClippedChernoff
    N hasInteriorOptimizedMGFToKLBound

/-- Active-prefix threshold crossing under the corrected KL/Chernoff profile. -/
theorem thresholdCrossingWithNonnegativeMarginChernoffBound
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hKL : HasInteriorOptimizedMGFToKLBound)
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (satNonnegativeMarginSupportClippedCountChernoffFailureBound n r) := by
  exact
    thresholdCrossingWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hn
      (hB := hasCountFailureUpperBound_nonnegativeMarginSupportClippedChernoff
        N hKL)
      hmargin

/-- Unconditional active-prefix threshold crossing under the corrected
KL/Chernoff profile. -/
theorem thresholdCrossingWithNonnegativeMarginChernoffBound_pathPMF
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (satNonnegativeMarginSupportClippedCountChernoffFailureBound n r) := by
  exact
    thresholdCrossingWithNonnegativeMarginChernoffBound
      hn hasInteriorOptimizedMGFToKLBound hmargin

/-- Active-prefix collapse under the corrected KL/Chernoff profile. -/
theorem collapseWithNonnegativeMarginChernoffBound
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hKL : HasInteriorOptimizedMGFToKLBound)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    CollapseWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (satNonnegativeMarginSupportClippedCountChernoffFailureBound n r) := by
  exact
    collapseWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hn
      (hB := hasCountFailureUpperBound_nonnegativeMarginSupportClippedChernoff
        N hKL)
      hθ hmargin

/-- Unconditional active-prefix collapse under the corrected KL/Chernoff
profile. -/
theorem collapseWithNonnegativeMarginChernoffBound_pathPMF
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    CollapseWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (satNonnegativeMarginSupportClippedCountChernoffFailureBound n r) := by
  exact
    collapseWithNonnegativeMarginChernoffBound
      hn hasInteriorOptimizedMGFToKLBound hθ hmargin

/-- Terminal stopped-collapse under the corrected KL/Chernoff profile. -/
theorem stoppedCollapseWithNonnegativeMarginChernoffBound
    {N T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hKL : HasInteriorOptimizedMGFToKLBound)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * random3ClauseDrift - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satNonnegativeMarginSupportClippedCountChernoffFailureBound T r) := by
  exact
    stoppedCollapseWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hT
      (hB := hasCountFailureUpperBound_nonnegativeMarginSupportClippedChernoff
        N hKL)
      hθ hmargin

/-- Unconditional terminal stopped-collapse under the corrected KL/Chernoff
profile. -/
theorem stoppedCollapseWithNonnegativeMarginChernoffBound_pathPMF
    {N T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * random3ClauseDrift - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satNonnegativeMarginSupportClippedCountChernoffFailureBound T r) := by
  exact
    stoppedCollapseWithNonnegativeMarginChernoffBound
      hT hasInteriorOptimizedMGFToKLBound hθ hmargin

/-- Hitting-time-before-horizon under the corrected KL/Chernoff profile. -/
theorem hittingTimeBeforeHorizonWithNonnegativeMarginChernoffBound
    {N k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1) {s₀ θ r : ℝ}
    (hKL : HasInteriorOptimizedMGFToKLBound)
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * random3ClauseDrift - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satNonnegativeMarginSupportClippedCountChernoffFailureBound k r) := by
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hkT hk
      (hB := hasCountFailureUpperBound_nonnegativeMarginSupportClippedChernoff
        N hKL)
      hmargin

/-- Unconditional hitting-time-before-horizon under the corrected KL/Chernoff
profile. -/
theorem hittingTimeBeforeHorizonWithNonnegativeMarginChernoffBound_pathPMF
    {N k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1) {s₀ θ r : ℝ}
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * random3ClauseDrift - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satNonnegativeMarginSupportClippedCountChernoffFailureBound k r) := by
  exact
    hittingTimeBeforeHorizonWithNonnegativeMarginChernoffBound
      hkT hk hasInteriorOptimizedMGFToKLBound hmargin

end

end Survival.SATStateDependentCountChernoffKLAlgebra
