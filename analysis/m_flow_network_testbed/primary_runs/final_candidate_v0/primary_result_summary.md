# M Flow Network Primary Result Summary

Status: one-time guarded primary executed on 2026-04-29.

Support decision: **no M-primary support under the frozen support rules**.

This is a controlled mechanistic testbed result. It is not real-domain support
for software, SaaS, battery, or organizational systems.


## 1. What Was Tested

The testbed asks whether the same total maintenance budget \(E=10\) has
different persistence value depending on how it is allocated across:

- buffer;
- recovery;
- reconfiguration.

The functional structure is a synthetic flow network. The system must maintain
required flow \(Q=4\) under damage. Each allocation is evaluated under the same
graph and damage stream within a group, so the ranking is an intervention-style
comparison of allocation choices rather than a comparison of unrelated random
runs.


## 2. Frozen Settings

Primary setting:

- `Q=4`
- `damage_intensity=0.34`
- `horizon_T=8`
- seeds `2000..2029`

Sensitivity settings:

- `Q=4`, `damage_intensity=0.28`, `T=9`
- `Q=4`, `damage_intensity=0.32`, `T=8`
- `Q=4`, `damage_intensity=0.34`, `T=9`

All four settings were executed through the guarded primary runner in
`analysis/m_flow_network_testbed/primary_packages/final_candidate_v0/`.


## 3. Primary Metrics

Lower regret is better.

| Setting | Collapse fraction | Keep / review groups | Total-resource regret | M-profile regret | Policy-prior regret | M beats total-resource rate | M beats policy-prior rate |
|---|---:|---:|---:|---:|---:|---:|---:|
| `primary_q4_d034_t8` | 0.5975 | 500 / 220 | 0.2372 | 0.2204 | 0.1506 | 0.4972 | 0.3389 |
| `sensitivity_heldout_top_q4_d028_t9` | 0.5770 | 493 / 227 | 0.2427 | 0.2326 | 0.1602 | 0.4472 | 0.3014 |
| `sensitivity_nearby_q4_d032_t8` | 0.5862 | 497 / 223 | 0.2388 | 0.2189 | 0.1528 | 0.4722 | 0.3208 |
| `sensitivity_harder_horizon_q4_d034_t9` | 0.6495 | 526 / 194 | 0.2567 | 0.2229 | 0.1620 | 0.4931 | 0.3514 |


## 4. Interpretation Under Frozen Rules

The M-profile linear model improves aggregate regret over the total-resource
tie baseline in all four settings. This is a useful secondary signal: the
allocation vector carries more information than the scalar total budget alone.

However, M-primary support requires beating the calibration-best policy-prior
baseline. The M-profile linear model does not beat that baseline in the primary
setting or in the sensitivity settings. The frozen no-support rule therefore
applies.

This result should be recorded as:

```text
no_support for M-primary support
secondary signal relative to total-resource baseline
no real-domain support
no universal M-law support
```


## 5. Reusable Lesson

The experiment did not show that a simple linear M-profile is enough to rank
interventions better than a strong policy-prior baseline in this controlled
flow-network setting.

It did show that the evaluator can reject M-support when the strong baseline is
better. This is useful: the testbed is not merely an apparatus that makes M win.

The next clean step is not to reinterpret this as support. If the M-side
program continues, it should either:

- design a new versioned M-profile model that can beat policy-prior without
  using primary outcomes; or
- move to a different controlled mechanism where policy-prior is less dominant;
  or
- keep this as a closed no-support controlled-mechanistic result and return to
  real-domain acquisition.
