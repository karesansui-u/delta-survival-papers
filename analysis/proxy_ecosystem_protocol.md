# Proxy Ecosystem Protocol

Status: future design outlook for the empirical side of structural persistence
theory. This is not evidence by itself and does not upgrade any existing
mapping attempt.

Date opened: 2026-04-28

## 1. Purpose

The theoretical core gives a common accounting coordinate. The empirical
program needs a second layer: a shared ecosystem for discovering, freezing,
testing, rejecting, and upgrading proxies.

The goal is not to make every first proxy permanent. Early Route A / Route C /
non-CSP proxies create scaffolding. Later, if better measurements, stronger
datasets, or direct \(r_t\) / \(g_t\)-like records become available, the proxy
can be replaced by a more detailed version. The replacement must be versioned,
frozen, and validated; it must not silently rewrite the status of the earlier
attempt.

## 2. Promotion Ladder

Proxy families should move through an explicit ladder:

| Stage | Meaning | Evidence status |
|---|---|---|
| `candidate_signal` | Exploratory correlation, direction, monotonicity, or useful failure lesson. | Not support |
| `validation_candidate` | A candidate selected for future frozen validation. | Not support |
| `frozen_test` | Mapping, transform, baseline, metric, split, and failure rule are fixed. | Pending |
| `internally_supported_proxy` | Frozen proxy improves on a holdout or sealed internal validation surface. | Scoped support |
| `externally_supported_proxy` | Fresh archive, future data, outside rerun, or independent runner reproduces the improvement. | Stronger support |
| `cross_domain_transferable_principle` | The same structural coordinate works, after domain-specific freezing, in another domain. | Transferable principle candidate |

Failed branches also move through a ledger:

| Stage | Meaning |
|---|---|
| `failed_candidate` | Exploration-stage candidate should not be promoted. |
| `no_support` | Frozen test failed its primary rule. |
| `weak_axis_mapping_failure` | Added SP axis substantially duplicated the baseline. |
| `silence` | No natural non-leaky mapping or validation surface is available. |

## 3. Replacement Rule

Early proxies can be superseded, but not erased.

Allowed:

- keep an early proxy as historical support / no-support / weakening outcome;
- define a stricter v2 proxy family from the lesson;
- freeze the v2 mapping before its validation surface is opened;
- promote v2 only if it passes the new preregistered surface;
- record whether v2 uses the same archive, a fresh archive, future data, or an
  outside runner.

Not allowed:

- use a failed held-out result to tune a v2 proxy and then call the same archive
  result confirmatory support;
- rename a baseline feature as an SP feature and count the improvement as
  structural persistence support;
- erase no-support attempts after a later version succeeds;
- import support from one domain into another without a domain-specific frozen
  validation.

## 4. Controlled-Access Data

Private or partner datasets can participate if evaluation remains auditable.
The preferred framing is controlled access, not hidden evidence.

Minimal protocol:

1. dataset owner publishes or shares a redacted dataset card;
2. raw rows remain private, under NDA, enclave, data-owner execution, or trusted
   auditor control;
3. schema, field names, rough counts, unit definitions, endpoint grammar, and
   allowed train-only summaries are shared before proxy selection;
4. candidate proxy is submitted with transform code, baseline, metric, split,
   and failure rule;
5. sealed holdout or future surface is executed by the data owner, trusted
   runner, or controlled enclave;
6. a redacted result card is published with hashes or audit identifiers when
   possible;
7. success, no-support, weak-axis, or silence status is added to the mapping
   attempt ledger.

Submission budgets are required. If the same sealed dataset is queried
repeatedly, later submissions become exploratory or validation-candidate
evidence unless a fresh validation surface is reserved in advance.

## 5. Public Result Cards

Even when raw data are private, each attempt should leave a public or shareable
card:

```text
attempt_id:
domain:
data_access: public / controlled-access / private
dataset_card:
maintained_structure:
structure_granularity:
proxy_family:
baseline:
SP_axis:
frozen_transform:
metric:
validation_surface:
submission_count:
result_status:
failure_or_support_mode:
what_not_to_repeat:
what_would_promote_next:
artifact_links_or_audit_ids:
```

This makes failed attempts useful to other people without exposing raw rows.

## 6. Role of Current Route A Anchors

The current Route A packages serve as scaffolding for the ecosystem:

- Mixed-CSP shows how a drift-weighted coordinate can be frozen, validated, and
  externally rerun in a finite CSP family;
- Exp43c q-coloring shows how a first-moment coordinate can transfer across
  held-out q and survive outside reruns;
- failed or weakening non-CSP branches show why support language must stay
  narrow.

These anchors do not make future proxies automatic. They define a working
template: freeze, compare against baselines, record failures, rerun outside the
author environment, and keep each claim scoped to the package that passed.

## 7. Long-Term View

As better measurements become available, proxy precision should improve:

```text
coarse proxy -> independent SP axis -> direct event log -> audited repair /
maintenance / recovery flow -> cross-domain transferable principle
```

The program can therefore become sharper over time without becoming
anything-goes. The rule is:

```text
exploration may improve proxies indefinitely;
support only changes after a versioned frozen validation passes.
```

This is the empirical complement to the theory core. The core supplies the
common coordinate; the ecosystem supplies the disciplined way to decide which
domain proxies deserve to be promoted, replaced, or retired.
