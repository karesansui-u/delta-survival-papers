import Survival.CategoryBridge
import Survival.AdmissibleMapInvariants

/-!
# Noether Bridge — Discrete Conservation Laws

Establishes the correspondence between Noether's theorem
(symmetry → conservation law) and structural persistence
accounting (iso-invariance → loss preservation).

## Correspondence

| Noether / Physics | Structural Persistence |
|---|---|
| Continuous symmetry | Iso-morphism (gauge = 1) |
| Conservation law | Loss invariance (L_micro = L_coarse) |
| Symmetry breaking | Non-unit gauge (loss scales) |
| Energy conservation | Total production conservation |
| Noether current | Stage loss l_i |

The key insight: iso-morphisms in CategoryBridge preserve stage
losses exactly. This IS the discrete Noether theorem: the
symmetry (isomorphism) implies a conservation law (loss invariance).
-/

namespace Survival.NoetherBridge

open Survival.CategoryBridge
open Survival.AdmissibleMapInvariants

noncomputable section

/-! ## Part 1: Symmetry = Isomorphism -/

/-- A **structural symmetry** is an isomorphic admissible morphism
(gauge = 1). Under this symmetry, all stage losses are exactly
preserved. -/
def IsStructuralSymmetry
    (P Q : StructuralMaintenanceProblem)
    (f : AdmissibleMorphism P Q) : Prop :=
  f.gauge = 1

/-- **Discrete Noether theorem**: a structural symmetry preserves
stage losses exactly.

Symmetry (gauge = 1) → conservation (loss_coarse = loss_micro).
This is the structural-persistence analogue of Noether's theorem. -/
theorem noether_conservation
    {P Q : StructuralMaintenanceProblem}
    (f : AdmissibleMorphism P Q)
    (hsym : IsStructuralSymmetry P Q f)
    (t : ℕ) :
    smpStageLoss Q t = smpStageLoss P t := by
  have h := f.stage_covariance t
  rw [hsym, one_mul] at h
  exact h

/-- Noether conservation extends to cumulative losses. -/
theorem noether_cumulative_conservation
    {P Q : StructuralMaintenanceProblem}
    (f : AdmissibleMorphism P Q)
    (hsym : IsStructuralSymmetry P Q f)
    (n : ℕ) :
    smpCumulativeLoss Q n = smpCumulativeLoss P n := by
  unfold smpCumulativeLoss
  apply Finset.sum_congr rfl
  intro t _
  exact noether_conservation f hsym t

/-! ## Part 2: Symmetry Breaking = Non-Unit Gauge -/

/-- **Symmetry breaking**: when gauge ≠ 1, the conservation law
is replaced by a covariance relation. Losses scale by the gauge
factor.

In physics: broken symmetry → mass gap / Goldstone boson.
Here: broken symmetry → losses amplified or reduced by gauge. -/
theorem symmetry_breaking_covariance
    {P Q : StructuralMaintenanceProblem}
    (f : AdmissibleMorphism P Q) (t : ℕ) :
    smpStageLoss Q t = f.gauge * smpStageLoss P t :=
  f.stage_covariance t

/-- Under symmetry breaking with gauge > 1, losses are amplified.
The coarse system experiences more structural consumption than
the micro system at each step. -/
theorem amplified_loss_of_broken_symmetry
    {P Q : StructuralMaintenanceProblem}
    (f : AdmissibleMorphism P Q) (t : ℕ)
    (hgauge : 1 < f.gauge)
    (hloss : 0 < smpStageLoss P t) :
    smpStageLoss P t < smpStageLoss Q t := by
  rw [symmetry_breaking_covariance f t]
  exact lt_mul_of_one_lt_left hloss hgauge

/-! ## Part 3: Identity as Trivial Symmetry -/

/-- The identity morphism is always a structural symmetry. -/
theorem identity_is_symmetry (P : StructuralMaintenanceProblem) :
    IsStructuralSymmetry P P (identityMorphism P) := by
  unfold IsStructuralSymmetry identityMorphism
  rfl

/-- Under the identity symmetry, the Noether conservation
is trivially satisfied. -/
theorem identity_noether
    (P : StructuralMaintenanceProblem) (t : ℕ) :
    smpStageLoss P t = smpStageLoss P t :=
  noether_conservation (identityMorphism P)
    (identity_is_symmetry P) t

end

end Survival.NoetherBridge
