import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

/-!
# Random Parity-Check Full-Rank Envelope

This module records the finite row-slack side of the BEC random-achievability
skeleton.

It does not count random matrices and it does not prove the exact product
formula for the probability that an `r x e` binary matrix has full column rank.
Instead, it formalizes the final deterministic algebra used after the standard
union-bound estimate

`Pr[rank failure] <= 2^e / 2^r`.

If the erasure column count `e` has row slack `s`, i.e. `e + s <= r`, then this
failure envelope is at most `2^{-s}`.  Equivalently, the full-rank success
probability is at least `1 - 2^{-s}`.
-/

namespace Survival.LinearCodeRandomParityCheckFullRank

noncomputable section

/-- The union-bound envelope `2^e / 2^r` is at most `2^{-s}` when `e+s <= r`. -/
theorem two_pow_ratio_le_inv_two_pow_of_add_le
    {e s r : ℕ} (h : e + s ≤ r) :
    ((2 : ℝ) ^ e) / ((2 : ℝ) ^ r) ≤ (1 : ℝ) / ((2 : ℝ) ^ s) := by
  have hbase : (1 : ℝ) ≤ 2 := by norm_num
  have hpow : (2 : ℝ) ^ (e + s) ≤ (2 : ℝ) ^ r :=
    pow_le_pow_right₀ hbase h
  have hpos_e : 0 < (2 : ℝ) ^ e := pow_pos (by norm_num) _
  have hpos_s : 0 < (2 : ℝ) ^ s := pow_pos (by norm_num) _
  have hpos_r : 0 < (2 : ℝ) ^ r := pow_pos (by norm_num) _
  rw [pow_add] at hpow
  rw [div_le_div_iff₀ hpos_r hpos_s]
  nlinarith

/-- A small envelope object for a random `r x e` parity-check submatrix.

`failureProb` is the rank-failure probability for the erased-column submatrix.
The structure assumes the standard union-bound estimate and a row-slack
condition. -/
structure FullRankEnvelope where
  rows : ℕ
  cols : ℕ
  slack : ℕ
  failureProb : ℝ
  failure_nonneg : 0 ≤ failureProb
  union_bound : failureProb ≤ ((2 : ℝ) ^ cols) / ((2 : ℝ) ^ rows)
  row_slack : cols + slack ≤ rows

/-- Full-rank success probability corresponding to `failureProb`. -/
def successProb (P : FullRankEnvelope) : ℝ :=
  1 - P.failureProb

/-- Row slack turns the union-bound envelope into a `2^{-s}` rank-failure
bound. -/
theorem failureProb_le_inv_two_pow_slack
    (P : FullRankEnvelope) :
    P.failureProb ≤ (1 : ℝ) / ((2 : ℝ) ^ P.slack) := by
  exact le_trans P.union_bound
    (two_pow_ratio_le_inv_two_pow_of_add_le P.row_slack)

/-- Equivalently, full-rank success is at least `1 - 2^{-s}`. -/
theorem successProb_ge_one_sub_inv_two_pow_slack
    (P : FullRankEnvelope) :
    1 - (1 : ℝ) / ((2 : ℝ) ^ P.slack) ≤ successProb P := by
  unfold successProb
  have h := failureProb_le_inv_two_pow_slack P
  linarith

/-- A toy envelope with two bits of row slack. -/
def toySlackTwo : FullRankEnvelope where
  rows := 5
  cols := 3
  slack := 2
  failureProb := (1 : ℝ) / 4
  failure_nonneg := by norm_num
  union_bound := by norm_num
  row_slack := by norm_num

theorem toySlackTwo_failure_bound :
    toySlackTwo.failureProb ≤ (1 : ℝ) / 4 := by
  simp [toySlackTwo]

theorem toySlackTwo_success_bound :
    (3 : ℝ) / 4 ≤ successProb toySlackTwo := by
  norm_num [successProb, toySlackTwo]

end

end Survival.LinearCodeRandomParityCheckFullRank
