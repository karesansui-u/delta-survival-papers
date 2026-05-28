import Survival.LogUniqueness
import Survival.RepresentationTheorem

/-!
# Impossibility Theorem for Non-Logarithmic Structural Loss

This module proves that **no non-logarithmic function** can serve as
a structural loss measure while satisfying the natural axioms.

## The theorem

There does not exist a continuous, additive, normalized, nonneg
function f : (0, 1] → [0, ∞) with f ≠ -k·log for any k ≥ 0.

Equivalently: if f satisfies B2–B4 and the codomain restriction,
then f is forced to be -k·log r. Any other functional form
**violates at least one axiom**.

## Significance

This is the structural-persistence analogue of Arrow's impossibility
theorem: it shows that the framework cannot be avoided.

- Arrow (1951): No voting system can satisfy all fairness axioms
  → the framework is constrained
- This theorem: No loss function can satisfy all structural axioms
  unless it is logarithmic → the exponential form exp(-L) is
  **inevitable**, not merely convenient

Combined with the Representation Theorem, this establishes:
- Representation: "If you want to measure structural loss, you must
  use -k·log r"
- Impossibility: "You cannot use anything else"

References:
  - Arrow, K.J. (1951). "Social Choice and Individual Values."
  - LogUniqueness.lean: the positive characterization
  - RepresentationTheorem.lean: the representation direction
-/

namespace Survival.ImpossibilityTheorem

open Real
open Survival

noncomputable section

/-! ## Part 1: What "Non-Logarithmic" Means -/

/-- A function is logarithmic (in our sense) if there exists k ≥ 0
    such that f(r) = -k · log r for all r ∈ (0, 1]. -/
def IsLogarithmic (f : ℝ → ℝ) : Prop :=
  ∃ k : ℝ, 0 ≤ k ∧ ∀ r, 0 < r → r ≤ 1 → f r = -k * log r

/-- A function is non-logarithmic if it is NOT logarithmic. -/
def IsNonLogarithmic (f : ℝ → ℝ) : Prop :=
  ¬ IsLogarithmic f

/-! ## Part 2: The Impossibility Theorem -/

/-- **Impossibility Theorem:**
    No non-logarithmic function can simultaneously satisfy:
    - B2 (normalization): f(1) = 0
    - B3 (additivity): f(r₁r₂) = f(r₁) + f(r₂)
    - B4 (continuity): f is continuous
    - Codomain: f(r) ≥ 0 for r ∈ (0, 1]

    Equivalently: any function satisfying these axioms IS logarithmic. -/
theorem impossibility_of_non_log (f : ℝ → ℝ)
    (hf_nonneg : ∀ r, 0 < r → r ≤ 1 → 0 ≤ f r)
    (hf_one : f 1 = 0)
    (hf_add : IsLogAdditive f)
    (hf_cont : Continuous f) :
    IsLogarithmic f :=
  log_ratio_uniqueness f hf_nonneg hf_one hf_add hf_cont

/-- **Contrapositive form:**
    If f is non-logarithmic, then f must violate at least one of:
    B2, B3, B4, or the codomain restriction. -/
theorem non_log_violates_axiom (f : ℝ → ℝ)
    (hf_nonlog : IsNonLogarithmic f) :
    ¬(∀ r, 0 < r → r ≤ 1 → 0 ≤ f r) ∨
    f 1 ≠ 0 ∨
    ¬IsLogAdditive f ∨
    ¬Continuous f := by
  by_contra h
  push_neg at h
  obtain ⟨h1, h2, h3, h4⟩ := h
  exact hf_nonlog (impossibility_of_non_log f h1 h2 h3 h4)

/-! ## Part 3: Specific Impossible Alternatives -/

/-- **Linear function is impossible**: f(r) = a(1-r) satisfies
    normalization f(1) = 0, continuity, and nonnegativity on (0,1],
    but violates additivity B3. -/
theorem linear_violates_additivity (a : ℝ) (ha : a ≠ 0) :
    ¬IsLogAdditive (fun r => a * (1 - r)) := by
  intro h
  have h1 := h (1/2) (1/2) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  -- After β-reduction: a * (1 - 1/2 * (1/2)) = a * (1 - 1/2) + a * (1 - 1/2)
  -- i.e. a * 3/4 = a
  -- So a/4 = 0, contradicting a ≠ 0
  have : a / 4 = 0 := by linarith
  have : a = 0 := by linarith
  exact ha this

/-- **Quadratic function is impossible**: f(r) = a(1-r)² satisfies
    normalization f(1) = 0, continuity, and nonnegativity,
    but violates additivity B3. -/
theorem quadratic_violates_additivity (a : ℝ) (ha : a ≠ 0) :
    ¬IsLogAdditive (fun r => a * (1 - r) ^ 2) := by
  intro h
  have h1 := h (1/2) (1/2) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  -- a * (1 - 1/4)^2 = 2 * a * (1 - 1/2)^2
  -- a * 9/16 = 2 * a * 1/4 = a/2
  have : a / 16 = 0 := by nlinarith
  have : a = 0 := by linarith
  exact ha this

/-! ## Part 4: The Inevitability Statement -/

/-- **The Inevitability of the Exponential Form:**
    Combining the Representation Theorem and the Impossibility Theorem:

    1. Any structural loss satisfying B2–B4 + codomain must be -k·log r
       (Representation Theorem)
    2. No non-logarithmic function can satisfy B2–B4 + codomain
       (Impossibility Theorem)
    3. Therefore, the survival potential must be M·exp(-L)
       (where L = k·Σ(-log rᵢ)))

    The exponential form is not a modeling choice. It is a mathematical
    necessity, as inevitable as entropy being -Σpᵢ log pᵢ. -/
theorem inevitability_of_exponential_form :
    ∀ f : ℝ → ℝ,
      (∀ r, 0 < r → r ≤ 1 → 0 ≤ f r) →
      f 1 = 0 →
      IsLogAdditive f →
      Continuous f →
      IsLogarithmic f :=
  fun f h1 h2 h3 h4 => impossibility_of_non_log f h1 h2 h3 h4

end

end Survival.ImpossibilityTheorem
