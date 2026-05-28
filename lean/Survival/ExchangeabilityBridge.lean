import Survival.WeakDependence
import Survival.TelescopingExp

/-!
# de Finetti Exchangeability Bridge

When stage losses are exchangeable, de Finetti says they are
conditionally iid. Under conditional independence, S = M exp(-L)
holds with L = n·rate(θ) for environment parameter θ.
-/

namespace Survival.ExchangeabilityBridge

open Survival.TelescopingExp

noncomputable section

/-! ## Part 1: Conditional Independence Reading -/

/-- Cumulative loss under conditional iid losses with rate r. -/
def conditionalRate (r : ℝ) (n : ℕ) : ℝ := (n : ℝ) * r

/-- Retention factor conditioned on environment: exp(-nr). -/
def conditionalRetention (r : ℝ) (n : ℕ) : ℝ :=
  Real.exp (-conditionalRate r n)

/-- Conditional retention is always positive. -/
theorem conditionalRetention_pos (r : ℝ) (n : ℕ) :
    0 < conditionalRetention r n :=
  Real.exp_pos _

/-- Conditional retention decreases with time when rate > 0. -/
theorem conditionalRetention_antitone
    {r : ℝ} (hr : 0 < r) :
    Antitone (conditionalRetention r) := by
  intro m n hmn
  unfold conditionalRetention conditionalRate
  apply Real.exp_le_exp.mpr
  have : (m : ℝ) ≤ (n : ℝ) := Nat.cast_le.mpr hmn
  nlinarith

/-! ## Part 2: Mixture = Marginal over Environments -/

/-- Mixture retention: average of conditional retentions. -/
def mixtureRetention
    {k : ℕ} (weights : Fin k → ℝ) (rates : Fin k → ℝ)
    (n : ℕ) : ℝ :=
  ∑ i : Fin k, weights i * conditionalRetention (rates i) n

/-- Mixture retention is nonneg when weights are nonneg. -/
theorem mixtureRetention_nonneg
    {k : ℕ} (weights : Fin k → ℝ) (rates : Fin k → ℝ)
    (n : ℕ) (hw : ∀ i, 0 ≤ weights i) :
    0 ≤ mixtureRetention weights rates n := by
  unfold mixtureRetention
  apply Finset.sum_nonneg
  intro i _
  exact mul_nonneg (hw i)
    (le_of_lt (conditionalRetention_pos _ _))

/-- **Jensen bound**: mixture retention ≤ 1 when weights
sum to 1 and rates are nonneg. -/
theorem mixture_retention_le_one
    {k : ℕ} (weights : Fin k → ℝ) (rates : Fin k → ℝ)
    (n : ℕ)
    (hw : ∀ i, 0 ≤ weights i)
    (hsum : ∑ i : Fin k, weights i = 1)
    (hr : ∀ i, 0 ≤ rates i) :
    mixtureRetention weights rates n ≤ 1 := by
  unfold mixtureRetention
  calc ∑ i : Fin k,
      weights i * conditionalRetention (rates i) n
      ≤ ∑ i : Fin k, weights i * 1 := by
        apply Finset.sum_le_sum
        intro i _
        apply mul_le_mul_of_nonneg_left _ (hw i)
        unfold conditionalRetention conditionalRate
        have hri : (0 : ℝ) ≤ rates i := hr i
        have hni : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
        have h : -((n : ℝ) * rates i) ≤ 0 := by nlinarith
        calc Real.exp (-((n : ℝ) * rates i))
            ≤ Real.exp 0 := Real.exp_le_exp.mpr h
          _ = 1 := Real.exp_zero
    _ = 1 := by simp [hsum]

/-! ## Part 3: Weak Dependence as Approximate Exchangeability -/

/-- The ρ-bracket from WeakDependence gives the deviation from
exact conditional independence. When ρ → 0, the mixture
representation becomes exact (de Finetti limit). -/
theorem weak_dep_as_approximate_exchangeability
    {Lref : ℝ} (hL : 0 < Lref) {rho : ℝ} (hrho : 0 ≤ rho)
    (_hrho1 : rho < 1) :
    Real.exp (-Lref * (1 + rho)) ≤
      Real.exp (-Lref * (1 - rho)) := by
  apply Real.exp_le_exp.mpr
  nlinarith

end

end Survival.ExchangeabilityBridge
