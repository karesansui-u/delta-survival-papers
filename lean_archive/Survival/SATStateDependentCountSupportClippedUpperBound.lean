import Survival.SATStateDependentCountSupportBound
import Survival.SATStateDependentCountTailUpperBound

/-!
# SAT State-Dependent Support-Clipped Tail Upper Bound

This module combines the exact support envelope of the SAT count tail with any
interior upper profile.

After `SATStateDependentCountSupportBound`, the exact failure profile is already
known on the two extreme regimes:

* it is exactly `1` below the support floor `-7 n log (8 / 7)`;
* it is exactly `0` once the deviation budget reaches the active linear center
  `n log (8 / 7)`.

Therefore any further analytic upper bound only needs to work on the remaining
interior regime. This file packages that observation into a reusable
`supportClippedFailureBound`, and then specializes it to the SAT
Azuma/Hoeffding profile.
-/

namespace Survival.SATStateDependentCountSupportClippedUpperBound

open MeasureTheory
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentClauseExposure
open Survival.SATStateDependentExactConcentration
open Survival.SATStateDependentCountReduction
open Survival.SATStateDependentCountSupportBound
open Survival.SATStateDependentTailUpperBound
open Survival.SATStateDependentCountTailUpperBound
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- The exact lower support floor of the non-flat SAT tail. -/
def supportFloor (n : ℕ) : ℝ :=
  -(7 : ℝ) * (n : ℝ) * random3ClauseDrift

/-- Any interior count-tail upper profile can be sharpened by clipping it to
the exact support envelope of the SAT tail. -/
def supportClippedFailureBound
    (B : CountFailureProfile) : CountFailureProfile :=
  fun n r =>
    if r < supportFloor n then 1
    else if (n : ℝ) * random3ClauseDrift ≤ r then 0
    else B n r

theorem supportClippedFailureBound_eq_one_of_supportFloor_lt
    {B : CountFailureProfile} (n : ℕ) {r : ℝ}
    (hr : r < supportFloor n) :
    supportClippedFailureBound B n r = 1 := by
  simp [supportClippedFailureBound, hr]

theorem supportClippedFailureBound_eq_zero_of_activeDrift_le
    {B : CountFailureProfile} (n : ℕ) {r : ℝ}
    (hr : (n : ℝ) * random3ClauseDrift ≤ r) :
    supportClippedFailureBound B n r = 0 := by
  have hnot : ¬ r < supportFloor n := by
    intro hlt
    have hfloor_le : supportFloor n ≤ (n : ℝ) * random3ClauseDrift := by
      unfold supportFloor
      have hnonneg : 0 ≤ (n : ℝ) * random3ClauseDrift := by
        exact mul_nonneg (by positivity) random3ClauseDrift_nonneg
      linarith
    have hrlt : r < (n : ℝ) * random3ClauseDrift := lt_of_lt_of_le hlt hfloor_le
    exact (not_le_of_gt hrlt) hr
  simp [supportClippedFailureBound, hnot, hr]

theorem supportClippedFailureBound_eq_base_of_interior
    {B : CountFailureProfile} (n : ℕ) {r : ℝ}
    (hlow : ¬ r < supportFloor n)
    (hhigh : ¬ (n : ℝ) * random3ClauseDrift ≤ r) :
    supportClippedFailureBound B n r = B n r := by
  simp [supportClippedFailureBound, hlow, hhigh]

/-- The support-clipped profile is always a valid upper bound as soon as the
base profile is valid on the count tail. -/
theorem hasCountFailureUpperBound_supportClipped
    {N : ℕ} {B : CountFailureProfile}
    (hB : HasCountFailureUpperBound N B) :
    HasCountFailureUpperBound N (supportClippedFailureBound B) := by
  intro n hn r
  by_cases hlow : r < supportFloor n
  · rw [supportClippedFailureBound_eq_one_of_supportFloor_lt (B := B) n hlow]
    have hlow' : r < -(7 : ℝ) * (n : ℝ) * random3ClauseDrift := by
      simpa [supportFloor, mul_assoc, mul_left_comm, mul_comm] using hlow
    rw [exactCountFailureBound_eq_one_of_supportFloor_lt N n r hlow']
  · by_cases hhigh : (n : ℝ) * random3ClauseDrift ≤ r
    · rw [supportClippedFailureBound_eq_zero_of_activeDrift_le (B := B) n hhigh]
      rw [exactCountFailureBound_eq_zero_of_activeDrift_le N n r hhigh]
    · rw [supportClippedFailureBound_eq_base_of_interior (B := B) n hlow hhigh]
      exact hB hn r

/-- Active-prefix exact SAT failure is therefore bounded by the clipped
count-tail profile. -/
theorem exactFailureBound_le_supportClippedFailureBound_of_hasCountFailureUpperBound
    {N : ℕ} {n : ℕ} (hn : n ≤ N + 1) {s₀ r : ℝ}
    {B : CountFailureProfile}
    (hB : HasCountFailureUpperBound N B) :
    exactFailureBound N s₀ n r ≤ supportClippedFailureBound B n r := by
  calc
    exactFailureBound N s₀ n r = exactCountFailureBound N n r := by
      exact exactFailureBound_eq_exactCountFailureBound N s₀ hn r
    _ ≤ supportClippedFailureBound B n r :=
      hasCountFailureUpperBound_supportClipped hB hn r

/-- The SAT Azuma/Hoeffding profile sharpened by the exact support envelope. -/
def satSupportClippedAzumaFailureBound : CountFailureProfile :=
  supportClippedFailureBound satAzumaFailureBound

/-- The sharpened SAT Azuma/Hoeffding profile is a valid count-tail upper bound
whenever the interior Azuma/Hoeffding inequality is available. -/
theorem hasCountFailureUpperBound_satSupportClippedAzuma_of_hasCountAzumaFailureUpperBound
    {N : ℕ}
    (hB : HasCountAzumaFailureUpperBound N) :
    HasCountFailureUpperBound N satSupportClippedAzumaFailureBound :=
  hasCountFailureUpperBound_supportClipped (B := satAzumaFailureBound) hB

/-- Active-prefix exact SAT failure is bounded by the support-clipped
Azuma/Hoeffding profile. -/
theorem exactFailureBound_le_satSupportClippedAzumaFailureBound_of_hasCountAzumaFailureUpperBound
    {N : ℕ} {n : ℕ} (hn : n ≤ N + 1) {s₀ r : ℝ}
    (hB : HasCountAzumaFailureUpperBound N) :
    exactFailureBound N s₀ n r ≤ satSupportClippedAzumaFailureBound n r :=
  exactFailureBound_le_supportClippedFailureBound_of_hasCountFailureUpperBound
    hn
    (B := satAzumaFailureBound)
    hB

/-- Active-prefix threshold crossing under the support-clipped SAT
Azuma/Hoeffding profile. -/
theorem thresholdCrossingWithFailureBound_of_activeLinearMargin_of_hasCountAzumaFailureUpperBound
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hB : HasCountAzumaFailureUpperBound N)
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      n θ
      (satSupportClippedAzumaFailureBound n r) := by
  exact
    thresholdCrossingWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hn
      (B := satSupportClippedAzumaFailureBound)
      (hB := hasCountFailureUpperBound_satSupportClippedAzuma_of_hasCountAzumaFailureUpperBound hB)
      hmargin

/-- Active-prefix stopped-collapse bound under the support-clipped SAT
Azuma/Hoeffding profile. -/
theorem stoppedCollapseWithFailureBound_of_activeLinearMargin_of_hasCountAzumaFailureUpperBound
    {N T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hB : HasCountAzumaFailureUpperBound N)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * random3ClauseDrift - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satSupportClippedAzumaFailureBound T r) := by
  exact
    stoppedCollapseWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hT
      (B := satSupportClippedAzumaFailureBound)
      (hB := hasCountFailureUpperBound_satSupportClippedAzuma_of_hasCountAzumaFailureUpperBound hB)
      hθ hmargin

/-- Active-prefix hitting-time-before-horizon bound under the support-clipped
SAT Azuma/Hoeffding profile. -/
theorem
    hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin_of_hasCountAzumaFailureUpperBound
    {N k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1) {s₀ θ r : ℝ}
    (hB : HasCountAzumaFailureUpperBound N)
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * random3ClauseDrift - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satSupportClippedAzumaFailureBound k r) := by
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hkT hk
      (B := satSupportClippedAzumaFailureBound)
      (hB := hasCountFailureUpperBound_satSupportClippedAzuma_of_hasCountAzumaFailureUpperBound hB)
      hmargin

end

end Survival.SATStateDependentCountSupportClippedUpperBound
