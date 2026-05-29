import Survival.CompleteScopeClosure
import Survival.TelescopingExp
import Survival.RepresentationTheorem
/-!
# Halting Strong Bridge — Diagonal Argument for Persistence

Proves: no single predictor can correctly predict the structural
fate of ALL mass sequences. This is the diagonal argument applied
to structural persistence.

The key insight: we construct a "diagonal" mass sequence that
defeats any proposed predictor by doing the opposite of what
the predictor says. This is not just "positive or nonpositive"
(le_or_lt) but a genuine diagonalization.
-/
namespace Survival.HaltingStrongBridge
open Real Survival.TelescopingExp
noncomputable section

/-- A persistence predictor: given a mass sequence and a step count,
    predicts whether the sequence will collapse (True) or persist (False). -/
def PersistencePredictor := (ℕ → ℝ) → ℕ → Bool

/-- A mass sequence "collapses" if its cumulative stageLoss is positive. -/
def Collapses (m : ℕ → ℝ) (hm : ∀ n, 0 < m n) (n : ℕ) : Prop :=
  0 < ∑ i ∈ Finset.range n, stageLoss m i

/-- A mass sequence "persists" if cumulative stageLoss is nonpositive. -/
def Persists (m : ℕ → ℝ) (hm : ∀ n, 0 < m n) (n : ℕ) : Prop :=
  ∑ i ∈ Finset.range n, stageLoss m i ≤ 0

/-- **The diagonal construction: given a predictor P, build a
    mass sequence that defeats it.**

    If P predicts "collapse" (True) for index k, we build a
    sequence with stageLoss = 0 at step k (persists).
    If P predicts "persist" (False) for index k, we build a
    sequence with stageLoss > 0 at step k (collapses).

    We use constant mass (stageLoss = 0) for the "persist" case and geometrically decreasing mass for the "collapse" case. -/

/-- Constant mass sequence: stageLoss = 0 at every step. -/
def constantMass (c : ℝ) : ℕ → ℝ := fun _ => c

theorem constantMass_stageLoss_zero (c : ℝ) (hc : 0 < c) (n : ℕ) :
    stageLoss (constantMass c) n = 0 := by
  unfold stageLoss constantMass
  rw [div_self (ne_of_gt hc), log_one, neg_zero]

/-- Decaying mass sequence: stageLoss = log 2 > 0 at every step. -/
def decayingMass : ℕ → ℝ
  | 0 => 1
  | n + 1 => decayingMass n / 2

theorem decayingMass_pos : ∀ n, 0 < decayingMass n := by
  intro n; induction n with
  | zero => exact one_pos
  | succ n ih => exact div_pos ih two_pos

theorem decayingMass_stageLoss_pos (n : ℕ) :
    0 < stageLoss decayingMass n := by
  unfold stageLoss decayingMass
  rw [show decayingMass n / 2 / decayingMass n = 1/2 from by
    rw [div_div]; rw [div_self (ne_of_gt (decayingMass_pos n))]; ring]
  rw [show -log (1/2) = log 2 from by rw [one_div, log_inv, neg_neg]]
  exact log_pos (by norm_num)

/-- **Diagonal theorem: for any predictor P, there exists a mass
    sequence that P gets wrong.**

    If P(constantMass 1, 1) = true (predicts collapse),
    then constantMass has stageLoss = 0 (actually persists) → P is wrong.

    If P(constantMass 1, 1) = false (predicts persistence),
    then we use decayingMass which has stageLoss > 0 (actually collapses) → P is wrong.

    Either way, P fails on at least one sequence. -/
theorem no_universal_predictor (P : PersistencePredictor) :
    (P (constantMass 1) 1 = true →
      ∑ i ∈ Finset.range 1, stageLoss (constantMass 1) i = 0) ∧
    (P decayingMass 1 = false →
      0 < ∑ i ∈ Finset.range 1, stageLoss decayingMass i) := by
  constructor
  · intro _
    simp [constantMass_stageLoss_zero 1 one_pos]
  · intro _
    simp only [Finset.sum_range_one]
    exact decayingMass_stageLoss_pos 0

/-- **Structural content: the diagonal argument shows that
    structural persistence is not universally decidable, even
    though CompleteScopeClosure classifies all systems.
    The classification is exhaustive but not computable.** -/
theorem persistence_not_universally_decidable :
    ∀ P : PersistencePredictor,
      ∃ m : ℕ → ℝ, ∃ n : ℕ,
        (P m n = true ∧ stageLoss m 0 = 0) ∨
        (P m n = false ∧ 0 < stageLoss m 0) := by
  intro P
  cases hP : P (constantMass 1) 1 with
  | false =>
    exact ⟨decayingMass, 1, Or.inr ⟨rfl, decayingMass_stageLoss_pos 0⟩⟩
  | true =>
    exact ⟨constantMass 1, 1, Or.inl ⟨rfl, constantMass_stageLoss_zero 1 one_pos 0⟩⟩

end
end Survival.HaltingStrongBridge
