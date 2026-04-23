# Falsification and Rival-Framework Stress Test

Status: working stress-test memo, not a new evidence source.

Purpose:

This memo records how the structural persistence / structural balance-law
program could still be overturned or substantially weakened after several
domain anchors succeed. Its role is to prevent the program from drifting into
an unfalsifiable "unified language" that can always reinterpret failures as
domain-specific problems.

The memo should be read together with:

- `analysis/current_evidence_map.md`
- `v2/5_構造持続の収支法則と崩壊傾向.md` §7-8
- `v2/補論_構造持続写像の標準手順.md`
- `analysis/g6c_foster_lyapunov_embedding_draft.md`
- `v2/補論_構造収支律とFoster-Lyapunovドリフトの形式的埋め込み.md`
- `analysis/ldp_rate_function_comparison.md`

## 1. Core Risk

The program becomes scientifically weak if it can always say:

```text
The domain prediction failed, but the structural-balance language still applies.
```

That move would convert the theory from a falsifiable framework into a
retrospective vocabulary. The current Route A / B / C discipline, preregistered
baselines, non-claim lists, and G6-a/b/c hierarchy are designed to prevent that
failure mode. This memo adds an explicit stress test for the remaining risks.

The current one-line status is:

```text
The program is a stronger universal-law candidate than before, but it is not
yet a universal law. It remains vulnerable to translation inconsistency,
non-preservation of predictive content, scope overreach, rival-framework
subsumption, and practical redundancy.
```

## 2. Five Ways To Overturn Or Weaken The Program

| ID | Defeat mode | What would count as defeat | Current defense | Next needed artifact |
|---|---|---|---|---|
| F1 | Translation / sign inconsistency | The same symbol, especially \(a_t\), \(\ell_t\), \(g_t\), \(A_n\), or \(R_t\), has incompatible sign or semantic meaning across anchors | G6-c queueing and G4 v2 repair-maintenance keep \(a_t=\ell_t-g_t\) / overload-positive convention explicit | Cross-domain sign-convention table |
| F2 | Prediction / theorem content not preserved | Translation preserves notation but not nontrivial predictions, inequalities, thresholds, or theorem assumptions | Exp43c and Mixed-CSP test prediction coordinates; G6-c preserves algebraic identities | Non-triviality / theorem-transfer score per domain |
| F3 | Scope overreach / silent systems | The theory claims to cover dynamical structure generally but cannot express phase transitions, cycles, heavy-tail criticality, or static structures | Paper 5 §8 and Route A/B/C already limit claims | Catalog of systems where the theory is intentionally silent |
| F4 | Rival framework subsumption | Large deviation theory, free-energy / stochastic thermodynamics, contraction analysis, or Lyapunov drift calculus does the same work with less extra vocabulary and more predictions | Paper 5 §7 handles thermodynamics, Lyapunov, control, and information theory; `analysis/ldp_rate_function_comparison.md` opens the LDP / rate-function stress test | Extend to free-energy / contraction comparison if needed |
| F5 | Practical redundancy | The translation is correct but less useful than reading each domain theory directly | Evidence map and Route classification reduce overclaim but do not prove usefulness | Reader-facing teaching / translation-efficiency document |

These are not all equally urgent. F4 is the most dangerous near-term
theoretical risk, because it can defeat the program without any empirical
failure. F1 and F3 are easiest to address cleanly. F2 is important but requires
a more formal transfer criterion. F5 is an adoption / usefulness risk and is
best handled after the theoretical scope is stable.

## 3. F1: Translation And Sign Consistency

### Failure Pattern

The program is weakened if different domains require incompatible readings of
the same structural-balance variables. The most important convention is:

\[
  a_t = \ell_t - g_t.
\]

The intended sign convention is:

| Quantity | Intended cross-domain meaning |
|---|---|
| \(\ell_t \ge 0\) | one-step structural loss, damage, obstruction, load, or bad-event action |
| \(g_t \ge 0\) | one-step compensation, repair, service, support, or maintenance action |
| \(a_t > 0\) | net overload / collapse tendency / damage accumulation |
| \(a_t = 0\) | balance / maintenance tendency at the chosen coarse scale |
| \(a_t < 0\) | recovery / repair-dominant tendency |
| \(A_n=\sum_{t<n}a_t\) | cumulative net action |
| \(R_t=e^{-Z_t}\) or \(m(V_t)/m(V_0)\) | relative maintenance / feasible-structure ratio |

If an anchor can only be made to fit by reversing these signs ad hoc, or by
choosing \(Z_t\) after observing the desired conclusion, then the anchor should
be demoted. If multiple anchors require mutually incompatible sign conventions,
the "unified language" claim fails.

### Current Defense

- Queueing / Foster-Lyapunov:
  \(a_t\) is queue load increment or arrival-minus-service in the queue wrapper.
  Positive \(a_t\) means overload accumulation.
- Repair / maintenance:
  \(a_t=d_t-g_t\). Positive \(a_t\) means net damage accumulation.
- Route A bad-event CSP:
  \(\ell_t\) is bad-event exposure loss. In loss-only mode, \(g_t=0\) and
  \(A_n\) is cumulative structural loss.
- Branching processes were deferred partly because the "population increases"
  reading can invert the naive sign convention unless the maintained structure
  is fixed carefully.

### Required Next Test

Create a sign-convention table for all current anchors:

```text
anchor, Z_t / maintained quantity, ell_t, g_t, a_t sign,
what a_t > 0 means, what a_t < 0 means, whether any sign reversal is used.
```

Passing condition:

```text
No anchor uses a hidden sign reversal. Any domain requiring a non-obvious
monotone transform must state that transform before the conclusion is read.
```

## 4. F2: Prediction / Theorem Preservation

### Failure Pattern

The theory is weakened if translating a domain into structural-balance notation
only preserves superficial algebra, while nontrivial predictions or theorem
content disappear.

Example failure modes:

- a classical theorem becomes a tautology after translation;
- a nontrivial inequality loses its assumptions;
- a prediction becomes true only because the target variable was chosen after
  observing the outcome;
- a Route C observational signal is described with Route A theorem strength.

### Proposed Transfer Score

Use the following score when adding or auditing an anchor:

| Score | Meaning | Example |
|---|---|---|
| T0 | Vocabulary only | Same words, no preserved equation |
| T1 | Sign correspondence | \(a_t>0\) / \(a_t<0\) has the right qualitative direction |
| T2 | Pathwise identity preserved | \(A_n=Z_n-Z_0\), \(D_n=D_0+\sum(d_t-g_t)\), or \(m(V_n)=m(V_0)e^{-A_n}\) |
| T3 | Classical theorem assumptions preserved | Existing theorem can be read through the structural variables without dropping assumptions |
| T4 | Predictive content preserved prospectively | Frozen structural coordinate beats preregistered baselines or transfers across a held-out family |

Current examples:

- G6-c Foster-Lyapunov embedding: T2 / partial T3. It preserves the algebraic
  drift identity, but does not reprove positive recurrence.
- Exp43c q-coloring: T4 for a Route A empirical coordinate. It does not prove a
  q-coloring threshold theorem.
- G4 v2 repair-maintenance Lean skeleton: T2. It gives finite-prefix algebra
  and repair dominance over damage-only, but not an optimal maintenance theorem.
- G4 v2 operational pilot draft: not scored yet. It remains observational until
  a dataset is ranked, frozen, and tested.

Passing condition for "unified language" strength:

```text
At least one non-CSP anchor should reach T3, and at least one independent
empirical anchor should reach T4 without sharing the same data-generation
family as the CSP anchors.
```

## 5. F3: Systems Where The Theory Should Be Silent

The program should not claim that every dynamical or structural phenomenon is
best described by a scalar loss-repair balance. The following systems should be
treated as scope tests, not as automatic failures.

| System type | Why structural balance may be silent | Correct program response |
|---|---|---|
| Critical phase transitions | Singular behavior, order-parameter discontinuity, symmetry breaking, or critical exponents may be the main object, not monotone loss / repair | Do not claim to explain critical exponents unless a concrete order parameter and measure are fixed |
| Hopf bifurcation / limit cycles | \(a_t\) may oscillate and \(A_n\) may remain bounded while the important structure is a periodic orbit | Treat as outside finite-prefix collapse / recovery unless a maintained cycle basin is pre-fixed |
| Self-organized criticality / heavy tails | Mean drift can be misleading; tail events and avalanche distributions carry the main structure | Require tail / large-deviation layer before making structural-balance claims |
| Static complexity classes | No natural time-indexed \(Z_t\), \(a_t\), or \(A_n\) may exist | Do not force into Route A/B/C unless an exposure or reduction path is pre-fixed |
| Multi-attractor systems without a chosen target | "Maintenance" depends on which attractor or basin is treated as the target structure | Require target basin / maintained structure to be fixed before applying the theory |

This catalog is not a retreat. It is a falsifiability guardrail:

```text
If the theory claims these systems without adding the missing structure, it is
overreaching. If it explicitly stays silent, the boundary is healthy.
```

## 6. F4: Rival Framework Subsumption

This is the most urgent theoretical risk.

The program loses independent-theory status if an existing unifying framework
does the same work, with fewer operational choices and stronger predictions.

### 6.1 Large Deviation Theory

Risk:

```text
Structural loss \(L\), exponential maintenance \(e^{-L}\), Chernoff-KL exits,
and finite-horizon collapse bounds may be read as special cases of rate-function
calculus.
```

Why this is dangerous:

- Route A already uses Chernoff / KL / first-moment language.
- \(R_t=e^{-Z_t}\) looks like an exponential-rate coordinate.
- LDP handles rare events, threshold windows, tail behavior, and some phase-like
  phenomena more naturally than a scalar balance law.

Possible defense:

```text
Structural balance law is not primarily a new tail-asymptotic theory. Its
distinctive content is the operational discipline:

1. pre-fixed maintained structure \(V\);
2. pre-fixed measure \(m\) or path measure;
3. explicit loss / repair split \(a_t=\ell_t-g_t\);
4. Route A/B/C strength separation;
5. preregistered baseline comparisons for empirical anchors.
```

Dedicated comparison note:

```text
analysis/ldp_rate_function_comparison.md
```

The current position there is:

```text
Route A is built on classical exponential-rate machinery. Structural balance
does not replace LDP; it supplies an operational discipline for choosing,
testing, and limiting the use of those rate coordinates across domains.
```

Remaining next work:

```text
If this line is promoted into the main paper, add an explicit LDP /
rate-function row to Paper 5 §7.8 and keep the wording as anti-overclaim
calibration, not as a universal-law claim.

Then decide whether free-energy / stochastic thermodynamic path ratios or
contraction analysis deserve similarly focused comparison notes.
```

Allowed outcome:

```text
It is acceptable if the theory is partly a disciplined operational interface to
LDP. The defeat occurs only if LDP supplies the same domain-selection,
loss/repair, Route-strength, and preregistration discipline with less extra
structure.
```

### 6.2 Free-Energy / Stochastic-Thermodynamic Frameworks

Risk:

```text
The balance law may be a rephrasing of free-energy input, entropy production,
or variational free-energy minimization.
```

Current status:

- Paper 5 §7 treats thermodynamics and non-equilibrium thermodynamics as
  G6-a / G6-b.
- The current program does not yet give a stochastic-thermodynamic path-ratio
  embedding.

Possible defense:

```text
The structural-balance language does not claim to replace thermodynamics.
It applies to pre-fixed maintained structures even when physical energy is not
the natural conserved or minimized quantity. Its value is cross-domain
operationalization, not thermodynamic depth.
```

Required next work:

```text
Pick one concrete stochastic-thermodynamic model if this route is pursued.
Do not compare against "thermodynamics" in general.
```

### 6.3 Contraction / Incremental Stability

Risk:

```text
If \(Z_t\) is just a distance-to-target or Lyapunov distance, then structural
balance may be a weak version of contraction analysis.
```

Current status:

- Foster-Lyapunov / queueing has a minimal algebraic G6-c embedding.
- The program has not yet compared against contraction metrics or incremental
  stability directly.

Possible defense:

```text
Contraction analysis is strongest when a natural metric and dynamics are given.
Structural balance is more modest: it asks whether a maintained structure,
measure, loss flow, and compensation flow can be pre-fixed and tested.
```

Required next work:

```text
Add contraction analysis to the G6 comparison table as either:

- G6-b correspondence, if only metric decrease is matched;
- G6-c, only if a concrete contraction theorem is embedded without weakening
  its assumptions.
```

### 6.4 Lyapunov / Drift Calculus

Risk:

```text
This is the closest existing-theory overlap. The structural balance law may be
only a restatement of Lyapunov drift.
```

Current defense:

- G6-c iteration 1 explicitly accepts the overlap and embeds the algebraic
  drift skeleton.
- The supplement states that positive recurrence and geometric ergodicity are
  not reproved.

Remaining weakness:

```text
If future non-CSP anchors are all Lyapunov-drift examples, then G4 becomes
coverage within one existing theory rather than heterogeneous-domain support.
```

Next step:

```text
Keep queueing / Foster-Lyapunov as the primary G6-c bridge, but ensure at least
one future non-CSP anchor is not merely another Lyapunov-drift restatement.
```

## 7. F5: Practical Redundancy

A theory can be correct and still unused.

The program is practically weakened if:

- each translation is longer than the original domain theory;
- no reader can learn a new domain faster through the structural-balance
  language;
- the language does not suggest new diagnostics, baselines, or experiments;
- the framework only renames existing quantities.

Current defense:

- Exp43c and Mixed-CSP show that theory-specified coordinates can outperform
  naive baselines.
- Route A/B/C prevents all examples from being claimed at equal strength.
- The G4 v2 operational pilot draft turns \(g_t\) into a measurable design
  problem rather than a metaphor.

Required later artifact:

```text
Write a short educational / onboarding note:

"Four stability problems in one structural-balance coordinate system."

It should show whether the language reduces the cognitive cost of reading
queueing, reliability, CSP feasibility, and maintenance logs.
```

This is not the most urgent scientific risk, but it matters for adoption.

## 8. Priority Order

Recommended next defensive work:

| Priority | Work item | Why |
|---|---|---|
| 1 | Rival-framework comparison, starting with LDP | Most likely intellectual defeat route |
| 2 | Scope / silence catalog | Prevents universal-language overreach |
| 3 | Sign-convention table | Low-cost, high-clarity internal consistency check |
| 4 | Theorem-transfer / non-triviality score | Separates notation from content |
| 5 | Educational translation-efficiency note | Adoption / usefulness defense |

Do not respond to this memo by only adding more domains. More anchors help only
if the translation remains consistent, predictive content is preserved, scope
boundaries are explicit, and rival frameworks do not already subsume the work.

## 9. Current Recommended Next Move

The LDP / rate-function comparison note has been opened:

```text
analysis/ldp_rate_function_comparison.md
```

The next clean move is:

```text
Create the F1 cross-domain sign-convention table.
```

Minimum contents:

1. anchor;
2. maintained quantity \(Z_t\) or \(V_t\);
3. \(\ell_t\);
4. \(g_t\);
5. what \(a_t>0\) means;
6. what \(a_t<0\) means;
7. whether any monotone transform or sign reversal is used;
8. claim strength (Route A/B/C or G6 level).

This is lower-risk than another empirical anchor and directly addresses the
"unified language or merely a glossary?" objection.

## 10. Non-Claims Of This Memo

This memo does not claim:

1. The structural-balance program is false.
2. Large deviation theory already subsumes the entire program.
3. Free-energy or contraction frameworks are better.
4. Four successful domains would establish a universal law.
5. Any single failed observational pilot would refute the core theory.
6. Scope boundaries are defeats.

It claims only:

```text
A universal-law candidate becomes stronger when it states how it could lose.
```
