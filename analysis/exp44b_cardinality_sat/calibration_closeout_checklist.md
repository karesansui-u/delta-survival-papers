# Exp44b Calibration Closeout Checklist

Status: required checklist before any Exp44b calibration result may be used to
select a primary window. This is not a result note and not validation evidence.

## 1. Boundary

Exp44b may reuse the Exp44 pilot harness for calibration execution, but the
old Exp44 summary script is not sufficient to decide the Exp44b gate. The
Exp44b closeout must implement the gate in
`analysis/exp44b_cardinality_sat/preregistration_draft.md` exactly.

Until this checklist is completed:

- no primary window is frozen;
- no primary command is written;
- no support / no-support language is allowed;
- Exp44b remains draft / calibration-only.

## 2. Required Inputs

- calibration result JSONL path;
- calibration config path;
- script identity for every runner / parser / summary script used;
- solver backend and timeout policy;
- exact phase namespace.

## 3. Required Gate Checks

The closeout must report all of the following:

1. total row count and expected cell count;
2. `MALFORMED = 0`;
3. timeout rate for every `(mixture, n, rho_fm)` cell, with failure if any
   cell exceeds `5%`;
4. runtime-instability flag for every cell, with failure if median runtime is
   greater than `30` seconds or at least `20%` of completed instances exceed
   `60` seconds;
5. pooled informative rho bands for every mixture, where informative means SAT
   rate in `(5%, 95%)` after excluding timeouts;
6. n-specific primary-eligible windows after the buffered-window rule in
   `analysis/protocols/threshold_local_route_a_v1.md`;
7. monotonicity for all six mixtures, not only a subset;
8. power-collapse diagnostic using absolute Spearman correlation between the
   primary theory predictor and each raw / density / CNF-size baseline, with
   freeze blocked if all such correlations are `>= 0.98`.

## 4. Required Outputs

The default closeout checker is:

```text
analysis/exp44b_cardinality_sat/scripts/calibration_closeout.py
```

The closeout must end with one of three statuses:

```text
calibration_pass
calibration_no_go
calibration_inconclusive
```

If `calibration_pass`, it must also write the exact buffered primary windows
that a later freeze package may use.

If `calibration_no_go` or `calibration_inconclusive`, the same Exp44b design
must not be tuned into a primary. A later attempt must be a new versioned
candidate.

## 5. Non-Claims

The calibration closeout does not establish support. It only decides whether a
separate freeze package may be written.
