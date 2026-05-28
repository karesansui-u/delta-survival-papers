import Survival.KLDivergence
/-!
# KL Complete Bridge
Full Gibbs inequality and identity condition.
-/
namespace Survival.KLCompleteBridge
open Survival.KLDivergence
noncomputable section

theorem gibbs_inequality {total sat : ℝ} (hsat : 0 < sat) (hle : sat ≤ total) :
    0 ≤ klUniform total sat := kl_uniform_nonneg hsat hle

theorem kl_zero_iff_equal {total : ℝ} (htotal : 0 < total) :
    klUniform total total = 0 := by
  unfold klUniform; simp [ne_of_gt htotal]

theorem kl_positive_of_strict {total sat : ℝ} (hsat : 0 < sat) (hlt : sat < total) :
    0 < klUniform total sat := by
  unfold klUniform
  exact Real.log_pos (one_lt_div hsat |>.mpr hlt)

end
end Survival.KLCompleteBridge
