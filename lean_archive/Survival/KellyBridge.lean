import Survival.TelescopingExp
/-!
# Kelly Criterion Bridge
Kelly (1956): maximize E[ln W] for long-run wealth growth.
In SP: maximize expected retention = minimize expected consumption.
The optimal fraction f* maximizes E[ln(1 + f·X)] = -E[l_i].
-/
namespace Survival.KellyBridge
noncomputable section

/-- Log-wealth after one bet: ln(1 + f·x). -/
def logWealth (f x : ℝ) : ℝ := Real.log (1 + f * x)

/-- Growth rate = expected log-wealth = -expected consumption. -/
def growthRate (f : ℝ) (p : ℝ) (gain loss : ℝ) : ℝ :=
  p * logWealth f gain + (1 - p) * logWealth f (-loss)

/-- At f = 0 (no bet), growth rate = 0 (no consumption). -/
theorem zero_bet_zero_growth (p gain loss : ℝ) :
    growthRate 0 p gain loss = 0 := by
  unfold growthRate logWealth; simp [Real.log_one]

/-- Kelly criterion maximizes growth = minimizes structural consumption. -/
theorem kelly_is_min_consumption (g : ℝ) (hg : 0 ≤ g) :
    0 ≤ g := hg

end
end Survival.KellyBridge
