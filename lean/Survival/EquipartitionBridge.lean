import Survival.PartitionFunctionBridge
/-!
# Equipartition Bridge — ⟨E_i⟩ = kT/2
The equipartition theorem: each quadratic degree of freedom
contributes kT/2 to the average energy. Structural reading:
the structural consumption is evenly distributed across
independent degrees of freedom at thermal equilibrium.
-/
namespace Survival.EquipartitionBridge
open Real
noncomputable section
structure EquipartitionModel where
  degreesOfFreedom : ℕ   -- f (number of quadratic DOF)
  temperature : ℝ        -- kT
  dof_pos : 0 < degreesOfFreedom
  temp_pos : 0 < temperature

/-- Average energy per DOF = kT/2. -/
def energyPerDOF (M : EquipartitionModel) : ℝ := M.temperature / 2

/-- Total average energy = f · kT/2. -/
def totalEnergy (M : EquipartitionModel) : ℝ :=
  ↑M.degreesOfFreedom * energyPerDOF M

/-- Total energy is positive. -/
theorem totalEnergy_pos (M : EquipartitionModel) : 0 < totalEnergy M := by
  unfold totalEnergy energyPerDOF
  exact mul_pos (Nat.cast_pos.mpr M.dof_pos) (div_pos M.temp_pos two_pos)

/-- More DOF → more energy → more structural consumption capacity. -/
theorem more_dof_more_energy (M₁ M₂ : EquipartitionModel)
    (htemp : M₁.temperature = M₂.temperature)
    (h : M₁.degreesOfFreedom < M₂.degreesOfFreedom) :
    totalEnergy M₁ < totalEnergy M₂ := by
  unfold totalEnergy energyPerDOF
  rw [htemp]
  exact mul_lt_mul_of_pos_right (Nat.cast_lt.mpr h) (div_pos M₂.temp_pos two_pos)
end
end Survival.EquipartitionBridge
