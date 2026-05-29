import Survival.DNAReplicationBridge
/-!
# Genetic Load Bridge — Mutation-Selection Balance
Haldane's genetic load: L_genetic = 1 - w̄/w_max. The population
mean fitness is reduced by the mutation load. Structural reading:
genetic load = cumulative structural consumption from mutations
that selection hasn't yet purged. Mutation-selection balance =
ergodic equilibrium where mutation consumption = selection recovery.
-/
namespace Survival.GeneticLoadBridge
open Real
noncomputable section
structure GeneticLoadModel where
  mutationLoad : ℝ      -- fraction of fitness lost to mutations
  selectionStrength : ℝ  -- rate at which selection purges mutations
  load_nonneg : 0 ≤ mutationLoad
  load_le_one : mutationLoad ≤ 1
  selection_pos : 0 < selectionStrength

/-- The equilibrium load: mutation rate / selection coefficient.
    At equilibrium, load is constant (structural balance). -/
def equilibriumLoad (mutRate selCoeff : ℝ) : ℝ := mutRate / selCoeff

/-- Higher mutation rate → higher load (more structural consumption). -/
theorem higher_mutation_higher_load (μ₁ μ₂ s : ℝ) (hs : 0 < s)
    (h : μ₁ < μ₂) :
    equilibriumLoad μ₁ s < equilibriumLoad μ₂ s := by
  unfold equilibriumLoad
  exact div_lt_div_of_pos_right h hs

/-- Stronger selection → lower load (more recovery). -/
theorem stronger_selection_lower_load (μ s₁ s₂ : ℝ) (hμ : 0 < μ)
    (hs₁ : 0 < s₁) (h : s₁ < s₂) :
    equilibriumLoad μ s₂ < equilibriumLoad μ s₁ := by
  unfold equilibriumLoad
  exact div_lt_div_of_pos_left hμ hs₁ h
end
end Survival.GeneticLoadBridge
