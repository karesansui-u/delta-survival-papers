import Survival.LinearCodeErasureAccountingToy
import Mathlib.Tactic.NormNum

/-!
# BEC Rank Boundary

This module records the deterministic converse side of the BEC erasure-rank
operational anchor.

It does not use a random parity-check ensemble, a BEC concentration argument, or
an empirical proxy.  The statement is the finite linear-algebra fact that if the
number of erased coordinates exceeds the number of available parity-check rows,
then the erased-column submatrix cannot have full column rank.  In the
`LinearCodeErasureAccountingToy` coordinates this means positive ambiguity,
positive exact loss, and non-unique recovery.
-/

namespace Survival.LinearCodeBECRankBoundary

open Survival.LinearCodeErasureAccountingToy

noncomputable section

/-- A BEC erasure profile together with the number of parity-check rows.

`checkRows` is the row count `r` of the parity-check matrix.  The only additional
linear-algebra input needed for the deterministic converse is
`rank(H_E) <= r`. -/
structure BECConverseProfile where
  erasure : ErasureRankProfile
  checkRows : ℕ
  rank_le_checkRows : erasure.erasedRank ≤ checkRows

/-- The erased set exceeds the available parity-check row budget. -/
def exceedsCheckRows (P : BECConverseProfile) : Prop :=
  P.checkRows < P.erasure.erasedCount

/-- If `|E| > r`, then `rank(H_E) < |E|`. -/
theorem rankDeficient_of_exceedsCheckRows
    (P : BECConverseProfile) (h : exceedsCheckRows P) :
    rankDeficient P.erasure := by
  unfold exceedsCheckRows at h
  unfold rankDeficient
  exact lt_of_le_of_lt P.rank_le_checkRows h

/-- If `|E| > r`, then the ambiguity dimension is positive. -/
theorem ambiguityDim_pos_of_exceedsCheckRows
    (P : BECConverseProfile) (h : exceedsCheckRows P) :
    0 < ambiguityDim P.erasure := by
  exact (ambiguityDim_pos_iff_rankDeficient P.erasure).2
    (rankDeficient_of_exceedsCheckRows P h)

/-- Deterministic BEC converse: erasing more coordinates than parity-check rows
precludes unique recovery. -/
theorem not_uniquelyRecoverable_of_exceedsCheckRows
    (P : BECConverseProfile) (h : exceedsCheckRows P) :
    ¬ uniquelyRecoverable P.erasure := by
  exact (rankDeficient_iff_not_uniquelyRecoverable P.erasure).1
    (rankDeficient_of_exceedsCheckRows P h)

/-- In the same regime, the exact structural loss is strictly positive. -/
theorem exactLoss_pos_of_exceedsCheckRows
    (P : BECConverseProfile) (h : exceedsCheckRows P) :
    0 < exactLoss P.erasure := by
  exact exactLoss_pos_of_rankDeficient P.erasure
    (rankDeficient_of_exceedsCheckRows P h)

/-- A wording closer to coding theory: if `r = n - k` and `|E| > r`, unique
recovery is impossible. -/
theorem not_uniquelyRecoverable_of_erasedCount_gt_redundancy
    {n k : ℕ} (P : BECConverseProfile)
    (hr : P.checkRows = n - k)
    (h : n - k < P.erasure.erasedCount) :
    ¬ uniquelyRecoverable P.erasure := by
  apply not_uniquelyRecoverable_of_exceedsCheckRows P
  unfold exceedsCheckRows
  rwa [hr]

/-- A tiny over-row-budget toy profile. -/
def toyOverCheckRows : BECConverseProfile where
  erasure := toyTripleRankOne
  checkRows := 2
  rank_le_checkRows := by norm_num [toyTripleRankOne]

theorem toyOverCheckRows_exceedsCheckRows :
    exceedsCheckRows toyOverCheckRows := by
  norm_num [exceedsCheckRows, toyOverCheckRows, toyTripleRankOne]

theorem toyOverCheckRows_not_uniquelyRecoverable :
    ¬ uniquelyRecoverable toyOverCheckRows.erasure := by
  exact not_uniquelyRecoverable_of_exceedsCheckRows
    toyOverCheckRows toyOverCheckRows_exceedsCheckRows

theorem toyOverCheckRows_exactLoss_pos :
    0 < exactLoss toyOverCheckRows.erasure := by
  exact exactLoss_pos_of_exceedsCheckRows
    toyOverCheckRows toyOverCheckRows_exceedsCheckRows

end

end Survival.LinearCodeBECRankBoundary
