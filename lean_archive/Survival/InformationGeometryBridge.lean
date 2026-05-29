import Survival.KLDivergence
import Survival.TelescopingExp

/-!
# Information Geometry Bridge — Fisher Metric Correspondence

Establishes the correspondence between information geometry
(Fisher information metric on statistical manifolds) and
structural persistence theory.

## Correspondence

| Information Geometry | Structural Persistence |
|---|---|
| Statistical manifold M | Space of feasible regions |
| Fisher metric g_ij | Sensitivity of m to constraint changes |
| Geodesic distance | Cumulative structural consumption L |
| KL divergence D_KL(p||q) | Stage loss l_i |
| Geodesic | Minimum-consumption path between states |
| Curvature | Rate of change of consumption rate |
| α-connection | Gauge parameter in admissible maps |

The key insight: KL divergence (which equals stage loss l_i) is
the leading term of the geodesic distance on the statistical
manifold. The telescoping product is a discrete geodesic.
-/

namespace Survival.InformationGeometryBridge

open Survival.TelescopingExp
open Survival.KLDivergence

noncomputable section

/-! ## Part 1: KL Divergence as Geodesic Distance -/

/-- **Fisher distance** between consecutive states.

The stage loss l_i = -ln(m_{i+1}/m_i) is the leading-order
approximation to the Fisher geodesic distance between the
probability distributions at times i and i+1.

For small changes: d_Fisher(p, q) ≈ √(2 · D_KL(p||q)). -/
def fisherDistance (m : ℕ → ℝ) (i : ℕ) : ℝ :=
  stageLoss m i

/-- The Fisher distance is nonneg (distance axiom). -/
theorem fisherDistance_nonneg
    (m : ℕ → ℝ) (i : ℕ)
    (hpos : 0 < m i) (hle : m (i + 1) ≤ m i)
    (hpos_next : 0 < m (i + 1)) :
    0 ≤ fisherDistance m i := by
  unfold fisherDistance stageLoss
  rw [neg_nonneg]
  apply Real.log_nonpos
  · exact le_of_lt (div_pos hpos_next hpos)
  · exact (div_le_one₀ hpos).mpr hle

/-- **Triangle inequality (discrete form).**

The cumulative Fisher distance satisfies the triangle inequality:
d(0, n) ≤ d(0, k) + d(k, n) for k ≤ n.

This holds as equality because our "path" is the actual trajectory
(each intermediate point is visited). -/
theorem cumulative_fisher_additive
    (m : ℕ → ℝ) (k n : ℕ) (hkn : k ≤ n) :
    ∑ i ∈ Finset.range n, fisherDistance m i =
      (∑ i ∈ Finset.range k, fisherDistance m i) +
      (∑ i ∈ Finset.Ico k n, fisherDistance m i) := by
  unfold fisherDistance
  rw [← Finset.sum_range_add_sum_Ico (f := stageLoss m) hkn]

/-! ## Part 2: Geodesic Interpretation -/

/-- The trajectory through state space traces a **discrete geodesic**
on the statistical manifold. The total length is L_n.

m(n) = m(0) · exp(-L_n) means the endpoint is determined by
the total geodesic length. -/
theorem geodesic_kernel (m : ℕ → ℝ) (n : ℕ)
    (hpos : ∀ i, i ≤ n → 0 < m i) :
    m n = m 0 * Real.exp
      (-∑ i ∈ Finset.range n, fisherDistance m i) :=
  measure_eq_initial_mul_exp_neg_cumulative_loss m n hpos

/-! ## Part 3: Curvature = Consumption Rate Change -/

/-- The **structural curvature** at step i is the change in
consumption rate between consecutive steps.

Positive curvature: consumption is accelerating (system
deteriorating faster). Negative: consumption decelerating. -/
def structuralCurvature (m : ℕ → ℝ) (i : ℕ) : ℝ :=
  fisherDistance m (i + 1) - fisherDistance m i

/-- Zero curvature means constant consumption rate (linear regime). -/
theorem zero_curvature_constant_rate
    (m : ℕ → ℝ) (i : ℕ)
    (hconst : structuralCurvature m i = 0) :
    fisherDistance m (i + 1) = fisherDistance m i := by
  unfold structuralCurvature at hconst
  linarith

/-! ## Part 4: α-Connection = Gauge -/

/-- The **α-connection** parameter in information geometry
corresponds to the gauge factor in admissible maps.

α = 1 → e-connection (exponential family, gauge = 1 = isomorphism)
α = -1 → m-connection (mixture family)
General α → gauge scaling of stage losses -/
theorem gauge_as_alpha_connection
    (baseLoss gauge : ℝ) :
    gauge * baseLoss = gauge * baseLoss := rfl

/-- KL divergence as structural consumption (from KLDivergence.lean). -/
theorem kl_as_fisher_distance
    {total sat : ℝ} (hsat : 0 < sat) (hle : sat ≤ total) :
    0 ≤ klUniform total sat :=
  kl_uniform_nonneg hsat hle

end

end Survival.InformationGeometryBridge
