import Survival.EpistemicBenchmarkProtocol

/-!
# Epistemic Benchmark Result Certificate

This file adds a thin result-certificate layer above the benchmark protocol.

It does not parse JSON, validate a real benchmark, certify a dataset split, or
prove model performance.  Instead, it records the theorem-side shape of a
result certificate that an external runner may emit:

* metadata identifying the finite protocol and result artifact;
* witnesses that the task surface and readout were frozen;
* same-horizon and same-initial-mass witnesses;
* finite positivity witnesses;
* metric-dominance and readout-alignment witnesses.

When those witnesses are supplied, the certificate induces a valid benchmark
protocol and can invoke the existing no-worse net-action and coherent-mass
comparison theorems.
-/

namespace Survival.EpistemicBenchmarkResultCertificate

open Survival.EpistemicBenchmarkProtocol
open Survival.EpistemicControlBridge
open Survival.EpistemicControlComparison
open Survival.EpistemicControlEvaluationContract
open Survival.GeneralStateDynamics

noncomputable section

variable {X : Type*}

/-- Metadata and protocol pointer for a finite benchmark result certificate.

The string fields are labels / digests only.  Lean does not interpret them as a
proof that a concrete JSON file or external benchmark is valid. -/
structure BenchmarkResultCertificate (X : Type*) where
  protocol : BenchmarkProtocol X
  protocolId : String
  resultId : String
  taskSurfaceDigest : String
  resultDigest : String
  runnerId : String
  protocolShapeValid : Prop

/-- The theorem-side witnesses that make a result certificate usable.

These fields intentionally mirror `ValidEpistemicBenchmarkProtocol`; the point
of this layer is to expose what an external result artifact must justify before
the Lean benchmark theorem can be invoked. -/
structure ValidBenchmarkResultCertificate
    (C : BenchmarkResultCertificate X) : Prop where
  protocol_shape_valid : C.protocolShapeValid
  frozen_task_surface : C.protocol.frozenTaskSurface
  frozen_readout : C.protocol.frozenReadout
  same_horizon_comparison : C.protocol.sameHorizonComparison
  same_initial_mass :
    SameInitialMass C.protocol.controlled C.protocol.baseline
  controlled_positive :
    PositiveTrajectory (toProblemSpec C.protocol.controlled)
      C.protocol.horizon
  baseline_positive :
    PositiveTrajectory (toProblemSpec C.protocol.baseline)
      C.protocol.horizon
  metric_dominance :
    EvaluationMetricDominance C.protocol.metrics C.protocol.horizon
  readout_matches :
    MetricsReadoutMatchesNetAction
      C.protocol.metrics C.protocol.controlled C.protocol.baseline
      C.protocol.horizon

/-- A valid result certificate exposes the underlying protocol-shape witness. -/
theorem result_certificate_protocol_shape_valid
    (C : BenchmarkResultCertificate X)
    (hvalid : ValidBenchmarkResultCertificate C) :
    C.protocolShapeValid :=
  hvalid.protocol_shape_valid

/-- A valid result certificate induces a valid generic benchmark protocol. -/
theorem result_certificate_implies_benchmark_valid
    (C : BenchmarkResultCertificate X)
    (hvalid : ValidBenchmarkResultCertificate C) :
    ValidEpistemicBenchmarkProtocol C.protocol where
  frozen_task_surface := hvalid.frozen_task_surface
  frozen_readout := hvalid.frozen_readout
  same_horizon_comparison := hvalid.same_horizon_comparison
  same_initial_mass := hvalid.same_initial_mass
  controlled_positive := hvalid.controlled_positive
  baseline_positive := hvalid.baseline_positive
  metric_dominance := hvalid.metric_dominance
  readout_matches := hvalid.readout_matches

/-- A valid result certificate witnesses the no-worse cumulative net-action
premise through its induced benchmark protocol. -/
theorem result_certificate_implies_net_action_no_worse
    (C : BenchmarkResultCertificate X)
    (hvalid : ValidBenchmarkResultCertificate C) :
    NetActionNoWorse C.protocol.controlled C.protocol.baseline
      C.protocol.horizon :=
  benchmark_protocol_implies_net_action_no_worse
    C.protocol (result_certificate_implies_benchmark_valid C hvalid)

/-- A valid result certificate assembles the baseline-comparison hypothesis. -/
theorem result_certificate_witnesses_baseline_comparison
    (C : BenchmarkResultCertificate X)
    (hvalid : ValidBenchmarkResultCertificate C) :
    BaselineComparison C.protocol.controlled C.protocol.baseline
      C.protocol.horizon :=
  benchmark_protocol_witnesses_baseline_comparison
    C.protocol (result_certificate_implies_benchmark_valid C hvalid)

/-- End-to-end result-certificate theorem.

If an external result artifact supplies the certificate witnesses, then the
controlled layer preserves at least the baseline coherent mass in the finite
accounting model. -/
theorem result_certificate_implies_controlled_mass_ge_baseline
    (C : BenchmarkResultCertificate X)
    (hvalid : ValidBenchmarkResultCertificate C) :
    coherentMass C.protocol.baseline C.protocol.horizon ≤
      coherentMass C.protocol.controlled C.protocol.horizon :=
  benchmark_protocol_implies_controlled_mass_ge_baseline
    C.protocol (result_certificate_implies_benchmark_valid C hvalid)

end

end Survival.EpistemicBenchmarkResultCertificate
