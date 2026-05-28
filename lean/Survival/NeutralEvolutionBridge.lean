import Survival.WrightFisherBridge
import Survival.ErgodicRateBridge
/-!
# Neutral Evolution Bridge — Kimura's Neutral Theory
Kimura's neutral theory: most evolutionary change is due to
genetic drift (random), not selection. Structural reading:
when the consumption rate l̄ ≈ 0 (neutral mutations don't
affect fitness), structural change is a random walk with
zero drift. The structure changes but persistence is not affected.
-/
namespace Survival.NeutralEvolutionBridge
open Survival.ErgodicRateBridge
noncomputable section

/-- Neutral evolution: consumption rate is exactly zero.
    Structure changes but persistence is unaffected. -/
theorem neutral_persists (n : ℕ) :
    constantRateRetention ⟨(0 : ℝ)⟩ n = 1 :=
  boundary_of_zero_rate ⟨0⟩ rfl n

/-- Nearly neutral: consumption rate ≈ 0 but not exactly.
    Very slow collapse or persistence depending on sign. -/
theorem nearly_neutral_slow (rate : ℝ) (h : 0 < rate) (n : ℕ) (hn : 0 < n) :
    0 < constantRateRetention ⟨rate⟩ n ∧
    constantRateRetention ⟨rate⟩ n < 1 := by
  constructor
  · unfold constantRateRetention ConstantRateModel.cumulative; exact Real.exp_pos _
  · unfold constantRateRetention ConstantRateModel.cumulative
    rw [Real.exp_lt_one_iff]
    have : (0 : ℝ) < ↑n := Nat.cast_pos.mpr hn
    linarith [mul_pos this h]
end
end Survival.NeutralEvolutionBridge
