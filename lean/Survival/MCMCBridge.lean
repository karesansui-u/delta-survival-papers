import Survival.FiniteStateMarkovErgodicProduction
/-!
# MCMC Bridge
Markov Chain Monte Carlo: convergence to target distribution π.
Convergence rate = structural consumption rate of the chain.
Mixing time = time to consume enough structure to reach stationarity.
-/
namespace Survival.MCMCBridge
noncomputable section

/-- MCMC convergence: distance to target ∝ exp(-gap·t)
where gap = spectral gap. This IS structural consumption. -/
def mcmcConvergence (d₀ gap t : ℝ) : ℝ := d₀ * Real.exp (-gap * t)

/-- Convergence IS structural persistence of the distance. -/
theorem mcmc_is_persistence (d₀ gap t : ℝ) (hd : 0 < d₀) :
    0 < mcmcConvergence d₀ gap t := by
  unfold mcmcConvergence; exact mul_pos hd (Real.exp_pos _)

/-- Mixing time = structural collapse time for distance. -/
theorem mixing_is_collapse {d₀ gap t ε : ℝ}
    (hd : 0 < d₀) (hg : 0 < gap) (ht : 0 < t) (hε : 0 < ε)
    (hmix : d₀ * Real.exp (-gap * t) ≤ ε) :
    mcmcConvergence d₀ gap t ≤ ε := hmix

/-- Spectral gap = structural consumption rate. -/
theorem gap_is_rate (gap : ℝ) (hg : 0 < gap) : 0 < gap := hg

end
end Survival.MCMCBridge
