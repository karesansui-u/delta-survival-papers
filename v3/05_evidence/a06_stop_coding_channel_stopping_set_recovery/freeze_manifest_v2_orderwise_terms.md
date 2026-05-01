A06-stop v2 Order-Wise Normalized-Terms Freeze Manifest
=======================================================

Status: frozen manifest; no primary result yet.

Date frozen: 2026-05-01 JST

manifest_id: a06_stop_v2_orderwise_terms

domain_id: coding_channel_stopping_set_recovery

candidate_profile:

```text
03_domains/01_specification_fixed/coding_channel_stopping_set_recovery.md
```

pre-freeze draft:

```text
05_evidence/a06_stop_coding_channel_stopping_set_recovery/
  orderwise_normalized_terms_v2_manifest_draft.md
```

pre-freeze diagnostics:

```text
05_evidence/a06_stop_coding_channel_stopping_set_recovery/
  row_level_diagnostic_memo_after_normalized_pressure_smoke_v1.md

05_evidence/a06_stop_coding_channel_stopping_set_recovery/
  orderwise_terms_freeze_prep_smoke_v2_summary.md
```

The diagnostics above are not validation evidence and must not be converted
into support or no-support. This manifest fixes a separate support-bearing
primary run.


1. Structural Condition
-----------------------

The structural condition is:

```text
After BEC erasures, all erased transmitted codeword coordinates are recovered
by the fixed peeling / iterative decoder.
```

For a fixed parity-check matrix \(H\) and erasure set \(E\), let
\(S_\infty(H,E)\) be the residual erased set after BEC peeling terminates.
The endpoint is

\[
Y=1\{|S_\infty(H,E)|>0\}.
\]

This is a decoder-specific recovery condition. It is not full
maximum-likelihood message recovery and is not the A06/A19 rank-dependency
condition.


2. Primary Coordinate
---------------------

For each order \(j=2,\ldots,5\), let \(N_j^{\mathrm{stop}}(H)\) be the number
of all stopping sets of size \(j\), not only minimal stopping sets.

The primary coordinate is the fixed order-wise normalized bundle:

\[
\left(
  \frac{N_2^{\mathrm{stop}}(H)}{\binom{n}{2}}p^2,\,
  \frac{N_3^{\mathrm{stop}}(H)}{\binom{n}{3}}p^3,\,
  \frac{N_4^{\mathrm{stop}}(H)}{\binom{n}{4}}p^4,\,
  \frac{N_5^{\mathrm{stop}}(H)}{\binom{n}{5}}p^5
\right).
\]

Feature names:

```text
N_stop_2_norm_q2
N_stop_3_norm_q3
N_stop_4_norm_q4
N_stop_5_norm_q5
```

No single order is selected as primary. Order-specific effects are diagnostic
only.


3. Baselines And Models
-----------------------

Primary baseline:

```text
B1_degree
```

Primary model:

```text
B1_degree_SP_stop_orderwise_norm_terms
```

Hazard guardrail baseline/model:

```text
B1_degree_hazard
B1_degree_hazard_SP_stop_orderwise_norm_terms
```

Rank-dependency guardrail baseline/model:

```text
B1_degree_rankdep
B1_degree_rankdep_SP_stop_orderwise_norm_terms
```

Diagnostic models to report:

```text
B0
B1_simple
B1_degree_hazard
B1_SP_stop_scalar
B1_SP_stop_terms
B1_degree_SP_stop_norm_scalar
B1_degree_SP_stop_norm_terms
B1_degree_rankdep
B1_degree_rankdep_SP_stop_norm_scalar
```

Raw stopping-pressure diagnostics may have lower loss, but they are not
primary because prior diagnostics showed strong entanglement with \(q\),
hazard, and rank-dependency pressure.


4. Frozen Surface
-----------------

Primary run surface:

```text
n-values:                  24,32
rate:                      0.50
column-weight:             3
q-values:                  0.18,0.24,0.30,0.36
codes-per-cell:            80
erasure-samples per row:   256
stopping-order:            5
dependency-order:          4
generation seed:           16221
split seed:                16231
bootstrap replicates:      2000
bootstrap seed:            16341
```

This primary run uses a larger, separate surface from the freeze-prep smoke.


5. Script Hashes
----------------

The following script SHA256 hashes are frozen:

```text
generate_smoke.py:
7bb7ed225623557571a09f5a458df076ef72319cbac041bd4077e591693970f7

evaluate_smoke.py:
f9d0a51034341aca156ac1f6bc5239a89460a33af8781a3c98b02e36ac776e99

evaluate_orderwise_terms_smoke.py:
7a5f044a2c749ada6454fb277774a3a4d826bc7fa997ed4e7fb652ba6b251a10
```


6. Frozen Commands
------------------

Generation command:

```bash
python3 05_evidence/a06_stop_coding_channel_stopping_set_recovery/scripts/generate_smoke.py \
  --output-dir 05_evidence/a06_stop_coding_channel_stopping_set_recovery/primary_v2_orderwise_terms \
  --n-values 24,32 \
  --rates 0.50 \
  --column-weight 3 \
  --q-values 0.18,0.24,0.30,0.36 \
  --codes-per-cell 80 \
  --samples 256 \
  --stopping-order 5 \
  --dependency-order 4 \
  --seed 16221 \
  --split-seed 16231
```

Evaluation command:

```bash
python3 05_evidence/a06_stop_coding_channel_stopping_set_recovery/scripts/evaluate_orderwise_terms_smoke.py \
  --input-dir 05_evidence/a06_stop_coding_channel_stopping_set_recovery/primary_v2_orderwise_terms \
  --output-dir 05_evidence/a06_stop_coding_channel_stopping_set_recovery/primary_v2_orderwise_terms \
  --bootstrap-replicates 2000 \
  --bootstrap-seed 16341
```


7. Required Artifacts
---------------------

The primary result directory must contain at least:

```text
codes.csv
stopping_sets.csv
dependencies.csv
features.csv
erasure_samples.csv
labels.csv
counter_microbench.csv
sanity_cases.csv
generation_summary.json
model_metrics.csv
guardrail_summary.csv
prevalence_by_q_split.csv
evaluation_summary.json
governance_summary.json
primary_v2_orderwise_terms_result_summary.md
```

The package summary must report:

- primary baseline/model names;
- primary relative log-loss improvement;
- primary paired code-id bootstrap positive rate;
- hazard guardrail improvement and bootstrap rate;
- rank-dependency guardrail improvement and bootstrap rate;
- endpoint prevalence and degeneracy status;
- label/sample audit status;
- split audit status;
- final decision.


8. Decision Rule
----------------

The primary gate passes if all conditions hold:

1. `B1_degree_SP_stop_orderwise_norm_terms` has lower code-id grouped binomial
   log loss than `B1_degree`.
2. Relative log-loss improvement of the primary comparison is at least
   1 percent.
3. Paired code-id bootstrap positive rate for the primary comparison is at
   least 90 percent.
4. Test endpoint is nondegenerate: code-balanced prevalence is in
   \([0.02,0.98]\).
5. Peeling label/sample audit passes.
6. Split integrity audit passes.

Guardrail pass conditions:

```text
hazard_guardrail_pass =
  hazard improvement > 0
  and hazard bootstrap positive rate >= 0.90

rankdep_guardrail_pass =
  rankdep improvement > 0
  and rankdep bootstrap positive rate >= 0.90
```

Final decision:

```text
primary gate fails
=> no_support

primary gate passes
and hazard_guardrail_pass
and rankdep_guardrail_pass
=> clean_support

primary gate passes
and (hazard_guardrail_pass fails or rankdep_guardrail_pass fails)
=> caveated_support
```

If the endpoint is degenerate or an audit fails, the run is invalid and must
not be interpreted as support or no-support.


9. No-Oracle Rule
-----------------

Forbidden primary features:

- realized erasure set for the target label;
- final peeling residual \(S_\infty(H,E)\);
- \(|S_\infty(H,E)|\) for the target label;
- exact peeling failure indicator;
- exact finite-block peeling failure probability;
- Monte Carlo peeling failure estimate as an input feature;
- stopping-set counts or stopping pressure inside any baseline tier;
- outcome-derived feature selection.

The peeling residual is used only for label generation and audit. It is not a
prediction feature.


10. Interpretation Discipline
-----------------------------

This manifest fixes the v2 support-bearing primary package. Once the primary
run is executed, the decision must be recorded according to Section 8. The
result must not be rescued by changing seeds, changing the \(q\)-grid,
dropping the rank-dependency guardrail, selecting only \(j=2\) or \(j=4\), or
promoting raw stopping-pressure diagnostics to primary after seeing the
outcome.
