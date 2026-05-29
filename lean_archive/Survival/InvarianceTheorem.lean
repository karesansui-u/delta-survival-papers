import Survival.AdmissibleMapInvariants
import Survival.TelescopingExp
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Invariance Theorem — Coordinate Invariance of Structural Loss

This module proves that the structural consumption l_i = -log(R_i) is
**invariant** under positive rescaling of the measure m, and
**covariant** under power-law reparametrization.

## The theorem

If m' = α · m for some α > 0, then:
    l_i' = -log(m'(V^{(i+1)}) / m'(V^{(i)}))
         = -log((α m_{i+1}) / (α m_i))
         = -log(m_{i+1} / m_i)
         = l_i

The stage loss is independent of the overall scale of m.

More generally, if m' = m^β for β > 0, then l_i' = β · l_i
(gauge covariance, already in AdmissibleMapInvariants).

## Significance

This is the structural-persistence analogue of the principle that
physical laws must be independent of the choice of units (dimensional
analysis / Buckingham π theorem). The structural consumption rate
is a "dimensionless" quantity — it measures proportional change,
not absolute change.

References:
  - Buckingham, E. (1914). "On physically similar systems."
  - Bridgman, P.W. (1931). "Dimensional Analysis."
  - AdmissibleMapInvariants.lean: gauge covariance
  - NoetherBridge.lean: conservation from symmetry
-/

namespace Survival.InvarianceTheorem

open Real
open Survival.TelescopingExp

noncomputable section

/-! ## Part 1: Scale Invariance of Stage Loss -/

/-- **Scale Invariance Theorem**: The stage loss l_i = -log(m_{i+1}/m_i)
    is invariant under positive rescaling m' = α·m.

    This is because the ratio m_{i+1}/m_i cancels the scale factor:
    (α m_{i+1}) / (α m_i) = m_{i+1} / m_i. -/
theorem stageLoss_scale_invariant (m : ℕ → ℝ) (α : ℝ) (hα : 0 < α)
    (i : ℕ) (hm : 0 < m i) (hm1 : 0 < m (i + 1)) :
    stageLoss (fun n => α * m n) i = stageLoss m i := by
  unfold stageLoss
  congr 1
  rw [show α * m (i + 1) / (α * m i) = m (i + 1) / m i from by
    rw [mul_div_mul_left _ _ (ne_of_gt hα)]]

/-- Cumulative loss is also scale invariant. -/
theorem cumulativeLoss_scale_invariant (m : ℕ → ℝ) (α : ℝ) (hα : 0 < α)
    (n : ℕ) (hm : ∀ i ≤ n, 0 < m i) :
    Survival.AdmissibleMapInvariants.cumulativeStageLoss
      (fun k => α * m k) n =
    Survival.AdmissibleMapInvariants.cumulativeStageLoss m n := by
  unfold Survival.AdmissibleMapInvariants.cumulativeStageLoss
  refine Finset.sum_congr rfl ?_
  intro i hi
  have hi_le : i ≤ n := Nat.le_of_lt (Finset.mem_range.mp hi)
  have hi1_le : i + 1 ≤ n :=  Nat.succ_le_of_lt (Finset.mem_range.mp hi)
  exact stageLoss_scale_invariant m α hα i (hm i hi_le) (hm (i + 1) hi1_le)

/-! ## Part 2: Ratio Invariance (the deep reason) -/

/-- The fundamental reason for scale invariance: the ratio R_i = m_{i+1}/m_i
    is scale-independent. -/
theorem ratio_scale_invariant (m : ℕ → ℝ) (α : ℝ) (hα : α ≠ 0)
    (i : ℕ) :
    α * m (i + 1) / (α * m i) = m (i + 1) / m i := by
  rw [mul_div_mul_left _ _ hα]

/-- Scale invariance means the loss measures *proportional* change,
    not *absolute* change. This is why structural consumption is
    a natural "dimensionless" quantity. -/
theorem proportional_not_absolute (m : ℕ → ℝ) (i : ℕ)
    (hm : 0 < m i) (hm1 : 0 < m (i + 1)) :
    stageLoss m i = -log (m (i + 1) / m i) := rfl

/-! ## Part 3: Power-Law Covariance -/

-- Power-law covariance: see `AdmissibleMapInvariants.positive_gauge_covariance`.

/-- The retention factor exp(-L) at step n is also scale invariant:
    changing m to α·m doesn't change exp(-Σ l_i). -/
theorem retention_scale_invariant (m : ℕ → ℝ) (α : ℝ) (hα : 0 < α)
    (n : ℕ) (hm : ∀ i ≤ n, 0 < m i) :
    exp (-∑ i ∈ Finset.range n, stageLoss (fun k => α * m k) i) =
    exp (-∑ i ∈ Finset.range n, stageLoss m i) := by
  congr 1
  congr 1
  refine Finset.sum_congr rfl ?_
  intro i hi
  have hi_le := Nat.le_of_lt (Finset.mem_range.mp hi)
  have hi1_le := Nat.succ_le_of_lt (Finset.mem_range.mp hi)
  exact stageLoss_scale_invariant m α hα i (hm i hi_le) (hm (i + 1) hi1_le)

/-! ## Part 5: Summary -/

/-- **Invariance Theorem (complete):**
    1. Stage loss is scale-invariant (α-rescaling)
    2. Stage loss is power-covariant (β-reparametrization: l' = βl)
    3. Retention factor exp(-L) is scale-invariant
    4. These invariances hold because loss measures proportional change

    This establishes structural consumption as a coordinate-independent
    quantity — analogous to proper time in relativity or entropy in
    thermodynamics. -/
theorem invariance_summary (m : ℕ → ℝ) (α : ℝ) (hα : 0 < α)
    (n : ℕ) (hm : ∀ i ≤ n, 0 < m i) :
    -- Scale invariance of cumulative loss
    Survival.AdmissibleMapInvariants.cumulativeStageLoss
      (fun k => α * m k) n =
    Survival.AdmissibleMapInvariants.cumulativeStageLoss m n ∧
    -- Scale invariance of retention
    exp (-∑ i ∈ Finset.range n, stageLoss (fun k => α * m k) i) =
    exp (-∑ i ∈ Finset.range n, stageLoss m i) :=
  ⟨cumulativeLoss_scale_invariant m α hα n hm,
   retention_scale_invariant m α hα n hm⟩

end

end Survival.InvarianceTheorem
