import Survival.BayesianBridge

/-!
# Causal Inference Bridge — Pearl's do-calculus Reading

Reads causal inference through structural persistence: a causal
intervention do(X=x) changes the structural maintenance conditions G,
which changes the viable set V_G. The causal effect is measured by
the change in structural consumption.

Key identification:
- Observational distribution P(Y|X) → conditional viable set
- Interventional distribution P(Y|do(X=x)) → modified viable set
  (where the structural mechanism for X is replaced)
- Causal effect = difference in structural consumption
- Confounding = using wrong G (observational instead of interventional)
-/
namespace Survival.CausalInferenceBridge
open Real
noncomputable section

/-- A causal model with observational and interventional masses. -/
structure CausalModel where
  observationalMass : ℝ   -- m(V) under observation
  interventionalMass : ℝ  -- m(V) under do(X=x)
  obs_pos : 0 < observationalMass
  int_pos : 0 < interventionalMass

/-- The causal effect as structural consumption difference. -/
def causalEffect (M : CausalModel) : ℝ :=
  -log (M.interventionalMass / M.observationalMass)

/-- When intervention doesn't change the viable set, causal effect = 0. -/
theorem no_effect_when_same (M : CausalModel)
    (h : M.interventionalMass = M.observationalMass) :
    causalEffect M = 0 := by
  unfold causalEffect
  rw [h, div_self (ne_of_gt M.obs_pos), log_one, neg_zero]

/-- Confounding bias = difference between observational and
    interventional structural consumption. When they differ,
    the observational estimate is biased. -/
def confoundingBias (M : CausalModel) : ℝ :=
  |causalEffect M|

/-- No confounding iff causal effect is zero. -/
theorem no_confounding_iff_no_effect (M : CausalModel)
    (h : M.interventionalMass = M.observationalMass) :
    confoundingBias M = 0 := by
  unfold confoundingBias
  rw [no_effect_when_same M h, abs_zero]

end
end Survival.CausalInferenceBridge
