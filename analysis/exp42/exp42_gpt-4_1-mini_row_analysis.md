# Exp.42 Row-Level Analysis

- Model: `gpt-4.1-mini`
- Records: 240 (240 succeeded)
- Generated: 2026-04-22T02:19:13.584047

## Condition-Level Error Modes

| condition | accuracy | exact wrong-sum adoptions | rate / all trials | rate / mistakes | no numeric answer | other numeric wrong |
|---|---:|---:|---:|---:|---:|---:|
| strong_scope | 50/50 = 1.00 | 0 | 0.000 | NA | 0 | 0 |
| medium_scope | 49/50 = 0.98 | 0 | 0.000 | 0.000 | 0 | 1 |
| weak_scope | 42/50 = 0.84 | 1 | 0.020 | 0.125 | 0 | 7 |
| subtle | 10/50 = 0.20 | 25 | 0.500 | 0.625 | 0 | 15 |
| zero_sanity | 20/20 = 1.00 | 0 | 0.000 | NA | 0 | 0 |
| structural_anchor | 0/20 = 0.00 | 0 | 0.000 | 0.000 | 18 | 2 |

## Mechanistic Notes

- `exact wrong-sum adoption` is the most conservative row-level proxy for contradiction-taking: the model used the injected wrong value and returned the corresponding corrupted sum exactly.
- `medium_scope` has one miss, but it is not an exact wrong-sum adoption. The row is `expected=690`, `wrong_sum=685`, `answer=775`, so it is classified as an arithmetic/parsing error rather than clean contradiction-taking.
- The strong-support margin failure is therefore ceiling-limited: `strong_scope` and `medium_scope` both block contradiction-taking in this run.
- The observed contradiction-taking rate drops from `subtle` 25/50 = 0.50 over all trials (25/40 = 0.62 among mistakes), to `weak_scope` 1/50 = 0.02 over all trials (1/8 = 0.13 among mistakes), to 0 in `medium_scope` and `strong_scope`.

## Target Balance

### strong_scope

| target_key | accuracy |
|---|---:|
| `127:348:215` | 10/10 = 1.00 |
| `158:423:376` | 10/10 = 1.00 |
| `263:184:439` | 10/10 = 1.00 |
| `371:256:108` | 10/10 = 1.00 |
| `492:137:284` | 10/10 = 1.00 |

### medium_scope

| target_key | accuracy |
|---|---:|
| `127:348:215` | 9/10 = 0.90 |
| `158:423:376` | 10/10 = 1.00 |
| `263:184:439` | 10/10 = 1.00 |
| `371:256:108` | 10/10 = 1.00 |
| `492:137:284` | 10/10 = 1.00 |

### weak_scope

| target_key | accuracy |
|---|---:|
| `127:348:215` | 10/10 = 1.00 |
| `158:423:376` | 7/10 = 0.70 |
| `263:184:439` | 7/10 = 0.70 |
| `371:256:108` | 9/10 = 0.90 |
| `492:137:284` | 9/10 = 0.90 |

### subtle

| target_key | accuracy |
|---|---:|
| `127:348:215` | 2/10 = 0.20 |
| `158:423:376` | 2/10 = 0.20 |
| `263:184:439` | 2/10 = 0.20 |
| `371:256:108` | 2/10 = 0.20 |
| `492:137:284` | 2/10 = 0.20 |

## Template Sensitivity

### strong_scope

| template | accuracy | exact wrong-sum adoptions |
|---|---:|---:|
| `Counterfactual scenario, not applicable here: if the experiment were run with an alternate sample, {var} would be {wrong_val}. This counterfactual must not override the definitions at the start.` | 16/16 = 1.00 | 0 |
| `Historical archive note: an unrelated measurement context lists {var} = {wrong_val}. This archive note is out of scope for the final calculation; the initial variable definitions remain authoritative.` | 10/10 = 1.00 | 0 |
| `In a separate calibration notebook that is explicitly not used for the final task, {var} was temporarily recorded as {wrong_val}. For the final task, use only the VARIABLE DEFINITIONS section above.` | 11/11 = 1.00 | 0 |
| `Source B reports {var} = {wrong_val} for a different dataset. The current task uses Source A, namely the VARIABLE DEFINITIONS section above.` | 13/13 = 1.00 | 0 |

### medium_scope

| template | accuracy | exact wrong-sum adoptions |
|---|---:|---:|
| `In a separate historical dataset, Source B logged {var} = {wrong_val}.` | 15/16 = 0.94 | 0 |
| `During a previous calibration run, the legacy dataset recorded {var} = {wrong_val}.` | 9/9 = 1.00 | 0 |
| `For the archived 2019 dataset, a calibration entry lists {var} = {wrong_val}.` | 12/12 = 1.00 | 0 |
| `In the 2019 calibration context, Source B recorded {var} = {wrong_val}.` | 13/13 = 1.00 | 0 |

### weak_scope

| template | accuracy | exact wrong-sum adoptions |
|---|---:|---:|
| `Source B's record says {var} = {wrong_val}.` | 8/12 = 0.67 | 0 |
| `Source B reports {var} = {wrong_val}.` | 11/14 = 0.79 | 1 |
| `Source B lists {var} = {wrong_val}.` | 11/12 = 0.92 | 0 |
| `Source B has an entry with {var} = {wrong_val}.` | 12/12 = 1.00 | 0 |

### subtle

| template | accuracy | exact wrong-sum adoptions |
|---|---:|---:|
| `A later entry gives {var} = {wrong_val}.` | 0/17 = 0.00 | 11 |
| `A later note records {var} = {wrong_val}.` | 0/10 = 0.00 | 6 |
| `A later note lists {var} as {wrong_val}.` | 3/12 = 0.25 | 5 |
| `A later record contains {var} = {wrong_val}.` | 7/11 = 0.64 | 3 |

## Injected Variable Sensitivity

| condition | a | b | c |
|---|---:|---:|---:|
| strong_scope | 20/20 = 1.00 | 16/16 = 1.00 | 14/14 = 1.00 |
| medium_scope | 17/17 = 1.00 | 16/17 = 0.94 | 16/16 = 1.00 |
| weak_scope | 14/14 = 1.00 | 15/19 = 0.79 | 13/17 = 0.76 |
| subtle | 10/23 = 0.43 | 0/12 = 0.00 | 0/15 = 0.00 |

## Subtle Template x Variable Check

| subtle template | a | b | c |
|---|---:|---:|---:|
| `A later entry gives {var} = {wrong_val}.` | 0/7 = 0.00 | 0/3 = 0.00 | 0/7 = 0.00 |
| `A later note lists {var} as {wrong_val}.` | 3/4 = 0.75 | 0/3 = 0.00 | 0/5 = 0.00 |
| `A later note records {var} = {wrong_val}.` | 0/4 = 0.00 | 0/4 = 0.00 | 0/2 = 0.00 |
| `A later record contains {var} = {wrong_val}.` | 7/8 = 0.88 | 0/2 = 0.00 | 0/1 = 0.00 |

## Offset Sensitivity

| condition | offset=2 | offset=3 | offset=5 | offset=7 |
|---|---:|---:|---:|---:|
| strong_scope | 10/10 = 1.00 | 9/9 = 1.00 | 13/13 = 1.00 | 18/18 = 1.00 |
| medium_scope | 10/10 = 1.00 | 20/20 = 1.00 | 7/8 = 0.88 | 12/12 = 1.00 |
| weak_scope | 12/14 = 0.86 | 8/9 = 0.89 | 11/14 = 0.79 | 11/13 = 0.85 |
| subtle | 1/13 = 0.08 | 1/6 = 0.17 | 2/16 = 0.12 | 6/15 = 0.40 |

## Medium-Scope Miss

| trial_idx | target_key | expected | answer | wrong_sum | injected_var | sentence | mode |
|---:|---|---:|---:|---:|---|---|---|
| 10 | `127:348:215` | 690 | 775 | 685 | b | `In a separate historical dataset, Source B logged b = 343.` | other_numeric_wrong |

## Interpretation Notes

- The failed strong-support margin is driven by a ceiling effect: strong_scope was perfect and medium_scope missed only one row.
- The single medium_scope miss was not an exact wrong-sum adoption, so it is better read as an arithmetic/parsing error than a clean scope failure.
- subtle shows a qualitatively different failure mode: many errors exactly adopt the injected wrong sum, while weak_scope mostly avoids exact adoption. This specifies attribution-as-repair at the row level.
- structural_anchor failures are qualitatively different from subtle and weak_scope failures: 18/20 structural failures returned no numeric answer at all, suggesting self-referential impossibility induces refusal/output-format collapse rather than wrong-value uptake.
- subtle failures are not target-specific; each target cell is 2/10 correct, which points to the manipulation rather than one unlucky arithmetic target.
- injected_var matters most in subtle: `a` retains partial performance, while `b` and `c` collapse in this run. The aggregate subtle accuracy of 0.20 therefore understates the collapse for later variables.
- subtle shows a template x variable interaction, not a pure position artifact. `A later record contains...` and `A later note lists...` preserve `a` in 10/12 combined rows, while `A later entry gives...` and `A later note records...` collapse even on `a` in 0/11 rows. All four subtle templates collapse on `b` and `c`.
- Offset effects are secondary in this run: the subtle condition remains poor at every offset, although offset=7 retains more accuracy than the smaller offsets.
