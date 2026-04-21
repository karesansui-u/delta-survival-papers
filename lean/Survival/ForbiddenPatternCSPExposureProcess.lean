import Survival.BernoulliCSPPathMeasure
import Survival.ForbiddenPatternCSPTemplate

/-!
# Forbidden-Pattern CSP Exposure Process

This module specializes the reusable Bernoulli-CSP path-space layer to the
generic finite-alphabet forbidden-pattern exposure model.
-/

open scoped ProbabilityTheory

namespace Survival.ForbiddenPatternCSPExposureProcess

open MeasureTheory
open ProbabilityTheory
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.ForbiddenPatternCSPTemplate

noncomputable section

/-- Bernoulli MGF for the bad-pattern indicator. -/
def forbiddenPatternBadMGF
    (alphabet forbidden : ℝ) (arity : ℕ) (t : ℝ) : ℝ :=
  bernoulliBadMGF (forbiddenPatternBadProb alphabet forbidden arity) t

/-- Finite-horizon forbidden-pattern exposure path PMF. -/
def pathPMF
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) (N : ℕ) :
    PMF (Trajectory N) :=
  BernoulliCSPPathMeasure.pathPMF
    (forbiddenPatternParameters alphabet forbidden arity ha hf hlt) N

/-- The corresponding finite-horizon probability measure. -/
def pathMeasure
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) (N : ℕ) :
    Measure (Trajectory N) :=
  BernoulliCSPPathMeasure.pathMeasure
    (forbiddenPatternParameters alphabet forbidden arity ha hf hlt) N

instance instIsProbabilityMeasurePathMeasure
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) (N : ℕ) :
    IsProbabilityMeasure
      (pathMeasure alphabet forbidden arity ha hf hlt N) := by
  dsimp [pathMeasure]
  infer_instance

/-- Real-valued active-prefix bad-pattern count. -/
def badCountRV
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) (N n : ℕ) :
    Trajectory N → ℝ :=
  BernoulliCSPPathMeasure.badCountRV
    (forbiddenPatternParameters alphabet forbidden arity ha hf hlt) N n

/-- Exact Bernoulli-product MGF for the active-prefix bad-pattern count. -/
theorem mgf_badCountRV_eq_forbiddenPatternBadMGF_pow
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) (N : ℕ) (t : ℝ) :
    ∀ ⦃n : ℕ⦄, n ≤ N + 1 →
      mgf
          (badCountRV alphabet forbidden arity ha hf hlt N n)
          (pathMeasure alphabet forbidden arity ha hf hlt N) t =
        forbiddenPatternBadMGF alphabet forbidden arity t ^ n := by
  intro n hn
  change
    mgf
        (BernoulliCSPPathMeasure.badCountRV
          (forbiddenPatternParameters alphabet forbidden arity ha hf hlt) N n)
        (BernoulliCSPPathMeasure.pathMeasure
          (forbiddenPatternParameters alphabet forbidden arity ha hf hlt) N) t =
      bernoulliBadMGF (forbiddenPatternBadProb alphabet forbidden arity) t ^ n
  simpa [forbiddenPatternBadMGF, forbiddenPatternParameters_badProb] using
    BernoulliCSPPathMeasure.mgf_badCountRV_eq_bernoulliBadMGF_pow
      (forbiddenPatternParameters alphabet forbidden arity ha hf hlt) N t hn

/-- Closed Bernoulli MGF witness generated directly by the forbidden-pattern
path PMF. -/
theorem hasBernoulliMGFUpperBound_pathPMF
    (alphabet forbidden : ℝ) (arity : ℕ)
    (ha : 0 < alphabet) (hf : 0 < forbidden)
    (hlt : forbidden < alphabet ^ arity) (N : ℕ) (t : ℝ) :
    ∀ ⦃n : ℕ⦄, n ≤ N + 1 →
      mgf
          (badCountRV alphabet forbidden arity ha hf hlt N n)
          (pathMeasure alphabet forbidden arity ha hf hlt N) t ≤
        forbiddenPatternBadMGF alphabet forbidden arity t ^ n := by
  intro n hn
  rw [mgf_badCountRV_eq_forbiddenPatternBadMGF_pow
    alphabet forbidden arity ha hf hlt N t hn]

end

end Survival.ForbiddenPatternCSPExposureProcess
