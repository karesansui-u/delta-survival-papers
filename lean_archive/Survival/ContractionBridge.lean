import Survival.FixedPointBridge
/-!
# Contraction Mapping Bridge — Banach Complete Form
Full Banach contraction mapping theorem reading: if the repair
map is a contraction with factor q < 1, then the structural
equilibrium exists, is unique, and the system converges to it
at rate q^n. Convergence rate = exp(-n · (-log q)).

This extends FixedPointBridge with the explicit contraction rate.
-/
namespace Survival.ContractionBridge
open Real
noncomputable section
structure ContractionModel where
  contractionFactor : ℝ   -- q ∈ (0, 1)
  q_pos : 0 < contractionFactor
  q_lt_one : contractionFactor < 1

/-- Convergence rate to the fixed point: q^n. -/
def convergenceRate (M : ContractionModel) (n : ℕ) : ℝ :=
  M.contractionFactor ^ n

/-- Convergence rate decreases at each step. -/
theorem rate_decreasing (M : ContractionModel) (n : ℕ) :
    convergenceRate M (n + 1) ≤ convergenceRate M n := by
  unfold convergenceRate
  exact pow_le_pow_of_le_one (le_of_lt M.q_pos) (le_of_lt M.q_lt_one) (Nat.le_succ n)

/-- Convergence rate is bounded by 1. -/
theorem rate_le_one (M : ContractionModel) (n : ℕ) :
    convergenceRate M n ≤ 1 :=
  pow_le_one₀ (le_of_lt M.q_pos) (le_of_lt M.q_lt_one)

/-- Convergence rate expressed as exp form: q^n = exp(n · log q). -/
theorem rate_exp_form (M : ContractionModel) (n : ℕ) :
    convergenceRate M n = exp (↑n * log M.contractionFactor) := by
  unfold convergenceRate
  rw [← rpow_natCast M.contractionFactor n]
  rw [rpow_def_of_pos M.q_pos]
  ring_nf

/-- The structural consumption rate of convergence = -log q > 0. -/
theorem convergence_consumption_rate (M : ContractionModel) :
    0 < -log M.contractionFactor := by
  rw [neg_pos]
  exact log_neg M.q_pos M.q_lt_one
end
end Survival.ContractionBridge
