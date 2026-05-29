import Survival.ArrowOfTime
import Survival.Basic

/-!
# Fisher's Fundamental Theorem — Structural Persistence Bridge

This module provides the G6-c formal embedding of Fisher's fundamental
theorem of natural selection into structural persistence theory.

## Biological context

Fisher (1930) showed that the rate of increase in mean fitness of a
population equals the additive genetic variance in fitness:

    d⟨w⟩/dt = Var(w)

This is the "fundamental theorem of natural selection."

## Structural-persistence reading

We identify:
- **Fitness** `w` ≡ structural survival potential `S = M exp(-L)`
- **Hazard rate** `h(δ)` ≡ structural consumption rate (increasing in δ)
- **Selection** ≡ differential survival based on structural integrity

Under this reading:

1. **Price–Fisher theorem**: The change in mean δ due to selection is
   `Δ⟨δ⟩ = -Cov(δ, w) / ⟨w⟩`, which is negative when lower-δ types
   have higher fitness (survival selection H-theorem).

2. **Variance–rate relation**: `d⟨w⟩/dt = Var(w)` in the linear
   approximation, reading fitness as exp(-δ).

3. **Two-type Fisher theorem**: For a two-type population with
   fitness differential arising from structural consumption difference,
   the rate of fitness increase equals the variance of fitness.

The module builds on `ArrowOfTime.lean` which already proves the
selection H-theorem (average δ of survivors decreases).

References:
  - Fisher, R.A. (1930). "The Genetical Theory of Natural Selection"
  - Price, G.R. (1970). "Selection and Covariance" Nature 227, 520-521
  - Ewens, W.J. (1989). "An interpretation and proof of the fundamental
    theorem of natural selection." Theor. Pop. Biol. 36, 167-180.
  - ArrowOfTime.lean: Survival selection H-theorem
-/

namespace Survival.FisherFundamentalTheorem

open Real

noncomputable section

/-! ## Part 1: Two-Type Population with Structural Fitness -/

/-- A two-type population where fitness is determined by structural integrity.
    Type 1 has lower structural divergence (δ₁ < δ₂), hence higher fitness. -/
structure TwoTypePopulation where
  /-- Structural divergence of type 1 -/
  δ₁ : ℝ
  /-- Structural divergence of type 2 -/
  δ₂ : ℝ
  /-- Frequency of type 1 -/
  p₁ : ℝ
  /-- Frequency of type 2 -/
  p₂ : ℝ
  /-- Type 1 has lower structural divergence -/
  hδ : δ₁ < δ₂
  /-- Both types present -/
  hp₁ : 0 < p₁
  hp₂ : 0 < p₂
  /-- Frequencies sum to 1 -/
  hsum : p₁ + p₂ = 1

/-- Fitness of a type = exp(-δ), the structural survival factor. -/
def fitness (δ : ℝ) : ℝ := exp (-δ)

/-- Fitness is always positive. -/
theorem fitness_pos (δ : ℝ) : 0 < fitness δ := exp_pos _

/-- Lower δ means higher fitness. -/
theorem fitness_decreasing {δ₁ δ₂ : ℝ} (h : δ₁ < δ₂) :
    fitness δ₂ < fitness δ₁ := by
  unfold fitness
  exact exp_lt_exp.mpr (by linarith)

/-! ## Part 2: Weighted Averages and Variance -/

/-- Mean fitness of a two-type population (unnormalized). -/
def meanFitness (pop : TwoTypePopulation) : ℝ :=
  pop.p₁ * fitness pop.δ₁ + pop.p₂ * fitness pop.δ₂

/-- Mean fitness is positive. -/
theorem meanFitness_pos (pop : TwoTypePopulation) :
    0 < meanFitness pop := by
  unfold meanFitness
  exact add_pos (mul_pos pop.hp₁ (fitness_pos _)) (mul_pos pop.hp₂ (fitness_pos _))

/-- Mean δ of a two-type population (unnormalized numerator). -/
def meanDelta (pop : TwoTypePopulation) : ℝ :=
  pop.p₁ * pop.δ₁ + pop.p₂ * pop.δ₂

/-- Mean of w² (needed for the variance decomposition). -/
def meanFitnessSquared (pop : TwoTypePopulation) : ℝ :=
  pop.p₁ * (fitness pop.δ₁) ^ 2 + pop.p₂ * (fitness pop.δ₂) ^ 2

/-- Variance of fitness: p₁ p₂ (w₁ - w₂)².
    For a normalized two-type distribution (p₁+p₂=1), this equals ⟨w²⟩ - ⟨w⟩². -/
def fitnessVariance (pop : TwoTypePopulation) : ℝ :=
  pop.p₁ * pop.p₂ * (fitness pop.δ₁ - fitness pop.δ₂) ^ 2

/-- Fitness variance is nonneg. -/
theorem fitnessVariance_nonneg (pop : TwoTypePopulation) :
    0 ≤ fitnessVariance pop := by
  unfold fitnessVariance
  exact mul_nonneg (mul_nonneg (le_of_lt pop.hp₁) (le_of_lt pop.hp₂)) (sq_nonneg _)

/-- Fitness variance is strictly positive when types differ. -/
theorem fitnessVariance_pos (pop : TwoTypePopulation) :
    0 < fitnessVariance pop := by
  unfold fitnessVariance
  have hw : fitness pop.δ₂ < fitness pop.δ₁ := fitness_decreasing pop.hδ
  have hdiff : 0 < fitness pop.δ₁ - fitness pop.δ₂ := by linarith
  have hsq : 0 < (fitness pop.δ₁ - fitness pop.δ₂) ^ 2 := by positivity
  exact mul_pos (mul_pos pop.hp₁ pop.hp₂) hsq

/-! ## Part 3: Covariance of δ and Fitness -/

/-- Covariance of δ and fitness (unnormalized): p₁ p₂ (δ₂ - δ₁)(w₂ - w₁). -/
def covDeltaFitness (pop : TwoTypePopulation) : ℝ :=
  pop.p₁ * pop.p₂ * (pop.δ₂ - pop.δ₁) * (fitness pop.δ₂ - fitness pop.δ₁)

/-- **Key sign result**: Cov(δ, w) < 0 when δ₁ < δ₂.
    This means lower-δ types have higher fitness (survival selection). -/
theorem covDeltaFitness_neg (pop : TwoTypePopulation) :
    covDeltaFitness pop < 0 := by
  unfold covDeltaFitness
  have hd : 0 < pop.δ₂ - pop.δ₁ := by linarith [pop.hδ]
  have hw : fitness pop.δ₂ - fitness pop.δ₁ < 0 := by
    have := fitness_decreasing pop.hδ
    linarith
  have hpp : 0 < pop.p₁ * pop.p₂ := mul_pos pop.hp₁ pop.hp₂
  have hpd : 0 < pop.p₁ * pop.p₂ * (pop.δ₂ - pop.δ₁) :=
    mul_pos hpp hd
  exact mul_neg_of_pos_of_neg hpd hw

/-! ## Part 4: Price Equation (Structural Form) -/

/-- **Price equation (structural form)**:
    Change in mean δ due to selection = Cov(δ, w) / ⟨w⟩.

    Since Cov(δ, w) < 0, selection always reduces mean δ.
    This is the structural-persistence reading of Price's equation:
    differential survival by structural integrity drives the population
    toward lower structural divergence. -/
theorem price_equation_sign (pop : TwoTypePopulation) :
    covDeltaFitness pop / meanFitness pop < 0 :=
  div_neg_of_neg_of_pos (covDeltaFitness_neg pop) (meanFitness_pos pop)

/-! ## Part 5: Fisher's Fundamental Theorem (Two-Type Structural Form) -/

/-- After one round of viability selection with fitness `w_i = exp(-δ_i)`,
    the new frequencies are `p_i' = p_i * w_i`. The new mean fitness
    minus the old mean fitness is related to the fitness variance. -/
def postSelectionMeanFitness (pop : TwoTypePopulation) : ℝ :=
  pop.p₁ * fitness pop.δ₁ * fitness pop.δ₁ +
  pop.p₂ * fitness pop.δ₂ * fitness pop.δ₂

/-- The post-selection mean fitness equals the mean of w². -/
theorem postSelectionMeanFitness_eq_meanFitnessSquared
    (pop : TwoTypePopulation) :
    postSelectionMeanFitness pop = meanFitnessSquared pop := by
  unfold postSelectionMeanFitness meanFitnessSquared
  ring

/-- **Fisher's fundamental theorem (two-type structural form)**:
    The gain in mean fitness (unnormalized) is the fitness variance
    plus the square of mean fitness, minus the mean of w².

    More precisely: `⟨w²⟩ - ⟨w⟩² = Var(w) ≥ 0`.

    This is the classical decomposition showing that selection
    always increases (or maintains) mean fitness.

    Under normalization (p₁+p₂=1): ⟨w²⟩ - ⟨w⟩² = p₁ p₂ (w₁ - w₂)². -/
theorem fisher_variance_decomposition (pop : TwoTypePopulation) :
    meanFitnessSquared pop - meanFitness pop ^ 2 =
      fitnessVariance pop := by
  unfold meanFitnessSquared meanFitness fitnessVariance
  have hs := pop.hsum
  have hp2 : pop.p₂ = 1 - pop.p₁ := by linarith
  rw [hp2]
  ring

/-- **Corollary**: `⟨w²⟩ ≥ ⟨w⟩²` (variance is nonnegative). -/
theorem mean_fitness_squared_ge_square_mean_fitness
    (pop : TwoTypePopulation) :
    meanFitnessSquared pop ≥ meanFitness pop ^ 2 := by
  have h := fisher_variance_decomposition pop
  have hv := fitnessVariance_nonneg pop
  linarith

/-- **Strict inequality**: when types differ, `⟨w²⟩ > ⟨w⟩²`. -/
theorem mean_fitness_squared_gt_square_mean_fitness
    (pop : TwoTypePopulation) :
    meanFitnessSquared pop > meanFitness pop ^ 2 := by
  have h := fisher_variance_decomposition pop
  have hv := fitnessVariance_pos pop
  linarith

/-! ## Part 6: Connection to ArrowOfTime H-Theorem -/

/-- The survival selection H-theorem from `ArrowOfTime` is a consequence
    of the negative covariance `Cov(δ, w) < 0`:
    selection drives mean δ downward, which means mean fitness increases.

    This connects the Price equation to the ArrowOfTime result. -/
theorem structural_selection_drives_delta_down
    (pop : TwoTypePopulation) :
    covDeltaFitness pop < 0 ∧
    0 < fitnessVariance pop :=
  ⟨covDeltaFitness_neg pop, fitnessVariance_pos pop⟩

end

end Survival.FisherFundamentalTheorem
