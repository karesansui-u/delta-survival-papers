import Survival.ChannelCapacityBridge
import Survival.QuantumInformationBridge
/-!
# Quantum Channel Bridge — Quantum Channel Capacity
Reads quantum channel capacity through structural persistence:
the Holevo bound χ = S(ρ_out) - Σ p_i S(ρ_i) bounds the
classical information transmittable through a quantum channel.
Structural reading: χ = maximum sustainable information rate
through a quantum structural channel.
-/
namespace Survival.QuantumChannelBridge
open Real
noncomputable section
structure QuantumChannelModel where
  holevoBound : ℝ       -- χ (Holevo capacity)
  decoherenceRate : ℝ    -- structural consumption per use
  holevo_nonneg : 0 ≤ holevoBound
  decoherence_nonneg : 0 ≤ decoherenceRate

/-- Below Holevo capacity: reliable quantum communication possible. -/
def belowCapacity (M : QuantumChannelModel) (rate : ℝ) : Prop :=
  rate ≤ M.holevoBound

/-- Above Holevo capacity: structural consumption exceeds recovery. -/
def aboveCapacity (M : QuantumChannelModel) (rate : ℝ) : Prop :=
  M.holevoBound < rate

/-- Capacity boundary is sharp. -/
theorem capacity_dichotomy (M : QuantumChannelModel) (rate : ℝ) :
    belowCapacity M rate ∨ aboveCapacity M rate := by
  unfold belowCapacity aboveCapacity
  exact le_or_lt rate M.holevoBound
end
end Survival.QuantumChannelBridge
