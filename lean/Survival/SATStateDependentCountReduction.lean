import Mathlib.Tactic.Ring
import Survival.SATStateDependentExactConcentration

/-!
# SAT State-Dependent Count Reduction

This module rewrites the exact lower-tail event of the non-flat SAT
clause-exposure process in terms of a simple unsatisfied-clause count on the
active prefix.

For the concrete emission

* `sat ↦ 0`
* `unsat ↦ 8 * log (8 / 7)`

the cumulative total production on the active prefix is pathwise

`s₀ + (#unsat up to time n) * 8 * log (8 / 7)`.

Hence the exact lower-tail event, and therefore the exact failure profile,
depends only on the prefix unsatisfied-clause count. This isolates the remaining
analytic task as a tail bound for that count process.
-/

namespace Survival.SATStateDependentCountReduction

open MeasureTheory
open Survival.SATClauseExposureProcess
open Survival.SATDriftLowerBound
open Survival.SATStateDependentClauseExposure
open Survival.SATStateDependentExactConcentration
open Survival.StochasticTotalProduction

noncomputable section

/-- Recursive count of unsatisfied clauses on the first `n` exposed clauses of
an actual SAT clause-exposure path. -/
def unsatCountPrefix {N : ℕ} (τ : Trajectory N) : ℕ → ℕ
  | 0 => 0
  | n + 1 => unsatCountPrefix τ n + if outcomeAt τ n = ClauseOutcome.unsat then 1 else 0

/-- On the active prefix, cumulative total production is exactly the initial
value plus the unsatisfied-clause count times `8 * log (8 / 7)`. -/
  theorem cumulativeTotalProductionRV_eq_initial_add_unsatCount
    (N : ℕ) (s₀ : ℝ) (τ : Trajectory N) :
    ∀ {n : ℕ}, n ≤ N + 1 →
      cumulativeTotalProductionRV
          (stepModel N s₀ oneSidedUnsatEmission) n τ =
        s₀ + (unsatCountPrefix τ n : ℝ) * (8 * random3ClauseDrift)
  | 0, _ => by
      simp [cumulativeTotalProductionRV, SATStateDependentClauseExposure.stepModel, unsatCountPrefix]
  | n + 1, hn => by
      have hprefix : n ≤ N + 1 := Nat.le_trans (Nat.le_succ n) hn
      simp [cumulativeTotalProductionRV]
      rw [cumulativeTotalProductionRV_eq_initial_add_unsatCount N s₀ τ hprefix]
      rw [stepTotalProductionRV_eq_totalOf N s₀ oneSidedUnsatEmission n]
      cases hout : outcomeAt τ n with
      | sat =>
          simp [unsatCountPrefix, oneSidedUnsatEmission, hout]
      | unsat =>
          simp [unsatCountPrefix, oneSidedUnsatEmission, hout]
          ring

/-- Count-based reformulation of the exact lower-tail event on the active
prefix. -/
def exactCountLowerTailEvent
    (N : ℕ) (n : ℕ) (r : ℝ) : Set (Trajectory N) :=
  {τ |
    (n : ℝ) * random3ClauseDrift - r ≤
      (unsatCountPrefix τ n : ℝ) * (8 * random3ClauseDrift)}

/-- On the active prefix, the exact lower-tail event depends only on the
unsatisfied-clause count. -/
theorem exactLowerTailEvent_eq_exactCountLowerTailEvent
    (N : ℕ) (s₀ : ℝ) {n : ℕ} (hn : n ≤ N + 1) (r : ℝ) :
    exactLowerTailEvent N s₀ n r = exactCountLowerTailEvent N n r := by
  ext τ
  constructor <;> intro hτ
  · change
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative n - r ≤
        cumulativeTotalProductionRV (stepModel N s₀ oneSidedUnsatEmission) n τ at hτ
    rw [expectedCumulative_eq_initial_add_linear_of_le N s₀ hn] at hτ
    rw [cumulativeTotalProductionRV_eq_initial_add_unsatCount N s₀ τ hn] at hτ
    change
      (n : ℝ) * random3ClauseDrift - r ≤
        (unsatCountPrefix τ n : ℝ) * (8 * random3ClauseDrift)
    linarith
  · change
      (stepModel N s₀ oneSidedUnsatEmission).toStochasticProcess.toExpectedProcess.expectedCumulative n - r ≤
        cumulativeTotalProductionRV (stepModel N s₀ oneSidedUnsatEmission) n τ
    rw [expectedCumulative_eq_initial_add_linear_of_le N s₀ hn]
    rw [cumulativeTotalProductionRV_eq_initial_add_unsatCount N s₀ τ hn]
    change
      (n : ℝ) * random3ClauseDrift - r ≤
        (unsatCountPrefix τ n : ℝ) * (8 * random3ClauseDrift) at hτ
    linarith

/-- Exact failure profile written purely in terms of the prefix
unsatisfied-clause count. -/
def exactCountFailureBound
    (N : ℕ) (n : ℕ) (r : ℝ) : ENNReal :=
  pathMeasure N ((exactCountLowerTailEvent N n r)ᶜ)

/-- Therefore the exact SAT lower-tail failure profile on the active prefix is
completely determined by the unsatisfied-clause count event. -/
theorem exactFailureBound_eq_exactCountFailureBound
    (N : ℕ) (s₀ : ℝ) {n : ℕ} (hn : n ≤ N + 1) (r : ℝ) :
    exactFailureBound N s₀ n r = exactCountFailureBound N n r := by
  unfold exactFailureBound exactCountFailureBound
  rw [exactLowerTailEvent_eq_exactCountLowerTailEvent N s₀ hn r]

/-- On the active prefix, the exact lower-tail failure profile is independent of
the initial offset `s₀`. -/
theorem exactFailureBound_eq_of_activePrefix
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ s₀' r : ℝ} :
    exactFailureBound N s₀ n r = exactFailureBound N s₀' n r := by
  rw [exactFailureBound_eq_exactCountFailureBound N s₀ hn r]
  rw [exactFailureBound_eq_exactCountFailureBound N s₀' hn r]

end

end Survival.SATStateDependentCountReduction
