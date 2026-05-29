import Survival.RenormalizationBridge
import Survival.IsingTransitionBridge
import Mathlib.Analysis.SpecialFunctions.Pow.Real
/-!
# Critical Exponent Bridge — Universality Classes
Near a critical point, physical quantities diverge as power laws:
ξ ∝ |T - T_c|^(-ν), C ∝ |T - T_c|^(-α), etc.

Structural reading: near the structural persistence boundary
(rate l̄ → 0), the correlation length (= range of structural
coherence) diverges. The critical exponents characterize HOW
the approach to the boundary occurs. Different systems with
the same exponents are in the same universality class =
same structural consumption scaling behavior.
-/
namespace Survival.CriticalExponentBridge
open Real
noncomputable section
structure CriticalModel where
  reducedTemperature : ℝ  -- t = (T - T_c) / T_c
  exponent : ℝ            -- ν (correlation length exponent)
  temp_pos : 0 < |reducedTemperature|
  exponent_pos : 0 < exponent

/-- Correlation length diverges as |t|^(-ν). -/
def correlationLength (M : CriticalModel) : ℝ :=
  |M.reducedTemperature| ^ ((-M.exponent) : ℝ)

/-- Closer to critical point → longer correlation length. -/
theorem closer_longer (M₁ M₂ : CriticalModel)
    (hexp : M₁.exponent = M₂.exponent)
    (h : |M₁.reducedTemperature| < |M₂.reducedTemperature|) :
    correlationLength M₂ < correlationLength M₁ := by
  unfold correlationLength
  rw [hexp]
  apply Real.rpow_lt_rpow_of_exponent_neg M₁.temp_pos h
  linarith [M₂.exponent_pos]

/-- Universality: same exponent → same structural scaling class. -/
def SameUniversalityClass (M₁ M₂ : CriticalModel) : Prop :=
  M₁.exponent = M₂.exponent
end
end Survival.CriticalExponentBridge
