# Paper 5 §3 Review Draft

Status: review draft, not a main preprint.

Date: 2026-04-22

Source: `PAPER5_SECTION_1_2_DRAFT.md`, `v2/3_構造持続と推論性能の劣化.md`, `v2/4_構造持続と継続学習における破滅的忘却.md`

Target file on promotion: `v2/5_構造持続における資源項Mの操作的定式化.md`

Scope of this draft: §3 Paper 3 / Paper 4 の mode 対応のみ。§4 以降の software / SaaS mapping と empirical route は後続 draft で起草する。

---

## 3. Paper 3 / Paper 4 の mode 対応

§2 では、有効維持能力を、内部の持続様式
\[
  M^{\mathrm{int}}=(M_b^{\mathrm{int}},M_r^{\mathrm{int}},M_a^{\mathrm{int}})
\]
と外部供給 channel
\[
  M^x=(M_{x\to b},M_{x\to r},M_{x\to a})
\]
に分けた。本節では、この mode / channel 分解を Paper 3 と Paper 4 の観察に対応づける。ただし、本節の対応は mode 値の直接推定ではない。各実験で観察された差分を、どの mode の不足または外部供給を示す indicator として読むのが安全である。

### 3.1 対応の原則: mode と担い手を分ける

本節で最も重要なのは、mode と担い手を混同しないことである。$M_b, M_r, M_a$ は「どの様式で持続するか」を表す。これに対して、その様式を担うのが base system 自身なのか、prompt 内の表現なのか、外部プロセスなのかは別問題である。§2 の formal notation では、外部供給分を $M_{x\to b}, M_{x\to r}, M_{x\to a}$ と書く。

したがって、外部システムが repair 型の作用を供給する場合、本稿ではこれを
\[
  M_x\text{-supplied }M_r
\]
と呼ぶ。これは shorthand であり、§2 の記法では $M_{x\to r}$ に対応する。$M_x$ は外部支援の channel を表し、$M_r$ は供給される持続様式を表す。つまり、

- in-context $M_r$: base system 内の $\gamma_r$ を prompt design によって誘導する。
- $M_x$-supplied $M_r$: 外部プロセスが repair / resolution を担い、その結果を base system に供給する。

この区別により、Paper 3 の scope-as-repair と外部代謝 ON/OFF を同じ「repair 的効果」として見つつ、供給階層の違いを失わずに記述できる。

### 3.2 Paper 3: 推論時矛盾と外部代謝

Paper 3 は、LLM 推論における未整理矛盾の効果を扱った。Paper 5 の観点から見ると、Paper 3 は主に次の二つを示している。

第一に、未整理矛盾は L 側の損失として働く。第二に、その損失を抑えるには、矛盾を範囲づける repair 型の作用が必要である。この repair は、prompt 内で誘導される場合もあれば、外部代謝プロセスによって供給される場合もある。

#### 3.2.1 Scope-as-repair / attribution-as-repair: in-context $M_r$

Exp.40 は、矛盾の有無ではなく、矛盾が task 外に範囲づけられているかどうかを前向きに比較した。32K 文脈に固定し、`zero_sanity`, `scoped`, `subtle`, `structural` を各 50 試行で比較した結果は次である。

| 条件 | 正答率 |
|---|---:|
| zero_sanity | 50/50 = 1.00 |
| scoped | 50/50 = 1.00 |
| subtle | 23/50 = 0.46 |
| structural | 0/50 = 0.00 |

`scoped` が `zero_sanity` と同水準に戻り、`subtle` と `structural` が崩れるという結果は、単に矛盾らしき文があるかどうかではなく、その衝突が task から範囲づけられているかどうかが重要であることを示した。Paper 5 の語彙では、これは base LLM の in-context $\gamma_r$ が prompt design によって誘導された indicator と読める。

Exp.42 は、この repair をさらに分解した。`strong_scope`, `medium_scope`, `weak_scope`, `subtle` の四段階で、正答率は次のようになった。

| 条件 | 正答率 | exact wrong-sum adoption |
|---|---:|---:|
| strong_scope | 50/50 = 1.00 | 0/50 |
| medium_scope | 49/50 = 0.98 | 0/50 |
| weak_scope | 42/50 = 0.84 | 1/50 |
| subtle | 10/50 = 0.20 | 25/50 |

row-level では、exact wrong-sum adoption が `subtle` の 25/40 mistakes = 0.625 から、`weak_scope` の 1/8 mistakes = 0.125、`medium_scope` / `strong_scope` の 0 へ落ちた。これは、明示命令だけでなく、参照元 attribution という最小の source label が contradiction-taking を大きく抑えることを示す。

この効果は外部プロセスによるものではない。prompt 内の source / dataset / temporal marker が、base LLM の解釈過程を修復方向へ誘導している。したがって、Paper 5 ではこれを in-context $M_r$ の indicator と呼ぶ。

Exp.41 は、この方向が `gpt-4.1-mini` 固有でないことを検査した。`gpt-4.1-nano` では `scoped=27/30 = 0.90`, `structural=1/30 = 0.03`、`gemini-3.1-flash-lite-preview` では `scoped=30/30 = 1.00`, `structural=14/30 = 0.47` であり、二つの primary model の両方で `scoped > structural` が成立した。ただし `subtle` と `structural` の相対順序はモデル依存であった。したがって、Paper 5 が受け取るべき invariant は、固定された subtle/structural ranking ではなく、scope marker が repair 的に働くという狭い方向である。

特に `gpt-4.1-nano` では `subtle=30/30 = 1.00` と天井に張りついたため、secondary ordering は固定的な invariant として扱わない。

#### 3.2.2 外部代謝 ON/OFF: $M_x$-supplied $M_r$

Paper 3 の対話実験では、未整理矛盾を外部で検出し、時間ラベルつきの更新対として整理する代謝パイプラインを ON/OFF で比較した。ここで ON は、矛盾更新を外部プロセスが整理し検索可能な形に保持する条件であり、OFF は同じ矛盾を未整理のまま混在させる条件である。

gemma3:27b の 180 ターン実験では、対話 LLM と代謝 LLM は同一モデルであるが、代謝は対話呼び出しとは別のプロセスとして行われる。規則＋事実の合算は次であった。

| 条件 | 規則＋事実 合算 |
|---|---:|
| ON | 73.3% |
| NC | 56.7% |
| OFF | 21.1% |

ON vs OFF は `p = 0.0004`, Cohen's `d = 8.80` であった。qwen3.5:27b の追試では、ON の代謝 LLM に Claude Sonnet を使用し、全体正答率は ON 64.4%、OFF 44.4% であった。

この効果は in-context marker とは階層が異なる。代謝 pipeline が、古い情報と新しい情報の衝突を検出し、旧値 -> 新値という範囲づけられた形へ変換してから base system に供給している。Paper 5 の語彙では、これは $M_x$-supplied $M_r$ の indicator である。

ここで $M_x$ は「外部に助けられている」という channel を表し、$M_r$ は「供給されている作用が repair / resolution 型である」ことを表す。同じ外部支援でも、冗長サーバを供給するなら $M_x$-supplied $M_b$、依存再編を供給するなら $M_x$-supplied $M_r$ と読むべきである。

さらに、qwen3.5:9b の代謝あり 100 ターン実験では、規則適用と矛盾検出が 87-100% の範囲で振動し、検索成功率は 96% で安定していた。これは単独では強い検証ではないが、$M_x$-supplied $M_r$ が機能し続ける限り、長期の制約蓄積がただちに単調崩壊へ向かわないことの示唆的 indicator である。

#### 3.2.3 Exp.36 / Exp.39: L の質と量の補助観察

Exp.36 と Exp.39 は、Paper 5 の mode 対応そのものではなく、L 側の質的構造が重要であることを示す補助観察として扱うのがよい。

Exp.36 は、3 モデル × 3 δ 水準 × 3 文脈長 × n=30、合計 810 試行で、文脈長と矛盾の質を操作した。Exp.39 はその中心的方向を prospective comparison として再検査した。これらの結果は、文脈長や制約数だけでは推論性能劣化を説明できず、構造的矛盾の質が大きく効くことを示す。

Paper 5 にとって、この観察は「mode の直接証拠」ではない。むしろ、$\gamma_i(R,\Sigma,F)$ の入力として、L 側の構造が raw count ではなく質的に効くことを示す背景である。したがって本節では、Exp.36 / Exp.39 を $M$ の mode 値に対応づけず、Paper 3 の L-side anchor として扱う。

### 3.3 Paper 4: LoRA 継続学習と依存再編

Paper 4 は、前提更新を伴う LoRA ベース継続学習が、知識を蓄積するのか、それとも上書きするのかを検査した。Paper 5 の観点から見ると、Paper 4 は $M_a$ と $M_r$ の分離を鋭く示している。

#### 3.3.1 LoRA 逐次更新: partial $M_a$, weak $M_r$

LoRA はパラメータを変えるため、局所的には adaptive な作用を持つ。新しい課題や前提更新に反応して表現を変えるという意味で、これは partial $M_a$ に近い。しかし Paper 4 の主要結果は、その適応が repair / resolution を代替しないことであった。

主要三条件の最終時点の結果は次である。

| 条件 | T5 依存整合性 | T5 更新成功率 | T5 時点の T1 保持 |
|---|---:|---:|---:|
| E-lite | 0.189 ± 0.096 | 0.400 ± 0.173 | 0.167 ± 0.289 |
| F-v2c | 0.333 ± 0.000 | 0.583 ± 0.144 | 0.000 ± 0.000 |
| F-multi | 0.367 | 0.500-0.750 | 0.500 |

最初の前提更新後、旧知識保持は全条件で急減した。これは、LoRA 更新が新しい信号に反応して表現を変える一方で、既存の派生知識との整合を自律的に取り直す $M_r$ を十分に持たないことを示す indicator である。

したがって、Paper 5 では LoRA を「partial $M_a$ はあるが weak $M_r$」として読む。ここでの $M_a$ は §2.3 の制限に従い、target function $F$ を保つ範囲での再編に限る。LoRA が別タスクへ乗り換えた場合、それは本稿の $M_a$ ではなく、対象 $F$ の変更である。

#### 3.3.2 F-v2c: $M_x$-supplied $M_r$

F-v2c は、前提と依存属性の関係を DAG として保持し、前提更新時に下流の依存属性だけを選択的に再提示する。これは、base LoRA update が持たない依存再編を、外部 controller が供給する条件である。

平均値では、依存整合性は E-lite の 0.189 から F-v2c の 0.333 へ改善した。一方、T5 時点の T1 保持は 0.000 であり、旧知識保持そのものは回復しなかった。この組み合わせは、F-v2c が「古いものをそのまま保存する」介入ではなく、「現在有効な前提に対して下流知識を整合させ直す」介入であることを示す。

Paper 5 の語彙では、F-v2c は $M_x$-supplied $M_r$ の indicator である。外部 controller が依存構造を持ち、base training process に対して repair-like な再提示を供給する。ただし、F-v2c は再提示件数や除外ポリシーも同時に変えているため、依存構造だけの寄与を完全に分離した実験ではない。この点は §6 の empirical route で、将来の ablation として扱う。

#### 3.3.3 F-multi: partial $M_b$ + partial $M_a$

F-multi は、現在知識と過去知識を別々のアダプタに分離する条件である。単一アダプタにすべてを混在させるのではなく、保持用の部分空間と現在用の部分空間を分けるため、Paper 5 では partial $M_b$ と partial $M_a$ の合成として読める。

F-multi は T5 時点の T1 保持を 0.500 まで上げ、E-lite や F-v2c にはない非ゼロ保持を与えた。ただし、これは理想振り分け、すなわち対象例が現在知識側か保持知識側かを既知として振り分ける条件である。したがって F-multi の結果は、実運用性能ではなく、空間分離が原理的に保持と更新の衝突を緩和しうることを示す上界 indicator として読むべきである。

F-multi が示すのは、部分空間分離によって一部の $M_b$ と $M_a$ は得られるが、それだけでは高忠実度の長期保持や依存整合の完全な repair には足りない、ということである。

### 3.4 Mode 対応表

以上をまとめると、Paper 3 / Paper 4 の観察は次のように mode indicator と対応づけられる。

| 観察 | 主な indicator | 供給階層 | 主要数値 / 方向 | 読み方 |
|---|---|---|---|---|
| Exp.40 scoped | in-context $M_r$ | base LLM + prompt | scoped 50/50, subtle 23/50, structural 0/50 | source / dataset scope が contradiction-taking を抑える |
| Exp.42 attribution | in-context $M_r$ | base LLM + prompt | wrong-sum adoption: subtle 25/40 mistakes -> weak 1/8 -> medium/strong 0 | 最小 source label が repair を誘導 |
| Exp.41 width | in-context $M_r$ の幅確認 | base LLM + prompt | scoped > structural in 2/2 primary models | invariant は scope protection |
| 外部代謝 ON/OFF | $M_x$-supplied $M_r$ | out-of-context process | gemma ON 73.3% vs OFF 21.1%; qwen ON 64.4% vs OFF 44.4% | 外部整理が未整理矛盾を時間ラベルつきに修復 |
| Exp.36 / Exp.39 | L-side quality anchor | 該当なし | 810 試行 + prospective comparison | raw context length ではなく構造の質が効く |
| LoRA sequential update | partial $M_a$, weak $M_r$ | parameter update | T1 retention collapse after premise update | 適応はあるが依存 repair は弱い |
| F-v2c | $M_x$-supplied $M_r$ | external controller + training signal | DC 0.189 -> 0.333, T1 retention 0.000 | DAG 沿いの選択的 repair |
| F-multi | partial $M_b$ + partial $M_a$ | adapter separation | T1 retention 0.500 under ideal routing | 空間分離による保持上界 |

この表は、既存結果を mode 値として再推定するものではない。既存結果は、それぞれの mode が不足している、または外部から供給されている、という方向を示す indicator である。

### 3.5 Paper 4 §7.5 の三役分離との接続

Paper 4 §7.5 は、持続知能に少なくとも三つの役割が必要であると述べた。第一にパラメータ的適応、第二に外部代謝、第三に応答生成の忠実化である。Paper 5 の mode 分解は、この三役分離を M 側の言葉で整理し直す。

| Paper 4 の役割 | Paper 5 の位置づけ | 注意 |
|---|---|---|
| パラメータ的適応 | partial $M_a$ | 新しい信号に反応するが、repair を代替しない |
| 外部代謝 | $M_{x\to r}$ (shorthand: $M_x$-supplied $M_r$) | 更新履歴と依存関係を外部で整理する |
| 応答生成の忠実化 | output-side realization | $M$ そのものではなく、保持された構造を出力へ反映する段階 |

ここで output-side realization は第五の mode ではない。これは、すでに保持・修復・再編された構造が実際の応答へ反映されるかどうかの出力段階であり、本稿の主予測である mode composition には含めない。

この対応により、Paper 4 の結論は Paper 5 の介入順位予測へ接続する。条件 (i) 内部に長期的な矛盾解消代謝機構を持たず、条件 (ii) 推論呼び出しの境界を越えて信念を持ち越す機構が弱い系では、最初に効く介入は単なる capacity 増強ではなく、$M_r$ の供給である可能性が高い。

Paper 3 では、これは in-context scope marker または外部代謝として現れた。Paper 4 では、F-v2c の依存 DAG controller として現れた。どちらも、raw resource を増やすのではなく、衝突をどう整理し直すかを変えている。この点で、Paper 3 / Paper 4 は Paper 5 の中心予測——同じ L、同じ R、同じ scalar $M_{\mathrm{total}}$ でも mode composition が違えば有効介入順位が異なる——への準備的根拠を与える。

### 3.6 非主張

本節の対応には、次の制限を置く。

1. 本節は $M_b^{\mathrm{int}}, M_r^{\mathrm{int}}, M_a^{\mathrm{int}}$ や $M_{x\to j}$ の数値を直接推定しない。
2. Exp.40 / 42 / 41 の scope 効果と、外部代謝 ON/OFF の効果が同一機構であるとは主張しない。共通しているのは repair-like な観測帰結であり、供給階層は異なる。
3. gemma3:27b の自己代謝と qwen3.5:27b + Sonnet の外部代謝を同一条件として合算しない。前者は coupled process、後者は teacher-like external process を含む。
4. F-v2c の改善を依存 DAG の寄与だけに還元しない。再提示件数、除外ポリシー、学習安定性が交絡しうる。
5. F-multi を実用性能として読まない。理想振り分け条件で得た上界 indicator である。
6. Exp.36 / Exp.39 は $M$-mode の直接証拠ではなく、L-side quality anchor として扱う。
7. DeltaLint、SAT、Mixed-CSP の $M$-mode 解釈は本節では扱わない。これらは §5-6 または別稿で扱う。

---

## §3 で更新される判断

**Resolved by §3 draft:**

- in-context repair と external metabolism は分離する。前者は in-context $M_r$、後者は $M_x$-supplied $M_r$ と呼ぶ。
- $M_x$ は同列の第四 mode ではなく、他 mode の外部供給 channel として読む。§2 の formal notation では $M_{x\to b},M_{x\to r},M_{x\to a}$ に分ける。
- Exp.36 / Exp.39 は $M$-mode ではなく L-side quality anchor として扱う。
- Paper 4 §7.5 の三役分離は、partial $M_a$ / $M_x$-supplied $M_r$ / output-side realization に対応づける。

**Still open after §3:**

- Q2 / Q8: DeltaLint を Paper 5 本論に入れるか、software pilot の別 note に切り出すか。
- Q4: four-domain comparison を本論に含めるか。
- Q7: validation protocol の primary split を time-split に固定するか、leave-one-project-out と同格にするか。
- §4-5: software / SaaS ドメインで $F, \Sigma, R, M_i$ を具体化する。
- §6: $\Phi$ choice と $\rho_i$ variation に対する robustness validation を設計する。

## 次のアクション候補

1. §4-5 (software / SaaS mapping) を起草する。§3 の mode 対応を、実際の software signals に落とす。
2. Q2 / Q8 を決める。DeltaLint を Paper 5 本論の empirical pilot に含めるか、独立 note に回すか。
3. §6 (validation protocol) を起草し、time-split / leave-one-project-out / log loss or Brier / Kendall tau / $\rho_i$ variation を事前固定する。
4. §1-3 をまとめて main preprint へ昇格するか、§4-6 まで review draft で進めるか判断する。

推奨順: 1 → 2 → 3 → 4。§3 により既存 Paper 3/4 の対応は整理されたため、次は software / SaaS の操作的 mapping へ進むのが自然である。
