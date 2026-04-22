# Exp44 Cardinality-SAT pilot harness

Status: exploration / pilot harness for the draft Exp44 preregistration. Do not
run primary data collection until the preregistration, grid, generator,
feature schema, and analysis script are frozen.

## Layout

- `preregistration_draft.md`: draft-only experiment design.
- `src/generator.py`: deterministic cardinality-constraint instance generator.
- `src/cnf_encoder.py`: direct forbidden-pattern CNF encoding and semantic verifier.
- `src/solver.py`: optional PySAT wrapper with multiprocessing timeout.
- `src/feature_extractor.py`: preregistered feature / predictor extraction.
- `src/pilot_runner.py`: dry-run and append-safe pilot execution.
- `src/pilot_summary.py`: pilot pass/fallback summary.
- `config/smoke_config.json`: small solver smoke grid.
- `config/pilot_config.json`: draft pilot grid from the preregistration.
- `tests/`: unit tests; solver tests skip if PySAT is unavailable.

## Commands

Run unit tests:

```bash
python3 -m unittest discover -s analysis/exp44_cardinality_sat/tests
```

Inspect the pilot plan without solving:

```bash
python3 analysis/exp44_cardinality_sat/src/pilot_runner.py \
  --config analysis/exp44_cardinality_sat/config/pilot_config.json \
  dry-run
```

Run a small solver smoke test:

```bash
python3 analysis/exp44_cardinality_sat/src/pilot_runner.py \
  --config analysis/exp44_cardinality_sat/config/smoke_config.json \
  --output analysis/exp44_cardinality_sat/data/smoke_results.jsonl \
  run --execute
```

Summarize smoke or pilot output:

```bash
python3 analysis/exp44_cardinality_sat/src/pilot_summary.py \
  analysis/exp44_cardinality_sat/data/smoke_results.jsonl
```

Run the pilot only after review:

```bash
python3 analysis/exp44_cardinality_sat/src/pilot_runner.py \
  --config analysis/exp44_cardinality_sat/config/pilot_config.json \
  --output analysis/exp44_cardinality_sat/data/pilot_results.jsonl \
  run --execute
```

## Guardrails

- Exp44 is exploration / pilot until explicitly frozen.
- Pilot data are not validation evidence.
- The solver endpoint is SAT feasibility, not solver cost.
- SAT models are checked by an independent semantic cardinality verifier.
- Timeout / unknown instances are not silently counted as UNSAT.
- CNF size is recorded as a guardrail baseline, not hidden inside `L`.

