import Survival.BernoulliCSPPathMeasure
import Survival.KSATBernoulliTemplate

/-!
# k-SAT Clause-Exposure Process

This module specializes the reusable Bernoulli CSP path-space layer to random
`k`-SAT.

For a fixed assignment, a uniformly random `k`-clause is falsified with
probability `(1 / 2)^k`.  `KSATBernoulliTemplate` packages the algebraic
parameters; `BernoulliCSPPathMeasure` supplies the actual finite path PMF and
the MGF product for the bad-clause count.  This file is intentionally thin: it
is the domain-facing API for random `k`-SAT clause exposure.
-/

open scoped ProbabilityTheory

namespace Survival.KSATClauseExposureProcess

open MeasureTheory
open ProbabilityTheory
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.KSATBernoulliTemplate

noncomputable section

/-- Bernoulli MGF for the bad-clause indicator in random `k`-SAT. -/
def kSATBadMGF (k : ℕ) (t : ℝ) : ℝ :=
  bernoulliBadMGF (kSATBadProb k) t

/-- Finite-horizon random `k`-SAT clause-exposure path PMF. -/
def pathPMF (k : ℕ) (hk : 0 < k) (N : ℕ) :
    PMF (Trajectory N) :=
  BernoulliCSPPathMeasure.pathPMF (kSATParameters k hk) N

/-- The corresponding finite-horizon probability measure. -/
def pathMeasure (k : ℕ) (hk : 0 < k) (N : ℕ) :
    Measure (Trajectory N) :=
  BernoulliCSPPathMeasure.pathMeasure (kSATParameters k hk) N

instance instIsProbabilityMeasurePathMeasure
    (k : ℕ) (hk : 0 < k) (N : ℕ) :
    IsProbabilityMeasure (pathMeasure k hk N) := by
  dsimp [pathMeasure]
  infer_instance

/-- Real-valued active-prefix falsified-clause count. -/
def badCountRV (k : ℕ) (hk : 0 < k) (N n : ℕ) :
    Trajectory N → ℝ :=
  BernoulliCSPPathMeasure.badCountRV (kSATParameters k hk) N n

/-- Exact Bernoulli-product MGF for the active-prefix falsified-clause count in
random `k`-SAT. -/
theorem mgf_badCountRV_eq_kSATBadMGF_pow
    (k : ℕ) (hk : 0 < k) (N : ℕ) (t : ℝ) :
    ∀ ⦃n : ℕ⦄, n ≤ N + 1 →
      mgf (badCountRV k hk N n) (pathMeasure k hk N) t =
        kSATBadMGF k t ^ n := by
  intro n hn
  change
    mgf
        (BernoulliCSPPathMeasure.badCountRV (kSATParameters k hk) N n)
        (BernoulliCSPPathMeasure.pathMeasure (kSATParameters k hk) N) t =
      bernoulliBadMGF (kSATBadProb k) t ^ n
  simpa [kSATBadMGF, kSATParameters_badProb] using
    BernoulliCSPPathMeasure.mgf_badCountRV_eq_bernoulliBadMGF_pow
      (kSATParameters k hk) N t hn

/-- Closed Bernoulli MGF witness generated directly by the random `k`-SAT
path PMF. -/
theorem hasBernoulliMGFUpperBound_pathPMF
    (k : ℕ) (hk : 0 < k) (N : ℕ) (t : ℝ) :
    ∀ ⦃n : ℕ⦄, n ≤ N + 1 →
      mgf (badCountRV k hk N n) (pathMeasure k hk N) t ≤
        kSATBadMGF k t ^ n := by
  intro n hn
  rw [mgf_badCountRV_eq_kSATBadMGF_pow k hk N t hn]

/-- The `k = 3` path-space MGF product, as a named specialization. -/
theorem threeSAT_mgf_badCountRV_eq_pow
    (N : ℕ) (t : ℝ) :
    ∀ ⦃n : ℕ⦄, n ≤ N + 1 →
      mgf (badCountRV 3 (by norm_num) N n)
        (pathMeasure 3 (by norm_num) N) t =
        kSATBadMGF 3 t ^ n :=
  mgf_badCountRV_eq_kSATBadMGF_pow 3 (by norm_num) N t

/-- The `k = 3` Bernoulli MGF is the familiar `7/8 + (1/8) exp t`. -/
theorem threeSAT_kSATBadMGF_eq (t : ℝ) :
    kSATBadMGF 3 t = (7 / 8 : ℝ) + (1 / 8 : ℝ) * Real.exp t := by
  unfold kSATBadMGF bernoulliBadMGF kSATBadProb
  norm_num

end

end Survival.KSATClauseExposureProcess
