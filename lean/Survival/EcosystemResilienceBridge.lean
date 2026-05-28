import Survival.ViabilityKernelBridge
import Survival.ErgodicRateBridge

/-!
# Ecosystem Resilience Bridge — Ecological Resilience as V_rec

Reads ecosystem resilience through structural persistence:
resilience = size of the recovery-reachable region V_rec.

Key identification:
- Ecological state = point in V_G
- Disturbance = perturbation that pushes state toward V_G boundary
- Resilience = distance to boundary (how large V_rec is)
- Regime shift = transition to a different attractor basin
- Recovery = active management that expands V_rec
-/
namespace Survival.EcosystemResilienceBridge
open Survival.ErgodicRateBridge
noncomputable section

structure EcosystemModel where
  disturbanceRate : ℝ   -- consumption from perturbations
  recoveryRate : ℝ       -- natural recovery + management
  disturbance_pos : 0 < disturbanceRate
  recovery_nonneg : 0 ≤ recoveryRate

def netDegradation (M : EcosystemModel) : ℝ :=
  M.disturbanceRate - M.recoveryRate

/-- Resilient ecosystem: recovery ≥ disturbance. -/
theorem resilient_persists (M : EcosystemModel)
    (h : M.recoveryRate ≥ M.disturbanceRate) (n : ℕ) :
    1 ≤ constantRateRetention ⟨netDegradation M⟩ n :=
  persistence_of_nonpositive_rate ⟨netDegradation M⟩
    (by unfold netDegradation; linarith) n

/-- Regime shift: disturbance > recovery → ecosystem collapses. -/
theorem regime_shift (M : EcosystemModel)
    (h : M.disturbanceRate > M.recoveryRate) :
    Filter.Tendsto (fun n => constantRateRetention ⟨netDegradation M⟩ n)
      Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨netDegradation M⟩
    (by unfold netDegradation; linarith)

/-- Critical threshold: disturbance = recovery. -/
theorem critical_threshold (M : EcosystemModel)
    (h : M.disturbanceRate = M.recoveryRate) (n : ℕ) :
    constantRateRetention ⟨netDegradation M⟩ n = 1 :=
  boundary_of_zero_rate ⟨netDegradation M⟩
    (by unfold netDegradation; linarith) n

end
end Survival.EcosystemResilienceBridge
