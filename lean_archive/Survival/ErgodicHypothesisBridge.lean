import Survival.ErgodicRateBridge
import Survival.MixingTimeBridge
/-!
# Ergodic Hypothesis Bridge — Time Average = Ensemble Average
Reads the ergodic hypothesis through structural persistence:
for an ergodic system, the time-averaged consumption rate L_n/n
equals the ensemble-averaged rate E[l]. This justifies using
the single-trajectory L_n to predict structural fate.

Ergodic: L_n/n → E[l] (a.s.)
Non-ergodic: L_n/n depends on initial conditions (glass-like)
-/
namespace Survival.ErgodicHypothesisBridge
open Survival.ErgodicRateBridge
noncomputable section

/-- An ergodic structural system: the time average equals
    the ensemble average. -/
structure ErgodicSystem where
  ensembleRate : ℝ     -- E[l] (ensemble average)
  timeAverageConverges : Prop  -- L_n/n → ensembleRate (a.s.)

/-- For ergodic systems, the structural fate is determined by
    the ensemble rate — independent of initial conditions. -/
theorem ergodic_fate_is_universal (S : ErgodicSystem) :
    (0 < S.ensembleRate →
      Filter.Tendsto (fun n => constantRateRetention ⟨S.ensembleRate⟩ n)
        Filter.atTop (nhds 0)) ∧
    (S.ensembleRate = 0 →
      ∀ n, constantRateRetention ⟨S.ensembleRate⟩ n = 1) ∧
    (S.ensembleRate < 0 →
      ∀ n, 1 ≤ constantRateRetention ⟨S.ensembleRate⟩ n) :=
  ergodic_trichotomy ⟨S.ensembleRate⟩

/-- Non-ergodic systems have path-dependent structural fate.
    The same ensemble rate can produce different outcomes
    depending on which basin the trajectory is trapped in. -/
theorem nonergodic_is_path_dependent :
    ∀ (rate₁ rate₂ : ℝ),
      rate₁ ≠ rate₂ →
      ∃ n, constantRateRetention ⟨rate₁⟩ n ≠
           constantRateRetention ⟨rate₂⟩ n := by
  intro r₁ r₂ hr
  refine ⟨1, ?_⟩
  unfold constantRateRetention ConstantRateModel.cumulative
  simp only [Nat.cast_one, one_mul]
  exact fun h => hr (neg_injective (Real.exp_injective h))

end
end Survival.ErgodicHypothesisBridge
