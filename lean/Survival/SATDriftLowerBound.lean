import Mathlib.Tactic.Linarith
import Survival.SATFirstMoment

/-!
# SAT Drift Lower Bound

This module extracts the random-3-SAT first-moment information loss

  I_random = log (8 / 7)

as an explicit positive drift parameter.

The point is modest but important: the `drift` used by later collapse wrappers
is not an arbitrary externally supplied constant in the random 3-SAT case.
It is exactly the per-clause first-moment information loss already formalized in
`SATFirstMoment`.
-/

open scoped BigOperators
open Finset

namespace Survival.SATDriftLowerBound

open Survival.SATFirstMoment

noncomputable section

/-- The per-clause random-3-SAT drift parameter: the information loss of one
uniform random 3-clause. -/
noncomputable def random3ClauseDrift : ℝ :=
  infoLoss (7 / 8 : ℝ)

/-- The drift parameter is exactly `log (8 / 7)`. -/
theorem random3ClauseDrift_eq_log :
    random3ClauseDrift = Real.log (8 / 7 : ℝ) := by
  unfold random3ClauseDrift
  rw [info_loss_random_3clause]

/-- The random-3-SAT per-clause drift is strictly positive. -/
theorem random3ClauseDrift_pos :
    0 < random3ClauseDrift := by
  rw [random3ClauseDrift_eq_log]
  exact Real.log_pos (by norm_num)

/-- The random-3-SAT per-clause drift is nonnegative. -/
theorem random3ClauseDrift_nonneg :
    0 ≤ random3ClauseDrift := le_of_lt random3ClauseDrift_pos

/-- For `m` uniform random 3-clauses, cumulative information loss is exactly
linear with slope `random3ClauseDrift`. -/
theorem cumulativeInfoLoss_random3Clause
    (m : ℕ) :
    cumulativeInfoLoss (Finset.range m) (fun _ : ℕ => (7 / 8 : ℝ)) =
      (m : ℝ) * random3ClauseDrift := by
  unfold random3ClauseDrift
  simpa using
    (cumulative_uniform (s := Finset.range m) (p := (7 / 8 : ℝ))
      (f := fun _ : ℕ => (7 / 8 : ℝ))
      (hf := by intro _ hi; rfl))

/-- First-moment survival for `m` uniform random 3-clauses takes the exponential
form `exp (-(m * random3ClauseDrift))`. -/
theorem firstMoment_random3Clause_exp
    (m : ℕ) :
    ∏ _i ∈ Finset.range m, (7 / 8 : ℝ) =
      Real.exp (-((m : ℝ) * random3ClauseDrift)) := by
  have hfm :=
    first_moment_identity
      (s := Finset.range m)
      (p := fun _ : ℕ => (7 / 8 : ℝ))
      (hp := by
        intro i hi
        norm_num)
  rw [cumulativeInfoLoss_random3Clause] at hfm
  simpa using hfm

/-- The expected cumulative drift of `m` uniform random 3-clauses is bounded
below by the same linear term, trivially by exact equality. -/
theorem cumulativeDriftLowerBound_random3Clause
    (m : ℕ) :
    (m : ℝ) * random3ClauseDrift ≤
      cumulativeInfoLoss (Finset.range m) (fun _ : ℕ => (7 / 8 : ℝ)) := by
  rw [cumulativeInfoLoss_random3Clause]

end

end Survival.SATDriftLowerBound
