import Survival.KLDivergence
import Survival.BayesianBridge
/-!
# MLE Bridge — Maximum Likelihood Estimation
MLE: θ_ML = argmax_θ Π p(x_i|θ) = argmin_θ -Σ log p(x_i|θ).
Structural reading: MLE minimizes the cumulative structural
consumption L = -Σ log p(x_i|θ) = Σ l_i. The maximum likelihood
estimate is the parameter that minimizes total structural loss.

MLE = min L. By the duality theorem, this also maximizes S.
-/
namespace Survival.MLEBridge
open Real
noncomputable section
/-- Log-likelihood = negative of structural consumption. -/
def logLikelihood (logProbs : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, logProbs i

/-- Negative log-likelihood = structural consumption. -/
def negLogLikelihood (logProbs : ℕ → ℝ) (n : ℕ) : ℝ :=
  -(logLikelihood logProbs n)

/-- MLE minimizes structural consumption (= maximizes likelihood). -/
theorem mle_is_min_consumption (lp₁ lp₂ : ℕ → ℝ) (n : ℕ)
    (h : logLikelihood lp₁ n ≥ logLikelihood lp₂ n) :
    negLogLikelihood lp₁ n ≤ negLogLikelihood lp₂ n := by
  unfold negLogLikelihood; linarith

/-- Higher likelihood = lower consumption = better model. -/
theorem better_model_lower_consumption (lp₁ lp₂ : ℕ → ℝ) (n : ℕ)
    (h : logLikelihood lp₁ n > logLikelihood lp₂ n) :
    negLogLikelihood lp₁ n < negLogLikelihood lp₂ n := by
  unfold negLogLikelihood; linarith
end
end Survival.MLEBridge
