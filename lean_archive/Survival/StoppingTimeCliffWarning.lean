import Mathlib.Probability.Martingale.OptionalStopping
import Survival.ConditionalMartingale

/-!
Stopping-Time Cliff Warning
optional stopping や hitting time を使って cliff warning を stopping-time 版に伸ばす

This module lifts the cliff-warning story from deterministic / one-step checks
to stopping times.

Given a real-valued cumulative process `f : ℕ → Ω → ℝ`, a collapse threshold
`-log θ`, and a finite horizon `N`, we define the first hitting time of the
collapse set within `[0, N]`.

Then we prove:

* the collapse hitting time is a stopping time;
* if the hitting time is strictly before `N`, the stopped value has crossed the
  collapse threshold;
* for a submartingale, optional stopping gives
  `E[f 0] ≤ E[f_τ] ≤ E[f N]`.
-/

open scoped ProbabilityTheory

namespace Survival.StoppingTimeCliffWarning

open MeasureTheory

noncomputable section

variable {Ω : Type*} [MeasurableSpace Ω]
variable {μ : Measure Ω}
variable {ℱ : Filtration ℕ ‹MeasurableSpace Ω›}

/-- Collapse set at retention fraction `θ`. -/
def collapseSet (θ : ℝ) : Set ℝ :=
  Set.Ici (-Real.log θ)

/-- First time the process crosses the collapse threshold within the finite
horizon `[0, N]`. -/
def collapseHittingTime
    (f : ℕ → Ω → ℝ) (θ : ℝ) (N : ℕ) : Ω → ℕ :=
  fun ω => hittingBtwn f (collapseSet θ) 0 N ω

omit [MeasurableSpace Ω] in
theorem collapseHittingTime_le_horizon
    (f : ℕ → Ω → ℝ) (θ : ℝ) (N : ℕ) (ω : Ω) :
    collapseHittingTime f θ N ω ≤ N :=
  hittingBtwn_le ω

theorem collapseHittingTime_isStoppingTime
    {f : ℕ → Ω → ℝ} (hadp : Adapted ℱ f) (θ : ℝ) (N : ℕ) :
    IsStoppingTime ℱ (fun ω ↦ (collapseHittingTime f θ N ω : ℕ)) := by
  simpa [collapseHittingTime, collapseSet]
    using hittingBtwn_isStoppingTime
      (f := ℱ) (u := f) (s := collapseSet θ) (n := 0) (n' := N)
      hadp measurableSet_Ici

omit [MeasurableSpace Ω] in
theorem threshold_le_stoppedValue_of_exists_hit
    {f : ℕ → Ω → ℝ} {θ : ℝ} {N : ℕ} {ω : Ω}
    (hhit : ∃ j ∈ Set.Icc 0 N, -Real.log θ ≤ f j ω) :
    -Real.log θ ≤
      stoppedValue f (fun ω ↦ (collapseHittingTime f θ N ω : ℕ)) ω := by
  have hmem :
      stoppedValue f (fun ω ↦ (collapseHittingTime f θ N ω : ℕ)) ω ∈ collapseSet θ := by
    exact stoppedValue_hittingBtwn_mem (u := f) (s := collapseSet θ) (n := 0) (m := N) hhit
  exact hmem

omit [MeasurableSpace Ω] in
theorem threshold_le_stoppedValue_of_collapseHittingTime_lt
    {f : ℕ → Ω → ℝ} {θ : ℝ} {N : ℕ} {ω : Ω}
    (hlt : collapseHittingTime f θ N ω < N) :
    -Real.log θ ≤
      stoppedValue f (fun ω ↦ (collapseHittingTime f θ N ω : ℕ)) ω := by
  have hτ_mem_Icc :
      collapseHittingTime f θ N ω ∈ Set.Icc 0 N :=
    hittingBtwn_mem_Icc (u := f) (s := collapseSet θ) (n := 0) (m := N) (Nat.zero_le N) ω
  have hhit_at_tau :
      f (collapseHittingTime f θ N ω) ω ∈ collapseSet θ := by
    exact hittingBtwn_mem_set_of_hittingBtwn_lt
      (u := f) (s := collapseSet θ) (n := 0) (m := N) hlt
  have hhit : ∃ j ∈ Set.Icc 0 N, -Real.log θ ≤ f j ω := by
    refine ⟨collapseHittingTime f θ N ω, hτ_mem_Icc, hhit_at_tau⟩
  exact threshold_le_stoppedValue_of_exists_hit hhit

theorem Submartingale.expected_initial_le_expected_collapseHittingTime
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ ℱ]
    {f : ℕ → Ω → ℝ} (hsub : Submartingale f ℱ μ)
    (θ : ℝ) (N : ℕ) :
    μ[f 0] ≤ μ[stoppedValue f (fun ω ↦ (collapseHittingTime f θ N ω : ℕ))] := by
  let τ : Ω → ℕ∞ := fun _ ↦ (0 : ℕ)
  let π : Ω → ℕ∞ := fun ω ↦ (collapseHittingTime f θ N ω : ℕ)
  have hτ : IsStoppingTime ℱ τ := isStoppingTime_const ℱ 0
  have hπ : IsStoppingTime ℱ π := collapseHittingTime_isStoppingTime
    (ℱ := ℱ) hsub.adapted θ N
  have hle : τ ≤ π := by
    intro ω
    change ((0 : ℕ) : ℕ∞) ≤ ((collapseHittingTime f θ N ω : ℕ) : ℕ∞)
    exact_mod_cast Nat.zero_le (collapseHittingTime f θ N ω)
  have hbdd : ∀ ω, π ω ≤ N := by
    intro ω
    change ((collapseHittingTime f θ N ω : ℕ) : ℕ∞) ≤ (N : ℕ∞)
    exact_mod_cast collapseHittingTime_le_horizon f θ N ω
  simpa [τ, π, stoppedValue_const] using
    hsub.expected_stoppedValue_mono hτ hπ hle hbdd

theorem Submartingale.expected_collapseHittingTime_le_terminal
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ ℱ]
    {f : ℕ → Ω → ℝ} (hsub : Submartingale f ℱ μ)
    (θ : ℝ) (N : ℕ) :
    μ[stoppedValue f (fun ω ↦ (collapseHittingTime f θ N ω : ℕ))] ≤ μ[f N] := by
  let τ : Ω → ℕ∞ := fun ω ↦ (collapseHittingTime f θ N ω : ℕ)
  let π : Ω → ℕ∞ := fun ω ↦ (N : ℕ)
  have hτ : IsStoppingTime ℱ τ := collapseHittingTime_isStoppingTime
    (ℱ := ℱ) hsub.adapted θ N
  have hπ : IsStoppingTime ℱ π := isStoppingTime_const ℱ N
  have hle : τ ≤ π := by
    intro ω
    change ((collapseHittingTime f θ N ω : ℕ) : ℕ∞) ≤ (N : ℕ∞)
    exact_mod_cast collapseHittingTime_le_horizon f θ N ω
  have hbdd : ∀ ω, π ω ≤ N := by
    intro ω
    change ((N : ℕ) : ℕ∞) ≤ (N : ℕ∞)
    exact le_rfl
  simpa [τ, π, stoppedValue_const] using
    hsub.expected_stoppedValue_mono hτ hπ hle hbdd

theorem Submartingale.expected_initial_le_expected_collapseHittingTime_le_terminal
    [IsFiniteMeasure μ] [SigmaFiniteFiltration μ ℱ]
    {f : ℕ → Ω → ℝ} (hsub : Submartingale f ℱ μ)
    (θ : ℝ) (N : ℕ) :
    μ[f 0] ≤ μ[stoppedValue f (fun ω ↦ (collapseHittingTime f θ N ω : ℕ))] ∧
      μ[stoppedValue f (fun ω ↦ (collapseHittingTime f θ N ω : ℕ))] ≤ μ[f N] := by
  exact ⟨
    Submartingale.expected_initial_le_expected_collapseHittingTime hsub θ N,
    Submartingale.expected_collapseHittingTime_le_terminal hsub θ N
  ⟩

end

end Survival.StoppingTimeCliffWarning
