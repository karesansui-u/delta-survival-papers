# 構造収支律と Foster-Lyapunov drift の形式的埋め込み

Status: G6-c draft. Not a final paper section, not a Lean theorem, and not a
replacement for Foster-Lyapunov / queueing stability theory.

Date: 2026-04-23

## 1. 目的

本 draft の目的は、構造収支律が既存理論と単に「似ている」のではなく、少なくとも一つの古典的 drift calculus を構造収支律の変数へ形式的に埋め込めることを示すことである。

対象にするのは、離散時間の Foster-Lyapunov drift 条件である。確率過程 \(X_t\) と非負関数 \(W\) に対して、
\[
  \mathbb E[W(X_{t+1})-W(X_t)\mid X_t]\le -\epsilon
\]
のような負の drift 条件が成り立つとき、過程は高負荷状態から戻る傾向を持つ。

構造収支律側では、この \(W(X_t)\) を構造負荷 \(Z_t\) と読み替え、一段の差分を正味作用
\[
  a_t=Z_{t+1}-Z_t
\]
と置く。すると、Foster-Lyapunov drift 条件はそのまま
\[
  \mathbb E[a_t\mid X_t]\le -\epsilon
\]
という recovery tendency になる。

この対応は G6-c formal embedding の候補である。理由は、語彙の類似ではなく、累積作用と指数的維持量の恒等式が同じ形で書けるからである。

## 2. G6-a/b/c の中での位置

本稿群では、既存理論との接続を三段階に分けている。

| level | 内容 | 本 draft での扱い |
|---|---|---|
| G6-a analogy | 直感や語彙が似ている | 目的ではない |
| G6-b correspondence | 量と符号の対応表が作れる | §6 で明示する |
| G6-c formal embedding | 既存の drift / balance 条件が構造収支律の変数へ埋め込める | 本 draft の中心 |

ただし、G6-c と言っても、既存の安定性定理を無条件に再証明するという意味ではない。Markov 性、irreducibility、小集合条件、petite set、moment 条件など、元の theorem が必要とする仮定はそのまま継承される。

本 draft が主張するのは、次の限定された命題である。

\begin{quote}
Foster-Lyapunov drift calculus の負荷差分は、構造収支律の正味作用 \(a_t\) として読める。したがって、その expectation-level drift 条件は、構造収支律の recovery / collapse tendency の特例として埋め込める。
\end{quote}

## 3. 最小埋め込み

離散時間過程 \(X_t\) と非負関数 \(W\colon \mathcal X\to [0,\infty)\) を考える。構造負荷を
\[
  Z_t:=W(X_t)
\]
と定義する。

一段の正味作用を
\[
  a_t:=Z_{t+1}-Z_t
\]
と置く。累積作用は
\[
  A_n:=\sum_{t=0}^{n-1}a_t
\]
である。

このとき、望遠鏡和により
\[
  A_n
  =
  \sum_{t=0}^{n-1}(Z_{t+1}-Z_t)
  =
  Z_n-Z_0.
\]

これは構造収支律の累積正味作用と同じ形式である。\(Z_t\) が増えると、構造負荷が増える。\(Z_t\) が減ると、補償または回復が勝っている。

## 4. 指数的維持量

構造維持の相対量を
\[
  R_t:=e^{-Z_t}
\]
と定義する。

すると、
\[
  R_{t+1}
  =
  e^{-Z_{t+1}}
  =
  e^{-Z_t}e^{-(Z_{t+1}-Z_t)}
  =
  R_t e^{-a_t}.
\]

したがって、局所更新は
\[
  R_{t+1}=R_t e^{-a_t}
\]
である。

これは、構造収支律の
\[
  m(V^{(t+1)})=m(V^{(t)})e^{-a_t}
\]
と同じ algebraic shape を持つ。ただしここでの \(R_t\) は、実際の feasible set measure そのものではなく、Lyapunov 負荷から作った相対的維持座標である。この違いは明示しておく必要がある。

## 5. \(\ell_t,g_t\) への分解

構造収支律の標準形では、一段の作用を
\[
  a_t=\ell_t-g_t
\]
と書く。ここで \(\ell_t\ge 0\) は損失流、\(g_t\ge 0\) は補償流である。

Lyapunov 差分 \(\Delta Z_t:=Z_{t+1}-Z_t\) から、次のように分解できる。
\[
  \ell_t := (\Delta Z_t)^+,
  \qquad
  g_t := (-\Delta Z_t)^+,
\]
ただし \(x^+=\max(x,0)\) である。

このとき
\[
  \ell_t-g_t
  =
  (\Delta Z_t)^+ - (-\Delta Z_t)^+
  =
  \Delta Z_t
  =
  a_t.
\]

したがって、負荷が増えるステップは loss flow として、負荷が減るステップは compensation / recovery flow として読める。

この読み替えは、物理的資源流を同定したという意味ではない。あくまで、Lyapunov 負荷の増減を構造収支律の符号つき作用へ写す最小的な分解である。

## 6. Drift regime の対応

Foster-Lyapunov 条件は、\(a_t\) の条件付き期待値の符号として読める。

| Foster-Lyapunov 側 | 構造収支律側 | 読み |
|---|---|---|
| \(\mathbb E[Z_{t+1}-Z_t\mid X_t]\le -\epsilon\) | \(\mathbb E[a_t\mid X_t]\le -\epsilon\) | recovery tendency |
| \(\mathbb E[Z_{t+1}-Z_t\mid X_t]\approx 0\) | \(\mathbb E[a_t\mid X_t]\approx 0\) | maintenance regime |
| \(\mathbb E[Z_{t+1}-Z_t\mid X_t]\ge \epsilon\) | \(\mathbb E[a_t\mid X_t]\ge \epsilon\) | overload / collapse tendency |

ここで重要なのは、構造収支律が drift theorem を置き換えるのではなく、drift theorem が扱う負荷差分を構造収支律の \(a_t\) として読む点である。

したがって、G6-c としての主張は次の形になる。

\begin{quote}
Foster-Lyapunov drift 条件は、構造負荷 \(Z_t=W(X_t)\) を用いることで、構造収支律の expectation-level tendency の特例として埋め込める。
\end{quote}

## 7. Queueing fluid skeleton

既存 Lean file `Survival.QueueStability` は、反射境界を持つ完全な stochastic queue ではなく、決定論的 fluid skeleton を扱う。

到着率を \(\lambda\)、サービス率を \(\mu\)、初期 backlog を \(Z_0\) とする。backlog は
\[
  Z_n=Z_0+n(\lambda-\mu)
\]
である。

このとき一段の正味作用は
\[
  a_t=Z_{t+1}-Z_t=\lambda-\mu
\]
で一定である。

したがって、
\[
  A_n=n(\lambda-\mu),
  \qquad
  Z_n=Z_0+A_n.
\]

三つの regime は次のように分かれる。

| 条件 | \(a_t\) | 構造収支律の読み |
|---|---:|---|
| \(\lambda<\mu\) | \(a_t<0\) | service が arrival を上回り、recovery tendency |
| \(\lambda=\mu\) | \(a_t=0\) | critical / maintenance boundary |
| \(\lambda>\mu\) | \(a_t>0\) | excess demand が累積し、overload tendency |

有限閾値 \(B\) を置けば、
\[
  Z_n\ge B
\]
は overload threshold event である。Lean 側では、これは `ThresholdExceeded` として skeleton 化されている。

この例は小さいが、G6-c にとって重要である。なぜなら、構造収支律の \(a_t=\ell_t-g_t\) が、queueing の arrival minus service という古典的 balance と同じ符号構造を持つことを示すからである。

## 8. theorem assumption の継承

ここで最も重要な注意は、仮定の継承である。

Foster-Lyapunov theorem は通常、単なる代数恒等式だけでは成立しない。たとえば、次のような仮定が必要になる。

1. Markov 性。
2. 状態空間の可測構造。
3. irreducibility。
4. small set / petite set 条件。
5. moment 条件。
6. drift 条件が成り立つ領域の指定。
7. 再帰性や正再帰性を結論するための追加条件。

構造収支律への埋め込みは、これらの仮定を消さない。したがって、正しい言い方は
\[
  \text{Foster-Lyapunov theorem の仮定を満たすなら、その drift 部分は構造収支律へ埋め込める}
\]
であり、
\[
  \text{構造収支律だけから queueing stability が無条件に従う}
\]
ではない。

この discipline を守ることで、G6-c は「既存理論の再発見」や「仮定の隠蔽」ではなく、既存理論との形式的接続として読める。

## 9. この埋め込みが与えるもの

この G6-c draft が与える価値は三つある。

第一に、構造収支律が熱力学的比喩だけではなく、既存の確率過程安定性理論と同じ drift algebra を共有していることを示す。

第二に、Route A CSP calibration とは別の方向で、構造収支律の generality を強化する。random CSP の threshold-local grid に依存せず、負荷、補償、回復、過負荷という語彙を既存の安定性理論へ接続できる。

第三に、次の G4 non-CSP anchor を選ぶ基準を与える。すなわち、queueing、reliability、branching process、population dynamics などは、いずれも \(Z_t\), \(a_t\), \(A_n\), \(R_t\) の形に落とせるかどうかで比較できる。

## 10. この埋め込みが与えないもの

本 draft は、次を主張しない。

1. 構造収支律が Foster-Lyapunov theorem を置き換える。
2. queueing stability theorem を新たに証明した。
3. positive recurrence が構造収支律だけから従う。
4. 任意の開いた構造系が Markov chain stability 問題である。
5. 物理的な資源流 \(g_t\) が Lyapunov 負荷の減少と一意に同定される。
6. continuous-time generator や stochastic thermodynamics まで同時に扱った。
7. G6-c が成立したので universal law が確立した。

本 draft の主張は限定的である。

\begin{quote}
Foster-Lyapunov drift calculus は、構造収支律の expectation-level tendency 層へ形式的に埋め込める。その際、既存 theorem の仮定は保存される。
\end{quote}

## 11. 次の作業

次の選択肢は二つある。

第一に、この draft を補論化する。候補名は
\[
  \text{補論\_構造収支律とFoster-Lyapunovドリフトの形式的埋め込み}
\]
である。これは G6-c の reader-facing artifact になる。

第二に、Lean 側に軽量 file を追加する。候補は `Survival/LyapunovBalanceEmbedding.lean` である。最小 theorem は次でよい。

1. \(A_n = Z_n-Z_0\) の telescoping。
2. \(R_{t+1}=R_t e^{-a_t}\) の局所恒等式。
3. \(a_t=\ell_t-g_t\) の positive / negative part decomposition。
4. `QueueStability.lean` の `excessDemand` を \(a_t\) として読む wrapper。

ただし Lean 化は必須ではない。まず prose draft として G6-c の scope と claim を固定し、その後に Lean theorem map へ接続する順序が安全である。
