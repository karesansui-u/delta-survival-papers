import Survival.FisherFundamentalTheorem
/-!
# Price Equation Bridge — Complete Price Equation
The Price equation: Δz̄ = Cov(w,z)/w̄ + E(wΔz)/w̄.
First term = selection (FisherFundamentalTheorem already covers).
Second term = transmission bias (mutation, recombination).

Structural reading: Δz̄ = structural selection + structural mutation.
Both are structural consumption/recovery processes.
-/
namespace Survival.PriceEquationBridge
open Survival.FisherFundamentalTheorem
noncomputable section
structure PriceModel where
  selectionComponent : ℝ   -- Cov(w,z)/w̄
  transmissionBias : ℝ      -- E(wΔz)/w̄

/-- Total evolutionary change = selection + transmission. -/
def totalChange (M : PriceModel) : ℝ := M.selectionComponent + M.transmissionBias

/-- Pure selection (no transmission bias). -/
theorem pure_selection (M : PriceModel) (h : M.transmissionBias = 0) :
    totalChange M = M.selectionComponent := by
  unfold totalChange; linarith

/-- Selection always reduces mean δ (from FisherFundamentalTheorem). -/
theorem selection_reduces_delta (pop : TwoTypePopulation) :
    covDeltaFitness pop < 0 := covDeltaFitness_neg pop
end
end Survival.PriceEquationBridge
