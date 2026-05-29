import Survival.BernoulliCSPTemplate

/-!
# XOR-SAT Bernoulli Template

This module instantiates the generic Bernoulli-CSP template for fixed-assignment
random `k`-XOR-SAT exposure.

For a fixed assignment, a uniformly random XOR equation with a uniformly random
right-hand side is violated with probability `1 / 2`.  This is intentionally
only the Bernoulli bad-event exposure layer; rank/nullity dynamics of the full
linear system are outside this module.
-/

namespace Survival.XORSATBernoulliTemplate

open Survival.BernoulliCSPTemplate

noncomputable section

/-- Bad-equation probability for random `k`-XOR-SAT under a fixed assignment. -/
def xorSATBadProb (_k : ℕ) : ℝ :=
  (1 / 2 : ℝ)

theorem xorSATBadProb_pos (k : ℕ) :
    0 < xorSATBadProb k := by
  unfold xorSATBadProb
  norm_num

theorem xorSATBadProb_lt_one (k : ℕ) :
    xorSATBadProb k < 1 := by
  unfold xorSATBadProb
  norm_num

/-- Bernoulli-CSP parameters for fixed-assignment random `k`-XOR-SAT exposure. -/
def xorSATParameters (k : ℕ) : Parameters where
  badProb := xorSATBadProb k
  badProb_pos := xorSATBadProb_pos k
  badProb_lt_one := xorSATBadProb_lt_one k

theorem xorSATParameters_badProb (k : ℕ) :
    (xorSATParameters k).badProb = xorSATBadProb k := rfl

/-- Random `k`-XOR-SAT exposure drift in the Bernoulli-CSP template. -/
def xorSATDrift (k : ℕ) : ℝ :=
  (xorSATParameters k).drift

theorem xorSATDrift_eq_log_two (k : ℕ) :
    xorSATDrift k = Real.log 2 := by
  unfold xorSATDrift xorSATParameters Parameters.drift xorSATBadProb
  norm_num

theorem xorSATDrift_pos (k : ℕ) :
    0 < xorSATDrift k :=
  (xorSATParameters k).drift_pos

/-- Random `k`-XOR-SAT one-sided emission scale.  Since the bad-event
probability is `1 / 2`, bad equations emit `2 * log 2`. -/
def xorSATBadEmissionScale (k : ℕ) : ℝ :=
  (xorSATParameters k).badEmissionScale

theorem xorSATBadEmissionScale_eq_two_mul_log_two (k : ℕ) :
    xorSATBadEmissionScale k = 2 * Real.log 2 := by
  unfold xorSATBadEmissionScale xorSATParameters Parameters.badEmissionScale
    Parameters.drift xorSATBadProb
  norm_num
  ring

theorem xorSATBadEmissionScale_pos (k : ℕ) :
    0 < xorSATBadEmissionScale k :=
  (xorSATParameters k).badEmissionScale_pos

theorem xorSAT_expectedBadEmission_eq_drift (k : ℕ) :
    xorSATBadProb k * xorSATBadEmissionScale k = xorSATDrift k := by
  exact (xorSATParameters k).expectedBadEmission_eq_drift

/-- The generic interior KL/Chernoff identity specialized to random
`k`-XOR-SAT bad-event exposure. -/
theorem xorSAT_optimizedClosedMGFReal_failure_eq_chernoffFailureBound_of_interior
    (k : ℕ) {n : ℕ} {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * xorSATDrift k) :
    ENNReal.ofReal ((xorSATParameters k).optimizedClosedMGFReal n r) =
      (xorSATParameters k).chernoffFailureBound n r := by
  exact
    (xorSATParameters k).optimizedClosedMGFReal_failure_eq_chernoffFailureBound_of_interior
      hr hlt

end

end Survival.XORSATBernoulliTemplate
