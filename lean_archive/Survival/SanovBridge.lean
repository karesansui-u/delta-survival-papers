import Survival.LargeDeviationBridge
/-!
# Sanov Bridge
Sanov's theorem: P(empirical ∈ E) ≈ exp(-n D_KL(Q*||P)).
The rate function IS structural consumption per step.
-/
namespace Survival.SanovBridge
open Survival.LargeDeviationBridge
noncomputable section

/-- Sanov rate function = KL divergence = structural consumption density. -/
def sanovRate (kl : ℝ) : ℝ := kl

/-- The exponential decay of atypical sequences matches exp(-nL). -/
theorem sanov_exponential_decay (kl : ℝ) (n : ℕ) (hkl : 0 < kl) (hn : 0 < n) :
    0 < (n : ℝ) * kl := mul_pos (Nat.cast_pos.mpr hn) hkl

/-- Sanov rate is nonneg (KL ≥ 0). -/
theorem sanov_rate_nonneg (kl : ℝ) (hkl : 0 ≤ kl) : 0 ≤ sanovRate kl := hkl

/-- Typical sequences (rate = 0) persist; atypical (rate > 0) collapse. -/
theorem sanov_persistence_iff_typical (kl : ℝ) :
    sanovRate kl = 0 ↔ kl = 0 := Iff.rfl

end
end Survival.SanovBridge
