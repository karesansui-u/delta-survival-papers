import Survival.BernoulliCSPPathMeasure
import Survival.QColoringBernoulliTemplate

/-!
# q-Coloring Edge-Exposure Process

This module specializes the reusable Bernoulli-CSP path-space layer to a
fixed-coloring edge-exposure model.  Each exposed edge is bad when its endpoint
colors coincide; at this exposure layer the bad probability is `1 / q`.
-/

open scoped ProbabilityTheory

namespace Survival.QColoringEdgeExposureProcess

open MeasureTheory
open ProbabilityTheory
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.QColoringBernoulliTemplate

noncomputable section

/-- Bernoulli MGF for the bad-edge indicator in `q`-coloring exposure. -/
def qColoringBadMGF (q : ℝ) (t : ℝ) : ℝ :=
  bernoulliBadMGF (qColoringBadProb q) t

/-- Finite-horizon `q`-coloring bad-edge exposure path PMF. -/
def pathPMF (q : ℝ) (hq : 1 < q) (N : ℕ) :
    PMF (Trajectory N) :=
  BernoulliCSPPathMeasure.pathPMF (qColoringParameters q hq) N

/-- The corresponding finite-horizon probability measure. -/
def pathMeasure (q : ℝ) (hq : 1 < q) (N : ℕ) :
    Measure (Trajectory N) :=
  BernoulliCSPPathMeasure.pathMeasure (qColoringParameters q hq) N

instance instIsProbabilityMeasurePathMeasure (q : ℝ) (hq : 1 < q) (N : ℕ) :
    IsProbabilityMeasure (pathMeasure q hq N) := by
  dsimp [pathMeasure]
  infer_instance

/-- Real-valued active-prefix bad-edge count. -/
def badCountRV (q : ℝ) (hq : 1 < q) (N n : ℕ) :
    Trajectory N → ℝ :=
  BernoulliCSPPathMeasure.badCountRV (qColoringParameters q hq) N n

/-- Exact Bernoulli-product MGF for the active-prefix bad-edge count. -/
theorem mgf_badCountRV_eq_qColoringBadMGF_pow
    (q : ℝ) (hq : 1 < q) (N : ℕ) (t : ℝ) :
    ∀ ⦃n : ℕ⦄, n ≤ N + 1 →
      mgf (badCountRV q hq N n) (pathMeasure q hq N) t =
        qColoringBadMGF q t ^ n := by
  intro n hn
  change
    mgf
        (BernoulliCSPPathMeasure.badCountRV (qColoringParameters q hq) N n)
        (BernoulliCSPPathMeasure.pathMeasure (qColoringParameters q hq) N) t =
      bernoulliBadMGF (qColoringBadProb q) t ^ n
  simpa [qColoringBadMGF, qColoringParameters_badProb] using
    BernoulliCSPPathMeasure.mgf_badCountRV_eq_bernoulliBadMGF_pow
      (qColoringParameters q hq) N t hn

/-- Closed Bernoulli MGF witness generated directly by the `q`-coloring
edge-exposure path PMF. -/
theorem hasBernoulliMGFUpperBound_pathPMF
    (q : ℝ) (hq : 1 < q) (N : ℕ) (t : ℝ) :
    ∀ ⦃n : ℕ⦄, n ≤ N + 1 →
      mgf (badCountRV q hq N n) (pathMeasure q hq N) t ≤
        qColoringBadMGF q t ^ n := by
  intro n hn
  rw [mgf_badCountRV_eq_qColoringBadMGF_pow q hq N t hn]

/-- The `q`-coloring Bernoulli MGF is `(1 - 1/q) + (1/q) exp t`. -/
theorem qColoringBadMGF_eq (q : ℝ) (t : ℝ) :
    qColoringBadMGF q t = (1 - 1 / q) + (1 / q) * Real.exp t := by
  unfold qColoringBadMGF bernoulliBadMGF qColoringBadProb
  rfl

end

end Survival.QColoringEdgeExposureProcess
