# M Flow Network Primary Package Final Candidate v0

Status: frozen primary package candidate; not executed.

This package freezes the exact pre-primary settings for the controlled
flow-network M-profile testbed.  It does not report M-support.


## Contents

- `config.json`: primary package config.
- `seeds.txt`: primary-only seed block.
- `commands.md`: exact print-plan and guarded execution commands.
- `hashes.json`: SHA-256 record for manifests, scripts, seeds, and config.


## Frozen Primary Candidate

```yaml
required_flow_Q: 4
damage_intensity: 0.34
horizon_T: 8
```

Required sensitivity settings:

- `Q=4`, `damage_intensity=0.28`, `T=9`
- `Q=4`, `damage_intensity=0.32`, `T=8`
- `Q=4`, `damage_intensity=0.34`, `T=9`


## Primary-Only Seed Block

Seeds are frozen to the contiguous block `2000` through `2029`, inclusive.
Calibration smoke tests used seed `1000`; this block is primary-only.


## Guard

The runner refuses execution unless both conditions are met:

- `--execute --confirm-token CONFIRM_M_FLOW_PRIMARY_AA90761`
- `CONFIRM_M_FLOW_PRIMARY=CONFIRM_M_FLOW_PRIMARY_AA90761`

Printing the plan does not require the token.

The guarded runner delegates to explicit primary-mode subcommands, not to the
dry-run status path.  The raw simulator output, evaluator metrics, and
degeneracy report remain uninterpreted until the frozen support rules are
applied.


## Non-Claims

This package does not claim:

- M-primary support;
- M-preparatory support;
- real-domain support;
- that the primary result will favor M-profile.

If the guarded primary execution yields no-support, that result remains in the
record.
