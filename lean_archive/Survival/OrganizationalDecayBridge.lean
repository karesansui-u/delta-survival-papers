import Survival.ErgodicRateBridge
/-!
# Organizational Decay Bridge — Bureaucratic Rigidification
Organizations accumulate structural consumption through bureaucratic
rigidification, process ossification, and institutional memory loss.
Innovation = recovery. When bureaucracy > innovation, the
organization's structural persistence collapses.
-/
namespace Survival.OrganizationalDecayBridge
open Survival.ErgodicRateBridge
noncomputable section
structure OrganizationModel where
  bureaucracyRate : ℝ   -- consumption (rigidification)
  innovationRate : ℝ    -- recovery (adaptation)
  bureaucracy_pos : 0 < bureaucracyRate
  innovation_nonneg : 0 ≤ innovationRate

def organizationalDecay (M : OrganizationModel) : ℝ := M.bureaucracyRate - M.innovationRate

theorem innovative_org_persists (M : OrganizationModel) (h : M.innovationRate ≥ M.bureaucracyRate) (n : ℕ) :
    1 ≤ constantRateRetention ⟨organizationalDecay M⟩ n :=
  persistence_of_nonpositive_rate ⟨organizationalDecay M⟩ (by unfold organizationalDecay; linarith) n

theorem rigid_org_collapses (M : OrganizationModel) (h : M.bureaucracyRate > M.innovationRate) :
    Filter.Tendsto (fun n => constantRateRetention ⟨organizationalDecay M⟩ n) Filter.atTop (nhds 0) :=
  collapse_of_positive_rate ⟨organizationalDecay M⟩ (by unfold organizationalDecay; linarith)
end
end Survival.OrganizationalDecayBridge
