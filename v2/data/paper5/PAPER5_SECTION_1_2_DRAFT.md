# Paper 5 §1-2 Review Draft

Status: review draft, not a main preprint.

Date: 2026-04-22

Source: `PAPER5_DRAFT_PLAN.md`, `paper5_メモ.md`

Target file on promotion: `v2/5_構造持続における資源項Mの操作的定式化.md`

Scope of this draft: §1 はじめに と §2 最小形式 のみ。§3 以降および正式な要旨は、§2.5 の表現規律の暫定方針 (Q6 / D2) と、§2.2 の mode / channel 分離を前提として、後続 draft で起草する。

---

構造持続における資源項 M の操作的定式化
— 有効維持能力の mode 分解と介入順位予測 —

(要旨は §1-2 確定後に起草)

## 1. はじめに

構造持続理論の既存の分冊は、主として L の側、すなわち「構造を維持できる状態の集合がどれだけ削られたか」を扱ってきた。Paper 1 は、損失尺度の公理系 B1–B4 から対数比の一意性定理を導き、残存可能性の指数表現
\[
  m(V^{(n)}) = m(V^{(0)}) e^{-L_n}
\]
を恒等式として与えた。Paper 2 は、この指数表現が A1–A2 のもとで恒等式として成り立ち、段階損失生成過程の弱依存のもとでも指数境界として安定に保たれることを述べた。Paper 3 は、LLM の長期対話において未整理矛盾が有効推論経路を削る過程を 810 試行と対話実験で示し、Paper 4 は、LoRA ベース継続学習において、前提更新が依存知識の再編を壊す破滅的忘却を示した。

これらはいずれも L という「削られる側」の座標を具体化する方向に集中している。

本稿は新しい普遍法則の証明ではない。本稿は、支える側の操作的座標系である。
Paper 1/2 が与えた structural loss $L$、および Paper 3/4 で経験的に観察された
loss / support の相互作用を前提として、どの maintenance mode を最初に強化すべきかを問う。
本稿の固有の主張は、よりよい risk prediction そのものではなく、mode 分解にもとづく
intervention ranking である。

しかし、Paper 1 の最小形式
\[
  S = M e^{-L}
\]
には、もう一つの側がある。有効維持資源 M である。M は「L と独立に、構造がどれだけ持ちこたえられるか」を担う量として導入されたが、既存分冊ではその内部構造はほとんど議論されていない。補論「構造持続写像の標準手順」 (以下 補論B と呼ぶ) は運用展開
\[
  S = N_{\mathrm{eff}}^{(0)} \times (\mu / \mu_c) \times e^{-L}
\]
を与え、M を初期有効選択肢多様性 $N_{\mathrm{eff}}^{(0)}$ と有効余力 $\mu$ の積として解体しているが、この展開のうち、何が「耐える」作用で、何が「戻す」作用で、何が「作り変える」作用で、何が「外から支える」作用かは、区別されないままである。

### 1.1 スカラー M の限界

現行のスカラー M では、次のような観察が記述できない。

- 同じ L を受け、同じ raw resource R を持つ二つの系が、異なる介入を必要とする。
- 資源が潤沢にあるにもかかわらず、機能が維持できない。
- 崩壊の仕方が系ごとに質的に異なる (即時、徐々、相転移)。
- 介入として有効なのが、緩衝投入か、回復能力強化か、構造再編か、外部支援かが系によって異なる。

これらはいずれも「削られ方」の差ではなく、「支え方」の差である。L 側の解像度をいくら上げても、この差は出てこない。現行スカラー M は、これらの質的差を単一数量に押し込めてしまい、区別の余地を残していない。

### 1.2 本稿の問い

本稿の問いは、一文に要約される。

\begin{quote}
同じ L を受け、同じ R を持つ二つの系で、必要な介入が違うのはなぜか。
\end{quote}

この問いに答えるには、M をスカラーのまま扱うのをやめ、「構造が持ちこたえる様式」ごとに分解する必要がある。本稿はその最小の定式化を与えることを目的とする。

### 1.3 立場と範囲

本稿の立場は、Paper 1–4 および補論群と整合するように、以下のように限定する。

- 本稿は M の完全理論ではない。現行スカラー M を mode ベクトルへ分解するための分析フレームである。
- 本稿は**介入順位予測**を主予測として一つだけ押す。崩壊プロファイルや時間発展主張は後続の拡張とみなす。
- 本稿は最初のドメインとしてソフトウェア / SaaS を置き、four-domain comparison や普遍理論の宣言には進まない。
- 本稿は Paper 1 §3 の対数比の一意性定理と対応する設計原理 (関数形を任意に選ばず、公理で候補族を制限する) を M 側に移植する。ただし、§2.5 の表現規律は Paper 1 §3 と同じ強度の一意性定理ではない。積型・bottleneck 型・CES 型を候補族として明示し、どの選択でも主予測が保たれるかを §6 の robustness validation で検査する。
- 本稿は Route A の普遍法則宣言を行わない。ソフトウェアは Route C として扱う。

ここでいう介入順位予測とは、同じ L、同じ R、同じスカラー量 $M_{\mathrm{total}}$ のもとで、異なる mode 構成を持つ二つの系では、有効な介入の順位が異なるという予測である。これは静学式 $S = \Phi(M) e^{-L}$ の範囲で検査可能であり、補論B の手順 4.5 (基準モデルに対する追加予測力) に直接対応する。

本稿で扱う対象構造は、Paper 1 §2 の適用可能性条件 P1–P5 を満たすもの、すなわち観測前に対象構造・測度・制約列・時間地平が事前固定された構造維持問題に限る。観測後に F、$\Sigma$、R、mode 集合を選び直してよいなら、本稿の予測は事後的適合によって空虚化するからである。

### 1.4 Paper 3 / Paper 4 との概観的接続

§2 の mode 分解を置くと、Paper 3 と Paper 4 の具体的観察は、それぞれ M の異なる mode として自然に読み直される。詳細な対応は §3 に委ねるが、概観を述べておく。

- Paper 3 の scope-as-repair および attribution-as-repair は、「source 分離」という最小の外部整理作用として働き、未整理矛盾による有効 L 蓄積を局所的に削減する。本稿の枠組みでは、これは外部から供給された $M_r$ 型の作用として読める。
- Paper 3 の外部代謝 ON/OFF 実験は、対話 LLM 単体では欠けていた $M_r$ が外部から供給された効果の直接観察として位置づけられる。
- Paper 4 の LoRA 逐次更新が「蓄積ではなく上書き」に振る舞う結果は、パラメータ更新が $M_a$ に近い部分作用を持つが $M_r$ を代替しないという、mode 分離の経験的支持として読める。
- Paper 4 の F-v2c は依存構造に沿った選択的再提示によって外部 $M_r$ を運用した結果、F-multi は空間分離による部分的 $M_b$ / $M_a$ の模倣と読める。

これらの接続は、本稿の mode 分解が既存観察に対する事後的再記述にとどまらず、異なる分冊で観察された現象を共通の座標で読むための座標系を提供することを示唆する。詳細な対応表と、各 mode の Paper 3/4 における具体的指標は §3 で与える。

## 2. 最小形式

### 2.1 F / Sigma / R / M の 4 層

構造を維持できるかどうかは、単に「資源がどれだけあるか」の問題ではない。何を守ろうとしているのか、どの構造を通して守るのか、その構造が素材をどれだけ実効能力に変換できるのかによって決まる。本稿では、この区別を次の 4 層で明示する。

- $F$: 守りたい機能 (target function)
- $\Sigma$: その機能を担う構造
- $R$: 資源素材 (raw resource stock)
- $M$: 有効維持能力 (effective maintenance capacity)

ここで $F$ と $\Sigma$ は、Paper 1 の $V^{(0)}$ および測度 $m$ の具体化に対応する。どの構造の持続を問題にしているかを決めるのが $F$ と $\Sigma$ である。$R$ は、系が素材として持っている stock である。予算、人員、時間、エネルギー、容量、冗長要素などが該当する。$M$ は、その $R$ が「$F$ を守るための実効能力」にどれだけ変換されているかを表す量である。

重要なのは、$R$ と $M$ を混同しないことである。現金はあるが承認権限が詰まっている、病床はあるが看護師がいない、キャッシュはあるが設定ミスで効かない、という状況はすべて「$R$ はあるが $M$ は小さい」と書ける。本稿の mode 分解が意味を持つのは、この区別が最初から明示されているからである。

### 2.2 Mode と供給 channel の定義

本稿では、$M$ をスカラーではなく、持続の様式と供給 channel に分けて扱う。初期の shorthand として
\[
  M = (M_b, M_r, M_a, M_x)
\]
と書くことはあるが、集約関数 $\Phi$ が直接受け取る同列の座標は $M_b, M_r, M_a$ の三つである。$M_x$ は第四の repair mode ではなく、外部から他 mode を供給する channel / externalization profile として扱う。

\begin{definition}[持続様式と外部供給 channel]
\[
  M^{\mathrm{int}} = (M_b^{\mathrm{int}}, M_r^{\mathrm{int}}, M_a^{\mathrm{int}}),
  \quad
  M^{x} = (M_{x \to b}, M_{x \to r}, M_{x \to a})
\]
各成分の意味は次の通り。

| 記号 | 英名 | 持続の様式 |
|---|---|---|
| $M_b^{\mathrm{int}}$ | internal buffering / robustness capacity | base system 自身が今この瞬間に持ちこたえる力 (耐える) |
| $M_r^{\mathrm{int}}$ | internal recovery capacity | base system 自身が壊れた部分を元の構造に戻す力 (戻す) |
| $M_a^{\mathrm{int}}$ | internal adaptive capacity | base system 自身が同じ $F$ を保ったまま構造を再編する力 (作り変える) |
| $M_{x \to b}$ | externally supplied buffering | 外部 channel が buffering を供給する量 |
| $M_{x \to r}$ | externally supplied recovery | 外部 channel が recovery / repair を供給する量 |
| $M_{x \to a}$ | externally supplied adaptation | 外部 channel が adaptation / reconfiguration を供給する量 |

\end{definition}

ここで強調すべきなのは、$b,r,a$ は「持続の様式」であり、$x$ は「誰がその様式を供給するか」の channel であるという点である。予算や人員や時間そのものは source であって、$M_b$ などの成分ではない。予算が増えたからといって、それが自動的に buffering capacity や recovery capacity に変換されるわけではない。どの様式に、どれだけ、どのように変換されるかを操作的に記述するのが、次節で導入する写像 $\gamma_i$ の役割である。

以降では、内部能力と外部供給を合わせた effective mode profile を
\[
  \widetilde M_j = A_j(M_j^{\mathrm{int}}, M_{x \to j}),
  \quad j \in \{b,r,a\}
\]
と書く。$A_j$ は少なくとも非負かつ各引数に単調非減少な集約である。最も単純には加法型 $A_j(u,v)=u+v$ と置けるが、本稿の主張はこの特定形に依存しない。

### 2.3 $M_a$ に関する重要な制限

$M_a$ に関しては、本稿では以下の強い制限を置く。

\begin{quote}
$M_a$ は、target function $F$ を保つ範囲の再編に限定される。$\Sigma$ が別の $\Sigma'$ に置換されることを扱うが、置換後も $F$ は保持されていなければならない。$F$ 自体が変わる遷移は $M_a$ の対象外であり、別稿の課題として残す。
\end{quote}

この制限が必要なのは、適応を無制限に許すと理論が空虚化するためである。たとえば、ある企業が破綻後に別業種で存続した場合、それは元の target function を保ったのではなく、別の $F$ に乗り換えたのである。これを「適応して生き延びた」と扱うと、どんな結果でも事後的に適応で説明できてしまう。

この制限は、Paper 1 §2 が「基体そのものの消滅ではなく、ある構造としての持続の失敗」を扱うと述べた立場と一貫する。$F$ 自体の遷移は、本稿の枠組みではなく、構造持続の集合値力学的表現 (別補論) の $R_t$ 作用のうち target structure 自体を書き換える部分として、将来の拡張対象となる。

### 2.4 Raw resource から mode への写像 $\gamma_i$

$R$ から各 $M_i$ への変換を、写像 $\gamma_i$ で与える。

\begin{definition}[mode 変換写像]
\[
  M_j^{\mathrm{int}} = \gamma_j^{\mathrm{int}}(R, \Sigma, F),
  \quad
  M_{x \to j} = \gamma_{x \to j}(R, \Sigma, F),
  \quad j \in \{b,r,a\}.
\]
各 $\gamma$ は次の条件を満たすものとする。
\begin{itemize}
  \item 非負性: $\gamma(R, \Sigma, F) \ge 0$
  \item 弱単調性: $R$ の関連成分について単調非減少
  \item 相対性: $F$ および $\Sigma$ を固定したときに定まる
  \item 事前固定性: 経験的応用では、結果観測前に定義される
\end{itemize}
\end{definition}

ここで「関連成分」とは、$R$ のうちその mode または外部供給 channel に寄与しうる成分を指す。たとえばソフトウェアドメインでは、冗長サーバは $M_b^{\mathrm{int}}$ に寄与しうるが、rollback 導線の整備状況なしには $M_r^{\mathrm{int}}$ には寄与しない。vendor contract は $M_{x \to r}$ に寄与しうるが、incident response と接続されていなければ実効化しない。どの $R$ 成分がどの mode に寄与しうるかは domain 固有の設計問題であり、本稿はドメイン横断の普遍的対応表を主張しない。

$\gamma_i$ を導入することで、本稿は次の観察を理論内で書けるようになる。
\[
  R \text{ は大きいが、} \gamma_j^{\mathrm{int}}(R, \Sigma, F) \approx 0
  \quad \text{または} \quad
  \gamma_{x \to j}(R, \Sigma, F) \approx 0.
\]
すなわち、「資源は潤沢にあるが、機能維持能力にはなっていない」という事態が、$M_i$ の小ささとして定量的に書ける。この形は、§1.1 で挙げた「資源があるのに機能しない」という観察に対する形式的な位置づけを与える。

### 2.5 有効維持能力と集約関数 $\Phi$

系の有効維持能力 $M_{\mathrm{eff}}$ を、mode ベクトルの集約量として定める。

\begin{definition}[有効維持能力]
\[
  M_{\mathrm{eff}} = \Phi(\widetilde M_b, \widetilde M_r, \widetilde M_a).
\]
$\Phi$ は、少なくとも非負性と各 effective mode に関する単調非減少性を満たす集約関数である。
\end{definition}

本稿では $\Phi$ の関数形を一意に固定しない。むしろ、表現規律として、いくつかの候補族を明示し、その選択に対して主予測が頑健かを §6 で検査する。

候補の一つは積型である。scale separability (各 mode を独立にスケールしたときの影響が他 mode を変えずに乗法的に分離できる性質) と multiplicative composition ($h_i(\lambda\mu) = h_i(\lambda) h_i(\mu)$) を追加仮定として置くと、連続性と正規化から $\Phi$ は積型
\[
  \Phi(q) = \prod_i q_i^{\alpha_i}
\]
に制限される。一次同次性 $\Phi(cq) = c \Phi(q)$ を追加すれば $\sum_i \alpha_i = 1$ が従う。ただし、この仮定は強い。scale separability を置いた時点で、積型へかなり寄っている。したがって、これは Paper 1 §3 と同じ強度の非自明な一意性定理ではなく、積型を選ぶ場合の表現補題候補として扱う。

他の候補として、CES family
\[
  \Phi_\rho(q) =
  \left(\sum_i \alpha_i q_i^\rho \right)^{1/\rho}
\]
を置ける。$\rho=1$ は加法型、$\rho \to 0$ は積型、$\rho \to -\infty$ は bottleneck / Leontief 型に対応する。各 mode が代替不能な regime では bottleneck 型
\[
  \Phi(q)=\min_i w_i q_i
\]
が自然である。

この関数族の整理は、Paper 1 §3 の対数比の一意性定理と方法論上は対応するが、強度は異なる。Paper 1 では損失尺度の加法性が対数形を強く拘束した。Paper 5 では、support 側の結合様式そのものが経験的・設計的選択を含むため、積型・CES・bottleneck のどれを採るかを理論だけで一意化しない。対応は次の通り。

| 項目 | Paper 1 §3 | Paper 5 §2.5 |
|---|---|---|
| 対象 | 残存比率 $r \in (0,1]$ 上の損失 $f$ | 正規化能力 $q_i \in \mathbb{R}_{>0}$ 上の集約 $\Phi$ |
| 関数方程式 | additive Cauchy | multiplicative Cauchy は積型候補の十分条件 |
| 一意な関数形 | $f(r) = -k \ln r$ | 積型・CES・bottleneck の候補族 |
| 残る経験量 | 各ドメインにおける $m(V)$ の具体化 | 各ドメインにおける $\alpha_i$, $w_i$, $\rho$ とその頑健性 |

この骨格対応により、本稿の mode 分解は単なる分類表ではなく、Paper 1 の方法論を support 側に移植するための候補族を持つ。ただし、本稿の load-bearing claim は積型の証明ではない。以降の節では $\Phi$ を単調非減少な集約として扱い、積型・CES・bottleneck 型のどれを採るかは domain 固有の経験的推定と §6 の robustness validation に委ねる。主予測 (介入順位予測) はこの選択に対して robust であるべきである。

以上により、本稿の最小形式は次で与えられる。

\begin{definition}[Paper 5 最小形式]
\[
  S = M_{\mathrm{eff}} \, e^{-L}
    = \Phi\bigl(\widetilde M_b,\ \widetilde M_r,\ \widetilde M_a\bigr) \, e^{-L}.
\]
\end{definition}

この式は Paper 1 の $S = M e^{-L}$ を否定するものではない。スカラー $M$ を $M_{\mathrm{eff}}$ で置き換え、$M_{\mathrm{eff}}$ を effective mode profile の集約として再構成しただけであり、スカラー $M$ は本式の粗視化として回収される。

### 2.6 補論 B との関係

Paper 5 の枠組みが補論 B の運用展開
\[
  S = N_{\mathrm{eff}}^{(0)} \times (\mu/\mu_c) \times e^{-L}
\]
と重複しないように、両者の関係を明示しておく。

| 補論 B の量 | Paper 5 側の最も近い位置 |
|---|---|
| $\mu / \mu_c$ | $M_b$ (buffering margin) に最も近い |
| $N_{\mathrm{eff}}^{(0)}$ | 初期選択肢多様性。$M_a$ の上流に位置するが、$M_a$ と同一ではない |
| (補論 B では未分離) | $M_r$ は補論 B の $\mu$ 側に畳み込まれていた作用として切り出される |
| (補論 B では未分離) | $M_a$ は $N_{\mathrm{eff}}^{(0)}$ と $\mu$ のあいだに埋まっていた再編作用として切り出される |
| (補論 B には対応物なし) | $M_x$ は開放系の外部供給 channel として補論 B の外に置かれる |

重要な注意として、静的な $N_{\mathrm{eff}}^{(0)}$ をそのまま $M_a$ に吸収しないこと。ドメインが再編を通じて選択肢を再生させるケース以外では、$N_{\mathrm{eff}}^{(0)}$ と $M_a$ は別物として保つ方が安全である。Paper 5 は補論 B を上書きするのではなく、補論 B の右辺の $M$ 側を mode 分解して再解釈するものとして位置づける。

---

## §1-2 で resolved / still open

本稿の §1-2 に必要な範囲で、`PAPER5_DRAFT_PLAN.md` の review question 8 項目のうち次が resolved / still open として整理される。

**Resolved in §1-2:**

- Q1 (F の二段構成): §1.3 で broad framing (safe change continuity) + narrow pilot (bug detection / localization) の二段構成を採用する方針を明示。具体化は §4 以降。
- Q3 / Q6 ($\Phi$ の表現定理を本論に置くか補論に置くか): §2.5 で暫定決定。**表現定理ではなく表現規律として本論 §2.5 に短く含める**。Paper 1 §3 対数比の一意性定理との方法論上の対応を示すが、同じ強度の一意性とは主張しない。積型・CES・bottleneck 型を候補族として明示し、主予測はその choice に対して robust であることを §6 で検査する。この決定は暫定方針であり、§3-7 起草後に再検討しうる。
- Q5 (M_x に autonomy caveat): §2.2 で $M_x$ を外部供給 channel / externalization profile として定義し、自律的 robustness や第四の repair mode ではないことを定義レベルで区別。
- $M_a$ の限定: Q 項目外だが、§2.3 で「$F$ を保つ範囲の再編に限定」という制限を明示。`PAPER5_DRAFT_PLAN.md` §4 の restriction 句を定義レベルに昇格。

**Still open after §1-2:**

- Q2 / Q8 (DeltaLint の扱い): §1-2 では触れていない。§5 software mapping と §6 empirical route で再判断。
- Q4 (four-domain comparison を含めるか): §1-2 では扱わない。本稿は software 中心で起草し、§9 Future work で言及可能性を検討。
- Q7 (validation protocol の leave-one-project-out / time-split): §6 候補 empirical protocol 起草時に判断。

---

## 次のアクション候補

本 draft は §1-2 のみ。Q6 暫定決定（表現規律を §2.5 に短く含める）が入った状態での次のアクションは以下。

1. §3 (Paper 3/4 マッピングの詳細化) の起草。§1.4 で概観した接続を指標レベルまで落とす。
2. §4-5 (software mapping、$F/\Sigma/R/M$ 表、$M_a$ の具体例) の起草。
3. §6 (empirical route) と DeltaLint baseline 比較 (Q2 / Q8) の扱いを確定。
4. Q7 (validation protocol の leave-one-project-out / time-split) を §6 起草時に確定。
5. §1-2 を含む全章をレビューし、main preprint `v2/5_構造持続における資源項Mの操作的定式化.md` への昇格判断。

推奨順: 1 → 2 → 3 → 4 → 5。表現規律の扱い（Q6）が決まったため、§3 は §2.5 を motivating example として参照する形で直接起草できる。
