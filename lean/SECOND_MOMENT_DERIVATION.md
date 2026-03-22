# Second Moment Method for Random 3-SAT: Mathematical Derivation
# 第二モーメント法の数学的導出（Lean形式化の設計書）

## 目的

第一モーメント法（既に形式化済み）は閾値の**上界** α_c^(1) ≈ 5.19 を与える。
第二モーメント法は閾値の**下界**を与え、「δ < budget のとき存続可能」方向を証明する。

## 1. Paley-Zygmund不等式（一般的な第二モーメント下界）

**定理**: X ≥ 0 が確率変数、E[X] > 0 のとき：

    Pr[X > 0] ≥ E[X]² / E[X²]

**証明**: Cauchy-Schwarzより：
    E[X]² = E[X · 1_{X>0}]² ≤ E[X²] · Pr[X > 0]

**Lean上の位置づけ**: Mathlibに直接はないが、Cauchy-Schwarzは
`MeasureTheory.inner_mul_le_norm_mul_sq` などから構成可能。
ただし離散有限確率空間上で直接証明する方が簡潔。

## 2. ペア相関公式（Random 3-SAT固有）

2つの割当 σ, τ のHamming距離を d とする。

### 2.1 単一節に対するペア充足確率

random 3-clause C が変数 v₁, v₂, v₃ を選び、各リテラルの符号をランダムに決める。
C の3変数のうち j 個が不一致集合 D (|D| = d) に含まれるとき：

- j = 0: σ, τ は節変数上で一致。失敗パターンが同一。
  → P(both satisfy C) = 1 - 1/2³ = 7/8

- j ≥ 1: σ, τ の節変数上の値が異なる。失敗パターンが異なる。
  → 両方同時に失敗する確率 = 0（異なるパターン）
  → P(at least one fails) = 2/2³ = 1/4
  → P(both satisfy C) = 1 - 2/2³ = 6/8 = 3/4

### 2.2 変数が不一致集合に入る確率

節の3変数が n 個から無作為に選ばれるとき、j 個が D に含まれる確率：

    P(j = 0) = C(n-d, 3) / C(n, 3)

大数近似（n → ∞, β = d/n）：
    P(j = 0) → (1 - β)³

### 2.3 単一節のペア充足確率（統合）

    g(β) = (7/8) · (1-β)³ + (3/4) · (1 - (1-β)³)
          = 3/4 + (1/8) · (1-β)³

### 2.4 m 節のペア充足確率（独立性より）

    P(σ ∈ SAT ∧ τ ∈ SAT | d(σ,τ) = d) = g(d/n)^m

## 3. E[X²] の分解

    E[X²] = Σ_{σ,τ} P(σ ∈ SAT ∧ τ ∈ SAT)
           = Σ_{d=0}^{n} C(n,d) · g(d/n)^m

ここで C(n,d) はHamming距離 d の割当ペア数。

## 4. E[X²]/E[X]² の評価

    E[X]² = [2^n · (7/8)^m]² = 4^n · (7/8)^{2m}

    E[X²]/E[X]² = (1/4^n) · Σ_d C(n,d) · g(d/n)^m / (7/8)^{2m}
                 = Σ_d (C(n,d)/2^n) · [g(d/n) / (7/8)²]^m · (1/2^n) ...

整理すると：

    E[X²]/E[X]² = Σ_d C(n,d)/2^n · [g(d/n)/(7/8)²]^m

ここで C(n,d)/2^n は距離 d の割合。

## 5. Lean形式化の対象

### Module 1: `SecondMomentBound.lean`
- Paley-Zygmund不等式（離散有限確率空間上）
- 入力: 非負関数 f : Fin N → ℝ, 重み w : Fin N → ℝ（一様）
- 出力: (Σ f)² ≤ (Σ f²) · |{i | f i > 0}|

### Module 2: `PairCorrelation.lean`
- g(β) = 3/4 + (1/8)(1-β)³ の定義と性質
- g(0) = 7/8（σ = τ のとき、第一モーメントに退化）
- g(1/2) = 49/64
- g(1) = 3/4（最大距離）
- 0 < g(β) ≤ 7/8 for β ∈ [0,1]
- g は単調減少

### Module 3: `SATSecondMoment.lean`
- E[X²] のoverlap分解の形式化
- E[X²]/E[X]² の有界性条件
- 閾値下界の導出

## 6. 数学的に回避すべき部分（Lean上で困難）

- Stirling近似：漸近展開はLeanで冗長。有限 n での正確な計算に限定
- Laplace法：連続最適化。離散版を直接扱う
- α_c の精密な値（4.27）：replica法やsurvey propagationが必要。ここは対象外

## 7. 形式化で示す中心定理

**Theorem (Second Moment Lower Bound)**:
ランダム 3-SAT instance with n 変数, m = αn 節が与えられたとき、

    E[X²]/E[X]² = Σ_{d=0}^{n} C(n,d) · [g(d/n)/(7/8)²]^m

が有界 ⟹ Pr[SAT] > 0 （第二モーメント法の適用条件）

**Corollary**: g(0)/(7/8)² = 1 かつ g(d/n) < (7/8)² for d > 0 (十分大きいdで)、
よって d = 0 の項が支配的。E[X²]/E[X]² の発散は d > 0 の項の寄与による。
