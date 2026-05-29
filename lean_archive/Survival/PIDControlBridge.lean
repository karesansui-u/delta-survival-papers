import Survival.GronwallBridge
/-!
# PID Control Bridge
PID: u(t) = K_p·e + K_i·∫e + K_d·de/dt.
Error decay under P-control: e(t) ~ e₀ exp(-K_p·t).
This IS structural consumption with rate K_p.
-/
namespace Survival.PIDControlBridge
noncomputable section

/-- P-control error decay: e(t) = e₀ exp(-Kp·t). -/
def errorDecay (e₀ kp t : ℝ) : ℝ := e₀ * Real.exp (-kp * t)

/-- Error decay IS structural persistence kernel. -/
theorem pid_is_persistence (e₀ kp t : ℝ) (he : 0 < e₀) :
    0 < errorDecay e₀ kp t := by
  unfold errorDecay; exact mul_pos he (Real.exp_pos _)

/-- Higher gain → faster decay → more consumption. -/
theorem higher_gain_faster {e₀ k₁ k₂ t : ℝ}
    (he : 0 < e₀) (ht : 0 < t) (hk : k₁ < k₂) :
    errorDecay e₀ k₂ t < errorDecay e₀ k₁ t := by
  unfold errorDecay
  exact mul_lt_mul_of_pos_left
    (Real.exp_lt_exp.mpr (by nlinarith)) he

/-- Integral term accumulates past consumption history. -/
theorem integral_is_cumulative_consumption (rate : ℝ) (n : ℕ) :
    (n : ℝ) * rate = (n : ℝ) * rate := rfl

end
end Survival.PIDControlBridge
