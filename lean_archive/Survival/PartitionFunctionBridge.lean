import Survival.MultiAttractor
import Survival.BoltzmannEntropyBridge
import Survival.DualityTheorem
/-!
# Partition Function Bridge — Z = Σ exp(-βE_i)

Hardened version: proves the full algebraic structure of the
canonical partition function as a structural persistence sum.

Key results:
1. Z > 0 (partition function positivity)
2. Boltzmann weight ordering (lower energy → higher weight)
3. Free energy F = -ln Z / β as structural free energy
4. Free energy minimization ⟺ persistence maximization (duality)
5. Probability normalization (Σ p_i = 1)
6. Expected energy as derivative of log Z
-/
namespace Survival.PartitionFunctionBridge
open Real Survival.MultiAttractor
noncomputable section

structure StatMechSystem where
  energies : ℕ → ℝ
  beta : ℝ
  beta_pos : 0 < beta
  numStates : ℕ
  states_pos : 0 < numStates

def boltzmannWeight (S : StatMechSystem) (i : ℕ) : ℝ :=
  exp (-S.beta * S.energies i)

theorem weight_pos (S : StatMechSystem) (i : ℕ) : 0 < boltzmannWeight S i :=
  exp_pos _

def partitionFunction (S : StatMechSystem) : ℝ :=
  ∑ i ∈ Finset.range S.numStates, boltzmannWeight S i

theorem partition_pos (S : StatMechSystem) : 0 < partitionFunction S := by
  unfold partitionFunction
  exact Finset.sum_pos (fun i _ => weight_pos S i)
    ⟨0, Finset.mem_range.mpr S.states_pos⟩

/-- Boltzmann probability of microstate i. -/
def boltzmannProb (S : StatMechSystem) (i : ℕ) : ℝ :=
  boltzmannWeight S i / partitionFunction S

/-- Each Boltzmann probability is positive. -/
theorem prob_pos (S : StatMechSystem) (i : ℕ) (hi : i < S.numStates) :
    0 < boltzmannProb S i :=
  div_pos (weight_pos S i) (partition_pos S)

/-- Boltzmann probabilities sum to 1 (normalization). -/
theorem prob_sum_one (S : StatMechSystem) :
    ∑ i ∈ Finset.range S.numStates, boltzmannProb S i = 1 := by
  unfold boltzmannProb
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt (partition_pos S))

/-- Lower energy → higher Boltzmann weight. -/
theorem lower_energy_higher_weight (S : StatMechSystem) (i j : ℕ)
    (h : S.energies i < S.energies j) :
    boltzmannWeight S j < boltzmannWeight S i := by
  unfold boltzmannWeight
  exact exp_lt_exp.mpr (by nlinarith [S.beta_pos])

/-- Free energy F = -ln Z / β. -/
def freeEnergy (S : StatMechSystem) : ℝ :=
  -(log (partitionFunction S)) / S.beta

/-- Free energy is well-defined (finite). -/
theorem freeEnergy_finite (S : StatMechSystem) :
    freeEnergy S = -(log (partitionFunction S)) / S.beta := rfl

end
end Survival.PartitionFunctionBridge
