# Data Access Guide

This file exists so that external LLMs and reviewers can find all data without searching.

## Quick summary (read this first)

- **Prompts** (exact text used in experiments): [`analysis/llm/prompts.py`](analysis/llm/prompts.py)
- **Experiment scripts**: [`analysis/`](analysis/)
- **Result summaries** (small JSON, GitHub-readable): [`data/summaries/`](data/summaries/)
- **Raw trial data** (turn-by-turn logs, benchmarks): [`data/raw/`](data/raw/) — all on GitHub

## Evidence hierarchy / 証拠の扱い

The main public evidence is the LLM contradiction experiments listed below and
the Lean-checked SAT / Bernoulli-CSP finite-horizon chain. Older computational
validation runs from the previous `ugentropy-papers` workspace are useful as
exploratory or sanity evidence, but they should not be treated as the primary
public dataset unless separately archived.

Legacy local workspace:
`/Users/sunagawa/Project/ugentropy-papers/analysis/computational_validation/`

Most reusable legacy SAT files:

| File | Use in the current papers |
|------|---------------------------|
| `results/phase2c_solver_comparison_20260308_035525.json` | Solver comparison sanity check: CDCL `c = 0.2506`, WalkSAT `c = 0.1843`, with high linear fit quality |
| `results/prediction_test_20260308_195043.json` | Cross-`N` prediction check: pooled CDCL `c ≈ 0.221`, WalkSAT `c ≈ 0.149`; useful as exploratory support, not a replacement for the current public summaries |
| `results/bootstrap_ci_20260308_211934.json` | Bootstrap confidence intervals for solver-specific `c`; useful for uncertainty discussion |

Other legacy files, such as percolation, branching, control, SIR, and real-data
fits, are best read as Route A/B sanity checks or hypothesis-generation runs.
They are not current headline evidence for universality claims.

---

## Raw data on GitHub — data/raw/

All files are directly fetchable via GitHub raw URLs (no redirect, no auth).

### Paper 1 — Exp.35 (δ=0 control, 6 models)

| File | GitHub raw URL |
|------|---------------|
| Prompts (all experiments) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/llm/prompts.py |
| Control trials (all models) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/exp35/exp35_delta_zero_control_trials.json |
| Llama 3.1:8b trials | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/exp35/exp35_llama8b_trials.json |
| Sonnet batch trials | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/exp35/exp35_sonnet_batch/sonnet_trials.json |

### Paper 1 — Exp.36 (810 trials, 3 models × δ × context length)

| File | GitHub raw URL |
|------|---------------|
| GPT-4.1-nano trials (270 trials) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/data/raw/exp36_gpt-4_1-nano_trials.jsonl |
| GPT-4.1-mini trials (270 trials) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/data/raw/exp36_gpt-4_1-mini_trials.jsonl |
| GPT-4.1-nano judged | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/exp36/exp36_gpt-4_1-nano_judged.jsonl |
| GPT-4.1-mini judged | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/exp36/exp36_gpt-4_1-mini_judged.jsonl |
| Gemini trials (270 trials) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/data/raw/exp36_gemini-3_1-flash-lite-preview_trials.jsonl |
| Gemini judged | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/exp36/exp36_gemini-3_1-flash-lite-preview_judged.jsonl |
| Reassignment test (Gemini δ₁) | https://raw.githubusercontent.com/karesansui-u/delta-survival-papers/main/analysis/exp36/exp36c_reassignment_test.jsonl |

### Paper 1 — Exp.39 prospective contradiction-dominance replication

Focused 2×2 prospective replication of the primary structural-persistence
contrast: `32K structural contradiction` vs `256K filler-only`.

| File | Description |
|------|-------------|
| [Exp.39 preregistration](analysis/exp39/exp39_preregistration.md) | Frozen design, primary prediction, and falsification rule |
| [Exp.39 results summary](analysis/exp39/exp39_results_summary.md) | `gpt-4.1-nano`: zero/32K `29/30`, zero/256K `19/30`, structural/32K `0/30`, structural/256K `0/30` |
| [Exp.39 summary JSON](analysis/exp39/exp39_gpt-4_1-nano_summary.json) | Machine-readable cell counts and primary margin |
| [Exp.39 raw trials](analysis/exp39/exp39_gpt-4_1-nano_trials.jsonl) | 120 raw trial records |

### Paper 3 — Baseline model comparison for Exp.36/39

Zero-cost reanalysis of the trial-level Exp.36/39 data. It compares three
predictive baselines: token length only, contradiction presence without type,
and structure-aware contradiction type.

| File | Description |
|------|-------------|
| [Baseline comparison script](analysis/baseline_comparison/compare_structural_models.py) | Fits ridge-regularized logistic models and evaluates leave-one-model-out, leave-one-context-out, and Exp.39 prospective prediction |
| [Baseline comparison summary](analysis/baseline_comparison/baseline_comparison_results_summary.md) | Human-readable table: structure-aware model has the best log loss on Exp.36 CV and Exp.39 |
| [Baseline comparison JSON](analysis/baseline_comparison/baseline_comparison_results.json) | Machine-readable metrics, coefficients, and Exp.39 predicted cell probabilities |

### Paper 3 — Exp.40 prospective contradiction-quality test

Exp.40 tests the strongest remaining baseline from the Exp.36/39
reanalysis: contradiction presence without contradiction quality. It fixes
context length at 32K and compares `scoped`, `subtle`, and `structural`
contradiction-like conditions with 50 trials per cell. In the preregistered
coding, `quality_blind` treats all three primary conditions as contradiction
present, while `structure_aware` treats `scoped` as repaired / zero-like.

Result on `gpt-4.1-mini`: `zero_sanity = 50/50`, `scoped = 50/50`,
`subtle = 23/50`, `structural = 0/50`. Strong support passed. Leave-one-target-out
primary log loss: `structure_aware = 0.2763`, `quality_blind = 0.6944`.

| File | Description |
|------|-------------|
| [Exp.40 README](analysis/exp40/README.md) | Design summary and commands |
| [Exp.40 preregistration](analysis/exp40/exp40_preregistration.md) | Frozen prediction, exclusions, and falsification rules |
| [Exp.40 runner](analysis/exp40/exp40_contradiction_quality.py) | Append-safe API runner; refuses paid calls without `--execute` |
| [Exp.40 results summary](analysis/exp40/exp40_results_summary.md) | Human-readable result table and Fisher exact tests |
| [Exp.40 raw trials](analysis/exp40/exp40_gpt-4_1-mini_trials.jsonl) | 200 raw trial records |
| [Exp.40 summary JSON](analysis/exp40/exp40_gpt-4_1-mini_summary.json) | Machine-readable counts, prediction flags, and Fisher exact tests |
| [Exp.40 model comparison](analysis/exp40/exp40_gpt-4_1-mini_model_comparison.md) | Human-readable quality-blind vs structure-aware comparison |
| [Exp.40 model comparison JSON](analysis/exp40/exp40_gpt-4_1-mini_model_comparison.json) | Machine-readable leave-one-target-out metrics |

### Paper 3 — Exp.42 scope-strength dose-response

Exp.42 decomposes the Exp.40 `scoped` effect into four preregistered
scope-strength levels at fixed 32K context: `strong_scope`,
`medium_scope`, `weak_scope`, and `subtle`. It tests whether the repair
effect requires explicit imperative language, or whether weaker attribution
and temporal/dataset markers also carry predictive information.

Result on `gpt-4.1-mini`: `strong_scope = 50/50`, `medium_scope = 49/50`,
`weak_scope = 42/50`, `subtle = 10/50`, `zero_sanity = 20/20`,
`structural_anchor = 0/20`. The preregistered primary ordering passed, while
the preregistered strong-support margin did not pass because the
strong-vs-medium gap was only 2 percentage points. Leave-one-target-out log
loss: `scope_gradient = 0.2646`, `binary_scoped = 0.3012`,
`quality_blind = 0.5577`.

Row-level analysis shows that exact wrong-sum adoption fell from 25/40
subtle mistakes to 1/8 weak-scope mistakes and 0 in medium/strong, supporting
an attribution-as-repair interpretation. OSF addendum:
[zip](https://osf.io/mdh7b/files/osfstorage/69e7b24315d73a03cafd8705),
[manifest](https://osf.io/mdh7b/files/osfstorage/69e7b246a1f38466e6923969).

| File | Description |
|------|-------------|
| [Exp.42 README](analysis/exp42/README.md) | Design summary and commands |
| [Exp.42 preregistration](analysis/exp42/exp42_preregistration.md) | Frozen prediction, exclusions, model comparison plan, and diagnostics |
| [Exp.42 runner](analysis/exp42/exp42_scope_gradient.py) | Append-safe API runner; refuses paid calls without `--execute` |
| [Exp.42 results summary](analysis/exp42/exp42_gpt-4_1-mini_results_summary.md) | Human-readable result table and Fisher exact tests |
| [Exp.42 raw trials](analysis/exp42/exp42_gpt-4_1-mini_trials.jsonl) | 240 raw trial records |
| [Exp.42 summary JSON](analysis/exp42/exp42_gpt-4_1-mini_summary.json) | Machine-readable counts and preregistered flags |
| [Exp.42 model comparison](analysis/exp42/exp42_gpt-4_1-mini_model_comparison.md) | Human-readable scope-gradient vs binary/quality-blind comparison |
| [Exp.42 model comparison JSON](analysis/exp42/exp42_gpt-4_1-mini_model_comparison.json) | Machine-readable leave-one-target-out metrics |
| [Exp.42 row-level script](analysis/exp42/analyze_exp42_rows.py) | Reproducible row-level diagnostics |
| [Exp.42 row-level summary](analysis/exp42/exp42_gpt-4_1-mini_row_analysis.md) | Human-readable row-level analysis |
| [Exp.42 row-level JSON](analysis/exp42/exp42_gpt-4_1-mini_row_analysis.json) | Machine-readable row-level analysis |

### Paper 3 — Exp.41 cross-model width replication

Exp.41 tests whether the Exp.40 scope-vs-structural direction survives beyond
`gpt-4.1-mini`. The preregistered primary decision is deliberately narrow:
`accuracy(scoped) > accuracy(structural)` in both primary models. `subtle` is
reported as a secondary, model-sensitive diagnostic rather than as the primary
width criterion.

Result: primary width support passed in 2/2 primary models. `gpt-4.1-nano`:
`scoped = 27/30`, `subtle = 30/30`, `structural = 1/30`, `zero_sanity = 10/10`.
`gemini-3.1-flash-lite-preview`: `scoped = 30/30`, `subtle = 12/30`,
`structural = 14/30`, `zero_sanity = 10/10`. Descriptive leave-one-(model,target)-out
log loss: `structure_aware_ordered = 0.4715`, `structure_aware_categorical = 0.5016`,
`quality_blind = 0.6588`. OSF addendum:
[zip](https://files.us.osf.io/v1/resources/mdh7b/providers/osfstorage/69e7bebe273a040976affc88),
[manifest](https://files.us.osf.io/v1/resources/mdh7b/providers/osfstorage/69e7bec1760e3d5118fd836a).

| File | Description |
|------|-------------|
| [Exp.41 README](analysis/exp41/README.md) | Design summary and commands |
| [Exp.41 preregistration](analysis/exp41/exp41_preregistration.md) | Frozen width prediction, exclusions, and reporting plan |
| [Exp.41 runner](analysis/exp41/exp41_width_replication.py) | Append-safe API runner; refuses paid calls without `--execute` |
| [Exp.41 results summary](analysis/exp41/exp41_results_summary.md) | Human-readable result table and Fisher exact tests |
| [Exp.41 nano raw trials](analysis/exp41/exp41_gpt-4_1-nano_trials.jsonl) | 100 raw trial records |
| [Exp.41 Gemini raw trials](analysis/exp41/exp41_gemini-3_1-flash-lite-preview_trials.jsonl) | 100 raw trial records |
| [Exp.41 summary JSON](analysis/exp41/exp41_summary.json) | Machine-readable counts and preregistered flags |
| [Exp.41 model comparison](analysis/exp41/exp41_model_comparison.md) | Human-readable descriptive baseline-model comparison |
| [Exp.41 model comparison JSON](analysis/exp41/exp41_model_comparison.json) | Machine-readable leave-one-(model,target)-out metrics |

### Route A — Mixed-CSP empirical universality test

Mixed-CSP tests whether drift-weighted structural loss `L` predicts feasibility
better than raw constraint count in a mixed SAT/NAE Bernoulli-CSP domain. The
official primary run uses 12,000 solver records across 3 values of `n`, 4
densities, and 5 SAT/NAE mixture weights.

Result: all preregistered support criteria passed. The primary model
`L_plus_n` achieved leave-one-mixture-out log loss `0.0970`, compared with
`raw_plus_n = 0.7525`. Strong support passed with an 87.1% relative improvement.
The theory-pure `first_moment` predictor also beat `raw_plus_n`
(`0.1489 < 0.7525`), and the encoding guardrail passed
(`L_plus_n = 0.0970 <= cnf_count_plus_n = 0.1010`). OSF addendum:
[zip](https://osf.io/download/69e826573b65e7b53bfd8b7e/),
[manifest](https://osf.io/download/69e8265a30357781bafd90d6/).

| File | Description |
|------|-------------|
| [Mixed-CSP README](analysis/route_a_mixed_csp/README.md) | Design summary, commands, verifier-fix note, and status |
| [Mixed-CSP preregistration](analysis/route_a_mixed_csp/mixed_csp_preregistration.md) | Frozen primary prediction, support criteria, and guardrails |
| [Mixed-CSP runner](analysis/route_a_mixed_csp/run_mixed_csp.py) | Append-safe smoke / pilot / primary runner |
| [Mixed-CSP analyzer](analysis/route_a_mixed_csp/analyze_mixed_csp.py) | Leave-one-mixture-out model-comparison analysis |
| [Official primary records](analysis/route_a_mixed_csp/mixed_csp_primary_official_2026-04-22.jsonl) | 12,000 official solver records; aborted attempt excluded |
| [Mixed-CSP results summary](analysis/route_a_mixed_csp/mixed_csp_results_summary.md) | Human-readable primary model-comparison summary |
| [Mixed-CSP results JSON](analysis/route_a_mixed_csp/mixed_csp_results.json) | Machine-readable primary analysis and support flags |

### Paper 3 — Experiment 3: Three-condition (gemma3:27b, n=3, 180 turns each)

Trials 2–4 are the three replicates reported in the paper (Table 3).

| Condition | Trial | turn_logs | summary | benchmarks |
|-----------|-------|-----------|---------|------------|
| Metabolism ON | trial_02 | [turn_logs](data/raw/deltazero_gemma27b/trial_02_metabolism_on/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_02_metabolism_on/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_02_metabolism_on/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_02_metabolism_on/benchmarks/benchmark_turn0180.json) |
| Metabolism ON | trial_03 | [turn_logs](data/raw/deltazero_gemma27b/trial_03_metabolism_on/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_03_metabolism_on/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_03_metabolism_on/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_03_metabolism_on/benchmarks/benchmark_turn0180.json) |
| Metabolism ON | trial_04 | [turn_logs](data/raw/deltazero_gemma27b/trial_04_metabolism_on/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_04_metabolism_on/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_04_metabolism_on/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_04_metabolism_on/benchmarks/benchmark_turn0180.json) |
| No contradiction (δ=0) | trial_02 | [turn_logs](data/raw/deltazero_gemma27b/trial_02_no_contradiction/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_02_no_contradiction/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_02_no_contradiction/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_02_no_contradiction/benchmarks/benchmark_turn0180.json) |
| No contradiction (δ=0) | trial_03 | [turn_logs](data/raw/deltazero_gemma27b/trial_03_no_contradiction/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_03_no_contradiction/summary.json) | — |
| No contradiction (δ=0) | trial_04 | [turn_logs](data/raw/deltazero_gemma27b/trial_04_no_contradiction/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_04_no_contradiction/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_04_no_contradiction/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_04_no_contradiction/benchmarks/benchmark_turn0180.json) |
| Metabolism OFF | trial_02 | [turn_logs](data/raw/deltazero_gemma27b/trial_02_metabolism_off/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_02_metabolism_off/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_02_metabolism_off/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_02_metabolism_off/benchmarks/benchmark_turn0180.json) |
| Metabolism OFF | trial_03 | [turn_logs](data/raw/deltazero_gemma27b/trial_03_metabolism_off/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_03_metabolism_off/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_03_metabolism_off/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_03_metabolism_off/benchmarks/benchmark_turn0180.json) |
| Metabolism OFF | trial_04 | [turn_logs](data/raw/deltazero_gemma27b/trial_04_metabolism_off/turn_logs.json) | [summary](data/raw/deltazero_gemma27b/trial_04_metabolism_off/summary.json) | [T90](data/raw/deltazero_gemma27b/trial_04_metabolism_off/benchmarks/benchmark_turn0090.json) [T180](data/raw/deltazero_gemma27b/trial_04_metabolism_off/benchmarks/benchmark_turn0180.json) |

### Paper 3 — Experiment 1: Cross-model sign test (8 models, 11 pairs)

| Model | Trials | Location |
|-------|--------|----------|
| gemma3:27b (T1–T4) | ON/OFF | [data/raw/deltazero_gemma27b/](data/raw/deltazero_gemma27b/) |
| gemma3:27b (T1, old code) | ON/OFF | [data/raw/deltazero_gemma/](data/raw/deltazero_gemma/) |
| gemma3:12b (T1, T4) | ON/OFF/NC | [data/raw/deltazero_gemma12/](data/raw/deltazero_gemma12/) |
| llama3.1:8b (T1–T4) | ON/OFF/NC | [data/raw/deltazero_llama31/](data/raw/deltazero_llama31/) |
| mistral-nemo:12b (T1–T4) | ON/OFF/NC | [data/raw/deltazero_mistral/](data/raw/deltazero_mistral/) |
| deepseek-r1:14b (T1–T2) | ON/OFF | [data/raw/deltazero_deepseek/](data/raw/deltazero_deepseek/) |
| qwen2.5:14b (T1) | ON/OFF | [data/raw/deltazero_qwen25/](data/raw/deltazero_qwen25/) |
| phi4 (excluded) | ON/OFF | [data/raw/deltazero_phi4/](data/raw/deltazero_phi4/) |

### Paper 3 — Experiment 2: Controlled ablation (mistral-nemo:12b)

Covered by `deltazero_gemma` (old code) and `deltazero_mistral` (new code) above.

### Paper 3 — Capability–vulnerability paradox (delta_c factor analysis)

| File | Description |
|------|-------------|
| [delta_c/](data/raw/delta_c/) | GPT-4o, GPT-4o-mini, Haiku — T1×F1/F2/F3 |
| [delta_c/phase1/](data/raw/delta_c/phase1/) | Sonnet — T1–T3×F1/F2/F3 |

### Paper 3 — Frontier model replication (Exp35-R)

| Model | Location |
|-------|----------|
| Sonnet 4.6 | [data/raw/exp35_claude/](data/raw/exp35_claude/) |
| Gemini 3.1 Flash Lite | [data/raw/exp35_gemini/](data/raw/exp35_gemini/) |
| GPT-4o | [data/raw/exp35_gpt4o/](data/raw/exp35_gpt4o/) |

### Paper 3 — delta-prune defense test (n=1)

[data/raw/delta_prune_defense/](data/raw/delta_prune_defense/) — A_no_prune.json, B_reverse_prune.json, summary.json

### Paper 3 — Fact recall direct control (GPT-4o non-retention)

[data/raw/fact_recall_direct/](data/raw/fact_recall_direct/) — summary.json

### Paper 3 — Frontier full-pipeline controlled replication (Sonnet 4.6, n=3)

[paper3/frontier_full_pipeline_pilot.md](paper3/frontier_full_pipeline_pilot.md) — summarized three-condition controlled replication (`ON / OFF / NC`), aggregate statistics, and workspace raw-log locations

---

## OSF backup — https://osf.io/mdh7b/overview

Large files and additional supplements are also archived at OSF. Start from the project overview page if you want the landing entry rather than direct file downloads.
Direct download links (no redirect):

| File | Direct download |
|------|----------------|
| GPT-4.1-nano trials (270 trials) | https://osf.io/download/69cc2cdc8ae788fce7460979/ |
| GPT-4.1-mini trials (270 trials) | https://osf.io/download/69cc2ce88ae788fce7460978/ |
| Gemini trials (270 trials) | https://osf.io/download/69cc2cead9fd2082f051e161/ |

---

## Key statistics (for quick verification)

**Paper 3 — Three-condition (gemma3:27b, n=3, 180 turns each):**
- Metabolism ON: 73.3% ± 6.7
- No contradictions (δ=0): 56.7% ± 5.8
- Metabolism OFF: 21.1% ± 5.1
- KW p=0.027; all pairwise MW p=0.05 (minimum achievable for n=3)

**Paper 3 — Sign test (8 models, 11 trial pairs):**
- 9 wins for ON / 1 for OFF / 1 TIE
- p = 0.0107 (one-sided sign test, n=10 non-tied)
- Conservative by-model: 6/7 models, p = 0.0625
- Largest effect: +42.2pp (mistral-nemo:12b T2)

**Paper 1 — Exp.36 (δ × context length):**
- 810 trials (270 per model: GPT-4.1-nano, GPT-4.1-mini, Gemini Flash Lite)
- Design: 3-digit addition task, δ ∈ {zero, subtle, structural} × L ∈ {short, medium, long}

**Paper 1 — Multi-attractor prediction:**
- P(correct) = 1/(1 + K/L), K = 19.5 ± 3.4 (thousands of tokens)
- Confirmed at 5 context lengths (32K–512K), MAE 2%
- Prediction derived from 3 data points; 2 out-of-sample predictions within 1%
