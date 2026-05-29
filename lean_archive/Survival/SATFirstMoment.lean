/-
SAT First Moment — Formal Verification of Paper's Core Mathematical Identities
SAT第一モーメント法 — 論文の中核数学的恒等式の形式的検証

Formalizes the derivation chain from the paper's Section 3 (SAT Experiments):
論文のセクション3（SAT実験）の導出チェーンを形式化:

  Eq.3-6: First Moment Identity — ∏ p_i = exp(-δ), where δ = Σ(-ln p_i)
  Eq.7:   I(random 3-clause) = ln(8/7) ≈ 0.134 nats
  Eq.9:   I(XOR pair) = ln 2 ≈ 0.693 nats
  Eq.10:  I(closed implication chain, length L) = L·ln 2 - ln L nats
  Eq.11:  α_XOR/α_random = ln 2 / ln(8/7) (≈ 5.19, parameter-free prediction)

These are existing mathematical results (first moment method, Shannon information).
The contribution is verifying the derivation chain used in the paper.

Key correspondence:
  δ = Σ_i I(C_i) where I(C_i) = -ln(p_i) nats
  e^{-δ} = ∏ p_i = first moment normalized by 2^n (solution space)
  This is a mathematical identity, not an approximation.

References:
- Alon, N. & Spencer, J.H. (2016). The Probabilistic Method, 4th ed.
- Shannon, C.E. (1948). A mathematical theory of communication.
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Survival.Basic

open Finset BigOperators

namespace Survival.SATFirstMoment

/-! ## Part 1: Definitions — Information Loss per Constraint -/

/-- Information loss per constraint: I(C) = -ln(p) nats. -/
noncomputable def infoLoss (p : ℝ) : ℝ := -Real.log p

/-- Cumulative information loss: δ = Σ I(C_i) = Σ (-ln p_i). -/
noncomputable def cumulativeInfoLoss {ι : Type*} (s : Finset ι) (p : ι → ℝ) : ℝ :=
  ∑ i ∈ s, infoLoss (p i)

/-! ## Part 2: First Moment Identity (Eq.3-6) -/

/-- **First Moment Identity** (Eq.3→6 in the paper):
    ∏ p_i = exp(-δ), where δ is the cumulative information loss. -/
theorem first_moment_identity {ι : Type*}
    (s : Finset ι) (p : ι → ℝ) (hp : ∀ i ∈ s, p i > 0) :
    ∏ i ∈ s, p i = Real.exp (-(cumulativeInfoLoss s p)) := by
  unfold cumulativeInfoLoss infoLoss
  have hne : ∀ i ∈ s, p i ≠ 0 := fun i hi => ne_of_gt (hp i hi)
  have hprod : (∏ i ∈ s, p i) > 0 := Finset.prod_pos fun i hi => hp i hi
  have h_neg : -(∑ i ∈ s, -Real.log (p i)) = ∑ i ∈ s, Real.log (p i) := by
    simp
  rw [h_neg]
  rw [← Real.log_prod hne]
  exact (Real.exp_log hprod).symm

/-! ## Part 3: Properties of Information Loss -/

/-- Information loss is non-negative when 0 < p ≤ 1. -/
theorem infoLoss_nonneg {p : ℝ} (hp : 0 < p) (hp1 : p ≤ 1) :
    0 ≤ infoLoss p := by
  unfold infoLoss
  linarith [Real.log_nonpos (le_of_lt hp) hp1]

/-- Information loss is strictly positive when 0 < p < 1. -/
theorem infoLoss_pos {p : ℝ} (hp : 0 < p) (hp1 : p < 1) :
    infoLoss p > 0 := by
  unfold infoLoss
  linarith [Real.log_neg hp hp1]

/-- Information loss is zero iff the constraint is vacuous (p = 1). -/
theorem infoLoss_eq_zero_iff {p : ℝ} (hp : 0 < p) :
    infoLoss p = 0 ↔ p = 1 := by
  unfold infoLoss
  constructor
  · intro h
    have h1 : Real.log p = 0 := by linarith
    have h2 : Real.exp (Real.log p) = Real.exp 0 := congr_arg _ h1
    rw [Real.exp_log hp, Real.exp_zero] at h2
    exact h2
  · intro h
    rw [h, Real.log_one, neg_zero]

/-! ## Part 4: Constraint Type Information Losses (Eq.7, 9, 10) -/

/-- **Random 3-clause** (Eq.7): I = ln(8/7) nats. -/
theorem info_loss_random_3clause :
    infoLoss (7/8 : ℝ) = Real.log (8/7 : ℝ) := by
  unfold infoLoss
  have h_inv : (7 / 8 : ℝ) = (8 / 7 : ℝ)⁻¹ := by norm_num
  rw [h_inv, Real.log_inv, neg_neg]

/-- **XOR pair** (Eq.9): I = ln 2 nats. -/
theorem info_loss_xor_pair :
    infoLoss (1/2 : ℝ) = Real.log 2 := by
  unfold infoLoss
  have h_inv : (1 / 2 : ℝ) = (2 : ℝ)⁻¹ := by norm_num
  rw [h_inv, Real.log_inv, neg_neg]

/-- **Closed implication chain** (Eq.10): algebraic identity
    ln(2^L / L) = L·ln 2 - ln L. -/
theorem info_loss_impl_chain (L : ℕ) (hL : 0 < L) :
    Real.log ((2 : ℝ) ^ L / ↑L) = ↑L * Real.log 2 - Real.log (↑L : ℝ) := by
  have h2L_ne : ((2 : ℝ) ^ L) ≠ 0 := ne_of_gt (pow_pos (by norm_num : (0 : ℝ) < 2) L)
  have hL_pos : (0 : ℝ) < (↑L : ℝ) := Nat.cast_pos.mpr hL
  rw [div_eq_mul_inv]
  rw [Real.log_mul h2L_ne (ne_of_gt (inv_pos.mpr hL_pos))]
  rw [Real.log_inv, Real.log_pow]
  ring

/-! ## Part 5: Parameter-Free Ratio Prediction (Eq.11) -/

/-- **Information loss ratio**: I(XOR) / I(random) = ln 2 / ln(8/7). -/
theorem ratio_xor_over_random :
    infoLoss (1/2 : ℝ) / infoLoss (7/8 : ℝ) = Real.log 2 / Real.log (8/7 : ℝ) := by
  rw [info_loss_xor_pair, info_loss_random_3clause]

/-- XOR constraints carry strictly more information loss per constraint
    than random 3-clauses: ln 2 > ln(8/7). -/
theorem xor_stronger_than_random :
    infoLoss (1/2 : ℝ) > infoLoss (7/8 : ℝ) := by
  rw [info_loss_xor_pair, info_loss_random_3clause]
  exact Real.log_lt_log (by norm_num : (0 : ℝ) < 8 / 7) (by norm_num : (8 : ℝ) / 7 < 2)

/-- **General ratio theorem**: if α₁·I₁ = α₂·I₂, then α₁/α₂ = I₂/I₁. -/
theorem ratio_from_info_loss {I₁ I₂ α₁ α₂ : ℝ}
    (hI₁ : I₁ ≠ 0) (hα₂ : α₂ ≠ 0)
    (h : α₁ * I₁ = α₂ * I₂) :
    α₁ / α₂ = I₂ / I₁ := by
  rw [div_eq_div_iff hα₂ hI₁]
  rw [h]; ring

/-- **SAT ratio prediction**: α_r/α_x = ln 2 / ln(8/7) ≈ 5.19. -/
theorem sat_ratio_prediction {α_r α_x : ℝ}
    (hα_x : α_x ≠ 0)
    (h : α_r * infoLoss (7/8 : ℝ) = α_x * infoLoss (1/2 : ℝ)) :
    α_r / α_x = Real.log 2 / Real.log (8/7 : ℝ) := by
  have h1 := ratio_from_info_loss
    (ne_of_gt (infoLoss_pos (by norm_num : (0:ℝ) < 7/8) (by norm_num : (7:ℝ)/8 < 1)))
    hα_x h
  rw [info_loss_xor_pair, info_loss_random_3clause] at h1
  exact h1

/-! ## Part 6: Uniform Constraint Scaling -/

/-- For m uniform constraints, δ = m · I(p). -/
theorem cumulative_uniform {ι : Type*} (s : Finset ι) (p : ℝ)
    (f : ι → ℝ) (hf : ∀ i ∈ s, f i = p) :
    cumulativeInfoLoss s f = ↑s.card * infoLoss p := by
  unfold cumulativeInfoLoss
  have : ∀ i ∈ s, infoLoss (f i) = infoLoss p := fun i hi => by rw [hf i hi]
  rw [Finset.sum_congr rfl this, Finset.sum_const, nsmul_eq_mul]

end Survival.SATFirstMoment
