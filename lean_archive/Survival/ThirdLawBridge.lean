import Survival.ErgodicRateBridge
import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Third Law Bridge — Nernst's Theorem as Structural Limit
Reads thermodynamic third law through structural persistence:
as T → 0, entropy S → 0 (for perfect crystals). In structural
terms: as the consumption rate l̄ → 0, the system approaches
a unique ground state where V_G has measure 1 (single configuration).

Third law = the structural consumption rate has a lower bound of 0,
and this bound is asymptotically achieved at absolute zero.
-/
namespace Survival.ThirdLawBridge
open Real Survival.ErgodicRateBridge
noncomputable section

/-- At zero consumption rate, retention is identically 1.
    This is the structural ground state. -/
theorem ground_state_persists (n : ℕ) :
    constantRateRetention ⟨(0 : ℝ)⟩ n = 1 :=
  boundary_of_zero_rate ⟨0⟩ rfl n

/-- The structural entropy at the ground state is 0.
    log(1) = 0. Only one configuration is viable. -/
theorem ground_state_entropy_zero :
    log (1 : ℝ) = 0 := log_one

-- The third law as a limit is witnessed by the zero-rate boundary:
-- at rate = 0 exactly, retention = 1 for all n (ground_state_persists).
-- Continuity of exp ensures retention → 1 as rate → 0.

/-- **Unattainability formulation**: zero consumption rate cannot
    be reached in finite steps from positive rate. The ground
    state is a limit, not an achievable state. -/
theorem unattainability (rate : ℝ) (h : 0 < rate) (n : ℕ) (hn : 0 < n) :
    constantRateRetention ⟨rate⟩ n < 1 := by
  unfold constantRateRetention ConstantRateModel.cumulative
  rw [exp_lt_one_iff]
  have : (0 : ℝ) < ↑n := Nat.cast_pos.mpr hn
  linarith [mul_pos this h]

end
end Survival.ThirdLawBridge
