# Structural Persistence Theory

## A Lean-Verified Structural Persistence Accounting Framework

**Working preprint draft.**
This file is a paper-facing draft scaffold. It is meant to be migrated into the
LaTeX paper repository once the argument order is stable.

## Abstract

Persistence, collapse, recovery, and irreversibility are usually discussed in
domain-specific vocabularies: reliability, resilience, viability, stability,
recoverability, maintenance, repair, or sustainability. These vocabularies often
mix together the function to be preserved, the structure that carries it,
structural loss, raw resource stock, effective support, and restoration
affordability. Structural Persistence Theory formalizes an accounting
interface whose main line separates these roles before the recovery layer is
invoked.

The maintained function or target `F` and its carrying structure `K` fix
what it means for the system to persist as that structure. The viable state
region `V` is the region in which `F` can still be maintained through `K`,
and `m(V)` measures its room. The structural-loss coordinate `L`, or the
repair-inclusive net burden `B`, records log-additive loss derived from changes
in that viable room. The resource ledger `M` records effective support: the
amount of resource actually usable, at that time, to maintain `F` through
`K`, not merely raw resource stock `R`. This split distinguishes
functional stop, resource-side collapse, target-relative recoverability,
target-relative irrecoverability, and identity-relative death without
collapsing them into one failure axis.

This main line can be summarized as:

```text
F -> K -> V_K,m -> L/B -> R/M -> S.
```

The resource-coupled readout `S = M * exp(-L)` or, with explicit repair,
`S = M * exp(-B)`, measures full-persistence potential after structural loss
discounts effective support; it is not the definition of target recovery. A
target-specific restoration requirement `C_req` enters only when one asks
whether a particular restoration target is affordable. Positive recovery then
requires an attainable restoration witness; negative recovery claims require a
lower-bound certificate showing that every target-restoring action exceeds the
effective resource available. The accompanying Lean 4 development verifies the
certificate-scoped accounting consequences--recoverability, irrecoverability,
intervention thresholds, timing readouts, finite forbidden subsets, robustness,
and repair externalities--without unfinished proofs or project-declared axioms.
The result is an audit grammar for persistence and repair decisions, not a
universal dynamics or master score.

The practical target class is therefore not arbitrary syntax, labels, or
identifiers. It is persistence subjects: structures for which maintained,
stopped, and recoverable questions are meaningful once resource-side and
structure-side aspects have been supplied. The Lean development names this
scope explicitly, so a domain can enter the common M/L accounting interface by
certificate while nontriviality and independence of the aspects remain
separate proof obligations.

## Keywords

structural persistence; repair affordability; recoverability; irreversibility;
Lean 4; formal verification; intervention design; resilience; nested repair
accounting; resource allocation; collapse

## 1. Introduction

Many systems fail in ways that are easy to name but hard to compare. A patient
can be functionally dead relative to a viability predicate yet recoverable under
a supplied treatment witness. A network can be damaged but still restorable
within a repair budget. An organization can retain resources while the cost of
restoring trust or coordination exceeds its remaining capacity. A public
intervention can improve the margin of one family, firm, city, or ecosystem
while shifting restoration burden onto neighboring, higher-level, or natural
systems.

The difficulty is not merely terminological. Discussions of persistence and
collapse often conflate several questions:

1. How structurally degraded is the system?
2. What target is supposed to be restored?
3. Is raw resource actually converted into effective support for that function?
4. What does restoration require when an explicit recovery target is supplied?
5. Is there enough effective resource to pay that requirement?
6. Does repairing one system consume resources or increase requirements for
   another?
7. Which intervention would change the verdict?

Structural Persistence Theory separates these questions into a small accounting interface. Its main line
is:

```text
F -> K -> V_K,m -> L/B -> R/M -> S.
```

`F` names the
function, identity, predicate, or target being maintained, and `K` names the
structure that carries it. `V` is the viable state region for maintaining `F`
through `K`, and `m(V)` measures the remaining room in that region. The
coordinate `L`, or repair-inclusive `B`, tracks log-ratio loss of that viable
room; larger values mean weaker persistence or greater burden. The ledger `M`
tracks effective support rather than raw stock: cash without authority, beds
without nurses, or servers without rollback paths are cases where `R` may be
large while `M` is small. A target-specific requirement `C_req` is used only
when the recovery layer is invoked. The structural
kernel records how multiplicative persistence becomes log-additive loss, while
the recovery layer reads target-relative affordability through requirements,
effective resource, witnesses, and lower-bound certificates.

The central claim is therefore modest but sharp: Structural Persistence Theory does not replace native
domain dynamics. It gives a verified interface through which native domain
certificates can produce common persistence-facing readouts. A domain supplies
its target predicates, cost bounds, resources, witnesses, and coupling
certificates; the core theory checks what follows.

Equivalently, Structural Persistence Theory is not a theory of arbitrary symbols. Its natural subjects
are maintainable structures: objects for which it makes sense to ask whether a
function is still maintained, stopped, recoverable, or blocked under resource
constraints. In Lean, this scope is represented by a supplied M/L aspect
decomposition plus the predicates that make persistence questions meaningful;
nontriviality and independence are explicit certificates rather than automatic
discoveries.

This has two linked faces. The first is individual diagnosis: whether a system
is still persisting, functionally stopped, recoverable, irrecoverable, or
collapsed relative to explicit targets. The second is collective design: whether
finite subsets can be repaired together under shared resources, which subsets
are forbidden, and which repairs create external shortfalls elsewhere.

### Minimal example

Suppose system `A` has restoration requirement `40`, system `B` has restoration
requirement `70`, and the shared resource ledger is `M = 90`.

```text
A alone: 40 <= 90
B alone: 70 <= 90
A+B jointly: 40 + 70 > 90
```

Each system is individually recoverable, but the pair is not jointly recoverable
under the shared resource ledger. If repairing `A` also raises `B`'s
restoration requirement, a baseline-feasible plan can become infeasible. Structural Persistence Theory
formalizes this kind of transition as a repair externality and a
possible-to-impossible flip under explicit certificates.

## 2. Core Accounting

### 2.1 The `F / K / V,m / L or B / R,M` main line

Structural Persistence Theory starts from a role separation:

```text
F -> K -> V_K,m -> L/B -> R/M -> S.
```

- `F`: the function, identity, predicate, or target to be maintained;
- `K`: the structure that carries `F`;
- `V`: the viable state region in which `F` can still be maintained through
  `K`;
- `m`: a measure of the size, room, or tolerance of that viable region;
- `L`: structural-loss coordinate read from log-ratio shrinkage of `m(V)`;
  larger `L` means weaker persistence or greater accumulated structural burden;
- `B`: repair-inclusive cumulative net structural burden, including both
  shrinkage and explicitly supplied repair;
- `R`: raw resource stock;
- `M`: effective resource actually usable to maintain `F` through `K`.

Without this split, structural degradation, raw resource stock, effective
support, functional stop, and repair infeasibility collapse into one axis. With
the split, Structural Persistence Theory can ask which boundary has been crossed and which intervention
axis can move it back. `L` is not the desired state itself. It is the loss read
after `F`, `K`, `V`, and `m` have fixed what counts as viable room. A
target-specific `C_req` is introduced when an explicit restoration target is
supplied; it is a recovery-boundary readout inside this larger accounting, not
the whole core.

### 2.2 The structural kernel

The `L` side is log-additive. In the closed shrinkage reading,

```text
d_t = -log(m(V_{t+1}) / m(V_t))
L_n = sum_{t<n} d_t
m(V_n) = m(V_0) * exp(-L_n).
```

With explicit repair or maintenance,

```text
d_t = -log(m(V_t^-) / m(V_t))
r_t =  log(m(V_{t+1}) / m(V_t^-))
b_t = d_t - r_t
B_n = sum_{t<n} b_t
m(V_n) = m(V_0) * exp(-B_n).
```

This is not a merely cosmetic choice. Under the representation assumptions used
in the Lean development, multiplicative structural persistence is forced into a
logarithmic loss scale.

**Representation principle.** Let `f : (0,1] -> R` be a stage-loss functional
satisfying normalization, additivity, continuity, and nonnegativity:

```text
f(1) = 0
f(r * s) = f(r) + f(s)
f is continuous
f(r) >= 0 for r in (0,1].
```

Then `f(r) = -k * log(r)` for some `k >= 0`. With an explicit calibration point,
the scale can be fixed to `k = 1`. This is the representation-backed reason
that the structural kernel has an exponential form.

### 2.3 The resource-coupled readout

Structural Persistence Theory often reads full-persistence potential through

```text
S_n = M_n * exp(-L_n),
```

or, with explicit repair,

```text
S_n = M_n * exp(-B_n).
```

This readout says how much full-persistence potential remains after structural
loss discounts available resource. Since the structural exponential is positive
in the intended kernel, the finite-time nonpositive boundary of this readout is
carried by the additive resource axis:

```text
S_n <= 0 iff M_n <= 0.
```

This is a collapse-mode discriminant, not the whole theory. In settings where
`M` is constrained to be nonnegative, this boundary is often read as `S_n = 0`;
for the general real-valued ledger, the theorem is stated with `<= 0`.
Target-relative recoverability is read separately. In shorthand one writes:

```text
certified requirement is affordable  iff  C_req_n <= M_n
```

but this is not by itself the full positive recovery claim. Positive recovery
also requires an attainable restoration witness. Negative claims require
lower-bound certificates showing that every target-restoring action exceeds
effective resource.

### 2.4 Scalar aggregate limit and cross-domain tradeoffs

The M/L split is not only a useful notation. The Lean development now makes a
limited no-go claim precise: a scalar-only readout such as

```text
S = M * exp(-L)
```

can identify two states whose resource-side, loss-side, and supplied
intervention-axis diagnostics differ. More generally, any diagnostic classifier
whose score factors only through that scalar readout is blocked by a supplied
same-scalar ambiguity witness.

This is not a claim that every scalar theory is impossible, that existing
research cannot explain persistence or collapse, or that M/L is uniquely
minimal among all possible decompositions. The claim is interface-relative:
under supplied ambiguity witnesses, aggregate-score interfaces that factor
through `S` cannot carry the mechanism distinctions Structural Persistence Theory asks the cross-domain
accounting layer to preserve.

The positive companion is that split M/L adapters can project the same
diagnostic vocabulary--resource-side, loss-side, and supplied intervention
axes--across domains. This is the sense in which Structural Persistence Theory begins to provide a
measuring interface for whole-system tradeoffs. It does not automatically
compute a global optimum. Rather, it keeps explicit which function is being
maintained, which structure carries it, which boundary has been crossed, which
resource is effective, which recovery requirement is certified, and which
externality a repair imposes on another system. Those are the quantities a
global optimization or policy choice must supply, weight, and constrain.

The diagnostic tradeoff layer makes this connection formal. Given supplied
decoders from action-restored scalar values into domain states, the resource
and loss readouts of a split diagnostic interface become finite predicate-set
targets. For two domains, the left and right diagnostic axes are combined into
one finite index type and passed to the same shared-budget predicate-set
ledger. Under explicit required-cost lower bounds and attainable witnesses,
Lean proves both the positive shared-budget recovery wrapper and the
individual-feasible / jointly-infeasible forbidden-region wrapper. Thus the
split is not only a diagnostic convenience; it is the interface through which
diagnostics enter collective tradeoff accounting.

The necessity layer names the contrapositive boundary. An structural-persistence-style
tradeoff-ready interface must preserve the supplied resource and loss
diagnostics, hence exposes both readouts and is equivalent to the split
projection at the diagnostic-readout level. If a proposed interface factors
diagnostic preservation through one scalar readout, a supplied scalar mechanism
ambiguity witness blocks tradeoff readiness on the corresponding diagnostic
side. This is not an impossibility theorem for all encodings; it is an
interface-relative necessity theorem for the diagnostics Structural Persistence Theory asks the
tradeoff ledger to preserve.

The ready-ledger layer then closes the forward handoff. Once a domain supplies
such a tradeoff-ready interface, the resource/loss diagnostics can be routed
into the same finite predicate-set ledger, including cross-domain
shared-budget recovery wrappers and forbidden-interval wrappers. This is not a
global optimizer or a cost-discovery theorem; it is the verified ledger entry
point on which such optimization would have to operate.

The policy-comparison layer adds the first explicit decision vocabulary on top
of that ledger. A policy is a selected finite set of diagnostic axes; Lean can
package certificates that the policy is recoverable, blocked, covers another
policy, or is forbidden as a set while its selected axes remain individually
recoverable. This is still not automatic policy synthesis: no action-cost
nonnegativity or subset monotonicity of recoverability is assumed unless
supplied as an additional certificate.

The frontier layer packages the corresponding boundary readout. A supplied
partial classifier may mark policies as recoverable or blocked only through
soundness proofs, and a minimal forbidden policy additionally carries a proof
that no strict subpolicy is forbidden. Thus the formalization can represent a
certified diagnostic frontier without claiming exhaustive search or automatic
optimization.

The summary layer packages this certified boundary into a compact readout for
downstream use: a supplied frontier together with optional
recoverable-coverage and minimal-forbidden witnesses. The summary projects the
facts already carried by those certificates; it does not rank policies,
synthesize preferences, or enumerate all possible policies.

The readout layer then makes the optional witnesses reportable only when their
presence in the summary is itself certified. A combined readout can expose a
recoverable-coverage certificate together with a minimal-forbidden certificate,
but this remains certificate projection. It is not a policy-ranking,
preference-synthesis, or frontier-enumeration theorem.

The consistency layer adds the corresponding sanity check: the same selected
policy cannot be reported as both recoverable and minimal-forbidden blocked.
This is the incompatibility of recoverability and blockage for one policy, not
a completeness result for the frontier and not a policy-selection theorem.

The report layer then packages this supplied combined readout as a downstream
report object. It re-exposes the summary, recoverable policy,
minimal-forbidden policy, consistency fact, and no-strict-subpolicy witness by
projection. It does not choose policies, rank policies, discover certificates,
or optimize.
On the structural side, `StructuralPersistenceDiagnosticFrontierReport`
specializes this report layer to the supplied resource/loss structural
diagnostic readout. Its reported recoverable and minimal-forbidden policies are
projections from the supplied combined readout, not policy choices. It does not
construct a frontier, enumerate policies, infer minimality, rank policies,
discover certificates, or optimize interventions.
The structural diagnostic report construction layer then gives the explicit
constructor from supplied certificates. A supplied sound frontier,
recoverable-coverage certificate, and minimal-forbidden certificate can be
bundled into a structural report. For the toy resource/loss forbidden interval,
the minimal-forbidden side is derived from the existing two-axis minimality
theorem. A concrete toy report can use a silent frontier classifier that marks
nothing, a resource-singleton recoverable-coverage certificate extracted from
the toy resource-axis witness, and the full resource/loss minimal-forbidden
certificate. The resulting report rules out using the full resource/loss
forbidden policy as its recoverable singleton side. Guard lemmas further make
explicit that the silent frontier marks no policies and that report facts come
from summary certificate fields.
This concrete toy report can also be placed beside the admitted ontology's
inherited M/L ledger profile in a ledger/report bundle. The bundle is still a
handoff object: the ledger profile does not generate the diagnostic report.
The cross-domain structural report bundle is terminal in the same sense: it
places two supplied single-domain bundles beside a separately supplied
cross-domain frontier report, and projects the resulting readouts without
deriving the cross-domain report from the single-domain reports.
For the built-in two-axis `{resource, loss}` diagnostic policy, Lean also
proves a narrow shape result: under `0 <= M`, a supplied full forbidden
certificate upgrades to a minimal-forbidden certificate, because every strict
subpolicy is empty or singleton and is recoverable from the individual
witnesses. This is not arbitrary-axis minimality and not frontier search.

## 3. Death, Collapse, and Irrecoverability

Structural Persistence Theory does not define life or death universally. It reads death and recovery
relative to supplied predicates, functions, identities, or targets.

- Functional stop: the current state fails a chosen function or viability
  predicate.
- Target-relative recoverability: a target-restoring action exists and is
  affordable.
- Target-relative irrecoverability: every target-restoring action exceeds the
  effective resource ledger.
- Resource-side collapse: the resource-coupled full-persistence readout reaches
  the resource boundary.

Thus an identity can be functionally dead but recoverable, functionally dead and
irrecoverable, or resource-collapsed under additional absorbing hypotheses. The
point is to avoid turning "death" into an unscoped universal term.

## 4. Intervention Grammar

Structural Persistence Theory turns diagnosis into intervention design by asking which part of the
accounting an intervention changes. At the persistence layer this includes `F`,
`K`, `V,m`, `L/B`, the conversion from raw `R` to effective support `M`, and
`M` itself. When an explicit recovery target is supplied, the recovery layer
also has a margin:

```text
margin = M - C_req < 0,
```

then an intervention `u` can be read through

```text
margin(u) = (M + DeltaM(u)) - (C_req + DeltaC_req(u)).
```

Recovery can return when the intervention covers the certified gap and supplies
the required target-restoring witness. Interventions can therefore be classified
as:

1. preserving or changing the maintained function `F` under explicit
   conditions;
2. redesigning the carrying structure `K`;
3. protecting or expanding the viable region `V`;
4. reducing `L` or repair-inclusive net burden `B`;
5. improving the conversion from raw resource `R` into effective resource `M`;
6. increasing or reallocating `M`;
7. lowering a target-specific restoration boundary `C_req`;
8. supplying a restoration witness;
9. weakening harmful coupling between systems;
10. moving a deadline or horizon.

The transferable object across domains is the type of repairability structure
changed by the intervention, not the intervention's domain-native mechanism.
Changing a target is not treated as free goalpost moving: target changes are
auditable only under explicit predicate-inclusion, equivalence, or
sortal-morphism witnesses, and the old and new target-relative readouts remain
distinct.

## 5. Collective Repair and Externalities

The collective layer is one of the main reasons for the accounting split.
Individual affordability does not imply joint affordability under shared
resources:

```text
forall i in I, C_req_i <= M
```

does not imply

```text
sum_{i in I} C_req_i <= M.
```

Structural Persistence Theory formalizes finite forbidden subsets, required-budget gaps, budget-lift
sufficiency, required-cost-reduction routes, and timing layers for when joint
affordability returns. It also formalizes repair externality patterns in which
restoring one system consumes shared resource or increases another system's
restoration requirement. This supports no-go statements of the form:

```text
A can be restored locally,
but every A-restoring action forces B into shortfall.
```

and possible-to-impossible flips:

```text
baseline joint recovery is affordable,
but coupling-induced required-cost pressure makes joint recovery unaffordable.
```

## 6. Practical Deployment: Nested Audit Layers

In deployment, Structural Persistence Theory should be read as an audit layer for repair decisions, not as
an oracle that replaces domain judgment. A domain keeps its native measurements
and causal models, but exposes a certificate-scoped adapter specifying:

- the maintained function, predicate, identity, or target `F`;
- the carrying structure `K`;
- the viable state region `V`, or the mass trajectory abstracting it;
- the structural-loss coordinate `L/B` read from changes in viable room;
- the raw resource stock `R` and effective resource ledger `M`;
- the target-relative restoration boundary `C_req`, when an explicit recovery
  layer is invoked;
- the intervention axis being changed;
- the coupling or externality imposed on other systems;
- the witness or lower-bound certificate supporting the verdict.

The point is not to collapse individuals, families, firms, communities,
societies, nations, ecosystems, and the global environment into one scalar
score. The point is to keep each level's native semantics visible while making
recovery margins, intervention gaps, forbidden subsets, repair externalities,
and timing deadlines comparable at the decision layer.

In nested deployment, each unit can be read both as a system in its own right
and as a component of higher-level systems. A person can be a repair unit inside
a family, workplace, city, society, and ecosystem. A firm can be a repair unit
inside a supply chain, community, nation, and environment. A nation can be a
repair unit inside a global ecological and institutional system. The accounting
question is how an intervention that improves one unit's persistence or
recovery margin changes the `F`, `K`, `V,m`, `L/B`, `R/M`, `C_req`, or coupling of
neighboring, lower-level, higher-level, social, and natural systems.

This supports whole-system feasibility and tradeoff accounting, not automatic
value optimization. To compute a global optimum, one must supply the objective,
targets, weights, constraints, and certificates. Structural Persistence Theory supplies the auditable
accounting structure that keeps those choices explicit. Environmental, ESG, and
governance claims can be entered into this ledger, but they are examples of the
nested social-ecological reading rather than a separate master application.
The scalar aggregate limit is the formal reason for this restraint: if the
decision layer factors only through one aggregate score, distinct mechanisms
and intervention axes can be merged before the tradeoff is even stated.

## 7. Lean Verification

The Lean development verifies the accounting consequences of explicit
certificates. It does not verify the empirical truth of the certificates
themselves. The full conceptual ontology `F / K / V,m / L or B / R,M / S` is
supplied by definitions, adapters, and certificates; Lean verifies the formal
kernel and the readouts once that mapping is supplied. In particular, it
verifies:

- feasible-set / mass-trajectory kernels and their abstraction into ledger
  interfaces, with `C_req` as an explicit recovery-boundary layer when invoked;
- the structural exponential kernel and resource-coupled readout;
- scalar non-identification: same scalar readouts can hide different resource,
  loss, and intervention-axis diagnostics, while split M/L adapters project
  these diagnostics across domains;
- collapse-mode discriminants such as `S_n <= 0 iff M_n <= 0`;
- repair infeasibility as target-relative irrecoverability;
- monotone structural-cost channels under explicit assumptions;
- sufficient and necessary intervention gap readouts;
- first shortfall, first recoverable again, and deadline-style timing readouts;
- finite forbidden subsets and collective repair tradeoffs;
- witness-conditional robustness and sortal invariance boundaries.

The current repository builds 605 import-spine modules with:

```text
sorry = 0
admit = 0
project-declared axiom = 0
```

The paper-level ontology and the Lean implementation do not have identical
granularity. The conceptual model starts from `F / K / V,m / L,B / R,M`.
The Lean artifact verifies the central accounting engine beneath that model:
`GeneralStateDynamics` keeps explicit feasible sets, an initial region
`V0 : Set X`, and a mass model `MassModel.mass : Set X -> Real`, while many domain
bridges and `MLLedgerClass` abstract this to a positive mass trajectory
`m : Nat -> Real`. On that abstracted trajectory the development proves the
log-ratio kernel, repair-inclusive net burden, resource ledger consequences,
`fullPotential`, and the `CanRecoverTo`/predicate-recoverability readouts. Thus
Lean verifies the accounting consequences of supplied certificates; it does
not claim to formalize the entire philosophical ontology of function and
structure as a single object.

### Representative verified readouts

The Lean development is organized around reusable readouts such as:

1. Structural kernel:
   `m(V_n) = m(V_0) * exp(-L_n)`.
2. Collapse-mode discriminant:
   `S_n <= 0 iff M_n <= 0` under the positive structural kernel.
3. Repair infeasibility:
   if every target-restoring action costs at least `C_req` and `M < C_req`, then
   target recovery is impossible.
4. Intervention sufficiency:
   if an intervention covers the certified gap and supplies the required
   witness, recovery returns.
5. Intervention necessity:
   if the certified gap is not covered under lower-bound certificates, recovery
   remains impossible at that point.
6. Collective forbidden subset:
   individual affordability does not imply joint affordability; required-sum
   lower bounds can block joint recovery.
7. Coupled flip:
   baseline joint recovery can be affordable while coupling-induced required
   increase makes joint recovery unaffordable.
8. Scalar non-identification:
   same scalar readouts can hide different resource-side, loss-side, and
   intervention-axis diagnostics, while split M/L adapters can project those
   diagnostics across domains.

## 8. Domain Bridges and Non-Claims

Structural Persistence Theory includes certificate-to-affordability bridges for finite-block coding,
Bellman/control, thermodynamic work/free-energy, PAC/sample complexity, network
repair, finite cascade traces, resilience margins, predicate targets, and
physiological or homeostatic wrappers. These are not claims that each native
domain theory has been re-derived.

The bridge list should be read as adapter compatibility, not as accumulated
domain authority. A bridge shows that, once a domain supplies the relevant
certificate, the same repair-affordability readout can be reused. It does not
mean that Structural Persistence Theory has re-derived the native theory of that domain.

The paper should avoid the following readings:

- Structural Persistence Theory proves a universal physical law.
- Structural Persistence Theory proves Shannon's coding theorem.
- Structural Persistence Theory derives the thermodynamic second law, Jarzynski/Crooks, Landauer, or
  PAC/VC theory from first principles.
- Structural Persistence Theory automatically discovers real-world interventions.
- Structural Persistence Theory defines life or death universally.
- Structural Persistence Theory turns resilience, social value, or ecological value into one master score.

The intended reading is:

```text
domain certificate -> structural-persistence adapter -> repair-affordability readout
```

not:

```text
all domains are the same theorem
```

## 9. Contributions

This paper's contributions are:

1. A formal `F / K / V,m / L or B / R,M` split separating maintained
   function, carrying structure, viable state region and measure, structural
   loss or net burden, raw resource, and effective support, with `C_req` reserved
   for explicit recovery-boundary readouts.
2. A representation-backed log-additive structural kernel and a
   resource-coupled full-persistence readout, explicitly distinguished from
   target-relative recovery.
3. A target-relative account of recoverability, irrecoverability, and
   identity-relative death.
4. A typed intervention grammar for moving recoverability margins.
5. A collective repair accounting layer for forbidden subsets, budget gaps,
   timing, and repair externalities.
6. A deployment reading of Structural Persistence Theory as an audit layer for nested repair decisions,
   including social, institutional, and ecological repair ledgers.
7. A Lean 4 artifact verifying the accounting consequences under explicit
   certificates and assumptions.

## 10. Suggested Paper Structure

1. Introduction: the conflation problem and the `F / K / V,m / L or B / R,M` split.
2. Structural kernel: log-additivity and exponential persistence.
3. Resource-coupled readout and target-relative recovery.
4. Death, irrecoverability, and sortal/identity boundaries.
5. Intervention grammar and timing readouts.
6. Collective repair feasibility and externalities.
7. Domain adapters and deployment reading.
8. Lean artifact and theorem map.
9. Non-claims and limitations.
10. Conclusion.

## Conclusion Draft

Structural Persistence Theory is best understood as a verified accounting interface for structural
persistence and repairability. It does not erase domain-specific meanings,
prove native empirical laws, or compress all values into one scalar. Instead,
it asks each domain to expose what function is being maintained, what structure
carries it, how the viable region is lost or repaired, which raw resources are
available, which of them become effective support, and what witnesses or
externalities are claimed. When an explicit recovery target is supplied, the
same interface also records the target-relative restoration boundary `C_req`.
Once those certificates are explicit, the Lean-checked core can read
persistence, collapse, recoverability, irrecoverability, intervention
thresholds, timing, and collective repair tradeoffs. This makes Structural Persistence Theory a common
audit grammar for persistence and intervention design.
