LLM Epistemic-Control Benchmark Manifest
========================================

Status: protocol manifest; not validation evidence

Date frozen: 2026-05-27 JST

Lean protocol target:

- `../../../lean/Survival/EpistemicBenchmarkProtocol.lean`
- `../../../lean/Survival/EpistemicControlEvaluationContract.lean`

This manifest states how a future LLM-style epistemic-control benchmark should
try to witness the Lean evaluation contract. It does not report results and
does not claim that any model, benchmark, or implementation already satisfies
the protocol.


1. Task Surface
---------------

The benchmark surface must be frozen before outcome-bearing execution.

Allowed task families for the first protocol:

- contradiction-injection tasks;
- premise-update tasks;
- memory-eligibility tasks;
- dependency-rewrite tasks.

Each task must specify:

- the initial information state;
- the injected contradiction, premise update, or raw memory item;
- the expected dependency surface, when applicable;
- the finite horizon \(n\);
- the readout fields used for loss and repair.

No task may be added, removed, or relabeled after model outputs or workflow
outcomes are inspected.


2. Baseline
-----------

The baseline system is a predeclared no-control or weak-control policy. Examples
include:

- accept-all memory admission;
- no dependency-aware rewrite;
- no explicit contradiction metabolism;
- generic summary or retrieval without eligibility gating.

The baseline must run on the same task surface and the same horizon as the
controlled system.


3. Controlled System
--------------------

The controlled system is a predeclared epistemic-control policy. Examples
include:

- contradiction metabolism before answer generation;
- dependency-aware premise refresh;
- memory eligibility filtering;
- lifecycle and provenance guards before memory use.

The controlled system may not receive extra task information unavailable to the
baseline except for the predeclared control state used by the protocol.


4. Horizon
----------

The horizon \(n\) is fixed before evaluation.

All loss, repair, and readout-alignment checks are evaluated over
`0, ..., n-1`. Baseline and controlled runs must use the same \(n\).


5. Metrics
----------

For each finite step \(t < n\), the manifest must define:

- `baselineLoss(t)`;
- `controlledLoss(t)`;
- `baselineRepair(t)`;
- `controlledRepair(t)`.

The intended Lean reading is:

```text
EpistemicEvaluationMetrics.baselineLoss
EpistemicEvaluationMetrics.controlledLoss
EpistemicEvaluationMetrics.baselineRepair
EpistemicEvaluationMetrics.controlledRepair
```

The metric definitions must be fixed before evaluation. A later diagnostic may
be reported, but it cannot be promoted into the support-bearing readout for the
same run.


6. Dominance Rule
-----------------

The metric-dominance witness for the Lean protocol is:

```text
controlledLoss(t) <= baselineLoss(t)
baselineRepair(t) <= controlledRepair(t)
```

for every \(t < n\), or for the predeclared aggregation rule if the benchmark
uses aggregate cells. If an aggregate rule is used, the aggregation operator,
tie policy, missing-output policy, and failure handling must be frozen before
execution.


7. Readout Alignment
--------------------

The manifest must explain why the cumulative metric sums are read as the
bridge-level cumulative net actions:

```text
sum_t (controlledLoss(t) - controlledRepair(t))
  = cumulativeEpistemicNetAction controlled n

sum_t (baselineLoss(t) - baselineRepair(t))
  = cumulativeEpistemicNetAction baseline n
```

This is the `MetricsReadoutMatchesNetAction` obligation. It is not automatic.
It must be justified by the benchmark design or treated as an explicit
assumption.


8. Decision Rule
----------------

A run satisfies the protocol only if all of the following hold:

- the task surface was frozen before outcome-bearing execution;
- the readout was frozen before outcome-bearing execution;
- baseline and controlled systems used the same horizon;
- same initial coherent mass is justified or explicitly assumed;
- metric dominance holds under the frozen rule;
- readout alignment is supplied;
- no post-hoc metric, split, or task remapping is used.

Failure of any item is recorded as invalid-run or silence, not as support.


9. Mapping To Lean
------------------

| Manifest item | Lean object |
|---|---|
| Task surface | `BenchmarkProtocol.Task` |
| Baseline system | `BenchmarkProtocol.baseline` |
| Controlled system | `BenchmarkProtocol.controlled` |
| Horizon | `BenchmarkProtocol.horizon` |
| Metrics | `BenchmarkProtocol.metrics` |
| Frozen task surface | `ValidEpistemicBenchmarkProtocol.frozen_task_surface` |
| Frozen readout | `ValidEpistemicBenchmarkProtocol.frozen_readout` |
| Same horizon | `ValidEpistemicBenchmarkProtocol.same_horizon_comparison` |
| Same initial mass | `ValidEpistemicBenchmarkProtocol.same_initial_mass` |
| Positive trajectories | `ValidEpistemicBenchmarkProtocol.controlled_positive`, `baseline_positive` |
| Metric dominance | `ValidEpistemicBenchmarkProtocol.metric_dominance` |
| Readout alignment | `ValidEpistemicBenchmarkProtocol.readout_matches` |


10. Non-Claims
--------------

This manifest does not claim:

- a proof of LLM semantics or model performance;
- that any benchmark measures the Lean quantities correctly without a separate
  readout-alignment argument;
- that memory safety, continual-learning safety, or agent reliability follows;
- that future empirical support can be transferred from another domain;
- that field demonstrations are theorem-side evidence.
