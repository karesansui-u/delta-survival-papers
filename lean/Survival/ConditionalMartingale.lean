import Mathlib.Probability.Martingale.Basic
import Survival.MartingaleDrift

/-!
Conditional Martingale Layer
conditional expectation を使う本物の martingale 層

This module connects the abstract survival interfaces to mathlib's actual
martingale language.

Two things happen here:

* a real-valued process `f : ℕ → Ω → ℝ` is converted into the
  `StochasticExpectedProcess` interface by using the increment
  `f (n + 1) - f n`;
* genuine martingale / submartingale / supermartingale assumptions with
  respect to a filtration are pushed down to the expectation-level drift layer
  in `Survival.MartingaleDrift`.

We also expose the standard one-step conditional-expectation drift conditions
that generate submartingales, supermartingales, and martingales.
-/

open scoped ProbabilityTheory

namespace Survival.ConditionalMartingale

open MeasureTheory
open Survival.ProbabilityConnection
open Survival.MartingaleDrift

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}
variable {ℱ : Filtration ℕ ‹MeasurableSpace Ω›}

/-- One-step increment extracted from a cumulative process. -/
def incrementProcess (f : ℕ → Ω → ℝ) (n : ℕ) : Ω → ℝ :=
  fun ω => f (n + 1) ω - f n ω

/-- Build the survival stochastic-process interface from an actual cumulative
process and its one-step differences. -/
def processAsStochasticExpectedProcess
    (f : ℕ → Ω → ℝ)
    (hint : ∀ n, Integrable (f n) μ) :
    StochasticExpectedProcess (μ := μ) where
  cumulativeRV := f
  incrementRV := incrementProcess f
  integrable_cumulative := hint
  integrable_increment n := (hint (n + 1)).sub (hint n)
  cumulative_succ_ae n := Filter.Eventually.of_forall (by
    intro ω
    simp [incrementProcess])

theorem expectedIncrement_eq_integral_sub
    (f : ℕ → Ω → ℝ)
    (hint : ∀ n, Integrable (f n) μ)
    (n : ℕ) :
    (processAsStochasticExpectedProcess (μ := μ) f hint).toExpectedProcess.expectedIncrement n =
      ∫ ω, f (n + 1) ω ∂μ - ∫ ω, f n ω ∂μ := by
  simp [ProbabilityConnection.StochasticExpectedProcess.toExpectedProcess,
    processAsStochasticExpectedProcess, incrementProcess, integral_sub,
    hint (n + 1), hint n]

/-- Genuine submartingales induce the expectation-level nonnegative drift
condition used by the survival layer. -/
theorem submartingaleLike_of_submartingale
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ ℱ]
    {f : ℕ → Ω → ℝ} (hf : MeasureTheory.Submartingale f ℱ μ) :
    SubmartingaleLike (μ := μ)
      (processAsStochasticExpectedProcess (μ := μ) f hf.integrable) := by
  intro n
  change 0 ≤ ∫ ω, incrementProcess f n ω ∂μ
  have hstep : ∫ ω in Set.univ, f n ω ∂μ ≤ ∫ ω in Set.univ, f (n + 1) ω ∂μ := by
    exact hf.setIntegral_le (Nat.le_succ n) MeasurableSet.univ
  have hstep' : ∫ ω, f n ω ∂μ ≤ ∫ ω, f (n + 1) ω ∂μ := by
    simpa using hstep
  have hinc :
      ∫ ω, incrementProcess f n ω ∂μ =
        ∫ ω, f (n + 1) ω ∂μ - ∫ ω, f n ω ∂μ := by
    simp [incrementProcess, integral_sub, hf.integrable (n + 1), hf.integrable n]
  rw [hinc]
  linarith

/-- Genuine supermartingales induce the expectation-level nonpositive drift
condition used by the survival layer. -/
theorem supermartingaleLike_of_supermartingale
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ ℱ]
    {f : ℕ → Ω → ℝ} (hf : MeasureTheory.Supermartingale f ℱ μ) :
    SupermartingaleLike (μ := μ)
      (processAsStochasticExpectedProcess (μ := μ) f hf.integrable) := by
  intro n
  change ∫ ω, incrementProcess f n ω ∂μ ≤ 0
  have hstep : ∫ ω in Set.univ, f (n + 1) ω ∂μ ≤ ∫ ω in Set.univ, f n ω ∂μ := by
    exact hf.setIntegral_le (Nat.le_succ n) MeasurableSet.univ
  have hstep' : ∫ ω, f (n + 1) ω ∂μ ≤ ∫ ω, f n ω ∂μ := by
    simpa using hstep
  have hinc :
      ∫ ω, incrementProcess f n ω ∂μ =
        ∫ ω, f (n + 1) ω ∂μ - ∫ ω, f n ω ∂μ := by
    simp [incrementProcess, integral_sub, hf.integrable (n + 1), hf.integrable n]
  rw [hinc]
  linarith

/-- Genuine martingales induce zero expected drift in the survival layer. -/
theorem martingaleLike_of_martingale
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ ℱ]
    {f : ℕ → Ω → ℝ} (hf : MeasureTheory.Martingale f ℱ μ) :
    MartingaleLike (μ := μ)
      (processAsStochasticExpectedProcess
        (μ := μ) f (fun n => hf.integrable n)) := by
  have hsub := submartingaleLike_of_submartingale
    (μ := μ) (ℱ := ℱ) (f := f) hf.submartingale
  have hsuper := supermartingaleLike_of_supermartingale
    (μ := μ) (ℱ := ℱ) (f := f) hf.supermartingale
  intro n
  have h1 :
      0 ≤
        (processAsStochasticExpectedProcess
          (μ := μ) f (fun k => hf.integrable k)).toExpectedProcess.expectedIncrement n :=
    hsub n
  have h2 :
      (processAsStochasticExpectedProcess
        (μ := μ) f (fun k => hf.integrable k)).toExpectedProcess.expectedIncrement n ≤ 0 :=
    hsuper n
  linarith

/-- Conditional nonnegative one-step drift. -/
def ConditionalIncrementSubmartingaleDrift
    (f : ℕ → Ω → ℝ) (ℱ : Filtration ℕ ‹MeasurableSpace Ω›) (μ : Measure Ω) : Prop :=
  ∀ n, 0 ≤ᵐ[μ] μ[f (n + 1) - f n|ℱ n]

/-- Conditional nonnegative reverse drift, corresponding to a supermartingale. -/
def ConditionalIncrementSupermartingaleDrift
    (f : ℕ → Ω → ℝ) (ℱ : Filtration ℕ ‹MeasurableSpace Ω›) (μ : Measure Ω) : Prop :=
  ∀ n, 0 ≤ᵐ[μ] μ[f n - f (n + 1)|ℱ n]

/-- Conditional zero one-step drift, corresponding to a martingale. -/
def ConditionalIncrementMartingaleDrift
    (f : ℕ → Ω → ℝ) (ℱ : Filtration ℕ ‹MeasurableSpace Ω›) (μ : Measure Ω) : Prop :=
  ∀ n, μ[f (n + 1) - f n|ℱ n] =ᵐ[μ] 0

theorem submartingale_of_conditionalIncrementSubmartingaleDrift
    [IsFiniteMeasure μ]
    {f : ℕ → Ω → ℝ}
    (hadp : Adapted ℱ f)
    (hint : ∀ n, Integrable (f n) μ)
    (hcond : ConditionalIncrementSubmartingaleDrift f ℱ μ) :
    MeasureTheory.Submartingale f ℱ μ := by
  exact MeasureTheory.submartingale_of_condExp_sub_nonneg_nat hadp hint hcond

theorem supermartingale_of_conditionalIncrementSupermartingaleDrift
    [IsFiniteMeasure μ]
    {f : ℕ → Ω → ℝ}
    (hadp : Adapted ℱ f)
    (hint : ∀ n, Integrable (f n) μ)
    (hcond : ConditionalIncrementSupermartingaleDrift f ℱ μ) :
    MeasureTheory.Supermartingale f ℱ μ := by
  exact MeasureTheory.supermartingale_of_condExp_sub_nonneg_nat hadp hint hcond

theorem martingale_of_conditionalIncrementMartingaleDrift
    [IsFiniteMeasure μ]
    {f : ℕ → Ω → ℝ}
    (hadp : Adapted ℱ f)
    (hint : ∀ n, Integrable (f n) μ)
    (hcond : ConditionalIncrementMartingaleDrift f ℱ μ) :
    MeasureTheory.Martingale f ℱ μ := by
  exact MeasureTheory.martingale_of_condExp_sub_eq_zero_nat hadp hint hcond

theorem submartingaleLike_of_conditionalIncrementSubmartingaleDrift
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ ℱ]
    {f : ℕ → Ω → ℝ}
    (hadp : Adapted ℱ f)
    (hint : ∀ n, Integrable (f n) μ)
    (hcond : ConditionalIncrementSubmartingaleDrift f ℱ μ) :
    SubmartingaleLike (μ := μ)
      (processAsStochasticExpectedProcess (μ := μ) f hint) := by
  exact submartingaleLike_of_submartingale (μ := μ) (ℱ := ℱ)
    (submartingale_of_conditionalIncrementSubmartingaleDrift
      (μ := μ) (ℱ := ℱ) hadp hint hcond)

theorem supermartingaleLike_of_conditionalIncrementSupermartingaleDrift
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ ℱ]
    {f : ℕ → Ω → ℝ}
    (hadp : Adapted ℱ f)
    (hint : ∀ n, Integrable (f n) μ)
    (hcond : ConditionalIncrementSupermartingaleDrift f ℱ μ) :
    SupermartingaleLike (μ := μ)
      (processAsStochasticExpectedProcess (μ := μ) f hint) := by
  exact supermartingaleLike_of_supermartingale (μ := μ) (ℱ := ℱ)
    (supermartingale_of_conditionalIncrementSupermartingaleDrift
      (μ := μ) (ℱ := ℱ) hadp hint hcond)

theorem martingaleLike_of_conditionalIncrementMartingaleDrift
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ ℱ]
    {f : ℕ → Ω → ℝ}
    (hadp : Adapted ℱ f)
    (hint : ∀ n, Integrable (f n) μ)
    (hcond : ConditionalIncrementMartingaleDrift f ℱ μ) :
    MartingaleLike (μ := μ)
      (processAsStochasticExpectedProcess (μ := μ) f hint) := by
  exact martingaleLike_of_martingale (μ := μ) (ℱ := ℱ)
    (martingale_of_conditionalIncrementMartingaleDrift
      (μ := μ) (ℱ := ℱ) hadp hint hcond)

end

end Survival.ConditionalMartingale
