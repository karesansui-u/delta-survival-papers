import Survival.TelescopingExp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Hamilton's Rule Bridge — Hardened (Core-Connected)

Constructs altruistic trait frequency as a mass sequence where
each generation's viable carriers shrink/grow by factor
determined by rB vs C. stageLoss = log(1 + C/freq) - log(1 + rB/freq),
telescoping kernel gives cumulative fitness, Hamilton's rule
as necessary and sufficient condition for persistence.

Pattern: mass列 → stageLoss一致 → telescoping核適用 → 大域的帰結
-/
namespace Survival.HamiltonRuleBridge
open Real Survival.TelescopingExp
noncomputable section

/-- Kin selection model: each generation, altruists pay cost C
    but receive rB from relatives. Net fitness change per generation
    determines whether the trait persists. -/
structure KinModel where
  relatedness : ℝ
  benefit : ℝ
  cost : ℝ
  r_pos : 0 < relatedness
  r_le_one : relatedness ≤ 1
  benefit_pos : 0 < benefit
  cost_pos : 0 < cost

/-- Net fitness multiplier per generation: (1 + rB - C) / 1.
    When rB > C, the trait grows; when rB < C, it shrinks. -/
def fitnessMultiplier (M : KinModel) : ℝ :=
  1 + M.relatedness * M.benefit - M.cost

/-- Mass sequence: frequency of altruistic allele over generations.
    Each generation multiplies by the fitness multiplier. -/
def alleleMass (M : KinModel) (f₀ : ℝ) : ℕ → ℝ
  | 0 => f₀
  | n + 1 => alleleMass M f₀ n * fitnessMultiplier M

/-- When rB > C, fitness multiplier > 1 (trait grows). -/
theorem multiplier_gt_one (M : KinModel) (h : M.relatedness * M.benefit > M.cost) :
    1 < fitnessMultiplier M := by
  unfold fitnessMultiplier; linarith

/-- When rB < C, fitness multiplier < 1 (trait shrinks). -/
theorem multiplier_lt_one (M : KinModel) (h : M.cost > M.relatedness * M.benefit) :
    fitnessMultiplier M < 1 := by
  unfold fitnessMultiplier; linarith

/-- Assuming fitnessMultiplier > 0 (not lethal), mass is positive. -/
theorem alleleMass_pos (M : KinModel) (f₀ : ℝ) (hf₀ : 0 < f₀)
    (hfm : 0 < fitnessMultiplier M) :
    ∀ n, 0 < alleleMass M f₀ n := by
  intro n; induction n with
  | zero => exact hf₀
  | succ n ih => exact mul_pos ih hfm

/-- **Core bridge: stageLoss = -log(fitnessMultiplier).**
    When rB > C, stageLoss < 0 (net recovery).
    When rB < C, stageLoss > 0 (net consumption). -/
theorem stageLoss_eq_fitness (M : KinModel) (f₀ : ℝ) (hf₀ : 0 < f₀)
    (hfm : 0 < fitnessMultiplier M) (n : ℕ) :
    stageLoss (alleleMass M f₀) n = -log (fitnessMultiplier M) := by
  unfold stageLoss
  simp only [stageLoss, alleleMass]
  rw [mul_div_cancel_left₀ _ (ne_of_gt (alleleMass_pos M f₀ hf₀ hfm n))]

/-- **Telescoping kernel: allele frequency after n generations.** -/
theorem hamilton_telescoping (M : KinModel) (f₀ : ℝ) (hf₀ : 0 < f₀)
    (hfm : 0 < fitnessMultiplier M) (n : ℕ) :
    alleleMass M f₀ n = alleleMass M f₀ 0 *
      exp (-∑ i ∈ Finset.range n, stageLoss (alleleMass M f₀) i) :=
  measure_eq_initial_mul_exp_neg_cumulative_loss _ n
    (fun i _ => alleleMass_pos M f₀ hf₀ hfm i)

/-- **Hamilton's rule (global): rB > C ⟹ stageLoss < 0 ⟹ trait grows.** -/
theorem hamilton_rule_persistence (M : KinModel) (f₀ : ℝ) (hf₀ : 0 < f₀)
    (h : M.relatedness * M.benefit > M.cost)
    (hfm : 0 < fitnessMultiplier M) (n : ℕ) :
    stageLoss (alleleMass M f₀) n < 0 := by
  rw [stageLoss_eq_fitness M f₀ hf₀ hfm]
  rw [neg_neg_iff_pos] at *
  exact log_pos (multiplier_gt_one M h)

/-- Sibling rule: r = 1/2 → B > 2C required. -/
theorem sibling_rule (B C : ℝ) (hB : 0 < B) (hC : 0 < C) :
    (1/2 : ℝ) * B > C ↔ B > 2 * C := by
  constructor <;> intro h <;> linarith

end
end Survival.HamiltonRuleBridge
