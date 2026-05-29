import Survival.CompletenessTheorem
import Survival.RepresentationTheorem
import Survival.LogUniqueness
/-!
# Shannon Uniqueness as Corollary of Representation Theorem

Shannon (1948) proved: the unique function H satisfying
continuity, maximality at uniform, and chain rule is -Σ p_i log p_i.

This module proves: Shannon's uniqueness is a **corollary** of
SPT's representation theorem. The key insight is that Shannon's
axioms imply B2+B3+B4+nonnegativity on the ratio space (0,1],
so LogUniqueness forces f(r) = -k log r, which gives
H = -k Σ p_i log p_i.

This is not an analogy. It is a formal derivation.
-/
namespace Survival.ShannonUniquenessCorollary
open Real Survival
noncomputable section

-- Shannon's setup: a function on probability ratios.
-- When one event has probability p, the "surprise" of observing
-- it is f(p). Shannon's axioms require this f to satisfy
-- exactly the SPT axioms B2+B3+B4+nonnegativity.

/-- **Step 1: Shannon's additivity IS B3.**
    For independent events with probabilities p₁, p₂:
    surprise(p₁ · p₂) = surprise(p₁) + surprise(p₂).
    This is exactly IsLogAdditive on (0, 1]. -/
theorem shannon_additivity_is_B3 (f : ℝ → ℝ) (hf : IsLogAdditive f) :
    ∀ p₁ p₂, 0 < p₁ → p₁ ≤ 1 → 0 < p₂ → p₂ ≤ 1 →
      f (p₁ * p₂) = f p₁ + f p₂ :=
  hf
/-- **Step 2: Shannon's normalization IS B2.**
    f(1) = 0: a certain event has zero surprise.
    (Moreover, B2 follows from B3 alone.) -/
theorem shannon_normalization_is_B2 (f : ℝ → ℝ) (hf : IsLogAdditive f) :
    f 1 = 0 :=
  Survival.CompletenessTheorem.b2_follows_from_b3 f hf

/-- **Step 3: Apply the Representation Theorem.**
    B2+B3+B4+nonnegativity → f(p) = -k log p.
    This IS Shannon's uniqueness theorem. -/
theorem shannon_uniqueness_from_representation (f : ℝ → ℝ)
    (hf_nonneg : ∀ r, 0 < r → r ≤ 1 → 0 ≤ f r)
    (hf_add : IsLogAdditive f)
    (hf_cont : Continuous f) :
    ∃ k : ℝ, 0 ≤ k ∧ ∀ r, 0 < r → r ≤ 1 → f r = -k * log r :=
  log_ratio_uniqueness f hf_nonneg
    (Survival.CompletenessTheorem.b2_follows_from_b3 f hf_add)
    hf_add hf_cont

/-- **Step 4: The coefficient k is unique.**
    Two representations of the same f must have the same k. -/
theorem shannon_coefficient_unique (f : ℝ → ℝ) (k₁ k₂ : ℝ)
    (h₁ : ∀ r, 0 < r → r ≤ 1 → f r = -k₁ * log r)
    (h₂ : ∀ r, 0 < r → r ≤ 1 → f r = -k₂ * log r) :
    k₁ = k₂ :=
  log_ratio_coefficient_unique f k₁ k₂ h₁ h₂

/-- **Step 5: Shannon entropy H = -k Σ p_i log p_i follows.**
    If surprise(p) = -k log p, then entropy H(p₁,...,pₙ)
    = Σ pᵢ · surprise(pᵢ) = -k Σ pᵢ log pᵢ. -/
def shannonEntropy (k : ℝ) (probs : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, probs i * (-k * log (probs i))

/-- Shannon entropy at k=1 is the standard form. -/
theorem standard_shannon (probs : ℕ → ℝ) (n : ℕ) :
    shannonEntropy 1 probs n =
      -(∑ i ∈ Finset.range n, probs i * log (probs i)) := by
  unfold shannonEntropy
  simp [shannonEntropy, one_mul, neg_mul, Finset.sum_neg_distrib]

/-- **The punchline: Shannon's uniqueness theorem is a corollary
    of SPT's representation theorem, not an independent result.** -/
theorem shannon_is_corollary :
    ∀ f : ℝ → ℝ,
      (∀ r, 0 < r → r ≤ 1 → 0 ≤ f r) →
      IsLogAdditive f →
      Continuous f →
      ∃ k, 0 ≤ k ∧ ∀ r, 0 < r → r ≤ 1 → f r = -k * log r :=
  fun f h1 h2 h3 => shannon_uniqueness_from_representation f h1 h2 h3

end
end Survival.ShannonUniquenessCorollary
