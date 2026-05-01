import Survival.FiniteCSPFirstMomentCollapseBound
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# BEC Erasure-Concentration Boundary

This module records the finite event-level bridge from BEC erasure-count
concentration to the rank-recovery anchors.

It does not prove a binomial Chernoff bound and it does not prove BEC capacity.
Instead, it assumes a tail/concentration envelope for the erasure count and
combines it with a separate rank-failure envelope by a union bound.

The intended reading is:

* if `Pr[|E| + s > r] <= δ`, and
* rank failure on the row-slack side is bounded by `2^{-s}`,

then total unique-recovery failure is bounded by `δ + 2^{-s}`.

Conversely, if an over-row event `|E| > r` has probability at least `1 - δ`,
then any failure event that contains the over-row event also has probability at
least `1 - δ`.
-/

open scoped BigOperators

namespace Survival.LinearCodeBECConcentrationBoundary

open Survival.FiniteCSPFirstMomentCollapseBound

noncomputable section

variable {Ω : Type*} [Fintype Ω]

/-- The BEC erasure count still has row slack `s`: `|E| + s <= r`. -/
def withinRowSlack (erasureCount : Ω → ℕ) (rows slack : ℕ) (ω : Ω) : Prop :=
  erasureCount ω + slack ≤ rows

/-- The BEC erasure count exceeds the parity-check row budget. -/
def overRows (erasureCount : Ω → ℕ) (rows : ℕ) (ω : Ω) : Prop :=
  rows < erasureCount ω

instance instDecidablePredWithinRowSlack
    (erasureCount : Ω → ℕ) (rows slack : ℕ) :
    DecidablePred (withinRowSlack erasureCount rows slack) := by
  intro ω
  unfold withinRowSlack
  infer_instance

instance instDecidablePredOverRows
    (erasureCount : Ω → ℕ) (rows : ℕ) :
    DecidablePred (overRows erasureCount rows) := by
  intro ω
  unfold overRows
  infer_instance

/-- Monotonicity of finite event probability. -/
theorem eventProb_mono
    (P : PMF Ω) {A B : Ω → Prop}
    [DecidablePred A] [DecidablePred B]
    (hsub : ∀ ω, A ω → B ω) :
    eventProb P A ≤ eventProb P B := by
  classical
  unfold eventProb
  refine Finset.sum_le_sum ?_
  intro ω _
  by_cases hA : A ω
  · have hB : B ω := hsub ω hA
    simp [hA, hB]
  · by_cases hB : B ω
    · simp [hA, hB, ENNReal.toReal_nonneg]
    · simp [hA, hB]

/-- Union bound for finite event probabilities. -/
theorem eventProb_or_le_add
    (P : PMF Ω) (A B : Ω → Prop)
    [DecidablePred A] [DecidablePred B] :
    eventProb P (fun ω => A ω ∨ B ω) ≤ eventProb P A + eventProb P B := by
  classical
  unfold eventProb
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_le_sum ?_
  intro ω _
  have hpoint :
      (if A ω ∨ B ω then (1 : ℝ) else 0) ≤
        (if A ω then (1 : ℝ) else 0) + (if B ω then (1 : ℝ) else 0) := by
    by_cases hA : A ω <;> by_cases hB : B ω <;> simp [hA, hB]
  calc
    (P ω).toReal * (if A ω ∨ B ω then (1 : ℝ) else 0)
        ≤ (P ω).toReal *
            ((if A ω then (1 : ℝ) else 0) + (if B ω then (1 : ℝ) else 0)) :=
          mul_le_mul_of_nonneg_left hpoint ENNReal.toReal_nonneg
    _ = (P ω).toReal * (if A ω then (1 : ℝ) else 0) +
          (P ω).toReal * (if B ω then (1 : ℝ) else 0) := by
          ring

/-- If every decoding failure is covered by either an erasure-count tail event
or a rank-failure event, then failure probability is bounded by the sum of their
probabilities. -/
theorem failureProb_le_tail_add_rankFailure
    (P : PMF Ω) (failure rankFailure : Ω → Prop)
    [DecidablePred failure] [DecidablePred rankFailure]
    (erasureCount : Ω → ℕ) (rows slack : ℕ)
    (hcover :
      ∀ ω, failure ω →
        (¬ withinRowSlack erasureCount rows slack ω) ∨ rankFailure ω) :
    eventProb P failure ≤
      eventProb P (fun ω => ¬ withinRowSlack erasureCount rows slack ω) +
        eventProb P rankFailure := by
  classical
  exact le_trans
    (eventProb_mono P hcover)
    (eventProb_or_le_add P
      (fun ω => ¬ withinRowSlack erasureCount rows slack ω) rankFailure)

/-- Achievability-side finite BEC envelope: erasure-count concentration plus a
rank-failure row-slack envelope gives a total failure bound.

The `rankFailure` event may be chosen as the rank-failure event restricted to
the row-slack region, or as any separately fixed event whose probability already
has the stated envelope.  This theorem only combines the two envelopes by a
union bound. -/
theorem failureProb_le_tailBound_add_rankBound
    (P : PMF Ω) (failure rankFailure : Ω → Prop)
    [DecidablePred failure] [DecidablePred rankFailure]
    (erasureCount : Ω → ℕ) (rows slack : ℕ) {δ : ℝ}
    (hcover :
      ∀ ω, failure ω →
        (¬ withinRowSlack erasureCount rows slack ω) ∨ rankFailure ω)
    (hTail :
      eventProb P (fun ω => ¬ withinRowSlack erasureCount rows slack ω) ≤ δ)
    (hRank :
      eventProb P rankFailure ≤ (1 : ℝ) / ((2 : ℝ) ^ slack)) :
    eventProb P failure ≤ δ + (1 : ℝ) / ((2 : ℝ) ^ slack) := by
  have h :=
    failureProb_le_tail_add_rankFailure
      P failure rankFailure erasureCount rows slack hcover
  linarith

/-- If success is read as the complement of `failure`, the preceding theorem
gives a lower bound on success probability. -/
theorem successProb_ge_one_sub_tailBound_sub_rankBound
    (P : PMF Ω) (failure rankFailure : Ω → Prop)
    [DecidablePred failure] [DecidablePred rankFailure]
    (erasureCount : Ω → ℕ) (rows slack : ℕ) {δ : ℝ}
    (hcover :
      ∀ ω, failure ω →
        (¬ withinRowSlack erasureCount rows slack ω) ∨ rankFailure ω)
    (hTail :
      eventProb P (fun ω => ¬ withinRowSlack erasureCount rows slack ω) ≤ δ)
    (hRank :
      eventProb P rankFailure ≤ (1 : ℝ) / ((2 : ℝ) ^ slack)) :
    1 - δ - (1 : ℝ) / ((2 : ℝ) ^ slack) ≤
      1 - eventProb P failure := by
  have hfail :=
    failureProb_le_tailBound_add_rankBound
      P failure rankFailure erasureCount rows slack hcover hTail hRank
  linarith

/-- Converse-side finite BEC envelope: if the over-row event already has
probability at least `1 - δ`, and over-row implies failure, then failure has at
least that probability. -/
theorem failureProb_ge_one_sub_delta_of_overRows
    (P : PMF Ω) (failure : Ω → Prop)
    [DecidablePred failure]
    (erasureCount : Ω → ℕ) (rows : ℕ) {δ : ℝ}
    (hover : 1 - δ ≤ eventProb P (overRows erasureCount rows))
    (hsub : ∀ ω, overRows erasureCount rows ω → failure ω) :
    1 - δ ≤ eventProb P failure := by
  exact le_trans hover (eventProb_mono P hsub)

end

end Survival.LinearCodeBECConcentrationBoundary
