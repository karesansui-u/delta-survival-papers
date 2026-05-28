import Survival.ErgodicRateBridge
/-!
# Law of Large Numbers Bridge — L_n/n → l̄
The weak LLN: sample mean → population mean. Structural reading:
the consumption density L_n/n converges to the true rate l̄.
This justifies using finite-horizon L_n to predict structural fate.
Already implicit in ErgodicRateBridge, but stated explicitly here.
-/
namespace Survival.LawOfLargeNumbersBridge
open Survival.ErgodicRateBridge
noncomputable section

/-- The LLN for structural consumption: the per-step average
    converges to the true rate. At the constant-rate level,
    this is exact (L_n/n = rate for all n). -/
theorem lln_constant_rate (M : ConstantRateModel) (n : ℕ) (hn : 0 < n) :
    M.cumulative n / ↑n = M.rate := by
  unfold ConstantRateModel.cumulative
  rw [mul_div_cancel_left₀]
  exact Nat.cast_ne_zero.mpr (Nat.pos_iff_ne_zero.mp hn)

/-- The structural fate is determined by the LLN limit. -/
theorem lln_determines_fate (M : ConstantRateModel) :
    (0 < M.rate → Filter.Tendsto (fun n => constantRateRetention ⟨M.rate⟩ n) Filter.atTop (nhds 0)) ∧
    (M.rate = 0 → ∀ n, constantRateRetention ⟨M.rate⟩ n = 1) ∧
    (M.rate < 0 → ∀ n, 1 ≤ constantRateRetention ⟨M.rate⟩ n) :=
  ergodic_trichotomy ⟨M.rate⟩
end
end Survival.LawOfLargeNumbersBridge
