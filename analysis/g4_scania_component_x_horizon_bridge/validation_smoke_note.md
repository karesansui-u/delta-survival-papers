# G4 Scania Component X Horizon-Bridge Validation Smoke Note

Status: pre-freeze execution note. Not frozen. Not validation evidence. Not
repair-flow evidence.

Date: 2026-04-27

Upstream drafts:

- `analysis/g4_scania_component_x_horizon_bridge_preregistration_draft.md`
- `analysis/g4_scania_component_x_horizon_bridge/freeze_manifest_draft.md`

Execution script:

- `analysis/g4_scania_component_x_horizon_bridge/scripts/evaluate_scania_component_x_horizon_bridge.py`
- current script sha256:
  `ec685027940259fe0785127f27569a2dc2385a8174209423d393c54b11beadd7`

## 1. Purpose

Confirm that the first Scania public bridge package now has a working
script-level path for:

1. exact file-identity verification;
2. deterministic train-label construction under the censored-as-class-0 rule;
3. compressed `D_pc1` construction;
4. fitting `B1`, `B2`, `B3`, and the primary multinomial logistic models;
5. producing validation-surface probabilities without touching held-out test
   labels or reporting validation metrics.

This note is about pipeline integrity only. It does not freeze the script hash
into the manifest and does not evaluate the held-out test surface.

## 2. Local Pre-Freeze Data Root

Local package root used for this smoke:

```text
analysis/g4_scania_component_x_horizon_bridge/data
```

That root contains the exact small supervision/specification files plus local
links to the already exact-acquired large readout CSV files under:

```text
/tmp/scania_component_x_v3_exact
```

This is a local pre-freeze execution arrangement only. The frozen package still
needs its final local path section completed in the manifest.

## 3. Metadata-Only Check

`--metadata-only` passed under the current script.

Fixed structural facts recovered:

- dataset identity: `Scania Component X`, version `3`, DOI `10.5878/bnh5-ka77`
- readout columns: `107`
- raw readout feature columns: `105`
- specification fields: `Spec_0` through `Spec_7`
- held-out label grammar:
  - `0` = `>48`
  - `1` = `48–24`
  - `2` = `24–12`
  - `3` = `12–6`
  - `4` = `6–0`
- training repair counts from `train_tte.csv`:
  - `0`: `21278`
  - `1`: `2272`
- validation label counts:
  - `0`: `4910`
  - `1`: `16`
  - `2`: `14`
  - `3`: `30`
  - `4`: `76`
- test label counts:
  - `0`: `4903`
  - `1`: `26`
  - `2`: `15`
  - `3`: `41`
  - `4`: `60`

## 4. Validation-Smoke Result

`--validation-smoke` passed under the current script.

Observed train/validation structure:

- train rows: `1122452`
- train unique vehicles: `23550`
- validation surface rows: `5046`
- validation unique vehicles: `5046`

Deterministic training-label counts under the frozen rule:

- `0`: `1096712`
- `1`: `12503`
- `2`: `6179`
- `3`: `3200`
- `4`: `3858`

Compressed coordinate diagnostic:

- oriented train correlation of `D_pc1` with `time_step`:
  `0.8283997884816924`

Model-fit status:

- `B1`: passed
- `B2`: passed
- `B3`: passed
- `primary`: passed

Feature dimensions:

- `B1`: `1`
- `B2`: `91`
- `B3`: `196`
- `primary`: `92`

Validation probability output shapes:

- `B0`: `5046 x 5`
- `B1`: `5046 x 5`
- `B2`: `5046 x 5`
- `B3`: `5046 x 5`
- `primary`: `5046 x 5`

## 5. No-Peek Boundary

No log-loss values, macro-F1 values, balanced-accuracy values, plain-accuracy
values, ordered-distance values, or model-comparison outcomes from the
validation-surface predictions are recorded here or used as evidence.

This note records only that the pipeline:

- built the deterministic training labels;
- constructed the `D_pc1` coordinate;
- fit all preregistered bridge models; and
- produced shape-correct validation probabilities without touching the held-out
  test surface.

Current no-peek status from the script output:

- validation metrics recorded: `false`
- validation predictions recorded: `false`
- held-out test loaded: `false`
- held-out test metrics recorded: `false`
- held-out test predictions recorded: `false`

## 6. What This Closes

This closes the following pre-freeze gate:

```text
script implementation plus metadata-only / validation-smoke integration
```

So the Scania branch is no longer blocked on code-path existence.

## 7. What Still Remains Open

This note does not freeze the Scania bridge package.

Remaining steps still include:

1. decide whether the current script needs any pre-freeze wording-only hardening
   in the drafts;
2. fill the final script sha256 into the freeze manifest;
3. mark the manifest as frozen;
4. run the one-time held-out test evaluation under `--allow-primary-run`.

## 8. Bottom Line

```text
The first Scania public horizon-bridge package now has a working execution
script, a passing metadata-only identity check, and a passing no-peek
validation-smoke run. The package is still pre-freeze and has not yet touched
the held-out test evaluation surface.
```
