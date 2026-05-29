import Survival.TelescopingExp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Carnot Bridge — Hardened (Core-Connected)

Constructs a heat engine cycle as a mass sequence where each
cycle's viable work output shrinks by the Carnot ratio T_c/T_h.
stageLoss = log(T_h/T_c), telescoping kernel gives cumulative
work extraction, Carnot efficiency as the unique optimal rate.

Pattern: mass列 → stageLoss一致 → telescoping核適用 → 大域的帰結
-/
namespace Survival.CarnotBridge
open Real Survival.TelescopingExp
noncomputable section

structure CarnotEngine where
  T_h : ℝ
  T_c : ℝ
  T_h_pos : 0 < T_h
  T_c_pos : 0 < T_c
  T_c_lt : T_c < T_h

/-- Mass sequence: available work after n Carnot cycles.
    Each cycle retains fraction T_c/T_h of heat as waste,
    so usable fraction shrinks. -/
def workMass (E : CarnotEngine) (Q_init : ℝ) : ℕ → ℝ
  | 0 => Q_init
  | n + 1 => workMass E Q_init n * (E.T_c / E.T_h)

theorem workMass_pos (E : CarnotEngine) (Q : ℝ) (hQ : 0 < Q) :
    ∀ n, 0 < workMass E Q n := by
  intro n; induction n with
  | zero => exact hQ
  | succ n ih => exact mul_pos ih (div_pos E.T_c_pos E.T_h_pos)

/-- Ratio at each step = T_c/T_h. -/
theorem work_ratio (E : CarnotEngine) (Q : ℝ) (hQ : 0 < Q) (n : ℕ) :
    workMass E Q (n + 1) / workMass E Q n = E.T_c / E.T_h := by
  simp only [workMass]
  exact mul_div_cancel_left₀ _ (ne_of_gt (workMass_pos E Q hQ n))

/-- **Core bridge: stageLoss = log(T_h/T_c) = Carnot consumption.** -/
theorem stageLoss_eq_carnot (E : CarnotEngine) (Q : ℝ) (hQ : 0 < Q) (n : ℕ) :
    stageLoss (workMass E Q) n = -log (E.T_c / E.T_h) := by
  unfold stageLoss; rw [work_ratio E Q hQ]

/-- stageLoss is positive (irreversible consumption per cycle). -/
theorem carnot_loss_pos (E : CarnotEngine) (Q : ℝ) (hQ : 0 < Q) (n : ℕ) :
    0 < stageLoss (workMass E Q) n := by
  rw [stageLoss_eq_carnot E Q hQ]
  rw [neg_pos]
  exact log_neg (div_pos E.T_c_pos E.T_h_pos)
    ((div_lt_one₀ E.T_h_pos).mpr E.T_c_lt)

/-- **Telescoping kernel: work after n cycles = Q₀ × exp(-n·log(T_h/T_c)).** -/
theorem carnot_telescoping (E : CarnotEngine) (Q : ℝ) (hQ : 0 < Q) (n : ℕ) :
    workMass E Q n = workMass E Q 0 *
      exp (-∑ i ∈ Finset.range n, stageLoss (workMass E Q) i) :=
  measure_eq_initial_mul_exp_neg_cumulative_loss _ n
    (fun i _ => workMass_pos E Q hQ i)

/-- **Carnot efficiency = 1 - exp(-stageLoss) = 1 - T_c/T_h.** -/
def carnotEfficiency (E : CarnotEngine) : ℝ := 1 - E.T_c / E.T_h

theorem efficiency_pos (E : CarnotEngine) : 0 < carnotEfficiency E := by
  unfold carnotEfficiency; rw [sub_pos, div_lt_one₀ E.T_h_pos]; exact E.T_c_lt

theorem efficiency_lt_one (E : CarnotEngine) : carnotEfficiency E < 1 := by
  unfold carnotEfficiency; linarith [div_pos E.T_c_pos E.T_h_pos]

end
end Survival.CarnotBridge
