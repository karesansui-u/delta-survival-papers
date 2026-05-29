import Survival.LinearCodeBECConcentrationBoundary

/-!
# BEC Capacity-Style Boundary Wrapper

This module is a thin wrapper around the finite BEC rank/concentration bridge.

It does not prove the BEC capacity theorem.  It packages the already-separated
finite ingredients into a capacity-style envelope:

* achievability side: erasure-count concentration plus row-slack rank-failure
  envelope bounds unique-recovery failure;
* converse side: an over-row erasure-count lower-tail witness forces
  unique-recovery failure.

The asymptotic Chernoff rates, random-matrix full-rank product formula, and
capacity limit are deliberately outside this module.
-/

namespace Survival.LinearCodeBECCapacityStyleBoundary

open Survival.FiniteCSPFirstMomentCollapseBound
open Survival.LinearCodeBECConcentrationBoundary

noncomputable section

variable {Ω : Type*} [Fintype Ω]

/-- Finite achievability-side envelope:
`Pr[failure] <= delta + 2^{-slack}`. -/
theorem achievability_failureProb_le
    (P : PMF Ω) (failure rankFailure : Ω → Prop)
    [DecidablePred failure] [DecidablePred rankFailure]
    (erasureCount : Ω → ℕ) (rows slack : ℕ) {delta : ℝ}
    (hcover :
      ∀ ω, failure ω →
        (¬ withinRowSlack erasureCount rows slack ω) ∨ rankFailure ω)
    (hTail :
      eventProb P (fun ω => ¬ withinRowSlack erasureCount rows slack ω) ≤ delta)
    (hRank :
      eventProb P rankFailure ≤ (1 : ℝ) / ((2 : ℝ) ^ slack)) :
    eventProb P failure ≤ delta + (1 : ℝ) / ((2 : ℝ) ^ slack) :=
  failureProb_le_tailBound_add_rankBound
    P failure rankFailure erasureCount rows slack hcover hTail hRank

/-- Equivalent finite achievability-side success lower bound:
`Pr[success] >= 1 - delta - 2^{-slack}`, when success is read as the complement
of `failure`. -/
theorem achievability_successProb_ge
    (P : PMF Ω) (failure rankFailure : Ω → Prop)
    [DecidablePred failure] [DecidablePred rankFailure]
    (erasureCount : Ω → ℕ) (rows slack : ℕ) {delta : ℝ}
    (hcover :
      ∀ ω, failure ω →
        (¬ withinRowSlack erasureCount rows slack ω) ∨ rankFailure ω)
    (hTail :
      eventProb P (fun ω => ¬ withinRowSlack erasureCount rows slack ω) ≤ delta)
    (hRank :
      eventProb P rankFailure ≤ (1 : ℝ) / ((2 : ℝ) ^ slack)) :
    1 - delta - (1 : ℝ) / ((2 : ℝ) ^ slack) ≤
      1 - eventProb P failure :=
  successProb_ge_one_sub_tailBound_sub_rankBound
    P failure rankFailure erasureCount rows slack hcover hTail hRank

/-- Finite converse-side envelope:
if `|E| > r` with probability at least `1-delta`, then unique-recovery failure
has probability at least `1-delta`. -/
theorem converse_failureProb_ge
    (P : PMF Ω) (failure : Ω → Prop) [DecidablePred failure]
    (erasureCount : Ω → ℕ) (rows : ℕ) {delta : ℝ}
    (hover : 1 - delta ≤ eventProb P (overRows erasureCount rows))
    (hsub : ∀ ω, overRows erasureCount rows ω → failure ω) :
    1 - delta ≤ eventProb P failure :=
  failureProb_ge_one_sub_delta_of_overRows
    P failure erasureCount rows hover hsub

end

end Survival.LinearCodeBECCapacityStyleBoundary
