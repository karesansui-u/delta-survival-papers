import Survival.BinarySymmetricChannel
import Survival.KLDivergence

/-!
# Channel Capacity Bridge — Shannon's Information Theory Connection

This module provides the G6-b correspondence (not full G6-c embedding)
between Shannon's channel capacity and structural persistence theory.

## Information-theoretic context

Shannon (1948) defined the channel capacity C as:

    C = max_{p(x)} I(X; Y)

For a binary symmetric channel with error probability p:

    C_BSC = 1 - H(p) = 1 + p log₂(p) + (1-p) log₂(1-p)

## Structural-persistence reading

We identify:
- **Reliable communication rate** ≡ sustainable structural-persistence
  rate: the maximum rate at which structural information can be
  maintained against noise/degradation
- **Symbol loss** `-ln(1-p)` from BSC ≡ per-step structural consumption `l_i`
- **Block success probability** `(1-p)^n` ≡ `exp(-L)` retention factor

The key insight: Shannon's coding theorem says that below capacity,
reliable communication is possible. In structural-persistence terms,
this means there exist coding strategies (= repair/recovery mechanisms)
that keep structural consumption below the sustainable threshold.

This module does NOT prove Shannon's coding theorem in Lean. It records:
1. The per-symbol structural loss reading of BSC parameters
2. The capacity as a structural-persistence rate boundary
3. The KL divergence correspondence (δ = D_KL)

References:
  - Shannon, C.E. (1948). "A mathematical theory of communication."
    Bell System Tech. J. 27, 379-423 & 623-656.
  - BinarySymmetricChannel.lean: BSC skeleton
  - KLDivergence.lean: δ = D_KL correspondence
-/

namespace Survival.ChannelCapacityBridge

open Real

noncomputable section

/-! ## Part 1: Binary Entropy and Capacity -/

/-- Binary entropy function H(p) = -p ln(p) - (1-p) ln(1-p). -/
def binaryEntropy (p : ℝ) : ℝ :=
  -(p * log p + (1 - p) * log (1 - p))

/-- Binary entropy at 0 is 0 (by convention 0 ln 0 = 0). -/
theorem binaryEntropy_zero : binaryEntropy 0 = 0 := by
  unfold binaryEntropy
  simp [log_one]

/-- Binary entropy at 1/2 is ln 2 (maximum uncertainty). -/
theorem binaryEntropy_half :
    binaryEntropy (1/2) = log 2 := by
  unfold binaryEntropy
  have h : (1 : ℝ) - 1 / 2 = 1 / 2 := by ring
  rw [h]
  have hlog : log (1/2) = -log 2 := by
    rw [one_div, log_inv]
  rw [hlog]
  ring

/-- Channel capacity of BSC in nats: C = ln 2 - H(p).
    (In bits, this would be 1 - H₂(p).) -/
def bscCapacity (C : Survival.BinarySymmetricChannel.System) : ℝ :=
  log 2 - binaryEntropy C.errorRate

/-! ## Part 2: Structural Persistence Reading -/

/-- The sustainable structural-persistence rate: the per-symbol
    rate at which structural information can be reliably maintained.

    For a BSC, this equals the channel capacity. Below this rate,
    there exist coding strategies (repair mechanisms) that keep
    exp(-L) bounded away from zero. Above this rate, structural
    collapse (exp(-L) → 0) is inevitable. -/
def sustainableRate (C : Survival.BinarySymmetricChannel.System) : ℝ :=
  bscCapacity C

/-- The per-symbol structural consumption (already defined in BSC). -/
def perSymbolConsumption (C : Survival.BinarySymmetricChannel.System) : ℝ :=
  Survival.BinarySymmetricChannel.symbolLoss C

/-- Per-symbol consumption equals -ln(1-p). -/
theorem perSymbolConsumption_eq
    (C : Survival.BinarySymmetricChannel.System) :
    perSymbolConsumption C = -log (1 - C.errorRate) := rfl

/-- Per-symbol consumption is nonneg (since 1-p ≤ 1). -/
theorem perSymbolConsumption_nonneg
    (C : Survival.BinarySymmetricChannel.System) :
    0 ≤ perSymbolConsumption C := by
  unfold perSymbolConsumption Survival.BinarySymmetricChannel.symbolLoss
  rw [neg_nonneg]
  exact log_nonpos (le_of_lt (Survival.BinarySymmetricChannel.symbolSuccess_pos C))
    (Survival.BinarySymmetricChannel.symbolSuccess_le_one C)

/-! ## Part 3: Rate–Collapse Boundary -/

/-- The structural interpretation of being above capacity:
    if the information rate exceeds channel capacity, then
    per-block structural consumption grows linearly with block length,
    causing exp(-L_n) → 0.

    More precisely: for an uncoded BSC, L_n = n * (-ln(1-p)),
    which grows linearly, so the retention factor exp(-L_n) = (1-p)^n → 0.
    This is the structural-persistence reading of "communication above
    capacity is unreliable." -/
theorem uncoded_consumption_linear
    (C : Survival.BinarySymmetricChannel.System) (n : ℕ) :
    Survival.BinarySymmetricChannel.cumulativeLoss C n =
      (n : ℝ) * perSymbolConsumption C := rfl

/-- The uncoded retention factor equals the block success probability. -/
theorem uncoded_retention_eq_blockSuccess
    (C : Survival.BinarySymmetricChannel.System) (n : ℕ) :
    exp (-(Survival.BinarySymmetricChannel.cumulativeLoss C n)) =
      Survival.BinarySymmetricChannel.blockSuccessProbability C n :=
  Survival.BinarySymmetricChannel.exp_neg_cumulativeLoss_eq_blockSuccessProbability C n

/-! ## Part 4: KL Divergence as Structural Consumption -/

/-- The correspondence between δ (structural consumption density) and
    KL divergence: for independent constraints,
    δ = D_KL(P_constrained || P_uniform).

    This is formalized in KLDivergence.lean. Here we record the
    structural-persistence reading: each constraint reduces the viable
    set by a factor that is exactly measured by the KL divergence. -/
theorem kl_as_structural_consumption
    {total sat : ℝ} (htotal : 0 < total) (hsat : 0 < sat)
    (hle : sat ≤ total) :
    Survival.KLDivergence.klUniform total sat =
      log total - log sat := by
  unfold Survival.KLDivergence.klUniform
  exact log_div (ne_of_gt htotal) (ne_of_gt hsat)

/-- Structural consumption from constraint imposition is nonneg
    (Gibbs' inequality). -/
theorem kl_structural_consumption_nonneg
    {total sat : ℝ} (hsat : 0 < sat) (hle : sat ≤ total) :
    0 ≤ Survival.KLDivergence.klUniform total sat :=
  Survival.KLDivergence.kl_uniform_nonneg hsat hle

end

end Survival.ChannelCapacityBridge
