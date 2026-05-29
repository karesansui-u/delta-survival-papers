import Survival.RenyiEntropyBridge
import Survival.ErgodicRateBridge

/-!
# Integrated Information Theory Bridge — Consciousness as Structural Persistence

Reads Tononi's Integrated Information Theory (IIT) through structural
persistence: Φ (integrated information) measures how much a system's
structural persistence depends on its wholeness.

Key identification:
- Φ = 0 → system decomposes into independent parts (no integration)
- Φ > 0 → system loses structural persistence when partitioned
- High Φ → highly integrated structure (consciousness candidate)
- Structural consumption of partition = Φ
-/
namespace Survival.IntegratedInformationBridge
open Real
noncomputable section

/-- An integrated information model: the whole system has mass m_whole,
    and the best partition has mass m_partition. Φ measures how much
    structural information is lost by partitioning. -/
structure IITModel where
  wholeMass : ℝ         -- m(V) of the whole system
  partitionMass : ℝ     -- m(V) of the best partition
  whole_pos : 0 < wholeMass
  partition_pos : 0 < partitionMass
  partition_le : partitionMass ≤ wholeMass  -- partition loses information

/-- Integrated information Φ = structural consumption from partitioning. -/
def phi (M : IITModel) : ℝ :=
  -log (M.partitionMass / M.wholeMass)

/-- Φ is nonneg (partitioning can only lose structure). -/
theorem phi_nonneg (M : IITModel) : 0 ≤ phi M := by
  unfold phi
  rw [neg_nonneg]
  exact log_nonpos (le_of_lt (div_pos M.partition_pos M.whole_pos))
    ((div_le_one₀ M.whole_pos).mpr M.partition_le)

/-- Φ = 0 iff the system is fully decomposable (no integration). -/
theorem phi_zero_iff_decomposable (M : IITModel)
    (h : M.partitionMass = M.wholeMass) :
    phi M = 0 := by
  unfold phi
  rw [h, div_self (ne_of_gt M.whole_pos), log_one, neg_zero]

/-- Higher Φ = more structural consumption from partitioning =
    more integrated = more "conscious" (in IIT's framework). -/
theorem higher_phi_more_integrated (M₁ M₂ : IITModel)
    (h : M₁.partitionMass / M₁.wholeMass >
         M₂.partitionMass / M₂.wholeMass)
    (h₁ : 0 < M₁.partitionMass / M₁.wholeMass)
    (h₂ : 0 < M₂.partitionMass / M₂.wholeMass) :
    phi M₁ < phi M₂ := by
  unfold phi
  exact neg_lt_neg (log_lt_log h₂ h)

end
end Survival.IntegratedInformationBridge
