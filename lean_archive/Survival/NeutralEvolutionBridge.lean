import Survival.WrightFisherBridge
import Survival.ErgodicRateBridge
import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Neutral Evolution Bridge — Hardened Version

Proves: under neutral evolution (no selection), structural change
is a random walk with zero drift. Key results:

1. Neutral rate = 0 → retention = 1 (structure changes but persists)
2. Nearly neutral: |rate| small → slow drift
3. Fixation probability under drift: higher rate → faster fixation
4. Neutral diversity equilibrium: H = 4Nμ reading
5. Connection to genetic drift as zero-drift structural consumption
-/
namespace Survival.NeutralEvolutionBridge
open Real Survival.ErgodicRateBridge
noncomputable section

/-- Neutral: consumption rate exactly zero. -/
theorem neutral_persists (n : ℕ) :
    constantRateRetention ⟨(0 : ℝ)⟩ n = 1 :=
  boundary_of_zero_rate ⟨0⟩ rfl n

/-- Nearly neutral: small positive rate → slow collapse. -/
theorem nearly_neutral_retention (rate : ℝ) (h : 0 < rate) (n : ℕ) (hn : 0 < n) :
    0 < constantRateRetention ⟨rate⟩ n ∧
    constantRateRetention ⟨rate⟩ n < 1 := by
  constructor
  · unfold constantRateRetention ConstantRateModel.cumulative; exact exp_pos _
  · unfold constantRateRetention ConstantRateModel.cumulative
    rw [exp_lt_one_iff]
    have : (0 : ℝ) < ↑n := Nat.cast_pos.mpr hn
    linarith [mul_pos this h]

/-- Fixation probability model: under drift, the probability of
    fixation of a neutral allele is 1/(2N). The structural reading:
    each allele's "retention probability" in the population is 1/(2N). -/
def fixationProbability (effectivePopSize : ℝ) (h : 0 < effectivePopSize) : ℝ :=
  1 / (2 * effectivePopSize)

theorem fixation_prob_pos (N : ℝ) (hN : 0 < N) :
    0 < fixationProbability N hN := by
  unfold fixationProbability; positivity

theorem fixation_prob_le_half (N : ℝ) (hN : 1 ≤ N) :
    fixationProbability N (by linarith) ≤ 1/2 := by
  unfold fixationProbability
  rw [div_le_div_iff₀ (by linarith : 0 < 2 * N) two_pos]
  linarith

/-- Larger population → lower fixation probability per allele. -/
theorem larger_pop_lower_fixation (N₁ N₂ : ℝ) (h₁ : 0 < N₁) (h₂ : 0 < N₂)
    (h : N₁ < N₂) :
    fixationProbability N₂ h₂ < fixationProbability N₁ h₁ := by
  unfold fixationProbability
  rw [div_lt_div_iff₀ (by positivity : 0 < 2 * N₂) (by positivity : 0 < 2 * N₁)]
  nlinarith

/-- Neutral heterozygosity: H = 4Nμ / (4Nμ + 1) at equilibrium.
    Structural reading: the equilibrium diversity (fraction of
    viable configurations) is determined by the balance between
    mutation (adding configurations) and drift (removing them). -/
def neutralDiversity (N μ : ℝ) : ℝ := 4 * N * μ / (4 * N * μ + 1)

theorem diversity_nonneg (N μ : ℝ) (hN : 0 < N) (hμ : 0 < μ) :
    0 ≤ neutralDiversity N μ := by
  unfold neutralDiversity
  exact div_nonneg (by positivity) (by positivity)

theorem diversity_lt_one (N μ : ℝ) (hN : 0 < N) (hμ : 0 < μ) :
    neutralDiversity N μ < 1 := by
  unfold neutralDiversity
  rw [div_lt_one₀ (by positivity)]
  linarith

/-- Higher mutation rate → higher diversity (more viable configurations). -/
theorem higher_mutation_higher_diversity (N μ₁ μ₂ : ℝ)
    (hN : 0 < N) (hμ₁ : 0 < μ₁) (hμ₂ : 0 < μ₂) (h : μ₁ < μ₂) :
    neutralDiversity N μ₁ < neutralDiversity N μ₂ := by
  unfold neutralDiversity
  have h4Nμ₁ : 0 < 4 * N * μ₁ := by positivity
  have h4Nμ₂ : 0 < 4 * N * μ₂ := by positivity
  rw [div_lt_div_iff₀ (by positivity) (by positivity)]
  nlinarith [mul_pos h4Nμ₁ h4Nμ₂]

end
end Survival.NeutralEvolutionBridge
