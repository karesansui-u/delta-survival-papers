import Survival.BernoulliCSPTemplate

/-!
# NAE-SAT Bernoulli Template

This module instantiates the generic Bernoulli-CSP template for fixed-assignment
random `k`-NAE-SAT exposure.

For a fixed assignment, a uniformly random signed `k`-clause is not-all-equal
unsatisfied exactly when all exposed literals have the same truth value.  The
bad-event probability is therefore `2 / 2^k = (1 / 2)^(k - 1)`, for `k ≥ 2`.
-/

namespace Survival.NAESATBernoulliTemplate

open Survival.BernoulliCSPTemplate

noncomputable section

/-- Bad-clause probability for random `k`-NAE-SAT under a fixed assignment. -/
def naeSATBadProb (k : ℕ) : ℝ :=
  (1 / 2 : ℝ) ^ (k - 1)

theorem naeSATBadProb_pos (k : ℕ) :
    0 < naeSATBadProb k := by
  unfold naeSATBadProb
  exact pow_pos (by norm_num) (k - 1)

theorem naeSATBadProb_lt_one {k : ℕ} (hk : 1 < k) :
    naeSATBadProb k < 1 := by
  unfold naeSATBadProb
  have hk1 : 0 < k - 1 := Nat.sub_pos_of_lt hk
  exact pow_lt_one₀
    (by norm_num : 0 ≤ (1 / 2 : ℝ))
    (by norm_num : (1 / 2 : ℝ) < 1)
    (Nat.ne_of_gt hk1)

/-- Bernoulli-CSP parameters for random `k`-NAE-SAT. -/
def naeSATParameters (k : ℕ) (hk : 1 < k) : Parameters where
  badProb := naeSATBadProb k
  badProb_pos := naeSATBadProb_pos k
  badProb_lt_one := naeSATBadProb_lt_one hk

theorem naeSATParameters_badProb
    (k : ℕ) (hk : 1 < k) :
    (naeSATParameters k hk).badProb = naeSATBadProb k := rfl

/-- Random `k`-NAE-SAT drift in the Bernoulli-CSP template. -/
def naeSATDrift (k : ℕ) (hk : 1 < k) : ℝ :=
  (naeSATParameters k hk).drift

theorem naeSATDrift_eq_log
    (k : ℕ) (hk : 1 < k) :
    naeSATDrift k hk =
      Real.log (1 / (1 - (1 / 2 : ℝ) ^ (k - 1))) := by
  rfl

theorem naeSATDrift_pos
    (k : ℕ) (hk : 1 < k) :
    0 < naeSATDrift k hk :=
  (naeSATParameters k hk).drift_pos

/-- Random `k`-NAE-SAT one-sided emission scale. -/
def naeSATBadEmissionScale (k : ℕ) (hk : 1 < k) : ℝ :=
  (naeSATParameters k hk).badEmissionScale

theorem naeSATBadEmissionScale_pos
    (k : ℕ) (hk : 1 < k) :
    0 < naeSATBadEmissionScale k hk :=
  (naeSATParameters k hk).badEmissionScale_pos

theorem naeSAT_expectedBadEmission_eq_drift
    (k : ℕ) (hk : 1 < k) :
    naeSATBadProb k * naeSATBadEmissionScale k hk = naeSATDrift k hk := by
  exact (naeSATParameters k hk).expectedBadEmission_eq_drift

/-- The generic interior KL/Chernoff identity specialized to random
`k`-NAE-SAT. -/
theorem naeSAT_optimizedClosedMGFReal_failure_eq_chernoffFailureBound_of_interior
    (k : ℕ) (hk : 1 < k) {n : ℕ} {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * naeSATDrift k hk) :
    ENNReal.ofReal ((naeSATParameters k hk).optimizedClosedMGFReal n r) =
      (naeSATParameters k hk).chernoffFailureBound n r := by
  exact
    (naeSATParameters k hk).optimizedClosedMGFReal_failure_eq_chernoffFailureBound_of_interior
      hr hlt

/-- The `k = 3` NAE-SAT specialization. -/
def naeSAT3Parameters : Parameters :=
  naeSATParameters 3 (by norm_num)

theorem naeSAT3Parameters_badProb_eq :
    naeSAT3Parameters.badProb = (1 / 4 : ℝ) := by
  norm_num [naeSAT3Parameters, naeSATParameters, naeSATBadProb]

theorem naeSAT3Parameters_drift_eq_log :
    naeSAT3Parameters.drift = Real.log (4 / 3 : ℝ) := by
  unfold naeSAT3Parameters naeSATParameters Parameters.drift naeSATBadProb
  norm_num

end

end Survival.NAESATBernoulliTemplate
