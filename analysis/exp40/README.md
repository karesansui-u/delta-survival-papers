# Experiment 40: Contradiction Quality Under Matched Presence

Exp.40 is a prospective follow-up to the Exp.36/39 baseline comparison.

The goal is to test the strongest remaining baseline: contradiction presence
without contradiction quality. Context length is fixed at 32K, and the primary
conditions all contain task-variable-related conflict-like information.

## Design

| Factor | Levels |
|---|---|
| Primary model | `gpt-4.1-mini` |
| Context length | 32K |
| Conditions | `zero_sanity`, `scoped`, `subtle`, `structural` |
| Trials per cell | 50 |
| Total trials | 200 |
| Temperature | 1.0 |

Primary prediction:

```text
accuracy(zero_sanity) ≈ accuracy(scoped) > accuracy(subtle) > accuracy(structural)
```

The key baseline comparison is quality-blind contradiction presence versus a
structure-aware coding in which `scoped` is treated as repaired / zero-like.

## Files

| File | Purpose |
|---|---|
| `exp40_preregistration.md` | Frozen design, primary prediction, exclusions, falsification rules |
| `exp40_contradiction_quality.py` | Append-safe runner and summarizer |
| `exp40_results_summary.md` | Human-readable result table |
| `analyze_exp40_results.py` | Leave-one-target-out baseline comparison |
| `exp40_gpt-4_1-mini_model_comparison.md` | Human-readable baseline comparison |

## Usage

Dry run only:

```bash
python3 analysis/exp40/exp40_contradiction_quality.py dry-run
```

Paid API execution:

```bash
python3 analysis/exp40/exp40_contradiction_quality.py run --execute
```

Summarize completed trials:

```bash
python3 analysis/exp40/exp40_contradiction_quality.py summarize
```

The runner refuses paid API calls unless `--execute` is passed.

## Result

`gpt-4.1-mini`, 200 trials:

| Condition | Accuracy |
|---|---:|
| `zero_sanity` | 50/50 = 1.00 |
| `scoped` | 50/50 = 1.00 |
| `subtle` | 23/50 = 0.46 |
| `structural` | 0/50 = 0.00 |

Primary prediction and strong support both passed.

Leave-one-target-out primary log loss:

| Model | Primary log loss |
|---|---:|
| `structure_aware` | 0.2763 |
| `quality_blind` | 0.6944 |
