import Survival.FixedPointBridge
import Survival.ErgodicRateBridge

/-!
# Game Theory Bridge — Minimax / Nash Equilibrium Connection

This module provides the G6-b correspondence between game theory
and structural persistence theory.

## Structural-persistence reading

The structural balance b_t = d_t - r_t can be viewed as the outcome
of a two-player zero-sum game:

- **Player 1 (Environment/Adversary)**: chooses damage intensity d
  to maximize structural consumption
- **Player 2 (System/Defender)**: chooses repair intensity r
  to minimize structural consumption

The Nash equilibrium of this game determines the stationary
structural consumption rate l̄.

Key identifications:
- **Nash equilibrium** ≡ structural equilibrium (b = 0)
- **Minimax value** ≡ optimal achievable retention rate
- **Best response** ≡ optimal repair given damage (or vice versa)
- **Security level** ≡ worst-case structural consumption rate

References:
  - Nash, J. (1950). "Equilibrium points in n-person games."
  - von Neumann, J. (1928). "Zur Theorie der Gesellschaftsspiele."
  - FixedPointBridge.lean: equilibrium characterization
  - ErgodicRateBridge.lean: ergodic trichotomy
-/

namespace Survival.GameTheoryBridge

open Real

noncomputable section

/-! ## Part 1: Two-Player Structural Game -/

/-- A two-player structural game: Environment chooses damage,
    System chooses repair. Payoff is net consumption. -/
structure StructuralGame where
  /-- Maximum damage the environment can inflict per step -/
  maxDamage : ℝ
  /-- Maximum repair the system can perform per step -/
  maxRepair : ℝ
  /-- Both are positive -/
  maxDamage_pos : 0 < maxDamage
  maxRepair_pos : 0 < maxRepair

/-- The payoff (net consumption) given damage d and repair r.
    Environment wants to maximize, System wants to minimize. -/
def payoff (_G : StructuralGame) (d r : ℝ) : ℝ := d - r

/-- Feasible damage: 0 ≤ d ≤ maxDamage. -/
def FeasibleDamage (G : StructuralGame) (d : ℝ) : Prop :=
  0 ≤ d ∧ d ≤ G.maxDamage

/-- Feasible repair: 0 ≤ r ≤ maxRepair. -/
def FeasibleRepair (G : StructuralGame) (r : ℝ) : Prop :=
  0 ≤ r ∧ r ≤ G.maxRepair

/-! ## Part 2: Security Levels -/

/-- System's security level (minimax): the best the system can
    guarantee regardless of environment's action.
    min_r max_d (d - r) = maxDamage - maxRepair (take d=maxDamage). -/
def systemSecurityLevel (G : StructuralGame) : ℝ :=
  G.maxDamage - G.maxRepair

/-- Environment's security level (maximin): the worst the environment
    can guarantee regardless of system's action.
    max_d min_r (d - r) = maxDamage - maxRepair (take r=maxRepair). -/
def envSecurityLevel (G : StructuralGame) : ℝ :=
  G.maxDamage - G.maxRepair

/-- **Minimax theorem (structural form)**: In this game, the
    minimax value equals the maximin value (no duality gap).
    This is trivially true here since the payoff is bilinear. -/
theorem minimax_eq_maximin (G : StructuralGame) :
    systemSecurityLevel G = envSecurityLevel G := rfl

/-- The game value (minimax = maximin value). -/
def gameValue (G : StructuralGame) : ℝ := systemSecurityLevel G

/-! ## Part 3: Nash Equilibrium -/

/-- A Nash equilibrium: (d*, r*) such that neither player can
    improve by unilateral deviation. -/
structure NashEquilibrium (G : StructuralGame) where
  /-- Equilibrium damage -/
  damage : ℝ
  /-- Equilibrium repair -/
  repair : ℝ
  /-- Both are feasible -/
  damage_feasible : FeasibleDamage G damage
  repair_feasible : FeasibleRepair G repair
  /-- Environment can't improve: d* maximizes payoff given r* -/
  env_best_response : ∀ d, FeasibleDamage G d →
    payoff G d repair ≤ payoff G damage repair
  /-- System can't improve: r* minimizes payoff given d* -/
  sys_best_response : ∀ r, FeasibleRepair G r →
    payoff G damage repair ≤ payoff G damage r

/-- The standard Nash equilibrium: Environment plays maxDamage,
    System plays maxRepair. -/
def standardEquilibrium (G : StructuralGame) : NashEquilibrium G where
  damage := G.maxDamage
  repair := G.maxRepair
  damage_feasible := ⟨le_of_lt G.maxDamage_pos, le_refl _⟩
  repair_feasible := ⟨le_of_lt G.maxRepair_pos, le_refl _⟩
  env_best_response := fun d ⟨_, hd⟩ => by
    unfold payoff
    linarith
  sys_best_response := fun r ⟨_, hr⟩ => by
    unfold payoff
    linarith

/-- The equilibrium payoff equals the game value. -/
theorem equilibrium_payoff_eq_value (G : StructuralGame) :
    payoff G (standardEquilibrium G).damage
      (standardEquilibrium G).repair = gameValue G := rfl

/-! ## Part 4: Structural Fate from Game Value -/

/-- **Structural fate theorem**: The game value determines the
    structural fate.
    - gameValue > 0 → damage > repair → structural collapse
    - gameValue = 0 → damage = repair → structural equilibrium
    - gameValue < 0 → damage < repair → structural recovery -/
theorem game_value_determines_fate (G : StructuralGame) :
    (0 < gameValue G → 0 < G.maxDamage - G.maxRepair) ∧
    (gameValue G = 0 → G.maxDamage = G.maxRepair) ∧
    (gameValue G < 0 → G.maxRepair > G.maxDamage) := by
  unfold gameValue systemSecurityLevel
  exact ⟨id, fun h => by linarith, fun h => by linarith⟩

/-- When the game value is zero, the system is at structural
    equilibrium: the retention factor stays at 1 forever. -/
theorem equilibrium_retention_stable (G : StructuralGame)
    (hval : gameValue G = 0) (n : ℕ) :
    Survival.ErgodicRateBridge.constantRateRetention
      ⟨gameValue G⟩ n = 1 :=
  Survival.ErgodicRateBridge.boundary_of_zero_rate ⟨gameValue G⟩ hval n

/-- When the game value is positive, the system collapses. -/
theorem positive_value_collapse (G : StructuralGame)
    (hval : 0 < gameValue G) :
    Filter.Tendsto
      (fun n => Survival.ErgodicRateBridge.constantRateRetention
        ⟨gameValue G⟩ n)
      Filter.atTop (nhds 0) :=
  Survival.ErgodicRateBridge.collapse_of_positive_rate ⟨gameValue G⟩ hval

end

end Survival.GameTheoryBridge
