Recoverable Viability
— A Structural Accounting Draft for Resilience —

Status: working draft. This note is a candidate public paper unit derived from the structural persistence accounting drafts. It does not add a new empirical support claim. Its role is to make resilience precise as recoverable viability under resource constraints.


Abstract

Resilience is often used as a broad positive word for systems that survive disturbance. This paper narrows the term. In structural persistence accounting, robustness and resilience are different readings. Robustness is small immediate structural loss under disturbance. Resilience is the preservation and use of recovery paths after disturbance, under finite resource margin and pre-specified repair rules.

We define a structural maintenance problem by a base space \(X\), a maintenance condition \(G\), a viable region \(V_G\), a recoverable region or path set \(V_{\mathrm{rec}}\), a pre-fixed measure \(m\), and resource margin \(M\). Disturbance creates structural consumption \(d_t\), repair creates recovery \(r_t\), and net consumption is \(b_t=d_t-r_t\). Over a finite horizon, \(B_n=\sum_{t<n}b_t\), and the reading \(S_n=M_n e^{-B_n}\) connects resource margin to the set-valued accounting kernel. This is not a universal law of empirical decay. It is an accounting coordinate for separating loss, recovery, and resource exhaustion.

The central claim is: resilience is not the absence of error; it is recoverable structural viability after error. A system may make mistakes, suffer contradictions, lose consistency, or leave its maintenance condition temporarily, yet remain resilient if the error is localized, admissible recovery paths remain, repair resources remain, and the system can return to \(G\) without losing its relevant identity. This paper develops the formal vocabulary, distinguishes resilience from robustness, gives a measurement protocol based on pre-frozen mappings from observations to \(B\), \(M\), and \(V_{\mathrm{rec}}\), and sketches candidate empirical designs in LLM information qualification, software change-risk detection, and organizational maintenance.


1. Why resilience needs a sharper definition

Many systems are judged by whether they avoid errors. That is too narrow. Humans learn by making errors and repairing them. Software systems ship regressions and recover through rollbacks, patches, test additions, and incident reviews. LLM-based agents hallucinate, misremember, or misclassify inputs, yet can be made safer when errors are typed, quarantined, rechecked, and prevented from becoming persistent state.

The practical insight is simple: a structure does not need to be perfect to remain viable. It needs errors to be localizable and repairable. What matters is not only the magnitude of the initial damage, but whether the damage destroys the paths by which the system can return to its maintenance condition.

This paper treats resilience as a structural property:

> Resilience is recoverable structural viability under finite resources.

Equivalently:

> Resilience is not the absence of error. It is the preservation of recoverable paths after error, under bounded resources and pre-specified repair rules.

This definition separates resilience from two nearby notions.

Robustness is resistance before or during impact. A robust system has small immediate loss \(d_t\). Resilience is recovery after impact. A resilient system may have nonzero \(d_t\), but retains \(V_{\mathrm{rec}}\), can produce \(r_t\), and keeps cumulative net consumption \(B_n\) bounded relative to its resource margin \(M_n\).

Reliability is the probability of avoiding failure over a specified time and environment. Resilience is not merely high reliability. It includes the structure of recovery after violation, including whether the same system can return to the relevant maintenance condition \(G\).


2. Structural maintenance problem

Let \(X\) be a base space of states, actions, configurations, or paths. Let \(G\) be the maintenance condition under which \(X\) is read as the same relevant system. The condition \(G\) may represent functional correctness, identity, safety, consistency, operational continuity, policy compliance, or another domain-specific maintenance condition.

Let \(V_G\) be the viable region: the set of states, actions, or paths that satisfy, or can continue to satisfy, \(G\) under the fixed observation unit. Let \(m\) be a pre-fixed measure, count, mass, or weight used to read the size of \(V_G\). The measure is not chosen after observing the result.

Let \(V_{\mathrm{rec}}\) be the recoverable region or path set: the set of paths by which a state outside \(G\), or a damaged state within a reduced viable region, can return to \(G\) while preserving the identity relevant to the problem. \(V_G\) and \(V_{\mathrm{rec}}\) must be separated. A system may currently violate \(G\) but still have recovery paths. Conversely, a system may retain resources while losing the paths required to recover as the same structure.

Let \(M\) be effective resource margin. \(M\) may read time, budget, attention, staff, compute, operational authority, redundancy, or another domain-specific capacity. \(M\) is not derived from the exponential accounting kernel. It is a separate resource-side reading connected to the structural side by a specified convention.


3. Consumption, recovery, and net structural loss

For each time step, disturbance or constraint accumulation may shrink the viable region. Let \(V^{(t)}\) be the region before damage, \(V_t^-\) the region after damage, and \(V^{(t+1)}\) the region after repair or recovery.

Define structural consumption:

\[
d_t=-\log\frac{m(V_t^-)}{m(V^{(t)})}.
\]

Define recovery:

\[
r_t=\log\frac{m(V^{(t+1)})}{m(V_t^-)}.
\]

Define net consumption:

\[
b_t=d_t-r_t.
\]

Then

\[
b_t=-\log\frac{m(V^{(t+1)})}{m(V^{(t)})}.
\]

Over a finite horizon,

\[
B_n=\sum_{t<n}b_t,
\qquad
m(V^{(n)})=m(V^{(0)})e^{-B_n}.
\]

If resource margin is attached as a separate reading, the structural persistence potential is

\[
S_n=M_n e^{-B_n}.
\]

This expression is an accounting coordinate. It does not state that all real systems empirically decay exponentially. It says that, after \(G\), \(V\), and \(m\) are fixed, multiplicative remaining-region ratios become additive consumption, and recovery can be subtracted on the same log-ratio scale.


4. Robustness versus resilience

The distinction can be stated operationally:

| Property | Structural reading | Typical indicators |
|---|---|---|
| Robustness | Small immediate damage | low \(d_t\), low violation count, low initial degradation |
| Resilience | Recoverable damage | positive \(r_t\), nonempty \(V_{\mathrm{rec}}\), bounded \(B_n\), finite recovery time |
| Resource margin | Capacity to execute recovery | \(M\), budget, time, compute, staff, redundancy, authority |
| Irreversibility risk | Loss of internal recovery | \(M=0\) and \(m(V_{\mathrm{rec}})=0\), or no admissible recovery path |

A robust system can be non-resilient. For example, it may resist small disturbances but become unrecoverable after a larger one because recovery paths were never maintained.

A resilient system can be non-robust. It may fail often or incur visible damage, but if failures are localized, repair rules are available, and recovery paths remain, the structure can persist.

The common phrase "resilient system" should therefore not mean "system with no failure." It should mean "system whose failures do not destroy recovery."


5. Error as a structural accounting event

In an epistemic or software system, an error is not only an incorrect output. It is a structural event whose danger depends on admission, propagation, and repair.

An error is low-risk when:

- it is typed,
- it is localized,
- it is not promoted into durable state without qualification,
- it has a repair route,
- the repair route has resources,
- the repair is recorded so that future behavior changes.

An error is high-risk when:

- it is untyped,
- it is mixed with trusted state,
- stale information is presented as current,
- weak evidence is promoted to confirmed state,
- dependency changes do not trigger downstream re-evaluation,
- memory is reused outside its validity conditions,
- no recovery path remains.

This is the reason resilience is central to LLM control. LLM failures are difficult to eliminate. A more realistic goal is to prevent failures from becoming unrecoverable structural loss. The control architecture should preserve \(V_{\mathrm{rec}}\): paths for rechecking, demoting, quarantining, correcting, reopening, or invalidating information.


6. LLM information qualification as a resilience example

Information Qualification Control (IQC) can be read as a resilience mechanism. The goal is not to make the upstream model incapable of misclassification. The goal is to prevent a misclassification from being accepted as durable memory or action without qualification.

Failure labels such as M1-M4 in the IQC suite are not the same as the theoretical resource margin \(M\). They are operational failure-mode labels. The theoretical \(M\) is resource-side effective margin.

In IQC, resilience appears through:

- source boundaries: quoted or third-party content is not silently treated as the user's own memory;
- permission boundaries: no-store or read-only information is not promoted into writable memory;
- version boundaries: withdrawn or stale values are not reactivated as current;
- uncertainty boundaries: weak assertion is not promoted as confirmed fact;
- freeze paths: under low health or confidence, scored judgment can be frozen while hard violations remain blocked.

These controls do not require the system never to be wrong. They require the wrongness to be blocked, routed, or made repairable. This is a concrete operational reading of \(V_{\mathrm{rec}}\): the system keeps paths from an uncertain or damaged information state back to qualified use.


7. Software change-risk detection as a resilience example

Software development is a natural domain for recoverable viability. Regressions occur when a premise changes and dependent assumptions are not repaired. A change in an API, schema, configuration, authorization policy, dependency, or branch/head state can make old findings, old tests, or old memory invalid.

The resilience-centered pipeline is:

```text
before state
  -> after state
  -> premise update
  -> dependency closure
  -> evidence qualification
  -> candidate generation
  -> staged verification
  -> repair / rejection / re-evaluation
  -> current-vs-stale presentation
```

The key is not that the detector never proposes a wrong candidate. The key is that candidates have stages. A raw candidate is not a confirmed finding. A stale observation is not a resolved issue. A self-asserted LLM confirmation is not proof. Evidence must qualify, dependency surfaces must be recomputed, and promotion must pass control-transition conditions.

This makes bug and regression detection a resilience problem. The pipeline is strong when it preserves recovery paths after detection error:

- false candidates can be rejected without contaminating confirmed state;
- stale candidates can be re-evaluated without being called resolved;
- changed premises can invalidate downstream findings;
- verified findings can be separated from raw provider candidates;
- review decisions can be separated from freshness.


8. Measurement protocol

To avoid turning resilience into a retrospective label, the mapping from observation to structural coordinates must be frozen before evaluation.

A resilience study must specify:

1. Maintenance condition \(G\).
2. Observation unit: state, action, path, candidate, memory record, branch, or job.
3. Viable region \(V_G\) or a justified proxy.
4. Recoverable region \(V_{\mathrm{rec}}\) or a justified proxy.
5. Measure \(m\) or a frozen observational readout.
6. Resource margin \(M\) or its fixed readout.
7. Damage indicators for \(d_t\).
8. Repair indicators for \(r_t\).
9. Net-consumption endpoint \(B_n\) or a proxy endpoint.
10. Baseline and support rule.

Candidate operational measures include:

| Target | Example readout |
|---|---|
| Immediate damage \(d_t\) | number of violated invariants, dependency breaks, unqualified admissions |
| Recovery \(r_t\) | restored invariants, rejected bad candidates, corrected memory records |
| Recovery time | MTTR, \(P(T_{\mathrm{rec}}\le \tau)\), correction latency |
| Net recovery | \(\sum r_t / \sum d_t\), or reduction in unresolved structural loss |
| Resource margin \(M\) | remaining review budget, retry budget, compute budget, operational authority |
| Irreversibility risk | no admissible repair path, no rollback, no qualified evidence, exhausted \(M\) |

The study must not rename an observed indicator as \(L\), \(B\), or \(M\) after seeing the result. The mapping must be pre-specified, and failures must be recorded as non-support, silence, or invalid execution rather than rescued by relabeling.


9. Testable hypotheses

This paper suggests several testable hypotheses.

H1: Systems with explicit recovery paths have lower unresolved net structural loss \(B_n\) after disturbance than systems with direct acceptance pipelines, even when immediate damage \(d_t\) is similar.

H2: \(M\)-limited failures and \(V_{\mathrm{rec}}\)-limited failures have different recovery signatures. \(M\)-limited failures improve when resources are added. \(V_{\mathrm{rec}}\)-limited failures do not improve without redesign or new recovery paths.

H3: In LLM memory systems, qualification controls reduce durable error admission more than they reduce raw upstream error generation.

H4: In software regression detection, dependency-closure re-evaluation reduces stale-current confusion and lowers correction latency after branch/head changes.

H5: A system can show high robustness but low resilience when small disturbances are resisted but larger disturbances destroy recovery paths.

These hypotheses are intentionally narrower than "resilience improves everything." They are designed to be falsifiable under frozen mappings.


10. Figure plan

Figure 1: Robustness versus resilience.

```text
disturbance
  -> immediate loss d_t
  -> recovery r_t
  -> net loss b_t
```

Figure 2: Recoverable viability regions.

```text
V_G: currently viable region
outside G but recoverable: V_rec paths back to G
outside recovery: no internal return path
```

Figure 3: \(M\)-limited versus \(V_{\mathrm{rec}}\)-limited failure.

```text
case A: recovery path exists, resource margin exhausted
case B: resource margin remains, recovery path absent
case C: both absent, internal irreversible collapse
```

Figure 4: LLM information qualification as repair-preserving control.

```text
raw input
  -> typed candidate
  -> qualification gate
  -> accepted / pending / rejected / frozen
  -> repair log
```

Figure 5: Software change-risk detection as recoverable viability.

```text
premise update
  -> dependency closure
  -> eligible evidence
  -> candidate
  -> staged verification
  -> repair or confirmed finding
```


11. What this paper claims and does not claim

This paper claims:

- resilience can be defined as recoverable structural viability under finite resources;
- robustness and resilience are different coordinates;
- \(V_{\mathrm{rec}}\), \(B_n\), \(r_t\), and \(M\) provide a structured vocabulary for recovery;
- observational resilience claims require frozen mappings and failure ledgers;
- LLM information qualification and software change-risk detection are natural candidate domains.

This paper does not claim:

- every real system obeys an empirical exponential law;
- \(M\) is derived from the log-ratio kernel;
- any single resilience metric is universal;
- all LLM errors can be prevented;
- software bugs can be completely detected by the proposed accounting;
- a supportive case study proves the theory for all domains.


12. Draft contribution

The contribution is not a new slogan for resilience. It is a separation:

```text
robustness = resistance to loss
resilience = recoverability after loss
resource margin = capacity to execute recovery
irreversibility = loss of both internal recovery path and required margin
```

The core intellectual move is to treat error as an accounting event rather than a terminal failure. If the structure preserves typed boundaries, recovery paths, and resource margin, then error can be a repairable event. If it does not, even small errors can become persistent structural loss.

This is the shared axis connecting human learning, LLM memory control, software regression detection, and organizational recovery: not perfection, but structured repair.
