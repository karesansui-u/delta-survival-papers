import Survival.BernoulliCSPTemplate
import Survival.KSATBernoulliTemplate
import Survival.SATStateDependentCountChernoffKLAlgebra

/-!
# Bernoulli CSP to SAT Bridge

This module records that the generic Bernoulli-CSP template really specializes
to the existing random-3-SAT Chernoff/KL stack.

The goal is bookkeeping rather than new probability: the SAT chain was built
first with concrete constants `1 / 8`, `log (8 / 7)`, and
`8 * log (8 / 7)`.  `BernoulliCSPTemplate` then abstracted the one-variable
MGF/KL algebra to an arbitrary bad-event probability `p`.  This file proves
that the generic `p = 1 / 8` parameter agrees with the older concrete SAT
definitions, so future `k`-SAT instantiations can reuse the template without
silently forking the theory.
-/

namespace Survival.BernoulliCSPToSATBridge

open Survival.BernoulliCSPTemplate
open Survival.SATDriftLowerBound
open Survival.SATStateDependentCountThreshold
open Survival.SATStateDependentCountChernoffMGF
open Survival.SATStateDependentCountChernoffUpperBound
open Survival.SATStateDependentCountChernoffKL

noncomputable section

/-- The generic Bernoulli-CSP `p = 1 / 8` drift is the existing random-3-SAT
drift. -/
theorem random3SATParameters_drift_eq_random3ClauseDrift :
    random3SATParameters.drift = random3ClauseDrift := by
  rw [random3SATParameters_drift_eq_log, random3ClauseDrift_eq_log]

/-- The generic one-sided emission scale is the existing non-flat SAT emission
scale. -/
theorem random3SATParameters_badEmissionScale_eq_unsatEmissionScale :
    random3SATParameters.badEmissionScale = unsatEmissionScale := by
  rw [random3SATParameters_badEmissionScale_eq]
  unfold unsatEmissionScale
  rw [random3ClauseDrift_eq_log]

/-- The generic Bernoulli relative entropy is the older SAT KL candidate when
`p = 1 / 8`. -/
theorem random3SATParameters_relativeEntropy_eq_candidate
    (q : ℝ) :
    bernoulliRelativeEntropy q random3SATParameters.badProb =
      bernoulliRelativeEntropyCandidate q (1 / 8 : ℝ) := by
  norm_num [random3SATParameters, bernoulliRelativeEntropy,
    bernoulliRelativeEntropyCandidate]

/-- The generic Bernoulli MGF is the older SAT unsatisfied-count one-step MGF. -/
theorem random3SATParameters_bernoulliBadMGF_eq_bernoulliUnsatMGF
    (t : ℝ) :
    bernoulliBadMGF random3SATParameters.badProb t =
      bernoulliUnsatMGF t := by
  norm_num [random3SATParameters, bernoulliBadMGF, bernoulliUnsatMGF]

/-- The generic lower-tail tilt is the older SAT-specialized lower-tail tilt. -/
theorem random3SATParameters_lowerTailTilt_eq_satLowerTailTilt
    (q : ℝ) :
    BernoulliCSPTemplate.bernoulliLowerTailTilt q random3SATParameters.badProb =
      satLowerTailTilt q := by
  simp [random3SATParameters, BernoulliCSPTemplate.bernoulliLowerTailTilt,
    satLowerTailTilt, SATStateDependentCountChernoffKL.bernoulliLowerTailTilt]

/-- The generic clipped lower-tail tilt is the older SAT clipped tilt. -/
theorem random3SATParameters_clippedLowerTailTilt_eq_clippedSatLowerTailTilt
    (q : ℝ) :
    clippedLowerTailTilt q random3SATParameters.badProb =
      clippedSatLowerTailTilt q := by
  unfold clippedLowerTailTilt clippedSatLowerTailTilt
  rw [random3SATParameters_lowerTailTilt_eq_satLowerTailTilt]

/-- The generic Bernoulli-CSP count threshold is the older SAT count threshold. -/
theorem random3SATParameters_countThreshold_eq_countThreshold
    (n : ℕ) (r : ℝ) :
    random3SATParameters.countThreshold n r = countThreshold n r := by
  unfold BernoulliCSPTemplate.Parameters.countThreshold countThreshold
  rw [random3SATParameters_drift_eq_random3ClauseDrift,
    random3SATParameters_badEmissionScale_eq_unsatEmissionScale]

/-- The generic threshold ratio is the older SAT count-threshold ratio. -/
theorem random3SATParameters_thresholdRatio_eq_countThresholdRatio
    (n : ℕ) (r : ℝ) :
    random3SATParameters.thresholdRatio n r =
      countThresholdRatio n r := by
  unfold BernoulliCSPTemplate.Parameters.thresholdRatio countThresholdRatio
  rw [random3SATParameters_countThreshold_eq_countThreshold]

/-- The generic optimized tilt is the older SAT count-dependent optimized tilt. -/
theorem random3SATParameters_optimizingTilt_eq_countOptimizingTilt
    (n : ℕ) (r : ℝ) :
    random3SATParameters.optimizingTilt n r =
      countOptimizingTilt n r := by
  unfold BernoulliCSPTemplate.Parameters.optimizingTilt countOptimizingTilt
  rw [random3SATParameters_thresholdRatio_eq_countThresholdRatio,
    random3SATParameters_clippedLowerTailTilt_eq_clippedSatLowerTailTilt]

/-- The generic Chernoff/KL rate is the older SAT count Chernoff rate. -/
theorem random3SATParameters_chernoffRate_eq_countChernoffRate
    (n : ℕ) (r : ℝ) :
    random3SATParameters.chernoffRate n r =
      countChernoffRate n r := by
  by_cases hn : n = 0
  · simp [BernoulliCSPTemplate.Parameters.chernoffRate, countChernoffRate,
      hn]
  · simp [BernoulliCSPTemplate.Parameters.chernoffRate, countChernoffRate,
      hn, random3SATParameters_thresholdRatio_eq_countThresholdRatio,
      random3SATParameters_relativeEntropy_eq_candidate]

/-- The generic Chernoff/KL failure profile is the older SAT count Chernoff
failure profile. -/
theorem random3SATParameters_chernoffFailureBound_eq_countChernoffFailureBound
    (n : ℕ) (r : ℝ) :
    random3SATParameters.chernoffFailureBound n r =
      countChernoffFailureBound n r := by
  unfold BernoulliCSPTemplate.Parameters.chernoffFailureBound
    countChernoffFailureBound
  unfold Survival.ConcentrationInterface.largeDeviationFailureBound
  rw [random3SATParameters_chernoffRate_eq_countChernoffRate]

/-- The generic optimized closed-MGF real expression is the real expression
inside the older SAT optimized closed-MGF profile. -/
theorem random3SATParameters_optimizedClosedMGFReal_eq_satReal
    (n : ℕ) (r : ℝ) :
    random3SATParameters.optimizedClosedMGFReal n r =
      Real.exp (-(countOptimizingTilt n r) * countThreshold n r) *
        bernoulliUnsatMGF (countOptimizingTilt n r) ^ n := by
  unfold BernoulliCSPTemplate.Parameters.optimizedClosedMGFReal
  rw [random3SATParameters_optimizingTilt_eq_countOptimizingTilt,
    random3SATParameters_countThreshold_eq_countThreshold,
    random3SATParameters_bernoulliBadMGF_eq_bernoulliUnsatMGF]

/-- ENNReal form: the generic optimized closed-MGF profile is exactly the older
SAT optimized closed-MGF profile. -/
theorem random3SATParameters_optimizedClosedMGFReal_eq_countOptimizedClosedMGF
    (n : ℕ) (r : ℝ) :
    ENNReal.ofReal (random3SATParameters.optimizedClosedMGFReal n r) =
      countOptimizedClosedMGFChernoffFailureBound n r := by
  unfold countOptimizedClosedMGFChernoffFailureBound
    countClosedMGFChernoffFailureBound
  rw [random3SATParameters_optimizedClosedMGFReal_eq_satReal]

/-- Therefore the generic Bernoulli-CSP interior KL identity specializes to the
existing SAT Chernoff/KL failure profile. -/
theorem random3SATParameters_generic_failure_eq_countChernoffFailureBound_of_interior
    {n : ℕ} {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * random3ClauseDrift) :
    ENNReal.ofReal (random3SATParameters.optimizedClosedMGFReal n r) =
      countChernoffFailureBound n r := by
  have hlt_generic : r < (n : ℝ) * random3SATParameters.drift := by
    rwa [random3SATParameters_drift_eq_random3ClauseDrift]
  rw [random3SATParameters.optimizedClosedMGFReal_failure_eq_chernoffFailureBound_of_interior
    hr hlt_generic]
  exact random3SATParameters_chernoffFailureBound_eq_countChernoffFailureBound n r

end

end Survival.BernoulliCSPToSATBridge
