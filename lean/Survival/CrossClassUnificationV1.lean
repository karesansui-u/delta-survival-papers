import Survival.CrossClassUnificationV0

/-!
# Cross-Class Unification V1

Phase 7 v1 extracts the first generic schema behind the Phase 7 v0 registry.

This file still does **not** prove a universal second-law theorem. It records
the weaker, reader-facing schema now visible across the three registered
limited classes:

* a Sigma / total-production carrier;
* a class-specific nonnegative tendency driver;
* a finite-horizon certificate route;
* an admissible-transfer guard;
* no requirement that Bernoulli-style pathwise nondecrease hold in every class.

The important v1 correction is that subadditivity is not promoted as the single
generic core. It is one possible tendency driver. The cross-class schema is
broader: an ordered additive Sigma carrier plus an explicit driver that supplies
the relevant nonnegative tendency under class-specific assumptions.
-/

namespace Survival.CrossClassUnificationV1

/-- Tendency drivers currently visible across the registered limited classes.

These are deliberately engine labels, not a theorem that the list is exhaustive.
-/
inductive TendencyDriver where
  | oneSidedPathwiseEmission
  | conditionalDriftLowerBound
  | resourceCostLowerBound
deriving DecidableEq, Repr

/-- Finite-horizon certificate routes currently used by the registered classes. -/
inductive CertificateRoute where
  | chernoffKL
  | conditionalAzuma
  | resourceBoundedAzuma
deriving DecidableEq, Repr

/-- Coarse/admissible-transfer guards currently used by the registered classes. -/
inductive TransferGuard where
  | endpointDefectBudget
  | stochasticCompatibility
  | resourceBoundedCompatibility
deriving DecidableEq, Repr

/-- Phase 7 v1 schema fields.

The Boolean fields keep this file at the same modest level as
`CrossClassUnificationV0`: a machine-checked registry / schema extraction, not a
generic theorem over all structural-maintenance problems. -/
structure Phase7V1SchemaProfile where
  hasSigmaCarrier : Bool
  hasTendencyDriver : Bool
  hasFiniteHorizonCertificate : Bool
  hasAdmissibleTransferGuard : Bool
  requiresPathwiseNondecrease : Bool
  tendencyDriver : TendencyDriver
  certificateRoute : CertificateRoute
  transferGuard : TransferGuard
deriving Repr

/-- The Phase 7 v1 schema profile for each currently registered limited class. -/
def schema :
    Survival.CrossClassUnificationV0.LimitedClassTemplate →
      Phase7V1SchemaProfile
  | .bernoulliCSP =>
      { hasSigmaCarrier := true
        hasTendencyDriver := true
        hasFiniteHorizonCertificate := true
        hasAdmissibleTransferGuard := true
        requiresPathwiseNondecrease := false
        tendencyDriver := .oneSidedPathwiseEmission
        certificateRoute := .chernoffKL
        transferGuard := .endpointDefectBudget }
  | .fosterLyapunovQueueing =>
      { hasSigmaCarrier := true
        hasTendencyDriver := true
        hasFiniteHorizonCertificate := true
        hasAdmissibleTransferGuard := true
        requiresPathwiseNondecrease := false
        tendencyDriver := .conditionalDriftLowerBound
        certificateRoute := .conditionalAzuma
        transferGuard := .stochasticCompatibility }
  | .repairMaintenance =>
      { hasSigmaCarrier := true
        hasTendencyDriver := true
        hasFiniteHorizonCertificate := true
        hasAdmissibleTransferGuard := true
        requiresPathwiseNondecrease := false
        tendencyDriver := .resourceCostLowerBound
        certificateRoute := .resourceBoundedAzuma
        transferGuard := .resourceBoundedCompatibility }

/-- The Phase 7 v1 schema candidate.

It includes the Phase 7 v0 support profile and adds the v1 explanation layer:
each class must expose a Sigma carrier, a nonnegative tendency driver, a
finite-horizon certificate route, and an admissible-transfer guard. It also
records that Bernoulli-style pathwise nondecrease is not a generic requirement.
-/
def supportsPhase7V1Schema
    (C : Survival.CrossClassUnificationV0.LimitedClassTemplate) : Prop :=
  Survival.CrossClassUnificationV0.supportsPhase7V0 C ∧
    (schema C).hasSigmaCarrier = true ∧
    (schema C).hasTendencyDriver = true ∧
    (schema C).hasFiniteHorizonCertificate = true ∧
    (schema C).hasAdmissibleTransferGuard = true ∧
    (schema C).requiresPathwiseNondecrease = false

/-- Bernoulli-CSP supports the Phase 7 v1 schema candidate. -/
theorem bernoulliCSP_supportsPhase7V1Schema :
    supportsPhase7V1Schema .bernoulliCSP := by
  simp [supportsPhase7V1Schema, schema,
    Survival.CrossClassUnificationV0.supportsPhase7V0,
    Survival.CrossClassUnificationV0.profile]

/-- Foster-Lyapunov / queueing supports the Phase 7 v1 schema candidate. -/
theorem fosterLyapunovQueueing_supportsPhase7V1Schema :
    supportsPhase7V1Schema .fosterLyapunovQueueing := by
  simp [supportsPhase7V1Schema, schema,
    Survival.CrossClassUnificationV0.supportsPhase7V0,
    Survival.CrossClassUnificationV0.profile]

/-- Repair-Maintenance supports the Phase 7 v1 schema candidate. -/
theorem repairMaintenance_supportsPhase7V1Schema :
    supportsPhase7V1Schema .repairMaintenance := by
  simp [supportsPhase7V1Schema, schema,
    Survival.CrossClassUnificationV0.supportsPhase7V0,
    Survival.CrossClassUnificationV0.profile]

/-- All currently registered limited classes support the Phase 7 v1 schema
candidate. -/
theorem all_registered_classes_supportPhase7V1Schema
    (C : Survival.CrossClassUnificationV0.LimitedClassTemplate) :
    supportsPhase7V1Schema C := by
  cases C <;>
    simp [supportsPhase7V1Schema, schema,
      Survival.CrossClassUnificationV0.supportsPhase7V0,
      Survival.CrossClassUnificationV0.profile]

/-- The Phase 7 v1 schema is intentionally an extension of the v0 registry, not
a replacement for it. -/
theorem phase7V1Schema_implies_phase7V0
    (C : Survival.CrossClassUnificationV0.LimitedClassTemplate)
    (h : supportsPhase7V1Schema C) :
    Survival.CrossClassUnificationV0.supportsPhase7V0 C :=
  h.1

/-- Phase 7 v1 explicitly does not require Bernoulli-style pathwise
nondecrease as part of the cross-class schema. -/
theorem no_registered_class_requires_pathwiseNondecrease
    (C : Survival.CrossClassUnificationV0.LimitedClassTemplate) :
    (schema C).requiresPathwiseNondecrease = false := by
  cases C <;> simp [schema]

/-- Bernoulli-CSP uses the one-sided pathwise-emission tendency driver. -/
theorem bernoulliCSP_tendencyDriver :
    (schema .bernoulliCSP).tendencyDriver = .oneSidedPathwiseEmission := by
  simp [schema]

/-- Foster-Lyapunov / queueing uses the conditional-drift lower-bound tendency
driver. -/
theorem fosterLyapunovQueueing_tendencyDriver :
    (schema .fosterLyapunovQueueing).tendencyDriver =
      .conditionalDriftLowerBound := by
  simp [schema]

/-- Repair-Maintenance uses the resource-cost lower-bound tendency driver. -/
theorem repairMaintenance_tendencyDriver :
    (schema .repairMaintenance).tendencyDriver = .resourceCostLowerBound := by
  simp [schema]

end Survival.CrossClassUnificationV1
