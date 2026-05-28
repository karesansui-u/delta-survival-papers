import Survival.RepairMaintenanceBalance
import Survival.ErgodicRateBridge

/-!
# DNA Replication Bridge — Mutation and Repair

Reads DNA replication fidelity through structural persistence:
mutation = structural consumption, DNA repair = recovery.

Key identification:
- DNA sequence = structure to be maintained
- Mutation rate μ = per-step consumption rate l_i
- DNA repair efficiency = recovery rate r_t
- Net mutation rate = b_t = μ - repair
- Structural persistence of genome = S = M exp(-B)
-/
namespace Survival.DNAReplicationBridge
open Survival.ErgodicRateBridge
noncomputable section

structure GenomeModel where
  mutationRate : ℝ     -- consumption (errors per replication)
  repairRate : ℝ        -- recovery (repair per replication)
  mutation_pos : 0 < mutationRate
  repair_nonneg : 0 ≤ repairRate

def netMutationRate (M : GenomeModel) : ℝ := M.mutationRate - M.repairRate

/-- With repair: genome persists if repair ≥ mutation. -/
theorem genome_persists_with_repair (M : GenomeModel)
    (h : M.repairRate ≥ M.mutationRate) (n : ℕ) :
    1 ≤ constantRateRetention ⟨netMutationRate M⟩ n :=
  persistence_of_nonpositive_rate ⟨netMutationRate M⟩
    (by unfold netMutationRate; linarith) n

/-- Without sufficient repair: genome degrades (error catastrophe). -/
theorem error_catastrophe (M : GenomeModel)
    (h : M.mutationRate > M.repairRate) :
    Filter.Tendsto (fun n => constantRateRetention ⟨netMutationRate M⟩ n)
      Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨netMutationRate M⟩
    (by unfold netMutationRate; linarith)

/-- Eigen's error threshold: the critical repair rate where
    net mutation = 0. -/
theorem eigen_threshold (M : GenomeModel)
    (h : M.repairRate = M.mutationRate) (n : ℕ) :
    constantRateRetention ⟨netMutationRate M⟩ n = 1 :=
  boundary_of_zero_rate ⟨netMutationRate M⟩
    (by unfold netMutationRate; linarith) n

end
end Survival.DNAReplicationBridge
