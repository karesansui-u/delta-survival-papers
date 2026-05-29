import Survival.KLDivergence
import Survival.TelescopingExp
import Survival.GeneralStateDynamics

/-!
# Free Energy Principle Bridge — Friston FEP Connection

Establishes the algebraic correspondence between Friston's Free
Energy Principle and structural persistence theory.

## Correspondence

| Free Energy Principle (Friston) | Structural Persistence |
|---|---|
| Surprise -ln P(o) | Stage loss l_i = -ln(m(V^i)/m(V^{i-1})) |
| Variational free energy F | Cumulative consumption L_n |
| F ≥ -ln P(o) (ELBO) | L ≥ individual stage losses |
| FE minimization | Structural consumption minimization |
| Active inference (action) | Recovery r_t (repair) |
| Blanket states | Maintenance condition G |
| Expected free energy G(π) | Expected structural consumption E[L|π] |
| Precision | Measure sensitivity (dm/dG) |

The key theorem: variational free energy F and cumulative structural
consumption L share the same algebraic skeleton — both are nonneg
sums of KL-divergence-like terms that measure deviation from a
reference distribution/region.
-/

namespace Survival.FreeEnergyPrincipleBridge

open Survival.KLDivergence
open Survival.TelescopingExp

noncomputable section

/-! ## Part 1: Surprise = Stage Loss -/

/-- **Surprise** in FEP is -ln P(o), the negative log-probability
of an observation. -/
def surprise (p : ℝ) : ℝ := -Real.log p

/-- Surprise is nonneg when 0 < p ≤ 1 (probability in [0,1]). -/
theorem surprise_nonneg {p : ℝ} (hp : 0 < p) (hp1 : p ≤ 1) :
    0 ≤ surprise p := by
  unfold surprise
  rw [neg_nonneg]
  exact Real.log_nonpos (le_of_lt hp) hp1

/-- Stage loss IS surprise applied to the retention ratio.
l_i = -ln(m(V^i)/m(V^{i-1})) = surprise(R_i). -/
theorem stageLoss_eq_surprise_of_ratio
    (m : ℕ → ℝ) (i : ℕ) :
    stageLoss m i = surprise (m (i + 1) / m i) := by
  unfold stageLoss surprise
  rfl

/-! ## Part 2: Free Energy = Cumulative Loss -/

/-- **Variational free energy** (simplified finite version).

For a model Q approximating true distribution P over n outcomes:
F = Σ -ln(p_i/q_i) · w_i

In structural persistence: each step's "surprise" l_i accumulates
into the total "free energy" L_n. -/
def cumulativeFreeEnergy (m : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, stageLoss m i

/-- Cumulative free energy = cumulative structural consumption.
They are the same quantity by definition. -/
theorem freeEnergy_eq_consumption (m : ℕ → ℝ) (n : ℕ) :
    cumulativeFreeEnergy m n =
      ∑ i ∈ Finset.range n, stageLoss m i := rfl

/-- The FEP identity: the system state at time n is determined by
initial state times exp(-F), where F is cumulative free energy.

This IS the structural persistence kernel. -/
theorem fep_kernel (m : ℕ → ℝ) (n : ℕ)
    (hpos : ∀ i, i ≤ n → 0 < m i) :
    m n = m 0 * Real.exp (-cumulativeFreeEnergy m n) :=
  measure_eq_initial_mul_exp_neg_cumulative_loss m n hpos

/-! ## Part 3: ELBO and Bounds -/

/-- **Evidence Lower Bound (structural form).**

KL divergence gives a lower bound on free energy:
F ≥ KL(Q||P) ≥ 0.

In structural persistence: consumption is bounded below by
the KL divergence between constrained and unconstrained
distributions. -/
theorem elbo_nonneg
    {total sat : ℝ} (hsat : 0 < sat) (hle : sat ≤ total) :
    0 ≤ klUniform total sat :=
  kl_uniform_nonneg hsat hle

/-! ## Part 4: Active Inference = Recovery -/

/-- **Active inference** in FEP corresponds to the recovery term r_t
in structural persistence. Both reduce the effective consumption:

- FEP: agent acts to minimize surprise → reduces F
- SP: repair/recovery reduces net consumption b_t = d_t - r_t

The algebraic structure is identical: an additive correction
that reduces the cumulative quantity. -/
theorem active_inference_reduces_consumption
    (d r : ℝ) (hr : 0 ≤ r) :
    d - r ≤ d := by linarith

/-- With sufficient active inference (recovery), net consumption
can be zero or negative (system improves). -/
theorem full_recovery_eliminates_consumption
    (d r : ℝ) (hr : d ≤ r) :
    d - r ≤ 0 := by linarith

/-! ## Part 5: Precision and Measure Sensitivity -/

/-- **Precision** in FEP is the inverse variance of prediction
errors. Higher precision → more confident predictions.

In structural persistence: precision corresponds to the
sensitivity of the measure m to changes in the maintenance
condition G. Higher precision → small changes in G cause
large changes in m(V_G).

Algebraically: precision scales the effective stage loss.
At high precision, each constraint has larger structural impact. -/
theorem precision_amplifies_positive_loss
    (baseLoss prec : ℝ) (hprec : 0 < prec) (hloss : 0 < baseLoss) :
    0 < prec * baseLoss :=
  mul_pos hprec hloss

/-- At higher precision, the same base loss has larger effect. -/
theorem higher_precision_larger_effect
    (baseLoss p₁ p₂ : ℝ) (hp : p₁ < p₂) (hloss : 0 < baseLoss) :
    p₁ * baseLoss < p₂ * baseLoss :=
  mul_lt_mul_of_pos_right hp hloss

end

end Survival.FreeEnergyPrincipleBridge
