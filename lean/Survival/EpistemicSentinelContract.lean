import Survival.EpistemicBenchmarkProtocol

/-!
# Epistemic Sentinel Contract

This file adds a minimal contract layer for a content-blind sentinel that
routes epistemic checks before a heavier semantic-judgment path.

It does not prove that a concrete implementation is content-blind, calibrated,
or empirically optimal.  It only formalizes the theorem-side shape needed to
connect sentinel-facing obligations to the existing benchmark protocol and
coherent-mass comparison theorems.
-/

namespace Survival.EpistemicSentinelContract

open Survival.EpistemicControlBridge
open Survival.EpistemicControlComparison
open Survival.EpistemicControlEvaluationContract
open Survival.EpistemicBenchmarkProtocol
open Survival.GeneralStateDynamics

noncomputable section

variable {X : Type*}

/-- Sentinel decision surface for one step. -/
inductive SentinelDecision where
  | hardReject
  | escalate
  | defer
  | accept
deriving DecidableEq, Repr

/-- Minimal per-step sentinel readout.

`anomalyScore` and `contradictionScore` are abstract readouts; this file does
not commit to a specific estimator (e.g., surprisal, drift, compression, or
schema-only proxy). -/
structure SentinelStepReadout where
  anomalyScore : ℝ
  contradictionScore : ℝ
  decision : SentinelDecision
  judgeCalled : Bool

/-- Policy-side obligations carried as explicit assumptions.

The three fields represent design-time claims that a concrete implementation
must justify externally (spec, tests, benchmark evidence). -/
structure SentinelPolicyContract where
  content_blind_hot_path : Prop
  hard_reject_sound : Prop
  escalate_path_sound : Prop

/-- Evaluation-facing metrics for sentinel experiments.

This extends the existing epistemic loss/repair metrics with operational
readouts typically used by a sentinel layer. -/
structure SentinelEvaluationMetrics where
  core : EpistemicEvaluationMetrics
  baselineJudgeCall : ℕ → ℝ
  controlledJudgeCall : ℕ → ℝ
  baselineEscalationRecall : ℕ → ℝ
  controlledEscalationRecall : ℕ → ℝ
  baselineFalseAbstention : ℕ → ℝ
  controlledFalseAbstention : ℕ → ℝ

/-- Operational dominance assumptions for a finite horizon. -/
structure SentinelOperationalDominance
    (M : SentinelEvaluationMetrics) (n : ℕ) : Prop where
  metric_dominance : EvaluationMetricDominance M.core n
  judge_call_no_more :
    ∀ t, t < n → M.controlledJudgeCall t ≤ M.baselineJudgeCall t
  escalation_recall_no_less :
    ∀ t, t < n →
      M.baselineEscalationRecall t ≤ M.controlledEscalationRecall t
  false_abstention_no_more :
    ∀ t, t < n →
      M.controlledFalseAbstention t ≤ M.baselineFalseAbstention t

/-- Sentinel operational dominance implies the core metric-dominance premise. -/
theorem sentinelOperationalDominance_implies_metricDominance
    (M : SentinelEvaluationMetrics) (n : ℕ)
    (hdom : SentinelOperationalDominance M n) :
    EvaluationMetricDominance M.core n :=
  hdom.metric_dominance

/-- Sentinel protocol wrapper over the generic benchmark protocol. -/
structure SentinelBenchmarkProtocol (X : Type*) where
  protocol : BenchmarkProtocol X
  frozenPolicySurface : Prop
  frozenThresholdSpec : Prop

/-- Validity witnesses required for the sentinel protocol wrapper. -/
structure ValidSentinelBenchmarkProtocol
    (P : SentinelBenchmarkProtocol X) : Prop where
  benchmark_valid : ValidEpistemicBenchmarkProtocol P.protocol
  frozen_policy_surface : P.frozenPolicySurface
  frozen_threshold_spec : P.frozenThresholdSpec

/-- A valid sentinel protocol exposes the underlying benchmark validity. -/
theorem sentinel_protocol_implies_benchmark_valid
    (P : SentinelBenchmarkProtocol X)
    (hvalid : ValidSentinelBenchmarkProtocol P) :
    ValidEpistemicBenchmarkProtocol P.protocol :=
  hvalid.benchmark_valid

/-- Sentinel wrapper theorem: no-worse net action at the same horizon. -/
theorem sentinel_protocol_implies_net_action_no_worse
    (P : SentinelBenchmarkProtocol X)
    (hvalid : ValidSentinelBenchmarkProtocol P) :
    NetActionNoWorse P.protocol.controlled P.protocol.baseline
      P.protocol.horizon :=
  benchmark_protocol_implies_net_action_no_worse P.protocol hvalid.benchmark_valid

/-- Sentinel wrapper theorem: controlled coherent mass dominates baseline. -/
theorem sentinel_protocol_implies_controlled_mass_ge_baseline
    (P : SentinelBenchmarkProtocol X)
    (hvalid : ValidSentinelBenchmarkProtocol P) :
    coherentMass P.protocol.baseline P.protocol.horizon ≤
      coherentMass P.protocol.controlled P.protocol.horizon :=
  benchmark_protocol_implies_controlled_mass_ge_baseline
    P.protocol hvalid.benchmark_valid

/-- End-to-end finite-horizon bridge from sentinel metric assumptions to the
existing coherent-mass comparison theorem. -/
theorem sentinel_metrics_controlled_coherentMass_ge_baseline
    (M : SentinelEvaluationMetrics)
    (controlled baseline : EpistemicControlSpec X) (n : ℕ)
    (hcontrolled :
      PositiveTrajectory (toProblemSpec controlled) n)
    (hbaseline :
      PositiveTrajectory (toProblemSpec baseline) n)
    (hsame : SameInitialMass controlled baseline)
    (hdom : SentinelOperationalDominance M n)
    (hreadout :
      MetricsReadoutMatchesNetAction M.core controlled baseline n) :
    coherentMass baseline n ≤ coherentMass controlled n :=
  metrics_controlled_coherentMass_ge_baseline
    M.core controlled baseline n
    hcontrolled hbaseline hsame
    (sentinelOperationalDominance_implies_metricDominance M n hdom)
    hreadout

end

end Survival.EpistemicSentinelContract
