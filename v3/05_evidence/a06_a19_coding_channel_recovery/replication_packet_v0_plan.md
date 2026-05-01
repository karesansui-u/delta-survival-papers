A06/A19 Coding-Channel Recovery Replication Packet v0 Plan
==========================================================

status: replication_packet_plan_not_evidence

date: 2026-05-01 JST

domain_id: coding_channel_recovery

package_id: a06_a19_coding_channel_recovery_v0

This memo defines a rerun-ready packet plan for the supported A06/A19 v0
finite BEC / binary-linear-code package. It does not create new evidence and
does not change the existing support decision.

The purpose is to make the package easy to rerun locally or by an outside
executor while preserving the distinction between exact rank accounting and
oracle-free prediction support.


1. Current Evidence Record
--------------------------

Primary support record:

```text
05_evidence/a06_a19_coding_channel_recovery/primary_v0_result_summary.md
```

Frozen manifest:

```text
05_evidence/a06_a19_coding_channel_recovery/freeze_manifest_v0.md
```

Primary result:

```text
decision: support
B1 test log loss:             0.43822689815179555
B1 + SP scalar test log loss: 0.4289932917900723
relative improvement:         0.02107037792674442
bootstrap positive rate:      1.0
```

Hazard guardrail:

```text
B1_hazard test log loss:             0.4363397035431776
B1_hazard + SP scalar test log loss: 0.4280894618984881
relative improvement:                0.018907840789402438
bootstrap positive rate:             1.0
```


2. Claim Boundary
-----------------

The supported claim is:

> On the frozen finite synthetic BEC sparse parity-check surface, the pre-fixed
> scalar low-order parity-check dependency coordinate
> \(\log(1+H_{\mathrm{dep},4})\) adds incremental predictive value over the
> natural coding baseline \(B1\).

This is not:

- Shannon-capacity theorem support;
- arbitrary-code support;
- non-BEC support;
- decoder-specific non-ML recovery support;
- exact failure-probability superiority;
- \(M\)-side validation;
- support for A06/A19 successor surfaces v1 / v1b.


3. Exact Anchor Versus Prediction Features
------------------------------------------

The exact specification-fixed accounting anchor is:

\[
a(E)=|E|-\operatorname{rank}_{\mathbb F_2}(H_E),
\qquad
L_E=a(E)\log 2.
\]

This exact rank accounting is used for:

- label generation;
- label audit;
- interpretation of the law-side exact anchor.

It must not be used as a prediction feature in the support-bearing model.

Forbidden prediction features include:

- final erased-column rank;
- final ambiguity dimension \(a(E)\);
- exact recovery indicator;
- exact finite-block failure probability;
- realized erasure-set summaries for the label being predicted;
- Monte Carlo failure estimates as model features.


4. Frozen Surface
-----------------

The v0 support surface is:

```text
n-values:                  24,32
rate:                      0.50
column-weight:             3
q-values:                  0.18,0.24,0.30,0.36
codes-per-cell:            120
erasure-samples per row:   256
dependency-order:          4
generator-seed:            91221
split-seed:                91231
max-attempts:              500
bootstrap-replicates:      1000
bootstrap-seed:            91241
```

Rows are split by code id, not by code / \(q\) row.


5. Script Hashes
----------------

Generator:

```text
05_evidence/a06_a19_coding_channel_recovery/scripts/generate_smoke.py
sha256: ced8e6658f4f0c0cd7220f15b5afe68fbeca15c7a502d5f22214c2de16b290a9
```

Evaluator:

```text
05_evidence/a06_a19_coding_channel_recovery/scripts/evaluate_smoke.py
sha256: b4366e49e63b37021feaf2a8b6163a33020b58c2cf30fcc46989403f1e3095a3
```

An outside rerun should verify these hashes or explicitly report any hash
drift before execution.


6. Minimal Rerun Commands
-------------------------

A clean rerun should write to a new output directory, not overwrite the
committed primary output.

Recommended output directory:

```text
05_evidence/a06_a19_coding_channel_recovery/rerun_v0_local
```

Generation:

```text
python3 -B 05_evidence/a06_a19_coding_channel_recovery/scripts/generate_smoke.py \
  --output-dir 05_evidence/a06_a19_coding_channel_recovery/rerun_v0_local \
  --n-values 24,32 \
  --rates 0.50 \
  --column-weight 3 \
  --q-values 0.18,0.24,0.30,0.36 \
  --codes-per-cell 120 \
  --samples 256 \
  --dependency-order 4 \
  --seed 91221 \
  --split-seed 91231 \
  --max-attempts 500
```

Evaluation:

```text
python3 -B 05_evidence/a06_a19_coding_channel_recovery/scripts/evaluate_smoke.py \
  --input-dir 05_evidence/a06_a19_coding_channel_recovery/rerun_v0_local \
  --output-dir 05_evidence/a06_a19_coding_channel_recovery/rerun_v0_local \
  --c-grid 0.01,0.1,1,10 \
  --bootstrap-replicates 1000 \
  --bootstrap-seed 91241
```


7. Expected Output Schema
-------------------------

The rerun output directory should contain:

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
governance_summary.json
```

The exact row order may differ only if the script, Python runtime, or random
implementation changes. Any such drift must be reported rather than silently
normalized.


8. Expected Decision Checks
---------------------------

The rerun should reproduce the support decision if:

- `rank_sample_audit` passes;
- split integrity audit passes;
- endpoint is nondegenerate;
- `B1_SP_scalar` has lower grouped test log loss than `B1`;
- relative grouped log-loss improvement is at least 1 percent;
- paired code-id bootstrap positive rate is at least 0.90.

The primary expected numeric values from the original run are:

```text
B1:                         0.43822689815179555
B1_SP_scalar:               0.4289932917900723
relative_improvement:       0.02107037792674442
bootstrap_positive_rate:    1.0
test_prevalence:            0.15936279296875
```

Exact numeric equality is expected when the same scripts, seeds, and runtime
behavior are used. If a different runtime produces small numeric drift, the
support decision and audit status are the primary comparison.


9. Artifact Handling
--------------------

The original committed primary output is approximately:

```text
primary_v0 size: 26M
erasure sample rows: 245760
```

For future outside reruns, follow:

```text
04_operations/55_artifact_storage_policy.md
```

Recommended handling:

- keep manifest, result summary, governance summary, script hashes, and small
  diagnostics in Git;
- bundle large raw row files such as `erasure_samples.csv`;
- record bundle SHA256, byte size, included file list, and row counts;
- do not delete no-support or invalid-run summaries from successor packages.


10. Rerun Outcome Categories
----------------------------

Use these categories for a rerun report:

```text
clean_reproduction:
  audits pass and support decision matches with no material numeric drift

decision_reproduction_with_numeric_drift:
  audits pass and support decision matches, but floating-point or runtime
  details produce small metric drift

schema_or_audit_failure:
  generated files exist, but schema, split, rank/sample, or label audit fails

generation_failure:
  the frozen surface cannot be regenerated

decision_mismatch:
  audits pass, but the support decision does not match
```

A decision mismatch should trigger a dedicated replication-failure note rather
than post-hoc retuning.


11. Outside-Rerun Packet Checklist
----------------------------------

Before sending this package outside, prepare:

1. this replication plan;
2. `freeze_manifest_v0.md`;
3. `primary_v0_result_summary.md`;
4. generator and evaluator scripts;
5. dependency / Python environment note;
6. expected output schema;
7. expected support decision;
8. artifact bundle policy;
9. mismatch reporting template.


12. Non-Claims
--------------

This replication packet plan does not claim:

- a new support result;
- that outside reproduction has already occurred;
- that successor v1 / v1b are supported;
- that exact rank accounting is a prediction feature;
- that A06/A19 support transfers automatically to A06-stop.
