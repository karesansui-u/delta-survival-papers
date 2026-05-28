import Survival.ErgodicRateBridge

/-!
# Lyapunov Exponent Bridge — Chaos Theory Connection

This module provides the G6-b/c correspondence between the maximal
Lyapunov exponent and the structural-persistence consumption rate.

## Mathematical context

The maximal Lyapunov exponent λ of a dynamical system measures the
exponential rate of divergence of nearby trajectories:

    λ = lim_{n→∞} (1/n) ln ‖Df^n(x₀)‖

## Structural-persistence reading

We identify:
- **Lyapunov exponent λ** ≡ stationary structural consumption rate l̄
- **λ > 0** (chaos) ≡ structural collapse (exponential loss of
  viable states)
- **λ < 0** (stability) ≡ structural persistence (exponential
  contraction toward viable set)
- **λ = 0** (marginality) ≡ boundary regime

The connection is exact for linear maps and approximate for
nonlinear systems via the Oseledets multiplicative ergodic theorem.

References:
  - Oseledets, V.I. (1968). "A multiplicative ergodic theorem."
  - Eckmann, J.-P. & Ruelle, D. (1985). "Ergodic theory of chaos."
  - ErgodicRateBridge.lean: ergodic trichotomy
-/

namespace Survival.LyapunovExponentBridge

open Real
open Survival.ErgodicRateBridge

noncomputable section

/-! ## Part 1: Lyapunov Exponent as Consumption Rate -/

/-- A Lyapunov exponent model: the structural consumption rate
    equals the Lyapunov exponent of the underlying dynamics.

    For a linear map with expansion/contraction factor σ,
    λ = ln(σ) and L_n = n · ln(σ).
    The retention factor is exp(-L_n) = σ^{-n}. -/
structure LyapunovModel where
  /-- The Lyapunov exponent (= structural consumption rate) -/
  exponent : ℝ

/-- Convert a Lyapunov model to a constant-rate consumption model. -/
def toConstantRate (M : LyapunovModel) : ConstantRateModel where
  rate := M.exponent

/-- Cumulative structural consumption = n · λ. -/
def cumulativeConsumption (M : LyapunovModel) (n : ℕ) : ℝ :=
  (toConstantRate M).cumulative n

/-- The structural retention factor exp(-n·λ). -/
def retentionFactor (M : LyapunovModel) (n : ℕ) : ℝ :=
  constantRateRetention (toConstantRate M) n

/-! ## Part 2: Chaos–Stability Dichotomy -/

/-- **Chaotic regime (λ > 0)**: Positive Lyapunov exponent implies
    exponential structural collapse.

    Nearby trajectories diverge ⟺ viable states are exponentially lost. -/
theorem chaos_implies_collapse (M : LyapunovModel) (hchaos : 0 < M.exponent) :
    Filter.Tendsto (fun n => retentionFactor M n) Filter.atTop (nhds 0) :=
  collapse_of_positive_rate (toConstantRate M) hchaos

/-- **Stable regime (λ < 0)**: Negative Lyapunov exponent implies
    structural persistence with growing retention.

    Nearby trajectories converge ⟺ system contracts toward viable set. -/
theorem stability_implies_persistence (M : LyapunovModel)
    (hstable : M.exponent < 0) (n : ℕ) :
    1 ≤ retentionFactor M n :=
  persistence_of_nonpositive_rate (toConstantRate M) (le_of_lt hstable) n

/-- **Marginal regime (λ = 0)**: Zero Lyapunov exponent means
    retention is identically 1 (edge of chaos). -/
theorem marginal_retains (M : LyapunovModel)
    (hmarginal : M.exponent = 0) (n : ℕ) :
    retentionFactor M n = 1 :=
  boundary_of_zero_rate (toConstantRate M) hmarginal n

/-- The complete Lyapunov trichotomy. -/
theorem lyapunov_trichotomy (M : LyapunovModel) :
    (0 < M.exponent → Filter.Tendsto (fun n => retentionFactor M n)
        Filter.atTop (nhds 0)) ∧
    (M.exponent = 0 → ∀ n, retentionFactor M n = 1) ∧
    (M.exponent < 0 → ∀ n, 1 ≤ retentionFactor M n) :=
  ⟨chaos_implies_collapse M, marginal_retains M, stability_implies_persistence M⟩

/-! ## Part 3: Linear Map Example -/

/-- For a linear map x ↦ σx with |σ| > 1, the Lyapunov exponent
    is λ = ln|σ| > 0 (chaotic/expanding). -/
theorem linear_expanding_exponent (σ : ℝ) (hσ : 1 < σ) :
    0 < log σ := by
  exact log_pos hσ

/-- For a linear map x ↦ σx with 0 < |σ| < 1, the Lyapunov exponent
    is λ = ln|σ| < 0 (stable/contracting). -/
theorem linear_contracting_exponent (σ : ℝ) (hσ_pos : 0 < σ) (hσ_lt : σ < 1) :
    log σ < 0 := by
  exact log_neg hσ_pos hσ_lt

end

end Survival.LyapunovExponentBridge
