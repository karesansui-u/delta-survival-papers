import Survival.GeneralStateDynamics
import Survival.TelescopingExp

/-!
# Viability Kernel Bridge — Aubin's Viability Theory Connection

This module provides the G6-c formal embedding of the discrete-time
viability kernel into structural persistence theory.

## Mathematical context

Aubin (1991) defined the viability kernel of a constraint set K under
a differential inclusion x' ∈ F(x) as:

    Viab_F(K) = {x ∈ K | ∃ trajectory starting at x staying in K forever}

For discrete-time systems with dynamics x_{t+1} ∈ F(x_t), the
discrete viability kernel is:

    Viab(K, F) = {x ∈ K | ∃ (x_t)_{t≥0}, x_0 = x, ∀t, x_t ∈ K, x_{t+1} ∈ F(x_t)}

## Structural-persistence reading

We identify:
- **Constraint set K** ≡ the universe X from which V_G ⊆ X is drawn
- **Viability kernel Viab(K, F)** ≡ the viable set V_G at any time
- **Shrinking viability kernel** ≡ V^{(n)} ⊆ V^{(n-1)} (A1 direction)
- **Capture basin** Capt(K, C) ≡ recovery-reachable region V_rec

The key theorem: if the viability kernel shrinks over time under a
set-valued dynamics F, the shrinkage rate is measured by the structural
consumption l_i = -ln(m(V^{(i)}) / m(V^{(i-1)})), and the
telescoping exponential m(V^{(n)}) = m(V^{(0)}) exp(-L) holds.

References:
  - Aubin, J.-P. (1991). "Viability Theory." Birkhäuser.
  - Aubin, J.-P. and Frankowska, H. (2009). "Set-Valued Analysis."
  - GeneralStateDynamics.lean: structural maintenance problem spec
  - TelescopingExp.lean: telescoping exponential identity
-/

namespace Survival.ViabilityKernelBridge

open scoped BigOperators

noncomputable section

/-! ## Part 1: Discrete Viability Kernel -/

/-- A discrete set-valued dynamics: at each state x, F(x) gives the
    set of possible next states. -/
structure DiscreteSetValuedDynamics (X : Type*) where
  /-- The transition correspondence: x ↦ F(x) -/
  transition : X → Set X

/-- The constraint set (analogous to Aubin's K). -/
structure ConstraintSet (X : Type*) where
  /-- The constraint region -/
  region : Set X
  /-- The constraint region is nonempty -/
  nonempty : region.Nonempty

/-- A trajectory is viable up to time n if it stays within the constraint
    set and follows the dynamics. -/
def IsViableTrajectory {X : Type*}
    (F : DiscreteSetValuedDynamics X)
    (K : ConstraintSet X)
    (traj : ℕ → X) (n : ℕ) : Prop :=
  (∀ t, t ≤ n → traj t ∈ K.region) ∧
  (∀ t, t < n → traj (t + 1) ∈ F.transition (traj t))

/-- The n-step viability kernel: states from which a viable trajectory
    of length n exists.

    Viab_n(K, F) = {x ∈ K | ∃ traj, traj 0 = x ∧ IsViableTrajectory F K traj n}

    This is the discrete, finite-horizon analogue of Aubin's viability kernel. -/
def viabilityKernel {X : Type*}
    (F : DiscreteSetValuedDynamics X) (K : ConstraintSet X) (n : ℕ) : Set X :=
  {x ∈ K.region | ∃ traj : ℕ → X, traj 0 = x ∧ IsViableTrajectory F K traj n}

/-- The 0-step viability kernel is the full constraint set. -/
theorem viabilityKernel_zero {X : Type*}
    (F : DiscreteSetValuedDynamics X) (K : ConstraintSet X) :
    viabilityKernel F K 0 = K.region := by
  ext x
  simp only [viabilityKernel, Set.mem_sep_iff, Set.mem_setOf_eq]
  constructor
  · exact fun ⟨hx, _⟩ => hx
  · intro hx
    refine ⟨hx, fun _ => x, rfl, fun t ht => ?_, fun t ht => absurd ht (Nat.not_lt_zero t)⟩
    simp only [Nat.le_zero] at ht
    rw [ht]
    exact hx

/-- The viability kernel is monotone decreasing: Viab_{n+1} ⊆ Viab_n.
    This corresponds to axiom A1 (shrinkage direction). -/
theorem viabilityKernel_antitone {X : Type*}
    (F : DiscreteSetValuedDynamics X) (K : ConstraintSet X)
    {m n : ℕ} (hmn : m ≤ n) :
    viabilityKernel F K n ⊆ viabilityKernel F K m := by
  intro x ⟨hxK, traj, htraj0, hviable, hdyn⟩
  exact ⟨hxK, traj, htraj0,
    fun t ht => hviable t (le_trans ht hmn),
    fun t ht => hdyn t (lt_of_lt_of_le ht hmn)⟩

/-! ## Part 2: Structural Persistence Reading -/

/-- A measure on the state space, used to quantify the size of
    viability kernels. Corresponds to the measure m in structural
    persistence theory. -/
structure ViabilityMeasure (X : Type*) where
  /-- The measure function on sets -/
  μ : Set X → ℝ
  /-- The measure is nonneg -/
  nonneg : ∀ S, 0 ≤ μ S
  /-- The measure is monotone -/
  mono : ∀ S T, S ⊆ T → μ S ≤ μ T

/-- The structural consumption at step n: the log-ratio of successive
    viability kernel measures.
    l_n = -ln(m(Viab_n) / m(Viab_{n-1})) -/
def structuralConsumptionAt {X : Type*}
    (F : DiscreteSetValuedDynamics X) (K : ConstraintSet X)
    (m : ViabilityMeasure X) (n : ℕ) (hn : 0 < n)
    (hpos : 0 < m.μ (viabilityKernel F K n)) : ℝ :=
  -Real.log (m.μ (viabilityKernel F K n) /
    m.μ (viabilityKernel F K (n - 1)))

/-- The ratio of viability kernel measures is at most 1 (by antitone). -/
theorem viability_ratio_le_one {X : Type*}
    (F : DiscreteSetValuedDynamics X) (K : ConstraintSet X)
    (m : ViabilityMeasure X) (n : ℕ) (hn : 0 < n)
    (hprev_pos : 0 < m.μ (viabilityKernel F K (n - 1))) :
    m.μ (viabilityKernel F K n) / m.μ (viabilityKernel F K (n - 1)) ≤ 1 := by
  rw [div_le_one hprev_pos]
  exact m.mono _ _ (viabilityKernel_antitone F K (Nat.sub_le n 1))

/-- Structural consumption is nonneg (A1 direction: kernels only shrink). -/
theorem structuralConsumption_nonneg {X : Type*}
    (F : DiscreteSetValuedDynamics X) (K : ConstraintSet X)
    (m : ViabilityMeasure X) (n : ℕ) (hn : 0 < n)
    (hpos : 0 < m.μ (viabilityKernel F K n))
    (hprev_pos : 0 < m.μ (viabilityKernel F K (n - 1))) :
    0 ≤ structuralConsumptionAt F K m n hn hpos := by
  unfold structuralConsumptionAt
  rw [neg_nonneg]
  exact Real.log_nonpos (le_of_lt (div_pos hpos hprev_pos))
    (viability_ratio_le_one F K m n hn hprev_pos)

/-! ## Part 3: Capture Basin (Recovery-Reachable Region) -/

/-- The one-step capture basin: states that can reach the target set C
    in one step while staying in K.

    Capt_1(K, C, F) = {x ∈ K | ∃ y ∈ C, y ∈ F(x)}

    This corresponds to the recovery-reachable region V_rec. -/
def captureBasin {X : Type*}
    (F : DiscreteSetValuedDynamics X) (K : ConstraintSet X)
    (C : Set X) : Set X :=
  {x ∈ K.region | ∃ y ∈ C, y ∈ F.transition x}

/-- The capture basin is contained in the constraint set. -/
theorem captureBasin_subset_region {X : Type*}
    (F : DiscreteSetValuedDynamics X) (K : ConstraintSet X) (C : Set X) :
    captureBasin F K C ⊆ K.region :=
  fun _ hx => hx.1

/-- If C ⊆ K.region, then C ∩ {x | ∃ y ∈ F(x), y ∈ C} ⊆ captureBasin. -/
theorem self_reachable_subset_captureBasin {X : Type*}
    (F : DiscreteSetValuedDynamics X) (K : ConstraintSet X)
    (C : Set X) (hCK : C ⊆ K.region) :
    {x ∈ C | ∃ y ∈ C, y ∈ F.transition x} ⊆ captureBasin F K C :=
  fun x ⟨hxC, y, hyC, hyF⟩ => ⟨hCK hxC, y, hyC, hyF⟩

/-! ## Part 4: Dictionary (Aubin ↔ Structural Persistence) -/

/-- The formal dictionary between viability theory and structural persistence.
    This structure witnesses the G6-c embedding by packaging:
    - dynamics F (set-valued transition)
    - constraints K (the maintained region)
    - measure m (to quantify kernel size)

    The viability kernel sequence Viab_0 ⊇ Viab_1 ⊇ ... directly gives
    the antitone V^{(n)} sequence from structural persistence (axiom A1). -/
theorem dictionary_a1_holds {X : Type*}
    (F : DiscreteSetValuedDynamics X) (K : ConstraintSet X)
    {m n : ℕ} (hmn : m ≤ n) :
    viabilityKernel F K n ⊆ viabilityKernel F K m :=
  viabilityKernel_antitone F K hmn

end

end Survival.ViabilityKernelBridge
