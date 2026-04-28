import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Tactic.Linarith
import Survival.AdmissibleMapInvariants

/-!
# Saturation-Defect Readout Spec

This module is the narrow Lean-facing specification for the saturation-defect
identity in the admissible-map supplement.

It deliberately stays at the finite readout level.  It does **not** formalize a
full measurable coarse-graining map, push-forward measure, or unconditional DPI.
Instead, it records the exact algebra that any later set-level coarse-graining
interface must instantiate:

* if the coarse one-step log-ratio loss differs from the micro one by the
  defect difference `e t - e (t+1)`, then
* cumulative coarse loss equals cumulative micro loss plus initial defect minus
  terminal defect.

Consequently, coarse loss is below micro loss only under the additional defect
condition `e 0 ≤ e n`.
-/

open scoped BigOperators
open Finset

namespace Survival.SaturationDefect

open Survival.AdmissibleMapInvariants
open Survival.TelescopingExp

noncomputable section

/-- Readout-level saturation-defect relation up to horizon `n`.

This is the intentionally narrow spec:

`coarse stage loss = micro stage loss + initial-stage defect - next-stage defect`.

The set-level definition
`eπ(A) = log (m (π⁻¹(π(A))) / m(A))` should instantiate this relation only
after positive finite mass and coarse-graining compatibility assumptions have
been supplied. -/
def SaturationDefectReadout (m mcoarse e : ℕ → ℝ) (n : ℕ) : Prop :=
  ∀ t, t ∈ Finset.range n →
    stageLoss mcoarse t = stageLoss m t + e t - e (t + 1)

/-- Stage-level form of the saturation-defect readout. -/
theorem coarse_stageLoss_eq_micro_add_defect_diff
    {m mcoarse e : ℕ → ℝ} {n t : ℕ}
    (hdef : SaturationDefectReadout m mcoarse e n)
    (ht : t ∈ Finset.range n) :
    stageLoss mcoarse t = stageLoss m t + e t - e (t + 1) :=
  hdef t ht

/-- If stage losses differ by a telescoping defect difference, then cumulative
coarse loss equals cumulative micro loss plus initial defect minus terminal
defect. -/
theorem coarse_cumulativeStageLoss_eq_micro_add_initial_defect_sub_terminal
    (m mcoarse e : ℕ → ℝ) (n : ℕ)
    (hdef : SaturationDefectReadout m mcoarse e n) :
    cumulativeStageLoss mcoarse n =
      cumulativeStageLoss m n + e 0 - e n := by
  induction n with
  | zero =>
      simp [cumulativeStageLoss]
  | succ n ih =>
      have hprefix : SaturationDefectReadout m mcoarse e n := by
        intro t ht
        exact hdef t
          (Finset.mem_range.mpr
            (Nat.lt_trans (Finset.mem_range.mp ht) (Nat.lt_succ_self n)))
      have ih' := ih hprefix
      unfold cumulativeStageLoss at ih' ⊢
      rw [Finset.sum_range_succ, Finset.sum_range_succ]
      rw [hdef n (by simp)]
      rw [ih']
      ring

/-- Conditional coarse-graining monotonicity: the coarse cumulative loss is
bounded above by the micro cumulative loss when terminal saturation defect is at
least the initial defect.

This is the Lean guardrail against an unconditional coarse-graining DPI claim. -/
theorem coarse_cumulativeStageLoss_le_micro_of_terminal_defect_ge_initial
    (m mcoarse e : ℕ → ℝ) (n : ℕ)
    (hdef : SaturationDefectReadout m mcoarse e n)
    (hmono : e 0 ≤ e n) :
    cumulativeStageLoss mcoarse n ≤ cumulativeStageLoss m n := by
  rw [coarse_cumulativeStageLoss_eq_micro_add_initial_defect_sub_terminal
    m mcoarse e n hdef]
  linarith

/-- If the terminal defect is no larger than the initial defect, the inequality
can reverse.  This theorem is not a claim that reversal always happens; it is a
reader-facing reminder that the sign is controlled by the defect comparison. -/
theorem micro_cumulativeStageLoss_le_coarse_of_terminal_defect_le_initial
    (m mcoarse e : ℕ → ℝ) (n : ℕ)
    (hdef : SaturationDefectReadout m mcoarse e n)
    (hmono : e n ≤ e 0) :
    cumulativeStageLoss m n ≤ cumulativeStageLoss mcoarse n := by
  rw [coarse_cumulativeStageLoss_eq_micro_add_initial_defect_sub_terminal
    m mcoarse e n hdef]
  linarith

end

end Survival.SaturationDefect
