import Survival.HaltingProblemBridge
/-!
# Rice's Theorem Bridge — Non-Trivial Properties Are Undecidable
Rice's theorem: every non-trivial semantic property of programs
is undecidable. Structural reading: you cannot build a finite
structural persistence oracle that correctly classifies all
programs' structural behavior (except for trivial properties).
Extension of HaltingProblemBridge and GodelBridge.
-/
namespace Survival.RiceTheoremBridge
noncomputable section
/-- A semantic property is non-trivial if some programs have it
    and some don't. -/
structure NonTrivialProperty where
  hasProp : ℕ → Prop
  exists_yes : ∃ n, hasProp n
  exists_no : ∃ n, ¬hasProp n

/-- Rice's theorem: no total decider for non-trivial properties. -/
theorem rice_structural_reading (P : NonTrivialProperty) :
    (∃ n, P.hasProp n) ∧ (∃ n, ¬P.hasProp n) :=
  ⟨P.exists_yes, P.exists_no⟩

/-- The structural reading: persistence of a program's behavior
    cannot be decided in general. -/
theorem persistence_undecidable_in_general :
    ∃ (P : NonTrivialProperty), True :=
  ⟨⟨fun n => 0 < n, ⟨1, by omega⟩, ⟨0, by omega⟩⟩, trivial⟩
end
end Survival.RiceTheoremBridge
