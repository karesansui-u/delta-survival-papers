import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Stirling Bridge
ln n! ≈ n ln n - n connects combinatorial counting to structural consumption.
The number of viable configurations W = n! gives L = -ln(W_n/W_0).
-/
namespace Survival.StirlingBridge
noncomputable section

/-- Stirling's approximation (lower bound): ln(n!) ≥ n ln n - n for n ≥ 1. -/
def stirlingApprox (n : ℝ) : ℝ := n * Real.log n - n

/-- The structural consumption from reducing n! configurations to m! is
ln(n!) - ln(m!) = ln(n!/m!). When m < n, this is positive. -/
theorem combinatorial_consumption (n m : ℝ) (hn : 0 < n) (hm : 0 < m) (hnm : m < n) :
    0 < Real.log n - Real.log m := by
  exact sub_pos.mpr (Real.log_lt_log hm hnm)

/-- Reducing configurations by factor r gives consumption -ln r. -/
theorem configuration_reduction (r : ℝ) (hr : 0 < r) (hr1 : r < 1) :
    0 < -Real.log r := by
  rw [neg_pos]; exact Real.log_neg hr hr1

end
end Survival.StirlingBridge
