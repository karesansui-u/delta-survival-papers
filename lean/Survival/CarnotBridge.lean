import Survival.ClausiusBridge
/-!
# Carnot Bridge — Maximum Efficiency η = 1 - T_c/T_h
Carnot's theorem: no heat engine operating between T_h and T_c
can exceed efficiency η = 1 - T_c/T_h. Structural reading:
the maximum fraction of resource M that can be converted to
structural recovery (useful work) is bounded by the temperature
ratio. The rest is irreversible structural consumption.
-/
namespace Survival.CarnotBridge
open Real
noncomputable section
structure CarnotModel where
  hotTemp : ℝ     -- T_h
  coldTemp : ℝ    -- T_c
  hot_pos : 0 < hotTemp
  cold_pos : 0 < coldTemp
  cold_lt_hot : coldTemp < hotTemp

/-- Carnot efficiency = maximum recovery fraction. -/
def carnotEfficiency (M : CarnotModel) : ℝ := 1 - M.coldTemp / M.hotTemp

/-- Carnot efficiency is positive. -/
theorem efficiency_pos (M : CarnotModel) : 0 < carnotEfficiency M := by
  unfold carnotEfficiency
  rw [sub_pos]
  exact (div_lt_one₀ M.hot_pos).mpr M.cold_lt_hot

/-- Carnot efficiency is less than 1 (can't convert all heat to work). -/
theorem efficiency_lt_one (M : CarnotModel) : carnotEfficiency M < 1 := by
  unfold carnotEfficiency; linarith [div_pos M.cold_pos M.hot_pos]

/-- Minimum irreversible consumption = 1 - η = T_c/T_h. -/
def irreversibleFraction (M : CarnotModel) : ℝ := M.coldTemp / M.hotTemp

/-- Irreversible fraction is positive (always some waste). -/
theorem irreversible_pos (M : CarnotModel) : 0 < irreversibleFraction M :=
  div_pos M.cold_pos M.hot_pos

/-- Larger temperature ratio → higher efficiency → less waste. -/
theorem larger_ratio_more_efficient (M₁ M₂ : CarnotModel)
    (hh : M₁.hotTemp = M₂.hotTemp) (hc : M₂.coldTemp < M₁.coldTemp) :
    carnotEfficiency M₁ < carnotEfficiency M₂ := by
  unfold carnotEfficiency; rw [hh]
  linarith [div_lt_div_of_pos_right hc M₂.hot_pos]
end
end Survival.CarnotBridge
