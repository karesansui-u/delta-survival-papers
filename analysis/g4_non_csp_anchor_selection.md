# G4 Non-CSP Anchor Selection

Status: selection memo for the next non-CSP anchor layer.

Date: 2026-04-23

## 1. Purpose

G4 の目的は、構造収支律が SAT / Bernoulli-CSP / Mixed-CSP の内部だけで閉じた理論ではなく、古典的な非CSP系にも歪めず写ることを示すことである。

ただし、G4 は新しい queueing theorem や reliability theorem を主張する場ではない。既存分野の定理を置き換えるのではなく、構造収支律の語彙
\[
  Z_t,\quad a_t,\quad A_n,\quad R_t,\quad \ell_t,\quad g_t
\]
へ、どの古典例が最も自然に写るかを選ぶ。

この memo の結論は次である。

\begin{quote}
G4 v1 の主 anchor は queueing / Foster-Lyapunov drift とする。
Serial reliability と constant-fraction decay は loss-only control anchor として添える。
\end{quote}

この組み合わせにより、open-system balance と closed/loss-only exponential kernel の両方を non-CSP 側で見せられる。


## 2. Selection Criteria

候補を次の基準で評価する。

| criterion | 内容 |
|---|---|
| C1. balance-law fit | \(a_t=\ell_t-g_t\), \(A_n\), \(R_t=e^{-Z_t}\) へ自然に写るか |
| C2. Lean-backed | 既存 Lean theorem が reader-facing claim を支えるか |
| C3. non-CSP distance | SAT / CSP から十分に離れて見えるか |
| C4. theorem humility | 既存分野の強い theorem を過剰に再主張せずに済むか |
| C5. next-step value | 次の G4 / G6 / empirical anchor を選ぶ基準になるか |

G4 では C1 と C2 を最重視する。C3 は rhetorical value、C4 は overclaim 防止、C5 は研究戦略上の価値である。


## 3. Candidate Summary

| candidate | Lean file | fit | status |
|---|---|---|---|
| queueing / Foster-Lyapunov drift | `QueueStability.lean`, `LyapunovBalanceEmbedding.lean` | \(a_t\) が excess demand / Lyapunov increment として直接出る | primary G4 v1 anchor |
| serial reliability | `SerialReliability.lean` | \(R=\prod p_i=\exp(-L)\) の loss-only kernel | loss-only control anchor |
| constant-fraction decay | `ConstantFractionDecay.lean` | \(q^n=\exp(-n(-\log q))\) の textbook exponential kernel | loss-only control anchor |
| branching expectation | `BranchingProcessExtinction.lean` | subcritical mean \(m^n\) を exponential loss として読む | secondary; expectation-level only |
| fatigue / consensus cumulative thresholds | `FatigueDamage.lean`, `ConsensusFaultThreshold.lean` | cumulative load / fault threshold | useful but threshold-only |
| buckling / percolation critical thresholds | `BucklingThreshold.lean`, `PercolationThreshold.lean` | control parameter crosses critical value | useful but currently too thin |


## 4. Recommended G4 v1 Package

### 4.1 Primary: Queueing / Foster-Lyapunov Drift

Queueing / Foster-Lyapunov を主 anchor にする理由は、構造収支律の open-system balance と最も直接に対応するからである。

`QueueStability.lean` では、deterministic fluid skeleton として
\[
  \mathrm{backlog}_n
  =
  \mathrm{initial}
  +
  n(\lambda-\mu)
\]
が形式化されている。ここで
\[
  a_t=\lambda-\mu
\]
と読める。到着率がサービス率を上回れば overload tendency、サービス率が到着率を上回れば recovery tendency である。

さらに `LyapunovBalanceEmbedding.lean` では、任意の load sequence \(Z_t\) に対して
\[
  a_t=Z_{t+1}-Z_t,\qquad
  A_n=Z_n-Z_0,\qquad
  R_{t+1}=R_t e^{-a_t}
\]
を形式化している。これにより、queueing / Foster-Lyapunov drift は G6-c iteration 1 と G4 の交点になる。

これは double-counting ではない。G6 は既存理論との formal-mapping credibility を測る gate であり、G4 は non-CSP domain coverage を測る gate である。同一の artifact が両 dimension に寄与するのは、埋め込みが自然であることの帰結であり、二重に evidence を数えるという意味ではない。

この anchor が言えること:

- \(a_t\) が古典的な excess demand / Lyapunov increment と一致する。
- overload / maintenance / recovery の三 regime が \(\mathbb E[a_t]\) または deterministic \(a_t\) の符号として読める。
- 構造収支律は、open-system stability theory と同じ drift algebra を共有する。

この anchor が言えないこと:

- positive recurrence が構造収支律だけから従う。
- reflected stochastic queue の安定性定理を新たに証明した。
- geometric ergodicity や \(R_n\le R_0e^{-cn}\) 型境界を得た。

したがって、queueing / Foster-Lyapunov は G4 v1 の主 anchor として最も強いが、主張は minimal algebraic embedding に限定する。


### 4.2 Control Anchor: Serial Reliability

Serial reliability は、loss-only kernel の non-CSP control として置く。

`SerialReliability.lean` では、直列系の信頼度
\[
  R_n=\prod_{i<n}p_i
\]
と累積損失
\[
  L_n=\sum_{i<n}-\log p_i
\]
に対して
\[
  R_n=\exp(-L_n)
\]
が形式化されている。

これは Paper 1 / Paper 2 の loss-only kernel が、SAT ではなく信頼性工学の textbook model にもそのまま現れることを示す。open-system compensation \(g_t\) は出ないが、closed / loss-only control として非常に読みやすい。

G4 v1 では、serial reliability を primary anchor にしない。理由は、構造収支律の新しい要素である補償流 \(g_t\) や recovery tendency を含まないからである。しかし、queueing anchor と並べることで、

\[
  \text{loss-only exponential kernel}
  \quad\text{and}\quad
  \text{open-system drift balance}
\]

の両方を non-CSP 側で示せる。


### 4.3 Control Anchor: Constant-Fraction Decay

Constant-fraction decay は、放射性崩壊、Beer-Lambert attenuation、一次反応、一次薬物動態などを同じ有限 prefix skeleton で読むための control anchor である。

`ConstantFractionDecay.lean` では、各 step で \(q\) が残るとき
\[
  q^n=\exp(-n(-\log q))
\]
が形式化されている。

これは非常に古典的で、数学的新規性はない。しかし、その古典性が利点でもある。構造収支律の指数核が、CSP や LLM 固有の構文ではなく、既存の textbook exponential decay と同じ log-ratio algebra を共有することを示す。

G4 v1 では、constant-fraction decay を serial reliability と同じく control anchor とする。


## 5. Why Not Make Branching / Fatigue / Percolation Primary Yet?

### Branching Process

`BranchingProcessExtinction.lean` は subcritical / critical branching process の expectation-level skeleton を与える。

これは non-CSP として魅力的だが、現時点では almost-sure extinction theorem ではない。期待値レベルの \(m^n\) skeleton であり、強い branching-process theorem へ進むには追加の確率論が必要である。

したがって、G4 v1 では secondary とする。

### Fatigue / Consensus

`FatigueDamage.lean` と `ConsensusFaultThreshold.lean` は累積 damage / fault count の閾値 skeleton としてよくできている。

ただし、現時点では
\[
  \sum d_i \ge C
\]
型の threshold bookkeeping であり、構造収支律の \(R_t=e^{-Z_t}\) や \(a_t=\ell_t-g_t\) との接続は queueing ほど強くない。

したがって、G4 v1 の primary にはしない。後続の G4 v2 で、repair / maintenance intervention を含めた richer model に拡張する候補である。

### Buckling / Percolation

`BucklingThreshold.lean` と `PercolationThreshold.lean` は critical-parameter skeleton として有用である。

しかし、現時点では既存理論の本体、たとえば Euler buckling theorem や percolation theorem を扱っていない。critical parameter に到達する finite-prefix control skeleton であり、G4 の射程確認としては良いが、primary anchor にすると overclaim の危険がある。

したがって、G4 v1 では coverage skeleton に留める。


## 6. Recommended Wording

G4 v1 の正しい言い方:

\begin{quote}
構造収支律は、非CSP古典例のうち、少なくとも queueing / Foster-Lyapunov drift に対して、\(a_t,A_n,R_t,\ell_t,g_t\) の最小代数的埋め込みを持つ。Serial reliability と constant-fraction decay は、同じ log-ratio exponential kernel が loss-only non-CSP 系にも現れることを示す control anchors である。
\end{quote}

避けるべき言い方:

- 構造収支律が queueing stability theorem を証明した。
- 構造収支律が信頼性理論や分岐過程を置き換える。
- non-CSP skeletons が full empirical validation である。
- percolation / buckling の本格的 threshold theorem が Lean 化済みである。


## 7. Next Work

G4 v1 の次作業は、次の順で進めるのがよい。

1. Paper 5 §7 / §8 と G6-c 補論から、queueing / Foster-Lyapunov を primary non-CSP anchor として明示する。これは `v2/5_構造持続の収支法則と崩壊傾向.md` と `v2/補論_非CSP古典例における構造収支律の最小アンカー.md` に反映済みである。
2. `SerialReliability.lean` と `ConstantFractionDecay.lean` を loss-only control anchors として theorem map にまとめる。これは `lean/PAPER_MAPPING.md` の C2 / C3 と README の formalization section に反映済みである。
3. G4 v2 では、branching expectation から almost-sure extinction 方向へ進むか、fatigue / reliability の repair intervention を含む open-system model へ進むかを選ぶ。

この時点で G4 は「non-CSP 古典例をすべて証明した」ではなく、「次に見るべき non-CSP anchor の優先順位が G6-c embedding によって決まった」と読む。
