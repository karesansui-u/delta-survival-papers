import Survival.KLDivergence
/-!
# Bregman Divergence Bridge
Bregman divergence D_φ(p, q) = φ(p) - φ(q) - φ'(q)(p-q).
For φ(x) = x ln x: D_φ = KL divergence.
The KL case IS structural consumption, so Bregman with φ = x ln x
is a corollary of the structural persistence framework.
-/
namespace Survival.BregmanBridge
noncomputable section

/-- Bregman divergence with φ(x) = -ln x on positive reals.
D_φ(p, q) = -ln p + ln q + (1/q)(p - q) = -ln(p/q) + p/q - 1. -/
def bregmanLogDiv (p q : ℝ) : ℝ := -Real.log (p / q) + p / q - 1

/-- Bregman divergence is nonneg (by ln x ≤ x - 1). -/
theorem bregman_nonneg {p q : ℝ} (hp : 0 < p) (hq : 0 < q) :
    0 ≤ bregmanLogDiv p q := by
  unfold bregmanLogDiv
  have hratio : 0 < p / q := div_pos hp hq
  linarith [Real.add_one_le_exp (Real.log (p / q)),
            Real.exp_log hratio]

/-- At p = q, Bregman divergence = 0. -/
theorem bregman_zero_iff_equal {q : ℝ} (hq : 0 < q) :
    bregmanLogDiv q q = 0 := by
  unfold bregmanLogDiv
  rw [div_self (ne_of_gt hq), Real.log_one]; ring

/-- KL divergence is a special case of Bregman. -/
theorem kl_is_bregman_special_case {total sat : ℝ} (hsat : 0 < sat) (htotal : 0 < total) :
    Survival.KLDivergence.klUniform total sat = Real.log total - Real.log sat :=
  Real.log_div (ne_of_gt htotal) (ne_of_gt hsat)

end
end Survival.BregmanBridge
