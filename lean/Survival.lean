/-
Survival Model - Formal Verification (Paper 1 + Second Moment Extension)
存続モデルの形式的検証（論文1 + 第二モーメント法拡張）

Paper: "Structural Conflicts as Information Loss"

16 modules, sorry = 0, axiom = 0.

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
- Second moment method: Paley-Zygmund inequality (threshold lower bound)
- Pair correlation function g(β) for random 3-SAT
- SAT second moment overlap decomposition and threshold bracketing
- KL divergence: δ = D_KL identity, Jensen inequality, gap-R₂ connection
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

-- Second moment method: Paley-Zygmund inequality
import Survival.SecondMomentBound

-- Pair correlation function for random 3-SAT
import Survival.PairCorrelation

-- SAT second moment: overlap decomposition and threshold bracketing
import Survival.SATSecondMoment

-- Asymptotic exponent: gap analysis between first/second moment thresholds
import Survival.AsymptoticExponent

-- KL divergence: δ = D_KL identity and information-theoretic grounding
import Survival.KLDivergence
