# A Lean-Verified Artifact for Structural Persistence Accounting

## Draft artifact preprint

This document is a Lean-facing companion to the structural-persistence theory
notes.  Its purpose is not to restate the whole theory, nor to advertise a large
module count.  Its purpose is to say precisely what the Lean development fixes:
which objects are formalized, which readouts are derived from certificates, and
which claims remain outside the formal artifact.

The theory-facing mainline is:

```text
F -> K -> V_K,m -> L/B -> R/M -> S
```

Here `F` is the maintained function, identity, predicate, or target; `K` is the
carrying structure; `V_K,m` is the viable region and its mass or room; `L` is
closed structural loss; `B` is repair-inclusive net burden; `R` is raw resource;
`M` is effective resource; and `S` is the full-persistence-potential readout,
usually `M * exp(-L)` or `M * exp(-B)`.

The recovery-cost parameter `C_req` is not treated as the ontology core in this
artifact.  It appears only as a boundary parameter in the explicit recovery
readout, when a target, action space, lower-bound certificate, and witness
discipline have already been supplied.

The theory-facing ambition is larger than this artifact: to make persistence,
collapse, functional death, recovery, irreversibility, intervention, and
cross-system tradeoff readable as a common accounting problem.  The Lean
artifact plays the narrower role.  It does not certify the real world directly;
it checks what follows after the relevant structural, resource, proxy, or report
certificates have been supplied and audited.

## Abstract

Structural persistence accounting separates the maintained role of a system
from the structure that carries it, the viable region in which that role can be
maintained, the structural loss or repair-inclusive burden of that region, and
the effective resource that can support the structure.  The Lean 4 development
formalizes this separation as a certificate-scoped accounting interface.  It
verifies log-additive structural kernels, repair-inclusive balance identities,
M/L full-potential sign readouts, admission/ontology handoff boundaries,
runtime-failure readout wrappers, proxy-measurement robustness rules, diagnostic
resource/loss split reports, finite-policy forbidden regions, cross-domain
projection guards, and finite Ising-style structural readout examples.

The artifact deliberately does not prove that every real-world system has a
canonical `F/K/V_K,m/L/B/R/M/S` representation.  It does not prove the empirical
truth of domain measurements or proxies.  It does not prove native domain
theorems such as thermodynamic laws, Shannon achievability, biological
mechanisms, or Ising phase transitions.  Its verified contribution is narrower:
once a domain supplies the relevant structural, resource, proxy, or report
certificates, the accounting consequences are checked inside Lean without
unfinished proofs or project-declared axioms.

## 1. Why a Separate Lean Artifact Paper?

The theory notes explain the conceptual move: do not collapse persistence,
collapse, repair, and irreversibility into one scalar label.  Instead, split:

- what is being maintained (`F`);
- what carries it (`K`);
- where it can be maintained (`V_K`);
- how much viable room remains (`m`);
- how the room is structurally lost or restored (`L/B`);
- what nominal resource exists (`R`);
- what resource is actually effective (`M`);
- what full-persistence potential remains (`S`).

The Lean artifact has a different job.  It records what follows mechanically
after those entries have been supplied.  This matters because the theory is
highly abstract: without formal boundaries it is easy to slide from "this is a
readout" into "this is a new domain law."  The Lean development prevents that
slide by forcing each consequence to pass through explicit data, certificates,
and theorem names.

The artifact should therefore be read as a proof boundary document:

```text
domain interpretation   -> supplied certificate
supplied certificate    -> Lean readout
Lean readout            -> audited accounting consequence
```

It is not an automatic discovery engine for `F`, `K`, viable regions, or
empirical measurements.

## 2. Formal Mainline

The core object-level split is implemented around structural-persistence
ontology modules.

```text
Admission
  pre-ontology checklist

Ontology
  F/K/V_K,m/R/M-style structural object

Handoff
  bundle of admission readiness plus supplied ontology certificates

Adapters
  route admitted ontology into existing M/L ledger machinery

Failures
  certified and reported runtime readout vocabulary

Interventions
  axes of intervention, not intervention discovery

Diagnostics and reports
  supplied resource/loss policies, frontiers, and bundles
```

This order is important.  Admission readiness does not build a well-formed
ontology.  A reported runtime label does not become a certified runtime failure.
A structural diagnostic report does not search for a frontier.  A cross-domain
bundle does not generate cross-domain causality.  Each step only exposes or
routes certificates that were supplied at the correct layer.

## 3. Structural Loss Kernel

The Lean development contains the standard structural-loss kernel:

```text
stage loss  = -log(m_{t+1} / m_t)
cumulative loss L_n = sum_{t<n} stageLoss_t
m_n = m_0 * exp(-L_n)
```

The representation theorem states, under the chosen assumptions, that a
ratio-based stage-loss functional satisfying the appropriate normalization,
composition, regularity, and nonnegativity conditions is forced into a
logarithmic scale.  The telescoping theorem then shows that finite structural
loss accumulates additively in log coordinates and multiplicatively in mass
coordinates.

Representative Lean anchors:

- `RepresentationTheorem.loss_must_be_log`
- `TelescopingExp.measure_eq_initial_mul_exp_neg_cumulative_loss`

Artifact boundary:

- This is a formal kernel for a supplied positive mass trajectory.
- It is not a theorem that all empirical degradation measures are already this
  mass trajectory.
- It is not a claim that every real-world loss proxy is automatically valid.

## 4. Repair-Inclusive Balance

The repair-inclusive layer introduces a signed net burden:

```text
d_t = structural consumption / loss contribution
r_t = repair or recovery contribution
b_t = d_t - r_t
B_n = sum_{t<n} b_t
m_n = m_0 * exp(-B_n)
```

The Lean artifact verifies pathwise balance identities once the two-stage
contraction/repair structure is supplied.  This is intentionally pathwise and
certificate-scoped.  It does not say that every simultaneous real-world process
has a unique loss/repair decomposition.  In real domains, the observation unit,
proxy, validation protocol, and two-stage interpretation must be fixed before
the theorem is applied.

Representative Lean anchors:

- `GeneralStateDynamics.feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction`
- `StructuralPersistenceBalancePrinciple.pathwise_netConsumption_exponential_kernel`
- `StructuralPersistenceBalancePrinciple.local_exponential_netConsumption_identity`

Artifact boundary:

- `B` governs the supplied mass-side kernel.
- Full-persistence potential still includes effective resource `M`.
- Runtime stop, collapse, and transition readouts require their own certificates
  or thresholds; they are not consequences of the sign of `b_t` alone.

## 5. M/L Separation

The central artifact distinction is the separation between structural loss and
effective support:

```text
L or B   structural loss / repair-inclusive burden
M        effective support resource
S        M * exp(-L) or M * exp(-B)
```

This separation is what prevents distinct failure mechanisms from collapsing
into one score.  A system may be structurally outside a viable region while
resource remains positive.  A system may still satisfy a maintained predicate
while the resource-side full-potential boundary has already been crossed.  A raw
resource may exist without becoming effective resource.

Representative Lean anchors:

- `StructuralPersistenceOntology.inherits_commonPersistenceProfile`
- `StructuralPersistenceOntology.fullPotential_collapse_iff_effectiveResource_nonpos`
- `StructuralPersistenceOntology.fullPotential_pos_iff_effectiveResource_pos`
- `resourceCollapseAt_and_state_mem_to_maintained_and_fullPotentialCollapse`
- `structuralStopAt_and_effectiveResource_pos_to_fullPotential_pos`
- `ineffectiveRawResourceAt_unwrap_bottleneck`

Artifact boundary:

- `S` is a full-persistence-potential readout.
- `S` is not a universal scalar health score.
- `S` is not the target-recovery readout.
- For finite positive structural factors, the zero/nonpositive full-potential
  boundary is carried by the effective-resource sign.  Structural loss remains
  causally relevant when a supplied model connects it to costs, viable-region
  shrinkage, or effective-resource degradation.

## 6. Admission, Ontology, and Handoff

The artifact separates entrance failure from runtime failure.

Admission is a pre-ontology checklist.  It can say that a domain has not yet
supplied enough material to enter the structural-persistence interface.  It does
not produce runtime collapse, non-recovery, or full-potential readouts.

Ontology is the admitted structural object.  It carries the state, carrier,
maintained predicate, viable region, viable mass, raw resource, effective
resource, and resource update data.  Ordinary well-formedness is deliberately
weaker than exact viable-region semantics.  If a theorem needs exact equivalence
between viable-region membership and the maintained predicate, it asks for an
extra exact-region certificate.

Handoff bundles admission readiness with separately supplied ontology
certificates.  It is not an automatic map from admission readiness to
well-formed ontology.

Representative Lean anchors:

- `AdmissionReady`
- `AdmissionFailure`
- `AdmittedOntology`
- `AdmittedExactOntology`
- `StructuralPersistenceWellFormed`
- `StructuralPersistenceExactViableRegion`
- `StructuralPersistenceViableMassCertificate`
- `StructuralPersistenceMassModelCertificate`

Artifact boundary:

- Admission failure is not runtime failure.
- Admission readiness is not well-formedness.
- Viable mass is not assumed to be a measure-theoretic `m(V_K)` unless a
  certificate supplies that connection.

## 7. Runtime Readouts

Runtime readouts are separated by source:

```text
CertifiedRuntimeFailure
ReportedRuntimeFailure
ActivatedRuntimeFailureObservation
```

This prevents a domain-reported label from being used as if it were a certified
structural consequence.  The classification lemmas close the internal readout
grammar: if an activated runtime observation is supplied, it has a nonempty
classification.  They do not claim that all real-world failures are exhausted by
this grammar.

Representative Lean anchors:

- `activatedRuntimeFailure_has_classification`
- `classification_nonempty_iff_activatedRuntimeFailure`
- `outsideViableRegionAt_to_not_maintained`
- `resourceCollapseAt_to_fullPotentialCollapse`
- `structuralStopAt_of_certificate`

Artifact boundary:

- Runtime readout classification is internal to the supplied observation type.
- It is not an ontology of all possible real-world failure modes.

## 8. Recovery Boundary Parameter

Some questions ask not only whether a structure is maintained or supported, but
whether a specified target can be restored by actions within available resource.
For that readout the artifact uses an explicit recovery layer:

```text
target / action / witness / lowerBound / C_req / CanRecoverTo
```

Here `C_req` is just the supplied or certified boundary used by that recovery
question.  It is not the main state variable of structural persistence.  It is
one parameter in one readout layer.

Representative Lean anchor:

- `recoveryShortfallAt_to_notCanRecover`

Artifact boundary:

- Recovery readouts require the target/action/witness/lower-bound setup.
- They do not redefine the ontology core.
- They should not be used to make `C_req` look like the center of the theory.

## 9. Proxy Measurement and Validation

Real domains often cannot directly measure the ideal `V_K`, `m`, `L`, `B`, or
`M`.  The artifact therefore separates candidate proxies from validated
readouts.

```text
candidate proxy
  not enough for a theorem

proxy certificate
  upper/lower/error relation to a true signal

validation protocol
  frozen before evaluation, with support or no-support record

robustness theorem
  if error is smaller than the margin, the readout sign is preserved
```

Representative Lean anchors:

- `ConservativeLossUpperProxy.trueLoss_le_proxyLoss`
- `ApproxLossProxy.abs_error_bound`
- `ApproxResourceProxy.abs_error_bound`
- `ApproxNetBurdenProxy.abs_error_bound`
- `ApproxLossProxy.failure_of_proxy_margin_and_true_sound`
- `ApproxNetBurdenProxy.failure_of_proxy_margin_and_true_sound`
- `ProxyValidationCertificate.no_post_hoc_selection`
- `NoSupportRecord.lacks_empirical_support`

Artifact boundary:

- A proxy candidate is not a measurement theorem.
- Empirical support metadata is not mathematical soundness.
- Proxy-based failure readout requires both approximation/ordering certificates
  and a true-signal readout certificate.

## 10. Diagnostic Policies, Forbidden Regions, and Reports

The diagnostic layer uses the M/L split to expose resource-side and loss-side
readouts as separate diagnostic axes.  Policies can select finite subsets of
these axes.  Existing finite-policy theorems then express recoverable coverage,
joint blockage, forbidden intervals, and minimal-forbidden reports under
supplied lower-bound and attainable-witness certificates.

Representative Lean anchors:

- `admittedExactMLSeparationDiagnosticSplitInterface`
- `admittedExactMLSeparationPairSummary_exposes_diagnosticSplit_readouts`
- `admittedExactMLSeparationDiagnostic_forbidden_set_of_required_interval`
- `structuralDiagnosticPolicyRecoverable_of_required_sum_le_budget_and_attainable_le`
- `structuralDiagnosticPolicyBlocked_of_required_sum_exceeds_budget`
- `structuralDiagnosticForbiddenPolicy_of_required_interval`
- `structuralDiagnosticFrontierReport_of_certificates`
- `structuralDiagnosticFrontierReport_resourceLossStrictSubpolicy_recoverable`

Artifact boundary:

- The artifact can verify that supplied policies and certificates imply
  recoverable or blocked readouts.
- It does not automatically discover the optimal policy.
- It does not turn a frontier report into empirical truth.

## 11. Cross-Domain Reports

Cross-domain modules use separately admitted ontologies and supplied reports to
expose left/right resource-loss readouts and scalar-factorization obstructions.
The point is not to prove that two domains have the same native dynamics.  The
point is to keep their native semantics separate while allowing the accounting
layer to compare supplied resource/loss readouts and report-side certificates.

Representative Lean anchors:

- `structuralCrossDomainFrontierReport_exposes_left_readouts`
- `structuralCrossDomainFrontierReport_exposes_right_readouts`
- `structuralCrossDomainPairEncodingReport_exposes_left_resource`
- `structuralCrossDomainPairEncodingReport_exposes_right_loss`
- `structuralCrossDomainReport_not_scalarFactoredClassifiers_of_left_ambiguity`
- `structuralCrossDomainReport_not_scalarFactoredClassifiers_of_right_ambiguity`

Artifact boundary:

- Cross-domain reports do not generate coupling laws.
- They expose supplied reports and show where scalar-factored summaries are too
  weak.
- Richer encodings are not ruled out by scalar non-identification theorems.

## 12. Finite Ising-Style Structural Readouts

The finite Ising modules are included as a hard-model-facing example of the
interface discipline.  They do not prove thermodynamic limits or phase
transitions.  They show how a finite spin-style system can expose a maintained
predicate, exact viable-region readouts, M-side collapse readouts, and supplied
intervention axes without identifying those phenomena.

Representative Lean anchors:

- `positiveMagnetizationAdmittedExactOntology`
- `allMinus_admittedExact_not_maintainedAt`
- `allMinus_admittedExact_quietReadoutSummary_with_supplied_expandV`
- `allPlus_admitted_quietMaintainedResourceCollapseSummary_with_supplied_increaseM`
- `allMinus_admittedExact_quietOutsideViablePositiveResourceSummary_with_supplied_expandV`
- `allPlus_allMinus_admittedExact_quietMLSeparationPairSummary_with_supplied_axes`

Artifact boundary:

- Finite Ising readouts are adapter examples.
- Gibbs dynamics and phase-transition theorems remain domain-native unless
  separately supplied as certificates.

## 13. Proof Audit Discipline

The repository keeps a proof audit log that classifies new structural
persistence declarations as:

- `substantive bridge`;
- `witness exposure`;
- `non-identification`;
- `bookkeeping`;
- `risk`.

This is part of the artifact.  It prevents bookkeeping lemmas from being counted
as deep mathematical progress and prevents supplied witnesses from being
described as discovered consequences.

The intended workflow is:

```bash
scripts/proof_audit.sh
lake build Persistence
```

The audit script checks the structural-persistence theorem list against
`PROOF_AUDIT.md` and guards the structural modules against `sorry`, `admit`,
project-declared `axiom`, and `unsafe`.

At this draft, `Persistence.lean` has 554 import lines, and the repository has
572 `.lean` files by `rg --files -g '*.lean'`.

## 14. What the Artifact Proves

The Lean artifact proves, in its present form, that:

1. Supplied ratio-loss and mass-trajectory assumptions yield the expected
   log-additive/exponential structural kernel.
2. Supplied repair-inclusive dynamics yield pathwise net-burden exponential
   kernels.
3. Well-formed structural ontologies can be routed into the existing M/L ledger
   interface.
4. Full-persistence sign readouts are derived from the effective-resource side
   under the supplied positive structural factor.
5. Exact viable-region certificates allow outside-viable observations to imply
   not-maintained readouts.
6. Certified runtime observations are kept separate from domain-reported labels.
7. Raw resource and effective resource can be separated by explicit bottleneck
   witnesses.
8. Proxy readouts require explicit approximation, bound, or soundness
   certificates.
9. Diagnostic policies and frontier reports expose supplied resource/loss
   accounting facts without pretending to perform search.
10. Cross-domain reports can expose separately supplied left/right readouts and
    show scalar-summary limitations.

## 15. What the Artifact Does Not Prove

The Lean artifact does not prove:

- that every real domain has a canonical structural-persistence ontology;
- that the correct `F`, `K`, `V_K`, or `m` can be found automatically;
- that any proposed proxy is empirically valid;
- that all real-world failure modes are exhausted by the runtime readout grammar;
- that domain-specific mechanisms are replaced by structural persistence;
- that finite Ising examples prove phase transitions;
- that thermodynamic, Shannon, PAC, biological, or ESG claims are true as
  empirical domain claims;
- that recovery-boundary parameters are the theory's ontology core;
- that a single scalar score can replace the M/L split.

These are not accidental omissions.  They are part of the artifact boundary.
The artifact verifies what follows after the relevant object, measurement,
proxy, lower-bound, or report certificate has been supplied.

## 16. Contribution of the Lean Artifact

The artifact contributes a mechanically checked guardrail for structural
persistence accounting:

```text
not metaphor alone
not a universal empirical law
not a master score
not domain-theorem replacement

but:

certificate-scoped M/L structural accounting,
with explicit admission, ontology, handoff, runtime, proxy,
diagnostic, cross-domain, and finite-model readout boundaries.
```

This is the point of the Lean companion.  It makes the decomposition of
persistence, collapse, support, recovery readouts, and externality difficult to
blur.  The theory may be broad, but the artifact forces each broad use to pass
through an explicit certificate boundary.
