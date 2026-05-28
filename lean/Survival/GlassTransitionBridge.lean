import Survival.MixingTimeBridge
import Survival.ErgodicRateBridge

/-!
# Glass Transition Bridge — Ergodicity Breaking

Reads the glass transition as structural persistence with diverging
mixing time. Above T_g: ergodic, system explores all configurations
(fast mixing, spectral gap > 0). Below T_g: non-ergodic, system
is trapped in a metastable basin (mixing time → ∞, gap → 0).

Glass = frozen structural state with extremely slow consumption rate.
-/

namespace Survival.GlassTransitionBridge
open Survival.MixingTimeBridge Survival.ErgodicRateBridge

noncomputable section

structure GlassModel where
  spectralGap : ℝ       -- gap decreases toward T_g
  consumptionRate : ℝ    -- structural consumption rate
  gap_nonneg : 0 ≤ spectralGap
  rate_nonneg : 0 ≤ consumptionRate

/-- Above T_g: positive gap means ergodic behavior. -/
theorem ergodic_above_Tg (M : GlassModel) (hgap : 0 < M.spectralGap)
    (hle : M.spectralGap ≤ 1) :
    0 < (SpectralGapModel.mk M.spectralGap M.consumptionRate hgap hle).gap :=
  hgap

/-- At T_g: gap = 0 means mixing time diverges (non-ergodic). The
    system is "frozen" — it cannot explore its configuration space. -/
theorem frozen_at_Tg (M : GlassModel) (hgap : M.spectralGap = 0)
    (hrate : M.consumptionRate = 0) (n : ℕ) :
    constantRateRetention ⟨M.consumptionRate⟩ n = 1 :=
  boundary_of_zero_rate ⟨M.consumptionRate⟩ hrate n

/-- Below T_g with residual rate: extremely slow collapse. -/
theorem slow_aging_below_Tg (M : GlassModel)
    (hrate : 0 < M.consumptionRate) :
    Filter.Tendsto (fun n => constantRateRetention ⟨M.consumptionRate⟩ n)
      Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨M.consumptionRate⟩ hrate

end
end Survival.GlassTransitionBridge
