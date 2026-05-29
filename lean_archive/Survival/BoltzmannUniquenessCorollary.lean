import Survival.CompletenessTheorem
import Survival.RepresentationTheorem
import Survival.LogUniqueness
import Survival.TelescopingExp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# Boltzmann Entropy — Isothermal/Adiabatic Differentiation

Proves: S = k ln W is forced by the representation theorem,
AND differentiates isothermal from adiabatic processes via
their distinct mass sequences and stageLoss profiles.

This is not just "the same theorem as Shannon with different names."
The physical content is: isothermal and adiabatic processes have
different stageLoss profiles, even though both are forced to use
the log form. This differentiation is the physical content that
goes beyond Shannon.
-/
namespace Survival.BoltzmannUniquenessCorollary
open Real Survival Survival.TelescopingExp
noncomputable section

-- Part 1: The log form is forced (same as Shannon)

theorem boltzmann_uniqueness (f : ℝ → ℝ)
    (hf_nonneg : ∀ r, 0 < r → r ≤ 1 → 0 ≤ f r)
    (hf_add : IsLogAdditive f)
    (hf_cont : Continuous f) :
    ∃ k : ℝ, 0 ≤ k ∧ ∀ r, 0 < r → r ≤ 1 → f r = -k * log r :=
  log_ratio_uniqueness f hf_nonneg
    (CompletenessTheorem.b2_follows_from_b3 f hf_add) hf_add hf_cont

-- Part 2: Isothermal process (constant-rate mass decay)

/-- Isothermal mass sequence: at constant temperature, microstates
    decrease at a constant ratio per step (heat exchange maintains T). -/
def isothermalMass (W₀ ratio : ℝ) : ℕ → ℝ
  | 0 => W₀
  | n + 1 => isothermalMass W₀ ratio n * ratio

theorem isothermalMass_pos (W₀ r : ℝ) (hW : 0 < W₀) (hr : 0 < r) :
    ∀ n, 0 < isothermalMass W₀ r n := by
  intro n; induction n with
  | zero => exact hW
  | succ n ih => exact mul_pos ih hr

/-- Isothermal stageLoss is constant: -log(ratio) at every step. -/
theorem isothermal_stageLoss (W₀ r : ℝ) (hW : 0 < W₀) (hr : 0 < r) (n : ℕ) :
    stageLoss (isothermalMass W₀ r) n = -log r := by
  simp only [stageLoss, isothermalMass]
  rw [mul_div_cancel_left₀ _ (ne_of_gt (isothermalMass_pos W₀ r hW hr n))]

/-- Isothermal telescoping: W_n = W₀ × r^n = W₀ × exp(-n log(1/r)). -/
theorem isothermal_telescoping (W₀ r : ℝ) (hW : 0 < W₀) (hr : 0 < r) (n : ℕ) :
    isothermalMass W₀ r n = isothermalMass W₀ r 0 *
      exp (-∑ i ∈ Finset.range n, stageLoss (isothermalMass W₀ r) i) :=
  measure_eq_initial_mul_exp_neg_cumulative_loss _ n
    (fun i _ => isothermalMass_pos W₀ r hW hr i)

-- Part 3: Adiabatic process (decreasing-rate mass decay)

/-- Adiabatic mass sequence: without heat exchange, the accessible
    microstates decrease faster as the system cools.
    Each step's ratio depends on the step number (non-constant). -/
def adiabaticMass (W₀ : ℝ) (ratioFn : ℕ → ℝ) : ℕ → ℝ
  | 0 => W₀
  | n + 1 => adiabaticMass W₀ ratioFn n * ratioFn n

theorem adiabaticMass_pos (W₀ : ℝ) (ratioFn : ℕ → ℝ)
    (hW : 0 < W₀) (hr : ∀ n, 0 < ratioFn n) :
    ∀ n, 0 < adiabaticMass W₀ ratioFn n := by
  intro n; induction n with
  | zero => exact hW
  | succ n ih => exact mul_pos ih (hr n)

/-- Adiabatic stageLoss varies per step: -log(ratioFn(n)). -/
theorem adiabatic_stageLoss (W₀ : ℝ) (ratioFn : ℕ → ℝ)
    (hW : 0 < W₀) (hr : ∀ n, 0 < ratioFn n) (n : ℕ) :
    stageLoss (adiabaticMass W₀ ratioFn) n = -log (ratioFn n) := by
  simp only [stageLoss, adiabaticMass]
  rw [mul_div_cancel_left₀ _ (ne_of_gt (adiabaticMass_pos W₀ ratioFn hW hr n))]

/-- Adiabatic telescoping: same kernel, different stageLoss profile. -/
theorem adiabatic_telescoping (W₀ : ℝ) (ratioFn : ℕ → ℝ)
    (hW : 0 < W₀) (hr : ∀ n, 0 < ratioFn n) (n : ℕ) :
    adiabaticMass W₀ ratioFn n = adiabaticMass W₀ ratioFn 0 *
      exp (-∑ i ∈ Finset.range n, stageLoss (adiabaticMass W₀ ratioFn) i) :=
  measure_eq_initial_mul_exp_neg_cumulative_loss _ n
    (fun i _ => adiabaticMass_pos W₀ ratioFn hW hr i)

-- Part 4: The differentiation

/-- **Isothermal vs adiabatic: same log form, different stageLoss.**
    Isothermal: constant stageLoss (ratio fixed by temperature)
    Adiabatic: varying stageLoss (ratio changes as system evolves)

    This is the physical content that differentiates Boltzmann
    from Shannon: the stageLoss profile carries domain information
    (temperature, heat exchange) that Shannon's axioms don't see. -/
theorem isothermal_vs_adiabatic (W₀ r : ℝ) (ratioFn : ℕ → ℝ)
    (hW : 0 < W₀) (hr : 0 < r) (hrFn : ∀ n, 0 < ratioFn n)
    (n : ℕ) (hdiff : ratioFn n ≠ r) :
    stageLoss (isothermalMass W₀ r) n ≠
      stageLoss (adiabaticMass W₀ ratioFn) n := by
  rw [isothermal_stageLoss W₀ r hW hr, adiabatic_stageLoss W₀ ratioFn hW hrFn]
  intro h
  have hlog := neg_injective h  -- log(ratioFn n) = log r
  exact hdiff (Real.log_injOn_pos (Set.mem_Ioi.mpr (hrFn n))
    (Set.mem_Ioi.mpr hr) hlog.symm)

end
end Survival.BoltzmannUniquenessCorollary
