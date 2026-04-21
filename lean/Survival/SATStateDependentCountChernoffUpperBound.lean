import Survival.ConcentrationInterface
import Survival.SATStateDependentCountSupportClippedUpperBound

/-!
# SAT State-Dependent Count Chernoff Upper Bound

This module packages the SAT-specific Chernoff / binomial closed-form candidate
for the interior count tail.

The exact domination proof is intentionally separated: the previous modules have
already reduced the actual non-flat SAT failure profile to a lower tail of the
unsatisfied-clause count, together with an exact support envelope. Here we add

* a Bernoulli relative-entropy style rate function,
* the corresponding exponential failure profile,
* support clipping by the exact SAT support envelope,
* and direct collapse / hitting-time wrappers assuming this Chernoff bound.

So after this file, the remaining SAT-specific probabilistic task is localized
to one statement:

* `HasCountChernoffFailureUpperBound N`.
-/

namespace Survival.SATStateDependentCountChernoffUpperBound

open MeasureTheory
open Survival.ConcentrationInterface
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentClauseExposure
open Survival.SATStateDependentExactConcentration
open Survival.SATStateDependentCountThreshold
open Survival.SATStateDependentCountTailUpperBound
open Survival.SATStateDependentCountSupportClippedUpperBound
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Bernoulli relative-entropy candidate `D(q || p)`.

This is recorded as a closed-form rate candidate; the exact domination proof of
the SAT count tail by the associated Chernoff profile is left to a later file.
-/
def bernoulliRelativeEntropyCandidate (q p : ℝ) : ℝ :=
  q * Real.log (q / p) + (1 - q) * Real.log ((1 - q) / (1 - p))

/-- SAT lower-tail count proportion corresponding to the deviation budget `r`.

For `n = 0` we set the proportion to `0` by convention. -/
def countThresholdRatio (n : ℕ) (r : ℝ) : ℝ :=
  if n = 0 then 0 else countThreshold n r / (n : ℝ)

/-- Chernoff / binomial large-deviation rate candidate for the active-prefix SAT
count tail. We clip at `0` so the induced exponential profile never exceeds `1`.
-/
def countChernoffRate (n : ℕ) (r : ℝ) : ℝ :=
  max 0 <|
    if n = 0 then
      0
    else
      (n : ℝ) *
        bernoulliRelativeEntropyCandidate
          (countThresholdRatio n r)
          (1 / 8 : ℝ)

/-- Exponential Chernoff / binomial failure profile candidate for the count
tail. -/
def countChernoffFailureBound : CountFailureProfile :=
  fun n r => largeDeviationFailureBound countChernoffRate n r

/-- The remaining SAT-specific analytic input for a Chernoff-style interior
bound on the count tail. -/
def HasCountChernoffFailureUpperBound
    (N : ℕ) : Prop :=
  HasCountFailureUpperBound N countChernoffFailureBound

/-- Support-clipped Chernoff / binomial failure profile for the actual non-flat
SAT process. -/
def satSupportClippedCountChernoffFailureBound : CountFailureProfile :=
  supportClippedFailureBound countChernoffFailureBound

/-- The actual non-flat SAT process used by the Chernoff wrapper. -/
abbrev satProcess (N : ℕ) (s₀ : ℝ) :=
  (SATStateDependentClauseExposure.stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess

/-- Any interior Chernoff / binomial bound is automatically sharpened by the
exact SAT support envelope. -/
theorem hasCountFailureUpperBound_supportClippedChernoff
    {N : ℕ}
    (hB : HasCountChernoffFailureUpperBound N) :
    HasCountFailureUpperBound N satSupportClippedCountChernoffFailureBound :=
  hasCountFailureUpperBound_supportClipped
    (B := countChernoffFailureBound)
    hB

/-- Active-prefix exact SAT failure is bounded by the support-clipped Chernoff
candidate whenever the interior count tail is. -/
theorem exactFailureBound_le_supportClippedChernoff
    {N : ℕ} {n : ℕ} (hn : n ≤ N + 1) {s₀ r : ℝ}
    (hB : HasCountChernoffFailureUpperBound N) :
    exactFailureBound N s₀ n r ≤ satSupportClippedCountChernoffFailureBound n r :=
  exactFailureBound_le_supportClippedFailureBound_of_hasCountFailureUpperBound
    hn
    (B := countChernoffFailureBound)
    hB

/-- Active-prefix threshold crossing under the support-clipped SAT Chernoff
profile. -/
theorem thresholdCrossingWithChernoffBound_of_activeLinearMargin
    {N n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hB : HasCountChernoffFailureUpperBound N)
    (hmargin : -Real.log θ ≤ s₀ + (n : ℝ) * random3ClauseDrift - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure N)
      (satProcess N s₀)
      n θ
      (satSupportClippedCountChernoffFailureBound n r) := by
  have hclip :
      HasCountFailureUpperBound N satSupportClippedCountChernoffFailureBound :=
    hasCountFailureUpperBound_supportClippedChernoff hB
  exact
    thresholdCrossingWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hn
      (B := satSupportClippedCountChernoffFailureBound)
      (hB := hclip)
      hmargin

/-- Active-prefix stopped-collapse bound under the support-clipped SAT Chernoff
profile. -/
theorem stoppedCollapseWithChernoffBound_of_activeLinearMargin
    {N T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hB : HasCountChernoffFailureUpperBound N)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ s₀ + (T : ℝ) * random3ClauseDrift - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (satProcess N s₀)
      T θ
      (satSupportClippedCountChernoffFailureBound T r) := by
  have hclip :
      HasCountFailureUpperBound N satSupportClippedCountChernoffFailureBound :=
    hasCountFailureUpperBound_supportClippedChernoff hB
  exact
    stoppedCollapseWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hT
      (B := satSupportClippedCountChernoffFailureBound)
      (hB := hclip)
      hθ hmargin

/-- Active-prefix hitting-time-before-horizon bound under the support-clipped
SAT Chernoff profile. -/
theorem hittingTimeBeforeHorizonWithChernoffBound_of_activeLinearMargin
    {N k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1) {s₀ θ r : ℝ}
    (hB : HasCountChernoffFailureUpperBound N)
    (hmargin : -Real.log θ ≤ s₀ + (k : ℝ) * random3ClauseDrift - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (satProcess N s₀)
      T θ
      (satSupportClippedCountChernoffFailureBound k r) := by
  have hclip :
      HasCountFailureUpperBound N satSupportClippedCountChernoffFailureBound :=
    hasCountFailureUpperBound_supportClippedChernoff hB
  exact
    hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin_of_hasCountFailureUpperBound
      hkT hk
      (B := satSupportClippedCountChernoffFailureBound)
      (hB := hclip)
      hmargin

end

end Survival.SATStateDependentCountChernoffUpperBound
