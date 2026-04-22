# Paper 5 §6 Review Draft

Status: review draft, not a main preprint.

Date: 2026-04-22

Source: `PAPER5_DRAFT_PLAN.md`, `PAPER5_SECTION_1_2_DRAFT.md`,
`PAPER5_SECTION_3_DRAFT.md`, `PAPER5_SECTION_4_5_DRAFT.md`,
`paper5_メモ.md`

Target file on promotion: `v2/5_構造持続における資源項Mの操作的定式化.md`

Scope of this draft: §6 empirical validation protocol のみ。Paper 5 の M-side
主張を検査するための protocol を置く。DeltaLint は本節の主 validation
から除外し、`DELTALINT_PAPER3_EXTENSION_NOTE.md` に切り出した L-side
extension として扱う。

---

## 6. 経験的検証プロトコル

本稿は、M の完全理論を完成させるものではない。したがって本節の役割は、
Paper 5 の主張をどのようなデータで検証可能にするかを固定することである。

Paper 5 の主張は、次の形を持つ。

\begin{quote}
同じ $\hat L$、同じ raw resource $R$、同じ scalar $M_{\mathrm{total}}$
に見える系でも、mode composition が異なれば、有効な介入順位が異なる。
\end{quote}

この主張を検査するには、静的コード上の bug-prone location だけでは足りない。
必要なのは、少なくとも次の四つである。

1. 対象となる software / SaaS system。
2. 時間窓ごとの $\hat L$、raw $R$、mode profile の測定。
3. 実際に行われた介入 $I_b, I_r, I_a, I_{x\to j}$ の履歴。
4. 介入後の outcome 変化。

したがって、§6 の validation は operational data を必要とする。DeltaLint のような
静的検出器は、局所 $\hat L$ の候補にはなりうるが、M-mode intervention ranking
の検証を代替しない。

### 6.1 検証対象

本稿では、software / SaaS を Route C ドメインとして扱う。第一段階の broad target
と pilot target は、§4.2 で定義した通りである。

\[
  F_{\mathrm{broad}} = \text{safe change continuity}
\]

\[
  F_{\mathrm{pilot}} = \text{change-introduced bug detection / localization}
\]

ただし、M-side validation の主 outcome は単なる「bug が見つかるか」ではない。
次のような operational outcome を用いる。

| outcome | 意味 | 対応する mode |
|---|---|---|
| change failure rate | 変更が失敗・rollback・hotfix を要した比率 | $M_b$, $M_r$ |
| MTTR | 障害から復旧までの時間 | $M_r$ |
| MTTD | 障害検出までの時間 | $M_r$ |
| rollback success | rollback が即時・安全に成立したか | $M_r$ |
| incident recurrence | 同種障害が再発したか | $M_a$ |
| lead time degradation | 変更リードタイムが悪化したか | $M_a$, $\hat L$ |
| external escalation rate | vendor / external SRE / upstream maintainer に依存した比率 | $M_{x\to j}$ |

この表は outcome 候補であり、実験時には対象組織・対象 repo・対象運用ログに応じて
観測可能なものを事前固定する。

### 6.2 分析単位と分割

単位は、project / service / repository / team / time window の組で定義する。
たとえば、

\[
  u = (\text{repo}, \text{month})
\]

または

\[
  u = (\text{service}, \text{deployment window})
\]

を一単位とする。

Primary split は time-split held-out validation とする。

\[
  \text{train}: [T_0, T_1), \quad
  \text{test}: [T_1, T_2)
\]

この分割は、software outcome が時間的に漏れやすいためである。将来の incident や
bug-fix を予測するなら、未来の情報を predictor 設計に混ぜてはいけない。

Secondary split は leave-one-project-out validation とする。

\[
  \text{train}: \mathcal P \setminus \{p\}, \quad
  \text{test}: \{p\}
\]

これは cross-project generalization を見るためである。time-split が通っても、
単一 project 内の局所慣習を拾っているだけなら、Paper 5 の一般性は弱い。

### 6.3 Predictor families

比較する predictor family は、事前に固定する。

#### Baseline predictors

最低限、次を含める。

| baseline | predictors |
|---|---|
| raw size | LOC, file count, module count |
| age | file age, service age |
| complexity | cyclomatic complexity, nesting depth, dependency count |
| activity | churn, commit count, author count |
| history | prior incidents, prior bug-fix count, prior rollback count |
| scalar resource | team size, on-call hours, budget proxy, server capacity |
| scalar $M_{\mathrm{total}}$ | mode signals を合計または単一スカラー化したもの |

これらは quality-blind / scalar-resource baseline である。Paper 5 の主張は、これらの
baseline より mode-aware predictor が out-of-sample で勝つかにかかっている。

特に B2 scalar $M_{\mathrm{total}}$ baseline は straw-man にしてはいけない。
単純和だけを倒しても、Paper 5 の mode 分解が本当に必要だとは言えない。したがって、
B2 には train fold 上で作れる最も強い単一スカラー要約を含める。

候補は次である。

- mode signal の z-score 平均。
- train fold 上の第一主成分 (PCA-1)。
- train fold 上で学習した weighted scalar combination。
- raw $R$ proxy と mode signal を一つの scalar に圧縮した summary。

いずれの場合も、重み・平均・標準偏差・主成分方向は train fold でのみ推定し、
test fold では固定して適用する。これにより、mode-aware model が弱い単純和ではなく、
強い scalar-resource baseline を上回るかを検査する。

#### Structure-loss proxy

第一段階の $\hat L_{\mathrm{pilot}}$ は、§4.5 の最小構成を用いる。

\[
  \hat L_{\mathrm{pilot}}
  =
  w_1 \cdot \text{boundary-crossing count}
  +
  w_2 \cdot \text{rollback-impossibility rate}.
\]

ここで、boundary-crossing count と rollback-impossibility rate の定義は
outcome 観測前に固定する。重み $w_1,w_2$ を学習する場合は train fold のみで推定し、
test fold には固定済みの重みを適用する。

#### Mode predictors

§4.6 の mode / channel 表に従い、候補 signal を事前固定する。

| mode/channel | candidate signals |
|---|---|
| $M_b^{\mathrm{int}}$ | redundancy, spare capacity, queue/cache slack, rate limit, circuit breaker |
| $M_r^{\mathrm{int}}$ | rollback path, restore drill, observability coverage, incident runbook, patch path |
| $M_a^{\mathrm{int}}$ | feature flag coverage, migration tooling, modular replacement path, boundary redesign capacity |
| $M_{x\to b}$ | managed redundancy, cloud failover, external capacity burst |
| $M_{x\to r}$ | vendor incident response, external SRE support, upstream maintainer response |
| $M_{x\to a}$ | external migration support, consultant-led redesign, upstream architectural support |

各 signal は、raw resource ではなく effective capacity として operationalize する必要がある。
たとえば「SRE がいる」は raw $R$ であり、「対象サービスで restore drill が実施済みで
手順が有効」は $M_r^{\mathrm{int}}$ signal である。

### 6.4 Model families

最小比較では、次の model family を使う。

| model | predictors | 役割 |
|---|---|---|
| B0 raw | raw size, age, churn, complexity | quality-blind baseline |
| B1 history | B0 + prior incidents / prior fixes | history baseline |
| B2 scalar resource | B1 + raw $R$ / scalar $M_{\mathrm{total}}$ | scalar M baseline |
| S1 loss-aware | B1 + $\hat L_{\mathrm{pilot}}$ | L-side control |
| S2 mode-aware | B1 + $\hat L_{\mathrm{pilot}}$ + $\widetilde M_b,\widetilde M_r,\widetilde M_a$ | Paper 5 primary model |
| S3 intervention-aware | S2 + intervention family indicators | intervention-ranking model |

Primary comparison は、

\[
  S2 < B2
\]

を held-out log loss / Brier score で見る。ここで $<$ は loss が小さいことを表す。

ただし、Paper 5 の distinctive claim は単なる risk prediction ではなく
intervention ranking である。したがって、S2 が B2 に勝つだけでは strong support
とは呼ばない。strong support には §6.6 の intervention-ranking criterion が必要である。

### 6.5 Primary predictive endpoint

第一の endpoint は、held-out outcome の予測性能である。

候補は次のいずれかを事前固定する。

- binary outcome: change failure / no change failure;
- binary outcome: rollback succeeded / failed;
- binary outcome: incident recurrence / no recurrence;
- time-to-event: time to recovery, time to recurrence;
- count outcome: incidents per window.

binary outcome の場合、primary metric は Brier score または log loss とする。
count outcome の場合は Poisson / negative-binomial log loss、time-to-event の場合は
事前固定した survival metric を用いる。

第一段階の safest default は binary outcome + Brier score である。理由は、
calibration の解釈がしやすく、small-N の pilot でも破綻しにくいからである。

### 6.6 Intervention-ranking endpoint

Paper 5 の主予測は、介入順位である。したがって、可能なら次を primary または
strong-support endpoint とする。

各単位 $u$ について、観測された mode profile から推奨介入順位を出す。

例:

\[
  \mathrm{rank}_{\mathrm{pred}}(u)
  =
  (I_r, I_a, I_b, I_{x\to r}, \dots)
\]

実際の介入履歴と outcome から、効果順位を後から推定する。

\[
  \mathrm{rank}_{\mathrm{obs}}(u)
\]

評価は Kendall $\tau$、Spearman $\rho$、または top-1 / top-2 agreement で行う。

$\mathrm{rank}_{\mathrm{obs}}$ の推定方法は preregistration で具体化する。候補は次である。

- pre/post outcome difference;
- difference-in-differences;
- matched-pair analysis;
- interrupted time-series;
- randomized intervention assignment, if available.

どの推定法を採るか、どの time window を使うか、どの covariate を調整するかは、
outcome 観測前に固定する。観測後に都合のよい推定法を選ぶなら、intervention-ranking
validation ではなく post-hoc explanation である。

ただし、この endpoint には介入履歴が必要である。介入履歴がない dataset では、
Paper 5 の primary claim は fully tested とは言わない。その場合、§6.5 の
risk prediction は preparatory evidence に留める。

### 6.7 $\rho_i$ normalization robustness

Mode signal は単位が揃っていない。したがって、各 signal を $q_i=\rho_i(M_i)$ に
正規化する必要がある。

ここで恣意性が入る。したがって、$\rho_i$ は単一に決め打ちせず、複数の合理的候補で
robustness を検査する。

例:

| mode | normalization candidates |
|---|---|
| $M_b$ | min-max within train fold; percentile rank; log(1+capacity proxy) |
| $M_r$ | inverse MTTR percentile; rollback success rate; restore drill recency score |
| $M_a$ | feature-flag coverage; migration tooling availability; recurrence reduction proxy |
| $M_{x\to r}$ | external response SLA score; vendor escalation success; upstream fix latency inverse |

Rule:

```text
The intervention-ranking conclusion is considered robust only if the dominant
mode / recommended intervention ordering is stable across at least two
reasonable normalization families.
```

All normalization parameters must be fitted on train folds only.

ここでいう「reasonable normalization」とは、本節で preregister された $\rho_i$
候補 family に属するものを指す。観測後に追加した normalization で ranking が
逆転しても、それだけでは non-support と判定しない。逆に、preregistered family 内で
ranking が反転するなら、Paper 5 の strong support は成立しない。

### 6.8 $\Phi$ robustness

§2.5 で述べた通り、本稿は $\Phi$ の一意性を主張しない。したがって、主予測は
$\Phi$ の選択に対して robust でなければならない。

検査する候補は次である。

| family | form | interpretation |
|---|---|---|
| additive scalar baseline | $\sum_i \alpha_i q_i$ | scalar M baseline |
| product | $\prod_i q_i^{\alpha_i}$ | complementary modes |
| CES | $(\sum_i \alpha_i q_i^\rho)^{1/\rho}$ | substitutability continuum |
| bottleneck / Leontief | $\min_i w_i q_i$ | weakest-mode dominance |

Paper 5 の strong support は、mode-aware model が scalar baseline に勝つだけでなく、
product / CES / bottleneck の複数候補で同じ intervention-ranking direction を保つ場合に限定する。

ここでいう「複数候補」は、preregistration で固定された $\Phi$ family に限る。
観測後に追加した aggregator は探索的解析として報告できるが、primary / strong support
の判定には用いない。

### 6.9 $A_j$ internal/external aggregation robustness

外部供給 channel と内部能力を合わせる関数

\[
  \widetilde M_j = A_j(M_j^{\mathrm{int}}, M_{x\to j})
\]

も一意には決まらない。ここにも robustness check が必要である。

候補:

| family | form | reading |
|---|---|---|
| additive | $u+v$ | internal and external support add |
| substitutive | $\max(u,v)$ | stronger channel dominates |
| complementarity | $\sqrt{uv}$ or product-like form | both internal and external are needed |
| bottleneck | $\min(u,v)$ | external support fails without internal uptake |

特に Case C (high $M_{x\to r}$, low internal $M_r$) では、この選択が重要になる。
外部支援が短期には効くが、再発低減には内部 $M_r$ が必要という予測は、additive
だけではなく、substitutive / bottleneck 的な読みでも保たれるかを確認する。

$A_j$ についても、reasonable candidate は preregistration で固定された family に限る。
観測後に追加した $A_j$ でのみ主張が成立する場合、それは Paper 5 の support ではなく
exploratory result として扱う。

### 6.10 Support criteria

Paper 5 の validation は、段階を分けて報告する。

| support level | criterion |
|---|---|
| preparatory support | mode-aware predictor improves held-out risk prediction over raw / scalar baselines |
| primary support | predicted intervention ranking agrees with observed intervention effectiveness above preregistered threshold |
| strong support | ranking direction is robust across $\rho_i$, $\Phi$, and $A_j$ candidate families |
| non-support | scalar baselines match or beat mode-aware models, or rankings reverse under reasonable normalizations |

この分類により、「予測性能が少し上がった」ことと、「Paper 5 の介入順位予測が支持された」
ことを混同しない。

ここで reasonable とは、§6.7 の $\rho_i$、§6.8 の $\Phi$、§6.9 の $A_j$ で
preregister された候補 family に属するものを指す。

### 6.11 Minimum preregistration checklist

実験前に、少なくとも以下を凍結する。

- 対象 project / service / repo 集合。
- time cutoff と train/test split。
- target function $F$。
- outcome definition。
- $\hat L_{\mathrm{pilot}}$ の定義。
- raw baseline predictors。
- mode / channel signals。
- $\rho_i$ normalization candidates。
- $\Phi$ candidate families。
- $A_j$ candidate families。
- primary metric。
- primary support threshold。
- minimum unit count per fold。
- detectable effect size / power target for the primary endpoint。
- handling of missing operational data。

これらを観測後に選ぶなら、Paper 5 の validation ではなく post-hoc analysis である。

特に intervention-ranking を primary support として使う場合、Kendall $\tau$ や
top-k agreement に対して、事前に想定する effect size と必要な unit count を見積もる。
十分な power がない pilot では、非有意な結果を strong non-support と解釈しない。

### 6.12 本節の非主張

本節は、次を主張しない。

1. 現時点で Paper 5 の M-framework が実証済みであるとは主張しない。
2. Software / SaaS が Route A ドメインであるとは主張しない。
3. $\hat L_{\mathrm{pilot}}$ が真の $L$ であるとは主張しない。
4. DeltaLint が Paper 5 の validation であるとは主張しない。
5. 単一の $\rho_i$、$\Phi$、$A_j$ が全ドメインで正しいとは主張しない。
6. 介入履歴なしの risk prediction だけで介入順位予測が検証されたとは主張しない。
7. 観察データから推定した $\mathrm{rank}_{\mathrm{obs}}$ が、直ちに因果的効果順位を表すとは主張しない。randomized intervention assignment または明示的な causal identification がない限り、本稿の intervention-ranking support は observational support である。

---

## §6 で更新される判断

**Resolved by §6 draft:**

- Q7: validation は time-split held-out を primary、leave-one-project-out を secondary とする。
- DeltaLint は §6 validation から除外し、Paper 3 / L-side static-code extension note に分離済みとする。
- Paper 5 の empirical support は、risk prediction と intervention-ranking support を分けて報告する。
- $\rho_i$、$\Phi$、$A_j$ の robustness を preregistration checklist に含める。
- B2 scalar $M_{\mathrm{total}}$ baseline は train-fold learned scalarization を含む強い baseline として扱う。
- $\mathrm{rank}_{\mathrm{obs}}$ の推定法と power / unit count を preregistration checklist に含める。
- observational intervention-ranking support は causal proof ではないことを明記する。

**Still open after §6:**

- 実際に使う operational dataset。
- outcome の最初の primary choice。
- intervention history が取得できるか。
- §7 limitations / future work の整理。
- main preprint へ昇格するか、§7 まで review draft を続けるか。

## 次のアクション候補

1. §7 limitations / future work を起草する。
2. §1-6 を統合して main preprint 昇格前の章構成を整える。
3. operational dataset 候補を調査する。
4. DeltaLint note を Phase 2 preregistration に拡張する。

推奨順: 1 → 2 → 3 → 4。Paper 5 本体は §7 まで書けば、review draft として一段閉じる。
