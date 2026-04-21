import Survival.BernoulliCSPTemplate

/-!
# k-SAT Bernoulli Template

This module instantiates the generic Bernoulli CSP template for random `k`-SAT.

For a fixed assignment, a uniformly random `k`-clause is falsified with
probability `(1 / 2)^k`.  The previous module already proves the MGF/KL
Chernoff algebra for any bad-event probability `p ∈ (0, 1)`, so this file only
packages the `k`-SAT parameter choice and checks that `k = 3` recovers the
existing random-3-SAT constants.
-/

namespace Survival.KSATBernoulliTemplate

open Survival.BernoulliCSPTemplate

noncomputable section

/-- Bad-clause probability for random `k`-SAT under a fixed assignment. -/
def kSATBadProb (k : ℕ) : ℝ :=
  (1 / 2 : ℝ) ^ k

theorem kSATBadProb_pos (k : ℕ) :
    0 < kSATBadProb k := by
  unfold kSATBadProb
  exact pow_pos (by norm_num) k

theorem kSATBadProb_lt_one {k : ℕ} (hk : 0 < k) :
    kSATBadProb k < 1 := by
  unfold kSATBadProb
  exact pow_lt_one₀
    (by norm_num : 0 ≤ (1 / 2 : ℝ))
    (by norm_num : (1 / 2 : ℝ) < 1)
    (Nat.ne_of_gt hk)

/-- Bernoulli-CSP parameters for random `k`-SAT. -/
def kSATParameters (k : ℕ) (hk : 0 < k) : Parameters where
  badProb := kSATBadProb k
  badProb_pos := kSATBadProb_pos k
  badProb_lt_one := kSATBadProb_lt_one hk

theorem kSATParameters_badProb
    (k : ℕ) (hk : 0 < k) :
    (kSATParameters k hk).badProb = kSATBadProb k := rfl

/-- Random `k`-SAT drift in the Bernoulli-CSP template. -/
def kSATDrift (k : ℕ) (hk : 0 < k) : ℝ :=
  (kSATParameters k hk).drift

theorem kSATDrift_eq_log
    (k : ℕ) (hk : 0 < k) :
    kSATDrift k hk =
      Real.log (1 / (1 - (1 / 2 : ℝ) ^ k)) := by
  rfl

theorem kSATDrift_pos
    (k : ℕ) (hk : 0 < k) :
    0 < kSATDrift k hk :=
  (kSATParameters k hk).drift_pos

/-- Random `k`-SAT one-sided emission scale: bad clauses carry
`drift / badProb`, so the expected emission is exactly the drift. -/
def kSATBadEmissionScale (k : ℕ) (hk : 0 < k) : ℝ :=
  (kSATParameters k hk).badEmissionScale

theorem kSATBadEmissionScale_pos
    (k : ℕ) (hk : 0 < k) :
    0 < kSATBadEmissionScale k hk :=
  (kSATParameters k hk).badEmissionScale_pos

theorem kSAT_expectedBadEmission_eq_drift
    (k : ℕ) (hk : 0 < k) :
    kSATBadProb k * kSATBadEmissionScale k hk = kSATDrift k hk := by
  exact (kSATParameters k hk).expectedBadEmission_eq_drift

/-- The generic interior KL/Chernoff identity specialized to random `k`-SAT. -/
theorem kSAT_optimizedClosedMGFReal_failure_eq_chernoffFailureBound_of_interior
    (k : ℕ) (hk : 0 < k) {n : ℕ} {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * kSATDrift k hk) :
    ENNReal.ofReal ((kSATParameters k hk).optimizedClosedMGFReal n r) =
      (kSATParameters k hk).chernoffFailureBound n r := by
  exact
    (kSATParameters k hk).optimizedClosedMGFReal_failure_eq_chernoffFailureBound_of_interior
      hr hlt

/-- The `k = 3` specialization used by the SAT chain. -/
def kSAT3Parameters : Parameters :=
  kSATParameters 3 (by norm_num)

theorem kSAT3Parameters_badProb_eq :
    kSAT3Parameters.badProb = random3SATParameters.badProb := by
  norm_num [kSAT3Parameters, kSATParameters, kSATBadProb,
    random3SATParameters]

theorem kSAT3Parameters_drift_eq_random3SATParameters :
    kSAT3Parameters.drift = random3SATParameters.drift := by
  rw [random3SATParameters_drift_eq_log]
  unfold kSAT3Parameters kSATParameters Parameters.drift kSATBadProb
  norm_num

theorem kSAT3Parameters_badEmissionScale_eq_random3SATParameters :
    kSAT3Parameters.badEmissionScale =
      random3SATParameters.badEmissionScale := by
  rw [random3SATParameters_badEmissionScale_eq]
  unfold kSAT3Parameters kSATParameters Parameters.badEmissionScale
    Parameters.drift kSATBadProb
  norm_num
  ring

end

end Survival.KSATBernoulliTemplate
