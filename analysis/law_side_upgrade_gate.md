# Law-Side Upgrade Gate

Status: scope-and-interpretation memo. Not a theorem, not validation evidence,
and not a universal-law declaration.

## 1. Purpose

This note fixes the minimal gate for when a non-CSP domain may be described as
a **conditional law-side bridge** for the structural balance law, rather than
only as a suggestive framework or observational analogy.

The point is not to blur the boundary between the current program state and a
future universal-law claim. The point is to say, explicitly, what extra
conditions must hold before a non-CSP anchor can be read as more than an
illustration.

The gate is narrow on purpose.

## 2. The Three Conditions

### 2.1 Measure condition: \(m\) is natural and pre-fixed

The domain must provide a defensible structural quantity before outcome
inspection:

- a state-space safety set, slack quantity, survival quantity, Lyapunov load,
  or remaining margin;
- a measure or scalarization that is natural inside the domain, not chosen
  after observing which predictor performs well;
- a fixed horizon and fixed object of persistence.

What fails this condition:

- choosing \(V\) or \(m\) after seeing which representation makes the theory
  look good;
- relying on a proxy that has no domain-local reason to be preferred over
  nearby alternatives;
- mixing multiple incompatible measures without a pre-specified rule.

### 2.2 Compensation condition: \(g_t\) is observable

The domain must expose a compensation flow that can be identified without
theory-rescuing reinterpretation:

- service rate, repair rate, maintenance input, redundancy activation, or
  logged intervention;
- a quantity recorded or defined before the collapse outcome is known;
- a domain-local meaning that distinguishes compensation from mere activity.

What fails this condition:

- post-hoc inference of “repair” from the outcome itself;
- purely metaphorical support variables with no operational reading;
- observables that cannot be separated from the collapse event they are
  supposed to prevent.

### 2.3 Boundary condition: collapse / hitting behavior is available

The domain must support a conditional collapse boundary, threshold, or
hitting-time statement under explicit assumptions:

- deterministic threshold crossing;
- drift-based stability / overload regimes;
- martingale, concentration, or Foster-Lyapunov style conditions.

This does not require an unconditional theorem. It does require a clear path
from

\[
  a_t=\ell_t-g_t,\qquad A_n=\sum_{t<n} a_t
\]

to some boundary reading such as:

- \(A_n\) crosses a threshold;
- \(Z_n\) hits an overload region;
- a remaining margin \(M_n\) reaches zero;
- a stopping / collapse probability is bounded under stated assumptions.

What fails this condition:

- expectation-level tendency with no threshold reading at all;
- observational prediction with no domain-side collapse boundary;
- a score that ranks outcomes but cannot be connected to a domain-level
  boundary statement.

## 3. Gate Outcomes

The gate produces four qualitatively different statuses.

| status | meaning |
|---|---|
| Conditional law-side bridge | \(m\), \(g_t\), and a collapse boundary are all available under explicit assumptions |
| Near-bridge open-system anchor | \(m\) and \(g_t\) are available, but the boundary statement is finite-prefix or only partially developed |
| Loss-only control anchor | \(m\) and a loss-side boundary are available, but \(g_t\) is absent or intentionally zero |
| Observational / companion layer | one or more of \(m\), \(g_t\), boundary remain proxy-level or domain-weak |

This gate is intentionally stronger than “can be written in structural-balance
notation?” Many domains can be written that way. Fewer can be elevated toward
law-side status.

## 4. Current Program Classification

### 4.1 Queueing / Foster-Lyapunov drift

Status:

```text
Conditional law-side bridge
```

Why:

- \(m\): natural load / Lyapunov quantity / slack quantity;
- \(g_t\): service or compensatory capacity is observable;
- boundary: overload, stability, and hitting-style interpretations already
  exist in the underlying theory.

This is the strongest current non-CSP law-side bridge because the structural
balance variables inherit the role of the domain-native drift calculus without
claiming to replace it.

### 4.2 Repair / maintenance reliability-fatigue balance

Status:

```text
Near-bridge open-system anchor
```

Why:

- \(m\): damage, remaining margin, or threshold slack can be fixed naturally;
- \(g_t\): repair / maintenance / replacement is operationally meaningful;
- boundary: finite-prefix threshold crossing is available, but a full
  stochastic reliability theorem is not yet reader-facing.

This is the cleanest route to a future empirical \(g_t\), but it is not yet a
completed law-side bridge.

### 4.3 Serial reliability / constant-fraction decay

Status:

```text
Loss-only control anchors
```

Why:

- \(m\): survival / remaining quantity is natural;
- \(g_t\): intentionally absent or zero;
- boundary: decay or survival threshold readings are straightforward.

These anchors matter because they show the loss-only kernel outside CSP, but
they do not by themselves support an open-system balance claim.

### 4.4 Backblaze v2 and C-MAPSS FD001

Status:

```text
Observational loss-only anchors below law-side status
```

Why:

- Backblaze v2 gives same-domain observational loss-only support;
- C-MAPSS FD001 gives a weakening outcome with real compressed-signal value;
- neither provides an empirical \(g_t\);
- neither is the right place to claim a non-CSP law-side bridge.

These results remain valuable. They just belong to a different evidence tier.

### 4.5 Route C companion anchors

Status:

```text
Observational / companion layer
```

Why:

- \(m\) is still proxy-heavy;
- \(g_t\) is observable mainly as indicator-level repair or scope variables;
- collapse boundaries are predictive / observational rather than domain-native
  stability theorems.

Route C is still important, but it is not the first place where the program
becomes law-side in the strong sense of this gate.

## 5. Main Bridge Claim

The strongest safe claim at present is:

```text
The program is not yet entitled to a non-CSP universal-law declaration.
However, in repairable stochastic systems and drift-based stability models,
the structural balance law can already be presented as a conditional
law-side bridge to existing stability theory.
```

This is stronger than saying “the notation is suggestive” and weaker than
saying “the theory replaces queueing or reliability theory.”

That is the right level.

## 6. Non-Claims

This gate does not claim:

1. that non-CSP generality is solved once one domain passes;
2. that a law-side bridge replaces the original domain theory;
3. that a natural \(m\) for queueing automatically gives a natural \(m\) for
   LLMs, organizations, or software systems;
4. that empirical \(g_t\) has already been captured in the current public
   datasets;
5. that expectation-level tendency automatically yields universal
   concentration or collapse laws.

## 7. Next Clean Move

Use this gate to organize the next reader-facing non-CSP bridge note:

1. state the three conditions;
2. classify queueing / Foster-Lyapunov, serial reliability,
   constant-fraction decay, and repair-maintenance against them;
3. conclude with the narrow bridge claim, not a universal-law declaration.

That is the cleanest way to move G4 / G6-c from “interesting analogies” toward
“conditional law-side bridge” without overclaim.
