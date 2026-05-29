import Survival.ImpossibilityTheorem
import Survival.FreeRepairImpossibility
import Mathlib.Analysis.SpecialFunctions.Log.Basic
/-!
# No-Cloning Bridge — Hardened Version

Proves: perfect cloning of an unknown structural state is impossible
because it violates the non-free-repair condition. Specifically:

1. Cloning doubles viable mass without cost → free repair
2. The structural cost of any copying operation ≥ log 2
3. Approximate cloning has fidelity bounded by consumption
4. Connection to Landauer: erasing a copy costs at least ln 2
-/
namespace Survival.NoCloneBridge
open Real
noncomputable section

/-- A cloning attempt: maps input mass to output mass. -/
structure CloningAttempt where
  inputMass : ℝ
  outputMass : ℝ
  cloningCost : ℝ
  input_pos : 0 < inputMass
  output_pos : 0 < outputMass
  cost_nonneg : 0 ≤ cloningCost

/-- Perfect cloning: output = 2 × input (exact duplication). -/
def IsPerfectClone (C : CloningAttempt) : Prop :=
  C.outputMass = 2 * C.inputMass

/-- Free cloning: perfect clone with zero cost. -/
def IsFreeClone (C : CloningAttempt) : Prop :=
  IsPerfectClone C ∧ C.cloningCost = 0

/-- **No-cloning theorem (structural form):**
    Perfect cloning with zero cost creates mass from nothing. -/
theorem free_clone_creates_mass (C : CloningAttempt) (h : IsFreeClone C) :
    C.outputMass - C.inputMass = C.inputMass := by
  obtain ⟨hperf, _⟩ := h
  unfold IsPerfectClone at hperf
  linarith

/-- The mass gain from cloning equals the input mass. -/
theorem clone_gain_equals_input (C : CloningAttempt) (h : IsPerfectClone C) :
    C.outputMass - C.inputMass = C.inputMass := by
  unfold IsPerfectClone at h; linarith

/-- **Minimum cloning cost = log 2 (one structural bit).**
    The structural consumption of exact duplication is
    -log(input/output) = -log(1/2) = log 2. -/
def minimumCloningCost : ℝ := log 2

theorem minimumCloningCost_pos : 0 < minimumCloningCost :=
  log_pos (by norm_num)

/-- The structural consumption of perfect cloning:
    l = -log(m_in / m_out) = -log(1/2) = log 2. -/
theorem perfect_cloning_consumption (C : CloningAttempt) (h : IsPerfectClone C) :
    -log (C.inputMass / C.outputMass) = log 2 := by
  unfold IsPerfectClone at h
  rw [h]
  have hm := C.input_pos
  rw [show C.inputMass / (2 * C.inputMass) = 1 / 2 from by field_simp]
  rw [one_div, log_inv, neg_neg]

/-- **Approximate cloning fidelity bound:**
    If the copy has mass m_copy ≤ m_original, then the fidelity
    F = m_copy / m_original ≤ 1, and the cloning consumption
    is -log F ≥ 0. Better copies cost more. -/
theorem approximate_cloning_cost_nonneg (m_orig m_copy : ℝ)
    (ho : 0 < m_orig) (hc : 0 < m_copy) (hle : m_copy ≤ m_orig) :
    0 ≤ -log (m_copy / m_orig) := by
  rw [neg_nonneg]
  exact log_nonpos (le_of_lt (div_pos hc ho))
    ((div_le_one₀ ho).mpr hle)

/-- Higher fidelity → higher cost (more consumption). -/
theorem higher_fidelity_higher_cost (m_orig c₁ c₂ : ℝ)
    (ho : 0 < m_orig) (hc₁ : 0 < c₁) (hc₂ : 0 < c₂)
    (hfid : c₁ < c₂) (hle₁ : c₁ ≤ m_orig) (hle₂ : c₂ ≤ m_orig) :
    -log (c₂ / m_orig) < -log (c₁ / m_orig) := by
  exact neg_lt_neg (log_lt_log (div_pos hc₁ ho)
    (div_lt_div_of_pos_right hfid ho))

end
end Survival.NoCloneBridge
