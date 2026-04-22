# Universality Program — Next Decisions

Status: program memo after Exp.41, Mixed-CSP primary, and Lean M1.

## 1. Phase Assessment

The program has passed a real phase transition, but not an independent
replication / universal-law victory condition.

The core theory and the LLM scope-as-repair domain are now load-bearing:

- the Paper 1/2 formal core and the signed-kernel / set-valued dynamics layer
  are stable;
- Exp.40 showed that scope-aware coding beats a quality-blind contradiction
  baseline prospectively;
- Exp.42 decomposed the scoped effect and showed that the result is not well
  explained by explicit instruction-following alone;
- row-level Exp.42 analysis specified the main repair mechanism as
  attribution-as-repair;
- Exp.41 confirmed the preregistered `scoped > structural` width claim in
  both primary models, while also showing that `subtle` / `structural`
  ordering is model-dependent.
- the Mixed-CSP primary test showed that drift-weighted `L_plus_n` beats raw
  count + `n` for SAT/NAE feasibility out-of-sample;
- Lean M1 showed that the expectation-level target theorem 4 / law-of-tendency
  schema is already formally accessible through existing theorems and only
  needs reader-facing mapping.

The accurate public characterization is:

```text
Core theory is consolidated. LLM scope repair and Route A Mixed-CSP feasibility
now have prospective support, and the expectation-level formal tendency schema
is mapped to existing Lean theorems. Independent replication and optional width
extensions remain open.
```

Avoid public wording such as "the theory is proven" or "universality is
established". The stronger claim should wait for independent review /
replication and, if needed, later theorem-wrapper polish.

## 2. Current Status by Track

| Track | Phase | Current state | Next decisive signal |
|---|---|---|---|
| Core theory | Consolidation | Stable theorem vocabulary and Lean anchors | Only wording / mapping refinements |
| LLM domain | Verification | Exp.40 + Exp.42 support scope-as-repair and attribution-as-repair; Exp.41 width passed | Model-dependent failure-mode follow-up only if needed |
| Route A / CSP | Mixed-CSP validated; q-coloring exploratory; Exp44 drafted | Mixed-CSP official primary passed: `L_plus_n` log loss 0.0970 < `raw_plus_n` 0.7525. Exp43 q-coloring is pilot calibration only; pilot_v1/v2 did not pass the freeze gate. Exp44 Cardinality-SAT draft exists but is not frozen | Exp43b fine-grid preregistration or Exp44 harness / pilot |
| Formal tendency | M1 completed | Expectation-level target theorem 4 formally accessible via existing theorems; M2-A mapping-only fixed | Optional M2-B wrapper if paper needs named theorem aliases |
| External reception | Open | Internal reproducibility and OSF available | Independent review / replication |

## 3. Resolved Gates And Next Options

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

Status:

```text
Passed: 0.0970 < 0.7525 on the official 12,000-row primary run.
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

Status:

```text
Passed: first_moment log loss 0.1489 < raw_plus_n 0.7525.
Encoding guardrail also passed: L_plus_n 0.0970 <= cnf_count_plus_n 0.1010.
```

Interpretation:
  Route A gains an empirical universality-class anchor. The claim is still not
  "same coefficient everywhere"; it is that the pre-specified structural loss
  coordinate carries predictive information beyond unweighted baselines.

### Gate 2: Exp.41 Width Check

Purpose:

```text
Show that Exp.40 scoped > structural is not gpt-4.1-mini-specific.
```

Status:

```text
Passed: scoped > structural in both primary new models.
```

Interpretation:
  Paper 3 becomes substantially more defensible as a model-width claim.
  The invariant is scoped protection, not a fixed subtle/structural ordering.

Unexpected secondary finding:
  `gemini-3.1-flash-lite-preview` inverted the preregistered secondary
  `subtle >= structural` direction (`subtle = 0.40`, `structural = 0.47`).
  Row-level inspection shows Gemini took the injected wrong value on 14/18
  subtle failures but on 0/16 structural failures. This does not affect the
  primary decision, because `scoped > structural` passed on both primary
  models, but it should remain recorded as evidence that self-referential
  paradox resistance and alternate-source uptake are model-dependent.

### Gate 3: Formal Target Theorem 4

Purpose:

```text
Upgrade balance-law language to reusable tendency theorem language.
```

M1 output:

```text
lean/UNIVERSALITY_GAP_MAP.md
```

Status:

```text
Passed at expectation level via M1 mapping.
```

M1 conclusion:

```text
Target theorem 4 is formally accessible at the expectation level through
existing Lean theorems. M2-A mapping-only is sufficient; M2-B thin wrappers are
optional reader-facing polish.
```

Interpretation:
  Formal law-strength improves independently of the empirical program. The
  remaining caution is schema separation: high-probability stopped-collapse
  requires explicit concentration / margin assumptions and should not be folded
  into the expectation-level theorem.

## 4. Recommended Next Order

Short horizon:

1. Keep the M1 conclusion synchronized across the supplement / README /
   program memo.
2. Decide whether the paper needs optional M2-B reader-facing Lean wrapper
   theorem names.
3. Keep M resource operationalization as a supplement-level mapping layer, not
   as the next main-theory paper.
4. Review and polish the structural balance law / 構造収支律 draft as the next
   core-theory candidate. §1-8 now exist at
   `v2/5_構造持続の収支法則と崩壊傾向.md`; current control memo:
   `analysis/structural_balance_law_draft_plan.md`.
5. Treat q-coloring and Cardinality-SAT as optional Route A width extensions,
   not as required gates.

Rationale:

- Mixed-CSP and Exp.41 are now complete and passed.
- Lean M1 is now complete and reduced the formal gate to mapping / wording.
- The remaining work is no longer a hidden core-definition gate; it is
  propagation, optional wrappers, structural-balance-law review / freeze,
  width extension, and external replication.

Estimated timelines, assuming no unexpected gates:

| Step | Estimate |
|---|---:|
| M1 propagation to public docs | 30-60 min |
| Optional M2-B wrapper, if needed | 1-2 hours + `lake build` |
| M operationalization supplement cleanup | 30-60 min |
| Structural balance law §1-8 review pass | 1 focused session |
| Exp43 q-coloring preregistration draft review / freeze | 1 focused session |
| Optional q-coloring / Cardinality-SAT design | 1 focused session |

Route A extension discipline is recorded separately in
[`route_a_extension_map.md`](route_a_extension_map.md). In short, Mixed-CSP
has now passed; q-coloring and Cardinality-SAT are safe post-Mixed-CSP
extensions. XOR-SAT, LDPC decoder performance, SAT chain v2.0, and bootstrap
percolation should not be promoted as primary Route A empirical anchors.

The current Exp43 draft is
`v2/data/exp43_qcoloring_preregistration_draft.md`.
It is draft-only and must be reviewed / frozen before primary data generation.
The pilot harness lives at `analysis/exp43_qcoloring/`. Smoke, pilot_v1, and
pilot_v2 have run locally. Pilot_v1 was infrastructure-clean but failed the
freeze gate; pilot_v2 solved the timeout issue but still failed because q=4 and
q=5 each had only one informative rho band. See
`analysis/exp43_qcoloring/phase_status.md`,
`analysis/exp43_qcoloring/pilot_v1_addendum.md`, and
`analysis/exp43_qcoloring/pilot_v2_summary.md`.

Exp43 is therefore in exploration / pilot calibration, not validation. Pilot
data are not theory-confirming primary evidence. Primary q-coloring data must
not be generated from the current grid.

Exp44 Cardinality-SAT now has a draft preregistration at
`analysis/exp44_cardinality_sat/preregistration_draft.md`. It is a draft-only
Route A width-extension design using heterogeneous cardinality constraints. No
Exp44 primary data should be generated until its freeze checklist is complete.

## 5. Public Wording

Recommended:

```text
The core framework is consolidated. LLM scope repair, model-width replication,
and Mixed-CSP feasibility now support structure-aware coordinates over
quality-blind / raw baselines. Lean M1 maps the expectation-level tendency
schema to existing verified theorems. This supports a Level 2 universality
candidate, while independent replication remains necessary before any universal
law declaration.
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
| Exp41 passed, Mixed-CSP passed, M1 mapping-only sufficient | Verification phase across LLM + Route A + formal expectation-level tendency | integrate into universality paper / update program status |
| Optional M2-B wrapper added | Reader-facing theorem names improve | cite wrappers in supplement; no new empirical claim |
| Exp43b q-coloring or Exp44 Cardinality-SAT passes later | Route A width expands | update Route A extension map and finite-CSP supplement |
| independent replication arrives | Social proof strengthens | consider stronger universality wording |
