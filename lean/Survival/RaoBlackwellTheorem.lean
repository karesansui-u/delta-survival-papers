import Survival.SufficientStatisticBridge
import Survival.SaturationDefect

/-!
# Rao-Blackwell Theorem — Structural Persistence Derivation

Sufficient coarse-grainings minimize accounting error.
-/

namespace Survival.RaoBlackwellTheorem

open Survival.SaturationDefect
open Survival.TelescopingExp

noncomputable section

/-- Coarse loss = micro loss + boundary defect. -/
theorem estimation_error
    (m mcoarse e : ℕ → ℝ) (n : ℕ)
    (hdef : SaturationDefectReadout m mcoarse e n) :
    Survival.AdmissibleMapInvariants.cumulativeStageLoss mcoarse n =
      Survival.AdmissibleMapInvariants.cumulativeStageLoss m n +
        e 0 - e n :=
  coarse_cumulativeStageLoss_eq_micro_add_initial_defect_sub_terminal
    m mcoarse e n hdef

def IsSufficient (e : ℕ → ℝ) (n : ℕ) : Prop := e 0 = e n

/-- Under sufficiency, coarse = micro. -/
theorem rao_blackwell_exact
    (m mcoarse e : ℕ → ℝ) (n : ℕ)
    (hdef : SaturationDefectReadout m mcoarse e n)
    (hsuff : IsSufficient e n) :
    Survival.AdmissibleMapInvariants.cumulativeStageLoss mcoarse n =
      Survival.AdmissibleMapInvariants.cumulativeStageLoss m n := by
  have h := estimation_error m mcoarse e n hdef
  unfold IsSufficient at hsuff; linarith

/-- When e(0) ≤ e(n), coarse ≤ micro. -/
theorem coarse_underestimates
    (m mcoarse e : ℕ → ℝ) (n : ℕ)
    (hdef : SaturationDefectReadout m mcoarse e n)
    (hgrow : e 0 ≤ e n) :
    Survival.AdmissibleMapInvariants.cumulativeStageLoss mcoarse n ≤
      Survival.AdmissibleMapInvariants.cumulativeStageLoss m n :=
  coarse_cumulativeStageLoss_le_micro_of_terminal_defect_ge_initial
    m mcoarse e n hdef hgrow

/-- When e(n) ≤ e(0), micro ≤ coarse. -/
theorem coarse_overestimates
    (m mcoarse e : ℕ → ℝ) (n : ℕ)
    (hdef : SaturationDefectReadout m mcoarse e n)
    (hshrink : e n ≤ e 0) :
    Survival.AdmissibleMapInvariants.cumulativeStageLoss m n ≤
      Survival.AdmissibleMapInvariants.cumulativeStageLoss mcoarse n := by
  have h := estimation_error m mcoarse e n hdef; linarith

/-- Defect magnitude = |coarse - micro|. -/
theorem defect_magnitude
    (m mcoarse e : ℕ → ℝ) (n : ℕ)
    (hdef : SaturationDefectReadout m mcoarse e n) :
    Survival.AdmissibleMapInvariants.cumulativeStageLoss mcoarse n -
      Survival.AdmissibleMapInvariants.cumulativeStageLoss m n =
        e 0 - e n := by
  have h := estimation_error m mcoarse e n hdef; linarith

end

end Survival.RaoBlackwellTheorem
