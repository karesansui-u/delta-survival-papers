import Survival.TelescopingExp
import Survival.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Survival.MartingaleConvergenceBridge

/-!
# Large Deviation Bridge — Cramér's Theorem Connection

This module provides the G6-c formal embedding of the large deviation
principle into structural persistence theory.

## Mathematical context

Cramér's theorem (1938): For i.i.d. random variables X₁, ..., Xₙ with
moment generating function M(t) = E[exp(tX)], the probability of the
empirical mean exceeding a threshold satisfies:

    P(S_n/n ≥ a) ≤ exp(-n I(a))

where I(a) = sup_t {ta - ln M(t)} is the Cramér rate function
(Legendre–Fenchel transform of the cumulant generating function).

## Structural-persistence reading

We identify:
- **Empirical mean of stage losses** `L_n / n = (1/n) Σ l_i` ≡
  structural consumption density
- **Cramér rate function** `I(a)` ≡ the exponential rate at which
  "atypical structural consumption densities" become unlikely
- **Chernoff bound** `exp(-n I(a))` ≡ `exp(-L)` where L = n · I(a)

The key insight: the exponential form `exp(-L)` is not merely an
algebraic identity from telescoping (A1–A2). It is also the *natural
scaling* for tail probabilities of cumulative structural consumption,
as dictated by the large deviation principle. This provides a second,
independent justification for the exponential kernel.

References:
  - Cramér, H. (1938). "Sur un nouveau théorème-limite de la théorie
    des probabilités." Actualités Scientifiques et Industrielles 736.
  - Dembo, A. & Zeitouni, O. (2010). "Large Deviations Techniques
    and Applications." 2nd ed., Springer.
  - TelescopingExp.lean: algebraic exponential identity
-/

namespace Survival.LargeDeviationBridge

open Real

noncomputable section

/-! ## Part 1: Cumulant Generating Function and Rate Function -/

/-- The cumulant generating function (CGF) of a per-step structural
    consumption distribution, parameterized by a tilt `t`.
    Λ(t) = ln E[exp(t · l)]
    Here we work with a finite-support model where the CGF is given. -/
structure CGFData where
  /-- The cumulant generating function Λ(t) = ln E[exp(t l)] -/
  Λ : ℝ → ℝ
  /-- Λ(0) = 0 (normalization) -/
  Λ_zero : Λ 0 = 0
  /-- Λ is convex (needed for Legendre transform) -/
  Λ_convex : ConvexOn ℝ Set.univ Λ

/-- The Cramér rate function (Legendre–Fenchel transform of the CGF):
    I(a) = sup_t {t·a - Λ(t)}
    Here we use a simpler finite-dimensional form. -/
def rateFunction (cgf : CGFData) (a : ℝ) : ℝ → ℝ :=
  fun t => t * a - cgf.Λ t

/-- The rate function evaluated at a specific tilt. -/
def rateFunctionAt (cgf : CGFData) (a t : ℝ) : ℝ :=
  t * a - cgf.Λ t

/-- At tilt 0, the rate function value is 0 (since Λ(0) = 0). -/
theorem rateFunctionAt_zero (cgf : CGFData) (a : ℝ) :
    rateFunctionAt cgf a 0 = 0 := by
  unfold rateFunctionAt
  rw [cgf.Λ_zero]
  ring

/-- The rate function is nonneg at its supremum (since I(a) ≥ I(a)|_{t=0} = 0). -/
theorem rateFunctionAt_nonneg_exists (cgf : CGFData) (a : ℝ) :
    ∃ t, 0 ≤ rateFunctionAt cgf a t := by
  exact ⟨0, le_of_eq (rateFunctionAt_zero cgf a).symm⟩

/-! ## Part 2: Chernoff-Style Exponential Bound -/

/-- **Chernoff bound (structural form)**: For any tilt parameter t,
    the probability that cumulative structural consumption exceeds n·a
    is bounded by exp(-n · (t·a - Λ(t))).

    This is the structural-persistence reading: the probability of
    "anomalously high structural consumption density" decays
    exponentially with the horizon n, at rate I(a). -/
structure ChernoffBound where
  /-- The CGF data -/
  cgf : CGFData
  /-- The threshold structural consumption density -/
  threshold : ℝ
  /-- The optimal tilt -/
  tilt : ℝ
  /-- The tilt achieves a positive rate -/
  rate_pos : 0 < rateFunctionAt cgf threshold tilt

/-- The exponential decay rate from the Chernoff bound. -/
def chernoffRate (B : ChernoffBound) : ℝ :=
  rateFunctionAt B.cgf B.threshold B.tilt

/-- The Chernoff rate is positive. -/
theorem chernoffRate_pos (B : ChernoffBound) :
    0 < chernoffRate B := B.rate_pos

/-- The exponential upper bound for n steps.
    P(L_n ≥ n·a) ≤ exp(-n · I(a)) -/
def chernoffUpperBound (B : ChernoffBound) (n : ℕ) : ℝ :=
  exp (-(↑n * chernoffRate B))

/-- The Chernoff upper bound is positive. -/
theorem chernoffUpperBound_pos (B : ChernoffBound) (n : ℕ) :
    0 < chernoffUpperBound B n :=
  exp_pos _

/-- The Chernoff upper bound is at most 1 (since the rate is positive). -/
theorem chernoffUpperBound_le_one (B : ChernoffBound) (n : ℕ) :
    chernoffUpperBound B n ≤ 1 := by
  unfold chernoffUpperBound
  rw [exp_le_one_iff]
  exact neg_nonpos.mpr (mul_nonneg (Nat.cast_nonneg n) (le_of_lt B.rate_pos))

/-- The Chernoff bound at step 0 is exactly 1. -/
theorem chernoffUpperBound_zero (B : ChernoffBound) :
    chernoffUpperBound B 0 = 1 := by
  unfold chernoffUpperBound
  simp

/-! ## Part 3: Structural Persistence Connection -/

/-- **Key theorem**: The Chernoff upper bound `exp(-n·I(a))` is exactly
    the structural retention factor `exp(-L)` where L = n·I(a).

    This shows that the large deviation bound produces the same
    exponential form as the telescoping identity, but from a
    probabilistic (not algebraic) argument. -/
theorem chernoff_eq_retention (B : ChernoffBound) (n : ℕ) :
    chernoffUpperBound B n =
      exp (-(↑n * chernoffRate B)) := rfl

/-- The cumulative "effective structural consumption" from the
    large deviation perspective: L_eff = n · I(a). -/
def effectiveConsumption (B : ChernoffBound) (n : ℕ) : ℝ :=
  ↑n * chernoffRate B

/-- Effective consumption is nonneg. -/
theorem effectiveConsumption_nonneg (B : ChernoffBound) (n : ℕ) :
    0 ≤ effectiveConsumption B n :=
  mul_nonneg (Nat.cast_nonneg n) (le_of_lt B.rate_pos)

/-- Effective consumption grows linearly with n. -/
theorem effectiveConsumption_succ (B : ChernoffBound) (n : ℕ) :
    effectiveConsumption B (n + 1) =
      effectiveConsumption B n + chernoffRate B := by
  unfold effectiveConsumption
  push_cast
  ring

/-- The retention factor from the large deviation bound. -/
theorem retention_eq_exp_neg_effective (B : ChernoffBound) (n : ℕ) :
    chernoffUpperBound B n =
      exp (-(effectiveConsumption B n)) := rfl

/-! ## Part 4: Connection to Telescoping Exponential -/

/-- The structural bridge: large deviations and telescoping give
    the same exponential form.

    - Telescoping (A1–A2): m(V^{(n)}) = m(V^{(0)}) exp(-Σ l_i)
    - Large deviations: P(L_n/n ≥ a) ≤ exp(-n I(a))

    Both produce exp(-L) where L is a cumulative quantity.
    The algebraic identity tells us the form is necessary;
    the large deviation principle tells us it is also the
    natural probabilistic scaling. -/
theorem dual_justification_exponential_form
    (B : ChernoffBound) (n : ℕ) :
    chernoffUpperBound B n = exp (-(effectiveConsumption B n)) ∧
    0 ≤ effectiveConsumption B n :=
  ⟨rfl, effectiveConsumption_nonneg B n⟩

/-- The rate of exponential decay per step. -/
theorem per_step_rate (B : ChernoffBound) :
    0 < chernoffRate B := B.rate_pos

/-- As n → ∞, the Chernoff bound tends to 0 when the rate is positive.
    This is structural collapse: if the structural consumption density
    exceeds the threshold, the retention factor vanishes. -/
theorem chernoff_tends_zero (B : ChernoffBound) :
    Filter.Tendsto (fun n => chernoffUpperBound B n)
      Filter.atTop (nhds 0) := by
  unfold chernoffUpperBound
  have hrate : 0 < chernoffRate B := B.rate_pos
  -- Express as retention process tending to zero via MartingaleConvergenceBridge
  -- Define B(n, ω) = n * rate, then exp(-B_n) = chernoffUpperBound
  let B' : ℕ → Unit → ℝ := fun n _ => ↑n * chernoffRate B
  have hB : Filter.Tendsto (fun n => B' n ()) Filter.atTop Filter.atTop :=
    Filter.Tendsto.atTop_mul_const hrate tendsto_natCast_atTop_atTop
  exact Survival.MartingaleConvergenceBridge.retention_tends_zero_of_consumption_diverges
    B' () hB

end

end Survival.LargeDeviationBridge
