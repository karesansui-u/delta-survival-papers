import Survival.RaoBlackwellTheorem
/-!
# Blackwell Equivalence Bridge
Blackwell's theorem: experiment A is more informative than B iff
A is sufficient for B. In SP: coarse-graining A ≤ B iff defect(A) ≤ defect(B).
-/
namespace Survival.BlackwellBridge
open Survival.RaoBlackwellTheorem
open Survival.SaturationDefect
noncomputable section

/-- Experiment A dominates B if A's defect magnitude ≤ B's. -/
def BlackwellDominates (defect_A defect_B : ℝ) : Prop := |defect_A| ≤ |defect_B|

/-- Zero defect (sufficiency) Blackwell-dominates everything. -/
theorem sufficient_dominates_all (defect_B : ℝ) :
    BlackwellDominates 0 defect_B := by
  unfold BlackwellDominates; simp

/-- Self-dominance (reflexivity). -/
theorem blackwell_refl (d : ℝ) : BlackwellDominates d d := le_refl _

/-- Transitivity. -/
theorem blackwell_trans {a b c : ℝ}
    (h1 : BlackwellDominates a b) (h2 : BlackwellDominates b c) :
    BlackwellDominates a c := le_trans h1 h2

end
end Survival.BlackwellBridge
