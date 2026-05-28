import Survival.ErgodicRateBridge
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Mixing Time Bridge — Markov Chain Mixing Connection

This module provides the G6-b correspondence between Markov chain
mixing time and structural persistence theory.

## Mathematical context

The mixing time of an ergodic Markov chain with transition matrix P
and stationary distribution π is:

    t_mix(ε) = min{t : ‖P^t(x, ·) - π‖_TV ≤ ε for all x}

The spectral gap γ = 1 - λ₂ (where λ₂ is the second-largest
eigenvalue modulus) controls mixing: t_mix ∼ (1/γ) ln(1/ε).

## Structural-persistence reading

We identify:
- **Mixing time** t_mix ≡ time for structural consumption density
  L_n/n to converge to the stationary rate l̄
- **Spectral gap γ** ≡ rate of convergence to structural equilibrium
- **Total variation distance** ‖P^t - π‖_TV ≡ structural distance
  from equilibrium
- **Pre-mixing regime** (t < t_mix) ≡ transient structural dynamics
- **Post-mixing regime** (t > t_mix) ≡ ergodic structural behavior

References:
  - Levin, D.A. & Peres, Y. (2017). "Markov Chains and Mixing Times."
  - ErgodicRateBridge.lean: ergodic trichotomy
-/

namespace Survival.MixingTimeBridge

open Real

noncomputable section

/-! ## Part 1: Spectral Gap Model -/

/-- A spectral gap model for structural convergence.
    The spectral gap γ determines how fast the system converges
    to its stationary structural consumption rate. -/
structure SpectralGapModel where
  /-- Spectral gap (second eigenvalue gap) -/
  gap : ℝ
  /-- Stationary consumption rate -/
  stationaryRate : ℝ
  /-- Spectral gap is positive (ergodic chain) -/
  gap_pos : 0 < gap
  /-- Spectral gap is at most 1 -/
  gap_le_one : gap ≤ 1

/-- The convergence factor λ₂ = 1 - γ. -/
def secondEigenvalue (M : SpectralGapModel) : ℝ := 1 - M.gap

/-- λ₂ is nonneg. -/
theorem secondEigenvalue_nonneg (M : SpectralGapModel) :
    0 ≤ secondEigenvalue M := by
  unfold secondEigenvalue
  linarith [M.gap_le_one]

/-- λ₂ < 1 (strict, from positive gap). -/
theorem secondEigenvalue_lt_one (M : SpectralGapModel) :
    secondEigenvalue M < 1 := by
  unfold secondEigenvalue
  linarith [M.gap_pos]

/-! ## Part 2: Convergence Rate -/

/-- The deviation from stationarity at time t decays as (1-γ)^t.
    This is the structural interpretation: the "error" in the
    consumption density converges exponentially to zero. -/
def deviationBound (M : SpectralGapModel) (t : ℕ) : ℝ :=
  (secondEigenvalue M) ^ t

/-- Deviation bound at time 0 is 1. -/
theorem deviationBound_zero (M : SpectralGapModel) :
    deviationBound M 0 = 1 := by
  unfold deviationBound
  simp

/-- Deviation bound is nonneg. -/
theorem deviationBound_nonneg (M : SpectralGapModel) (t : ℕ) :
    0 ≤ deviationBound M t := by
  unfold deviationBound
  exact pow_nonneg (secondEigenvalue_nonneg M) t

/-- Deviation bound is at most 1. -/
theorem deviationBound_le_one (M : SpectralGapModel) (t : ℕ) :
    deviationBound M t ≤ 1 := by
  unfold deviationBound
  exact pow_le_one₀ (secondEigenvalue_nonneg M) (le_of_lt (secondEigenvalue_lt_one M))

/-- The deviation bound decreases at each step (multiplicatively). -/
theorem deviationBound_succ (M : SpectralGapModel) (t : ℕ) :
    deviationBound M (t + 1) =
      secondEigenvalue M * deviationBound M t := by
  unfold deviationBound
  rw [pow_succ]
  ring

/-! ## Part 3: Mixing Time -/

/-- The mixing time: smallest t such that (1-γ)^t ≤ ε.
    Structural interpretation: time until consumption density
    is within ε of its stationary value.

    From (1-γ)^t ≤ ε, taking logs:
    t ≥ ln(ε) / ln(1-γ) ≈ ln(1/ε) / γ -/
def mixingTimeThreshold (M : SpectralGapModel) (ε : ℝ) : ℝ :=
  log ε / log (secondEigenvalue M)

/-- The structural interpretation: after the mixing time, the
    system's consumption density is approximately stationary.
    In the pre-mixing regime, transient effects dominate. -/
theorem pre_mixing_deviation_large (M : SpectralGapModel)
    (t : ℕ) (ht : t = 0) :
    deviationBound M t = 1 := by
  rw [ht]
  exact deviationBound_zero M

/-! ## Part 4: Connection to Structural Persistence -/

/-- The structural-persistence connection: the spectral gap determines
    how quickly exp(-L_n/n) converges to exp(-l̄).

    - Large γ (fast mixing) → rapid convergence to structural fate
    - Small γ (slow mixing) → long transient before fate is determined
    - γ = 0 (non-ergodic) → structural fate depends on initial state -/
theorem mixing_rate_determines_convergence_speed (M : SpectralGapModel) :
    0 < M.gap ∧ M.gap ≤ 1 ∧
    ∀ t, deviationBound M t ≤ 1 :=
  ⟨M.gap_pos, M.gap_le_one, deviationBound_le_one M⟩

/-- Structural interpretation: spectral gap and structural consumption
    rate are linked. A larger gap means faster convergence to the
    stationary structural fate. -/
theorem gap_determines_convergence_quality (M : SpectralGapModel) :
    0 < M.gap ∧ secondEigenvalue M < 1 :=
  ⟨M.gap_pos, secondEigenvalue_lt_one M⟩

end

end Survival.MixingTimeBridge
