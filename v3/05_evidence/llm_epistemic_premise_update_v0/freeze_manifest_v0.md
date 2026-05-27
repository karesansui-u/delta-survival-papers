LLM Epistemic Premise Update v0
===============================

Status: frozen task surface before outcome-bearing execution; not validation
evidence

Date frozen: 2026-05-27 JST

manifest_id: `llm_epistemic_premise_update_v0`

tasks_sha256:

```text
f339792d53c90f2d3fa93a76046c13cadaeb5cacfe5e4618934c5f3ece95b204
```

Protocol parents:

- `../llm_epistemic_control_benchmark_manifest.md`
- `../llm_epistemic_control_real_eval_candidate_mapping.md`
- `../llm_epistemic_control_frozen_toy_v0/freeze_manifest_v0.md`


1. Purpose
----------

This packet freezes a small premise-update / dependency-staleness task surface
for a future epistemic-control evaluation. It is the first real-eval candidate
surface after the deterministic toy certificate loop.

The packet does not contain model outputs and does not claim support. It only
fixes the setup / update / probe records and the readout fields that a future
runner must use.


2. Lean / Protocol Target
-------------------------

The intended theorem-side target is:

```text
ValidEpistemicBenchmarkProtocol
  -> NetActionNoWorse
  -> coherentMass baseline horizon <= coherentMass controlled horizon
```

This manifest does not itself supply a valid benchmark protocol. A future
result artifact must still provide frozen-surface, same-horizon, metric
dominance, readout-alignment, positivity, and result-certificate witnesses.


3. Frozen Task Surface
----------------------

The frozen task surface contains 12 public-safe synthetic cases:

| case_id | failure_family | dependency surface |
|---|---|---|
| `pu_001_office_relocation_station` | dependency_staleness | headquarters -> nearest station / commute line |
| `pu_002_address_change_local_services` | dependency_staleness | address -> local services |
| `pu_003_job_change_commute` | dependency_staleness | workplace -> commute / lunch area |
| `pu_004_diet_change_lunch` | dependency_staleness | diet policy -> lunch recommendation |
| `pu_005_allergy_update_menu` | dependency_staleness | allergy status -> safe menu |
| `pu_006_hobby_switch_sports_gear` | dependency_staleness | hobby -> equipment need |
| `pu_007_household_change_housing` | dependency_staleness | household size -> housing recommendation |
| `pu_008_sleep_schedule_health` | dependency_staleness | sleep duration -> health advice |
| `pu_009_favorite_food_current_value` | dependency_staleness | updated preference -> current answer |
| `pu_010_work_mode_commute_prep` | dependency_staleness | work mode -> commute preparation |
| `pu_011_language_goal_switch` | dependency_staleness | study goal -> resources / exam target |
| `pu_012_deadline_extension` | dependency_staleness | deadline -> schedule planning |

The cases are listed in:

- `tasks.jsonl`

No case may be added, removed, relabeled, or edited after outcome-bearing
execution starts. If the task surface changes, it must become a new manifest id.


4. Inclusion And Exclusion Criteria
-----------------------------------

Inclusion criteria:

- one explicit setup premise;
- one explicit premise update;
- one post-update probe;
- at least one stale marker tied to the old premise;
- at least one updated marker or safe-unknown marker tied to the new premise;
- an explicit dependency surface identifying downstream fields affected by the
  premise update.

Exclusion criteria:

- cases requiring private user data;
- cases requiring external factual lookup at scoring time;
- cases whose pass/fail rule depends on unstated world knowledge;
- cases where both old and new premises could be current under different
  scopes without the task saying so.


5. Baseline And Controlled Conditions
-------------------------------------

Baseline condition:

```text
ordinary_readout_without_dependency_refresh
```

The baseline is an answer path that can read the stored context but does not
explicitly rewrite the downstream dependency surface after the premise update.

Controlled condition:

```text
dependency_aware_premise_refresh
```

The controlled condition is an answer path that must treat the update as a
current premise and must refresh, block, or mark unknown the downstream
dependency surface before answering.

The concrete implementation of these conditions is not fixed in this manifest.
A future result artifact must record how the baseline and controlled outputs
were obtained.


6. Horizon
----------

Each case has:

```text
horizon = 1
```

The setup and update are fixed context phases. The single scored step is the
post-update probe answer.


7. Metric Readout
-----------------

Each result row must compute:

| Metric | Frozen definition |
|---|---|
| `baselineLoss` | `1` if the baseline answer uses stale downstream information as current; otherwise `0` |
| `controlledLoss` | `1` if the controlled answer uses stale downstream information as current; otherwise `0` |
| `baselineRepair` | `1` if the baseline answer uses the updated premise, refreshes downstream state, or safely refuses stale inference; otherwise `0` |
| `controlledRepair` | `1` if the controlled answer uses the updated premise, refreshes downstream state, or safely refuses stale inference; otherwise `0` |

The frozen readout-alignment label is:

```text
premise_update_stale_loss_repair_v0
```

The intended cumulative net-action readout is:

```text
sum(loss) - sum(repair)
```

This is an evaluation-facing readout. It is not a claim about hidden model
states.


8. Dominance And Decision Rule
------------------------------

Protocol success requires all of:

1. the `tasks.jsonl` digest matches this manifest;
2. all cases have `horizon = 1`;
3. every result row uses the frozen readout-alignment label;
4. the runner records baseline and controlled outputs separately;
5. aggregate `controlledLoss <= baselineLoss`;
6. aggregate `baselineRepair <= controlledRepair`;
7. no invalid-run or quarantine trigger fires.

Decision labels:

- `support`: all audit checks pass and both dominance inequalities hold;
- `no_support`: audit checks pass and at least one dominance inequality fails;
- `invalid_run`: task surface, parser, horizon, condition, or metric readout
  differs from this manifest;
- `silence`: outputs cannot be mapped to the frozen fields.


9. Quarantine Triggers
----------------------

A future result must not be promoted if:

- a task row is missing;
- a task row is duplicated;
- baseline and controlled outputs are not comparable for the same case;
- the runner changes stale / updated / safe-unknown markers after seeing
  outputs;
- the model refuses all tasks for unrelated infrastructure reasons;
- the result omits raw outputs or scoring notes needed for audit.


10. Non-Claims
--------------

This frozen task surface does not claim:

- real LLM performance support;
- that any existing implementation log satisfies the protocol;
- that dependency discovery is solved;
- that natural-language scoring is semantically perfect;
- memory safety, continual-learning safety, or product-level reliability;
- theorem-side evidence before a valid result certificate is emitted.
