# Cross-Domain Sign-Convention Table

Status: internal consistency note. This is not new evidence and not a theorem.

Purpose:

Check whether the current anchors really use one sign convention, or whether
the program is silently flipping meanings from domain to domain.

The main convention under audit is:

\[
  b_t=\ell_t-g_t.
\]

Intended reading:

- \(\ell_t \ge 0\): one-step loss / damage / obstruction / collapse pressure;
- \(g_t \ge 0\): one-step repair / compensation / service / maintenance;
- \(b_t>0\): net overload / net damage / collapse tendency;
- \(b_t<0\): net recovery / repair-dominant tendency.

## 1. Anchor Table

| Anchor | Maintained quantity | \(\ell_t\) | \(g_t\) | What \(b_t>0\) means | What \(b_t<0\) means | Transform / reversal used? | Claim strength |
|---|---|---|---|---|---|---|---|
| Mixed-CSP / Bernoulli-CSP | feasible assignment mass or count proxy | bad-event exposure loss | 0 | cumulative feasibility loss / collapse pressure | not used in loss-only form | monotone log-ratio / first-moment coordinate, no sign reversal | Route A primary |
| Exp43c q-coloring | first-moment feasible-coloring count proxy | edge-exposure loss \(L\) or its normalized first-moment coordinate | 0 | stronger pressure against q-colorability | not used in loss-only form | monotone first-moment transform, no sign reversal | Route A primary |
| Queueing / Foster-Lyapunov | load / Lyapunov quantity \(Z_t\) | arrivals / excess demand positive part | service / compensating drift positive part | overload accumulation | recovery / service-dominant drift | positive-part decomposition only, no sign reversal | G6-c algebraic embedding + G4 v1 primary anchor |
| Serial reliability | survival mass via \(Z_t=-\log S_t\) | hazard / failure exposure increment | 0 | reliability loss | not used in loss-only form | monotone \(-\log\) transform, no sign reversal | G4 v1 loss-only control |
| Constant-fraction decay | remaining mass via negative log transform | decay increment | 0 | further decay / structural shrinkage | not used in loss-only form | monotone \(-\log\) transform, no sign reversal | G4 v1 loss-only control |
| Repair-maintenance balance | accumulated damage \(D_t\) or remaining margin \(M_t\) | damage flow \(d_t\) | repair / maintenance flow \(g_t\) | net damage accumulation, threshold approach | repair-dominant recovery, larger remaining margin | equivalent switch between damage and margin views, no sign reversal | G4 v2 algebraic anchor |
| Backblaze loss-only branch | drive-health / failure-risk proxy | SMART-derived degradation / exposure proxy | 0 | higher future failure tendency | not used in primary claim | observational proxy only, no sign reversal | G4 loss-only observational |
| Route C scope-repair | maintained answer-consistency / eligible reasoning structure | contradiction load / conflicting evidence pressure | scope / attribution / repair prompt structure | contradiction-dominant confusion pressure | repair-dominant prompt framing | operational / proxy reading only, no sign reversal | Route C observational |

## 2. What The Table Shows

The encouraging result is simple:

```text
No current anchor requires a hidden sign reversal to make b_t > 0 mean
"worse for the maintained structure."
```

There are monotone transforms, but they are visible transforms:

- \(-\log S_t\) for survival / reliability;
- first-moment / log-ratio coordinates for Route A;
- damage-vs-margin dual views in repair-maintenance.

These are not covert sign flips. They keep the same order:

```text
more loss / worse structure -> larger Z_t or larger cumulative B_n
```

## 3. Where Caution Is Still Needed

Not all anchors are equally strong.

| Anchor type | Main caution |
|---|---|
| Route A loss-only anchors | \(b_t<0\) is usually not exercised, because \(g_t=0\) in the primary reading |
| Observational anchors | \(\ell_t\) and \(g_t\) are often proxies rather than directly measured flows |
| Route C LLM anchors | the maintained structure is semantic / task-structural, not a physically measured quantity |
| Damage-vs-margin dual views | one must state whether \(Z_t\) means accumulated damage or remaining margin before reading the sign |

So the sign table does not show that every anchor is equally literal. It shows
that the literal and proxy anchors at least point in the same direction.

## 4. Why This Matters

This note is aimed at one specific objection:

```text
Is the program a unified language, or only a glossary that renames different
quantities case by case?
```

The table helps because it shows one invariant:

```text
Across current anchors, positive net action means deterioration of the
maintained structure, not a domain-specific arbitrary direction.
```

That is weaker than a theorem-transfer result, but stronger than mere
terminological similarity.

## 5. Current Verdict

Current verdict:

```text
The present anchors satisfy sign consistency at the level required for a
serious unified-language candidate. The remaining open issue is not hidden sign
reversal, but whether the preserved content is nontrivial enough and whether
rival frameworks already do the same work more directly.
```

This means F1 is not closed forever, but it is in better shape than the more
dangerous F4 rival-framework question.

## 6. Next Use

This table is best used together with:

- `analysis/falsification_and_rival_frameworks.md`
- `analysis/ldp_rate_function_comparison.md`
- `analysis/current_evidence_map.md`

It is a consistency artifact, not a standalone claim source.

## 7. Non-Claims

This note does not claim:

1. every anchor is equally literal or equally strong;
2. sign consistency proves universality;
3. observational proxies are as clean as algebraic embeddings;
4. theorem content is preserved merely because sign direction is preserved.

It claims only:

```text
The current successful and active anchors do not appear to rely on hidden sign
reversal, which removes one low-level objection to the unified-language claim.
```
