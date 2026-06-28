補論_Shannon 型操作的整合性の現在地
Shannon 型操作的整合性の現在地
— 仕様固定レイヤーにおける third-layer anchor の整理 —

要旨

本メモは、構造持続理論と Shannon 1948 型の比較を、過大にも過小にも
読まないための横断整理である。

Shannon の仕事を三層に分けるなら、第一層は座標の導入、第二層は
表現定理、第三層は独立に定義された操作的量との一致である。構造持続
理論では、座標導入と表現定理は Lean 側の中核で扱う。一方、本
リポジトリの仕様固定レイヤーには、第三層に対応する操作的 anchor が
複数存在する。

ただし、ここで言う第三層は、Shannon 通信容量定理そのものを再証明した
という意味ではない。より正確には、仕様から状態空間、質量、曝露法則、
境界、判定対象が固定できる有限 domain において、構造持続座標が独立に
定義された操作的 endpoint と一致、境界化、または out-of-sample 予測
整合を示している、という意味である。

安全な一文は次である。

> 構造持続理論は、座標導入と表現定理に加えて、仕様固定 domain では
> Shannon 型第三層に相当する操作的整合性を持ち始めている。特に有限
> CSP、SAT 発見コスト、BEC 線形符号、s-t 信頼性では、構造持続座標が
> 独立に定義された判定対象や予測 endpoint に接続する。ただし、これは
> Shannon 通信容量定理の再証明でも、任意 domain の universal law でも
> ない。


1. 比較の基準
--------------

Shannon 型の強さを、ここでは三層に分ける。

第一層は、対象現象を測る座標を導入することである。Shannon では
エントロピー \(H\)、構造持続理論では \(L\), \(B\), \(M\), boundary,
certificate などの境界座標がこれに当たる。

第二層は、その座標が任意の定義ではなく、自然な保存条件や分解条件から
一意に出ることを示す表現定理である。Shannon ではエントロピーの公理的
一意性、構造持続理論では対数比、収支、同値までの必要文法が対応する。

第三層は、座標とは別に定義された操作的量が、その座標で読めることで
ある。Shannon では source coding / channel coding theorem により、
抽象量 \(H\) や capacity が圧縮率や通信限界という工学量に接続する。

構造持続理論で問うべき第三層は、次の形である。

- endpoint が \(L\) や \(B\) の定義そのものではなく、別に定義されている。
- raw count, raw density, simple resource sum などの弱い座標では区別
  できない非縮退条件がある。
- 構造持続座標が、その endpoint に対して厳密境界、漸近主項、有限包絡、
  または事前登録された予測支持を与える。
- 失敗、非支持、無効 run がある場合は、成功と同じ台帳で記録される。


2. 仕様固定レイヤーの主要 anchor
----------------------------------

2.1 有限 CSP / Mixed-SAT-NAE / q-coloring
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`v3/03_domains/01_specification_fixed/finite_csp.md` は、現在の最も強い
経験的 third-layer anchor の一つである。

単一制約族では \(L=m\cdot d\) となり、raw count の定数倍に縮退する。
このため、単一 3-SAT だけで \(L\) が raw count より強いと主張する
ことはできない。Mixed-SAT/NAE-SAT では、raw count を固定したまま
制約ごとの drift を変えられるため、非縮退な検査が可能になる。

この設定で、\(L+n\) および \(n\log 2-L\) 型の first-moment coordinate
は、raw count / raw density baseline より feasibility を強く
out-of-sample に予測した。さらに q-coloring の threshold-local package
でも、first-moment / drift coordinate が raw / density / encoding-size
baseline を上回った。

これは Shannon の coding theorem そのものではない。しかし、

- raw count では区別できない仕様差を \(L\) が区別する。
- endpoint は feasibility であり、\(L\) の定義そのものではない。
- 事前登録、freeze、外部再実行がある。

という意味で、座標が単なる relabeling ではないことを示す強い
操作的 anchor である。


2.2 SAT 発見コスト
~~~~~~~~~~~~~~~~~~

`v3/03_domains/01_specification_fixed/computational_cost.md` は、存在と
発見を分ける。

存在側では、第一モーメント法により
\[
  E[\#\mathrm{SAT}]=2^n(7/8)^m=\exp(n\log 2-L)
\]
が成り立つ。ここで \(L=m|\log(7/8)|\) は仕様から固定される。

発見側では、ソルバー予算 \(\mu\) と中央値コスト \(\mu_c(L)\) を置き、
\[
  \mu_c(L)=A e^{cL}
\]
型の scaling を検査する。random search では \(c=1\) が厳密な構造非依存
基準線として出る。一方、CDCL や WalkSAT では \(c<1\) の経験的感度が
観測される。

この anchor の価値は、同じ \(L\) が存在側と発見側の双方に現れる一方、
発見側では solver-dependent sensitivity \(c\) が入ることを分離した点に
ある。

ただし、ここでの \(c=1\) は random search の厳密 baseline であって、
任意ソルバーに対する universal lower bound ではない。SAT solver 全体に
ついて \(c_{\min}\) を下から押さえる主張は、ETH や P vs NP 近傍の難問に
触れるため、本 anchor の claim ではない。


2.3 BEC 線形符号復元
~~~~~~~~~~~~~~~~~~~~

`v3/02_foundations/27_specification_fixed_operational_theorems.md` と
`v3/03_domains/01_specification_fixed/coding_channel_recovery.md` は、
Shannon の本拠地に最も近い anchor である。

固定 parity-check matrix \(H\) と消失集合 \(E\) に対し、
\[
  a(E)=|E|-\operatorname{rank}(H_E)
\]
を置くと、両立符号語の数は \(2^{a(E)}\) であり、区別可能な
message-cell mass は \(2^{-a(E)}\) に縮む。したがって
\[
  L_E=a(E)\log 2
\]
である。一意復元は \(a(E)=0\) と同値であり、\(L_E\) は復元境界を
厳密に読む。

さらに、検査行数を \(r\) とすると、任意固定符号で
\[
  |E|>r \Rightarrow \text{一意復元不能}
\]
が成り立つ。これは有限の deterministic converse である。

ランダム検査行列側では、full-rank 失敗確率の包絡が与えられた場合、
行数 slack \(s\) により失敗確率を \(2^{-s}\) 以下に押さえる
achievability-side envelope が得られる。さらに BEC 消失数集中包絡と
合成することで、failure \(\le \delta+2^{-s}\) といった有限包絡が得られる。

Lean 側では、これらは次の形に分かれる。

- `LinearCodeBECRankBoundary`: finite deterministic converse.
- `LinearCodeRandomParityCheckFullRank`: random-ensemble full-rank envelope.
- `LinearCodeBECConcentrationBoundary`: erasure-count concentration との event-level connection.
- `LinearCodeBECCapacityStyleBoundary`: finite achievability/converse envelope bundle.

この構成は Shannon-style である。ただし文書が明示する通り、これは BEC
capacity theorem の再証明ではない。二項 Chernoff、正確なランダム行列
rank formula、漸近容量定理は外側に残る。


2.4 s-t cut-spectrum reliability
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`v3/03_domains/01_specification_fixed/st_cut_spectrum_reliability.md` は、
operational embedding と経験的支持を併せ持つ。

固定 finite graph、terminals \(s,t\)、独立 edge-failure probability
\(q\) を置く。最小 \(s\)-\(t\) cutset size を \(\kappa\)、最小 cutset
の個数を \(N_\kappa\) とすると、低 failure limit で
\[
  \Pr_q(s\not\leftrightarrow t)
  =
  N_\kappa q^\kappa + O(q^{\kappa+1})
  \quad(q\to0)
\]
が成り立つ。

これは単なる経験的 fit ではなく、操作的失敗確率の leading term に
cut-spectrum coordinate が現れるという解析的 embedding である。

一方、経験的 prediction package では、\(\kappa=2\) と \(\kappa=3\) の
restricted finite synthetic surfaces で scalar low-order cut-spectrum
pressure が supported と記録されている。初回 v0 は invalid run として
記録され、成功に書き換えられていない。

したがって、この anchor の safe reading は次である。

> finite \(s\)-\(t\) reliability では、low-order cut-spectrum coordinate
> が操作的 disconnection probability の leading-order pressure として
> 現れ、さらに制限された frozen synthetic surfaces で予測支持を持つ。
> ただし arbitrary graph, arbitrary \(\kappa\), exact reliability
> superiority, real network support は主張しない。


3. 条件付き埋め込みとの区別
----------------------------

`v3/03_domains/03_conditional_embedding/foster_lyapunov.md` と
`v3/03_domains/03_conditional_embedding/non_csp_classical.md` は、第三層の
経験的 evidence ではなく、既存古典理論への条件付き formal embedding で
ある。

Foster-Lyapunov では、負荷 \(Z_t=W(X_t)\) を置き、
\[
  b_t=Z_{t+1}-Z_t,
  \qquad
  B_n=Z_n-Z_0,
  \qquad
  R_{t+1}=R_t e^{-b_t}
\]
と読める。これは構造持続の収支原理の \(b_t,B_n,R_t\) と同じ algebraic
shape を持つ。

しかし、この embedding は positive recurrence theorem や geometric
ergodicity を構造持続理論から新たに証明するものではない。Markov 性、
irreducibility、小集合条件、moment 条件など、元理論の仮定は保持される。

したがって、これらは次のように読む。

> 非CSP古典理論の drift / balance calculus は、構造持続の収支原理の
> 変数へ歪めず埋め込める。ただし、それは既存 theorem の置き換えでも、
> empirical validation でもない。


4. 支持、非支持、無効 run の意味
---------------------------------

Shannon 型比較で重要なのは、成功例だけでなく失敗・非支持も同じ台帳に
置かれていることである。

例:

- BEC recovery v1: generator infeasible による invalid run.
- BEC recovery v1b: directionally positive だが frozen 1% gate 未達の no-support.
- stopping-set recovery v2: directionally positive だが primary gate 未達の no-support.
- s-t cut-spectrum v0: frozen attempt cap による invalid run.
- s-t cut-spectrum v0b/v0c: \(\kappa=2,3\) の restricted surfaces で support.
- flow-network M testbed: strongest frozen baseline では no-support.
- spanning-tree persistence v0: primary no-support; matched-residual v1 では support.

これは弱点ではなく、claim discipline の一部である。野心的な統一理論ほど、
支持だけを集めると危険になる。ここでは、どの surface が support で、
どの surface が no-support / invalid なのかを分けることで、第三層 anchor
の範囲を制限している。


5. 現在の安全な結論
--------------------

現時点で安全に言えるのは次である。

1. 構造持続理論には、座標導入と表現定理だけでなく、仕様固定 domain における
   操作的整合性 anchor が複数ある。
2. 有限 CSP / Mixed-CSP / q-coloring では、drift / first-moment coordinate が
   raw baseline より feasibility を強く予測する evidence がある。
3. SAT discovery cost では、存在 \(L\) と発見 cost \(\mu_c\) が分離され、同じ
   structural parameter が solver-dependent sensitivity を通じて発見側にも
   現れる。
4. BEC 線形符号では、消失ランク loss \(L_E=a(E)\log2\) が一意復元境界を厳密に
   読み、finite achievability/converse envelope が形式化されている。
5. s-t reliability では、cut-spectrum coordinate が operational failure
   probability の leading-order term に現れ、restricted finite surfaces で
   prediction support がある。
6. Foster-Lyapunov / non-CSP classical anchors は、empirical third layer ではなく、
   既存理論との conditional embedding である。

このため、次の言い方は弱すぎる。

> 構造持続理論には、Shannon の第一層と第二層しかまだない。

一方、次の言い方は強すぎる。

> 構造持続理論は、Shannon 通信容量定理と同等の universal theorem をすでに
> 持っている。

安全な現在地は、その中間である。

> 構造持続理論は、Shannon 型の第三層へ向かう具体的構築物をすでに複数持つ。
> 仕様固定 domain では、構造持続座標が独立の操作的 endpoint と一致、境界化、
> または予測整合する例がある。ただし、それらは finite / class-bounded /
> surface-bounded であり、Shannon capacity theorem 級の universal converse や
> 任意 domain への自由転用はまだ主張しない。


6. 次の本丸
-----------

次に問うべきことは、既存理論を構造持続座標で読み直せるかだけではない。
より強い問いは次である。

> 構造持続座標が、既存分野でまだ標準化されていない操作的量を事前に予測し、
> 後から独立に測られた endpoint と一致するか。

候補は三つある。

第一に、有限 CSP 側で scoped converse をさらに硬くする。raw count / density /
encoding size だけを見る predictor が Mixed-CSP の paired instances を区別
できないことを、経験だけでなく feature-class limitation として固定する。

第二に、SAT discovery cost 側で solver class を明示した lower envelope を
切る。任意ソルバーの lower bound は難しいが、structure-blind search や
限定 heuristic class に対する converse は現実的である。

第三に、非CSP empirical branch で、queueing / maintenance / reliability logs
に対して非縮退な design を組む。同じ raw resource や raw load では区別できず、
\(d_t-r_t\), cut-spectrum, qualified \(M\) だけが異なる条件を作り、独立 endpoint
を測る。

この方向で成功すると、Shannon 比較は比喩ではなく、系譜としてさらに強くなる。


7. 外向き wording
-----------------

短い説明では、次の wording を使う。

> SPT is not claiming to reprove Shannon capacity. Its current claim is more
> precise: beyond the coordinate and representation layers, several
> specification-fixed domains already show Shannon-style operational alignment.
> Finite CSPs give preregistered and externally rerun evidence that drift /
> first-moment coordinates outperform raw baselines; finite BEC linear-code
> recovery gives an exact rank-loss readout and a capacity-style finite
> achievability/converse envelope; and finite s-t reliability gives a
> leading-order cut-spectrum embedding. These are bounded anchors, not a
> universal free-transfer theorem.

日本語では次のように言う。

> 構造持続理論は Shannon 容量定理を再証明したとは言わない。正確には、
> 座標導入と表現定理に加えて、仕様固定 domain では Shannon 型第三層に
> 相当する操作的整合性が複数出ている。有限 CSP、BEC 線形符号、s-t 信頼性
> では、構造持続座標が独立に定義された判定対象や予測 endpoint に接続する。
> ただし、それらは bounded anchor であり、任意 domain への自由転用や
> universal capacity theorem 級の主張ではない。
