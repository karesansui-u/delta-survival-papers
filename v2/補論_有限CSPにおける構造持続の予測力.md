補論_有限CSPにおける構造持続の予測力
有限CSPにおける構造持続の予測力
— Mixed-SAT/NAE-SAT による Route A 経験的検証 —

要旨

本補論は、構造持続理論の Route A に属する有限制約充足問題において、累積構造損失 \(L\) が単なる制約数より強い予測情報を持つかを検証する。

単一の制約族、たとえば 3-SAT だけ、または NAE-SAT だけを見るなら、各制約の drift は定数である。したがって

\[
  L = m \cdot \ell
\]

となり、\(L\) は raw constraint count \(m\) の定数倍にすぎない。この設定では、\(L\) が raw count より良いかを問うことは原理的に縮退している。

そこで本補論では、同じインスタンス内に 3-SAT 制約と 3-NAE-SAT 制約を混ぜる Mixed-CSP を用いる。3-SAT の drift は

\[
  \ell_{\mathrm{SAT}}=\log(8/7)\approx 0.1335
\]

であり、3-NAE-SAT の drift は

\[
  \ell_{\mathrm{NAE}}=\log(4/3)\approx 0.2877
\]

である。raw count は両者を同じ 1 制約として数えるが、\(L\) は制約の質を drift-weighted に数える。この差により、構造持続理論の経験的主張を非縮退に検査できる。

2026-04-22 に事前登録済み primary run を実行した。全 12,000 インスタンスが正常に完走し、timeout は 0、malformed encoding は 0 であった。leave-one-mixture-out の予測比較では、primary predictor である \(L+n\) モデルが raw count + \(n\) baseline を大きく上回った。

| model | log loss | Brier | accuracy@0.5 |
|---|---:|---:|---:|
| `L_plus_n` | 0.0970 | 0.0299 | 0.9631 |
| `cnf_count_plus_n` | 0.1010 | 0.0304 | 0.9631 |
| `first_moment` | 0.1489 | 0.0482 | 0.9457 |
| `raw_density` | 0.7447 | 0.2524 | 0.6279 |
| `raw_plus_n` | 0.7525 | 0.2539 | 0.6159 |
| `raw_count` | 0.7708 | 0.2798 | 0.5139 |

事前登録された四つの判定基準はいずれも通過した。

- primary support: `L_plus_n` log loss 0.0970 < `raw_plus_n` 0.7525
- strong support: `raw_plus_n` に対する相対改善 87.1%（閾値 10%）
- theory-pure support: `first_moment` 0.1489 < `raw_plus_n` 0.7525
- encoding guardrail: `L_plus_n` 0.0970 <= `cnf_count_plus_n` 0.1010

この結果は、\(L\) が単なる制約数ではなく、制約が解空間を削る質的差を予測情報として運ぶことを示す。これは Bernoulli-CSP universality class に対する経験的支持であり、SAT 単独の結果を finite CSP class 内へ拡張する最初の非縮退な prospective test である。


1. 目的

構造持続理論の最小形式では、状態集合の縮小は対数損失として蓄積される。制約充足問題では、状態集合は候補割当ての集合であり、各制約はその集合を一定割合だけ削る。

ランダム 3-SAT では、一様な割当てが単一節を破る確率は \(1/8\) であり、単一節を満たす確率は \(7/8\) である。したがって各節による drift は

\[
  \ell_{\mathrm{SAT}}=-\log(7/8)=\log(8/7).
\]

同様に、3-NAE-SAT では全て真または全て偽の 2 通りが禁止されるため、単一 NAE 制約を満たす確率は \(6/8=3/4\) であり、

\[
  \ell_{\mathrm{NAE}}=-\log(3/4)=\log(4/3).
\]

このとき混合インスタンスの累積損失は

\[
  L
  =
  m_{\mathrm{SAT}}\log(8/7)
  +
  m_{\mathrm{NAE}}\log(4/3).
\]

第一モーメント法は、候補割当て数の期待値を

\[
  E[\#\mathrm{SAT}]
  =
  2^n e^{-L}
  =
  \exp(n\log 2-L)
\]

と与える。したがって

\[
  F = n\log 2 - L
\]

は、充足割当て数の第一モーメント対数である。

本補論の問いは、第一モーメントそのものを証明することではない。それは制約族の仕様から従う。問いは、その \(L\) または \(n\log 2-L\) が、raw count や raw density よりも、有限インスタンスの feasibility を out-of-sample に予測するかである。


2. 単一 family での縮退

NAE-SAT 単独で

\[
  L=m\log(4/3)
\]

を用いて feasibility を予測しても、これは raw count \(m\) と完全に同値である。3-SAT 単独でも同じである。

したがって、単一 family 内で

```text
L normalization > raw count
```

を主張することはできない。回帰モデルでは係数が定数倍に変わるだけで、予測性能は同一になる。

非自明な検査には、少なくとも二つの条件が必要である。

第一に、制約ごとの drift が異なること。第二に、評価 endpoint が raw count だけでは区別できない差を含むこと。

Mixed-SAT/NAE-SAT はこの条件を満たす。たとえば \(n=120\)、density \(d=2.5\) では raw count は全 mixture で \(m=300\) に固定される。しかし SAT/NAE の比率を変えると \(L\) は変わる。

| mixture | raw count | qualitative drift | observed SAT rate |
|---|---:|---|---:|
| pure SAT | 300 | low | 1.000 |
| 25% NAE | 300 | low-medium | 1.000 |
| 50% NAE | 300 | medium | 1.000 |
| 75% NAE | 300 | high | 0.145 |
| pure NAE | 300 | highest | 0.000 |

raw count はこれらを全て同一視する。\(L\) は NAE 制約を SAT 制約より重く数えるため、この差を区別できる。


3. 実験設計

3.1 インスタンス

primary grid は以下で構成される。

- \(n\in\{80,120,160\}\)
- density \(d=m/n\in\{2.0,2.5,3.0,3.5\}\)
- mixture:
  - pure SAT
  - 75% SAT / 25% NAE
  - 50% SAT / 50% NAE
  - 25% SAT / 75% NAE
  - pure NAE
- 各 cell 200 インスタンス

合計は

\[
  3\times 4\times 5\times 200=12000
\]

である。

exact-one-3-SAT は、drift が大きく CNF encoding size との交絡も強いため、初回 primary には含めない。これは保守的な判断である。SAT/NAE の二型混合だけでも \(L\neq \mathrm{constant}\times m\) は成立し、raw count との非縮退比較が可能である。

3.2 endpoint

primary endpoint は feasibility である。すなわち、インスタンスが SAT か UNSAT かを予測する。

これは重要である。以前の計算コスト補論では、条件つき発見確率 \(P(\mathrm{found}\mid\mathrm{SAT})\) と solver cost を扱った。しかし Route A の第一モーメント構造が直接支配するのは、まず解空間の体積と feasibility であって、特定ソルバーの探索コストではない。

したがって本補論では、solver conflict count ではなく SAT rate を primary に置く。solver cost は別の問いであり、存在論的 \(L\) と発見論的 \(c\) を混同しない。

3.3 予測モデル

事前登録では、leave-one-mixture-out cross-validation により、以下のモデルを比較した。

| model | predictor |
|---|---|
| `raw_count` | raw semantic constraint count |
| `raw_density` | \(m/n\) |
| `raw_plus_n` | raw count + \(n\) |
| `L_only` | drift-weighted \(L\) |
| `L_plus_n` | \(L+n\) |
| `first_moment` | \(n\log2-L\) |
| `cnf_count_plus_n` | CNF clause count + \(n\) |

primary comparison は `L_plus_n < raw_plus_n` である。`first_moment < raw_plus_n` は theory-pure support とした。`cnf_count_plus_n` は encoding guardrail であり、\(L\) の勝利が単に CNF 展開サイズの勝利でないかを検査する。


4. 実行整合性

4.1 aborted attempt と verifier fix

最初の primary attempt は 563 行で停止した。2 行が `malformed_encoding` と判定されたためである。これは CNF encoding の論理バグではなく、verifier 側の false positive であった。

原因は、PySAT / MiniSat が unconstrained variable を返却 model から省略することがある一方で、初期 verifier が全変数 \(1,\dots,n\) の assignment を要求していたことである。SAT/NAE 制約の意味論評価に必要なのは、実際に制約に現れる変数だけである。

修正後 verifier は、semantic constraints に現れる変数集合だけを要求する。修正後、以下の検査を通した。

- archived malformed rows 2 件の regression replay
- default agreement test 1000 instances
- stress agreement test \(n=80,d=2.0\), 500 instances
- stress agreement test \(n=160,d=2.0\), 500 instances

いずれも agreement failure は 0 であった。aborted attempt は OSF bundle と git history に forensic archive として残し、official primary analysis からは除外している。

4.2 official primary

修正後、official primary を別ファイルでゼロから実行した。

```text
official primary rows: 12000/12000
status: succeeded = 12000
timeouts: 0
malformed encodings: 0
SAT feasible rows: 6753
UNSAT rows: 5247
```

このため、primary analysis は aborted attempt に依存しない。


5. 結果

5.1 primary model comparison

leave-one-mixture-out の結果は以下である。

| model | log loss | Brier | accuracy@0.5 |
|---|---:|---:|---:|
| `L_plus_n` | 0.0970 | 0.0299 | 0.9631 |
| `cnf_count_plus_n` | 0.1010 | 0.0304 | 0.9631 |
| `first_moment` | 0.1489 | 0.0482 | 0.9457 |
| `L_only` | 0.4731 | 0.1601 | 0.7626 |
| `raw_density` | 0.7447 | 0.2524 | 0.6279 |
| `raw_plus_n` | 0.7525 | 0.2539 | 0.6159 |
| `raw_count` | 0.7708 | 0.2798 | 0.5139 |

primary predictor `L_plus_n` は `raw_plus_n` を大きく上回った。

\[
  0.0970 < 0.7525.
\]

相対改善は

\[
  1-\frac{0.0970}{0.7525}\approx 0.871
\]

であり、事前登録の strong support 閾値 10% を大幅に超える。

5.2 first moment

理論的に最も純粋な predictor は

\[
  n\log2-L
\]

である。これは係数を固定した第一モーメント対数であり、追加の自由係数を持たない。

この `first_moment` も `raw_plus_n` を明確に上回った。

\[
  0.1489 < 0.7525.
\]

ただし `L_plus_n` には負ける。これは有限サイズ補正を示唆する。`first_moment` は \(n\) と \(L\) の係数を \((\log2,-1)\) に固定するが、`L_plus_n` は有限 \(n\) の偏りを logistic regression の係数で吸収できる。

したがって、`first_moment` と `L_plus_n` の差

\[
  0.1489-0.0970=0.0519
\]

は、第一モーメント理論からの finite-size deviation を測る経験的余白として読める。

5.3 encoding guardrail

`L_plus_n` は `cnf_count_plus_n` にもわずかに勝った。

\[
  0.0970 \le 0.1010.
\]

この margin は小さい。しかし SAT/NAE の二型混合では、それは予想される。CNF encoding では SAT 制約は 1 clause、NAE 制約は 2 clauses で表せる。一方、drift ratio は

\[
  \frac{\log(4/3)}{\log(8/7)}\approx 2.15
\]

であり、CNF clause count の比 2.00 と近い。したがって SAT/NAE-only grid では、\(L\) と CNF clause count はほぼ比例する。

この条件で `L_plus_n` が `cnf_count_plus_n` に勝つことは、方向としては理論と整合するが、margin が狭くなるのは構造的に自然である。

将来、exact-one 制約を stress extension として含めると、この guardrail はより強く分離される。exact-one-3-SAT の drift は

\[
  \log(8/3)\approx 0.981
\]

であり、SAT に対して約 7.3 倍である。一方、pairwise CNF encoding の clause count は SAT に対して 4 倍である。ここでは \(L\) と CNF size の比例性がより大きく破れる。

ただし、exact-one は feasibility の飽和と encoding size 交絡が強いため、初回 primary から外した。この判断は、最初の empirical Route A test を清潔に保つための保守的設計である。


6. 理論的位置づけ

6.1 SAT 単独から Bernoulli-CSP class へ

ランダム 3-SAT は、構造持続理論にとって最も硬い Route A anchor の一つである。状態集合は \(\{0,1\}^n\)、測度は counting measure、各制約の縮小率は仕様から直接計算できる。

しかし 3-SAT 単独では、\(L=m\log(8/7)\) であり、raw count と縮退する。したがって、3-SAT で \(L\) が有効であることは重要だが、「制約の質を drift-weighted に数えることが raw count より強い」という主張はまだ検査されていない。

Mixed-SAT/NAE-SAT はこの間隙を埋める。raw count を固定したまま、constraint type の drift を変えることで、\(L\) の非自明な予測力を検査する。

今回の結果は、Bernoulli-CSP universality class に対して、Lean での formal layer に対応する empirical counterpart を与える。具体的には `Survival.BernoulliCSPUniversality`、`Survival.NAESATChernoffCollapse`、および関連する exposure / Chernoff wrapper 群に対応する経験的検査である。すなわち、固定割当てに対する Bernoulli bad-event exposure として表現できる異なる CSP 制約族が、同じ \(L\)-based coordinate で feasibility を整理される。

6.2 何を主張し、何を主張しないか

本補論が主張するのは次である。

1. SAT/NAE mixed finite CSP では、\(L+n\) が raw count + \(n\) より feasibility を強く予測した。
2. \(n\log2-L\) という theory-pure predictor も raw baseline を上回った。
3. CNF encoding size baseline との比較でも、\(L+n\) は少なくとも同等以上であった。
4. したがって、\(L\) は単なる制約数ではなく、制約の質的 drift を含む予測座標として機能する。

本補論が主張しないのは次である。

1. すべての CSP で同じ定数係数が成立する、とは主張しない。
2. drift から solver cost の感度指数 \(c\) を一点予測できる、とは主張しない。
3. XOR-SAT のように多項式構造が支配する family を primary empirical cost test に使える、とは主張しない。
4. Bootstrap percolation や branching process がこの意味で Route A anchor である、とは主張しない。
5. 独立再現なしに universal law が確立した、とは主張しない。

ここで得られたのは、Bernoulli-CSP class 内での empirical universality support である。より強い universal law of tendency には、formal theorem 4 の昇格と独立再現が必要である。

6.3 LLM 実験との対応

LLM 側の Exp.40/41/42 は、scope-as-repair が quality-blind baseline より予測力を持つことを示した。Mixed-CSP は、それとは全く異なる hard combinatorial domain で、drift-weighted \(L\) が raw baseline より予測力を持つことを示す。

両者の機構は同じではない。LLM の attribution-as-repair と SAT/NAE の bad-event exposure は別の現象である。

共通しているのは、単純な「量」ではなく、構造の質を区別する座標が out-of-sample の予測力を持つ点である。LLM では scope / attribution の質が効き、Mixed-CSP では constraint drift の質が効く。

この意味で、Mixed-CSP は「例を一つ足した」のではなく、方法論を横断した検査である。すなわち、quality-blind / raw-count baseline に対して、structure-aware coordinate が prospective に勝つかを問う同じ型の検査である。


7. 限界

第一に、本結果は SAT/NAE の二型混合に限定される。q-coloring や cardinality-SAT への拡張は自然な次段階だが、本補論の primary claim ではない。

第二に、encoding guardrail の margin は小さい。これは SAT/NAE では CNF clause ratio と drift ratio が近いためである。この点は exact-one stress extension でより強く検査できる。

第三に、対象は feasibility であり、solver cost ではない。solver cost については、既存の計算コスト補論が存在と発見を分けて扱っている。本補論の結果を、任意ソルバーの runtime 予測へ直接外挿してはならない。

第四に、有限サイズ効果が残る。`first_moment` が raw baseline を大きく上回る一方で `L_plus_n` に負けることは、理論的第一モーメントだけでは finite \(n\) の補正を完全には吸収できないことを示す。

第五に、公式 primary の前に verifier false positive による aborted attempt が存在する。ただしこれは archive され、原因は unconstrained variable の model omission と特定され、修正後の regression / agreement test を通過した。official primary は修正後に別ファイルでゼロから実行され、aborted attempt は分析から除外されている。


8. 再現性

関連ファイルは以下にある。

| file | role |
|---|---|
| `analysis/route_a_mixed_csp/mixed_csp_preregistration.md` | 事前登録 |
| `analysis/route_a_mixed_csp/run_mixed_csp.py` | 実行 runner |
| `analysis/route_a_mixed_csp/analyze_mixed_csp.py` | primary analysis |
| `analysis/route_a_mixed_csp/debug_mixed_csp_encoding.py` | verifier regression / agreement diagnostics |
| `analysis/route_a_mixed_csp/mixed_csp_primary_official_2026-04-22.jsonl` | official primary raw records |
| `analysis/route_a_mixed_csp/mixed_csp_results.json` | machine-readable results |
| `analysis/route_a_mixed_csp/mixed_csp_results_summary.md` | human-readable results |

OSF addendum:

- zip: <https://osf.io/download/69e826573b65e7b53bfd8b7e/>
- manifest: <https://osf.io/download/69e8265a30357781bafd90d6/>

公式 primary の commit は

```text
1dadb73dd435347977c47be066002460f136ea00
```

であり、結果導線の commit は

```text
a5fc8e2
```

である。


9. 結論

Mixed-CSP primary は、構造持続理論の Route A empirical test として、事前登録された四つの判定基準を全て通過した。

3-SAT と 3-NAE-SAT は raw count では同じ 1 制約として見えるが、解空間を削る drift は異なる。\(L\) はこの差を加法的に累積し、finite CSP の feasibility を out-of-sample に予測した。

これは、構造持続理論における \(L\) が単なる量ではなく、制約の質を含む座標として機能することの経験的証拠である。SAT 単独の Route A anchor は、Mixed-SAT/NAE-SAT により Bernoulli-CSP class へ一段拡張された。

ただし、本補論は universal law の最終宣言ではない。正確な位置づけは、三つの異なる領域——SAT、LLM contradiction repair、Mixed-CSP feasibility——で、structure-aware coordinate が quality-blind / raw baseline を上回った、という Level 2 universality candidate への強い支持である。

残る課題は、formal theorem 4 による tendency law への昇格、q-coloring / cardinality-SAT などへの幅拡張、そして独立再現である。
