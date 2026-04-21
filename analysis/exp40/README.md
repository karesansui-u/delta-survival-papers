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
