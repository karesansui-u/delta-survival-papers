# Exp44b Cardinality-SAT Calibration v1 Closeout Note

Status: calibration no-go. This note records a calibration-only solver run. It
is not a freeze manifest, not a primary validation run, and not Route A
evidence.

Date: 2026-04-28

## 1. Command

```bash
python3 analysis/exp44_cardinality_sat/src/pilot_runner.py \
  --config analysis/exp44b_cardinality_sat/config/calibration_v1_config.json \
  --output analysis/exp44b_cardinality_sat/data/calibration_v1_results.jsonl \
  run --execute
```

Closeout command:

```bash
python3 analysis/exp44b_cardinality_sat/scripts/calibration_closeout.py \
  --config analysis/exp44b_cardinality_sat/config/calibration_v1_config.json \
  --jsonl analysis/exp44b_cardinality_sat/data/calibration_v1_results.jsonl \
  --output-json analysis/exp44b_cardinality_sat/calibration_v1_closeout_summary.json
```

## 2. Run Completeness

- Expected records: `4800`
- Observed records: `4800`
- Expected cells: `96`
- Timeout records: `0`
- Malformed records: `0`

The solver run completed cleanly. The no-go decision is not caused by execution
failure.

## 3. Gate Status

| Gate | Result |
|---|---|
| Complete records | pass |
| Informative rho windows | pass |
| Malformed guard | pass |
| Monotonicity | fail |
| n-specific window | pass |
| Power-collapse diagnostic | pass |
| Runtime guard | pass |
| Timeout guard | pass |

Closeout status:

```text
calibration_no_go
```

## 4. Failed Gate

The failing gate is monotonicity for `M3_threeway_low`.

`M3_threeway_low` SAT rates:

| n | rho values | SAT rates |
|---|---|---|
| `60` | `0.64, 0.68, 0.72, 0.76, 0.80, 0.84, 0.88, 0.92` | `0.64, 0.62, 0.66, 0.50, 0.36, 0.22, 0.16, 0.04` |
| `100` | `0.64, 0.68, 0.72, 0.76, 0.80, 0.84, 0.88, 0.92` | `0.62, 0.70, 0.56, 0.38, 0.14, 0.06, 0.04, 0.00` |

The early low-rho cells have local upward reversals. This violates the
precommitted calibration monotonicity gate even though the overall transition
direction is broadly visible.

## 5. Informative Bands

Pooled informative rho values were found for all mixtures:

| Mixture | Informative rho values |
|---|---|
| `M0_low` | `0.88, 0.90, 0.92, 0.94, 0.96, 0.98, 1.00` |
| `M1_low_med` | `0.86, 0.88, 0.90, 0.92, 0.94, 0.96, 0.98` |
| `M2_bal_low_med` | `0.86, 0.88, 0.90, 0.92, 0.94, 0.96, 0.98` |
| `M3_threeway_low` | `0.64, 0.68, 0.72, 0.76, 0.80, 0.84, 0.88` |
| `M4_threeway_med` | `0.64, 0.68, 0.72, 0.76, 0.80, 0.84, 0.88` |
| `M5_med_high` | `0.64, 0.68, 0.72, 0.76, 0.80, 0.84` |

This is useful calibration information, but it is not sufficient to open a
primary package because the monotonicity gate failed.

## 6. Power-Collapse Diagnostic

The power-collapse diagnostic passed:

- Candidate grid rows: `92`
- Power collapse: `false`
- Spearman absolute cutoff: `0.98`
- Spearman correlations against `fm_plus_n`:
  - `raw_plus_n`: `0.1186629419562746`
  - `density_plus_n`: `0.5532757671712318`
  - `cnf_density_plus_n`: `0.5241522816947377`
  - `cnf_count_plus_n`: `0.3788697343361324`

This means the calibration did not collapse into a trivial power proxy. The
failed decision is specifically the monotonicity gate.

## 7. Interpretation

Exp44b calibration v1 remains calibration-only and should not be promoted to a
freeze manifest or primary validation package.

Do not tune this same Exp44b v1 grid into a primary. A later Cardinality-SAT
attempt may use this as calibration history only if it is opened as a new
versioned attempt with a fresh gate and a new closeout boundary.

See `calibration_v1_row_audit_note.md` for the row-level audit showing that the
failed monotonicity gate was caused by a small local reversal in
`M3_threeway_low`, not by timeout, malformed rows, or power-proxy collapse.
