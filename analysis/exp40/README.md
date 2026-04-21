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
| Trials per cell | 30 |
| Total trials | 120 |

Primary prediction:

```text
accuracy(scoped) > accuracy(subtle) > accuracy(structural)
```

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
