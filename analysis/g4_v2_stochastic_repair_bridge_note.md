# G4 v2 Stochastic Repair Bridge Note

Status: reader-facing theorem-bridge note. Not a full theorem paper, not a
universal-law declaration, and not a replacement for stochastic reliability
theory.

## 1. Purpose

Queueing / Foster-Lyapunov currently gives the strongest non-CSP conditional
law-side bridge. Repair / maintenance balance is one step behind: it already
has a finite-prefix skeleton and an operationally meaningful \(r_t\), but not
yet a reader-facing stochastic bridge statement.

This note fixes that next half-step.

The aim is not to pretend that a full stochastic maintenance theorem is
already proved. The aim is to make explicit what the next law-side bridge would
look like in a repairable stochastic system.

## 2. Minimal Setting

Consider a filtered process \((\mathcal F_t)\) with:

- accumulated damage \(D_t\);
- one-step damage increment \(d_t\);
- one-step repair / maintenance increment \(r_t\);
- one-step balance
  \[
    b_t := d_t-r_t;
  \]
- cumulative one-step balance
  \[
    B_n := \sum_{t<n} b_t;
  \]
- failure threshold \(B\);
- remaining margin
  \[
    M_t := B-D_t.
  \]

Then the finite-prefix identity is

\[
  D_n = D_0 + B_n,
  \qquad
  M_n = M_0 - B_n.
\]

Collapse occurs at the stopping time

\[
  \tau_B := \inf\{t \ge 0 : D_t \ge B\}
  =
  \inf\{t \ge 0 : M_t \le 0\}.
\]

This is already enough to phrase a stochastic bridge.

## 3. What “Bridge” Means Here

The bridge claim is conditional:

```text
If a repairable stochastic system admits a natural damage / margin quantity,
an observable recovery amount, and a stopping boundary, then its stability
question can be written in structural-persistence balance form.
```

That is stronger than a metaphor and weaker than a new universal theorem.

## 4. Three Reader-Facing Bridge Statements

### 4.1 Positive net-drift overload

If

\[
  \mathbb E[b_t \mid \mathcal F_t] \ge \varepsilon > 0
\]

while the process remains below the failure threshold, then the expected margin
decreases and the process moves toward threshold crossing.

Reader-facing meaning:

```text
When damage systematically exceeds repair, collapse risk rises.
```

This is the repairable analog of overload drift in queueing.

### 4.2 Negative net-drift maintenance

If

\[
  \mathbb E[b_t \mid \mathcal F_t] \le -\varepsilon < 0
\]

outside a critical set, then the expected margin increases and the process has
a maintenance / recovery tendency.

Reader-facing meaning:

```text
When repair systematically outpaces damage, the system drifts away from
collapse.
```

This is not yet an optimal maintenance theorem. It is the sign-level bridge.

### 4.3 Bounded-increment stopping / concentration

If \(b_t\) has bounded increments, or a suitable MGF / concentration condition
holds, then finite-horizon collapse probabilities can be bounded through the
structural persistence balance amount \(B_n\).

Reader-facing meaning:

```text
Once a repairable system has a frozen margin variable and bounded one-step balance,
collapse risk over a horizon can be controlled by standard drift /
concentration tools.
```

This is exactly where repair / maintenance could move from near-bridge to a
fuller law-side bridge.

## 5. Why This Is Still “Near-Bridge”

The missing step is not notation. It is theorem closure.

Queueing already comes with reader-recognizable stability and overload
regimes. Repair / maintenance currently has:

- finite-prefix balance identity;
- threshold crossing semantics;
- repair dominance over damage-only;
- clear operational meaning for \(r_t\).

What it does not yet have in the checked-in reader-facing layer is:

- a standard stochastic reliability theorem stated in this notation;
- a hitting-probability or stopping-time result written out end-to-end;
- an empirical dataset where \(r_t\) is directly logged and frozen before
  validation.

So the current status remains:

```text
near-bridge open-system anchor
```

not:

```text
completed stochastic law-side bridge
```

## 6. Relation To Existing Files

This note sits between three existing layers.

1. `analysis/g4_v2_repair_maintenance_scope.md`
   - finite-prefix scope lock
2. `lean/Survival/RepairMaintenanceBalance.lean`
   - algebraic skeleton
3. `analysis/law_side_upgrade_gate.md`
   - the stronger gate for calling something law-side

Its role is to say what the next theorem-shaped step would look like before
any new empirical dataset arrives.

## 7. What Would Upgrade This Further

Repair / maintenance would move closer to a genuine law-side bridge if one of
the following were added.

1. a reader-facing stopping / hitting proposition under explicit bounded-drift
   assumptions;
2. a reliability-style theorem that preserves the original domain assumptions
   and is rewritten in \(b_t, B_n, M_t\) notation;
3. a frozen maintenance-log primary where \(r_t\) is a direct logged
   intervention quantity rather than a proxy.

The third item is the empirical bottleneck. The first two are theorem-side
polish.

## 8. Main Takeaway

The strongest current safe statement is:

```text
Queueing already gives the program a conditional law-side bridge.
Repair / maintenance now gives the program a reader-facing stochastic bridge
target: the same collapse / maintenance question, but with an operationally
meaningful recovery amount.
```

That is why repair / maintenance is the right next non-CSP escalation path.
