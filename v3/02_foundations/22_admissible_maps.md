補論_構造持続における許容写像と階層的不変量
構造持続における許容写像と階層的不変量
— 構造共変性・粗視化欠損・限定クラス普遍性 —

要旨

本補論は、構造持続理論における「保存される量」「許容される構造粒度変換」「自然なドメインクラス」の関係を整理する。目的は、構造持続理論を直ちに単一の普遍法則として宣言することではない。むしろ、どの写像のもとで何が不変であり、どの写像のもとで何が共変し、どの写像では欠損項や誤差境界を持ち、どの写像では観測・推定指標による凍結検証に降りるべきかを明確にすることである。

中心となる見方は、構造維持問題を対象とし、その間の写像を許容写像として扱うことである。名前変更や測度保存同型では累積純消耗量 \(B_n\) は不変である。測度比を正の冪で読み替えるようなゲージ変更では \(B_n\) は正の定数倍として共変する。粗視化や観測指標による推定では一般に不変性は失われるため、許容条件、誤差境界、または凍結後の予測力検証が必要になる。

この整理により、仕様固定構造層、条件付き構造埋め込み層、構造推定層は、強弱の直線的序列ではなく、観測可能性と許容写像の違いとして読める。Bernoulli-CSP class も、SAT 風の構文を後から集めたものではなく、iid bad-event exposure と log-drift を保つテンプレート保存写像で閉じた仕様固定構造層の限定クラスとして位置づけられる。


1. 問い

構造持続理論が第二法則級の方向へ進むには、少なくとも三つの問いが残る。

第一に、どの量が保存量または単調量の候補なのか。

第二に、どの構造粒度変換を許容してよいのか。

第三に、Bernoulli-CSP のような限定クラスは、なぜ自然なクラスと言えるのか。

本補論の立場では、これらは独立した三問題ではない。むしろ、どの許容写像に対する不変量または共変量を求めるのかがまだ明示されていなかった、という一つの問題の三つの側面である。

したがって、本補論の問いは次である。

構造維持問題の間にどのような写像を許し、その写像のもとで \(B_n\)、\(\Sigma_n\)、drift、collapse boundary は、不変・共変・欠損項つき・誤差境界つき・検証対象のどれとして扱われるのか。


2. 構造維持問題を対象として見る

構造維持問題を
\[
  \Pi = (X,m,V^{(0)},K_t,R_t,T)
\]
と書く。ここで \(X\) は状態空間、\(m\) は比較に用いる質量モデル、\(V^{(0)}\) は初期構造維持可能集合、\(K_t\) は構造維持可能領域を削る作用、\(R_t\) は再拡大作用、\(T\) は時間地平である。

Paper 1 の loss-only 核だけを見るなら、列 \(\{V^{(t)}\}\) だけで十分である。しかし Paper 2 の収支原理を扱うには、消耗後・回復前の中間集合 \(V_t^-\) が必要になる。したがって本補論では、二段階更新
\[
  V^{(t)} \longrightarrow V_t^- \longrightarrow V^{(t+1)}
\]
を構造維持問題の読みに含める。\(K_t,R_t\) は単なる付属物ではなく、消耗量 \(d_t\) と回復量 \(r_t\) を分けるための readout structure である。

この問題から、各時刻の構造維持可能集合
\[
  V^{(t)}
\]
と中間集合
\[
  V_t^- := K_t(V^{(t)})
\]
が定まる。正かつ有限の質量が保たれる範囲では、
\[
  d_t := -\log \frac{m(V_t^-)}{m(V^{(t)})},
  \qquad
  r_t := \log \frac{m(V^{(t+1)})}{m(V_t^-)}
\]
を定義できる。純消耗量は
\[
  b_t := d_t-r_t
\]
であり、累積純消耗量は
\[
  B_n(\Pi) := \sum_{t<n} b_t
\]
である。

ここで \(B_n\) は一般には非負量ではない。回復優位の区間では \(b_t<0\) となり、累積純消耗量も負になりうる。したがって target は単純な \(\mathbb{R}_{\ge0}\) ではなく、符号つきの実数的 readout として扱う方が自然である。

構造維持問題の間の写像
\[
  \Psi:\Pi\to\Pi'
\]
は、単なる状態空間写像ではない。構造、質量比、時刻、消耗・回復の読み方をどこまで保つかを含む。したがって、本補論では「写像」を次の四段階に分ける。

1. 同型写像。
2. ゲージ変更。
3. 粗視化。
4. 観測指標による推定。

この四段階は、どの量を定理として保てるかを決める。

圏論的に言えば、構造維持問題を対象、上の写像を射として扱う。ただし、本補論は \(B_n\) が全ての許容写像上で一つの通常の関手になる、と主張しない。むしろ、射の部分クラスごとに \(B_n\) が不変量、共変量、欠損項つき量、境界つき量、検証対象のどれになるかを分ける。ここで必要なのは、圏論の重い装置ではなく、次の最小事実である。

| 要件 | 意味 |
|---|---|
| 恒等射 | 同じ構造維持問題をそのまま読む写像がある |
| 合成 | 二つの許容写像を続けて適用したとき、どの種類の写像として残るかを問える |
| 射の部分クラス | 同型、ゲージ、粗視化、観測指標による推定を区別できる |
| 量の振る舞い | 累積純消耗量、総生成量、drift、collapse boundary が不変・共変・欠損項つき・境界つき・検証対象のどれになるかを分けられる |

この意味で、構造持続理論で必要なのは群ではなく圏である。群は可逆変換を中心に置くが、構造持続で重要な粗視化、射影、忘却、観測指標による推定は多くの場合非可逆である。非可逆な写像を外に追い出すと、構造推定層や operational content が理論の外へ落ちてしまう。

したがって、本補論では「不変量」を同型写像に対して、「共変量」をゲージ変更に対して、「欠損項または条件つき単調性」を粗視化に対して、「誤差境界」を確率テンプレートに対して、「support 判定」を観測指標による推定に対して置く。この分担が、階層的不変量という語の意味である。より正確には、階層的不変量とは、不変・共変・欠損項・境界・検証対象の階層である。


3. 同型不変性

同型写像とは、二つの構造維持問題が同じ問題の別表現である場合である。たとえば、状態名の変更、変数名の変更、同じ質量比を保つ可測同型などがこれに含まれる。

命題 1（同型不変性）。
二つの構造維持問題 \(\Pi,\Pi'\) について、すべての \(t<T\) で
\[
  \frac{m'(V_t^{\prime -})}{m'(V^{\prime(t)})}
  =
  \frac{m(V_t^-)}{m(V^{(t)})}
\]
かつ
\[
  \frac{m'(V^{\prime(t+1)})}{m'(V_t^{\prime -})}
  =
  \frac{m(V^{(t+1)})}{m(V_t^-)}
\]
が成り立つなら、
\[
  b_t(\Pi')=b_t(\Pi)
\]
であり、したがって
\[
  B_n(\Pi')=B_n(\Pi)
\]
である。

証明。
各時刻の消耗量 \(d_t\) と回復量 \(r_t\) は、上の二つの質量比の対数で定義される。質量比が等しければ、それぞれの対数も等しい。したがって \(b_t=d_t-r_t\) が等しく、和を取れば \(B_n\) も等しい。証明終。

この命題は、構造持続理論の最も硬い不変性である。名前を変えても、同じ比率を見ている限り \(B_n\) は変わらない。


4. ゲージ共変性

同型より少し弱い写像として、測度比の単位を変える場合がある。たとえば、全ての質量比を同じ正の冪で読むような変更である。

ここで注意すべきことは、\(m(A)^\alpha\) が一般に測度になるとは限らない点である。したがって、これは測度そのものの変更というより、質量比 readout のゲージ変更として扱う。

以下の命題で \(m'\) と書くものも、必ずしも \(m\) から構成された新しい測度である必要はない。必要なのは、各時刻の二つの質量比 readout が下の冪変換関係を満たすことである。したがって、命題 2 は測度構成定理ではなく、質量比の読み替えに対する共変性命題である。

命題 2（正ゲージ共変性）。
ある \(\alpha>0\) が存在して、すべての \(t<T\) で
\[
  \frac{m'(V_t^{\prime -})}{m'(V^{\prime(t)})}
  = \left(\frac{m(V_t^-)}{m(V^{(t)})}\right)^\alpha
\]
かつ
\[
  \frac{m'(V^{\prime(t+1)})}{m'(V_t^{\prime -})}
  = \left(\frac{m(V^{(t+1)})}{m(V_t^-)}\right)^\alpha
\]
が成り立つなら、
\[
  b_t(\Pi')=\alpha b_t(\Pi)
\]
であり、
\[
  B_n(\Pi')=\alpha B_n(\Pi)
\]
である。

証明。
\(-\log x^\alpha=\alpha(-\log x)\) および \(\log x^\alpha=\alpha \log x\) から従う。証明終。

この場合、\(B_n\) の数値そのものは変わる。しかし、\(\alpha>0\) なので、符号、順序、消耗優位・維持・回復優位の regime は保たれる。したがって、完全不変性ではなく共変性として読むのが正確である。


5. 粗視化は不変性ではなく許容条件を要する

粗視化とは、細かな状態空間 \(X\) から粗い状態空間 \(\bar X\) への写像
\[
  \pi:X\to\bar X
\]
によって、微視的な構造維持問題を巨視的な構造維持問題へ送ることである。

粗視化は一般に非可逆である。したがって、同型不変性のような完全な保存は期待できない。下位状態の違いをまとめる時点で、情報は落ちる。

したがって、粗視化では次のいずれかを要求する必要がある。

1. 力学との可換性。
2. 質量比の一様スケーリング。
3. 累積量の誤差境界。
4. 順序予測の非反転。

Lean 側の `Survival.CoarseGraining` は、このうち保守的な exact case を形式化している。すなわち、粗視化写像が初期領域、収縮作用、再拡大作用と可換であり、かつ feasible mass と contracted mass に一様な質量スケーリングがある場合、step loss、step gain、step net action、cumulative net action が保存される。

これは第二法則級の普遍性を証明したものではない。むしろ、粗視化で何を仮定すれば \(B_n\) 側の不変性が壊れないかを示す定義層である。

より弱い粗視化では、完全保存ではなく欠損項つきの恒等式として扱う方が安全である。粗視化写像を \(\pi:X\to\bar X\) とし、集合 \(A\subseteq X\) に対して飽和欠損、すなわち saturation defect を
\[
  e_\pi(A)
  :=
  \log\frac{m(\pi^{-1}\pi(A))}{m(A)}
\]
と置く。ただし、この定義は
\[
  0<m(A)\le m(\pi^{-1}\pi(A))<\infty
\]
の範囲で読む。これは、粗視化したあとに引き戻すことで、もとの集合にどれだけ余分な状態が混ざるかを測る量である。定義上 \(e_\pi(A)\ge 0\) であり、\(A\) が粗視化に対して saturated、すなわち \(A=\pi^{-1}\pi(A)\) なら \(e_\pi(A)=0\) である。

押し出し測度 \(\bar m=\pi_*m\) と \(\bar V^{(t)}=\pi(V^{(t)})\) によって粗視化後の残存領域を読むと、
\[
  \bar m(\bar V^{(t)})
  =
  m(V^{(t)})\exp(e_\pi(V^{(t)}))
\]
である。したがって、純消耗の一歩更新は
\[
  b_t^{\mathrm{coarse}}
  =
  b_t^{\mathrm{micro}}
  + e_\pi(V^{(t)})
  - e_\pi(V^{(t+1)})
\]
となり、累積では
\[
  B_n^{\mathrm{coarse}}
  =
  B_n^{\mathrm{micro}}
  + e_\pi(V^{(0)})
  - e_\pi(V^{(n)})
\]
となる。

この式が粗視化の基本形である。したがって、粗視化によって常に
\[
  B_n^{\mathrm{coarse}} \le B_n^{\mathrm{micro}}
\]
が成り立つわけではない。成り立つのは、たとえば \(e_\pi(V^{(n)})\ge e_\pi(V^{(0)})\) のように、終端側の飽和欠損が初期側以上である場合である。初期集合が saturated なら \(e_\pi(V^{(0)})=0\) なので、この条件は自然に満たされやすい。しかし欠損項が減少する粗視化では、不等式の向きは反転しうる。

また、消耗量 \(d_t\) と回復量 \(r_t\) を個別に比較する場合には、中間集合 \(V_t^-\) の飽和欠損も必要になる。この分解は、粗視化が収縮作用 \(K_t\) と可換であり、粗視化後の中間集合を
\[
  \bar V_t^-=\pi(V_t^-)
\]
として読める場合に成立する。このとき形式的には
\[
  d_t^{\mathrm{coarse}}
  =
  d_t^{\mathrm{micro}}
  + e_\pi(V^{(t)})
  - e_\pi(V_t^-)
\]
および
\[
  r_t^{\mathrm{coarse}}
  =
  r_t^{\mathrm{micro}}
  + e_\pi(V^{(t+1)})
  - e_\pi(V_t^-)
\]
となる。したがって、粗視化は \(B_n\) だけでなく、消耗と回復の分解そのものにも欠損項を入れる。

このため、本補論は条件なしの DPI 型定理を主張しない。むしろ、許容粗視化とは飽和欠損が制御され、必要な可換性と中間集合の対応が明示された写像である、と定義するのが正しい。DPI 型単調性は、そのような欠損項条件のもとで得られる候補定理であり、無条件の普遍法則ではない。


6. 観測指標による推定は不変量ではなく検証手順で扱う

構造推定層では、\(V^{(t)}\) や \(m(V^{(t)})\) を直接数えられないことが多い。この場合、観測されるのは観測・推定指標
\[
  Z_t
\]
であり、そこから構造消耗量、回復量、余力、または介入候補を推定する。

この観測指標による推定写像は、一般には \(B_n\) を不変にも共変にも保たない。したがって、ここで必要なのは不変量定理ではなく、凍結検証である。

観測指標による推定が構造持続理論の support になるのは、探索後に写像、特徴量、baseline、metric、split、判定規則を凍結し、別データ、future surface、fresh archive、または outside rerun で追加予測力を示す場合に限られる。

このため、構造推定層の no-support は直ちに理論核の反証ではない。それは、観測・推定指標、観測単位、endpoint、または写像手順の失敗として failure ledger に残すべきである。


7. 観測可能性の三層の再解釈

以上の写像階層から、仕様固定構造層、条件付き構造埋め込み層、構造推定層は次のように読み直せる。

| 層 | 主な写像 | 保てるもの | 主な判定 |
|---|---|---|---|
| 仕様固定構造層 | 同型、ゲージ、テンプレート保存写像 | 累積純消耗量、drift、collapse boundary の定義または境界 | 定理、有限時間境界、frozen primary |
| 条件付き構造埋め込み層 | 既存理論からの構造埋め込み | drift、差分、停止境界の対応 | formal embedding / conditional bridge |
| 構造推定層 | 観測指標による推定写像 | 不変量ではなく予測的効果 | baseline + SP の凍結後改善 |

この表で重要なのは、構造推定層を弱い層として見ることではない。構造推定層は、実世界で構造を直接数えられない場合の標準的インターフェースである。ただし、それは法則側定理を証明する場所ではなく、予測、診断、介入候補を作る場所である。


8. Bernoulli-CSP class の自然性

Bernoulli-CSP class は、SAT 風の構文を後から集めた便宜的な集合としてではなく、one-sided iid bad-event exposure を保つテンプレートとして読むのがよい。ここで必要なのは群作用の orbit ではなく、iid bad-event exposure と log-drift を保つ許容写像で閉じた subcategory または generated class である。

ここでテンプレート保存写像とは、少なくとも次を保つ写像である。

1. one-sided iid bad-event exposure 構造。
2. bad-event probability の許容パラメータ範囲。
3. 一歩あたりの log-drift。
4. MGF / Chernoff / KL / stopping wrapper へ接続できる downstream structure。

この class では、各 exposure が bad-event probability
\[
  p\in(0,1)
\]
を持ち、一歩あたりの drift は
\[
  \log\frac{1}{1-p}
\]
で定まる。さらに、有限地平の path measure、MGF product、Chernoff / KL profile、fixed-time collapse、stopped collapse、hitting-time wrapper が同じテンプレートで走る。

Lean 側では `Survival.BernoulliCSPUniversality` がこの interface を固定している。そこでは k-SAT、NAE-SAT、XOR-SAT、q-coloring、finite-alphabet forbidden-pattern CSP、hypergraph coloring、exactly-one-SAT、exactly-\(r\) cardinality-SAT、at-most / at-least threshold cardinality-SAT が、同じ `ExposureModel` と `Parameters` の下に載る。

さらに `Survival.BernoulliTypicalSigma` は、この one-sided iid bad-event exposure で得られる累積生成量を \(\Sigma\) として読むための reader-facing wrapper である。そこでは、\(\Sigma\) の隣接ステップ非減少、期待単調性、interior KL/Chernoff lower-tail certificate、その補集合 good event 上での点ごとの lower-bound certificate、fixed-time typical-growth certificate、endpoint-defect budget つきの coarse terminal / typical-growth transfer、fixed-time collapse、stopped collapse、hitting-time wrapper が、有限地平と明示的 margin 条件の下で切り出されている。これは high-probability な全域単調性ではなく、Bernoulli-CSP class における有限 path / expectation-level / 条件つき粗視化 transfer の入口である。

さらに `Survival.BernoulliAdmissibleMapV0` は、この条件つき粗視化 transfer を発火させる十分条件を一つの reader-facing package として切り出している。すなわち、terminal equality \(\bar\Sigma_n=\Sigma_n+e_0-e_n\)、endpoint defect budget \(e_n-e_0\le\delta\)、および固定時刻の coarse monotonicity が与えられれば、micro 側の lower-bound / typical-growth certificate は coarse 側へ \(\delta\) penalty つきで移る。ただしこれは必要十分な admissible-map 特徴づけではなく、set-level の任意粗視化写像から自動生成される定理でもない。

したがって、Bernoulli-CSP class の自然性は「CSPっぽいから」ではない。bad-event exposure、log-drift、MGF/KL collapse stack を保つテンプレート保存写像で閉じているからである。

これは全ドメイン普遍性ではない。しかし、仕様固定構造層における限定 class universality theorem の候補としては非常に自然である。

ここで「閉じている」とは、現時点では最大生成クラスの完全な特徴づけを意味しない。より控えめには、上記の family 群が同じ exposure template と同じ downstream wrappers に入ることを意味する。将来的な stronger claim は、「この template を保つ許容写像で閉じた subcategory または generated class が Bernoulli-CSP universality class を特徴づける」という形になる。その場合でも、主張は全ドメイン普遍性ではなく、仕様固定構造層における限定クラス普遍性である。


9. 階層的不変量としての普遍性

構造持続理論で無理に単一の universal 保存則を探すと、過剰主張になりやすい。より自然なのは、許容写像の強さに応じて、保たれる量の階層を分けることである。

| 階層 | 写像の種類 | 保たれるもの |
|---|---|---|
| Level 0 | 同一問題内の pathwise update | pathwise exponential identity |
| Level 1 | 同型写像 | 累積純消耗量の不変性 |
| Level 2 | 正ゲージ変更 | 累積純消耗量の正定数倍共変性 |
| Level 3 | admissible coarse-graining | 飽和欠損恒等式、条件つき単調性、誤差境界 |
| Level 4 | 確率テンプレート保存写像 | drift / MGF / Chernoff / KL の一様境界 |
| Level 5 | 観測指標による推定写像 | 凍結後の追加予測力 |

この階層は、第二法則をそのまま移植するものではない。物理における Noether 型対応は、連続群と微分可能な作用に強く依存する。構造持続理論の写像は、離散的、非可逆的、確率的であり、観測指標にもとづく推定を含むことが多い。したがって、直接の移植ではなく、構造維持問題の許容写像と階層的不変量として再定式化する必要がある。

この意味で、目標は単一の全域普遍不等式ではなく、複数の限定クラスで成立する保存・共変・欠損項・境界・条件つき単調性の定理群である。これらが十分に厚くなるとき、構造持続理論は第二法則そのものではなく、構造維持可能性に関する階層的な統一枠組みへ近づく。


10. 既存 Lean との対応

本補論の考え方には、すでに Lean 側の足場がある。

| 役割 | Lean 側の足場 |
|---|---|
| pathwise balance kernel | `Survival.GeneralStateDynamics`, `Survival.StructuralPersistenceBalancePrinciple` |
| 粗視化の exact interface | `Survival.CoarseGraining` |
| admissible-map compatibility wrapper | `Survival.AdmissibleMapCompatibility` |
| defect-controlled compatibility wrapper | `Survival.DefectControlledAdmissibleMap` |
| total production の粗視化保存 | `Survival.CoarseTotalProduction` |
| 確率空間上の coarse compatibility | `Survival.CoarseStochasticTotalProduction` |
| resource-bounded monotonicity | `Survival.ResourceBoundedDynamics` |
| 同型不変性・正ゲージ共変性の readout wrapper | `Survival.AdmissibleMapInvariants` |
| 飽和欠損恒等式の readout spec | `Survival.SaturationDefect` |
| Sigma / total production の reader-facing wrapper | `Survival.SecondLawTotalProduction` |
| Bernoulli-CSP template | `Survival.BernoulliCSPTemplate`, `Survival.BernoulliCSPUniversality` |
| Bernoulli-CSP Sigma finite-path wrapper | `Survival.BernoulliTypicalSigma` |
| Bernoulli-CSP Sigma good-event lower-bound certificate | `Survival.BernoulliTypicalSigma` |
| Bernoulli-CSP Sigma endpoint-defect coarse transfer | `Survival.BernoulliTypicalSigma` |
| Bernoulli-CSP admissible-map v0 sufficient package | `Survival.BernoulliAdmissibleMapV0` |
| Foster-Lyapunov / queueing template | `Survival.FosterLyapunovTemplate`, `Survival.LyapunovBalanceEmbedding`, `Survival.QueueStability` |
| Repair-Maintenance template | `Survival.RepairMaintenanceBalance`, `Survival.RepairMaintenanceTemplate`, `Survival.MaintenanceComponentDecomposition` |
| cross-class unifying schema v1 | `Survival.CrossClassUnificationV1` |
| registered limited-class interface closure v2 | `Survival.CrossClassUnificationV2` |

したがって、Bernoulli-CSP だけでなく、Foster-Lyapunov / queueing と Repair-Maintenance も登録済み限定クラスとして reader-facing な interface に載っている。Phase 7 v2 で閉じているのは、三つの登録済み限定クラスが ordered Sigma carrier、nonnegative tendency driver、finite-horizon certificate route、admissible-transfer guard からなる共通 interface を満たす、という限定された closure である。

なお、現時点でも一般化されていない、または今後の stronger wrapper として切り出すべき対象は次である。

1. 構造維持問題の一般的な morphism interface。
2. defect-controlled な粗視化代数を、実際の set-level coarse map、正有限質量条件、feasible / contracted / repaired region の compatibility から instantiate すること。
3. Bernoulli-CSP class をテンプレート保存 subcategory / generated class として読む外向け定理名。現時点では `Survival.BernoulliAdmissibleMapV0` が十分条件 package までを閉じている。
4. Bernoulli-CSP \(\Sigma\) wrapper を、high-probability な class-level tendency へ強めるための追加 margin / concentration 条件の整理。
5. 観測指標による推定写像は不変量定理ではなく frozen validation に落ちる、という運用側の theorem map。

`Survival.SaturationDefect` が閉じるのは、集合論的な粗視化写像の完全な許容性ではなく、readout-level の狭い spec と、その最小 set-level instantiation である。すなわち、一歩ごとの粗視化 log-ratio loss が微視的 loss と欠損差 \(e_t-e_{t+1}\) だけ異なるなら、累積量は
\[
  B_n^{\mathrm{coarse}}
  =
  B_n^{\mathrm{micro}}+e_0-e_n
\]
となる。この theorem は、条件なしの DPI ではなく、\(e_n\ge e_0\) のような欠損条件のもとで初めて \(B_n^{\mathrm{coarse}}\le B_n^{\mathrm{micro}}\) が読めることも同時に示す。

さらに、正の set mass readout の範囲では、実際の粗視化写像 \(\pi:X\to Y\) から
\[
  e_\pi(A)=\log\frac{m(\pi^{-1}\pi(A))}{m(A)}
\]
を作る最小接続も Lean に入っている。ただし、これは任意の \(\pi\) が構造維持問題に対して許容であることを示すものではない。

一方で、exact な admissible coarse map については、\(\pi\) が初期集合、feasible trajectory、収縮作用、回復作用と可換する条件が `Survival.CoarseGraining` にあり、それを reader-facing に読む wrapper が `Survival.AdmissibleMapCompatibility` にある。ここでは、初期領域の可換性、feasible trajectory の可換性、contracted intermediate region の可換性、repaired intermediate region の可換性、さらに一様質量スケーリング下での signed kernel の exact preservation が Lean theorem 名として切り出されている。

さらに `Survival.DefectControlledAdmissibleMap` は、feasible mass readout と contracted intermediate mass readout の二段階で飽和欠損を入れた場合の代数を閉じている。収縮段階では feasible defect と contracted defect が現れ、回復段階では次時点の feasible defect と contracted defect が現れる。しかし純消耗量 \(b_t=d_t-r_t\) では contracted defect が相殺され、
\[
  \bar b_t
  =
  b_t + e_V(t)-e_V(t+1)
\]
となる。したがって累積量では
\[
  \bar B_n
  =
  B_n + e_V(0)-e_V(n)
\]
だけが残る。この theorem は、条件なしの DPI ではなく、終端 feasible defect が初期 feasible defect を上回る場合に初めて \(\bar B_n\le B_n\) を読むための reader-facing な algebraic core である。

残る作業は、この二段階 readout algebra を、実際の set-level coarse map、正有限質量条件、feasible / contracted / repaired region の compatibility から instantiate することである。

Bernoulli-CSP 側では、`Survival.BernoulliTypicalSigma` が累積 bad-event production を \(\Sigma\) として読む薄い入口を与える。これは、隣接ステップ非減少、期待単調性、finite-path Chernoff lower-tail、good-event lower-bound certificate、fixed-time typical-growth certificate、endpoint-defect budget つき coarse transfer、collapse wrapper を同じ \(\Sigma\) 語彙で参照可能にするためのものであり、無条件の第二法則型単調性や Bernoulli-CSP class の最大閉包性までは主張しない。

この coarse transfer は、粗視化 terminal readout が微視的 \(\Sigma_n\) に対して \(e_0-e_n\) だけずれる場合に、\(e_n-e_0\le\delta\) という endpoint-defect budget の下で
\[
  \mathrm{center}_n-r-\delta \le \bar\Sigma_n
\]
を good event 上で読むための fixed-time certificate である。したがって、ここで閉じているのは「欠損予算つきの条件つき transfer」であって、全時間一様の high-probability 単調性でも、条件なしの coarse-graining DPI でもない。

`Survival.BernoulliAdmissibleMapV0` は、この transfer に必要な条件を、Bernoulli coarse readout の v0 sufficient package としてまとめる。ここで必要なのは terminal equality、endpoint defect budget、coarse monotonicity の三つであり、これらがあれば Phase-4 の lower-bound / typical-growth certificate は coarse 側へ移る。ただしこれは「十分条件の束」であり、Bernoulli-CSP における許容写像の必要十分特徴づけではない。

したがって、本補論は新しい普遍法則を主張するものではない。既存の粗視化・総生成量・Bernoulli-CSP interface、および Phase 7 v2 の登録済み限定クラス interface closure を、一つの数学的見取り図にまとめ、どの wrapper が閉じており、どこから先が set-level 粗視化、高確率化、追加クラス登録、より強い限定クラス普遍性の未解決部分なのかを指定する文書である。

第二法則級の統一へ向けた実行順序は、本文の主張ではなく作業地図として `analysis/second_law_level_roadmap.md` に分けて記録する。そこでは、許容写像、\(\Sigma\) / total production、典型的非減少、限定クラス普遍性、Phase 7 v2 の登録済み限定クラス統一 interface、および将来の追加クラスや stronger interface を別々の構成要素として扱う。


11. 本補論で言っていないこと

本補論は、次を主張しない。

第一に、任意のドメインに自然な許容写像が存在するとは主張しない。

第二に、任意の粗視化で \(B_n\) が保存される、または一方向に単調になるとは主張しない。

第三に、観測・推定指標が構造そのものを直接観測しているとは主張しない。

第四に、Bernoulli-CSP class の限定普遍性が、そのまま全ドメイン普遍法則を意味するとは主張しない。

第五に、物理の Noether 定理をそのまま構造持続理論へ移植できるとは主張しない。

第六に、\(B_n\) が全ての許容写像上で一つの通常の関手として振る舞うとは主張しない。

ここでの貢献は、保存則を直接宣言することではなく、保存・共変・欠損項・境界・観測指標による推定を同じ写像階層の中で分けることにある。


12. 結論

構造持続理論の普遍性を考えるとき、問いは「ただ一つの保存則があるか」ではなく、「どの許容写像のもとで、どの量が保たれるか」である。

同型写像では \(B_n\) は不変である。正ゲージ変更では \(B_n\) は共変であり、符号と regime は保たれる。粗視化では、一般に飽和欠損が発生し、単調性は欠損項条件つきでしか言えない。観測指標による推定では、不変量定理ではなく、凍結後の追加予測力によって評価する。

この整理により、仕様固定構造層、条件付き構造埋め込み層、構造推定層は、強弱のラベルではなく、構造維持問題をどの写像で観測し、どの量をどの強さで保てるかの違いとして位置づけられる。

第二法則そのものを模倣するのではなく、許容写像の階層に対応する不変量・共変量・欠損項つき量・境界つき量・検証対象の系列を積み上げること。これが、構造持続理論をより深い統一枠組みへ進める現実的な道である。
