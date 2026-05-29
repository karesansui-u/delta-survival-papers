import Survival.FiniteStateMarkovStationaryProduction
import Mathlib.Analysis.SpecificLimits.Basic

/-!
# Finite-State Markov Ergodic Production

This module adds a conservative expectation-level long-time law on top of the
finite-state stationary production layer.

It does **not** yet prove a full ergodic theorem. Instead, it formalizes the
first Cesaro-style step:

* choose a family of finite horizons whose active window always contains the
  prefix under study;
* normalize the stationary expected cumulative total production by prefix
  length;
* show an exact decomposition into the stationary mean production plus an
  initial-condition correction `s₀ / (n + 1)`;
* deduce convergence of the normalized expected cumulative production to the
  stationary mean.

This is the expectation-level bridge from finite-horizon collapse bounds to a
long-time "law of tendency".
-/

namespace Survival.FiniteStateMarkovErgodicProduction

open Filter
open Survival.MarkovRepairFailureExample
open Survival.FiniteStateMarkovRepairChain
open Survival.FiniteStateMarkovStationaryProduction

noncomputable section

/-- A family of finite horizons whose active window always contains the prefix
`0, ..., n`. This lets us formulate long-time averages while staying inside the
finite-horizon Markov path-space framework. -/
structure PrefixFamily where
  horizon : ℕ → ℕ
  active : ∀ n, n ≤ horizon n

/-- Prefix-normalized stationary expected cumulative total production. The
numerator is evaluated at time `n + 1`, so the denominator is always positive.
-/
def stationaryPrefixAverage
    (s₀ : ℝ) (H : PrefixFamily) (S : StationaryData M) (E : Emission)
    (n : ℕ) : ℝ :=
  (stationaryExpectedProcess (H.horizon n) s₀ S E).expectedCumulative (n + 1) /
    ((n : ℝ) + 1)

@[simp] theorem stationaryPrefixAverage_eq_mean_add_correction
    (s₀ : ℝ) (H : PrefixFamily) (S : StationaryData M) (E : Emission)
    (n : ℕ) :
    stationaryPrefixAverage s₀ H S E n =
      stationaryMean S E + s₀ / ((n : ℝ) + 1) := by
  unfold stationaryPrefixAverage
  have hn : n + 1 ≤ H.horizon n + 1 := Nat.succ_le_succ (H.active n)
  rw [stationaryExpectedCumulative_eq_initial_add_linear_of_le
      (N := H.horizon n) (s₀ := s₀) (S := S) (E := E) hn]
  norm_num
  have hden : (n : ℝ) + 1 ≠ 0 := by positivity
  field_simp [hden]
  ring

@[simp] theorem stationaryPrefixAverage_zero_initial
    (H : PrefixFamily) (S : StationaryData M) (E : Emission) (n : ℕ) :
    stationaryPrefixAverage 0 H S E n = stationaryMean S E := by
  simp

/-- Expectation-level long-time law under stationary start: the normalized
expected cumulative total production converges to the stationary mean
one-step total production. -/
theorem tendsto_stationaryPrefixAverage
    (s₀ : ℝ) (H : PrefixFamily) (S : StationaryData M) (E : Emission) :
    Tendsto (fun n : ℕ => stationaryPrefixAverage s₀ H S E n)
      atTop (nhds (stationaryMean S E)) := by
  have hden : Tendsto (fun n : ℕ => (n : ℝ) + 1) atTop atTop := by
    simpa using (tendsto_add_atTop_iff_nat 1).2 tendsto_natCast_atTop_atTop
  have hcorr : Tendsto (fun n : ℕ => s₀ / ((n : ℝ) + 1)) atTop (nhds 0) := by
    exact tendsto_const_nhds.div_atTop hden
  have hsum :
      Tendsto
        (fun n : ℕ => stationaryMean S E + s₀ / ((n : ℝ) + 1))
        atTop (nhds (stationaryMean S E + 0)) := by
    exact tendsto_const_nhds.add hcorr
  simpa [stationaryPrefixAverage_eq_mean_add_correction] using hsum

/-- Zero-initial-condition corollary: under stationary start, the normalized
expected cumulative total production is already exactly equal to the stationary
mean at every finite prefix. -/
theorem tendsto_stationaryPrefixAverage_zero_initial
    (H : PrefixFamily) (S : StationaryData M) (E : Emission) :
    Tendsto (fun n : ℕ => stationaryPrefixAverage 0 H S E n)
      atTop (nhds (stationaryMean S E)) := by
  simpa using tendsto_const_nhds

end

end Survival.FiniteStateMarkovErgodicProduction
