# Reproduction Guide

This repository currently centers on the `v2` reader-facing map, integrated
overview, main theory spine (`1` and `2`), operational discipline note, Route
A/C anchors, technical supplements, their PDF builds, supporting experiment
code, and Lean formalization.

Raw data, logs, and PDF mirrors are available at [osf.io/mdh7b](https://osf.io/mdh7b).

## Setup

Primary public repository:

```bash
git clone https://codeberg.org/delta-survival/papers.git delta-survival-paper
cd delta-survival-paper
pip install -r requirements.txt
```

## Current Reader-Facing Order (v2)

Reader orientation:

- `v2/補論_構造持続理論の構成地図.md`
- `v2/0_構造持続理論の統合版.md`
- `v2/1_構造持続の最小形式.md`
- `v2/2_構造持続の収支原理.md`
- `v2/補論_構造持続理論の運用規律.md`

Route A / C anchors:

- `v2/補論_有限CSPにおける構造持続の予測力.md`
- `v2/Companion_RouteC_推論時の構造劣化.md`
- `v2/Companion_RouteC_継続学習時の構造的忘却.md`

Technical supplements:

- `v2/補論_構造持続における資源項Mの操作的定式化.md`
- `v2/補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み.md`
- `v2/補論_非CSP古典例における構造持続の収支原理の最小アンカー.md`
- `v2/補論_構造持続の条件つき導出.md`
- `v2/補論_構造持続の収支原理の詳細展開.md`

Built PDFs:

- `v2/pdf用/補論_構造持続理論の構成地図.pdf`
- `v2/pdf用/0_構造持続理論の統合版.pdf`
- `v2/pdf用/1_構造持続の最小形式.pdf`
- `v2/pdf用/2_構造持続の収支原理.pdf`
- `v2/pdf用/補論_構造持続理論の運用規律.pdf`
- `v2/pdf用/補論_有限CSPにおける構造持続の予測力.pdf`
- `v2/pdf用/Companion_RouteC_推論時の構造劣化.pdf`
- `v2/pdf用/Companion_RouteC_継続学習時の構造的忘却.pdf`
- `v2/pdf用/補論_構造持続における資源項Mの操作的定式化.pdf`
- `v2/pdf用/補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み.pdf`
- `v2/pdf用/補論_非CSP古典例における構造持続の収支原理の最小アンカー.pdf`
- `v2/pdf用/補論_構造持続の条件つき導出.pdf`
- `v2/pdf用/補論_構造持続の収支原理の詳細展開.pdf`

Current OSF mirrors:

- Paper 1: <https://osf.io/mdh7b/files/osfstorage/69dde399e43067989d1187e1>
- Conditional derivation supplement: <https://osf.io/mdh7b/files/osfstorage/69dde4faa17296e9bb3e7a3b>
- Route C companion I: <https://osf.io/mdh7b/files/osfstorage/69dde3bde1158f542e3e7aec>
- Route C companion II: <https://osf.io/mdh7b/files/osfstorage/69dde3c0cc45911aa117d84c>
- v2 spine bundle (2026-04-28): <https://osf.io/mdh7b/files/osfstorage/69f0aac955cae29ef45db6b6>
- v2 spine manifest (2026-04-28): <https://osf.io/mdh7b/files/osfstorage/69f0aaeb6982d95c29f8c2c2>

## SAT Experiments (no API key needed)

Deterministic. Results should match exactly.

```bash
cd analysis/sat

# Main phase transition (Fig. 1)
python exp2_sat_transition.py

# XOR-SAT threshold prediction (5.19x ratio)
python prediction_test.py

# Contradiction type comparison
python exp_sat_contradiction.py

# Bootstrap confidence intervals
python phase3_bootstrap_ci.py
```

## Mixed-CSP Outside-Group Reruns

The Mixed-CSP true outside-group rerun stream has completed the requested
three-run set. Three independent external executors reran the same frozen
package and each returned `12000` primary rows, `0` checked core-field
mismatches, and all support flags true.

Current notes:

- `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_01_katsumasa1234.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_02_SCRAPRO.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_rerun_03_philia_channel.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_final_report.md`
- `analysis/route_a_mixed_csp/mixed_csp_true_outside_interim_report.md`

## Exp43c Q-Coloring Outside-Group Reruns

The Exp43c q-coloring true outside-group rerun stream has completed at the
current three-return level. Three external executors reran the same frozen
package and each returned `4000` primary rows, `0` checked core-field
mismatches, `TIMEOUT = 0`, `MALFORMED = 0`, and the same qualitative support
decision.

Current notes:

- `analysis/exp43_qcoloring/exp43c_true_outside_rerun_01_philia_channel.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_rerun_02_katsumasa1234.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_rerun_03_SCRAPRO.md`
- `analysis/exp43_qcoloring/exp43c_true_outside_final_report.md`
- `analysis/g7_route_a_true_outside_replication_summary.md`

## LLM Experiments (API key required)

Stochastic. Set one or more API keys:

```bash
export ANTHROPIC_API_KEY=...
export OPENAI_API_KEY=...
export GOOGLE_API_KEY=...
```

### Exp. 35 — Context rot is δ accumulation

```bash
cd analysis/exp35
python exp35_delta_zero_control.py
```

### Exp. 36 — Two-factor matrix (δ x context length)

```bash
cd analysis/exp36
python exp36_context_delta_matrix.py
python exp36_judge.py
```

### Exp. 40 / 42 — Scope-as-repair checks

```bash
cd analysis/exp40
python exp40_contradiction_quality.py dry-run
python exp40_contradiction_quality.py summarize

cd ../exp42
python exp42_scope_gradient.py dry-run --include-diagnostics
python exp42_scope_gradient.py summarize
python exp42_scope_gradient.py compare
python analyze_exp42_rows.py --model gpt-4.1-mini
```

Paid API calls require `run --execute`; the summary and row-level commands
above reproduce the stored result tables from committed JSONL files.

### Exp. 14–19 — Double-bind & N_eff

```bash
cd analysis/llm
python run_exp14_v4_precision.py
python run_exp16_cross_model.py
python run_exp18_neff_measurement.py
```

## Formal Verification (Lean 4)

Requires [Lean 4](https://leanprover.github.io/) and Mathlib.

The current core covers four layers separately:

- `LogUniqueness.lean`: axiomatic uniqueness of the log-ratio loss scale
- `TelescopingExp.lean`: purely algebraic A1–A2 telescoping identity
- `AxiomsToExp.lean`: exponential form under the independent-constraint model
- `WeakDependence.lean`: weak-dependence brackets around the independent case

```bash
cd lean
lake exe cache get
lake build
```

## OSF Layout

At the time of writing:

- `v2_preprints_2026-04-14/` contains the current `v2` PDF mirrors
- `paper1_survival_equation/` contains earlier paper-1-related materials
- `paper3_deltazero/` contains earlier DeltaZero and legacy Route C materials
- `supplementary/` contains additional files

## Notes

- LLM experiment results are stochastic; reproduced results should be statistically consistent, not bit-for-bit identical.
- Proprietary model APIs may change over time.
- Some older references inside the repository point to earlier versions or legacy artifact locations. For the current manuscripts, prefer `v2/` and the OSF links listed above.
- The STRING PPI dataset (`9606.protein.links.v12.0.txt`) must be downloaded separately from [string-db.org](https://string-db.org).
