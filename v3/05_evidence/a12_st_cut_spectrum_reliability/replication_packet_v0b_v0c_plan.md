A12 S-t Cut-Spectrum Reliability Replication Packet v0b/v0c Plan
================================================================

status: replication_packet_plan_not_evidence

date: 2026-05-01 JST

domain_id: st_cut_spectrum_reliability

package_ids:

```text
a12_st_cut_spectrum_reliability_v0b_kappa2
a12_st_cut_spectrum_reliability_v0c_kappa3
```

This memo defines a rerun-ready packet plan for the supported A12 finite
\(s\)-\(t\) cut-spectrum reliability packages. It does not create new evidence
and does not change the existing support / invalid-run decisions.

The goal is to make the two supported A12 surfaces easy to rerun while keeping
the invalid original v0 surface visible.


1. Current Evidence Record
--------------------------

Summary record:

```text
05_evidence/a12_st_cut_spectrum_reliability/replication_summary.md
```

Package decisions:

| package | surface | decision | relative improvement | bootstrap positive |
|---|---|---:|---:|---:|
| `primary_v0` | mixed \(\kappa=2,3\), original random generator | invalid_run | n/a | n/a |
| `primary_v0b_kappa2` | \(\kappa=2\), edge-factor 1.5 | support | 0.016605514534675368 | 1.0 |
| `primary_v0c_kappa3` | \(\kappa=3\), edge-factor 2.0, constructive generator | support | 0.020916036845913213 | 1.0 |


2. Claim Boundary
-----------------

The supported A12 claim is:

> On each frozen finite two-cluster \(s\)-\(t\) reliability surface,
> the pre-fixed scalar low-order cut-spectrum coordinate
> \(\log(1+H_{\mathrm{cut},2})\) adds incremental predictive value over the
> natural graph baseline \(B1\).

The claim is surface-specific:

- v0b supports the \(\kappa=2\)-only surface;
- v0c supports the \(\kappa=3\)-only surface;
- the original mixed v0 surface remains invalid-run because generation failed.

This is not:

- exact reliability superiority;
- arbitrary-\(\kappa\) support;
- real-world network reliability support;
- all-terminal reliability support;
- A31 spanning-tree persistence support;
- \(M\)-side validation.


3. A31 / A12 Separation
-----------------------

A31 and A12 answer different questions.

- A31 is the spanning-tree mass / global redundancy anchor.
- A12 is the cutset / \(s\)-\(t\) reliability prediction package.

The A31 primary_v0 no-support result taught that short-horizon disconnection is
often governed by local cutsets, bridges, and min-cut proximity. A12 is the
separately frozen cut-spectrum response to that endpoint.

Do not describe A12 as A31 support, and do not describe A31 as cut-spectrum
support.


4. Script Hashes And Script Evolution
-------------------------------------

Evaluator hash for both supported packages:

```text
05_evidence/a12_st_cut_spectrum_reliability/scripts/evaluate_smoke.py
sha256: db44d0425e83467366bc4d8e2cb786d6fb4b6f0a9503351b93a70959635e4815
```

Generator hash for v0b:

```text
manifest: freeze_manifest_v0b_kappa2.md
sha256: 22d306820903a36a72b7d3926e5f1b16a71cb431c3fcb8987b5f891930e5b503
```

Generator hash for v0c:

```text
manifest: freeze_manifest_v0c_kappa3.md
sha256: 104c7f9694d906d135abf49540811610f8b93e8f661d668811da64d93eec4dff
```

The generator path evolved between v0b and v0c to add the constructive
\(\kappa=3\) generator. Therefore:

- exact v0b replay should use the v0b manifest-era generator hash;
- exact v0c replay should use the v0c manifest-era generator hash;
- using the current generator for v0b must be reported as a hash-drift rerun,
  even if the support decision reproduces.

The command below uses the current tracked generator path. Since the current
tracked generator has the v0c hash, the v0b command is a convenient
current-generator hash-drift rerun, not a clean v0b exact replay. A clean v0b
exact replay requires either checking out the manifest-era script at the v0b
hash or packaging that historical script under a frozen name such as
`scripts/generate_smoke_v0b_kappa2_frozen.py`.


5. Frozen Surfaces
------------------

### v0b Kappa-2

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
bootstrap-replicates:     2000
bootstrap-seed:           73141
```

### v0c Kappa-3

```text
n-values:                 16,20
edge-factors:             2.0
kappas:                   3 only
q-values:                 0.20,0.30,0.40,0.50
candidate-count:          40
graphs-per-cell:          40
failure-samples per row:  256
generator-seed:           73221
split-seed:               73231
max-attempts:             500
max-cutset-subset-tests:  900000
cluster-generator:        constructive
bootstrap-replicates:     2000
bootstrap-seed:           73241
```

Rows are split by graph id, not by graph / \(q\) row.


6. Primary Coordinate And Forbidden Oracle Features
---------------------------------------------------

The only support-bearing SP coordinate is:

```text
log1p_H_cut_2 = log(1 + sum_{j=kappa}^{kappa+2} N_j q^j)
```

where \(N_j\) counts \(s\)-\(t\) cutsets of size \(j\), enumerated exactly
within the frozen cap.

Forbidden prediction features include:

- exact \(s\)-\(t\) reliability;
- exact failure probability;
- realized failed-edge set for the label being predicted;
- final \(s\)-\(t\) connectivity of the sampled failure state;
- Monte Carlo reliability estimate as a model feature;
- spanning-tree count as an A12 primary coordinate.


7. Minimal Rerun Commands
-------------------------

A clean rerun should write to a new output directory and should not overwrite
the committed primary outputs.

### v0b Kappa-2 Current-Generator Hash-Drift Rerun

Recommended output directory:

```text
05_evidence/a12_st_cut_spectrum_reliability/rerun_v0b_kappa2_local
```

Generation using the current tracked generator. This should be reported as
`decision_reproduction_with_hash_or_numeric_drift` unless the v0b
manifest-era generator hash is restored before execution:

```bash
python3 -B 05_evidence/a12_st_cut_spectrum_reliability/scripts/generate_smoke.py \
  --output-dir 05_evidence/a12_st_cut_spectrum_reliability/rerun_v0b_kappa2_local \
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

Evaluation:

```bash
python3 -B 05_evidence/a12_st_cut_spectrum_reliability/scripts/evaluate_smoke.py \
  --input-dir 05_evidence/a12_st_cut_spectrum_reliability/rerun_v0b_kappa2_local \
  --output-dir 05_evidence/a12_st_cut_spectrum_reliability/rerun_v0b_kappa2_local \
  --c-grid 0.01,0.1,1,10 \
  --bootstrap-replicates 2000 \
  --bootstrap-seed 73141
```

For a clean v0b exact replay, replace the generator path with the historical
v0b manifest-era generator whose SHA256 is:

```text
22d306820903a36a72b7d3926e5f1b16a71cb431c3fcb8987b5f891930e5b503
```

### v0c Kappa-3

Recommended output directory:

```text
05_evidence/a12_st_cut_spectrum_reliability/rerun_v0c_kappa3_local
```

Generation:

```bash
python3 -B 05_evidence/a12_st_cut_spectrum_reliability/scripts/generate_smoke.py \
  --output-dir 05_evidence/a12_st_cut_spectrum_reliability/rerun_v0c_kappa3_local \
  --n-values 16,20 \
  --edge-factors 2.0 \
  --kappas 3 \
  --q-values 0.20,0.30,0.40,0.50 \
  --candidate-count 40 \
  --graphs-per-cell 40 \
  --failure-samples 256 \
  --seed 73221 \
  --split-seed 73231 \
  --max-attempts 500 \
  --max-cutset-subset-tests 900000 \
  --cluster-generator constructive
```

Evaluation:

```bash
python3 -B 05_evidence/a12_st_cut_spectrum_reliability/scripts/evaluate_smoke.py \
  --input-dir 05_evidence/a12_st_cut_spectrum_reliability/rerun_v0c_kappa3_local \
  --output-dir 05_evidence/a12_st_cut_spectrum_reliability/rerun_v0c_kappa3_local \
  --c-grid 0.01,0.1,1,10 \
  --bootstrap-replicates 2000 \
  --bootstrap-seed 73241
```


8. Expected Output Schema
-------------------------

Each rerun output directory should contain:

```text
graphs.csv
cutsets.csv
features.csv
failure_samples.csv
labels.csv
cutset_count_sanity.json
generation_summary.json
model_metrics.csv
prevalence_by_q_split.csv
evaluation_summary.json
governance_summary.json
```


9. Expected Decision Checks
---------------------------

Both supported reruns should reproduce the support decision if:

- label/sample audit passes;
- split integrity audit passes;
- every retained graph has exact cutset enumeration;
- endpoint is nondegenerate;
- `B1_SP_scalar` has lower grouped test log loss than `B1`;
- relative grouped log-loss improvement is at least 1 percent;
- paired graph-id bootstrap positive rate is at least 0.90.

Expected v0b values:

```text
B1:                         0.5627084187154574
B1_SP_scalar:               0.5533643558896937
relative_improvement:       0.016605514534675368
bootstrap_positive_rate:    1.0
test_prevalence:            0.40960693359375
```

Expected v0c values:

```text
B1:                         0.4423180021090647
B1_SP_scalar:               0.4330664624793408
relative_improvement:       0.020916036845913213
bootstrap_positive_rate:    1.0
test_prevalence:            0.18170166015625
```

Exact numeric equality is expected only when the same scripts, seeds, and
runtime behavior are used. If a different runtime or evolved generator produces
small numeric drift, the support decision, audits, and hash-drift note are the
primary comparison.


10. Hazard Guardrail Reporting
------------------------------

Both supported packages have hazard guardrail caveats.

v0b:

```text
B1_hazard:                  0.5544517981006696
B1_hazard_SP_scalar:        0.5517535883129523
relative_improvement:       0.004866446094972145
bootstrap_positive_rate:    1.0
```

v0c:

```text
B1_hazard:                  0.43094334078508734
B1_hazard_SP_scalar:        0.4295577115905518
relative_improvement:       0.003215339612885609
bootstrap_positive_rate:    0.9905
```

The rerun report should state that nonlinear \(q,\kappa\) hazard terms account
for part of the gain. The clean claim remains finite low-order pressure
support, not unrestricted dominance over all reliability features.


11. Artifact Handling
---------------------

Committed primary output sizes:

```text
primary_v0b_kappa2: 8.2M
primary_v0c_kappa3: 9.2M
```

For future outside reruns, follow:

```text
04_operations/55_artifact_storage_policy.md
```

Recommended handling:

- keep manifests, result summaries, governance summaries, script hashes, and
  small diagnostics in Git;
- bundle large raw row files such as `failure_samples.csv`;
- record bundle SHA256, byte size, included file list, and row counts;
- keep the invalid v0 summary as an ordinary tracked file.


12. Rerun Outcome Categories
----------------------------

Use these categories for a rerun report:

```text
clean_reproduction:
  audits pass and support decision matches with manifest-matching hashes

decision_reproduction_with_hash_or_numeric_drift:
  audits pass and support decision matches, but script hash or numeric details
  drift from the frozen package

schema_or_audit_failure:
  generated files exist, but schema, split, cutset, or label audit fails

generation_failure:
  the frozen surface cannot be regenerated

decision_mismatch:
  audits pass, but the support decision does not match
```

A decision mismatch should trigger a dedicated replication-failure note rather
than post-hoc retuning.


13. Outside-Rerun Packet Checklist
----------------------------------

Before sending this package outside, prepare:

1. this replication plan;
2. `freeze_manifest_v0b_kappa2.md`;
3. `freeze_manifest_v0c_kappa3.md`;
4. `primary_v0_invalid_run_summary.md`;
5. `primary_v0b_kappa2_result_summary.md`;
6. `primary_v0c_kappa3_result_summary.md`;
7. generator and evaluator scripts, with the relevant frozen hashes;
8. dependency / Python environment note;
9. expected output schema;
10. expected support decisions;
11. artifact bundle policy;
12. mismatch reporting template.


14. Non-Claims
--------------

This replication packet plan does not claim:

- new support beyond v0b / v0c;
- outside reproduction has already occurred;
- the invalid v0 surface is rescued;
- support for arbitrary \(\kappa\);
- exact reliability superiority;
- A31 support;
- real-world network reliability evidence.
