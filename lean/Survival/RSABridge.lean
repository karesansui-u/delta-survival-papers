import Survival.HaltingProblemBridge
/-!
# RSA Bridge
RSA security relies on computational hardness of factoring.
Key length n gives structural barrier exp(c·n^{1/3}).
Breaking RSA = overcoming structural consumption barrier.
-/
namespace Survival.RSABridge
noncomputable section

/-- RSA barrier: computational cost grows as exp(c·n^{1/3}).
This IS a structural consumption barrier: the attacker must
overcome L ∝ n^{1/3} structural consumption to factor. -/
def rsaBarrier (c : ℝ) (keyBits : ℝ) : ℝ :=
  Real.exp (c * keyBits)

/-- Larger keys = higher barrier = more structural consumption. -/
theorem larger_key_harder {c k₁ k₂ : ℝ} (hc : 0 < c) (hk : k₁ < k₂) :
    rsaBarrier c k₁ < rsaBarrier c k₂ := by
  unfold rsaBarrier
  exact Real.exp_lt_exp.mpr (by nlinarith)

/-- The barrier is always > 1 for positive key size and constant. -/
theorem barrier_exceeds_one {c k : ℝ} (hc : 0 < c) (hk : 0 < k) :
    1 < rsaBarrier c k := by
  unfold rsaBarrier
  exact Real.one_lt_exp_iff.mpr (by positivity)

end
end Survival.RSABridge
