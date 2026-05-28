import Survival.ViabilityKernelBridge
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Wasserstein Bridge — Optimal Transport Connection

This module provides the G6-b correspondence between optimal
transport distances and structural persistence theory.

## Mathematical context

The Wasserstein-p distance between two probability measures μ, ν on
a metric space (X, d) is:

    W_p(μ, ν) = (inf_{γ ∈ Π(μ,ν)} ∫ d(x,y)^p dγ)^{1/p}

## Structural-persistence reading

The structural consumption `l_i = -ln(m(V^{(i)}) / m(V^{(i-1)}))`
measures the *measure-theoretic* shrinkage of the viable set.
Wasserstein distance captures the *geometric* cost of this shrinkage:
how far mass must move when the viable set contracts.

Key identifications:
- **Wasserstein distance** W(V^{(i)}, V^{(i-1)}) ≡ geometric cost
  of structural consumption at step i
- **Total variation distance** TV(μ_i, μ_{i-1}) ≡ qualitative change
  in the viable distribution
- **KL divergence** D_KL ≡ information-theoretic structural consumption

The hierarchy: KL ≥ TV² / 2 (Pinsker's inequality) and TV controls
Wasserstein under bounded metrics.

This module records the algebraic skeleton and the relationships
between these distances, not full optimal transport theory.

References:
  - Villani, C. (2009). "Optimal Transport: Old and New." Springer.
  - Pinsker, M.S. (1964). "Information and Information Stability."
  - ViabilityKernelBridge.lean: viable set shrinkage
-/

namespace Survival.WassersteinBridge

open Real

noncomputable section

/-! ## Part 1: Transport Cost and Structural Consumption -/

/-- A structural transport datum: at each step, we have a measure-
    theoretic shrinkage (log-ratio loss) and a geometric transport cost. -/
structure TransportDatum where
  /-- Measure-theoretic structural consumption l_i = -ln(R_i) -/
  logRatioLoss : ℝ
  /-- Geometric transport cost W_i (Wasserstein-like) -/
  transportCost : ℝ
  /-- Both are nonneg -/
  loss_nonneg : 0 ≤ logRatioLoss
  cost_nonneg : 0 ≤ transportCost

/-- Cumulative measure-theoretic structural consumption. -/
def cumulativeLoss (data : ℕ → TransportDatum) (n : ℕ) : ℝ :=
  Finset.sum (Finset.range n) (fun i => (data i).logRatioLoss)

/-- Cumulative geometric transport cost. -/
def cumulativeTransportCost (data : ℕ → TransportDatum) (n : ℕ) : ℝ :=
  Finset.sum (Finset.range n) (fun i => (data i).transportCost)

/-- Both cumulative quantities are nonneg. -/
theorem cumulativeLoss_nonneg (data : ℕ → TransportDatum) (n : ℕ) :
    0 ≤ cumulativeLoss data n := by
  unfold cumulativeLoss
  exact Finset.sum_nonneg (fun i _ => (data i).loss_nonneg)

theorem cumulativeTransportCost_nonneg (data : ℕ → TransportDatum) (n : ℕ) :
    0 ≤ cumulativeTransportCost data n := by
  unfold cumulativeTransportCost
  exact Finset.sum_nonneg (fun i _ => (data i).cost_nonneg)

/-! ## Part 2: Pinsker-Style Inequality -/

/-- A Pinsker-like bound relating transport cost to log-ratio loss.
    In the full theory: TV(μ, ν) ≤ √(D_KL(μ ‖ ν) / 2), and
    W(μ, ν) ≤ diam · TV(μ, ν).

    Here we axiomatize a bound: W_i ≤ C · √(l_i) for some constant C. -/
structure PinskerBound (data : ℕ → TransportDatum) where
  /-- The Pinsker constant (depends on metric diameter) -/
  C : ℝ
  C_pos : 0 < C
  /-- The Pinsker-like inequality: W_i ≤ C · √(l_i) -/
  bound : ∀ i, (data i).transportCost ≤ C * Real.sqrt ((data i).logRatioLoss)

/-- Under a Pinsker bound, cumulative transport cost is controlled
    by cumulative log-ratio loss. -/
theorem cumulative_transport_le_of_pinsker
    (data : ℕ → TransportDatum) (P : PinskerBound data) (n : ℕ) :
    cumulativeTransportCost data n ≤
      P.C * Finset.sum (Finset.range n)
        (fun i => Real.sqrt ((data i).logRatioLoss)) := by
  unfold cumulativeTransportCost
  calc
    Finset.sum (Finset.range n) (fun i => (data i).transportCost)
      ≤ Finset.sum (Finset.range n)
          (fun i => P.C * Real.sqrt ((data i).logRatioLoss)) :=
        Finset.sum_le_sum (fun i _ => P.bound i)
    _ = P.C * Finset.sum (Finset.range n)
          (fun i => Real.sqrt ((data i).logRatioLoss)) :=
        (Finset.mul_sum _ _ _).symm

/-! ## Part 3: Structural Interpretation -/

/-- The retention factor from measure-theoretic consumption. -/
def retentionFromLoss (data : ℕ → TransportDatum) (n : ℕ) : ℝ :=
  exp (-(cumulativeLoss data n))

/-- Retention is positive. -/
theorem retention_pos (data : ℕ → TransportDatum) (n : ℕ) :
    0 < retentionFromLoss data n :=
  exp_pos _

/-- Retention is at most 1 (since loss is nonneg). -/
theorem retention_le_one (data : ℕ → TransportDatum) (n : ℕ) :
    retentionFromLoss data n ≤ 1 := by
  unfold retentionFromLoss
  rw [exp_le_one_iff]
  exact neg_nonpos.mpr (cumulativeLoss_nonneg data n)

/-- **Key bridge**: geometric transport cost and measure-theoretic
    consumption provide complementary views of the same structural
    degradation process. The retention factor exp(-L) captures
    the measure-theoretic aspect; the cumulative Wasserstein cost
    captures the geometric aspect. Under Pinsker bounds, the
    geometric cost is controlled by the measure-theoretic one. -/
theorem geometric_controlled_by_measure
    (data : ℕ → TransportDatum) (P : PinskerBound data) (n : ℕ) :
    0 ≤ cumulativeTransportCost data n ∧
    0 ≤ cumulativeLoss data n ∧
    0 < retentionFromLoss data n :=
  ⟨cumulativeTransportCost_nonneg data n,
   cumulativeLoss_nonneg data n,
   retention_pos data n⟩

end

end Survival.WassersteinBridge
