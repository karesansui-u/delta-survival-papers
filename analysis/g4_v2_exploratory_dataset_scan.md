# G4 v2 Exploratory Dataset Scan

Status: exploration-only scan plan. Not a freeze document, not validation, and
not evidence for or against the theory.

Purpose:

Find whether any real maintenance / repair / incident / degradation dataset is
usable for the G4 v2 operational pilot. The only current goal is schema
feasibility:

```text
Can we define unit, time, damage indicator, repair indicator, and future
degradation / failure endpoint without leaking future information?
```

This note deliberately does not rank datasets for primary validation. Dataset
ranking and freeze discipline belong later, after the exploratory scan has
identified plausible candidates.

## 1. Phase Boundary

| Phase | Current? | What is allowed | What is forbidden |
|---|---|---|---|
| Exploratory scan | yes | inspect documentation, schemas, sample rows, missingness, timestamps, event availability, rough base rates | report validation evidence or theory support |
| Freeze | no | lock dataset, features, split, endpoint, metric, evaluation code | choose parameters after seeing primary performance |
| Validation | no | run frozen pipeline once on held-out period | change dataset, feature schema, horizon, split, or decision rules |

The governing rule is:

```text
Exploration is allowed. Mixing exploration with validation is not allowed.
```

Therefore, the scan may produce:

- candidate list;
- eligibility / ineligibility notes;
- schema feasibility notes;
- reasons a dataset is weak for \(g_t\);
- suggestions for a later freeze design.

The scan may not produce:

- primary support;
- weakening outcomes;
- pass / fail of H1-H5;
- claims that repair-aware predictors beat baselines;
- claims that the structural balance law is validated in maintenance logs.

## 2. What We Are Looking For

An ideal dataset has all of the following:

| Requirement | Why it matters |
|---|---|
| stable unit identifiers | needed for repeated prediction cutoffs |
| timestamps | needed to define lagged features and future horizon |
| damage / degradation signals | candidate \(d_t\) |
| repair / maintenance / compensation events | candidate \(g_t\) |
| future failure / degradation endpoint | candidate \(Y_{i,t,H}\) |
| preventive or scheduled repair class | cleaner \(g_t\), less reactive leakage |
| enough events | log loss / Brier estimates are meaningful |
| public or reproducible access | later validation can be audited |

The minimum useful dataset does not need to be perfect. It only needs enough
structure to decide whether a frozen pilot is feasible.

## 3. Scan Checklist

For each candidate dataset, record:

| Field | Question |
|---|---|
| candidate id | short name / URL / source note |
| domain | machines, components, services, repositories, fleets, assets, etc. |
| access | public, restricted, local, synthetic, or unavailable |
| units | what is the repeated unit? |
| time coverage | time span and timestamp resolution |
| damage signals | load, age, error, vibration, latency, defect count, etc. |
| repair signals | maintenance, replacement, patch, rollback, inspection, redundancy activation |
| repair timing | can repair be placed before the prediction cutoff? |
| preventive vs reactive | can these be separated or approximated? |
| endpoint | future failure / incident / degradation definition |
| leakage risk | obvious post-outcome labels or repair-as-outcome? |
| activity baseline | generic activity / logging / exposure count available? |
| rough base rate | approximate event rate only for feasibility |
| missingness | obvious missing or censored fields |
| reproducibility | can another reader obtain or reproduce it? |
| provisional status | promising / weak / ineligible / unclear |
| reason | one sentence |

This checklist is exploratory. It is allowed to look at rough base rates for
feasibility, but not to compare repair-aware models against baselines.

## 4. Candidate Categories

Start broad. Do not overfit the search to datasets that are likely to support
the theory.

| Category | Why it might work | Common weakness |
|---|---|---|
| predictive maintenance / PHM datasets | rich damage signals and failure endpoints | repair events often absent |
| fleet / component maintenance logs | repair and replacement are natural \(g_t\) candidates | public access may be limited |
| IT incident / outage logs | incidents, fixes, rollbacks, patches may be timestamped | public datasets often lack clean unit histories |
| software repository / CI logs | commits, failures, fixes, rollbacks, tests are available | repair may be reactive and confounded with activity |
| reliability / degradation sensor datasets | clean damage trajectory | usually loss-only, not open-system repair |
| support ticket / operations logs | repair / intervention records may be explicit | outcome labels and privacy can be hard |

Loss-only datasets are not useless. They can be G4 controls. But they are not
the primary target for G4 v2, because G4 v2 is specifically about making
compensation flow \(g_t\) operational.

## 5. Eligibility Labels During Exploration

Use lightweight labels only:

| Label | Meaning |
|---|---|
| promising | likely enough fields for a future frozen pilot |
| weak-g | damage and endpoint exist, but repair \(g_t\) is missing or reactive only |
| weak-y | repair and damage exist, but future endpoint is unclear |
| leakage-risk | repair or labels appear to use future outcome information |
| access-risk | dataset may not be reproducible or shareable |
| ineligible | missing a core element |
| unclear | needs more inspection |

These labels are not theory outcomes.

## 6. When To Move From Exploration To Freeze

Move to a freeze design only when at least one candidate has:

1. stable units;
2. usable timestamps;
3. candidate \(d_t\);
4. candidate \(g_t\);
5. future endpoint \(Y_{i,t,H}\);
6. plausible activity baseline;
7. manageable leakage risk;
8. reproducible access or a clear reporting plan.

At that point, create a separate freeze document that locks:

- dataset identifier;
- endpoint;
- feature windows;
- prediction horizon;
- train / validation split;
- model class;
- metrics;
- baselines;
- non-claims.

If multiple candidates are promising, the later freeze document must explain
how the primary dataset is selected. That selection can be stricter than this
exploratory scan, but it should not be retroactively described as if it had
been fixed before exploration.

## 7. Relation To The G4 v2 Operational Pilot Draft

The stricter document is:

```text
analysis/g4_v2_operational_pilot_preregistration_draft.md
```

That draft is the shape of a possible validation design. This scan note is
lighter:

```text
scan note -> candidate feasibility -> later freeze design -> validation
```

Do not skip directly from this scan note to validation.

## 8. Recommended Next Action

Create a small candidate table using only public documentation and lightweight
schema inspection. The table should be allowed to say:

```text
No suitable dataset found yet.
```

That outcome is useful. It would mean the G4 v2 operational pilot needs either
a different domain, a private dataset, or a more modest loss-only control.

Current candidate table:

```text
analysis/g4_v2_dataset_scan_candidates.md
```

