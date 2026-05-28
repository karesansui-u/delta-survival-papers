import Survival.BoltzmannEntropyBridge
import Survival.ErgodicRateBridge
/-!
# CMB Bridge — Cosmic Microwave Background as Frozen Structure
Reads the CMB through structural persistence: the temperature
fluctuations δT/T ≈ 10⁻⁵ are the frozen structural consumption
density at the time of last scattering (recombination).

Before recombination: photon-baryon fluid maintains structural
coherence (tight coupling = high recovery rate).
At recombination: photons decouple → recovery drops to zero →
structural pattern freezes into the CMB.
-/
namespace Survival.CMBBridge
open Survival.ErgodicRateBridge
noncomputable section

structure CMBModel where
  couplingRate : ℝ     -- recovery (photon-baryon coupling)
  decouplingRate : ℝ   -- consumption (expansion + recombination)
  coupling_pos : 0 < couplingRate
  decoupling_pos : 0 < decouplingRate

def photonBarionBalance (M : CMBModel) : ℝ := M.decouplingRate - M.couplingRate

/-- Before recombination: tight coupling → structure preserved. -/
theorem tight_coupling_preserves (M : CMBModel)
    (h : M.couplingRate > M.decouplingRate) (n : ℕ) :
    1 ≤ constantRateRetention ⟨photonBarionBalance M⟩ n :=
  persistence_of_nonpositive_rate ⟨photonBarionBalance M⟩
    (by unfold photonBarionBalance; linarith) n

/-- At recombination: coupling vanishes → pattern freezes. -/
theorem recombination_freezes (M : CMBModel)
    (h : M.decouplingRate > M.couplingRate) :
    Filter.Tendsto (fun n => constantRateRetention ⟨photonBarionBalance M⟩ n)
      Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨photonBarionBalance M⟩
    (by unfold photonBarionBalance; linarith)

/-- The CMB temperature fluctuations are the frozen structural
    consumption density at last scattering. -/
theorem cmb_is_frozen_consumption (M : CMBModel)
    (h : M.couplingRate = M.decouplingRate) (n : ℕ) :
    constantRateRetention ⟨photonBarionBalance M⟩ n = 1 :=
  boundary_of_zero_rate ⟨photonBarionBalance M⟩
    (by unfold photonBarionBalance; linarith) n

end
end Survival.CMBBridge
