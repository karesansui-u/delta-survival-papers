# Paper 5 Draft Plan

Status: review draft, not a main preprint.

Date: 2026-04-22

Working title:

```text
構造持続における資源項 M の操作的定式化
```

## 1. Purpose

Paper 1/2 mainly stabilized the loss side of the theory:

```text
L: cumulative structural loss
```

Paper 3/4 then showed two empirical domains where structure-aware coordinates
matter:

- Paper 3: unscoped contradictions and scope / attribution repair in inference.
- Paper 4: premise updates, dependency repair, and structural forgetting in
  continual learning.

Paper 5 should turn to the support side:

```text
M: effective maintenance / survival resource
```

The purpose is not to produce a complete theory of resources. The purpose is
to split the current scalar `M` into operational modes so that the theory can
make intervention-ranking predictions.

Core question:

```text
Why can two systems with similar L and similar raw resource stock R require
different interventions to remain viable?
```

## 2. Minimal Claim

The current scalar resource term should be treated as a coarse-grained
effective quantity:

```text
S = M_eff e^{-L}
```

Paper 5 proposes that `M_eff` is induced by internal persistence modes plus
external supply channels:

```text
M_int = (M_b^int, M_r^int, M_a^int)
M_x   = (M_{x->b}, M_{x->r}, M_{x->a})
```

where:

| Component | English | Japanese | Role |
|---|---|---|---|
| `M_b^int` | internal buffering / robustness capacity | 内在的な緩衝・耐性資源 | endure |
| `M_r^int` | internal recovery capacity | 内在的な回復・修復資源 | repair |
| `M_a^int` | internal adaptive capacity | 内在的な適応・再編資源 | reconfigure |
| `M_{x->b}` | externally supplied buffering | 外部供給された緩衝 | supply channel |
| `M_{x->r}` | externally supplied recovery / repair | 外部供給された修復 | supply channel |
| `M_{x->a}` | externally supplied adaptation | 外部供給された再編 | supply channel |

The components are not raw resource stocks. They are effective capacities
generated from raw resources under a target function and structure:

```text
M_j^int   = gamma_j^int(R, Sigma, F)
M_{x->j}  = gamma_{x->j}(R, Sigma, F)
M_tilde_j = A_j(M_j^int, M_{x->j}),  j in {b, r, a}
M_eff     = Phi(M_tilde_b, M_tilde_r, M_tilde_a)
```

Interpretation:

- `F`: the function to preserve;
- `Sigma`: the structure carrying that function;
- `R`: raw resource stock / material;
- `M_j^int`: internally available effective capacity in persistence mode `j`;
- `M_{x->j}`: externally supplied capacity for persistence mode `j`;
- `M_tilde_j`: effective mode after internal and external supply are combined.

This lets the theory state:

```text
R can be large while gamma_i(R, Sigma, F) is small.
```

That is the formal place for "there are resources, but they do not function as
maintenance capacity."

## 3. Relation To Existing Papers

### Paper 3

Paper 3 is mainly about the loss / repair boundary in inference:

- unscoped contradiction increases effective structural loss;
- scope marker and attribution reduce wrong-value uptake;
- external metabolism organizes contradiction histories across turns.

Paper 5 should read this as:

```text
scope / attribution repair is not merely more context.
It is a structuring operation that converts ambiguous conflict into usable
maintenance capacity.
```

Mapping:

| Paper 3 phenomenon | Paper 5 reading |
|---|---|
| scoped conflict repairs performance | local reduction of effective `L` |
| attribution-as-repair | minimal source-separation resource |
| external metabolism ON > OFF | `M_{x->r}`: repair supplied outside the base model |
| long-run stability under metabolism | repair capacity prevents unchecked loss accumulation |

### Paper 4

Paper 4 shows that parameter updates alone do not reliably repair dependency
structure:

- LoRA behaves more like overwrite than faithful accumulation;
- F-v2c improves dependency consistency by selectively refreshing descendants;
- F-multi preserves some old-task signal by spatial separation, but fidelity
  remains low.

Paper 5 should read this as:

```text
parameter adaptation is not the same as repair capacity.
```

Mapping:

| Paper 4 mechanism | Paper 5 reading |
|---|---|
| LoRA update | partial `M_a`, weak `M_r` |
| F-v2c dependency refresh | `M_{x->r}` applied along known dependency structure |
| F-multi adapter separation | `M_b` / `M_a` through representational separation |
| low retention fidelity | raw parameter capacity does not automatically become effective maintenance capacity |

## 4. First Target Domain

Default target domain:

```text
software / SaaS / continuously operated systems
```

Reason:

- `F`, `Sigma`, `R`, and `M_i` can be stated concretely;
- operational data can exist: incidents, commits, rollback, tests, MTTR;
- intervention modes are recognizable: capacity, rollback, failover, support;
- software is a strong Route C domain, not a forced Route A domain.

Two-level `F` definition:

Use a broad `F` for the paper framing:

```text
safe change continuity
```

Use a narrow `F` for the first empirical pilot:

```text
detecting and localizing change-introduced bugs before or shortly after release
```

Rationale:

- broad `F` keeps the theory aligned with software / SaaS as a maintained
  operational system;
- narrow `F` gives a tractable Route C validation target where `L_hat`, raw
  baselines, and outcomes can be compared directly.

Software mapping:

| Layer | Software interpretation |
|---|---|
| `F` | availability, correctness, safe change continuity |
| `Sigma` | dependencies, API contracts, data boundaries, monitoring, deployment path, rollback path, operational procedures |
| `R` | servers, cache, spare capacity, backup, team time, tooling |
| `L` | dependency breakage, configuration drift, hidden coupling, irreversible changes, monitoring gaps, operational divergence |
| `M_b` | redundant capacity, graceful degradation, queue / cache slack |
| `M_r` | rollback, restore, patch path, test repair, SRE response |
| `M_a` | failover, feature flags, architecture change, modular replacement |
| `M_{x->b}` / `M_{x->r}` / `M_{x->a}` | vendor support, managed service, external SRE / consultants, recorded by the mode they supply |

Important restriction on `M_a`:

```text
M_a includes architecture change only insofar as target function F is preserved.
Changes that redefine F are out of scope and belong to a separate analysis.
```

## 5. Main Prediction

The main prediction should be intervention ranking, not a full dynamic collapse
profile.

Minimal prediction:

```text
For systems with comparable L, comparable raw resources R, and comparable
scalar M_total, the effective intervention ranking depends on the composition
of M, not only on total R or scalar resource amount.
```

Software version:

```text
If a software system is high in M_b but low in M_r, then adding more buffering
capacity should be less effective than improving repair / rollback pathways.
```

Another software version:

```text
If M_r is adequate but M_a is weak, then local repair interventions should show
diminishing returns relative to adaptive reconfiguration interventions such as
feature flags, failover paths, or boundary redesign.
```

Baseline:

```text
M_total = sum_i q_i
```

or any model that treats resources as a single scalar.

The Paper 5 claim is that a mode-aware model can predict intervention orderings
that scalar-resource baselines cannot.

## 6. Candidate Empirical Route

This is optional and should be framed as future work unless the data are
already assembled.

Route C software pilot:

| Item | Candidate |
|---|---|
| Target function | safe change continuity, or bug detection / localization |
| Baseline predictors | LOC, cyclomatic complexity, churn, file count, raw incident count |
| Structure-loss proxy `L_hat` | boundary-crossing count, hidden dependency score, special-case density, rollback-impossibility rate, untested branch rate |
| Resource-mode predictors | rollback success, restore time, feature flag coverage, failover availability, vendor/support contract |
| Outcomes | change failure rate, escaped defects, MTTR, MTTD, rollback success, incident recurrence |
| Primary comparison | mode-aware model vs scalar-resource / raw-size baseline |

Validation protocol:

- use held-out projects or time-split windows;
- preregister predictors and outcomes before inspecting held-out outcomes;
- primary metrics: log loss or Brier score on the held-out set;
- secondary metric: intervention-ranking agreement, e.g. Kendall tau;
- report whether gains remain after controlling for raw size / churn baselines.

DeltaLint is separated from Paper 5's main validation. It may be discussed as
a related L-side / Paper 3 static-code extension, but it should not be used as
the load-bearing empirical anchor for the M-framework.

Safe wording:

```text
DeltaLint-like structural diagnostics may provide a practical proxy for
software structural loss in a separate L-side note. Paper 5 does not rely on
them as proof of the M-framework.
```

## 7. Mathematical Shape

Minimal static shape:

```text
M_j^int = gamma_j^int(R, Sigma, F)
M_{x->j} = gamma_{x->j}(R, Sigma, F)
M_tilde_j = A_j(M_j^int, M_{x->j})
M_eff = Phi(M_tilde_b, M_tilde_r, M_tilde_a)
S = M_eff e^{-L}
```

Assumptions for `gamma_i`:

- nonnegative;
- weakly monotone in relevant raw resource components;
- defined only relative to fixed `F` and `Sigma`;
- preregistered before outcome observation in empirical use.

Keep `Phi` conservative.

Recommended for the main paper:

- leave `Phi` as monotone but structured;
- discuss product, CES, and bottleneck forms as candidate families;
- treat sum / weighted sum as baselines, not as the theory's strongest form.

Representation-discipline question:

The Paper 5 memo contains a stronger possible route: under scale separability
and multiplicative Cauchy-type assumptions, a product-like form becomes
distinguished. This is useful, but it is not as nontrivial as Paper 1's
log-ratio uniqueness theorem because scale separability already leans heavily
toward product form. Treat it as representation discipline, not as the
load-bearing theorem of Paper 5.

Tentative decision (2026-04-22, reflected in `PAPER5_SECTION_1_2_DRAFT.md` §2.5):

```text
Include a short representation-discipline pointer in the main text at §2.5.
Show a one-paragraph correspondence to Paper 1 §3 log-ratio uniqueness, but
explicitly state that the strength is lower: product form is a candidate under
strong assumptions, not a universal consequence. Name product, CES, and
bottleneck forms as candidate families. Defer any full axiom list and proof to
a separate supplement or later note. Do not promote §2.5 to a standalone §3.
Keep Phi as a monotone aggregator in the remaining sections, and make the
intervention-ranking prediction robust to Phi choice.
```

Rationale:

- a one-paragraph spine prevents the paper from reading as a classification
  table without pretending the product form has Paper 1-level force;
- deferring proofs to a supplement keeps Paper 5 light and focused on
  intervention-ranking prediction;
- product form vs CES vs bottleneck remains a domain-specific empirical choice.

Robustness discipline:

```text
When normalizing M_i through q_i = rho_i(M_i), test whether the predicted
dominant mode or intervention ordering is stable under several reasonable
choices of rho_i.
```

Avoid making the dynamic claim primary:

```text
M_b high / M_r low implies cliff-like collapse
```

This is promising, but it requires time-dynamic assumptions. Place it as a
future prediction or secondary hypothesis.

## 8. Relationship To `N_eff^(0)` And `mu`

Paper 5 should not duplicate the existing supplement formula:

```text
S = N_eff^(0) * (mu / mu_c) * e^{-L}
```

It should reinterpret the scalar resource side.

Conservative mapping:

| Existing quantity | Paper 5 reading |
|---|---|
| `mu / mu_c` | closest to `M_b` / buffering margin |
| `N_eff^(0)` | initial option diversity, upstream of `M_a` but not identical |
| `M_r` | repair loop that was not separated in the scalar formula |
| `M_a` | capacity to reopen or reorganize option space |
| `M_{x->j}` | open-system external supply channel outside the closed-system scalar formula |

Important caution:

```text
Do not absorb static N_eff^(0) into M_a unless the domain actually regenerates
or reopens options through adaptation.
```

## 9. Non-Claims

Paper 5 should not claim:

- a complete universal resource theory;
- a universal value of `Phi`;
- that all domains use the same `M_i` measurement;
- that software evidence proves the theory;
- that `M_a` can rescue any target structure;
- that external support `M_{x->j}` is equivalent to autonomous robustness;
- a universal law declaration before independent replication.

## 10. Proposed Section Outline

### 1. Problem Setting

From loss-side theory to support-side operationalization.

### 2. Scalar `M` Is Too Coarse

Why "more resources" does not imply more maintenance capacity.

### 3. F / Sigma / R / M

Define `F`, `Sigma`, `R`, internal modes, and external supply channels.

### 4. Maintenance Modes And External Supply Channels

Internal modes `M_b^int`, `M_r^int`, `M_a^int`; external supply channels
`M_{x->b}`, `M_{x->r}`, `M_{x->a}`.

### 5. Software As The First Route C Domain

Map software / SaaS to `F / Sigma / R / M / L`.

### 6. Main Prediction: Intervention Ranking

Mode composition predicts which intervention should work first.

### 7. Baselines And Possible Empirical Protocol

Scalar resources, raw size, churn, LOC, complexity, etc.

### 8. Relation To Paper 3/4 And Existing Formula

Connect scope repair, external metabolism, LoRA/F-v2c/F-multi, `N_eff^(0)`,
and `mu`.

### 9. Limits And Future Work

Dynamic collapse profiles, q-coloring / other Route A extensions, independent
replication, and domain-specific measurement work.

## 11. Review Questions For The User

Before promoting this to a main preprint, decide:

1. Should the two-level `F` definition be fixed as broad framing (`safe change
   continuity`) plus narrow pilot (`change-introduced bug detection /
   localization`)?
   _Provisionally resolved by D1 (§12)._
2. Should DeltaLint be mentioned in Paper 5, or kept for a separate software
   Route C note?
   _Resolved by D6 (§12): keep it out of Paper 5's main validation; mention
   only as related L-side / Paper 3 static-code extension._
3. Should `Phi` remain abstract, or should product / CES / bottleneck forms be named
   in the main text?
   _Provisionally resolved by D2 (§12): named briefly at §2.5._
4. Should Paper 5 include four-domain comparison tables, or keep the first
   draft software-centered?
   _Resolved by D8 (§12): keep the first draft software-centered; four-domain
   comparison is future work._
5. Should external support be framed as a supply channel with an autonomy
   caveat from the start?
   _Provisionally resolved at `PAPER5_SECTION_1_2_DRAFT.md` §2.2: `M_x` is
   an externalization profile (`M_{x->b}`, `M_{x->r}`, `M_{x->a}`), not
   autonomous robustness._
6. Should product-form representation discipline be included in the main
   paper, or moved to a supplement / later note?
   _Reframed by D2 (§12): main text contains representation discipline, not a
   load-bearing product-form theorem._
7. Should validation use leave-one-project-out, time-split held-out windows, or
   both?
   _Provisionally resolved by D3 (§12): time-split primary, leave-one-project-out
   secondary, both preregistered._
8. Should DeltaLint baseline comparison be included in Paper 5, or split into
   an independent short Route C software note?
   _Resolved by D6 (§12): split into an independent note / preregistration.
   Paper 5 §6 remains a generic M-validation protocol._

## 12. Provisional Decisions

These decisions are provisional but strong enough to guide the current main-text
review drafts.

### D1. Two-Level `F`

Use the two-level `F` definition.

Main-paper framing:

```text
F = safe change continuity
```

First empirical pilot:

```text
F_pilot = detecting and localizing change-introduced bugs before or shortly
after release
```

Rationale:

- the broad `F` keeps Paper 5 connected to software / SaaS as an operational
  maintenance system;
- the narrow pilot gives a measurable Route C target;
- DeltaLint-like diagnostics connect more directly to a separate L-side
  static-code note than to Paper 5's M-side intervention-ranking claim.

### D2. Representation Discipline, Not A Load-Bearing Product Theorem

Include a short representation-discipline pointer in the main paper at §2.5.
This pointer consists of:

- a statement that product form follows under strong scale separability and
  multiplicative-composition assumptions;
- an explicit caveat that this is weaker than Paper 1 §3 log-ratio uniqueness,
  because scale separability already pushes strongly toward product form;
- a one-paragraph correspondence to Paper 1 §3 log-ratio uniqueness;
- a small mapping table (additive Cauchy -> multiplicative Cauchy,
  `f(r) = -k ln r -> Phi(q) = prod q_i^alpha_i`);
- product, CES, and bottleneck forms as candidate families.

Default placement:

```text
main text §2.5: representation discipline + correspondence paragraph + mapping table
supplement / later note: optional full axiom list and proof-level product lemma
```

Do not promote §2.5 to a standalone §3. Keep `Phi` as a monotone aggregator in
the remaining sections, and treat product form as a motivating candidate rather
than a load-bearing theorem. Product form vs CES vs bottleneck form remains a
domain-specific empirical choice and must be checked by robustness analysis.

Rationale:

- Paper 5 should not become only a taxonomy of resource modes;
- product-form structure is a useful theoretical candidate that connects to
  Paper 1 §3, but it should not be oversold as equally nontrivial;
- CES and bottleneck alternatives prevent the theory from silently assuming
  product form;
- full proof-level treatment would make the first draft too heavy and is not
  needed for the main intervention-ranking prediction.

Status: reflected in `PAPER5_SECTION_1_2_DRAFT.md` §2.5 (2026-04-22).

### D3. Validation Protocol

For a future software Route C pilot, use:

```text
primary: time-split held-out validation
secondary: leave-one-project-out validation
```

Rationale:

- time-split tests prospective value, which is central for software defects;
- leave-one-project-out tests cross-project generalization;
- both should be preregistered before inspecting held-out outcomes.

Preferred primary metrics:

- log loss or Brier score for held-out risk prediction;
- Kendall tau or similar rank correlation for intervention-ranking agreement.

Status: reflected in `PAPER5_SECTION_6_DRAFT.md` §6 (2026-04-22). The draft
separates preparatory risk-prediction support from primary intervention-ranking
support, requires robustness checks for `rho_i`, `Phi`, and `A_j`, and treats
observational intervention-ranking support as non-causal unless randomized
assignment or an explicit causal-identification design is available.

DeltaLint baseline comparison is separated from Paper 5:

```text
Do not make DeltaLint evidence load-bearing in Paper 5. If pursued, give it
its own Paper 3 / L-side static-code extension note with baseline-controlled
validation.
```

### D4. Mode vs Supply Channel Distinction

Treat mode labels as persistence manners, not providers.

Use:

```text
in-context M_r
M_x-supplied M_r  (formal notation: M_{x->r})
```

when distinguishing prompt-internal repair markers from out-of-context external
repair processes.

Rationale:

- Exp.40/42 scope-as-repair and attribution-as-repair are in-context effects:
  the prompt induces the base model's repair-like interpretation.
- Paper 3 external metabolism and Paper 4 F-v2c are out-of-context/controller
  processes: an external channel supplies repair-like structure to the base
  system.
- Keeping this distinction avoids treating `M_x` as a fourth same-level repair
  mode. `M_x` is an externalization profile split by target mode:
  `M_{x->b}`, `M_{x->r}`, `M_{x->a}`. `M_r` is the supplied persistence
  manner.

Status: reflected in `PAPER5_SECTION_3_DRAFT.md` §3.1-3.5 (2026-04-22).

### D5. Software Route C Mapping

Treat software / SaaS as the first Route C domain, not as Route A.

Use:

```text
F_broad = safe change continuity
F_pilot = change-introduced bug detection / localization
```

and treat:

```text
prompt / runbook / checklist / CI-CD / operational protocol ∈ Sigma
```

rather than raw `R`.

Initial pilot proxy:

```text
L_hat_pilot = boundary-crossing count + rollback-impossibility rate
```

with raw/conventional baselines such as LOC, churn, age, cyclomatic complexity,
prior incident count, and code-smell counts.

DeltaLint-like structural diagnostics are not part of the Paper 5 validation.
They may be mentioned only as a related L-side / Paper 3 static-code extension,
with their own baseline-controlled validation.

Status: reflected in `PAPER5_SECTION_4_5_DRAFT.md` §4-5 (2026-04-22).

### D6. DeltaLint Split

DeltaLint is not used as Paper 5's load-bearing empirical anchor.

Decision:

```text
Paper 5 = M-side operationalization and intervention-ranking protocol.
DeltaLint = separate L-side / Paper 3 static-code extension.
```

Rationale:

- DeltaLint primarily observes unresolved structural contradictions and premise
  mismatches in static code. This is closer to `L_hat` / local `Delta L` risk
  than to `M`-mode composition.
- Paper 5's distinctive claim concerns mode composition and intervention
  ranking. DeltaLint data do not directly measure `M_b`, `M_r`, `M_a`,
  external supply channels, or intervention outcomes.
- Keeping DeltaLint separate prevents the strong engineering record from
  pulling Paper 5 away from its theoretical spine.

If pursued, the DeltaLint note should use an additive-prediction protocol:

```text
existing tools + DeltaLint > existing tools alone
```

under the same alert budget, with held-out or prospective bug-fix outcomes.

Status: reflected in `PAPER5_SECTION_4_5_DRAFT.md` §5.4 and
`DELTALINT_PAPER3_EXTENSION_NOTE.md` (2026-04-22).

### D7. Section 6 Validation Protocol

Paper 5's empirical validation protocol is specified without using DeltaLint
as the validation anchor.

Decision:

```text
primary split: time-split held-out validation
secondary split: leave-one-project-out validation
preparatory support: held-out risk prediction improves over raw/scalar baselines
primary support: predicted intervention ranking matches observed intervention effectiveness
strong support: ranking remains stable across rho_i, Phi, and A_j choices
```

Rationale:

- Paper 5's main claim is intervention ranking, not merely bug-risk prediction.
- Risk prediction can support the framework only as preparatory evidence unless
  intervention history is available.
- The scalar `M_total` baseline must be strong: the preregistration should
  include train-fold learned scalarizations, not only an unweighted sum.
- The observed intervention ranking estimator must be fixed before outcome
  inspection. Candidate estimators include pre/post differences,
  difference-in-differences, matched-pair analysis, interrupted time series, or
  randomized intervention assignment if available.
- Robustness across normalization (`rho_i`), aggregator (`Phi`), and
  internal/external aggregation (`A_j`) prevents the main prediction from being
  an artifact of a single scaling convention.
- "Reasonable" robustness variants mean the preregistered `rho_i`, `Phi`, and
  `A_j` candidate families; post-hoc additions are exploratory.
- The preregistration must include minimum unit counts per fold and a detectable
  effect-size / power target for the primary ranking endpoint.

Status: reflected in `PAPER5_SECTION_6_DRAFT.md` (2026-04-22).

### D8. Section 7 Closure And Limitations

Paper 5 is closed as a review draft by keeping its scope thin.

Decision:

```text
Paper 5 = framework / protocol paper for M-side operationalization.
It does not yet claim completed empirical validation.
Software / SaaS remains the first Route C domain.
Four-domain comparison is future work.
DeltaLint remains a separate Paper 3 / L-side static-code extension.
```

Rationale:

- Paper 5's distinctive contribution is mode decomposition and intervention
  ranking, not another L-side bug-localization result.
- The current draft should not borrow DeltaLint's engineering record as
  validation for the M-framework.
- A software-centered first draft is cleaner than adding broad cross-domain
  comparison tables before operational metrics are fixed.
- Limitations must state that `L_hat_pilot` is a proxy, mode / channel signals
  are indicators, observational ranking support is non-causal, and underpowered
  pilots should not be read as strong non-support.

Status: reflected in `PAPER5_SECTION_7_DRAFT.md` (2026-04-22).

### D9. Promotion Summary And Lean Non-Blocker

The §1-7 review summary fixes the essence and promotion stance.

Decision:

```text
Paper 5 is the support-side coordinate system for intervention ranking.
It is not a new universality proof.
Lean formalization is optional and not a promotion blocker.
```

Rationale:

- Paper 5's core is the operational question: given structural loss $L$, which
  maintenance mode should be strengthened first?
- A thin Lean scaffold could formalize definitions, monotonicity, and robustness
  quantifiers, but it would not substitute for operational data.
- Promotion should depend on whether the paper is clean as a framework /
  protocol paper, not on new Lean code.

Status: reflected in `PAPER5_SECTION_1_2_DRAFT.md` §1 and
`PAPER5_REVIEW_SUMMARY.md` (2026-04-22).
