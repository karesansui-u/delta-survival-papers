import Survival.BernoulliTypicalSigma

/-!
# Bernoulli Admissible Map V0

This file packages the Phase-4 coarse-transfer hypotheses into a small
reader-facing interface for the Bernoulli-CSP template.

The interface is deliberately narrow.  It is a *sufficient* readout-level
compatibility condition, not a necessary-and-sufficient characterization of all
admissible maps.  It says that a coarse Bernoulli `Σ` readout is usable by the
Phase-4 certificates when it supplies:

* a terminal endpoint-defect identity;
* an endpoint-defect budget;
* fixed-time coarse monotonicity.

Under those three assumptions, the existing Bernoulli `Σ` lower-bound and
typical-growth certificates transfer to the coarse readout with the explicit
defect penalty.
-/

namespace Survival.BernoulliAdmissibleMapV0

open MeasureTheory
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.BernoulliTypicalSigma

noncomputable section

/-- A minimal sufficient readout-level compatibility package for the
Bernoulli-CSP fixed-time coarse `Σ` certificates.

This is the Phase-5 v0 interface.  It is intentionally weaker than a full
admissible-map characterization: it only records the endpoint equality,
endpoint defect budget, and coarse monotonicity needed to invoke the Phase-4.4
transfer theorems. -/
structure BernoulliCoarseReadoutV0
    (P : Parameters) (N : ℕ) (s₀ : ℝ) (n : ℕ)
    (δ : ℝ) (coarseSigma0 coarseSigmaN : Trajectory N → ℝ) where
  /-- Initial endpoint saturation defect. -/
  e0 : ℝ
  /-- Terminal endpoint saturation defect. -/
  en : ℝ
  /-- Terminal coarse readout equals the micro terminal readout plus the
  endpoint defect difference. -/
  terminal_eq :
    ∀ τ, coarseSigmaN τ = bernoulliSigma P s₀ τ n + e0 - en
  /-- The terminal endpoint defect exceeds the initial defect by at most the
  penalty budget `δ`. -/
  endpoint_defect_budget : en - e0 ≤ δ
  /-- Coarse fixed-time monotonicity supplied by the readout. -/
  coarse_monotone : ∀ τ, coarseSigma0 τ ≤ coarseSigmaN τ

namespace BernoulliCoarseReadoutV0

/-- The v0 readout package gives the terminal lower-bound transfer used by the
Phase-4.4 coarse certificates. -/
theorem terminal_lower_bound
    {P : Parameters} {N n : ℕ} {s₀ δ : ℝ}
    {coarseSigma0 coarseSigmaN : Trajectory N → ℝ}
    (H : BernoulliCoarseReadoutV0
      P N s₀ n δ coarseSigma0 coarseSigmaN) :
    ∀ τ, bernoulliSigma P s₀ τ n - δ ≤ coarseSigmaN τ := by
  intro τ
  exact
    terminalDefectBudget_terminal_lower_bound
      (H.terminal_eq τ)
      H.endpoint_defect_budget

/-- Transfer any micro Bernoulli lower-bound certificate through a v0 coarse
readout. -/
theorem lowerBoundWithFailureBound_of_micro
    {P : Parameters} {N n : ℕ} {s₀ r δ : ℝ} {ε : ENNReal}
    {coarseSigma0 coarseSigmaN : Trajectory N → ℝ}
    (H : BernoulliCoarseReadoutV0
      P N s₀ n δ coarseSigma0 coarseSigmaN)
    (hmicro : BernoulliSigmaLowerBoundWithFailureBound P N s₀ n r ε) :
    CoarseBernoulliSigmaLowerBoundWithFailureBound
      P N s₀ n r δ ε coarseSigmaN := by
  exact
    coarseBernoulliSigma_lowerBoundWithFailureBound_of_micro_defectBudget
      P N hmicro (terminal_lower_bound H)

/-- Interior Chernoff lower-bound transfer through a v0 coarse readout. -/
theorem lowerBoundWithChernoffBound_of_interior
    {P : Parameters} {N n : ℕ} (hn : n ≤ N + 1) {s₀ r δ : ℝ}
    {coarseSigma0 coarseSigmaN : Trajectory N → ℝ}
    (H : BernoulliCoarseReadoutV0
      P N s₀ n δ coarseSigma0 coarseSigmaN)
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift) :
    CoarseBernoulliSigmaLowerBoundWithFailureBound
      P N s₀ n r δ (P.chernoffFailureBound n r) coarseSigmaN := by
  exact
    coarseBernoulliSigma_lowerBoundWithChernoffBound_of_endpointDefectBudget
      P N hn hr hlt H.terminal_eq H.endpoint_defect_budget

/-- Transfer any micro Bernoulli lower-bound certificate to a v0 coarse
fixed-time typical-growth certificate. -/
theorem typicalGrowthWithFailureBound_of_micro
    {P : Parameters} {N n : ℕ} {s₀ r δ : ℝ} {ε : ENNReal}
    {coarseSigma0 coarseSigmaN : Trajectory N → ℝ}
    (H : BernoulliCoarseReadoutV0
      P N s₀ n δ coarseSigma0 coarseSigmaN)
    (hmicro : BernoulliSigmaLowerBoundWithFailureBound P N s₀ n r ε) :
    CoarseBernoulliSigmaTypicalGrowthWithFailureBound
      P N s₀ n r δ ε coarseSigma0 coarseSigmaN := by
  exact
    coarseBernoulliSigma_typicalGrowthWithFailureBound_of_micro_defectBudget
      P N hmicro H.coarse_monotone (terminal_lower_bound H)

/-- Interior Chernoff fixed-time typical-growth transfer through a v0 coarse
readout. -/
theorem typicalGrowthWithChernoffBound_of_interior
    {P : Parameters} {N n : ℕ} (hn : n ≤ N + 1) {s₀ r δ : ℝ}
    {coarseSigma0 coarseSigmaN : Trajectory N → ℝ}
    (H : BernoulliCoarseReadoutV0
      P N s₀ n δ coarseSigma0 coarseSigmaN)
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift) :
    CoarseBernoulliSigmaTypicalGrowthWithFailureBound
      P N s₀ n r δ (P.chernoffFailureBound n r)
      coarseSigma0 coarseSigmaN := by
  exact
    coarseBernoulliSigma_typicalGrowthWithChernoffBound_of_endpointDefectBudget
      P N hn hr hlt H.coarse_monotone H.terminal_eq
      H.endpoint_defect_budget

end BernoulliCoarseReadoutV0

end

end Survival.BernoulliAdmissibleMapV0
