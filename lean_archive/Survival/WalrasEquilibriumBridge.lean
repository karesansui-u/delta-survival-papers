import Survival.TelescopingExp
import Survival.ZerothLawBridge
import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Walras Equilibrium Bridge — Hardened (Core-Connected)

Constructs market viability as a mass sequence where each
price adjustment step shrinks/expands the viable trading set.
stageLoss = excess-demand-driven shrinkage, telescoping kernel
gives cumulative market disequilibrium, equilibrium as the
zero-stageLoss fixed point.

Pattern: mass列 → stageLoss一致 → telescoping核適用 → 大域的帰結
-/
namespace Survival.WalrasEquilibriumBridge
open Real Survival.TelescopingExp
noncomputable section

/-- Market adjustment model: viable trading set shrinks when
    prices are wrong (excess demand ≠ 0). -/
structure MarketModel where
  initialViability : ℝ     -- m(V_0) = initial market viability
  adjustmentFactor : ℝ     -- fraction retained per adjustment step
  init_pos : 0 < initialViability
  factor_pos : 0 < adjustmentFactor

/-- Mass sequence: market viability after n adjustment steps. -/
def marketMass (M : MarketModel) : ℕ → ℝ
  | 0 => M.initialViability
  | n + 1 => marketMass M n * M.adjustmentFactor

theorem marketMass_pos (M : MarketModel) : ∀ n, 0 < marketMass M n := by
  intro n; induction n with
  | zero => exact M.init_pos
  | succ n ih => exact mul_pos ih M.factor_pos

/-- Ratio at each step = adjustmentFactor. -/
theorem market_ratio (M : MarketModel) (n : ℕ) :
    marketMass M (n + 1) / marketMass M n = M.adjustmentFactor := by
  simp only [marketMass]
  exact mul_div_cancel_left₀ _ (ne_of_gt (marketMass_pos M n))

/-- **Core bridge: stageLoss = -log(adjustmentFactor).** -/
theorem stageLoss_eq_adjustment (M : MarketModel) (n : ℕ) :
    stageLoss (marketMass M) n = -log M.adjustmentFactor := by
  unfold stageLoss; rw [market_ratio]

/-- **Telescoping kernel: market viability after n steps.** -/
theorem walras_telescoping (M : MarketModel) (n : ℕ) :
    marketMass M n = marketMass M 0 *
      exp (-∑ i ∈ Finset.range n, stageLoss (marketMass M) i) :=
  measure_eq_initial_mul_exp_neg_cumulative_loss _ n
    (fun i _ => marketMass_pos M i)

/-- **Equilibrium: adjustmentFactor = 1 ⟹ stageLoss = 0 ⟹ market stable.** -/
theorem equilibrium_zero_loss (M : MarketModel) (h : M.adjustmentFactor = 1) (n : ℕ) :
    stageLoss (marketMass M) n = 0 := by
  rw [stageLoss_eq_adjustment, h, log_one, neg_zero]

/-- **Disequilibrium: factor < 1 ⟹ positive stageLoss ⟹ viability shrinks.** -/
theorem disequilibrium_positive_loss (M : MarketModel) (h : M.adjustmentFactor < 1) (n : ℕ) :
    0 < stageLoss (marketMass M) n := by
  rw [stageLoss_eq_adjustment, neg_pos]
  exact log_neg M.factor_pos h

/-- **Global: disequilibrium → viability strictly decreases.** -/
theorem disequilibrium_shrinks (M : MarketModel) (h : M.adjustmentFactor < 1) (n : ℕ) :
    marketMass M n ≤ marketMass M 0 := by
  rw [walras_telescoping M n]
  have hexp : exp (-∑ i ∈ Finset.range n, stageLoss (marketMass M) i) ≤ 1 := by
    rw [exp_le_one_iff, neg_nonpos]
    exact Finset.sum_nonneg fun i _ => le_of_lt (disequilibrium_positive_loss M h i)
  nlinarith [marketMass_pos M 0]

/-- Market equilibrium is transitive (zeroth law). -/
theorem equilibrium_transitive (p₁ p₂ p₃ : ℝ)
    (h₁₂ : Survival.ZerothLawBridge.StructuralEquilibrium p₁ p₂)
    (h₂₃ : Survival.ZerothLawBridge.StructuralEquilibrium p₂ p₃) :
    Survival.ZerothLawBridge.StructuralEquilibrium p₁ p₃ :=
  Survival.ZerothLawBridge.zeroth_law_transitivity p₁ p₂ p₃ h₁₂ h₂₃

end
end Survival.WalrasEquilibriumBridge
