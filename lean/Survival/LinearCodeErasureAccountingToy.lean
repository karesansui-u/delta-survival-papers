import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
# Linear-Code Erasure Accounting Toy

This module is a small specification-fixed accounting anchor for the A06/A19
coding-channel recovery domain.

It does not prove a decoding theorem and it does not formalize the empirical
low-order dependency proxy.  Instead, it records the exact finite-block
accounting used for a binary linear code over a BEC once an erasure set `E` and
the rank of the erased-column parity-check submatrix `H_E` have been fixed:

* ambiguity dimension `a(E) = |E| - rank(H_E)`;
* compatible-codeword multiplicity `2 ^ a(E)`;
* distinguishable-message-cell retained mass ratio `2^{-a(E)}`;
* exact structural loss `a(E) * log 2`.

The point is to keep the law-side exact anchor separate from prediction-support
features such as low-order dependency pressure.
-/

namespace Survival.LinearCodeErasureAccountingToy

noncomputable section

/-- A finite erasure/rank profile for the erased-column submatrix `H_E`.

`erasedCount` is `|E|` and `erasedRank` is `rank(H_E)`.  The only structural
assumption needed for the accounting identity is `rank(H_E) <= |E|`. -/
structure ErasureRankProfile where
  erasedCount : ℕ
  erasedRank : ℕ
  rank_le_erased : erasedRank ≤ erasedCount

/-- Ambiguity dimension `a(E) = |E| - rank(H_E)`. -/
def ambiguityDim (P : ErasureRankProfile) : ℕ :=
  P.erasedCount - P.erasedRank

/-- Number of compatible codewords/coset candidates after the erasure set is
fixed. -/
def compatibleMass (P : ErasureRankProfile) : ℕ :=
  2 ^ ambiguityDim P

/-- The retained distinguishable-message-cell mass ratio.  Compatible
codewords expand under erasure; the shrinking Core object is the distinguishable
message-cell mass, hence the inverse factor. -/
def retainedDistinguishableMassRatio (P : ErasureRankProfile) : ℝ :=
  (1 : ℝ) / (2 : ℝ) ^ ambiguityDim P

/-- Exact loss coordinate induced by the erasure/rank profile. -/
def exactLoss (P : ErasureRankProfile) : ℝ :=
  -Real.log (retainedDistinguishableMassRatio P)

/-- Unique recovery means zero ambiguity dimension. -/
def uniquelyRecoverable (P : ErasureRankProfile) : Prop :=
  ambiguityDim P = 0

/-- Rank deficiency means the erased columns fail to have full column rank. -/
def rankDeficient (P : ErasureRankProfile) : Prop :=
  P.erasedRank < P.erasedCount

@[simp] theorem compatibleMass_eq_two_pow_ambiguityDim
    (P : ErasureRankProfile) :
    compatibleMass P = 2 ^ ambiguityDim P := rfl

/-- The real-valued retained mass ratio is the inverse of the compatible
multiplicity. -/
theorem retainedDistinguishableMassRatio_eq_inv_compatibleMass
    (P : ErasureRankProfile) :
    retainedDistinguishableMassRatio P = (1 : ℝ) / (compatibleMass P : ℝ) := by
  simp [retainedDistinguishableMassRatio, compatibleMass]

/-- Exact A06/A19 accounting: the loss is `a(E) * log 2`. -/
theorem exactLoss_eq_ambiguityDim_mul_log_two
    (P : ErasureRankProfile) :
    exactLoss P = (ambiguityDim P : ℝ) * Real.log 2 := by
  unfold exactLoss retainedDistinguishableMassRatio
  have hpow_pos : 0 < (2 : ℝ) ^ ambiguityDim P :=
    pow_pos (by norm_num) _
  have hpow_ne : (2 : ℝ) ^ ambiguityDim P ≠ 0 :=
    ne_of_gt hpow_pos
  rw [Real.log_div (by norm_num : (1 : ℝ) ≠ 0) hpow_ne]
  rw [Real.log_one, Real.log_pow]
  ring

/-- Zero ambiguity is the same as full erased-column rank. -/
theorem ambiguityDim_eq_zero_iff_full_rank
    (P : ErasureRankProfile) :
    ambiguityDim P = 0 ↔ P.erasedRank = P.erasedCount := by
  unfold ambiguityDim
  constructor
  · intro h
    have hle : P.erasedCount ≤ P.erasedRank :=
      Nat.sub_eq_zero_iff_le.mp h
    exact le_antisymm P.rank_le_erased hle
  · intro h
    simp [h]

/-- Positive ambiguity is exactly rank deficiency. -/
theorem ambiguityDim_pos_iff_rankDeficient
    (P : ErasureRankProfile) :
    0 < ambiguityDim P ↔ rankDeficient P := by
  unfold ambiguityDim rankDeficient
  exact Nat.sub_pos_iff_lt

/-- Unique recovery is the same as full erased-column rank. -/
theorem uniquelyRecoverable_iff_full_rank
    (P : ErasureRankProfile) :
    uniquelyRecoverable P ↔ P.erasedRank = P.erasedCount := by
  unfold uniquelyRecoverable
  exact ambiguityDim_eq_zero_iff_full_rank P

/-- Rank deficiency is the same as non-unique recovery. -/
theorem rankDeficient_iff_not_uniquelyRecoverable
    (P : ErasureRankProfile) :
    rankDeficient P ↔ ¬ uniquelyRecoverable P := by
  rw [← ambiguityDim_pos_iff_rankDeficient]
  unfold uniquelyRecoverable
  exact Nat.pos_iff_ne_zero

/-- Exact loss is nonnegative. -/
theorem exactLoss_nonneg (P : ErasureRankProfile) :
    0 ≤ exactLoss P := by
  rw [exactLoss_eq_ambiguityDim_mul_log_two]
  exact mul_nonneg (Nat.cast_nonneg _) (le_of_lt (Real.log_pos (by norm_num)))

/-- Full rank / unique recovery has zero exact loss. -/
theorem exactLoss_eq_zero_of_uniquelyRecoverable
    (P : ErasureRankProfile) (h : uniquelyRecoverable P) :
    exactLoss P = 0 := by
  rw [exactLoss_eq_ambiguityDim_mul_log_two]
  simp [uniquelyRecoverable] at h
  simp [h]

/-- Rank deficiency gives strictly positive exact loss. -/
theorem exactLoss_pos_of_rankDeficient
    (P : ErasureRankProfile) (h : rankDeficient P) :
    0 < exactLoss P := by
  rw [exactLoss_eq_ambiguityDim_mul_log_two]
  have hdim : 0 < ambiguityDim P :=
    (ambiguityDim_pos_iff_rankDeficient P).2 h
  exact mul_pos (Nat.cast_pos.mpr hdim) (Real.log_pos (by norm_num))

/-- A two-erasure, full-rank toy profile: no ambiguity. -/
def toyFullRankTwo : ErasureRankProfile where
  erasedCount := 2
  erasedRank := 2
  rank_le_erased := by norm_num

/-- A two-erasure, rank-one toy profile: one bit of ambiguity. -/
def toyDependentPair : ErasureRankProfile where
  erasedCount := 2
  erasedRank := 1
  rank_le_erased := by norm_num

/-- A three-erasure, rank-one toy profile: two bits of ambiguity. -/
def toyTripleRankOne : ErasureRankProfile where
  erasedCount := 3
  erasedRank := 1
  rank_le_erased := by norm_num

@[simp] theorem toyFullRankTwo_ambiguityDim :
    ambiguityDim toyFullRankTwo = 0 := by
  norm_num [ambiguityDim, toyFullRankTwo]

@[simp] theorem toyDependentPair_ambiguityDim :
    ambiguityDim toyDependentPair = 1 := by
  norm_num [ambiguityDim, toyDependentPair]

@[simp] theorem toyTripleRankOne_ambiguityDim :
    ambiguityDim toyTripleRankOne = 2 := by
  norm_num [ambiguityDim, toyTripleRankOne]

theorem toyFullRankTwo_compatibleMass :
    compatibleMass toyFullRankTwo = 1 := by
  norm_num [compatibleMass]

theorem toyDependentPair_compatibleMass :
    compatibleMass toyDependentPair = 2 := by
  norm_num [compatibleMass]

theorem toyTripleRankOne_compatibleMass :
    compatibleMass toyTripleRankOne = 4 := by
  norm_num [compatibleMass]

theorem toyFullRankTwo_exactLoss :
    exactLoss toyFullRankTwo = 0 := by
  rw [exactLoss_eq_ambiguityDim_mul_log_two]
  simp

theorem toyDependentPair_retainedRatio :
    retainedDistinguishableMassRatio toyDependentPair = (1 : ℝ) / 2 := by
  norm_num [retainedDistinguishableMassRatio]

theorem toyDependentPair_exactLoss :
    exactLoss toyDependentPair = Real.log 2 := by
  rw [exactLoss_eq_ambiguityDim_mul_log_two]
  simp

theorem toyTripleRankOne_retainedRatio :
    retainedDistinguishableMassRatio toyTripleRankOne = (1 : ℝ) / 4 := by
  norm_num [retainedDistinguishableMassRatio]

theorem toyTripleRankOne_exactLoss :
    exactLoss toyTripleRankOne = 2 * Real.log 2 := by
  rw [exactLoss_eq_ambiguityDim_mul_log_two]
  norm_num

end

end Survival.LinearCodeErasureAccountingToy
