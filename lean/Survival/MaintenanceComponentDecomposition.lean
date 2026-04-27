import Mathlib.Data.Real.Basic

/-!
# Maintenance Component Decomposition

This module formalizes the M-side operational vocabulary used in the resource
term supplement.

The key distinction is type-level:

* `MaintenanceComponent` has exactly three constructors:
  `buffer`, `recovery`, and `reconfiguration`.
* `SupplyChannel` has exactly two constructors: `internal` and `external`.

Thus `external` is not a fourth maintenance component in this formal language.
It is a supply channel that can provide any of the three maintenance components.

This file is intentionally an operational grammar, not an empirical theorem:
it does not claim that these coordinates are naturally measurable in every
domain, that a particular aggregator `Φ` is universal, or that a given proxy is
valid out of sample.
-/

namespace Survival.MaintenanceComponentDecomposition

universe u v w

/-- The three internal maintenance components used by the M supplement. -/
inductive MaintenanceComponent where
  | buffer
  | recovery
  | reconfiguration
  deriving DecidableEq, Repr

namespace MaintenanceComponent

/-- The component language is exhausted by buffer, recovery, and reconfiguration. -/
theorem exhaustive (c : MaintenanceComponent) :
    c = buffer ∨ c = recovery ∨ c = reconfiguration := by
  cases c with
  | buffer => exact Or.inl rfl
  | recovery => exact Or.inr (Or.inl rfl)
  | reconfiguration => exact Or.inr (Or.inr rfl)

end MaintenanceComponent

/-- A maintenance component can be supplied by the base system or externally. -/
inductive SupplyChannel where
  | internal
  | external
  deriving DecidableEq, Repr

namespace SupplyChannel

/-- The supply-channel language is exhausted by internal and external supply. -/
theorem exhaustive (ch : SupplyChannel) :
    ch = internal ∨ ch = external := by
  cases ch with
  | internal => exact Or.inl rfl
  | external => exact Or.inr rfl

end SupplyChannel

/-- A profile over the three maintenance components. -/
abbrev ComponentProfile (α : Type u) := MaintenanceComponent → α

/-- A profile that records, for each supply channel, how much of each component is supplied. -/
abbrev SupplyProfile (α : Type u) := SupplyChannel → MaintenanceComponent → α

/-- The internally supplied component profile. -/
def internalProfile (M : SupplyProfile α) : ComponentProfile α :=
  M SupplyChannel.internal

/-- The externally supplied component profile. -/
def externalProfile (M : SupplyProfile α) : ComponentProfile α :=
  M SupplyChannel.external

/-- Build a full supply profile from its internal and external component profiles. -/
def fromInternalExternal
    (internal external : ComponentProfile α) : SupplyProfile α :=
  fun ch c =>
    match ch with
    | SupplyChannel.internal => internal c
    | SupplyChannel.external => external c

@[simp] theorem fromInternalExternal_internal
    (internal external : ComponentProfile α) (c : MaintenanceComponent) :
    fromInternalExternal internal external SupplyChannel.internal c = internal c := rfl

@[simp] theorem fromInternalExternal_external
    (internal external : ComponentProfile α) (c : MaintenanceComponent) :
    fromInternalExternal internal external SupplyChannel.external c = external c := rfl

@[simp] theorem internalProfile_fromInternalExternal
    (internal external : ComponentProfile α) :
    internalProfile (fromInternalExternal internal external) = internal := rfl

@[simp] theorem externalProfile_fromInternalExternal
    (internal external : ComponentProfile α) :
    externalProfile (fromInternalExternal internal external) = external := rfl

/-- Any component profile is fully determined by its three component coordinates. -/
theorem componentProfile_ext {p q : ComponentProfile α}
    (hbuffer : p MaintenanceComponent.buffer = q MaintenanceComponent.buffer)
    (hrecovery : p MaintenanceComponent.recovery = q MaintenanceComponent.recovery)
    (hreconfiguration :
      p MaintenanceComponent.reconfiguration = q MaintenanceComponent.reconfiguration) :
    p = q := by
  funext c
  cases c with
  | buffer => exact hbuffer
  | recovery => exact hrecovery
  | reconfiguration => exact hreconfiguration

/-- There is no hidden fourth coordinate in a component profile. -/
theorem componentProfile_eq_three_coordinate_reconstruction
    (p : ComponentProfile α) :
    p =
      fun c =>
        match c with
        | MaintenanceComponent.buffer => p MaintenanceComponent.buffer
        | MaintenanceComponent.recovery => p MaintenanceComponent.recovery
        | MaintenanceComponent.reconfiguration => p MaintenanceComponent.reconfiguration := by
  funext c
  cases c <;> rfl

/--
A full supply profile is fully determined by six coordinates:
internal/external supply for each of the three maintenance components.
-/
theorem supplyProfile_ext {p q : SupplyProfile α}
    (hibuffer :
      p SupplyChannel.internal MaintenanceComponent.buffer =
        q SupplyChannel.internal MaintenanceComponent.buffer)
    (hirecovery :
      p SupplyChannel.internal MaintenanceComponent.recovery =
        q SupplyChannel.internal MaintenanceComponent.recovery)
    (hireconfiguration :
      p SupplyChannel.internal MaintenanceComponent.reconfiguration =
        q SupplyChannel.internal MaintenanceComponent.reconfiguration)
    (hebuffer :
      p SupplyChannel.external MaintenanceComponent.buffer =
        q SupplyChannel.external MaintenanceComponent.buffer)
    (herecovery :
      p SupplyChannel.external MaintenanceComponent.recovery =
        q SupplyChannel.external MaintenanceComponent.recovery)
    (hereconfiguration :
      p SupplyChannel.external MaintenanceComponent.reconfiguration =
        q SupplyChannel.external MaintenanceComponent.reconfiguration) :
    p = q := by
  funext ch c
  cases ch <;> cases c
  · exact hibuffer
  · exact hirecovery
  · exact hireconfiguration
  · exact hebuffer
  · exact herecovery
  · exact hereconfiguration

/--
Every supply profile decomposes into an internal component profile and an
external component profile.
-/
theorem fromInternalExternal_internalProfile_externalProfile
    (M : SupplyProfile α) :
    fromInternalExternal (internalProfile M) (externalProfile M) = M := by
  funext ch c
  cases ch <;> rfl

/-- The internal/external decomposition of a supply profile is unique. -/
theorem fromInternalExternal_eq_iff
    {internal external internal' external' : ComponentProfile α} :
    fromInternalExternal internal external =
        fromInternalExternal internal' external' ↔
      internal = internal' ∧ external = external' := by
  constructor
  · intro h
    constructor
    · funext c
      exact congrFun (congrFun h SupplyChannel.internal) c
    · funext c
      exact congrFun (congrFun h SupplyChannel.external) c
  · intro h
    rcases h with ⟨rfl, rfl⟩
    rfl

/--
Combine internal and external supply of each component into an effective
component profile.  The aggregator `A` is component-wise: external supply enters
only through the component it supplies.
-/
def effectiveProfile
    (A : MaintenanceComponent → α → α → β)
    (M : SupplyProfile α) : ComponentProfile β :=
  fun c => A c (internalProfile M c) (externalProfile M c)

@[simp] theorem effectiveProfile_apply
    (A : MaintenanceComponent → α → α → β)
    (M : SupplyProfile α) (c : MaintenanceComponent) :
    effectiveProfile A M c =
      A c (M SupplyChannel.internal c) (M SupplyChannel.external c) := rfl

/-- Aggregate an effective component profile into a scalar maintenance capacity. -/
def effectiveMaintenance
    (Φ : ComponentProfile β → γ)
    (A : MaintenanceComponent → α → α → β)
    (M : SupplyProfile α) : γ :=
  Φ (effectiveProfile A M)

/--
If internal/external supplies are nonnegative and the component-wise aggregator
preserves nonnegativity, then the effective component profile is nonnegative.
-/
theorem effectiveProfile_nonneg
    (A : MaintenanceComponent → ℝ → ℝ → ℝ)
    (M : SupplyProfile ℝ)
    (hA : ∀ c x y, 0 ≤ x → 0 ≤ y → 0 ≤ A c x y)
    (hM : ∀ ch c, 0 ≤ M ch c) :
    ∀ c, 0 ≤ effectiveProfile A M c := by
  intro c
  exact hA c _ _ (hM SupplyChannel.internal c) (hM SupplyChannel.external c)

/--
If the final aggregator preserves nonnegativity of component profiles, then the
scalar effective maintenance capacity is nonnegative.
-/
theorem effectiveMaintenance_nonneg
    (Φ : ComponentProfile ℝ → ℝ)
    (A : MaintenanceComponent → ℝ → ℝ → ℝ)
    (M : SupplyProfile ℝ)
    (hΦ : ∀ p : ComponentProfile ℝ, (∀ c, 0 ≤ p c) → 0 ≤ Φ p)
    (hA : ∀ c x y, 0 ≤ x → 0 ≤ y → 0 ≤ A c x y)
    (hM : ∀ ch c, 0 ≤ M ch c) :
    0 ≤ effectiveMaintenance Φ A M :=
  hΦ (effectiveProfile A M) (effectiveProfile_nonneg A M hA hM)

end Survival.MaintenanceComponentDecomposition
