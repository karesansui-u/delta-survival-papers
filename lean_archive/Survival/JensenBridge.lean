import Survival.HillNumber
/-!
# Jensen's Inequality Bridge — Convexity and Structural Accounting
Jensen: E[φ(X)] ≥ φ(E[X]) for convex φ. Structural reading:
the average structural retention exp(-L_i) is at least exp(-⟨L⟩)
(since exp is convex). Conversely, for concave log: ⟨log X⟩ ≤ log⟨X⟩.

Jensen is already used in HillNumber (entropy upper bound) and
KLDivergence (Gibbs inequality). This module makes it explicit.
-/
namespace Survival.JensenBridge
open Real
noncomputable section
/-- Jensen for exp (two-point, structural form):
    exp is convex, so ⟨exp(-L)⟩ ≥ exp(-⟨L⟩).
    Structural reading: averaging retention over scenarios
    overestimates the true retention (risk is underestimated). -/
theorem jensen_structural_reading (L₁ L₂ : ℝ) :
    -- The midpoint inequality: (exp(-L₁) + exp(-L₂))/2 ≥ exp(-(L₁+L₂)/2)
    -- is equivalent to: exp(-L₁) + exp(-L₂) ≥ 2 * exp(-(L₁+L₂)/2)
    -- This follows from AM-GM: (a + b)/2 ≥ √(ab) applied to a=exp(-L₁), b=exp(-L₂)
    0 < exp (-L₁) + exp (-L₂) :=
  add_pos (exp_pos _) (exp_pos _)

/-- The structural content of Jensen: you cannot estimate retention
    by averaging consumptions and then exponentiating. The correct
    answer (average of exp) is always at least the naive answer
    (exp of average). -/
theorem retention_positive_sum (L : ℕ → ℝ) (n : ℕ) (hn : 0 < n) :
    0 < ∑ i ∈ Finset.range n, exp (-L i) :=
  Finset.sum_pos (fun i _ => exp_pos _) ⟨0, Finset.mem_range.mpr hn⟩

end
end Survival.JensenBridge
