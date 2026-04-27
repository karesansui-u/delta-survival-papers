# Non-CSP Conditional Law-Side Bridge

Status: reader-facing bridge memo. Not a replacement for queueing theory,
reliability theory, or Markov stability theory.

## 1. Purpose

This note closes a gap that remained implicit across the current G4 and G6-c
artifacts.

The program already had:

- a minimal non-CSP anchor package;
- a Foster-Lyapunov / queueing embedding;
- a repair-maintenance open-system skeleton.

What it did not yet have was a single reader-facing statement of how far these
materials move the program toward the **law side** outside CSP.

The answer is:

```text
Not to non-CSP universality in general.
But yes to a conditional law-side bridge inside repairable stochastic systems,
queueing drift, and related stability domains.
```

## 2. Bridge Claim

The bridge claim is deliberately narrow:

```text
In a restricted non-CSP class where
  (i) the structural quantity is naturally fixed,
  (ii) compensation flow is operationally observable, and
  (iii) a collapse or hitting boundary is available under explicit assumptions,
the structural persistence balance principle may be read as a conditional law-side embedding of
existing stability theory.
```

This is not the claim that structural persistence balance principle is a new complete theory of
queueing, reliability, or stochastic stability. It is the claim that the core
balance variables

\[
  b_t=\ell_t-g_t,\qquad
  B_n=\sum_{t<n} b_t,\qquad
  R_t=e^{-Z_t}
\]

appear naturally inside those existing theories.

## 3. Gate Table

The gate used here is the one defined in
`analysis/law_side_upgrade_gate.md`.

| domain | \(m\) natural? | \(g_t\) observable? | collapse / hitting boundary? | current role |
|---|---|---|---|---|
| queueing / Foster-Lyapunov drift | yes | yes | yes, under drift assumptions | conditional law-side bridge |
| repair / maintenance reliability-fatigue | yes | yes | partially, finite-prefix and threshold-level | near-bridge open-system anchor |
| serial reliability | yes | no | yes | loss-only control anchor |
| constant-fraction decay | yes | no | yes | loss-only control anchor |
| Backblaze v2 | partly domain-natural, but observational | no | predictive only | observational loss-only support |
| C-MAPSS FD001 | yes for loss-only degradation coordinate | no | classification boundary only | cross-domain weakening outcome |
| Route C companion anchors | proxy-heavy | indicator-level only | observational only | companion layer |

## 4. Queueing / Foster-Lyapunov

Queueing and discrete-time drift theory are the strongest current bridge.

The map is direct:

| domain-native quantity | structural-persistence balance reading |
|---|---|
| Lyapunov load \(W(X_t)\) or backlog \(Z_t\) | structural load |
| \(W(X_{t+1})-W(X_t)\) | one-step balance \(b_t\) |
| negative drift | maintenance / recovery tendency |
| positive drift | overload / collapse tendency |
| load threshold or unstable region | collapse / hitting boundary |

This is why G4 v1 and G6-c meet here so naturally.

The point is not novelty in queueing theory. The point is that the
loss-minus-compensation vocabulary is not foreign to a classical stability
domain. It is already there, just under different names.

## 5. Repair / Maintenance Reliability-Fatigue

Repair-maintenance systems are the cleanest route to a future empirical
\(g_t\).

The map is again direct:

\[
  D_n = D_0 + \sum_{t<n}(d_t-g_t),
  \qquad
  M_n = B-D_n.
\]

Here:

- \(d_t\) is damage / degradation increment;
- \(g_t\) is repair, replacement, maintenance input, or redundancy
  activation;
- \(M_n\) is remaining margin to collapse.

This domain matters because it shows that compensation is not merely a
metaphor. It can be a schedule, a maintenance log, a repair event, or an
explicit resource input.

What is still missing is a reader-facing stochastic reliability theorem that
pushes this all the way through the boundary condition in the same way that
queueing already does.

## 6. Why Serial Reliability and Constant-Fraction Decay Stay as Controls

These anchors remain important, but they are not enough for the open-system
claim.

They show:

- a natural structural quantity;
- a clean exponential kernel;
- a threshold or survival reading.

They do not show:

- explicit compensation flow;
- maintenance-versus-overload balance;
- a genuine open-system bridge.

So they are best kept as non-CSP loss-only controls, not promoted beyond what
they support.

## 7. Why Backblaze and C-MAPSS Do Not Close the Bridge

Backblaze v2 is a real observational success and C-MAPSS FD001 is a real
weakening result. Both matter. Neither closes the law-side bridge.

Backblaze:

- same-domain second attempt;
- loss-only observational support;
- no empirical \(g_t\).

C-MAPSS:

- cross-domain loss-only branch;
- compressed degradation coordinate with real signal;
- still weaker than the preregistered wide raw-sensor baseline.

These are good non-CSP empirical steps. They are not yet the place where
existing stochastic stability theory is recovered as a structural persistence balance principle.

## 8. What This Changes

This bridge note changes the public interpretation in one specific way.

Before:

```text
The program had strong CSP evidence and some non-CSP algebraic correspondences.
```

After:

```text
The program still does not have non-CSP universality in general, but it can
now state a conditional law-side bridge for a restricted class of repairable
stochastic systems.
```

That is a stronger and more precise sentence.

## 9. What It Does Not Change

This note does not change the evidence tier of:

- Backblaze v2;
- C-MAPSS FD001;
- Route C companion anchors.

It also does not convert G4 / G6-c into a universal-law declaration.

The claim remains conditional, domain-restricted, and assumption-preserving.

## 10. Next Work After This Bridge

The clean follow-up order is:

1. keep queueing / Foster-Lyapunov as the canonical law-side bridge;
2. continue the repair-maintenance route until a real empirical \(g_t\) can be
   measured;
3. only then ask whether a broader non-CSP law-side package is justified.

That sequence is stronger than jumping immediately from CSP success to a
universal non-CSP declaration.
