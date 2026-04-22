# Exp43 q-coloring pilot harness

Status: draft harness for the Exp43 preregistration. Do not run primary data
collection until `v2/data/exp43_qcoloring_preregistration_draft.md` is frozen.

## Layout

- `src/generator.py`: deterministic `G(n,m)` generation from `(q,n,rho_fm,idx)`.
- `src/cnf_encoder.py`: pairwise q-coloring CNF encoding and verifier.
- `src/solver.py`: optional PySAT wrapper with multiprocessing timeout.
- `src/feature_extractor.py`: preregistered feature / predictor extraction.
- `src/pilot_runner.py`: dry-run and append-safe pilot execution.
- `src/pilot_summary.py`: pilot pass/fallback summary.
- `config/pilot_config.json`: draft pilot grid.
- `config/pilot_v2_config.json`: preregistered fallback pilot grid after the
  pilot v1 addendum.
- `tests/`: unit tests that avoid PySAT unless the optional solver test can run.

## Commands

Run unit tests:

```bash
python3 -m unittest discover -s analysis/exp43_qcoloring/tests
```

Inspect the pilot plan without solving:

```bash
python3 analysis/exp43_qcoloring/src/pilot_runner.py dry-run
```

Run a small solver smoke test after PySAT is installed:

```bash
python3 analysis/exp43_qcoloring/src/pilot_runner.py \
  --config analysis/exp43_qcoloring/config/smoke_config.json \
  --output analysis/exp43_qcoloring/data/smoke_results.jsonl \
  run --execute
```

Run the pilot only after review:

```bash
python3 analysis/exp43_qcoloring/src/pilot_runner.py run --execute
```

Run the fallback pilot v2:

```bash
python3 analysis/exp43_qcoloring/src/pilot_runner.py \
  --config analysis/exp43_qcoloring/config/pilot_v2_config.json \
  --output analysis/exp43_qcoloring/data/pilot_v2_results.jsonl \
  run --execute
```

Summarize pilot output:

```bash
python3 analysis/exp43_qcoloring/src/pilot_summary.py \
  analysis/exp43_qcoloring/data/pilot_results.jsonl \
  --output analysis/exp43_qcoloring/data/pilot_summary.json
```

## Guardrails

- The solver endpoint is q-colorability / feasibility, not solver cost.
- The solver result is checked by an independent coloring verifier on the
  original graph edges.
- Timeout / unknown instances are not silently counted as uncolorable.
- The harness is implementation support for the preregistration, not a frozen
  preregistration by itself.
