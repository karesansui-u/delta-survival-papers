import Survival.SATDriftLowerBound
import Survival.KSATBernoulliTemplate
import Survival.NAESATBernoulliTemplate
import Survival.XORSATBernoulliTemplate
import Survival.QColoringBernoulliTemplate
import Survival.ForbiddenPatternCSPTemplate

/-!
# Numerical Sanity Checks

This module collects small concrete checks for the generic CSP wrappers.

The role is analogous to software unit tests: these are not new theorems or
empirical support, but reader-facing guardrails showing that the abstract
interfaces recover familiar constants in small instances.
-/

namespace Survival.NumericalSanityChecks

noncomputable section

/-- Random 3-SAT recovers the familiar per-clause drift `log (8/7)`. -/
theorem random3SAT_drift_sanity :
    SATDriftLowerBound.random3ClauseDrift = Real.log (8 / 7 : ℝ) :=
  SATDriftLowerBound.random3ClauseDrift_eq_log

/-- The `k = 3` k-SAT Bernoulli wrapper recovers `log (8/7)`. -/
theorem kSAT3_drift_sanity :
    KSATBernoulliTemplate.kSATDrift 3 (by norm_num) =
      Real.log (8 / 7 : ℝ) := by
  unfold KSATBernoulliTemplate.kSATDrift
    KSATBernoulliTemplate.kSATParameters
    BernoulliCSPTemplate.Parameters.drift
    KSATBernoulliTemplate.kSATBadProb
  norm_num

/-- The `k = 3` NAE-SAT Bernoulli wrapper recovers `log (4/3)`. -/
theorem naeSAT3_drift_sanity :
    NAESATBernoulliTemplate.naeSATDrift 3 (by norm_num) =
      Real.log (4 / 3 : ℝ) := by
  unfold NAESATBernoulliTemplate.naeSATDrift
    NAESATBernoulliTemplate.naeSATParameters
    BernoulliCSPTemplate.Parameters.drift
    NAESATBernoulliTemplate.naeSATBadProb
  norm_num

/-- The XOR-SAT Bernoulli wrapper recovers `log 2`. -/
theorem xorSAT_drift_sanity (k : ℕ) :
    XORSATBernoulliTemplate.xorSATDrift k = Real.log 2 :=
  XORSATBernoulliTemplate.xorSATDrift_eq_log_two k

/-- Two-coloring edge exposure recovers `log 2`. -/
theorem qColoring2_drift_sanity :
    QColoringBernoulliTemplate.qColoringDrift 2 (by norm_num) =
      Real.log 2 := by
  rw [QColoringBernoulliTemplate.qColoringDrift_eq_log_ratio]
  norm_num

/-- A binary arity-3 forbidden-pattern wrapper with one forbidden pattern
recovers the random 3-SAT drift `log (8/7)`. -/
theorem forbiddenPattern_2_3_1_drift_sanity :
    ForbiddenPatternCSPTemplate.forbiddenPatternDrift
        2 1 3 (by norm_num) (by norm_num) (by norm_num) =
      Real.log (8 / 7 : ℝ) := by
  rw [ForbiddenPatternCSPTemplate.forbiddenPatternDrift_eq_log_ratio]
  norm_num

end

end Survival.NumericalSanityChecks
