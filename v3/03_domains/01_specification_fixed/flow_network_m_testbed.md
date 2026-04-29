Structural Maintenance Flow Network Testbed
===========================================

domain_id: flow_network_m_testbed

domain_name: Structural maintenance flow-network testbed

observability_layer: specification_fixed

status: design


1. Purpose
----------

This testbed is the first clean validation target for the resource term \(M\).
Its role is not to model software, batteries, or organizations directly. Its role
is to build a controlled functional structure where:

- the maintained function \(F\) is explicit;
- collapse is mechanically defined;
- damage and repair are observable;
- raw energy can be allocated into different M-components.

The central question is:

> Under the same damage process and the same total energy budget, does the
> \(M\)-component allocation predict persistence better than a total-resource
> baseline?


2. Structural Object
--------------------

Let
\[
  G=(N,E)
\]
be a directed capacitated network with source \(s\), sink \(t\), and edge
capacities \(c_e\ge 0\).

The maintained function is:

\[
  F(G,c) = \mathbf{1}\{\operatorname{maxflow}_{s\to t}(G,c)\ge Q\},
\]

where \(Q>0\) is the required service flow.

Collapse occurs at the first time
\[
  \tau_Q := \inf\{n:\operatorname{maxflow}_{s\to t}(G_n,c_n)<Q\}.
\]

The flow margin is
\[
  \mu_n := \operatorname{maxflow}_{s\to t}(G_n,c_n)-Q.
\]

The primary functional readouts are:

- collapse time \(\tau_Q\);
- maintained-flow ratio;
- minimum margin \(\min_{k\le n}\mu_k\);
- recovery time after damage.


3. M-Component Interpretation
-----------------------------

The same raw energy budget
\[
  E = E_{\mathrm{buffer}}+E_{\mathrm{recovery}}+E_{\mathrm{reconfiguration}}
\]
is split into three M-components.

| Component | Operation | Effect |
|---|---|---|
| \(M_{\mathrm{buffer}}\) | pre-allocate spare capacity, harden edges, add redundant capacity on existing paths | increases margin before damage |
| \(M_{\mathrm{recovery}}\) | repair damaged edges or restore lost capacity after damage | shortens recovery and restores previous structure |
| \(M_{\mathrm{reconfiguration}}\) | activate bypass edges, add alternate edges, or rewire around bottlenecks | changes topology while preserving \(F\) |

External supply is not a fourth component. In this testbed, an external channel is
represented as an additional source of energy into one of the three components,
for example \(E_{\mathrm{ext}\to\mathrm{recovery}}\).


4. State and Measure
--------------------

For a finite testbed, capacities are discretized:

\[
  c_e\in\{0,1,\ldots,C_{\max}\}.
\]

The feasible region at time \(n\) is
\[
  V^{(n)} := \{c:\operatorname{maxflow}_{s\to t}(G_n,c)\ge Q\}.
\]

The default measure \(m\) is counting measure over the finite capacity grid. For
small graphs, \(m(V^{(n)})\) can be computed exactly. For larger graphs, the
testbed uses a frozen Monte Carlo estimator with a fixed seed schedule and
reports estimator error separately.

The loss-side coordinate is
\[
  L_n = -\log\frac{m(V^{(n)})}{m(V^{(0)})}.
\]

When repair and reconfiguration are represented as two-stage updates, the net
coordinate is
\[
  B_n=\sum_{k<n}(d_k-r_k).
\]


5. Damage Families
------------------

The primary design uses several pre-fixed damage families so that no single
M-component is always optimal.

| Damage family | Description | Expected useful component |
|---|---|---|
| random attrition | independent edge capacity loss | buffer / recovery |
| bottleneck attack | capacity loss concentrated on min-cut edges | reconfiguration / buffer |
| clustered failure | correlated edge loss inside a subnetwork | reconfiguration |
| demand shock | temporary increase in \(Q\) | buffer |
| repairable wear | repeated small losses on existing edges | recovery |

These expectations are not support claims. They are used only to ensure that the
calibration regime is not trivially favorable to one component.


6. Allocation Policies
----------------------

For a fixed total energy \(E\), compare at least the following policies:

| Anchor policy | Energy allocation |
|---|---|
| buffer-heavy | high \(E_{\mathrm{buffer}}\), low recovery/reconfiguration |
| recovery-heavy | high \(E_{\mathrm{recovery}}\), low buffer/reconfiguration |
| reconfiguration-heavy | high \(E_{\mathrm{reconfiguration}}\), low buffer/recovery |
| balanced | equal or near-equal split |
| total-energy baseline | uses only \(E\), not the split |

These anchors are not enough for M-profile support. The frozen primary should use
an allocation grid over
\[
  E_{\mathrm{buffer}}+E_{\mathrm{recovery}}+E_{\mathrm{reconfiguration}}=E
\]
and include held-out allocation mixes. This prevents the M-profile model from
merely memorizing four policy labels.

The optional oracle policy may be reported as an upper bound, but it is not a
baseline for support.


7. Baselines
------------

The main baseline is a total-resource model:

- graph family;
- initial max-flow margin;
- total energy \(E\);
- graph size and density;
- damage intensity.

The M-profile model adds:

- \(E_{\mathrm{buffer}}/E\);
- \(E_{\mathrm{recovery}}/E\);
- \(E_{\mathrm{reconfiguration}}/E\);
- pre-fixed interaction terms between damage family and M-component, if frozen.

A stronger calibration-best-allocation baseline should also be included. It
learns, from calibration data only, which allocation region tends to work for
observable graph and damage summaries. M-profile support requires beating this
baseline, not only the total-resource scalar baseline.

The central comparison is:

\[
  \text{total-resource baseline} + \text{M-profile}
  >
  \text{total-resource baseline}.
\]


8. Frozen Validation
--------------------

The frozen target is persistence prediction under fixed allocation and damage
conditions.

Primary metrics:

- collapse-time prediction error;
- maintained-flow ratio prediction error;
- minimum-margin prediction error;
- regret relative to the best observed allocation, reported as a diagnostic.

M-profile support:

- M-profile improves held-out prediction of collapse time or maintained-flow
  ratio over the total-resource baseline.

Robustness support:

- the result is stable across pre-frozen graph families, damage families,
  normalization choices, and \(\Phi\)-style aggregation choices.


9. Split Discipline
-------------------

The testbed must keep calibration and primary evaluation separate.

Suggested split:

- calibration: choose graph sizes, damage intensities, and non-degenerate \(Q\);
- validation: freeze graph generator, damage families, energy grid, policies,
  baselines, metrics, and support thresholds;
- primary: run on held-out graph seeds and damage seeds;
- outside rerun: provide a seed-locked package for independent execution.

No M-profile support is allowed if the \(Q\), damage intensity, or allocation
grid is chosen after observing primary outcomes.


10. Non-Claims
--------------

This testbed does not claim:

- that software, SaaS, batteries, or organizations have the same M-profile;
- that a total-resource failure in this testbed refutes the M formalism;
- that a successful testbed result proves a universal resource law;
- that \(M_{\mathrm{buffer}}, M_{\mathrm{recovery}}, M_{\mathrm{reconfiguration}}\)
  are directly observable physical quantities in real domains;

The result, if positive, would show something narrower and more useful:

> M-component allocation is not empty bookkeeping. In a controlled functional
> structure, the same total energy can have different persistence value depending
> on whether it is allocated to buffer, recovery, or reconfiguration.

Current status (2026-04-29): the guarded primary final candidate produced
no M-profile support under its strongest frozen baseline. The M-profile model
improved over the total-resource baseline on one diagnostic surface, but it did
not beat the calibration-best-allocation baseline. This is recorded as
controlled mechanistic no-support, not as a refutation of \(M\) as the familiar
effective-resource side.


11. Implementation Roadmap
--------------------------

The working design package is:

- `analysis/m_flow_network_testbed/design_note.md`
- `analysis/m_flow_network_testbed/simulator_spec.md`
- `analysis/m_flow_network_testbed/preregistration_draft.md`

Phase 0: simulator smoke test.

- implement max-flow network generator;
- implement damage families;
- implement buffer / recovery / reconfiguration policies;
- verify deterministic replay from seed.

Phase 1: calibration.

- find graph and damage regimes where not all policies tie;
- freeze \(Q\), graph families, damage intensities, and energy grid;
- define no-support and degenerate-case rules.

Phase 2: frozen primary.

- compare total-resource baseline against M-profile model;
- record support / no-support in `05_evidence/`.

Phase 3: outside rerun.

- package generator, seeds, configs, and evaluator;
- request outside reruns;
- record results in `05_evidence/outside_reruns.tsv`.
