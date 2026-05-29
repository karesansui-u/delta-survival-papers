import Survival.MartingaleConvergenceBridge
/-!
# Itô Bridge — Stochastic Differential Equations
Reads Itô's formula through structural persistence: for a
stochastic process dX = μdt + σdW, the structural consumption
has both a drift component (μ → systematic) and a diffusion
component (σ² → noise-induced consumption).

Itô's correction: the σ²/2 term is additional structural
consumption from volatility. Higher noise = more consumption,
even with zero drift.
-/
namespace Survival.ItoBridge
open Real
noncomputable section
structure SDEModel where
  drift : ℝ        -- μ (systematic component)
  volatility : ℝ   -- σ (noise amplitude)
  vol_nonneg : 0 ≤ volatility

/-- Itô's correction: effective drift includes σ²/2 term.
    Even zero-drift processes have positive structural consumption
    from noise (Itô's lemma). -/
def effectiveDrift (M : SDEModel) : ℝ := M.drift + M.volatility ^ 2 / 2

/-- Pure noise (zero drift) still has positive effective drift
    when volatility > 0. This is Itô's correction. -/
theorem noise_induces_consumption (M : SDEModel) (hv : 0 < M.volatility)
    (hd : M.drift = 0) :
    0 < effectiveDrift M := by
  unfold effectiveDrift
  rw [hd, zero_add]
  exact div_pos (sq_pos_of_pos hv) two_pos

/-- Zero noise: effective drift = actual drift. -/
theorem no_noise_no_correction (M : SDEModel) (hv : M.volatility = 0) :
    effectiveDrift M = M.drift := by
  unfold effectiveDrift; rw [hv]; simp
end
end Survival.ItoBridge
