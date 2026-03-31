/-
Multi-Attractor Extension — Basin Partition and Basin-Local Survival
多重アトラクター拡張 — 盆地分割と盆地局所的存続

Extends the single-attractor survival equation to systems with multiple
attractor basins. Each basin has its own survival potential S_j, and
transitions occur when one basin's S drops below another's.

New axioms (extending A1-A3):
  (A4) Basin partition: finite partition of state space into attractor basins
  (A5) Basin-local survival: A1-A3 hold within each basin independently
  (A6-weak) Statistical max-survival: populations asymptotically migrate
            to higher-S basins (follows from ArrowOfTime H-theorem)

Core insight: the same physical constraint has different information loss
in different basins. This is structurally identical to the SAT result
where random 3-clauses (I = ln(8/7)) and XOR pairs (I = ln(2)) have
different per-constraint costs.

References:
  - Paper 1, Section 2: Three axioms → survival equation
  - ArrowOfTime.lean: H-theorem (statistical basis for A6-weak)
  - Penalty.lean: FullSurvival N_eff δ μ μ_c (single-basin case)
  - Landau, L.D. (1937): first-order phase transition structure
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Survival.Basic
import Survival.Penalty
import Survival.AxiomsToExp

open Real

namespace Survival.MultiAttractor

noncomputable section

/-! ## Basin Definition -/

/-- An attractor basin with its own survival parameters.
    Decomposes the pre-exponential factor C = N_eff × (μ/μ_c) to maintain
    compatibility with Penalty.FullSurvival. -/
structure Basin where
  N_eff : ℝ   -- effective dispersion (number of viable configurations)
  μ : ℝ       -- resource margin
  μ_c : ℝ     -- critical margin
  hN : 0 < N_eff
  hμ : 0 < μ
  hμc : 0 < μ_c

/-- Pre-exponential factor C = N_eff × (μ/μ_c).
    Corresponds to Entropy × MarginRatio in Penalty.lean. -/
def Basin.C (b : Basin) : ℝ := b.N_eff * (b.μ / b.μ_c)

theorem Basin.C_pos (b : Basin) : 0 < b.C := by
  unfold Basin.C
  exact mul_pos b.hN (div_pos b.hμ b.hμc)

/-! ## General Basin Survival (non-uniform constraints) -/

/-- General basin survival: S = C × exp(-δ)
    where δ = Σᵢ I_j(cᵢ) is the basin-specific cumulative information loss.
    This is Penalty.FullSurvival expressed in the multi-attractor setting:
    S = N_eff × exp(-δ) × (μ/μ_c) = C × exp(-δ). -/
def basinSurvival (b : Basin) (δ : ℝ) : ℝ :=
  b.C * exp (-δ)

/-- Basin survival is always positive (C > 0 and exp > 0). -/
theorem basinSurvival_pos (b : Basin) (δ : ℝ) :
    0 < basinSurvival b δ := by
  exact mul_pos b.C_pos (exp_pos _)

/-- Basin survival at zero information loss equals C.
    No constraints → full survival potential. -/
theorem basinSurvival_zero (b : Basin) :
    basinSurvival b 0 = b.C := by
  unfold basinSurvival
  simp

/-- Basin survival decreases as information loss accumulates. -/
theorem basinSurvival_antitone (b : Basin) {δ₁ δ₂ : ℝ} (hδ : δ₁ < δ₂) :
    basinSurvival b δ₂ < basinSurvival b δ₁ := by
  unfold basinSurvival
  apply mul_lt_mul_of_pos_left _ b.C_pos
  exact exp_strictMono (by linarith)

/-- Basin survival is bounded above by C (since exp(-δ) ≤ 1 for δ ≥ 0). -/
theorem basinSurvival_le_C (b : Basin) {δ : ℝ} (hδ : 0 ≤ δ) :
    basinSurvival b δ ≤ b.C := by
  unfold basinSurvival
  have h : exp (-δ) ≤ exp 0 := exp_le_exp_of_le (by linarith)
  rw [exp_zero] at h
  exact mul_le_of_le_one_right (le_of_lt b.C_pos) h

/-! ## Connection to existing Penalty.FullSurvival -/

/-- Basin survival equals FullSurvival from Penalty.lean.
    This bridges the multi-attractor and single-attractor frameworks. -/
theorem basinSurvival_eq_fullSurvival (b : Basin) (δ : ℝ) :
    basinSurvival b δ = Penalty.FullSurvival b.N_eff δ b.μ b.μ_c := by
  unfold basinSurvival Penalty.FullSurvival Penalty.Entropy
    Penalty.Negentropy Penalty.MarginRatio Basin.C
  ring

/-! ## Uniform Constraints (special case: closed-form transition) -/

/-- Under the uniform constraint assumption, all constraints have the
    same per-constraint information loss I within a basin.
    Then δ = m × I where m is the number of constraints. -/
def uniformBasinSurvival (b : Basin) (I m : ℝ) : ℝ :=
  b.C * exp (-m * I)

/-- Uniform basin survival is a special case of general basin survival
    with δ = m × I. -/
theorem uniformBasinSurvival_eq (b : Basin) (I m : ℝ) :
    uniformBasinSurvival b I m = basinSurvival b (m * I) := by
  unfold uniformBasinSurvival basinSurvival
  congr 1; ring

/-- Uniform basin survival is positive. -/
theorem uniformBasinSurvival_pos (b : Basin) (I m : ℝ) :
    0 < uniformBasinSurvival b I m := by
  rw [uniformBasinSurvival_eq]
  exact basinSurvival_pos b _

/-- Uniform basin survival decreases in m when I > 0. -/
theorem uniformBasinSurvival_decreasing_in_m (b : Basin) {I : ℝ} (hI : 0 < I)
    {m₁ m₂ : ℝ} (hm : m₁ < m₂) :
    uniformBasinSurvival b I m₂ < uniformBasinSurvival b I m₁ := by
  rw [uniformBasinSurvival_eq, uniformBasinSurvival_eq]
  exact basinSurvival_antitone b (by nlinarith)

/-! ## Two-Basin Dominance -/

/-- Basin A dominates basin B at information losses (δ_A, δ_B) when
    S_A > S_B. -/
def dominates (A B : Basin) (δ_A δ_B : ℝ) : Prop :=
  basinSurvival B δ_B < basinSurvival A δ_A

/-- Dominance is determined by C × exp(-δ) comparison. -/
theorem dominates_iff (A B : Basin) (δ_A δ_B : ℝ) :
    dominates A B δ_A δ_B ↔ B.C * exp (-δ_B) < A.C * exp (-δ_A) := by
  unfold dominates basinSurvival
  exact Iff.rfl

end

end Survival.MultiAttractor
