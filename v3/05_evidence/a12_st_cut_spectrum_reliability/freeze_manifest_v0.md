A12 S-t Cut-Spectrum Reliability Freeze Manifest v0
===================================================

Status: frozen executable protocol before primary execution; not validation
evidence by itself.

Date frozen: 2026-05-01 JST

manifest_id: st_cut_spectrum_reliability_v0

domain_id: st_cut_spectrum_reliability

Repository HEAD at freeze:

```text
7247a3d693fb8d399358299fcbc9b678b21bedcb
```

Note: A12 files are newly staged-in-worktree material in this session. For this
freeze, the content SHA256 values below are authoritative for the generator and
evaluator used by the primary command.

Execution note: initial pre-artifact generation attempts with broader
`edge-factors=1.5,2.0` surfaces were stopped or failed before any output files
were emitted. The first was too slow under exact cutset enumeration; the second
failed to obtain enough eligible graphs in one cell. No labels, metrics, or
model outcomes were produced. The executable frozen v0 surface below is a
smaller exact surface with `edge-factors=1.5` only.


1. Frozen Claim
---------------

Primary claim to evaluate:

> For finite two-cluster synthetic \(s\)-\(t\) reliability graphs under a
> pre-fixed independent edge-failure law, \(B1+\log(1+H_{\mathrm{cut},2})\)
> predicts held-out \(s\)-\(t\) disconnection probability better than \(B1\)
> alone.

Claim strength if passed:

- finite synthetic A12-v0 support for scalar low-order cut-spectrum pressure;
- support for \(s\)-\(t\) reliability prediction in this frozen two-cluster
  graph family only;
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

Design draft:

```text
05_evidence/st_cut_spectrum_reliability_freeze_manifest_draft.md
```

Design draft SHA256 at freeze:

```text
47016f935466a4bf961452b43e10d896cb1c17280f8b45e6ff379a03d4d13867
```


3. Frozen Surface
-----------------

The v0 primary surface uses the exact subset-enumeration implementation and is
kept below the registered enumeration cap.

Primary grid:

```text
n-values:                 16,20
edge-factors:             1.5
kappas:                   2,3 only
q-values:                 0.20,0.30,0.40,0.50
candidate-count:          20
graphs-per-cell:          10
failure-samples per row:  256
generator-seed:           73021
split-seed:               73031
max-attempts:             500
max-cutset-subset-tests:  250000
```

The `n=24` draft grid point and the `edge-factor=2.0` cells are excluded from
v0 because exact brute-force low-order cutset enumeration is too slow for the
current implementation at those sizes. Larger or denser graphs require a
separately frozen successor package with its own enumeration cap and audit.

The graph family is the current two-cluster synthetic generator. Any support is
bounded to this finite family.


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

Wide guardrail:

```text
B2_guardrail
```

B2 is diagnostic only.


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
- implementation error that invalidates generated labels.


8. Frozen Commands
------------------

Primary output directory:

```text
05_evidence/a12_st_cut_spectrum_reliability/primary_v0
```

Generation command:

```bash
python3 -B 05_evidence/a12_st_cut_spectrum_reliability/scripts/generate_smoke.py \
  --output-dir 05_evidence/a12_st_cut_spectrum_reliability/primary_v0 \
  --n-values 16,20 \
  --edge-factors 1.5 \
  --kappas 2,3 \
  --q-values 0.20,0.30,0.40,0.50 \
  --candidate-count 20 \
  --graphs-per-cell 10 \
  --failure-samples 256 \
  --seed 73021 \
  --split-seed 73031 \
  --max-attempts 500 \
  --max-cutset-subset-tests 250000
```

Evaluation command:

```bash
python3 -B 05_evidence/a12_st_cut_spectrum_reliability/scripts/evaluate_smoke.py \
  --input-dir 05_evidence/a12_st_cut_spectrum_reliability/primary_v0 \
  --output-dir 05_evidence/a12_st_cut_spectrum_reliability/primary_v0 \
  --c-grid 0.01,0.1,1,10 \
  --bootstrap-replicates 2000 \
  --bootstrap-seed 73041
```


9. Expected Artifacts
---------------------

Generation:

```text
graphs.csv
cutsets.csv
features.csv
failure_samples.csv
labels.csv
cutset_count_sanity.json
generation_summary.json
```

Evaluation:

```text
model_metrics.csv
prevalence_by_q_split.csv
evaluation_summary.json
```


10. Non-Claims
--------------

This manifest does not claim:

- support before the frozen primary commands are executed;
- exact reliability superiority;
- a new graph-theoretic theorem;
- real-world infrastructure reliability;
- all-terminal reliability;
- A31 spanning-tree support;
- \(M\)-side validation;
- universal-law closure.
