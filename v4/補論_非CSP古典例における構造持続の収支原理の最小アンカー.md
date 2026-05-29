補論_非CSP古典例における構造持続の収支原理の最小アンカー
非CSP古典例における構造持続の収支原理の最小アンカー
— queueing / reliability / decay による G4 v1 と repair / maintenance による G4 v2 —

要旨

本補論は、構造持続の収支原理が SAT / Bernoulli-CSP / Mixed-CSP の内部だけで閉じた理論ではなく、非CSPの古典的構造にも歪めず写ることを示すための G4 anchor package を定める。

結論は三つである。第一に、G4 v1 の primary anchor は queueing / Foster-Lyapunov drift とする。これは、構造持続の収支原理の純損失量 \(b_t\) が、excess demand や Lyapunov increment として直接読めるためである。第二に、serial reliability と constant-fraction decay を loss-only control anchors とする。これらは、構造持続の収支原理の指数核
\[
  R=\exp(-L)
\]
が、CSP ではない信頼性工学・減衰過程にも現れることを示す。第三に、G4 v2 として repair / maintenance reliability-fatigue balance を追加する。これは、損傷量 \(d_t\) と修復量 \(r_t\) を分けて
\[
  D_n = D_0 + \sum_{t<n}(d_t-r_t)
\]
と読むことで、修復量 \(r_t\) を非CSPの open-system anchor として明示するためである。Branching expectation、consensus、buckling、percolation は現時点では secondary / coverage skeleton として扱う。

本補論は、新しい queueing theorem、reliability theorem、branching theorem を主張しない。既存分野の定理を置き換えるものでもない。目的は、構造持続の収支原理の語彙
\[
  Z_t,\quad b_t,\quad B_n,\quad R_t,\quad d_t,\quad r_t
\]
が、非CSPの古典例においてどこまで自然に働くかを整理することである。

Lean 側では、`QueueStability.lean`、`LyapunovBalanceEmbedding.lean`、`SerialReliability.lean`、`ConstantFractionDecay.lean` が G4 v1 の中心的な対応であり、`RepairMaintenanceBalance.lean` が G4 v2 の対応である。これらはすべて finite-prefix / minimal algebraic skeleton であり、確率過程安定性や物理的破壊過程の本格定理を再証明するものではない。


1. 目的

G4 の目的は、構造持続の収支原理が情報・論理・CSP 系に閉じた特殊理論ではないことを確認することである。

ただし、この確認は慎重でなければならない。非CSP古典例には、すでに各分野で強い理論がある。queueing theory、信頼性工学、反応速度論、分岐過程、材料疲労、パーコレーションは、それぞれ独自の前提と定理を持つ。構造持続の収支原理はそれらを置き換えるのではない。

本補論が行うのは、次の限定された作業である。

\begin{quote}
既存の非CSP古典例を、構造持続の収支原理の \(b_t,B_n,R_t,d_t,r_t\) という最小語彙へ写したとき、どの例が primary anchor として最も自然かを定める。
\end{quote}

この作業は、普遍法則の宣言ではない。むしろ、普遍理論候補として進むために、どの既存理論とどの強度で接続できるかを整理する discipline である。


2. 選定基準

候補は次の五つの基準で見る。

C1 は balance-principle fit であり、\(b_t=d_t-r_t\), \(B_n\), \(R_t=e^{-Z_t}\) へ自然に写るかを見る。
C2 は Lean-backed であり、既存 Lean theorem が reader-facing claim を支えるかを見る。
C3 は non-CSP distance であり、SAT / CSP から十分に離れて見えるかを見る。
C4 は theorem humility であり、既存分野の強い theorem を過剰に再主張せずに済むかを見る。
C5 は next-step value であり、次の G4 / G6 / empirical anchor を選ぶ基準になるかを見る。

G4 v1 では、C1 と C2 を最重視する。C3 は rhetoric 上の価値、C4 は overclaim 防止、C5 は研究戦略上の価値である。


3. G4 v1 package

G4 v1 は、次の三層で構成する。

primary anchor は queueing / Foster-Lyapunov drift であり、`QueueStability.lean` と
`LyapunovBalanceEmbedding.lean` が open-system drift balance を支える。
loss-only control の第一は serial reliability であり、`SerialReliability.lean` が
product reliability \(=\exp(-L)\) を支える。
loss-only control の第二は constant-fraction decay であり、
`ConstantFractionDecay.lean` が textbook exponential decay を支える。

この組み合わせにより、構造持続の収支原理の二つの面を非CSP側で示せる。

第一に、queueing / Foster-Lyapunov は、修復量や処理能力が段階損失量を上回るかどうかという open-system balance を示す。

第二に、serial reliability と constant-fraction decay は、修復量を含まない指数核が、古典的な工学・自然科学モデルにも現れることを示す。


4. Primary anchor: queueing / Foster-Lyapunov drift

Queueing / Foster-Lyapunov を primary anchor にする理由は、構造持続の収支原理の open-system balance と最も直接に対応するからである。

`QueueStability.lean` では、deterministic fluid skeleton として
\[
  \mathrm{backlog}_n
  =
  \mathrm{initial}
  +
  n(\lambda-\mu)
\]
が形式化されている。ここで \(\lambda\) は arrival rate、\(\mu\) は service rate である。

純損失量は
\[
  b_t=\lambda-\mu
\]
と読める。到着率がサービス率を上回れば \(b_t>0\) で overload tendency、サービス率が到着率を上回れば \(b_t<0\) で recovery tendency である。

さらに `LyapunovBalanceEmbedding.lean` では、任意の load sequence \(Z_t\) に対して
\[
  b_t=Z_{t+1}-Z_t,
  \qquad
  B_n=Z_n-Z_0,
  \qquad
  R_{t+1}=R_t e^{-b_t}
\]
が形式化されている。

したがって、queueing / Foster-Lyapunov drift は G4 と G6-c の交点である。G4 としては非CSP古典例であり、G6-c としては既存 drift calculus の minimal algebraic embedding である。

これは double-counting ではない。G6 は既存理論との formal-mapping credibility を測る gate であり、G4 は non-CSP domain coverage を測る gate である。同一の artifact が両 dimension に寄与するのは、埋め込みが自然であることの帰結であり、二重に evidence を数えるという意味ではない。

この anchor が言えること:

- \(b_t\) が古典的な excess demand / Lyapunov increment と一致する。
- overload / maintenance / recovery の三 regime が \(b_t\) または \(\mathbb E[b_t]\) の符号として読める。
- 構造持続の収支原理は、open-system stability theory と同じ drift algebra を共有する。

この anchor が言えないこと:

- positive recurrence が構造持続の収支原理だけから従う。
- reflected stochastic queue の安定性定理を新たに証明した。
- geometric ergodicity や \(R_n\le R_0e^{-cn}\) 型境界を得た。

したがって、queueing / Foster-Lyapunov は G4 v1 の primary anchor として最も強いが、主張は minimal algebraic embedding に限定する。


5. Loss-only control anchor: serial reliability

Serial reliability は、修復量を含まない最小核の非CSP対照例として置く。

直列系では、全ての component が動作しなければ全体が動作しない。component reliability を \(p_i\) とすると、最初の \(n\) components の reliability は
\[
  R_n=\prod_{i<n}p_i
\]
である。

一方、component ごとの段階損失量を
\[
  d_i=-\log p_i
\]
と置けば、累積段階損失量は
\[
  L_n=\sum_{i<n}d_i
\]
であり、
\[
  R_n=\exp(-L_n)
\]
が成り立つ。

`SerialReliability.lean` はこの対応を形式化している。これは、構造持続の最小形式と条件つき導出の修復量を含まない最小核が、SAT ではなく信頼性工学の textbook model にもそのまま現れることを示す。

ただし、serial reliability は G4 v1 の primary anchor ではない。理由は、構造持続の収支原理の新しい要素である修復量 \(r_t\) や修復傾向を含まないからである。queueing anchor と並べることで、修復量を含まない指数核と open-system drift balance の両方を non-CSP 側で示す対照例として使う。


6. Loss-only control anchor: constant-fraction decay

Constant-fraction decay は、放射性崩壊、Beer-Lambert attenuation、一次反応、一次薬物動態などに共通する最小 skeleton である。

各 step で一定割合 \(q\) が残るとする。このとき、\(n\) step 後の残存割合は
\[
  q^n
\]
である。step consumption を
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

これは非常に古典的であり、数学的新規性はない。しかし、その古典性が利点でもある。構造持続の収支原理の指数核が、CSP や LLM 固有の構文ではなく、既存の textbook exponential decay と同じ log-ratio algebra を共有することを示すからである。


7. Secondary / coverage skeletons

G4 v1 では、次の候補は secondary / coverage として扱う。

branching expectation は `BranchingProcessExtinction.lean` に対応し、expectation-level \(m^n\) skeleton として扱う。almost-sure extinction theorem ではない。
fatigue damage は `FatigueDamage.lean` に対応し、cumulative damage threshold として扱う。repair / recovery を含む richer model が必要である。
consensus fault threshold は `ConsensusFaultThreshold.lean` に対応し、cumulative fault threshold として扱う。分散合意 theorem そのものではない。
buckling threshold は `BucklingThreshold.lean` に対応し、critical-load finite-prefix skeleton として扱う。Euler buckling theorem ではない。
percolation threshold は `PercolationThreshold.lean` に対応し、critical-occupation finite-prefix skeleton として扱う。percolation theorem ではない。

これらは価値がないという意味ではない。むしろ、G4 v2 以降の候補である。ただし現時点では、primary anchor として前面に出すには overclaim の危険が大きい。


8. Lean 対応表

G4 v1 の reader-facing claim は、次の Lean files に対応する。

primary open-system anchor は `QueueStability.lean` に対応し、`backlog_n = initial + n(arrival-service)` と stable / overloaded regime を支える。
G6-c embedding bridge は `LyapunovBalanceEmbedding.lean` に対応し、\(b_t=Z_{t+1}-Z_t\), \(B_n=Z_n-Z_0\), \(R_{t+1}=R_t e^{-b_t}\) を支える。
loss-only control の serial reliability は `SerialReliability.lean` に対応し、\(\prod p_i = \exp(-\sum -\log p_i)\) を支える。
loss-only control の constant-fraction decay は `ConstantFractionDecay.lean` に対応し、\(q^n=\exp(-n(-\log q))\) を支える。
G4 v2 open-system anchor は `RepairMaintenanceBalance.lean` に対応し、\(D_n=D_0+\sum(d_t-r_t)\), \(M_n=B-D_n\), \(R_{t+1}=R_t e^{-(d_t-r_t)}\) を支える。
secondary expectation skeleton は `BranchingProcessExtinction.lean` に対応し、subcritical mean \(m^n\) skeleton を支える。
secondary threshold skeletons は `FatigueDamage.lean`, `ConsensusFaultThreshold.lean`, `BucklingThreshold.lean`, `PercolationThreshold.lean` に対応し、finite-prefix cumulative / critical threshold skeletons を支える。

この対応表は、Lean file が各分野の本格理論を証明しているという意味ではない。あくまで、構造持続の収支原理の最小語彙へ写したときの algebraic skeleton を機械検証している、という意味である。


9. 本補論が与えるもの

本補論が与えるものは四つある。

第一に、構造持続の収支原理の非CSP側 primary anchor を queueing / Foster-Lyapunov に固定する。これにより、G4 の次作業が「古典例を何でも足す」ではなく、G6-c embedding と整合する方向へ絞られる。

第二に、serial reliability と constant-fraction decay を loss-only controls として明示する。これにより、構造持続の収支原理の指数核が SAT / CSP だけでなく、信頼性工学や減衰過程にも現れることを示せる。

第三に、secondary skeletons を前面に出しすぎない discipline を与える。Branching、fatigue、consensus、buckling、percolation は有用な coverage examples だが、現時点では本格定理ではない。

第四に、G4 v2 として repair / maintenance balance を追加する。これにより、非CSP側でも修復量 \(r_t\) が単なる比喩ではなく、repair event、maintenance schedule、replacement、redundancy activation などの operational variable として読めることを示す。

9.1 条件つき law-side bridge

本補論の strongest safe reading は、non-CSP 一般で universal law を宣言することではない。より正確には、queueing / Foster-Lyapunov drift を中心とする drift-based stability class に対して、構造持続の収支原理を **条件つき law-side bridge** として提示できる、ということである。repair / maintenance balance は、その bridge を empirical \(r_t\) 側へ押し広げる near-bridge open-system anchor として置く。

この bridge が成立する最小条件は三つである。

1. 自然な構造量または測度 \(m\) が事前固定されること。
2. 修復量 \(r_t\) が domain-native な変数として観測できること。
3. collapse / hitting boundary が明示的仮定の下で読めること。

これに照らすと、本補論の anchors は次のように分かれる。

queueing / Foster-Lyapunov drift は conditional law-side bridge である。
repair / maintenance balance は near-bridge open-system anchor である。
serial reliability は loss-only control anchor である。
constant-fraction decay も loss-only control anchor である。
secondary skeletons は coverage only として扱う。

重要なのは、この bridge claim が既存理論を置き換えるという意味ではないことである。queueing / reliability 側の theorem assumptions は保持される。本補論が言うのは、構造持続の収支原理の \(b_t,B_n,R_t,d_t,r_t\) という語彙が、それらの理論内部に自然に現れる、という限定的な主張である。


10. 本補論が与えないもの

本補論は、次を主張しない。

1. 構造持続の収支原理が queueing stability theorem を証明した。
2. 構造持続の収支原理が reliability theory や reaction kinetics を置き換える。
3. branching process の almost-sure extinction theorem を Lean 化した。
4. fatigue failure、buckling、percolation の本格的 threshold theorem を導いた。
5. non-CSP skeletons が empirical validation である。
6. repair / maintenance schedule の最適制御定理を証明した。
7. repair cost が無料である。
8. G4 v1 / v2 が閉じたので universal law が確立した。

本補論の主張は限定的である。

\begin{quote}
構造持続の収支原理は、非CSP古典例のうち、少なくとも queueing / Foster-Lyapunov drift に対して、\(b_t,B_n,R_t,d_t,r_t\) の最小代数的埋め込みを持つ。Serial reliability と constant-fraction decay は、同じ対数比の指数核が、修復量を含まない非CSP系にも現れることを示す対照アンカーである。Repair / maintenance balance は、修復量 \(r_t\) が非CSP open-system 系でも operational variable として読めることを示す G4 v2 anchor である。
\end{quote}

この statement を一歩だけ強く言い直すなら、queueing / Foster-Lyapunov drift は current program における最初の **conditional law-side bridge** であり、repair / maintenance balance はその open-system semantic range を広げる near-bridge anchor である。


11. G4 v2: repair / maintenance balance

G4 v1 の primary anchor である queueing / Foster-Lyapunov drift は、サービス率 \(\mu\) を通じて修復に相当する項を持つ。しかし、queueing の gloss では、修復は主に constant-rate service として表れる。G4 v2 の目的は、この修復量をより operational に見える形へ移すことである。

Repair / maintenance reliability-fatigue model では、損傷量 \(d_t\) と修復量 \(r_t\) を分ける。
\[
  b_t=d_t-r_t,\qquad
  B_n=\sum_{t<n}(d_t-r_t),
\]
したがって accumulated damage は
\[
  D_n = D_0 + B_n
      = D_0 + \sum_{t<n}(d_t-r_t)
\]
である。

Failure threshold を \(B\) とすると、remaining margin は
\[
  M_n = B-D_n
      = (B-D_0)-B_n
\]
であり、threshold crossing は
\[
  D_n \ge B
\]
または
\[
  M_n \le 0
\]
として読める。

この形式は、閉じた場合 \(r_t\equiv 0\) に Miner-rule style skeleton
\[
  \sum_{t<n} d_t \ge C
\]
を回収する。開いた場合 \(r_t\neq 0\) では、repair、re-annealing、component replacement、redundancy activation、preventive maintenance schedule などが \(r_t\) として表れる。

`RepairMaintenanceBalance.lean` は、この最小 skeleton を形式化している。中心対応は次の通りである。

\(D_n=D_0+B_n\) は `damageLevel_eq_initial_plus_cumulative_net_action` に対応する。
\(M_n=(B-D_0)-B_n\) は `margin_eq_initial_margin_sub_cumulative_net_action` に対応する。
\(D_n<B\) なら threshold crossing していない、という主張は `not_thresholdCrossed_of_damage_lt_threshold` に対応する。
\(B-D_0\le B_n\) なら threshold crossing、という主張は `thresholdCrossed_of_initial_margin_le_cumulativeNetAction` に対応する。
\(R_{t+1}=R_t e^{-(d_t-r_t)}\) は `relativeMaintenance_succ_eq_mul_exp_neg_netAction` に対応する。
repair が非負なら damage-only より damage が小さい、という主張は `damageLevel_le_damageOnlyLevel_of_repair_nonneg` に対応する。
repair が非負なら damage-only より margin が大きい、という主張は `damageOnlyMargin_le_margin_of_repair_nonneg` に対応する。

最後の二つは、G4 v2 に固有の operational 意味を持つ。すなわち、同じ損傷系列のもとで修復量が非負なら、repair を入れた系の損傷水準は修復なしの損傷動力学を上回らず、残余余白は修復なしの損傷動力学を下回らない。

これは「repair は何もしないよりよい」という常識的命題を、構造持続の収支原理の \(r_t\) として明示する小定理である。ただし、これは最適保守 policy theorem ではない。どの timing で repair すべきか、repair cost をどう最小化するか、stochastic fatigue distribution がどう振る舞うかは、本補論の範囲外である。

M 補論の語彙で言えば、preventive maintenance schedule は \(M_{\mathrm{recovery}}\) recovery component の concrete instance として読める。Repair events は schedule-driven、logged、cost-accounted であり、LLM の prompt-level repair よりも \(r_t\) の operational observability が高い。

この G4 v2 anchor が言えること:

- 修復量 \(r_t\) は非CSPの reliability / fatigue 系でも自然に出る。
- 構造持続の収支原理は、修復量を含まない指数核だけでなく、損失量から修復量を差し引く会計も非CSP側に持つ。
- repair / maintenance は \(B_n\) を下げ、remaining margin を damage-only dynamics より改善する。

この G4 v2 anchor が言えないこと:

- 信頼性工学や疲労破壊の本格理論を置き換えた。
- optimal maintenance theorem を証明した。
- repair が無料である。
- 実システムで \(r_t\) が常に一意に測定できる。

したがって、G4 v2 は open-system recovery の semantic coverage を広げるが、empirical validation や engineering theorem ではない。


12. 次の iteration

G4 v2 iteration 1 は、finite-prefix algebraic skeleton として閉じた。次にありうる方向は三つである。

第一に、repair / maintenance balance を stochastic reliability model へ拡張する方向である。これは、failure probability、inspection schedule、repair cost、availability などを扱う可能性がある。ただし、本格的な reliability theorem や optimal maintenance theorem を導くには、別の仮定が必要である。

第二に、branching process を強化する方向である。現状は expectation-level skeleton だが、almost-sure extinction や martingale / generating-function argument へ進めば、より強い非CSP確率過程 anchor になる。ただし、それは \(r_t\) を明示する open-system anchor ではなく、主に loss-only / decay 側の強化である。

第三に、G4 v2 の empirical / operational pilot を設計する方向である。たとえば、maintenance log、incident count、repair schedule、remaining margin indicator を持つ実データで、\(d_t-r_t\) が failure / degradation を予測するかを検査できる。ただし、これは構造推定層 / operational validation であり、本補論の algebraic skeleton とは別段階である。

いずれに進む場合でも、現在の G4 v1 / v2 の discipline を保つ必要がある。すなわち、既存分野の theorem を置き換えたとは言わず、どの仮定を保持し、どの algebraic skeleton だけを構造持続の収支原理へ写したのかを明示する。


13. 結論

G4 v1 は、非CSP古典例の最小 anchor package として閉じることができる。primary anchor は queueing / Foster-Lyapunov drift であり、これは G6-c iteration 1 の minimal algebraic embedding と一致する。serial reliability と constant-fraction decay は、修復量を含まない指数核の対照アンカーである。

G4 v2 は、repair / maintenance balance を加えることで、修復量 \(r_t\) を非CSP open-system anchor として明示した。`RepairMaintenanceBalance.lean` は、損傷量と修復量の差し引きが累積損傷と残余余白を決めることを形式化している。

この package により、構造持続の収支原理は SAT / Bernoulli-CSP / Mixed-CSP の内部だけでなく、少なくとも queueing stability、reliability、decay、repairable fatigue / maintenance という古典的非CSP語彙にも歪めず写ることが示される。

ただし、それは universal law の最終宣言ではない。G4 v1 / v2 が与えるのは、次に進むべき非CSP anchor の優先順位と、過剰主張を避けるための境界である。
