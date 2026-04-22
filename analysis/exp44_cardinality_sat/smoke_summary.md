# Exp44 Cardinality-SAT smoke summary

Status: smoke / infrastructure check, not pilot evidence and not validation.

Date: 2026-04-23

## 1. Configuration

Smoke used `config/smoke_config.json`:

```text
mixtures = {M0_low, M2_bal_low_med, M5_med_high}
n = 24
rho_fm = {0.70, 1.00, 1.30}
instances_per_cell = 5
timeout = 20 seconds
solver = Minisat22 via python-sat
```

Total:

```text
3 mixtures * 1 n-value * 3 rho-values * 5 = 45 instances
```

Raw JSONL and JSON summaries are in `analysis/exp44_cardinality_sat/data/`,
which is intentionally gitignored.

## 2. Outcome

```text
records: 45
SAT: 14
UNSAT: 31
TIMEOUT: 0
MALFORMED: 0
SAT assignment_verified: 14 / 14
```

The smoke run exercises the full solver path:

- deterministic instance generation;
- direct forbidden-pattern CNF encoding;
- PySAT / Minisat22 solving;
- model decoding;
- independent semantic cardinality verification;
- JSONL output;
- pilot summary generation.

## 3. Cell-level sanity

| mixture | rho_fm | SAT rate |
|---|---:|---:|
| M0_low | 0.70 | 1.00 |
| M0_low | 1.00 | 0.00 |
| M0_low | 1.30 | 0.00 |
| M2_bal_low_med | 0.70 | 1.00 |
| M2_bal_low_med | 1.00 | 0.20 |
| M2_bal_low_med | 1.30 | 0.00 |
| M5_med_high | 0.70 | 0.40 |
| M5_med_high | 1.00 | 0.20 |
| M5_med_high | 1.30 | 0.00 |

This pattern is monotone non-increasing in `rho_fm` for all three smoke
mixtures. The smoke run is intentionally small, so its SAT rates are not
evidence for the Exp44 hypotheses.

## 4. Interpretation

The Exp44 harness is infrastructure-clean at smoke scale:

```text
0 timeout
0 malformed encoding
all SAT assignments verified semantically
SAT and UNSAT outcomes both generated
```

The next step is the draft pilot grid in `config/pilot_config.json`, unless the
preregistration draft is revised before pilot.

Primary validation is still not allowed. Exp44 remains in exploration / pilot
calibration until the freeze checklist in `preregistration_draft.md` is
completed.

