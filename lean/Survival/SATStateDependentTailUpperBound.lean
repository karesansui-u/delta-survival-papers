import Survival.SATStateDependentExactConcentration
import Survival.SATStateDependentAzuma

/-!
# SAT State-Dependent Tail Upper Bound Bridge

This module isolates the single remaining probabilistic input needed to turn the
exact lower-tail concentration object of the non-flat SAT clause-exposure
process into an explicit Azuma/Hoeffding-style high-probability bound.

The design is conservative:

* `SATStateDependentExactConcentration` gives the exact lower-tail event and its
  exact failure profile under the actual SAT path measure;
* `SATStateDependentAzuma` gives the generic Azuma/collapse wrappers once a
  `StepModelLowerTailWitness` is available;
* this file proves that any external upper bound on the exact failure profile
  automatically yields such a witness, and hence the full Azuma wrapper stack.

So the only remaining SAT-specific analytic task is to prove a closed-form
upper bound on `exactFailureBound`.
-/

namespace Survival.SATStateDependentTailUpperBound

open MeasureTheory
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentClauseExposure
open Survival.SATStateDependentExactConcentration
open Survival.SATStateDependentAzuma
open Survival.StochasticTotalProductionAzuma
open Survival.BoundedAzumaConstruction
open Survival.AzumaHoeffding
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- The concrete increment bound for the non-flat SAT emission is the constant
`8 * log (8 / 7)`. -/
theorem incrementBound_eq_eight_mul_random3ClauseDrift
    (t : ℕ) :
    incrementBound t = 8 * random3ClauseDrift := by
  unfold incrementBound emissionBound oneSidedUnsatEmission
  simp [random3ClauseDrift_nonneg, abs_of_nonneg]

/-- The resulting variance proxy is linear in the horizon. -/
theorem varianceProxy_eq
    (n : ℕ) :
    varianceProxyOfBounds incrementBound n =
      (n : ℝ) * (8 * random3ClauseDrift) ^ (2 : ℕ) := by
  unfold varianceProxyOfBounds
  simp [incrementBound_eq_eight_mul_random3ClauseDrift, Finset.sum_const, nsmul_eq_mul]

/-- Specialized Azuma/Hoeffding failure profile for the non-flat SAT process. -/
def satAzumaFailureBound
    (n : ℕ) (r : ℝ) : ENNReal :=
  azumaHoeffdingFailureBound
    (varianceProxyOfBounds incrementBound) n r

/-- The remaining analytic input: a closed-form Azuma/Hoeffding upper bound on
the exact SAT lower-tail failure profile. -/
def HasAzumaFailureUpperBound
    (N : ℕ) (s₀ : ℝ) : Prop :=
  ∀ n r, exactFailureBound N s₀ n r ≤ satAzumaFailureBound n r

/-- Any explicit upper bound on the exact failure profile yields a genuine SAT
lower-tail witness for the generic Azuma interface. -/
def lowerTailWitness_of_hasAzumaFailureUpperBound
    (N : ℕ) (s₀ : ℝ)
    (hupper : HasAzumaFailureUpperBound N s₀) :
    StepModelLowerTailWitness
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission)
      incrementBound where
  goodEvent := exactLowerTailEvent N s₀
  measurable_goodEvent := measurable_exactLowerTailEvent N s₀
  lower_bound_on_good := lower_bound_on_exactLowerTailEvent N s₀
  azuma_failure_bound := by
    intro n r
    simpa [exactFailureBound, satAzumaFailureBound] using hupper n r

/-- Hence the non-flat SAT process acquires concrete Azuma data as soon as the
exact failure profile is dominated by the Azuma profile. -/
def stepModelAzumaData_of_hasAzumaFailureUpperBound
    (N : ℕ) (s₀ : ℝ)
    (hupper : HasAzumaFailureUpperBound N s₀) :
    StepModelAzumaData
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission) :=
  stepModelAzumaData N s₀
    (lowerTailWitness_of_hasAzumaFailureUpperBound N s₀ hupper)

/-- Expected-margin stopped-collapse bound once the exact SAT failure profile
is known to satisfy the Azuma/Hoeffding upper bound. -/
theorem stoppedCollapseWithFailureBound_of_expectedMargin_of_hasAzumaFailureUpperBound
    {N : ℕ} {s₀ θ r : ℝ}
    (hupper : HasAzumaFailureUpperBound N s₀)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative N - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      N θ
      (satAzumaFailureBound N r) := by
  simpa [satAzumaFailureBound] using
    SATStateDependentAzuma.stoppedCollapseWithFailureBound_of_expectedMargin
      (W := lowerTailWitness_of_hasAzumaFailureUpperBound N s₀ hupper)
      hθ hmargin

/-- Expected-margin hitting-time-before-horizon bound once the exact SAT
failure profile is known to satisfy the Azuma/Hoeffding upper bound. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin_of_hasAzumaFailureUpperBound
    {N : ℕ} {k : ℕ} (hkN : k < N) {s₀ θ r : ℝ}
    (hupper : HasAzumaFailureUpperBound N s₀)
    (hmargin :
      -Real.log θ ≤
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative k - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      N θ
      (satAzumaFailureBound k r) := by
  simpa [satAzumaFailureBound] using
    SATStateDependentAzuma.hittingTimeBeforeHorizonWithFailureBound_of_expectedMargin
      hkN
      (W := lowerTailWitness_of_hasAzumaFailureUpperBound N s₀ hupper)
      hmargin

/-- Active-prefix stopped-collapse bound from the exact linear center, once the
exact SAT tail is controlled by the Azuma/Hoeffding profile. -/
theorem stoppedCollapseWithFailureBound_of_activeLinearMargin_of_hasAzumaFailureUpperBound
    {N T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hupper : HasAzumaFailureUpperBound N s₀)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤ s₀ + (T : ℝ) * random3ClauseDrift - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satAzumaFailureBound T r) := by
  simpa [satAzumaFailureBound] using
    SATStateDependentAzuma.stoppedCollapseWithFailureBound_of_activeLinearMargin
      hT
      (W := lowerTailWitness_of_hasAzumaFailureUpperBound N s₀ hupper)
      hθ hmargin

/-- Active-prefix hitting-time-before-horizon bound from the exact linear
center, once the exact SAT tail is controlled by the Azuma/Hoeffding profile. -/
theorem hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin_of_hasAzumaFailureUpperBound
    {N k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1) {s₀ θ r : ℝ}
    (hupper : HasAzumaFailureUpperBound N s₀)
    (hmargin :
      -Real.log θ ≤ s₀ + (k : ℝ) * random3ClauseDrift - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure N)
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess
      T θ
      (satAzumaFailureBound k r) := by
  simpa [satAzumaFailureBound] using
    SATStateDependentAzuma.hittingTimeBeforeHorizonWithFailureBound_of_activeLinearMargin
      hkT hk
      (W := lowerTailWitness_of_hasAzumaFailureUpperBound N s₀ hupper)
      hmargin

end

end Survival.SATStateDependentTailUpperBound
