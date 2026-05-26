import Mathlib.Tactic.Linarith
import Survival.EpistemicControlComparison

/-!
# Epistemic Control Evaluation Contract

This file connects evaluation-facing loss / repair metrics to the abstract
baseline-comparison theorem.

It does not prove that a real benchmark measures these quantities correctly,
or that a real LLM system satisfies the hypotheses.  It proves the finite
accounting step that an implementation or experiment can try to witness:

* if controlled per-step contradiction loss is no larger than baseline loss;
* and controlled per-step repair gain is no smaller than baseline repair gain;
* and these metric sums read out the two cumulative net actions;

then the metrics witness `NetActionNoWorse`, hence the existing comparison
theorem applies.
-/

open scoped BigOperators

namespace Survival.EpistemicControlEvaluationContract

open Survival.EpistemicControlBridge
open Survival.EpistemicControlComparison
open Survival.GeneralStateDynamics

noncomputable section

variable {X : Type*}

/-- Evaluation-facing readouts for baseline and controlled layers. -/
structure EpistemicEvaluationMetrics where
  baselineLoss : ℕ → ℝ
  controlledLoss : ℕ → ℝ
  baselineRepair : ℕ → ℝ
  controlledRepair : ℕ → ℝ

/-- Baseline one-step net action read from evaluation metrics. -/
def baselineStepNet (M : EpistemicEvaluationMetrics) (t : ℕ) : ℝ :=
  M.baselineLoss t - M.baselineRepair t

/-- Controlled one-step net action read from evaluation metrics. -/
def controlledStepNet (M : EpistemicEvaluationMetrics) (t : ℕ) : ℝ :=
  M.controlledLoss t - M.controlledRepair t

/-- Baseline cumulative metric net action over `0, ..., n-1`. -/
def cumulativeBaselineNet (M : EpistemicEvaluationMetrics) (n : ℕ) : ℝ :=
  ∑ t ∈ Finset.range n, baselineStepNet M t

/-- Controlled cumulative metric net action over `0, ..., n-1`. -/
def cumulativeControlledNet (M : EpistemicEvaluationMetrics) (n : ℕ) : ℝ :=
  ∑ t ∈ Finset.range n, controlledStepNet M t

/-- Per-step metric dominance over a finite horizon. -/
structure EvaluationMetricDominance
    (M : EpistemicEvaluationMetrics) (n : ℕ) : Prop where
  loss_no_worse : ∀ t, t < n → M.controlledLoss t ≤ M.baselineLoss t
  repair_no_less : ∀ t, t < n → M.baselineRepair t ≤ M.controlledRepair t

/-- The metric sums agree with the bridge-level cumulative net actions. -/
structure MetricsReadoutMatchesNetAction
    (M : EpistemicEvaluationMetrics)
    (controlled baseline : EpistemicControlSpec X) (n : ℕ) : Prop where
  controlled_matches :
    cumulativeControlledNet M n =
      cumulativeEpistemicNetAction controlled n
  baseline_matches :
    cumulativeBaselineNet M n =
      cumulativeEpistemicNetAction baseline n

/-- Per-step dominance of loss and repair implies per-step net-action
dominance. -/
theorem controlledStepNet_le_baselineStepNet
    (M : EpistemicEvaluationMetrics) (t : ℕ)
    (hloss : M.controlledLoss t ≤ M.baselineLoss t)
    (hrepair : M.baselineRepair t ≤ M.controlledRepair t) :
    controlledStepNet M t ≤ baselineStepNet M t := by
  unfold controlledStepNet baselineStepNet
  linarith

/-- Per-step metric dominance implies cumulative metric net action is no worse
for the controlled layer. -/
theorem cumulativeControlledNet_le_cumulativeBaselineNet
    (M : EpistemicEvaluationMetrics) (n : ℕ)
    (hdom : EvaluationMetricDominance M n) :
    cumulativeControlledNet M n ≤ cumulativeBaselineNet M n := by
  unfold cumulativeControlledNet cumulativeBaselineNet
  refine Finset.sum_le_sum ?_
  intro t ht
  have ht_lt : t < n := Finset.mem_range.mp ht
  exact controlledStepNet_le_baselineStepNet M t
    (hdom.loss_no_worse t ht_lt)
    (hdom.repair_no_less t ht_lt)

/-- Evaluation metrics witness the abstract `NetActionNoWorse` hypothesis when
their cumulative readouts match the bridge-level cumulative net actions. -/
theorem metric_net_action_no_worse
    (M : EpistemicEvaluationMetrics)
    (controlled baseline : EpistemicControlSpec X) (n : ℕ)
    (hdom : EvaluationMetricDominance M n)
    (hreadout : MetricsReadoutMatchesNetAction M controlled baseline n) :
    NetActionNoWorse controlled baseline n := by
  unfold NetActionNoWorse
  rw [← hreadout.controlled_matches, ← hreadout.baseline_matches]
  exact cumulativeControlledNet_le_cumulativeBaselineNet M n hdom

/-- Evaluation metrics plus equal initial coherent mass assemble the full
baseline-comparison hypothesis used by `EpistemicControlComparison`. -/
theorem metrics_witness_baseline_comparison
    (M : EpistemicEvaluationMetrics)
    (controlled baseline : EpistemicControlSpec X) (n : ℕ)
    (hsame : SameInitialMass controlled baseline)
    (hdom : EvaluationMetricDominance M n)
    (hreadout : MetricsReadoutMatchesNetAction M controlled baseline n) :
    BaselineComparison controlled baseline n where
  same_initial_mass := hsame
  net_action_no_worse :=
    metric_net_action_no_worse M controlled baseline n hdom hreadout

/-- End-to-end evaluation contract: metric dominance and metric readout
alignment are enough to invoke the coherent-mass baseline comparison theorem. -/
theorem metrics_controlled_coherentMass_ge_baseline
    (M : EpistemicEvaluationMetrics)
    (controlled baseline : EpistemicControlSpec X) (n : ℕ)
    (hcontrolled :
      PositiveTrajectory (toProblemSpec controlled) n)
    (hbaseline :
      PositiveTrajectory (toProblemSpec baseline) n)
    (hsame : SameInitialMass controlled baseline)
    (hdom : EvaluationMetricDominance M n)
    (hreadout : MetricsReadoutMatchesNetAction M controlled baseline n) :
    coherentMass baseline n ≤ coherentMass controlled n :=
  controlled_coherentMass_ge_baseline
    controlled baseline n hcontrolled hbaseline
    (metrics_witness_baseline_comparison
      M controlled baseline n hsame hdom hreadout)

end

end Survival.EpistemicControlEvaluationContract
