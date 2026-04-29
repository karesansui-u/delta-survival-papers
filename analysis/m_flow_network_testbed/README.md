# M Flow Network Testbed

This directory contains the design package for the controlled M-side validation
testbed.

Files:

- `design_note.md`: conceptual design and anti-overfitting guardrails.
- `simulator_spec.md`: simulator interface, graph families, damage families,
  policies, readouts, and degeneracy flags.
- `preregistration_draft.md`: draft frozen-test plan for primary validation.
- `freeze_manifest_draft_v0.md`: initial pre-freeze checklist for
  split/evaluator and degeneracy rules.
- `freeze_manifest_draft_v1.md`: adds the calibration-selected candidate
  region from calibration review v1.
- `freeze_manifest_final_candidate.md`: records the pre-primary Q / damage /
  horizon candidate and required sensitivity settings.
- `scripts/simulate_flow_network.py`: simulator v0 dry-run implementation.
- `scripts/evaluate_flow_network.py`: evaluator v1 split-aware ranking-schema
  smoke test.
- `scripts/report_flow_degeneracy.py`: degeneracy report v1 smoke test.
- `scripts/run_calibration_sweep.py`: calibration sweep v0 over Q / damage /
  horizon candidates.
- `scripts/run_primary_package.py`: guarded primary-package runner; prints the
  plan by default and requires an explicit confirmation token to execute.
- `dry_runs/`: non-primary smoke-test outputs.
- `primary_packages/`: frozen pre-primary package configs, seed lists, command
  records, and hashes. These packages are not support evidence until executed
  and interpreted under the frozen rules.
- `primary_runs/final_candidate_v0/`: one-time guarded primary outputs and the
  frozen-rule result summary.

The purpose is to test whether buffer / recovery / reconfiguration allocation
has predictive and intervention-ranking value beyond total resource in a
controlled functional structure.

This is controlled mechanistic support only. It does not count as real-domain
support for software, SaaS, battery, or organizational systems.

Simulator v0 smoke test:

```bash
python3 analysis/m_flow_network_testbed/scripts/simulate_flow_network.py dry-run
```

The default run writes `dry_runs/v0_smoke/runs.csv` and
`dry_runs/v0_smoke/summary.json`. These outputs are schema checks only and do
not count as M-primary support.

Evaluator v1 smoke test:

```bash
python3 analysis/m_flow_network_testbed/scripts/evaluate_flow_network.py
```

The default evaluator reads `dry_runs/v0_smoke/runs.csv` and writes
`dry_runs/v0_smoke/evaluation_group_rankings.csv`,
`dry_runs/v0_smoke/evaluation_slice_metrics.csv`, and
`dry_runs/v0_smoke/evaluation_summary.json`. These outputs check the
split-aware ranking schema only; they are not support evidence.

Degeneracy report v1 smoke test:

```bash
python3 analysis/m_flow_network_testbed/scripts/report_flow_degeneracy.py
```

The default report reads `dry_runs/v0_smoke/runs.csv` and writes
`dry_runs/v0_smoke/degeneracy_run_flags.csv`,
`dry_runs/v0_smoke/degeneracy_group_summary.csv`, and
`dry_runs/v0_smoke/degeneracy_summary.json`. These outputs check reporting and
exclusion-rule plumbing only; they are not exclusion decisions.

Calibration sweep v0:

```bash
python3 analysis/m_flow_network_testbed/scripts/run_calibration_sweep.py
```

The default sweep writes `dry_runs/calibration_sweep_v0/sweep_summary.csv` and
`dry_runs/calibration_sweep_v0/sweep_diagnostics.json`. The sweep is a
calibration-screening tool only; it is not support evidence.

Calibration review v1:

```bash
python3 analysis/m_flow_network_testbed/scripts/run_calibration_sweep.py \
  --q-values 4 \
  --damage-values 0.26,0.28,0.30,0.32,0.34 \
  --horizon-values 8,9,10,12 \
  --out-dir analysis/m_flow_network_testbed/dry_runs/calibration_review_v1
```

The review narrows the v0 sweep around `Q=4` and writes
`dry_runs/calibration_review_v1/sweep_summary.csv` and
`dry_runs/calibration_review_v1/sweep_diagnostics.json`. It is still a
calibration pointer, not a freeze decision or support claim.

Primary package final candidate v0:

```bash
python3 analysis/m_flow_network_testbed/scripts/run_primary_package.py \
  --config analysis/m_flow_network_testbed/primary_packages/final_candidate_v0/config.json
```

This command only prints the execution plan. The guarded execution command is
recorded in `primary_packages/final_candidate_v0/commands.md`.

The one-time guarded primary was executed on 2026-04-29 and is recorded in
`primary_runs/final_candidate_v0/`. Under the frozen support rules it produced
no M-primary support: the M-profile model improved over total-resource regret
in aggregate, but did not beat the calibration-best policy-prior baseline.
