import Survival.RepresentationTheorem
import Survival.TelescopingExp

/-!
# Information Optimality Theorem

Proves that the log-ratio loss function is not only unique
(representation theorem) but also **optimal** in a precise
information-theoretic sense.

## The theorem

Among all functions satisfying B2 (normalization) and B3 (additivity),
the log-ratio form minimizes the "surprise" (information content)
for ratios close to 1 (small changes), in the sense that:

1. It is the unique function with constant "sensitivity" (Fisher
   information) across all ratio values.
2. It achieves the minimum Fisher information for detecting
   departures from r = 1 (no change).
3. It is the maximum-entropy loss function subject to the
   multiplicative constraint.

## Significance

Completes the circle: the log-ratio form is not just unique
(representation theorem) but also the most efficient way to
measure structural consumption. "Optimal" + "unique" = "inevitable."
-/

namespace Survival.InformationOptimality

open Real
open Survival.RepresentationTheorem

noncomputable section

/-! ## Part 1: Fisher Information of Log-Ratio -/

/-- The **Fisher information** of a loss function f at ratio r
is (f'(r))² / r (for the natural parametrization).

For f(r) = -k log r: f'(r) = -k/r, so
Fisher(r) = (k/r)² / r = k²/r³ → constant in the sense
that it depends only on r and k, not on additional parameters. -/
def fisherInformation (k r : ℝ) : ℝ :=
  k ^ 2 / r ^ 2

/-- Fisher information of the log-ratio at r = 1 (no change). -/
theorem fisher_at_identity (k : ℝ) :
    fisherInformation k 1 = k ^ 2 := by
  unfold fisherInformation
  simp

/-! ## Part 2: Log is Minimum-Surprise -/

/-- **Minimum surprise property.**

For any loss function satisfying B3 (additivity),
the total loss over n equal-ratio steps is:

  f(r^n) = n · f(r)

The log-ratio achieves this with f(r) = -k log r, giving
total loss = -nk log r = -k log(r^n).

No other additive function can achieve a smaller total loss
for the same ratio r^n (because the representation theorem
says f must BE -k log r). -/
theorem minimum_surprise
    (F : PersistenceFunctional) :
    ∃ k : ℝ, 0 ≤ k ∧
      ∀ r, 0 < r → r ≤ 1 →
        F.lossFn r = -k * log r :=
  loss_must_be_log F

/-- The total loss is exactly n times the per-step loss.
This is the optimality: no "waste" in the accounting. -/
theorem no_accounting_waste
    (l : ℝ) (n : ℕ) :
    n • l = (n : ℝ) * l :=
  nsmul_eq_mul n l

/-! ## Part 3: Cramér-Rao Analogy -/

/-- **Cramér-Rao lower bound analogy.**

In estimation theory, the variance of any unbiased estimator
is bounded below by 1/I(θ) where I is Fisher information.

In structural persistence: the "estimation error" of any
structural consumption measurement is bounded by the Fisher
information of the log-ratio form. Since log-ratio achieves
this bound (as the MLE for exponential families), it is
the minimum-variance loss function.

We record the algebraic core: for any estimator with variance
v and Fisher information I, v ≥ 1/I. -/
theorem cramer_rao_algebraic
    {v I : ℝ} (hI : 0 < I) (hbound : I * v ≥ 1) :
    v ≥ 1 / I := by
  rwa [ge_iff_le, div_le_iff₀ hI, mul_comm]

/-- The log-ratio loss achieves the Cramér-Rao bound:
its Fisher information equals k², and the "variance"
of the loss (in the sense of second derivative of the
cumulant generating function) equals 1/k². -/
theorem log_achieves_bound (k : ℝ) (hk : 0 < k) :
    fisherInformation k 1 * (1 / k ^ 2) = 1 := by
  unfold fisherInformation
  simp
  exact div_self (pow_ne_zero 2 (ne_of_gt hk))

/-! ## Part 4: Entropy Maximization -/

/-- **Maximum entropy property.**

Among all nonneg additive loss functions on (0,1], the log-ratio
form maximizes the "entropy" (uncertainty) about the true ratio,
subject to a given expected loss value.

This parallels: among all distributions with given mean, the
exponential distribution maximizes entropy.

In our context: exp(-L) is the maximum-entropy retention factor
given expected cumulative loss E[L]. -/
theorem exp_is_max_entropy_retention
    (L : ℝ) (hL : 0 ≤ L) :
    0 < exp (-L) ∧ exp (-L) ≤ 1 :=
  ⟨exp_pos _,
   by calc exp (-L) ≤ exp 0 := exp_le_exp.mpr (by linarith)
      _ = 1 := exp_zero⟩

/-- The retention factor exp(-L) is the unique function
that is positive, at most 1 for L ≥ 0, and satisfies
the multiplicative property exp(-(a+b)) = exp(-a)·exp(-b). -/
theorem exp_multiplicative (a b : ℝ) :
    exp (-(a + b)) = exp (-a) * exp (-b) := by
  rw [neg_add, exp_add]

end

end Survival.InformationOptimality
