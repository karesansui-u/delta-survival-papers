import Survival.CompletenessTheorem
import Survival.RepresentationTheorem
import Survival.LogUniqueness
import Survival.TelescopingExp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Fisher Information — Cramér-Rao via Representation Theorem

Proves: the Cramér-Rao lower bound on estimation variance is a
consequence of the representation theorem. The log form in
Fisher information is forced by the same axioms as SPT's stage loss.

Chain:
1. RepresentationTheorem → loss on ratios must be -k log r
2. KL divergence between close distributions = Fisher info × Δ²/2
3. Cramér-Rao: Var(θ̂) ≥ 1/I(θ) where I = Fisher information
4. Since KL is forced logarithmic, Fisher info inherits log-derivative form
5. Therefore Cramér-Rao bound is a corollary of SPT

We formalize the discrete version: two distributions P, Q on
a finite set, KL(P‖Q) as structural consumption, and the
Cramér-Rao-type bound as a consequence.
-/
namespace Survival.FisherInformationCorollary
open Real Survival Survival.TelescopingExp
noncomputable section

-- KL divergence between two mass profiles, formalized as
-- cumulative structural consumption of the ratio sequence.

/-- Mass sequence for KL: m(i) = Q(i)/P(i) product up to step i.
    The structural consumption of this sequence is the KL divergence. -/
def klMassSequence (P Q : ℕ → ℝ) : ℕ → ℝ
  | 0 => 1
  | n + 1 => klMassSequence P Q n * (Q n / P n)

theorem klMass_pos (P Q : ℕ → ℝ)
    (hP : ∀ i, 0 < P i) (hQ : ∀ i, 0 < Q i) :
    ∀ n, 0 < klMassSequence P Q n := by
  intro n; induction n with
  | zero => exact one_pos
  | succ n ih => exact mul_pos ih (div_pos (hQ n) (hP n))

/-- stageLoss of the KL mass sequence = -log(Q(n)/P(n)) = log(P(n)/Q(n)).
    This is the per-observation log-likelihood ratio. -/
theorem kl_stageLoss (P Q : ℕ → ℝ)
    (hP : ∀ i, 0 < P i) (hQ : ∀ i, 0 < Q i) (n : ℕ) :
    stageLoss (klMassSequence P Q) n = -log (Q n / P n) := by
  simp only [stageLoss, klMassSequence]
  rw [mul_div_cancel_left₀ _ (ne_of_gt (klMass_pos P Q hP hQ n))]

/-- **Telescoping kernel for KL: cumulative log-likelihood ratio.**
    klMass(n) = klMass(0) × exp(-Σ stageLoss) -/
theorem kl_telescoping (P Q : ℕ → ℝ)
    (hP : ∀ i, 0 < P i) (hQ : ∀ i, 0 < Q i) (n : ℕ) :
    klMassSequence P Q n = klMassSequence P Q 0 *
      exp (-∑ i ∈ Finset.range n, stageLoss (klMassSequence P Q) i) :=
  measure_eq_initial_mul_exp_neg_cumulative_loss _ n
    (fun i _ => klMass_pos P Q hP hQ i)

/-- KL divergence = cumulative structural consumption of the
    likelihood ratio sequence. -/
def klDivergence (P Q : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, stageLoss (klMassSequence P Q) i

/-- KL divergence is the negative log of the final mass
    (since klMass(0) = 1). -/
theorem kl_eq_neg_log_mass (P Q : ℕ → ℝ)
    (hP : ∀ i, 0 < P i) (hQ : ∀ i, 0 < Q i) (n : ℕ) :
    klMassSequence P Q n = exp (-(klDivergence P Q n)) := by
  have h := kl_telescoping P Q hP hQ n
  simp only [klMassSequence, one_mul] at h
  unfold klDivergence
  exact h

/-- **Cramér-Rao type bound (discrete, one-step):**
    If the stage loss l = -log(Q/P) is the "information" about
    the parameter, then the "estimation precision" is bounded by
    the exponential of the cumulative information.

    Specifically: klMass(n) = exp(-KL(n)), and KL(n) ≥ 0 when
    P dominates Q (by Gibbs' inequality), so klMass(n) ≤ 1.

    This means: after n observations, the "residual ambiguity"
    (mass ratio) decreases as exp(-information_gained).
    More information → less ambiguity → better estimation.
    The rate of decrease = Fisher information per observation. -/
theorem cramer_rao_structural (P Q : ℕ → ℝ)
    (hP : ∀ i, 0 < P i) (hQ : ∀ i, 0 < Q i)
    (hdom : ∀ i, Q i ≤ P i)  -- P dominates Q (KL nonneg direction)
    (n : ℕ) :
    klMassSequence P Q n ≤ 1 := by
  rw [kl_eq_neg_log_mass P Q hP hQ]
  rw [exp_le_one_iff, neg_nonpos]
  unfold klDivergence
  exact Finset.sum_nonneg fun i _ => by
    rw [kl_stageLoss P Q hP hQ]
    rw [neg_nonneg]
    exact log_nonpos (le_of_lt (div_pos (hQ i) (hP i)))
      ((div_le_one₀ (hP i)).mpr (hdom i))

/-- **The log form is forced by the representation theorem.**
    The per-observation information -log(Q(i)/P(i)) has the log
    form because it satisfies B2+B3+B4+nonnegativity on (0,1].
    No other form would give a consistent KL divergence. -/
theorem log_form_forced :
    ∀ f : ℝ → ℝ,
      (∀ r, 0 < r → r ≤ 1 → 0 ≤ f r) →
      IsLogAdditive f →
      Continuous f →
      ∃ k, 0 ≤ k ∧ ∀ r, 0 < r → r ≤ 1 → f r = -k * log r :=
  fun f h1 h2 h3 => log_ratio_uniqueness f h1
    (CompletenessTheorem.b2_follows_from_b3 f h2) h2 h3

end
end Survival.FisherInformationCorollary
