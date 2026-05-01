補論_構造持続理論の構成地図
構造持続理論の構成地図
— Architecture Map / 読み順・層・依存関係 —

要旨

本補論は、構造持続理論の主理論 spine、companion papers、補論群、Lean 形式化、実証アンカーを、一つの構成地図として整理するための文書である。新しい定理、新しい実験、新しい support 判定を追加するものではない。目的は、どの文書がどの層の主張を担い、どの文書をどの順番で読むと誤読が少ないかを明示することである。

本稿群は、単一の長大な論文ではなく、最小核、回復を含む形式への拡張、条件つき導出、写像手順、M（有効維持余力）の操作化、許容写像、仕様固定構造レイヤー、構造推定レイヤー、条件付き構造埋め込みレイヤー、Lean 形式化を分けて書いている。本補論は、それらの役割、依存関係、主張強度を一つの地図として示す。

v3 では、個別ドメインを本文へ直接増殖させない。ドメインは `03_domains/registry.tsv` と個別 domain profile に登録し、support / no-support / outside rerun / field demonstration / bounded benchmark は `05_evidence/` に記録する。これにより、ドメインが増えても主理論 spine と主張境界が崩れないようにする。

Hard Evidence Snapshot

現時点で最も硬い経験的入口は、仕様固定構造レイヤーにある二つの凍結済み検証パッケージである。

| package | 外部再実行の状態 | 判定に関わる出力 |
|---|---|---|
| Mixed-CSP | 外部実行者 3 名による 3/3 clean rerun | 各 12,000 primary rows、checked core mismatches 0、support flags reproduced |
| q-coloring（内部パッケージ名 Exp43c） | 外部実行者 3 名による 3/3 clean rerun | 各 4,000 primary rows、checked core mismatches 0、TIMEOUT 0、MALFORMED 0、qualitative support decision reproduced |

これは普遍法則の閉包ではない。しかし、仕様固定構造レイヤーにおいて、\(L\) / first-moment 型の法則側座標が raw baseline と比較され、その凍結済み検証パッケージが著者環境外で同じ判定関係出力を返したという意味で、local rerun や単なる手順公開より強い package-scoped replication support である。詳細は [`../05_evidence/outside_reruns.tsv`](../05_evidence/outside_reruns.tsv) と [`../../analysis/g7_route_a_true_outside_replication_summary.md`](../../analysis/g7_route_a_true_outside_replication_summary.md) に置く。


1. この地図が与えるもの

本補論が与えるのは、次の三つである。

| 項目 | 役割 |
|---|---|
| 層の地図 | 主理論、操作化、実証アンカー、形式化を分ける |
| 読み順 | 読者向けの最短導線と、論理依存順を分ける |
| 主張強度の位置づけ | 仕様固定構造レイヤー / 条件付き構造埋め込みレイヤー / 構造推定レイヤー、G6-a / G6-b / G6-c、support status の混同を避ける |

本補論が与えないものは、次の三つである。

| 非主張 | 理由 |
|---|---|
| 新しい理論核 | 主理論核は Paper 1 / Paper 2 にあり、条件つき導出と集合値力学はそれを支える技術補論である |
| 新しい経験的 support | 経験的 support は凍結検証、fresh archive、outside rerun で別途定まる |
| 普遍法則の宣言 | 普遍性の評価は観測可能性レイヤーごとの evidence と外部再現の蓄積に依存する |


2. 七層の構成

本稿群は、次の七層として読むのが最も自然である。

| レイヤー | 役割 | 主な文書 |
|---|---|---|
| Layer 0: Map / Discipline | 読み順、主張強度、support 判定、沈黙条件を定める | 本補論、補論「構造持続理論の運用規律」、補論「構造持続写像の標準手順」 |
| Layer 1: Entry | 全体像と外向け主導線を読む | Paper 0 統合版、Core Paper「構造持続の最小核と収支原理」 |
| Layer 2: Foundation | 回復を明示しない最小核 | Paper 1 最小形式 |
| Layer 3: Core Extension | 構造消耗量と回復量を含む指数核 | Paper 2 収支原理、条件つき導出補論、集合値力学補論、定常総生成量補論、定常 current 補論、trajectory-ratio bridge 補論、許容写像補論、収支原理の詳細展開補論 |
| Layer 4: Operational Mapping | 現実ドメインへの写像、M（有効維持余力）、設計原理 | 補論「構造持続写像の標準手順」、補論「M（有効維持余力）の操作的定式化」 |
| Layer 5: Anchors / Bridges | 仕様固定構造レイヤー、構造推定レイヤー、条件付き構造埋め込みレイヤーのアンカー | CSP 補論、計算コスト補論、LLM companions、Foster-Lyapunov 補論、非CSP補論 |
| Layer 6: Formal Layer | Lean theorem、reader-facing claim、numerical sanity check の対応 | Lean modules, PAPER_MAPPING, NumericalSanityChecks |

このレイヤー分けで重要なのは、文書の重要度を順位づけることではない。重要なのは、役割を混ぜないことである。たとえば LLM companion は主理論核の証明ではなく、主理論核を LLM 推論や継続学習へ写した構造推定レイヤーの観測的アンカーである。Foster-Lyapunov 補論は、新しい安定性定理の証明ではなく、既存の drift calculus が構造持続の純消耗量 \(b_t\) へ条件付きに埋め込めることを示す bridge である。

また、Layer 2 を Foundation と呼ぶのは、それが自明な前提だからではない。Paper 1 は、構造喪失を維持可能領域の縮小として定式化し、対数比尺度を一意化し、事後的表現選択による空虚化を防ぐ第一の非自明な主理論層である。Paper 2 は、その非自明な最小形式を回復を含む系へ拡張する。


3. 最短読順

外向きに最も短く読むなら、次の順でよい。

1. `01_theory/00_map.md`
2. `01_theory/01_overview.md`
3. `01_theory/02_core.md`
4. `01_theory/10_paper1_minimal_form.md`
5. `01_theory/11_paper2_balance_principle.md`
6. `CLAIMS.md`
7. `03_domains/registry.tsv`
8. 必要な domain profile
9. 必要に応じて `04_operations/`, `02_foundations/`, `05_evidence/`

この順序は、読者の認知負荷を下げるための順序である。Core Paper は Paper 1 / Paper 2 を外部読者向けに一つの導線として読むための統合短論文であり、分冊版の置き換えではない。論理依存そのものは、Paper 1 -> Paper 2 を主線とし、条件つき導出補論、集合値力学補論、定常総生成量補論、定常 current 補論がその背後の技術条件を支える。trajectory-ratio bridge 補論は、stochastic thermodynamics 側の path-ratio 構造に進む前の追加仮定を固定し、有限 path-ratio identity、その有限状態 Markov path specialization、structural observable residual coupling を Lean 上で閉じた bridge である。


4. 論理依存順

理論核だけを硬く追うなら、次の順で読む。

| 順序 | 文書 | 役割 |
|---|---|---|
| 1 | Paper 1 | 構造維持可能集合の縮小、対数比尺度の一意性、空虚化防止条件から S = M exp(-L) を得る |
| 2 | Paper 2 | S = M exp(-L) を、回復量を含む S = M exp(-B) へ拡張する |
| 3 | 条件つき導出補論 | どこまでが恒等式で、どこからが弱依存・確率条件に依存するかを分ける |
| 4 | 集合値力学補論 / 定常総生成量補論 / 定常 current 補論 / trajectory-ratio bridge 補論 / 許容写像補論 / 詳細展開補論 | d_t, r_t, b_t, B_n の pathwise kernel、定常維持と housekeeping cost の分離、定常 pair-flow と detailed balance の分離、finite path-ratio identity とその追加仮定、許容写像の階層、応用上の背景を整理する |
| 5 | Lean mapping | 対応する代数核と finite-horizon skeleton が機械検証されている範囲を確認する |

この順序で読むと、構造推定レイヤーの経験的主張や設計原理に入る前に、理論核の範囲を確認できる。


5. 中心式と内部定義

本稿群の reader-facing な中心式は、次の二つである。第三行は、回復を含む式に入る内部定義である。

| レイヤー | 式 | 読み方 |
|---|---|---|
| 最小核 | S = M exp(-L) | 累積構造消耗量 L が構造持続ポテンシャルを指数的に削る |
| recovery-aware | S = M exp(-B) | 累積純消耗量 B が、回復を含む構造持続ポテンシャルを決める |
| internal definition | B_n = sum_{t<n}(d_t-r_t) | 消耗量 d_t から回復量 r_t を差し引いた純消耗量の累積 |

対象期間が文脈上固定されているとき、読者向けには \(S=Me^{-B}\) と書ける。有限時間地平を明示するときは \(B_n\), \(S_n\), \(M_n\) を付ける。ここで添字 \(n\) は、時点または期間を固定していないことを明示するためのものであり、式の思想を変えるものではない。


6. 観測可能性の三つのレイヤー

本理論は、同一の構造持続核を、観測可能性と主張強度の異なる三つのレイヤーで扱う。各レイヤーは異なる理論ではなく、同一の構造持続核を異なる観測レベルで扱ったものである。これは対象ドメインの固定分類ではない。同じ LLM でも明示制約タスクなら仕様固定構造レイヤーに近づき、同じ物理・生物・ソフトウェア系でも観測・推定指標しか取れない場合は構造推定レイヤーに入る。これは「構造は常にある」という主張ではない。維持対象・測度・観測単位を固定できる場合に、その系を構造持続問題として扱う、という規律である。

観測可能性の軸は次のように読む。

| 方向 | 意味 |
|---|---|
| ↑ 観測可能性が高い | 構造、測度、境界を仕様として直接指定できる |
| ↓ 観測可能性が低い | 構造そのものを直接数えず、観測・推定指標と凍結検証で推定する |

三つのレイヤーに共通する核は
\[
  S=Me^{-L},
  \qquad
  S=Me^{-B},
  \qquad
  B_n=\sum_{t<n}(d_t-r_t)
\]
である。違うのは式ではなく、その式に入る \(V,m,d_t,r_t\) をどの程度直接指定・観測できるかである。

| 外向け名 | 条件 | 現在の代表例 |
|---|---|---|
| 仕様固定構造レイヤー | 構造、測度、境界が仕様から事前固定される | SAT, Mixed-CSP, q-coloring, Bernoulli-CSP interface |
| 条件付き構造埋め込みレイヤー | 既存理論のドリフト、差分、停止境界を本理論の変数へ条件付きに写す。縦軸の中間段階ではなく、既存理論との横方向の橋渡しである | Foster-Lyapunov / queueing drift, bounded approximation candidates |
| 構造推定レイヤー | 構造そのものを直接数えるのではなく、観測・推定指標と凍結検証によりその効果を推定する。多くの現実系で標準的な観測形である | LLM 推論劣化、継続学習、software contract-coherence 系 |

仕様固定構造レイヤーは、法則側定理または限定クラス普遍性を狙うレイヤーである。構造推定レイヤーは、自然測度が直ちに得られない現実ドメインで、観測指標と凍結写像により追加予測力、診断、介入候補を検査するレイヤーである。構造推定レイヤーの support は、主理論核の証明ではなく、凍結写像が out-of-sample に追加予測力を持つかによって決まる。

この意味で、普遍性主張はまず仕様固定構造レイヤーの限定クラス普遍性定理として評価される。構造推定レイヤーでは、同じ座標を観測・推定指標と凍結検証によって実世界に写し、予測的・操作的 support を蓄積する。したがって、構造推定レイヤーでの no-support は直ちに理論核の反証ではなく、観測・推定指標設計または写像手順の失敗として記録される。

この配置で重要なのは、構造推定レイヤーの観測・推定指標を法則そのものと混同しないことである。推定指標が \(L/B\) の法則側座標をよく近似していることが凍結検証で確認されるほど、その指標は説明語彙から予測装置へ近づく。\(M\) はこの座標に混ぜ込まず、有効維持余力を表すリソース側のスカラーとして別に読む。ただし、その近似度は主観的に宣言されるものではなく、held-out / future / fresh archive / outside rerun における baseline + SP の増分、または no-support / silence として判定される。

Software contract-coherence 系は、この構造推定レイヤーの中でも、ソフトウェア崩壊そのものではなく、分散契約矛盾という早期シグナルを検査する operational track として扱う。構造は、API / caller、config / runtime、documentation / implementation、lifecycle producer / consumer などにまたがる contract set である。この track は二層に分ける。第一に、外部 OSS での merged PR は field demonstration / maintainer-acceptance evidence であり、実運用上の有用性を示すが、raw precision / recall ではない。第二に、contract-coherence benchmark の主比較は provider 間競争ではなく、同一 model・同一 frozen context で generic review と structural-lens review を比較し、bounded validation 後の unique valid structural root causes が増えるかで判定する。DeltaLint はこの track の現在の実装名である。


7. G6-a / G6-b / G6-c の配置

既存理論との接続は、次の三段階に分ける。

| 強度 | 意味 | 注意 |
|---|---|---|
| G6-a analogy | 直感や語彙が似ている | 証明ではない |
| G6-b correspondence | 量・符号・役割の対応表が作れる | 構造対応であって定理移植ではない |
| G6-c formal embedding | 既存理論の差分・drift・balance が b_t, B_n へ埋め込める | 元理論の仮定は保持される |

Foster-Lyapunov / queueing drift の補論は、G6-c iteration 1 として位置づける。すなわち、正再帰性や幾何的エルゴード性を新しく証明するのではなく、既存の drift algebra が構造持続の \(b_t=d_t-r_t\) と同じ符号構造を持つことを、reader-facing かつ Lean 対応可能な形で示す。


8. Bernoulli-CSP universality interface の位置

本稿群の数学的核は、指数式だけではない。もう一つの核は、Bernoulli-CSP universality interface である。

この interface は、k-SAT、NAE-SAT、XOR-SAT、q-coloring、hypergraph coloring、finite-alphabet forbidden-pattern CSP、cardinality-SAT、threshold-cardinality-SAT を、同じ finite-horizon / iid bad-event exposure の型に載せる。これにより、個別構文の違いではなく、禁止パターンが有効状態空間をどれだけ削るかという共通座標で読める。

このレイヤーは、現在は主に Lean modules と集合値力学補論の後半にある。読者が仕様固定構造レイヤーの横断性を評価するときは、PAPER_MAPPING と Bernoulli-CSP universality modules を参照するのがよい。さらに、NumericalSanityChecks は、各 wrapper が小さな具体例で期待される定数を返すことを示す。これは経験的 support ではなく、reader-facing な numerical sanity check である。


9. 許容写像と階層的不変量

補論「構造持続における許容写像と階層的不変量」は、観測可能性の三つのレイヤーを数学的に読み直すための深部補論である。そこでは、構造維持問題を対象、その間の許容写像を射として扱い、同型では \(B_n\) が不変、正ゲージ変更では \(B_n\) が共変、粗視化では保存・単調性・誤差境界の条件が必要、観測指標による推定では凍結後の追加予測力で評価する、という階層を置く。

この補論の役割は、第二法則級の単一普遍法則を宣言することではない。むしろ、仕様固定構造レイヤー、条件付き構造埋め込みレイヤー、構造推定レイヤーが、強弱のラベルではなく、どの写像で何が保たれるかの違いであることを明確にする。Bernoulli-CSP interface の自然性も、SAT 風の構文を後から集めたものではなく、iid bad-event exposure と log-drift を保つテンプレート保存写像で閉じた限定クラスとして読む。


10. 限定クラス統一 interface

Lean 形式化の Phase 7 v2 は、三つの登録済み限定クラスが共通の構造持続 interface を満たすことを示す reader-facing anchor である。対象は Bernoulli-CSP、Foster-Lyapunov / queueing、Repair-Maintenance であり、共通 interface は次の四要素からなる。

| 要素 | 役割 |
|---|---|
| ordered Sigma carrier | 累積量 Sigma_n を順序つきの量として読む |
| nonnegative tendency driver | 期待値または傾向レベルで非負方向を生む駆動構造を持つ |
| finite-horizon certificate route | Chernoff、Azuma、資源制約境界など、有限地平の certificate 経路を持つ |
| admissible-transfer guard | 許容写像で転用するときの保存・共変・境界条件を明示する |

この interface は、全ドメインに対する単一の普遍不等式ではない。むしろ、登録済み限定クラスを同じ形式で比較し、新しい候補クラスを追加するときに何を検査すべきかを定める拡張可能な枠である。Lean 側の対応は `Survival.CrossClassUnificationV2`、読者向けの整理は `analysis/phase7_unifying_schema_v2.md` に置く。


11. 構造粒度と多階層性

構造持続理論では、自然な \(V,m\) が常に一つの階層で一意に決まるとは限らない。多くの系では、構造は入れ子状・多階層的であり、下位構造の消耗、上位構造の制約、階層間の依存、回復量の伝播が相互作用する。

したがって、現実ドメインへの適用では、まず構造粒度を定める必要がある。構造粒度とは、維持対象をどの細かさ、どの階層、どの境界で見るかである。これはドメイン写像の一部である。ただし、その選択を support と呼ぶには、写像を凍結した後に別データ・別時期・別条件で検証する必要がある。


12. この地図の使い方

各補論には、その文脈で必要な限界と非主張を短く残す。ただし、観測可能性の三つのレイヤー、G6 分類、mapping status、support 判定、silence 条件の完全な定義は、補論「構造持続理論の運用規律」と補論「構造持続写像の標準手順」に集約する。

この分担により、各補論は自分の数学的核または経験的核に集中できる。全体の規律は失われず、むしろ独立した参照点として見えるようになる。
