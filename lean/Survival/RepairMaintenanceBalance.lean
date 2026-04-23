import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Repair / Maintenance Balance

This module records the minimal G4 v2 non-CSP open-system skeleton.  It is a
finite-prefix algebraic model of accumulated damage with explicit repair:

* damage flow `d_t`,
* repair / maintenance flow `g_t`,
* net action `a_t = d_t - g_t`,
* cumulative action `A_n = ∑_{t<n} a_t`,
* damage level `D_n = D_0 + A_n`,
* margin `M_n = B - D_n`,
* optional exponential maintenance coordinate `R_t = exp (-D_t)`.

It deliberately does not prove an optimal maintenance theorem, a stochastic
reliability theorem, or a fatigue crack-growth law.  It only packages the
loss-minus-repair finite-prefix identity needed by the structural balance law.
-/

open scoped BigOperators

namespace Survival.RepairMaintenanceBalance

noncomputable section

/-- One-step net structural action: damage minus repair / maintenance. -/
def netAction (damage repair : ℕ → ℝ) (t : ℕ) : ℝ :=
  damage t - repair t

/-- Cumulative net action over the finite prefix `0, ..., n-1`. -/
def cumulativeNetAction (damage repair : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ t ∈ Finset.range n, netAction damage repair t

/-- Damage accumulated from initial damage `D0` after `n` steps. -/
def damageLevel (D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) : ℝ :=
  D0 + cumulativeNetAction damage repair n

/-- Remaining margin before crossing threshold `B`. -/
def margin (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) : ℝ :=
  B - damageLevel D0 damage repair n

/-- Threshold crossing predicate for the finite prefix. -/
def ThresholdCrossed (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) : Prop :=
  B ≤ damageLevel D0 damage repair n

/-- Optional exponential maintenance coordinate induced by damage level. -/
def relativeMaintenance (D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) : ℝ :=
  Real.exp (-(damageLevel D0 damage repair n))

/-- Damage-only cumulative action, used to compare with repaired dynamics. -/
def cumulativeDamage (damage : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ t ∈ Finset.range n, damage t

/-- Damage-only level, i.e. the same system with zero repair. -/
def damageOnlyLevel (D0 : ℝ) (damage : ℕ → ℝ) (n : ℕ) : ℝ :=
  D0 + cumulativeDamage damage n

/-- Damage-only remaining margin. -/
def damageOnlyMargin (B D0 : ℝ) (damage : ℕ → ℝ) (n : ℕ) : ℝ :=
  B - damageOnlyLevel D0 damage n

@[simp] theorem cumulativeNetAction_zero (damage repair : ℕ → ℝ) :
    cumulativeNetAction damage repair 0 = 0 := by
  simp [cumulativeNetAction]

@[simp] theorem cumulativeDamage_zero (damage : ℕ → ℝ) :
    cumulativeDamage damage 0 = 0 := by
  simp [cumulativeDamage]

@[simp] theorem damageLevel_zero (D0 : ℝ) (damage repair : ℕ → ℝ) :
    damageLevel D0 damage repair 0 = D0 := by
  simp [damageLevel]

@[simp] theorem margin_zero (B D0 : ℝ) (damage repair : ℕ → ℝ) :
    margin B D0 damage repair 0 = B - D0 := by
  simp [margin]

@[simp] theorem relativeMaintenance_pos
    (D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    0 < relativeMaintenance D0 damage repair n := by
  exact Real.exp_pos _

/-- Appending one step adds that step's net action. -/
theorem cumulativeNetAction_succ (damage repair : ℕ → ℝ) (n : ℕ) :
    cumulativeNetAction damage repair (n + 1) =
      cumulativeNetAction damage repair n + netAction damage repair n := by
  unfold cumulativeNetAction
  rw [Finset.sum_range_succ]

/-- Appending one damage-only step adds that step's damage. -/
theorem cumulativeDamage_succ (damage : ℕ → ℝ) (n : ℕ) :
    cumulativeDamage damage (n + 1) =
      cumulativeDamage damage n + damage n := by
  unfold cumulativeDamage
  rw [Finset.sum_range_succ]

/-- Damage level is initial damage plus cumulative net action. -/
theorem damageLevel_eq_initial_plus_cumulative_net_action
    (D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    damageLevel D0 damage repair n =
      D0 + cumulativeNetAction damage repair n := rfl

/-- One more step updates damage by the net action `d_t - g_t`. -/
theorem damageLevel_succ_eq_damageLevel_add_netAction
    (D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    damageLevel D0 damage repair (n + 1) =
      damageLevel D0 damage repair n + netAction damage repair n := by
  unfold damageLevel
  rw [cumulativeNetAction_succ]
  ring

/-- Margin is initial margin minus cumulative net action. -/
theorem margin_eq_initial_margin_sub_cumulative_net_action
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    margin B D0 damage repair n =
      (B - D0) - cumulativeNetAction damage repair n := by
  unfold margin damageLevel
  ring

/-- One more step lowers margin by the net action. -/
theorem margin_succ_eq_margin_sub_netAction
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    margin B D0 damage repair (n + 1) =
      margin B D0 damage repair n - netAction damage repair n := by
  rw [margin_eq_initial_margin_sub_cumulative_net_action]
  rw [margin_eq_initial_margin_sub_cumulative_net_action]
  rw [cumulativeNetAction_succ]
  ring

/-- Crossing the damage threshold is exactly having nonpositive margin. -/
theorem thresholdCrossed_iff_margin_nonpos
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    ThresholdCrossed B D0 damage repair n ↔
      margin B D0 damage repair n ≤ 0 := by
  unfold ThresholdCrossed margin
  constructor
  · intro h
    linarith
  · intro h
    linarith

/-- If damage remains below threshold, the threshold has not crossed. -/
theorem not_thresholdCrossed_of_damage_lt_threshold
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ)
    (hbelow : damageLevel D0 damage repair n < B) :
    ¬ ThresholdCrossed B D0 damage repair n := by
  unfold ThresholdCrossed
  exact not_le_of_gt hbelow

/-- If remaining margin is nonpositive, the threshold has crossed. -/
theorem thresholdCrossed_of_margin_nonpos
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ)
    (hmargin : margin B D0 damage repair n ≤ 0) :
    ThresholdCrossed B D0 damage repair n := by
  exact (thresholdCrossed_iff_margin_nonpos B D0 damage repair n).2 hmargin

/-- If cumulative net action exceeds initial margin, threshold crossing occurs. -/
theorem thresholdCrossed_of_initial_margin_le_cumulativeNetAction
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ)
    (hcross : B - D0 ≤ cumulativeNetAction damage repair n) :
    ThresholdCrossed B D0 damage repair n := by
  unfold ThresholdCrossed damageLevel
  linarith

/-- The exponential maintenance coordinate obeys the same local balance law. -/
theorem relativeMaintenance_succ_eq_mul_exp_neg_netAction
    (D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ) :
    relativeMaintenance D0 damage repair (n + 1) =
      relativeMaintenance D0 damage repair n *
        Real.exp (-(netAction damage repair n)) := by
  unfold relativeMaintenance
  rw [damageLevel_succ_eq_damageLevel_add_netAction]
  rw [← Real.exp_add]
  congr 1
  ring

/-- Nonnegative repair makes one-step net action no larger than raw damage. -/
theorem netAction_le_damage_of_repair_nonneg
    (damage repair : ℕ → ℝ) (n : ℕ)
    (hrepair : 0 ≤ repair n) :
    netAction damage repair n ≤ damage n := by
  unfold netAction
  linarith

/-- If repair dominates damage, the one-step net action is nonpositive. -/
theorem netAction_nonpos_of_damage_le_repair
    (damage repair : ℕ → ℝ) (n : ℕ)
    (hdom : damage n ≤ repair n) :
    netAction damage repair n ≤ 0 := by
  unfold netAction
  linarith

/-- Nonnegative repair makes next margin at least the damage-only next margin
computed from the same current margin. -/
theorem margin_succ_ge_margin_sub_damage_of_repair_nonneg
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ)
    (hrepair : 0 ≤ repair n) :
    margin B D0 damage repair n - damage n ≤
      margin B D0 damage repair (n + 1) := by
  rw [margin_succ_eq_margin_sub_netAction]
  unfold netAction
  linarith

/-- With nonnegative repair at every step, repaired damage never exceeds the
damage-only level over the same finite prefix. -/
theorem damageLevel_le_damageOnlyLevel_of_repair_nonneg
    (D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ)
    (hrepair : ∀ t, 0 ≤ repair t) :
    damageLevel D0 damage repair n ≤ damageOnlyLevel D0 damage n := by
  have hsum :
      cumulativeNetAction damage repair n ≤ cumulativeDamage damage n := by
    unfold cumulativeNetAction cumulativeDamage
    exact Finset.sum_le_sum fun t _ => by
      unfold netAction
      linarith [hrepair t]
  unfold damageLevel damageOnlyLevel
  linarith

/-- With nonnegative repair at every step, repaired margin is at least the
damage-only margin over the same finite prefix. -/
theorem damageOnlyMargin_le_margin_of_repair_nonneg
    (B D0 : ℝ) (damage repair : ℕ → ℝ) (n : ℕ)
    (hrepair : ∀ t, 0 ≤ repair t) :
    damageOnlyMargin B D0 damage n ≤ margin B D0 damage repair n := by
  have hlevel :=
    damageLevel_le_damageOnlyLevel_of_repair_nonneg D0 damage repair n hrepair
  unfold damageOnlyMargin margin
  linarith

end

end Survival.RepairMaintenanceBalance
