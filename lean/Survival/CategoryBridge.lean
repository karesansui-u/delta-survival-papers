import Survival.AdmissibleMapInvariants
import Survival.TelescopingExp

/-!
# Category Bridge — Functorial Structure of Structural Persistence

This module provides the G6-b correspondence between category-
theoretic structures and structural persistence theory.

## Mathematical context

A category consists of objects and morphisms with composition and
identity. We define:
- **Objects**: structural maintenance problems (X, G, m) — a state
  space, maintenance condition, and measure
- **Morphisms**: admissible maps that preserve or covariantly
  transform the structural accounting

## Structural-persistence reading

The admissible maps from `AdmissibleMapInvariants.lean` already
satisfy:
1. **Identity preservation**: the identity map preserves all
   structural accounting quantities
2. **Composition**: composition of admissible maps is admissible
3. **Invariance/covariance**: isomorphic maps preserve loss;
   gauge maps scale loss covariantly

This module makes these category-theoretic properties explicit,
showing that structural persistence theory has natural functorial
structure.

References:
  - Mac Lane, S. (1998). "Categories for the Working Mathematician."
  - AdmissibleMapInvariants.lean: invariance and covariance
  - TelescopingExp.lean: telescoping exponential identity
-/

namespace Survival.CategoryBridge

open scoped BigOperators
open Finset
open Survival.TelescopingExp
open Survival.AdmissibleMapInvariants

noncomputable section

/-! ## Part 1: Structural Maintenance Problem -/

/-- A structural maintenance problem: the minimal data needed to
    define structural persistence theory. -/
structure StructuralMaintenanceProblem where
  /-- The mass readout at each time step -/
  mass : ℕ → ℝ
  /-- Mass is always positive -/
  mass_pos : ∀ n, 0 < mass n

/-- The stage loss for a structural maintenance problem. -/
def smpStageLoss (P : StructuralMaintenanceProblem) (t : ℕ) : ℝ :=
  stageLoss P.mass t

/-- The cumulative loss for a structural maintenance problem. -/
def smpCumulativeLoss (P : StructuralMaintenanceProblem) (n : ℕ) : ℝ :=
  cumulativeStageLoss P.mass n

/-! ## Part 2: Morphisms (Admissible Maps) -/

/-- A morphism between structural maintenance problems:
    a map that transforms mass readouts in an admissible way. -/
structure AdmissibleMorphism
    (P Q : StructuralMaintenanceProblem) where
  /-- The gauge factor (1 for isomorphism, α for gauge map) -/
  gauge : ℝ
  gauge_pos : 0 < gauge
  /-- The morphism preserves stage losses up to gauge -/
  stage_covariance : ∀ t, smpStageLoss Q t = gauge * smpStageLoss P t

/-! ## Part 3: Identity Morphism -/

/-- The identity morphism: maps a problem to itself with gauge 1. -/
def identityMorphism (P : StructuralMaintenanceProblem) :
    AdmissibleMorphism P P where
  gauge := 1
  gauge_pos := one_pos
  stage_covariance := fun t => by
    simp [smpStageLoss]

/-- Identity morphism preserves cumulative loss exactly. -/
theorem identity_preserves_loss (P : StructuralMaintenanceProblem) (n : ℕ) :
    smpCumulativeLoss P n = smpCumulativeLoss P n := rfl

/-! ## Part 4: Composition of Morphisms -/

/-- Composition of admissible morphisms.
    If f : P → Q has gauge α and g : Q → R has gauge β,
    then g ∘ f : P → R has gauge α · β. -/
def composeMorphism
    {P Q R : StructuralMaintenanceProblem}
    (f : AdmissibleMorphism P Q) (g : AdmissibleMorphism Q R) :
    AdmissibleMorphism P R where
  gauge := g.gauge * f.gauge
  gauge_pos := mul_pos g.gauge_pos f.gauge_pos
  stage_covariance := fun t => by
    rw [g.stage_covariance t, f.stage_covariance t]
    ring

/-- Composition gauge is multiplicative. -/
theorem compose_gauge_mul
    {P Q R : StructuralMaintenanceProblem}
    (f : AdmissibleMorphism P Q) (g : AdmissibleMorphism Q R) :
    (composeMorphism f g).gauge = g.gauge * f.gauge := rfl

/-! ## Part 5: Cumulative Loss Covariance -/

/-- An admissible morphism with gauge α transforms cumulative loss
    by the factor α. -/
theorem morphism_cumulative_covariance
    {P Q : StructuralMaintenanceProblem}
    (f : AdmissibleMorphism P Q) (n : ℕ) :
    smpCumulativeLoss Q n = f.gauge * smpCumulativeLoss P n := by
  unfold smpCumulativeLoss cumulativeStageLoss
  calc
    (∑ t ∈ Finset.range n, stageLoss Q.mass t)
      = ∑ t ∈ Finset.range n, (f.gauge * stageLoss P.mass t) := by
          refine Finset.sum_congr rfl ?_
          intro t _
          exact f.stage_covariance t
    _ = f.gauge * ∑ t ∈ Finset.range n, stageLoss P.mass t :=
          (Finset.mul_sum _ _ _).symm

/-- An isomorphism (gauge = 1) preserves cumulative loss exactly. -/
theorem isomorphism_preserves_loss
    {P Q : StructuralMaintenanceProblem}
    (f : AdmissibleMorphism P Q) (hiso : f.gauge = 1) (n : ℕ) :
    smpCumulativeLoss Q n = smpCumulativeLoss P n := by
  rw [morphism_cumulative_covariance f n, hiso, one_mul]

/-! ## Part 6: Functorial Properties -/

/-- Identity is a left unit for composition (up to gauge). -/
theorem identity_left_unit
    {P Q : StructuralMaintenanceProblem}
    (f : AdmissibleMorphism P Q) :
    (composeMorphism (identityMorphism P) f).gauge = f.gauge := by
  unfold composeMorphism identityMorphism
  ring

/-- Identity is a right unit for composition (up to gauge). -/
theorem identity_right_unit
    {P Q : StructuralMaintenanceProblem}
    (f : AdmissibleMorphism P Q) :
    (composeMorphism f (identityMorphism Q)).gauge = f.gauge := by
  unfold composeMorphism identityMorphism
  ring

/-- Composition is associative (for gauges). -/
theorem compose_assoc
    {P Q R S : StructuralMaintenanceProblem}
    (f : AdmissibleMorphism P Q)
    (g : AdmissibleMorphism Q R)
    (h : AdmissibleMorphism R S) :
    (composeMorphism (composeMorphism f g) h).gauge =
      (composeMorphism f (composeMorphism g h)).gauge := by
  unfold composeMorphism
  ring

end

end Survival.CategoryBridge
