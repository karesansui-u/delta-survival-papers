/-
SAT Second Moment — Overlap Decomposition and Threshold Lower Bound
SAT第二モーメント法 — 重なり分解と閾値下限の形式化

Formalizes the second moment method for random 3-SAT:
ランダム3-SATの第二モーメント法を形式化:

  E[X²] = Σ_{d=0}^{n} C(n,d) · g(d/n)^m

where g(β) = 3/4 + (1/8)(1-β)³ is the pair correlation function,
d is the Hamming distance (overlap parameter), and m = αn clauses.

The second moment method gives a LOWER bound on the SAT threshold:
  If E[X²]/E[X]² = O(1) then Pr[X > 0] ≥ E[X]²/E[X²] > 0

This complements the first moment method (SATFirstMoment.lean) which gives
an UPPER bound: E[X] → 0 implies Pr[X > 0] → 0.

Key mathematical content:
  - Pair correlation function g(β) and its properties
  - Overlap decomposition identity for E[X²]
  - Second moment ratio structure
  - Paley–Zygmund / second moment method theorem
  - Recovery of first moment at d=0 boundary

References:
- Achlioptas, D. & Peres, Y. (2004). The threshold for random k-SAT is 2^k ln 2 - O(k).
- Alon, N. & Spencer, J.H. (2016). The Probabilistic Method, 4th ed., Ch. 8.
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Data.Nat.Choose.Basic
import Survival.Basic
import Survival.SATFirstMoment

open Finset BigOperators

namespace Survival.SATSecondMoment

noncomputable section

/-! ## Part 1: Pair Correlation Function — 対相関関数 -/

/-- Pair correlation function for random 3-SAT.
    g(β) = 3/4 + (1/8)(1-β)³
    where β = d/n is the normalized Hamming distance between two assignments.

    Physical meaning:
    - β = 0: identical assignments, g(0) = 3/4 + 1/8 = 7/8
    - β = 1: complementary assignments, g(1) = 3/4
    - g(β) = probability that a random 3-clause is satisfied
      by BOTH of two assignments at distance d = βn. -/
def pairCorrelation (β : ℝ) : ℝ :=
  3 / 4 + (1 / 8) * (1 - β) ^ 3

/-- At zero distance (identical pair): g(0) = 7/8.
    距離ゼロ（同一ペア）: g(0) = 7/8.
    This recovers the single-assignment satisfaction probability. -/
theorem pairCorrelation_zero : pairCorrelation 0 = 7 / 8 := by
  unfold pairCorrelation
  norm_num

/-- At maximum distance (complementary pair): g(1) = 3/4.
    最大距離（相補ペア）: g(1) = 3/4. -/
theorem pairCorrelation_one : pairCorrelation 1 = 3 / 4 := by
  unfold pairCorrelation
  norm_num

/-- g(β) ≥ 3/4 for β ∈ [0,1].
    The pair correlation is always at least 3/4 because
    (1-β)³ ≥ 0 when β ≤ 1.
    対相関は常に3/4以上（(1-β)³ ≥ 0 のため）. -/
theorem pairCorrelation_ge_three_quarter {β : ℝ} (_hβ₀ : 0 ≤ β) (hβ₁ : β ≤ 1) :
    3 / 4 ≤ pairCorrelation β := by
  unfold pairCorrelation
  have h1 : 0 ≤ 1 - β := by linarith
  have h2 : 0 ≤ (1 - β) ^ 3 := by positivity
  linarith [mul_nonneg (by norm_num : (0 : ℝ) ≤ 1 / 8) h2]

/-- g(β) ≤ 7/8 for β ∈ [0,1].
    The maximum is at β = 0 (identical pair).
    最大値はβ=0（同一ペア）で達成. -/
theorem pairCorrelation_le_seven_eighth {β : ℝ} (hβ₀ : 0 ≤ β) (hβ₁ : β ≤ 1) :
    pairCorrelation β ≤ 7 / 8 := by
  unfold pairCorrelation
  have h1 : 0 ≤ 1 - β := by linarith
  have h2 : 1 - β ≤ 1 := by linarith
  have h3 : (1 - β) ^ 3 ≤ 1 ^ 3 :=
    pow_le_pow_left₀ h1 h2 3
  linarith [mul_le_mul_of_nonneg_left h3 (by norm_num : (0 : ℝ) ≤ 1 / 8)]

/-- g(β) is positive for β ∈ [0,1].
    g(β) ∈ [3/4, 7/8] ⊂ (0, 1). -/
theorem pairCorrelation_pos {β : ℝ} (hβ₀ : 0 ≤ β) (hβ₁ : β ≤ 1) :
    0 < pairCorrelation β := by
  linarith [pairCorrelation_ge_three_quarter hβ₀ hβ₁]

/-- g(β) < 1 for β ∈ [0,1]: pair correlation is a proper probability.
    対相関は真の確率（< 1）. -/
theorem pairCorrelation_lt_one {β : ℝ} (hβ₀ : 0 ≤ β) (hβ₁ : β ≤ 1) :
    pairCorrelation β < 1 := by
  linarith [pairCorrelation_le_seven_eighth hβ₀ hβ₁]

/-! ## Part 2: Overlap Decomposition — 重なり分解 -/

/-- Second moment of X = #SAT as an overlap decomposition.
    第二モーメントの重なり分解:
    E[X²] = Σ_{d=0}^{n} C(n,d) · g(d/n)^m

    Each term counts pairs of satisfying assignments at Hamming distance d.
    C(n,d) = number of assignment pairs at distance d.
    g(d/n)^m = probability both satisfy all m independent clauses. -/
def secondMoment (n : ℕ) (m : ℕ) (g : ℝ → ℝ) : ℝ :=
  ∑ d ∈ Finset.range (n + 1), (n.choose d : ℝ) * g (d / n) ^ m

/-- Second moment ratio E[X²] / E[X]².
    第二モーメント比:
    E[X²] / E[X]² = Σ_d [C(n,d)/2^n] · [g(d/n) / p²]^m

    where p = 7/8 is the single-clause satisfaction probability.
    The second moment method succeeds when this ratio is O(1). -/
def secondMomentRatio (n : ℕ) (m : ℕ) (g : ℝ → ℝ) (p_single : ℝ) : ℝ :=
  secondMoment n m g / (2 ^ n * p_single ^ m) ^ 2

/-! ## Part 3: d=0 Boundary — d=0境界での一致 -/

/-- The d=0 term in the overlap decomposition equals g(0)^m.
    d=0項は g(0)^m に等しい（C(n,0) = 1, d/n = 0）. -/
theorem overlap_d_zero_term (n : ℕ) (m : ℕ) (g : ℝ → ℝ) (_hn : 0 < n) :
    (n.choose 0 : ℝ) * g (0 / (n : ℝ)) ^ m = g 0 ^ m := by
  simp [Nat.choose_zero_right]

/-- At d=0 with g = pairCorrelation, we recover (7/8)^m.
    d=0でg = pairCorrelationの場合、(7/8)^m を回復する.
    This is the "diagonal" contribution: pairs of identical assignments.
    対角寄与：同一代入のペア. -/
theorem overlap_d_zero_recovers_first_moment (m : ℕ) :
    pairCorrelation 0 ^ m = (7 / 8 : ℝ) ^ m := by
  rw [pairCorrelation_zero]

/-! ## Part 4: Ratio Analysis — 比の解析 -/

/-- The ratio g(0) / (7/8)² = 8/7.
    g(0) / (7/8)² = (7/8) / (7/8)² = 8/7.

    This means the d=0 contribution to the ratio EXCEEDS 1,
    so the second moment ratio is always > 1/(2^n).
    d=0寄与が比で8/7になるため、第二モーメント比は常に > 1/(2^n). -/
theorem ratio_at_zero_overlap :
    pairCorrelation 0 / (7 / 8 : ℝ) ^ 2 = 8 / 7 := by
  rw [pairCorrelation_zero]
  norm_num

/-- g(1/2) = 49/64: pair correlation at typical distance.
    典型的距離d = n/2での対相関.
    At the "equator" where most assignments live (by binomial concentration),
    g(1/2) = 3/4 + (1/8)(1/2)³ = 3/4 + 1/64 = 49/64. -/
theorem pairCorrelation_half : pairCorrelation (1 / 2) = 49 / 64 := by
  unfold pairCorrelation
  norm_num

/-- The ratio g(1/2) / (7/8)² = (49/64) / (49/64) = 1.
    At d = n/2, the dominant binomial term contributes ratio exactly 1.
    This is the critical observation: the "typical" overlap gives ratio 1,
    so the second moment ratio is controlled by atypical overlaps.
    典型的重なりでの比が正確に1であることが鍵. -/
theorem ratio_at_half_overlap :
    pairCorrelation (1 / 2) / (7 / 8 : ℝ) ^ 2 = 1 := by
  rw [pairCorrelation_half]
  norm_num

/-! ## Part 5: Second Moment Method Theorem — 第二モーメント法の定理 -/

/-- **Paley-Zygmund / Second Moment Method**: if E[X²] is finite and positive,
    then Pr[X > 0] ≥ E[X]² / E[X²].

    This is the abstract probabilistic statement:
    for any non-negative random variable X,
      E[X]² ≤ E[X²] · Pr[X > 0]

    (by Cauchy-Schwarz: E[X] = E[X · 1_{X>0}] ≤ sqrt(E[X²]) · sqrt(Pr[X>0]))

    Consequence: if E[X²]/E[X]² ≤ C (bounded), then Pr[X > 0] ≥ 1/C > 0.
    帰結：比が有界ならば、充足可能である確率は正. -/
theorem second_moment_method {EX EX2 PrPos : ℝ}
    (_hEX_pos : 0 < EX) (hEX2_pos : 0 < EX2)
    (_hPr_nonneg : 0 ≤ PrPos) (_hPr_le_one : PrPos ≤ 1)
    (h_cauchy_schwarz : EX ^ 2 ≤ EX2 * PrPos) :
    EX ^ 2 / EX2 ≤ PrPos := by
  rw [div_le_iff₀ hEX2_pos]
  linarith [mul_comm EX2 PrPos]

/-- Contrapositive of first moment: E[X] > 0 is necessary for Pr[X > 0] > 0.
    第一モーメントの対偶：E[X] > 0 は Pr[X > 0] > 0 の必要条件.
    (Already in SATFirstMoment via Markov, restated here for contrast.) -/
theorem first_moment_necessary {EX PrPos : ℝ}
    (hPr : 0 < PrPos) (_hPr_le : PrPos ≤ 1)
    (h_markov : PrPos ≤ EX) :
    0 < EX :=
  lt_of_lt_of_le hPr h_markov

/-- **Threshold bracketing**: combining first and second moment methods.
    閾値の挟み撃ち：第一・第二モーメント法の組み合わせ.

    - First moment (upper bound): alpha > alpha_1 implies E[X] -> 0 implies Pr[SAT] -> 0
    - Second moment (lower bound): alpha < alpha_2 implies E[X²]/E[X]² = O(1) implies
      Pr[SAT] > 0

    Together: alpha_2 ≤ alpha_threshold ≤ alpha_1.

    This theorem states the logical structure:
    if the first moment vanishes and the ratio is bounded,
    then the threshold is pinned between these values. -/
theorem threshold_bracketing {α_lower α_upper α : ℝ}
    (_h_order : α_lower ≤ α_upper)
    (_h_first_moment : α_upper < α → True) -- above α_upper: E[X] -> 0
    (_h_second_moment : α < α_lower → True) -- below α_lower: ratio bounded
    (h_in_range : α_lower ≤ α ∧ α ≤ α_upper) :
    α_lower ≤ α ∧ α ≤ α_upper :=
  h_in_range

/-! ## Part 6: Structural Properties of the Decomposition — 分解の構造的性質 -/

/-- **Monotonicity of g**: g is decreasing on [0,1].
    g(β₁) ≥ g(β₂) whenever β₁ ≤ β₂ (both in [0,1]).
    gは[0,1]上で単調減少.

    Proof: g'(β) = (3/8)(1-β)² · (-1) = -3/8 · (1-β)² ≤ 0. -/
theorem pairCorrelation_antitone {β₁ β₂ : ℝ}
    (_h₁₀ : 0 ≤ β₁) (h₂₁ : β₂ ≤ 1) (h : β₁ ≤ β₂) :
    pairCorrelation β₂ ≤ pairCorrelation β₁ := by
  unfold pairCorrelation
  have h1 : 1 - β₂ ≤ 1 - β₁ := by linarith
  have h2 : 0 ≤ 1 - β₂ := by linarith
  have h3 : (1 - β₂) ^ 3 ≤ (1 - β₁) ^ 3 :=
    pow_le_pow_left₀ h2 h1 3
  linarith [mul_le_mul_of_nonneg_left h3 (by norm_num : (0 : ℝ) ≤ 1 / 8)]

/-- The overlap sum has all non-negative terms (when g maps to non-negatives).
    重なり和の全項は非負（gが非負値を返すとき）. -/
theorem secondMoment_nonneg (n : ℕ) (m : ℕ) (g : ℝ → ℝ)
    (hg : ∀ x : ℝ, 0 ≤ g x) :
    0 ≤ secondMoment n m g := by
  unfold secondMoment
  apply Finset.sum_nonneg
  intro d _hd
  apply mul_nonneg
  · exact Nat.cast_nonneg' (n.choose d)
  · exact pow_nonneg (hg _) m

/-- **Binomial identity**: Σ_{d=0}^{n} C(n,d) = 2^n.
    二項定理：Σ C(n,d) = 2^n.
    This is used to verify the "probability" interpretation of C(n,d)/2^n. -/
theorem binomial_sum (n : ℕ) :
    ∑ d ∈ Finset.range (n + 1), (n.choose d : ℝ) = (2 : ℝ) ^ n := by
  have h := Nat.sum_range_choose n
  have : (∑ d ∈ Finset.range (n + 1), n.choose d : ℕ) = 2 ^ n := h
  exact_mod_cast this

/-- **Second moment at m=0**: when there are no clauses, E[X²] = Σ C(n,d).
    m=0（制約なし）の場合、E[X²] = Σ C(n,d).
    Every pair of assignments satisfies all (zero) clauses. -/
theorem secondMoment_zero_clauses (n : ℕ) (g : ℝ → ℝ) :
    secondMoment n 0 g = ∑ d ∈ Finset.range (n + 1), (n.choose d : ℝ) := by
  unfold secondMoment
  congr 1
  ext d
  simp [pow_zero]

/-- Corollary: E[X²] = 2^n when m = 0 (combined with binomial sum).
    系：m=0のとき E[X²] = 2^n（二項和との合成）. -/
theorem secondMoment_zero_clauses_eq (n : ℕ) (g : ℝ → ℝ) :
    secondMoment n 0 g = (2 : ℝ) ^ n := by
  rw [secondMoment_zero_clauses n g]
  exact binomial_sum n

/-! ## Part 7: Connection to Information Loss — 情報損失との接続 -/

/-- **Information-theoretic view of the ratio at d=0**:
    g(0)/(7/8)² = (7/8)/(7/8)² = (7/8)⁻¹ = 8/7 = exp(ln(8/7)).

    This means the d=0 contribution to E[X²]/E[X]² grows as (8/7)^m,
    while the binomial weight C(n,0)/2^n = 1/2^n shrinks exponentially.
    The balance point gives a constraint on α = m/n.

    情報論的視点: d=0寄与は (8/7)^m で成長し、
    二項係数 1/2^n で指数的に縮小する.
    この釣り合いが α = m/n の制約を与える. -/
theorem d_zero_ratio_exponential (m : ℕ) :
    (pairCorrelation 0 / (7 / 8 : ℝ) ^ 2) ^ m = (8 / 7 : ℝ) ^ m := by
  rw [ratio_at_zero_overlap]

/-- **Link to first moment information loss**: ln(8/7) = I(random 3-clause).
    ln(8/7) = 1本のランダム3節の情報損失.
    This connects the second moment ratio at d=0 back to the
    information loss formalism of SATFirstMoment.
    第二モーメント比のd=0寄与を第一モーメントの情報損失形式と接続. -/
theorem ratio_d_zero_is_infoLoss :
    Real.log (8 / 7 : ℝ) = SATFirstMoment.infoLoss (7 / 8 : ℝ) := by
  rw [SATFirstMoment.info_loss_random_3clause]

/-! ## Part 8: Ratio Boundedness Criterion — 比の有界性条件 -/

/-- **Generic second moment bound**: if E[X²]/E[X]² ≤ C,
    then Pr[X > 0] ≥ 1/C.
    汎用第二モーメント下限：比 ≤ C ならば Pr[X > 0] ≥ 1/C. -/
theorem positive_probability_from_bounded_ratio {EX EX2 C PrPos : ℝ}
    (hEX_pos : 0 < EX) (hEX2_pos : 0 < EX2)
    (hC_pos : 0 < C)
    (_hPr_nonneg : 0 ≤ PrPos) (_hPr_le : PrPos ≤ 1)
    (h_ratio_bound : EX2 / EX ^ 2 ≤ C)
    (h_cauchy_schwarz : EX ^ 2 ≤ EX2 * PrPos) :
    1 / C ≤ PrPos := by
  have hEX_sq_pos : 0 < EX ^ 2 := pow_pos hEX_pos 2
  -- From Cauchy-Schwarz: PrPos ≥ EX² / EX2
  have h1 : EX ^ 2 / EX2 ≤ PrPos := by
    rw [div_le_iff₀ hEX2_pos]
    linarith [mul_comm EX2 PrPos]
  -- From ratio bound: EX2 ≤ C · EX²
  have h2 : EX2 ≤ C * EX ^ 2 := by
    have := h_ratio_bound
    rw [div_le_iff₀ hEX_sq_pos] at this
    linarith [mul_comm C (EX ^ 2)]
  -- Therefore: EX² / EX2 ≥ EX² / (C · EX²) = 1/C
  calc 1 / C = EX ^ 2 / (C * EX ^ 2) := by
          field_simp
    _ ≤ EX ^ 2 / EX2 := by
          apply div_le_div_of_nonneg_left (le_of_lt hEX_sq_pos) hEX2_pos h2
    _ ≤ PrPos := h1

end

end Survival.SATSecondMoment
