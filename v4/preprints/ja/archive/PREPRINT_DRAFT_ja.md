# 構造持続理論（Structural Persistence Theory）

## 構造維持における可能性と不可能性の境界を形式化する理論

**作業中の日本語プレプリント草稿。**
この文書は、英語版 [`PREPRINT_DRAFT.md`](PREPRINT_DRAFT.md) の日本語向け要約・構成案です。論文本文へ移す前の paper-facing scaffold として扱います。

## 概要

構造持続理論は、構造維持における可能性と不可能性の境界を形式化する理論です。システムが「何として持続しているのか」、その持続を「何が担っているのか」、その構造を維持できる余地が「どう削られ、どう支えられ、どこで停止・崩壊・回復不能になるのか」を、明示的な機能・構造・損失・有効資源・証拠のもとで読むための形式理論です。

自然環境、医療、企業経営、インフラ、機械のメンテナンス、AI、安全性、社会実装などでは、「回復力」「崩壊」「持続可能性」「不可逆性」が語られます。しかし多くの場合、次の問いが混ざったまま議論されます。

1. どれくらい構造的に劣化しているのか。
2. 何を「守りたい機能」や「持続させたい構造」と呼ぶのか。
3. raw resource は、その機能を支える有効資源になっているのか。
4. 明示的な復元ターゲットを置いたとき、その復元には何が必要なのか。
5. その要求を払うための有効資源は残っているのか。
6. ある修復が、別のシステムの回復可能性を悪化させないか。

構造持続理論はこれらを、守りたい機能 `F`、それを担う構造 `K`、その構造を維持できる状態集合 `V` と測度 `m`、構造損失 `L` または修復込みの純負担 `B`、raw resource `R`、有効資源 `M` に分けます。明示的な復元ターゲットを判定するときだけ、追加の回復判定レイヤーとして `C_req`、witness、lower-bound certificate を置きます。この分離により、「壊れているが回復可能」「機能停止しているが戻せる」「raw resource はあるが有効資源になっていない」「個別には回復可能だが集合としては回復不能」といった違いを、同じ会計インターフェースで扱えます。

Lean 4 形式化は、この会計上の帰結を機械的に検査します。Lean が検証するのは、ドメイン固有の経験的真理そのものではありません。各ドメインがターゲット、コスト、資源、witness、下限証明書、結合証明書を与えたときに、そこから回復可能性・回復不能性・介入しきい値・タイミング・集合的トレードオフが正しく流れることを検証します。

したがって、実用上の対象は任意の記号・ラベル・識別子ではありません。対象は、maintained / stopped / recoverable という問いが意味を持つ構造体です。Lean 側ではこの範囲を `PersistenceSubject` として名前づけ、domain が resource 側と structure 側の aspect を供給したときに共通の M/L 会計へ入れるようにしています。ただし、その分解が非自明か、両側が独立に分離するかは、別途 witness / certificate として要求します。

## 1. 問題設定

従来の議論では、以下のような概念が一つの「弱さ」や「リスク」に潰されがちです。

- 構造的にどれだけ傷んでいるか。
- どの機能やアイデンティティを復元したいのか。
- その復元に必要なコストはいくらか。
- そのコストを払うリソースはあるか。
- その介入が他の対象へどの外部性を出すか。

構造持続理論の目的は、これらを単一スコアへ圧縮することではありません。むしろ、それぞれの役割を分け、ドメイン固有の意味論を残したまま、意思決定層で比較可能な形にすることです。

この意味で、構造持続理論は「任意の記号列」の理論ではありません。自然な対象は、維持され、止まり、壊れ、回復可能性を問える構造体です。domain が M/L aspect と持続判定に必要な predicate を供給すると、Lean はそれを共通の診断・会計インターフェースへ射影できます。

## 2. 構造持続論の主導線：`F / K / V,m / L or B / R,M`

構造持続理論の本体は「回復にいくら必要か」ではなく、持続が成立する仕組みを次の主導線として分解することです。

```text
F -> K -> V_K,m -> L/B -> R/M -> S
```

まず何を持続させたいのかを固定し、そのうえで削られる側と支える側を分けます。

- `F`（target function）:
  守りたい機能、アイデンティティ、述語、ターゲットです。

- `K`（carrying structure）:
  その `F` を担う構造です。構造持続理論が問うのは、基体一般の存在ではなく、この `F` をこの `K` として維持できるかです。

- `V`（viable state region）:
  `F` を `K` として維持できる状態集合です。持続とは、ただ何かが存在することではなく、選ばれた機能・同一性・述語を担う構造が、この維持可能領域の中に留まれることとして読まれます。

- `m`（measure of viable room）:
  `V` の大きさ、余地、許容範囲を読む測度です。構造損失は、状態集合そのものを直接数えるのではなく、`m(V)` が時間とともにどう縮むかから読まれます。

- `L`（structural-loss coordinate）:
  `m(V)` の縮小を対数比で読む構造的損失座標です。大きい `L` は、より弱い持続性またはより大きい構造的損失を意味します。

- `B`（repair-inclusive net burden）:
  明示的な修復やメンテナンスを含む場合の累積純負担です。収縮だけでなく、修復によって `V` がどれだけ戻されたかも含めて読む量です。

- `R`（raw resource stock）:
  予算、時間、人員、エネルギー、計算資源、社会的信頼、政治的余力などの資源素材です。

- `M`（effective resource）:
  `R` のうち、その時点で `F` と `K` を支えるために実際に使える有効資源です。

明示的に特定ターゲットへの復元可能性を判定する場合には、追加の境界として `C_req` を使います。`C_req` は、選ばれた機能・アイデンティティ・述語・ターゲットを復元するための target-relative な復元境界です。これは回復判定レイヤーの量であり、理論全体の主役ではありません。

したがって、本稿では三つの層を分けて読む。

```text
本体:
  F / K / V_K / m / L / B / R / M / S

判定レイヤー:
  target / action / witness / lowerBound / C_req / CanRecoverTo

集合・波及レイヤー:
  coupling / externality / forbidden subset / nested system
```

この順序が重要です。`L` は「あるべき状態」そのものではありません。`F` と `K` が決まったあと、その構造を維持できる領域 `V` がどれだけ狭くなったかを、`m(V)` の対数比として読んだ量です。同じ raw resource `R` があっても、それがこの `F/K` を支える経路を持たなければ、有効資源 `M` にはなりません。

この分離によって、たとえば次を区別できます。

- 機能停止しているが、到達可能 witness と十分な有効資源があるので回復可能。
- 構造的損失 `L` は大きいが、修復や外部支援により `B` が抑えられている。
- raw resource `R` は大きいが、その構造に効く `M` は小さい。
- 資源 `M` は正だが、`C_req > M` なので特定ターゲットには回復不能。
- `A` と `B` は個別には回復可能だが、共有資源の下では同時に回復不能。

## 3. 構造カーネルと `S`

`L` 側は対数加法的です。乗法的な構造持続性は、標準的な対数表現によって加法的な構造損失になります。

閉じた収縮の読みでは、

```text
d_t = -log(m(V_{t+1}) / m(V_t))
L_n = sum_{t<n} d_t
m(V_n) = m(V_0) * exp(-L_n)
```

明示的な修復やメンテナンスを伴う場合、

```text
d_t = -log(m(V_t^-) / m(V_t))
r_t =  log(m(V_{t+1}) / m(V_t^-))
b_t = d_t - r_t
B_n = sum_{t<n} b_t
m(V_n) = m(V_0) * exp(-B_n)
```

リソース結合ポテンシャルは、

```text
S_n = M_n * exp(-L_n)
```

または修復込みで、

```text
S_n = M_n * exp(-B_n)
```

です。これは、構造的損失が有効資源を割り引いたあと、どれだけの full-persistence potential が残っているかを読む量です。

ここでの `M` は raw resource `R` ではありません。`M` は、その `F` と `K` を支えるために、その時点で実際に使える有効資源です。現金はあるが承認権限が詰まっている、病床はあるが看護師がいない、サーバはあるが rollback 導線がない、という場合、`R` はあっても `M` は小さいと読めます。

ただし、`S` はターゲット回復可能性そのものではありません。

- `S_n <= 0`: resource-side / full-persistence potential boundary。
- `C_req_n <= M_n` + 到達可能 witness: ターゲット相対的な回復可能性。
- `M_n < C_req_n` + lower-bound certificate: そのターゲットに対する回復不能性。

`M` を非負台帳として扱う設定では、この境界はしばしば `S_n = 0` と読めます。一般の実数台帳では、Lean 側の判別式は `S_n <= 0 iff M_n <= 0` として表現されます。

また、定義上 `L` は `M` を直接更新しません。`S = M * exp(-L)` の読み出しを指数関数的に割り引きます。ただし、明示的な structural-cost channel を与える場合、`L` はメンテナンスコストや復元コストを通じて `M` の時間発展を悪化させることがあります。

## 4. 単一スコアの限界とドメイン横断トレードオフ

M/L 分離は、単に見通しのよい記法ではありません。Lean 形式化では、
限定された no-go として、次を明示しています。

```text
S = M * exp(-L)
```

のような scalar-only readout は、resource-side、loss-side、supplied
intervention-axis の診断が異なる二つの状態を、同じ値に潰しうる。
さらに、その scalar readout だけを経由して作る任意の score /
aggregate classifier は、その ambiguity witness がある診断を分類できません。

これは「すべての scalar 理論が不可能」「既存研究は持続や崩壊を説明できない」
「M/L が唯一最小の分解である」という主張ではありません。主張は
interface-relative です。明示的な ambiguity witness の下では、`S` に factor
する aggregate-score interface では、構造持続理論が横断会計で保持させる
機構差を運べない、ということです。

反対に、各 domain が split M/L adapter を供給するなら、resource-side、
loss-side、supplied intervention-axis の同じ diagnostic vocabulary を
複数ドメインに投影できます。ここに、全体トレードオフを議論するための
モノサシが出てきます。構造持続理論は全体最適を自動計算する理論では
ありません。どの `F` を維持し、どの `K` が担い、どの境界が越えられ、
どの資源が有効で、どの `C_req` が証明され、ある修復が他の系へどの
外部性を出すかを、単一スコアに潰さず並べるための会計 interface です。
全体最適を計算するには、目的関数、重み、制約、証明書を別途明示する
必要があります。

この接続は `MLDiagnosticTradeoff` レイヤーで形式化されています。action の
restored scalar value を domain state として読む decoder を domain が供給すると、
split diagnostic interface の resource / loss readout は finite predicate-set
target になります。二つの domain では、左右の diagnostic axes を一つの有限 index
type にまとめ、同じ shared-budget predicate-set ledger に渡します。明示的な
required-cost lower bound と attainable witness の下で、Lean は共同回復可能性と、
個別には可能だが同時には不可能な forbidden-region wrapper の両方を証明します。
つまり M/L split は診断上の便利な分解にとどまらず、集合的トレードオフ会計へ入る
interface でもあります。

`MLDiagnosticNecessity` レイヤーは、この主張の反対側の境界を名前として固定します。
structural-persistence-style tradeoff-ready interface は、供給された resource 診断と loss 診断を保持し、
その両 readout を露出する必要があります。したがって診断 readout レベルでは split
projection と同値になります。提案された interface が一つの scalar readout に
factor して診断保存を行う場合、明示的な scalar mechanism ambiguity witness の下で
その interface は tradeoff-ready になれません。これはすべての encoding の不可能性ではなく、
構造持続理論が tradeoff ledger に保存させる診断に対する interface-relative necessity です。

`MLDiagnosticReadyLedger` レイヤーは、その順方向の handoff を閉じます。domain が
tradeoff-ready interface を供給すると、resource/loss diagnostics は同じ finite
predicate-set ledger に入り、cross-domain shared-budget recovery wrapper と
forbidden-interval wrapper に接続できます。これは全体最適や cost discovery の定理ではなく、
そのような最適化が乗るべき検証済み ledger entry point です。

`MLDiagnosticPolicyComparison` レイヤーは、その ledger 上に最初の明示的な
decision vocabulary を追加します。policy は selected diagnostic axes の有限集合であり、
Lean はその policy が recoverable か、blocked か、別 policy を covers するか、
または selected axes は個別には recoverable だが集合としては forbidden かを
証明書として束ねられます。これは automatic policy synthesis ではなく、action-cost
nonnegativity や recoverability の subset monotonicity は、追加証明書なしには仮定しません。

`MLDiagnosticPolicyFrontier` レイヤーは、その境界 readout を束ねます。supplied
partial classifier は、recoverable / blocked の印を soundness proof を通してだけ
使えます。また minimal forbidden policy は、strict subpolicy が forbidden でないことの
証明を追加で持ちます。したがって certified diagnostic frontier を表現できますが、
exhaustive search や automatic optimization は主張しません。

`MLDiagnosticFrontierSummary` レイヤーは、この certified boundary を downstream 用の
compact readout として束ねます。supplied frontier と optional な recoverable-coverage
witness / minimal-forbidden witness を持ち、そこから取り出すのは各 certificate が
すでに持つ事実だけです。policy ranking、preference synthesis、全 policy の列挙は
主張しません。

`MLDiagnosticFrontierReadout` レイヤーは、その optional witness が summary 内に
存在すること自体が certificate として与えられた場合だけ、それを reportable にします。
combined readout は recoverable-coverage certificate と minimal-forbidden certificate
を同時に露出できますが、これはあくまで certificate projection です。policy ranking、
preference synthesis、frontier enumeration の定理ではありません。

`MLDiagnosticFrontierConsistency` レイヤーは、それに対応する sanity check を追加します。
同じ selected policy を recoverable かつ minimal-forbidden blocked として同時に
報告することはできません。これは 1 policy に対する recoverability と blockage の
非両立性であり、frontier completeness や policy selection の定理ではありません。

`MLDiagnosticFrontierReport` レイヤーは、この supplied combined readout を downstream
report object として束ねます。summary、recoverable policy、minimal-forbidden policy、
consistency fact、no-strict-subpolicy witness を projection で再露出します。policy
choice、ranking、certificate discovery、optimization は主張しません。
構造側でも、`StructuralPersistenceDiagnosticFrontierReport` は supplied structural
summary/readout を downstream report として束ねるだけです。recoverability、
forbidden status、consistency、no-strict-subpolicy facts は既存 certificate の
projection であり、frontier construction、enumeration、ranking、optimization は
主張しません。
structural diagnostic report construction layer では、supplied sound frontier、
recoverable-coverage certificate、minimal-forbidden certificate から structural
report を作る明示的な constructor を置きます。toy resource/loss forbidden
interval では、minimal-forbidden 側は既存の二軸 minimality theorem から導き、
さらに具体的な toy report では、何も mark しない silent frontier classifier、
toy resource-axis witness から取り出した resource singleton の recoverable-coverage
certificate、full resource/loss minimal-forbidden certificate を束ねます。この
report から、recoverable singleton 側が full resource/loss forbidden policy と同一では
ありえないことも出ます。guard lemma により、silent frontier 自体は policy を何も
mark せず、report の事実は summary certificate field から来ることも明示されます。
この具体的な toy report も、admitted ontology の inherited M/L ledger profile と
同じ ledger/report bundle に入れられます。ただし bundle はあくまで handoff object
であり、ledger profile が diagnostic report を生成するわけではありません。
cross-domain structural report bundle も同じ意味で terminal です。左右の supplied
single-domain bundle と、別途 supplied な cross-domain frontier report を横に置き、
single-domain report から cross-domain report を導出せずに readout を射影します。
組み込みの二軸 `{resource, loss}` diagnostic policy については、Lean はさらに狭い
形状定理を証明します。`0 <= M` のもとで、supplied full forbidden certificate は
minimal-forbidden certificate に上がります。なぜなら strict subpolicy は空集合または
singleton であり、個別 witness から recoverable になるためです。これは任意軸の
minimality でも frontier search でもありません。

## 5. 死・崩壊・回復不能性

構造持続理論は生命や死を普遍的に定義しません。死や回復不能性は、与えられた function、identity、predicate、target に相対して読みます。

- functional stop:
  現在の状態が、選ばれた機能や viability predicate を満たしていない。
- target-relative recoverability:
  ターゲット復元 action が存在し、それが `M` で払える。
- target-relative irrecoverability:
  すべてのターゲット復元 action が有効資源 `M` を超える。
- resource-side collapse:
  resource-coupled full-persistence readout が非正境界に達する。

このため、ある identity に対して「機能的に死んでいるが回復可能」「機能的に死んでいて回復不能」「リソース側で完全崩壊」といった読みを区別できます。

## 6. 介入の文法

構造持続理論は、回復可能かどうかを判定するだけではありません。どの介入レバーを動かせば、持続性や回復可能性の符号が変わるかを読むための文法でもあります。

持続レイヤーでは、介入は `F`、`K`、`V,m`、`L/B`、raw resource `R` から有効資源 `M` への変換、そして `M` そのもののどこを動かすかで読めます。ここまでが構造持続論の主導線に属する介入です。さらに明示的な復元ターゲットを置いた場合だけ、回復判定レイヤーでは現在のマージンが

```text
margin = M - C_req < 0
```

であるとき、介入 `u` の後のマージンは概念的に

```text
margin(u) = (M + DeltaM(u)) - (C_req + DeltaC_req(u))
```

として読めます。

介入は、会計のどこを動かすかで型付けされます。

1. 守るべき `F` を明示する、または明示条件のもとで変更する。
2. `F` を担う `K` を再設計する。
3. 維持可能状態集合 `V` を守る、または広げる。
4. `L` や修復込みの `B` を下げる。
5. raw resource `R` を有効資源 `M` に変換する経路を改善する。
6. `M` を増やす、または再配分する。
7. 回復判定レイヤーで `C_req` を下げる。
8. ターゲット復元 witness を供給する。
9. 有害な coupling / externality を弱める。
10. deadline / horizon を動かす。

重要なのは、target の変更は自由な goalpost moving ではないことです。target を変える場合には、predicate inclusion、equivalence、sortal morphism などの明示的 witness が必要であり、古い target と新しい target の読みは別々に監査可能でなければなりません。

ドメインを越えて転用されるのは、治療法や修理手順そのものではありません。転用されるのは、その介入がどの repairability structure を変えるかという型です。

## 7. 集合的修復と外部性

構造持続理論の重要な読みの一つは、個別回復可能性と集合回復可能性を分けることです。

```text
A の復元要求: 40
B の復元要求: 70
共有リソース M: 90
```

このとき、

```text
A alone: 40 <= 90
B alone: 70 <= 90
A+B jointly: 40 + 70 > 90
```

です。`A` と `B` は個別には回復可能ですが、共有リソースの下では同時に回復不能です。

さらに、`A` を修復することが `B` の `C_req` を上げる、または共有 `M` を消費するなら、ベースラインでは可能だった共同回復が不可能へ反転することがあります。構造持続理論は、このような repair externality や possible-to-impossible flip を、明示的な lower-bound / attainability / coupling certificate の下で読みます。

## 8. 実用・社会実装：監査レイヤーとしての構造持続理論

社会実装では、構造持続理論は意思決定の神託ではなく、修復判断の監査レイヤーです。

各ドメインは自分の native measurements と causal models を保持します。そのうえで、certificate-scoped adapter として以下を露出します。

- 維持すべき function / predicate / identity / target `F`。
- それを担う構造 `K`。
- 維持可能状態集合 `V` と、その余地を読む測度 `m`。
- `m(V)` の縮小または修復込み純変化から読まれる構造損失座標 `L/B`。
- raw resource `R` と有効資源台帳 `M`。
- 明示的な回復判定レイヤーを置く場合のターゲット相対的復元境界 `C_req`。
- どの介入軸を動かしているか。
- 他システムへの coupling / externality。
- 判定を支える witness または lower-bound certificate。

目的は、個人、家族、企業、地域社会、社会、国家、世界、自然・生態系を 1 つのスコアに潰すことではありません。それぞれの階層の意味論を残したまま、recovery margin、intervention gap、forbidden subset、repair externality、deadline を意思決定層で比較可能にすることです。

## 9. 入れ子になった社会・生態系での読み

構造持続理論の社会実装で重要なのは、各単位が「それ自体としてのシステム」であると同時に「上位システムの構成要素」でもある、という入れ子構造です。

- 個人は、家族、職場、地域社会、国家、自然環境の中の repair unit でもある。
- 家族や企業は、それ自体の `F / K / V,m / L or B / R,M` を持つと同時に、地域・社会・サプライチェーン・環境の構成要素でもある。
- 国家は、それ自体の制度的・資源的台帳を持ちながら、世界的な生態系・経済・安全保障システムの一部でもある。
- 自然・生態系は、企業や社会の外部条件であるだけでなく、それ自体が回復 target、損失座標、復元要求、資源制約を持つシステムとして読める。

この読みでは、ある介入が一つの単位の持続性や回復 margin を改善するとき、近隣、家族、労働者、地域社会、自然・生態系、上位制度の `F`、`K`、`V,m`、`L/B`、`R/M`、`C_req`、coupling をどう変えるかを記録します。

これは「全体最適」を自動で決める理論ではありません。全体最適を計算するには、目的関数、ターゲット、重み、制約、証明書を明示する必要があります。構造持続理論が提供するのは、それらの選択を隠さず、どの修復がどの外部性を生み、どの有限集合が共有資源の下で同時に回復可能かを監査可能にする会計構造です。単一 aggregate score に factor すると機構差や介入軸が潰れうる、という scalar non-identification が、この慎重さの形式的理由です。

ESG や環境の claim は、この入れ子型の repairability ledger に入る一例です。中心は ESG master score ではなく、個人から生態系までの相互作用を、target-relative な修復可能性と外部性として見えるようにすることです。

## 10. Lean が保証すること

Lean は主役ではなくガードレールです。構造持続理論の読みが比喩ではなく、明示された仮定、証明書、定理に結びついていることを保証します。

Lean が保証するのは、各ドメインの経験的真理ではありません。保証するのは、`F`、`K`、`V,m` またはその測度列、`L/B`、`R`、`M`、必要に応じた `C_req`、witness、lower bound、coupling certificate などの明示的な certificate が与えられたときの accounting consequences です。

ここで、論文の概念モデルと Lean 実装の粒度は同一ではありません。概念モデルは `F / K / V,m / L,B / R,M` から始まります。一方、Lean では二層に分かれています。`GeneralStateDynamics` は `V0 : Set X`、時刻ごとの feasible set、`MassModel.mass : Set X -> Real` を明示的に扱います。多くのドメイン bridge と `MLLedgerClass` では、その情報を正の質量列 `m : Nat -> Real` に抽象化し、その上で対数損失カーネル、修復込み純負担、資源台帳、`fullPotential`、`CanRecoverTo` の帰結を検証します。したがって Lean が検証しているのは、概念スキーマ全体の存在論ではなく、その中核会計エンジンです。

現在のリポジトリは `Persistence.lean` が import する 644 modules をビルドし、以下を満たします。

```text
sorry = 0
admit = 0
project-declared axiom = 0
```

代表的な verified readout は以下です。

1. Structural kernel:
   `m(V_n) = m(V_0) * exp(-L_n)`。
2. Collapse-mode discriminant:
   正の構造カーネルの下で `S_n <= 0 iff M_n <= 0`。
3. Repair infeasibility:
   `C_req` がすべての target-restoring action の certified lower bound であり、`M < C_req` なら回復不能。
4. Intervention sufficiency:
   介入が certified gap を覆い、必要な witness を供給すれば、回復可能性が戻る。
5. Intervention necessity:
   lower-bound certificate の下で gap が覆われなければ、その時点で回復不能のまま。
6. Collective forbidden subset:
   個別支払可能性は共同支払可能性を含意しない。要求合計の下限が共同回復をブロックできる。
7. Coupled flip:
   ベースライン共同回復は可能でも、coupling-induced required increase により共同回復不能へ反転しうる。
8. Scalar non-identification:
   同じ scalar readout が、異なる resource-side / loss-side / intervention-axis 診断を隠しうる。split M/L adapter は、それらの診断をドメイン横断で投影できる。

## 11. 主張しないこと

構造持続理論は以下を主張しません。

- 普遍的な物理法則であること。
- 各ドメインの native dynamics を置き換えること。
- Shannon coding theorem、熱力学第二法則、Jarzynski/Crooks、Landauer、PAC/VC 理論を第一原理から再証明すること。
- 実世界の介入を自動発見すること。
- 生命や死を普遍的に定義すること。
- レジリエンス、社会的価値、生態学的価値、全体最適を 1 つの master score に変換すること。
- すべての scalar 理論が不可能であること、または M/L が唯一最小の分解であること。

構造持続理論の意図した読みは、

```text
domain certificate -> 構造持続理論 adapter -> repair-affordability readout
```

であり、

```text
all domains are the same theorem
```

ではありません。

## 12. 貢献

この論文の主な貢献は以下です。

1. 維持すべき機能 `F`、それを担う構造 `K`、維持可能状態集合と測度 `V,m`、そこから読まれる構造損失または純負担 `L/B`、raw resource `R`、有効資源 `M` の形式的分離。`C_req` は明示的な回復判定レイヤーの復元境界として扱う。
2. 表現論に裏付けられた対数加法的構造カーネルと、target-relative recovery から明示的に区別された resource-coupled full-persistence readout。
3. 回復可能性、回復不能性、identity-relative death の target-relative な扱い。
4. 回復可能性マージンを動かすための intervention grammar。
5. forbidden subset、budget gap、timing、repair externality のための集合的修復会計。
6. scalar-only / aggregate-score interface では M/L の機構診断を保持できないことを示す non-identification 境界と、split M/L adapter による横断診断 interface。
7. 修復判断の audit layer としての社会実装読み。個人、家族、企業、社会、国家、自然・生態系をまたぐ入れ子型 repairability ledger。
8. 明示的な certificate と仮定の下で accounting consequences を検証する Lean 4 artifact。

## 参考

- 英語版草稿: [`PREPRINT_DRAFT.md`](PREPRINT_DRAFT.md)
- 日本語 README: [`README.ja.md`](README.ja.md)
- 主張境界: [`CLAIM_AUDIT.md`](CLAIM_AUDIT.md)
- 定理マップ: [`THEOREM_MAP.md`](THEOREM_MAP.md)
