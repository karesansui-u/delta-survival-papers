import Survival.ClausiusBridge
/-!
# First Law Bridge — Energy Conservation as Accounting Closure
Reads thermodynamic first law (ΔU = Q - W) through structural
persistence: the total of consumption d_t and recovery r_t is
conserved within the accounting boundary. What enters the
boundary as resource must exit as either structural maintenance
or dissipation. The books must balance.

Structural first law: d_t + (M_{t+1} - M_t) = resource_input_t
(consumption + resource change = input)
-/
namespace Survival.FirstLawBridge
noncomputable section

structure FirstLawModel where
  resourceInput : ℕ → ℝ    -- external resource supply
  consumption : ℕ → ℝ       -- structural consumption d_t
  resourceChange : ℕ → ℝ    -- ΔM_t = M_{t+1} - M_t

/-- The first law: at each step, input = consumption + resource change.
    The books balance. -/
def SatisfiesFirstLaw (M : FirstLawModel) : Prop :=
  ∀ t, M.resourceInput t = M.consumption t + M.resourceChange t

/-- If the first law holds, consumption is bounded by input. -/
theorem consumption_bounded_by_input (M : FirstLawModel)
    (h : SatisfiesFirstLaw M) (t : ℕ)
    (hΔM : 0 ≤ M.resourceChange t) :
    M.consumption t ≤ M.resourceInput t := by
  have := h t
  linarith

/-- If the first law holds and no external input, consumption
    must come from stored resources (ΔM < 0). -/
theorem no_input_drains_resources (M : FirstLawModel)
    (h : SatisfiesFirstLaw M) (t : ℕ)
    (hzero : M.resourceInput t = 0)
    (hd : 0 < M.consumption t) :
    M.resourceChange t < 0 := by
  have := h t
  linarith

/-- Cumulative first law: total input = total consumption + net resource change. -/
theorem cumulative_first_law (M : FirstLawModel)
    (h : SatisfiesFirstLaw M) (n : ℕ) :
    ∑ t ∈ Finset.range n, M.resourceInput t =
      ∑ t ∈ Finset.range n, M.consumption t +
      ∑ t ∈ Finset.range n, M.resourceChange t := by
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl (fun t _ => h t)

end
end Survival.FirstLawBridge
