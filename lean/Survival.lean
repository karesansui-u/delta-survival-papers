/-
Survival Model - Formal Verification (Paper 1 Subset)
存続モデルの形式的検証（論文1用サブセット）

Paper: "Structural Conflicts as Information Loss"

11 modules, sorry = 0, axiom = 0.

Covers:
- Survival equation algebraic properties (S > 0 ⟺ all factors positive)
- Hazard rate monotonicity
- Penalty function behavior (subcritical/supercritical)
- Survival selection theorem (H-theorem, general n-type)
- SAT first moment correspondence and ratio prediction
- Cauchy functional equation: e^{-cδ} uniqueness characterization
- Hill number upper bound: N_eff ≤ N (Jensen's inequality)
- 3 axioms → e^{-δ} derivation chain (independence → exponential)
- Error propagation bounds
- Multiplicative vs additive model comparison
-/

-- Core definitions and survival equation
import Survival.Basic
import Survival.Penalty
import Survival.FullFormula

-- Survival selection theorem (H-theorem)
import Survival.ArrowOfTime
import Survival.ArrowOfTimeGeneral
import Survival.ArrowOfTimeNGeneral

-- SAT first moment method and ratio prediction
import Survival.SATFirstMoment

-- Cauchy functional equation: uniqueness of e^{-cδ}
import Survival.CauchyExponential

-- Error propagation and sensitivity analysis
import Survival.SensitivityAnalysis

-- Hill number upper bound (N_eff ≤ N)
import Survival.HillNumber

-- 3 axioms → e^{-δ}: the derivation chain
import Survival.AxiomsToExp
