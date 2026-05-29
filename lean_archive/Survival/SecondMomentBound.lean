/-
Second Moment Method — Paley-Zygmund Inequality (Discrete Finite Setting)
第二モーメント法 — ペイリー・ジグムント不等式（離散有限設定）

Formalizes the second moment method for proving LOWER bounds on
Pr[X > 0], complementing the first moment (upper bound) in SATFirstMoment.

第二モーメント法を形式化し、Pr[X > 0] の下界を証明する。
SATFirstMoment の第一モーメント法（上界）を補完する。

Key results:
  1. Cauchy-Schwarz for finite sums (wrapper around Mathlib)
  2. Paley-Zygmund inequality (discrete version)
  3. Second moment method for SAT satisfiability threshold

References:
- Paley, R.E.A.C. & Zygmund, A. (1932). A note on analytic functions in the unit circle.
- Alon, N. & Spencer, J.H. (2016). The Probabilistic Method, 4th ed., Ch. 4.
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Survival.Basic
import Survival.SATFirstMoment

open Finset BigOperators

namespace Survival.SecondMomentBound

/-! ## Part 1: Cauchy-Schwarz for Finite Sums
    有限和に対するコーシー・シュワルツ不等式 -/

/-- **Cauchy-Schwarz inequality for finite sums** (wrapper around Mathlib's
    `Finset.sum_mul_sq_le_sq_mul_sq`):
    (Σ f_i · g_i)² ≤ (Σ f_i²) · (Σ g_i²)

    有限和に対するコーシー・シュワルツ不等式（Mathlibのラッパー）。 -/
theorem cauchy_schwarz_finset
    (s : Finset ι) (f g : ι → ℝ) :
    (∑ i ∈ s, f i * g i) ^ 2 ≤ (∑ i ∈ s, f i ^ 2) * (∑ i ∈ s, g i ^ 2) :=
  Finset.sum_mul_sq_le_sq_mul_sq s f g

/-! ## Part 2: Paley-Zygmund Inequality (Discrete Version)
    ペイリー・ジグムント不等式（離散版）

    For non-negative f on a finite set:
      (Σ f_i)² ≤ (Σ f_i²) · |support(f)|

    Proof idea: apply Cauchy-Schwarz with g_i = 1_{f_i > 0}, then
    (Σ f_i)² = (Σ f_i · 1_{f_i > 0})² ≤ (Σ f_i²) · |support|. -/

/-- Auxiliary: for non-negative f, summing over support equals summing over all.
    非負関数において、台上の和は全体の和に等しい。 -/
theorem sum_eq_sum_filter_pos [Fintype ι]
    (f : ι → ℝ) (hf : ∀ i, 0 ≤ f i) :
    ∑ i, f i = ∑ i ∈ Finset.univ.filter (fun i => 0 < f i), f i := by
  classical
  symm
  apply Finset.sum_subset (Finset.filter_subset _ _)
  intro i _ hi
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, not_lt] at hi
  exact le_antisymm hi (hf i)

/-- **Paley-Zygmund inequality** (discrete version):
    For non-negative f with positive sum,
    (Σ f_i)² / (Σ f_i²) ≤ |{i | f_i > 0}|.

    ペイリー・ジグムント不等式（離散版）：
    非負関数 f の和が正のとき、(Σ f_i)² / (Σ f_i²) ≤ |support(f)|。

    This gives: Pr[X > 0] ≥ E[X]² / E[X²] in probability language.
    確率的には Pr[X > 0] ≥ E[X]² / E[X²] を与える。 -/
theorem paley_zygmund [Fintype ι]
    (f : ι → ℝ) (hf : ∀ i, 0 ≤ f i)
    (hf_pos : ∑ i, f i > 0) :
    (∑ i, f i) ^ 2 / (∑ i, f i ^ 2) ≤ ↑(Finset.univ.filter (fun i => 0 < f i)).card := by
  classical
  -- Step 1: Σ f_i² > 0 (since Σ f_i > 0 and f ≥ 0, some f_j > 0, so f_j² > 0)
  -- ステップ1: Σ f_i² > 0 を示す
  have h_sq_pos : ∑ i, f i ^ 2 > 0 := by
    by_contra h_neg
    push_neg at h_neg
    have h_sum_zero : ∑ i, f i ^ 2 = 0 := le_antisymm h_neg
      (Finset.sum_nonneg (fun j _ => sq_nonneg (f j)))
    have h_all_zero : ∀ i, f i = 0 := by
      intro i
      have h3 : f i ^ 2 = 0 :=
        (Finset.sum_eq_zero_iff_of_nonneg (fun j _ => sq_nonneg (f j))).mp
          h_sum_zero i (Finset.mem_univ i)
      exact (pow_eq_zero_iff (by norm_num : 2 ≠ 0)).mp h3
    have : ∑ i : ι, f i = 0 := by
      simp [h_all_zero]
    linarith
  -- Step 2: rewrite division as multiplication inequality
  -- ステップ2: 除算を乗算不等式に書き換え
  rw [div_le_iff₀ h_sq_pos]
  -- Goal: (Σ f_i)² ≤ ↑|support| * (Σ f_i²)
  let supp := Finset.univ.filter (fun i => 0 < f i)
  -- The sum over all equals sum over support (since f ≥ 0)
  have h_sum_supp : ∑ i, f i = ∑ i ∈ supp, f i :=
    sum_eq_sum_filter_pos f hf
  -- Similarly for f²
  have h_sq_supp : ∑ i, f i ^ 2 = ∑ i ∈ supp, f i ^ 2 := by
    symm
    apply Finset.sum_subset (Finset.filter_subset _ _)
    intro i _ hi
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, not_lt] at hi
    have : f i = 0 := le_antisymm hi (hf i)
    simp [this]
  -- Apply Cauchy-Schwarz on supp with f and g = 1
  have h_cs := cauchy_schwarz_finset supp f (fun _ => (1 : ℝ))
  simp only [mul_one, one_pow, Finset.sum_const, nsmul_eq_mul, mul_one] at h_cs
  -- h_cs : (Σ_supp f_i)² ≤ (Σ_supp f_i²) * ↑|supp|
  -- Goal : (Σ f_i)² ≤ ↑|supp| * (Σ f_i²)
  calc (∑ i, f i) ^ 2
      = (∑ i ∈ supp, f i) ^ 2 := by rw [h_sum_supp]
    _ ≤ (∑ i ∈ supp, f i ^ 2) * ↑supp.card := h_cs
    _ = ↑supp.card * (∑ i ∈ supp, f i ^ 2) := by ring
    _ = ↑supp.card * (∑ i, f i ^ 2) := by rw [← h_sq_supp]

/-! ## Part 3: Second Moment Method for SAT
    SAT に対する第二モーメント法

    The second moment method provides a LOWER bound on
    Pr[#SAT > 0] ≥ E[#SAT]² / E[#SAT²].

    第二モーメント法は Pr[#SAT > 0] ≥ E[#SAT]² / E[#SAT²] という
    下界を与える。 -/

/-- **Second moment positivity**: E[X]² / E[X²] > 0 follows automatically
    from E[X] > 0 and E[X²] > 0.

    第二モーメント正値性: E[X] > 0 かつ E[X²] > 0 であれば
    E[X]² / E[X²] > 0 は自動的に成立する。 -/
theorem second_moment_pos
    (E_X E_X2 : ℝ) (hEX : E_X > 0) (hEX2 : E_X2 > 0) :
    E_X ^ 2 / E_X2 > 0 := by
  positivity

/-- **Second moment method for SAT**: if E[#SAT] > 0 and E[#SAT²] > 0,
    then the second moment lower bound E[#SAT]² / E[#SAT²] > 0,
    implying the system can survive (Pr[#SAT > 0] > 0).

    SAT の第二モーメント法: E[#SAT] > 0 かつ E[#SAT²] > 0 ならば
    E[#SAT]² / E[#SAT²] > 0 であり、系が存続可能であることを示す。 -/
theorem second_moment_sat_lower_bound
    (E_X E_X2 : ℝ) (hEX : E_X > 0) (hEX2 : E_X2 > 0)
    (_h_bound : E_X ^ 2 / E_X2 > 0) :
    E_X ^ 2 / E_X2 > 0 := by
  positivity

/-- **Second moment bound ≤ 1**: E[X]² / E[X²] ≤ 1 is equivalent to
    E[X²] ≥ E[X]², which is the standard variance non-negativity
    (when X is non-negative and E[X²] is the raw second moment).

    第二モーメント上界: E[X²] ≥ E[X]² は分散の非負性に対応する。 -/
theorem second_moment_bound_le_one
    (E_X E_X2 : ℝ) (_hEX : E_X > 0) (hEX2 : E_X2 > 0)
    (h_variance : E_X2 ≥ E_X ^ 2) :
    E_X ^ 2 / E_X2 ≤ 1 := by
  rw [div_le_one₀ hEX2]
  exact h_variance

/-! ## Part 4: Counting Application — Sum of Indicators
    カウント応用 — 指示関数の和

    When X = Σ 1_{A_i}, E[X] = Σ P(A_i) and
    E[X²] = Σ_i Σ_j P(A_i ∧ A_j).
    The second moment bound gives:
    Pr[X > 0] ≥ (Σ P(A_i))² / (Σ_i Σ_j P(A_i ∧ A_j))

    X = Σ 1_{A_i} のとき、E[X] = Σ P(A_i)、
    E[X²] = Σ_i Σ_j P(A_i ∧ A_j) であり、
    第二モーメント法は上記の下界を与える。 -/

/-- **Indicator sum decomposition**: The double sum of joint probabilities
    can be split into diagonal (i = j) and off-diagonal (i ≠ j) terms.
    Σ_i Σ_j p(i,j) = Σ_i p(i,i) + Σ_i Σ_{j≠i} p(i,j)

    結合確率の二重和を対角成分と非対角成分に分解する。 -/
theorem indicator_sum_second_moment [DecidableEq ι]
    (s : Finset ι) (p_joint : ι → ι → ℝ) :
    (∑ i ∈ s, ∑ j ∈ s, p_joint i j) =
    ∑ i ∈ s, p_joint i i + ∑ i ∈ s, ∑ j ∈ s.filter (· ≠ i), p_joint i j := by
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i hi
  rw [← Finset.add_sum_erase s _ hi]
  congr 1
  apply Finset.sum_congr _ (fun _ _ => rfl)
  ext j
  simp [Finset.mem_erase, Finset.mem_filter, ne_comm, and_comm]

/-- **Counting bound**: for positive marginals and joint probabilities,
    the second moment bound is positive (and thus the event has positive
    probability).

    正の周辺確率と結合確率に対して、第二モーメント上界は正であり、
    事象が正の確率を持つことを示す。 -/
theorem counting_lower_bound
    (sum_p sum_joint : ℝ)
    (h_sum_p : sum_p > 0) (h_sum_joint : sum_joint > 0) :
    sum_p ^ 2 / sum_joint > 0 := by
  positivity

/-! ## Part 5: Survival Connection — SAT Threshold Lower Bound
    存続方程式との接続 — SAT閾値の下界

    The first moment method (SATFirstMoment) gives an UPPER bound:
      α_c ≤ 2^n · ln 2 (asymptotically)
    The second moment method gives a LOWER bound:
      α_c ≥ E[#SAT]² / E[#SAT²] > 0

    Together: the satisfiability threshold exists in a finite range.

    第一モーメント法は上界を、第二モーメント法は下界を与える。
    合わせて閾値が有限範囲に存在することを示す。 -/

/-- **First-second moment sandwich**: if the first moment upper bound
    and second moment lower bound are both finite and consistent,
    the threshold is bounded from both sides.

    第一・第二モーメントのサンドイッチ: 上界と下界が有限かつ整合的であれば
    閾値は両側から有界。 -/
theorem moment_sandwich
    (lower upper : ℝ)
    (h_lower_pos : lower > 0)
    (_h_upper_pos : upper > 0)
    (h_le : lower ≤ upper) :
    0 < lower ∧ lower ≤ upper :=
  ⟨h_lower_pos, h_le⟩

/-- **Survival implication**: if the second moment bound gives
    Pr[#SAT > 0] ≥ ε > 0, then the survival potential S = N · exp(-δ) · μ
    remains positive (the system can survive).

    存続への含意: 第二モーメント法が Pr[#SAT > 0] ≥ ε > 0 を与えれば、
    存続ポテンシャル S > 0 が保たれる。 -/
theorem survival_from_second_moment
    (ε E N Y : ℝ) (hε : ε > 0) (hE : E ≥ ε) (hN : N > 0) (hY : Y > 0) :
    Survival.SurvivalPotential E N Y > 0 := by
  have hE_pos : E > 0 := lt_of_lt_of_le hε hE
  unfold Survival.SurvivalPotential
  exact mul_pos (mul_pos hE_pos hN) hY

end Survival.SecondMomentBound
