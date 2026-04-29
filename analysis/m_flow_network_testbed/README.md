# M Flow Network Testbed

This directory contains the design package for the controlled M-side validation
testbed.

Files:

- `design_note.md`: conceptual design and anti-overfitting guardrails.
- `simulator_spec.md`: simulator interface, graph families, damage families,
  policies, readouts, and degeneracy flags.
- `preregistration_draft.md`: draft frozen-test plan for primary validation.
- `scripts/simulate_flow_network.py`: simulator v0 dry-run implementation.
- `scripts/evaluate_flow_network.py`: evaluator v0 ranking-schema smoke test.
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

Evaluator v0 smoke test:

```bash
python3 analysis/m_flow_network_testbed/scripts/evaluate_flow_network.py
```

The default evaluator reads `dry_runs/v0_smoke/runs.csv` and writes
`dry_runs/v0_smoke/evaluation_group_rankings.csv` plus
`dry_runs/v0_smoke/evaluation_summary.json`. These outputs check the ranking
schema only; they are not support evidence.
