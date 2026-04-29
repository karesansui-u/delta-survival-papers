import Survival.CrossClassUnificationV1

/-!
# Cross-Class Unification V2

Phase 7 v2 turns the v1 schema into an explicit interface and records that the
three registered limited classes instantiate it.

This is still not a theorem over all future structural-maintenance problems.
The generic theorem here is intentionally small: an object that supplies the
four interface fields has the corresponding law-like limited-class profile.
The three registered classes are then packaged as instances of that interface.
-/

namespace Survival.CrossClassUnificationV2

abbrev LimitedClassTemplate :=
  Survival.CrossClassUnificationV0.LimitedClassTemplate

/-- Abstract Phase 7 v2 interface.

The propositions are supplied by a concrete class template.  This keeps the
schema independent of a single engine such as subadditivity while still making
the proof obligations explicit. -/
structure AbstractUnifyingSchemaInstance where
  orderedSigmaCarrier : Prop
  nonnegativeTendencyDriver : Prop
  finiteHorizonCertificateRoute : Prop
  admissibleTransferGuard : Prop
  noGenericPathwiseRequirement : Prop
  has_orderedSigmaCarrier : orderedSigmaCarrier
  has_nonnegativeTendencyDriver : nonnegativeTendencyDriver
  has_finiteHorizonCertificateRoute : finiteHorizonCertificateRoute
  has_admissibleTransferGuard : admissibleTransferGuard
  has_noGenericPathwiseRequirement : noGenericPathwiseRequirement

/-- The law-like limited-class profile induced by the v2 interface. -/
def AbstractLawLikeLimitedClassProfile
    (I : AbstractUnifyingSchemaInstance) : Prop :=
  I.orderedSigmaCarrier ∧
    I.nonnegativeTendencyDriver ∧
    I.finiteHorizonCertificateRoute ∧
    I.admissibleTransferGuard ∧
    I.noGenericPathwiseRequirement

/-- Generic Phase 7 v2 interface theorem.

This is the meta-theorem shape: once a concrete class supplies the four fields
and the non-pathwise-genericity discipline, the law-like limited-class profile
follows by unpacking the interface. -/
theorem abstractLawLikeProfile_of_instance
    (I : AbstractUnifyingSchemaInstance) :
    AbstractLawLikeLimitedClassProfile I :=
  ⟨I.has_orderedSigmaCarrier,
    I.has_nonnegativeTendencyDriver,
    I.has_finiteHorizonCertificateRoute,
    I.has_admissibleTransferGuard,
    I.has_noGenericPathwiseRequirement⟩

/-- Registered-class version of the v2 interface.

This specializes the abstract interface to the three classes already present in
`CrossClassUnificationV0` and the schema fields extracted in
`CrossClassUnificationV1`. -/
structure RegisteredUnifyingSchemaInstance where
  C : LimitedClassTemplate
  sigmaCarrier :
    (Survival.CrossClassUnificationV1.schema C).hasSigmaCarrier = true
  tendencyDriver :
    (Survival.CrossClassUnificationV1.schema C).hasTendencyDriver = true
  finiteHorizonCertificate :
    (Survival.CrossClassUnificationV1.schema C).hasFiniteHorizonCertificate =
      true
  admissibleTransferGuard :
    (Survival.CrossClassUnificationV1.schema C).hasAdmissibleTransferGuard =
      true
  noGenericPathwiseRequirement :
    (Survival.CrossClassUnificationV1.schema C).requiresPathwiseNondecrease =
      false

/-- Convert a registered-class instance into the abstract v2 interface. -/
def RegisteredUnifyingSchemaInstance.toAbstract
    (I : RegisteredUnifyingSchemaInstance) :
    AbstractUnifyingSchemaInstance where
  orderedSigmaCarrier :=
    (Survival.CrossClassUnificationV1.schema I.C).hasSigmaCarrier = true
  nonnegativeTendencyDriver :=
    (Survival.CrossClassUnificationV1.schema I.C).hasTendencyDriver = true
  finiteHorizonCertificateRoute :=
    (Survival.CrossClassUnificationV1.schema I.C).hasFiniteHorizonCertificate =
      true
  admissibleTransferGuard :=
    (Survival.CrossClassUnificationV1.schema I.C).hasAdmissibleTransferGuard =
      true
  noGenericPathwiseRequirement :=
    (Survival.CrossClassUnificationV1.schema I.C).requiresPathwiseNondecrease =
      false
  has_orderedSigmaCarrier := I.sigmaCarrier
  has_nonnegativeTendencyDriver := I.tendencyDriver
  has_finiteHorizonCertificateRoute := I.finiteHorizonCertificate
  has_admissibleTransferGuard := I.admissibleTransferGuard
  has_noGenericPathwiseRequirement := I.noGenericPathwiseRequirement

/-- Every currently registered class supplies the v2 registered interface. -/
def registeredInstanceOf
    (C : LimitedClassTemplate) : RegisteredUnifyingSchemaInstance where
  C := C
  sigmaCarrier := by
    cases C <;> simp [Survival.CrossClassUnificationV1.schema]
  tendencyDriver := by
    cases C <;> simp [Survival.CrossClassUnificationV1.schema]
  finiteHorizonCertificate := by
    cases C <;> simp [Survival.CrossClassUnificationV1.schema]
  admissibleTransferGuard := by
    cases C <;> simp [Survival.CrossClassUnificationV1.schema]
  noGenericPathwiseRequirement := by
    cases C <;> simp [Survival.CrossClassUnificationV1.schema]

/-- Bernoulli-CSP as a Phase 7 v2 schema instance. -/
def bernoulliCSP_unifyingSchemaInstance :
    RegisteredUnifyingSchemaInstance :=
  registeredInstanceOf .bernoulliCSP

/-- Foster-Lyapunov / queueing as a Phase 7 v2 schema instance. -/
def fosterLyapunovQueueing_unifyingSchemaInstance :
    RegisteredUnifyingSchemaInstance :=
  registeredInstanceOf .fosterLyapunovQueueing

/-- Repair-Maintenance as a Phase 7 v2 schema instance. -/
def repairMaintenance_unifyingSchemaInstance :
    RegisteredUnifyingSchemaInstance :=
  registeredInstanceOf .repairMaintenance

/-- A registered v2 instance implies the v1 schema support statement for its
class. -/
theorem registeredInstance_supportsPhase7V1Schema
    (I : RegisteredUnifyingSchemaInstance) :
    Survival.CrossClassUnificationV1.supportsPhase7V1Schema I.C :=
  ⟨Survival.CrossClassUnificationV0.all_registered_classes_supportPhase7V0 I.C,
    I.sigmaCarrier,
    I.tendencyDriver,
    I.finiteHorizonCertificate,
    I.admissibleTransferGuard,
    I.noGenericPathwiseRequirement⟩

/-- Bernoulli-CSP satisfies the v2 unifying schema. -/
theorem bernoulliCSP_satisfies_unifyingSchema :
    Survival.CrossClassUnificationV1.supportsPhase7V1Schema .bernoulliCSP :=
  registeredInstance_supportsPhase7V1Schema
    bernoulliCSP_unifyingSchemaInstance

/-- Foster-Lyapunov / queueing satisfies the v2 unifying schema. -/
theorem fosterLyapunovQueueing_satisfies_unifyingSchema :
    Survival.CrossClassUnificationV1.supportsPhase7V1Schema
      .fosterLyapunovQueueing :=
  registeredInstance_supportsPhase7V1Schema
    fosterLyapunovQueueing_unifyingSchemaInstance

/-- Repair-Maintenance satisfies the v2 unifying schema. -/
theorem repairMaintenance_satisfies_unifyingSchema :
    Survival.CrossClassUnificationV1.supportsPhase7V1Schema
      .repairMaintenance :=
  registeredInstance_supportsPhase7V1Schema
    repairMaintenance_unifyingSchemaInstance

/-- All registered classes have a v2 unifying-schema instance. -/
theorem all_registered_classes_have_unifyingSchemaInstance
    (C : LimitedClassTemplate) :
    ∃ I : RegisteredUnifyingSchemaInstance, I.C = C :=
  ⟨registeredInstanceOf C, rfl⟩

/-- All registered classes satisfy the v2 unifying schema. -/
theorem all_registered_classes_satisfy_unifyingSchema
    (C : LimitedClassTemplate) :
    Survival.CrossClassUnificationV1.supportsPhase7V1Schema C :=
  registeredInstance_supportsPhase7V1Schema (registeredInstanceOf C)

/-- The registered v2 instance also yields the abstract law-like profile. -/
theorem abstractProfile_of_registeredInstance
    (I : RegisteredUnifyingSchemaInstance) :
    AbstractLawLikeLimitedClassProfile I.toAbstract :=
  abstractLawLikeProfile_of_instance I.toAbstract

end Survival.CrossClassUnificationV2
