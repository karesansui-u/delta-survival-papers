import Survival.EpistemicControlEvaluationContract

/-!
# Epistemic Benchmark Protocol

This file fixes the protocol assumptions needed to use the evaluation contract.

It does not validate any real benchmark, dataset, split, metric, or model.  It
formalizes the shape of a finite benchmark protocol that can witness the
comparison theorem:

* the task surface and readout are frozen;
* baseline and controlled layers are compared at the same finite horizon;
* the two layers have the same initial coherent mass;
* the metric dominance and readout-alignment witnesses are supplied.

Under those protocol-validity assumptions, the existing evaluation contract
implies the coherent-mass baseline comparison.
-/

namespace Survival.EpistemicBenchmarkProtocol

open Survival.EpistemicControlBridge
open Survival.EpistemicControlComparison
open Survival.EpistemicControlEvaluationContract
open Survival.GeneralStateDynamics

noncomputable section

variable {X : Type*}

/-- Benchmark metadata and fixed comparison surface.

The three `Prop` fields are explicit protocol obligations.  They are not
proved by this structure; `ValidEpistemicBenchmarkProtocol` carries the
corresponding witnesses. -/
structure BenchmarkProtocol (X : Type*) where
  Task : Type*
  baseline : EpistemicControlSpec X
  controlled : EpistemicControlSpec X
  horizon : ℕ
  metrics : EpistemicEvaluationMetrics
  frozenTaskSurface : Prop
  frozenReadout : Prop
  sameHorizonComparison : Prop

/-- Validity witnesses required before a benchmark protocol can invoke the
evaluation contract. -/
structure ValidEpistemicBenchmarkProtocol
    (P : BenchmarkProtocol X) : Prop where
  frozen_task_surface : P.frozenTaskSurface
  frozen_readout : P.frozenReadout
  same_horizon_comparison : P.sameHorizonComparison
  same_initial_mass : SameInitialMass P.controlled P.baseline
  controlled_positive :
    PositiveTrajectory (toProblemSpec P.controlled) P.horizon
  baseline_positive :
    PositiveTrajectory (toProblemSpec P.baseline) P.horizon
  metric_dominance :
    EvaluationMetricDominance P.metrics P.horizon
  readout_matches :
    MetricsReadoutMatchesNetAction
      P.metrics P.controlled P.baseline P.horizon

/-- A valid benchmark protocol witnesses the no-worse cumulative net-action
premise used by the comparison theorem. -/
theorem benchmark_protocol_implies_net_action_no_worse
    (P : BenchmarkProtocol X)
    (hvalid : ValidEpistemicBenchmarkProtocol P) :
    NetActionNoWorse P.controlled P.baseline P.horizon :=
  metric_net_action_no_worse
    P.metrics P.controlled P.baseline P.horizon
    hvalid.metric_dominance hvalid.readout_matches

/-- A valid benchmark protocol assembles the full baseline-comparison
hypothesis. -/
theorem benchmark_protocol_witnesses_baseline_comparison
    (P : BenchmarkProtocol X)
    (hvalid : ValidEpistemicBenchmarkProtocol P) :
    BaselineComparison P.controlled P.baseline P.horizon :=
  metrics_witness_baseline_comparison
    P.metrics P.controlled P.baseline P.horizon
    hvalid.same_initial_mass
    hvalid.metric_dominance
    hvalid.readout_matches

/-- End-to-end benchmark protocol theorem.

Once the protocol validity witnesses are supplied, the benchmark protocol
invokes the existing evaluation contract and coherent-mass comparison theorem. -/
theorem benchmark_protocol_implies_controlled_mass_ge_baseline
    (P : BenchmarkProtocol X)
    (hvalid : ValidEpistemicBenchmarkProtocol P) :
    coherentMass P.baseline P.horizon ≤
      coherentMass P.controlled P.horizon :=
  metrics_controlled_coherentMass_ge_baseline
    P.metrics P.controlled P.baseline P.horizon
    hvalid.controlled_positive
    hvalid.baseline_positive
    hvalid.same_initial_mass
    hvalid.metric_dominance
    hvalid.readout_matches

end

end Survival.EpistemicBenchmarkProtocol
