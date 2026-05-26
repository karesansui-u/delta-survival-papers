import Mathlib.Tactic.Linarith
import Survival.EpistemicControlBridge

/-!
# Epistemic Control Comparison

This file strengthens the epistemic-control bridge with a baseline comparison
lemma.  It does not compare real LLM systems or prove model performance.
Instead, it proves a finite, assumption-explicit statement:

if a controlled epistemic layer has the same initial coherent mass as a
baseline layer and no larger cumulative net action, then the controlled layer
retains at least as much coherent mass at the same finite horizon.
-/

namespace Survival.EpistemicControlComparison

open Survival.EpistemicControlBridge
open Survival.GeneralStateDynamics

noncomputable section

variable {X : Type*}

/-- Exponential survival factor read from the epistemic net action. -/
def survivalFactor (S : EpistemicControlSpec X) (n : ℕ) : ℝ :=
  Real.exp (-(cumulativeEpistemicNetAction S n))

/-- Same initial coherent mass for two epistemic-control layers. -/
def SameInitialMass
    (controlled baseline : EpistemicControlSpec X) : Prop :=
  coherentMass controlled 0 = coherentMass baseline 0

/-- The controlled layer has no larger cumulative net action than baseline. -/
def NetActionNoWorse
    (controlled baseline : EpistemicControlSpec X) (n : ℕ) : Prop :=
  cumulativeEpistemicNetAction controlled n ≤
    cumulativeEpistemicNetAction baseline n

/-- Package the finite comparison assumptions for a horizon `n`. -/
structure BaselineComparison
    (controlled baseline : EpistemicControlSpec X) (n : ℕ) : Prop where
  same_initial_mass : SameInitialMass controlled baseline
  net_action_no_worse : NetActionNoWorse controlled baseline n

/-- Smaller cumulative net action gives a larger exponential survival factor. -/
theorem survivalFactor_ge_of_netActionNoWorse
    (controlled baseline : EpistemicControlSpec X) (n : ℕ)
    (hnet : NetActionNoWorse controlled baseline n) :
    survivalFactor baseline n ≤ survivalFactor controlled n := by
  unfold survivalFactor NetActionNoWorse at *
  exact Real.exp_le_exp.mpr (by linarith)

/-- Main comparison theorem.

Under the bridge positivity hypotheses, equal initial coherent mass, and a
no-worse cumulative net action, the controlled layer preserves at least the
baseline coherent mass at the same finite horizon. -/
theorem controlled_coherentMass_ge_baseline_of_same_initial
    (controlled baseline : EpistemicControlSpec X) (n : ℕ)
    (hcontrolled :
      PositiveTrajectory (toProblemSpec controlled) n)
    (hbaseline :
      PositiveTrajectory (toProblemSpec baseline) n)
    (hinitial_nonneg : 0 ≤ coherentMass baseline 0)
    (hsame : SameInitialMass controlled baseline)
    (hnet : NetActionNoWorse controlled baseline n) :
    coherentMass baseline n ≤ coherentMass controlled n := by
  have hfactor :
      survivalFactor baseline n ≤ survivalFactor controlled n :=
    survivalFactor_ge_of_netActionNoWorse controlled baseline n hnet
  calc
    coherentMass baseline n =
        coherentMass baseline 0 * survivalFactor baseline n := by
          simpa [survivalFactor] using
            epistemic_control_composition_kernel baseline n hbaseline
    _ ≤ coherentMass baseline 0 * survivalFactor controlled n :=
          mul_le_mul_of_nonneg_left hfactor hinitial_nonneg
    _ = coherentMass controlled 0 * survivalFactor controlled n := by
          rw [hsame]
    _ = coherentMass controlled n := by
          simpa [survivalFactor] using
            (epistemic_control_composition_kernel
              controlled n hcontrolled).symm

/-- Positivity of the baseline trajectory supplies the nonnegative initial mass
needed by the comparison theorem. -/
theorem controlled_coherentMass_ge_baseline
    (controlled baseline : EpistemicControlSpec X) (n : ℕ)
    (hcontrolled :
      PositiveTrajectory (toProblemSpec controlled) n)
    (hbaseline :
      PositiveTrajectory (toProblemSpec baseline) n)
    (hcmp : BaselineComparison controlled baseline n) :
    coherentMass baseline n ≤ coherentMass controlled n :=
  controlled_coherentMass_ge_baseline_of_same_initial
    controlled baseline n hcontrolled hbaseline
    ((hbaseline.feasible_pos 0 (Nat.zero_le n)).le)
    hcmp.same_initial_mass hcmp.net_action_no_worse

end

end Survival.EpistemicControlComparison
