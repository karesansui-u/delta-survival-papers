# Universality Program — Next Decisions

Status: design draft for review after Exp.42.

## 1. Phase Assessment

The program has passed a real phase transition, but not a victory condition.

The core theory and the LLM scope-as-repair domain are now load-bearing:

- the Paper 1/2 formal core and the signed-kernel / set-valued dynamics layer
  are stable;
- Exp.40 showed that scope-aware coding beats a quality-blind contradiction
  baseline prospectively;
- Exp.42 decomposed the scoped effect and showed that the result is not well
  explained by explicit instruction-following alone;
- row-level Exp.42 analysis specified the main repair mechanism as
  attribution-as-repair.

The accurate public characterization is:

```text
Core theory is consolidated. The LLM domain has entered verification mode.
Route A and the formal tendency upgrade remain decisive open gates.
```

Avoid public wording such as "the theory is proven" or "universality is
established". The stronger claim should wait for Mixed-CSP and at least the M1
/ M2 formal gap work.

## 2. Current Status by Track

| Track | Phase | Current state | Next decisive signal |
|---|---|---|---|
| Core theory | Consolidation | Stable theorem vocabulary and Lean anchors | Only wording / mapping refinements |
| LLM domain | Verification | Exp.40 + Exp.42 support scope-as-repair and attribution-as-repair | Exp.41 width check |
| Route A / CSP | Empirical gate | Pre-registration drafted; implementation not run | Mixed-CSP `L_plus_n < raw_plus_n` log loss |
| Formal tendency | Planned execution | Formal plan exists; gap map not written | M1 gap map, then SAT concrete M2 |
| External reception | Open | Internal reproducibility and OSF available | Independent review / replication |

## 3. Three Remaining Gates

### Gate 1: Mixed-CSP Feasibility Test

Purpose:

```text
Show that drift-weighted L is a better feasibility coordinate than raw count
outside the LLM arithmetic setting.
```

Primary success:

```text
L_plus_n held-out log loss < raw_plus_n held-out log loss
```

Strong support:

```text
L_plus_n improves held-out log loss by at least 10%
and does not lose to cnf_count_plus_n.
```

Theory-pure support:

```text
first_moment = n log 2 - L beats raw_plus_n.
```

Interpretation if successful:
  Route A gains an empirical universality-class anchor. The claim is still not
  "same coefficient everywhere"; it is that the pre-specified structural loss
  coordinate carries predictive information beyond unweighted baselines.

Interpretation if failed:
  The theory is not refuted globally, but Route A universality is weakened.
  The likely failure branches are:

- raw count is enough in the SAT/NAE grid;
- finite-size threshold effects dominate first-moment drift;
- CNF encoding size explains feasibility better than semantic drift;
- the chosen density grid is too far from the informative transition region.

### Gate 2: Exp.41 Width Check

Purpose:

```text
Show that Exp.40 scoped > structural is not gpt-4.1-mini-specific.
```

Primary success:

```text
scoped > structural in both primary new models.
```

Interpretation if successful:
  Paper 3 becomes substantially more defensible as a model-width claim.

Interpretation if failed:
  Scope-as-repair remains supported in gpt-4.1-mini but loses width. Inspect
  whether failures are diagnostic/task-validity failures, structural_anchor
  insensitivity, or true absence of scoped repair.

### Gate 3: Formal Target Theorem 4

Purpose:

```text
Upgrade balance-law language to reusable tendency theorem language.
```

M1 output:

```text
lean/UNIVERSALITY_GAP_MAP.md
```

M2 success:

```text
SAT state-dependent clause exposure is mapped to the target tendency schema.
```

Interpretation if successful:
  Formal law-strength improves independently of the empirical program.

Interpretation if delayed:
  This is not an empirical failure. It means the current Lean anchors require
  more bridge lemmas before the theorem can be stated at the desired level.

## 4. Recommended Execution Order

Short horizon:

1. Finalize Mixed-CSP implementation plan.
2. Run Exp.41 as the small-budget width check.
3. Implement Mixed-CSP generator, CNF encoder, solver wrapper, and analysis.
4. Start Lean M1 gap map in parallel.
5. Run Mixed-CSP pre-primary exact-one pilot if exact-one is still being
   considered for conditional primary promotion.
6. Freeze any updated primary-grid decision before primary Mixed-CSP data.
7. Run primary Mixed-CSP.

Rationale:

- Exp.41 is cheap and improves Paper 3 width.
- Mixed-CSP is the major empirical gate.
- Lean M1 is low monetary cost but can reveal hidden formal work early.

Estimated timelines, assuming no unexpected gates:

| Step | Estimate |
|---|---:|
| Exp.41 primary run | ~2 hours, about $1 |
| Mixed-CSP smoke test | ~1 day |
| Lean M1 gap map | 1-2 weeks, $0 |
| Mixed-CSP exact-one pilot, if used | ~1 day, $0 |
| Mixed-CSP primary grid | ~2-5 days depending on solver runtime |
| Analysis integration | ~1 week |

## 5. Public Wording

Recommended:

```text
The core framework is consolidated, and the LLM scope-as-repair domain now has
prospective and row-level support. The next stage tests empirical universality:
whether the same L-normalization methodology beats raw baselines in Mixed-CSP,
and whether formal balance laws can be lifted into reusable tendency theorems.
```

Avoid:

```text
Universality is established.
The theory is proven.
The remaining work is only examples.
```

## 6. Decision Table

| Result pattern | Interpretation | Next action |
|---|---|---|
| Exp41 passes, Mixed-CSP passes, M1 gap small | Verification phase across LLM + Route A | integrate into universality paper / update program status |
| Exp41 fails, Mixed-CSP passes | LLM width limited, Route A strong | keep Paper 3 model-specific, develop Route A |
| Exp41 passes, Mixed-CSP fails | LLM scope theory strong, Route A not yet generalized | redesign Route A around cross-family or threshold-adjacent grids |
| M1 gap large | Formal tendency upgrade delayed | document gap; keep empirical claims separate |
| CNF baseline beats L in Mixed-CSP | Encoding-size explanation stronger than semantic drift | report as weakening; redesign with native evaluator or alternate domain |
