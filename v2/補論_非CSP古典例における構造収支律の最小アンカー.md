補論_非CSP古典例における構造収支律の最小アンカー
非CSP古典例における構造収支律の最小アンカー
— queueing / reliability / decay による G4 v1 —

要旨

本補論は、構造収支律が SAT / Bernoulli-CSP / Mixed-CSP の内部だけで閉じた理論ではなく、非CSPの古典的構造にも歪めず写ることを示すための G4 v1 anchor package を定める。

結論は三つである。第一に、G4 v1 の primary anchor は queueing / Foster-Lyapunov drift とする。これは、構造収支律の正味作用 \(a_t\) が、excess demand や Lyapunov increment として直接読めるためである。第二に、serial reliability と constant-fraction decay を loss-only control anchors とする。これらは、構造収支律の指数核
\[
  R=\exp(-L)
\]
が、CSP ではない信頼性工学・減衰過程にも現れることを示す。第三に、branching expectation、fatigue、consensus、buckling、percolation は現時点では secondary / coverage skeleton として扱う。

本補論は、新しい queueing theorem、reliability theorem、branching theorem を主張しない。既存分野の定理を置き換えるものでもない。目的は、構造収支律の語彙
\[
  Z_t,\quad a_t,\quad A_n,\quad R_t,\quad \ell_t,\quad g_t
\]
が、非CSPの古典例においてどこまで自然に働くかを整理することである。

Lean 側では、`QueueStability.lean`、`LyapunovBalanceEmbedding.lean`、`SerialReliability.lean`、`ConstantFractionDecay.lean` が G4 v1 の中心的な対応である。これらはすべて finite-prefix / minimal algebraic skeleton であり、確率過程安定性や物理的破壊過程の本格定理を再証明するものではない。


1. 目的

G4 の目的は、構造収支律が情報・論理・CSP 系に閉じた特殊理論ではないことを確認することである。

ただし、この確認は慎重でなければならない。非CSP古典例には、すでに各分野で強い理論がある。queueing theory、信頼性工学、反応速度論、分岐過程、材料疲労、パーコレーションは、それぞれ独自の前提と定理を持つ。構造収支律はそれらを置き換えるのではない。

本補論が行うのは、次の限定された作業である。

\begin{quote}
既存の非CSP古典例を、構造収支律の \(a_t,A_n,R_t,\ell_t,g_t\) という最小語彙へ写したとき、どの例が primary anchor として最も自然かを定める。
\end{quote}

この作業は、普遍法則の宣言ではない。むしろ、普遍理論候補として進むために、どの既存理論とどの強度で接続できるかを整理する discipline である。


2. 選定基準

候補は次の五つの基準で見る。

| criterion | 内容 |
|---|---|
| C1. balance-law fit | \(a_t=\ell_t-g_t\), \(A_n\), \(R_t=e^{-Z_t}\) へ自然に写るか |
| C2. Lean-backed | 既存 Lean theorem が reader-facing claim を支えるか |
| C3. non-CSP distance | SAT / CSP から十分に離れて見えるか |
| C4. theorem humility | 既存分野の強い theorem を過剰に再主張せずに済むか |
| C5. next-step value | 次の G4 / G6 / empirical anchor を選ぶ基準になるか |

G4 v1 では、C1 と C2 を最重視する。C3 は rhetoric 上の価値、C4 は overclaim 防止、C5 は研究戦略上の価値である。


3. G4 v1 package

G4 v1 は、次の三層で構成する。

| role | anchor | Lean files | 読み |
|---|---|---|---|
| primary anchor | queueing / Foster-Lyapunov drift | `QueueStability.lean`, `LyapunovBalanceEmbedding.lean` | open-system drift balance |
| loss-only control | serial reliability | `SerialReliability.lean` | product reliability \(=\exp(-L)\) |
| loss-only control | constant-fraction decay | `ConstantFractionDecay.lean` | textbook exponential decay |

この組み合わせにより、構造収支律の二つの面を非CSP側で示せる。

第一に、queueing / Foster-Lyapunov は、補償流や処理能力が損失流を上回るかどうかという open-system balance を示す。

第二に、serial reliability と constant-fraction decay は、補償流を含まない loss-only kernel が、古典的な工学・自然科学モデルにも現れることを示す。


4. Primary anchor: queueing / Foster-Lyapunov drift

Queueing / Foster-Lyapunov を primary anchor にする理由は、構造収支律の open-system balance と最も直接に対応するからである。

`QueueStability.lean` では、deterministic fluid skeleton として
\[
  \mathrm{backlog}_n
  =
  \mathrm{initial}
  +
  n(\lambda-\mu)
\]
が形式化されている。ここで \(\lambda\) は arrival rate、\(\mu\) は service rate である。

一段の正味作用は
\[
  a_t=\lambda-\mu
\]
と読める。到着率がサービス率を上回れば \(a_t>0\) で overload tendency、サービス率が到着率を上回れば \(a_t<0\) で recovery tendency である。

さらに `LyapunovBalanceEmbedding.lean` では、任意の load sequence \(Z_t\) に対して
\[
  a_t=Z_{t+1}-Z_t,
  \qquad
  A_n=Z_n-Z_0,
  \qquad
  R_{t+1}=R_t e^{-a_t}
\]
が形式化されている。

したがって、queueing / Foster-Lyapunov drift は G4 と G6-c の交点である。G4 としては非CSP古典例であり、G6-c としては既存 drift calculus の minimal algebraic embedding である。

これは double-counting ではない。G6 は既存理論との formal-mapping credibility を測る gate であり、G4 は non-CSP domain coverage を測る gate である。同一の artifact が両 dimension に寄与するのは、埋め込みが自然であることの帰結であり、二重に evidence を数えるという意味ではない。

この anchor が言えること:

- \(a_t\) が古典的な excess demand / Lyapunov increment と一致する。
- overload / maintenance / recovery の三 regime が \(a_t\) または \(\mathbb E[a_t]\) の符号として読める。
- 構造収支律は、open-system stability theory と同じ drift algebra を共有する。

この anchor が言えないこと:

- positive recurrence が構造収支律だけから従う。
- reflected stochastic queue の安定性定理を新たに証明した。
- geometric ergodicity や \(R_n\le R_0e^{-cn}\) 型境界を得た。

したがって、queueing / Foster-Lyapunov は G4 v1 の primary anchor として最も強いが、主張は minimal algebraic embedding に限定する。


5. Loss-only control anchor: serial reliability

Serial reliability は、loss-only kernel の non-CSP control として置く。

直列系では、全ての component が動作しなければ全体が動作しない。component reliability を \(p_i\) とすると、最初の \(n\) components の reliability は
\[
  R_n=\prod_{i<n}p_i
\]
である。

一方、component loss を
\[
  \ell_i=-\log p_i
\]
と置けば、累積損失は
\[
  L_n=\sum_{i<n}\ell_i
\]
であり、
\[
  R_n=\exp(-L_n)
\]
が成り立つ。

`SerialReliability.lean` はこの対応を形式化している。これは Paper 1 / Paper 2 の loss-only kernel が、SAT ではなく信頼性工学の textbook model にもそのまま現れることを示す。

ただし、serial reliability は G4 v1 の primary anchor ではない。理由は、構造収支律の新しい要素である補償流 \(g_t\) や recovery tendency を含まないからである。queueing anchor と並べることで、loss-only exponential kernel と open-system drift balance の両方を non-CSP 側で示す control として使う。


6. Loss-only control anchor: constant-fraction decay

Constant-fraction decay は、放射性崩壊、Beer-Lambert attenuation、一次反応、一次薬物動態などに共通する最小 skeleton である。

各 step で一定割合 \(q\) が残るとする。このとき、\(n\) step 後の残存割合は
\[
  q^n
\]
である。step loss を
\[
  \ell=-\log q
\]
と置けば、
\[
  q^n=\exp(-n\ell)
  =
  \exp(-n(-\log q)).
\]

`ConstantFractionDecay.lean` はこの対応を形式化している。

これは非常に古典的であり、数学的新規性はない。しかし、その古典性が利点でもある。構造収支律の指数核が、CSP や LLM 固有の構文ではなく、既存の textbook exponential decay と同じ log-ratio algebra を共有することを示すからである。


7. Secondary / coverage skeletons

G4 v1 では、次の候補は secondary / coverage として扱う。

| candidate | Lean file | 理由 |
|---|---|---|
| branching expectation | `BranchingProcessExtinction.lean` | expectation-level \(m^n\) skeleton。almost-sure extinction theorem ではない |
| fatigue damage | `FatigueDamage.lean` | cumulative damage threshold。repair / recovery を含む richer model が必要 |
| consensus fault threshold | `ConsensusFaultThreshold.lean` | cumulative fault threshold。分散合意 theorem そのものではない |
| buckling threshold | `BucklingThreshold.lean` | critical-load finite-prefix skeleton。Euler buckling theorem ではない |
| percolation threshold | `PercolationThreshold.lean` | critical-occupation finite-prefix skeleton。percolation theorem ではない |

これらは価値がないという意味ではない。むしろ、G4 v2 以降の候補である。ただし現時点では、primary anchor として前面に出すには overclaim の危険が大きい。


8. Lean 対応表

G4 v1 の reader-facing claim は、次の Lean files に対応する。

| role | Lean file | 主対応 |
|---|---|---|
| primary open-system anchor | `QueueStability.lean` | `backlog_n = initial + n(arrival-service)`、stable / overloaded regime |
| G6-c embedding bridge | `LyapunovBalanceEmbedding.lean` | \(a_t=Z_{t+1}-Z_t\), \(A_n=Z_n-Z_0\), \(R_{t+1}=R_t e^{-a_t}\) |
| loss-only control | `SerialReliability.lean` | \(\prod p_i = \exp(-\sum -\log p_i)\) |
| loss-only control | `ConstantFractionDecay.lean` | \(q^n=\exp(-n(-\log q))\) |
| secondary expectation skeleton | `BranchingProcessExtinction.lean` | subcritical mean \(m^n\) skeleton |
| secondary threshold skeletons | `FatigueDamage.lean`, `ConsensusFaultThreshold.lean`, `BucklingThreshold.lean`, `PercolationThreshold.lean` | finite-prefix cumulative / critical threshold skeletons |

この対応表は、Lean file が各分野の本格理論を証明しているという意味ではない。あくまで、構造収支律の最小語彙へ写したときの algebraic skeleton を機械検証している、という意味である。


9. 本補論が与えるもの

本補論が与えるものは三つある。

第一に、構造収支律の非CSP側 primary anchor を queueing / Foster-Lyapunov に固定する。これにより、G4 の次作業が「古典例を何でも足す」ではなく、G6-c embedding と整合する方向へ絞られる。

第二に、serial reliability と constant-fraction decay を loss-only controls として明示する。これにより、構造収支律の指数核が SAT / CSP だけでなく、信頼性工学や減衰過程にも現れることを示せる。

第三に、secondary skeletons を前面に出しすぎない discipline を与える。Branching、fatigue、consensus、buckling、percolation は有用な coverage examples だが、現時点では本格定理ではない。


10. 本補論が与えないもの

本補論は、次を主張しない。

1. 構造収支律が queueing stability theorem を証明した。
2. 構造収支律が reliability theory や reaction kinetics を置き換える。
3. branching process の almost-sure extinction theorem を Lean 化した。
4. fatigue failure、buckling、percolation の本格的 threshold theorem を導いた。
5. non-CSP skeletons が empirical validation である。
6. G4 v1 が閉じたので universal law が確立した。

本補論の主張は限定的である。

\begin{quote}
構造収支律は、非CSP古典例のうち、少なくとも queueing / Foster-Lyapunov drift に対して、\(a_t,A_n,R_t,\ell_t,g_t\) の最小代数的埋め込みを持つ。Serial reliability と constant-fraction decay は、同じ log-ratio exponential kernel が loss-only non-CSP 系にも現れることを示す control anchors である。
\end{quote}


11. 次の iteration

G4 v1 の次にありうる方向は二つである。

第一に、G4 v2 として branching process を強化する方向である。現状は expectation-level skeleton だが、almost-sure extinction や martingale / generating-function argument へ進めば、より強い非CSP確率過程 anchor になる。

第二に、repair / intervention を持つ reliability or fatigue model へ進む方向である。たとえば、component replacement、redundancy、maintenance schedule、damage repair を \(g_t\) として明示できれば、loss-only control から open-system balance へ進める。

どちらに進む場合でも、現在の G4 v1 の discipline を保つ必要がある。すなわち、既存分野の theorem を置き換えたとは言わず、どの仮定を保持し、どの algebraic skeleton だけを構造収支律へ写したのかを明示する。


12. 結論

G4 v1 は、非CSP古典例の最小 anchor package として閉じることができる。primary anchor は queueing / Foster-Lyapunov drift であり、これは G6-c iteration 1 の minimal algebraic embedding と一致する。serial reliability と constant-fraction decay は、loss-only exponential kernel の control anchors である。

この package により、構造収支律は SAT / Bernoulli-CSP / Mixed-CSP の内部だけでなく、少なくとも queueing stability、reliability、decay という古典的非CSP語彙にも歪めず写ることが示される。

ただし、それは universal law の最終宣言ではない。G4 v1 が与えるのは、次に進むべき非CSP anchor の優先順位と、過剰主張を避けるための境界である。
