import Survival.MultiAttractor
import Survival.BoltzmannEntropyBridge
/-!
# Partition Function Bridge — Z = Σ exp(-βE_i)
The canonical partition function Z = Σ exp(-βE_i) is the sum of
survival potentials over all microstates. Structural reading:
Z = Σ_i S_i where S_i = exp(-βE_i) is the structural persistence
of microstate i. Z normalizes the Boltzmann distribution.

Free energy F = -kT ln Z = -kT ln(total structural persistence).
-/
namespace Survival.PartitionFunctionBridge
open Real Survival.MultiAttractor
noncomputable section
structure StatMechModel where
  energies : ℕ → ℝ     -- E_i for each microstate
  beta : ℝ              -- 1/kT (inverse temperature)
  beta_pos : 0 < beta
  numStates : ℕ
  states_pos : 0 < numStates

/-- Boltzmann weight of microstate i = structural persistence. -/
def boltzmannWeight (M : StatMechModel) (i : ℕ) : ℝ :=
  exp (-M.beta * M.energies i)

/-- Each Boltzmann weight is positive. -/
theorem weight_pos (M : StatMechModel) (i : ℕ) : 0 < boltzmannWeight M i :=
  exp_pos _

/-- Partition function = total structural persistence over all states. -/
def partitionFunction (M : StatMechModel) : ℝ :=
  ∑ i ∈ Finset.range M.numStates, boltzmannWeight M i

/-- Partition function is positive. -/
theorem partition_pos (M : StatMechModel) : 0 < partitionFunction M := by
  unfold partitionFunction
  exact Finset.sum_pos (fun i _ => weight_pos M i)
    ⟨0, Finset.mem_range.mpr M.states_pos⟩

/-- Free energy = -log Z / β. -/
def freeEnergyStatMech (M : StatMechModel) : ℝ :=
  -(log (partitionFunction M)) / M.beta

/-- Lower energy states have higher Boltzmann weight. -/
theorem lower_energy_higher_weight (M : StatMechModel) (i j : ℕ)
    (h : M.energies i < M.energies j) :
    boltzmannWeight M j < boltzmannWeight M i := by
  unfold boltzmannWeight
  exact exp_lt_exp.mpr (by nlinarith [M.beta_pos])
end
end Survival.PartitionFunctionBridge
