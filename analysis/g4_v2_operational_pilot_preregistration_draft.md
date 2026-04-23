# G4 v2 Operational Pilot Preregistration Draft

Status: draft / exploration. Not frozen. No primary data may be generated from
this document until a dataset, feature schema, split, and evaluation script are
frozen in a later commit.

Date: 2026-04-23

## 1. Purpose

G4 v2 closed a finite-prefix algebraic skeleton for repair / maintenance
balance:

\[
  D_n = D_0 + \sum_{t<n}(d_t-g_t),
  \qquad
  M_n = B-D_n.
\]

The next operational question is narrower:

\begin{quote}
Given real maintenance / repair logs, does a lagged repair-aware coordinate
predict future degradation or failure better than damage-only and activity-only
baselines?
\end{quote}

This is an operational validation design, not a new theorem. It tests whether
the compensation flow \(g_t\) can be made observable enough to improve
prospective prediction in a non-CSP open-system domain.


## 2. Phase Discipline

This experiment has three phases.

| phase | role | allowed actions | forbidden actions |
|---|---|---|---|
| exploration | dataset audit and schema feasibility | inspect fields, missingness, timestamp coverage, base rates | report validation evidence |
| freeze | commit preregistration, feature code, split, and evaluation script | lock parameters and primary endpoint | tune after primary labels |
| validation | run frozen pipeline once on held-out time period | report pass / fail / weakening outcomes | change features, horizon, split, or decision rules |

All pre-freeze analyses are calibration. They may justify design changes, but
they are not evidence that the theory is correct.


## 3. Unit, Time, and Endpoint

The data must have repeated observations for identifiable units.

| symbol | operational meaning |
|---|---|
| \(i\) | unit: machine, component, service, repository, pipeline, or asset |
| \(t\) | prediction cutoff time |
| \(W\) | lagged feature window before \(t\) |
| \(H\) | prediction horizon after \(t\) |
| \(Y_{i,t,H}\) | future degradation / failure indicator in \((t,t+H]\) |

Primary endpoint:

\[
  Y_{i,t,H}=1
\]

if unit \(i\) experiences a pre-specified failure / degradation event in the
future horizon \((t,t+H]\). The endpoint must be fixed before validation.

Examples of eligible endpoints:

- incident / outage in the next horizon;
- component failure;
- threshold exceedance in remaining useful life proxy;
- severe regression / rollback event after a change;
- safety-relevant degradation alert.

Examples of ineligible endpoints:

- repair event itself, if used as both \(g_t\) and outcome;
- labels created using information after \(t+H\);
- subjective severity labels assigned after seeing model outputs.


## 4. Damage and Repair Indicators

The pilot separates loss-side and compensation-side signals.

Damage-side indicators \(d_{i,u}\) may include:

- load, utilization, cycles, temperature, vibration, latency, error rate;
- incident count, failure count, test failure count;
- unrepaired defect count;
- age since deployment or age since last replacement;
- change size or exposure count.

Repair-side indicators \(g_{i,u}\) may include:

- preventive maintenance;
- component replacement;
- patch, rollback, restore, reconfiguration;
- redundancy activation;
- inspection with completed corrective action;
- repair drill / restore drill that is tied to the unit.

Repair signals must be timestamped before the prediction cutoff \(t\). Events
after \(t\) cannot be used as features for predicting \(Y_{i,t,H}\).


## 5. Leakage and Confounding Controls

Repair is not automatically protective in observational data. Units that are
already fragile often receive more repair. Without controls, \(g_t\) can look
like a risk marker rather than compensation.

This draft therefore commits to four controls.

1. Lag rule:
   features are computed only from \([t-W,t)\). No event after \(t\) enters
   predictors.

2. Outcome blackout:
   repair events inside \((t,t+H]\) are not predictors. If they are logged as
   responses to the outcome, they are excluded from \(g_t\).

3. Repair class split:
   preventive / scheduled repair is separated from reactive repair when the
   logs allow it. Preventive repair is the preferred primary \(g_t\) signal.

4. Activity control:
   generic activity volume, such as number of tickets, log entries, maintenance
   records, or inspections, is included as a baseline. A repair-aware model must
   beat this activity-only explanation.

These controls do not identify a causal effect. They only make the predictive
test less vulnerable to obvious leakage and confounding-by-indication.


## 6. Feature Families

For each unit \(i\) and cutoff \(t\), define lagged summaries over
\([t-W,t)\).

Damage summary:

\[
  D^{\mathrm{obs}}_{i,t}
  =
  \sum_{u\in[t-W,t)} w_d(u)\,d_{i,u}.
\]

Repair summary:

\[
  G^{\mathrm{obs}}_{i,t}
  =
  \sum_{u\in[t-W,t)} w_g(u)\,g_{i,u}.
\]

The default primary model is the non-commensurable vector model
\((D^{\mathrm{obs}},G^{\mathrm{obs}})\). Real maintenance logs usually do not
put damage and repair in the same physical unit.

The net-action proxy

\[
  A^{\mathrm{obs}}_{i,t}
  =
  D^{\mathrm{obs}}_{i,t}
  -
  G^{\mathrm{obs}}_{i,t}.
\]

may be used as primary only if the dataset already contains a pre-existing
engineering or operational standard that converts damage and repair into the
same damage-equivalent unit. This conversion rule must exist before this pilot;
it cannot be fitted from validation outcomes or chosen after seeing predictive
performance.

If no such pre-existing standard exists, the primary repair-aware model uses
separate features \((D^{\mathrm{obs}},G^{\mathrm{obs}})\), and support requires
both predictive improvement and the pre-specified coefficient-sign check in
§10.


## 7. Candidate Models

All models are trained on pre-primary data and evaluated on a held-out future
time period.

| model | features | role |
|---|---|---|
| B0 exposure-only | unit age, exposure, calendar time, base-rate controls | minimal baseline |
| B1 damage-only | B0 + \(D^{\mathrm{obs}}\) | primary baseline |
| B2 activity-only | B0 + generic activity count | confounding / logging baseline |
| B3 repair-only | B0 + \(G^{\mathrm{obs}}\) | diagnostic, not support by itself |
| S1 net-action | B0 + \(A^{\mathrm{obs}}\) | primary only with pre-existing damage-equivalent units |
| S2 repair-aware vector | B0 + \((D^{\mathrm{obs}},G^{\mathrm{obs}})\) as separate features | default primary model |

The default model class is L2-regularized logistic regression for binary
endpoints. If the endpoint is time-to-event rather than binary horizon risk,
the freeze document must explicitly switch to a survival model. In that case,
the primary metric is integrated Brier score over the pre-specified prediction
horizon, and the secondary metric is C-index. If integrated Brier score cannot
be computed from the available censoring information, the survival path is not
eligible for primary validation under this draft.


## 8. Splits

Primary split:

\[
  \text{train/calibration period} < \text{validation period}.
\]

Random row splits are not allowed as primary evidence, because they leak
unit-level history across time.

Secondary splits:

- leave-one-unit-group-out, if enough units exist;
- leave-one-site-out, if sites / fleets / repositories exist;
- rolling-origin time split, if the time span is long enough.

The primary split must be fixed before validation.


## 9. Dataset Eligibility

A dataset is eligible only if it satisfies all of the following before freeze.

1. Timestamps exist for damage, repair, and outcome events.
2. Unit identifiers are stable across time.
3. Repair events can be placed before or after the prediction cutoff.
4. At least one repair class is not merely a label for the outcome itself.
5. Primary validation has enough events to estimate log loss meaningfully.
6. Outcome base rate in validation is not saturated: target range 5%-50%.
7. Missingness and censoring rules can be written before validation.
8. Data use is permitted, privacy-safe, and reproducible at the level reported.
9. Preventive or scheduled repair is distinguishable from purely reactive
   repair, or there is another pre-specified repair class that occurs before
   visible failure and is not merely an outcome response.

If these conditions fail, the pilot is marked dataset-ineligible. This is not a
theory failure.


## 10. Hypotheses

H1 primary predictive support:

The primary repair-aware model beats the best damage / activity baseline on
held-out log loss:

\[
  \mathrm{LL}(\mathrm{repair\mbox{-}aware})
  <
  0.95
  \cdot
  \min\{
    \mathrm{LL}(B1),
    \mathrm{LL}(B2)
  \}.
\]

H2 strong predictive support:

\[
  \mathrm{LL}(\mathrm{repair\mbox{-}aware})
  <
  0.90
  \cdot
  \min\{
    \mathrm{LL}(B1),
    \mathrm{LL}(B2)
  \}.
\]

H3 sign discipline:

- damage coefficient must have risk-increasing sign in the primary model;
- preventive repair coefficient must have risk-decreasing sign when repair is
  separated from reactive repair;
- if using \(A^{\mathrm{obs}}=D^{\mathrm{obs}}-G^{\mathrm{obs}}\), the
  coefficient on \(A^{\mathrm{obs}}\) must be risk-increasing.

H4 leakage robustness:

The H1 direction must persist after excluding repair events within a
pre-specified blackout interval immediately before \(t\), if those events are
likely to be reactive to already-visible failure.

H5 ranking diagnostic:

Among units with similar damage summary \(D^{\mathrm{obs}}\), units with higher
preventive \(G^{\mathrm{obs}}\) should have lower predicted failure risk under
the repair-aware model. This is diagnostic only; it is not causal evidence.


## 11. Decision Rules

Primary support requires:

1. H1 passes on the primary time-held-out split.
2. H3 sign discipline passes.
3. The activity-only baseline B2 does not beat the repair-aware model.
4. No leakage violation is discovered after freeze.

Strong support requires:

1. H2 passes.
2. H3 passes in all primary and secondary splits.
3. H4 blackout robustness passes.

Weakening outcomes:

| outcome | interpretation |
|---|---|
| repair-aware improves log loss but sign discipline fails | predictive signal exists, but not interpretable as \(g_t\) compensation |
| sign discipline passes but log loss does not improve | algebraic reading may be plausible, but operational predictor is weak |
| activity-only baseline wins | signal may be logging / attention intensity, not repair |
| only reactive repair is available | \(g_t\) operationalization is not clean; dataset is weak for G4 v2 |
| dataset ineligible | no validation claim |


## 12. Non-Claims

This pilot must not claim:

1. repair causally reduces failure;
2. an optimal maintenance policy has been found;
3. \(g_t\) is uniquely measurable in all domains;
4. the same repair coefficient transfers across datasets;
5. stochastic reliability theory has been replaced;
6. safety-critical deployment decisions can be made from the pilot alone;
7. universal law status has been established.


## 13. Freeze Checklist

Before validation, the freeze commit must contain:

1. dataset identifier and access note;
2. unit definition;
3. endpoint definition \(Y_{i,t,H}\);
4. feature window \(W\);
5. prediction horizon \(H\);
6. damage indicators and weights;
7. repair indicators and weights;
8. preventive vs reactive repair rule;
9. commensurability decision: S2 default, or S1 only with a pre-existing
   damage-equivalent unit standard;
10. blackout interval, if used;
11. missingness / censoring rules;
12. primary train / validation split;
13. model class and regularization value;
14. metric and decision rules;
15. evaluation script hash or committed script path;
16. non-claim statement copied into the report template.


## 14. Report Template

The validation report should include:

- dataset eligibility decision;
- frozen SHA;
- number of units, time windows, and events;
- outcome base rate;
- model log loss table;
- coefficient sign table;
- leakage / blackout robustness result;
- weakening outcome, if any;
- exact statement of what is supported and what is not supported.


## 15. Dataset Selection Discipline

Dataset selection is part of the preregistration discipline once the project
moves from exploration to freeze. Before that point, an exploratory dataset
scan is allowed and should be documented separately. The current scan document
is:

```text
analysis/g4_v2_exploratory_dataset_scan.md
```

The scan may inspect schemas, documentation, timestamps, rough base rates, and
repair / outcome availability. It must not report validation evidence or model
performance. Its purpose is only to decide whether a frozen operational pilot
is feasible.

If this draft later moves to freeze, the pilot must not silently choose
whichever eligible dataset looks most favorable.

Candidate datasets are handled as follows.

1. Before inspecting outcome-model performance, create a candidate list with a
   fixed ranking rule. The ranking rule may use only metadata: domain relevance,
   timestamp coverage, unit count, repair-class availability, expected privacy
   feasibility, and reproducibility.
2. The first §9-eligible dataset under that fixed ranking becomes the primary
   dataset.
3. Later §9-eligible candidates become pre-committed replication candidates.
4. If multiple datasets are already equally accessible, the stronger option is
   to analyze all §9-eligible datasets in parallel and report the pattern
   across them. This must be frozen before validation.
5. Dataset selection cannot use primary model log loss, coefficient signs, or
   any outcome-dependent comparison between candidate datasets.

The dataset-ranking commit is required only if moving from exploratory scan to
frozen validation. It should be separate from the later freeze commit. It records
the search path and prevents the pilot from becoming a garden-of-forking-paths
exercise.


## 16. Evidence Weight

Even if this pilot passes, its evidential weight is lower than Exp43c
q-coloring primary validation.

| comparison | Exp43c q-coloring | G4 v2 operational pilot |
|---|---|---|
| data generation | randomized from frozen rules | observational logs |
| confounding | structurally controlled by generation | residual confounding remains |
| primary claim | frozen coordinate beats baselines | predictive consistency with repair balance |
| causal interpretation | not causal, but randomized instance generation | explicitly non-causal |
| evidence tier | Route A primary validation | Route C / operational observational support |

Therefore, a passing G4 v2 operational pilot should be reported as
observational support for operationalizing \(g_t\), not as evidence equal in
strength to a randomized Route A primary.


## 17. Current Status

This draft opens the G4 v2 operational pilot track. It does not freeze a dataset
or launch validation.

The clean next step is an exploration-only dataset scan under:

```text
analysis/g4_v2_exploratory_dataset_scan.md
```

Candidate datasets should first be inspected only for schema feasibility and
eligibility under §9, not for whether they are likely to support the theory.
Dataset-ranking and freeze discipline become necessary only after a plausible
candidate has been found and the project is ready to define a primary
validation package.
