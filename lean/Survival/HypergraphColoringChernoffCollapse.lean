import Survival.MultiForbiddenPatternCSP

/-!
# Hypergraph Coloring Chernoff Collapse Bound

This module specializes the finite-alphabet forbidden-pattern CSP interface to
fixed-coloring `q`-coloring of `k`-uniform hyperedges.  A sampled hyperedge is
bad when all `k` endpoint colors coincide.  There are `q` monochromatic local
patterns among `q^k` possible color patterns, so the bad-event probability is

`q / q^k`.

The scope remains finite-horizon iid local-pattern exposure.  Random
hypergraph dependence, overlapping hyperedges, and coloring-algorithm dynamics
are separate layers.
-/

namespace Survival.HypergraphColoringChernoffCollapse

open MeasureTheory
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.BernoulliCSPPathChernoff
open Survival.BernoulliCSPPathCollapse
open Survival.ForbiddenPatternCSPTemplate
open Survival.ForbiddenPatternCSPExposureProcess
open Survival.ForbiddenPatternCSPChernoffCollapse
open Survival.MultiForbiddenPatternCSP
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Bad-event probability for fixed-coloring `q`-coloring of `k`-uniform
hyperedges. -/
def hypergraphColoringBadProb (q : ℝ) (arity : ℕ) : ℝ :=
  forbiddenPatternBadProb q q arity

theorem colorCount_pos {q : ℝ} (hq : 1 < q) :
    0 < q :=
  lt_trans zero_lt_one hq

/-- For `q > 1` and arity `k > 1`, the `q` monochromatic patterns form a
proper subset of the `q^k` local color patterns. -/
theorem monochromaticPatterns_lt_totalPatterns
    {q : ℝ} {arity : ℕ} (hq : 1 < q) (harity : 1 < arity) :
    q < q ^ arity := by
  simpa using (pow_lt_pow_right₀ hq harity : q ^ 1 < q ^ arity)

/-- Bernoulli-CSP parameters for fixed-coloring hypergraph-coloring exposure. -/
def hypergraphColoringParameters
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity) :
    Parameters :=
  forbiddenPatternParameters q q arity
    (colorCount_pos hq)
    (colorCount_pos hq)
    (monochromaticPatterns_lt_totalPatterns hq harity)

/-- Domain-combinatorial witness for fixed-coloring hypergraph-coloring
exposure.  The `q` monochromatic local color patterns are the forbidden
patterns among `q^arity` possible local color patterns. -/
def hypergraphColoringWitness
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity) :
    Witness where
  alphabet := q
  arity := arity
  forbiddenCount := q
  alphabet_pos := colorCount_pos hq
  forbiddenCount_pos := colorCount_pos hq
  forbiddenCount_lt_total := monochromaticPatterns_lt_totalPatterns hq harity

theorem hypergraphColoringParameters_eq_witnessParameters
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity) :
    hypergraphColoringParameters q arity hq harity =
      (hypergraphColoringWitness q arity hq harity).parameters := rfl

theorem hypergraphColoringParameters_badProb
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity) :
    (hypergraphColoringParameters q arity hq harity).badProb =
      hypergraphColoringBadProb q arity := rfl

theorem hypergraphColoring_badProb_eq_witness_badProb
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity) :
    hypergraphColoringBadProb q arity =
      (hypergraphColoringWitness q arity hq harity).badProb := rfl

/-- Mean one-step information-production drift for hypergraph coloring. -/
def hypergraphColoringDrift
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity) : ℝ :=
  (hypergraphColoringParameters q arity hq harity).drift

theorem hypergraphColoringDrift_eq_log_ratio
    {q : ℝ} {arity : ℕ} (hq : 1 < q) (harity : 1 < arity) :
    hypergraphColoringDrift q arity hq harity =
      Real.log (q ^ arity / (q ^ arity - q)) := by
  exact
    forbiddenPatternDrift_eq_log_ratio
      (colorCount_pos hq)
      (colorCount_pos hq)
      (monochromaticPatterns_lt_totalPatterns hq harity)

theorem hypergraphColoringDrift_pos
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity) :
    0 < hypergraphColoringDrift q arity hq harity :=
  (hypergraphColoringParameters q arity hq harity).drift_pos

theorem hypergraphColoringDrift_eq_witnessDrift
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity) :
    hypergraphColoringDrift q arity hq harity =
      (hypergraphColoringWitness q arity hq harity).drift := rfl

/-- Hypergraph-coloring Chernoff/KL count failure profile. -/
def countChernoffFailureBound
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity) :
    CountFailureProfile :=
  ForbiddenPatternCSPChernoffCollapse.countChernoffFailureBound
    q q arity
    (colorCount_pos hq)
    (colorCount_pos hq)
    (monochromaticPatterns_lt_totalPatterns hq harity)

/-- Hypergraph-coloring finite-horizon iid path measure. -/
def pathMeasure
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity)
    (N : ℕ) : Measure (Trajectory N) :=
  ForbiddenPatternCSPExposureProcess.pathMeasure
    q q arity
    (colorCount_pos hq)
    (colorCount_pos hq)
    (monochromaticPatterns_lt_totalPatterns hq harity)
    N

instance instIsProbabilityMeasurePathMeasure
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity)
    (N : ℕ) :
    IsProbabilityMeasure (pathMeasure q arity hq harity N) := by
  dsimp [pathMeasure]
  infer_instance

/-- Hypergraph-coloring cumulative-production process induced by the generic
one-sided forbidden-pattern emission. -/
def process
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity)
    (N : ℕ) (s₀ : ℝ) :=
  ForbiddenPatternCSPChernoffCollapse.process
    q q arity
    (colorCount_pos hq)
    (colorCount_pos hq)
    (monochromaticPatterns_lt_totalPatterns hq harity)
    N s₀

/-- Interior KL/Chernoff count-tail bound for fixed-coloring hypergraph
coloring exposure. -/
theorem exactCountFailureBound_le_chernoffFailureBound_of_interior
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity)
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * hypergraphColoringDrift q arity hq harity) :
    ForbiddenPatternCSPChernoffCollapse.exactCountFailureBound
        q q arity
        (colorCount_pos hq)
        (colorCount_pos hq)
        (monochromaticPatterns_lt_totalPatterns hq harity)
        N n r ≤
      countChernoffFailureBound q arity hq harity n r := by
  simpa [countChernoffFailureBound, hypergraphColoringDrift] using
    ForbiddenPatternCSPChernoffCollapse.exactCountFailureBound_le_chernoffFailureBound_of_interior
        q q arity
        (colorCount_pos hq)
        (colorCount_pos hq)
        (monochromaticPatterns_lt_totalPatterns hq harity)
        N hn hr
        (by simpa [hypergraphColoringDrift] using hlt)

/-- Fixed-time collapse for hypergraph coloring under the KL/Chernoff failure
profile. -/
theorem collapseWithChernoffBound_of_linearMargin
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity)
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * hypergraphColoringDrift q arity hq harity)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter
          (hypergraphColoringParameters q arity hq harity) s₀ n - r) :
    CollapseWithFailureBound
      (μ := pathMeasure q arity hq harity N)
      (process q arity hq harity N s₀)
      n θ
      (countChernoffFailureBound q arity hq harity n r) := by
  simpa [
    pathMeasure,
    process,
    countChernoffFailureBound,
    hypergraphColoringParameters,
  ] using
    ForbiddenPatternCSPChernoffCollapse.collapseWithChernoffBound_of_linearMargin
      q q arity
      (colorCount_pos hq)
      (colorCount_pos hq)
      (monochromaticPatterns_lt_totalPatterns hq harity)
      N hn hr (by simpa [hypergraphColoringDrift] using hlt) hθ hmargin

/-- Terminal stopped-collapse for hypergraph coloring under the KL/Chernoff
failure profile. -/
theorem stoppedCollapseWithChernoffBound_of_linearMargin
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity)
    (N : ℕ) {T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (T : ℝ) * hypergraphColoringDrift q arity hq harity)
    (hθ : 0 < θ)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter
          (hypergraphColoringParameters q arity hq harity) s₀ T - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure q arity hq harity N)
      (process q arity hq harity N s₀)
      T θ
      (countChernoffFailureBound q arity hq harity T r) := by
  simpa [
    pathMeasure,
    process,
    countChernoffFailureBound,
    hypergraphColoringParameters,
  ] using
    ForbiddenPatternCSPChernoffCollapse.stoppedCollapseWithChernoffBound_of_linearMargin
      q q arity
      (colorCount_pos hq)
      (colorCount_pos hq)
      (monochromaticPatterns_lt_totalPatterns hq harity)
      N hT hr (by simpa [hypergraphColoringDrift] using hlt) hθ hmargin

/-- Earlier threshold crossing gives a high-probability
hitting-time-before-horizon bound for hypergraph coloring. -/
theorem hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
    (q : ℝ) (arity : ℕ) (hq : 1 < q) (harity : 1 < arity)
    (N : ℕ) {j T : ℕ} (hjT : j < T)
    (hj : j ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (j : ℝ) * hypergraphColoringDrift q arity hq harity)
    (hmargin :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter
          (hypergraphColoringParameters q arity hq harity) s₀ j - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure q arity hq harity N)
      (process q arity hq harity N s₀)
      T θ
      (countChernoffFailureBound q arity hq harity j r) := by
  simpa [
    pathMeasure,
    process,
    countChernoffFailureBound,
    hypergraphColoringParameters,
  ] using
    ForbiddenPatternCSPChernoffCollapse.hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
        q q arity
        (colorCount_pos hq)
        (colorCount_pos hq)
        (monochromaticPatterns_lt_totalPatterns hq harity)
        N hjT hj hr (by simpa [hypergraphColoringDrift] using hlt) hmargin

end

end Survival.HypergraphColoringChernoffCollapse
