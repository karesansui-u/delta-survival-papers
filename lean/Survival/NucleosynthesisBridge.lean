import Survival.ErgodicRateBridge
/-!
# Big Bang Nucleosynthesis Bridge
Reads primordial nucleosynthesis as structural persistence: the
light element abundances (H, He, Li) are determined by the
freeze-out of nuclear reactions — the moment when the reaction
rate drops below the expansion rate (consumption > recovery → V_G freezes).

Freeze-out = structural consumption rate exceeds recovery rate
→ nuclear network "collapses" into fixed abundances.
-/
namespace Survival.NucleosynthesisBridge
open Survival.ErgodicRateBridge
noncomputable section

structure NucleosynthesisModel where
  reactionRate : ℝ    -- recovery (nuclear reactions maintain equilibrium)
  expansionRate : ℝ   -- consumption (expansion dilutes reactants)
  reaction_pos : 0 < reactionRate
  expansion_pos : 0 < expansionRate

def netRate (M : NucleosynthesisModel) : ℝ := M.expansionRate - M.reactionRate

/-- Before freeze-out: reactions fast enough → equilibrium maintained. -/
theorem equilibrium_before_freezeout (M : NucleosynthesisModel)
    (h : M.reactionRate > M.expansionRate) (n : ℕ) :
    1 ≤ constantRateRetention ⟨netRate M⟩ n :=
  persistence_of_nonpositive_rate ⟨netRate M⟩ (by unfold netRate; linarith) n

/-- After freeze-out: expansion wins → abundances frozen. -/
theorem freezeout_collapses (M : NucleosynthesisModel)
    (h : M.expansionRate > M.reactionRate) :
    Filter.Tendsto (fun n => constantRateRetention ⟨netRate M⟩ n)
      Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨netRate M⟩ (by unfold netRate; linarith)

/-- Freeze-out temperature: reaction rate = expansion rate. -/
theorem freezeout_boundary (M : NucleosynthesisModel)
    (h : M.reactionRate = M.expansionRate) (n : ℕ) :
    constantRateRetention ⟨netRate M⟩ n = 1 :=
  boundary_of_zero_rate ⟨netRate M⟩ (by unfold netRate; linarith) n

end
end Survival.NucleosynthesisBridge
