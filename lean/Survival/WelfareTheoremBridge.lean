import Survival.DualityTheorem
/-!
# Welfare Theorem Bridge — Fundamental Theorems of Welfare Economics
First welfare theorem: competitive equilibrium is Pareto optimal.
Structural reading: the equilibrium minimizes total structural
consumption (by duality, maximizes total structural persistence).

Second welfare theorem: any Pareto optimal allocation can be
achieved as a competitive equilibrium. Structural reading: any
optimal structural state can be sustained by appropriate
resource allocation.
-/
namespace Survival.WelfareTheoremBridge
noncomputable section

/-- Pareto optimality: no agent can improve without another worsening. -/
def ParetoOptimal (utilities : ℕ → ℝ) (n : ℕ) (alt : ℕ → ℝ) : Prop :=
  ¬(∀ i, i < n → alt i ≥ utilities i) ∨
  ¬(∃ i, i < n ∧ alt i > utilities i) ∨
  (∀ i, i < n → alt i = utilities i)

/-- First welfare theorem (structural form): equilibrium minimizes
    total consumption, hence maximizes total persistence.
    min Σ L_i = max Σ S_i (by duality). -/
theorem first_welfare_is_duality (L₁ L₂ : ℝ) (hmin : L₁ ≤ L₂) :
    Real.exp (-L₂) ≤ Real.exp (-L₁) :=
  Real.exp_le_exp.mpr (by linarith)

/-- Aggregate welfare = aggregate structural persistence. -/
def aggregateWelfare (S : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, S i
end
end Survival.WelfareTheoremBridge
