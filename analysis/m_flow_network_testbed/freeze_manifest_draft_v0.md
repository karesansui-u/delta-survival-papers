# M Flow Network Testbed Freeze Manifest Draft v0

Status: draft; not frozen.

Date: 2026-04-29

Purpose: define the fields that must be frozen before any outcome-bearing
primary run of the controlled flow-network M testbed.

This manifest is not a primary result. It is a pre-freeze contract for turning
the simulator and evaluator smoke tests into a controlled mechanistic validation
attempt.


## 1. Frozen Claim

Primary claim to freeze:

> Under the same total maintenance budget and the same stochastic damage
> stream, M-profile allocation predicts held-out intervention ranking better
> than both a total-resource baseline and a calibration-best-policy baseline.

Claim strength:

- controlled mechanistic support only;
- not real-world software / SaaS / battery / organizational support;
- not a universal \(M\)-law;
- not a claim that M-profile wins in every damage regime.


## 2. Frozen Code and Artifacts

Before primary execution, record:

- repository commit hash;
- simulator script path;
- evaluator script path;
- manifest hash;
- generated config files;
- random seeds;
- expected output schemas.

Current smoke-test scripts:

- `scripts/simulate_flow_network.py`;
- `scripts/evaluate_flow_network.py`.

Current smoke-test outputs:

- `dry_runs/v0_smoke/runs.csv`;
- `dry_runs/v0_smoke/summary.json`;
- `dry_runs/v0_smoke/evaluation_group_rankings.csv`;
- `dry_runs/v0_smoke/evaluation_slice_metrics.csv`;
- `dry_runs/v0_smoke/evaluation_summary.json`.

The smoke-test outputs are schema checks only and must not be treated as support
evidence.


## 3. Frozen Maintained Function

Each instance is a directed capacitated network with source \(s\), sink \(t\),
and required flow \(Q_t\).

The maintained function is:

\[
  \operatorname{maxflow}_{s\to t}(G_t,c_t) \ge Q_t.
\]

Collapse occurs at the first time \(t\) where this inequality fails.

Frozen readouts:

- max-flow series;
- required-flow series;
- margin series;
- collapse time;
- maintained-step ratio;
- maintained-flow ratio;
- minimum margin;
- buffer / recovery / reconfiguration energy spent;
- active bypass edges;
- degeneracy flags.


## 4. Frozen Split Design

The primary design must include three independent held-out axes.

Graph split:

- calibration graph families: `layered_dag`, `grid`, `series_parallel`;
- held-out graph family: `random_geometric`, unless calibration records it as
  structurally degenerate before primary execution.
- this draft requires family-level heldout. Seed-level heldout is a separate
  axis: if used, the freeze manifest must explicitly add a `seed_split` field
  and state which seeds are calibration-only and which are primary-only.

Damage split:

- damage families: `random_attrition`, `bottleneck_attack`,
  `clustered_failure`, `demand_shock`, `repairable_wear`,
  `scalar_only_control`;
- at least one damage family must be held out from rule selection and used only
  in primary evaluation.

Allocation split:

- freeze a simplex grid over
  \[
    E_{\mathrm{buffer}} + E_{\mathrm{recovery}}
    + E_{\mathrm{reconfiguration}} = E;
  \]
- include extremes and mixed allocations;
- hold out at least one allocation mix or simplex region from calibration.

All primary groups must retain explicit split labels:

- `graph_split`;
- `damage_split`;
- `allocation_split`;
- `primary_axes`;
- `group_split`.


## 5. Frozen Allocation Grid

The allocation grid must be frozen as explicit triples:

\[
  (E_{\mathrm{buffer}}, E_{\mathrm{recovery}},
  E_{\mathrm{reconfiguration}}).
\]

Named policies are only anchor labels:

- buffer-heavy;
- recovery-heavy;
- reconfiguration-heavy;
- balanced.

They are not the primary object. The primary object is the allocation vector.

The manifest must record:

- total energy values \(E\);
- all allocation triples;
- held-out allocation triples or held-out simplex region rule;
- whether named anchor labels are used only for reporting or also as model
  features.


## 6. Frozen Baselines

Total-resource baseline:

- graph family or observable graph summaries;
- graph size;
- edge count;
- initial max-flow;
- initial margin;
- total energy \(E\);
- damage intensity;
- horizon \(T\).

M-profile model:

- all total-resource baseline features;
- \(E_{\mathrm{buffer}}/E\);
- \(E_{\mathrm{recovery}}/E\);
- \(E_{\mathrm{reconfiguration}}/E\);
- pre-frozen interactions, if allowed.

Calibration-best-policy baseline:

- learns from calibration rows only;
- may use observable graph and damage summaries;
- estimates the best policy / allocation region from calibration outcomes;
- has no access to held-out graph, held-out damage, or held-out allocation
  outcomes.

The M-profile model must not receive generator-rule information unavailable to
the baselines.


## 7. Frozen Evaluator Schema

The evaluator must report group-level ranking metrics for:

- `total_resource_tie`;
- `policy_prior`;
- `m_profile_linear` or its frozen successor.

Primary group output must include:

- group identifiers;
- split labels;
- number of allocations;
- observed best allocation set;
- top-1 agreement;
- top-2 agreement;
- Kendall \(\tau\);
- regret relative to best observed allocation;
- whether M-profile beats total-resource by regret;
- whether M-profile beats policy-prior by regret;
- whether M-profile beats policy-prior by Kendall \(\tau\);
- whether M-profile clears the policy-prior smoke condition.

Slice output must include metrics by:

- all groups;
- graph split;
- damage split;
- allocation split;
- held-out axis;
- combined group split.

The evaluator must write:

- `evaluation_group_rankings.csv`;
- `evaluation_slice_metrics.csv`;
- `evaluation_summary.json`.


## 8. Degeneracy Rules

Each run or group must retain degeneracy flags rather than silently dropping
unfavorable cells.

Run-level degeneracy flags include:

- `initially_collapsed`;
- `collapse_at_first_step`;
- `no_collapse`;
- `far_above_q`;
- `post_policy_below_q`;
- `recovery_unused`;
- `reconfiguration_impossible`;
- `no_alternate_path`.

Primary exclusions are allowed only if frozen before primary execution.

Required reporting:

- total degenerate run count;
- degenerate run count by graph family;
- degenerate run count by damage family;
- degenerate run count by allocation split;
- group-level degeneracy fraction;
- list of excluded cells, if any;
- analysis with and without excluded cells when feasible.

No-support must be recorded if:

- most primary cells are degenerate;
- degeneracy is concentrated in a way that creates the M advantage;
- M wins only after excluding pre-frozen unfavorable regimes;
- reconfiguration cannot act in most reconfiguration-heavy cells;
- recovery cannot act in most recovery-heavy cells.


## 9. Frozen Support Rules

M-primary support requires all of the following:

1. M-profile improves the primary ranking metric over the total-resource
   baseline on held-out graph evaluation units. In this draft, that means the
   held-out graph family. If seed-level heldout is added, the manifest must
   separately require held-out graph seeds.
2. Improvement holds on the held-out graph family.
3. Improvement holds on at least one held-out damage family.
4. Improvement holds on the held-out allocation mix or held-out simplex region.
5. M-profile beats the calibration-best-policy baseline.
6. Scalar-only control does not show a spurious large M advantage.
7. Degenerate cells remain below the pre-frozen maximum fraction.

M-preparatory support requires:

- M-profile improves at least one secondary outcome prediction over the
  total-resource baseline out-of-sample.

No-support is recorded if:

- total-resource baseline matches or beats M-profile on the primary metric;
- calibration-best-policy baseline matches or beats M-profile on the primary
  metric;
- M-profile only wins after excluding unfavorable frozen regimes;
- M-profile only memorizes named policy labels and fails on held-out allocation
  mixes;
- held-out topology or held-out damage reverses the effect;
- most primary cells are degenerate;
- the M model is given generator-rule information unavailable to the baseline.


## 10. Frozen Reporting Package

The primary package must include:

- freeze manifest;
- config files;
- seed list;
- run table;
- evaluator outputs;
- degeneracy report;
- support or no-support decision;
- exact code commit hash;
- reproduction instructions.

Failed, null, and degenerate attempts remain in the record.


## 11. Non-Claims

This manifest does not claim:

- real-world empirical support;
- causal validity in observational domains;
- transfer to software / SaaS / batteries / organizations;
- a universal \(M\)-law;
- support from the current smoke-test outputs.
