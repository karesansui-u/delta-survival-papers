A06/A19 Coding-Channel Recovery Freeze Manifest v1 Rate-0.625 CW4
==================================================================

Status: frozen executable successor protocol before primary execution; not
validation evidence by itself.

Date frozen: 2026-05-01 JST

manifest_id: coding_channel_recovery_v1_rate625_cw4

domain_id: coding_channel_recovery

Predecessors:

```text
05_evidence/a06_a19_coding_channel_recovery/smoke_result_summary.md
05_evidence/a06_a19_coding_channel_recovery/primary_v0_result_summary.md
```

The predecessor smoke run is not evidence. The predecessor primary_v0 passed on
a rate-0.50, column-weight-3 surface. This v1 package is an independently
seeded successor surface with different block lengths, rate, column weight, and
erasure grid. It is not a rescue or reinterpretation of v0.


1. Frozen Claim
---------------

Primary claim to evaluate:

> For finite random sparse binary linear codes under a fixed BEC erasure law,
> \(B1+\log(1+H_{\mathrm{dep},4})\) predicts held-out finite-block
> unique-recovery failure better than \(B1\) alone on a rate-0.625,
> column-weight-4 surface.

Claim strength if passed:

- finite synthetic A06/A19-v1 support for low-order parity-check
  column-dependency pressure;
- independent successor support beyond the rate-0.50, column-weight-3 v0
  surface;
- support only for the frozen BEC, sparse parity-check, rate-0.625,
  column-weight-4 surface;
- not Shannon-capacity theorem support;
- not arbitrary-code support;
- not non-BEC support;
- not decoder-specific non-ML recovery support;
- not exact failure-probability superiority;
- not \(M\)-side validation.


2. Frozen Scripts
-----------------

Generator:

```text
05_evidence/a06_a19_coding_channel_recovery/scripts/generate_smoke.py
```

Generator SHA256:

```text
ced8e6658f4f0c0cd7220f15b5afe68fbeca15c7a502d5f22214c2de16b290a9
```

Evaluator:

```text
05_evidence/a06_a19_coding_channel_recovery/scripts/evaluate_smoke.py
```

Evaluator SHA256:

```text
b4366e49e63b37021feaf2a8b6163a33020b58c2cf30fcc46989403f1e3095a3
```

Both scripts emit progress messages to stderr. The progress logging is not an
outcome-bearing feature and does not enter any model input.


3. Frozen Surface
-----------------

Primary grid:

```text
n-values:                  32,40
rate:                      0.625
column-weight:             4
q-values:                  0.16,0.22,0.28,0.34
codes-per-cell:            120
erasure-samples per row:   256
dependency-order:          4
generator-seed:            101221
split-seed:                101231
max-attempts:              500
```

Rows are split by code id, not by code / \(q\) row. The split is a seeded
random permutation within each `(n,k,column_weight)` cell.


4. Frozen Primary Coordinate
----------------------------

The only support-bearing SP coordinate is:

```text
log1p_H_dep_4 = log(1 + N_2 p^2 + N_3 p^3 + N_4 p^4)
```

where \(N_j\) is the number of dependent parity-check column subsets of size
\(j\), counted exactly over \(\mathbb F_2\).

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
k
r = n-k
rate
capacity_margin = 1 - q - rate
column_weight
parity_check_density
row_weight_mean / variance / min / max
column_weight_mean / variance / min / max
```

The baseline excludes \(N_j\), dependency pressure, final erased-column rank,
final ambiguity dimension, exact finite-block failure probability, failure
sample summaries, and realized erasure-set information.

Hazard guardrail:

```text
B1_hazard = B1 + p^2 + p^3 + p^4
B1_hazard_SP_scalar = B1_hazard + log1p_H_dep_4
```

The hazard guardrail is diagnostic. If the primary gate passes but the hazard
guardrail absorbs the gain, the result must be reported with a
hazard-absorption caveat.


6. Frozen Endpoint And Metric
-----------------------------

For every code / \(q\) row, the generator samples \(K=256\) independent BEC
erasure states. The endpoint is:

```text
Y = 1 if a(E)>0, where a(E)=|E|-rank_GF2(H_E)
```

Primary metric:

```text
code-id grouped binomial log loss
```

The evaluator audits labels against saved erasure samples and recomputes
\(a(E)\) from the saved parity-check matrix before scoring.


7. Frozen Support Rule
----------------------

Primary support is true only if all conditions hold on the frozen test set:

1. `B1_SP_scalar` has lower code-id grouped binomial log loss than `B1`.
2. Relative log-loss improvement is at least 1 percent:
   \[
   \frac{\ell(B1)-\ell(B1\_SP\_scalar)}{\ell(B1)}\ge 0.01.
   \]
3. Paired code-id bootstrap positive rate is at least 90 percent.
4. Endpoint is nondegenerate: code-balanced test prevalence is in
   \([0.02,0.98]\).
5. Rank/sample accounting audit passes.
6. Split integrity audit passes.

No-support:

- any primary support gate fails;
- frozen test endpoint degeneracy occurs.

Invalid-run:

- schema mismatch;
- rank/sample audit failure;
- split integrity failure;
- implementation error that invalidates generated labels;
- generation fails to produce the frozen code surface.


8. Frozen Commands
------------------

Primary output directory:

```text
05_evidence/a06_a19_coding_channel_recovery/primary_v1_rate625_cw4
```

Generation command:

```text
python3 -B 05_evidence/a06_a19_coding_channel_recovery/scripts/generate_smoke.py \
  --output-dir 05_evidence/a06_a19_coding_channel_recovery/primary_v1_rate625_cw4 \
  --n-values 32,40 \
  --rates 0.625 \
  --column-weight 4 \
  --q-values 0.16,0.22,0.28,0.34 \
  --codes-per-cell 120 \
  --samples 256 \
  --dependency-order 4 \
  --seed 101221 \
  --split-seed 101231 \
  --max-attempts 500
```

Evaluation command:

```text
python3 -B 05_evidence/a06_a19_coding_channel_recovery/scripts/evaluate_smoke.py \
  --input-dir 05_evidence/a06_a19_coding_channel_recovery/primary_v1_rate625_cw4 \
  --output-dir 05_evidence/a06_a19_coding_channel_recovery/primary_v1_rate625_cw4 \
  --c-grid 0.01,0.1,1,10 \
  --bootstrap-replicates 1000 \
  --bootstrap-seed 101241
```


9. Required Artifacts
---------------------

The primary result must retain:

```text
codes.csv
dependencies.csv
features.csv
erasure_samples.csv
labels.csv
generation_summary.json
model_metrics.csv
prevalence_by_q_split.csv
evaluation_summary.json
```

The result summary must report the primary comparison, hazard guardrail,
endpoint prevalence, bootstrap positive rate, and audit status.
