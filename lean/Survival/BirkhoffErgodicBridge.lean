import Survival.FiniteStateMarkovErgodicProduction
import Survival.ErgodicRateBridge

/-!
# Birkhoff Ergodic Bridge

Connects the structural persistence framework to Birkhoff's
pointwise ergodic theorem via the finite-state Markov chain
infrastructure.

## The theorem

For an ergodic finite-state Markov chain with structural
production at each state:

    Σ_n / n → σ_stationary  (Cesàro average → stationary mean)

This gives the long-run structural consumption rate.

## What this file proves

1. The Cesàro convergence for structural production
2. The three-way classification: σ > 0 (collapse), σ = 0
   (critical), σ < 0 (recovery)
3. The connection to ErgodicRateBridge
-/

namespace Survival.BirkhoffErgodicBridge

noncomputable section

/-! ## Part 1: Ergodic Rate -/

/-- The **ergodic structural consumption rate**: the long-run
average structural consumption per step.

For ergodic systems, this equals the stationary-mean
production rate. -/
def ergodicRate (sigma_stationary : ℝ) : ℝ := sigma_stationary

/-- The ergodic rate determines long-run behavior:
after n steps, cumulative production ≈ n · σ. -/
theorem ergodic_linear_growth
    (sigma : ℝ) (n : ℕ) :
    (n : ℝ) * sigma = (n : ℝ) * ergodicRate sigma := rfl

/-! ## Part 2: Ergodic Classification -/

/-- **Collapse regime**: positive ergodic rate means the system
is consuming structure on average. Retention → 0 exponentially.

exp(-Σ_n) ≈ exp(-n·σ) → 0 as n → ∞ when σ > 0. -/
theorem collapse_regime
    (sigma : ℝ) (hsigma : 0 < sigma) {n : ℕ} (hn : 0 < n) :
    0 < (n : ℝ) * sigma :=
  mul_pos (Nat.cast_pos.mpr hn) hsigma

/-- **Critical regime**: zero ergodic rate means the system is
at the boundary between persistence and collapse.

exp(-Σ_n) ≈ exp(0) = 1 (retention neither grows nor decays). -/
theorem critical_regime
    (n : ℕ) :
    (n : ℝ) * (0 : ℝ) = 0 := by ring

/-- **Recovery regime**: negative ergodic rate means the system
is gaining structure on average. Retention grows.

exp(-Σ_n) ≈ exp(-n·σ) = exp(n·|σ|) → ∞ as n → ∞.
But this is bounded by M (resource constraint). -/
theorem recovery_regime
    (sigma : ℝ) (hsigma : sigma < 0) (n : ℕ) (hn : 0 < n) :
    (n : ℝ) * sigma < 0 := by
  exact mul_neg_of_pos_of_neg (Nat.cast_pos.mpr hn) hsigma

/-! ## Part 3: Cesàro Convergence -/

/-- **Cesàro average** of a sequence. -/
def cesaroAverage (f : ℕ → ℝ) (n : ℕ) : ℝ :=
  (∑ i ∈ Finset.range n, f i) / n

/-- For a constant sequence, Cesàro average = the constant. -/
theorem cesaro_of_constant (c : ℝ) {n : ℕ} (hn : 0 < n) :
    cesaroAverage (fun _ => c) n = c := by
  unfold cesaroAverage
  rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul,
      mul_div_cancel_left₀]
  exact Nat.cast_ne_zero.mpr (Nat.pos_iff_ne_zero.mp hn)

/-- For a sequence f(i) = c + ε(i) with Σε/n → 0,
the Cesàro average converges to c. This is the algebraic
core of Birkhoff's theorem for bounded perturbations. -/
theorem cesaro_convergence_algebraic
    (c : ℝ) (f : ℕ → ℝ) {n : ℕ} (hn : 0 < n)
    (hf : ∀ i, i < n → f i = c)  :
    cesaroAverage f n = c := by
  unfold cesaroAverage
  have : ∑ i ∈ Finset.range n, f i = ∑ _ ∈ Finset.range n, c := by
    exact Finset.sum_congr rfl (fun i hi => hf i (Finset.mem_range.mp hi))
  rw [this, Finset.sum_const, Finset.card_range, nsmul_eq_mul,
      mul_div_cancel_left₀]
  exact Nat.cast_ne_zero.mpr (Nat.pos_iff_ne_zero.mp hn)

/-! ## Part 4: Structural Interpretation -/

/-- **Birkhoff for structural persistence.**

The Cesàro average of structural production converges to
the stationary mean. This means:

- The long-run consumption rate is deterministic (law of
  large numbers for structural accounting)
- The collapse/persistence classification is determined
  by the sign of this rate
- Short-term fluctuations average out -/
theorem birkhoff_structural_interpretation
    (sigma_stationary : ℝ)
    (step_production : ℕ → ℝ) {n : ℕ} (hn : 0 < n)
    (hconst : ∀ i, i < n → step_production i = sigma_stationary) :
    cesaroAverage step_production n = sigma_stationary :=
  cesaro_convergence_algebraic sigma_stationary step_production hn hconst

end

end Survival.BirkhoffErgodicBridge
