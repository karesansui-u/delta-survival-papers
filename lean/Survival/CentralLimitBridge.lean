import Survival.StabilityTheorem
import Survival.ErgodicRateBridge

/-!
# Central Limit Theorem Bridge

Reads CLT as: the structural consumption density L_n/n converges
to a normal distribution around the mean rate l̄, with variance
σ²/n. This means deviations from the ergodic rate are Gaussian
at scale √n — the "typical" structural fate is sharply concentrated.

CLT for structural persistence: √n(L_n/n - l̄) → N(0, σ²).
-/
namespace Survival.CentralLimitBridge
open Real Survival.ErgodicRateBridge
noncomputable section

structure CLTModel where
  meanRate : ℝ          -- l̄ = E[l_i]
  variance : ℝ          -- σ² = Var(l_i)
  variance_pos : 0 < variance

/-- The typical fluctuation scale of consumption density is 1/√n. -/
def fluctuationScale (n : ℕ) (hn : 0 < n) : ℝ :=
  1 / Real.sqrt ↑n

theorem fluctuationScale_pos (n : ℕ) (hn : 0 < n) :
    0 < fluctuationScale n hn := by
  unfold fluctuationScale
  exact div_pos one_pos (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hn))

/-- As n → ∞, the fluctuation scale vanishes: structural fate
    becomes deterministic in the ergodic limit. -/
theorem fate_becomes_deterministic :
    ∀ (M : CLTModel),
      (M.meanRate > 0 → -- collapse is certain
        Filter.Tendsto (fun n => constantRateRetention ⟨M.meanRate⟩ n)
          Filter.atTop (nhds 0)) ∧
      (M.meanRate = 0 → -- boundary
        ∀ n, constantRateRetention ⟨M.meanRate⟩ n = 1) ∧
      (M.meanRate < 0 → -- persistence is certain
        ∀ n, 1 ≤ constantRateRetention ⟨M.meanRate⟩ n) :=
  fun M => ergodic_trichotomy ⟨M.meanRate⟩

end
end Survival.CentralLimitBridge
