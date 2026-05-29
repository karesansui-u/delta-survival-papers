import Survival.SATStateDependentCountChernoffMGF

/-!
# SAT State-Dependent Count MGF Product

This module closes the SAT-specific MGF input left open by
`SATStateDependentCountChernoffMGF`.

For the actual recursive clause-exposure path PMF, the unsatisfied-clause count
on an active prefix has the same moment-generating function as a sum of
independent Bernoulli indicators with unsatisfied probability `1 / 8`.

Consequently the abstract `HasBernoulliMGFUpperBound` witness required by the
closed MGF Chernoff tail is generated directly from the actual path-space law.
-/

open scoped ProbabilityTheory
open scoped BigOperators

namespace Survival.SATStateDependentCountMGFProduct

open MeasureTheory
open ProbabilityTheory
open Survival.SATClauseExposureProcess
open Survival.SATStateDependentClauseExposure
open Survival.SATStateDependentCountReduction
open Survival.SATStateDependentCountChernoffMGF

noncomputable section

/-- Real-valued indicator of an unsatisfied clause outcome. -/
def unsatIndicator (s : ClauseOutcome) : ℝ :=
  if s = ClauseOutcome.unsat then 1 else 0

/-- Extending a path by a final outcome does not affect any old prefix count. -/
theorem unsatCountPrefix_snoc_of_le {N : ℕ} (τ : Trajectory N) (s : ClauseOutcome) :
    ∀ ⦃n : ℕ⦄, n ≤ N + 1 →
      unsatCountPrefix (snoc τ s) n = unsatCountPrefix τ n
  | 0, _ => by
      simp [unsatCountPrefix]
  | n + 1, hn => by
      have hprefix : n ≤ N + 1 := Nat.le_trans (Nat.le_succ n) hn
      have hstep : n ≤ N := Nat.le_of_succ_le_succ hn
      simp [unsatCountPrefix, unsatCountPrefix_snoc_of_le τ s hprefix,
        outcomeAt_snoc_of_le τ s hstep]

/-- The terminal prefix count after `snoc` is the old full count plus the new
unsatisfied indicator. -/
theorem unsatCountPrefix_snoc_last {N : ℕ} (τ : Trajectory N) (s : ClauseOutcome) :
    unsatCountPrefix (snoc τ s) (N + 2) =
      unsatCountPrefix τ (N + 1) + if s = ClauseOutcome.unsat then 1 else 0 := by
  change
    unsatCountPrefix (snoc τ s) ((N + 1) + 1) =
      unsatCountPrefix τ (N + 1) + if s = ClauseOutcome.unsat then 1 else 0
  rw [unsatCountPrefix]
  rw [unsatCountPrefix_snoc_of_le τ s (Nat.le_refl (N + 1))]
  rw [outcomeAt_snoc_last]

/-- The one-step MGF of the unsatisfied indicator is
`7/8 + (1/8) * exp t`. -/
theorem oneStepUnsatIndicatorMGF_eq_bernoulliUnsatMGF (t : ℝ) :
    ∫ s, Real.exp (t * unsatIndicator s) ∂clausePMF.toMeasure =
      bernoulliUnsatMGF t := by
  rw [PMF.integral_eq_sum]
  rw [finset_univ_clauseOutcome]
  simp [unsatIndicator, bernoulliUnsatMGF]
  ring

/-- A finite-type bind integral rule for PMFs.  This is the elementary
expectation law for a recursively sampled finite path. -/
theorem integral_bind_eq_sum
    {α β : Type*} [MeasurableSpace β] [MeasurableSingletonClass β]
    [Fintype α] [Fintype β]
    (p : PMF α) (q : α → PMF β) (f : β → ℝ) :
    ∫ b, f b ∂(p.bind q).toMeasure =
      ∑ a, (p a).toReal * ∫ b, f b ∂(q a).toMeasure := by
  classical
  rw [PMF.integral_eq_sum]
  simp_rw [PMF.integral_eq_sum]
  simp_rw [PMF.bind_apply]
  have htsum :
      ∀ b : β,
        (∑' a : α, p a * q a b).toReal =
          ∑ a : α, (p a).toReal * (q a b).toReal := by
    intro b
    calc
      (∑' a : α, p a * q a b).toReal
          = (∑ a : α, p a * q a b).toReal := by
              rw [tsum_eq_sum (s := Finset.univ)]
              intro a ha
              simp at ha
      _ = ∑ a : α, (p a * q a b).toReal := by
              rw [ENNReal.toReal_sum]
              intro a _ha
              exact ENNReal.mul_ne_top (p.apply_ne_top a) ((q a).apply_ne_top b)
      _ = ∑ a : α, (p a).toReal * (q a b).toReal := by
              simp [ENNReal.toReal_mul]
  simp_rw [htsum]
  calc
    ∑ b : β, (∑ a : α, (p a).toReal * (q a b).toReal) • f b
        = ∑ b : β, (∑ a : α, (p a).toReal * (q a b).toReal) * f b := by
            simp [smul_eq_mul]
    _ = ∑ b : β, ∑ a : α, ((p a).toReal * (q a b).toReal) * f b := by
            simp [Finset.sum_mul]
    _ = ∑ a : α, ∑ b : β, ((p a).toReal * (q a b).toReal) * f b := by
            exact Finset.sum_comm
    _ = ∑ a : α, (p a).toReal * ∑ b : β, (q a b).toReal * f b := by
            refine Finset.sum_congr rfl ?_
            intro a _ha
            rw [Finset.mul_sum]
            refine Finset.sum_congr rfl ?_
            intro b _hb
            ring

theorem mgf_unsatCountRV_eq_countPMF_integral
    (N n : ℕ) (t : ℝ) :
    mgf (unsatCountRV N n) (pathMeasure N) t =
      ∫ k, Real.exp (t * (k : ℝ))
        ∂((pathPMF N).map fun τ => unsatCountPrefix τ n).toMeasure := by
  change
    ∫ τ, Real.exp (t * ((unsatCountPrefix τ n : ℕ) : ℝ)) ∂(pathPMF N).toMeasure =
      ∫ k, Real.exp (t * (k : ℝ))
        ∂((pathPMF N).map fun τ => unsatCountPrefix τ n).toMeasure
  rw [← PMF.toMeasure_map
    (p := pathPMF N)
    (f := fun τ : Trajectory N => unsatCountPrefix τ n)
    (hf := (measurable_from_top : Measurable (fun τ : Trajectory N => unsatCountPrefix τ n)))]
  symm
  exact
    MeasureTheory.integral_map
      (μ := (pathPMF N).toMeasure)
      (φ := fun τ : Trajectory N => unsatCountPrefix τ n)
      (measurable_from_top :
        Measurable (fun τ : Trajectory N => unsatCountPrefix τ n)).aemeasurable
      ((measurable_from_top :
        Measurable (fun k : ℕ => Real.exp (t * (k : ℝ)))).aestronglyMeasurable)

theorem countPMF_succ_of_le {N n : ℕ} (hn : n ≤ N + 1) :
    (pathPMF (N + 1)).map (fun τ => unsatCountPrefix τ n) =
      (pathPMF N).map (fun τ => unsatCountPrefix τ n) := by
  calc
    (pathPMF (N + 1)).map (fun τ => unsatCountPrefix τ n)
        = (pathPMF N).bind
            (fun τ => (clausePMF.map (snoc τ)).map
              (fun τ' => unsatCountPrefix τ' n)) := by
            rw [pathPMF_succ_eq, PMF.map_bind]
    _ = (pathPMF N).bind
            (fun τ => PMF.pure (unsatCountPrefix τ n)) := by
            refine congrArg (fun f => (pathPMF N).bind f) ?_
            funext τ
            rw [PMF.map_comp]
            have hfun :
                ((fun τ' : Trajectory (N + 1) => unsatCountPrefix τ' n) ∘ snoc τ) =
                  fun _ : ClauseOutcome => unsatCountPrefix τ n := by
              funext s
              exact unsatCountPrefix_snoc_of_le τ s hn
            simpa using (hfun ▸ PMF.map_const (p := clausePMF) (b := unsatCountPrefix τ n))
    _ = (pathPMF N).map (fun τ => unsatCountPrefix τ n) := by
            simpa [Function.comp] using
              (PMF.bind_pure_comp (p := pathPMF N)
                (f := fun τ => unsatCountPrefix τ n))

theorem mgf_unsatCountRV_succ_of_le {N n : ℕ} (hn : n ≤ N + 1) (t : ℝ) :
    mgf (unsatCountRV (N + 1) n) (pathMeasure (N + 1)) t =
      mgf (unsatCountRV N n) (pathMeasure N) t := by
  change
    ∫ τ', Real.exp (t * ((unsatCountPrefix τ' n : ℕ) : ℝ))
      ∂(pathPMF (N + 1)).toMeasure =
    ∫ τ, Real.exp (t * ((unsatCountPrefix τ n : ℕ) : ℝ))
      ∂(pathPMF N).toMeasure
  rw [pathPMF_succ_eq]
  rw [integral_bind_eq_sum]
  have hinner :
      ∀ τ : Trajectory N,
        ∫ τ', Real.exp (t * ((unsatCountPrefix τ' n : ℕ) : ℝ))
            ∂(clausePMF.map (snoc τ)).toMeasure =
          Real.exp (t * ((unsatCountPrefix τ n : ℕ) : ℝ)) := by
    intro τ
    rw [← PMF.toMeasure_map
      (p := clausePMF)
      (f := snoc τ)
      (hf := (measurable_from_top : Measurable (snoc τ)))]
    calc
      ∫ τ', Real.exp (t * ((unsatCountPrefix τ' n : ℕ) : ℝ))
          ∂Measure.map (snoc τ) clausePMF.toMeasure
          = ∫ s, Real.exp (t * ((unsatCountPrefix (snoc τ s) n : ℕ) : ℝ))
              ∂clausePMF.toMeasure := by
              exact
                MeasureTheory.integral_map
                  (μ := clausePMF.toMeasure)
                  (φ := snoc τ)
                  (measurable_from_top : Measurable (snoc τ)).aemeasurable
                  ((measurable_from_top :
                    Measurable
                      (fun τ' : Trajectory (N + 1) =>
                        Real.exp (t * ((unsatCountPrefix τ' n : ℕ) : ℝ)))).aestronglyMeasurable)
      _ = ∫ s, Real.exp (t * ((unsatCountPrefix τ n : ℕ) : ℝ))
              ∂clausePMF.toMeasure := by
              congr with s
              rw [unsatCountPrefix_snoc_of_le τ s hn]
      _ = Real.exp (t * ((unsatCountPrefix τ n : ℕ) : ℝ)) := by
              simp
  simp_rw [hinner]
  rw [PMF.integral_eq_sum]
  simp [smul_eq_mul]

theorem innerTerminalMGF_eq
    {N : ℕ} (τ : Trajectory N) (t : ℝ) :
    ∫ τ', Real.exp (t * ((unsatCountPrefix τ' (N + 2) : ℕ) : ℝ))
        ∂(clausePMF.map (snoc τ)).toMeasure =
      Real.exp (t * ((unsatCountPrefix τ (N + 1) : ℕ) : ℝ)) *
        bernoulliUnsatMGF t := by
  rw [← PMF.toMeasure_map
    (p := clausePMF)
    (f := snoc τ)
    (hf := (measurable_from_top : Measurable (snoc τ)))]
  calc
    ∫ τ', Real.exp (t * ((unsatCountPrefix τ' (N + 2) : ℕ) : ℝ))
        ∂Measure.map (snoc τ) clausePMF.toMeasure
        = ∫ s, Real.exp (t * ((unsatCountPrefix (snoc τ s) (N + 2) : ℕ) : ℝ))
            ∂clausePMF.toMeasure := by
            exact
              MeasureTheory.integral_map
                (μ := clausePMF.toMeasure)
                (φ := snoc τ)
                (measurable_from_top : Measurable (snoc τ)).aemeasurable
                ((measurable_from_top :
                  Measurable
                    (fun τ' : Trajectory (N + 1) =>
                      Real.exp (t * ((unsatCountPrefix τ' (N + 2) : ℕ) : ℝ)))).aestronglyMeasurable)
    _ = ∫ s,
          Real.exp (t * ((unsatCountPrefix τ (N + 1) : ℕ) : ℝ)) *
            Real.exp (t * unsatIndicator s) ∂clausePMF.toMeasure := by
            congr with s
            rw [unsatCountPrefix_snoc_last τ s]
            cases s <;>
              simp [unsatIndicator, Nat.cast_add, Real.exp_add, mul_add,
                add_comm, mul_comm]
    _ = Real.exp (t * ((unsatCountPrefix τ (N + 1) : ℕ) : ℝ)) *
          bernoulliUnsatMGF t := by
            rw [integral_const_mul]
            rw [oneStepUnsatIndicatorMGF_eq_bernoulliUnsatMGF]

/-- Terminal-step MGF recursion for the actual SAT path PMF. -/
theorem mgf_unsatCountRV_succ_last
    (N : ℕ) (t : ℝ) :
    mgf (unsatCountRV (N + 1) (N + 2)) (pathMeasure (N + 1)) t =
      mgf (unsatCountRV N (N + 1)) (pathMeasure N) t *
        bernoulliUnsatMGF t := by
  change
    ∫ τ', Real.exp (t * ((unsatCountPrefix τ' (N + 2) : ℕ) : ℝ))
      ∂(pathPMF (N + 1)).toMeasure =
      mgf (unsatCountRV N (N + 1)) (pathMeasure N) t *
        bernoulliUnsatMGF t
  rw [pathPMF_succ_eq]
  rw [integral_bind_eq_sum]
  simp_rw [innerTerminalMGF_eq]
  change
    ∑ τ : Trajectory N,
        (pathPMF N τ).toReal *
          (Real.exp (t * ((unsatCountPrefix τ (N + 1) : ℕ) : ℝ)) *
            bernoulliUnsatMGF t) =
      (∫ τ, Real.exp (t * ((unsatCountPrefix τ (N + 1) : ℕ) : ℝ))
        ∂(pathPMF N).toMeasure) *
        bernoulliUnsatMGF t
  rw [PMF.integral_eq_sum]
  change
    ∑ τ : Trajectory N,
        (pathPMF N τ).toReal *
          (Real.exp (t * ((unsatCountPrefix τ (N + 1) : ℕ) : ℝ)) *
            bernoulliUnsatMGF t) =
      (∑ τ : Trajectory N,
        (pathPMF N τ).toReal •
          Real.exp (t * ((unsatCountPrefix τ (N + 1) : ℕ) : ℝ))) *
        bernoulliUnsatMGF t
  have hleft :
      ∑ τ : Trajectory N,
          (pathPMF N τ).toReal *
            (Real.exp (t * ((unsatCountPrefix τ (N + 1) : ℕ) : ℝ)) *
              bernoulliUnsatMGF t)
        =
      (∑ τ : Trajectory N,
          (pathPMF N τ).toReal *
            Real.exp (t * ((unsatCountPrefix τ (N + 1) : ℕ) : ℝ))) *
        bernoulliUnsatMGF t := by
    rw [Finset.sum_mul]
    refine Finset.sum_congr rfl ?_
    intro τ _hτ
    ring
  rw [hleft]
  simp [smul_eq_mul]

/-- Exact Bernoulli-product MGF for the active-prefix unsatisfied count. -/
theorem mgf_unsatCountRV_eq_bernoulliUnsatMGF_pow
    (N : ℕ) (t : ℝ) :
    ∀ ⦃n : ℕ⦄, n ≤ N + 1 →
      mgf (unsatCountRV N n) (pathMeasure N) t =
        bernoulliUnsatMGF t ^ n := by
  induction N with
  | zero =>
      intro n hn
      interval_cases n
      · rw [pow_zero]
        rw [ProbabilityTheory.mgf]
        simp [unsatCountRV, unsatCountPrefix]
      · change
          ∫ τ, Real.exp (t * ((unsatCountPrefix τ 1 : ℕ) : ℝ))
            ∂(pathPMF 0).toMeasure =
            bernoulliUnsatMGF t ^ 1
        rw [pow_one]
        change
          ∫ τ, Real.exp (t * ((unsatCountPrefix τ 1 : ℕ) : ℝ))
            ∂(clausePMF.map singletonTraj).toMeasure =
            bernoulliUnsatMGF t
        rw [← PMF.toMeasure_map
          (p := clausePMF)
          (f := singletonTraj)
          (hf := (measurable_from_top : Measurable singletonTraj))]
        calc
          ∫ τ, Real.exp (t * ((unsatCountPrefix τ 1 : ℕ) : ℝ))
              ∂Measure.map singletonTraj clausePMF.toMeasure
              =
            ∫ s, Real.exp (t * ((unsatCountPrefix (singletonTraj s) 1 : ℕ) : ℝ))
              ∂clausePMF.toMeasure := by
              exact
                MeasureTheory.integral_map
                  (μ := clausePMF.toMeasure)
                  (φ := singletonTraj)
                  (measurable_from_top : Measurable singletonTraj).aemeasurable
                  ((measurable_from_top :
                    Measurable
                      (fun τ : Trajectory 0 =>
                        Real.exp (t * ((unsatCountPrefix τ 1 : ℕ) : ℝ)))).aestronglyMeasurable)
          _ = ∫ s, Real.exp (t * unsatIndicator s) ∂clausePMF.toMeasure := by
              congr with s
              cases s <;> simp [unsatIndicator, singletonTraj, unsatCountPrefix, outcomeAt]
          _ = bernoulliUnsatMGF t := oneStepUnsatIndicatorMGF_eq_bernoulliUnsatMGF t
  | succ N ih =>
      intro n hn
      by_cases hprefix : n ≤ N + 1
      · rw [mgf_unsatCountRV_succ_of_le hprefix t]
        exact ih hprefix
      · have hnlast : n = N + 2 := by
          exact Nat.le_antisymm hn (Nat.succ_le_of_lt (lt_of_not_ge hprefix))
        subst hnlast
        rw [mgf_unsatCountRV_succ_last N t]
        rw [ih (Nat.le_refl (N + 1))]
        simpa using (pow_succ (bernoulliUnsatMGF t) (N + 1)).symm

/-- The closed Bernoulli MGF witness is generated directly by the actual
clause-exposure path PMF. -/
theorem hasBernoulliMGFUpperBound_pathPMF
    (N : ℕ) (t : ℝ) :
    HasBernoulliMGFUpperBound N t := by
  intro n hn
  rw [mgf_unsatCountRV_eq_bernoulliUnsatMGF_pow N t hn]

end

end Survival.SATStateDependentCountMGFProduct
