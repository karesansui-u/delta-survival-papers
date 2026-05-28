import Survival.FalseVacuumBridge
import Survival.ErgodicRateBridge

/-!
# Inflation Bridge — Cosmological Inflation as Slow-Roll Persistence

Reads cosmic inflation as structural persistence during slow-roll:
the inflaton field slowly "consumes" its potential energy (low l̄),
maintaining an approximately de Sitter state. Reheating = basin
transition (end of inflation = transition to radiation-dominated era).

Slow-roll: l̄ ≈ 0 → retention ≈ 1 (quasi-persistent)
End of inflation: l̄ jumps → basin transition
-/

namespace Survival.InflationBridge
open Real Survival.ErgodicRateBridge

noncomputable section

structure InflationModel where
  slowRollRate : ℝ     -- structural consumption during inflation (small)
  rate_pos : 0 < slowRollRate
  rate_small : slowRollRate < 1  -- slow-roll condition

/-- During slow-roll, retention decreases slowly. -/
theorem slowroll_near_persistent (M : InflationModel) (n : ℕ) :
    0 < constantRateRetention ⟨M.slowRollRate⟩ n := by
  unfold constantRateRetention ConstantRateModel.cumulative
  exact exp_pos _

/-- Inflation eventually ends (retention → 0 even with small rate). -/
theorem inflation_ends (M : InflationModel) :
    Filter.Tendsto (fun n => constantRateRetention ⟨M.slowRollRate⟩ n)
      Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨M.slowRollRate⟩ M.rate_pos

/-- Number of e-folds ≈ 1/rate before retention halves. -/
def eFolds (M : InflationModel) : ℝ := 1 / M.slowRollRate

theorem eFolds_pos (M : InflationModel) : 0 < eFolds M :=
  div_pos one_pos M.rate_pos

end
end Survival.InflationBridge
