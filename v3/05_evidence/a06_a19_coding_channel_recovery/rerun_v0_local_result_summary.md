A06/A19 Coding-Channel Recovery Local Rerun v0 Summary
======================================================

status: local_rerun_reproduced_support_decision_not_new_evidence

date: 2026-05-01 JST

domain_id: coding_channel_recovery

package_id: a06_a19_coding_channel_recovery_v0

rerun_dir: `05_evidence/a06_a19_coding_channel_recovery/rerun_v0_local/`

This memo records a local clean rerun of the supported A06/A19 v0 finite
BEC / binary-linear-code package. It does not create a new support package and
does not change the existing support decision. Its purpose is to check whether
the frozen v0 commands, seeds, and scripts reproduce the existing decision.


1. Packet And Hash Check
------------------------

The rerun followed:

```text
05_evidence/a06_a19_coding_channel_recovery/replication_packet_v0_plan.md
```

Script hashes matched the packet plan before execution.

```text
generator:
  05_evidence/a06_a19_coding_channel_recovery/scripts/generate_smoke.py
  ced8e6658f4f0c0cd7220f15b5afe68fbeca15c7a502d5f22214c2de16b290a9

evaluator:
  05_evidence/a06_a19_coding_channel_recovery/scripts/evaluate_smoke.py
  b4366e49e63b37021feaf2a8b6163a33020b58c2cf30fcc46989403f1e3095a3
```


2. Commands
-----------

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


3. Generation Summary
---------------------

```text
codes:                 240
feature rows:          960
label rows:            960
erasure sample rows:   245760
n-values:              24,32
rate:                  0.50
column weight:         3
q-values:              0.18,0.24,0.30,0.36
samples per row:       256
dependency order:      4
generation elapsed:    103.9s
```


4. Audit Summary
----------------

The generated and evaluated outputs passed the rerun audits.

```text
split_integrity_audit: passed
  train codes:       144
  validation codes:  48
  test codes:        48

label_sample_audit: passed
  K:                 256
  audited labels:    960
  audited samples:   245760
  rank accounting:   a(E)=|E|-rank_GF2(H_E); failure iff a(E)>0

endpoint_degenerate: false
test prevalence:     0.15936279296875
```


5. Decision Reproduction
------------------------

The rerun reproduced the original support decision with the same primary
numeric values.

```text
B1 test log loss:                  0.43822689815179555
B1 + SP scalar test log loss:      0.4289932917900723
relative log-loss improvement:     0.02107037792674442
bootstrap positive rate:           1.0

decision_reproduction:             clean_decision_reproduction_with_schema_note
```

The hazard guardrail also reproduced.

```text
B1_hazard test log loss:           0.4363397035431776
B1_hazard + SP scalar test loss:   0.4280894618984881
relative log-loss improvement:     0.018907840789402438
bootstrap positive rate:           1.0
```

The primary comparison therefore remains:

```text
B1_SP_scalar > B1
```

under the frozen v0 decision rule. This is a reproduction of the existing
support decision, not a new support claim.


6. Schema Note
--------------

The replication packet plan lists `governance_summary.json` as an expected
artifact. The current evaluator command emitted `evaluation_summary.json` and
the diagnostic CSV files, but did not emit `governance_summary.json` for this
local rerun directory.

This is recorded as a minor local output-schema note. It did not affect the
decision check because the audit fields, model metrics, bootstrap result, and
decision-rule inputs are all present in `evaluation_summary.json`. The
governance classification for this rerun is recorded in this human-readable
summary.


7. Artifact Handling
--------------------

The local raw rerun directory is approximately 26M and includes 245,760
erasure sample rows. Per the artifact storage policy, this summary records the
rerun result and points to the local artifact manifest rather than treating the
raw row directory as a new ordinary evidence package.

Artifact manifest:

```text
05_evidence/a06_a19_coding_channel_recovery/rerun_v0_local_artifact_manifest.md
```


8. Non-Claims
-------------

This rerun summary does not claim:

- a new support package;
- outside reproduction;
- support for A06/A19 successor surfaces v1 or v1b;
- support for A06-stop;
- support for arbitrary codes, non-BEC channels, or Shannon-capacity claims;
- that exact rank accounting was used as a prediction feature.
