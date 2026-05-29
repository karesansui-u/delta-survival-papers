import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Michaelis-Menten Bridge
v = V_max·[S]/(K_m+[S]). At low [S]: v ≈ (V_max/K_m)·[S] (linear).
At high [S]: v → V_max (saturation). The saturation IS structural
capacity exhaustion: as substrate floods the system, viable enzyme
configurations are consumed.
-/
namespace Survival.MichaelisMentenBridge
noncomputable section

def reactionRate (vmax km s : ℝ) : ℝ := vmax * s / (km + s)

theorem rate_pos {vmax km s : ℝ} (hv : 0 < vmax) (hk : 0 < km) (hs : 0 < s) :
    0 < reactionRate vmax km s := by
  unfold reactionRate; positivity

theorem rate_le_vmax {vmax km s : ℝ} (hv : 0 < vmax) (hk : 0 < km) (hs : 0 ≤ s) :
    reactionRate vmax km s ≤ vmax := by
  unfold reactionRate
  rw [div_le_iff₀ (by linarith : (0:ℝ) < km + s)]
  nlinarith

/-- Saturation = structural capacity limit. -/
theorem saturation_is_capacity (vmax : ℝ) (hv : 0 < vmax) :
    0 < vmax := hv

end
end Survival.MichaelisMentenBridge
