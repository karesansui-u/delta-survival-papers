# Structural Persistence Theory

## A Lean-verified M/L accounting interface for persistence, collapse, and recovery

Status: focused preprint core draft.

This draft is meant to capture the central claim of Structural Persistence
Theory without turning the README into a paper verbatim. The emphasis is the
M/L separation and the structural mainline; the recovery-cost layer is treated
as one readout layer, not as the ontology core.

## Abstract

Many discussions of resilience, collapse, repair, and irreversibility mix
together several different mechanisms: what function is being maintained, what
structure carries it, how much viable room remains, what losses have accumulated,
what resources are actually usable, and what would be required to recover a
chosen target. Structural Persistence Theory separates these roles into a common
accounting interface.

The questions are deliberately basic: what persists, what collapses, what counts
as functional death relative to a maintained role, what can recover, what has
become irreversible, and what other systems are affected by an intervention.
The aim is not to turn these into one master score. The aim is to decompose the
mechanisms behind them so that structural loss, effective support, repair,
irreversibility, and externality can be compared without being confused.

The core mainline is:

```text
F -> K -> V_K, m -> L/B -> R/M -> S
```

Here `F` is the maintained function, identity, or predicate; `K` is the carrying
structure; `V_K` is the viable state region for that structure and `m` measures
its remaining room; `L` is log-additive structural loss and `B` is
repair-inclusive net burden; `R` is raw resource and `M` is effective resource;
and `S` is a full-persistence potential readout such as `M * exp(-L)` or
`M * exp(-B)`.

The recovery-cost layer is separate. When a target, action space, witness, and
lower-bound certificate are supplied, a recovery boundary `C_req` can be used to
judge target-relative recoverability through an affordability condition such as
`C_req <= M`. This is a useful boundary parameter for recovery questions, but it
is not the ontology core.

The accompanying Lean 4 development verifies accounting consequences inside
this certificate-scoped interface. It does not verify the empirical truth of a
domain adapter, discover the correct domain model automatically, or replace
native dynamics in thermodynamics, information theory, biology, networks,
medicine, finance, or ecology. Its role is to keep the distinction between
structure, resource, recovery, externality, and non-claim mechanically explicit.

If the measurement protocols, canonical examples, and certificate-producing
domain adapters mature, the framework could become a common quantity-language
for persistence in the way temperature became a common language for thermal
state or information became a common language for uncertainty and communication.
The analogy is aspirational, not a status claim: Structural Persistence Theory
does not replace thermodynamics or information theory, but can receive their
certificates and ask how they affect persistence, collapse, recovery, and
cross-system tradeoffs.

## 1. The Problem

Across domains, the same words often hide different failure modes.

A system may be called "collapsed" because its structure has degraded, because
its usable resource ledger has been exhausted, because nominal resources cannot
be converted into effective support, because the target has become
unrecoverable, because a coupled system consumes the shared budget, or because
the required intervention arrives too late.

These are not the same mechanism.

Structural Persistence Theory is an accounting language for keeping them apart.
The point is not to reduce all domains to one physical law. The point is to
provide a common structure in which different domains can expose their own
certificates and then share the same persistence, collapse, recovery, and
externality readouts.

This makes the theory a candidate measurement language for a root class of
human and planetary questions. In medicine, infrastructure, ecology, climate,
organizations, finance, AI systems, and public institutions, the hard question
is often not "is something bad happening?" but "which mechanism is failing, how
close is it to an irreversible boundary, what intervention axis can still move
it, and what else becomes less recoverable if we intervene here?"

A useful analogy is management accounting. Financial accounting separates
assets, liabilities, revenue, costs, and cash flow so that a firm is not judged
by one vague number. Structural Persistence Theory does something similar for
persistence: it separates structural room, structural loss, raw resource,
effective resource, recovery boundary, and shared-budget tradeoffs.

This is also how cross-domain transfer should be understood. A medical treatment
is not copied into a network repair problem, and a thermodynamic law is not
copied into an ESG claim. What can transfer is the intervention grammar: whether
an intervention lowers structural loss, improves raw-to-effective resource
conversion, increases effective support, expands the viable region, weakens a
harmful coupling, delays a deadline, or moves another system into shortfall.

## 2. The Structural Mainline

The ontology core is the following mainline.

```text
F -> K -> V_K, m -> L/B -> R/M -> S
```

Each component has a distinct role.

`F`: what is maintained.

This may be a function, identity, predicate, target range, viability condition,
service condition, or structural role. "Death", "failure", and "collapse" are
not absolute terms in this framework; they are read relative to an explicitly
chosen `F`.

`K`: what carries `F`.

The carrier may be an organism, organ system, code, network, institution,
machine, market structure, ecological system, or finite configuration space.
Changing `K` changes the meaning of persistence.

`V_K, m`: the viable region and its room.

`V_K` is the region of states in which `K` can carry `F`. The measure or mass
readout `m(V_K)` records how much room remains. This is the structural side of
persistence before resource affordability is considered.

`L/B`: structural loss and repair-inclusive burden.

`L` reads shrinkage of viable room on a log-additive scale. If explicit repair
or maintenance is included, `B` reads cumulative net burden rather than pure
loss.

`R/M`: raw resource and effective resource.

`R` is nominal or raw resource. `M` is the portion that can actually support the
target structure in the relevant context. This separation matters because
assets, money, energy, staff, data, trust, or spare parts may exist without being
convertible into effective support.

`S`: full-persistence potential.

`S` is a readout such as:

```text
S = M * exp(-L)
S = M * exp(-B)
```

It is a resource-coupled potential, not a universal definition of life,
recovery, or success.

## 3. Why M/L Separation Matters

The central move is the separation of structural loss `L` from effective resource
`M`.

Without this separation, different cases collapse into the same verbal label:

- structure remains viable, but resource support is exhausted;
- resource exists, but cannot be converted into effective support;
- structural room has shrunk, but the system is still recoverable;
- a target is functionally stopped but restartable;
- a target is identity-relative unrecoverable;
- two systems are individually recoverable but jointly unaffordable;
- repairing one system increases another system's burden.

The M/L split is therefore not cosmetic. It is what lets the theory distinguish
structure-side degradation from resource-side exhaustion, and both from
target-relative recovery failure.

In the Lean development this is reflected by scalar non-identification and
interface-relative no-go results. A single scalar readout can fail to distinguish
different mechanisms that the factored M/L interface keeps apart. The claim is
not that no scalar can ever be useful. The claim is that a scalar-only interface
does not, by itself, expose the mechanism needed for persistence diagnostics,
tradeoff accounting, and intervention routing.

Representative Lean anchors include:

- `scalarAmbiguity_blocks_scalarFactoredDiagnosticClassifier`
- `tradeoffReadyInterface_exposes_resource_and_loss`
- `scalarFactoredInterface_not_tradeoffReady_of_mechanism_ambiguity`

## 4. The Log-Additive Structural Kernel

The structural loss coordinate is not arbitrary notation.

Under the representation assumptions used in the Lean development, a stage-loss
functional on positive retention ratios satisfying identity, composition,
continuity, and nonnegativity conditions is forced into logarithmic form:

```text
loss(r) = -k * log r
```

With a calibration point, the scale can be fixed to the standard `-log r`.

This gives the structural kernel:

```text
m(V_n) = m(V_0) * exp(-L_n)
```

For repair-inclusive dynamics, stage loss and repair enter as net burden:

```text
b_t = d_t - r_t
B_n = sum_{t<n} b_t
m(V_n) = m(V_0) * exp(-B_n)
```

Representative Lean anchors:

- `RepresentationTheorem.loss_must_be_log`
- `TelescopingExp.measure_eq_initial_mul_exp_neg_cumulative_loss`
- `GeneralStateDynamics.feasibleMass_eq_initial_mul_exp_neg_cumulativeNetAction`

## 5. Resource-Coupled Potential Is Not Recovery

The readout

```text
S = M * exp(-L)
```

or, with repair-inclusive burden,

```text
S = M * exp(-B)
```

records full-persistence potential after structural discounting of effective
resource.

When the structural factor is positive, the finite-time nonpositive boundary of
this potential is carried by the resource ledger:

```text
S <= 0 iff M <= 0
```

This is a useful collapse-mode discriminant. It does not say that `L` is causally
irrelevant. Structural loss can drive maintenance costs, reduce effective
resource conversion, raise recovery burden, or close a functional mode. The
identity only says where the zero/nonpositive boundary is recorded once the
resource-coupled readout is fixed.

Representative Lean anchors:

- `CollapseModeDiscriminant.collapse_is_additive_not_multiplicative`
- `StructuralPersistenceOntology.fullPotential_collapse_iff_effectiveResource_nonpos`
- `AdmittedOntology.fullPotential_collapse_iff_effectiveResource_nonpos`
- `resourceCollapseAt_to_fullPotentialCollapse`

## 6. Recovery Layer

Recovery questions require additional structure.

The recovery layer introduces:

```text
target / action / witness / lowerBound / C_req / CanRecoverTo
```

Here `C_req` is the boundary parameter used by this readout. It appears only
after a target-relative recovery question has been asked.

A typical negative readout is:

```text
every target-restoring action costs at least C_req
M < C_req
therefore: not CanRecoverTo M target actions
```

A typical positive readout requires a witness:

```text
there exists an action restoring the target
that action costs at most M
therefore: CanRecoverTo M target actions
```

This is why `C_req` should not be treated as the ontology core. It is a
recovery-layer parameter used after the mainline has already specified what is
being maintained, what carries it, what room remains, and what effective
resource is available.

Representative Lean anchor:

- `AdmittedOntology.recoveryShortfallAt_to_notCanRecover`

## 7. Collective Persistence and Externality

Individual recoverability does not imply collective recoverability.

A minimal example:

```text
System A requires 40.
System B requires 70.
Shared effective resource M = 90.

A is individually recoverable.
B is individually recoverable.
A and B together are not: 40 + 70 > 90.
```

This is not merely a budget anecdote. It shows that persistence must be readable
both at the individual level and at the finite-subset or collective level.

The same interface can express repair externalities:

```text
repairing A consumes shared M
repairing A raises B's L
repairing A raises B's C_req
repairing A weakens B's R -> M conversion
```

Thus the theory separates local repair from global persistence design. This is
especially important for infrastructure, medicine, ecological restoration,
governance, AI operations, and ESG-like settings, where one intervention can
move burdens across systems.

The claim is not that the theory discovers all externalities automatically. A
coupling certificate must be supplied. Once supplied, the accounting consequence
is shared.

## 8. Domain Adapters and Proxy Measurement

Real domains rarely provide perfect access to `V_K`, `m(V_K)`, `L`, `B`, or `M`.

For this reason the practical deployment protocol has three layers.

Specification layer:

The domain gives a relatively clean account of `F`, `K`, `V_K`, `m`, `L/B`, and
`R/M`.

Proxy / estimation layer:

The domain supplies proxies such as `L_proxy`, `M_proxy`, `B_proxy`, or
`V_proxy`. These are not exact readouts by default.

Validation / robustness layer:

The proxy becomes useful only under certificates such as:

```text
|L_proxy - L| <= epsilon
|M_proxy - M| <= epsilon
L <= L_proxy          -- conservative upper proxy
L_proxy <= L          -- conservative lower proxy
margin > error bound
proxy threshold implies true failure
```

This turns measurement difficulty into an explicit part of the theory rather
than an unspoken weakness.

Representative Lean anchors include:

- `LossProxyCandidate`
- `ResourceProxyCandidate`
- `NetBurdenProxyCandidate`
- `ConservativeLossUpperProxy`
- `ConservativeLossLowerProxy`
- `ApproxLossProxy`
- `ApproxResourceProxy`
- `ApproxNetBurdenProxy`
- `ProxyValidationCertificate`
- `ProxySoundForFailure.failure_of_threshold_le_proxy`
- `NoSupportRecord`

## 9. What Lean Verifies

Lean verifies the formal consequences of supplied certificates inside the
accounting interface.

It verifies results such as:

- logarithmic representation of structural loss under explicit assumptions;
- telescoping structural kernels;
- repair-inclusive net-burden kernels;
- resource-coupled collapse discriminants;
- non-identification results for scalar-only readouts;
- admission and ontology handoff boundaries;
- runtime failure readouts from certified witnesses;
- recovery no-go results from lower-bound certificates;
- proxy-soundness readouts under explicit approximation assumptions.

The current repository reports:

```text
552 modules imported by Persistence.lean
569 Lean module files total
sorry = 0
admit = 0
project-declared axiom = 0
```

These numbers describe the formal artifact. They are not a claim that the
artifact proves the empirical truth of every domain adapter.

## 10. What Is Not Claimed

Structural Persistence Theory does not claim:

- that it is a new universal physical law;
- that all domains have the same native dynamics;
- that Lean proves empirical measurements are correct;
- that the correct `F`, `K`, `V_K`, `m`, `L`, `B`, `R`, or `M` are discovered
  automatically;
- that every real-world failure mode has been exhaustively classified;
- that recovery is equivalent to `S`;
- that `C_req` is the ontology core;
- that ESG, ecology, medicine, finance, or governance can be collapsed into one
  master score;
- that changing a target is free goalpost moving;
- that domain bridges rederive the native theorems of thermodynamics,
  information theory, statistical mechanics, control, or biology.

The safe claim is:

```text
Once a domain supplies certificate-scoped structure, resource, loss, proxy,
recovery, or coupling data, Structural Persistence Theory verifies the
accounting consequences for persistence, collapse, recovery, and externality
inside a shared M/L interface.
```

## 11. Contributions

This draft identifies seven contributions.

1. A structural mainline for persistence:

```text
F -> K -> V_K, m -> L/B -> R/M -> S
```

2. A separation of structural loss from effective resource, making M/L
mechanism differences explicit.

3. A representation-backed log-additive structural kernel and repair-inclusive
net-burden kernel.

4. A resource-coupled full-persistence potential readout, explicitly
distinguished from target-relative recovery.

5. A recovery layer in which `C_req` appears as a boundary parameter, not as the
ontology core.

6. A collective and externality layer for shared-resource no-go, forbidden
subsets, and repair-induced burden shifts.

7. A Lean 4 artifact that keeps these distinctions mechanically checkable under
explicit certificates and non-claims.

## 12. Why This Matters

Many high-stakes questions are persistence questions:

- Is the function still maintained?
- Is the carrying structure still viable?
- Is there remaining room, or has the viable region collapsed?
- Are resources merely nominal, or are they effective support?
- Is the target recoverable under the current ledger?
- Which intervention axis changes the verdict?
- Does repairing one system make another unrecoverable?

Structural Persistence Theory does not answer these questions by replacing the
domain. It answers them by requiring the domain to expose the relevant
certificates and then routing the consequences through a shared accounting
interface.

The resulting value is not only diagnostic. It also gives an intervention
grammar. Once a failure is decomposed, an intervention can be read by which
component it changes:

- change the maintained role `F`;
- redesign the carrier `K`;
- expand or protect the viable region `V_K`;
- reduce structural loss `L` or repair-inclusive burden `B`;
- improve conversion from raw resource `R` to effective support `M`;
- increase or reallocate `M`;
- weaken harmful coupling;
- change timing before an irreversible boundary is crossed.

This is the limited but important sense in which examples can transfer across
domains. The domain-native intervention itself does not transfer automatically.
The accounting pattern can: a successful intervention in one domain may suggest
that another domain should look for the analogous axis in its own native
semantics.

This is why the theory is best read as a persistence accounting calculus: not a
master score, not a universal oracle, but a disciplined way to keep structure,
resource, recovery, and externality from being confused.

In the long run, if stable measurement protocols and canonical adapters emerge,
this accounting calculus could play a role analogous to temperature or
information. It would not be a new law replacing physics, biology, finance,
ecology, or computation. It would be a shared language for asking what those
domains imply about persistence, collapse, functional death, recovery,
irreversibility, intervention, and collective tradeoff.
