import Survival.KLDivergence
import Survival.TelescopingExp
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Bayesian Bridge — Bayes' Theorem as Structural Update

Reads Bayesian inference through structural persistence:
updating beliefs = structural consumption where the "loss" is
the information gained from observation.

Key identification:
- Prior → initial viable set m(V^{(0)})
- Likelihood → constraint that shrinks V
- Posterior → updated viable set m(V^{(1)})
- KL(posterior ‖ prior) = structural consumption l = information gained
- Bayes update = one step of structural consumption
-/
namespace Survival.BayesianBridge
open Real
noncomputable section

/-- A Bayesian update model: prior mass shrinks to posterior mass
    after observing evidence. -/
structure BayesianUpdate where
  priorMass : ℝ       -- m(V^{(0)})
  posteriorMass : ℝ    -- m(V^{(1)})
  prior_pos : 0 < priorMass
  posterior_pos : 0 < posteriorMass
  posterior_le : posteriorMass ≤ priorMass  -- evidence constrains

/-- The information gained = structural consumption from the update. -/
def informationGain (B : BayesianUpdate) : ℝ :=
  -log (B.posteriorMass / B.priorMass)

/-- Information gain is nonneg (evidence reduces uncertainty =
    positive structural consumption). -/
theorem informationGain_nonneg (B : BayesianUpdate) :
    0 ≤ informationGain B := by
  unfold informationGain
  rw [neg_nonneg]
  exact log_nonpos (le_of_lt (div_pos B.posterior_pos B.prior_pos))
    ((div_le_one₀ B.prior_pos).mpr B.posterior_le)

/-- No evidence = no information gain. -/
theorem no_evidence_no_gain (B : BayesianUpdate)
    (h : B.posteriorMass = B.priorMass) :
    informationGain B = 0 := by
  unfold informationGain
  rw [h, div_self (ne_of_gt B.prior_pos), log_one, neg_zero]

/-- The retention factor after a Bayesian update. -/
theorem bayesian_retention (B : BayesianUpdate) :
    exp (-informationGain B) = B.posteriorMass / B.priorMass := by
  unfold informationGain
  rw [neg_neg, exp_log (div_pos B.posterior_pos B.prior_pos)]

/-- Sequential updates: the total information gain from n
    observations is the sum of individual gains (telescoping). -/
theorem sequential_updates_telescope
    (masses : ℕ → ℝ) (n : ℕ)
    (hm : ∀ i ≤ n, 0 < masses i) :
    exp (-∑ i ∈ Finset.range n,
      (-log (masses (i + 1) / masses i))) =
      masses n / masses 0 :=
  Survival.TelescopingExp.exp_neg_sum_stageLoss_eq_ratio masses n hm

end
end Survival.BayesianBridge
