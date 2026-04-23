# G4 v2 Repair / Maintenance Anchor Scope

Status: scope memo for the next non-CSP anchor after G4 v1.

Date: 2026-04-23

## 1. Purpose

G4 v1 fixed the minimal non-CSP anchor package:

- primary anchor: queueing / Foster-Lyapunov drift;
- loss-only controls: serial reliability and constant-fraction decay;
- secondary skeletons: branching expectation, fatigue, consensus, buckling,
  percolation.

G4 v2 should not merely add another loss-only example. The next most valuable
step is to show a non-CSP open-system model in which repair / maintenance is
explicitly represented as a compensation flow \(g_t\).

This memo therefore selects the next G4 direction:

\begin{quote}
G4 v2 should prioritize a repair / maintenance reliability-fatigue anchor,
not a branching-process strengthening, for the next iteration.
\end{quote}

The reason is architectural. The structural balance law is strongest when it
explains how open systems persist by paying compensatory flows. A repairable
reliability or fatigue model makes that \(g_t\) term visible in a classical
non-CSP domain.


## 2. Why Not Branching First?

Branching processes remain a good future anchor. A subcritical Galton-Watson
process has an exponential expectation skeleton, and almost-sure extinction is
a classical theorem.

However, making branching primary for G4 v2 has two disadvantages.

First, the current Lean support is expectation-level only. Strengthening it to
almost-sure extinction or generating-function theory would require a larger
probability-theory development. That may be valuable, but it would mostly
extend the loss-only / decay side.

Second, branching does not foreground the open-system question:

\[
  \text{what compensatory flow must be paid to maintain structure?}
\]

For the long-term program, this question is more central than adding one more
exponential-decay example. Branching should be deferred to a later G4 / G6
iteration unless a clean Lean route to almost-sure extinction becomes cheap.


## 3. Selected Direction

G4 v2 selects a repair / maintenance anchor with the following minimal
variables.

| symbol | meaning |
|---|---|
| \(D_t\) | accumulated damage / load / unrepaired degradation |
| \(d_t\) | one-step damage or loss increment |
| \(g_t\) | one-step repair / maintenance / compensation |
| \(a_t=d_t-g_t\) | net action |
| \(A_n=\sum_{t<n}a_t\) | cumulative net action |
| \(B\) | collapse / failure threshold |
| \(M_t=B-D_t\) | remaining margin |
| \(R_t=\exp(-D_t)\) | optional relative maintenance coordinate |

The finite-prefix balance identity is

\[
  D_n
  =
  D_0 + A_n
  =
  D_0 + \sum_{t<n}(d_t-g_t).
\]

Collapse occurs when

\[
  D_n \ge B
\]

or equivalently when \(M_n\le 0\).

This is the same structural balance law, but now the compensation term has an
operational reading: replacement, repair, inspection, redundancy activation,
cooling, patching, or scheduled maintenance.


## 4. Candidate Domains

### 4.1 Repairable Serial Reliability

The loss-only serial reliability anchor already has

\[
  R=\prod_i p_i=\exp(-L).
\]

G4 v2 can extend this by allowing components to be repaired or replaced before
the system crosses a failure boundary.

Minimal model:

\[
  D_{t+1}=D_t+d_t-g_t.
\]

Here \(d_t\) is component degradation or risk accumulation, while \(g_t\) is
maintenance effort. The primary claim is not a new reliability theorem. The
claim is that repairable reliability has the same loss-minus-repair accounting
as the structural balance law.

### 4.2 Fatigue Damage With Repair

The existing fatigue skeleton is threshold bookkeeping:

\[
  \sum_{t<n} d_t \ge C.
\]

The G4 v2 extension is to add repair:

\[
  \sum_{t<n}(d_t-g_t) \ge C.
\]

This is a clean open-system version of cumulative damage. It also maps well to
engineering language: damage accumulation, healing / annealing / maintenance,
remaining useful life, and failure threshold.

### 4.3 Preventive Maintenance Schedule

A schedule \(g_t\) can be deterministic:

\[
  g_t =
  \begin{cases}
    r, & t \in S,\\
    0, & t \notin S,
  \end{cases}
\]

where \(S\) is a maintenance schedule.

This gives an intervention-ranking bridge:

- increasing \(g_t\) lowers \(A_n\);
- moving maintenance earlier can increase the minimum margin \(M_t\);
- a schedule is useful only relative to the loss profile \(d_t\).

This is the non-CSP version of the M supplement's operational mapping layer.


## 5. Minimal Theorem Targets

G4 v2 should stay finite-prefix and algebraic in the first iteration.

Target 1:

\[
  D_n = D_0 + \sum_{t<n}(d_t-g_t).
\]

Target 2:

\[
  M_n = B-D_n = M_0-\sum_{t<n}(d_t-g_t).
\]

Target 3:

If \(D_0 + A_n < B\), then no threshold collapse has occurred by horizon \(n\).

Target 4:

If \(D_0 + A_n \ge B\), then the finite-prefix threshold has been crossed by
horizon \(n\).

Optional target:

\[
  R_{t+1}=R_t\exp(-(d_t-g_t))
\]

for \(R_t=\exp(-D_t)\).

These targets are deliberately small. They package the balance identity and
threshold reading; they do not prove optimal maintenance, stochastic
reliability, or fatigue crack-growth laws.


## 6. Lean Scope

A possible Lean file name is:

```text
lean/Survival/RepairMaintenanceBalance.lean
```

Minimal contents:

- finite sequences of damage \(d_t\) and repair \(g_t\);
- cumulative net action;
- damage after \(n\) steps;
- remaining margin;
- threshold crossing predicates;
- telescoping identities.

This should reuse the style of:

- `LyapunovBalanceEmbedding.lean`;
- `SerialReliability.lean`;
- `FatigueDamage.lean`;
- `QueueStability.lean`.

No stochastic theorem is required for G4 v2 iteration 1.


## 7. Non-Claims

G4 v2 must not claim:

1. a new reliability theorem;
2. a new fatigue crack-growth theorem;
3. an optimal maintenance policy theorem;
4. a stochastic proof of failure probability bounds;
5. that \(g_t\) is directly measurable in all engineering systems;
6. that repair cost is free;
7. that this anchor establishes a universal law.

Correct wording:

\begin{quote}
Repairable reliability and fatigue models provide a non-CSP open-system
anchor for the structural balance law: accumulated damage is governed by a
loss-minus-repair finite-prefix identity. This shows that the \(g_t\)
compensation term is not merely an LLM / software metaphor, while leaving
domain-specific reliability and fatigue theorems intact.
\end{quote}


## 8. Deliverables

Recommended sequence:

1. Add this scope memo.
2. Update the G4 v1 supplement and selection memo to mark repair /
   maintenance as the selected G4 v2 direction.
3. If proceeding to formalization, add a narrow Lean skeleton:
   `RepairMaintenanceBalance.lean`.
4. Add a reader-facing supplement or subsection only after the Lean skeleton
   and theorem map are stable.

This sequence keeps G4 v2 from becoming an unconstrained engineering survey.
The first step is to formalize the balance identity; empirical or optimal
maintenance claims come later, if at all.


## 9. Current Decision

G4 v2 is selected as:

\begin{quote}
repair / maintenance reliability-fatigue balance, finite-prefix algebraic
skeleton first.
\end{quote}

Branching-process strengthening is deferred. It remains valuable, but it is no
longer the immediate next G4 step.
