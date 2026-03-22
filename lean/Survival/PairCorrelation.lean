/-
Pair Correlation for Random 3-SAT — Formal Verification
ランダム3-SATのペア相関関数 — 形式的検証

For two Boolean assignments σ, τ at Hamming distance d on n variables:
n変数上のハミング距離dにある2つのブール割当σ, τについて:

  - A random 3-clause selects 3 variables uniformly
    ランダム3節は3変数を一様に選択
  - j of these 3 variables fall in the disagreement set D (|D| = d)
    3変数のうちj個が不一致集合D (|D| = d) に含まれる
  - j = 0 ⟹ P(both satisfy) = 7/8 (they agree on all selected variables)
    j = 0 ⟹ 両方充足する確率 = 7/8
  - j ≥ 1 ⟹ P(both satisfy) = 3/4 (failure patterns differ)
    j ≥ 1 ⟹ 両方充足する確率 = 3/4

The pair correlation function:
ペア相関関数:
    g(β) = (7/8)(1-β)³ + (3/4)(1 - (1-β)³)
         = 3/4 + (1/8)(1-β)³
where β = d/n ∈ [0,1].

References:
- Achlioptas, D. (2009). Random satisfiability. Ch.8 in
  Handbook of Satisfiability, IOS Press.
- Mézard, M. & Montanari, A. (2009). Information, Physics,
  and Computation. Oxford University Press.
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Survival.Basic
import Survival.SATFirstMoment

open Finset BigOperators

namespace Survival.PairCorrelation

/-! ## Part 1: Definitions — Pair Correlation Function
    定義 — ペア相関関数 -/

/-- Pair correlation function for random 3-SAT.
    ランダム3-SATのペア相関関数.

    g(β) = 3/4 + (1/8)(1-β)³
    where β = d/n is the fractional Hamming distance.
    βは正規化ハミング距離 d/n. -/
noncomputable def g (β : ℝ) : ℝ := 3/4 + (1/8) * (1 - β)^3

/-- The expanded form before simplification.
    簡約前の展開形.
    g_expanded(β) = (7/8)(1-β)³ + (3/4)(1 - (1-β)³) -/
noncomputable def g_expanded (β : ℝ) : ℝ :=
  (7/8) * (1 - β)^3 + (3/4) * (1 - (1 - β)^3)

/-! ## Part 2: Equivalence of Forms
    両形式の等価性 -/

/-- The expanded form equals the simplified form.
    展開形と簡約形は等しい. -/
theorem g_eq_g_expanded (β : ℝ) : g β = g_expanded β := by
  unfold g g_expanded
  ring

/-! ## Part 3: Boundary Values
    境界値 -/

/-- At distance 0: g(0) = 7/8 (reduces to single-assignment probability).
    距離0: 単一割当の充足確率に帰着. -/
theorem g_at_zero : g 0 = 7/8 := by
  unfold g
  norm_num

/-- At maximum distance: g(1) = 3/4.
    最大距離: g(1) = 3/4. -/
theorem g_at_one : g 1 = 3/4 := by
  unfold g
  norm_num

/-- At half distance: g(1/2) = 49/64.
    半分の距離: g(1/2) = 49/64. -/
theorem g_at_half : g (1/2 : ℝ) = 49/64 := by
  unfold g
  norm_num

/-! ## Part 4: Bounds on g
    gの上下界 -/

/-- Auxiliary: (1-β)³ ≥ 0 when 0 ≤ β ≤ 1.
    補助: 0 ≤ β ≤ 1 のとき (1-β)³ ≥ 0. -/
lemma one_sub_pow_nonneg {β : ℝ} (_h0 : 0 ≤ β) (h1 : β ≤ 1) :
    (0 : ℝ) ≤ (1 - β)^3 := by
  apply pow_nonneg
  linarith

/-- Auxiliary: (1-β)³ ≤ 1 when 0 ≤ β ≤ 1.
    補助: 0 ≤ β ≤ 1 のとき (1-β)³ ≤ 1. -/
lemma one_sub_pow_le_one {β : ℝ} (h0 : 0 ≤ β) (h1 : β ≤ 1) :
    (1 - β)^3 ≤ 1 := by
  apply pow_le_one₀
  · linarith
  · linarith

/-- g(β) > 0 for β ∈ [0,1].
    g(β) は [0,1] 上で正. -/
theorem g_pos {β : ℝ} (h0 : 0 ≤ β) (h1 : β ≤ 1) :
    0 < g β := by
  unfold g
  have h := one_sub_pow_nonneg h0 h1
  nlinarith

/-- g(β) ≥ 3/4 for β ∈ [0,1].
    g(β) ≥ 3/4 (下界). -/
theorem g_ge_three_quarters {β : ℝ} (h0 : 0 ≤ β) (h1 : β ≤ 1) :
    3/4 ≤ g β := by
  unfold g
  have h := one_sub_pow_nonneg h0 h1
  nlinarith

/-- g(β) ≤ 7/8 for β ∈ [0,1].
    g(β) ≤ 7/8 (上界). -/
theorem g_le_seven_eighths {β : ℝ} (h0 : 0 ≤ β) (h1 : β ≤ 1) :
    g β ≤ 7/8 := by
  unfold g
  have h := one_sub_pow_le_one h0 h1
  nlinarith

/-! ## Part 5: Monotonicity
    単調性 -/

/-- g is (weakly) monotonically decreasing on [0,1]:
    more disagreement → lower joint satisfaction probability.
    gは[0,1]上で単調減少: 不一致が増えると共同充足確率が下がる.

    Proof strategy: for β₁ ≤ β₂, we have (1-β₁) ≥ (1-β₂) ≥ 0,
    so (1-β₁)³ ≥ (1-β₂)³, and thus g(β₁) ≥ g(β₂).
    証明方針: β₁ ≤ β₂ ならば (1-β₁) ≥ (1-β₂) ≥ 0 で
    (1-β₁)³ ≥ (1-β₂)³ から g(β₁) ≥ g(β₂). -/
theorem g_antitone {β₁ β₂ : ℝ}
    (_h0₁ : 0 ≤ β₁) (h1₂ : β₂ ≤ 1) (hle : β₁ ≤ β₂) :
    g β₂ ≤ g β₁ := by
  unfold g
  have h_ge : (1 - β₁) ≥ (1 - β₂) := by linarith
  have h_nn : 0 ≤ 1 - β₂ := by linarith
  have h_cube : (1 - β₂)^3 ≤ (1 - β₁)^3 := by
    exact pow_le_pow_left₀ h_nn h_ge 3
  nlinarith

/-- Strictly decreasing when β₁ < β₂ (both in [0,1]).
    β₁ < β₂ のとき狭義単調減少. -/
theorem g_strictAnti {β₁ β₂ : ℝ}
    (_h0₁ : 0 ≤ β₁) (h1₂ : β₂ ≤ 1) (hlt : β₁ < β₂) :
    g β₂ < g β₁ := by
  unfold g
  have h_gt : (1 - β₁) > (1 - β₂) := by linarith
  have h_nn : 0 ≤ 1 - β₂ := by linarith
  have h_nn₁ : 0 ≤ 1 - β₁ := by linarith
  -- (1-β₁)³ > (1-β₂)³ since 0 ≤ (1-β₂) < (1-β₁) and exponent is odd
  have h_cube : (1 - β₂)^3 < (1 - β₁)^3 := by
    have h_sq₂ : (1 - β₂)^2 ≤ (1 - β₁)^2 := by nlinarith
    have h_sq₂_nn : 0 ≤ (1 - β₂)^2 := sq_nonneg _
    have h1_nn : 0 ≤ (1 - β₁) := by linarith
    -- (1-β₂)³ = (1-β₂)² · (1-β₂) ≤ (1-β₁)² · (1-β₂) < (1-β₁)² · (1-β₁) = (1-β₁)³
    calc (1 - β₂)^3 = (1 - β₂)^2 * (1 - β₂) := by ring
      _ ≤ (1 - β₁)^2 * (1 - β₂) := by nlinarith
      _ < (1 - β₁)^2 * (1 - β₁) := by
          have h_sq_pos : 0 < (1 - β₁)^2 := by
            apply sq_pos_of_pos; linarith
          nlinarith
      _ = (1 - β₁)^3 := by ring
  nlinarith

/-! ## Part 6: Connection to First Moment
    第一モーメントとの関係 -/

/-- g(0) equals the single-clause satisfaction probability 7/8.
    g(0) は単一節の充足確率 7/8 に等しい.
    This connects the pair correlation to the first moment method.
    ペア相関と第一モーメント法を結ぶ. -/
theorem g_zero_eq_first_moment :
    g 0 = 7/8 := g_at_zero

/-- The ratio g(0)/(7/8)² = 8/7 > 1.
    比 g(0)/(7/8)² = 8/7 > 1.
    This means the d=0 contribution to E[X²]/E[X]² exceeds 1,
    which is the source of variance in the second moment.
    d=0の寄与がE[X²]/E[X]²で1を超え、第二モーメントの分散源となる. -/
theorem g_zero_ratio :
    g 0 / (7/8 : ℝ)^2 = 8/7 := by
  rw [g_at_zero]
  norm_num

/-- The ratio g(0)/(7/8)² is strictly greater than 1.
    g(0)/(7/8)² は1より厳密に大きい. -/
theorem g_zero_ratio_gt_one :
    g 0 / (7/8 : ℝ)^2 > 1 := by
  rw [g_zero_ratio]
  norm_num

/-! ## Part 7: Multi-Clause Extension
    複数節への拡張 -/

/-- For m independent random 3-clauses, the joint probability that both σ and τ
    satisfy all clauses at distance d is g(d/n)^m.
    m個の独立なランダム3節について、距離dのσとτが全節を充足する確率は g(d/n)^m.

    This is the direct consequence of clause independence.
    節の独立性の直接的帰結. -/
noncomputable def pairSatProb (β : ℝ) (m : ℕ) : ℝ := (g β) ^ m

/-- pairSatProb at m=0 is 1 (vacuous truth).
    m=0のとき1（空真）. -/
theorem pairSatProb_zero_clauses (β : ℝ) :
    pairSatProb β 0 = 1 := by
  unfold pairSatProb
  simp

/-- pairSatProb at m=1 reduces to g(β).
    m=1のとき g(β) に帰着. -/
theorem pairSatProb_one_clause (β : ℝ) :
    pairSatProb β 1 = g β := by
  unfold pairSatProb
  simp

/-- pairSatProb is positive for β ∈ [0,1].
    β ∈ [0,1] のとき pairSatProb は正. -/
theorem pairSatProb_pos {β : ℝ} (h0 : 0 ≤ β) (h1 : β ≤ 1) (m : ℕ) :
    0 < pairSatProb β m := by
  unfold pairSatProb
  exact pow_pos (g_pos h0 h1) m

/-! ## Part 8: Information Loss Interpretation
    情報損失の解釈 -/

/-- Per-clause pair information loss: -ln g(β).
    1節あたりのペア情報損失: -ln g(β).
    This quantifies how much information a single clause provides
    about the joint satisfiability of two assignments at distance β.
    距離βの2つの割当の共同充足可能性について1節が与える情報量. -/
noncomputable def pairInfoLoss (β : ℝ) : ℝ := -Real.log (g β)

/-- Pair info loss is non-negative for β ∈ [0,1].
    ペア情報損失は [0,1] 上で非負. -/
theorem pairInfoLoss_nonneg {β : ℝ} (h0 : 0 ≤ β) (h1 : β ≤ 1) :
    0 ≤ pairInfoLoss β := by
  unfold pairInfoLoss
  have hg_pos := g_pos h0 h1
  have hg_le := g_le_seven_eighths h0 h1
  have hg_le_one : g β ≤ 1 := by linarith
  linarith [Real.log_nonpos (le_of_lt hg_pos) hg_le_one]

/-- At β=0, pair info loss equals the single-assignment info loss ln(8/7).
    β=0のとき、ペア情報損失は単一割当の情報損失 ln(8/7) に等しい. -/
theorem pairInfoLoss_at_zero :
    pairInfoLoss 0 = Real.log (8/7 : ℝ) := by
  unfold pairInfoLoss
  rw [g_at_zero]
  have h_inv : (7/8 : ℝ) = (8/7 : ℝ)⁻¹ := by norm_num
  rw [h_inv, Real.log_inv, neg_neg]

/-- Connection: pairInfoLoss at 0 equals the first moment's info loss per clause.
    関連: β=0でのペア情報損失は第一モーメントの1節あたり情報損失に等しい. -/
theorem pairInfoLoss_zero_eq_first_moment_info :
    pairInfoLoss 0 = Survival.SATFirstMoment.infoLoss (7/8 : ℝ) := by
  rw [pairInfoLoss_at_zero]
  unfold Survival.SATFirstMoment.infoLoss
  have h_inv : (7/8 : ℝ) = (8/7 : ℝ)⁻¹ := by norm_num
  rw [h_inv, Real.log_inv, neg_neg]

/-! ## Part 9: Algebraic Identities for Specific β Values
    特定β値の代数的恒等式 -/

/-- g(1/4) = 111/128.
    Proof: (1 - 1/4)³ = (3/4)³ = 27/64, so g = 3/4 + 27/512 = 411/512.
    Actually: g(1/4) = 3/4 + (1/8)(3/4)³ = 3/4 + 27/512 = 384/512 + 27/512 = 411/512. -/
theorem g_at_quarter : g (1/4 : ℝ) = 411/512 := by
  unfold g
  norm_num

/-- g(3/4) = 49/512.
    Wait: g(3/4) = 3/4 + (1/8)(1/4)³ = 3/4 + 1/512 = 384/512 + 1/512 = 385/512. -/
theorem g_at_three_quarters : g (3/4 : ℝ) = 385/512 := by
  unfold g
  norm_num

/-! ## Part 10: Composition with Exponential — Second Moment Contribution
    指数関数との合成 — 第二モーメント寄与 -/

/-- For m clauses at ratio α = m/n, the pair probability at distance β is
    g(β)^m = exp(m · ln g(β)) = exp(-m · pairInfoLoss(β)).
    比率 α = m/n のm節について、距離βでのペア確率は
    g(β)^m = exp(m · ln g(β)) = exp(-m · pairInfoLoss(β)). -/
theorem pairSatProb_exp {β : ℝ} (h0 : 0 ≤ β) (h1 : β ≤ 1) (m : ℕ) :
    pairSatProb β m = Real.exp (↑m * Real.log (g β)) := by
  unfold pairSatProb
  have hg_pos := g_pos h0 h1
  rw [← Real.exp_log (pow_pos hg_pos m)]
  congr 1
  rw [Real.log_pow]

/-- Alternative expression using pairInfoLoss.
    pairInfoLossを使った代替表現. -/
theorem pairSatProb_via_infoLoss {β : ℝ} (h0 : 0 ≤ β) (h1 : β ≤ 1) (m : ℕ) :
    pairSatProb β m = Real.exp (-(↑m * pairInfoLoss β)) := by
  rw [pairSatProb_exp h0 h1]
  unfold pairInfoLoss
  ring_nf

end Survival.PairCorrelation
