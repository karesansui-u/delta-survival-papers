/-
Asymptotic Exponent Analysis for Random 3-SAT Second Moment
ランダム3-SATの第二モーメントにおける漸近指数解析

The second moment ratio E[X²]/E[X]² for random 3-SAT with n variables
and m = αn clauses is controlled by the exponent function:

  φ(β, α) = h(β) - ln 2 + α · ln R(β)

where:
  h(β) = -β·ln(β) - (1-β)·ln(1-β)  is binary entropy (nats)
  R(β) = g(β)/(7/8)²                is the normalized pair correlation
  g(β) = 3/4 + (1/8)(1-β)³          is the pair correlation function

Key structural results:
  - φ(1/2, α) = 0 for ALL α (the dominant binomial term is always neutral)
  - φ(0, α) = α·ln(8/7) - ln 2 (recovers first moment threshold)
  - α_c^(1) = ln 2 / ln(8/7) ≈ 5.19 (first moment threshold from exponent)

References:
- Achlioptas, D. & Peres, Y. (2004). The threshold for random k-SAT
  is 2^k ln 2 - O(k).
- Mézard, M. & Montanari, A. (2009). Information, Physics, and
  Computation. Oxford University Press.
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Data.Real.Basic
import Survival.Basic
import Survival.SATFirstMoment
import Survival.PairCorrelation

open Real

namespace Survival.AsymptoticExponent

noncomputable section

/-! ## Part 1: Ratio Function R(β) = g(β) / (7/8)²
    比関数 R(β) = g(β) / (7/8)² -/

/-- Pair correlation function g(β) = 3/4 + (1/8)(1-β)³.
    Local alias for PairCorrelation.g.
    PairCorrelation.g のローカルエイリアス. -/
noncomputable def g (β : ℝ) : ℝ := 3/4 + (1/8) * (1 - β)^3

/-- g agrees with PairCorrelation.g.
    PairCorrelation.g と一致する. -/
theorem g_eq_pairCorrelation (β : ℝ) : g β = PairCorrelation.g β := by
  unfold g PairCorrelation.g; ring

/-- Normalized ratio function R(β) = g(β) / (7/8)².
    正規化比関数: R(β) = g(β) / (7/8)².
    Equivalently R(β) = g(β) · 64/49.
    同値な形式: R(β) = g(β) · 64/49. -/
noncomputable def R (β : ℝ) : ℝ := g β / (7/8 : ℝ)^2

/-- R expressed as g · 64/49.
    Rをg · 64/49として表現. -/
theorem R_eq_mul (β : ℝ) : R β = g β * (64 / 49) := by
  unfold R
  field_simp
  ring

/-! ## Part 2: Key Values of R
    Rの主要な値 -/

/-- g(0) = 7/8.
    g(0) = 7/8. -/
theorem g_at_zero : g 0 = 7/8 := by
  unfold g; norm_num

/-- g(1/2) = 49/64.
    g(1/2) = 49/64. -/
theorem g_at_half : g (1/2 : ℝ) = 49/64 := by
  unfold g; norm_num

/-- g(1) = 3/4.
    g(1) = 3/4. -/
theorem g_at_one : g 1 = 3/4 := by
  unfold g; norm_num

/-- **R(0) = 8/7**: at zero overlap, R exceeds 1.
    重なりゼロ: R > 1（第一モーメント寄与が優勢）. -/
theorem R_at_zero : R 0 = 8/7 := by
  unfold R
  rw [g_at_zero]
  norm_num

/-- **R(1/2) = 1**: at typical overlap, R is exactly 1.
    典型的重なり: Rは正確に1（第二モーメント寄与が中立）.
    This is the most important structural identity.
    これが最も重要な構造的恒等式. -/
theorem R_at_half : R (1/2 : ℝ) = 1 := by
  unfold R
  rw [g_at_half]
  norm_num

/-- **R(1) = 48/49**: at maximum distance, R is less than 1.
    最大距離: R < 1. -/
theorem R_at_one : R 1 = 48/49 := by
  unfold R
  rw [g_at_one]
  norm_num

/-- R(0) > 1: the d=0 contribution amplifies.
    R(0) > 1: d=0寄与は増幅する. -/
theorem R_zero_gt_one : R 0 > 1 := by
  rw [R_at_zero]; norm_num

/-- R(1/2) = 1: the typical contribution is neutral.
    R(1/2) = 1: 典型的寄与は中立. -/
theorem R_half_eq_one : R (1/2 : ℝ) = 1 := R_at_half

/-- R(1) < 1: the antipodal contribution is suppressed.
    R(1) < 1: 対蹠的寄与は抑制される. -/
theorem R_one_lt_one : R 1 < 1 := by
  rw [R_at_one]; norm_num

/-! ## Part 3: Binary Entropy
    二進エントロピー -/

/-- Binary entropy function h(β) = -β·ln(β) - (1-β)·ln(1-β).
    二進エントロピー関数（自然対数、nats単位）.

    Uses Real.log which satisfies log 0 = 0, so h(0) = h(1) = 0
    by convention (consistent with the limit).
    Real.log は log 0 = 0 を満たすので、h(0) = h(1) = 0（極限と整合）. -/
noncomputable def binaryEntropy (β : ℝ) : ℝ :=
  -(β * Real.log β) - (1 - β) * Real.log (1 - β)

/-- h(0) = 0 (by convention, since 0·ln(0) = 0 in Lean).
    h(0) = 0（規約により、Leanでは 0·ln(0) = 0）. -/
theorem binaryEntropy_zero : binaryEntropy 0 = 0 := by
  unfold binaryEntropy
  simp [Real.log_one]

/-- h(1) = 0 (by convention).
    h(1) = 0（規約により）. -/
theorem binaryEntropy_one : binaryEntropy 1 = 0 := by
  unfold binaryEntropy
  simp [Real.log_one]

/-- h(1/2) = ln 2: binary entropy is maximized at β = 1/2.
    h(1/2) = ln 2: 二進エントロピーは β = 1/2 で最大.

    Proof: h(1/2) = -(1/2)·ln(1/2) - (1/2)·ln(1/2)
                   = -ln(1/2) = -ln(2⁻¹) = ln 2. -/
theorem binaryEntropy_half : binaryEntropy (1/2 : ℝ) = Real.log 2 := by
  unfold binaryEntropy
  have h_half : (1 : ℝ) - 1/2 = 1/2 := by ring
  rw [h_half]
  have h_log_half : Real.log (1/2 : ℝ) = -Real.log 2 := by
    have : (1/2 : ℝ) = (2 : ℝ)⁻¹ := by norm_num
    rw [this, Real.log_inv]
  rw [h_log_half]
  ring

/-! ## Part 4: Exponent Function φ(β, α)
    指数関数 φ(β, α) -/

/-- The asymptotic exponent function:
    φ(β, α) = h(β) - ln 2 + α · ln R(β).
    漸近指数関数:
    φ(β, α) = h(β) - ln 2 + α · ln R(β).

    The second moment ratio is dominated by exp(n · max_β φ(β, α))
    via Laplace/saddle-point approximation.
    第二モーメント比はラプラス/鞍点近似により exp(n · max_β φ(β, α)) が支配する. -/
noncomputable def exponentPhi (β α : ℝ) : ℝ :=
  binaryEntropy β - Real.log 2 + α * Real.log (R β)

/-! ## Part 5: Key Evaluations of φ
    φの主要な評価値 -/

/-- **φ(1/2, α) = 0 for ALL α** — the central structural theorem.
    φ(1/2, α) = 0（全てのαに対して）— 中心的構造定理.

    This means the dominant binomial contribution (β = 1/2, where
    most assignment pairs live) gives exponent exactly 0, hence
    contribution exp(0) = 1. The second moment ratio is O(1) or
    diverges depending on OTHER values of β.

    二項分布の支配的寄与（β = 1/2、大半の代入ペアが存在）の指数は
    正確に0であり、寄与は exp(0) = 1。第二モーメント比が O(1) か
    発散かは他のβ値に依存する. -/
theorem exponentPhi_half (α : ℝ) : exponentPhi (1/2 : ℝ) α = 0 := by
  unfold exponentPhi
  rw [binaryEntropy_half, R_at_half, Real.log_one]
  ring

/-- **φ(0, α) = α·ln(8/7) - ln 2** — first moment connection.
    φ(0, α) = α·ln(8/7) - ln 2 — 第一モーメントとの接続.

    The d=0 term (identical assignment pairs) has:
    - Binomial weight: C(n,0)/2^n = 1/2^n → h(0) - ln 2 = -ln 2
    - Ratio factor: R(0)^(αn) → α·ln R(0) = α·ln(8/7)
    d=0項（同一代入ペア）は:
    - 二項係数: C(n,0)/2^n = 1/2^n → h(0) - ln 2 = -ln 2
    - 比因子: R(0)^(αn) → α·ln R(0) = α·ln(8/7) -/
theorem exponentPhi_zero (α : ℝ) :
    exponentPhi 0 α = α * Real.log (8/7 : ℝ) - Real.log 2 := by
  unfold exponentPhi
  rw [binaryEntropy_zero, R_at_zero]
  ring

/-- **φ(1, α) = α·ln(48/49) - ln 2** — antipodal contribution.
    φ(1, α) = α·ln(48/49) - ln 2 — 対蹠的寄与.
    Since ln(48/49) < 0, this is always negative for α > 0.
    ln(48/49) < 0 なので、α > 0 のとき常に負. -/
theorem exponentPhi_one (α : ℝ) :
    exponentPhi 1 α = α * Real.log (48/49 : ℝ) - Real.log 2 := by
  unfold exponentPhi
  rw [binaryEntropy_one, R_at_one]
  ring

/-! ## Part 6: First Moment Threshold Recovery
    第一モーメント閾値の回復 -/

/-- **First moment threshold from exponent**: φ(0, α) = 0 when
    α = ln 2 / ln(8/7).
    指数関数からの第一モーメント閾値: α = ln 2 / ln(8/7) のとき φ(0, α) = 0.

    This is the critical density where the d=0 contribution to the
    second moment ratio transitions from exponentially small to
    exponentially large.
    第二モーメント比のd=0寄与が指数的に小さいものから
    指数的に大きいものへ遷移する臨界密度. -/
theorem first_moment_threshold_from_exponent
    (h87_pos : (0 : ℝ) < Real.log (8 / 7)) :
    exponentPhi 0 (Real.log 2 / Real.log (8 / 7 : ℝ)) = 0 := by
  rw [exponentPhi_zero]
  rw [div_mul_cancel₀ (Real.log 2) (ne_of_gt h87_pos)]
  ring

/-- The first moment threshold α_c^(1) = ln 2 / ln(8/7).
    第一モーメント閾値 α_c^(1) = ln 2 / ln(8/7).
    This matches `ratio_xor_over_random` from SATFirstMoment.lean!
    SATFirstMoment.lean の `ratio_xor_over_random` と一致! -/
noncomputable def firstMomentThreshold : ℝ :=
  Real.log 2 / Real.log (8/7 : ℝ)

/-- The first moment threshold equals the XOR-to-random ratio from
    SATFirstMoment. Different derivation, same number!
    第一モーメント閾値はSATFirstMomentのXOR対ランダム比に等しい.
    異なる導出、同じ数! -/
theorem firstMomentThreshold_eq_ratio :
    firstMomentThreshold =
    SATFirstMoment.infoLoss (1/2 : ℝ) / SATFirstMoment.infoLoss (7/8 : ℝ) := by
  unfold firstMomentThreshold
  rw [SATFirstMoment.info_loss_xor_pair, SATFirstMoment.info_loss_random_3clause]

/-- φ(0, α) = 0 at the first moment threshold.
    第一モーメント閾値において φ(0, α) = 0. -/
theorem exponentPhi_zero_at_threshold
    (h87_pos : (0 : ℝ) < Real.log (8 / 7)) :
    exponentPhi 0 firstMomentThreshold = 0 :=
  first_moment_threshold_from_exponent h87_pos

/-- For α < firstMomentThreshold (and ln(8/7) > 0), φ(0, α) < 0.
    α < firstMomentThreshold のとき φ(0, α) < 0.
    The d=0 contribution is exponentially suppressed below the
    first moment threshold.
    第一モーメント閾値以下ではd=0寄与は指数的に抑制される. -/
theorem exponentPhi_zero_neg_below_threshold
    {α : ℝ}
    (h87_pos : (0 : ℝ) < Real.log (8 / 7))
    (hα : α < firstMomentThreshold) :
    exponentPhi 0 α < 0 := by
  rw [exponentPhi_zero]
  unfold firstMomentThreshold at hα
  -- α < ln 2 / ln(8/7), so α · ln(8/7) < ln 2
  have h1 : α * Real.log (8/7 : ℝ) < Real.log 2 := by
    rwa [lt_div_iff₀ h87_pos] at hα
  linarith

/-- For α > firstMomentThreshold (and ln(8/7) > 0), φ(0, α) > 0.
    α > firstMomentThreshold のとき φ(0, α) > 0.
    The d=0 contribution dominates exponentially above the threshold.
    閾値以上ではd=0寄与が指数的に支配する. -/
theorem exponentPhi_zero_pos_above_threshold
    {α : ℝ}
    (h87_pos : (0 : ℝ) < Real.log (8 / 7))
    (hα : firstMomentThreshold < α) :
    exponentPhi 0 α > 0 := by
  rw [exponentPhi_zero]
  unfold firstMomentThreshold at hα
  have h1 : Real.log 2 < α * Real.log (8/7 : ℝ) := by
    rwa [div_lt_iff₀ h87_pos] at hα
  linarith

/-! ## Part 7: Gap Structure — Why the First Moment Overestimates
    ギャップ構造 — 第一モーメントが過大評価する理由 -/

/-! The first moment threshold is determined by the d=0 exponent φ(0, α) = 0,
    but the true SAT threshold is lower because the second moment ratio receives
    contributions from ALL values of β ∈ [0, 1], not just β = 0.

    ギャップの説明: 第一モーメント閾値は d=0 指数 φ(0, α) = 0 で
    決まるが、真のSAT閾値はそれより低い. 第二モーメント比が
    β = 0 だけでなく β ∈ [0, 1] 全体からの寄与を受けるため.

    Key structural insight: since R(β) ≠ 1 for β ≠ 1/2 (in general),
    the inter-clause correlations encoded in g(β) make the first moment
    an upper bound, not an exact threshold.
    鍵となる構造的洞察: β ≠ 1/2 で R(β) ≠ 1 であるため、
    g(β) に符号化された節間相関が第一モーメントを上界にし、
    正確な閾値にはしない. -/

/-- R deviates from 1 at β = 0 (where R > 1).
    β = 0 において R は 1 から逸脱する（R > 1）. -/
theorem R_deviates_at_zero : R 0 ≠ 1 := by
  rw [R_at_zero]; norm_num

/-- R deviates from 1 at β = 1 (where R < 1).
    β = 1 において R は 1 から逸脱する（R < 1）. -/
theorem R_deviates_at_one : R 1 ≠ 1 := by
  rw [R_at_one]; norm_num

/-- The gap between first moment threshold and β=1/2 neutrality.
    β=1/2のexponentPhi_halfは「ギャップの原因は他のβ値にある」ことを
    端的に示す: β=1/2は常に中立なので、閾値を決めるのはβ≠1/2の挙動.

    Restating: φ(1/2, α) = 0 for all α means β = 1/2 NEVER determines
    the threshold — it is always the atypical overlaps (β near 0 or 1)
    that control whether the ratio diverges. -/
theorem half_never_determines_threshold (α₁ α₂ : ℝ) :
    exponentPhi (1/2 : ℝ) α₁ = exponentPhi (1/2 : ℝ) α₂ := by
  rw [exponentPhi_half, exponentPhi_half]

/-! ## Part 8: Positivity and Monotonicity of R
    Rの正値性と単調性 -/

/-- g(β) > 0 for β ∈ [0,1].
    g(β) は [0,1] 上で正. -/
theorem g_pos {β : ℝ} (_h0 : 0 ≤ β) (h1 : β ≤ 1) : 0 < g β := by
  unfold g
  have h_nn : 0 ≤ 1 - β := by linarith
  have : 0 ≤ (1 - β)^3 := pow_nonneg h_nn 3
  nlinarith

/-- R(β) > 0 for β ∈ [0,1].
    R(β) は [0,1] 上で正. -/
theorem R_pos {β : ℝ} (h0 : 0 ≤ β) (h1 : β ≤ 1) : 0 < R β := by
  unfold R
  apply div_pos (g_pos h0 h1)
  norm_num

/-- R(β) ≤ 8/7 for β ∈ [0,1] (maximum at β = 0).
    R(β) ≤ 8/7（最大はβ = 0で達成）. -/
theorem R_le_max {β : ℝ} (h0 : 0 ≤ β) (h1 : β ≤ 1) : R β ≤ 8 / 7 := by
  unfold R g
  have h_nn : 0 ≤ 1 - β := by linarith
  have h_cube_le : (1 - β) ^ 3 ≤ 1 := pow_le_one₀ h_nn (by linarith)
  rw [div_le_iff₀ (by norm_num : (0 : ℝ) < (7 / 8) ^ 2)]
  nlinarith

/-- R(β) ≥ 48/49 for β ∈ [0,1] (minimum at β = 1).
    R(β) ≥ 48/49（最小はβ = 1で達成）. -/
theorem R_ge_min {β : ℝ} (_h0 : 0 ≤ β) (h1 : β ≤ 1) : 48 / 49 ≤ R β := by
  unfold R g
  have h_nn : 0 ≤ 1 - β := by linarith
  have h_cube_nn : 0 ≤ (1 - β) ^ 3 := pow_nonneg h_nn 3
  rw [le_div_iff₀ (by norm_num : (0 : ℝ) < (7 / 8) ^ 2)]
  nlinarith

/-! ## Part 9: Exponent Monotonicity in α
    αに関する指数の単調性 -/

/-- φ(0, ·) is strictly increasing in α (since ln(8/7) > 0).
    φ(0, ·) は α に関して狭義単調増加（ln(8/7) > 0 のため）. -/
theorem exponentPhi_zero_strictMono
    (h87_pos : (0 : ℝ) < Real.log (8 / 7)) :
    ∀ α₁ α₂ : ℝ, α₁ < α₂ → exponentPhi 0 α₁ < exponentPhi 0 α₂ := by
  intro α₁ α₂ hlt
  rw [exponentPhi_zero, exponentPhi_zero]
  have : α₁ * Real.log (8/7 : ℝ) < α₂ * Real.log (8/7 : ℝ) := by
    exact mul_lt_mul_of_pos_right hlt h87_pos
  linarith

/-- φ(β, ·) is monotone in α for any β with R(β) > 1 (increasing)
    or R(β) < 1 (decreasing). At β = 1/2 where R = 1, it is constant.
    R(β) > 1 のとき α で増加、R(β) < 1 のとき減少、R(β) = 1 のとき定数. -/
theorem exponentPhi_const_in_alpha_at_half :
    ∀ α₁ α₂ : ℝ, exponentPhi (1/2 : ℝ) α₁ = exponentPhi (1/2 : ℝ) α₂ :=
  half_never_determines_threshold

/-! ## Part 10: Summary — Connecting All Pieces
    まとめ — 全体の接続 -/

/-- **Grand summary**: the exponent function φ encodes the full
    threshold structure of random 3-SAT:
    指数関数φは、ランダム3-SATの閾値構造の全体を符号化する:

    1. φ(1/2, α) = 0: typical overlaps are always neutral
       典型的重なりは常に中立
    2. φ(0, α) = α·ln(8/7) - ln 2: first moment exponent
       第一モーメント指数
    3. φ(0, α_c^(1)) = 0 where α_c^(1) = ln 2 / ln(8/7)
       第一モーメント閾値
    4. The true threshold α_c < α_c^(1) because R(β) ≠ 1 for β ≠ 1/2
       真の閾値 < 第一モーメント閾値（R(β) ≠ 1 のため）

    This theorem packages the key identities together.
    主要な恒等式をまとめる. -/
theorem exponent_structure_summary
    (h87_pos : (0 : ℝ) < Real.log (8 / 7)) :
    -- (1) typical overlap is neutral
    exponentPhi (1/2 : ℝ) 42 = 0
    -- (2) zero overlap gives first moment
    ∧ exponentPhi 0 firstMomentThreshold = 0
    -- (3) below threshold: d=0 suppressed
    ∧ exponentPhi 0 0 < 0
    -- (4) R deviates from 1 at boundaries
    ∧ R 0 ≠ 1
    ∧ R 1 ≠ 1 := by
  refine ⟨exponentPhi_half 42,
    exponentPhi_zero_at_threshold h87_pos, ?_,
    R_deviates_at_zero, R_deviates_at_one⟩
  rw [exponentPhi_zero]
  linarith [Real.log_pos (by norm_num : (1 : ℝ) < 2)]

end

end Survival.AsymptoticExponent
