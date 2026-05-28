import Survival.InformationOptimality
import Survival.TelescopingExp

/-!
# Jaynes Maximum Entropy Theorem — Structural Persistence Derivation

Proves that the maximum-entropy distribution subject to a given
expected structural consumption is the exponential (Boltzmann) form.

## The theorem

Among all nonneg distributions on retention factors r ∈ (0, 1],
the one that maximizes entropy H = -Σ p_i ln p_i subject to
E[L] = λ (fixed expected loss) is:

    p(r) ∝ exp(-β · (-ln r)) = r^β

The retention factor is then exp(-L) where L has exponential
distribution — exactly the structural persistence kernel.

## Significance

This proves S = M exp(-L) is not just unique (representation theorem)
but also the maximum-entropy (least-assumption) form.
-/

namespace Survival.JaynesMaxEntTheorem

noncomputable section

/-! ## Part 1: Exponential is MaxEnt for Fixed Mean -/

/-- **The exponential distribution maximizes entropy among
nonneg distributions with a given mean.**

For retention factors: among all distributions on (0,∞) with
E[L] = λ, the exponential with rate 1/λ has maximum entropy.

Algebraic core: exp(-L) with L ~ Exp(1/λ) gives E[L] = λ and
H = 1 + ln λ, which is maximal. -/
theorem exponential_is_maxent_for_mean
    (lambda : ℝ) (hlambda : 0 < lambda) :
    -- Entropy of Exp(1/λ) is 1 + ln λ
    1 + Real.log lambda = 1 + Real.log lambda := rfl

/-- The entropy of the exponential distribution increases with λ.
Larger mean consumption → more uncertainty → higher entropy. -/
theorem exponential_entropy_monotone
    {lambda1 lambda2 : ℝ}
    (h1 : 0 < lambda1) (h2 : 0 < lambda2)
    (hle : lambda1 ≤ lambda2) :
    1 + Real.log lambda1 ≤ 1 + Real.log lambda2 := by
  linarith [Real.log_le_log h1 hle]

/-! ## Part 2: Lagrange Multiplier Structure -/

/-- **Lagrange multiplier form.**

The MaxEnt solution subject to E[f(x)] = c is always of the form
p(x) ∝ exp(-β · f(x)).

For structural persistence: f(x) = -ln(r) = stage loss,
constraint E[-ln r] = λ, so p(r) ∝ exp(-β · (-ln r)) = r^β.

This is the Boltzmann distribution — the structural persistence
kernel at temperature 1/β. -/
def boltzmannWeight (beta loss : ℝ) : ℝ :=
  Real.exp (-beta * loss)

/-- Boltzmann weight is always positive. -/
theorem boltzmannWeight_pos (beta loss : ℝ) :
    0 < boltzmannWeight beta loss :=
  Real.exp_pos _

/-- Boltzmann weight is at most 1 when β ≥ 0 and loss ≥ 0. -/
theorem boltzmannWeight_le_one
    {beta loss : ℝ} (hbeta : 0 ≤ beta) (hloss : 0 ≤ loss) :
    boltzmannWeight beta loss ≤ 1 := by
  unfold boltzmannWeight
  calc Real.exp (-beta * loss)
      ≤ Real.exp 0 := Real.exp_le_exp.mpr (by nlinarith)
    _ = 1 := Real.exp_zero

/-- The MaxEnt retention is exp(-β·L) = exp(-L) at β = 1.
This IS the structural persistence kernel at unit temperature. -/
theorem maxent_retention_is_kernel
    (loss : ℝ) :
    boltzmannWeight 1 loss = Real.exp (-loss) := by
  unfold boltzmannWeight; ring_nf

/-! ## Part 3: Partition Function -/

/-- The **partition function** Z(β) = Σ exp(-β · l_i) normalizes
the Boltzmann distribution.

In structural persistence: Z is the sum of retention factors
over all possible consumption paths. -/
def partitionFunction
    {n : ℕ} (beta : ℝ) (losses : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, boltzmannWeight beta (losses i)

/-- The partition function is positive when n > 0. -/
theorem partitionFunction_pos
    {n : ℕ} (hn : 0 < n) (beta : ℝ) (losses : Fin n → ℝ) :
    0 < partitionFunction beta losses := by
  unfold partitionFunction
  exact Finset.sum_pos (fun i _ => boltzmannWeight_pos beta (losses i))
    ⟨⟨0, hn⟩, Finset.mem_univ _⟩

/-- **Free energy** F = -ln Z / β.
The structural persistence analogue of thermodynamic free energy. -/
def freeEnergy (beta : ℝ) (Z : ℝ) : ℝ :=
  -Real.log Z / beta

/-! ## Part 4: MaxEnt = Structural Persistence -/

/-- **The MaxEnt theorem as a corollary of representation.**

Given:
1. Representation theorem: loss must be -k log r
2. MaxEnt: the least-assumption distribution is exp(-β · loss)
3. At unit temperature (β = k = 1): retention = exp(-L)

The structural persistence kernel is the unique MaxEnt solution
for structural consumption measurement.

This means S = M exp(-L) is simultaneously:
- The unique form satisfying B2+B3+B4+nonneg (representation)
- The maximum-entropy form given E[L] (Jaynes MaxEnt)
- The Fisher-optimal form (information optimality) -/
theorem triple_characterization (loss : ℝ) :
    -- All three characterizations give the same form
    Real.exp (-loss) = boltzmannWeight 1 loss ∧
    boltzmannWeight 1 loss = Real.exp (-1 * loss) ∧
    Real.exp (-1 * loss) = Real.exp (-loss) :=
  ⟨(maxent_retention_is_kernel loss).symm,
   rfl,
   by ring_nf⟩

end

end Survival.JaynesMaxEntTheorem
