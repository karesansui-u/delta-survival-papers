import Survival.BernoulliTypicalSigma
import Survival.FosterLyapunovTemplate
import Survival.RepairMaintenanceTemplate

/-!
# Cross-Class Unification V0

Phase 7 v0 registry for the limited-class templates.

This file is intentionally small.  It does **not** prove a single universal
second-law theorem, a necessary/sufficient admissible-map characterization, or a
generic subadditivity principle.  Instead it records the common reader-facing
profile that is now present in three limited classes:

* Bernoulli-CSP / one-sided iid bad-event exposure;
* Foster-Lyapunov / queueing;
* Repair-Maintenance finite-prefix / resource-bounded stochastic models.

The common profile is:

1. a Sigma / total-production grammar;
2. an expectation-level tendency route;
3. a fixed finite-horizon high-probability certificate route;
4. a conditional coarse-transfer route.

Bernoulli-CSP additionally has pathwise nondecrease from nonnegative one-sided
emissions.  Foster-Lyapunov and Repair-Maintenance do not register that stronger
pathwise claim at this level.
-/

namespace Survival.CrossClassUnificationV0

/-- The three limited classes currently used as Phase 7 v0 evidence. -/
inductive LimitedClassTemplate where
  | bernoulliCSP
  | fosterLyapunovQueueing
  | repairMaintenance
deriving DecidableEq, Repr

/-- Concentration / certificate engine registered for the class.

This is a reader-facing registry, not a proof that these are the only possible
engines for each class. -/
inductive CertificateEngine where
  | chernoffKL
  | conditionalAzuma
  | resourceBoundedAzuma
deriving DecidableEq, Repr

/-- Phase 7 v0 profile fields.  `Bool` is used deliberately: this file is a
machine-checked registry of the current class profile, not the generic theorem
that will eventually explain why these fields should exist. -/
structure Phase7V0Profile where
  hasSigmaGrammar : Bool
  hasExpectedTendency : Bool
  hasHighProbabilityCertificate : Bool
  hasCoarseTransfer : Bool
  hasPathwiseNondecrease : Bool
  engine : CertificateEngine
deriving Repr

/-- The current Phase 7 v0 profile for each limited class. -/
def profile : LimitedClassTemplate → Phase7V0Profile
  | .bernoulliCSP =>
      { hasSigmaGrammar := true
        hasExpectedTendency := true
        hasHighProbabilityCertificate := true
        hasCoarseTransfer := true
        hasPathwiseNondecrease := true
        engine := .chernoffKL }
  | .fosterLyapunovQueueing =>
      { hasSigmaGrammar := true
        hasExpectedTendency := true
        hasHighProbabilityCertificate := true
        hasCoarseTransfer := true
        hasPathwiseNondecrease := false
        engine := .conditionalAzuma }
  | .repairMaintenance =>
      { hasSigmaGrammar := true
        hasExpectedTendency := true
        hasHighProbabilityCertificate := true
        hasCoarseTransfer := true
        hasPathwiseNondecrease := false
        engine := .resourceBoundedAzuma }

/-- The common Phase 7 v0 support profile shared by all three limited classes.

This is the narrow statement that Phase 7 v0 closes: all registered classes have
Sigma grammar, expectation-level tendency, high-probability certificates, and
conditional coarse-transfer routes. -/
def supportsPhase7V0 (C : LimitedClassTemplate) : Prop :=
  (profile C).hasSigmaGrammar = true ∧
    (profile C).hasExpectedTendency = true ∧
    (profile C).hasHighProbabilityCertificate = true ∧
    (profile C).hasCoarseTransfer = true

/-- Bernoulli-CSP supports the Phase 7 v0 profile. -/
theorem bernoulliCSP_supportsPhase7V0 :
    supportsPhase7V0 .bernoulliCSP := by
  simp [supportsPhase7V0, profile]

/-- Foster-Lyapunov / queueing supports the Phase 7 v0 profile. -/
theorem fosterLyapunovQueueing_supportsPhase7V0 :
    supportsPhase7V0 .fosterLyapunovQueueing := by
  simp [supportsPhase7V0, profile]

/-- Repair-Maintenance supports the Phase 7 v0 profile. -/
theorem repairMaintenance_supportsPhase7V0 :
    supportsPhase7V0 .repairMaintenance := by
  simp [supportsPhase7V0, profile]

/-- All registered limited classes support the Phase 7 v0 profile. -/
theorem all_registered_classes_supportPhase7V0
    (C : LimitedClassTemplate) :
    supportsPhase7V0 C := by
  cases C <;> simp [supportsPhase7V0, profile]

/-- Bernoulli-CSP registers the stronger pathwise nondecrease component. -/
theorem bernoulliCSP_pathwiseNondecrease_registered :
    (profile .bernoulliCSP).hasPathwiseNondecrease = true := by
  simp [profile]

/-- Foster-Lyapunov / queueing does not register Bernoulli-style pathwise
nondecrease in Phase 7 v0. -/
theorem fosterLyapunovQueueing_pathwiseNondecrease_not_registered :
    (profile .fosterLyapunovQueueing).hasPathwiseNondecrease = false := by
  simp [profile]

/-- Repair-Maintenance does not register Bernoulli-style pathwise nondecrease
in Phase 7 v0. -/
theorem repairMaintenance_pathwiseNondecrease_not_registered :
    (profile .repairMaintenance).hasPathwiseNondecrease = false := by
  simp [profile]

/-- Bernoulli-CSP currently uses the Chernoff/KL certificate engine. -/
theorem bernoulliCSP_engine :
    (profile .bernoulliCSP).engine = .chernoffKL := by
  simp [profile]

/-- Foster-Lyapunov / queueing currently uses the conditional-Azuma engine. -/
theorem fosterLyapunovQueueing_engine :
    (profile .fosterLyapunovQueueing).engine = .conditionalAzuma := by
  simp [profile]

/-- Repair-Maintenance currently uses the resource-bounded Azuma engine. -/
theorem repairMaintenance_engine :
    (profile .repairMaintenance).engine = .resourceBoundedAzuma := by
  simp [profile]

end Survival.CrossClassUnificationV0
