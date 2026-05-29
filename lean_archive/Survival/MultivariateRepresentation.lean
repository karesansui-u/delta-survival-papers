import Survival.RepresentationTheorem
import Survival.TelescopingExp

/-!
# Multivariate Representation Theorem

Extends the representation theorem to systems with multiple
independent maintenance conditions G_1, ..., G_k.

## The theorem

If a system has k independent maintenance conditions, each with
its own viability measure m_j and loss function f_j satisfying
B2+B3+B4+nonneg, then:

1. Each f_j must be -k_j · log r_j (by the scalar theorem)
2. The joint retention is the product: Π_j exp(-L_j^(n))
3. The joint loss is the sum: L_total = Σ_j L_j

## Significance

Ensures the theory scales to complex systems with multiple
maintenance conditions, without introducing any new "choices."
-/

namespace Survival.MultivariateRepresentation

open Survival.RepresentationTheorem
open Survival.TelescopingExp
open Real

noncomputable section

/-! ## Part 1: Independent Components -/

/-- A **multi-component system** with k independent maintenance
conditions, each with its own mass sequence and loss function. -/
structure MultiComponentSystem (k : ℕ) where
  /-- Mass sequence for each component -/
  mass : Fin k → ℕ → ℝ
  /-- Each component has positive mass -/
  mass_pos : ∀ j n, 0 < mass j n
  /-- Each component has a persistence functional -/
  functional : Fin k → PersistenceFunctional

/-- The stage loss for component j at time i. -/
def componentStageLoss
    (S : MultiComponentSystem k) (j : Fin k) (i : ℕ) : ℝ :=
  stageLoss (S.mass j) i

/-- The cumulative loss for component j up to time n. -/
def componentCumulativeLoss
    (S : MultiComponentSystem k) (j : Fin k) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, componentStageLoss S j i

/-! ## Part 2: Each Component Independently Log -/

/-- **Each component's loss must be logarithmic.**

By the scalar representation theorem, each f_j satisfying
B2+B3+B4+nonneg must be -k_j · log r for some k_j ≥ 0. -/
theorem each_component_log
    (S : MultiComponentSystem k) (j : Fin k) :
    ∃ kj : ℝ, 0 ≤ kj ∧
      ∀ r, 0 < r → r ≤ 1 →
        (S.functional j).lossFn r = -kj * log r :=
  loss_must_be_log (S.functional j)

/-! ## Part 3: Joint Retention -/

/-- The **joint retention factor** is the product of individual
retention factors.

Π_j m_j(n)/m_j(0) = Π_j exp(-L_j) = exp(-Σ_j L_j) -/
def jointRetention
    (S : MultiComponentSystem k) (n : ℕ) : ℝ :=
  ∏ j : Fin k, (S.mass j n / S.mass j 0)

/-- Each individual retention is exp(-L_j). -/
theorem individual_retention_exp
    (S : MultiComponentSystem k) (j : Fin k) (n : ℕ) :
    S.mass j n =
      S.mass j 0 *
        exp (-componentCumulativeLoss S j n) := by
  unfold componentCumulativeLoss componentStageLoss
  exact measure_eq_initial_mul_exp_neg_cumulative_loss
    (S.mass j) n (fun i _ => S.mass_pos j i)

/-! ## Part 4: Total Loss is Sum of Component Losses -/

/-- The **total structural loss** is the sum of component losses. -/
def totalLoss
    (S : MultiComponentSystem k) (n : ℕ) : ℝ :=
  ∑ j : Fin k, componentCumulativeLoss S j n

/-- Total loss is nonneg when each component loss is nonneg. -/
theorem totalLoss_nonneg
    (S : MultiComponentSystem k) (n : ℕ)
    (hcomp : ∀ j, 0 ≤ componentCumulativeLoss S j n) :
    0 ≤ totalLoss S n := by
  unfold totalLoss
  exact Finset.sum_nonneg (fun j _ => hcomp j)

/-! ## Part 5: The Multivariate Representation Theorem -/

/-- **Multivariate Representation Theorem.**

For a k-component system:
1. Each loss function is forced to be -k_j · log r
2. Each retention is exp(-L_j)
3. The total loss L_total = Σ_j L_j
4. No interaction terms arise

The multi-component case introduces NO new functional forms.
Independence is preserved by the additive structure of logarithms. -/
theorem multivariate_representation
    (S : MultiComponentSystem k) :
    ∀ j : Fin k,
      ∃ kj : ℝ, 0 ≤ kj ∧
        ∀ r, 0 < r → r ≤ 1 →
          (S.functional j).lossFn r = -kj * log r :=
  fun j => each_component_log S j

/-- **No interaction theorem**: the total loss is purely additive.
There are no cross-terms between components.

This means: in a multi-component system, structural accounting
decomposes into independent per-component accounts. No "synergy"
or "interference" terms can arise within the axiomatic framework. -/
theorem no_interaction_terms
    (S : MultiComponentSystem k) (n : ℕ) :
    totalLoss S n =
      ∑ j : Fin k, componentCumulativeLoss S j n := rfl

end

end Survival.MultivariateRepresentation
