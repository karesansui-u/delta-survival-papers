# Primary Package Commands

Status: command record only; primary not executed.


## Print Execution Plan

This command is safe.  It prints the commands that would be run and does not
execute the primary package.

```bash
python3 analysis/m_flow_network_testbed/scripts/run_primary_package.py \
  --config analysis/m_flow_network_testbed/primary_packages/final_candidate_v0/config.json
```


## Guarded Primary Execution

Do not run this command until the one-time primary execution is intentionally
approved.

```bash
CONFIRM_M_FLOW_PRIMARY=CONFIRM_M_FLOW_PRIMARY_AA90761 \
python3 analysis/m_flow_network_testbed/scripts/run_primary_package.py \
  --config analysis/m_flow_network_testbed/primary_packages/final_candidate_v0/config.json \
  --execute \
  --confirm-token CONFIRM_M_FLOW_PRIMARY_AA90761
```

The runner will refuse execution if either the environment variable or the
command-line token is absent or different.

The package runner delegates to:

- `simulate_flow_network.py primary-run --confirm-frozen-primary`;
- `evaluate_flow_network.py --primary-run --confirm-frozen-primary`;
- `report_flow_degeneracy.py --primary-run --confirm-frozen-primary`.

Those subcommands also refuse execution unless `CONFIRM_M_FLOW_PRIMARY` is set,
and they refuse to overwrite existing primary outputs by default.


## Expected Output Root

```text
analysis/m_flow_network_testbed/primary_runs/final_candidate_v0/
```

Each primary or sensitivity setting receives its own subdirectory containing:

- `runs.csv`
- `summary.json`
- `evaluation_group_rankings.csv`
- `evaluation_slice_metrics.csv`
- `evaluation_summary.json`
- `degeneracy_run_flags.csv`
- `degeneracy_group_summary.csv`
- `degeneracy_summary.json`


## Hash Checks

```bash
shasum -a 256 \
  analysis/m_flow_network_testbed/freeze_manifest_final_candidate.md \
  analysis/m_flow_network_testbed/freeze_manifest_draft_v1.md \
  analysis/m_flow_network_testbed/scripts/simulate_flow_network.py \
  analysis/m_flow_network_testbed/scripts/evaluate_flow_network.py \
  analysis/m_flow_network_testbed/scripts/report_flow_degeneracy.py \
  analysis/m_flow_network_testbed/scripts/run_primary_package.py \
  analysis/m_flow_network_testbed/primary_packages/final_candidate_v0/seeds.txt \
  analysis/m_flow_network_testbed/primary_packages/final_candidate_v0/config.json
```
