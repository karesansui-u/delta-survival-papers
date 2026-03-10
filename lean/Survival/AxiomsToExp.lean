/-
Survival From Axioms — 3 Axioms to e^{-δ}
3公理から e^{-δ} への導出チェーンの形式検証

Core theorem: Under three axioms,
  P(survive all constraints) = exp(-δ)
where δ = Σᵢ(-ln pᵢ) is the cumulative information loss.

Three Axioms:
  (A1) Finite state space: there are finitely many possible states
  (A2) Fraction removal: each constraint i passes a fraction pᵢ ∈ (0,1]
  (A3) Independence: constraints eliminate states independently
       → joint survival = product of individual pass-through rates

The "physical" content:
  - The exponential form e^{-δ} is NOT a modeling choice
  - It is a MATHEMATICAL CONSEQUENCE of axioms A1-A3
  - Whether a given system satisfies A1-A3 is an empirical question
  - SAT, nuclear stability, 3D percolation, and LLM reasoning all pass

Connection to CauchyExponential.lean:
  - This module proves: independence (product) → exp(-δ) via logarithms
  - CauchyExponential proves: the exp form is UNIQUE (Cauchy equation)
  - Together: A3 (independence) uniquely determines the exponential form

References:
  - Paper 1, Section 2: "Three axioms → survival equation"
  - Shannon, C. (1948). Self-information I = -log p
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Survival.Basic

open Finset BigOperators Real

namespace Survival.AxiomsToExp

noncomputable section

variable {ι : Type*}

/-! ## Definitions -/

/-- Self-information of a single constraint with pass-through rate p.
    I(p) = -ln(p) nats.
    - p = 1 (no constraint): I = 0
    - p = 1/2 (eliminates half): I = ln 2 ≈ 0.693 nats
    - p → 0 (total elimination): I → ∞ -/
def selfInfo (p : ℝ) : ℝ := -Real.log p

/-- Cumulative information loss δ = Σᵢ I(pᵢ) = Σᵢ(-ln pᵢ).
    Axiom A2 is encoded here: each constraint has a well-defined
    pass-through rate pᵢ > 0. -/
def delta (s : Finset ι) (p : ι → ℝ) : ℝ :=
  ∑ i ∈ s, selfInfo (p i)

/-- Joint survival probability under independence axiom A3.
    P(survive all) = Πᵢ pᵢ.
    The product structure IS axiom A3: independence means
    the joint probability equals the product of marginals. -/
def jointSurvival (s : Finset ι) (p : ι → ℝ) : ℝ :=
  ∏ i ∈ s, p i

/-! ## Self-information properties -/

/-- Self-information is non-negative when 0 < p ≤ 1.
    Constraints can only remove states, never create them. -/
theorem selfInfo_nonneg {p : ℝ} (hp_pos : 0 < p) (hp_le : p ≤ 1) :
    0 ≤ selfInfo p := by
  unfold selfInfo
  rw [le_neg, neg_zero]
  exact Real.log_nonpos (le_of_lt hp_pos) hp_le

/-- No constraint (p = 1) means zero information loss. -/
theorem selfInfo_one : selfInfo 1 = 0 := by
  unfold selfInfo; simp [Real.log_one]

/-- Self-information of p = 1/2 equals ln 2 (≈ 0.693 nats).
    This is the "1 bit" baseline: eliminating half the states
    costs exactly ln 2 nats of information. -/
theorem selfInfo_half : selfInfo (1 / 2) = Real.log 2 := by
  unfold selfInfo
  rw [one_div, Real.log_inv, neg_neg]

/-! ## Delta properties -/

/-- δ is non-negative for valid distributions (all pᵢ ∈ (0,1]).
    Information loss cannot be negative: constraints only remove states. -/
theorem delta_nonneg (s : Finset ι) (p : ι → ℝ)
    (hp_pos : ∀ i ∈ s, 0 < p i) (hp_le : ∀ i ∈ s, p i ≤ 1) :
    0 ≤ delta s p := by
  unfold delta
  exact Finset.sum_nonneg fun i hi => selfInfo_nonneg (hp_pos i hi) (hp_le i hi)

/-- Empty constraint set has δ = 0: no constraints, no information loss. -/
theorem delta_empty (p : ι → ℝ) : delta ∅ p = 0 := by
  unfold delta; simp

/-- **δ is additive over disjoint constraint sets.**
    δ(S₁ ∪ S₂) = δ(S₁) + δ(S₂) when S₁ ∩ S₂ = ∅.
    This is the additive structure that, via exp,
    becomes the multiplicative Cauchy equation f(a+b) = f(a)·f(b). -/
theorem delta_union [DecidableEq ι] {s t : Finset ι} (p : ι → ℝ)
    (h : Disjoint s t) :
    delta (s ∪ t) p = delta s p + delta t p := by
  unfold delta
  exact Finset.sum_union h

/-! ## Joint survival properties -/

/-- No constraints means certain survival. -/
theorem jointSurvival_empty (p : ι → ℝ) : jointSurvival ∅ p = 1 := by
  unfold jointSurvival; simp

/-- Joint survival is positive when all pass-through rates are positive.
    This ensures log is well-defined in the core theorem. -/
theorem jointSurvival_pos (s : Finset ι) (p : ι → ℝ)
    (hp_pos : ∀ i ∈ s, 0 < p i) :
    0 < jointSurvival s p := by
  unfold jointSurvival
  exact Finset.prod_pos hp_pos

/-- Joint survival is at most 1: constraints never increase probability. -/
theorem jointSurvival_le_one (s : Finset ι) (p : ι → ℝ)
    (hp_pos : ∀ i ∈ s, 0 < p i) (hp_le : ∀ i ∈ s, p i ≤ 1) :
    jointSurvival s p ≤ 1 := by
  unfold jointSurvival
  exact Finset.prod_le_one (fun i hi => le_of_lt (hp_pos i hi)) hp_le

/-- **Joint survival is multiplicative over disjoint constraint sets.**
    P(S₁ ∪ S₂) = P(S₁) · P(S₂).
    This IS axiom A3: independence means probability multiplies. -/
theorem jointSurvival_union [DecidableEq ι] {s t : Finset ι} (p : ι → ℝ)
    (h : Disjoint s t) :
    jointSurvival (s ∪ t) p = jointSurvival s p * jointSurvival t p := by
  unfold jointSurvival
  exact Finset.prod_union h

/-! ## Core Theorem: The Derivation Chain -/

/-- Helper: log of a product equals sum of logs (for positive functions). -/
private lemma log_prod_pos (s : Finset ι) (p : ι → ℝ)
    (hp_pos : ∀ i ∈ s, 0 < p i) :
    Real.log (∏ i ∈ s, p i) = ∑ i ∈ s, Real.log (p i) := by
  induction s using Finset.cons_induction with
  | empty => simp [Real.log_one]
  | cons a s ha ih =>
    rw [Finset.prod_cons, Finset.sum_cons,
        Real.log_mul (ne_of_gt (hp_pos a (Finset.mem_cons_self a s)))
                     (ne_of_gt (Finset.prod_pos
                       (fun i hi => hp_pos i (Finset.mem_cons_of_mem hi)))),
        ih (fun i hi => hp_pos i (Finset.mem_cons_of_mem hi))]

/-- **3 Axioms → e^{-δ}**: The fundamental derivation.

    Given:
    - (A2) All pass-through rates are positive: ∀ i, pᵢ > 0
    - (A3) Independence: joint survival = Πᵢ pᵢ (encoded in definition)

    Then:
      Πᵢ pᵢ = exp(-δ)   where  δ = Σᵢ(-ln pᵢ)

    Proof sketch:
      log(Πᵢ pᵢ) = Σᵢ log pᵢ = -Σᵢ(-log pᵢ) = -δ
      ∴ Πᵢ pᵢ = exp(log(Πᵢ pᵢ)) = exp(-δ)

    This formalizes the paper's core claim:
    **"e^{-δ} is not a hypothesis but a theorem."** -/
theorem joint_survival_eq_exp_neg_delta (s : Finset ι) (p : ι → ℝ)
    (hp_pos : ∀ i ∈ s, 0 < p i) :
    jointSurvival s p = Real.exp (-delta s p) := by
  unfold jointSurvival delta selfInfo
  have h_prod_pos : 0 < ∏ i ∈ s, p i := Finset.prod_pos hp_pos
  -- Step 1: Recover ∏ pᵢ from exp(log(∏ pᵢ))
  rw [← Real.exp_log h_prod_pos]
  congr 1
  -- Step 2: log(∏ pᵢ) = Σ log pᵢ
  rw [log_prod_pos s p hp_pos]
  -- Step 3: Σ log pᵢ = -(Σ(-log pᵢ)) by algebra
  rw [Finset.sum_neg_distrib, neg_neg]

/-! ## The Cauchy Structure Emerges -/

/-- **The Cauchy equation emerges from independence.**

    Combining two independent constraint sets:
    - Information adds:   δ(S₁ ∪ S₂) = δ(S₁) + δ(S₂)
    - Survival multiplies: exp(-δ(S₁ ∪ S₂)) = exp(-δ(S₁)) · exp(-δ(S₂))

    Setting f(x) = exp(-x), this gives f(a+b) = f(a)·f(b):
    exactly the Cauchy multiplicative functional equation.

    CauchyExponential.lean proves this equation has a UNIQUE
    continuous solution: f(x) = exp(-cx) for some c > 0.
    Here c = 1 because we use natural units (nats). -/
theorem cauchy_structure_from_independence [DecidableEq ι]
    {s t : Finset ι} (p : ι → ℝ) (h : Disjoint s t)
    (_hp_pos : ∀ i ∈ s ∪ t, 0 < p i) :
    Real.exp (-delta (s ∪ t) p) =
    Real.exp (-delta s p) * Real.exp (-delta t p) := by
  rw [delta_union p h, neg_add, Real.exp_add]

/-! ## Adding the state space: N_eff · exp(-δ) -/

/-- **With N equally likely initial states, the survival count is N · exp(-δ).**
    This connects to Paper 1's full equation:
      P(found) = (N_eff / N) · exp(-δ) · [discovery term]
    where N_eff / N = 1 for uniform prior (all states equally likely). -/
theorem surviving_states (N : ℕ) (_hN : 0 < N) (s : Finset ι) (p : ι → ℝ)
    (hp_pos : ∀ i ∈ s, 0 < p i) :
    (N : ℝ) * jointSurvival s p = (N : ℝ) * Real.exp (-delta s p) := by
  rw [joint_survival_eq_exp_neg_delta s p hp_pos]

end

end Survival.AxiomsToExp
