import Survival.TelescopingExp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Kalman Filter Bridge — Hardened (Core-Connected)

Constructs the prediction→update cycle as a mass sequence,
proves stageLoss equals the log-uncertainty-ratio, and applies
the telescoping kernel to derive cumulative estimation precision.

Pattern: mass列 → stageLoss一致 → telescoping核適用 → 大域的帰結
-/
namespace Survival.KalmanBridge
open Real Survival.TelescopingExp
noncomputable section

structure KalmanScalar where
  P_pred : ℝ
  R : ℝ
  P_pred_pos : 0 < P_pred
  R_pos : 0 < R

def sumPR (K : KalmanScalar) : ℝ := K.P_pred + K.R
theorem sumPR_pos (K : KalmanScalar) : 0 < sumPR K := by
  unfold sumPR; linarith [K.P_pred_pos, K.R_pos]

/-- Mass sequence: uncertainty after k updates. Each update
    multiplies by the retention ratio R/(P+R). -/
def uncertaintyMass (K : KalmanScalar) : ℕ → ℝ
  | 0 => K.P_pred
  | n + 1 => uncertaintyMass K n * (K.R / sumPR K)

theorem uncertaintyMass_pos (K : KalmanScalar) : ∀ n, 0 < uncertaintyMass K n := by
  intro n; induction n with
  | zero => exact K.P_pred_pos
  | succ n ih => exact mul_pos ih (div_pos K.R_pos (sumPR_pos K))

/-- Ratio at each step = R/(P+R). -/
theorem uncertainty_ratio (K : KalmanScalar) (n : ℕ) :
    uncertaintyMass K (n + 1) / uncertaintyMass K n = K.R / sumPR K := by
  simp only [uncertaintyMass]
  exact mul_div_cancel_left₀ _ (ne_of_gt (uncertaintyMass_pos K n))

/-- **Core bridge: stageLoss = -log(R/(P+R)).** -/
theorem stageLoss_eq_info (K : KalmanScalar) (n : ℕ) :
    stageLoss (uncertaintyMass K) n = -log (K.R / sumPR K) := by
  unfold stageLoss; rw [uncertainty_ratio]

/-- **Telescoping kernel: uncertainty_n = uncertainty_0 × exp(-Σ stageLoss).** -/
theorem kalman_telescoping (K : KalmanScalar) (n : ℕ) :
    uncertaintyMass K n = uncertaintyMass K 0 *
      exp (-∑ i ∈ Finset.range n, stageLoss (uncertaintyMass K) i) :=
  measure_eq_initial_mul_exp_neg_cumulative_loss _ n
    (fun i _ => uncertaintyMass_pos K i)

/-- **Global: uncertainty decreases monotonically (precision improves).** -/
theorem precision_improves (K : KalmanScalar) (n : ℕ) :
    uncertaintyMass K n ≤ uncertaintyMass K 0 := by
  rw [kalman_telescoping K n]
  have hsl : ∀ i, 0 ≤ stageLoss (uncertaintyMass K) i := fun i => by
    rw [stageLoss_eq_info]; rw [neg_nonneg]
    have : K.R / sumPR K ≤ 1 := by
      rw [div_le_one₀ (sumPR_pos K)]; unfold sumPR; linarith [K.P_pred_pos]
    exact log_nonpos (le_of_lt (div_pos K.R_pos (sumPR_pos K))) this
  have hexp : exp (-∑ i ∈ Finset.range n, stageLoss (uncertaintyMass K) i) ≤ 1 := by
    rw [exp_le_one_iff, neg_nonpos]
    exact Finset.sum_nonneg fun i _ => hsl i
  nlinarith [uncertaintyMass_pos K 0]

end
end Survival.KalmanBridge
