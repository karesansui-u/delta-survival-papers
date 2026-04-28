# Exp44b Cardinality-SAT Threshold-Local Candidate

Status: calibration-v1 no-go. This is a draft / calibration-facing package
only. It is not frozen and contains no validation evidence.

## Purpose

Exp44b is the disciplined successor to the Exp44 Cardinality-SAT calibration
history. Exp44 showed that the generator, CNF encoder, solver path, semantic
verifier, and monotonicity checks are infrastructure-clean, but that the
low-drift mixtures had transition windows too sharp for the precommitted grid.

Exp44b therefore does not rescue Exp44. It treats all Exp44 smoke / runtime /
pilot_v2 / pilot_v3 outputs as calibration history and opened a new
threshold-local candidate with a finer, mixture-specific calibration grid.
That calibration-v1 run completed cleanly but failed the precommitted
monotonicity gate, so Exp44b v1 is closed as calibration no-go.

## Files

- `preregistration_draft.md`: fresh Exp44b design and decision rules.
- `config/calibration_v1_config.json`: proposed calibration-only grid.
- `calibration_closeout_checklist.md`: required gate checklist before any
  calibration result may select a primary window.
- `scripts/calibration_closeout.py`: Exp44b-specific closeout gate checker.
- `data/calibration_v1_results.jsonl`: completed calibration-v1 solver output.
- `calibration_v1_closeout_summary.json`: machine-readable closeout summary.
- `calibration_v1_closeout_note.md`: reader-facing calibration-v1 no-go note.
- `calibration_v1_row_audit_note.md`: row-level explanation of why the v1
  no-go is local and retryable only as a future versioned design.

The current draft reuses the existing Exp44 harness in
`analysis/exp44_cardinality_sat/src/`. That reuse is allowed only for
calibration planning. Before any primary validation, the freeze package must
lock the generator identity, phase namespace, manifest script, feature schema,
and evaluation script explicitly.

The old Exp44 `pilot_summary.py` is not sufficient to decide the Exp44b gate.
The Exp44b-specific closeout checked all gates in
`calibration_closeout_checklist.md`. It returned `calibration_no_go` because
the `M3_threeway_low` monotonicity gate failed.

## Safe Commands

Dry-run the calibration plan without solving:

```bash
python3 analysis/exp44_cardinality_sat/src/pilot_runner.py \
  --config analysis/exp44b_cardinality_sat/config/calibration_v1_config.json \
  --output analysis/exp44b_cardinality_sat/data/calibration_v1_results.jsonl \
  dry-run
```

Do not run additional solver calibration or primary validation from this v1
design. Primary validation would require a later versioned attempt, a new
calibration boundary, a freeze manifest, and a separate `primary_v1` seed
stream.

After a calibration-only solver run, use:

```bash
python3 analysis/exp44b_cardinality_sat/scripts/calibration_closeout.py \
  --config analysis/exp44b_cardinality_sat/config/calibration_v1_config.json \
  --jsonl analysis/exp44b_cardinality_sat/data/calibration_v1_results.jsonl \
  --output-json analysis/exp44b_cardinality_sat/calibration_v1_closeout_summary.json
```

Current closeout status:

```text
calibration_no_go
```
