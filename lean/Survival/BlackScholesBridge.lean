import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Black-Scholes Bridge
Log-normal stock price: ln S_t = ln S_0 + (μ - σ²/2)t + σW_t.
The drift term (μ - σ²/2) is the structural consumption rate.
-/
namespace Survival.BlackScholesBridge
noncomputable section

/-- Log-price drift (risk-neutral): structural consumption rate. -/
def logPriceDrift (mu sigma : ℝ) : ℝ := mu - sigma ^ 2 / 2

/-- The log-price at time t under constant drift. -/
def logPrice (s₀ mu sigma t : ℝ) : ℝ := Real.log s₀ + logPriceDrift mu sigma * t

/-- The price process: S_t = S_0 exp(drift · t). -/
def priceProcess (s₀ mu sigma t : ℝ) : ℝ :=
  s₀ * Real.exp (logPriceDrift mu sigma * t)

/-- This IS S = M exp(-L) with L = -(drift · t).
When drift < 0, the price decays (structural consumption). -/
theorem bs_is_persistence (s₀ mu sigma t : ℝ) :
    priceProcess s₀ mu sigma t =
      s₀ * Real.exp (-(-(logPriceDrift mu sigma) * t)) := by
  unfold priceProcess; congr 1; ring

/-- Volatility σ² reduces the drift, accelerating structural consumption. -/
theorem volatility_increases_consumption (mu sigma₁ sigma₂ : ℝ) (h : sigma₁ ^ 2 < sigma₂ ^ 2) :
    logPriceDrift mu sigma₂ < logPriceDrift mu sigma₁ := by
  unfold logPriceDrift; linarith

end
end Survival.BlackScholesBridge
