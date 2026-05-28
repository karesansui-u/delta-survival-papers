import Survival.DualityTheorem
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Euler-Lagrange Bridge — Variational Principle for Structural Persistence

Reads the variational principle through structural persistence:
the "action" to be extremized is the cumulative structural
consumption L = Σ l_i. The Euler-Lagrange equation gives the
path of least structural consumption.

Key identification:
- Action S = ∫ L dt → cumulative consumption L = Σ l_i
- Lagrangian L(x,ẋ) → per-step consumption l_i
- Stationary action → minimum consumption path
- Hamilton's principle → duality theorem (min L = max S)
-/
namespace Survival.EulerLagrangeBridge
open Real
noncomputable section

/-- The "action" in structural persistence = cumulative consumption. -/
def structuralAction (l : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, l i

/-- Action is additive over intervals (like physical action). -/
theorem action_additive (l : ℕ → ℝ) (m n : ℕ) :
    structuralAction l (m + n) =
      structuralAction l m +
        ∑ i ∈ Finset.range n, l (m + i) := by
  unfold structuralAction
  rw [Finset.sum_range_add]

/-- The optimal path minimizes action (= minimizes consumption).
    By the duality theorem, this maximizes S = M exp(-L). -/
theorem optimal_path_duality (M : ℝ) (hM : 0 < M)
    (l₁ l₂ : ℕ → ℝ) (n : ℕ)
    (hmin : structuralAction l₁ n ≤ structuralAction l₂ n) :
    M * exp (-(structuralAction l₂ n)) ≤
      M * exp (-(structuralAction l₁ n)) :=
  Survival.DualityTheorem.persistence_antitone M hM hmin

/-- Zero consumption = stationary point (identity path). -/
theorem zero_action_stationary (l : ℕ → ℝ) (n : ℕ)
    (h : ∀ i, i < n → l i = 0) :
    structuralAction l n = 0 := by
  unfold structuralAction
  exact Finset.sum_eq_zero (fun i hi => h i (Finset.mem_range.mp hi))

end
end Survival.EulerLagrangeBridge
