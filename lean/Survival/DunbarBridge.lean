import Survival.HolographicBridge
/-!
# Dunbar Number Bridge — Social Structure Capacity Bound
Dunbar's number (~150) as a structural capacity bound: the maximum
number of stable social relationships a human can maintain.
Like the holographic bound, this is an upper bound on m(V_G)
for social structures, determined by cognitive "boundary area."
-/
namespace Survival.DunbarBridge
open Real
noncomputable section
structure SocialModel where
  cognitiveCapacity : ℝ   -- Dunbar number (boundary)
  actualRelationships : ℝ -- current social structure size
  capacity_pos : 0 < cognitiveCapacity
  actual_pos : 0 < actualRelationships

def socialOverload (M : SocialModel) : ℝ := M.actualRelationships - M.cognitiveCapacity

theorem within_capacity_persists (M : SocialModel) (h : M.actualRelationships ≤ M.cognitiveCapacity) :
    socialOverload M ≤ 0 := by unfold socialOverload; linarith

theorem over_capacity_stressed (M : SocialModel) (h : M.cognitiveCapacity < M.actualRelationships) :
    0 < socialOverload M := by unfold socialOverload; linarith
end
end Survival.DunbarBridge
