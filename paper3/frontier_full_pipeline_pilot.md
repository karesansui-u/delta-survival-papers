# Frontier Full-Pipeline Controlled Replication

Date: 2026-04-02

This note records the completed frontier-model full-pipeline replication for
Paper 3. It supersedes the earlier `n=1` Sonnet pilot with a completed
three-condition replication (`n=3`) under the same 30-turn Stage B protocol.

## Model and protocol

- Model: `Claude Sonnet 4.6`
- Runtime: `claude-cli`
- Pipeline: full DeltaZero pipeline
- Setup: `standard setup`
- Contradiction protocol: `F3`
- Session length: `30 turns`
- Benchmarks: `T15`, `T30`
- Conditions: `ON`, `OFF`, `NC`
- Trials per condition: `n=3`

## Results

| Condition | T15 overall | T15 fact | T30 overall | T30 fact | T30 rule | T30 contra |
|:--|:--|:--|:--|:--|:--|:--|
| `ON` | `100.0 ± 0.0%` | `100.0 ± 0.0%` | `98.5 ± 1.3%` | `95.6 ± 3.8%` | `100.0 ± 0.0%` | `100.0 ± 0.0%` |
| `OFF` | `87.4 ± 8.4%` | `62.2 ± 25.2%` | `69.6 ± 8.4%` | `46.7 ± 29.1%` | `93.3 ± 0.0%` | `68.9 ± 53.9%` |
| `NC` | `99.3 ± 1.3%` | `97.8 ± 3.8%` | `99.3 ± 1.3%` | `97.8 ± 3.8%` | `100.0 ± 0.0%` | `100.0 ± 0.0%` |

Key reading:

- `ON ≈ NC`
- `ON >> OFF`
- `T30 fact_recall` means: `ON = 95.6%`, `NC = 97.8%`, `OFF = 46.7%`
- `ON > OFF` holds in all three trials at `T30` for both overall accuracy and fact recall
- `ON` and `NC` remain within `2.2pp` on `T30 overall` and within `6.7pp` on `T30 fact_recall` in all three trials

## Interpretation

This replication is the first controlled frontier evidence in this project that
the full metabolism pipeline transfers to at least one frontier model.
The result does not replace the open-source `n=3` and sign-test evidence in
Paper 3. It extends the paper by showing that the same qualitative ordering
persists across three Sonnet trials when the pipeline is actually enabled.

One `OFF` trial shifted its main failure mode from fact recall to contradiction
detection (`T30 contra = 6.7%`), which inflated variance. Even so, the
qualitative ordering remained unchanged.

## Workspace raw result paths

These raw logs currently live in the paired DeltaZero workspace:

- `../delta-zero/data/experiments/stageb_sonnet/trial_01_metabolism_on/summary.json`
- `../delta-zero/data/experiments/stageb_sonnet/trial_02_metabolism_on/summary.json`
- `../delta-zero/data/experiments/stageb_sonnet/trial_03_metabolism_on/summary.json`
- `../delta-zero/data/experiments/stageb_sonnet/trial_01_metabolism_off/summary.json`
- `../delta-zero/data/experiments/stageb_sonnet/trial_02_metabolism_off/summary.json`
- `../delta-zero/data/experiments/stageb_sonnet/trial_03_metabolism_off/summary.json`
- `../delta-zero/data/experiments/stageb_sonnet/trial_01_no_contradiction/summary.json`
- `../delta-zero/data/experiments/stageb_sonnet/trial_02_no_contradiction/summary.json`
- `../delta-zero/data/experiments/stageb_sonnet/trial_03_no_contradiction/summary.json`
- `../delta-zero/data/experiments/stageb_sonnet/aggregate_summary.json`
