import Mathlib.Tactic.Linarith
import Survival.GeneralStateDynamics

/-!
# Epistemic Control Bridge

This file is a thin bridge from LLM-style epistemic control language to the
existing structural-persistence accounting kernel.

It does not formalize natural-language meaning, model weights, or LLM
performance.  Instead, an epistemic control layer supplies:

* a state space of epistemic configurations;
* a coherent / feasible region at each finite step;
* a contradiction update, read as contraction;
* a repair update, read as expansion after contraction;
* optional local guard lemmas for memory eligibility and dependency rewrites.

The main theorem is a wrapper around `GeneralStateDynamics`: once the epistemic
control layer satisfies the contraction / repair interface and positivity
conditions, coherent mass follows the same signed exponential net-action kernel.
-/

open scoped BigOperators

namespace Survival.EpistemicControlBridge

open Survival.GeneralStateDynamics

noncomputable section

variable {X : Type*}

/-- Minimal abstract interface for an epistemic control layer.

`X` is the type of complete epistemic configurations.  The bridge is agnostic
about whether a configuration is represented by claims, assumptions,
provenance labels, dependency graphs, memory states, or an implementation
record.  The only mathematical commitments are the mass readout and the
contraction / repair laws. -/
structure EpistemicControlSpec (X : Type*) where
  initialRegion : Set X
  massModel : MassModel X
  contradictionUpdate : ℕ → Set X → Set X
  repairUpdate : ℕ → Set X → Set X
  contradiction_contracts : ∀ t A, contradictionUpdate t A ⊆ A
  repair_expands : ∀ t A, A ⊆ repairUpdate t A

/-- The epistemic bridge as a `GeneralStateDynamics` dynamics object. -/
def toDynamics (S : EpistemicControlSpec X) : Dynamics X where
  contract := S.contradictionUpdate
  repair := S.repairUpdate
  contract_sub := S.contradiction_contracts
  repair_sup := S.repair_expands

/-- The epistemic bridge as an existing structural-persistence problem. -/
def toProblemSpec (S : EpistemicControlSpec X) : ProblemSpec X where
  V0 := S.initialRegion
  M := S.massModel
  D := toDynamics S

/-- Coherent epistemic region after `t` controlled steps. -/
def feasibleEpistemicRegion (S : EpistemicControlSpec X) (t : ℕ) : Set X :=
  feasible (toProblemSpec S) t

/-- Coherent mass of the epistemic region after `t` controlled steps. -/
def coherentMass (S : EpistemicControlSpec X) (t : ℕ) : ℝ :=
  feasibleMass (toProblemSpec S) t

/-- One-step contradiction loss, inherited from the general state dynamics. -/
def contradictionLoss (S : EpistemicControlSpec X) (t : ℕ) : ℝ :=
  stepLoss (toProblemSpec S) t

/-- One-step repair gain, inherited from the general state dynamics. -/
def repairGain (S : EpistemicControlSpec X) (t : ℕ) : ℝ :=
  stepGain (toProblemSpec S) t

/-- One-step epistemic net action: contradiction loss minus repair gain. -/
def epistemicNetAction (S : EpistemicControlSpec X) (t : ℕ) : ℝ :=
  stepNetAction (toProblemSpec S) t

/-- Cumulative epistemic net action over the finite prefix `0, ..., n-1`. -/
def cumulativeEpistemicNetAction (S : EpistemicControlSpec X) (n : ℕ) : ℝ :=
  cumulativeNetAction (toProblemSpec S) n

/-- A contradiction update contracts the current feasible epistemic region. -/
theorem contradiction_update_is_contraction
    (S : EpistemicControlSpec X) (t : ℕ) :
    S.contradictionUpdate t (feasibleEpistemicRegion S t) ⊆
      feasibleEpistemicRegion S t :=
  S.contradiction_contracts t (feasibleEpistemicRegion S t)

/-- A repair update expands from the post-contradiction intermediate region. -/
theorem repair_update_is_repair
    (S : EpistemicControlSpec X) (t : ℕ) :
    S.contradictionUpdate t (feasibleEpistemicRegion S t) ⊆
      S.repairUpdate t (S.contradictionUpdate t (feasibleEpistemicRegion S t)) :=
  S.repair_expands t (S.contradictionUpdate t (feasibleEpistemicRegion S t))

/-- Contradiction update cannot increase mass at the contraction substep. -/
theorem contradiction_update_mass_le_current
    (S : EpistemicControlSpec X) (t : ℕ) :
    S.massModel.mass (S.contradictionUpdate t (feasibleEpistemicRegion S t)) ≤
      S.massModel.mass (feasibleEpistemicRegion S t) :=
  S.massModel.mono (contradiction_update_is_contraction S t)

/-- Repair update cannot have less mass than the post-contradiction region. -/
theorem repair_update_mass_ge_contradiction
    (S : EpistemicControlSpec X) (t : ℕ) :
    S.massModel.mass (S.contradictionUpdate t (feasibleEpistemicRegion S t)) ≤
      S.massModel.mass
        (S.repairUpdate t (S.contradictionUpdate t (feasibleEpistemicRegion S t))) :=
  S.massModel.mono (repair_update_is_repair S t)

/-- The epistemic net action is the loss-gain difference `d_t - r_t`. -/
theorem epistemicNetAction_eq_contradictionLoss_sub_repairGain
    (S : EpistemicControlSpec X) (t : ℕ) :
    epistemicNetAction S t = contradictionLoss S t - repairGain S t := rfl

/-- Main bridge theorem: composed contradiction / repair control obeys the
existing signed exponential kernel for coherent epistemic mass. -/
theorem epistemic_control_composition_kernel
    (S : EpistemicControlSpec X) (n : ℕ)
    (hpos : PositiveTrajectory (toProblemSpec S) n) :
    coherentMass S n =
      coherentMass S 0 * Real.exp (-(cumulativeEpistemicNetAction S n)) := by
  simpa [coherentMass, cumulativeEpistemicNetAction] using
    feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction
      (P := toProblemSpec S) n hpos

/-! ## Memory eligibility guard -/

/-- Loss from a common pre-admission region to a post-admission region. -/
def lossFrom (M : MassModel X) (before after : Set X) : ℝ :=
  -Real.log (M.mass after / M.mass before)

/-- If one post-admission coherent region contains another, its loss from the
same prior region is no larger. -/
theorem lossFrom_anti_mono_after
    (M : MassModel X) {before afterA afterB : Set X}
    (hbefore : 0 < M.mass before)
    (hafterA : 0 < M.mass afterA)
    (hsubset : afterA ⊆ afterB) :
    lossFrom M before afterB ≤ lossFrom M before afterA := by
  have hmass_le : M.mass afterA ≤ M.mass afterB := M.mono hsubset
  have hafterB : 0 < M.mass afterB := lt_of_lt_of_le hafterA hmass_le
  have hratio_le :
      M.mass afterA / M.mass before ≤ M.mass afterB / M.mass before := by
    exact div_le_div_of_nonneg_right hmass_le hbefore.le
  have hlog_le :
      Real.log (M.mass afterA / M.mass before) ≤
        Real.log (M.mass afterB / M.mass before) :=
    Real.log_le_log (div_pos hafterA hbefore) hratio_le
  unfold lossFrom
  linarith

/-- Abstract comparison between an accept-all memory policy and a filtered
memory policy, read only through their resulting coherent regions. -/
structure MemoryAdmission (Raw : Type*) (X : Type*) where
  acceptAllAfter : Raw → Set X → Set X
  filteredAfter : Raw → Set X → Set X

/-- Conditional memory-filter guarantee.

If the filtered policy's post-admission coherent region contains the accept-all
policy's post-admission coherent region for a raw input, then the filtered
policy incurs no more log-ratio contradiction loss from the same prior region.
The soundness premise is where an implementation accounts for "bad memory was
blocked without discarding required coherent states." -/
theorem eligibility_filter_no_more_loss_under_soundness
    {Raw : Type*} (M : MassModel X) (A : MemoryAdmission Raw X)
    (raw : Raw) (before : Set X)
    (hbefore : 0 < M.mass before)
    (haccept : 0 < M.mass (A.acceptAllAfter raw before))
    (hsound : A.acceptAllAfter raw before ⊆ A.filteredAfter raw before) :
    lossFrom M before (A.filteredAfter raw before) ≤
      lossFrom M before (A.acceptAllAfter raw before) :=
  lossFrom_anti_mono_after M hbefore haccept hsound

/-! ## Dependency rewrite guard -/

/-- A dependency graph is represented only by its downstream closure oracle. -/
structure DependencyGraph (X : Type*) where
  downstream : X → Set X

/-- A graph has sound downstream closure for a semantic dependency relation. -/
def SoundDependencyClosure
    (G : DependencyGraph X) (semanticDepends : X → X → Prop) : Prop :=
  ∀ {root x}, semanticDepends root x → x ∈ G.downstream root

/-- Semantic invalidation induced by a set of changed roots. -/
def semanticInvalidation
    (semanticDepends : X → X → Prop) (roots : Set X) : Set X :=
  {x | ∃ root, root ∈ roots ∧ semanticDepends root x}

/-- Graph downstream closure induced by a set of changed roots. -/
def downstreamClosure (G : DependencyGraph X) (roots : Set X) : Set X :=
  {x | ∃ root, root ∈ roots ∧ x ∈ G.downstream root}

/-- A dependency rewrite transforms the operational dependency graph. -/
structure DependencyRewrite (X : Type*) where
  apply : DependencyGraph X → DependencyGraph X

/-- If the rewritten graph soundly over-approximates semantic dependency, then
semantic invalidation after a premise update is localized to the rewritten
downstream closure. -/
theorem dependency_rewrite_localizes_under_sound_closure
    (rewrite : DependencyRewrite X) (G : DependencyGraph X)
    (semanticDepends : X → X → Prop) (roots : Set X)
    (hsound : SoundDependencyClosure (rewrite.apply G) semanticDepends) :
    semanticInvalidation semanticDepends roots ⊆
      downstreamClosure (rewrite.apply G) roots := by
  intro x hx
  rcases hx with ⟨root, hroot, hdep⟩
  exact ⟨root, hroot, hsound hdep⟩

end

end Survival.EpistemicControlBridge
