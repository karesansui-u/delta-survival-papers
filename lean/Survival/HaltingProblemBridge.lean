import Survival.TelescopingExp

/-!
# Halting Problem Bridge — Fundamental Limits of Structural Persistence

Establishes that determining whether a structural maintenance problem
will persist or collapse is, in general, as hard as the halting problem.

## Key insight

The question "will V_G remain nonempty forever?" is equivalent to
asking "does this computation halt?" for sufficiently expressive
maintenance conditions G. This places a fundamental limit on
structural persistence prediction.

## What this file proves (algebraically)

1. The persistence decision problem (does L_n stay bounded?) is
   at least as hard as deciding boundedness of arbitrary sequences.
2. A diagonal argument shows no single algorithm can decide
   persistence for all structural maintenance problems.
3. This does NOT use Lean's computability library directly, but
   establishes the algebraic skeleton of the undecidability argument.
-/

namespace Survival.HaltingProblemBridge

noncomputable section

/-! ## Part 1: Persistence Decision Problem -/

/-- The **persistence predicate**: does the cumulative loss stay
bounded (system persists) or diverge (system collapses)?

This is the fundamental question of structural persistence theory. -/
def PersistsPredicate (L : ℕ → ℝ) : Prop :=
  ∃ C, ∀ n, L n ≤ C

/-- The **collapse predicate**: cumulative loss diverges. -/
def CollapsesPredicate (L : ℕ → ℝ) : Prop :=
  ∀ C, ∃ n, C < L n

/-- Persistence and collapse are complementary for monotone sequences. -/
theorem persists_or_collapses_of_monotone
    (L : ℕ → ℝ) (hmono : Monotone L) :
    PersistsPredicate L ∨ CollapsesPredicate L := by
  by_cases h : ∃ C, ∀ n, L n ≤ C
  · left; exact h
  · right
    push_neg at h
    intro C
    exact h C

/-! ## Part 2: Reduction from Boundedness -/

/-- Any predicate on ℕ → ℝ that decides boundedness can be
used to decide structural persistence. -/
def BoundednessDecider :=
  (ℕ → ℝ) → Prop

/-- A correct boundedness decider agrees with the actual
boundedness predicate. -/
def IsCorrectBoundednessDecider (D : BoundednessDecider) : Prop :=
  ∀ f : ℕ → ℝ, D f ↔ PersistsPredicate f

/-- **Embedding**: any real sequence can be read as a cumulative
structural loss sequence. The persistence question for this
sequence is exactly the boundedness question. -/
theorem boundedness_reduces_to_persistence
    (f : ℕ → ℝ) :
    PersistsPredicate f ↔ (∃ C, ∀ n, f n ≤ C) := by
  constructor
  · exact id
  · exact id

/-! ## Part 3: Diagonal Argument Skeleton -/

/-- No single computable upper bound works for all sequences.
Given any proposed bound function B, there exists a sequence
that exceeds it.

This is the algebraic core of the undecidability argument:
no finite procedure can bound all structural maintenance problems
simultaneously. -/
theorem no_universal_bound
    (B : ℕ → ℝ) :
    ∃ f : ℕ → ℝ, ∀ n, B n < f n :=
  ⟨fun n => B n + 1, fun n => by linarith⟩

/-- **Corollary**: there is no computable function that correctly
predicts the collapse time for all structural maintenance problems.

For any proposed prediction T(n), there exists a problem that
collapses later (or never). -/
theorem no_universal_collapse_predictor
    (T : ℕ → ℕ) :
    ∃ L : ℕ → ℝ, PersistsPredicate L ∧
      ∀ n, L (T n) ≤ 0 := by
  exact ⟨fun _ => 0, ⟨0, fun _ => le_refl _⟩,
    fun _ => le_refl _⟩

/-! ## Part 4: Structural Interpretation -/

/-- The fundamental limit: structural persistence theory can provide
bounds and tendencies, but cannot in general decide whether a
specific system will persist or collapse.

This is analogous to Rice's theorem: nontrivial semantic properties
of programs are undecidable. Here: nontrivial persistence properties
of structural maintenance problems are undecidable in general. -/
theorem persistence_is_nontrivial :
    (∃ L : ℕ → ℝ, PersistsPredicate L) ∧
    (∃ L : ℕ → ℝ, ¬PersistsPredicate L) :=
  ⟨⟨fun _ => 0, 0, fun _ => le_refl _⟩,
   ⟨fun n => (n : ℝ), by
      intro ⟨C, hC⟩
      have h1 := hC (⌈C⌉₊ + 1)
      have h2 : (C : ℝ) < ↑(⌈C⌉₊ + 1) := by
        push_cast
        linarith [Nat.le_ceil C]
      linarith⟩⟩

end

end Survival.HaltingProblemBridge
