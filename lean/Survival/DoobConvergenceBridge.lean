import Survival.SupermartingaleRetentionBridge
import Mathlib.Probability.Martingale.Convergence

/-!
# Doob Convergence Bridge — Almost Sure Convergence of Retention

This module applies Mathlib's Doob martingale convergence theorem to
establish almost-sure convergence of the structural retention process.

## What this file proves

1. Doob convergence for supermartingales (via negation to submartingale).
2. Retention-specific convergence: exp(-B_n) → R_∞ a.s. with R_∞ ≥ 0.
3. Structural persistence/collapse dichotomy.
-/

namespace Survival.DoobConvergenceBridge

open Survival.MartingaleConvergenceBridge
open Survival.SupermartingaleRetentionBridge
open MeasureTheory Filter
open scoped NNReal

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω} [IsFiniteMeasure μ]
variable {ℱ : Filtration ℕ ‹MeasurableSpace Ω›}

/-! ## Part 1: Doob Convergence for Supermartingales -/

/-- **Doob convergence for supermartingales** (via negation).

-R is a submartingale when R is a supermartingale.
Doob's theorem on the submartingale gives a.s. convergence. -/
theorem supermartingale_ae_convergence
    {f : ℕ → Ω → ℝ} {R : ℝ≥0}
    (hsuper : Supermartingale f ℱ μ)
    (hbdd : ∀ n, eLpNorm (fun ω => -f n ω) 1 μ ≤ ↑R) :
    ∀ᵐ ω ∂μ, ∃ L,
      Tendsto (fun n => f n ω) atTop (nhds L) := by
  have hneg : Submartingale (fun n ω => -f n ω) ℱ μ :=
    hsuper.neg
  have hconv := hneg.exists_ae_tendsto_of_bdd hbdd
  filter_upwards [hconv] with ω ⟨L, hL⟩
  refine ⟨-L, ?_⟩
  have : Tendsto (fun n => -(-f n ω)) atTop (nhds (-L)) := hL.neg
  simp only [neg_neg] at this
  exact this

/-! ## Part 2: Retention-Specific Convergence -/

/-- **Structural Retention Convergence.**

If exp(-B_n) is a supermartingale with bounded eLpNorm of its
negation, it converges a.s. to a nonneg limit R_∞. -/
theorem retention_ae_convergence_of_supermartingale
    {B : ℕ → Ω → ℝ} {R : ℝ≥0}
    (hsuper : Supermartingale (retentionProcess B) ℱ μ)
    (hbdd : ∀ n,
      eLpNorm (fun ω => -(retentionProcess B n ω)) 1 μ ≤ ↑R) :
    ∀ᵐ ω ∂μ, ∃ R_inf,
      Tendsto (fun n => retentionProcess B n ω)
        atTop (nhds R_inf) ∧
      0 ≤ R_inf := by
  have hconv := supermartingale_ae_convergence hsuper hbdd
  filter_upwards [hconv] with ω ⟨L, hL⟩
  refine ⟨L, hL, ?_⟩
  exact ge_of_tendsto hL
    (Eventually.of_forall fun n => retentionProcess_nonneg B n ω)

/-! ## Part 3: Structural Dichotomy -/

/-- **Collapse**: diverging consumption forces retention to zero. -/
theorem retention_collapse_of_diverging_consumption
    {B : ℕ → Ω → ℝ} (ω : Ω)
    (hB : Tendsto (fun n => B n ω) atTop atTop) :
    Tendsto (fun n => retentionProcess B n ω)
      atTop (nhds 0) :=
  retention_tends_zero_of_consumption_diverges B ω hB

/-- **Persistence**: bounded consumption keeps retention positive. -/
theorem retention_persists_of_bounded_consumption
    {B : ℕ → Ω → ℝ} (ω : Ω) {C : ℝ}
    (hbound : ∀ n, B n ω ≤ C) :
    ∀ n, Real.exp (-C) ≤ retentionProcess B n ω :=
  retention_bounded_away_from_zero B ω C hbound

/-- The persistence lower bound is strictly positive. -/
theorem persistence_bound_pos {C : ℝ} :
    0 < Real.exp (-C) :=
  Real.exp_pos _

end

end Survival.DoobConvergenceBridge
