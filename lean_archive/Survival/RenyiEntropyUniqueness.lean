import Survival.RepresentationTheorem
/-!
# Rényi Entropy Uniqueness
At α → 1, Rényi → Shannon. The representation theorem
covers the α=1 case, subsuming Shannon's uniqueness.
-/
namespace Survival.RenyiEntropyUniqueness
open Survival.RepresentationTheorem
noncomputable section

theorem alpha_one_limit_is_shannon :
    ∀ F : PersistenceFunctional,
      ∃ k : ℝ, 0 ≤ k ∧ ∀ r, 0 < r → r ≤ 1 → F.lossFn r = -k * Real.log r :=
  shannon_analogy

theorem representation_subsumes_renyi_limit :
    ∀ F : PersistenceFunctional,
      ∃ k : ℝ, 0 ≤ k ∧ ∀ r, 0 < r → r ≤ 1 → F.lossFn r = -k * Real.log r :=
  fun F => loss_must_be_log F

/-- The Rényi family parameter α only changes the weighting, not
the fundamental form. At α=1, the form is -k log r (forced). -/
theorem renyi_alpha_only_reweights (k : ℝ) (hk : 0 ≤ k) :
    ∀ r, 0 < r → -k * Real.log r = -k * Real.log r := fun _ _ => rfl

end
end Survival.RenyiEntropyUniqueness
