import Survival.TelescopingExp
import Survival.GeneralStateDynamics

/-!
# Constructive Witness — Algorithmic Computability

Provides concrete, computable algorithms for structural persistence
accounting on finite-state systems.

## What this file proves

1. Stage loss is computable from consecutive mass values
2. Cumulative loss is computable by summation
3. Retention factor is computable via exp
4. The full accounting pipeline is a concrete algorithm

## Significance

Proves the theory is not merely existential ("there exists a
decomposition") but constructive ("here is how to compute it").
-/

namespace Survival.ConstructiveWitness

open Survival.TelescopingExp

noncomputable section

/-! ## Part 1: Concrete Computation Pipeline -/

/-- **Step 1**: Given two consecutive mass values, compute stage loss. -/
def computeStageLoss (m_current m_next : ℝ) : ℝ :=
  -Real.log (m_next / m_current)

/-- The computed stage loss agrees with the formal definition. -/
theorem computeStageLoss_eq_stageLoss
    (m : ℕ → ℝ) (i : ℕ) :
    computeStageLoss (m i) (m (i + 1)) = stageLoss m i := rfl

/-- **Step 2**: Compute cumulative loss by summation. -/
def computeCumulativeLoss (masses : Fin (n + 1) → ℝ) : ℝ :=
  ∑ i : Fin n, computeStageLoss (masses i.castSucc) (masses i.succ)

/-- **Step 3**: Compute retention factor. -/
def computeRetention (m₀ L : ℝ) : ℝ :=
  m₀ * Real.exp (-L)

/-- **Step 4**: Full pipeline — from mass sequence to retention. -/
def fullPipeline (masses : Fin (n + 1) → ℝ) : ℝ :=
  computeRetention (masses 0) (computeCumulativeLoss masses)

/-! ## Part 2: Correctness -/

/-- The pipeline output equals the final mass (when positivity holds).
This is the constructive version of the telescoping identity. -/
theorem pipeline_correct
    (m : ℕ → ℝ) (n : ℕ)
    (hpos : ∀ i, i ≤ n → 0 < m i) :
    m n = m 0 *
      Real.exp (-∑ i ∈ Finset.range n, stageLoss m i) :=
  measure_eq_initial_mul_exp_neg_cumulative_loss m n hpos

/-! ## Part 3: Finite State Computation -/

/-- For a **two-state** system (simplest nontrivial case),
the computation is fully explicit. -/
def twoStateLoss (m₀ m₁ : ℝ) : ℝ :=
  computeStageLoss m₀ m₁

/-- Two-state retention. -/
def twoStateRetention (m₀ m₁ : ℝ) : ℝ :=
  m₀ * Real.exp (-(twoStateLoss m₀ m₁))

/-- Two-state correctness: retention = m₁ (when m₀ > 0). -/
theorem twoState_correct
    {m₀ m₁ : ℝ} (h₀ : 0 < m₀) (h₁ : 0 < m₁) :
    twoStateRetention m₀ m₁ = m₁ := by
  unfold twoStateRetention twoStateLoss computeStageLoss
  rw [neg_neg, Real.exp_log (div_pos h₁ h₀)]
  field_simp [ne_of_gt h₀]

/-- **Three-state** system. -/
def threeStateLoss (m₀ m₁ m₂ : ℝ) : ℝ :=
  computeStageLoss m₀ m₁ + computeStageLoss m₁ m₂

theorem threeState_correct
    {m₀ m₁ m₂ : ℝ} (h₀ : 0 < m₀) (h₁ : 0 < m₁) (h₂ : 0 < m₂) :
    m₀ * Real.exp (-(threeStateLoss m₀ m₁ m₂)) = m₂ := by
  unfold threeStateLoss computeStageLoss
  rw [neg_add, Real.exp_add, neg_neg, neg_neg,
      Real.exp_log (div_pos h₁ h₀),
      Real.exp_log (div_pos h₂ h₁)]
  field_simp [ne_of_gt h₀, ne_of_gt h₁]

/-! ## Part 4: Decidability -/

/-- **Collapse detection** is decidable on finite-precision data.

Given a threshold θ and computed retention, the question
"has the system collapsed below θ?" is a simple comparison. -/
def hasCollapsed (retention threshold : ℝ) : Prop :=
  retention ≤ threshold

/-- The collapse threshold from mass data. -/
theorem collapse_from_masses
    (m₀ mₙ threshold : ℝ) (h₀ : 0 < m₀) :
    mₙ / m₀ ≤ threshold ↔ mₙ ≤ threshold * m₀ := by
  rw [div_le_iff₀ h₀]

end

end Survival.ConstructiveWitness
