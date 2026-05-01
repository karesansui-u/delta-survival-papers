補論_定常 current と detailed balance の橋渡し
定常 current と detailed balance の橋渡し
— NESS analogy のための finite-state stationary-current bridge —

要旨

本補論は、構造持続理論と非平衡定常状態 (NESS) の関係をさらに一段だけ進めるための、有限状態 Markov chain 上の current bridge である。

前補論「定常維持と総生成量の橋渡し」では、定常分布の下で Core 型のネット構造変化は平均ゼロになり、正の維持散逸は housekeeping cost \(C_t\) として別項に置くべきだと整理した。本補論では、その次の構造として、定常分布を保ったまま存在しうる循環流
\[
J(x,y)=\pi(x)K(x,y)-\pi(y)K(y,x)
\]
を切り出す。

ここで主張するのは、stochastic thermodynamics の entropy production を証明したということではない。証明しているのは、有限状態・定常 flow の会計である。すなわち、stationary current は反対称であり、detailed balance は current が全て 0 であることと同値であり、detailed balance は stationarity より強い条件である、という最小事実である。さらに、三状態 deterministic cycle と uniform stationary distribution により、stationarity と nonzero current が両立する小さな witness も Lean 上で与える。

Lean 側では、この bridge を
\[
\texttt{Survival.FiniteStateMarkovStationaryCurrent}
\]
として追加した。


1. なぜ current が必要か

定常分布 \(\pi\) の下では、状態ポテンシャル \(\phi(x)\) の一歩期待差は 0 になる。これは前補論の主張である。

しかし、期待差が 0 であることは、状態間の流れがないことを意味しない。確率分布は定常でも、状態間には循環流が残りうる。このとき、各状態の占有確率は変わらないが、遷移の向きつき flow は釣り合っていない。

この違いを分けるために、定常 pair flow を
\[
F(x,y)=\pi(x)K(x,y)
\]
と置き、stationary current を
\[
J(x,y)=F(x,y)-F(y,x)
\]
と定義する。

この \(J\) は、Core の \(b_t\) ではない。Core の \(b_t\) は状態ポテンシャル差、すなわち exact differential 型のネット構造変化である。一方、\(J\) は定常分布上の循環 flow である。この二つを混同しないことが、NESS analogy を安全に進める条件である。


2. Detailed balance と stationarity

詳細釣り合い detailed balance は
\[
\pi(x)K(x,y)=\pi(y)K(y,x)
\]
が全ての \(x,y\) について成り立つこととして読む。

このとき、ただちに
\[
J(x,y)=0
\]
である。逆に、全ての \(x,y\) で \(J(x,y)=0\) なら、詳細釣り合いが成り立つ。

さらに、詳細釣り合いは定常性
\[
\pi K=\pi
\]
を含意する。したがって、関係は次のように整理される。

| 条件 | 意味 |
|---|---|
| detailed balance | 全 pair flow が向きごとに釣り合う |
| stationarity | 各状態への総流入と総流出が釣り合う |
| nonzero current | stationarity はありえても detailed balance は破れている |

NESS analogy の入口は、ここにある。定常分布が保たれていても、detailed balance が破れて nonzero current が残る場合がある。ただし、この事実だけでは entropy production rate はまだ定義されない。


3. Lean 形式化

対応する Lean module は
\[
\texttt{Survival.FiniteStateMarkovStationaryCurrent}
\]
である。

今回追加した主な定義と定理は次の通りである。

| Lean item | 内容 |
|---|---|
| `stationaryFlow` | \(\pi(x)K(x,y)\) を real coordinate で読む |
| `stationaryCurrent` | \(J(x,y)=F(x,y)-F(y,x)\) |
| `DetailedBalance` | real stationary-flow 座標での詳細釣り合い |
| `DetailedBalanceENN` | underlying `ENNReal` probability 座標での詳細釣り合い |
| `stationaryCurrent_antisymm` | \(J(x,y)=-J(y,x)\) |
| `detailedBalance_iff_current_eq_zero` | detailed balance と zero current の同値 |
| `detailedBalance_of_detailedBalanceENN` | `ENNReal` detailed balance から real detailed balance へ |
| `current_eq_zero_of_detailedBalanceENN` | `ENNReal` detailed balance は zero current を含意 |
| `nonzero_current_implies_not_detailedBalance` | current が非ゼロなら detailed balance は破れている |
| `detailedBalanceENN_implies_stationary` | `ENNReal` detailed balance は \(\pi K=\pi\) を含意 |
| `uniformCycle_stationary` | 三状態 deterministic cycle の uniform 分布が stationary である |
| `uniformCycle_nonzero_current` | 同じ stationary cycle が非ゼロ current を持つ |
| `stationary_with_nonzero_current_witness` | stationarity と nonzero current が両立する具体 witness |

`detailedBalanceENN_implies_stationary` では、\(\pi K=\pi\) を PMF の等式として示すため、`ENNReal` 座標の detailed balance を使っている。real coordinate の current は読者向けには自然だが、PMF の stationarity を証明するには underlying probability mass の等式が扱いやすい。一方、stationarity と nonzero current の両立は、三状態 cycle witness によって別途示している。

型検査は次で確認した。
\[
\texttt{lake build Survival.FiniteStateMarkovStationaryCurrent}
\]


4. 主張境界

本補論は、次を主張しない。

- stationary current が entropy production rate である。
- nonzero current から直ちに正の entropy production が従う。
- forward / reverse path probability ratio を構成した。
- fluctuation theorem を導いた。
- stochastic thermodynamics の NESS を Core から証明した。

本補論が与えるのは、NESS analogy に必要な有限状態の次の区別である。

1. 定常分布での状態ポテンシャル差の平均は 0 になる。
2. それでも、pair flow の反対称成分 \(J\) は非ゼロでありうる。
3. \(J=0\) は detailed balance、\(J\ne0\) は detailed balance の破れを表す。
4. しかし、entropy production を読むには path probability ratio などの追加構造が必要である。


5. 次の段階

次に進むなら、v3 は trajectory-ratio bridge である。設計境界は、補論「trajectory-ratio bridge 設計メモ」に切り出す。

そこでは、forward path measure と reverse path measure を別に固定し、absolute continuity と Radon-Nikodym 比
\[
\log\frac{P_{\mathrm{fwd}}(\gamma)}{P_{\mathrm{rev}}(\tilde\gamma)}
\]
を導入する必要がある。

この段階に進んで初めて、stochastic thermodynamics の entropy production との形式対応を議論できる。したがって、v2 の current bridge は、NESS analogy の入口ではあるが、entropy production bridge ではない。v3 でも最初に狙うのは物理的 FT ではなく、有限 path space 上の path-ratio identity である。
