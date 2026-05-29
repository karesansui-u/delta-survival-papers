import Mathlib.Data.Nat.Choose.Sum
import Survival.CardinalitySATChernoffCollapse

/-!
# Threshold Cardinality-SAT as a Multi-Forbidden-Pattern CSP

This module extends the exactly-`r` cardinality-SAT layer to threshold
cardinality constraints:

* at-most-`r`-of-`k`, whose allowed local patterns are
  `sum_{i <= r} choose k i`;
* at-least-`r`-of-`k`, whose allowed local patterns are
  `sum_{r <= i <= k} choose k i`.

Both are routed through the same multi-forbidden-pattern witness interface.
Thus the existing finite path measure, MGF product, Chernoff/KL profile, and
collapse / stopped-collapse / hitting-time wrappers are reused without a new
probability proof.

The scope remains finite-horizon iid signed-clause exposure under a fixed
assignment.  Solver dynamics and overlapping-clause dependence are outside this
module.
-/

namespace Survival.ThresholdCardinalitySATChernoffCollapse

open MeasureTheory
open Survival.BernoulliCSPTemplate
open Survival.BernoulliCSPPathMeasure
open Survival.BernoulliCSPPathChernoff
open Survival.BernoulliCSPPathCollapse
open Survival.MultiForbiddenPatternCSP
open Survival.HighProbabilityCollapse
open Survival.StoppingTimeHighProbabilityCollapse
open Survival.StoppingTimeCollapseEvent

noncomputable section

/-- Number of local truth patterns in a signed `k`-clause. -/
def totalPatternCount (k : ℕ) : ℝ :=
  (2 : ℝ) ^ k

/-- Number of local truth patterns satisfying at-most-`r`-of-`k`. -/
def atMostAllowedPatternCount (k r : ℕ) : ℝ :=
  ∑ i ∈ Finset.range (r + 1), ((k.choose i : ℕ) : ℝ)

/-- Number of local truth patterns violating at-most-`r`-of-`k`. -/
def atMostForbiddenPatternCount (k r : ℕ) : ℝ :=
  totalPatternCount k - atMostAllowedPatternCount k r

/-- Number of local truth patterns satisfying at-least-`r`-of-`k`. -/
def atLeastAllowedPatternCount (k r : ℕ) : ℝ :=
  ∑ i ∈ Finset.Icc r k, ((k.choose i : ℕ) : ℝ)

/-- Number of local truth patterns violating at-least-`r`-of-`k`. -/
def atLeastForbiddenPatternCount (k r : ℕ) : ℝ :=
  totalPatternCount k - atLeastAllowedPatternCount k r

theorem atMostAllowedPatternCount_pos (k r : ℕ) :
    0 < atMostAllowedPatternCount k r := by
  unfold atMostAllowedPatternCount
  have hmem : 0 ∈ Finset.range (r + 1) := by simp
  have hsingle : ((k.choose 0 : ℕ) : ℝ) ≤
      ∑ i ∈ Finset.range (r + 1), ((k.choose i : ℕ) : ℝ) :=
    Finset.single_le_sum
      (f := fun i => ((k.choose i : ℕ) : ℝ))
      (s := Finset.range (r + 1))
      (fun i _ => by exact Nat.cast_nonneg (k.choose i)) hmem
  have hpos : (0 : ℝ) < ((k.choose 0 : ℕ) : ℝ) := by simp
  exact lt_of_lt_of_le hpos hsingle

theorem atMostAllowedPatternCount_lt_totalPatternCount
    (k r : ℕ) (hrk : r < k) :
    atMostAllowedPatternCount k r < totalPatternCount k := by
  unfold atMostAllowedPatternCount totalPatternCount
  have hsubset : Finset.range (r + 1) ⊆ Finset.range (k + 1) := by
    intro i hi
    simp at hi ⊢
    omega
  have hk_mem : k ∈ Finset.range (k + 1) := by simp
  have hk_not : k ∉ Finset.range (r + 1) := by
    simp
    omega
  have hpos : (0 : ℝ) < ((k.choose k : ℕ) : ℝ) := by simp
  have hnonneg :
      ∀ j ∈ Finset.range (k + 1), j ∉ Finset.range (r + 1) →
        (0 : ℝ) ≤ ((k.choose j : ℕ) : ℝ) := by
    intro j _ _
    exact Nat.cast_nonneg (k.choose j)
  have hstrict :=
    Finset.sum_lt_sum_of_subset hsubset hk_mem hk_not hpos hnonneg
  have hsum :
      (∑ i ∈ Finset.range (k + 1), ((k.choose i : ℕ) : ℝ)) =
        (2 : ℝ) ^ k := by
    exact_mod_cast (Nat.sum_range_choose k)
  simpa [hsum] using hstrict

theorem atMostForbiddenPatternCount_pos
    (k r : ℕ) (hrk : r < k) :
    0 < atMostForbiddenPatternCount k r := by
  unfold atMostForbiddenPatternCount
  exact sub_pos.mpr (atMostAllowedPatternCount_lt_totalPatternCount k r hrk)

theorem atMostForbiddenPatternCount_lt_totalPatternCount
    (k r : ℕ) :
    atMostForbiddenPatternCount k r < totalPatternCount k := by
  unfold atMostForbiddenPatternCount
  have hpos := atMostAllowedPatternCount_pos k r
  linarith

theorem atLeastAllowedPatternCount_pos
    {k r : ℕ} (hrk : r ≤ k) :
    0 < atLeastAllowedPatternCount k r := by
  unfold atLeastAllowedPatternCount
  have hmem : r ∈ Finset.Icc r k := by simp [hrk]
  have hsingle : ((k.choose r : ℕ) : ℝ) ≤
      ∑ i ∈ Finset.Icc r k, ((k.choose i : ℕ) : ℝ) :=
    Finset.single_le_sum
      (f := fun i => ((k.choose i : ℕ) : ℝ))
      (s := Finset.Icc r k)
      (fun i _ => by exact Nat.cast_nonneg (k.choose i)) hmem
  have hpos : (0 : ℝ) < ((k.choose r : ℕ) : ℝ) := by
    exact_mod_cast (Nat.choose_pos hrk)
  exact lt_of_lt_of_le hpos hsingle

theorem atLeastAllowedPatternCount_lt_totalPatternCount
    (k r : ℕ) (hrpos : 0 < r) :
    atLeastAllowedPatternCount k r < totalPatternCount k := by
  unfold atLeastAllowedPatternCount totalPatternCount
  have hsubset : Finset.Icc r k ⊆ Finset.range (k + 1) := by
    intro i hi
    simp at hi ⊢
    omega
  have h0_mem : 0 ∈ Finset.range (k + 1) := by simp
  have h0_not : 0 ∉ Finset.Icc r k := by
    simp
    omega
  have hpos : (0 : ℝ) < ((k.choose 0 : ℕ) : ℝ) := by simp
  have hnonneg :
      ∀ j ∈ Finset.range (k + 1), j ∉ Finset.Icc r k →
        (0 : ℝ) ≤ ((k.choose j : ℕ) : ℝ) := by
    intro j _ _
    exact Nat.cast_nonneg (k.choose j)
  have hstrict :=
    Finset.sum_lt_sum_of_subset hsubset h0_mem h0_not hpos hnonneg
  have hsum :
      (∑ i ∈ Finset.range (k + 1), ((k.choose i : ℕ) : ℝ)) =
        (2 : ℝ) ^ k := by
    exact_mod_cast (Nat.sum_range_choose k)
  simpa [hsum] using hstrict

theorem atLeastForbiddenPatternCount_pos
    (k r : ℕ) (hrpos : 0 < r) :
    0 < atLeastForbiddenPatternCount k r := by
  unfold atLeastForbiddenPatternCount
  exact sub_pos.mpr (atLeastAllowedPatternCount_lt_totalPatternCount k r hrpos)

theorem atLeastForbiddenPatternCount_lt_totalPatternCount
    {k r : ℕ} (hrk : r ≤ k) :
    atLeastForbiddenPatternCount k r < totalPatternCount k := by
  unfold atLeastForbiddenPatternCount
  have hpos := atLeastAllowedPatternCount_pos hrk
  linarith

/-- Domain witness for fixed-assignment random at-most-`r`-of-`k` exposure. -/
def atMostRSATWitness (k r : ℕ) (hrk : r < k) :
    Witness where
  alphabet := 2
  arity := k
  forbiddenCount := atMostForbiddenPatternCount k r
  alphabet_pos := by norm_num
  forbiddenCount_pos := atMostForbiddenPatternCount_pos k r hrk
  forbiddenCount_lt_total :=
    by simpa [totalPatternCount] using
      atMostForbiddenPatternCount_lt_totalPatternCount k r

/-- Domain witness for fixed-assignment random at-least-`r`-of-`k` exposure. -/
def atLeastRSATWitness
    (k r : ℕ) (hrpos : 0 < r) (hrk : r ≤ k) :
    Witness where
  alphabet := 2
  arity := k
  forbiddenCount := atLeastForbiddenPatternCount k r
  alphabet_pos := by norm_num
  forbiddenCount_pos := atLeastForbiddenPatternCount_pos k r hrpos
  forbiddenCount_lt_total :=
    by simpa [totalPatternCount] using
      atLeastForbiddenPatternCount_lt_totalPatternCount hrk

/-- Bernoulli-CSP parameters generated by the at-most-`r` witness. -/
def atMostRSATParameters (k r : ℕ) (hrk : r < k) :
    Parameters :=
  (atMostRSATWitness k r hrk).parameters

/-- Bernoulli-CSP parameters generated by the at-least-`r` witness. -/
def atLeastRSATParameters
    (k r : ℕ) (hrpos : 0 < r) (hrk : r ≤ k) :
    Parameters :=
  (atLeastRSATWitness k r hrpos hrk).parameters

/-- Bad-event probability for fixed-assignment at-most-`r`-of-`k` exposure. -/
def atMostRSATBadProb (k r : ℕ) : ℝ :=
  atMostForbiddenPatternCount k r / totalPatternCount k

/-- Bad-event probability for fixed-assignment at-least-`r`-of-`k` exposure. -/
def atLeastRSATBadProb (k r : ℕ) : ℝ :=
  atLeastForbiddenPatternCount k r / totalPatternCount k

theorem atMostRSATParameters_badProb
    (k r : ℕ) (hrk : r < k) :
    (atMostRSATParameters k r hrk).badProb = atMostRSATBadProb k r := rfl

theorem atLeastRSATParameters_badProb
    (k r : ℕ) (hrpos : 0 < r) (hrk : r ≤ k) :
    (atLeastRSATParameters k r hrpos hrk).badProb =
      atLeastRSATBadProb k r := rfl

/-- Mean one-step information-production drift for at-most-`r`-of-`k`. -/
def atMostRSATDrift (k r : ℕ) (hrk : r < k) : ℝ :=
  (atMostRSATWitness k r hrk).drift

/-- Mean one-step information-production drift for at-least-`r`-of-`k`. -/
def atLeastRSATDrift
    (k r : ℕ) (hrpos : 0 < r) (hrk : r ≤ k) : ℝ :=
  (atLeastRSATWitness k r hrpos hrk).drift

theorem atMostRSATDrift_eq_log_ratio
    (k r : ℕ) (hrk : r < k) :
    atMostRSATDrift k r hrk =
      Real.log (totalPatternCount k / atMostAllowedPatternCount k r) := by
  rw [atMostRSATDrift, (atMostRSATWitness k r hrk).drift_eq_log_ratio]
  congr 2
  simp [
    atMostRSATWitness,
    Witness.totalPatternCount,
    atMostForbiddenPatternCount,
    totalPatternCount,
  ]

theorem atLeastRSATDrift_eq_log_ratio
    (k r : ℕ) (hrpos : 0 < r) (hrk : r ≤ k) :
    atLeastRSATDrift k r hrpos hrk =
      Real.log (totalPatternCount k / atLeastAllowedPatternCount k r) := by
  rw [atLeastRSATDrift, (atLeastRSATWitness k r hrpos hrk).drift_eq_log_ratio]
  congr 2
  simp [
    atLeastRSATWitness,
    Witness.totalPatternCount,
    atLeastForbiddenPatternCount,
    totalPatternCount,
  ]

theorem atMostRSATDrift_pos (k r : ℕ) (hrk : r < k) :
    0 < atMostRSATDrift k r hrk :=
  (atMostRSATWitness k r hrk).drift_pos

theorem atLeastRSATDrift_pos
    (k r : ℕ) (hrpos : 0 < r) (hrk : r ≤ k) :
    0 < atLeastRSATDrift k r hrpos hrk :=
  (atLeastRSATWitness k r hrpos hrk).drift_pos

def atMostCountChernoffFailureBound (k r : ℕ) (hrk : r < k) :
    CountFailureProfile :=
  (atMostRSATWitness k r hrk).countChernoffFailureBound

def atLeastCountChernoffFailureBound
    (k r : ℕ) (hrpos : 0 < r) (hrk : r ≤ k) :
    CountFailureProfile :=
  (atLeastRSATWitness k r hrpos hrk).countChernoffFailureBound

def atMostPathMeasure (k r : ℕ) (hrk : r < k) (N : ℕ) :
    Measure (Trajectory N) :=
  (atMostRSATWitness k r hrk).pathMeasure N

def atLeastPathMeasure
    (k r : ℕ) (hrpos : 0 < r) (hrk : r ≤ k) (N : ℕ) :
    Measure (Trajectory N) :=
  (atLeastRSATWitness k r hrpos hrk).pathMeasure N

instance instIsProbabilityMeasureAtMostPathMeasure
    (k r : ℕ) (hrk : r < k) (N : ℕ) :
    IsProbabilityMeasure (atMostPathMeasure k r hrk N) := by
  dsimp [atMostPathMeasure]
  infer_instance

instance instIsProbabilityMeasureAtLeastPathMeasure
    (k r : ℕ) (hrpos : 0 < r) (hrk : r ≤ k) (N : ℕ) :
    IsProbabilityMeasure (atLeastPathMeasure k r hrpos hrk N) := by
  dsimp [atLeastPathMeasure]
  infer_instance

def atMostProcess (k r : ℕ) (hrk : r < k) (N : ℕ) (s₀ : ℝ) :=
  (atMostRSATWitness k r hrk).process N s₀

def atLeastProcess
    (k r : ℕ) (hrpos : 0 < r) (hrk : r ≤ k) (N : ℕ) (s₀ : ℝ) :=
  (atLeastRSATWitness k r hrpos hrk).process N s₀

theorem atMostCollapseWithChernoffBound_of_linearMargin
    (k r : ℕ) (hrk : r < k)
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1)
    {s₀ θ margin : ℝ}
    (hmargin_nonneg : 0 ≤ margin)
    (hlt : margin < (n : ℝ) * atMostRSATDrift k r hrk)
    (hθ : 0 < θ)
    (hthreshold :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter
          (atMostRSATParameters k r hrk) s₀ n - margin) :
    CollapseWithFailureBound
      (μ := atMostPathMeasure k r hrk N)
      (atMostProcess k r hrk N s₀)
      n θ
      (atMostCountChernoffFailureBound k r hrk n margin) := by
  simpa [
    atMostPathMeasure,
    atMostProcess,
    atMostCountChernoffFailureBound,
    atMostRSATParameters,
    atMostRSATDrift,
  ] using
    (atMostRSATWitness k r hrk).collapseWithChernoffBound_of_linearMargin
      N hn hmargin_nonneg (by simpa [atMostRSATDrift] using hlt) hθ hthreshold

theorem atLeastCollapseWithChernoffBound_of_linearMargin
    (k r : ℕ) (hrpos : 0 < r) (hrk : r ≤ k)
    (N : ℕ) {n : ℕ} (hn : n ≤ N + 1)
    {s₀ θ margin : ℝ}
    (hmargin_nonneg : 0 ≤ margin)
    (hlt : margin < (n : ℝ) * atLeastRSATDrift k r hrpos hrk)
    (hθ : 0 < θ)
    (hthreshold :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter
          (atLeastRSATParameters k r hrpos hrk) s₀ n - margin) :
    CollapseWithFailureBound
      (μ := atLeastPathMeasure k r hrpos hrk N)
      (atLeastProcess k r hrpos hrk N s₀)
      n θ
      (atLeastCountChernoffFailureBound k r hrpos hrk n margin) := by
  simpa [
    atLeastPathMeasure,
    atLeastProcess,
    atLeastCountChernoffFailureBound,
    atLeastRSATParameters,
    atLeastRSATDrift,
  ] using
    (atLeastRSATWitness k r hrpos hrk).collapseWithChernoffBound_of_linearMargin
      N hn hmargin_nonneg (by simpa [atLeastRSATDrift] using hlt) hθ hthreshold

theorem atMostStoppedCollapseWithChernoffBound_of_linearMargin
    (k r : ℕ) (hrk : r < k)
    (N : ℕ) {T : ℕ} (hT : T ≤ N + 1)
    {s₀ θ margin : ℝ}
    (hmargin_nonneg : 0 ≤ margin)
    (hlt : margin < (T : ℝ) * atMostRSATDrift k r hrk)
    (hθ : 0 < θ)
    (hthreshold :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter
          (atMostRSATParameters k r hrk) s₀ T - margin) :
    StoppedCollapseWithFailureBound
      (μ := atMostPathMeasure k r hrk N)
      (atMostProcess k r hrk N s₀)
      T θ
      (atMostCountChernoffFailureBound k r hrk T margin) := by
  simpa [
    atMostPathMeasure,
    atMostProcess,
    atMostCountChernoffFailureBound,
    atMostRSATParameters,
    atMostRSATDrift,
  ] using
    (atMostRSATWitness k r hrk).stoppedCollapseWithChernoffBound_of_linearMargin
      N hT hmargin_nonneg (by simpa [atMostRSATDrift] using hlt) hθ hthreshold

theorem atLeastStoppedCollapseWithChernoffBound_of_linearMargin
    (k r : ℕ) (hrpos : 0 < r) (hrk : r ≤ k)
    (N : ℕ) {T : ℕ} (hT : T ≤ N + 1)
    {s₀ θ margin : ℝ}
    (hmargin_nonneg : 0 ≤ margin)
    (hlt : margin < (T : ℝ) * atLeastRSATDrift k r hrpos hrk)
    (hθ : 0 < θ)
    (hthreshold :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter
          (atLeastRSATParameters k r hrpos hrk) s₀ T - margin) :
    StoppedCollapseWithFailureBound
      (μ := atLeastPathMeasure k r hrpos hrk N)
      (atLeastProcess k r hrpos hrk N s₀)
      T θ
      (atLeastCountChernoffFailureBound k r hrpos hrk T margin) := by
  simpa [
    atLeastPathMeasure,
    atLeastProcess,
    atLeastCountChernoffFailureBound,
    atLeastRSATParameters,
    atLeastRSATDrift,
  ] using
    (atLeastRSATWitness k r hrpos hrk).stoppedCollapseWithChernoffBound_of_linearMargin
      N hT hmargin_nonneg (by simpa [atLeastRSATDrift] using hlt) hθ hthreshold

theorem atMostHittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
    (k r : ℕ) (hrk : r < k)
    (N : ℕ) {j T : ℕ} (hjT : j < T)
    (hj : j ≤ N + 1) {s₀ θ margin : ℝ}
    (hmargin_nonneg : 0 ≤ margin)
    (hlt : margin < (j : ℝ) * atMostRSATDrift k r hrk)
    (hthreshold :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter
          (atMostRSATParameters k r hrk) s₀ j - margin) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := atMostPathMeasure k r hrk N)
      (atMostProcess k r hrk N s₀)
      T θ
      (atMostCountChernoffFailureBound k r hrk j margin) := by
  simpa [
    atMostPathMeasure,
    atMostProcess,
    atMostCountChernoffFailureBound,
    atMostRSATParameters,
    atMostRSATDrift,
  ] using
    (atMostRSATWitness k r hrk).hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
      N hjT hj hmargin_nonneg (by simpa [atMostRSATDrift] using hlt) hthreshold

theorem atLeastHittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
    (k r : ℕ) (hrpos : 0 < r) (hrk : r ≤ k)
    (N : ℕ) {j T : ℕ} (hjT : j < T)
    (hj : j ≤ N + 1) {s₀ θ margin : ℝ}
    (hmargin_nonneg : 0 ≤ margin)
    (hlt : margin < (j : ℝ) * atLeastRSATDrift k r hrpos hrk)
    (hthreshold :
      -Real.log θ ≤
        BernoulliCSPPathChernoff.linearCenter
          (atLeastRSATParameters k r hrpos hrk) s₀ j - margin) :
    HittingTimeBeforeHorizonWithFailureBound
      (μ := atLeastPathMeasure k r hrpos hrk N)
      (atLeastProcess k r hrpos hrk N s₀)
      T θ
      (atLeastCountChernoffFailureBound k r hrpos hrk j margin) := by
  simpa [
    atLeastPathMeasure,
    atLeastProcess,
    atLeastCountChernoffFailureBound,
    atLeastRSATParameters,
    atLeastRSATDrift,
  ] using
    (atLeastRSATWitness k r hrpos hrk).hittingTimeBeforeHorizonWithChernoffBound_of_linearMargin
      N hjT hj hmargin_nonneg (by simpa [atLeastRSATDrift] using hlt) hthreshold

end

end Survival.ThresholdCardinalitySATChernoffCollapse
