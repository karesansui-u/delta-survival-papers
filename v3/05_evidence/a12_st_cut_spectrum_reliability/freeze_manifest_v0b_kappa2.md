A12 S-t Cut-Spectrum Reliability Freeze Manifest v0b Kappa-2
============================================================

Status: frozen executable successor protocol before primary execution; not
validation evidence by itself.

Date frozen: 2026-05-01 JST

manifest_id: st_cut_spectrum_reliability_v0b_kappa2

domain_id: st_cut_spectrum_reliability

Predecessor:

```text
05_evidence/a12_st_cut_spectrum_reliability/primary_v0_invalid_run_summary.md
```

The predecessor v0 did not produce prediction labels or metrics because the
frozen \(n=16,m=24,\kappa=3\) generation cell was infeasible under the current
two-cluster generator. This v0b package is a separate successor surface, not a
rescue or reinterpretation of v0.


1. Frozen Claim
---------------

Primary claim to evaluate:

> For finite two-cluster synthetic \(s\)-\(t\) reliability graphs with
> \(\kappa=2\) under a pre-fixed independent edge-failure law,
> \(B1+\log(1+H_{\mathrm{cut},2})\) predicts held-out \(s\)-\(t\)
> disconnection probability better than \(B1\) alone.

Claim strength if passed:

- finite synthetic A12-v0b support for scalar low-order cut-spectrum pressure;
- \(\kappa=2\)-only support in this frozen two-cluster graph family;
- not support for \(\kappa=3\) or broader connectivity classes;
- not A31 spanning-tree support;
- not exact reliability superiority;
- not real-world infrastructure evidence;
- not \(M\)-side validation.


2. Frozen Scripts
-----------------

Generator:

```text
05_evidence/a12_st_cut_spectrum_reliability/scripts/generate_smoke.py
```

Generator SHA256:

```text
22d306820903a36a72b7d3926e5f1b16a71cb431c3fcb8987b5f891930e5b503
```

Evaluator:

```text
05_evidence/a12_st_cut_spectrum_reliability/scripts/evaluate_smoke.py
```

Evaluator SHA256:

```text
db44d0425e83467366bc4d8e2cb786d6fb4b6f0a9503351b93a70959635e4815
```

Both scripts emit progress messages to stderr. The progress logging is not an
outcome-bearing feature and does not enter any model input.


3. Frozen Surface
-----------------

Primary grid:

```text
n-values:                 16,20
edge-factors:             1.5
kappas:                   2 only
q-values:                 0.20,0.30,0.40,0.50
candidate-count:          40
graphs-per-cell:          40
failure-samples per row:  256
generator-seed:           73121
split-seed:               73131
max-attempts:             500
max-cutset-subset-tests:  250000
```

This surface intentionally excludes \(\kappa=3\). Any \(\kappa=3\) successor
requires a separately frozen generator or feasibility screen.


4. Frozen Primary Coordinate
----------------------------

The only support-bearing SP coordinate is:

```text
log1p_H_cut_2 = log(1 + sum_{j=kappa}^{kappa+2} N_j q^j)
```

Term-vector and bundle variants are diagnostics only:

```text
B1_SP_terms
B1_SP_bundle
```

They cannot be promoted to primary after test results are known.


5. Frozen Baselines And Guardrails
----------------------------------

Primary comparison:

```text
B1_SP_scalar vs B1
```

B1 features:

```text
q
n
m
edge_density
mean_degree
degree_s
degree_t
degree_variance
kappa
shortest_st_path_length
bridge_count
```

The baseline excludes \(s\)-\(t\)-separating bridge count, \(N_j\), cut-spectrum
pressure, exact reliability, failure-sample summaries, and spanning-tree count.

Hazard guardrail:

```text
B1_hazard = B1 + q^kappa + q^(kappa+1) + q^(kappa+2)
B1_hazard_SP_scalar = B1_hazard + log1p_H_cut_2
```

The hazard guardrail is diagnostic. If the primary gate passes but the hazard
guardrail absorbs the gain, the result must be reported with a
hazard-absorption caveat.


6. Frozen Endpoint And Metric
-----------------------------

For every graph / \(q\) row, the generator samples \(K=256\) independent edge
failure states. The endpoint is:

```text
Y = 1 if s and t are disconnected after the sampled failures
```

Primary metric:

```text
graph-id grouped binomial log loss
```

Rows are split by graph id, not by graph / \(q\) row. The evaluator audits
labels against the saved failure samples before scoring.


7. Frozen Support Rule
----------------------

Primary support is true only if all conditions hold on the frozen test set:

1. `B1_SP_scalar` has lower graph-id grouped binomial log loss than `B1`.
2. Relative log-loss improvement is at least 1 percent:
   \[
   \frac{\ell(B1)-\ell(B1\_SP\_scalar)}{\ell(B1)}\ge 0.01.
   \]
3. Paired graph-id bootstrap positive rate is at least 90 percent.
4. Endpoint is nondegenerate: graph-balanced test prevalence is in
   \([0.02,0.98]\).
5. Label/sample audit passes.
6. Split integrity audit passes.
7. Every retained graph has `cutset_count_status=exact`.

No-support:

- any primary support gate fails;
- frozen test endpoint degeneracy occurs.

Invalid-run:

- schema mismatch;
- label/sample audit failure;
- split integrity failure;
- cutset enumeration audit failure;
- implementation error that invalidates generated labels;
- generation fails to produce the frozen graph surface.


8. Frozen Commands
------------------

Primary output directory:

```text
05_evidence/a12_st_cut_spectrum_reliability/primary_v0b_kappa2
```

Generation command:

```bash
python3 -B 05_evidence/a12_st_cut_spectrum_reliability/scripts/generate_smoke.py \
  --output-dir 05_evidence/a12_st_cut_spectrum_reliability/primary_v0b_kappa2 \
  --n-values 16,20 \
  --edge-factors 1.5 \
  --kappas 2 \
  --q-values 0.20,0.30,0.40,0.50 \
  --candidate-count 40 \
  --graphs-per-cell 40 \
  --failure-samples 256 \
  --seed 73121 \
  --split-seed 73131 \
  --max-attempts 500 \
  --max-cutset-subset-tests 250000
```

Evaluation command:

```bash
python3 -B 05_evidence/a12_st_cut_spectrum_reliability/scripts/evaluate_smoke.py \
  --input-dir 05_evidence/a12_st_cut_spectrum_reliability/primary_v0b_kappa2 \
  --output-dir 05_evidence/a12_st_cut_spectrum_reliability/primary_v0b_kappa2 \
  --c-grid 0.01,0.1,1,10 \
  --bootstrap-replicates 2000 \
  --bootstrap-seed 73141
```


9. Non-Claims
-------------

This manifest does not claim:

- support before the frozen primary commands are executed;
- \(\kappa=3\) support;
- exact reliability superiority;
- a new graph-theoretic theorem;
- real-world infrastructure reliability;
- all-terminal reliability;
- A31 spanning-tree support;
- \(M\)-side validation;
- universal-law closure.
