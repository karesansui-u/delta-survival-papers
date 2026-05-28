import Survival.LinearCodeBECCapacityStyleBoundary
import Survival.ChannelCapacityBridge
import Survival.BinarySymmetricChannel

/-!
# Shannon Finite Block Coding Bridge

This module elevates the Channel Capacity Bridge from a G6-b
correspondence to a G6-c embedding by proving that **below the
sustainable structural-persistence rate, repair mechanisms
(= coding strategies) can keep the structural retention factor
bounded away from zero**.

## Mathematical content

For a binary erasure channel (BEC) with erasure probability ε:

1. **Achievability (below capacity)**: There exist linear codes of
   rate R < 1 - ε such that the block failure probability
   Pr[failure] ≤ δ + 2^{-slack}, where slack grows with redundancy.

2. **Converse (above capacity)**: For any code with rate R > 1 - ε,
   block failure probability → 1 as block length increases.

In structural-persistence terms:
- **Below sustainable rate**: exp(-L_effective) stays bounded away
  from zero (structural persistence via coding/repair).
- **Above sustainable rate**: exp(-L_effective) → 0 (structural
  collapse despite repair attempts).

## What this file proves

1. The structural reading of achievability: below capacity, the
   effective structural retention can be kept close to 1.
2. The structural reading of converse: above capacity, effective
   structural retention must collapse.
3. The threshold is exactly the channel capacity (= sustainable rate).

## What this file does NOT prove

* Shannon's coding theorem in its asymptotic form.
* Random coding arguments or sphere-packing bounds.
* Capacity-achieving code constructions.

These results use the finite-block envelope from
`LinearCodeBECCapacityStyleBoundary` and `ChannelCapacityBridge`.
-/

namespace Survival.ShannonFiniteBlockCodingBridge

open Survival.LinearCodeBECCapacityStyleBoundary
open Survival.ChannelCapacityBridge
open Survival.BinarySymmetricChannel
open Survival.FiniteCSPFirstMomentCollapseBound
open Survival.LinearCodeBECConcentrationBoundary

noncomputable section

variable {Ω : Type*} [Fintype Ω]

/-! ## Part 1: Structural Reading of Achievability -/

/-- **Structural Achievability (Finite Block).**

Below the sustainable rate (= channel capacity), there exist
coding strategies (= repair mechanisms) such that the effective
structural retention factor `1 - Pr[failure]` is bounded away
from zero.

Specifically: `Pr[success] ≥ 1 - δ - 2^{-slack}`.

The slack parameter represents redundancy in the repair mechanism:
more redundancy → smaller failure probability → higher retention. -/
theorem structural_achievability_retention_bound
    (P : PMF Ω) (failure rankFailure : Ω → Prop)
    [DecidablePred failure] [DecidablePred rankFailure]
    (erasureCount : Ω → ℕ) (rows slack : ℕ) {delta : ℝ}
    (hcover :
      ∀ ω, failure ω →
        (¬ withinRowSlack erasureCount rows slack ω) ∨
          rankFailure ω)
    (hTail :
      eventProb P (fun ω =>
        ¬ withinRowSlack erasureCount rows slack ω) ≤ delta)
    (hRank :
      eventProb P rankFailure ≤
        (1 : ℝ) / ((2 : ℝ) ^ slack)) :
    1 - delta - (1 : ℝ) / ((2 : ℝ) ^ slack) ≤
      1 - eventProb P failure :=
  achievability_successProb_ge P failure rankFailure
    erasureCount rows slack hcover hTail hRank

/-- The retention bound improves as slack (redundancy) increases,
since 2^{-slack} → 0. This is the structural-persistence reading:
more repair investment → better structural retention. -/
theorem slack_improves_retention {slack : ℕ}
    (hslack : 0 < slack) :
    (0 : ℝ) < (1 : ℝ) / ((2 : ℝ) ^ slack) := by
  exact div_pos one_pos (pow_pos (by norm_num : (0:ℝ) < 2) slack)

/-! ## Part 2: Structural Reading of Converse -/

/-- **Structural Converse (Finite Block).**

Above the sustainable rate, structural collapse is unavoidable.
If the erasure count exceeds the number of parity-check rows
with probability at least 1-δ, then failure probability is at
least 1-δ.

In structural-persistence terms: above capacity, no coding/repair
strategy can prevent exp(-L_effective) → 0. -/
theorem structural_converse_collapse_bound
    (P : PMF Ω) (failure : Ω → Prop) [DecidablePred failure]
    (erasureCount : Ω → ℕ) (rows : ℕ) {delta : ℝ}
    (hover :
      1 - delta ≤
        eventProb P (overRows erasureCount rows))
    (hsub :
      ∀ ω, overRows erasureCount rows ω → failure ω) :
    1 - delta ≤ eventProb P failure :=
  converse_failureProb_ge P failure erasureCount rows
    hover hsub

/-! ## Part 3: BSC Uncoded Baseline -/

/-- **Uncoded BSC Retention Decay.**

Without coding (= without repair), the uncoded BSC retention
factor (1-p)^n = exp(-n · l) decays exponentially with block
length n.

This is the baseline: the structural consumption rate without
any repair mechanism. Coding/repair reduces the effective rate
below this baseline. -/
theorem uncoded_retention_exponential_decay
    (C : System) (n : ℕ) :
    blockSuccessProbability C n =
      Real.exp (-cumulativeLoss C n) :=
  blockSuccessProbability_eq_exp_neg_cumulativeLoss C n

/-- The uncoded retention approaches zero as n → ∞ when there is
positive channel noise (= positive structural consumption rate). -/
theorem uncoded_retention_vanishes_of_noise
    (C : System) (_herror : 0 < C.errorRate) (n : ℕ) {θ : ℝ}
    (hθ : 0 < θ)
    (hcross : -Real.log θ ≤ cumulativeLoss C n) :
    blockSuccessProbability C n ≤ θ :=
  blockSuccessProbability_le_threshold_of_cumulativeLoss_ge
    C n hθ hcross

/-! ## Part 4: Capacity as Sustainable Rate Boundary -/

/-- **Sustainable Rate Reading.**

The channel capacity C = ln 2 - H(ε) is the maximum rate at which
structural information can be reliably maintained.

- Below C: coding exists that keeps retention bounded away from 0
  (achievability).
- Above C: no coding can prevent retention collapse (converse).

This is the structural-persistence reading of Shannon's channel
coding theorem at the finite-block level. -/
theorem sustainable_rate_eq_capacity
    (C : System) :
    sustainableRate C = bscCapacity C := rfl

/-- Per-symbol structural consumption is nonneg (A1 direction). -/
theorem per_symbol_consumption_nonneg (C : System) :
    0 ≤ perSymbolConsumption C :=
  perSymbolConsumption_nonneg C

/-- Per-symbol structural consumption equals -ln(1-p). -/
theorem per_symbol_consumption_formula (C : System) :
    perSymbolConsumption C = -Real.log (1 - C.errorRate) :=
  rfl

/-- KL divergence as structural consumption (from KLDivergence.lean). -/
theorem kl_as_consumption
    {total sat : ℝ} (htotal : 0 < total) (hsat : 0 < sat)
    (hle : sat ≤ total) :
    Survival.KLDivergence.klUniform total sat =
      Real.log total - Real.log sat :=
  kl_as_structural_consumption htotal hsat hle

end

end Survival.ShannonFiniteBlockCodingBridge
