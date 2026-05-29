/-
Hill Number Upper Bound — N_eff ≤ N
Hill数の上界 — 有効多様性は全カテゴリ数を超えない

The Hill number of order 1 (exponential Shannon entropy) satisfies:
  exp(-∑ wᵢ ln wᵢ) ≤ |S|
with equality iff wᵢ = 1/|S| for all i.

This formalizes the claim from Paper 1 Section AA:
  N_eff (effective diversity) ≤ N (total number of categories).
  When all weights are equal, N_eff = N (uniform distribution maximizes entropy).

Proof: Jensen's inequality for concave log on (0,∞).

Key Mathlib ingredients:
  - ConcaveOn.le_map_sum (Jensen's inequality for concave functions)
  - strictConcaveOn_log_Ioi (log is strictly concave on ℝ₊)

References:
- Hill, M.O. (1973). Diversity and evenness: a unifying notation and its consequences.
- Jost, L. (2006). Entropy and diversity. Oikos.
-/

import Mathlib.Analysis.Convex.Jensen
import Mathlib.Analysis.Convex.SpecificFunctions.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Survival.Basic

open Finset BigOperators Real Set

namespace Survival.HillNumber

noncomputable section

variable {ι : Type*}

/-! ## Definitions -/

/-- Shannon entropy of a finite distribution (in nats).
    H(w) = -∑ᵢ wᵢ ln wᵢ.
    Measures the uncertainty (information content) of the distribution.
    Connects to Paper 1's δ: entropy is information *present*,
    δ is information *lost*. -/
def shannonEntropy (s : Finset ι) (w : ι → ℝ) : ℝ :=
  -∑ i ∈ s, w i * Real.log (w i)

/-- Hill number of order 1 (exponential Shannon entropy).
    N_eff = exp(H) = exp(-∑ wᵢ ln wᵢ).
    The effective number of types in a weighted collection.
    Generalizes N_eff from Paper 1: when wᵢ = 1/N (uniform),
    Hill number = N. -/
def hillNumber (s : Finset ι) (w : ι → ℝ) : ℝ :=
  Real.exp (shannonEntropy s w)

/-! ## Shannon entropy upper bound via Jensen's inequality -/

/-- **Shannon entropy ≤ log(N)**: The entropy of any distribution
    over N outcomes is at most log N (achieved by uniform distribution).

    Proof: By Jensen's inequality for concave log,
      H = ∑ wᵢ log(1/wᵢ) ≤ log(∑ wᵢ/wᵢ) = log(N). -/
theorem shannonEntropy_le_log_card [DecidableEq ι] (s : Finset ι) (w : ι → ℝ)
    (hw_pos : ∀ i ∈ s, 0 < w i) (hw_sum : ∑ i ∈ s, w i = 1) :
    shannonEntropy s w ≤ Real.log ↑s.card := by
  unfold shannonEntropy
  -- Step 1: Rewrite -∑ wᵢ log(wᵢ) as ∑ wᵢ log(1/wᵢ)
  -- Using: log(1/x) = log(x⁻¹) = -log(x), so wᵢ log(1/wᵢ) = -wᵢ log(wᵢ)
  suffices h : ∑ i ∈ s, w i * Real.log (1 / w i) ≤ Real.log ↑s.card by
    have h_eq : ∀ i ∈ s, -(w i * Real.log (w i)) = w i * Real.log (1 / w i) := by
      intro i _
      rw [one_div, Real.log_inv, mul_neg]
    calc -∑ i ∈ s, w i * Real.log (w i)
        = ∑ i ∈ s, -(w i * Real.log (w i)) := by
          rw [Finset.sum_neg_distrib]
      _ = ∑ i ∈ s, w i * Real.log (1 / w i) :=
          Finset.sum_congr rfl h_eq
      _ ≤ Real.log ↑s.card := h
  -- Step 2: Apply Jensen's inequality (concave log on (0,∞))
  -- ConcaveOn.le_map_sum: ∑ wᵢ • log(pᵢ) ≤ log(∑ wᵢ • pᵢ)
  have jensen := (strictConcaveOn_log_Ioi).concaveOn.le_map_sum
    (fun i (hi : i ∈ s) => le_of_lt (hw_pos i hi))
    hw_sum
    (fun i (hi : i ∈ s) => mem_Ioi.mpr (div_pos one_pos (hw_pos i hi)))
  simp only [smul_eq_mul] at jensen
  -- Step 3: Simplify RHS of Jensen: ∑ wᵢ * (1/wᵢ) = |s|
  have h_cancel : ∑ i ∈ s, w i * (1 / w i) = ↑s.card := by
    have h_one : ∀ i ∈ s, w i * (1 / w i) = (1 : ℝ) :=
      fun i hi => by rw [one_div, mul_inv_cancel₀ (ne_of_gt (hw_pos i hi))]
    calc ∑ i ∈ s, w i * (1 / w i)
        = ∑ _ ∈ s, (1 : ℝ) := Finset.sum_congr rfl h_one
      _ = ↑s.card := by simp [Finset.sum_const, nsmul_eq_mul]
  rw [h_cancel] at jensen
  exact jensen

/-! ## Hill number upper bound -/

/-- **Hill number ≤ N**: The effective diversity never exceeds
    the total number of categories.

    N_eff = exp(H) ≤ exp(log N) = N. -/
theorem hillNumber_le_card [DecidableEq ι] (s : Finset ι) (w : ι → ℝ)
    (hw_pos : ∀ i ∈ s, 0 < w i) (hw_sum : ∑ i ∈ s, w i = 1)
    (hs : s.Nonempty) :
    hillNumber s w ≤ ↑s.card := by
  unfold hillNumber
  have h_card_pos : (0 : ℝ) < ↑s.card := Nat.cast_pos.mpr hs.card_pos
  calc Real.exp (shannonEntropy s w)
      ≤ Real.exp (Real.log ↑s.card) :=
        Real.exp_le_exp.mpr (shannonEntropy_le_log_card s w hw_pos hw_sum)
    _ = ↑s.card := Real.exp_log h_card_pos

/-! ## Uniform distribution achieves equality -/

/-- Shannon entropy of the uniform distribution equals log(N). -/
theorem shannonEntropy_uniform [DecidableEq ι] (s : Finset ι) (hs : s.Nonempty) :
    shannonEntropy s (fun _ => 1 / ↑s.card) = Real.log ↑s.card := by
  unfold shannonEntropy
  have hn_ne : (↑s.card : ℝ) ≠ 0 := ne_of_gt (Nat.cast_pos.mpr hs.card_pos)
  -- All terms are equal: factor out as card * term
  simp only [Finset.sum_const, nsmul_eq_mul, one_div, Real.log_inv, mul_neg, neg_neg]
  -- Goal: ↑card * ((↑card)⁻¹ * log ↑card) = log ↑card
  rw [← mul_assoc, mul_inv_cancel₀ hn_ne, one_mul]

/-- **Hill number of uniform distribution = N**.
    When all weights are 1/N, the effective diversity equals N.
    This is the maximum possible Hill number for N categories. -/
theorem hillNumber_uniform [DecidableEq ι] (s : Finset ι) (hs : s.Nonempty) :
    hillNumber s (fun _ => 1 / ↑s.card) = ↑s.card := by
  unfold hillNumber
  rw [shannonEntropy_uniform s hs]
  exact Real.exp_log (Nat.cast_pos.mpr hs.card_pos)

/-- The uniform distribution has valid weights (all positive). -/
theorem uniform_weights_pos (s : Finset ι) (hs : s.Nonempty)
    (i : ι) (_ : i ∈ s) :
    (0 : ℝ) < 1 / ↑s.card :=
  div_pos one_pos (Nat.cast_pos.mpr hs.card_pos)

/-- The uniform distribution has weights summing to 1. -/
theorem uniform_weights_sum [DecidableEq ι] (s : Finset ι) (hs : s.Nonempty) :
    ∑ _ ∈ s, (1 : ℝ) / ↑s.card = 1 := by
  have hn_ne : (↑s.card : ℝ) ≠ 0 := ne_of_gt (Nat.cast_pos.mpr hs.card_pos)
  simp only [Finset.sum_const, nsmul_eq_mul, one_div]
  exact mul_inv_cancel₀ hn_ne

/-! ## Shannon entropy is non-negative for valid distributions -/

/-- Shannon entropy is non-negative when weights are in (0,1]. -/
theorem shannonEntropy_nonneg (s : Finset ι) (w : ι → ℝ)
    (hw_pos : ∀ i ∈ s, 0 < w i) (hw_le : ∀ i ∈ s, w i ≤ 1) :
    0 ≤ shannonEntropy s w := by
  unfold shannonEntropy
  rw [le_neg, neg_zero]
  exact Finset.sum_nonpos fun i hi =>
    mul_nonpos_of_nonneg_of_nonpos (le_of_lt (hw_pos i hi))
      (Real.log_nonpos (le_of_lt (hw_pos i hi)) (hw_le i hi))

/-! ## Hill number is at least 1 for valid distributions -/

/-- Hill number ≥ 1 when weights are in (0,1]. -/
theorem one_le_hillNumber (s : Finset ι) (w : ι → ℝ)
    (hw_pos : ∀ i ∈ s, 0 < w i) (hw_le : ∀ i ∈ s, w i ≤ 1) :
    1 ≤ hillNumber s w := by
  unfold hillNumber
  rw [← Real.exp_zero]
  exact Real.exp_le_exp.mpr (shannonEntropy_nonneg s w hw_pos hw_le)

end

end Survival.HillNumber
