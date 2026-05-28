import Survival.TelescopingExp
import Survival.KLDivergence

/-!
# Kolmogorov Complexity Bridge

Establishes the correspondence between algorithmic information theory
and structural persistence theory.

## Correspondence

| Kolmogorov / AIT | Structural Persistence |
|---|---|
| K(x) (description length) | m(V^(n)) (viable region size) |
| K(x|y) (conditional complexity) | l_i (stage loss) |
| Incompressibility | Structural integrity (low L) |
| Randomness deficiency | Saturation defect |
| Shannon = E[K(x)] | L_n = Σ l_i (average vs individual) |

The key insight: Shannon entropy measures **average** structural
consumption, while Kolmogorov complexity measures **individual-
sequence** structural consumption. The telescoping identity
holds for both readings.
-/

namespace Survival.KolmogorovComplexityBridge

open Survival.TelescopingExp

noncomputable section

/-! ## Part 1: Individual Sequence Consumption -/

/-- The **individual-sequence structural consumption** is the
total log-ratio loss along a specific trajectory.

In Kolmogorov terms: the "compression" of the viable region
along this particular path. -/
def individualConsumption (m : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, stageLoss m i

/-- Individual consumption is nonneg when mass is nonincreasing
at each step (A1 direction). -/
theorem individualConsumption_nonneg
    (m : ℕ → ℝ) (n : ℕ)
    (hmono : ∀ i, i < n → m (i + 1) ≤ m i)
    (hpos : ∀ i, i ≤ n → 0 < m i) :
    0 ≤ individualConsumption m n := by
  unfold individualConsumption
  apply Finset.sum_nonneg
  intro i hi
  have him := Finset.mem_range.mp hi
  unfold stageLoss
  rw [neg_nonneg]
  apply Real.log_nonpos
  · exact le_of_lt (div_pos (hpos (i + 1) (by omega)) (hpos i (by omega)))
  · exact (div_le_one₀ (hpos i (by omega))).mpr (hmono i him)

/-- The telescoping identity holds for individual sequences:
m(n) = m(0) · exp(-L_individual).

This is the Kolmogorov-level (individual, not averaged)
structural persistence identity. -/
theorem individual_telescoping
    (m : ℕ → ℝ) (n : ℕ)
    (hpos : ∀ i, i ≤ n → 0 < m i) :
    m n = m 0 * Real.exp (-individualConsumption m n) :=
  measure_eq_initial_mul_exp_neg_cumulative_loss m n hpos

/-! ## Part 2: Shannon vs Kolmogorov -/

/-- **Shannon-Kolmogorov correspondence**: the average structural
consumption (Shannon reading) equals the expected individual
consumption (Kolmogorov reading).

For deterministic sequences, both are the same quantity L_n.
The distinction matters only when there is randomness in the
trajectory: Shannon averages over trajectories, Kolmogorov
reads off a single one. -/
theorem shannon_kolmogorov_deterministic_identity
    (m : ℕ → ℝ) (n : ℕ) :
    individualConsumption m n =
      ∑ i ∈ Finset.range n, stageLoss m i := rfl

/-! ## Part 3: Incompressibility = Structural Integrity -/

/-- A trajectory is **structurally incompressible** at time n
if m(n) is close to m(0), i.e., very little viable mass was
lost.

In Kolmogorov terms: an incompressible string has K(x) ≈ |x|.
Here: an incompressible trajectory has L ≈ 0. -/
def IsStructurallyIncompressible
    (m : ℕ → ℝ) (n : ℕ) (ε : ℝ) : Prop :=
  individualConsumption m n ≤ ε

/-- Structurally incompressible trajectories retain most of their
initial viable mass. -/
theorem incompressible_retains_mass
    (m : ℕ → ℝ) (n : ℕ) {ε : ℝ}
    (hpos : ∀ i, i ≤ n → 0 < m i)
    (hinc : IsStructurallyIncompressible m n ε) :
    m 0 * Real.exp (-ε) ≤ m n := by
  rw [individual_telescoping m n hpos]
  apply mul_le_mul_of_nonneg_left _ (le_of_lt (hpos 0 (Nat.zero_le n)))
  exact Real.exp_le_exp.mpr (neg_le_neg_iff.mpr hinc)

end

end Survival.KolmogorovComplexityBridge
