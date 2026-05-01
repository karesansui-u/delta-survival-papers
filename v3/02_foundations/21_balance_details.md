補論_構造持続の収支原理の詳細展開
構造持続の収支原理の詳細展開
— 主論文から外した技術的背景・アンカー・限界整理 —

要旨

構造持続の最小形式は、まず、回復量を明示しない最小核として定式化される。そこでは、構造維持可能領域の縮小を対数比で測る消耗側の核が与えられ、残存可能性が指数核で表される。しかし、現実の多くの系では、構造消耗だけを見る近似では十分でない。修復、学習、冗長化、外部支援、ロールバックのように、構造維持可能領域を再拡大する作用が同時に働く。

本稿は、この回復を含む構造系を扱うために、構造持続の最小核を「構造消耗量」から「構造消耗量と回復量の収支」へ移す。各時刻の構造消耗量を \(d_t\)、回復量を \(r_t\)、純消耗量を
\[
  b_t := d_t - r_t
\]
と置く。対象期間が文脈上固定されているとき、その累積を
\[
  B := \sum_t b_t = \sum_t(d_t-r_t)
\]
と書けば、読者向けの看板式は
\[
  S = M e^{-B}
\]
である。これは、構造持続の最小形式で置いた最小核
\[
  S = M e^{-L}
\]
と同じ顔を持つ。違いは、回復量を明示しない累積情報損失 \(L\) が、回復量を差し引いた累積純消耗量 \(B\) に置き換わる点にある。厳密な有限時間地平 \(n\) では
\[
  B_n := \sum_{t<n}(d_t-r_t),
  \qquad
  S_n = M_n e^{-B_n}
\]
と書く。ここで \(B_n\) は時刻 \(n\) までの累積純消耗量、\(M_n\) はその時点で明示的に追跡する維持資源、\(S_n\) は時刻 \(n\) における構造持続ポテンシャルである。必要なら \(R_n:=e^{-B_n}\) を構造維持可能性の持続率（残存比）と呼ぶ。集合値核だけを見る場合には、この式は
\[
  m(V^{(n)}) = m(V^{(0)}) e^{-B_n}
\]
という最小収支恒等式になる。ここで \(b_t>0\) は構造消耗優位、\(b_t=0\) は維持、\(b_t<0\) は回復優位を表す。したがって、本稿でいう「収支」は equilibrium を意味しない。崩壊・維持・回復の三つの傾向を、同じ差し引き量の符号として扱うための収支 (accounting) の原理である。この三局面は均衡判定ではなく、後述するように、事前固定された観測単位の上での局所的な会計分類である。

本稿の役割は、構造持続理論が普遍法則として確立したと宣言することではない。むしろ、構造持続の最小形式の回復量を明示しない最小核、条件つき導出補論における層分離、集合値力学補論の符号付き指数核、Lean 形式化における期待値レベルの傾向、Mixed-CSP の有限時間 concentration、および LLM companion I / II の repair / external metabolism の観察を、単一の「構造持続の収支原理」として詳しく展開する技術補論である。現在の主線は「構造持続の最小形式」から「構造持続の収支原理」へ進み、本稿はその背後にある背景、アンカー、限界整理を必要に応じて参照するために読む。


1. はじめに

構造を維持するとは、単に物質や資源が残っていることではない。ある機能、関係、同一性、または推論経路を保てる状態の余地が残っていることである。構造持続の最小形式では、この余地を構造維持可能集合 \(V^{(t)}\) の測度 \(m(V^{(t)})\) として表し、その縮小を対数比で測る消耗側の最小核を孤立させた。構造持続の条件つき導出では、その核から指数表現をどこまで恒等式として読めるか、どこからが独立性や弱依存といった追加条件に依存するかを切り分けた。

しかし、収縮モードだけでは、回復を含む構造持続を十分に記述できない。LLM の対話では、未整理矛盾が推論経路を削る一方で、scope marker や外部代謝がその衝突を整理し直す。継続学習では、前提更新が依存知識を壊す一方で、依存構造に沿った再提示や外部 controller が整合を部分的に回復する。ソフトウェアや組織では、障害や制約が構造を削る一方で、rollback、冗長化、運用手順、外部支援が維持可能性を補う。

このとき問うべき量は、構造がどれだけ削られたかだけではない。構造維持可能性がどれだけ消耗し、それに対してどれだけ回復したか、その差し引きである。

本稿では、この差し引きを **構造持続の収支原理** と呼ぶ。英語では **Structural Persistence Balance** と呼ぶ。ただし、ここでの balance は equilibrium ではなく、収支、すなわち構造消耗と回復の accounting を意味する。したがって「均衡法則」とは訳さない。収支が正であれば構造消耗が優位であり、収支が負であれば回復が優位である。維持はその中間の一つの regime にすぎない。

1.1 本稿の問い

本稿の問いは、次の一文にまとめられる。

\begin{quote}
回復を含む構造系では、何をどれだけ補えば、構造は持続し、どの収支を越えると崩壊へ向かうのか。
\end{quote}

この問いは、構造持続の最小核を否定するものではない。むしろ、その最小核を \(r_t=0\) の特例として回収する。そのうえで、repair, learning, redundancy, external support, rollback のような再拡大作用を、同じ対数尺度上の回復量 \(r_t\) として導入する。

本稿の基本形は、読者向けには次の一式である。
\[
  S = M e^{-B},
  \qquad
  B = \sum_t(d_t-r_t)
\]
これは構造持続の最小形式の \(S=Me^{-L}\) を、回復量を含む形式へ持ち上げた同型の式である。

厳密な有限時間地平では、まず純消耗量と累積純消耗量を
\[
  b_t = d_t - r_t,
  \qquad
  B_n = \sum_{t=0}^{n-1} b_t
\]
と置き、時刻 \(n\) の構造持続ポテンシャルを
\[
  S_n = M_n e^{-B_n}
\]
と書く。必要なら残存比を \(R_n=e^{-B_n}\) と分離してもよい。集合値核だけを取り出せば、
\[
  m(V^{(n)}) = m(V^{(0)}) e^{-B_n}.
\]

ここで \(d_t\) は構造消耗量、\(r_t\) は回復量、\(b_t\) は純消耗量、\(B_n\) は累積純消耗量である。この表記にすると、構造持続の最小形式の \(S=Me^{-L}\) は、回復量を明示しない \(r_t=0\) の場合、したがって \(B_n=L_n\) となる特例として回収される。言い換えると、回復量を入れない場合、累積純消耗量は最小形式の累積情報損失、または累積構造消耗量に一致する。回復量を含む場合には \(r_t\) が正でありうるため、\(B_n\) は増えるとは限らない。

1.2 本稿の位置づけ

本稿は、M 分解を普遍理論の中核に据えるものではない。\(M\)（有効維持余力）の維持能力成分の分解は、補論「構造持続における M（有効維持余力）の操作的定式化」で扱う operational mapping layer である。すなわち、現実ドメインで \(r_t\) や回復能力をどのように測るかを与える層であって、本稿の主理論核そのものではない。

本稿が主理論 spine に与える核は、構造持続の最小形式の消耗側の最小核を \(r_t=0\) の特例として回収しつつ、構造消耗量 \(d_t\) と回復量 \(r_t\) の差し引きが、構造維持可能領域の指数的変化を支配するという収支恒等式である。

同時に、本稿の独自性は、対数比、ドリフト、回復という既存の道具を発明したことにはない。独自性は、対象となる構造条件、測度、時間地平、消耗側、回復側、そして主張強度を事前に固定し、それらを混同せずに写像する運用規律にある。この点は §7.7 で既存理論との差分として改めて整理するが、読者は最初からこの位置づけを念頭に置いてよい。

この位置づけにより、既存の分冊は次のように並び直される。

- 構造持続の最小形式は、\(r_t=0\) の loss-only 収縮モードを与える。
- 条件つき導出補論は、指数表現がどの条件で恒等式となり、どの条件で境界として安定化するかを与える。
- 集合値力学補論は、収縮作用 \(K_t\) と再拡大作用 \(R_t\) の合成から、符号付き純消耗量 \(B_n\) に対する指数核を与える。
- Lean M1 は、期待値レベルの傾向が既存の定理対応によって支えられることを示す。
- Mixed-CSP および Bernoulli-CSP 系は、有限時間の bad-event drift と Chernoff / KL 型 collapse bound の仕様固定レイヤー anchor を与える。
- LLM companion I / II は、scope-as-repair, external metabolism, dependency-aware replay などを回復量の推定レイヤー indicator として与える companion anchors である。
- M 補論は、回復量・資源入力を実ドメインで測るための operational coordinate を与える。

したがって本稿は、既存結果の上に新しい万能法則を宣言するのではなく、散在していた収縮・修復・資源・確率境界の層を、「構造持続の収支原理」という一つの主導線に沿って再配置する。

1.3 本稿が主張しないこと

本稿は、以下を主張しない。

- 構造持続理論がすでに普遍法則として確立したとは主張しない。
- あらゆるドメインで自然な測度 \(m\)、構造消耗量 \(d_t\)、回復量 \(r_t\) が一意に定まるとは主張しない。
- \(r_t\) が無料で得られるとは主張しない。回復には資源制約、外部供給、時間遅れ、劣化、交絡がありうる。
- 高確率の崩壊 / 非崩壊境界が、期待値レベルの傾向から無条件に従うとは主張しない。
- LLM companion I / II の観察が、機構レベルで同一であるとは主張しない。
- M の維持能力成分の分解が universal metric を与えるとは主張しない。

本稿が与えるのは、より限定された主張である。すなわち、事前固定された構造維持問題において、構造消耗量と回復量が同じ対数尺度で定義できるなら、その差し引き \(b_t\) の累積純消耗量 \(B_n\) に対して指数的な残存則が成り立つ。そして確率過程として扱う場合には、\(\mathbb E[b_t]\) の符号が傾向を与え、bounded increments や MGF などの追加条件があれば高確率境界へ進める、ということである。


2. 最小収支形式

本節では、構造持続の収支原理の最小形式を定義する。ここでの目的は、最も一般的な repair theory を完成させることではない。回復を明示しない最小モードと、回復を含むモードを、同じ指数核で扱うための最小恒等式を切り出すことである。

2.1 構造維持可能集合と二段階更新

基体または状態空間 \(X\) と維持条件 \(G\) を固定する。状態、行動、経路のいずれを比較対象として数えるかを観測単位として事前に固定し、その比較対象空間を \(\Omega_X\) と書く。各時刻 \(t\) における構造維持可能集合 \(V^{(t)}\subseteq\Omega_X\) を考える。\(m\) は、各 \(V^{(t)}\) の比較に用いる有限測度である。本稿でも構造持続の最小形式と同様に、維持条件 \(G\)、測度、時間地平、観測単位は事前に固定されているものとする。

回復を含む構造系では、各時刻の更新を二つに分ける。

第一に、収縮作用
\[
  K_t : \mathcal P(\Omega_X) \to \mathcal P(\Omega_X)
\]
を置く。これは制約、障害、矛盾、前提更新、資源不足、攻撃、負荷などによって構造維持可能領域を削る作用である。

第二に、再拡大作用
\[
  R_t : \mathcal P(\Omega_X) \to \mathcal P(\Omega_X)
\]
を置く。これは repair, learning, redundancy, external support, rollback などによって構造維持可能領域を押し広げる作用である。

最小形式では、
\[
  K_t(A) \subseteq A,
  \qquad
  A \subseteq R_t(A)
\]
を仮定する。時刻 \(t\) から \(t+1\) への更新を
\[
  V_t^- := K_t(V^{(t)}),
  \qquad
  V^{(t+1)} := R_t(V_t^-)
\]
で定める。\(V_t^-\) は収縮直後の集合、\(V^{(t+1)}\) は回復後の集合である。

現実の系では、収縮と回復が同時または相互作用的に起きる場合がある。本稿ではそれを、観測単位ごとの構造粒度を落とした discrete step の内部で \(K_t\) と \(R_t\) の合成として畳み込む。

以後、考える有限時間地平の範囲で、\(m(V^{(t)})\) および \(m(V_t^-)\) は有限かつ正であると仮定する。この仮定は、以下の対数比が well-defined であるために必要である。

2.2 構造消耗量・回復量・純消耗量

各時刻 \(t\) の構造消耗量を
\[
  d_t := -\log \frac{m(V_t^-)}{m(V^{(t)})}
\]
と定める。これは収縮作用 \(K_t\) が、その段階で構造維持可能領域をどれだけ削ったかを測る量である。\(K_t(V^{(t)})\subseteq V^{(t)}\) であるから、\(d_t\ge 0\) である。

各時刻 \(t\) の回復量を
\[
  r_t := \log \frac{m(V^{(t+1)})}{m(V_t^-)}
\]
と定める。これは再拡大作用 \(R_t\) が、収縮後の領域をどれだけ押し広げたかを測る量である。\(V_t^- \subseteq R_t(V_t^-)=V^{(t+1)}\) であるから、\(r_t\ge 0\) である。

ここで重要なのは、\(d_t\) と \(r_t\) がどちらも質量比の対数で測られていることである。これにより、構造消耗と回復を同じ尺度で差し引ける。

\begin{definition}[純消耗量]
各時刻 \(t\) の純消耗量を
\[
  b_t := d_t - r_t
\]
と定義する。
\end{definition}

累積量を
\[
  L_n := \sum_{t=0}^{n-1} d_t,
  \qquad
  R_n^{\mathrm{rec}} := \sum_{t=0}^{n-1} r_t,
  \qquad
  B_n := \sum_{t=0}^{n-1} b_t = L_n - R_n^{\mathrm{rec}}
\]
と定める。\(L_n\) は loss-only での累積情報損失、または本稿の語彙での累積構造消耗量である。\(R_n^{\mathrm{rec}}\) は累積回復量、\(B_n\) は累積純消耗量である。

2.3 純消耗量の対数比表現

収縮と回復を別々に定義しても、純消耗量は局所的には始点と終点の対数比だけで表される。

命題 1（純消耗量の対数比表現）。
各時刻 \(t\) について
\[
  b_t = -\log \frac{m(V^{(t+1)})}{m(V^{(t)})}
\]
が成り立つ。

証明。
定義より
\[
\begin{aligned}
b_t
&=
d_t - r_t \\
&=
-\log \frac{m(V_t^-)}{m(V^{(t)})}
-
\log \frac{m(V^{(t+1)})}{m(V_t^-)} \\
&=
-\log \frac{m(V^{(t+1)})}{m(V^{(t)})}.
\end{aligned}
\]
中間集合 \(V_t^-\) の質量が打ち消し合うため、主張が従う。証明終。

この命題は、構造消耗量と回復量の分解が domain-specific であっても、局所的に残る差し引き量はなお対数比として一意に読めることを示す。したがって、構造持続の最小形式の対数比核は、回復を含む系においても失われない。

2.4 局所収支則

命題 1 から、各段階の質量更新は指数型で書ける。

命題 2（局所収支則）。
各時刻 \(t\) について
\[
  m(V^{(t+1)}) = m(V^{(t)}) e^{-b_t}
\]
が成り立つ。

証明。
命題 1 より
\[
  e^{-b_t} = \frac{m(V^{(t+1)})}{m(V^{(t)})}
\]
である。両辺に \(m(V^{(t)})\) を掛ければよい。証明終。

この式は、局所的な収支の符号を直接読むことを可能にする。

- \(b_t>0\): 構造消耗量が回復量を上回り、構造維持可能領域は縮小する。
- \(b_t=0\): 構造消耗量と回復量が釣り合い、測度上の維持が起きる。
- \(b_t<0\): 回復量が構造消耗量を上回り、構造維持可能領域は拡大する。

ここで \(b_t=0\) は一つの局面であって、本稿の理論全体を equilibrium に還元するものではない。構造持続の収支原理は、三つの局面を同じ符号付き量で扱うための原理である。

冒頭で述べた通り、この局面分類は均衡判定ではなく、事前固定された観測単位の上での会計分類である。隣接区間を併合すると
\[
  b_{t:t+2}
  =
  -\log\frac{m(V^{(t+2)})}{m(V^{(t)})}
  =
  b_t+b_{t+1}
\]
となるため、累積純消耗量 \(B_n\) は時間併合に対して加法的に整合する。一方で、細かい粒度では「消耗の後に回復」と読める経路が、粗い粒度では \(b_{t:t+2}=0\) の維持局面として読まれることがある。したがって、局面分類、collapse boundary、hitting-time bound を経験的または確率的に主張する場合には、対象となる構造条件だけでなく、観測単位、段階列、時間地平も P2 の一部として事前固定する必要がある。

2.5 符号付き指数核

局所収支則を時間方向に積み上げると、構造持続の収支原理の中心恒等式が得られる。

定理 1（構造持続の収支原理の最小指数核）。
任意の \(n\ge 0\) について
\[
  m(V^{(n)}) = m(V^{(0)}) e^{-B_n}
\]
が成り立つ。

証明。
命題 2 を \(t=0,\ldots,n-1\) にわたって掛け合わせると
\[
\frac{m(V^{(n)})}{m(V^{(0)})} = \prod_{t=0}^{n-1} e^{-b_t} = e^{-\sum_{t=0}^{n-1} b_t} = e^{-B_n}.
\]
したがって
\[
  m(V^{(n)}) = m(V^{(0)}) e^{-B_n}
\]
である。証明終。

この定理は、指数型が loss-only 収縮モードに限られないことを示す。構造消耗量と回復量を同じ対数尺度で測れる限り、残存量は累積純消耗量 \(B_n\) に対して指数型で表される。

資源項を明示的に追跡する場合、読者向けの最小表示は
\[
  S = M e^{-B}
\]
である。これは構造持続の最小形式の
\[
  S = M e^{-L}
\]
と同じ顔を持つ。違いは、最小核の累積構造消耗量 \(L\) が、回復を含む形式では回復量を差し引いた累積純消耗量 \(B\) に置き換わる点である。厳密な finite-prefix 表記では
\[
  B_n := \sum_{t<n}(d_t-r_t),
  \qquad
  S_n := M_n e^{-B_n}
\]
と書く。必要なら残存比を \(R_n:=e^{-B_n}\) と置き、\(S_n=M_n R_n\) と分離してもよい。

2.6 収縮モードの回収

構造持続の最小形式は、構造持続の収支原理の特例として回収される。

命題 3（loss-only 収縮モード）。
すべての時刻で回復量が存在しない、すなわち \(r_t=0\) であるなら、
\[
  B_n = L_n
\]
であり、定理 1 は
\[
  m(V^{(n)}) = m(V^{(0)}) e^{-L_n}
\]
に一致する。

証明。
\(r_t=0\) なら各 \(t\) で \(b_t=d_t\) である。したがって
\[
  B_n = \sum_{t=0}^{n-1} b_t
      = \sum_{t=0}^{n-1} d_t
      = L_n.
\]
これを定理 1 に代入すればよい。証明終。

したがって、構造持続の収支原理は最小形式を置き換えるものではない。むしろ、その最小形式を \(r_t=0\) の特例として含む、より一般の形式である。

2.7 次節への接続

本節で示したのは、定義と対数比から従う恒等式である。ここまでは確率的独立性も、martingale 条件も、concentration も必要ない。

次に必要になるのは、\(b_t\) を確率過程として見たとき、その期待値の符号がどのような傾向を意味するかである。直観的には、
\[
  \mathbb E[b_t] > 0
\]
なら構造消耗優位の collapse tendency、
\[
  \mathbb E[b_t] \approx 0
\]
なら maintenance tendency、
\[
  \mathbb E[b_t] < 0
\]
なら recovery tendency を表す。

ただし、この期待値レベルの傾向は高確率境界ではない。有限時間で collapse / non-collapse の確率境界を得るには、bounded increments, MGF, Azuma-Hoeffding, Chernoff-KL などの追加条件が必要になる。この切り分けが、本稿の次節以降の主題である。


3. 期待値レベルの傾向律

前節の構造持続の収支原理は、各実現経路に対する恒等式である。そこには確率は入っていない。本節では、構造消耗量と回復量が確率的に生成される場合に、どのような意味で「崩壊傾向」「維持傾向」「回復傾向」を言えるかを切り分ける。

重要なのは、期待値レベルの傾向律と、高確率の崩壊境界を混同しないことである。期待値の符号は、累積純消耗量の中心がどちらへ動くかを与える。しかし、それだけで個々の経路が高確率に崩壊する、または崩壊しない、とは言えない。高確率主張には、4節で述べる concentration 条件が別に必要である。

3.1 構造持続の確率的収支過程

確率空間 \((\Omega,\mathcal F,\mathbb P)\) 上で、各時刻の構造消耗量 \(d_t(\omega)\)、回復量 \(r_t(\omega)\)、純消耗量
\[
  b_t(\omega) := d_t(\omega)-r_t(\omega)
\]
が定義されているとする。累積純消耗量を
\[
  B_n(\omega) := \sum_{t=0}^{n-1} b_t(\omega)
\]
と置く。各 \(\omega\) で前節の集合値更新が well-defined であるなら、経路ごとに
\[
  m(V^{(n)}(\omega)) = m(V^{(0)}(\omega)) e^{-B_n(\omega)}
\]
が成り立つ。

この式は pathwise identity であり、確率的独立性を仮定しない。確率が関与するのは、\(B_n\) の分布、期待値、集中、停止時刻を問う段階からである。

3.2 期待中心

各 \(b_t\) が可積分であるとする。このとき累積純消耗量の期待中心を
\[
  \bar B_n := \mathbb E[B_n]
\]
と書く。線形性により
\[
  \bar B_n = \sum_{t=0}^{n-1} \mathbb E[b_t]
\]
である。

したがって、各時刻で
\[
  \mathbb E[b_t] \ge 0
\]
なら、\(\bar B_n\) は \(n\) に関して非減少である。さらに、ある \(\alpha>0\) について
\[
  \mathbb E[b_t] \ge \alpha
\]
がすべての \(t\) で成り立つなら、
\[
  \bar B_n \ge n\alpha
\]
であり、期待中心は線形に増加する。

逆に、
\[
  \mathbb E[b_t] \le 0
\]
なら、期待中心は非増加方向へ向かう。ある \(\alpha>0\) について
\[
  \mathbb E[b_t] \le -\alpha
\]
なら、期待中心は少なくとも線形に減少する。

3.3 三つの傾向 regime

以上から、期待値レベルでは次の三 regime を区別できる。

| regime | condition | interpretation |
|---|---|---|
| collapse tendency | $\mathbb E[b_t] > 0$ | 構造消耗量が回復量を上回る |
| maintenance tendency | $\mathbb E[b_t] \approx 0$ | 構造消耗量と回復量が釣り合う |
| recovery tendency | $\mathbb E[b_t] < 0$ | 回復量が構造消耗量を上回る |

ここで「tendency」と呼ぶのは、期待中心 \(\bar B_n\) の向きを述べているからである。これは、個々の経路の単調性ではない。また、\(m(V^{(n)})\) の期待値がただちに \(m(V^{(0)})e^{-\bar B_n}\) に等しいという主張でもない。一般に
\[
  \mathbb E[e^{-B_n}]
  \ne
  e^{-\mathbb E[B_n]}
\]
である。したがって、本節の主張は、まず累積純消耗量 \(B_n\) の期待中心に関するものである。

この注意は重要である。期待値レベルの傾向律を、残存量そのものの平均に関する厳密な式や、高確率な collapse / non-collapse と混同すると、主張が過剰になる。本稿では、その混同を避ける。

3.4 Lean 形式化との対応

Lean 側では、この期待値レベルの傾向律は、既存の theorem map によってすでに支えられている。対応する主な語彙は次の通りである。

| 本稿の語彙 | Lean 側の語彙・定理 |
|---|---|
| 局所収支則 | `GeneralStateDynamics.local` |
| 累積指数核 | `GeneralStateDynamics.cumulative` |
| 非負 one-step production からの期待単調性 | `TotalProduction.expected` |
| 構造粒度変換後の expectation tendency | `CoarseTypicalNondecrease` |
| SAT state-dependent expected tendency | `SATStateDependentCount` |

ここで重要なのは、Lean が「すべての実ドメインで回復量が正しく測れている」ことを証明しているわけではない、という点である。Lean が保証しているのは、明示された確率過程・生産量・有界性・期待値条件のもとで、期待中心の単調性や有限時間境界が論理的に従うことである。

したがって、本稿の paper-side wording は次のように保つ。

\begin{quote}
At the expectation level, a law-of-tendency theorem is available when one-step net production is nonnegative, or when a resource-bounded assumption implies nonnegative one-step production. High-probability stopped-collapse statements require additional concentration and margin assumptions.
\end{quote}

3.5 ここまでで言えること

本節で言えるのは、次である。

第一に、構造持続の収支原理の純消耗量 \(b_t=d_t-r_t\) を確率変数として扱うと、その期待値の符号は累積純消耗量 \(B_n\) の期待中心の向きを決める。

第二に、構造消耗優位、維持、回復優位という三 regime は、同じ純消耗量 \(b_t\) の符号として定義できる。

第三に、これは high-probability statement ではない。有限時間で崩壊確率や停止時刻確率を述べるには、次節の concentration layer が必要である。


4. 有限時間境界と停止時刻

期待値レベルの傾向律は、構造持続の収支原理の方向を与える。しかし、実際に有限時間内で崩壊するか、あるいは閾値を越えないかを述べるには、分布のばらつきを制御しなければならない。本節では、そのための最小 schema を述べる。

4.1 崩壊閾値

相対残存量を
\[
  R_n := \frac{m(V^{(n)})}{m(V^{(0)})}
\]
と置く。構造持続の収支原理より
\[
  R_n = e^{-B_n}
\]
である。

閾値 \(\theta\in(0,1]\) を固定し、
\[
  B_\theta := -\log \theta
\]
と置く。このとき
\[
  R_n \le \theta
\]
は
\[
  B_n \ge B_\theta
\]
と同値である。したがって、有限時間 collapse event は、累積純消耗量 \(B_n\) が閾値 \(B_\theta\) を越える事象として表せる。

4.2 固定時刻での高確率崩壊 schema

固定時刻 \(n\) で、期待中心または deterministic center を \(c_n\) とする。たとえば \(c_n=\mathbb E[B_n]\) と置いてよい。

ある failure profile \(\delta_n(r)\) があり、すべての \(r\ge 0\) について
\[
  \mathbb P(B_n < c_n-r) \le \delta_n(r)
\]
が成り立つとする。これは \(B_n\) の lower-tail concentration である。

もし
\[
  c_n-r \ge B_\theta
\]
なら、補集合
\[
  \{B_n < B_\theta\}
\]
は \(\{B_n < c_n-r\}\) に含まれる。したがって
\[
  \mathbb P(R_n > \theta) = \mathbb P(B_n < B_\theta) \le \delta_n(r).
\]
同値に、
\[
  \mathbb P(R_n \le \theta) \ge 1-\delta_n(r)
\]
である。

これが固定時刻の high-probability collapse schema である。ここで必要なのは、期待中心が閾値を越えていることだけではない。中心から閾値までの margin \(r\) と、その margin に対する lower-tail probability bound が必要である。

4.3 停止時刻

崩壊閾値 \(\theta\) に対する hitting time を
\[
  \tau_\theta := \inf\{n \ge 0 : B_n \ge B_\theta\}
\]
と定める。これは、相対残存量 \(R_n\) が \(\theta\) 以下になった最初の時刻である。

有限地平 \(N\) において
\[
  \tau_\theta < N
\]
を示したい場合、単一の時刻 \(n\) で \(B_n\ge B_\theta\) が高確率に成り立てば十分である。より精密には、各時刻 \(j<N\) に対する lower-tail bound を組み合わせることで、hitting-time event の確率上界または下界を得る。

Lean 側では、この層は stopped-collapse / hitting-time theorem 群としてすでに分離されている。重要なのは、停止時刻境界が期待値レベルの傾向そのものではなく、concentration と margin を追加した第二層だという点である。

4.4 Azuma / Chernoff / KL の役割

どの concentration を使うかは、生成過程の性質によって異なる。

| 条件 | 典型的な境界 | 役割 |
|---|---|---|
| bounded increments + martingale-like structure | Azuma-Hoeffding | 一般的な有限時間 concentration |
| Bernoulli bad-event exposure | Chernoff / KL | CSP / SAT / q-coloring などの仕様固定レイヤー anchor |
| exact MGF product | optimized Chernoff-KL | tight exponential profile |
| resource-bounded conditional drift | stopped-collapse wrapper | 回復・資源制約つき過程 |

SAT / Bernoulli-CSP では、bad-event count の MGF product が内部導出できるため、Chernoff-KL 型の指数境界が得られる。これは期待値レベルの傾向より強い。なぜなら、単に中心が増えるだけでなく、中心から大きく外れる確率を指数的に抑えるからである。

一方、LLM や software のような推定レイヤーでは、自然な MGF product が直ちに得られるとは限らない。その場合、まずは期待値レベルの傾向や予測検証に留め、高確率境界を主張するには追加の確率モデルが必要である。

4.5 Lean 形式化との対応

本節の schema は、Lean 側では次のような既存層に対応する。

| 本稿の語彙 | Lean 側の語彙・定理 |
|---|---|
| bounded-increment concentration | Azuma modules |
| concentration interface | `ConcentrationInterface.lean` |
| resource-bounded stopped collapse | Resource-bounded modules |
| hitting-time event | Stopping-time modules |
| Bernoulli-CSP Chernoff collapse | Chernoff collapse wrappers |
| SAT Chernoff-KL closed form | SAT KL algebra module |

この対応により、本稿は次の二層を明示的に分ける。

1. 期待値レベルの傾向: \(\mathbb E[b_t]\) または one-step production 条件から、累積純消耗量の期待中心の向きを得る。
2. high-probability finite-horizon bound: bounded increments, MGF, Chernoff / KL, margin 条件を追加して、collapse / stopped-collapse / hitting-time の確率境界を得る。

この分離は、普遍理論候補としての節度を保つために重要である。期待値の符号だけで高確率崩壊を主張しない。逆に、仕様固定レイヤーのように MGF product や Chernoff-KL が得られるドメインでは、その強い構造を明示的に使う。

4.6 次節への接続

ここまでで、構造持続の収支原理の主理論層は次の形に整理された。

- §2: pathwise identity としての構造持続の収支原理。
- §3: 期待値レベルの傾向。
- §4: concentration / margin 条件つきの finite-horizon collapse schema。

次に必要なのは、この schema がどの concrete domain で自然に閉じるかである。仕様固定レイヤーでは、SAT / Mixed-CSP / Bernoulli-CSP が最も硬い anchor であり、Exp43c q-coloring により SAT 構文の外側へ empirical support が一段広がった。推定レイヤーでは、LLM companion I / II の scope-as-repair, external metabolism, dependency-aware replay が、回復量 \(r_t\) の observational indicator として扱われる。


5. 仕様固定レイヤー anchors

本節では、§2-4 の schema が最も強く閉じる concrete domain を整理する。ここでいう 仕様固定レイヤー anchor とは、次の四条件が問題設定そのものから与えられる場合を指す。

1. 構造維持可能集合 \(V\) が明示される。
2. 測度 \(m\) が自然に定まる。
3. 各 step の縮小率、または bad-event probability が仕様から計算できる。
4. 独立 exposure や MGF product などにより、期待値レベルの傾向から finite-horizon concentration へ進める。

以下では本論文の主鎖に必要な部分だけを述べる。family 別の Lean file inventory、実装上の verifier / solver guardrail、補助的な stress extension の詳細は、有限CSP補論、各 experiment README、対応する primary report に譲る。

この条件を満たすと、構造持続の収支原理は単なる分類語ではなく、実際に予測量を返す。すなわち、各制約または exposure の構造消耗量を
\[
  d_i = -\log(1-p_i)
\]
として足し上げることで、
\[
  L = \sum_i d_i
\]
が得られる。回復量を明示的に入れない loss-only finite CSP では \(r_i=0\) であり、\(B=L\) である。したがって
\[
  m(V^{(m)}) = m(V^{(0)})e^{-L}
\]
が pathwise または first-moment level の中心座標になる。

仕様固定レイヤー が強いのは、ここで止まらない点にある。bad-event exposure が Bernoulli 型に閉じる場合、count の MGF product が得られ、Chernoff / KL 型の lower-tail bound を通じて §4 の collapse / stopped-collapse / hitting-time schema に接続できる。つまり、仕様固定レイヤーでは
\[
  \text{仕様から drift}
  \quad\to\quad
  \text{線形中心}
  \quad\to\quad
  \text{MGF product}
  \quad\to\quad
  \text{finite-horizon bound}
\]
という鎖が自然に閉じる。

5.1 SAT anchor

ランダム 3-SAT は、この鎖が最も明示的に見える基本例である。状態集合を \(\{0,1\}^n\)、測度を counting measure とする。固定された割当てから見ると、ランダムな 3-clause がその割当てを破る確率は \(1/8\) であり、満たす確率は \(7/8\) である。したがって一 clause あたりの構造消耗量は
\[
  d_{\mathrm{SAT}} = -\log(7/8) = \log(8/7)
\]
である。

\(m\) 個の independent clause exposure に対して、first moment は
\[
  \mathbb E[\#\mathrm{SAT}] = 2^n(7/8)^m = \exp(n\log 2 - m\log(8/7))
\]
となる。これは、構造持続の収支原理の loss-only 特例
\[
  B_m=L_m=m\log(8/7)
\]
を有限 CSP の自然測度上で読んだものである。

Lean 側では、この SAT anchor は clause-exposure path、count support、MGF product、Chernoff-KL closed form、collapse / stopped-collapse / hitting-time wrapper まで段階的に閉じている。詳細な file inventory は有限CSP補論と README に譲るが、本論文で必要なのは、「仕様から drift が出て、そこから finite-horizon bound まで一つの定理鎖がある」という点である。

このため、SAT については、finite-horizon iid clause-exposure layer に限れば、次の意味で鎖が閉じている。

1. 問題仕様から \(\log(8/7)\) が出る。
2. actual path PMF から MGF product が出る。
3. MGF 最適化から Bernoulli relative entropy の Chernoff-KL profile が出る。
4. その profile が collapse / stopped-collapse / hitting-time bound に入る。

ただし、これは「すべての SAT solver dynamics を説明した」という主張ではない。ここで閉じているのは、有限時間の independent clause-exposure と、それに対応する first-moment / bad-count / collapse-bound の層である。CDCL や WalkSAT の探索過程、変数依存、threshold 近傍の精密な satisfiability transition は、別の dynamics 層に属する。

5.2 Bernoulli-CSP template

SAT anchor の一般形は、Bernoulli bad-event CSP として表せる。有限状態空間または有限 alphabet 上で、各 constraint が固定候補を bad にする確率を \(p\) とする。このとき一 constraint あたりの survival ratio は \(1-p\)、構造消耗量は
\[
  d(p)=-\log(1-p)
\]
である。

constraint type が複数ある場合には、type \(j\) の bad probability を \(p_j\)、その個数を \(m_j\) とすれば
\[
  L = \sum_j m_j\,[-\log(1-p_j)]
\]
となる。ここで重要なのは、raw count
\[
  m=\sum_j m_j
\]
では constraint の質的差が消えるのに対し、\(L\) は bad probability の差を加法的に保存する点である。

Lean 側では、この一般形も template core、Chernoff / collapse wrapper、family-level interface まで整理されている。ここで重要なのは file 名の網羅ではなく、SAT を一つの特殊例として閉じるだけでなく、Bernoulli bad-event probability を持つ有限CSP family 一般へ横展開できることである。

この層の役割は、SAT の結果を SAT 固有の偶然としてではなく、bad-event probability と対数 drift による有限 CSP class の一般 template として読むことである。

5.3 Mixed-CSP empirical anchor

ただし、単一 family だけを経験的に見ると、\(L\) は raw count と縮退する。たとえば 3-SAT 固定なら
\[
  L=m\log(8/7)
\]
であり、raw constraint count \(m\) の定数倍にすぎない。この設定では、\(L\) が raw count より良い予測量であるかを検査できない。

この縮退を避けるために、補論「有限CSPにおける構造持続の予測力」では Mixed-SAT/NAE-SAT を用いた。3-SAT と 3-NAE-SAT は raw count ではどちらも一つの制約だが、構造消耗量は異なる。
\[
  d_{\mathrm{SAT}}=\log(8/7),
  \qquad
  d_{\mathrm{NAE}}=\log(4/3).
\]
したがって混合インスタンスの構造消耗座標は
\[
  L = m_{\mathrm{SAT}}\log(8/7) + m_{\mathrm{NAE}}\log(4/3)
\]
となる。

2026-04-22 の事前登録済み primary run では、12,000 インスタンスが正常に完走し、timeout と malformed encoding は 0 であった。primary endpoint は solver cost ではなく feasibility / SAT rate である。これは、仕様固定レイヤーの第一モーメント構造が直接支配するのは解空間体積と feasibility であり、特定 solver の探索コストではないからである。

leave-one-mixture-out の結果は次であった。

| model | log loss | Brier | accuracy@0.5 |
|---|---:|---:|---:|
| `L_plus_n` | 0.0970 | 0.0299 | 0.9631 |
| `cnf_count_plus_n` | 0.1010 | 0.0304 | 0.9631 |
| `first_moment` | 0.1489 | 0.0482 | 0.9457 |
| `raw_plus_n` | 0.7525 | 0.2539 | 0.6159 |

この結果には三つの意味がある。

第一に、primary predictor `L_plus_n` は raw count baseline `raw_plus_n` を大きく上回った。
\[
  0.0970 < 0.7525.
\]

第二に、理論的に最も純粋な
\[
  n\log 2-L
\]
に対応する `first_moment` も raw baseline を上回った。
\[
  0.1489 < 0.7525.
\]

第三に、CNF encoding size の交絡に対する guardrail として、`L_plus_n` は `cnf_count_plus_n` にも少なくとも同等以上であった。
\[
  0.0970 \le 0.1010.
\]

これは、\(L\) が単なる制約数ではなく、制約が解空間を削る質的差を持つ座標として機能することを示す。ただし、この結果は universal law の確立ではない。正確には、Bernoulli-CSP class 内で、drift-weighted coordinate が raw-count baseline より feasibility を強く予測したという Level 2 support である。

この Mixed-CSP package は、公開後に依頼ベースの外部実行者 3 名によって独立に再実行された。3 件とも、凍結済み bundle を用いて 12,000 行の primary run を完走し、公式 primary JSONL に対する checked core fields は 0 mismatches、support flags はすべて true であった。環境は WSL / Ubuntu が 1 件、Windows 11 Home 系が 2 件であり、いずれも回避策は報告されていない。したがって Mixed-CSP は、依頼済みの 3 件の outside-group rerun set について、著者環境外でも同じ qualitative support decision が再現された状態にある。ただし、これは Mixed-CSP package に限った replication closure であり、non-CSP branch や observational branch の replication 完了を意味しない。

5.4 仕様固定レイヤー anchor の現在地

ここまでで、仕様固定レイヤーには三つの異なる状態がある。

第一に、SAT / Bernoulli-CSP の形式層は、Lean 側でかなり強く閉じている。ここで閉じているのは、仕様から bad-event probability と drift を計算し、path measure、MGF product、Chernoff-KL bound、collapse / hitting-time wrapper へ接続する有限時間の定理鎖である。

第二に、Mixed-CSP と Exp43c q-coloring は、経験的にも primary run を通った 仕様固定レイヤー anchor である。Mixed-CSP では、3-SAT と 3-NAE-SAT の混合により、raw count と drift-weighted coordinate の縮退を破り、事前登録された leave-one-mixture-out 検査で `L_plus_n` と `first_moment` が raw baseline を上回った。さらに、同じ frozen Mixed-CSP package は 3 名の外部実行者による独立再実行で 3/3 clean success を返している。Exp43c q-coloring では、freeze 済み threshold-local window の上で、`fm_plus_n` が raw edge count / density / CNF-size baselines を leave-one-q-out で上回った。さらに Exp43c package も、3 名の外部実行者による再実行で、それぞれ 4,000 行、checked core mismatches 0、TIMEOUT 0、MALFORMED 0、および同じ qualitative support decision を返している。

第三に、Cardinality-SAT は、現時点では proposed / calibration extension であり、validated empirical anchor ではない。Exp44 pilot calibration は、heterogeneous drift family でも informative window の配置が難しいことを示したため、Cardinality-SAT を primary evidence として扱うには、新しい threshold-local preregistration が必要である。Exp44b はその fresh draft と calibration-v1 dry-run として開かれたが、これは review / calibration 候補であって、freeze package でも validation evidence でもない。

この区別は重要である。仕様固定レイヤーの現在の validated empirical support は Mixed-CSP と Exp43c q-coloring であり、Cardinality-SAT は Exp44 no-go history と Exp44b draft を持つ future validation candidate である。

5.5 Validated extension I: q-coloring

SAT の外側に見える仕様固定レイヤーの幅 extension として最初に検査されたのが q-coloring である。理由は、SAT と見た目が大きく異なり、graph coloring、統計物理、組合せ最適化に接続するからである。

q-coloring の fixed-coloring edge exposure では、状態空間を \([q]^n\) とし、edge \((u,v)\) が同色を禁じる。固定 coloring から見ると、ランダム edge が bad になる確率は
\[
  p_q=\frac{1}{q}
\]
であり、一 edge あたりの構造消耗量は
\[
  d_q = -\log(1-1/q) = \log\frac{q}{q-1}.
\]

Lean 側では、q-coloring も Bernoulli-CSP template、edge-exposure path layer、Chernoff collapse wrapper に接続されている。ここでも重要なのは、graph-coloring family が SAT と別見えの対象でありながら、bad-edge drift という同じ仕様固定レイヤー grammar に入る点である。

ただし、経験的検査では注意が必要である。単一の \(q\) だけを見ると
\[
  L=m\log\frac{q}{q-1}
\]
であり、raw edge count \(m\) と縮退する。したがって q-coloring の primary empirical test は、単一 fixed-\(q\) family ではなく、\(q=3,4,5\) のような cross-\(q\) design、または threshold-normalized density design にする必要がある。

このため、q-coloring cross-q feasibility では、primary endpoint を colorable / uncolorable とし、primary predictor を \(L\) と state-space size correction の組、または threshold-normalized \(L\) として設計するのが自然である。baseline は raw edge count、density、\(n\)、\(q\)、および必要に応じて encoding-size diagnostic を含める。primary split は leave-one-q-out または leave-one-threshold-band-out が望ましい。

ここでも primary は solver cost ではない。colorability / feasibility である。solver metadata は diagnostic として残してよいが、仕様固定レイヤーの主張を solver dynamics にすり替えない。

初期 Exp43 / Exp43b の pilot calibration は、random CSP の sharp threshold を粗い grid で見に行く設計上の難しさを示した。そこで Exp43c では calibration / freeze / validation を分離した threshold-local protocol を用い、primary seed stream を calibration と分離して、q=3,4,5 の leave-one-q-out 検査を行った。

Exp43c primary validation では、4,000 インスタンスが正常に完走し、timeout と malformed encoding は 0 であった。primary endpoint は solver cost ではなく colorability / feasibility である。結果は次の通りである。

| model | mean held-out log loss |
|---|---:|
| `fm_plus_n` | 0.440189 |
| `first_moment` | 0.446814 |
| `raw_density` | 0.780910 |
| `density_plus_n_q` | 2.804019 |
| `cnf_count_plus_n_q` | 7.700105 |
| `raw_plus_n_q` | 8.567224 |

best preregistered primary raw baseline は 2.804019 であり、`fm_plus_n` はこれを大きく上回った。
\[
  0.440189 < 2.804019.
\]
相対改善は 84.3% であった。また、encoding-size guardrail でも
\[
  0.440189 < 7.700105
\]
となり、CNF encoding size 指標では説明されなかった。

fold-level でも H1 の方向は q=3,4,5 のすべてで通った。ただし q=5 fold は
\[
  0.426651 < 0.438133
\]
であり、差は 0.011482、相対改善は 2.62% に留まる。したがって、q=5 については「real but narrow」な fold-level win として扱い、大きな q=5 effect としては扱わない。

この結果で特に重要なのは、単に \(q\) を logistic regression の特徴量として入れた tuple predictor が leave-one-q-out で弱かった点である。`fm_plus_n` は \(n\log q-L\) という theory-specified coordinate の中に \(q\) 依存を畳み込む。一方、`raw_plus_n_q` や `cnf_count_plus_n_q` は \(q\) に自由係数を学習させるため、held-out q への外挿で壊れやすい。したがって Exp43c は、「\(q\) を追加特徴量として入れたから勝った」のではなく、「first-moment / drift coordinate として \(q\) 依存を事前に組み込んだ座標が外挿で機能した」ことを示している。

このため、q-coloring によって 仕様固定レイヤーは SAT / NAE-SAT mixed CSP に閉じず、graph-coloring family にも広がった。ただし、それでも universal law の確立ではない。正確には、SAT 以外に見える独立 family で、同じ first-moment / drift-weighted coordinate が frozen threshold-local window 内で out-of-sample に効いた、という primary empirical support である。

5.6 Proposed extension II: Cardinality-SAT and stress extensions

q-coloring の次に有用なのは、Cardinality-SAT や exactly-one SAT のような stress extension である。たとえば exactly-one-3-SAT では、3 変数のうちちょうど一つが真である割当てだけを許すため、許容数は \(\binom{3}{1}=3\)、survival ratio は \(3/8\)、drift は
\[
  \log(8/3)
\]
である。

これは 3-SAT の \(\log(8/7)\) よりはるかに大きく、drift の dose-response を強く検査できる。一方で、feasibility の飽和、CNF encoding size の交絡、solver 側の表現依存が強く出やすい。したがって、Cardinality-SAT は数学的には有用だが、最初の SAT 外 empirical extension としては q-coloring より後に置く方が安全である。

Exp44 Cardinality-SAT の pilot calibration も、solver / verifier / runtime path は clean であったが、current grid は freeze-ready ではない。特に low-drift mixtures では、precommitted fine grid でも informative band が一点に留まり、さらなる tuning は新しい Exp44b preregistration を必要とした。現在、Exp44b は fresh threshold-local draft と calibration-v1 config まで開かれている。dry-run では `4800` planned instances / `96` cells が確認されたが、solver run、freeze closeout、primary data はまだ存在しない。このため、Cardinality-SAT は現時点では validated empirical anchor ではなく、review 後の calibration-only execution から始めるべき proposed stress extension である。

5.7 仕様固定レイヤー anchor の限界

仕様固定レイヤー anchor は構造持続の収支原理の中で最も硬い証拠層である。しかし、次の限界を持つ。

1. 自然測度 \(m\) と bad-event probability が問題仕様から与えられる場合に強い。
2. 単一 family では \(L\) と raw count が縮退しやすい。
3. MGF product や Chernoff-KL は、独立 exposure などの追加構造に依存する。
4. feasibility と solver cost は別の問いである。
5. finite-horizon exposure bound は、無限時間の ergodic law や threshold theorem そのものではない。
6. 仕様固定レイヤー が広がっても、独立再現や異質ドメインへの写像なしに universal law は確立しない。

したがって、本節の正確な結論は次である。

\begin{quote}
SAT / Bernoulli-CSP、Mixed-CSP、Exp43c q-coloring は、構造持続の収支原理が自然測度と bad-event exposure の上で強く閉じる 仕様固定レイヤー universality-class candidate を与える。Cardinality-SAT は、その幅をさらに広げるための proposed stress extension であり、現時点では Exp44b の review / calibration gate を必要とする draft-stage anchor である。
\end{quote}

これは「普遍法則の完成」ではない。しかし、構造持続の収支原理が単なる比喩や分類ではなく、仕様から drift を計算し、finite-horizon bound と empirical prediction に接続できる一般形式であることを示す。

5.8 次節への接続

仕様固定レイヤーでは、測度、drift、MGF product が比較的自然に与えられる。これに対して、LLM 推論、継続学習、software / SaaS のような推定レイヤーでは、自然測度や path PMF は直ちには得られない。

しかし、それは構造持続の収支原理が使えないという意味ではない。むしろ、推定レイヤーでは \(r_t\) の observable indicator を慎重に設計し、期待値レベルまたは prospective prediction の形で検査する必要がある。次節では、LLM companion I / II の scope-as-repair, external metabolism, dependency-aware replay を、回復量 \(r_t\) の推定レイヤー anchor として整理する。


6. 推定レイヤー anchors

§5 の仕様固定レイヤー anchor では、自然測度、bad-event probability、path PMF、MGF product が問題仕様から与えられた。これに対して、LLM 推論、継続学習、software / SaaS のようなドメインでは、構造維持可能集合 \(V\) や測度 \(m\) を同じ強度で直接数えることは難しい。

本節では、このようなドメインを 推定レイヤーと呼ぶ。推定レイヤーでは、構造持続の収支原理
\[
  B_n=D_{\mathrm{obs}}-R_{\mathrm{obs}}^{\mathrm{rec}}
\]
を、pathwise に完全測定された恒等式としてではなく、観測可能な構造消耗指標と回復指標を通じて検査する。

このときの基本方針は次である。

1. 未整理矛盾、裸の競合値、前提更新、依存不整合などを消耗側指標として置く。
2. scope marker、source attribution、外部代謝、依存 DAG controller、空間分離などを回復側指標として置く。
3. 観測量 \(Y\) を、論理一貫性維持率、依存整合性、旧知識保持、更新成功率などとして事前固定する。
4. recovery indicator を含む structure-aware model が、quality-blind / raw-count / loss-only baseline より out-of-sample に予測力を持つかを検査する。

したがって、推定レイヤーの証拠は仕様固定レイヤー より弱い。推定レイヤーは、MGF product から高確率 bound を出す層ではない。むしろ、構造持続の収支原理が「何を構造消耗とし、何を回復として測るべきか」を予測し、その予測が観測量に対して基準モデルを上回るかを調べる層である。

6.1 推定レイヤーの証拠形式

推定レイヤーでは、次のような操作的モデルを置く。
\[
  B_{\mathrm{eff}} = D_{\mathrm{obs}} - R_{\mathrm{obs}}^{\mathrm{rec}},
\]
ここで \(D_{\mathrm{obs}}\) は観測された構造消耗指標、\(R_{\mathrm{obs}}^{\mathrm{rec}}\) は観測された回復指標である。\(B_{\mathrm{eff}}\) は、§2 の \(B_n\) と同じ強度の pathwise quantity ではない。あくまで、観測可能な推定量である。

推定レイヤーの最小検査は、次の形になる。

\[
  \text{構造消耗条件が同程度のとき、回復指標が強いほど }Y\text{ が保たれるか。}
\]

より強い検査は、次である。

\[
  (D_{\mathrm{obs}},R_{\mathrm{obs}}^{\mathrm{rec}})\text{ を区別する model が、}
  D_{\mathrm{obs}}\text{ だけ、または quality-blind baseline を上回るか。}
\]

この形なら、推定レイヤーでも事前登録された prospective prediction が可能である。ただし、次の主張はしない。

1. \(R_{\mathrm{obs}}^{\mathrm{rec}}\) が真の \(r_t\) を一意に測っているとは主張しない。
2. 観測された改善が単一機構で説明されるとは主張しない。
3. expectation-level の傾向から high-probability bound が従うとは主張しない。
4. observational support を causal effect と同一視しない。

この節の目的は、LLM companion I / II の結果を、構造持続の収支原理の \(r_t\) 側の observational anchor として位置づけることである。

6.2 LLM companion I: scope-as-repair

LLM companion I では、推論時の論理一貫性維持を観測量 \(Y\) とし、未整理の矛盾や競合値が有効推論経路を削るかを検査した。特に Exp40 / Exp42 / Exp41 は、推定レイヤーにおける回復指標の設計として重要である。

Exp40 では、文脈長を 32K に固定し、`zero_sanity`, `scoped`, `subtle`, `structural` を比較した。結果は次であった。

| condition | correct |
|---|---:|
| `zero_sanity` | 50/50 |
| `scoped` | 50/50 |
| `subtle` | 23/50 |
| `structural` | 0/50 |

ここで重要なのは、`scoped` が矛盾らしき情報を含むにもかかわらず、`zero_sanity` と同水準に戻った点である。quality-blind model は `scoped`, `subtle`, `structural` をいずれも contradiction-present として扱う。一方、structure-aware model は、`scoped` を repaired / zero-like、`subtle` を mild unscoped loss、`structural` を severe structural loss として扱う。leave-one-target-out の primary log loss は、quality-blind 0.6944 に対し、structure-aware 0.2763 であった。

構造持続の収支原理の語彙では、`subtle` や `structural` は消耗側指標である。これに対して `scoped` は、競合値を task 外へ範囲づける文脈内の回復側指標として読める。つまり、同じ「矛盾らしき文」が存在しても、その衝突がどの範囲に属するかを整理することで、有効な \(R_{\mathrm{obs}}^{\mathrm{rec}}\) が増え、観測収支 \(B_{\mathrm{eff}}\) が下がる、という読みである。

ただし、Exp40 は scoped condition の内部機構を同定したわけではない。scoped の改善が、明示命令への追従、source separation、dataset separation、または別の prompt feature によるものかは、Exp40 単独では分からない。

6.3 LLM companion I: attribution-as-repair

Exp42 は、Exp40 の scope-as-repair を分解した。`strong_scope`, `medium_scope`, `weak_scope`, `subtle` の四段階で、正答率は次のようになった。

| condition | correct | exact wrong-sum adoption |
|---|---:|---:|
| `strong_scope` | 50/50 | 0/50 |
| `medium_scope` | 49/50 | 0/50 |
| `weak_scope` | 42/50 | 1/50 |
| `subtle` | 10/50 | 25/40 mistakes |

第三列は exact wrong-sum adoption の診断である。`subtle` 行の 25/40 は、50 試行中の 40 失敗例に対する row-level analysis であり、他行の 0/50 は全試行中に該当 adoption が観測されなかったことを表す。

`medium_scope` は時間・データセット範囲を示すが、"ignore" や "use only" のような明示的命令を含まない。にもかかわらず、ほぼ完全に repair した。さらに `weak_scope` は、最小の source label だけを持つ条件であるが、裸の `subtle` に比べて wrong-sum adoption を大きく減らした。

したがって、Exp42 が示す 推定レイヤー的な中核は、scope-as-repair のなかでも attribution-as-repair が大きな成分を担う、という点である。すなわち、競合値を「どの source から来たものか」として分離するだけでも、未整理上書きとして取り込まれる失敗が減る。

この結果は、構造持続の収支原理の \(r_t\) 側に対して次の示唆を与える。
\[
  \text{source attribution}
  \quad\Rightarrow\quad
  \text{collision separation}
  \quad\Rightarrow\quad
  R_{\mathrm{obs}}^{\mathrm{rec}}\text{ の増加}
  \quad\Rightarrow\quad
  B_{\mathrm{eff}}\text{ の低下}.
\]

ただし、これは機構定理ではない。source label がどの内部表現を変えたか、attention pattern がどう変わったか、推論過程がどこで分岐したかまでは主張しない。主張できるのは、参照元 attribution を含む structure-aware coding が、quality-blind coding より観測量 \(Y\) をよく予測した、という限定された内容である。

Exp41 は、この scoped protection が GPT-4.1-mini 固有でないかを調べた。事前登録された primary claim は、`scoped > structural` が GPT-4.1-nano と Gemini 3.1 Flash Lite の二つの primary model で成立するかに限定された。結果は、GPT-4.1-nano で `scoped=27/30`, `structural=1/30`、Gemini で `scoped=30/30`, `structural=14/30` であり、2/2 モデルで成立した。

ここでも、不変量は固定された `subtle > structural` ordering ではない。実際、subtle と structural の相対順序はモデル依存であった。より保守的な不変量は、scope marker が未整理な structural conflict に対して repair 的に働く、という方向である。

6.4 LLM companion I: external metabolism

LLM companion I の対話実験は、in-context repair ではなく、外部プロセスによる repair supply を扱う。ON 条件では、矛盾する更新を外部で検出し、「旧値 -> 新値」の時間ラベルつき対として整理・保持する。OFF 条件では、同じ矛盾を注入するが、その整理を行わない。

gemma3:27b の 180 ターン実験では、規則＋事実の合算で次の結果が得られた。

| condition | consistency |
|---|---:|
| ON | 73.3% |
| NC | 56.7% |
| OFF | 21.1% |

ON vs OFF は \(p=0.0004\), Cohen's \(d=8.80\) であった。qwen3.5:27b の 30 ターン追試でも、全体正答率は ON 64.4%、OFF 44.4% となり、同じ方向が確認された。さらに、100 ターンの長期実験では、代謝あり条件で論理一貫性が長期にわたって安定し、単調な崩壊は観測されなかった。

構造持続の収支原理の語彙では、外部代謝は \(R_{\mathrm{obs}}^{\mathrm{rec}}\) を外部 channel から供給する intervention である。M 補論 §3 の語彙では、これは \(M_{\mathrm{ext}\to\mathrm{recovery}}\)、すなわち external channel が repair / resolution を供給する場合に対応する。

ただし、外部代謝 ON/OFF は、Exp40/42 の in-context scope-as-repair と同一機構ではない。共通しているのは、未整理な衝突を整理し、task-relevant な状態へ再配置するという観測上の帰結である。供給階層は異なる。

また、gemma3:27b の自己代謝と、qwen3.5:27b + Claude Sonnet の外部代謝を同一条件として合算してはならない。前者は coupled process、後者は teacher-like external process を含む。したがって、LLM companion I の外部代謝結果は、推定レイヤー anchor として強い方向性を持つが、機構同定や普遍的効果サイズの主張ではない。

6.5 LLM companion II: dependency-aware repair

LLM companion II は、推論時の一時的な scope marker ではなく、継続学習における前提更新と依存再編を扱う。ここでは、消耗側イベントは前提更新である。上流の前提が変わると、その下流にある派生知識も同時に更新されなければならない。これに失敗すると、単なる旧知識の喪失ではなく、現在有効な前提に対する依存不整合が生じる。

LLM companion II では、LoRA ベース継続学習に対して、主に三条件を比較した。

| 条件 | T5 依存整合性 | T5 更新成功率 | T5 時点の T1 保持 |
|---|---:|---:|---:|
| E-lite | 0.189 ± 0.096 | 0.400 ± 0.173 | 0.167 ± 0.289 |
| F-v2c | 0.333 ± 0.000 | 0.583 ± 0.144 | 0.000 ± 0.000 |
| F-multi | 0.367 | 0.500-0.750 | 0.500 |

LoRA 逐次更新は、パラメータを変えるため、partial reconfiguration としては働く。しかし主要結果は、その再構成作用が dependency repair を十分に代替しないことであった。最初の前提更新後、旧知識保持は全条件で急減した。これは、パラメータ更新が新しい信号に反応して表現を変える一方で、既存の派生知識との整合を自律的に取り直す回復量が弱いことを示す。

F-v2c は、前提と依存属性の関係を DAG として保持し、前提更新時に下流の依存属性だけを選択的に再提示する。これは、base LoRA update が持たない dependency repair を外部 controller が供給する条件である。依存整合性は E-lite の 0.189 から F-v2c の 0.333 へ改善した。一方、T5 時点の T1 保持は 0.000 であり、旧知識保持そのものは回復しなかった。

したがって、F-v2c は「古いものを保存する」介入ではない。現在有効な前提に対して、下流知識を整合させ直す intervention である。構造持続の収支原理の語彙では、これは dependency-aware \(R_{\mathrm{obs}}^{\mathrm{rec}}\) の indicator であり、M 補論 §3 の語彙では \(M_{\mathrm{ext}\to\mathrm{recovery}}\) に近い。

F-multi は、現在知識と過去知識を別々の adapter に分離する。これは repair というより、保持と更新の干渉を部分空間で分ける buffering / reconfiguration 的な回復である。T5 時点の T1 保持が 0.500 まで上がったことは、空間分離が保持と更新の衝突を緩和しうることを示す。ただし、これは理想振り分け条件で得た上界 indicator であり、実運用性能ではない。

LLM companion II が推定レイヤーに与える教訓は、単なる reconfiguration と repair を分ける必要がある、という点である。LoRA は新しい信号に反応して表現を再構成するが、依存構造を自律的に修復するとは限らない。F-v2c は依存整合性を改善するが、旧知識保持を回復しない。F-multi は保持を一部改善するが、完全な dependency repair ではない。したがって、\(r_t\) は単一の「資源量」ではなく、どの種類の回復がどの構造消耗に効いているかを区別して測る必要がある。

これは LLM companion II §7.5 の三役分離、すなわち parametric reconfiguration / external metabolism / response fidelity を、構造持続の収支原理側から \(r_t\) の indicator 階層として読み直したものである。M 補論 §3.5 は、この三役分離を support-side component decomposition として操作化する。

6.6 推定レイヤーのまとめ

LLM companion I / II は、仕様固定レイヤーのような自然測度・MGF product を持たない。しかし、構造持続の収支原理の観点から見ると、どちらも同じ形の検査を行っている。

| domain | 消耗側指標 | 回復側指標 | observed support |
|---|---|---|---|
| LLM companion I Exp40 | unscoped conflict / structural contradiction | scoped separation | `scoped` 50/50 vs `subtle` 23/50 vs `structural` 0/50 |
| LLM companion I Exp42 | naked competing value | source / time / dataset attribution | wrong-sum adoption: `subtle` 25/40 mistakes -> `weak_scope` 1/50 (1/8 mistakes) -> `medium/strong` 0/50 |
| LLM companion I Exp41 | structural contradiction | scoped marker | `scoped > structural` in 2/2 primary models |
| LLM companion I dialogue | unresolved contradictory updates | external metabolism | ON 73.3% vs OFF 21.1% in gemma3:27b |
| LLM companion II LoRA | premise update with dependencies | parameter reconfiguration only | old retention collapse after first premise update |
| LLM companion II F-v2c | dependency mismatch after premise update | DAG-based selective refresh | DC 0.189 -> 0.333 |
| LLM companion II F-multi | update / retention interference | adapter separation | T1 retention 0.500 under ideal routing |

この表から得られる保守的な結論は次である。

\begin{quote}
推定レイヤーでは、構造持続の収支原理は pathwise concentration theorem としてではなく、構造消耗指標と回復指標の組が観測量を予測するかを検査する方法論として働く。
\end{quote}

これは、推定レイヤーを弱く見せるための制限ではない。むしろ、自然測度や path PMF がないドメインで主張強度を誤らないための規律である。推定レイヤーの価値は、次の形で現れる。

1. loss-only / quality-blind baseline では説明しにくい逆転を予測できる。
2. 回復指標を追加した baseline + SP model が、domain baseline に対する out-of-sample 予測力の増分を持つかを検査できる。
3. 介入の種類によって、どの \(r_t\) がどの loss に効くかを区別できる。
4. 仕様固定レイヤーの定理層とは別に、実ドメインでの recovery design を導ける。

第四点は、単なる実装上の含意ではない。構造持続の収支原理は、consumption localization、recovery preservation、margin preservation、alternative-path preservation を共通座標に置くため、あるドメインで効いた維持設計を別ドメインの candidate intervention へ翻訳できる。たとえば、LLM の scope-as-repair は組織やソフトウェアでの責任境界・変更範囲の明示へ、継続学習の dependency-aware replay は制度変更や企業判断での下流再同期へ、repair / maintenance の margin は SaaS や運用系の局所復元余地へ転用できる。ただし、この転用は support ではない。転用先ドメインで写像と介入を凍結し、別データまたは future surface で検証して初めて support になる。

§6.1 の非主張をまとめ直すと、推定レイヤー だけからは次を言ってはならない。

1. high-probability collapse bound が得られたとは言わない。
2. \(r_t\) の真値を測定したとは言わない。
3. LLM companion I と LLM companion II が同一機構であるとは言わない。
4. 観測された association を causal proof と呼ばない。
5. universal law が確立したとは言わない。

これと別に、non-CSP empirical 側には loss-only observational branch がある。Backblaze drive reliability の Q4 2025 v1 は高い ranking signal を持ちながら frozen log-loss rule では no-support で終わった。一方、Q3 2025 v2 は、fresh untouched archive 上の calibration-aware redesign として separately frozen され、same-domain observational loss-only support を通った。ただしこれは回復量の evidence ではなく、推定レイヤーの scope / metabolism anchors とも別 tier である。ここで増えたのは「industrial reliability domain で loss-only operationalization が観測可能である」という限定的な support であって、non-CSP empirical gate 全体の閉鎖ではない。

この意味で、仕様固定レイヤーと 推定レイヤーは競合しない。仕様固定レイヤーは、自然測度と exposure law がある領域で構造持続の収支原理を強く閉じる。推定レイヤーは、自然測度が直ちに得られない領域で、どの構造消耗指標 / 回復指標が予測力を持つかを検査する。

6.7 次節への接続

§5 と §6 によって、構造持続の収支原理の二つの適用層が分かれた。

- 仕様固定レイヤー: 仕様から drift, MGF product, finite-horizon bound へ進む。
- 推定レイヤー: observable consumption / recovery indicator から prospective prediction へ進む。

次に必要なのは、この構造持続の収支原理が既存理論とどう関係するかを整理することである。非平衡熱力学、散逸構造、queueing theory の Lyapunov drift、確率制御、情報理論はいずれも、consumption / recovery / resource / drift を扱う既存枠組みを持つ。§7 では、これらとの同じ点と違う点を、単なる analogy ではなく、correspondence と formal reduction の強度差を明示しながら整理する。


7. 既存理論との差分

構造持続の収支原理は、既存理論と無関係な新語を作るものではない。むしろ、熱力学、非平衡系、queueing theory、確率制御、情報理論にすでに現れている「消耗、回復、流入、ドリフト、対数比」の構造を、構造維持可能性という一つの操作的座標に並べ直す試みである。

したがって、本節の目的は二つある。第一に、どの部分が既存理論と同じなのかを明示する。第二に、どの部分が本稿群の独自の operational discipline なのかを明示する。これを行わないと、構造持続の収支原理は、熱力学や Lyapunov drift の単なる言い換えに見える危険がある。

7.1 三つの接続強度

既存理論との関係には、少なくとも三つの強度がある。

| level | 名称 | 内容 | 本稿での扱い |
|---|---|---|---|
| G6-a | analogy | 語彙や直感が似ている | 導入・動機づけとしてのみ使う |
| G6-b | correspondence | 量、符号、条件の対応表が作れる | 差分を明示したうえで使う |
| G6-c | formal embedding / conditional reduction | 既存理論の差分・drift・balance が、本理論の変数へ仮定保持つきで埋め込める | 限定クラスの law-side credibility に効く |

本稿では、既存理論との接続をこの三段階で区別する。analogy だけでは理論的接続としては弱い。correspondence は有用だが、まだ theorem transfer を保証しない。formal embedding または条件つき reduction がある場合にのみ、既存理論の差分・drift・balance を構造持続の収支原理の変数として読むことができる。

この区別は重要である。構造持続の収支原理が熱力学に「似ている」ことは、それだけでは何も証明しない。一方、queueing theory の Lyapunov drift 条件のように、符号つき累積純消耗量として直接書き換えられるものは、より強い意味で構造持続の収支原理の特例または埋め込みとして扱える。

7.2 熱力学との関係

閉じた系の熱力学第二法則は、孤立系でエントロピーが減少しない、という方向性を述べる。構造持続の収支原理の loss-only 形式は、これと似た形を持つ。
\[
  r_t=0,
  \qquad
  b_t=d_t\ge 0,
  \qquad
  B_n=L_n\ge 0.
\]
このとき、構造維持可能領域は
\[
  m(V^{(n)})=m(V^{(0)})e^{-L_n}
\]
に従って縮小する。

この対応は、G6-a の analogy としては明確である。閉じた loss-only 系では、一方向の累積量が増え、構造維持可能性が下がる。開いた系では、回復量 \(r_t\) が入り、\(b_t=d_t-r_t\) の符号によって崩壊、維持、回復の三 regime が分かれる。この点は、開放系が外部から自由エネルギーや資源を取り入れて秩序構造を維持するという直感と対応する。

しかし、これは熱力学第二法則そのものではない。差分は次である。

| 熱力学 | 構造持続の収支原理 |
|---|---|
| 物理状態、熱、仕事、温度、エネルギー保存を扱う | 事前固定された構造維持可能集合と測度を扱う |
| エントロピーは物理的状態量である | $B_n$ は構造維持可能性の対数比である |
| $k_B$ など物理単位を持つ | 単位は測度 $m$ と対数比の規約に依存する |
| 孤立系・熱浴・可逆性などの物理仮定を持つ | 適用前に対象となる構造条件、測度、時間地平を固定する |
| open system の維持は具体的な物理流に依存する | $r_t$ は回復量の抽象座標であり、物理量とは限らない |

したがって、熱力学との接続は現時点では G6-a から G6-b の範囲である。具体的な物理系を取り、\(V^{(t)}\) を「対象となる構造条件を保つ微視状態集合」、\(m\) を熱力学的 multiplicity または path measure、\(r_t\) を外部駆動や自由エネルギー供給に対応させれば、より強い correspondence が作れる可能性はある。しかし、本稿はそれを一般に証明しない。

7.3 非平衡熱力学・散逸構造との関係

非平衡熱力学や散逸構造の語彙では、開いた系が外部との流れを通じて秩序を維持する。これは、構造持続の収支原理の問い
\[
  d_t \text{ を } r_t \text{ がどれだけ補えるか}
\]
とよく似ている。

対応を粗く書くと次のようになる。

| 非平衡系の語彙 | 構造持続の収支原理の語彙 |
|---|---|
| dissipation-like loss / entropy-production analogy | 構造消耗量 \(d_t\)（物理的 entropy production そのものではない） |
| external driving / resource throughput | 回復量 \(r_t\) |
| steady state | $\mathbb E[b_t]\approx 0$ の maintenance regime |
| instability / transition | $B_n$ が collapse threshold を越える event |
| driven recovery | $\mathbb E[b_t]<0$ の recovery tendency |

この correspondence は有用である。しかし、非平衡熱力学は物理的保存則、局所詳細釣り合い、熱浴、化学ポテンシャルなどの具体的構造を持つ。本稿の \(r_t\) は、それらをすべて抽象化した回復座標であり、それ自体が物理的流量であるとは限らない。

したがって、非平衡熱力学との関係も、一般には G6-b までである。G6-c に進むには、具体的な stochastic thermodynamics model を取り、path probability ratio や entropy production の式を、§2 の \(B_n=L_n-R_n^{\mathrm{rec}}\) に明示的に埋め込む必要がある。これは自然な次段階だが、本稿の範囲外である。

ただし、NESS analogy に向かうためのより安全な中間段階として、定常維持と総生成量の bridge は別補論で切り出す。そこでは、定常分布の下では Core 型のネット構造変化 \(b_t\) の期待値が 0 になり、正の定常散逸や維持コストは \(b_t\) ではなく housekeeping cost \(C_t\) と総生成量 \(\Sigma_t=b_t+C_t\) 側に置く。この有限状態・定常分布レベルの guardrail は、Lean の `Survival.FiniteStateMarkovHousekeepingBridge` に対応する。さらに、定常分布が保たれていても detailed balance が破れて stationary current \(J(x,y)=\pi(x)K(x,y)-\pi(y)K(y,x)\) が非ゼロになりうることは、別の current bridge として `Survival.FiniteStateMarkovStationaryCurrent` に切り出す。そこでは三状態 deterministic cycle による `stationary_with_nonzero_current_witness` も与える。

その次の最小段階として、trajectory-level entropy production に必要な path probability ratio は、`Survival.FinitePathTrajectoryRatioBridge` に有限 path-ratio identity として切り出す。これは forward / reverse path PMF、reversal map、support guard、reverse-mass coverage を明示的に追加した場合にだけ、\(\sum P(\gamma)e^{-\sigma(\gamma)}=1\) 型の有限恒等式を得るものである。さらに `Survival.FiniteStateMarkovTrajectoryRatioBridge` では、この有限 identity を二つの有限状態 Markov data から作った path PMF と deterministic time reversal に特殊化する。`Survival.FinitePathStructuralObservableBridge` では、同じ path support 上に structural net \(B(\gamma)\)、housekeeping cost \(C(\gamma)\)、trajectory ratio \(\sigma(\gamma)\) を並べ、差を \(R(\gamma)=\sigma(\gamma)-(B(\gamma)+C(\gamma))\) として残差化する。最後に `Survival.FinitePathLocalDetailedBalanceBridge` では、system-boundary term と medium term を別データとして置き、local-detailed-balance residual が 0 のときだけ \(\sigma=S_{\mathrm{sys}}+S_{\mathrm{med}}\) と読めるようにする。したがって、これも entropy production や物理的 fluctuation theorem の証明ではなく、Core の \(B_n\) を path probability ratio と混同しないための形式的 bridge である。

7.4 Queueing theory と Lyapunov drift

既存理論の中で、構造持続の収支原理と最も直接に接続できるのは、queueing theory や Markov chain stability における Foster-Lyapunov drift 条件である。

確率過程 \(X_t\) と非負の Lyapunov 関数 \(W(X_t)\) を考える。通常の drift 条件は、たとえばある領域の外で
\[
  \mathbb E[W(X_{t+1})-W(X_t)\mid X_t]\le -\epsilon
\]
が成り立つ、という形を取る。これは、負のドリフトによって過程が高負荷状態から戻る傾向を述べる。

構造持続の収支原理側では、負荷座標を
\[
  Z_t := W(X_t)
\]
と置き、
\[
  b_t := Z_{t+1}-Z_t
\]
と定義する。このとき
\[
  B_n = \sum_{t=0}^{n-1} b_t = Z_n-Z_0
\]
であり、Foster-Lyapunov drift 条件はそのまま
\[
  \mathbb E[b_t\mid X_t]\le -\epsilon
\]
という recovery tendency に書き換えられる。

さらに、相対的な構造維持量を形式的に
\[
  R_t := e^{-Z_t}
\]
と置けば、
\[
  R_{t+1}=R_t e^{-b_t}
\]
となり、これは §2 の局所収支恒等式と同じ形である。

§2.2 の \(d_t,r_t\ge 0\) という二段階 sign convention に合わせて読むなら、\(Z_t\) の増加分を構造消耗量 \(d_t\)、減少分を回復量 \(r_t\) に分ければよい。その差し引きが、ここで直接定義した \(b_t=Z_{t+1}-Z_t\) に一致する。

この意味で、Lyapunov drift calculus は構造持続の収支原理の G6-c formal embedding として扱える。より正確には、任意の Lyapunov drift process は、\(Z_t\) を構造負荷、\(R_t=e^{-Z_t}\) を相対維持量と読むことで、構造持続の収支原理の期待値レベルの傾向層に埋め込める。この最小代数的埋め込みは、補論「構造持続の収支原理と Foster-Lyapunov ドリフトの形式的埋め込み」および Lean の `Survival.LyapunovBalanceEmbedding` で読者向け / machine-checked に記録されている。

ただし、符号は重要である。負荷または badness potential を
\[
  \phi(x)=-\log m(V_x)
\]
と置くなら、Core 型の一歩の純消耗量は
\[
  b(x,y)=\phi(y)-\phi(x)
       =-\log \frac{m(V_y)}{m(V_x)}
\]
である。したがって \(b>0\) は potential が増える方向、すなわち悪化
または崩壊傾向であり、Foster-Lyapunov 型の安定 drift は
\(\mathbb E[b\mid x]\le -\epsilon\) 側である。この sign guardrail は
Lean の `Survival.FosterLyapunovSignBridge` に切り出している。同 module は
positive recurrence を証明せず、`potentialIncrement`,
`expectedNetChange`, `OutsideSafeNegativeDrift`,
`EverywherePositiveDrift`, および stationary marginal で mean increment が
0 になる恒等式だけを固定する。

ただし、ここにも限界がある。queueing theory の安定性定理をそのまま構造持続の収支原理の定理として使うには、Markov 性、irreducibility、petite set、moment 条件など、元の theorem が要求する仮定を保持しなければならない。構造持続の収支原理がそれらを不要にするわけではない。したがって本稿が主張できるのは、drift 条件の形式的埋め込みであり、queueing stability theorem 全体の無条件な再証明ではない。

この接続は重要である。なぜなら、構造持続の収支原理が単なる熱力学的比喩ではなく、既存の確率過程安定性理論と同じ drift algebra を共有していることを示すからである。

7.5 確率制御との関係

確率制御では、制御入力 \(u_t\) によって状態遷移やコストを変え、ある Lyapunov 関数や value function の drift を望ましい向きに保つ。構造持続の収支原理で言えば、制御入力は回復量 \(r_t\) を変える作用として読める。
\[
  b_t(u_t)=d_t-r_t(u_t).
\]
このとき制御問題は、制約やコストのもとで
\[
  \mathbb E[b_t(u_t)]
\]
を小さく保つ、あるいは collapse threshold に達しないようにする問題として書ける。

対応は次のようになる。

| 確率制御 | 構造持続の収支原理 |
|---|---|
| control input $u_t$ | repair / support intervention |
| cost of control | recovery cost |
| Lyapunov drift | $\mathbb E[b_t]$ |
| safety constraint / barrier | collapse threshold $B_\theta$ |
| stabilizing policy | $\mathbb E[b_t]\le 0$ を保つ policy |

この correspondence は強い。しかし、本稿は最適制御問題を解くものではない。どの \(u_t\) が最適か、制御コストと repair 効果の trade-off がどうなるか、部分観測下でどの policy が実装可能かは、別の制御理論層に属する。

したがって、確率制御との関係は G6-b であり、具体的な制御モデルを定めれば G6-c に進める。M 補論の operational readout は、この制御問題へ進むための support-side input を与えるが、それ自体は最適制御定理ではない。

7.6 情報理論との関係

構造持続の収支原理は、情報理論とも深く関係する。理由は、中心量が対数比だからである。構造持続の最小形式では、加法性、単調性、正規化などの公理から、構造消耗量が
\[
  -\log \frac{m(V')}{m(V)}
\]
の形に一意化されることを示した。これは、Shannon 情報量や KL divergence が対数比から生じるのと同じ数学的背景を持つ。

また、SAT / Bernoulli-CSP の Chernoff-KL 出口では、MGF 最適化から Bernoulli relative entropy が現れる。これは、仕様固定レイヤーでは単なる比喩ではなく、Lean 上でも閉じた実際の情報理論的計算である。

符号理論側では、A06/A19 の BEC 線形符号復元に対して、消失集合 \(E\) と
消失列部分行列 \(H_E\) の rank が固定された後の exact accounting も
Lean 側に切り出されている。`Survival.LinearCodeErasureAccountingToy`
は、曖昧性次元
\[
a(E)=|E|-\operatorname{rank}(H_E)
\]
から、compatible multiplicity \(2^{a(E)}\)、distinguishable message-cell
mass の retained ratio \(2^{-a(E)}\)、および exact loss
\[
L_E=a(E)\log 2
\]
が出ることだけを形式化する。これは final erasure rank を予測特徴量に
することでも、低次 dependency pressure proxy の empirical support を
Lean で証明することでもない。

しかし、構造持続の収支原理は情報理論そのものではない。情報理論は、通信、符号化、不確実性、分布間距離を扱う。構造持続の収支原理は、事前固定された構造条件を維持できる状態集合の比を扱う。両者は対数比という共通形式を持つが、何を測っているかが異なる。

| 情報理論 | 構造持続の収支原理 |
|---|---|
| surprise / code length | 構造維持可能領域の対数構造消耗 |
| KL divergence | bad-event tail / Chernoff-KL profile で出現 |
| distribution over messages | 測度 $m$ または path measure |
| coding optimality | 本稿の主対象ではない |
| entropy of uncertainty | 構造維持可能性の残存量とは別物 |

したがって、情報理論との関係は G6-b が基本である。ただし、Bernoulli-CSP の Chernoff-KL 部分については、すでに G6-c に近い局所的な formal embedding がある。すなわち、bad-count lower-tail bound の出口が Bernoulli relative entropy として閉じることが、仕様固定レイヤーの定理鎖の一部になっている。

7.7 本稿の独自性: operational discipline

以上を見ると、構造持続の収支原理の多くの成分は既存理論にすでに現れている。対数比、ドリフト、回復、安定性、制御、KL bound は、いずれも古典的な道具である。

本稿の独自性は、それらの道具を発明したことではない。独自性は、次の operational discipline にある。

1. 対象となる構造条件を事前に固定する。
2. 構造維持可能集合 \(V\) または観測量 \(Y\) を事前に固定する。
3. 測度 \(m\)、時間地平、更新単位を事前に固定する。
4. 消耗側と回復側を同じ対数尺度または対応する観測指標で分ける。
5. 経路ごとの恒等式、期待値レベルの傾向、高確率境界、観測的予測を混同しない。
6. 仕様固定レイヤー / 推定レイヤーの主張強度を分ける。
7. universal law declaration を、独立再現と formal mapping なしに行わない。

この discipline によって、構造持続の収支原理は単なる比喩ではなくなる。どの構造条件について、何を構造消耗とし、何を回復とし、どの強度の主張をしているのかを、適用前に固定するからである。

逆に言えば、この discipline を外すと、構造持続の収支原理は空虚になる。後から都合のよい \(V\), \(m\), \(r_t\) を選べば、ほとんど任意の現象を説明できてしまう。本稿が繰り返し非主張を置くのは、その空虚化を避けるためである。

7.8 まとめ

既存理論との関係をまとめると次のようになる。

| 既存理論 | 接続強度 | 本稿での位置づけ |
|---|---|---|
| 熱力学第二法則 | G6-a / G6-b | closed loss-only と open recovery の強い analogy / correspondence |
| 非平衡熱力学・散逸構造 | G6-b | 外部流による維持という correspondence |
| queueing / Foster-Lyapunov drift | G6-c (minimal algebraic embedding) | $b_t=W(X_{t+1})-W(X_t)$ による formal embedding |
| 確率制御 | G6-b、具体モデルでは G6-c 可能 | $r_t(u_t)$ を制御入力として読む correspondence |
| 情報理論 | G6-b、Bernoulli-CSP では局所的 G6-c | 対数比と Chernoff-KL 出口 |

このうち queueing / Foster-Lyapunov drift は、G6-c の minimal algebraic embedding であると同時に、G4 v1 の primary non-CSP anchor でもある。これは double-counting ではない。G6 は既存理論との formal-mapping credibility を測る gate であり、G4 は非CSP domain coverage を測る gate である。同一の artifact が両方に寄与するのは、構造持続の収支原理の \(b_t,B_n,R_t,d_t,r_t\) が既存 drift calculus と自然に噛み合うことの帰結である。

この G4 v1 / v2 の読者向け整理は、補論「非CSP古典例における構造持続の収支原理の最小アンカー」に置く。そこでは queueing / Foster-Lyapunov を G4 v1 primary anchor、serial reliability と constant-fraction decay を回復量を含まない対照アンカーとして扱う。さらに G4 v2 として、repair / maintenance reliability-fatigue balance を追加し、`RepairMaintenanceBalance.lean` によって損傷量 \(d_t\) と回復量 \(r_t\) の差し引きが累積損傷、残余余白、相対維持量を決めることを形式化する。branching、fatigue、consensus、buckling、percolation は secondary / coverage skeleton として位置づける。

ここで強調すべきなのは、non-CSP 側の最も強い言い方は universal law declaration ではなく、**conditional law-side bridge** だという点である。すなわち、(i) 自然な測度または構造量 \(m\) が事前固定され、(ii) 回復量 \(r_t\) が domain-native な変数として観測でき、(iii) collapse / hitting boundary が明示的仮定の下で読める場合に限り、構造持続の収支原理は既存の stochastic stability theory の内部へ law-side に近い形で埋め込まれる。queueing / Foster-Lyapunov drift は現在この条件を最も強く満たす。一方、repair / maintenance balance は near-bridge repair-maintenance anchor であり、Backblaze や C-MAPSS の observational loss-only branches、LLM companion I / II はまだこの law-side bridge を閉じない。

この表から分かるように、構造持続の収支原理は既存理論の外に立つ完全に新しい数学ではない。むしろ、既存理論に散在する drift / recovery / log-ratio の構造を、構造維持可能性という対象に向けて再配置する枠組みである。

本稿の正確な位置づけは次である。

\begin{quote}
構造持続の収支原理は、熱力学や情報理論を置き換えるものではない。対象となる構造条件を事前固定したうえで、構造消耗量と回復量の差し引きが構造維持可能性をどう支配するかを記述する、cross-domain な drift-and-balance framework である。
\end{quote}

この位置づけにより、§5 の仕様固定レイヤー anchor、§6 の推定レイヤー anchor、そして本節の既存理論対応は、一つの階層に収まる。すなわち、仕様固定レイヤーでは formal theorem に近づき、推定レイヤーでは observational prediction に留まり、既存理論との関係では analogy / correspondence / formal reduction を明示的に分ける。


8. 限界と次段階

本稿は、構造持続理論を「構造消耗のみの収縮則」から「構造消耗量と回復量の収支原理」へ再配置した。しかし、この再配置は普遍法則の最終確立ではない。本節では、本稿で確定した部分、まだ条件つきまたは経験的にしか言えない部分、そして次に必要な gate を整理する。

8.1 本稿で確定した部分

本稿で確定したのは、次の階層である。

第一に、pathwise identity としての構造持続の収支原理である。読者向けの最小表示では、構造持続の最小核 \(S=Me^{-L}\) が、回復を含む形式では
\[
  S = M e^{-B}
\]
になる。構造維持可能集合 \(V^{(t)}\)、測度 \(m\)、収縮作用 \(K_t\)、再拡大作用 \(R_t\) が事前に固定され、対数比が well-defined なら、厳密な finite-prefix 表記として
\[
  b_t=d_t-r_t,
  \qquad
  B_n=\sum_{t<n}b_t,
  \qquad
  m(V^{(n)})=m(V^{(0)})e^{-B_n}
\]
が成り立つ。これは定義と望遠鏡積から従う恒等式である。

第二に、期待値レベルの傾向である。\(b_t\) を確率変数として扱えるなら、\(\mathbb E[b_t]\) の符号は、累積純消耗量の期待中心がどちらへ動くかを与える。これは high-probability collapse ではなく、中心の方向に関する主張である。

第三に、concentration 条件つきの finite-horizon bound である。bounded increments、MGF product、Chernoff / KL profile、margin 条件などが追加される場合には、collapse / stopped-collapse / hitting-time の確率境界へ進める。これは仕様固定レイヤー で強く閉じるが、推定レイヤーでは一般に得られない。

第四に、仕様固定レイヤー / 推定レイヤーの主張強度の分離である。仕様固定レイヤーは自然測度と exposure law があるため、formal theorem に近い。推定レイヤーは observable consumption / recovery indicator による prospective prediction の層であり、同じ強度の theorem ではない。

8.1.1 Lean で閉じている部分

本稿の経路ごとの代数核は、Lean 側では GeneralStateDynamics によってすでに machine-checked である。そこでは、収縮後集合、修復後集合、feasible mass、stage loss、stage gain、net consumption amount、cumulative net consumption が定義され、positive finite trajectory assumptions の下で
\[
  m(V^{(t+1)})=m(V^{(t)})e^{-b_t},
  \qquad
  m(V^{(n)})=m(V^{(0)})e^{-B_n}
\]
が証明されている。Lean 側の `StructuralPersistenceBalancePrinciple` は、この既存 theorem 群を本稿の読者向け名称で束ねる薄い wrapper であり、新しい数学的仮定を追加するものではない。

Lean 対応は次の範囲に限られる。表中の SBP は、Lean 側の `StructuralPersistenceBalancePrinciple` wrapper を表す。

| 本稿の主張 | Lean 側の対応 | 読み |
|---|---|---|
| local net amount | SBP net | local difference の定義として証明済み |
| cumulative amount | SBP cumulative | finite-prefix sum として証明済み |
| local identity | SBP local | positive mass assumptions の下で証明済み |
| 経路ごとの核 | SBP pathwise | positive finite trajectory assumptions の下で証明済み |
| loss-only 回収 | SBP loss-only | pure contraction / zero gain の特例として証明済み |
| Lyapunov embedding | SBP Lyapunov | 最小代数的埋め込みとして証明済み |
| repair balance | SBP repair | finite-prefix damage-minus-repair skeleton として証明済み |

ここでいう positive finite trajectory assumptions は、各段階の \(m(V^{(t)})\) と中間質量が正であり、対数比が well-defined であるという仮定である。この仮定は測度 \(m\) の自然性を証明するものではない。対象となる構造条件、測度 \(m\)、構造消耗量 \(d_t\)、回復量 \(r_t\) を各ドメインで事前固定できるかは、Lean ではなく運用上の gate である。

また、repair / maintenance 側の `margin` は \(B-D_n\) という remaining margin であり、構造持続の最小形式の資源項 \(M\) と同一ではない。この区別を消すと、finite-prefix damage balance と operational resource mapping が混同される。

したがって Lean が閉じているのは、構造持続の収支原理の代数核である。任意ドメインで自然な \(m\) が一意に定まること、\(r_t\) が観測可能であること、推定レイヤーの repair-like effects が因果機構として同定されること、あるいは構造持続の収支原理が普遍法則として確立したことは、Lean の主張範囲外である。

8.2 本稿が確定していない部分

本稿は、次を確定していない。

1. 構造持続理論が普遍法則として確立したとは主張しない。
2. あらゆるドメインで自然な \(V\), \(m\), \(d_t\), \(r_t\) が一意に定まるとは主張しない。
3. \(r_t\) の真値を 推定レイヤーの観測指標から直接測定できるとは主張しない。
4. 期待値レベルの傾向から high-probability bound が無条件に従うとは主張しない。
5. SAT / Bernoulli-CSP の finite-horizon bound が、SAT threshold theorem や solver dynamics 全体を説明するとは主張しない。
6. LLM companion I / II の repair-like effects が同一機構であるとは主張しない。
7. 観測された association を causal proof と呼ばない。
8. 熱力学、情報理論、queueing theory、確率制御を置き換えるとは主張しない。
9. 探索的に発見された構造条件、測度、構造消耗量、回復量の候補を、そのまま support と呼ばない。

これらは弱さの列挙ではなく、理論を空虚化しないための境界である。構造持続の収支原理は、どの層で何を仮定しているかを明示する限りで意味を持つ。

とくに、理論核と写像発見は分けて扱う。構造持続の収支原理の核は、事前固定された構造維持問題における構造消耗量と回復量の会計である。一方、現実ドメインでは、何を consumption indicator とし、何を recovery indicator とするかを探索的に発見する段階がある。この探索は許されるが、その結果は candidate mapping であって support ではない。support と呼べるのは、写像を凍結した後に、holdout / future / fresh archive / outside rerun で事前に定めた比較を通った場合に限られる。

8.3 反証可能性

本稿の枠組みは、次のような形で反証または制限される。

第一に、仕様固定レイヤーでは、drift-weighted coordinate が raw count や encoding-size baseline を上回らない独立 family が見つかれば、Bernoulli-CSP universality-class claim は弱まる。Exp43c q-coloring ではこの反証経路を実際に primary validation として検査し、`fm_plus_n` が raw / density / CNF-size baselines を上回った。したがって q-coloring は現在では positive support である。一方、Cardinality-SAT の threshold-local test はまだ draft / calibration-stage extension であり、validation evidence ではない。

第二に、推定レイヤーでは、consumption condition を揃えたうえで recovery indicator が観測量 \(Y\) を改善しない、または structure-aware model が quality-blind baseline を out-of-sample に上回らないなら、そのドメインでの \(R_{\mathrm{obs}}^{\mathrm{rec}}\) 読みは失敗する。より強い検査では、SP-only model が simple baseline を上回るだけでなく、既存専門モデルまたは強い domain baseline に構造持続指標を加えた baseline + SP が、domain baseline 単独を out-of-sample に改善するかを見る。ここで SP は structural persistence coordinate、すなわち本稿の consumption / recovery / margin 指標群を指す。構造持続の収支原理の経験的価値は、各ドメインの最強モデルを置き換えることではなく、既存予測枠組みに対して追加的な consumption / recovery 座標を与えることにある。したがって、外向けの価値は「凍結検証」そのものではなく、凍結された写像による予測力の増分検証である。

第三に、既存理論との対応では、formal reduction と呼んだものが元理論の仮定を保持していない、または単なる記号置換にすぎないと判明すれば、G6-c claim は G6-b correspondence へ下げなければならない。

第四に、測度 \(m\) や対象となる構造条件が凍結検証後に都合よく選ばれている場合、その適用は無効である。探索フェーズで候補写像を作ること自体は許されるが、support 判定に使う構造条件、測度、時間地平、観測量、metric、baseline は検証前に固定されていなければならない。凍結写像が失敗した場合、それは理論核の即時棄却ではなく、その写像の no-support または、そのドメインでは理論が黙るべき silence 判定として扱う。

8.4 次に重要な gate

本稿の後に重要なのは、次の gate である。

1. threshold-local 仕様固定レイヤー extension の継続。
   SAT / NAE mixed CSP の次に、Exp43c q-coloring は、drift-weighted / first-moment coordinate が raw edge count / density / encoding-size baseline を上回るかを検査し、primary validation として通過した。次に仕様固定レイヤーの幅をさらに広げる場合は、Exp44b Cardinality-SAT のような family で同じ基準を検査する。ただし、random CSP の sharp threshold を粗い grid で見る設計は避け、calibration / freeze / validation を分離した threshold-local protocol を維持する必要がある。Exp44b は現時点では draft / dry-run のみであり、primary 実行には calibration closeout と別途 freeze package が必要である。

2. G4 non-CSP anchors の次 iteration。
   queueing / Foster-Lyapunov drift の最小代数的埋め込みは、補論と Lean の LyapunovBalanceEmbedding によって G6-c iteration 1 として閉じている。これを受けて、G4 v1 では queueing / Foster-Lyapunov を primary anchor、serial reliability と constant-fraction decay を loss-only control anchors として置く。この G4 v1 package は補論「非CSP古典例における構造持続の収支原理の最小アンカー」に整理されている。さらに G4 v2 iteration 1 として、repair / maintenance reliability-fatigue balance を RepairMaintenanceBalance と同補論 §11 に整理した。次に進む場合は、positive recurrence / geometric ergodicity への G6-c iteration 2、stochastic reliability / optimal maintenance theorem への拡張、または maintenance log を用いた operational pilot を、明示的に scope lock する必要がある。

ここで reader-facing に追加された gate は、non-CSP domain を law-side に近い bridge と呼べる条件を明示することである。現在の program では、`analysis/law_side_upgrade_gate.md` がその 3 条件、すなわち自然な \(m\)、観測可能な \(r_t\)、条件つき collapse / hitting boundary を固定している。これに照らすと、queueing / Foster-Lyapunov は conditional law-side bridge、repair / maintenance balance は near-bridge repair-maintenance anchor、serial reliability と constant-fraction decay は loss-only controls、Backblaze / C-MAPSS / LLM companion は observational tier に留まる。この整理により、G4 / G6-c は “何でも収支語彙で言い換えられる” という弱い枠組みではなく、既存安定性理論にどこまで law-side に近づけるかを段階的に評価する gate として読める。
   loss-only observational 側では、Backblaze drive reliability に対する二つの frozen run が現在の reference point である。Q4 2025 v1 は高い ranking signal を持ちながら preregistered log-loss support を通らず、closed no-support となった。これに対して Q3 2025 v2 は、fresh untouched archive 上の calibration-aware same-domain redesign として separately frozen され、loss-only primary support を通った。ただし、これは same-domain second attempt の observational support であり、回復量 evidence でも、Q4 2025 no-support を erase する evidence でもない。したがって、現時点で増えたのは「non-CSP loss-only observational anchor が一つ立った」という事実であって、non-CSP empirical gate 全体が解けたわけではない。

3. Lean theorem map の reader-facing 整理。
   既存 Lean theorem がどの paper claim を支えるかを、命名、表、wrapper theorem として読みやすくする。新 theorem を増やすことより、主張と仮定の対応を明確にすることが重要である。

4. 推定レイヤーの新規 prospective test。
   scope-as-repair や dependency-aware repair が、別タスク・別モデル・別ドメインでも baseline を上回るかを事前登録で検査する。

5. independent replication。
   Level 3 universal-law credibility には、内部再現だけでは足りない。外部研究者による再現、批判、失敗例の報告が必要である。
   現時点では Mixed-CSP について、3 名の外部実行者が同一 frozen package を再実行し、3/3 clean success を返している。これは Mixed-CSP package に限れば requested outside-group rerun set の完了であり、G7 replication gate に対する大きな前進である。さらに Exp43c q-coloring についても、3 名の外部実行者が同一 frozen package を再実行し、それぞれ 4,000 行、checked core mismatches 0、TIMEOUT 0、MALFORMED 0、および同じ qualitative support decision を返している。したがって仕様固定レイヤーでは、二つの frozen package について著者環境外の再実行成功が得られている。ただし、これはプログラム全体の replication 完了ではなく、non-CSP branch、observational branch、および追加の独立 review は別の gate として残る。

8.5 統合版との関係

本稿は、統合版と主論文「構造持続の収支原理」の背後にある詳細展開として読む。従来は、構造持続の最小形式と条件つき導出の loss-only 形式から、LLM companion I / II の LLM / 継続学習応用へ進む読み方が中心であった。

構造持続の収支原理を中心に置くなら、依存順は次のようになる。

1. 構造持続の最小形式: 回復を明示しない最小核。
2. 構造持続の収支原理: 構造消耗量と回復量を含む主原理。
3. 条件つき導出補論: 条件つき導出と弱依存境界。
4. 仕様固定レイヤー補論群: SAT / Bernoulli-CSP / Mixed-CSP / Exp43c q-coloring、および Cardinality-SAT などの proposed stress extensions。
5. G4 非CSP補論群: queueing / reliability / decay / repair-maintenance による古典例への最小埋め込み。
6. LLM companion I / II: 推定レイヤー observational anchors。
7. M 補論: \(r_t\) や回復能力を実ドメインで測る operational mapping。

この順序により、M 分解は universal core ではなく、構造持続の収支原理を現実ドメインへ写すための測定層として位置づく。

8.6 結論

本稿の中心主張は、回復を含む構造系では、構造消耗量そのものではなく、構造消耗量と回復量の収支が構造維持可能性を支配する、ということである。読者向けの看板式は
\[
  S = M e^{-B},
  \qquad
  B=\sum_t(d_t-r_t)
\]
である。厳密な finite-prefix 表記では
\[
  b_t=d_t-r_t,
  \qquad
  B_n=\sum_{t<n}b_t,
  \qquad
  m(V^{(n)})=m(V^{(0)})e^{-B_n}.
\]

この式は、構造持続の最小核を \(r_t=0\) の特例として回収し、回復を含む場合には回復量 \(r_t\) によって崩壊、維持、回復の三 regime を同じ座標上で扱う。期待値レベルでは \(\mathbb E[b_t]\) の符号が傾向を与え、追加の concentration 条件があれば finite-horizon collapse / hitting-time bound へ進める。

仕様固定レイヤーでは、SAT / Bernoulli-CSP / Mixed-CSP / Exp43c q-coloring が、自然測度と bad-event exposure の上でこの構造を強く閉じる。Cardinality-SAT は、この幅をさらに広げるための proposed stress extension であり、現時点では Exp44 no-go history と Exp44b draft / dry-run を持つ validation candidate に留まる。推定レイヤーでは、LLM companion I / II の scope-as-repair、external metabolism、dependency-aware replay が、回復量の observable indicator として働く。ただし、推定レイヤーは high-probability theorem ではなく、observational prediction の層である。

既存理論との関係では、熱力学や情報理論とは analogy / correspondence を持ち、queueing / Lyapunov drift とは最小代数的な formal embedding を持つ。さらに、serial reliability と constant-fraction decay は回復量を含まない指数核の非CSP対照アンカーとして働き、repair / maintenance balance は回復量 \(r_t\) を非CSP repair-maintenance anchor として明示する。しかし、本稿はこれらを置き換えない。本稿の役割は、対象となる構造条件を事前固定したうえで、何が構造を削り、何がそれを補い、どの収支を越えると崩壊へ向かうかを、一つのドリフトと収支の枠組みとして記述することである。

この枠組みは、設計原理としても読める。すなわち、崩壊しない系を無条件に作るのではなく、崩壊しにくく、改修可能性を失いにくく、局所的に修復できる系を作るための会計座標である。具体的には、構造消耗を局所化し、回復量を残し、margin を使い切らず、代替経路を保持する。ソフトウェア工学の冗長性、クリーンアーキテクチャ、rollback、observability は、この設計原理の一つの実践例として読めるが、それを別ドメインへ移す場合は candidate intervention として扱い、凍結検証によってのみ support とする。

この非CSP側の最も強い安全な言い方は、queueing / Foster-Lyapunov drift を中心とする restricted drift-based stability class における **conditional law-side bridge** である。これは、構造持続の収支原理が一般 non-CSP universal law だと言うことではない。むしろ、自然な \(m\)、観測可能な \(r_t\)、条件つき collapse / hitting boundary が揃う限定クラスでは、構造持続の収支原理が既存安定性理論の内部に law-side に近い形で埋め込まれる、と言うのである。Repair / maintenance balance は、その class を empirical \(r_t\) 側へ広げる near-bridge repair-maintenance anchor である。

非CSP empirical 側では、Backblaze v2 が calibration-aware loss-only design として same-domain observational support を与えた一方、Backblaze v1 は closed no-support のまま残っている。この組は、構造持続の収支原理の loss-only operationalization が industrial reliability domain でも観測可能であることを示すが、その証拠の重みは仕様固定レイヤー primary や独立再現と同じではない。ここで重要なのは、v1 を消すことではなく、calibration を明示した frozen redesign が fresh archive では通りうることを記録することである。

したがって、本稿は普遍法則の最終宣言ではない。より正確には、構造持続理論を universal-law candidate として強化するための主理論層である。Exp43c q-coloring により、SAT 以外に見える仕様固定レイヤー family への幅は一段広がった。また、Mixed-CSP package については、3 名の外部実行者による独立再実行が 3/3 clean success を返しており、Exp43c q-coloring package についても、3 名の外部実行者による独立再実行が 3/3 clean success を返している。したがって仕様固定レイヤーでは、二つの frozen package で著者環境外でも qualitative support decision が再現されることを示している。今後の決定的な進展は、さらなる異質 family、追加の独立 review、non-CSP formal embedding、および推定レイヤーの前向き検査によって与えられる。
