# Frontier Full-Pipeline Pilot

Date: 2026-04-02

This note records the first frontier-model full-pipeline pilot for Paper 3.
It is a single-trial result (`n=1`) and should be read as pilot evidence, not
as a statistical claim.

## Model and protocol

- Model: `Claude Sonnet 4.6`
- Runtime: `claude-cli`
- Pipeline: full DeltaZero pipeline
- Setup: `standard setup`
- Contradiction protocol: `F3`
- Session length: `30 turns`
- Benchmarks: `T15`, `T30`
- Conditions: `ON`, `OFF`, `NC`

## Results

| Condition | T15 overall | T15 fact | T30 overall | T30 fact | T30 rule | T30 contra |
|:--|:--|:--|:--|:--|:--|:--|
| `ON` | `100.0%` | `100.0%` | `97.8%` | `93.3%` | `100.0%` | `100.0%` |
| `OFF` | `77.8%` | `33.3%` | `73.3%` | `26.7%` | `93.3%` | `100.0%` |
| `NC` | `97.8%` | `93.3%` | `97.8%` | `93.3%` | `100.0%` | `100.0%` |

Key reading:

- `ON ≈ NC`
- `ON >> OFF`
- `T30 fact_recall`: `ON = 93.3%`, `NC = 93.3%`, `OFF = 26.7%`

## Interpretation

This pilot is the first local evidence in this project that the full
metabolism pipeline transfers to at least one frontier model.
The result does not replace the open-source `n=3` and sign-test evidence in
Paper 3. It extends the paper by showing that the same qualitative ordering can
appear in a frontier setting when the pipeline is actually enabled.

## Workspace raw result paths

These raw logs currently live in the paired DeltaZero workspace:

- `../delta-zero/data/experiments/stageb_sonnet/trial_01_metabolism_on/summary.json`
- `../delta-zero/data/experiments/stageb_sonnet/trial_01_metabolism_off/summary.json`
- `../delta-zero/data/experiments/stageb_sonnet/trial_01_no_contradiction/summary.json`
