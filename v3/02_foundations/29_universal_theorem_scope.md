補論_universal theorem の射程
Universal theorem の射程
仕様固定境界、必要文法、自由転用の分離

要旨

本メモは、構造持続理論における "universal theorem" という語を、
過大にも過小にも読ませないための整理である。

結論は三つである。

第一に、構造持続理論が最も強く主張できる universal theorem は、
全現象を同じ数式で予測する定理ではなく、持続・停止・崩壊 claim を
厳密に立てるための必要文法定理である。

第二に、仕様固定 domain では、その必要文法が操作的境界へ接続する
class-bounded universal theorem がある。有限 CSP、BEC 線形符号、
s-t 信頼性はこの層に属する。

第三に、任意の物理系、任意の LLM、任意の組織、任意のソフトウェアに
対して、同じ式が無条件に tight prediction boundary になるとは主張しない。
それは構造持続理論の現在の claim ではなく、将来も free transfer として
許してはならない。

したがって、正しい読みは次である。

> 構造持続理論は、万能予測定理ではない。だが、維持対象を持つ
> 持続・停止・崩壊 claim を厳密に計算・監査する場合、その claim が
> 必要とする役割分解は universal に再出現する。さらに仕様固定 class では、
> その文法が操作的境界へ接続する定理や有限包絡を持つ。


1. Universal theorem という語の危険
-------------------------------------

"universal theorem" は便利な言葉だが、少なくとも三つの意味に分かれる。

| 種類 | 内容 | SPT での位置 |
|---|---|---|
| 文法側 universal theorem | ある型の claim を厳密に立てるなら、必要な役割が避けられない | G1 の主線 |
| 仕様固定 class theorem | 明示された class 内の全対象で、構造座標が操作的境界へ接続する | 有限 CSP / BEC / s-t reliability |
| 全ドメイン万能予測 theorem | 任意 domain で同一式が tight prediction boundary になる | 主張しない |

混乱は、この三つを一つに潰すと起きる。

構造持続理論の強みは、第三の意味で無理に universal を言うことではない。
第一と第二を明確に切り、第三を禁止することである。


2. 文法側 universal theorem
----------------------------

文法側 universal theorem の対象は、世界の任意現象ではない。
対象は、次のような claim である。

> 特定の性質、機能、状態、同一性、達成目標などを維持対象 \(F\) として置き、
> その維持、停止、崩壊、回復、介入を厳密に計算または監査しようとする claim。

このとき、裸の \(F\) だけでは、持続・停止・崩壊は計算できない。
少なくとも次の役割が必要になる。

- 維持対象 \(F\)
- \(F\) を実現または支持する構造 \(K\)
- \(K\) が \(F\) を維持できる存続可能領域 \(V_K\)
- 状態空間または候補集合
- 損失、負担、制約、劣化、修復込み負担 \(L\) または \(B\)
- 有効支援 \(M\)
- 境界
- 時間範囲
- 読取り
- 変換器、根拠、証明書

これは、「この理論で見ると便利」という提案ではない。
維持対象つきの持続・崩壊 claim を、同じ計算として保存したまま
別表現へ移すなら、これらに相当する役割を消せない、という必要文法の主張である。

この定理の安全な一文は次である。

> 維持対象つきの持続・停止・崩壊 claim を、境界、読取り、証明書状態を
> 保存する厳密な計算として扱うなら、SPT の interface に相当する役割分解は
> 同値まで避けられない。

ここで重要なのは "同値まで" である。
別理論が同じ記号を使う必要はない。しかし、維持対象、境界、読取り、
根拠の身分、非ラベル性を保存するなら、対応する役割は再出現する。


3. 仕様固定 class theorem
--------------------------

仕様固定 class theorem は、文法側 universal theorem より狭いが、
操作的には強い。

ここでは、状態空間、質量、曝露法則、境界、判定対象が domain 仕様から
固定される。そのため、構造持続座標が独立に定義された操作的 endpoint に
接続できる。

代表例は次である。

3.1 有限 CSP
~~~~~~~~~~~~

有限候補集合 \(X\)、制約曝露後の実行可能集合 \(V_n\)、カウント
\(Z_n=|V_n|\) を置く。

曝露モデルから事前固定された一次モーメント消耗量 \(L_n^{FM}\) が
\[
  E[Z_n]\le |V_0|e^{-L_n^{FM}}
\]
を満たすなら、Markov 不等式により
\[
  P[V_n\ne\varnothing]\le |V_0|e^{-L_n^{FM}}
\]
が得られる。

したがって
\[
  L_n^{FM}\ge \log |V_0|+\lambda
\]
なら
\[
  P[V_n\ne\varnothing]\le e^{-\lambda}.
\]

これは任意 CSP の鋭い threshold theorem ではない。しかし、
一次モーメント \(L\) が、非空性という独立判定対象に崩壊側境界を与える
class theorem である。

二次モーメント比が制御できる場合には、存続側も
\[
  P[Z>0]\ge \frac{E[Z]^2}{E[Z^2]}
\]
で押さえられる。ここでは \(L\) だけでなく、相関や集中を表す
二次モーメント情報が必要になる。この追加条件を隠してはならない。


3.2 BEC 線形符号
~~~~~~~~~~~~~~~~

固定 parity-check matrix \(H\) と消失集合 \(E\) に対し、
\[
  a(E)=|E|-\operatorname{rank}(H_E)
\]
を置く。すると、区別可能な message-cell mass の損失は
\[
  L_E=a(E)\log 2
\]
であり、一意復元は
\[
  a(E)=0
  \quad\Longleftrightarrow\quad
  L_E=0
\]
と同値である。

さらに検査行数を \(r\) とすると、任意固定符号で
\[
  |E|>r \Rightarrow \text{一意復元不能}
\]
が成り立つ。これは有限 deterministic converse である。

ランダム検査行列側では、full-rank 失敗確率の包絡が与えられたとき、
行数 slack \(s\) から失敗確率 \(2^{-s}\) の envelope が出る。
BEC 消失数の集中境界が与えられれば、復元失敗確率の有限包絡が得られる。

これは Shannon-style achievability/converse envelope である。
ただし、Shannon BEC capacity theorem そのものの再証明ではない。
Chernoff 境界、正確なランダム行列 rank formula、漸近容量極限は
別の theorem として外側に残る。


3.3 s-t 信頼性
~~~~~~~~~~~~~~

固定 finite graph、terminals \(s,t\)、独立 edge-failure probability
\(q\) を置く。最小 \(s\)-\(t\) cutset size を \(\kappa\)、
その個数を \(N_\kappa\) とすると、
\[
  P_q(s\not\leftrightarrow t)
  =
  N_\kappa q^\kappa+O(q^{\kappa+1})
  \quad(q\to0)
\]
が成り立つ。

ここでは cut-spectrum coordinate が、操作的失敗確率の leading term に
現れる。これは単なる語彙写像ではない。

ただし、これは arbitrary graph reliability theorem でも、
exact reliability computation の代替でも、real network validation でもない。
有限仕様固定系の low-order operational embedding である。


4. 全ドメイン万能予測 theorem は主張しない
--------------------------------------------

次の主張はしない。

- 任意の物理系で \(S=M e^{-L}\) が tight prediction boundary になる。
- 任意の LLM で同じ \(L\) が同じ係数で劣化を予測する。
- 任意の組織、ソフトウェア、医療、経済、制御系に自由転用できる。
- 測定妥当性、観測妥当性、介入効果が Lean 形式化だけで保証される。
- ある domain での support が別 domain の support になる。

これは弱点ではなく、必要な制御である。

構造持続理論が universal に主張するのは、同じ予測式ではない。
維持対象つきの持続・崩壊 claim を厳密な境界計算として扱うときに必要な
文法である。予測式、測定手順、係数、実験妥当性は domain ごとに
凍結、検証、失敗台帳化される。


5. Criticism handling
---------------------

この整理に対する典型的な反論は、次のように分解できる。

5.1 "これは定義でしょ"
~~~~~~~~~~~~~~~~~~~~~~

返答:

対数比会計そのものは定義に近い。しかし仕様固定 layer では、
その座標が非空性、一意復元、disconnection probability など、
別に定義された操作的 endpoint に接続する。

有限 CSP では一次モーメント \(L\) が非空性へ一側境界を与える。
BEC では \(L_E=a(E)\log2\) が一意復元境界と厳密に一致する。
s-t reliability では cut-spectrum が失敗確率の leading term に現れる。

したがって、すべてが後付けの定義ではない。


5.2 "Shannon と同じではない"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

返答:

その通り。Shannon capacity theorem を再証明したとは言わない。

しかし、Shannon 型の第三層、すなわち座標が独立の操作的量に接続する
構造は、仕様固定 domain で複数ある。特に BEC 線形符号では、
Shannon の home domain に近い setting で finite achievability/converse
envelope が構成されている。

正しい statement は、

> Shannon と同一の theorem ではないが、Shannon-style operational
> alignment の bounded anchors がある。

である。


5.3 "Universal law ではない"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

返答:

全ドメイン万能予測 law ではない。

ただし、文法側 universal theorem と仕様固定 class theorem はある。
反論が要求している universal law が、任意 domain への free transfer なら、
それは最初から主張していない。


5.4 "経験的 support が domain ごとに弱い"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

返答:

その通り。domain ごとに効果量、support, no-support, invalid run が違う。
そのため、support は domain profile と evidence ledger に閉じ込める。

Mixed-CSP は強い support を持つ。BEC recovery は v0 support と successor
no-support を持つ。s-t reliability は restricted \(\kappa=2,3\) support を
持つ。flow-network M testbed は no-support である。

これは cherry-picking ではなく、claim discipline である。


6. Completion target
--------------------

この方向の完成形は、次の三段である。

1. 文法側 universal theorem:
   維持対象つきの持続・停止・崩壊 claim には、SPT interface 相当の
   役割が必要である。

2. 仕様固定 class theorem:
   有限 CSP、BEC、s-t reliability など、仕様から \(V,m\), exposure,
   boundary, endpoint が固定できる class では、構造持続座標が
   操作的 endpoint へ境界または leading-order として接続する。

3. Domain validation theorem / evidence:
   LLM、SRE、maintenance、software など、観測者依存が残る domain では、
   mapping, measurement, certificate, frozen validation を別途要求する。
   support は domain ごとに閉じ、free transfer を禁止する。

この三段を守る限り、構造持続理論は次の強い形で言える。

> 万能予測ではない。だが、維持対象つきの持続・崩壊 claim の必要文法は
> universal に現れる。さらに、仕様固定 class では、その文法が操作的境界へ
> 接続する定理がある。


7. 外向き wording
-----------------

短く言うなら、次を使う。

> 構造持続理論の universal claim は、全分野を同じ式で予測することではない。
> 維持対象つきの持続・停止・崩壊 claim を厳密に計算・監査するなら、
> 維持対象、実現構造、存続可能領域、損失・負担、有効支援、境界、時間範囲、
> 変換器、証明書に相当する役割が避けられない、という必要文法 theorem である。
> その上で、有限 CSP、BEC 線形符号、s-t 信頼性のような仕様固定 class では、
> この文法が独立の操作的 endpoint へ境界または leading-order として接続する。

英語では次を使う。

> SPT's universal claim is not that one formula predicts every domain. Its
> universal claim is grammatical: if a maintained-target persistence or collapse
> claim is to be computed and audited while preserving the target, boundary
> readout, and certificate status, then roles corresponding to target,
> realization structure, viable region, loss/burden, qualified support,
> boundary, horizon, adapter, and certificate reappear up to equivalence. In
> specification-fixed classes such as finite CSP, finite BEC linear-code
> recovery, and finite s-t reliability, this grammar further connects to
> operational endpoints through bounds, exact readouts, or leading-order
> embeddings. This is a bounded universal-theorem program, not a free-transfer
> prediction law.
