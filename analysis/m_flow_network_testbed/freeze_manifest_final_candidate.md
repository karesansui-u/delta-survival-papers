# M Flow Network Testbed Freeze Manifest Final Candidate

Status: final candidate; primary run not executed.

Date: 2026-04-29

Purpose: record the pre-primary choice of \(Q\), damage intensity, and horizon
for the controlled flow-network M-profile validation attempt.

This document does not report M-support.  It freezes a candidate setting for
the next primary configuration package, using only calibration artifacts already
recorded before any outcome-bearing primary run.


## 1. Source Artifacts

This final candidate is based on:

- `freeze_manifest_draft_v1.md`;
- `dry_runs/calibration_sweep_v0/`;
- `dry_runs/calibration_review_v1/`;
- `dry_runs/calibration_review_v1/full_grid_smoke/`.

Relevant commits:

- `0163ff6` adds calibration review v1;
- `be3e63c` adds freeze manifest draft v1;
- `a07af51` adds the target collapse band.


## 2. Selection Rule

The setting must be selected from the draft-v1 candidate region:

- required flow \(Q=4\);
- damage intensity \(d \in \{0.28,0.30,0.32,0.34\}\);
- horizon \(T \in \{8,9,10\}\);
- target calibration collapse band approximately \([0.55,0.75]\).

The setting must not be chosen by:

- primary outcome;
- M-profile evaluator performance on primary data;
- support/no-support implications;
- a single calibration-score winner.

Because the held-out-allocation review and full-grid smoke select different
top candidates, the final candidate favors a setting that is inside the target
collapse band in both views and is near the top under both calibration views.


## 3. Final Primary Candidate

The final primary candidate setting is:

```yaml
required_flow_Q: 4
damage_intensity: 0.34
horizon_T: 8
```

Rationale:

- it is the top heuristic candidate in the full-grid smoke;
- it remains near the top in the held-out-allocation review;
- both calibration views place it inside the target collapse band;
- it avoids selecting the held-out-allocation single top winner by itself;
- it keeps \(T=8\), avoiding the more collapse-heavy \(T=12\) sensitivity
  region.

Calibration diagnostics:

| view | collapse | no collapse | first-step collapse | far above \(Q\) | group recommendation |
|---|---:|---:|---:|---:|---|
| held-out allocation | 0.7045 | 0.2955 | 0.0076 | 0.0000 | 10 keep / 2 review |
| full grid | 0.6515 | 0.3485 | 0.0038 | 0.0833 | 18 keep / 6 review |

These diagnostics are calibration facts only.  They are not support evidence.


## 4. Required Sensitivity Candidates

The primary package should include sensitivity runs for at least the following
neighboring settings:

1. Held-out-allocation top candidate:

```yaml
required_flow_Q: 4
damage_intensity: 0.28
horizon_T: 9
```

2. Stable nearby candidate:

```yaml
required_flow_Q: 4
damage_intensity: 0.32
horizon_T: 8
```

3. Harder same-damage horizon neighbor:

```yaml
required_flow_Q: 4
damage_intensity: 0.34
horizon_T: 9
```

The first sensitivity point protects against over-reliance on the full-grid
winner.  The second protects against the upper-damage choice.  The third checks
whether the selected damage intensity is stable under a slightly longer horizon.


## 5. Primary-Package Freeze Status

This document freezes only the Q / damage / horizon candidate and required
sensitivity settings.  The remaining primary-package fields are frozen in:

```text
analysis/m_flow_network_testbed/primary_packages/final_candidate_v0/
```

That package freezes:

- exact seed list;
- number of seeds;
- graph-family split;
- damage-family held-out rule;
- allocation grid;
- held-out allocation mix or simplex region;
- evaluator version;
- degeneracy exclusion/reporting rule;
- output directory;
- reproduction command;
- manifest hash.

The package is still not a primary result.  It records the pre-execution
contract for a guarded one-time primary run.


## 6. Non-Claims

This final candidate does not claim:

- M-primary support;
- M-preparatory support;
- real-world empirical support;
- a universal \(M\)-law;
- that \(Q=4,d=0.34,T=8\) is uniquely optimal;
- that the primary result will favor M-profile.

If the primary run yields no-support under this setting, the result must remain
in the record.
