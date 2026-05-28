import Survival.ErgodicRateBridge
/-!
# Red Queen Bridge — "Running to Stay in Place"
Van Valen's Red Queen hypothesis: organisms must constantly
adapt (recover) just to maintain fitness relative to coevolving
competitors. Structural reading: even to maintain b_t = 0
(zero net consumption), active recovery r_t > 0 is needed
because the environment imposes d_t > 0 continuously.

"It takes all the running you can do, to keep in the same place."
= r_t must equal d_t just to maintain structural persistence.
-/
namespace Survival.RedQueenBridge
open Survival.ErgodicRateBridge
noncomputable section
structure RedQueenModel where
  environmentalPressure : ℝ  -- d_t (constant coevolutionary pressure)
  adaptationRate : ℝ         -- r_t (adaptation effort)
  pressure_pos : 0 < environmentalPressure
  adaptation_nonneg : 0 ≤ adaptationRate

def redQueenBalance (M : RedQueenModel) : ℝ :=
  M.environmentalPressure - M.adaptationRate

/-- Keeping up: adaptation matches pressure → persistence. -/
theorem keeping_up (M : RedQueenModel)
    (h : M.adaptationRate ≥ M.environmentalPressure) (n : ℕ) :
    1 ≤ constantRateRetention ⟨redQueenBalance M⟩ n :=
  persistence_of_nonpositive_rate ⟨redQueenBalance M⟩
    (by unfold redQueenBalance; linarith) n

/-- Falling behind: adaptation < pressure → extinction. -/
theorem falling_behind (M : RedQueenModel)
    (h : M.environmentalPressure > M.adaptationRate) :
    Filter.Tendsto (fun n => constantRateRetention ⟨redQueenBalance M⟩ n)
      Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨redQueenBalance M⟩
    (by unfold redQueenBalance; linarith)

/-- Zero adaptation → collapse at environmental pressure rate. -/
theorem no_adaptation_collapses (M : RedQueenModel)
    (h : M.adaptationRate = 0) :
    redQueenBalance M = M.environmentalPressure := by
  unfold redQueenBalance; linarith
end
end Survival.RedQueenBridge
