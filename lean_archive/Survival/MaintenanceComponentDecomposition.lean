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

The stronger representation result is interface-relative: any raw mechanism
admitted to the M-side observation interface is represented by a
three-component profile, and any extra readout that distinguishes two
mechanisms with the same profile is outside that interface.

The quotient layer makes this universal: the M-observation quotient is the
canonical observable object, and every valid M-side readout factors uniquely
through it.
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

/-!
## Observable maintenance interfaces

The stronger "no fourth component" reading is not a claim that the real world
contains only three kinds of mechanism.  Instead, it is a representation
claim: once a raw mechanism is observed through the M-side maintenance
interface, its M-relevant effect is a three-coordinate component profile.

Any extra quantity that is a valid M-side readout must factor through that
profile.  If a proposed fourth coordinate distinguishes two raw mechanisms
with the same component profile, then it is outside this M interface rather
than an independent fourth M component.
-/

/--
An interface that observes raw mechanisms only through their M-side component
profile.
-/
structure MaintenanceInterface (ι : Type u) (α : Type v) where
  effect : ι → ComponentProfile α

namespace MaintenanceInterface

/-- The three-component profile representing a raw mechanism through the M interface. -/
def representedProfile (I : MaintenanceInterface ι α) (u : ι) : ComponentProfile α :=
  I.effect u

@[simp] theorem representedProfile_eq_effect
    (I : MaintenanceInterface ι α) (u : ι) :
    representedProfile I u = I.effect u := rfl

/-- Two raw mechanisms are equivalent when the M interface sees the same component profile. -/
def ObservationallyEquivalent (I : MaintenanceInterface ι α) (u v : ι) : Prop :=
  I.effect u = I.effect v

/-- M-observational equivalence as a setoid on raw mechanisms. -/
def observationalSetoid (I : MaintenanceInterface ι α) : Setoid ι where
  r := ObservationallyEquivalent I
  iseqv := by
    constructor
    · intro u
      rfl
    · intro u v h
      exact h.symm
    · intro u v w huv hvw
      exact huv.trans hvw

/--
The canonical M-observation quotient: raw mechanisms modulo the equivalence
relation of having the same three-component M profile.
-/
abbrev ObservationQuotient (I : MaintenanceInterface ι α) :=
  Quotient (observationalSetoid I)

/-- Send a raw mechanism to its M-observation equivalence class. -/
def quotientOf (I : MaintenanceInterface ι α) (u : ι) : ObservationQuotient I :=
  Quotient.mk (observationalSetoid I) u

theorem quotientOf_eq_iff_observationallyEquivalent
    (I : MaintenanceInterface ι α) (u v : ι) :
    quotientOf I u = quotientOf I v ↔ ObservationallyEquivalent I u v := by
  constructor
  · intro h
    exact Quotient.exact h
  · intro h
    exact Quotient.sound h

/-- Lift a raw observation to the M-observation quotient when it respects M-equivalence. -/
def quotientReadout
    (I : MaintenanceInterface ι α) (obs : ι → β)
    (hobs : ∀ u v, ObservationallyEquivalent I u v → obs u = obs v) :
    ObservationQuotient I → β :=
  Quotient.lift obs hobs

@[simp] theorem quotientReadout_quotientOf
    (I : MaintenanceInterface ι α) (obs : ι → β)
    (hobs : ∀ u v, ObservationallyEquivalent I u v → obs u = obs v)
    (u : ι) :
    quotientReadout I obs hobs (quotientOf I u) = obs u := rfl

/--
Universal property of the M-observation quotient: an observation factors
through the quotient iff it is invariant under M-observational equivalence.
-/
theorem factors_through_observationQuotient_iff_respects_equivalence
    (I : MaintenanceInterface ι α) (obs : ι → β) :
    (∃ qobs : ObservationQuotient I → β,
        obs = fun u => qobs (quotientOf I u)) ↔
      ∀ u v, ObservationallyEquivalent I u v → obs u = obs v := by
  constructor
  · intro h u v huv
    rcases h with ⟨qobs, hqobs⟩
    calc
      obs u = qobs (quotientOf I u) := congrFun hqobs u
      _ = qobs (quotientOf I v) := congrArg qobs (Quotient.sound huv)
      _ = obs v := (congrFun hqobs v).symm
  · intro hobs
    exact ⟨quotientReadout I obs hobs, by funext u; rfl⟩

/-- The quotient factorization, when it exists, is unique. -/
theorem quotientFactor_unique
    {I : MaintenanceInterface ι α} {obs : ι → β}
    {qobs qobs' : ObservationQuotient I → β}
    (hqobs : obs = fun u => qobs (quotientOf I u))
    (hqobs' : obs = fun u => qobs' (quotientOf I u)) :
    qobs = qobs' := by
  funext q
  revert q
  refine Quotient.ind ?_
  intro u
  exact (congrFun hqobs u).symm.trans (congrFun hqobs' u)

/-- The quotient still has a canonical complete three-component profile. -/
def quotientProfile (I : MaintenanceInterface ι α) :
    ObservationQuotient I → ComponentProfile α :=
  quotientReadout I I.effect (by
    intro u v huv
    exact huv)

@[simp] theorem quotientProfile_quotientOf
    (I : MaintenanceInterface ι α) (u : ι) :
    quotientProfile I (quotientOf I u) = I.effect u := rfl

/--
The three-component profile is a faithful representation of the M-observation
quotient.  If two quotient classes have the same profile, they are the same
M-observation class.
-/
theorem quotientProfile_injective
    (I : MaintenanceInterface ι α) :
    Function.Injective (quotientProfile I) := by
  intro q r h
  revert h
  refine Quotient.inductionOn₂ q r ?_
  intro u v h
  exact Quotient.sound h

/-- Equality in the M-observation quotient is exactly equality of the complete profile. -/
theorem quotientProfile_eq_iff
    (I : MaintenanceInterface ι α) (q r : ObservationQuotient I) :
    quotientProfile I q = quotientProfile I r ↔ q = r := by
  constructor
  · intro h
    exact quotientProfile_injective I h
  · intro h
    rw [h]

/--
Every raw mechanism admitted to a total M interface has a three-component
representation.
-/
theorem everyMechanism_has_threeComponentRepresentation
    (I : MaintenanceInterface ι α) (u : ι) :
    ∃ p : ComponentProfile α, p = representedProfile I u :=
  ⟨representedProfile I u, rfl⟩

/-- The representation of a raw mechanism has no hidden fourth coordinate. -/
theorem representedProfile_three_coordinate_reconstruction
    (I : MaintenanceInterface ι α) (u : ι) :
    representedProfile I u =
      fun c =>
        match c with
        | MaintenanceComponent.buffer => representedProfile I u MaintenanceComponent.buffer
        | MaintenanceComponent.recovery => representedProfile I u MaintenanceComponent.recovery
        | MaintenanceComponent.reconfiguration =>
            representedProfile I u MaintenanceComponent.reconfiguration :=
  componentProfile_eq_three_coordinate_reconstruction (representedProfile I u)

/--
M-observational equivalence is exactly equality of the three component
coordinates.
-/
theorem observationallyEquivalent_iff_three_coordinates
    {I : MaintenanceInterface ι α} {u v : ι} :
    ObservationallyEquivalent I u v ↔
      I.effect u MaintenanceComponent.buffer =
          I.effect v MaintenanceComponent.buffer ∧
        I.effect u MaintenanceComponent.recovery =
            I.effect v MaintenanceComponent.recovery ∧
          I.effect u MaintenanceComponent.reconfiguration =
            I.effect v MaintenanceComponent.reconfiguration := by
  constructor
  · intro h
    exact
      ⟨congrFun h MaintenanceComponent.buffer,
        congrFun h MaintenanceComponent.recovery,
        congrFun h MaintenanceComponent.reconfiguration⟩
  · intro h
    exact componentProfile_ext h.1 h.2.1 h.2.2

/--
If two mechanisms agree on buffer, recovery, and reconfiguration, there is no
additional M-coordinate that separates them inside this interface.
-/
theorem noFourthObservableCoordinate
    {I : MaintenanceInterface ι α} {u v : ι}
    (hbuffer :
      I.effect u MaintenanceComponent.buffer =
        I.effect v MaintenanceComponent.buffer)
    (hrecovery :
      I.effect u MaintenanceComponent.recovery =
        I.effect v MaintenanceComponent.recovery)
    (hreconfiguration :
      I.effect u MaintenanceComponent.reconfiguration =
        I.effect v MaintenanceComponent.reconfiguration) :
    ObservationallyEquivalent I u v :=
  componentProfile_ext hbuffer hrecovery hreconfiguration

/--
A quantity is an M-side readout when it factors through the three-component
profile.  Such a readout can be nonlinear or domain-specific; the only
requirement is that it uses the M interface rather than hidden raw-mechanism
data.
-/
def IsMaintenanceReadout
    (I : MaintenanceInterface ι α) (obs : ι → β) : Prop :=
  ∃ readout : ComponentProfile α → β, obs = fun u => readout (I.effect u)

/--
Any valid M-side readout is constant on M-observational equivalence classes.
-/
theorem maintenanceReadout_constant_on_observationalEquivalence
    {I : MaintenanceInterface ι α} {obs : ι → β}
    (hobs : IsMaintenanceReadout I obs)
    {u v : ι} (huv : ObservationallyEquivalent I u v) :
    obs u = obs v := by
  rcases hobs with ⟨readout, rfl⟩
  exact congrArg readout huv

/--
Every M-side readout factors through the canonical M-observation quotient.
-/
theorem maintenanceReadout_factors_through_observationQuotient
    {I : MaintenanceInterface ι α} {obs : ι → β}
    (hobs : IsMaintenanceReadout I obs) :
    ∃ qobs : ObservationQuotient I → β,
      obs = fun u => qobs (quotientOf I u) :=
  (factors_through_observationQuotient_iff_respects_equivalence I obs).2
    (fun _ _ huv =>
      maintenanceReadout_constant_on_observationalEquivalence hobs huv)

/--
Any valid M-side readout is fixed by the three component coordinates.  Thus no
M-side scalar, score, or downstream feature can separate two mechanisms that
agree on buffer, recovery, and reconfiguration.
-/
theorem maintenanceReadout_eq_of_same_three_coordinates
    {I : MaintenanceInterface ι α} {obs : ι → β}
    (hobs : IsMaintenanceReadout I obs)
    {u v : ι}
    (hbuffer :
      I.effect u MaintenanceComponent.buffer =
        I.effect v MaintenanceComponent.buffer)
    (hrecovery :
      I.effect u MaintenanceComponent.recovery =
        I.effect v MaintenanceComponent.recovery)
    (hreconfiguration :
      I.effect u MaintenanceComponent.reconfiguration =
        I.effect v MaintenanceComponent.reconfiguration) :
    obs u = obs v :=
  maintenanceReadout_constant_on_observationalEquivalence hobs
    (noFourthObservableCoordinate hbuffer hrecovery hreconfiguration)

/--
If a proposed extra quantity distinguishes two mechanisms that the M interface
identifies, then that quantity does not factor through the M interface.
-/
theorem outsideInterface_if_distinguishes_observationallyEquivalent
    {I : MaintenanceInterface ι α} {obs : ι → β} {u v : ι}
    (huv : ObservationallyEquivalent I u v)
    (hobs : obs u ≠ obs v) :
    ¬ IsMaintenanceReadout I obs := by
  intro hreadout
  exact hobs (maintenanceReadout_constant_on_observationalEquivalence hreadout huv)

/--
If a proposed extra quantity distinguishes two mechanisms with the same three
component coordinates, then it is not an M-side readout.  It may be useful, but
it belongs outside the current M interface.
-/
theorem outsideInterface_if_distinguishes_same_three_coordinates
    {I : MaintenanceInterface ι α} {obs : ι → β} {u v : ι}
    (hbuffer :
      I.effect u MaintenanceComponent.buffer =
        I.effect v MaintenanceComponent.buffer)
    (hrecovery :
      I.effect u MaintenanceComponent.recovery =
        I.effect v MaintenanceComponent.recovery)
    (hreconfiguration :
      I.effect u MaintenanceComponent.reconfiguration =
        I.effect v MaintenanceComponent.reconfiguration)
    (hobs : obs u ≠ obs v) :
    ¬ IsMaintenanceReadout I obs :=
  outsideInterface_if_distinguishes_observationallyEquivalent
    (noFourthObservableCoordinate hbuffer hrecovery hreconfiguration) hobs

end MaintenanceInterface

/--
A partial interface for candidate mechanisms.  A candidate either receives a
three-component M profile or is not admitted to the M-side interface.
-/
structure PartialMaintenanceInterface (ι : Type u) (α : Type v) where
  effect? : ι → Option (ComponentProfile α)

namespace PartialMaintenanceInterface

/-- The candidate mechanism is represented inside the M interface. -/
def IsInside (I : PartialMaintenanceInterface ι α) (u : ι) : Prop :=
  ∃ p : ComponentProfile α, I.effect? u = some p

/-- The candidate mechanism is outside the M interface. -/
def IsOutside (I : PartialMaintenanceInterface ι α) (u : ι) : Prop :=
  I.effect? u = none

/--
Every candidate is either represented by a three-component profile or lies
outside the M interface.
-/
theorem representable_or_outside
    (I : PartialMaintenanceInterface ι α) (u : ι) :
    IsInside I u ∨ IsOutside I u := by
  unfold IsInside IsOutside
  cases h : I.effect? u with
  | none => exact Or.inr rfl
  | some p => exact Or.inl ⟨p, rfl⟩

/-- Any represented candidate is represented by exactly the three component coordinates. -/
theorem inside_profile_three_coordinate_reconstruction
    {I : PartialMaintenanceInterface ι α} {u : ι} {p : ComponentProfile α}
    (_h : I.effect? u = some p) :
    p =
      fun c =>
        match c with
        | MaintenanceComponent.buffer => p MaintenanceComponent.buffer
        | MaintenanceComponent.recovery => p MaintenanceComponent.recovery
        | MaintenanceComponent.reconfiguration => p MaintenanceComponent.reconfiguration :=
  componentProfile_eq_three_coordinate_reconstruction p

end PartialMaintenanceInterface

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
