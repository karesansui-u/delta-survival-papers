import Survival.BernoulliCSPPathMeasure
import Survival.XORSATBernoulliTemplate

/-!
# XOR-SAT Clause-Exposure Process

This module specializes the reusable Bernoulli-CSP path-space layer to
fixed-assignment random `k`-XOR-SAT exposure.

Each exposed XOR equation is bad for the fixed assignment with probability
`1 / 2`.  The file intentionally stays at the Bernoulli exposure level and does
not model rank/nullity dynamics of the accumulated linear system.
-/

open scoped ProbabilityTheory

namespace Survival.XORSATClauseExposureProcess

open MeasureTheory
open ProbabilityTheory
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.XORSATBernoulliTemplate

noncomputable section

/-- Bernoulli MGF for the bad-equation indicator in random `k`-XOR-SAT. -/
def xorSATBadMGF (k : ℕ) (t : ℝ) : ℝ :=
  bernoulliBadMGF (xorSATBadProb k) t

/-- Finite-horizon random `k`-XOR-SAT bad-equation exposure path PMF. -/
def pathPMF (k : ℕ) (N : ℕ) :
    PMF (Trajectory N) :=
  BernoulliCSPPathMeasure.pathPMF (xorSATParameters k) N

/-- The corresponding finite-horizon probability measure. -/
def pathMeasure (k : ℕ) (N : ℕ) :
    Measure (Trajectory N) :=
  BernoulliCSPPathMeasure.pathMeasure (xorSATParameters k) N

instance instIsProbabilityMeasurePathMeasure (k : ℕ) (N : ℕ) :
    IsProbabilityMeasure (pathMeasure k N) := by
  dsimp [pathMeasure]
  infer_instance

/-- Real-valued active-prefix bad-equation count. -/
def badCountRV (k : ℕ) (N n : ℕ) :
    Trajectory N → ℝ :=
  BernoulliCSPPathMeasure.badCountRV (xorSATParameters k) N n

/-- Exact Bernoulli-product MGF for the active-prefix bad-equation count in
random `k`-XOR-SAT exposure. -/
theorem mgf_badCountRV_eq_xorSATBadMGF_pow
    (k : ℕ) (N : ℕ) (t : ℝ) :
    ∀ ⦃n : ℕ⦄, n ≤ N + 1 →
      mgf (badCountRV k N n) (pathMeasure k N) t =
        xorSATBadMGF k t ^ n := by
  intro n hn
  change
    mgf
        (BernoulliCSPPathMeasure.badCountRV (xorSATParameters k) N n)
        (BernoulliCSPPathMeasure.pathMeasure (xorSATParameters k) N) t =
      bernoulliBadMGF (xorSATBadProb k) t ^ n
  simpa [xorSATBadMGF, xorSATParameters_badProb] using
    BernoulliCSPPathMeasure.mgf_badCountRV_eq_bernoulliBadMGF_pow
      (xorSATParameters k) N t hn

/-- Closed Bernoulli MGF witness generated directly by the random `k`-XOR-SAT
path PMF. -/
theorem hasBernoulliMGFUpperBound_pathPMF
    (k : ℕ) (N : ℕ) (t : ℝ) :
    ∀ ⦃n : ℕ⦄, n ≤ N + 1 →
      mgf (badCountRV k N n) (pathMeasure k N) t ≤
        xorSATBadMGF k t ^ n := by
  intro n hn
  rw [mgf_badCountRV_eq_xorSATBadMGF_pow k N t hn]

/-- The XOR-SAT Bernoulli MGF is `1/2 + (1/2) exp t`. -/
theorem xorSATBadMGF_eq (k : ℕ) (t : ℝ) :
    xorSATBadMGF k t = (1 / 2 : ℝ) + (1 / 2 : ℝ) * Real.exp t := by
  unfold xorSATBadMGF bernoulliBadMGF xorSATBadProb
  norm_num

end

end Survival.XORSATClauseExposureProcess
