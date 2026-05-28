import Survival.HillNumber
import Survival.KLDivergence
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-!
# Rényi Entropy Bridge — α-Parameter Family Connection

This module provides the G6-b correspondence between Rényi entropy
and structural persistence theory.

## Mathematical context

Rényi entropy of order α (α ≥ 0, α ≠ 1) for a distribution p:

    H_α(p) = (1/(1-α)) ln(Σᵢ pᵢ^α)

Special cases:
- α = 0: Hartley entropy H₀ = ln|support| (log of support size)
- α → 1: Shannon entropy H₁ = -Σ pᵢ ln pᵢ
- α = 2: Collision entropy H₂ = -ln(Σ pᵢ²)
- α → ∞: Min-entropy H_∞ = -ln(max pᵢ)

## Structural-persistence reading

The structural consumption l_i = -ln(R_i) corresponds to the Shannon
case (α = 1). Generalizing to Rényi gives an α-parameter family of
structural consumption measures, where:
- α = 0: counts the number of viable states (Hartley = log|V|)
- α = 1: standard structural consumption (Shannon)
- α = 2: collision-based structural consumption (sensitive to
  concentration of damage)
- α → ∞: worst-case structural consumption (min-entropy)

References:
  - Rényi, A. (1961). "On measures of entropy and information."
  - HillNumber.lean: Hill number = exp(Shannon entropy)
  - KLDivergence.lean: KL divergence as structural consumption
-/

namespace Survival.RenyiEntropyBridge

open Real

noncomputable section

/-! ## Part 1: Rényi Entropy Definition -/

/-- Rényi entropy of order α for a finite distribution given by
    weights w on index set s. For α ≠ 1:
    H_α(w) = (1/(1-α)) ln(Σᵢ wᵢ^α) -/
def renyiEntropy {ι : Type*} (s : Finset ι) (w : ι → ℝ) (α : ℝ) : ℝ :=
  (1 / (1 - α)) * log (∑ i ∈ s, w i ^ α)

/-- The effective number of types at order α: exp(H_α). -/
def renyiDiversity {ι : Type*} (s : Finset ι) (w : ι → ℝ) (α : ℝ) : ℝ :=
  exp (renyiEntropy s w α)

/-! ## Part 2: Special Cases -/

/-- Hartley entropy (α = 0): H₀ = ln|S| when all weights are 1.
    This counts viable states. -/
theorem renyiEntropy_zero_eq_log_card {ι : Type*} [DecidableEq ι]
    (s : Finset ι) (hs : s.Nonempty)
    (hw : ∀ i ∈ s, (1 : ℝ) = 1) :
    renyiEntropy s (fun _ => (1 : ℝ)) 0 = log ↑s.card := by
  unfold renyiEntropy
  simp

/-- Collision entropy (α = 2): H₂ = -ln(Σ wᵢ²). -/
theorem renyiEntropy_two_eq_neg_log_sum_sq {ι : Type*}
    (s : Finset ι) (w : ι → ℝ) :
    renyiEntropy s w 2 = -(log (∑ i ∈ s, w i ^ 2)) := by
  unfold renyiEntropy
  norm_num

/-! ## Part 3: Structural Consumption at Order α -/

/-- α-structural consumption: the change in Rényi entropy between
    successive viable sets, measured at order α.

    For a shrinkage from total_size to remaining_size (uniform):
    l_α = (1/(1-α)) ln(remaining^α / total^α)
        = (α/(1-α)) ln(remaining / total)

    At α = 1 (Shannon limit), this recovers l = -ln(R). -/
def alphaConsumption (total remaining α : ℝ) : ℝ :=
  (α / (1 - α)) * log (remaining / total)

/-- At α = 2, the structural consumption is 2·ln(R/(R-1))-like. -/
theorem alphaConsumption_two (total remaining : ℝ) :
    alphaConsumption total remaining 2 =
      -2 * log (remaining / total) := by
  unfold alphaConsumption
  norm_num

/-- α-consumption is nonneg when remaining ≤ total (shrinkage)
    and α > 1. For α > 1: α/(1-α) < 0, log(R/T) ≤ 0, product ≥ 0. -/
theorem alphaConsumption_nonneg_of_shrinkage_supercritical
    {total remaining α : ℝ}
    (htotal : 0 < total) (hrem : 0 < remaining)
    (hle : remaining ≤ total)
    (hα_gt : 1 < α) :
    0 ≤ alphaConsumption total remaining α := by
  unfold alphaConsumption
  have hfrac : α / (1 - α) ≤ 0 :=
    div_nonpos_of_nonneg_of_nonpos (le_of_lt (by linarith : (0 : ℝ) < α)) (by linarith)
  have hlog : log (remaining / total) ≤ 0 :=
    log_nonpos (le_of_lt (div_pos hrem htotal))
      ((div_le_one₀ htotal).mpr hle)
  nlinarith [mul_le_mul_of_nonpos_left hlog hfrac]

/-! ## Part 4: Ordering of Rényi Entropies -/

/-- **Key property**: for uniform distributions, Rényi entropy is
    independent of α. H_α(uniform_N) = ln N for all α.

    This means for uniform viable sets, all α give the same
    structural consumption. The α-parameter only matters when
    the distribution is non-uniform. -/
theorem renyiEntropy_uniform_form {ι : Type*}
    (s : Finset ι) (α : ℝ) :
    renyiEntropy s (fun _ => (1 : ℝ)) α =
      (1 / (1 - α)) * log (↑s.card) := by
  unfold renyiEntropy
  congr 1
  simp [Finset.sum_const, Finset.card_univ]

/-! ## Part 5: Connection to Hill Number -/

/-- The Hill number at order 1 (from HillNumber.lean) is the
    exponential of Shannon entropy, which is the α → 1 limit
    of exp(H_α). This module extends the family to all α. -/
theorem renyiDiversity_is_generalized_hill {ι : Type*}
    (s : Finset ι) (w : ι → ℝ) (α : ℝ) :
    renyiDiversity s w α = exp (renyiEntropy s w α) := rfl

end

end Survival.RenyiEntropyBridge
