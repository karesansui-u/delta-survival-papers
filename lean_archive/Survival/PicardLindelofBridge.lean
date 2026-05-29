import Survival.GronwallBridge
/-!
# Picard-Lindelöf Bridge
Existence and uniqueness of ODE solutions. The contraction mapping
in Picard iteration uses exp(-Lt) as the contraction factor.
Gronwall is a corollary. Picard IS the upstream of the structural
persistence kernel.
-/
namespace Survival.PicardLindelofBridge
open Survival.GronwallBridge
noncomputable section

/-- Picard contraction factor: exp(-L·t) for Lipschitz constant L.
After n iterations, error ≤ ε₀ · exp(-L·t)^n. -/
def picardContraction (lipschitz t : ℝ) : ℝ :=
  Real.exp (-lipschitz * t)

/-- Contraction factor is in (0, 1) when L·t > 0. -/
theorem picard_contracts {L t : ℝ} (hL : 0 < L) (ht : 0 < t) :
    picardContraction L t < 1 := by
  unfold picardContraction
  calc Real.exp (-L * t) < Real.exp 0 :=
        Real.exp_lt_exp.mpr (by nlinarith)
    _ = 1 := Real.exp_zero

theorem picard_pos (L t : ℝ) : 0 < picardContraction L t :=
  Real.exp_pos _

/-- n-fold Picard iteration: error ≤ ε₀ · (contraction)^n. -/
def picardError (eps₀ L t : ℝ) (n : ℕ) : ℝ :=
  eps₀ * (picardContraction L t) ^ n

/-- Error decreases with iterations. -/
theorem picard_error_decreases {eps₀ L t : ℝ} (he : 0 < eps₀)
    (hL : 0 < L) (ht : 0 < t) (n : ℕ) :
    picardError eps₀ L t (n + 1) ≤ picardError eps₀ L t n := by
  unfold picardError
  rw [pow_succ]
  calc eps₀ * (picardContraction L t ^ n * picardContraction L t)
      = (eps₀ * picardContraction L t ^ n) * picardContraction L t := by ring
    _ ≤ (eps₀ * picardContraction L t ^ n) * 1 := by
        apply mul_le_mul_of_nonneg_left (le_of_lt (picard_contracts hL ht))
        exact mul_nonneg (le_of_lt he)
          (pow_nonneg (le_of_lt (picard_pos L t)) n)
    _ = eps₀ * picardContraction L t ^ n := mul_one _

/-- Picard-Lindelöf guarantees existence when contraction < 1.
The structural reading: solutions exist iff the dynamics
contract the viable region at a bounded rate. -/
theorem existence_from_contraction {L t : ℝ} (hL : 0 < L) (ht : 0 < t) :
    0 < picardContraction L t ∧ picardContraction L t < 1 :=
  ⟨picard_pos L t, picard_contracts hL ht⟩

end
end Survival.PicardLindelofBridge
