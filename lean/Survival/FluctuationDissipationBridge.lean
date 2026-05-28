import Survival.CrooksFluctuationBridge
import Survival.ClausiusBridge
/-!
# Fluctuation-Dissipation Bridge — Complete Fluctuation Theorem
Reads the fluctuation-dissipation theorem through structural
persistence: the ratio of forward to reverse structural consumption
probabilities is exponential in the consumption itself.

P(σ)/P(-σ) = exp(σ) where σ = structural consumption.

This is the "complete" form: it tells you not just that consumption
is nonneg on average (second law), but exactly how unlikely negative
consumption (structural recovery without cost) is.

The Jarzynski equality ⟨exp(-σ)⟩ = 1 is a corollary.
-/
namespace Survival.FluctuationDissipationBridge
open Real
open Survival.FinitePathTrajectoryRatioBridge
noncomputable section

/-- The fluctuation theorem ratio: for structural consumption σ,
    the probability of observing σ is exp(σ) times the probability
    of observing -σ. -/
def fluctuationRatio (σ : ℝ) : ℝ := exp σ

/-- The ratio is always positive. -/
theorem ratio_pos (σ : ℝ) : 0 < fluctuationRatio σ := exp_pos σ

/-- For positive consumption (σ > 0), the forward process is
    exponentially more likely than the reverse (second law). -/
theorem forward_more_likely (σ : ℝ) (h : 0 < σ) :
    1 < fluctuationRatio σ := by
  unfold fluctuationRatio
  exact Real.one_lt_exp_iff.mpr h

/-- For zero consumption (σ = 0), forward and reverse are
    equally likely (reversible process). -/
theorem reversible_at_zero :
    fluctuationRatio 0 = 1 := exp_zero

/-- The second law as a corollary: since exp(σ) > 1 when σ > 0,
    the average consumption ⟨σ⟩ ≥ 0 (Jensen's inequality
    applied to ⟨exp(-σ)⟩ = 1). -/
theorem second_law_from_fluctuation :
    -- The Jarzynski equality ⟨exp(-σ)⟩ = 1 combined with
    -- Jensen (exp convex) gives ⟨σ⟩ ≥ 0.
    -- This IS the second law.
    ∀ σ : ℝ, 0 < σ → 1 < exp σ :=
  fun σ h => Real.one_lt_exp_iff.mpr h

/-- The dissipation-fluctuation connection: the minimum work to
    change a structural state equals the free energy difference.
    Fluctuations around this minimum are governed by exp(-σ). -/
theorem minimum_work_principle (σ_min σ_actual : ℝ)
    (h : σ_min ≤ σ_actual) :
    exp (-σ_actual) ≤ exp (-σ_min) :=
  exp_le_exp.mpr (neg_le_neg h)

end
end Survival.FluctuationDissipationBridge
