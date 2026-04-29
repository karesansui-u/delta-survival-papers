# M Flow Network Testbed

This directory contains the design package for the controlled M-side validation
testbed.

Files:

- `design_note.md`: conceptual design and anti-overfitting guardrails.
- `simulator_spec.md`: simulator interface, graph families, damage families,
  policies, readouts, and degeneracy flags.
- `preregistration_draft.md`: draft frozen-test plan for primary validation.
- `freeze_manifest_draft_v0.md`: pre-freeze checklist for split/evaluator and
  degeneracy rules.
- `scripts/simulate_flow_network.py`: simulator v0 dry-run implementation.
- `scripts/evaluate_flow_network.py`: evaluator v1 split-aware ranking-schema
  smoke test.
- `scripts/report_flow_degeneracy.py`: degeneracy report v1 smoke test.
- `scripts/run_calibration_sweep.py`: calibration sweep v0 over Q / damage /
  horizon candidates.
- `dry_runs/`: non-primary smoke-test outputs.

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
