import Survival.JaynesMaxEntTheorem
/-!
# Zipf's Law Bridge
Zipf ∝ 1/rank arises from MaxEnt with E[ln rank] constraint.
In SP: MaxEnt over structural configurations = Boltzmann = Zipf.
-/
namespace Survival.ZipfBridge
open Survival.JaynesMaxEntTheorem
noncomputable section

/-- Zipf-like weight: exp(-α · ln(rank)) for rank > 0. -/
def zipfLogWeight (alpha : ℝ) (rank : ℕ) (hr : 0 < rank) : ℝ :=
  Real.exp (-alpha * Real.log (rank : ℝ))

/-- Zipf weight is positive. -/
theorem zipf_pos (alpha : ℝ) (rank : ℕ) (hr : 0 < rank) :
    0 < zipfLogWeight alpha rank hr := Real.exp_pos _

/-- Zipf IS Boltzmann with loss = ln(rank). -/
theorem zipf_is_boltzmann (alpha : ℝ) (rank : ℕ) (hr : 0 < rank) :
    zipfLogWeight alpha rank hr =
      boltzmannWeight alpha (Real.log (rank : ℝ)) := rfl

/-- ln(Zipf weight) = -α ln(rank) = structural consumption. -/
theorem zipf_log (alpha : ℝ) (rank : ℕ) (hr : 0 < rank) :
    Real.log (zipfLogWeight alpha rank hr) =
      -alpha * Real.log (rank : ℝ) := by
  unfold zipfLogWeight; exact Real.log_exp _

end
end Survival.ZipfBridge
