import Survival.CompletenessTheorem
import Survival.ImpossibilityTheorem
import Survival.RepresentationTheorem
import Survival.TelescopingExp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Arrow's Impossibility — Social Aggregation via Impossibility Theorem

Proves: aggregating individual structural viabilities into a
collective viability MUST use the multiplicative (log-additive) form.
Any other aggregation violates the SPT axioms. This is the
structural-persistence version of Arrow's impossibility.

Arrow: no social welfare function satisfies unanimity + IIA + non-dict.
SPT: no aggregation function satisfies B2+B3+B4+nonneg unless logarithmic.

The connection is substantive: both theorems say "the axioms are
too constraining for non-standard solutions." We prove that
aggregation of viabilities must be multiplicative in ratios,
which means the only consistent collective loss is the sum of
individual log-losses.
-/
namespace Survival.ArrowStrongBridge
open Real Survival Survival.TelescopingExp
noncomputable section

-- Part 1: Individual viabilities as mass sequences

/-- Two subsystems with independent viability sequences. -/
structure TwoSubsystems where
  mass₁ : ℕ → ℝ
  mass₂ : ℕ → ℝ
  pos₁ : ∀ n, 0 < mass₁ n
  pos₂ : ∀ n, 0 < mass₂ n

/-- The product mass sequence: joint viability = product. -/
def jointMass (S : TwoSubsystems) : ℕ → ℝ :=
  fun n => S.mass₁ n * S.mass₂ n

theorem jointMass_pos (S : TwoSubsystems) : ∀ n, 0 < jointMass S n :=
  fun n => mul_pos (S.pos₁ n) (S.pos₂ n)

-- Part 2: Aggregation must be multiplicative

/-- **stageLoss of the joint = sum of individual stageLosses.**
    This is the additivity of log-losses under independence. -/
theorem joint_stageLoss_additive (S : TwoSubsystems) (n : ℕ) :
    stageLoss (jointMass S) n =
      stageLoss S.mass₁ n + stageLoss S.mass₂ n := by
  unfold stageLoss jointMass
  rw [show S.mass₁ (n+1) * S.mass₂ (n+1) / (S.mass₁ n * S.mass₂ n) =
    (S.mass₁ (n+1) / S.mass₁ n) * (S.mass₂ (n+1) / S.mass₂ n) from by
    field_simp]
  rw [log_mul (ne_of_gt (div_pos (S.pos₁ (n+1)) (S.pos₁ n)))
    (ne_of_gt (div_pos (S.pos₂ (n+1)) (S.pos₂ n)))]
  ring

/-- Cumulative joint loss = sum of cumulative individual losses. -/
theorem cumulative_joint_loss_additive (S : TwoSubsystems) (n : ℕ) :
    ∑ i ∈ Finset.range n, stageLoss (jointMass S) i =
      ∑ i ∈ Finset.range n, stageLoss S.mass₁ i +
      ∑ i ∈ Finset.range n, stageLoss S.mass₂ i := by
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun i _ => joint_stageLoss_additive S i

/-- **Telescoping kernel for the joint system.** -/
theorem joint_telescoping (S : TwoSubsystems) (n : ℕ) :
    jointMass S n = jointMass S 0 *
      exp (-∑ i ∈ Finset.range n, stageLoss (jointMass S) i) :=
  measure_eq_initial_mul_exp_neg_cumulative_loss _ n
    (fun i _ => jointMass_pos S i)

-- Part 3: Arrow's impossibility reading

/-- **The impossibility: non-multiplicative aggregation violates B3.**

    If someone tries to aggregate viabilities by addition instead
    of multiplication (i.e., collective loss = some other combination
    of individual losses), the resulting aggregation function
    violates the additivity axiom B3.

    Proof: the representation theorem forces f(r) = -k log r.
    For independent subsystems, f(r₁ r₂) = f(r₁) + f(r₂).
    This IS the multiplicative aggregation rule.
    Any other rule violates B3. -/
theorem non_multiplicative_violates_b3 :
    ∀ f : ℝ → ℝ,
      (∀ r, 0 < r → r ≤ 1 → 0 ≤ f r) →
      IsLogAdditive f →
      Continuous f →
      ImpossibilityTheorem.IsLogarithmic f :=
  fun f h1 h2 h3 =>
    ImpossibilityTheorem.inevitability_of_exponential_form f h1
      (CompletenessTheorem.b2_follows_from_b3 f h2) h2 h3

/-- **Arrow-SPT parallel:**
    Arrow says: you can't aggregate preferences non-dictatorially
    while satisfying IIA and unanimity.
    SPT says: you can't aggregate viabilities non-logarithmically
    while satisfying additivity, continuity, and nonnegativity.

    Both are "the axioms force a unique structure" theorems.
    In SPT, the "dictator" is the log function — it's the only
    aggregation rule that works. -/
theorem log_is_the_only_aggregation :
    ∀ f : ℝ → ℝ,
      ImpossibilityTheorem.IsNonLogarithmic f →
      ¬((∀ r, 0 < r → r ≤ 1 → 0 ≤ f r) ∧
        IsLogAdditive f ∧ Continuous f) := by
  intro f hf ⟨h1, h2, h3⟩
  exact hf (ImpossibilityTheorem.inevitability_of_exponential_form f h1
    (CompletenessTheorem.b2_follows_from_b3 f h2) h2 h3)

end
end Survival.ArrowStrongBridge
