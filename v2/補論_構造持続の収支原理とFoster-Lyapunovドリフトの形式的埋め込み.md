補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み
構造持続の収支原理と Foster-Lyapunov ドリフトの形式的埋め込み
— G6-c formal embedding の最小補論 —

要旨

本補論は、構造持続の収支原理が既存理論と単に「似ている」のではなく、少なくとも一つの古典的 drift calculus を構造持続の収支原理の変数へ形式的に埋め込めることを示す。

対象にするのは、離散時間過程に対する Foster-Lyapunov drift 条件である。確率過程 \(X_t\) と非負関数 \(W\) に対して、負荷
\[
  Z_t := W(X_t)
\]
を置き、一段の差分を
\[
  b_t := Z_{t+1}-Z_t
\]
と定義すると、累積純消耗量は
\[
  B_n = \sum_{t=0}^{n-1} b_t = Z_n-Z_0
\]
となる。また、相対的維持量を
\[
  R_t := e^{-Z_t}
\]
と置けば、
\[
  R_{t+1}=R_t e^{-b_t}
\]
が成り立つ。これは、構造持続の収支原理の局所更新と同じ algebraic shape を持つ。

本補論の主張は限定的である。Foster-Lyapunov theorem の正再帰性定理や幾何的エルゴード性を再証明するものではない。Markov 性、irreducibility、小集合条件、moment 条件など、元理論の仮定はそのまま保持される。本補論が示すのは、Foster-Lyapunov drift calculus の負荷差分が、構造持続の収支原理の純消耗量 \(b_t\) として読める、という最小の G6-c formal embedding である。

この最小埋め込みは Lean 側でも `Survival/LyapunovBalanceEmbedding.lean` として形式化されている。Lean が証明しているのは、望遠鏡和、指数的維持量の局所恒等式、正負部分による \(b_t=d_t-r_t\) 分解、および `QueueStability.lean` の excess demand を純消耗量として読む wrapper である。positive recurrence や \(R_n \le R_0 e^{-cn}\) 型の指数減衰境界は、次の iteration の対象であり、本補論の範囲外である。


1. 目的と位置づけ

構造持続の収支原理は、構造消耗量 \(d_t\) と回復量 \(r_t\) の差し引きを
\[
  b_t = d_t - r_t
\]
と置き、その累積純消耗量
\[
  B_n = \sum_{t=0}^{n-1} b_t
\]
によって構造維持量の変化を記述する枠組みである。

Paper 2「構造持続の収支原理」では、既存理論との接続を G6-a / G6-b / G6-c の三段階に分けた。熱力学や情報理論との対応は、多くの場合 G6-a または G6-b に留まる。一方、queueing theory や Markov chain stability に現れる Foster-Lyapunov drift 条件は、構造持続の収支原理の純消耗量 \(b_t\) へ直接埋め込める。

本補論の目的は、その最小埋め込みを読者向けの記録として独立に残すことである。これは既存理論の置き換えではない。むしろ、既存理論の drift 部分が構造持続の収支原理の期待値レベルの傾向層へどう写るかを明示する。


2. G6-a / G6-b / G6-c の中での位置

本稿群では、既存理論との接続強度を次の三段階に分ける。

| level | 内容 | 本補論での扱い |
|---|---|---|
| G6-a analogy | 直感や語彙が似ている | 目的ではない |
| G6-b correspondence | 量と符号の対応表が作れる | §6 で整理する |
| G6-c formal embedding | 既存の drift / balance 条件が構造持続の収支原理の変数へ埋め込める | 本補論の中心 |

ここでの G6-c は、Foster-Lyapunov theorem 全体を構造持続の収支原理から無条件に導く、という意味ではない。G6-c として主張するのは、次の限定命題である。

\begin{quote}
Foster-Lyapunov drift calculus の負荷差分は、構造持続の収支原理の純消耗量 \(b_t\) として読める。したがって、その expectation-level drift 条件は、構造持続の収支原理の recovery / collapse tendency の特例として埋め込める。
\end{quote}

この限定は重要である。formal embedding は、仮定の省略ではない。元の安定性定理が必要とする条件は、そのまま保持される。


3. 最小埋め込み

離散時間過程 \(X_t\) と、非負関数
\[
  W:\mathcal X\to [0,\infty)
\]
を考える。構造負荷を
\[
  Z_t := W(X_t)
\]
と定義する。

純消耗量を
\[
  b_t := Z_{t+1}-Z_t
\]
と置く。累積純消耗量は
\[
  B_n := \sum_{t=0}^{n-1} b_t
\]
である。

このとき、望遠鏡和により
\[
  B_n
  = \sum_{t=0}^{n-1}(Z_{t+1}-Z_t)
  = Z_n-Z_0.
\]

これは構造持続の収支原理の累積純消耗量と同じ形式である。\(Z_t\) が増えると、負荷が増える。\(Z_t\) が減ると、回復が勝っている。


4. 指数的維持量

構造維持の相対量を
\[
  R_t := e^{-Z_t}
\]
と定義する。

すると、
\[
  R_{t+1}
  = e^{-Z_{t+1}}
  = e^{-Z_t}e^{-(Z_{t+1}-Z_t)}
  = R_t e^{-b_t}.
\]

したがって、局所更新は
\[
  R_{t+1}=R_t e^{-b_t}
\]
である。

これは、構造持続の収支原理の
\[
  m(V^{(t+1)})=m(V^{(t)})e^{-b_t}
\]
と同じ algebraic shape を持つ。ただし、ここでの \(R_t\) は実際の feasible set measure そのものではない。これは Lyapunov 負荷から作った相対的維持座標である。この違いを消してはならない。


5. \(d_t,r_t\) への分解

構造持続の収支原理の標準形では、純消耗量を
\[
  b_t=d_t-r_t
\]
と書く。ここで \(d_t\ge 0\) は構造消耗量、\(r_t\ge 0\) は回復量である。

Lyapunov 差分
\[
  \Delta Z_t:=Z_{t+1}-Z_t
\]
から、次のように分解できる。
\[
  d_t := (\Delta Z_t)^+,
  \qquad
  r_t := (-\Delta Z_t)^+,
\]
ただし \(x^+=\max(x,0)\) である。

このとき
\[
  d_t-r_t
  = (\Delta Z_t)^+ - (-\Delta Z_t)^+
  = \Delta Z_t
  = b_t.
\]

したがって、負荷が増えるステップは構造消耗量として、負荷が減るステップは回復量として読める。

この読み替えは、物理的資源入力を同定したという意味ではない。あくまで、Lyapunov 負荷の増減を構造持続の収支原理の符号つき純消耗量へ写す最小的な分解である。


6. Drift regime の対応

Foster-Lyapunov 条件は、\(b_t\) の条件付き期待値の符号として読める。

Foster-Lyapunov 側で \(\mathbb E[Z_{t+1}-Z_t\mid X_t]\le -\epsilon\) なら、
構造持続の収支原理側では \(\mathbb E[b_t\mid X_t]\le -\epsilon\) であり、
これは recovery tendency と読む。

Foster-Lyapunov 側で \(\mathbb E[Z_{t+1}-Z_t\mid X_t]\approx 0\) なら、
構造持続の収支原理側では \(\mathbb E[b_t\mid X_t]\approx 0\) であり、
これは maintenance regime と読む。

Foster-Lyapunov 側で \(\mathbb E[Z_{t+1}-Z_t\mid X_t]\ge \epsilon\) なら、
構造持続の収支原理側では \(\mathbb E[b_t\mid X_t]\ge \epsilon\) であり、
これは overload / collapse tendency と読む。

ここで重要なのは、構造持続の収支原理が drift theorem を置き換えるのではなく、drift theorem が扱う負荷差分を構造持続の収支原理の \(b_t\) として読む点である。


7. Queueing fluid skeleton

既存 Lean file `Survival.QueueStability` は、反射境界を持つ完全な stochastic queue ではなく、決定論的 fluid skeleton を扱う。

到着率を \(\lambda\)、サービス率を \(\mu\)、初期 backlog を \(Z_0\) とする。backlog は
\[
  Z_n=Z_0+n(\lambda-\mu)
\]
である。

このとき純消耗量は
\[
  b_t=Z_{t+1}-Z_t=\lambda-\mu
\]
で一定である。したがって、
\[
  B_n=n(\lambda-\mu),
  \qquad
  Z_n=Z_0+B_n.
\]

三つの局面は次のように分かれる。

\(\lambda<\mu\) なら \(b_t<0\) であり、service が arrival を上回る recovery tendency と読む。
\(\lambda=\mu\) なら \(b_t=0\) であり、critical / maintenance boundary と読む。
\(\lambda>\mu\) なら \(b_t>0\) であり、excess demand が累積する overload tendency と読む。

有限閾値 \(B\) を置けば、
\[
  Z_n\ge B
\]
は overload threshold event である。Lean 側では、これは `ThresholdExceeded` として skeleton 化されている。

この例は小さいが、G6-c にとって重要である。構造持続の収支原理の \(b_t=d_t-r_t\) が、queueing の arrival minus service という古典的 balance と同じ符号構造を持つことを示すからである。


8. Lean 対応

本補論の最小埋め込みは、Lean 側では `Survival/LyapunovBalanceEmbedding.lean` に対応する。

Lean 側では、\(B_n=Z_n-Z_0\) の望遠鏡和を `cumulativeAction_eq_load_diff` が、
\(R_{t+1}=R_t e^{-b_t}\) を `relativeMaintenance_succ_eq_mul_exp_neg_increment` が、
\(b_t=d_t-r_t\) の正負部分分解を `increment_eq_consumptionAmount_sub_recoveryAmount` が支える。
また、queue excess demand を \(b_t\) として読む対応は `queue_increment_eq_excessDemand`、
queue の累積純消耗量と累積 overload loss の対応は `queue_cumulativeAction_eq_cumulativeOverloadLoss`、
\(\mu\ge\lambda\) 側の純消耗量は `queue_increment_nonpos_of_stable`、
\(\lambda<\mu\) でない側の純消耗量は `queue_increment_pos_of_overloaded` に対応する。

この Lean file は意図的に狭い。Foster-Lyapunov の positive recurrence theorem を Lean 化していない。また、geometric ergodicity や \(R_n\le R_0e^{-cn}\) 型の指数減衰境界も主張していない。証明しているのは、構造持続の収支原理の \(b_t,B_n,R_t,d_t,r_t\) が Lyapunov drift の代数にどう対応するかである。


9. theorem assumption の継承

Foster-Lyapunov theorem は通常、単なる代数恒等式だけでは成立しない。たとえば、次のような仮定が必要になる。

1. Markov 性。
2. 状態空間の可測構造。
3. irreducibility。
4. small set / petite set 条件。
5. moment 条件。
6. drift 条件が成り立つ領域の指定。
7. 再帰性や正再帰性を結論するための追加条件。

構造持続の収支原理への埋め込みは、これらの仮定を消さない。したがって、正しい言い方は
\[
  \text{Foster-Lyapunov theorem の仮定を満たすなら、その drift 部分は構造持続の収支原理へ埋め込める}
\]
であり、
\[
  \text{構造持続の収支原理だけから queueing stability が無条件に従う}
\]
ではない。

この discipline を守ることで、G6-c は「既存理論の再発見」や「仮定の隠蔽」ではなく、既存理論との形式的接続として読める。


10. この埋め込みが与えるもの

この G6-c 埋め込みが与える価値は三つある。

第一に、構造持続の収支原理が熱力学的比喩だけではなく、既存の確率過程安定性理論と同じ drift algebra を共有していることを示す。

第二に、仕様固定構造ドメイン CSP calibration とは別の方向で、構造持続の収支原理の generality を強化する。random CSP の threshold-local grid に依存せず、負荷、回復入力、過負荷という語彙を既存の安定性理論へ接続できる。

第三に、次の G4 non-CSP anchor を選ぶ基準を与える。すなわち、queueing、reliability、branching process、population dynamics などは、いずれも \(Z_t\), \(b_t\), \(B_n\), \(R_t\) の形に落とせるかどうかで比較できる。


11. この埋め込みが与えないもの

本補論は、次を主張しない。

1. 構造持続の収支原理が Foster-Lyapunov theorem を置き換える。
2. queueing stability theorem を新たに証明した。
3. positive recurrence が構造持続の収支原理だけから従う。
4. 任意の開いた構造系が Markov chain stability 問題である。
5. 物理的な資源入力 \(r_t\) が Lyapunov 負荷の減少と一意に同定される。
6. continuous-time generator や stochastic thermodynamics まで同時に扱った。
7. G6-c iteration 1 が閉じたので universal law が確立した。

本補論の主張は限定的である。

\begin{quote}
Foster-Lyapunov drift calculus は、構造持続の収支原理の期待値レベルの傾向層へ形式的に埋め込める。その際、既存 theorem の仮定は保存される。
\end{quote}


12. 結論

本補論は、構造持続の収支原理の G6-c iteration 1 を reader-facing な形で閉じる。閉じたのは、Foster-Lyapunov drift calculus の最小代数的埋め込みである。すなわち、Lyapunov 負荷 \(Z_t\)、純消耗量 \(b_t\)、累積純消耗量 \(B_n\)、相対維持量 \(R_t\)、構造消耗量 \(d_t\)、回復量 \(r_t\) の対応である。

この最小埋め込みにより、構造持続の収支原理は既存理論との接続において、単なる analogy から一段進む。ただし、それは正再帰性や幾何的エルゴード性を新たに証明したという意味ではない。そこへ進むには、元理論の仮定を保持したうえで、drift theorem 自体を明示的に移植する必要がある。

したがって、本補論の位置づけは明確である。G6-c iteration 1 は閉じており、G6-c iteration 2 は開いている。次に進むべき方向は、positive recurrence / geometric ergodicity の theorem 移植ではなく、まずこの埋め込みを基準として G4 non-CSP anchor を選ぶことである。候補は queueing、reliability、branching process、population dynamics であり、いずれも \(Z_t,b_t,B_n,R_t\) の形へ歪めず写せるかどうかが最初の検査点になる。
