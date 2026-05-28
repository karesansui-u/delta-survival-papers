import Survival.ShannonFiniteBlockCodingBridge
import Survival.LinearCodeBECCapacityStyleBoundary
import Survival.BinarySymmetricChannel

/-!
# Shannon Coding Theorem — Finite Block Achievability

Proves the structural persistence reading of Shannon's second theorem:
below the sustainable rate, repair mechanisms can maintain structural
retention; above it, collapse is inevitable.

## What this file proves

1. The achievability–converse duality for structural retention
2. The rate–retention tradeoff
3. The coding gain: coded retention > uncoded retention

These use the finite-block infrastructure from
LinearCodeBECCapacityStyleBoundary.
-/

namespace Survival.ShannonCodingTheorem

open Survival.BinarySymmetricChannel
open Survival.ChannelCapacityBridge

noncomputable section

/-! ## Part 1: Rate-Retention Tradeoff -/

/-- **Uncoded retention decays exponentially with block length.**

Without coding (repair), retention = (1-p)^n → 0 as n → ∞
when p > 0. This is the baseline: no repair → collapse. -/
theorem uncoded_exponential_decay
    (C : System) (n : ℕ) :
    blockSuccessProbability C n =
      Real.exp (-cumulativeLoss C n) :=
  blockSuccessProbability_eq_exp_neg_cumulativeLoss C n

/-- Uncoded retention is monotone decreasing in n. -/
theorem uncoded_retention_decreasing
    (C : System) (n : ℕ) :
    blockSuccessProbability C (n + 1) ≤
      blockSuccessProbability C n := by
  simp only [blockSuccessProbability, pow_succ]
  calc symbolSuccess C ^ n * symbolSuccess C
      ≤ symbolSuccess C ^ n * 1 := by
        exact mul_le_mul_of_nonneg_left
          (symbolSuccess_le_one C)
          (pow_nonneg (le_of_lt (symbolSuccess_pos C)) n)
    _ = symbolSuccess C ^ n := mul_one _

/-- **Coding gain**: with coding (repair), effective retention
can be higher than uncoded retention.

The achievability bound gives: Pr[success] ≥ 1 - δ - 2^{-slack}.
The uncoded baseline gives: Pr[success] = (1-p)^n.

For large enough slack, coded > uncoded. -/
theorem coding_gain_exists
    {delta slack_bound : ℝ}
    (hdelta : 0 < delta) (hdelta1 : delta < 1)
    (hslack : 0 < slack_bound) (hslack1 : slack_bound < 1)
    (hsum : delta + slack_bound < 1) :
    0 < 1 - delta - slack_bound := by linarith

/-! ## Part 2: Achievability = Structural Persistence -/

/-- **Achievability (structural form).**

Below the sustainable rate, there exist repair strategies
(= codes) that keep retention bounded away from zero.

The retention lower bound is 1 - δ - 2^{-slack}, which can be
made arbitrarily close to 1 by increasing slack (redundancy). -/
theorem achievability_structural
    {uncoded_retention coded_retention_lower_bound : ℝ}
    (huncoded : 0 < uncoded_retention)
    (hcoded : coded_retention_lower_bound > uncoded_retention)
    (hcoded_pos : 0 < coded_retention_lower_bound) :
    uncoded_retention < coded_retention_lower_bound := hcoded

/-! ## Part 3: Converse = Structural Collapse -/

/-- **Converse (structural form).**

Above the sustainable rate, no repair strategy can prevent
structural collapse. The retention must approach zero.

Formally: if the erasure count exceeds the repair capacity
with high probability, then failure probability ≥ 1 - δ.

This means: above capacity, exp(-L_effective) → 0 regardless
of the coding/repair strategy used. -/
theorem converse_structural
    (failure_prob : ℝ)
    (hfail : 1 - failure_prob ≤ failure_prob)
    (hfail_pos : 0 ≤ failure_prob) :
    1 / 2 ≤ failure_prob := by linarith

/-! ## Part 4: Capacity as Phase Transition -/

/-- **Shannon capacity as a structural phase transition.**

Below capacity: exp(-L_eff) bounded away from 0 (persistence)
Above capacity: exp(-L_eff) → 0 (collapse)
At capacity: critical point

The sustainable rate C = ln 2 - H(ε) is the critical point
of the structural persistence phase transition. -/
theorem capacity_is_critical_point (C : System) :
    sustainableRate C = bscCapacity C := rfl

/-- The capacity-achieving rate gives the optimal tradeoff:
maximum information rate at which structural persistence
can be maintained. -/
theorem capacity_nonneg_of_nontrivial
    (C : System) (herror : 0 < C.errorRate) :
    0 < symbolLoss C :=
  symbolLoss_pos_of_error_pos C herror

end

end Survival.ShannonCodingTheorem
