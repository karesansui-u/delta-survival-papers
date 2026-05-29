import Mathlib.Probability.ProbabilityMassFunction.Integrals
import Survival.SATClauseExposureProcess

/-!
# SAT State-Dependent Clause Exposure

This module upgrades `SATClauseExposureProcess` from a flat first-moment wrapper
to a genuinely state-dependent additive functional on the same actual finite
clause-exposure path space.

The probability space is unchanged:

* each exposed clause outcome is `sat` with probability `7 / 8`;
* each exposed clause outcome is `unsat` with probability `1 / 8`;
* finite-horizon trajectories are sampled from the actual recursive `pathPMF`.

What changes is the observable. Instead of attaching the same total production
to every realized outcome, we allow a state-dependent emission
`ClauseOutcome → ℝ`.

The file proves:

* the time-`t` clause-outcome marginal is still `clausePMF`;
* expected one-step total production equals the clause-level mean emission;
* for the concrete non-flat emission with
  `sat ↦ 0`, `unsat ↦ 8 * log (8 / 7)`,
  the expected drift is exactly `log (8 / 7)`;
* expected cumulative total production has the same linear center on the active
  prefix, while the actual process is now genuinely realized-outcome dependent.
-/

open scoped ProbabilityTheory
open scoped BigOperators

namespace Survival.SATStateDependentClauseExposure

open MeasureTheory
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.StochasticTotalProduction
open Survival.ProbabilityConnection

noncomputable section

instance : MeasurableSpace ClauseOutcome := ⊤

instance : MeasurableSingletonClass ClauseOutcome where
  measurableSet_singleton _ := by
    trivial

/-- State-dependent total production attached to one realized clause outcome. -/
structure Emission where
  totalOf : ClauseOutcome → ℝ
  total_nonneg : ∀ s, 0 ≤ totalOf s

/-- A concrete non-flat SAT emission:
successful clauses contribute `0`, while unsatisfied clauses contribute the
entire expected first-moment drift budget `8 * log (8 / 7)`. -/
def oneSidedUnsatEmission : Emission where
  totalOf
    | .sat => 0
    | .unsat => 8 * random3ClauseDrift
  total_nonneg := by
    intro s
    cases s with
    | sat =>
        simp
    | unsat =>
        exact mul_nonneg (by norm_num) random3ClauseDrift_nonneg

theorem oneSidedUnsatEmission_nonflat :
    oneSidedUnsatEmission.totalOf .sat ≠ oneSidedUnsatEmission.totalOf .unsat := by
  simp [oneSidedUnsatEmission, random3ClauseDrift_pos.ne']

/-- Outside the active finite horizon, we extend the process by the benign
default outcome `sat`. This makes the state-dependent step model globally
defined while keeping the active prefix exact. -/
def outcomeAt {N : ℕ} (τ : Trajectory N) (t : ℕ) : ClauseOutcome :=
  if ht : t ≤ N then
    τ ⟨t, Nat.lt_succ_of_le ht⟩
  else
    .sat

/-- Time-`t` marginal induced by the actual clause-exposure path PMF. -/
def outcomeProjectionPMF (N t : ℕ) : PMF ClauseOutcome :=
  (pathPMF N).map (fun τ => outcomeAt τ t)

/-- Finite-state average of a clause-level observable. -/
def stateAverage (p : PMF ClauseOutcome) (f : ClauseOutcome → ℝ) : ℝ :=
  ∑ s, (p s).toReal * f s

/-- Mean emission under the one-step clause-outcome law. -/
def emissionMean (E : Emission) : ℝ :=
  stateAverage clausePMF E.totalOf

/-- Uniform finite-state absolute bound for clause-level observables. -/
def emissionBound (E : Emission) : ℝ :=
  max |E.totalOf .sat| |E.totalOf .unsat|

theorem abs_le_emissionBound (E : Emission) (s : ClauseOutcome) :
    |E.totalOf s| ≤ emissionBound E := by
  cases s <;> simp [emissionBound]

theorem stateAverage_eq_integral (p : PMF ClauseOutcome) (f : ClauseOutcome → ℝ) :
    stateAverage p f = ∫ s, f s ∂ p.toMeasure := by
  unfold stateAverage
  symm
  simpa [smul_eq_mul, mul_comm, mul_left_comm, mul_assoc] using PMF.integral_eq_sum p f

theorem outcomeAt_snoc_of_le {N : ℕ} (τ : Trajectory N) (s : ClauseOutcome) {t : ℕ}
    (ht : t ≤ N) :
    outcomeAt (snoc τ s) t = outcomeAt τ t := by
  have hts : t < N + 1 := Nat.lt_succ_of_le ht
  have hnot : ¬ N + 1 < t := not_lt.mpr (Nat.le_trans ht (Nat.le_succ N))
  simp [outcomeAt, snoc, ht, hts, hnot]

theorem outcomeAt_snoc_last {N : ℕ} (τ : Trajectory N) (s : ClauseOutcome) :
    outcomeAt (snoc τ s) (N + 1) = s := by
  simp [outcomeAt, snoc]

theorem pathPMF_succ_eq (N : ℕ) :
    pathPMF (N + 1) =
      (pathPMF N).bind fun τ =>
        PMF.map (snoc τ) clausePMF := rfl

/-- Every active coordinate of the actual clause-exposure path PMF has the same
one-step marginal `clausePMF`. -/
theorem outcomeProjectionPMF_eq_clausePMF :
    ∀ {N t : ℕ}, t ≤ N → outcomeProjectionPMF N t = clausePMF
  | 0, t, ht => by
      have ht0 : t = 0 := Nat.eq_zero_of_le_zero ht
      subst ht0
      calc
        outcomeProjectionPMF 0 0
          = (clausePMF.map singletonTraj).map (fun τ => outcomeAt τ 0) := by
              rfl
        _ = clausePMF.map ((fun τ => outcomeAt τ 0) ∘ singletonTraj) := by
              rw [PMF.map_comp]
        _ = clausePMF.map id := by
              have hfun : ((fun τ => outcomeAt τ 0) ∘ singletonTraj) = id := by
                funext s
                simp [singletonTraj, outcomeAt]
              rw [hfun]
        _ = clausePMF := by
              simpa using (PMF.map_id (p := clausePMF))
  | N + 1, t, ht => by
      by_cases hlt : t ≤ N
      · calc
          outcomeProjectionPMF (N + 1) t
            = (pathPMF N).bind (fun τ => PMF.pure (outcomeAt τ t)) := by
                have hinner :
                    ∀ a : Trajectory N,
                      PMF.map (fun τ : Trajectory (N + 1) => outcomeAt τ t)
                          (PMF.map (snoc a) clausePMF) =
                        PMF.pure (outcomeAt a t) := by
                  intro a
                  rw [PMF.map_comp]
                  have hfun :
                      ((fun τ : Trajectory (N + 1) => outcomeAt τ t) ∘ snoc a) =
                        (fun _ : ClauseOutcome => outcomeAt a t) := by
                    funext s
                    exact outcomeAt_snoc_of_le a s hlt
                  simpa using (hfun ▸ PMF.map_const (p := clausePMF) (b := outcomeAt a t))
                rw [outcomeProjectionPMF, pathPMF_succ_eq, PMF.map_bind]
                exact congrArg (fun f => (pathPMF N).bind f) (funext hinner)
          _ = outcomeProjectionPMF N t := by
                simpa [outcomeProjectionPMF, Function.comp] using
                  (PMF.bind_pure_comp (p := pathPMF N) (f := fun τ => outcomeAt τ t))
          _ = clausePMF := outcomeProjectionPMF_eq_clausePMF hlt
      · have ht_eq : t = N + 1 := by
          exact Nat.le_antisymm ht (Nat.succ_le_of_lt (lt_of_not_ge hlt))
        subst ht_eq
        calc
          outcomeProjectionPMF (N + 1) (N + 1)
            = (pathPMF N).bind (fun _ => clausePMF.map id) := by
                have hinner :
                    ∀ a : Trajectory N,
                      PMF.map (fun τ : Trajectory (N + 1) => outcomeAt τ (N + 1))
                          (PMF.map (snoc a) clausePMF) =
                        clausePMF.map id := by
                  intro a
                  rw [PMF.map_comp]
                  have hfun :
                      ((fun τ : Trajectory (N + 1) => outcomeAt τ (N + 1)) ∘ snoc a) = id := by
                    funext s
                    exact outcomeAt_snoc_last a s
                  rw [hfun]
                rw [outcomeProjectionPMF, pathPMF_succ_eq, PMF.map_bind]
                exact congrArg (fun f => (pathPMF N).bind f) (funext hinner)
          _ = (pathPMF N).bind (fun _ => clausePMF) := by
                refine congrArg (fun f => (pathPMF N).bind f) ?_
                funext τ
                simpa using (PMF.map_id (p := clausePMF))
          _ = clausePMF := by
                simpa using (PMF.bind_const (p := pathPMF N) (q := clausePMF))

theorem expectedOutcomeFunction_eq_stateAverage_of_le
    (N : ℕ) (f : ClauseOutcome → ℝ) {t : ℕ} (ht : t ≤ N) :
    ∫ τ, f (outcomeAt τ t) ∂ pathMeasure N =
      stateAverage clausePMF f := by
  change ∫ τ, f (outcomeAt τ t) ∂ (pathPMF N).toMeasure =
    stateAverage clausePMF f
  calc
    ∫ τ, f (outcomeAt τ t) ∂ (pathPMF N).toMeasure
      = ∫ s, f s ∂ Measure.map (fun τ : Trajectory N => outcomeAt τ t) (pathPMF N).toMeasure := by
          symm
          exact MeasureTheory.integral_map
            (μ := (pathPMF N).toMeasure)
            (φ := fun τ : Trajectory N => outcomeAt τ t)
            (measurable_from_top : Measurable (fun τ : Trajectory N => outcomeAt τ t)).aemeasurable
            ((measurable_from_top : Measurable f).aestronglyMeasurable)
    _ = ∫ s, f s ∂ clausePMF.toMeasure := by
          rw [PMF.toMeasure_map (p := pathPMF N)
            (f := fun τ : Trajectory N => outcomeAt τ t)
            (hf := (measurable_from_top : Measurable (fun τ : Trajectory N => outcomeAt τ t)))]
          have hproj :
              ∫ s, f s ∂ (outcomeProjectionPMF N t).toMeasure =
                ∫ s, f s ∂ clausePMF.toMeasure := by
            exact congrArg (fun p : PMF ClauseOutcome => ∫ s, f s ∂ p.toMeasure)
              (outcomeProjectionPMF_eq_clausePMF ht)
          simpa [outcomeProjectionPMF] using hproj
    _ = stateAverage clausePMF f := by
          symm
          exact stateAverage_eq_integral clausePMF f

/-- Clause-level step data induced by a state-dependent emission on the actual
SAT clause-exposure path measure. -/
def stepModel (N : ℕ) (s₀ : ℝ) (E : Emission) : StepModel (μ := pathMeasure N) where
  initialRV := fun _ => s₀
  stepNetActionRV t := fun τ => E.totalOf (outcomeAt τ t)
  stepCostRV _ := fun _ => 0
  integrable_initial := integrable_const s₀
  integrable_stepNetAction := by
    intro t
    have hmeas : AEStronglyMeasurable (fun τ : Trajectory N => E.totalOf (outcomeAt τ t)) (pathMeasure N) := by
      exact (measurable_from_top : Measurable (fun τ : Trajectory N => E.totalOf (outcomeAt τ t))).aestronglyMeasurable
    refine Integrable.of_bound hmeas (emissionBound E) ?_
    refine Filter.Eventually.of_forall ?_
    intro τ
    simpa [Real.norm_eq_abs] using abs_le_emissionBound E (outcomeAt τ t)
  integrable_stepCost := by
    intro t
    exact integrable_const 0

theorem stepTotalProductionRV_eq_totalOf
    (N : ℕ) (s₀ : ℝ) (E : Emission) (t : ℕ) :
    stepTotalProductionRV (μ := pathMeasure N) (stepModel N s₀ E) t =
      fun τ => E.totalOf (outcomeAt τ t) := by
  funext τ
  simp [StochasticTotalProduction.stepTotalProductionRV, stepModel]

theorem ae_nonnegative_stepTotalProduction
    (N : ℕ) (s₀ : ℝ) (E : Emission) :
    AENonnegativeStepTotalProduction (μ := pathMeasure N) (stepModel N s₀ E) := by
  intro t
  refine Filter.Eventually.of_forall ?_
  intro τ
  rw [stepTotalProductionRV_eq_totalOf N s₀ E t]
  exact E.total_nonneg (outcomeAt τ t)

theorem boundedStepTotalProduction
    (N : ℕ) (s₀ : ℝ) (E : Emission) :
    ∀ t, ∀ᵐ τ ∂pathMeasure N,
      |stepTotalProductionRV (μ := pathMeasure N) (stepModel N s₀ E) t τ| ≤ emissionBound E := by
  intro t
  refine Filter.Eventually.of_forall ?_
  intro τ
  rw [stepTotalProductionRV_eq_totalOf N s₀ E t]
  exact abs_le_emissionBound E (outcomeAt τ t)

/-- On the active prefix, expected one-step total production is the clause-level
mean emission. -/
theorem expectedIncrement_eq_emissionMean_of_le
    (N : ℕ) (s₀ : ℝ) (E : Emission) {t : ℕ} (ht : t ≤ N) :
    (stepModel N s₀ E).toStochasticProcess.toExpectedProcess.expectedIncrement t =
      emissionMean E := by
  change
    ∫ τ, stepTotalProductionRV (μ := pathMeasure N) (stepModel N s₀ E) t τ ∂ pathMeasure N =
      emissionMean E
  rw [stepTotalProductionRV_eq_totalOf N s₀ E t]
  simpa [emissionMean] using expectedOutcomeFunction_eq_stateAverage_of_le N E.totalOf ht

/-- Beyond the active finite horizon, the process is extended by the benign
default outcome `sat`. -/
theorem expectedIncrement_eq_sat_of_not_le
    (N : ℕ) (s₀ : ℝ) (E : Emission) {t : ℕ} (ht : ¬ t ≤ N) :
    (stepModel N s₀ E).toStochasticProcess.toExpectedProcess.expectedIncrement t =
      E.totalOf .sat := by
  change
    ∫ τ, stepTotalProductionRV (μ := pathMeasure N) (stepModel N s₀ E) t τ ∂ pathMeasure N =
      E.totalOf .sat
  rw [stepTotalProductionRV_eq_totalOf N s₀ E t]
  have hconst : (fun τ : Trajectory N => E.totalOf (outcomeAt τ t)) = fun _ => E.totalOf .sat := by
    funext τ
    simp [outcomeAt, ht]
  rw [hconst]
  exact expected_constant_eq (μ := pathMeasure N) (E.totalOf .sat)

/-- Therefore expected cumulative total production is monotone for any
nonnegative state-dependent SAT clause emission. -/
theorem expectedCumulative_monotone
    (N : ℕ) (s₀ : ℝ) (E : Emission) :
    Monotone
      (stepModel N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative :=
  expectedCumulative_monotone_of_ae_nonnegative_stepTotalProduction
    (stepModel N s₀ E)
    (ae_nonnegative_stepTotalProduction N s₀ E)

@[simp] theorem unsatProb_coe_ennreal :
    (Survival.SATClauseExposureProcess.unsatProb : ENNReal) = (8⁻¹ : ENNReal) := by
  change (((1 / 8 : NNReal) : ENNReal) = (8⁻¹ : ENNReal))
  norm_num

@[simp] theorem clausePMF_apply_sat :
    clausePMF ClauseOutcome.sat = (1 - 8⁻¹ : ENNReal) := by
  rw [clausePMF, PMF.map_apply]
  simp [PMF.bernoulli_apply, unsatProb_coe_ennreal]

@[simp] theorem clausePMF_apply_unsat :
    clausePMF ClauseOutcome.unsat = (8⁻¹ : ENNReal) := by
  rw [clausePMF, PMF.map_apply]
  simp [PMF.bernoulli_apply, unsatProb_coe_ennreal]

@[simp] theorem clausePMF_apply_sat_toReal :
    (clausePMF ClauseOutcome.sat).toReal = (7 / 8 : ℝ) := by
  rw [clausePMF_apply_sat]
  norm_num

@[simp] theorem clausePMF_apply_unsat_toReal :
    (clausePMF ClauseOutcome.unsat).toReal = (1 / 8 : ℝ) := by
  rw [clausePMF_apply_unsat]
  norm_num

theorem finset_univ_clauseOutcome :
    (Finset.univ : Finset ClauseOutcome) = {ClauseOutcome.sat, ClauseOutcome.unsat} := by
  ext x
  cases x <;> simp

theorem emissionMean_eq_random3ClauseDrift :
    emissionMean oneSidedUnsatEmission = random3ClauseDrift := by
  unfold emissionMean stateAverage oneSidedUnsatEmission
  rw [finset_univ_clauseOutcome]
  simp [random3ClauseDrift]

/-- The concrete non-flat SAT emission still has the same expected active
one-step drift `log (8 / 7)`, but now as a realized-outcome dependent additive
functional on the actual clause-exposure path space. -/
theorem expectedIncrement_eq_random3ClauseDrift_of_le
    (N : ℕ) (s₀ : ℝ) {t : ℕ} (ht : t ≤ N) :
    (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedIncrement t =
      random3ClauseDrift := by
  rw [expectedIncrement_eq_emissionMean_of_le N s₀ oneSidedUnsatEmission ht,
    emissionMean_eq_random3ClauseDrift]

/-- On the active prefix, the expected cumulative total production still has
the same exact linear center as the flat first-moment wrapper. -/
theorem expectedCumulative_eq_initial_add_linear_of_le
    (N : ℕ) (s₀ : ℝ) :
    ∀ {n : ℕ}, n ≤ N + 1 →
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative n =
        s₀ + (n : ℝ) * random3ClauseDrift
  | 0, _ => by
      simp [ProbabilityConnection.StochasticExpectedProcess.toExpectedProcess,
        StochasticTotalProduction.StepModel.toStochasticProcess,
        StochasticTotalProduction.cumulativeTotalProductionRV, stepModel]
  | n + 1, hn => by
      have hprefix : n ≤ N + 1 := Nat.le_trans (Nat.le_succ n) hn
      have hstep : n ≤ N := Nat.le_of_succ_le_succ hn
      have hsucc :=
        (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expected_succ n
      rw [expectedCumulative_eq_initial_add_linear_of_le (N := N) (s₀ := s₀) (n := n) hprefix] at hsucc
      rw [expectedIncrement_eq_random3ClauseDrift_of_le N s₀ hstep] at hsucc
      norm_num [Nat.cast_add, Nat.cast_one] at hsucc ⊢
      linarith

end

end Survival.SATStateDependentClauseExposure
