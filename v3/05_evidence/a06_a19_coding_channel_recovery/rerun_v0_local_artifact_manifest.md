A06/A19 Local Rerun v0 Artifact Manifest
========================================

status: local_rerun_artifact_manifest_not_new_evidence

date: 2026-05-01 JST

domain_id: coding_channel_recovery

package_id: a06_a19_coding_channel_recovery_v0

local_artifact_dir: `05_evidence/a06_a19_coding_channel_recovery/rerun_v0_local/`

primary_summary_pointer:

```text
05_evidence/a06_a19_coding_channel_recovery/rerun_v0_local_result_summary.md
```

This manifest records the local raw artifact directory created by the A06/A19
v0 rerun. The local rerun reproduces the existing support decision, but it is
not a new evidence package.


1. Commands
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


2. Script Hashes
----------------

```text
generate_smoke.py:
  ced8e6658f4f0c0cd7220f15b5afe68fbeca15c7a502d5f22214c2de16b290a9

evaluate_smoke.py:
  b4366e49e63b37021feaf2a8b6163a33020b58c2cf30fcc46989403f1e3095a3
```


3. File List And Checksums
--------------------------

```text
e53aa02dbc28ce8df6a699a02a8e1dcc7bb3f48f413c5a4a28f32a7560c22369  codes.csv
21f200bd1145afcc3a17abd6b5b9538b5f17424003478b266e3137729624b325  dependencies.csv
26babcc25ae3a3c50725d67b6d97ec1997877625480d0ec2f1131e033d4d4ae8  erasure_samples.csv
0a9266959367aa7ed884ad0c1f578a3ba8056183633037277ffe5db4c56091db  evaluation_summary.json
e1ffd83b535c0fa7a95b00fc24fa64fb5f5ac2c319c2d5c03e3cb825ca4a91d6  features.csv
bd512f53394610543e882f574507b58d90b6752025b92546a7a7fc874c8a9882  generation_summary.json
8cdd4ab0be68e069f7a54f017622097fac63a4e6ab7979f04462fe0c8f1d878b  labels.csv
1537bea13ef10b0d597a387f16fed7a13eb6bb6f5b265bb6d1882ccdfafcd47e  model_metrics.csv
4f78ca7c8375a65130cdeafc7d69b2b7080b0a281dae785a80bf64e2dc186b16  prevalence_by_q_split.csv
```


4. File Sizes
-------------

```text
codes.csv:                    51K
dependencies.csv:             10K
erasure_samples.csv:          26M
evaluation_summary.json:      1.6K
features.csv:                 257K
generation_summary.json:      710B
labels.csv:                   84K
model_metrics.csv:            497B
prevalence_by_q_split.csv:    712B
```


5. Row Counts
-------------

Counts include header rows.

```text
codes.csv:                    241
dependencies.csv:             241
erasure_samples.csv:          245761
features.csv:                 961
labels.csv:                   961
model_metrics.csv:            8
prevalence_by_q_split.csv:    13
```


6. Storage Note
---------------

The local raw directory exceeds the practical row-count trigger in
`04_operations/55_artifact_storage_policy.md` because it includes 245,760
erasure sample rows. This manifest keeps the checksum and row-count surface
auditable without turning the local rerun into a new ordinary evidence package.

If this local rerun is later sent outside the repository, the raw directory
should be bundled and the bundle SHA256, byte size, and storage location should
be added here or in a successor artifact manifest.
