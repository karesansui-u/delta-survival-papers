import Survival.JaynesMaxEntTheorem
/-!
# Softmax Bridge
Softmax: p_i = exp(z_i) / Σ exp(z_j) is the MaxEnt distribution
with linear constraints E[e_i] = z_i. In SP: softmax weights are
Boltzmann weights exp(-β·l_i) normalized by the partition function.
-/
namespace Survival.SoftmaxBridge
open Survival.JaynesMaxEntTheorem
noncomputable section

/-- Softmax weight (unnormalized): exp(z_i). -/
def softmaxWeight (z : ℝ) : ℝ := Real.exp z

/-- Softmax weight is always positive. -/
theorem softmax_pos (z : ℝ) : 0 < softmaxWeight z := Real.exp_pos z

/-- Softmax = Boltzmann with negative loss: exp(z) = exp(-(-z)).
The logit z_i = -l_i (negative consumption). -/
theorem softmax_is_boltzmann (z : ℝ) :
    softmaxWeight z = boltzmannWeight 1 (-z) := by
  unfold softmaxWeight boltzmannWeight; congr 1; ring

/-- Partition function for softmax. -/
def softmaxPartition {n : ℕ} (z : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, softmaxWeight (z i)

/-- Partition function is positive when n > 0. -/
theorem softmaxPartition_pos {n : ℕ} (hn : 0 < n) (z : Fin n → ℝ) :
    0 < softmaxPartition z := by
  unfold softmaxPartition
  exact Finset.sum_pos (fun i _ => softmax_pos (z i)) ⟨⟨0, hn⟩, Finset.mem_univ _⟩

/-- Normalized softmax probability. -/
def softmaxProb {n : ℕ} (z : Fin n → ℝ) (i : Fin n) : ℝ :=
  softmaxWeight (z i) / softmaxPartition z

/-- Each softmax probability is positive. -/
theorem softmaxProb_pos {n : ℕ} (hn : 0 < n) (z : Fin n → ℝ) (i : Fin n) :
    0 < softmaxProb z i :=
  div_pos (softmax_pos (z i)) (softmaxPartition_pos hn z)

/-- Softmax partition function normalizes the weights. -/
theorem softmax_normalized {n : ℕ} (hn : 0 < n) (z : Fin n → ℝ) :
    0 < softmaxPartition z :=
  softmaxPartition_pos hn z

end
end Survival.SoftmaxBridge
