import Mathlib.Tactic.Linarith
import Survival.BernoulliCSPPathCollapse

/-!
# Bernoulli Typical Sigma

Reader-facing wrappers for the Bernoulli-CSP total-production observable.

The existing Bernoulli path modules already prove the substantial facts:

* a one-sided cumulative production observable;
* its KL/Chernoff lower-tail bound;
* collapse and stopping-time wrappers derived from that lower tail.
* a narrow endpoint-defect transfer for coarse/readout-level terminal
  certificates.

This file gives those facts the `Σ`-oriented names used by the second-law-level
roadmap.  It is intentionally thin: it does not assert an unconditional
second-law theorem.  It says that, in the Bernoulli-CSP template, the cumulative
`Σ` observable has an interior Chernoff lower-tail certificate and monotone
expectation because its one-step emissions are nonnegative.  Coarse transfer is
only conditional: the endpoint defect budget is explicit.
-/

namespace Survival.BernoulliTypicalSigma

open MeasureTheory
open Survival.ProbabilityConnection
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.BernoulliCSPPathChernoff
open Survival.BernoulliCSPPathCollapse
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Reader-facing name for the Bernoulli-CSP cumulative total-production
observable `Σ_n`. -/
abbrev bernoulliSigma
    (P : Parameters) (s₀ : ℝ) {N : ℕ} (τ : Trajectory N) (n : ℕ) : ℝ :=
  cumulativeProduction P s₀ τ n

/-- Reader-facing name for the deterministic Bernoulli-CSP linear center. -/
abbrev bernoulliSigmaCenter (P : Parameters) (s₀ : ℝ) (n : ℕ) : ℝ :=
  linearCenter P s₀ n

/-- Reader-facing name for the lower-tail event
`Σ_n < center_n - r`. -/
abbrev bernoulliSigmaLowerTailEvent
    (P : Parameters) (s₀ : ℝ) (N n : ℕ) (r : ℝ) : Set (Trajectory N) :=
  cumulativeLowerTailEvent P s₀ N n r

/-- Reader-facing name for the Bernoulli-CSP stochastic `Σ` process. -/
abbrev bernoulliSigmaProcess
    (P : Parameters) (N : ℕ) (s₀ : ℝ) :
    StochasticExpectedProcess (μ := pathMeasure P N) :=
  process P N s₀

/-- The Bernoulli-CSP `Σ` process increments by the one-sided bad-event
emission. -/
theorem bernoulliSigma_succ
    (P : Parameters) (s₀ : ℝ) {N : ℕ} (τ : Trajectory N) (n : ℕ) :
    bernoulliSigma P s₀ τ (n + 1) =
      bernoulliSigma P s₀ τ n + stepEmission P (outcomeAt τ n) := by
  exact cumulativeProduction_succ P s₀ τ n

/-- One-step Bernoulli-CSP `Σ` emissions are almost surely nonnegative. -/
theorem bernoulliSigma_ae_nonnegative_increment
    (P : Parameters) (N : ℕ) (s₀ : ℝ) :
    AENonnegativeIncrement (μ := pathMeasure P N)
      (bernoulliSigmaProcess P N s₀) := by
  intro t
  exact Filter.Eventually.of_forall
    (fun τ => stepEmission_nonneg P (outcomeAt τ t))

/-- In the one-sided Bernoulli-CSP template, every adjacent `Σ` step is
nondecreasing because each bad-event emission is nonnegative.  This is a
class-specific finite-path fact, not a universal second-law statement. -/
theorem bernoulliSigma_succ_le
    (P : Parameters) (s₀ : ℝ) {N : ℕ} (τ : Trajectory N) (n : ℕ) :
    bernoulliSigma P s₀ τ n ≤ bernoulliSigma P s₀ τ (n + 1) := by
  rw [bernoulliSigma_succ]
  exact le_add_of_nonneg_right (stepEmission_nonneg P (outcomeAt τ n))

/-- Initial-to-time monotonicity as a fixed-time corollary of the nonnegative
adjacent-step property. -/
theorem bernoulliSigma_initial_le
    (P : Parameters) (s₀ : ℝ) {N : ℕ} (τ : Trajectory N) (n : ℕ) :
    bernoulliSigma P s₀ τ 0 ≤ bernoulliSigma P s₀ τ n := by
  induction n with
  | zero => rfl
  | succ n ih =>
      exact le_trans ih (bernoulliSigma_succ_le P s₀ τ n)

/-- Therefore the expected Bernoulli-CSP `Σ` observable is monotone in the
finite-prefix horizon. -/
theorem bernoulliSigma_expectedCumulative_monotone
    (P : Parameters) (N : ℕ) (s₀ : ℝ) :
    Monotone
      (bernoulliSigmaProcess P N s₀).toExpectedProcess.expectedCumulative := by
  exact
    expectedCumulative_monotone_of_ae_nonnegative_increment
      (bernoulliSigmaProcess P N s₀)
      (bernoulliSigma_ae_nonnegative_increment P N s₀)

/-- Interior KL/Chernoff lower-tail certificate for the Bernoulli-CSP `Σ`
observable.  This is the Phase-4 reader-facing name: it is a fixed finite-path
lower-tail bound, not an unconditional second law. -/
theorem bernoulliSigmaLowerTailMeasure_le_chernoffFailureBound_of_interior
    (P : Parameters) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift) :
    pathMeasure P N (bernoulliSigmaLowerTailEvent P s₀ N n r) ≤
      P.chernoffFailureBound n r := by
  exact
    cumulativeLowerTailMeasure_le_chernoffFailureBound_of_interior
      P N hn hr hlt

/-- A fixed finite-path high-probability lower-bound certificate for the
Bernoulli-CSP `Σ` observable.  It packages a good event with a failure
probability bound and a pointwise lower bound
`center_n - r ≤ Σ_n` on that event. -/
def BernoulliSigmaLowerBoundWithFailureBound
    (P : Parameters) (N : ℕ) (s₀ : ℝ) (n : ℕ) (r : ℝ) (ε : ENNReal) : Prop :=
  ∃ E : Set (Trajectory N),
    EventWithFailureBound (μ := pathMeasure P N) E ε ∧
      ∀ τ ∈ E, bernoulliSigmaCenter P s₀ n - r ≤ bernoulliSigma P s₀ τ n

/-- A fixed finite-path typical-growth certificate for Bernoulli-CSP `Σ`.
On the same good event, `Σ` is nondecreasing from time zero and lies above its
linear center minus `r` at time `n`. -/
def BernoulliSigmaTypicalGrowthWithFailureBound
    (P : Parameters) (N : ℕ) (s₀ : ℝ) (n : ℕ) (r : ℝ) (ε : ENNReal) : Prop :=
  ∃ E : Set (Trajectory N),
    EventWithFailureBound (μ := pathMeasure P N) E ε ∧
      ∀ τ ∈ E,
        bernoulliSigma P s₀ τ 0 ≤ bernoulliSigma P s₀ τ n ∧
          bernoulliSigmaCenter P s₀ n - r ≤ bernoulliSigma P s₀ τ n

/-- A coarse/readout-level fixed-time lower-bound certificate.  The coarse
terminal observable may lose a deterministic endpoint-defect budget `δ`, so the
lower bound is degraded from `center-r` to `center-r-δ`. -/
def CoarseBernoulliSigmaLowerBoundWithFailureBound
    (P : Parameters) (N : ℕ) (s₀ : ℝ) (n : ℕ) (r δ : ℝ) (ε : ENNReal)
    (coarseSigmaN : Trajectory N → ℝ) : Prop :=
  ∃ E : Set (Trajectory N),
    EventWithFailureBound (μ := pathMeasure P N) E ε ∧
      ∀ τ ∈ E, bernoulliSigmaCenter P s₀ n - r - δ ≤ coarseSigmaN τ

/-- A coarse/readout-level fixed-time typical-growth certificate.  It is still
fixed-time and conditional: coarse monotonicity is supplied by the admissible
readout, while the terminal lower bound is transferred with endpoint-defect
budget `δ`. -/
def CoarseBernoulliSigmaTypicalGrowthWithFailureBound
    (P : Parameters) (N : ℕ) (s₀ : ℝ) (n : ℕ) (r δ : ℝ) (ε : ENNReal)
    (coarseSigma0 coarseSigmaN : Trajectory N → ℝ) : Prop :=
  ∃ E : Set (Trajectory N),
    EventWithFailureBound (μ := pathMeasure P N) E ε ∧
      ∀ τ ∈ E,
        coarseSigma0 τ ≤ coarseSigmaN τ ∧
          bernoulliSigmaCenter P s₀ n - r - δ ≤ coarseSigmaN τ

/-- Interior KL/Chernoff high-probability lower-bound certificate for
Bernoulli-CSP `Σ`: outside a bad event of probability at most the Chernoff
profile, `Σ_n` lies above its deterministic linear center minus `r`.

This is the narrow Phase-4.2 bridge from a lower-tail measure inequality to a
reader-facing typical lower-bound statement. -/
theorem bernoulliSigma_lowerBoundWithChernoffBound_of_interior
    (P : Parameters) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift) :
    BernoulliSigmaLowerBoundWithFailureBound
      P N s₀ n r (P.chernoffFailureBound n r) := by
  let badEvent := bernoulliSigmaLowerTailEvent P s₀ N n r
  let goodEvent : Set (Trajectory N) := badEventᶜ
  refine ⟨goodEvent, ?_, ?_⟩
  · constructor
    · change MeasurableSet (bernoulliSigmaLowerTailEvent P s₀ N n r)ᶜ
      trivial
    · simpa [goodEvent, badEvent] using
        bernoulliSigmaLowerTailMeasure_le_chernoffFailureBound_of_interior
          P N hn hr hlt
  · intro τ hτ
    dsimp [goodEvent, badEvent, bernoulliSigmaLowerTailEvent] at hτ
    exact not_lt.mp hτ

/-- Fixed-time typical growth certificate for Bernoulli-CSP `Σ`.  This combines
pathwise nondecrease from nonnegative emissions with the finite-path interior
Chernoff lower-bound certificate. -/
theorem bernoulliSigma_typicalGrowthWithChernoffBound_of_interior
    (P : Parameters) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift) :
    BernoulliSigmaTypicalGrowthWithFailureBound
      P N s₀ n r (P.chernoffFailureBound n r) := by
  rcases
    bernoulliSigma_lowerBoundWithChernoffBound_of_interior
      P N hn hr hlt with
    ⟨E, hE, hlower⟩
  refine ⟨E, hE, ?_⟩
  intro τ hτ
  exact ⟨bernoulliSigma_initial_le P s₀ τ n, hlower τ hτ⟩

/-- A scalar endpoint-defect budget transfers a terminal lower bound from the
micro `Σ_n` readout to a coarse terminal readout, losing at most `δ`. -/
theorem terminalDefectBudget_terminal_lower_bound
    {micro coarse e0 en δ : ℝ}
    (hcoarse : coarse = micro + e0 - en)
    (hbudget : en - e0 ≤ δ) :
    micro - δ ≤ coarse := by
  rw [hcoarse]
  linarith

/-- Transfer a micro Bernoulli-CSP lower-bound certificate to a coarse terminal
readout under a deterministic endpoint-defect budget.  This is the narrow
Phase-4.4 conditional coarse version: it is not a uniform-in-time theorem and
not an unconditional second-law claim. -/
theorem coarseBernoulliSigma_lowerBoundWithFailureBound_of_micro_defectBudget
    (P : Parameters) (N : ℕ) {n : ℕ} {s₀ r δ : ℝ} {ε : ENNReal}
    {coarseSigmaN : Trajectory N → ℝ}
    (hmicro : BernoulliSigmaLowerBoundWithFailureBound P N s₀ n r ε)
    (hterminal :
      ∀ τ, bernoulliSigma P s₀ τ n - δ ≤ coarseSigmaN τ) :
    CoarseBernoulliSigmaLowerBoundWithFailureBound
      P N s₀ n r δ ε coarseSigmaN := by
  rcases hmicro with ⟨E, hE, hlower⟩
  refine ⟨E, hE, ?_⟩
  intro τ hτ
  have hμ := hlower τ hτ
  have hc := hterminal τ
  linarith

/-- Interior Chernoff lower-bound transfer to a coarse terminal readout under a
deterministic endpoint-defect budget. -/
theorem coarseBernoulliSigma_lowerBoundWithChernoffBound_of_interior
    (P : Parameters) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ r δ : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift)
    {coarseSigmaN : Trajectory N → ℝ}
    (hterminal :
      ∀ τ, bernoulliSigma P s₀ τ n - δ ≤ coarseSigmaN τ) :
    CoarseBernoulliSigmaLowerBoundWithFailureBound
      P N s₀ n r δ (P.chernoffFailureBound n r) coarseSigmaN := by
  exact
    coarseBernoulliSigma_lowerBoundWithFailureBound_of_micro_defectBudget
      P N
      (bernoulliSigma_lowerBoundWithChernoffBound_of_interior
        P N hn hr hlt)
      hterminal

/-- Endpoint-defect form of the coarse lower-bound transfer.  If the coarse
terminal readout is the micro terminal readout plus `e0-en`, and `en-e0 ≤ δ`,
then the Chernoff lower bound transfers with a `δ` penalty. -/
theorem coarseBernoulliSigma_lowerBoundWithChernoffBound_of_endpointDefectBudget
    (P : Parameters) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ r δ e0 en : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift)
    {coarseSigmaN : Trajectory N → ℝ}
    (hcoarse :
      ∀ τ, coarseSigmaN τ = bernoulliSigma P s₀ τ n + e0 - en)
    (hbudget : en - e0 ≤ δ) :
    CoarseBernoulliSigmaLowerBoundWithFailureBound
      P N s₀ n r δ (P.chernoffFailureBound n r) coarseSigmaN := by
  refine
    coarseBernoulliSigma_lowerBoundWithChernoffBound_of_interior
      P N hn hr hlt ?_
  intro τ
  exact terminalDefectBudget_terminal_lower_bound (hcoarse τ) hbudget

/-- Coarse fixed-time typical-growth transfer.  The monotonicity of the coarse
readout is an explicit compatibility assumption; the terminal lower bound is
inherited from the micro Bernoulli certificate with defect penalty `δ`. -/
theorem coarseBernoulliSigma_typicalGrowthWithFailureBound_of_micro_defectBudget
    (P : Parameters) (N : ℕ) {n : ℕ} {s₀ r δ : ℝ} {ε : ENNReal}
    {coarseSigma0 coarseSigmaN : Trajectory N → ℝ}
    (hmicro : BernoulliSigmaLowerBoundWithFailureBound P N s₀ n r ε)
    (hmono : ∀ τ, coarseSigma0 τ ≤ coarseSigmaN τ)
    (hterminal :
      ∀ τ, bernoulliSigma P s₀ τ n - δ ≤ coarseSigmaN τ) :
    CoarseBernoulliSigmaTypicalGrowthWithFailureBound
      P N s₀ n r δ ε coarseSigma0 coarseSigmaN := by
  rcases
    coarseBernoulliSigma_lowerBoundWithFailureBound_of_micro_defectBudget
      P N hmicro hterminal with
    ⟨E, hE, hlower⟩
  refine ⟨E, hE, ?_⟩
  intro τ hτ
  exact ⟨hmono τ, hlower τ hτ⟩

/-- Interior Chernoff coarse fixed-time typical-growth transfer under explicit
coarse-readout monotonicity and terminal defect budget. -/
theorem coarseBernoulliSigma_typicalGrowthWithChernoffBound_of_interior
    (P : Parameters) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ r δ : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift)
    {coarseSigma0 coarseSigmaN : Trajectory N → ℝ}
    (hmono : ∀ τ, coarseSigma0 τ ≤ coarseSigmaN τ)
    (hterminal :
      ∀ τ, bernoulliSigma P s₀ τ n - δ ≤ coarseSigmaN τ) :
    CoarseBernoulliSigmaTypicalGrowthWithFailureBound
      P N s₀ n r δ (P.chernoffFailureBound n r) coarseSigma0 coarseSigmaN := by
  exact
    coarseBernoulliSigma_typicalGrowthWithFailureBound_of_micro_defectBudget
      P N
      (bernoulliSigma_lowerBoundWithChernoffBound_of_interior
        P N hn hr hlt)
      hmono hterminal

/-- Endpoint-defect version of the coarse fixed-time typical-growth transfer. -/
theorem coarseBernoulliSigma_typicalGrowthWithChernoffBound_of_endpointDefectBudget
    (P : Parameters) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ r δ e0 en : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift)
    {coarseSigma0 coarseSigmaN : Trajectory N → ℝ}
    (hmono : ∀ τ, coarseSigma0 τ ≤ coarseSigmaN τ)
    (hcoarse :
      ∀ τ, coarseSigmaN τ = bernoulliSigma P s₀ τ n + e0 - en)
    (hbudget : en - e0 ≤ δ) :
    CoarseBernoulliSigmaTypicalGrowthWithFailureBound
      P N s₀ n r δ (P.chernoffFailureBound n r) coarseSigma0 coarseSigmaN := by
  refine
    coarseBernoulliSigma_typicalGrowthWithChernoffBound_of_interior
      P N hn hr hlt hmono ?_
  intro τ
  exact terminalDefectBudget_terminal_lower_bound (hcoarse τ) hbudget

/-- Fixed-time threshold crossing for Bernoulli-CSP `Σ`, obtained by combining
the lower-tail certificate with a linear margin. -/
theorem bernoulliSigma_thresholdCrossingWithChernoffBound_of_linearMargin
    (P : Parameters) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift)
    (hmargin : -Real.log θ ≤ bernoulliSigmaCenter P s₀ n - r) :
    ThresholdCrossingWithFailureBound
      (μ := pathMeasure P N)
      (bernoulliSigmaProcess P N s₀)
      n θ
      (P.chernoffFailureBound n r) := by
  exact
    thresholdCrossingWithChernoffBound_of_linearMargin
      P N hn hr hlt hmargin

/-- Fixed-time collapse wrapper for Bernoulli-CSP `Σ`. -/
theorem bernoulliSigma_collapseWithChernoffBound_of_linearMargin
    (P : Parameters) (N : ℕ) {n : ℕ} (hn : n ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (n : ℝ) * P.drift)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ bernoulliSigmaCenter P s₀ n - r) :
    CollapseWithFailureBound
      (μ := pathMeasure P N)
      (bernoulliSigmaProcess P N s₀)
      n θ
      (P.chernoffFailureBound n r) := by
  exact
    collapseWithChernoffBound_of_linearMargin
      P N hn hr hlt hθ hmargin

/-- Terminal stopped-collapse wrapper for Bernoulli-CSP `Σ`. -/
theorem bernoulliSigma_stoppedCollapseWithChernoffBound_of_linearMargin
    (P : Parameters) (N : ℕ) {T : ℕ} (hT : T ≤ N + 1) {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (T : ℝ) * P.drift)
    (hθ : 0 < θ)
    (hmargin : -Real.log θ ≤ bernoulliSigmaCenter P s₀ T - r) :
    StoppedCollapseWithFailureBound
      (μ := pathMeasure P N)
      (bernoulliSigmaProcess P N s₀)
      T θ
      (P.chernoffFailureBound T r) := by
  exact
    stoppedCollapseWithChernoffBound_of_linearMargin
      P N hT hr hlt hθ hmargin

/-- Hitting-time-before-horizon wrapper for Bernoulli-CSP `Σ`. -/
theorem bernoulliSigma_hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
    (P : Parameters) (N : ℕ) {k T : ℕ} (hkT : k < T) (hk : k ≤ N + 1)
    {s₀ θ r : ℝ}
    (hr : 0 ≤ r)
    (hlt : r < (k : ℝ) * P.drift)
    (hmargin : -Real.log θ ≤ bernoulliSigmaCenter P s₀ k - r) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := pathMeasure P N)
      (bernoulliSigmaProcess P N s₀)
      T θ
      (P.chernoffFailureBound k r) := by
  exact
    hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
      P N hkT hk hr hlt hmargin

end

end Survival.BernoulliTypicalSigma
