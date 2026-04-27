# Exp43c G7 Replication Report Template

Status: template for a returned Exp43c true outside-group rerun. Do not fill
this as a final report until an outside-group return is received.

Date opened: 2026-04-27

## 1. Package Identity

```text
runner:
returned date:
bundle filename:
bundle sha256:
exported commit short:
exported commit full:
```

## 2. Outside Environment

```text
OS:
Python version:
dependency install result:
solver / PySAT version if reported:
workarounds used:
```

## 3. Returned Artifacts

| Artifact | Rows / size | sha256 |
|---|---:|---|
| `exp43c_primary_manifest_external.jsonl` | pending | pending |
| `exp43c_primary_results_external.jsonl` | pending | pending |
| `exp43c_primary_evaluation_external.json` | pending | pending |
| returned environment memo | pending | pending |

## 4. Frozen-Design Compliance

Check:

1. frozen config used: `analysis/exp43_qcoloring/config/exp43c_primary_config.json`;
2. output directory was separate from official references;
3. no redesign or threshold retuning was reported;
4. no official reference artifacts were overwritten;
5. no workaround changed the frozen interpretation.

## 5. Core Reproduction Checks

Manifest:

```text
external manifest rows:
official manifest rows: 4000
manifest comparison:
```

Primary results:

```text
external result rows:
SAT:
UNSAT:
TIMEOUT:
MALFORMED:
checked core mismatches:
```

Evaluation:

```text
external evaluation hash:
official evaluation hash: 901a307be1cc14ef038388b14becc2536a7247e307bae87a8c6e14757cb96539
qualitative decision reproduced:
```

## 6. Quantitative Summary

| Metric | Outside rerun | Official reference | Judgment |
|---|---:|---:|---|
| rows total | pending | `4000` | pending |
| SAT | pending | `2003` | pending |
| UNSAT | pending | `1997` | pending |
| TIMEOUT | pending | `0` | pending |
| MALFORMED | pending | `0` | pending |
| `fm_plus_n` mean held-out log loss | pending | `0.4401890410875378` | pending |
| `first_moment` mean held-out log loss | pending | `0.44681385336268226` | pending |
| best primary raw baseline | pending | `2.8040186173807204` | pending |
| `cnf_count_plus_n_q` mean held-out log loss | pending | `7.700105445308683` | pending |

Held-out q folds:

| held-out q | Outside `fm_plus_n` | Official `fm_plus_n` | Direction |
|---:|---:|---:|---|
| 3 | pending | `0.5705277449330725` | pending |
| 4 | pending | `0.32338831583926725` | pending |
| 5 | pending | `0.4266510624902738` | pending |

## 7. Interpretation

Choose one:

```text
successful outside-group reproduction
non-failure with minor drift
replication failure requiring dedicated follow-up
```

Boundary:

```text
This report, once filled, applies only to Exp43c q-coloring. It does not close
Mixed-CSP pending returns, observational-branch replication, or non-CSP
repair-flow support.
```

## 8. One-Line Program Update

```text
Exp43c true outside-group rerun: pending / successful / non-failure /
replication-failure.
```
