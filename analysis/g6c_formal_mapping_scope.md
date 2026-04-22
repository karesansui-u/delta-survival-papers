# G6-c formal mapping scope memo

Status: scope memo / draft plan. Not a theorem, not a universal-law
declaration, and not a replacement for existing queueing or Markov-chain
stability theory.

Date: 2026-04-23

## 1. Purpose

This memo fixes the scope for the next G6-c work item after the Route A CSP
calibration pause.

The goal is to turn the strongest existing-theory connection in the structural
balance law paper into a bounded formal-mapping draft:

```text
Foster-Lyapunov / queueing drift
  -> structural load Z_t
  -> net action a_t = Z_{t+1} - Z_t
  -> cumulative action A_n = Z_n - Z_0
  -> relative maintenance R_t = exp(-Z_t)
  -> local balance R_{t+1} = R_t exp(-a_t)
```

This is a sequencing move, not a retreat. The point is to strengthen the
formal spine before selecting the next non-CSP anchor.

## 2. Why G6-c now

Exp43 q-coloring and Exp44 Cardinality-SAT showed that Route A CSP width
experiments need a threshold-local protocol before validation. Continuing CSP
grid calibration immediately risks looking like calibration chase.

G6-c work has a different role:

1. It does not depend on random-CSP threshold-window tuning.
2. It clarifies how structural balance relates to existing stability theory.
3. It helps choose future G4 non-CSP anchors, such as queueing, reliability,
   branching, or population dynamics.

The intended order is:

```text
threshold-local Route A protocol
-> G6-c formal mapping
-> choose Exp43b / Exp44b / non-CSP anchor with better criteria
```

## 3. Scope lock

The first G6-c draft should cover exactly three items.

### 3.1 Discrete-time Foster-Lyapunov embedding

Setting:

- discrete time \(t \in \mathbb N\);
- process \(X_t\);
- nonnegative Lyapunov / load function \(W\);
- structural load \(Z_t := W(X_t)\);
- net action \(a_t := Z_{t+1}-Z_t\).

Then:

\[
  A_n = \sum_{t<n} a_t = Z_n-Z_0.
\]

If

\[
  \mathbb E[W(X_{t+1})-W(X_t)\mid X_t]\le -\epsilon
\]

outside a small / stable set, then in structural-balance notation:

\[
  \mathbb E[a_t\mid X_t]\le -\epsilon.
\]

This is the recovery-tendency regime of the structural balance law.

### 3.2 Exponential maintenance coordinate

Define a relative maintenance coordinate:

\[
  R_t := e^{-Z_t}.
\]

Then:

\[
  R_{t+1}
  =
  R_t e^{-a_t}.
\]

This is the same algebraic shape as the local structural balance identity.

If one wants the two-flow sign convention of Paper §2.2, decompose:

\[
  \ell_t := (Z_{t+1}-Z_t)^+,
  \qquad
  g_t := (Z_t-Z_{t+1})^+,
  \qquad
  a_t=\ell_t-g_t.
\]

The one-step Lyapunov increment is then exactly the net loss-minus-repair
action.

### 3.3 Queueing positive / overload regimes

For a fluid queue skeleton:

\[
  Z_n = Z_0 + n(\lambda-\mu),
\]

where \(\lambda\) is arrival rate and \(\mu\) is service rate.

Then:

- \(\lambda \le \mu\): \(a_t \le 0\), maintenance / recovery tendency;
- \(\lambda > \mu\): \(a_t > 0\), overload accumulation;
- finite threshold \(B\): \(Z_n \ge B\) gives a hitting-time / collapse
  reading.

This corresponds to the existing Lean skeleton:

```text
lean/Survival/QueueStability.lean
```

That file is currently a deterministic fluid skeleton, not a reflected
stochastic queue theorem.

## 4. What counts as G6-c here

For this work item, G6-c means:

```text
An existing drift / stability calculus can be embedded into the structural
balance variables with theorem assumptions preserved.
```

It does not mean:

```text
Structural balance law replaces queueing theory.
```

The embedding is meaningful because it transfers the algebraic role of drift:

| Existing theory | Structural balance |
|---|---|
| Lyapunov load \(W(X_t)\) | structural load \(Z_t\) |
| increment \(W(X_{t+1})-W(X_t)\) | net action \(a_t\) |
| negative drift | recovery / maintenance tendency |
| positive drift | overload / collapse tendency |
| stability theorem assumptions | inherited assumptions, not removed |

## 5. Non-goals

The first G6-c draft should not attempt:

1. non-Markov Lyapunov functionals;
2. continuous-time generators;
3. PDE / infinite-dimensional systems;
4. stochastic thermodynamics path-ratio embedding;
5. full proof of positive recurrence from first principles;
6. replacement of Foster-Lyapunov theorem assumptions;
7. claim that all structural persistence problems are Markov-chain stability
   problems.

Those are later G6-c iterations if needed.

## 6. Deliverables

Minimum deliverable:

1. a prose draft section or supplement note that states the embedding;
2. a correspondence table;
3. a theorem-assumption inheritance warning;
4. a small queueing/fluid example tied to `QueueStability.lean`;
5. a short non-claim list.

Optional Lean deliverable:

1. add a lightweight `LyapunovBalanceEmbedding.lean` file;
2. define `Z`, `a`, `A`, `R`;
3. prove `A_n = Z_n - Z_0`;
4. prove `R_{t+1} = R_t * exp (-a_t)`;
5. connect deterministic queue excess demand to this notation.

If any Lean file is edited, run:

```bash
cd lean && lake build
```

## 7. Suggested draft structure

```text
Title:
  構造収支律と Foster-Lyapunov drift の形式的埋め込み

§1 Why this is G6-c, not analogy
§2 Minimal embedding: Z_t, a_t, A_n, R_t
§3 Drift regimes: negative / zero / positive
§4 Queueing fluid skeleton
§5 Assumptions inherited from the original theorem
§6 What this does and does not prove
§7 Relation to future non-CSP anchors
```

## 8. Re-entry to Route A

After this G6-c scope is drafted, Route A can be revisited under the
threshold-local protocol. The preferred re-entry condition is:

```text
G6-c draft completed
AND threshold-local protocol v1 accepted
AND a fresh Exp43b / Exp44b preregistration exists
```

Until then, Exp43 and Exp44 remain calibration histories, not validation
evidence.
