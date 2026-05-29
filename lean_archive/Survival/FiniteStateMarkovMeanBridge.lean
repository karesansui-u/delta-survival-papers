import Mathlib.Probability.ProbabilityMassFunction.Constructions
import Mathlib.Probability.ProbabilityMassFunction.Integrals
import Survival.FiniteStateMarkovStationaryProduction

/-!
# Finite-State Markov Mean Bridge

This module connects the *actual* finite-horizon Markov path-space process from
`FiniteStateMarkovRepairChain` to the abstract mean / stationary expected
centers from `FiniteStateMarkovStationaryProduction`.

The key new ingredient is the finite-state marginal theorem:

* the time-`t` state under `pathPMF M N` has distribution `stateMarginal M t`
  whenever `t ≤ N`.

From this we derive:

* actual expected one-step total production = mean expected increment;
* actual expected cumulative total production = `meanExpectedProcess`;
* under stationary start, actual expected cumulative total production = the
  stationary linear center.

This is the missing bridge from concrete finite-horizon Markov path measures to
the mean-production / stationary-production layer.
-/

namespace Survival.FiniteStateMarkovMeanBridge

open MeasureTheory
open Survival.MarkovRepairFailureExample
open Survival.FiniteStateMarkovRepairChain
open Survival.FiniteStateMarkovFlatWitness
open Survival.StochasticTotalProduction
open Survival.ProbabilityConnection
open Survival.FiniteStateMarkovStationaryProduction

noncomputable section

instance : MeasurableSpace RepairState := ⊤

instance : MeasurableSingletonClass RepairState where
  measurableSet_singleton _ := by trivial

/-- The time-`t` state distribution induced by the finite-horizon path-space
`PMF`. -/
def stateProjectionPMF (M : ChainData) (N t : ℕ) : PMF RepairState :=
  (pathPMF M N).map (fun τ => stateAt τ t)

/-- Uniform finite-state absolute bound for real-valued functions on
`RepairState`. -/
def stateFunctionBound (f : RepairState → ℝ) : ℝ :=
  max |f .failure| (max |f .idle| |f .repair|)

theorem abs_le_stateFunctionBound (f : RepairState → ℝ) (s : RepairState) :
    |f s| ≤ stateFunctionBound f := by
  cases s <;> simp [stateFunctionBound]

theorem integrable_stateFunction (μ : Measure RepairState) [IsFiniteMeasure μ]
    (f : RepairState → ℝ) :
    Integrable f μ := by
  refine Integrable.of_bound (μ := μ) (f := f)
    (show AEStronglyMeasurable f μ from
      (measurable_from_top : Measurable f).aestronglyMeasurable)
    (stateFunctionBound f) ?_
  refine Filter.Eventually.of_forall ?_
  intro s
  simpa [Real.norm_eq_abs] using abs_le_stateFunctionBound f s

theorem stateAverage_eq_integral (p : PMF RepairState) (f : RepairState → ℝ) :
    stateAverage p f = ∫ s, f s ∂ p.toMeasure := by
  unfold stateAverage
  symm
  simpa [smul_eq_mul, mul_comm, mul_left_comm, mul_assoc] using PMF.integral_eq_sum p f

theorem stateAt_snoc_of_le {N : ℕ} (τ : Trajectory N) (s : RepairState) {t : ℕ}
    (ht : t ≤ N) :
    stateAt (snoc τ s) t = stateAt τ t := by
  have hts : t < N + 1 := Nat.lt_succ_of_le ht
  have hnot : ¬ N + 1 < t := not_lt.mpr (Nat.le_trans ht (Nat.le_succ N))
  simp [stateAt, snoc, ht, hts, hnot]

theorem stateAt_snoc_last {N : ℕ} (τ : Trajectory N) (s : RepairState) :
    stateAt (snoc τ s) (N + 1) = s := by
  simp [stateAt, snoc]

theorem stateAt_last {N : ℕ} (τ : Trajectory N) :
    stateAt τ N = τ (Fin.last N) := by
  have hidx : (⟨N, Nat.lt_succ_of_le (Nat.le_refl N)⟩ : Fin (N + 1)) = Fin.last N := by
    apply Fin.ext
    rfl
  simpa [stateAt] using congrArg τ hidx

theorem pathPMF_succ_eq (M : ChainData) (N : ℕ) :
    pathPMF M (N + 1) =
      (pathPMF M N).bind fun τ =>
        PMF.map (snoc τ) (M.step (τ (Fin.last N))) := rfl

/-- The time-`t` state marginal of the concrete finite-horizon path-space `PMF`
agrees with the abstract Markov marginal `stateMarginal M t`. -/
theorem stateProjectionPMF_eq_stateMarginal (M : ChainData) :
    ∀ {N t : ℕ}, t ≤ N → stateProjectionPMF M N t = stateMarginal M t
  | 0, t, ht => by
      have ht0 : t = 0 := Nat.eq_zero_of_le_zero ht
      subst ht0
      calc
        stateProjectionPMF M 0 0 = (M.init.map singletonTraj).map (fun τ => stateAt τ 0) := by
          rfl
        _ = M.init.map ((fun τ => stateAt τ 0) ∘ singletonTraj) := by
          rw [PMF.map_comp]
        _ = M.init.map id := by
          have hfun : ((fun τ => stateAt τ 0) ∘ singletonTraj) = id := by
            funext s
            simp [singletonTraj, stateAt]
          rw [hfun]
        _ = M.init := by simpa using (PMF.map_id (p := M.init))
        _ = stateMarginal M 0 := by rfl
  | N + 1, t, ht => by
      by_cases hlt : t ≤ N
      · calc
          stateProjectionPMF M (N + 1) t
            = (pathPMF M N).bind (fun τ => PMF.pure (stateAt τ t)) := by
                have hinner :
                    ∀ a,
                      PMF.map (fun τ => stateAt τ t)
                          (PMF.map (snoc a) (M.step (a (Fin.last N)))) =
                        PMF.pure (stateAt a t) := by
                  intro a
                  rw [PMF.map_comp]
                  have hfun :
                      ((fun τ => stateAt τ t) ∘ snoc a) = fun _ => stateAt a t := by
                    funext s
                    exact stateAt_snoc_of_le a s hlt
                  simpa using (hfun ▸ PMF.map_const (p := M.step (a (Fin.last N))) (b := stateAt a t))
                rw [stateProjectionPMF, pathPMF_succ_eq, PMF.map_bind]
                exact
                  congrArg (fun f => (pathPMF M N).bind f) (funext hinner)
          _ = stateProjectionPMF M N t := by
                simpa [stateProjectionPMF, Function.comp] using
                  (PMF.bind_pure_comp (p := pathPMF M N) (f := fun τ => stateAt τ t))
          _ = stateMarginal M t := stateProjectionPMF_eq_stateMarginal M hlt
      · have ht_eq : t = N + 1 := Nat.le_antisymm ht (Nat.succ_le_of_lt (lt_of_not_ge hlt))
        subst ht_eq
        calc
          stateProjectionPMF M (N + 1) (N + 1)
            = (pathPMF M N).bind (fun τ => (M.step (τ (Fin.last N))).map id) := by
                have hinner :
                    ∀ a,
                      PMF.map (fun τ => stateAt τ (N + 1))
                          (PMF.map (snoc a) (M.step (a (Fin.last N)))) =
                        PMF.map id (M.step (a (Fin.last N))) := by
                  intro a
                  rw [PMF.map_comp]
                  have hfun :
                      ((fun τ => stateAt τ (N + 1)) ∘ snoc a) = id := by
                    funext s
                    exact stateAt_snoc_last a s
                  rw [hfun]
                rw [stateProjectionPMF, pathPMF_succ_eq, PMF.map_bind]
                exact
                  congrArg (fun f => (pathPMF M N).bind f) (funext hinner)
          _ = (pathPMF M N).bind (fun τ => M.step (τ (Fin.last N))) := by
                exact congrArg (fun f => (pathPMF M N).bind f)
                  (funext fun τ => PMF.map_id (p := M.step (τ (Fin.last N))))
          _ = (pathPMF M N).bind (fun τ => M.step (stateAt τ N)) := by
                refine congrArg (fun f => (pathPMF M N).bind f) ?_
                funext τ
                rw [stateAt_last]
          _ = ((pathPMF M N).map (fun τ => stateAt τ N)).bind M.step := by
                symm
                exact PMF.bind_map (p := pathPMF M N) (f := fun τ => stateAt τ N) (q := M.step)
          _ = (stateMarginal M N).bind M.step := by
                change (stateProjectionPMF M N N).bind M.step = (stateMarginal M N).bind M.step
                rw [stateProjectionPMF_eq_stateMarginal M (Nat.le_refl N)]
          _ = stateMarginal M (N + 1) := by
                simp [stateMarginal]

/-- Expectation of a state function at time `t` on the actual finite-horizon
Markov path space is the corresponding finite-state marginal average. -/
theorem expectedStateFunction_eq_stateAverage_of_le
    (M : ChainData) (N : ℕ) (f : RepairState → ℝ) {t : ℕ} (ht : t ≤ N) :
    ∫ τ, f (stateAt τ t) ∂ pathMeasure M N =
      stateAverage (stateMarginal M t) f := by
  change ∫ τ, f (stateAt τ t) ∂ (pathPMF M N).toMeasure =
    stateAverage (stateMarginal M t) f
  calc
    ∫ τ, f (stateAt τ t) ∂ (pathPMF M N).toMeasure
      = ∫ s, f s ∂ Measure.map (fun τ : Trajectory N => stateAt τ t) (pathPMF M N).toMeasure := by
          symm
          exact MeasureTheory.integral_map
            (μ := (pathPMF M N).toMeasure)
            (φ := fun τ : Trajectory N => stateAt τ t)
            (measurable_from_top : Measurable (fun τ : Trajectory N => stateAt τ t)).aemeasurable
            ((measurable_from_top : Measurable f).aestronglyMeasurable)
    _ = ∫ s, f s ∂ ((stateMarginal M t).toMeasure) := by
          rw [PMF.toMeasure_map (p := pathPMF M N)
            (f := fun τ : Trajectory N => stateAt τ t)
            (hf := (measurable_from_top : Measurable (fun τ : Trajectory N => stateAt τ t)))]
          have hproj :
              ∫ s, f s ∂ (stateProjectionPMF M N t).toMeasure =
                ∫ s, f s ∂ (stateMarginal M t).toMeasure := by
            exact congrArg (fun p : PMF RepairState => ∫ s, f s ∂ p.toMeasure)
              (stateProjectionPMF_eq_stateMarginal M ht)
          simpa [stateProjectionPMF] using hproj
    _ = stateAverage (stateMarginal M t) f := by
          symm
          exact stateAverage_eq_integral (stateMarginal M t) f

theorem stepTotalProductionRV_eq_stateTotal_of_le
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission) {t : ℕ} (ht : t ≤ N) :
    stepTotalProductionRV (stepModel M N s₀ E) t =
      fun τ => totalProductionOfState E (stateAt τ t) := by
  funext τ
  simp [StochasticTotalProduction.stepTotalProductionRV, FiniteStateMarkovRepairChain.stepModel,
    stepNetActionRV, stepCostRV, totalProductionOfState, stateAt, ht]

theorem stepTotalProductionRV_eq_zero_of_not_le
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission) {t : ℕ} (ht : ¬ t ≤ N) :
    stepTotalProductionRV (stepModel M N s₀ E) t = fun _ => 0 := by
  funext τ
  simp [StochasticTotalProduction.stepTotalProductionRV, FiniteStateMarkovRepairChain.stepModel,
    stepNetActionRV, stepCostRV, ht]

/-- Actual expected one-step total production on the concrete path space agrees
with the abstract mean expected increment. -/
theorem expectedIncrement_eq_meanExpectedIncrement
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission) (t : ℕ) :
    (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedIncrement t =
      meanExpectedIncrement N M E t := by
  by_cases ht : t ≤ N
  · rw [show (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedIncrement t =
      ∫ τ, stepTotalProductionRV (stepModel M N s₀ E) t τ ∂ pathMeasure M N by rfl]
    rw [stepTotalProductionRV_eq_stateTotal_of_le M N s₀ E ht]
    simp [meanExpectedIncrement, ht, expectedStateFunction_eq_stateAverage_of_le M N
      (totalProductionOfState E) ht]
  · rw [show (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedIncrement t =
      ∫ τ, stepTotalProductionRV (stepModel M N s₀ E) t τ ∂ pathMeasure M N by rfl]
    rw [stepTotalProductionRV_eq_zero_of_not_le M N s₀ E ht]
    simp [meanExpectedIncrement, ht]

/-- Actual expected cumulative total production on the concrete finite-horizon
Markov path space agrees with the abstract mean-production center. -/
theorem expectedCumulative_eq_meanExpectedCumulative
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (E : Emission) :
    ∀ n,
      (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative n =
        (meanExpectedProcess N s₀ M E).expectedCumulative n
  | 0 => by
      change ∫ _ : Trajectory N, s₀ ∂ pathMeasure M N = s₀ + meanCumulativeSum N M E 0
      simp [meanCumulativeSum]
  | n + 1 => by
      rw [(stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expected_succ n]
      rw [(meanExpectedProcess N s₀ M E).expected_succ n]
      rw [expectedCumulative_eq_meanExpectedCumulative M N s₀ E n]
      rw [expectedIncrement_eq_meanExpectedIncrement M N s₀ E n]
      rw [meanExpectedProcess_expectedIncrement_eq]

/-- Under stationary start, the actual expected cumulative total production
matches the stationary linear center. -/
theorem expectedCumulative_eq_stationaryExpectedCumulative
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission) :
    ∀ n,
      (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative n =
        (stationaryExpectedProcess N s₀ S E).expectedCumulative n
  | n => by
      rw [expectedCumulative_eq_meanExpectedCumulative M N s₀ E n]
      exact meanExpectedCumulative_eq_stationaryExpectedCumulative
        (N := N) (s₀ := s₀) (S := S) (E := E) n

theorem expectedCumulative_eq_initial_add_linear_of_stationary
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission)
    {n : ℕ} (hn : n ≤ N + 1) :
    (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative n =
      s₀ + (n : ℝ) * stationaryMean S E := by
  rw [expectedCumulative_eq_stationaryExpectedCumulative M N s₀ S E n]
  exact stationaryExpectedCumulative_eq_initial_add_linear_of_le N s₀ S E hn

theorem expectedCumulative_eq_active_stationaryMean
    (M : ChainData) (N : ℕ) (s₀ : ℝ) (S : StationaryData M) (E : Emission) (n : ℕ) :
    (stepModel M N s₀ E).toStochasticProcess.toExpectedProcess.expectedCumulative n =
      s₀ + (activeSteps N n : ℝ) * stationaryMean S E := by
  rw [expectedCumulative_eq_stationaryExpectedCumulative M N s₀ S E n]
  exact stationaryExpectedProcess_expectedCumulative_eq N s₀ S E n

end

end Survival.FiniteStateMarkovMeanBridge
