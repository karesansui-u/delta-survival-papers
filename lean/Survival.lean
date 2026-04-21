/-
Survival Model - Formal Verification (Paper 1 + Second Moment Extension)
存続モデルの形式的検証（論文1 + 第二モーメント法拡張）

Paper: "Structural Conflicts as Information Loss"

Core + extension modules, sorry = 0, axiom = 0.

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
- Weak dependence: ρ-bracket around joint survival; robust survival potential
- Correlated second moment: meshwise bounds without clause independence
- Robust survival: conservative μ·exp(-δ(1+ρ)) and δ interval from bounded rates
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

-- Log-ratio uniqueness: f(r) = -k·log r from B1–B4 (Paper 1 §3)
import Survival.LogUniqueness

-- A1–A2-only telescoping identity: m_n = m_0 * exp(-Σ l_i)
import Survival.TelescopingExp
import Survival.GeneralStateDynamics
import Survival.CoarseGraining
import Survival.ResourceBudget
import Survival.TotalProduction
import Survival.CoarseTotalProduction
import Survival.TypicalNondecrease
import Survival.ResourceBoundedDynamics
import Survival.ResourceBudgetToTotalProductionDrift
import Survival.ResourceBudgetToSigmaDrift
import Survival.ProbabilityConnection
import Survival.StochasticTotalProduction
import Survival.CoarseStochasticTotalProduction
import Survival.CoarseTypicalNondecrease
import Survival.MinimumRepairRate
import Survival.StochasticMinimumRepairRate
import Survival.CoarseMinimumRepairRate
import Survival.CollapseTimeBound
import Survival.StochasticCollapseTimeBound
import Survival.CliffWarning
import Survival.HighProbabilityCollapse
import Survival.StochasticCliffWarning
import Survival.MartingaleDrift
import Survival.ConcentrationInterface
import Survival.ConditionalMartingale
import Survival.AzumaHoeffding
import Survival.BoundedAzumaConstruction
import Survival.StoppingTimeCliffWarning
import Survival.StoppingTimeHighProbabilityCollapse
import Survival.StoppingTimeCollapseEvent
import Survival.StoppingTimeSharpDecomposition
import Survival.CoarseStochasticStoppingTimeCollapse
import Survival.StochasticTotalProductionAzuma
import Survival.ResourceBoundedStochasticCollapse
import Survival.ResourceBoundedConditionalAzuma
import Survival.ToyRandomWalk
import Survival.MarkovRepairFailureExample
import Survival.FiniteStateMarkovRepairChain
import Survival.FiniteStateMarkovStationaryProduction
import Survival.FiniteStateMarkovMeanBridge
import Survival.FiniteStateMarkovErgodicProduction
import Survival.FiniteStateMarkovPositiveDriftCollapse
import Survival.FiniteStateMarkovStationaryMeanCollapse
import Survival.FiniteStateMarkovStationaryLongTimeConcentration
import Survival.FiniteStateMarkovCollapse
import Survival.FiniteStateMarkovDeterministicWitness
import Survival.FiniteStateMarkovFlatWitness
import Survival.FiniteStateMarkovConditionalAzuma
import Survival.ThreeStateTransitionExample
import Survival.ThreeStateStateDependentExample
import Survival.ConstantDriftExample

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
import Survival.SATDriftLowerBound
import Survival.SATClauseExposureProcess
import Survival.SATStateDependentClauseExposure
import Survival.SATStateDependentUnconditionalTendency
import Survival.SATStateDependentExactConcentration
import Survival.SATStateDependentAzuma
import Survival.SATStateDependentTailUpperBound
import Survival.SATStateDependentCountReduction
import Survival.SATStateDependentCountThreshold
import Survival.SATStateDependentCountSupportBound
import Survival.SATStateDependentCountTailUpperBound
import Survival.SATStateDependentCountSupportClippedUpperBound
import Survival.SATStateDependentCountMarkovUpperBound
import Survival.SATStateDependentCountChernoffUpperBound
import Survival.SATStateDependentCountChernoffMGF
import Survival.SATStateDependentCountMGFProduct
import Survival.SATStateDependentClosedMGFChernoff
import Survival.SATStateDependentCountChernoffKL
import Survival.SATStateDependentCountChernoffKLAlgebra
import Survival.BernoulliCSPTemplate
import Survival.BernoulliCSPPathMeasure
import Survival.BernoulliCSPPathChernoff
import Survival.BernoulliCSPPathCollapse
import Survival.KSATBernoulliTemplate
import Survival.KSATClauseExposureProcess
import Survival.KSATChernoffCollapse
import Survival.KSATToSATChernoffBridge
import Survival.BernoulliCSPToSATBridge
import Survival.NAESATBernoulliTemplate
import Survival.NAESATClauseExposureProcess
import Survival.NAESATChernoffCollapse
import Survival.XORSATBernoulliTemplate
import Survival.XORSATClauseExposureProcess
import Survival.XORSATChernoffCollapse
import Survival.QColoringBernoulliTemplate
import Survival.QColoringEdgeExposureProcess
import Survival.QColoringChernoffCollapse
import Survival.ForbiddenPatternCSPTemplate
import Survival.ForbiddenPatternCSPExposureProcess
import Survival.ForbiddenPatternCSPChernoffCollapse
import Survival.MultiForbiddenPatternCSP
import Survival.HypergraphColoringChernoffCollapse
import Survival.CardinalitySATChernoffCollapse
import Survival.ExactlyOneSATChernoffCollapse
import Survival.BernoulliCSPUniversality
import Survival.SATPositiveDriftCollapse
import Survival.SATUnconditionalTendency

-- Asymptotic exponent: gap analysis between first/second moment thresholds
import Survival.AsymptoticExponent

-- KL divergence: δ = D_KL identity and information-theoretic grounding
import Survival.KLDivergence

-- Weak dependence / robust exponential survival (relaxation of axiom A3)
import Survival.WeakDependence
import Survival.SignedWeakDependence
import Survival.CorrelatedSecondMoment
import Survival.RobustSurvival

-- Multi-attractor extension: basin partition, transition theorem, free energy
import Survival.MultiAttractor
import Survival.TransitionTheorem
import Survival.FreeEnergy
import Survival.ScaleInvariance
