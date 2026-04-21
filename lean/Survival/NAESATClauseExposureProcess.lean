import Survival.BernoulliCSPPathMeasure
import Survival.NAESATBernoulliTemplate

/-!
# NAE-SAT Clause-Exposure Process

This module specializes the reusable Bernoulli-CSP path-space layer to
fixed-assignment random `k`-NAE-SAT clause exposure.
-/

open scoped ProbabilityTheory

namespace Survival.NAESATClauseExposureProcess

open MeasureTheory
open ProbabilityTheory
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.NAESATBernoulliTemplate

noncomputable section

/-- Bernoulli MGF for the bad-clause indicator in random `k`-NAE-SAT. -/
def naeSATBadMGF (k : ℕ) (t : ℝ) : ℝ :=
  bernoulliBadMGF (naeSATBadProb k) t

/-- Finite-horizon random `k`-NAE-SAT clause-exposure path PMF. -/
def pathPMF (k : ℕ) (hk : 1 < k) (N : ℕ) :
    PMF (Trajectory N) :=
  BernoulliCSPPathMeasure.pathPMF (naeSATParameters k hk) N

/-- The corresponding finite-horizon probability measure. -/
def pathMeasure (k : ℕ) (hk : 1 < k) (N : ℕ) :
    Measure (Trajectory N) :=
  BernoulliCSPPathMeasure.pathMeasure (naeSATParameters k hk) N

instance instIsProbabilityMeasurePathMeasure
    (k : ℕ) (hk : 1 < k) (N : ℕ) :
    IsProbabilityMeasure (pathMeasure k hk N) := by
  dsimp [pathMeasure]
  infer_instance

/-- Real-valued active-prefix bad-clause count. -/
def badCountRV (k : ℕ) (hk : 1 < k) (N n : ℕ) :
    Trajectory N → ℝ :=
  BernoulliCSPPathMeasure.badCountRV (naeSATParameters k hk) N n

/-- Exact Bernoulli-product MGF for the active-prefix bad-clause count. -/
theorem mgf_badCountRV_eq_naeSATBadMGF_pow
    (k : ℕ) (hk : 1 < k) (N : ℕ) (t : ℝ) :
    ∀ ⦃n : ℕ⦄, n ≤ N + 1 →
      mgf (badCountRV k hk N n) (pathMeasure k hk N) t =
        naeSATBadMGF k t ^ n := by
  intro n hn
  change
    mgf
        (BernoulliCSPPathMeasure.badCountRV (naeSATParameters k hk) N n)
        (BernoulliCSPPathMeasure.pathMeasure (naeSATParameters k hk) N) t =
      bernoulliBadMGF (naeSATBadProb k) t ^ n
  simpa [naeSATBadMGF, naeSATParameters_badProb] using
    BernoulliCSPPathMeasure.mgf_badCountRV_eq_bernoulliBadMGF_pow
      (naeSATParameters k hk) N t hn

/-- Closed Bernoulli MGF witness generated directly by the random `k`-NAE-SAT
path PMF. -/
theorem hasBernoulliMGFUpperBound_pathPMF
    (k : ℕ) (hk : 1 < k) (N : ℕ) (t : ℝ) :
    ∀ ⦃n : ℕ⦄, n ≤ N + 1 →
      mgf (badCountRV k hk N n) (pathMeasure k hk N) t ≤
        naeSATBadMGF k t ^ n := by
  intro n hn
  rw [mgf_badCountRV_eq_naeSATBadMGF_pow k hk N t hn]

/-- The `k = 3` Bernoulli MGF is `3/4 + (1/4) exp t`. -/
theorem threeNAESAT_naeSATBadMGF_eq (t : ℝ) :
    naeSATBadMGF 3 t = (3 / 4 : ℝ) + (1 / 4 : ℝ) * Real.exp t := by
  unfold naeSATBadMGF bernoulliBadMGF naeSATBadProb
  norm_num

end

end Survival.NAESATClauseExposureProcess
