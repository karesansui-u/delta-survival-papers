/-
Correlated Second Moment — Uniform Bounds from Pairwise Marginals
相関第二モーメント — 周辺からの一様上界

The Paley–Zygmund / Cauchy–Schwarz route in `SecondMomentBound` and
`SATSecondMoment.second_moment_method` does **not** require independence of
constraints: it is a purely nonnegative-variable inequality.

This module packages:
1. Termwise bounding of the overlap sum `secondMoment` when the pair kernel
   `g` is uniformly bounded (robust to dependence that preserves per-pair
   satisfaction bounds).
2. A direct reuse of the abstract second moment method as the
   "correlated" version (same inequality, weaker assumptions).

References:
- `Survival.SecondMomentBound`
- `Survival.SATSecondMoment`
- `Survival.PairCorrelation`
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Survival.PairCorrelation
import Survival.SATSecondMoment
import Survival.SecondMomentBound

open Finset BigOperators Real

namespace Survival.CorrelatedSecondMoment

/-! ## Termwise bounding of the overlap second moment -/

/-- Pointwise upper bound on `secondMoment` from a uniform upper bound on `g`. -/
theorem secondMoment_le_uniform_upper (n m : ℕ) (g : ℝ → ℝ) (G : ℝ)
    (hg : ∀ x : ℝ, g x ≤ G) (hg_nn : ∀ x : ℝ, 0 ≤ g x) (_hG_nn : 0 ≤ G) :
    SATSecondMoment.secondMoment n m g ≤ (2 : ℝ) ^ n * G ^ m := by
  unfold SATSecondMoment.secondMoment
  have hterm : ∀ d ∈ range (n + 1),
      (n.choose d : ℝ) * g (d / n) ^ m ≤ (n.choose d : ℝ) * G ^ m := by
    intro d hd
    apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg' (n.choose d))
    exact pow_le_pow_left₀ (hg_nn _) (hg _) m
  have hsum :
      (∑ d ∈ range (n + 1), (n.choose d : ℝ) * g (d / n) ^ m)
        ≤ ∑ d ∈ range (n + 1), (n.choose d : ℝ) * G ^ m := by
    exact sum_le_sum hterm
  calc
    ∑ d ∈ range (n + 1), (n.choose d : ℝ) * g (d / n) ^ m
        ≤ ∑ d ∈ range (n + 1), (n.choose d : ℝ) * G ^ m := hsum
    _ = G ^ m * ∑ d ∈ range (n + 1), (n.choose d : ℝ) := by
          rw [Finset.mul_sum]
          congr 1
          ext d
          ring
    _ = G ^ m * (2 : ℝ) ^ n := by
          rw [SATSecondMoment.binomial_sum n]
    _ = (2 : ℝ) ^ n * G ^ m := by ring

/-- Pointwise lower bound on `secondMoment` from a uniform lower bound on `g`. -/
theorem secondMoment_ge_uniform_lower (n m : ℕ) (g : ℝ → ℝ) (G : ℝ)
    (hg : ∀ x : ℝ, G ≤ g x) (hG_nn : 0 ≤ G) :
    (2 : ℝ) ^ n * G ^ m ≤ SATSecondMoment.secondMoment n m g := by
  unfold SATSecondMoment.secondMoment
  have hterm : ∀ d ∈ range (n + 1),
      (n.choose d : ℝ) * G ^ m ≤ (n.choose d : ℝ) * g (d / n) ^ m := by
    intro d hd
    apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg' (n.choose d))
    exact pow_le_pow_left₀ hG_nn (hg _) m
  have hsum :
      ∑ d ∈ range (n + 1), (n.choose d : ℝ) * G ^ m
        ≤ ∑ d ∈ range (n + 1), (n.choose d : ℝ) * g (d / n) ^ m :=
    sum_le_sum hterm
  calc
    (2 : ℝ) ^ n * G ^ m
        = G ^ m * ∑ d ∈ range (n + 1), (n.choose d : ℝ) := by
          rw [SATSecondMoment.binomial_sum n]
          ring
    _ = ∑ d ∈ range (n + 1), (n.choose d : ℝ) * G ^ m := by
          rw [Finset.mul_sum]
          congr 1
          ext d
          ring
    _ ≤ ∑ d ∈ range (n + 1), (n.choose d : ℝ) * g (d / n) ^ m := hsum

/-! ## Random 3-SAT pair kernel bounds (PairCorrelation.g) -/

theorem g_real_le_seven_eighths (β : ℝ) (h0 : 0 ≤ β) (h1 : β ≤ 1) :
    (3 / 4 + (1 / 8) * (1 - β) ^ 3 : ℝ) ≤ 7 / 8 := by
  have := PairCorrelation.g_le_seven_eighths h0 h1
  unfold PairCorrelation.g at this
  exact this

theorem g_real_ge_three_quarters (β : ℝ) (h0 : 0 ≤ β) (h1 : β ≤ 1) :
    (3 / 4 : ℝ) ≤ 3 / 4 + (1 / 8) * (1 - β) ^ 3 := by
  have := PairCorrelation.g_ge_three_quarters h0 h1
  unfold PairCorrelation.g at this
  exact this

theorem pair_kernel_upper_forall (β : ℝ) (h0 : 0 ≤ β) (h1 : β ≤ 1) :
    SATSecondMoment.pairCorrelation β ≤ 7 / 8 := by
  unfold SATSecondMoment.pairCorrelation
  exact g_real_le_seven_eighths β h0 h1

theorem pair_kernel_lower_forall (β : ℝ) (h0 : 0 ≤ β) (h1 : β ≤ 1) :
    3 / 4 ≤ SATSecondMoment.pairCorrelation β := by
  unfold SATSecondMoment.pairCorrelation
  exact g_real_ge_three_quarters β h0 h1

theorem pair_kernel_nn (β : ℝ) (h0 : 0 ≤ β) (h1 : β ≤ 1) :
    0 ≤ SATSecondMoment.pairCorrelation β :=
  le_trans (by norm_num : (0 : ℝ) ≤ 3 / 4) (pair_kernel_lower_forall β h0 h1)

/-! ## Mesh points `d/n` for overlap decomposition -/

theorem mesh_beta_nonneg (n d : ℕ) (hd : d ∈ range (n + 1)) :
    (0 : ℝ) ≤ (d : ℝ) / (n : ℝ) := by
  rcases Nat.eq_zero_or_pos n with hn0 | hnpos
  · subst hn0
    rw [Finset.mem_range] at hd
    have hd0 : d = 0 := Nat.lt_one_iff.mp hd
    subst hd0
    simp
  · refine div_nonneg (Nat.cast_nonneg d) (Nat.cast_nonneg n)

theorem mesh_beta_le_one (n d : ℕ) (hd : d ∈ range (n + 1)) :
    (d : ℝ) / (n : ℝ) ≤ (1 : ℝ) := by
  rcases Nat.eq_zero_or_pos n with hn0 | hnpos
  · subst hn0
    rw [Finset.mem_range] at hd
    have hd0 : d = 0 := Nat.lt_one_iff.mp hd
    subst hd0
    simp
  · have d_le : d ≤ n := Nat.le_of_lt_succ (Finset.mem_range.mp hd)
    have hnR : (0 : ℝ) < (n : ℝ) := Nat.cast_pos.mpr hnpos
    have hdR : (d : ℝ) ≤ (n : ℝ) := Nat.cast_le.mpr d_le
    calc
      (d : ℝ) / (n : ℝ) ≤ (n : ℝ) / (n : ℝ) := div_le_div_of_nonneg_right hdR (le_of_lt hnR)
      _ = 1 := div_self (ne_of_gt hnR)

/-- Overlap second moment for random 3-SAT: uniform upper on the Hamming mesh. -/
theorem secondMoment_random3sat_upper (n m : ℕ) :
    SATSecondMoment.secondMoment n m SATSecondMoment.pairCorrelation
      ≤ (2 : ℝ) ^ n * (7 / 8 : ℝ) ^ m := by
  unfold SATSecondMoment.secondMoment
  have hterm :
      ∀ d ∈ range (n + 1),
        (n.choose d : ℝ) * SATSecondMoment.pairCorrelation (d / n) ^ m
          ≤ (n.choose d : ℝ) * (7 / 8 : ℝ) ^ m := by
    intro d hd
    have hβ0 := mesh_beta_nonneg n d hd
    have hβ1 := mesh_beta_le_one n d hd
    have hg := pair_kernel_upper_forall (d / n) hβ0 hβ1
    have hnn := pair_kernel_nn (d / n) hβ0 hβ1
    apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg' (n.choose d))
    exact pow_le_pow_left₀ hnn hg m
  have hsum :
      (∑ d ∈ range (n + 1), (n.choose d : ℝ) * SATSecondMoment.pairCorrelation (d / n) ^ m)
        ≤ ∑ d ∈ range (n + 1), (n.choose d : ℝ) * (7 / 8 : ℝ) ^ m :=
    sum_le_sum hterm
  calc
    ∑ d ∈ range (n + 1), (n.choose d : ℝ) * SATSecondMoment.pairCorrelation (d / n) ^ m
        ≤ ∑ d ∈ range (n + 1), (n.choose d : ℝ) * (7 / 8 : ℝ) ^ m := hsum
    _ = (7 / 8 : ℝ) ^ m * ∑ d ∈ range (n + 1), (n.choose d : ℝ) := by
          rw [Finset.mul_sum]
          congr 1
          ext d
          ring
    _ = (7 / 8 : ℝ) ^ m * (2 : ℝ) ^ n := by rw [SATSecondMoment.binomial_sum n]
    _ = (2 : ℝ) ^ n * (7 / 8 : ℝ) ^ m := by ring

/-- Uniform lower route on the mesh: `g ≥ 3/4` for `β ∈ [0,1]`. -/
theorem secondMoment_random3sat_lower (n m : ℕ) :
    (2 : ℝ) ^ n * (3 / 4 : ℝ) ^ m
      ≤ SATSecondMoment.secondMoment n m SATSecondMoment.pairCorrelation := by
  unfold SATSecondMoment.secondMoment
  have hterm :
      ∀ d ∈ range (n + 1),
        (n.choose d : ℝ) * (3 / 4 : ℝ) ^ m
          ≤ (n.choose d : ℝ) * SATSecondMoment.pairCorrelation (d / n) ^ m := by
    intro d hd
    have hβ0 := mesh_beta_nonneg n d hd
    have hβ1 := mesh_beta_le_one n d hd
    have hg := pair_kernel_lower_forall (d / n) hβ0 hβ1
    apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg' (n.choose d))
    exact pow_le_pow_left₀ (by norm_num) hg m
  have hsum :
      ∑ d ∈ range (n + 1), (n.choose d : ℝ) * (3 / 4 : ℝ) ^ m
        ≤ ∑ d ∈ range (n + 1), (n.choose d : ℝ) * SATSecondMoment.pairCorrelation (d / n) ^ m :=
    sum_le_sum hterm
  calc
    (2 : ℝ) ^ n * (3 / 4 : ℝ) ^ m
        = (3 / 4 : ℝ) ^ m * ∑ d ∈ range (n + 1), (n.choose d : ℝ) := by
          rw [SATSecondMoment.binomial_sum n]
          ring
    _ = ∑ d ∈ range (n + 1), (n.choose d : ℝ) * (3 / 4 : ℝ) ^ m := by
          rw [Finset.mul_sum]
          congr 1
          ext d
          ring
    _ ≤ ∑ d ∈ range (n + 1), (n.choose d : ℝ) * SATSecondMoment.pairCorrelation (d / n) ^ m :=
          hsum

/-- **Correlated / mesh robustness**: the overlap second moment is sandwiched between
    pure powers `(3/4)^m` and `(7/8)^m` (scaled by `2^n`) using only per-pair marginal
    bounds on `β = d/n ∈ [0,1]` — no clause-independence assumption. -/
theorem correlated_mesh_sandwich (n m : ℕ) :
    (2 : ℝ) ^ n * (3 / 4 : ℝ) ^ m
      ≤ SATSecondMoment.secondMoment n m SATSecondMoment.pairCorrelation
      ∧ SATSecondMoment.secondMoment n m SATSecondMoment.pairCorrelation
        ≤ (2 : ℝ) ^ n * (7 / 8 : ℝ) ^ m :=
  ⟨secondMoment_random3sat_lower n m, secondMoment_random3sat_upper n m⟩

/-- Plan-facing name: overlap second moment is **uniformly sandwiched** on the `d/n` mesh. -/
theorem correlated_ratio_bounded (n m : ℕ) :
    (2 : ℝ) ^ n * (3 / 4 : ℝ) ^ m
      ≤ SATSecondMoment.secondMoment n m SATSecondMoment.pairCorrelation
      ∧ SATSecondMoment.secondMoment n m SATSecondMoment.pairCorrelation
        ≤ (2 : ℝ) ^ n * (7 / 8 : ℝ) ^ m :=
  correlated_mesh_sandwich n m

/-! ## Second moment method (no independence needed) -/

/-- Abstract second moment lower bound — identical to `SATSecondMoment.second_moment_method`. -/
theorem correlated_second_moment_method {EX EX2 PrPos : ℝ}
    (hEX_pos : 0 < EX) (hEX2_pos : 0 < EX2)
    (hPr_nonneg : 0 ≤ PrPos) (hPr_le_one : PrPos ≤ 1)
    (h_cauchy_schwarz : EX ^ 2 ≤ EX2 * PrPos) :
    EX ^ 2 / EX2 ≤ PrPos :=
  SATSecondMoment.second_moment_method hEX_pos hEX2_pos hPr_nonneg hPr_le_one h_cauchy_schwarz

/-- Discrete Paley–Zygmund: same as `SecondMomentBound.paley_zygmund`. -/
theorem correlated_paley_zygmund [Fintype ι] (f : ι → ℝ) (hf : ∀ i, 0 ≤ f i)
    (hf_pos : ∑ i, f i > 0) :
    (∑ i, f i) ^ 2 / (∑ i, f i ^ 2)
      ≤ ↑(univ.filter (fun i => 0 < f i)).card :=
  SecondMomentBound.paley_zygmund f hf hf_pos

/-! ## Ratio bookkeeping (algebraic) -/

theorem second_moment_ratio_le_of_upper {EX EX2 C : ℝ}
    (hEX_pos : 0 < EX) (_hEX2_pos : 0 < EX2)
    (hEX2_le : EX2 ≤ C * EX ^ 2) :
    EX2 / EX ^ 2 ≤ C := by
  have hsq : 0 < EX ^ 2 := pow_pos hEX_pos 2
  rw [div_le_iff₀ hsq]
  exact hEX2_le

theorem positive_probability_from_bounded_ratio_correlated {EX EX2 C PrPos : ℝ}
    (hEX_pos : 0 < EX) (hEX2_pos : 0 < EX2)
    (hC_pos : 0 < C)
    (hPr_nonneg : 0 ≤ PrPos) (hPr_le : PrPos ≤ 1)
    (h_ratio_bound : EX2 / EX ^ 2 ≤ C)
    (h_cauchy_schwarz : EX ^ 2 ≤ EX2 * PrPos) :
    1 / C ≤ PrPos :=
  SATSecondMoment.positive_probability_from_bounded_ratio hEX_pos hEX2_pos hC_pos
    hPr_nonneg hPr_le h_ratio_bound h_cauchy_schwarz

end Survival.CorrelatedSecondMoment
