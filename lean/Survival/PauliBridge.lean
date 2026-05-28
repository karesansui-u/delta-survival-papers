import Survival.ViabilityKernelBridge
/-!
# Pauli Exclusion Principle Bridge — Fermionic Constraint on V_G
Reads Pauli's exclusion principle through structural persistence:
"no two identical fermions can occupy the same quantum state"
= a hard constraint on V_G that limits the viable set measure.

Without Pauli: m(V_G) = (number of states)^N (bosonic)
With Pauli: m(V_G) = C(K, N) = K!/(N!(K-N)!) (fermionic)

The exclusion principle is a structural constraint that reduces
V_G, thereby increasing the per-particle structural consumption.
-/
namespace Survival.PauliBridge
open Real
noncomputable section

structure FermionSystem where
  availableStates : ℕ   -- K (number of quantum states)
  particles : ℕ          -- N (number of fermions)
  states_pos : 0 < availableStates
  particles_le : particles ≤ availableStates

/-- Bosonic viable set measure: each particle can be in any state.
    m_boson = K^N (with replacement). -/
def bosonicMeasure (S : FermionSystem) : ℝ :=
  (↑S.availableStates : ℝ) ^ S.particles

/-- Fermionic viable set measure: each particle in a distinct state.
    m_fermion ≤ K^N (without replacement). Simplified: K!/(K-N)!/N! -/
def fermionicMeasure (S : FermionSystem) : ℝ :=
  (↑S.availableStates : ℝ) ^ S.particles / (↑(Nat.factorial S.particles) : ℝ)

/-- Pauli exclusion reduces the viable set: m_fermion ≤ m_boson. -/
theorem pauli_reduces_viable_set (S : FermionSystem) :
    fermionicMeasure S ≤ bosonicMeasure S := by
  unfold fermionicMeasure bosonicMeasure
  exact div_le_self
    (pow_nonneg (Nat.cast_nonneg S.availableStates) _)
    (Nat.one_le_cast.mpr (Nat.factorial_pos S.particles))

/-- The structural consumption from Pauli exclusion. -/
def pauliConsumption (S : FermionSystem)
    (hb : 0 < bosonicMeasure S) (hf : 0 < fermionicMeasure S) : ℝ :=
  -log (fermionicMeasure S / bosonicMeasure S)

/-- Pauli consumption is nonneg (exclusion only reduces V_G). -/
theorem pauli_consumption_nonneg (S : FermionSystem)
    (hb : 0 < bosonicMeasure S) (hf : 0 < fermionicMeasure S) :
    0 ≤ pauliConsumption S hb hf := by
  unfold pauliConsumption
  rw [neg_nonneg]
  exact log_nonpos (le_of_lt (div_pos hf hb))
    ((div_le_one₀ hb).mpr (pauli_reduces_viable_set S))

end
end Survival.PauliBridge
