import Survival.ChannelCapacityBridge
import Survival.HillNumber
import Survival.ErgodicRateBridge

/-!
# Language Entropy Bridge — Text Predictability as Structural Persistence

Reads language entropy through structural persistence: a language's
entropy rate h = lim H(X_n | X_{n-1},...,X_1) / n is the structural
consumption rate for prediction capability.

Low entropy rate → predictable → structure persists
High entropy rate → unpredictable → structure degrades
Shannon's source coding theorem: compression rate = entropy rate = l̄
-/
namespace Survival.LanguageEntropyBridge
open Survival.ErgodicRateBridge
noncomputable section

structure LanguageModel where
  entropyRate : ℝ      -- bits per symbol (consumption rate)
  rate_nonneg : 0 ≤ entropyRate

/-- A language with zero entropy rate is perfectly predictable
    (structural persistence of prediction). -/
theorem deterministic_language (M : LanguageModel)
    (h : M.entropyRate = 0) (n : ℕ) :
    constantRateRetention ⟨M.entropyRate⟩ n = 1 :=
  boundary_of_zero_rate ⟨M.entropyRate⟩ h n

/-- A language with positive entropy rate has prediction capability
    that degrades over time (without context). -/
theorem positive_entropy_degrades (M : LanguageModel)
    (h : 0 < M.entropyRate) :
    Filter.Tendsto (fun n => constantRateRetention ⟨M.entropyRate⟩ n)
      Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨M.entropyRate⟩ h

end
end Survival.LanguageEntropyBridge
