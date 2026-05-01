補論_trajectory-ratio bridge 設計メモ
Trajectory-ratio bridge 設計メモ
— forward / reverse path measure を導入するための v3 plan —

要旨

本補論は、構造持続理論と stochastic thermodynamics の trajectory-level entropy production を安全に接続するための設計メモである。

ここで主張するのは、Core の \(B_n\) が entropy production そのものだということではない。また、fluctuation theorem を現時点で証明済みだということでもない。本補論の目的は、もし
\[
\log\frac{P_{\mathrm{fwd}}(\gamma)}
        {P_{\mathrm{rev}}(\theta\gamma)}
\]
を扱うなら、Core に何を追加構造として入れなければならないかを事前に固定することである。

v1 では、定常下の Core 型ネット構造変化は平均ゼロになり、正の維持散逸は housekeeping cost \(C_t\) 側に置くことを確認した。v2 では、stationarity と nonzero current が両立することを finite-state witness で確認した。v3 では初めて、forward / reverse path measure と path reversal を導入する。


1. なぜ新しい構造が必要か

Core の \(B_n\) は、構造維持可能領域の log-ratio である。
\[
B_n=-\log\frac{m(V^{(n)})}{m(V^{(0)})}
\]
これは pathwise accounting であり、forward path probability と reverse path probability の比ではない。

一方、stochastic thermodynamics の trajectory-level entropy production は、通常、
\[
\sigma[\gamma]
=\log\frac{P_{\mathrm{fwd}}(\gamma)}
          {P_{\mathrm{rev}}(\tilde\gamma)}
\]
のように、二つの path measure の Radon-Nikodym 型の比として定義される。

したがって、Core 側の \(B_n\) だけから \(\sigma[\gamma]\) は出ない。必要なのは、少なくとも次の追加データである。

| 追加データ | 役割 |
|---|---|
| path space \(\Omega_N\) | 有限時間地平の trajectory の空間 |
| forward path measure \(P_{\mathrm{fwd}}\) | 前方 protocol の path probability |
| reverse path measure \(P_{\mathrm{rev}}\) | 逆 protocol の path probability |
| reversal map \(\theta:\Omega_N\to\Omega_N\) | path を時間反転または protocol 反転で対応させる写像 |
| support / absolute-continuity condition | 比が定義不能になる path を防ぐ |
| optional structural observable \(B_N(\gamma)\) | Core 型の構造会計を同じ path 上で読むための観測量 |

この追加構造を固定しない限り、Core の \(B_n\) を entropy production と同一視してはいけない。


2. 最小 finite-state 設計

Lean v3 の最小設計は、まず有限集合上でよい。

有限 path space \(\Omega\) を置き、
\[
P,Q:\Omega\to[0,1]
\]
を二つの PMF とする。ここで \(P\) が forward、\(Q\) が reverse である。path reversal は写像
\[
\theta:\Omega\to\Omega
\]
として固定する。

最初の v3 では、\(\theta\) は少なくとも involution
\[
\theta(\theta(\gamma))=\gamma
\]
または bijection として扱うのが安全である。

forward path の support 上で trajectory ratio を定義するには、少なくとも片側 absolute-continuity 条件
\[
P(\gamma)>0\Rightarrow Q(\theta\gamma)>0
\]
が必要である。このとき、\(\gamma\) を \(P(\gamma)>0\) を満たす path に制限すれば、trajectory ratio は
\[
\sigma(\gamma)
=\log P(\gamma)-\log Q(\theta\gamma)
\]
として定義できる。

ただし、有限和 identity を 1 まで閉じるには、この片側条件だけでは足りない。
\[
\sum_{\gamma:P(\gamma)>0} P(\gamma)e^{-\sigma(\gamma)}
=
\sum_{\gamma:P(\gamma)>0} Q(\theta\gamma)
\]
であるため、右辺が 1 になるには、たとえば support equality
\[
P(\gamma)>0 \Longleftrightarrow Q(\theta\gamma)>0
\]
または「\(Q\) の全質量が \(\theta(\mathrm{supp}\,P)\) に乗る」という reverse-mass coverage 条件が必要である。したがって、Lean v3-a では ratio の点別定義には片側条件を使い、integral identity \(=1\) には support equality / coverage を別仮定として要求する。

この時点で得られるのは、まだ物理的 entropy production ではない。得られるのは、有限 path measure 上の log-ratio observable である。


3. Lean で最初に狙う定理

Lean v3 では、まず名前を控えめにする。

推奨 module 名:
\[
\texttt{Survival.FinitePathTrajectoryRatioBridge}
\]

推奨 theorem set:

| theorem | 内容 |
|---|---|
| `reverse_toReal_pos_on_forward` | \(P(\gamma)>0\Rightarrow Q(\theta\gamma)>0\) の下で、forward support 上の分母が正 |
| `exp_neg_trajectoryRatio_eq_ratioWeight` | forward support 上で \(e^{-\sigma(\gamma)}=Q(\theta\gamma)/P(\gamma)\) 型の点別恒等式 |
| `forward_weighted_exp_neg_ratio_sum_eq_reverse_mass_along_forward_support` | \(\sum_{\gamma:P(\gamma)>0} P(\gamma)e^{-\sigma(\gamma)}\) が reversed forward support を走査した reverse mass に一致 |
| `finite_integral_exp_neg_ratio_identity_of_reverseMassCoverage` | reverse-mass coverage があるとき、指数形の有限和 identity が 1 になる |
| `core_B_not_trajectory_ratio` | \(B_n\) と \(\sigma\) は別データであり、同一視には追加仮定が必要、という reader-facing guardrail |

最後の theorem は数学定理というより、Lean 側では構造体を分けることで表現する。すなわち、Core 型の \(B_N(\gamma)\) と trajectory ratio \(\sigma(\gamma)\) を別フィールドとして持たせ、同一視する theorem をデフォルトでは与えない。

2026-05-01 時点で、v3-a の有限 path-ratio identity は Lean module
`Survival.FinitePathTrajectoryRatioBridge` として形式化済みである。
この module は、`ForwardSupport`, `ReversePositiveOnForward`,
`ReverseMassCoverage`, `trajectoryRatio`, `ratioWeight` を分けて定義し、
次を証明する。

| Lean theorem | 内容 |
|---|---|
| `forward_toReal_pos` | forward support 上で \(P(\gamma)\) の real 化が正 |
| `reverse_toReal_pos_on_forward` | 片側 support guard の下で \(Q(\theta\gamma)\) の real 化が正 |
| `exp_neg_trajectoryRatio_eq_ratioWeight` | \(e^{-\sigma(\gamma)}=Q(\theta\gamma)/P(\gamma)\) の点別恒等式 |
| `forward_weighted_ratio_sum_eq_reverse_mass_along_forward_support` | ratioWeight 版の有限和が reversed forward support を走査した reverse mass に一致 |
| `forward_weighted_exp_neg_ratio_sum_eq_reverse_mass_along_forward_support` | 指数形の有限和が同じ reverse mass に一致 |
| `finite_integral_ratio_identity_of_reverseMassCoverage` | reverse-mass coverage を仮定すると ratioWeight 版の identity が \(1\) に閉じる |
| `finite_integral_exp_neg_ratio_identity_of_reverseMassCoverage` | reverse-mass coverage を仮定すると \(\sum P(\gamma)e^{-\sigma(\gamma)}=1\) が閉じる |

ここで証明されたのは finite path-ratio identity であり、物理的 fluctuation theorem ではない。
また、Core の \(B_n\) との同一視定理は与えていない。なお、ここでいう reverse mass は
\(\theta\) が非単射の場合には set image 上の質量ではなく、`ForwardSupport P` を走査する
multiplicity-sensitive な和である。


4. fluctuation theorem と呼んでよい条件

有限和としては、適切な support 条件と bijection があれば
\[
\sum_\gamma P_{\mathrm{fwd}}(\gamma)
\exp(-\sigma(\gamma))
=1
\]
の形は出せる可能性がある。

しかし、これを stochastic thermodynamics の fluctuation theorem と呼ぶには、さらに次が必要である。

| 必要条件 | 理由 |
|---|---|
| reverse protocol の物理的意味 | 任意の \(Q\) ではなく、時間反転 protocol としての \(P_{\mathrm{rev}}\) が必要 |
| path reversal の意味 | \(\theta\) が単なる bijection ではなく、物理的 time reversal として定義される必要 |
| absolute continuity / support equality | 逆向き確率が 0 の path で比が壊れるのを防ぐ |
| system / medium split | total entropy production を system entropy と medium entropy に分けるには追加構造が必要 |
| local detailed balance など | 熱力学的な heat / work / reservoir 解釈には別仮定が必要 |

したがって、Lean v3 で仮に有限和 identity を証明しても、それは **finite path-ratio identity** であって、ただちに物理的 fluctuation theorem ではない。


5. Core の \(B_n\) との関係

Core の \(B_n\) は、構造維持可能領域の縮退と回復を読む。
\[
B_n=\sum_{t<n}(d_t-r_t)
\]

trajectory ratio は、path probability の非対称性を読む。
\[
\sigma[\gamma]
=\log\frac{P_{\mathrm{fwd}}(\gamma)}
          {P_{\mathrm{rev}}(\theta\gamma)}
\]

両者は同じ対数形式を持つが、型が違う。

| 量 | 入力 | 読んでいるもの |
|---|---|---|
| \(B_n\) | \(m(V^{(t)})\), \(d_t\), \(r_t\) | 構造維持可能領域のネット変化 |
| \(\sigma[\gamma]\) | \(P_{\mathrm{fwd}}\), \(P_{\mathrm{rev}}\), \(\theta\) | path probability の前後非対称性 |
| \(C_t\) | maintenance / housekeeping cost | 定常維持のための別項 cost |
| \(\Sigma_n=B_n+C_n\) | 構造変化 + cost | Core 側の総会計 |

したがって、安全な関係は次のように書く。

\[
B_n \not\equiv \sigma[\gamma]
\]

ただし、特定のモデルで
\[
\sigma[\gamma]=B_N(\gamma)+C_N(\gamma)+R_N(\gamma)
\]
のような分解を事前固定できるなら、そこで初めて correspondence theorem を狙える。ここで \(R_N\) は protocol-dependent な残差または boundary term である。


6. v3 の主張境界

v3 design が主張しないことは次である。

- Core から entropy production が自動的に出る。
- \(B_n\) と \(\sigma[\gamma]\) は同じである。
- nonzero current だけで fluctuation theorem が出る。
- finite path-ratio identity は物理的 FT そのものである。
- Lean v1/v2 の定理から stochastic thermodynamics の第二法則が証明された。

v3 design が主張することは、より限定されている。

1. trajectory-level entropy production へ進むには、forward / reverse path measure と reversal map が必要である。
2. それらを固定すれば、有限 path space 上の log-ratio observable を定義できる。
3. 適切な support / bijection 条件の下で、finite path-ratio identity を証明する設計は可能である。
4. その identity を物理的 fluctuation theorem と呼ぶには、さらに stochastic thermodynamics 側の protocol / reservoir / local detailed balance 仮定が必要である。


7. 実装順序

実装は三段階に分ける。

1. **v3-a: finite path-ratio identity**
   - finite path space
   - two PMFs \(P,Q\)
   - reversal map \(\theta\)
   - forward-support guard for pointwise ratio
   - support equality or reverse-mass coverage for identity \(=1\)
   - finite sum identity
   - Lean status: `Survival.FinitePathTrajectoryRatioBridge` で実装済み

2. **v3-b: Markov path specialization**
   - forward transition kernel \(K\)
   - reverse transition kernel \(K^\dagger\)
   - finite-horizon path PMFs
   - deterministic reversal on trajectories
   - Lean status: `Survival.FiniteStateMarkovTrajectoryRatioBridge` で最小 specialization を実装済み
   - 注意: \(K^\dagger\) は物理的 reverse protocol として導出されたものではなく、別に与える Markov data として扱う

3. **v3-c: structural observable coupling**
   - same path \(\gamma\) 上に \(B_N(\gamma)\), \(C_N(\gamma)\), \(\sigma(\gamma)\) を並べる
   - equality ではなく decomposition / bound / residual として扱う
   - ここで初めて Core と stochastic thermodynamics の correspondence を検討する
   - Lean status: `Survival.FinitePathStructuralObservableBridge` で最小 residual coupling を実装済み
   - 注意: residual は
     \[
     R(\gamma)=\sigma(\gamma)-\{B(\gamma)+C(\gamma)\}
     \]
     として定義され、\(R=0\) は別仮定である

4. **v3-d: local detailed-balance reading**
   - same path \(\gamma\) 上に system-boundary term \(S_{\mathrm{sys}}(\gamma)\) と medium term \(S_{\mathrm{med}}(\gamma)\) を並べる
   - equality ではなく
     \[
     R_{\mathrm{ldb}}(\gamma)=\sigma(\gamma)-\{S_{\mathrm{sys}}(\gamma)+S_{\mathrm{med}}(\gamma)\}
     \]
     を residual として保持する
   - Lean status: `Survival.FinitePathLocalDetailedBalanceBridge` で最小 system/medium residual coupling を実装済み
   - 注意: local detailed balance は証明されるのではなく、`HasExactLocalDetailedBalanceReading` として別仮定にする

現時点で Lean に入っているのは v3-a, v3-b, v3-c, v3-d の最小版である。v3-b は、二つの有限状態 Markov data から
forward / reverse path PMF を作り、deterministic time reversal で v3-a の finite identity に接続する。
ただし、reverse Markov data が物理的 reverse protocol であること、local detailed balance、heat/work/reservoir
解釈はまだ入っていない。v3-c は、structural observable \(B_N(\gamma)\) と housekeeping cost
\(C_N(\gamma)\) を同じ path 上に並べ、trajectory ratio との差を residual \(R_N(\gamma)\) として保持する。
したがって、\(B+C=\sigma\) はデフォルトの theorem ではなく、zero residual 仮定の下でのみ得られる。
v3-d は、stochastic thermodynamics 側の system / medium split について同じ安全策をとる。すなわち、
\[
\sigma(\gamma)=S_{\mathrm{sys}}(\gamma)+S_{\mathrm{med}}(\gamma)
\]
はデフォルトではなく、local-detailed-balance residual がゼロである場合に限って得られる。

v3-c の Lean module は次を与える。

| Lean theorem / definition | 内容 |
|---|---|
| `StructuralObservableData` | forward support 上の \(B(\gamma)\), \(C(\gamma)\) を別データとして持つ |
| `trajectoryResidual` | \(R(\gamma)=\sigma(\gamma)-(B(\gamma)+C(\gamma))\) |
| `HasZeroResidual` | \(R(\gamma)=0\) を明示仮定として表す |
| `structuralTotal_add_residual_eq_trajectoryRatio` | \(B+C+R=\sigma\) の定義的分解 |
| `trajectoryRatio_eq_structuralTotal_of_zeroResidual` | \(R=0\) なら \(\sigma=B+C\) |
| `finite_integral_structural_residual_identity_of_reverseMassCoverage` | residual を含めた \(\sum P e^{-(B+C+R)}=1\) |
| `finite_integral_structural_total_identity_of_zeroResidual` | coverage と \(R=0\) の下で \(\sum P e^{-(B+C)}=1\) |

v3-d の Lean module は次を与える。

| Lean theorem / definition | 内容 |
|---|---|
| `SystemMediumEntropyData` | forward support 上の system-boundary term と medium term を別データとして持つ |
| `localDetailedBalanceResidual` | \(R_{\mathrm{ldb}}=\sigma-(S_{\mathrm{sys}}+S_{\mathrm{med}})\) |
| `HasExactLocalDetailedBalanceReading` | \(R_{\mathrm{ldb}}=0\) を明示仮定として表す |
| `totalEntropyProduction_add_residual_eq_trajectoryRatio` | \(S_{\mathrm{sys}}+S_{\mathrm{med}}+R_{\mathrm{ldb}}=\sigma\) の定義的分解 |
| `trajectoryRatio_eq_totalEntropyProduction_of_exactReading` | exact reading の下で \(\sigma=S_{\mathrm{sys}}+S_{\mathrm{med}}\) |
| `finite_integral_system_medium_residual_identity_of_reverseMassCoverage` | residual を含めた \(\sum P e^{-(S_{\mathrm{sys}}+S_{\mathrm{med}}+R_{\mathrm{ldb}})}=1\) |
| `finite_integral_totalEntropy_identity_of_exactReading` | coverage と exact reading の下で \(\sum P e^{-(S_{\mathrm{sys}}+S_{\mathrm{med}})}=1\) |


8. 結論

trajectory-ratio bridge は、NESS analogy の中で初めて stochastic thermodynamics 側の本物の構造に触れる段階である。そのため、v1/v2 より主張境界を強く管理する必要がある。

本補論の結論は単純である。

Core の \(B_n\) は構造会計であり、path probability ratio ではない。trajectory-level entropy production を扱うには、forward / reverse path measure、reversal map、support 条件を追加で固定する必要がある。その追加構造の上でなら、有限 path-ratio identity から始めることができる。Lean v3-a は、この最小 identity を機械検証したものであり、Lean v3-b はそれを有限状態 Markov path PMF に特殊化したものである。Lean v3-c は、同じ path 上に structural observable と cost observable を置き、trajectory ratio との差を residual として明示化することで、Core の \(B_n\) と \(\sigma\) の同一視を避けたまま correspondence を検討する足場を与える。Lean v3-d は、local detailed balance 風の system / medium split にも同じ残差規律を課し、物理的 entropy-production reading は追加仮定の下でのみ得られることを形式化する。
