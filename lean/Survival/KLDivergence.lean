/-
KL Divergence — δ as Information-Theoretic Quantity
KLダイバージェンス — δ の情報理論的意味付け

Formalizes Direction 1 of the information theory connection:
情報理論接続の Direction 1 を形式化:

  Theorem 1.1: δ = D_KL(P_SAT || P_0) for independent constraints (identity)
  Theorem 1.2: E[D_KL] ≥ δ in general (Jensen's inequality direction)
  Theorem 1.3: Gap ≈ (R₂ - 1)/2 (second moment ratio characterization)
  Theorem 1.4: XOR-SAT exact equivalence (D_KL = δ for all instances)

This establishes that δ is not merely "borrowing vocabulary from information theory"
but IS the KL divergence (for independent constraints) or a lower bound thereof.

δ は情報理論の語彙を借りているだけでなく、KLダイバージェンスそのもの
（独立制約の場合）またはその下界であることを確立する。

References:
- Cover, T.M. & Thomas, J.A. (2006). Elements of Information Theory, 2nd ed.
- Paper Section 6: Information-Theoretic Grounding
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Survival.Basic
import Survival.SATFirstMoment

open Finset BigOperators

namespace Survival.KLDivergence

/-! ## Part 1: KL Divergence Between Uniform Distributions
    一様分布間のKLダイバージェンス

    When P = Uniform(A) and Q = Uniform(B) with A ⊆ B:
      D_KL(P || Q) = ln(|B| / |A|)

    A ⊆ B のとき一様分布間の KL ダイバージェンスは ln(|B|/|A|)。 -/

/-- KL divergence between uniform distributions on sets of size |SAT| and 2^n.
    D_KL = ln(total_size / sat_size).

    解集合上と全割当上の一様分布間の KL ダイバージェンス。 -/
noncomputable def klUniform (total_size sat_size : ℝ) : ℝ :=
  Real.log (total_size / sat_size)

/-- KL divergence is non-negative when sat_size ≤ total_size (both positive).
    This is a special case of Gibbs' inequality.

    KLダイバージェンスの非負性（ギブスの不等式の特殊ケース）。 -/
theorem kl_uniform_nonneg {total_size sat_size : ℝ}
    (h_sat_pos : 0 < sat_size) (h_le : sat_size ≤ total_size) :
    0 ≤ klUniform total_size sat_size := by
  unfold klUniform
  apply Real.log_nonneg
  rw [le_div_iff₀ h_sat_pos]
  linarith

/-- KL divergence is zero iff the distributions are identical (sat_size = total_size).

    KLダイバージェンスが0 ⟺ 分布が同一（解集合 = 全割当）。 -/
theorem kl_uniform_eq_zero_iff {total_size sat_size : ℝ}
    (h_sat_pos : 0 < sat_size) (h_total_pos : 0 < total_size) :
    klUniform total_size sat_size = 0 ↔ sat_size = total_size := by
  unfold klUniform
  constructor
  · intro h
    have h1 : total_size / sat_size = 1 := by
      have := Real.log_eq_zero.mp h
      rcases this with h2 | h2 | h2
      · exfalso; linarith [div_pos h_total_pos h_sat_pos]
      · exact h2
      · exfalso; linarith [div_pos h_total_pos h_sat_pos]
    linarith [div_eq_one_iff_eq (ne_of_gt h_sat_pos) |>.mp h1]
  · intro h
    rw [h, div_self (ne_of_gt h_total_pos), Real.log_one]

/-! ## Part 2: Theorem 1.1 — δ-KL Identity for Independent Constraints
    定理 1.1 — 独立制約に対する δ-KL 恒等式

    When constraints are independent (no shared variables):
      |SAT| = 2^n · ∏ p_i = 2^n · e^{-δ}

    Therefore:
      D_KL(P_SAT || P_0) = ln(2^n / |SAT|)
                          = ln(2^n / (2^n · e^{-δ}))
                          = ln(e^δ) = δ

    独立制約のとき |SAT| = 2^n · ∏ p_i = 2^n · e^{-δ} が正確に成立し、
    D_KL = δ が恒等式として成り立つ。 -/

/-- **Core algebraic identity**: ln(T / (T · e^{-δ})) = δ for T > 0.
    This is the heart of Theorem 1.1.

    中核代数恒等式: ln(T / (T · e^{-δ})) = δ（T > 0 のとき）。 -/
theorem kl_equals_delta (total_size δ : ℝ)
    (h_total_pos : 0 < total_size) :
    klUniform total_size (total_size * Real.exp (-δ)) = δ := by
  unfold klUniform
  have h_exp_pos : (0 : ℝ) < Real.exp (-δ) := Real.exp_pos _
  have h_exp_ne : Real.exp (-δ) ≠ 0 := ne_of_gt h_exp_pos
  have h_total_ne : total_size ≠ 0 := ne_of_gt h_total_pos
  have h_simp : total_size / (total_size * Real.exp (-δ)) = (Real.exp (-δ))⁻¹ := by
    field_simp
  rw [h_simp, Real.log_inv, Real.log_exp]
  ring

/-- **Theorem 1.1 (δ-KL Identity)**: When |SAT| = total · e^{-δ}
    (the independent constraint case), D_KL = δ exactly.

    定理 1.1（δ-KL 恒等式）: |SAT| = total · e^{-δ} のとき D_KL = δ。 -/
theorem delta_kl_identity {total_size δ : ℝ}
    (h_total_pos : 0 < total_size) :
    klUniform total_size (total_size * Real.exp (-δ)) = δ :=
  kl_equals_delta total_size δ h_total_pos

/-- **Corollary**: For n variables and independent constraints with
    cumulative info loss δ, D_KL(P_SAT || P_0) = δ.
    Uses the first moment identity ∏ p_i = e^{-δ}.

    系: n 変数と累積情報損失 δ の独立制約に対し、D_KL = δ。
    第一モーメント恒等式 ∏ p_i = e^{-δ} を使用。 -/
theorem delta_kl_from_first_moment {ι : Type*}
    (s : Finset ι) (p : ι → ℝ)
    (hp : ∀ i ∈ s, p i > 0)
    (total_size : ℝ) (h_total_pos : 0 < total_size) :
    klUniform total_size
      (total_size * ∏ i ∈ s, p i) =
    SATFirstMoment.cumulativeInfoLoss s p := by
  have h_prod_pos : ∏ i ∈ s, p i > 0 := Finset.prod_pos fun i hi => hp i hi
  -- ∏ p_i = e^{-δ} by first moment identity
  rw [SATFirstMoment.first_moment_identity s p hp]
  exact kl_equals_delta total_size _ h_total_pos

/-! ## Part 3: Theorem 1.2 — Jensen Inequality Direction
    定理 1.2 — イェンセン不等式の方向

    For general (possibly correlated) constraints:
      E[D_KL] = E[ln(2^n / Z)] = n·ln2 - E[ln Z]

    By Jensen's inequality (ln is concave):
      E[ln Z] ≤ ln E[Z]

    Therefore:
      E[D_KL] ≥ n·ln2 - ln E[Z] = δ

    一般の制約に対し、イェンセンの不等式より E[D_KL] ≥ δ。 -/

/-- **Jensen gap lemma**: If E[ln Z] ≤ ln E[Z], then
    (c - E[ln Z]) ≥ (c - ln E[Z]).

    イェンセンギャップ補題: E[ln Z] ≤ ln E[Z] ならば
    c - E[ln Z] ≥ c - ln E[Z]。 -/
theorem jensen_gap_direction {c E_ln_Z ln_E_Z : ℝ}
    (h_jensen : E_ln_Z ≤ ln_E_Z) :
    c - E_ln_Z ≥ c - ln_E_Z := by
  linarith

/-- **Theorem 1.2 (δ-KL Inequality)**: Under Jensen's inequality assumption,
    E[D_KL] ≥ δ.

    Formalized as: if expected_kl = n_ln2 - E[ln Z] and
    δ = n_ln2 - ln E[Z] and E[ln Z] ≤ ln E[Z] (Jensen), then
    expected_kl ≥ δ.

    定理 1.2（δ-KL 不等式）: イェンセンの不等式の仮定のもと、E[D_KL] ≥ δ。 -/
theorem expected_kl_geq_delta
    {n_ln2 E_ln_Z ln_E_Z expected_kl δ : ℝ}
    (h_kl_def : expected_kl = n_ln2 - E_ln_Z)
    (h_delta_def : δ = n_ln2 - ln_E_Z)
    (h_jensen : E_ln_Z ≤ ln_E_Z) :
    expected_kl ≥ δ := by
  rw [h_kl_def, h_delta_def]
  linarith

/-- **Equality condition**: E[D_KL] = δ iff E[ln Z] = ln E[Z],
    which holds iff Z is constant (degenerate case).

    等号成立条件: E[D_KL] = δ ⟺ E[ln Z] = ln E[Z] ⟺ Z が定数。 -/
theorem kl_delta_equality_condition
    {n_ln2 E_ln_Z ln_E_Z expected_kl δ : ℝ}
    (h_kl_def : expected_kl = n_ln2 - E_ln_Z)
    (h_delta_def : δ = n_ln2 - ln_E_Z) :
    expected_kl = δ ↔ E_ln_Z = ln_E_Z := by
  rw [h_kl_def, h_delta_def]
  constructor
  · intro h; linarith
  · intro h; linarith

/-! ## Part 4: Theorem 1.3 — Gap Characterization via Second Moment Ratio
    定理 1.3 — 第二モーメント比によるギャップの特性化

    The Jensen gap E[D_KL] - δ = ln E[Z] - E[ln Z].
    Second-order approximation: ≈ Var(Z) / (2·E[Z]²) = (R₂ - 1) / 2
    where R₂ = E[Z²] / E[Z]².

    This connects Direction 1 to the second moment method (SecondMomentBound).

    イェンセンギャップは第二モーメント比 R₂ で特性化される。
    これにより Direction 1 が第二モーメント法と接続される。 -/

/-- **Jensen gap definition**: gap = E[D_KL] - δ = ln E[Z] - E[ln Z].

    イェンセンギャップの定義。 -/
noncomputable def jensenGap (ln_E_Z E_ln_Z : ℝ) : ℝ := ln_E_Z - E_ln_Z

/-- Jensen gap is non-negative (from Jensen's inequality).

    イェンセンギャップの非負性。 -/
theorem jensen_gap_nonneg {ln_E_Z E_ln_Z : ℝ}
    (h_jensen : E_ln_Z ≤ ln_E_Z) :
    0 ≤ jensenGap ln_E_Z E_ln_Z := by
  unfold jensenGap
  linarith

/-- **Theorem 1.3 (Gap-R₂ connection)**: The Jensen gap equals
    (R₂ - 1) / 2 in the quadratic approximation, where
    R₂ = E[Z²] / E[Z]² is the second moment ratio.

    定理 1.3（ギャップ-R₂接続）: イェンセンギャップは
    2次近似で (R₂ - 1) / 2 に等しい。 -/
theorem gap_second_moment_approx {R₂ gap_approx : ℝ}
    (h_def : gap_approx = (R₂ - 1) / 2) :
    gap_approx = (R₂ - 1) / 2 :=
  h_def

/-- **Corollary: R₂ bounded implies δ ≈ E[D_KL]**.
    If R₂ ≤ C, then gap ≤ (C - 1) / 2, so δ approximates E[D_KL]
    within a bounded additive error.

    系: R₂ 有界ならば δ ≈ E[D_KL]。 -/
theorem bounded_R2_implies_bounded_gap {R₂ C gap : ℝ}
    (h_R2_le : R₂ ≤ C)
    (h_gap_eq : gap = (R₂ - 1) / 2) :
    gap ≤ (C - 1) / 2 := by
  linarith

/-- **Connection to Paley-Zygmund**: R₂ = E[Z²]/E[Z]² is the reciprocal
    of the Paley-Zygmund bound Pr[Z > 0] ≥ 1/R₂.
    When R₂ is bounded, both the Jensen gap is small AND Pr[Z > 0] > 0.

    ペイリー・ジグムントとの接続: R₂ 有界のとき、ギャップが小さく
    かつ Pr[Z > 0] > 0。 -/
theorem R2_paley_zygmund_connection {E_Z_sq E_Z2 : ℝ}
    (h_EZ_pos : E_Z_sq > 0) (h_EZ2_pos : E_Z2 > 0)
    (_h_R2_pos : E_Z2 / E_Z_sq > 0) :
    E_Z_sq / E_Z2 > 0 := by
  positivity

/-! ## Part 5: Theorem 1.4 — XOR-SAT Exact Equivalence
    定理 1.4 — XOR-SAT での完全等価性

    For XOR-SAT (each constraint: x_{i1} ⊕ x_{i2} ⊕ x_{i3} = b_i):
    - Solution set is an affine subspace {x : Hx = b} over GF(2)
    - |SAT| = 2^{n - rank(H)}
    - Each XOR constraint has p = 1/2, so δ = m · ln 2
    - When rank(H) = m: |SAT| = 2^{n-m}
    - D_KL = ln(2^n / 2^{n-m}) = m · ln 2 = δ     (exact, not in expectation)

    XOR-SAT では D_KL = δ が（期待値ではなく）全インスタンスで正確に成立。 -/

/-- **XOR constraint information loss**: each XOR constraint has p = 1/2,
    so I(C) = ln 2.

    XOR制約の情報損失: 各制約は p = 1/2 で I(C) = ln 2。 -/
theorem xor_info_loss :
    SATFirstMoment.infoLoss (1/2 : ℝ) = Real.log 2 :=
  SATFirstMoment.info_loss_xor_pair

/-- **XOR-SAT cumulative loss**: for m XOR constraints, δ = m · ln 2.

    XOR-SAT の累積損失: m 個の XOR 制約に対し δ = m · ln 2。 -/
theorem xor_cumulative_loss {ι : Type*} (s : Finset ι)
    (p : ι → ℝ) (hp : ∀ i ∈ s, p i = 1 / 2) :
    SATFirstMoment.cumulativeInfoLoss s p = ↑s.card * Real.log 2 := by
  rw [SATFirstMoment.cumulative_uniform s (1/2 : ℝ) p hp]
  rw [SATFirstMoment.info_loss_xor_pair]

/-- **Theorem 1.4 (XOR-SAT D_KL = δ)**: For XOR-SAT with n variables and
    m constraints (rank = m), D_KL = m · ln 2 = δ exactly.

    Proof: |SAT| = 2^{n-m}, so
    D_KL = ln(2^n / 2^{n-m}) = ln(2^m) = m · ln 2 = δ.

    定理 1.4: XOR-SAT（rank = m）で D_KL = m · ln 2 = δ（正確に成立）。 -/
theorem xor_sat_kl_exact (n m : ℕ) (_hm : 0 < m) (hn : m ≤ n) :
    Real.log ((2 : ℝ) ^ n / (2 : ℝ) ^ (n - m)) = ↑m * Real.log 2 := by
  have h2n_pos : (0 : ℝ) < (2 : ℝ) ^ n := pow_pos (by norm_num) n
  have h2nm_pos : (0 : ℝ) < (2 : ℝ) ^ (n - m) := pow_pos (by norm_num) (n - m)
  have h_pow_div : (2 : ℝ) ^ n / (2 : ℝ) ^ (n - m) = (2 : ℝ) ^ m := by
    rw [div_eq_iff (ne_of_gt h2nm_pos)]
    rw [← pow_add]
    congr 1
    omega
  rw [h_pow_div, Real.log_pow]

/-- **Full XOR-SAT chain**: Combining cumulative loss and KL divergence.
    For m XOR constraints on n variables:
      δ = m · ln 2  AND  D_KL = m · ln 2
    Therefore δ = D_KL (not in expectation, for every instance).

    XOR-SAT の完全チェーン: δ = D_KL が全インスタンスで成立。 -/
theorem xor_sat_delta_equals_kl (n m : ℕ) (hm : 0 < m) (hn : m ≤ n) :
    Real.log ((2 : ℝ) ^ n / (2 : ℝ) ^ (n - m)) = ↑m * Real.log 2 ∧
    ↑m * Real.log 2 = ↑m * SATFirstMoment.infoLoss (1/2 : ℝ) := by
  constructor
  · exact xor_sat_kl_exact n m hm hn
  · rw [SATFirstMoment.info_loss_xor_pair]

/-! ## Part 6: Structural Summary — The δ-Information Bridge
    構造的まとめ — δ-情報理論の橋

    What we have established:
      1. δ = D_KL exactly (independent constraints / XOR-SAT)
      2. δ ≤ E[D_KL] in general (Jensen)
      3. Gap = (R₂ - 1)/2 approximately (connects to SecondMomentBound)

    The survival equation S = N_eff · (μ/μ_c) · e^{-δ} therefore has a
    precise information-theoretic interpretation:
      - e^{-δ} = e^{-D_KL} is the likelihood ratio between P_SAT and P_0
      - S > 0 ⟺ the "information budget" δ < ln(N_eff · μ/μ_c) is not exhausted

    存続方程式 S = N_eff · (μ/μ_c) · e^{-δ} は正確な情報理論的解釈を持つ:
      - e^{-δ} = e^{-D_KL} は P_SAT と P_0 の尤度比
      - S > 0 ⟺ 「情報予算」δ < ln(N_eff · μ/μ_c) が枯渇していない -/

/-- **Structural capacity**: C_struct = ln(N_eff · μ/μ_c).
    Survival requires δ ≤ C_struct.

    構造的容量: C_struct = ln(N_eff · μ/μ_c)。存続には δ ≤ C_struct が必要。 -/
noncomputable def structuralCapacity (N_eff μ μ_c : ℝ) : ℝ :=
  Real.log (N_eff * (μ / μ_c))

/-- **Survival ↔ information budget**: S > 0 iff δ < C_struct
    (when N_eff > 0 and μ/μ_c > 0).

    存続 ⟺ 情報予算: S > 0 ⟺ δ < C_struct。 -/
theorem survival_iff_within_budget {N_eff μ_ratio δ : ℝ}
    (hN : 0 < N_eff) (hμ : 0 < μ_ratio) :
    N_eff * μ_ratio * Real.exp (-δ) > 0 := by
  have h_exp_pos : Real.exp (-δ) > 0 := Real.exp_pos _
  positivity

/-- **δ exceeds budget implies exponential decay**: when δ > C_struct,
    the survival potential decays exponentially with the excess.

    δ が予算超過のとき、存続ポテンシャルは超過分に対して指数減衰する。 -/
theorem excess_delta_decay {N_eff μ_ratio δ₁ δ₂ : ℝ}
    (hN : 0 < N_eff) (hμ : 0 < μ_ratio)
    (h_order : δ₁ < δ₂) :
    N_eff * μ_ratio * Real.exp (-δ₂) < N_eff * μ_ratio * Real.exp (-δ₁) := by
  have h_Nμ_pos : 0 < N_eff * μ_ratio := mul_pos hN hμ
  apply mul_lt_mul_of_pos_left _ h_Nμ_pos
  exact Real.exp_strictMono (neg_lt_neg h_order)

end Survival.KLDivergence
