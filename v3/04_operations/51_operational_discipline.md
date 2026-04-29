補論_構造持続理論の運用規律
構造持続理論の運用規律
— Operational Discipline / 写像・支持・沈黙の基準 —

要旨

本補論は、構造持続理論を現実ドメインへ適用するときの運用規律をまとめる。中心にあるのは、理論核と写像発見を分けることである。理論核は、事前固定された構造維持問題に対する会計的・代数的制約である。一方、現実ドメインでは、維持対象、構造粒度、測度、構造消耗指標、回復指標を探索的に発見する段階がある。この探索は許される。しかし、その同じ探索データ上の説明を support と呼んではならない。

Support と呼べるのは、写像・特徴量・baseline・metric・split・実行手順を凍結した後、holdout / future / fresh archive / outside rerun で、事前に定めた基準を満たした場合に限る。この補論は、その判定語彙を明示する。


1. 基本方針

構造持続理論の経験的運用は、次の二段階で行う。

| 段階 | 目的 | 許されること | support との関係 |
|---|---|---|---|
| 探索的写像フェーズ | ドメインの維持対象、測度、指標、介入候補を発見する | 候補生成、比較、再定義、proxy 探索 | support ではない |
| 凍結検証フェーズ | 見つけた写像が予測力を持つか検証する | 事前固定された手順で holdout / future / fresh archive / outside rerun を行う | ここで初めて support / no-support を判定する |

この区別により、探索的に見つけた説明をそのまま検証済みと呼ぶことを避ける。同時に、探索的な候補生成そのものは研究過程の一部として認める。


2. 理論核と写像発見

理論核は、次の形で読む。

| 核 | 内容 |
|---|---|
| 回復量を含まない最小核 | 構造維持可能集合の縮小を対数比で測ると S = M exp(-L) が現れる |
| recovery-aware kernel | 消耗量 d_t と回復量 r_t の差し引きにより B_n = sum(d_t-r_t), S = M exp(-B) が現れる |
| pathwise identity | 正の有限軌道では m(V_n) = m(V_0) exp(-B_n) が望遠鏡積として成り立つ |

この核は、写像が事前固定された構造維持問題に対する代数的制約である。現実ドメインでは、どの \(V\)、どの \(m\)、どの \(d_t\)、どの \(r_t\) が自然かを発見する作業が別に必要になる。

この別作業を、写像発見と呼ぶ。写像発見は理論の外ではない。むしろ、理論を経験科学として動かすための必要な入口である。ただし、写像発見そのものは support ではない。


3. Mapping status

写像の状態は、次の語彙で固定する。

| status | 意味 | 使用条件 |
|---|---|---|
| candidate mapping | 探索的に見つけた写像候補 | 同じデータ上で見つけた段階 |
| frozen mapping | 特徴量、baseline、metric、split、実行手順を固定した写像 | outcome-bearing run の前に manifest 化した段階 |
| weak support | frozen mapping が単純 baseline を上回る | ただし専門 baseline や wide baseline には未達の場合を含む |
| incremental support | domain baseline + SP が domain baseline を out-of-sample に上回る | 既存モデルへの追加予測力が出た段階 |
| strong support | 複数 split、複数 archive、複数 family、または outside rerun で再現する | 効果が単一設定に依存しにくい段階 |
| no-support | 事前定義された primary rule を満たさない | 結果に合わせて同一 archive 内で rescue しない |
| silence | 理論が主張しない、または写像を凍結できない | 維持対象・測度・endpoint が不自然な場合 |

SP は structural persistence coordinate の略であり、構造持続理論から導かれる構造消耗、回復、余力、代替経路などの指標群を指す。


4. 予測力の増分検証

構造持続理論の経験的価値は、常に SP-only が最強の単独モデルになることではない。多くの現実ドメインでは、既存専門モデル、既存 risk score、強い ML baseline がすでに存在する。

したがって、中心的な検査は次である。

| 比較 | 意味 |
|---|---|
| simple baseline vs SP-only | 構造座標が単純量を越えるか |
| domain baseline vs SP-only | 構造座標だけで既存専門モデルに迫るか |
| domain baseline vs domain baseline + SP | 構造座標が追加予測力を持つか |
| wide baseline vs compressed SP | 生特徴量の広いモデルより圧縮構造座標が効くか |

主検査は、しばしば `domain baseline + SP > domain baseline` である。これは、構造持続理論が既存分野を置き換えるという主張ではなく、既存分野の強いモデルに横断的な構造座標を追加するという主張である。


5. 観測可能性の三層

本理論は、同一の構造持続核を、観測可能性と主張強度の異なる三つの層で扱う。各層は異なる理論ではなく、同一の構造持続核を異なる観測レベルで扱ったものである。この分類は、対象ドメインの価値を順位づけるものでも、CSP や LLM のような対象名に固定ラベルを貼るものでもない。構造、測度、境界をどこまで事前固定できるか、あるいは代理指標と凍結検証でどこまで推定するかを分けるための運用語彙である。同じ対象でも、明示制約タスクでは仕様固定構造層に近づき、観測単位が代理指標に限られる場合は構造推定層に入る。

観測可能性の軸は、上に行くほど構造、測度、境界を仕様として直接指定できることを意味する。下に行くほど、構造そのものを直接数えず、代理指標、凍結写像、追加予測力によって構造持続核を推定する。全層に共通する核は \(S=Me^{-L}\), \(S=Me^{-B}\), \(B_n=\sum_{t<n}(d_t-r_t)\) であり、違うのは核そのものではなく、それに入る量の観測可能性である。

| 外向け名 | 判定基準 | support の読み方 |
|---|---|---|
| 仕様固定構造層 | 状態空間、測度、構造消耗、collapse boundary が仕様から事前固定される | theorem-side / finite-horizon / prospective empirical support を強く読む |
| 条件付き構造埋め込み層 | 既存理論のドリフト、差分、停止境界を \(b_t,B_n\) などへ条件付きに写せる。仕様固定層と構造推定層の中間ではなく、既存理論との横方向の bridge として読む | 限定主張として読む |
| 構造推定層 | proxy、観測指標、操作的写像によって検査する。多くの現実系ではこの形が標準的な観測形になる | empirical anchor / operational support として読む |

仕様固定構造層は、law-side theorem または限定 class universality を狙う場所である。条件付き構造埋め込み層は、既存理論との formal bridge を作る場所である。構造推定層は、LLM、software、組織、maintenance log のような現実ドメインで、観測指標と凍結写像により予測力、診断、介入候補を検査する層である。したがって構造推定層は劣化版ではなく、現実系において構造を直接数えられないときの標準的な入口である。ただし構造推定層の成功を、仕様固定構造層の定理的成功と同じ強さで書いてはならない。

この分離は failure ledger の読み方にも関わる。仕様固定構造層で事前固定された theorem-side / primary empirical rule が失敗する場合、それは理論側または class universality 側の反証候補になりうる。一方、構造推定層で proxy が外れる場合、それは直ちに理論核の反証ではなく、proxy 設計、観測単位、endpoint、または写像手順の失敗として記録する。

この分類は、「構造は常にある」という主張ではない。維持対象・測度・観測単位を固定できる場合に、その系を構造持続問題として扱う。固定できない場合、または観測単位が不安定な場合は、silence または mapping failure として記録する。


6. G6 connection strength

既存理論との接続は、次の三段階で書く。

| 強度 | 定義 | 禁止される誤読 |
|---|---|---|
| G6-a analogy | 似た語彙・直感・図式がある | 証明済み接続とは呼ばない |
| G6-b correspondence | 量、符号、役割の対応表がある | 元理論の定理を導いたとは言わない |
| G6-c formal embedding | 元理論の差分・drift・balance を構造持続変数へ埋め込める | 元理論の仮定を消したとは言わない |

Foster-Lyapunov / queueing bridge は G6-c の例である。ただし、そこで成立するのは drift algebra の埋め込みであって、positive recurrence や geometric ergodicity の新証明ではない。


7. Law-side upgrade gate

非CSPで law-side に近づくには、少なくとも次の三条件が必要である。

| 条件 | 意味 |
|---|---|
| natural m | ドメイン仕様から状態空間と測度が自然に固定される |
| observable r_t | 回復量または維持入力が、事後推定ではなく観測可能な量として記録される |
| boundary condition | collapse / hitting / maintenance boundary が条件つきで読める |

queueing / Foster-Lyapunov は、この gate のうち formal bridge 側をかなり満たす。repair / maintenance log は、observable \(r_t\) を取りに行けるため、現実側の有力候補である。ただし、公開データで \(r_t\) が直接見えない場合は、repair-flow primary ではなく stochastic reliability bridge または maintenance-boundary candidate として扱う。


8. Domain transfer rule

構造持続理論の価値は、ドメイン横断の設計転用にもある。あるドメインで効いた維持設計は、別ドメインの candidate intervention を作る手がかりになる。

例として、LLM で scope-as-repair が効くなら、software や組織でも、衝突情報を範囲づける設計が効くかもしれない。継続学習で dependency-aware replay が効くなら、企業や制度変更でも、上流前提が変わったときに下流判断を再同期する仕組みが効くかもしれない。

ただし、転用されるのは support ではなく candidate mapping である。A ドメインで効いた設計は、B ドメインでの仮説生成器になる。B ドメインでの support は、B 側で凍結検証して初めて成立する。


9. 構成物としての理論

本稿群では、理論を単一の長文としてではなく、検証可能・保守可能・拡張可能な構成物として扱う。そのために、主理論 spine、companion papers、補論、Lean theorem mapping、numerical sanity checks、no-support / silence 判定を分ける。

ここで重要なのは、語彙ではなく運用である。責任境界を分ける。差し替え可能な interface を作る。小さな具体例で抽象 wrapper を検査する。失敗した primary result は、同一 archive 内で rescue せず、no-support または silence として保存する。このため、本稿群では Lean theorem mapping と並んで、numerical sanity checks を文書化された小検査として扱う。


10. Non-claims

本稿群の補論や実証アンカーは、次を主張しない。

| 非主張 | 理由 |
|---|---|
| 任意の系に自然な V,m がある | 構造粒度と維持対象が定まらない系では沈黙する |
| 探索的写像がそのまま support である | support は凍結後検証でのみ成立する |
| SP-only が常に最強モデルである | 既存専門モデルへの追加予測力が主な勝ち筋になる場合が多い |
| 構造推定層の成功が仕様固定構造層の定理的成功を意味する | 証拠強度が異なる |
| G6-c が元理論の仮定を不要にする | formal embedding は仮定を保存する |
| no-support が理論核の反証である | 通常は写像、proxy、endpoint、そのドメインでの適用可能性の失敗を意味する |
| silence が敗北である | 理論が黙るべき系を識別することも規律の一部である |


11. 補論間の参照規則

各補論は、この運用規律を全文再掲する必要はない。各補論には、その補論固有の local guardrail を短く残す。観測可能性の三層、G6 分類、mapping status、support / no-support / silence の完全定義は、本補論と補論「構造持続写像の標準手順」を参照する。

この方針により、補論群は重複を減らしつつ、限界の明示を弱めずに済む。構造持続理論の強さは、広い対象を同じ語彙で読むことだけではなく、どこまで言えて、どこから先はまだ言えないかを明確に分けることにもある。
