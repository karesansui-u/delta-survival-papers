補論_定常維持と総生成量の橋渡し
定常維持と総生成量の橋渡し
— NESS analogy のための finite-state stationary total-production bridge —

要旨

本補論は、構造持続理論と非平衡定常状態 (NESS) の関係を、過剰主張なしに接続するための最小橋渡しである。

ここで主張するのは、Core の純消耗量 \(b_t\) が stochastic thermodynamics の total entropy production そのものだということではない。むしろ逆である。Core の
\[
b_t=-\log\frac{m(V^{(t+1)})}{m(V^{(t)})}
\]
は、構造維持可能領域のネット変化を読む量である。したがって、構造維持可能領域が定常に保たれるなら、長期平均では \(b_t\) はほぼ 0 でなければならない。

非平衡定常状態に似た正の散逸または維持コストは、\(b_t\) とは別に、housekeeping / maintenance cost \(C_t\) として記録されるべきである。総生成量を
\[
\Sigma_n=B_n+C_n
\]
と置くと、定常維持では \(B_n\approx 0\) であっても、\(C_n>0\) により \(\Sigma_n>0\) となりうる。この分離が、本補論の中心である。

Lean 側では、この有限状態・定常分布レベルの橋渡しを
\[
\texttt{Survival.FiniteStateMarkovHousekeepingBridge}
\]
として追加した。これは NESS 極限定理、詳細釣り合いの破れ、stationary current、fluctuation theorem を証明するものではない。証明しているのは、定常分布の下では状態ポテンシャル差の期待値が 0 になり、総生成量の定常平均が housekeeping cost の定常平均に等しくなる、という有限状態の会計恒等式である。


1. なぜこの補論が必要か

Core と Paper 2 は、構造維持可能領域の変化を
\[
b_t=d_t-r_t
=-\log\frac{m(V^{(t+1)})}{m(V^{(t)})}
\]
として読む。累積すると
\[
B_n=\sum_{t<n}b_t
=-\log\frac{m(V^{(n)})}{m(V^{(0)})}
\]
であり、これは pathwise な望遠鏡積である。

したがって、ある開いた系が修復や外部入力によって定常的に維持され、
\[
m(V^{(n)})\approx m(V^{(0)})
\]
であるなら、対応する純構造変化は
\[
B_n\approx 0
\]
である。長期平均で言えば、
\[
\frac{B_n}{n}\approx 0
\]
である。

ここで \(B_n/n>0\) を NESS の正の散逸として読んでしまうと、Core の定義と矛盾する。正の散逸や維持コストを読みたいなら、\(b_t\) とは別の項を導入しなければならない。


2. 定常維持の最小定式化

有限状態 \(x\) に、状態ポテンシャル
\[
\phi(x)=\log m(V_x)
\]
を対応させる。遷移 \(x\to y\) に伴うネット構造変化を
\[
b(x,y)=\phi(x)-\phi(y)
\]
と読む。これは、状態 \(x\) での維持可能領域から状態 \(y\) での維持可能領域へ移るときの log-ratio である。

有限状態 Markov chain の遷移核を \(K(x,y)\)、定常分布を \(\pi\) とし、
\[
\pi K=\pi
\]
を仮定する。このとき、定常始動のもとでは
\[
\mathbb E_\pi[b(X_t,X_{t+1})]=0
\]
である。

これは「定常状態では構造消耗がない」という意味ではない。消耗と回復、故障と修復、負荷と処理が流れていても、状態ポテンシャルの平均的なネット変化は 0 になる、という意味である。


3. Housekeeping cost と総生成量

定常維持に必要な外部入力、修復努力、処理、保守コストを、非負の項
\[
C(x,y)\ge 0
\]
として事前固定する。

一般の stochastic thermodynamics との接続を考えるなら、\(C\) は遷移 \(x\to y\) に乗る量として置くのが自然である。ただし、今回の Lean v1 では既存の finite-state repair-chain interface に合わせ、状態依存の特殊形 \(C(x)\) を形式化している。これは \(C(x,y)=C(x)\) と読む場合に対応する。

このとき、遷移ごとの総生成量を
\[
\sigma(x,y)=b(x,y)+C(x,y)
\]
と定義する。定常分布のもとでは、前節の結果により
\[
\mathbb E_\pi[\sigma]
=\mathbb E_\pi[b]+\mathbb E_\pi[C]
=\mathbb E_\pi[C].
\]
したがって、\(C\ge0\) なら
\[
\mathbb E_\pi[\sigma]\ge0
\]
であり、さらに \(\mathbb E_\pi[C]>0\) なら
\[
\mathbb E_\pi[\sigma]>0
\]
である。

これが NESS analogy における安全な最小読みである。定常維持では Core の \(b_t\) は平均ゼロへ向かう。一方、定常維持を支える housekeeping / maintenance cost は別項 \(C_t\) として正に流れ続けうる。


4. Core との関係

Core が直接扱うのは、構造維持可能領域のネット変化である。

| Core の量 | 読み方 |
|---|---|
| \(b_t\) | 一ステップのネット構造変化 |
| \(B_n\) | 累積ネット構造変化 |
| \(C_t\) | 維持のために支払う別項の cost / throughput |
| \(\Sigma_n=B_n+C_n\) | 総生成量、または housekeeping cost を含む総会計 |

この分離により、次の二つを混同しない。

1. 構造維持可能領域が縮むこと。
2. 構造維持可能領域を定常に保つために、外部入力や修復コストが流れ続けること。

前者は \(B_n\) が読む。後者は \(C_n\) または \(\Sigma_n\) が読む。


5. NESS analogy の主張境界

本補論は、stochastic thermodynamics の NESS を Core から導出するものではない。

主張しないことは次の通りである。

- detailed balance の破れを証明する。
- stationary current \(J(x,y)\) を構成する。
- path probability ratio \(\log(P_{\mathrm{fwd}}/P_{\mathrm{rev}})\) を Core の \(B_n\) と同一視する。
- fluctuation theorem を導く。
- entropy production rate を Lean で証明済みだと主張する。

本補論が主張するのは、より限定されたことである。すなわち、有限状態・定常分布のもとで、状態ポテンシャル差として読んだ Core 型のネット構造変化は期待値 0 になり、正の定常総生成量を読むには別項 \(C_t\) が必要である、ということである。

したがって、NESS との関係は現時点では G6-b から G6-c へ向かう途中の bridge である。Core 本文に入れる場合は、formal analogy / stationary total-production bridge として扱い、stochastic thermodynamics の完全同一視は避ける。


6. Lean 形式化

この補論に対応する Lean module は
\[
\texttt{Survival.FiniteStateMarkovHousekeepingBridge}
\]
である。

この module は、既存の
\[
\texttt{Survival.FiniteStateMarkovStationaryProduction}
\]
の上に立つ。既存側では、有限状態 repair / failure chain、定常分布、定常平均 total production、有限 prefix での線形 expected cumulative center が形式化されている。今回の v1 theorem set は、housekeeping cost を状態依存 \(C(x)\) として扱う最小特殊形であり、遷移依存 \(C(x,y)\) と stationary current まで含む形は次段階に残す。

今回追加した主な定理は次の通りである。

| Lean theorem | 内容 |
|---|---|
| `stationary_expected_netChange_eq_zero` | 定常分布の下で、任意の状態ポテンシャルの一歩期待ネット変化は 0 |
| `stationary_expected_totalProduction_eq_cost` | total production = net change + cost と定義したとき、定常平均 total production は定常平均 cost に等しい |
| `stationary_expected_totalProduction_nonneg` | cost が非負なら、定常平均 total production は非負 |
| `positive_housekeeping_of_positive_cost` | 定常平均 cost が正なら、定常平均 total production は正 |
| `n_times_stationary_expected_totalProduction_eq_cost` | 任意の \(n\) について、定常平均 total production と定常平均 cost の等式を \(n\) 倍しても保たれる |

最後の定理は、path-level の累積過程を構成するものではなく、平均レベルの会計恒等式である。この theorem set は、NESS そのものを証明するものではない。むしろ、NESS analogy に入る前に、Core の \(b_t\) と housekeeping cost を混同しないための guardrail である。

型検査は次で確認した。
\[
\texttt{lake build Survival.FiniteStateMarkovHousekeepingBridge}
\]


7. 次の段階

次に進む場合は、三段階に分けるのが安全である。

1. **Stationary total-production bridge v1**
   現在の有限状態・定常分布・housekeeping cost の橋渡しを、文書と Lean mapping に登録する。

2. **Stationary current v2**
   \(J(x,y)=\pi(x)K(x,y)-\pi(y)K(y,x)\) を定義し、詳細釣り合いの成立 / 破れを扱う。これは補論「定常 current と detailed balance の橋渡し」および Lean module `Survival.FiniteStateMarkovStationaryCurrent` として切り出した。

3. **Trajectory-ratio / fluctuation bridge v3**
   forward / reverse path measure、absolute continuity、Radon-Nikodym 比を導入し、stochastic thermodynamics の entropy production との対応を検討する。最初の設計境界は、補論「trajectory-ratio bridge 設計メモ」に置く。

v1 と v2 は Core の運用規律と整合する有限状態 bridge である。v3 以降は stochastic thermodynamics 側の追加構造を必要とするため、別補論または future bridge として扱うべきである。とくに、Core の \(B_n\) を path probability ratio と同一視しない。
