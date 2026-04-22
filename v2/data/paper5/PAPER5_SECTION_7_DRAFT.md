# Paper 5 §7 Draft — 限界と次段階

Status: review draft, local only.

This section closes the Paper 5 review draft by making explicit what the paper
does not yet establish and what would be required for empirical support.

---

## 7. 限界と次段階

本稿の貢献は、資源項 $M$ を単一スカラーとして扱うのではなく、
持続様式と外部供給 channel に分け、介入順位予測として検査可能な形に置くことである。

ただし、本稿はこの段階で Paper 5 の empirical pilot を完了したとは主張しない。
本稿が与えるのは、次の三点である。

1. $F / \Sigma / R / M$ の操作的分解。
2. software / SaaS における mode-based intervention-ranking prediction。
3. その予測を検査するための preregistered validation protocol。

したがって、本稿の現在地は「実証済み論文」ではなく、
「強い実証可能性を持つ framework / protocol paper」である。

### 7.1 Operational dataset の未取得

§6 の validation は、単なる静的 code score では足りない。
Paper 5 の primary claim は介入順位予測であるため、少なくとも次の情報が必要である。

- 対象 project / service / repository の集合。
- time cutoff と train/test split。
- target function $F$。
- $\hat L_{\mathrm{pilot}}$ の事前固定。
- $M_b$, $M_r$, $M_a$ と外部供給 channel の mode / channel signals。
- 実際に行われた介入履歴。
- 介入後の outcome: change failure rate, escaped defects, MTTR, MTTD,
  rollback success, incident recurrence など。

この operational dataset がない場合、risk prediction の改善は preparatory support に留まる。
介入履歴と outcome がない dataset では、Paper 5 の primary claim は fully tested とは言わない。

### 7.2 Software は Route C であり Route A ではない

Software / SaaS は、本稿の最初の具体ドメインとして扱いやすい。
しかし、SAT や Mixed-CSP のように、問題設定そのものから自然測度 $m$ と
縮小列 $V^{(0)} \supseteq V^{(1)} \supseteq \cdots$ が与えられる Route A
ドメインではない。

安全な変更経路や有効運用状態の集合を概念的に置くことはできるが、
その残存比率を domain-intrinsic に数えることは難しい。
したがって、本稿の software claim は Route C の operational prediction であり、
Route A の普遍法則宣言ではない。

### 7.3 $\hat L_{\mathrm{pilot}}$ は真の $L$ ではない

§4-6 で用いる $\hat L_{\mathrm{pilot}}$ は、boundary-crossing count,
rollback-impossibility rate などから作る実用 proxy である。
これは Paper 1 の対数比損失 $L$ そのものではない。

この違いは重要である。

- Paper 1 の $L$ は、構造維持可能集合の測度比から定義される。
- Paper 5 の $\hat L_{\mathrm{pilot}}$ は、software process で観測可能な
  structural-risk signal から作る proxy である。

したがって、$\hat L_{\mathrm{pilot}}$ が outcome を予測しても、それだけで
Paper 1 の最小形式が software に直接適用されたとは言わない。
本稿で問うのは、proxy と mode decomposition が out-of-sample で
scalar baselines より介入順位をよく予測するかである。

### 7.4 Mode signal は直接測定ではない

$M_b^{\mathrm{int}}$, $M_r^{\mathrm{int}}$, $M_a^{\mathrm{int}}$,
$M_{x\to b}$, $M_{x\to r}$, $M_{x\to a}$ は、いずれも直接観測される
物理量ではない。§4.6 の signal は、それぞれの mode を近似する operational
indicator である。

このため、mode signal の選択は preregistration で固定しなければならない。
観測後に都合のよい signal を選ぶなら、それは Paper 5 の validation ではなく、
post-hoc interpretation である。

また、同じ observed signal が複数の mode に関係する場合がある。
たとえば feature flag は一見 $M_a$ の signal だが、rollback workflow と
結びつくと $M_r$ にも寄与する。このような signal は、どの mode の proxy として
使うかを実験前に固定する必要がある。

### 7.5 観察的 support と因果的 support

§6 の $\mathrm{rank}_{\mathrm{obs}}$ は、多くの場合、観察データから推定される。
しかし、観察された介入効果順位は、直ちに因果的な効果順位を意味しない。

理由は単純である。
team はランダムに介入を選ぶわけではない。
多くの場合、効きそうな介入、予算が取れた介入、既に失敗が目立っている箇所への介入が
選ばれる。この selection bias は、observed effectiveness と team の事前判断を交絡させる。

したがって、randomized intervention assignment または明示的な causal-identification design
がない限り、Paper 5 の support は observational support に留まる。
これは弱点ではあるが、明示しておくべき境界である。

### 7.6 Underpowered pilot の扱い

介入順位予測は、risk prediction より data-hungry である。
介入履歴、outcome、mode profile、十分な variation が必要になる。

したがって、小さな pilot で非有意な結果が出ても、それだけで Paper 5 の強い反証とは言わない。
§6.11 の preregistration では、minimum unit count per fold と detectable effect size / power
target を事前に置く必要がある。

十分な power がない場合、結果は次のように扱う。

- 方向が予測通りなら preparatory evidence。
- 方向が不安定なら inconclusive。
- 事前に十分な power があると判定されており、かつ scalar baseline が mode-aware
  model を上回るなら non-support。

### 7.7 $\rho_i$, $\Phi$, $A_j$ の一意性は主張しない

本稿は $\Phi$ の universal form を主張しない。
また、各 mode の normalization $\rho_i$ や、内部能力と外部供給を合成する $A_j$
についても、単一の正しい形を主張しない。

したがって、Paper 5 の strong support は、単一の scaling convention ではなく、
複数の preregistered candidate family に対して介入順位が保たれる場合に限る。

この点で、§2.5 の product / CES / bottleneck family は、表現定理の勝利宣言ではない。
それらは、representation sensitivity を検査するための候補族である。

### 7.8 静的形式に留まる

本稿は主に静的な形式

```text
S = Phi(M) e^{-L}
```

または、その software proxy 版を扱う。
時間発展としての $\dot L$, $\dot M$, collapse profile, recovery profile は本稿の主対象ではない。

これは特に $M_{x\to r}$ の解釈で重要である。
外部支援は短期には強い repair capacity を供給しうる。
しかし、内部 $M_r^{\mathrm{int}}$ が形成されなければ、同じ failure class の再発低減には
つながらない可能性がある。この短期/長期の差は、本稿では intervention-ranking prediction
として述べるに留め、動的理論としては扱わない。

動的拡張では、少なくとも次を扱う必要がある。

- $\dot L$: 構造損失がどの速度で増えるか。
- $\dot M_j$: 各 mode が介入によってどの速度で変化するか。
- 外部供給が内部能力の形成を促進するか、代替してしまうか。
- collapse / recovery の time profile。

これらは future work である。

### 7.9 Domain generalization は未完

本稿は software / SaaS を最初の Route C ドメインとして扱う。
しかし、$M$ の mode decomposition は、組織、学校、病院、企業、研究チームなどにも
自然に現れる可能性がある。

この cross-domain extension は本稿の主張ではない。
最初の draft では、software-centered に保つ。

将来的には、次のような比較表を作れる可能性がある。

| domain | $M_b$ | $M_r$ | $M_a$ | external supply |
|---|---|---|---|---|
| software / SaaS | redundancy, slack | rollback, runbook | feature flag, modular replacement | vendor / SRE support |
| hospital | beds, staff slack | triage, recovery protocol | protocol redesign | external transfer / regional support |
| school | substitute capacity | remedial support | curriculum adaptation | district / external specialists |
| organization | buffer resources | incident response | structural redesign | consultants / external service |

ただし、この表は future work であり、本稿の empirical support ではない。

### 7.10 DeltaLint は並行 track である

DeltaLint は、Paper 5 の main validation ではない。
DeltaLint が観測しているのは、主に静的コード中の未整理な前提不整合、
scope mismatch、guard 欠落、順序依存、設定干渉である。
これは $M$-mode composition ではなく、L-side / Paper 3 static-code extension に近い。

したがって、DeltaLint は別 note で扱う。

```text
DELTALINT_PAPER3_EXTENSION_NOTE.md
```

その中心予測は、Paper 5 の介入順位予測ではなく、次である。

```text
existing tools + DeltaLint > existing tools alone
```

同じ alert budget の下で、既存 tool 群に DeltaLint を加えたとき、
将来 bug-fix outcome に対する hit が増えるかを検査する。
これは Paper 5 の validation ではなく、Paper 3 / L-side の別 track である。

### 7.11 Main preprint への昇格条件

本 review draft を main preprint に昇格する前に、少なくとも次を確認する。

1. §1-7 の主張が「framework / protocol paper」として過大でないこと。
2. DeltaLint を Paper 5 の empirical anchor として戻していないこと。
3. §6 の validation protocol が、risk prediction と intervention-ranking support を
   混同していないこと。
4. $\rho_i$, $\Phi$, $A_j$ の robustness が主張に組み込まれていること。
5. empirical pilot 未完了であることを明示していること。
6. software が Route C であり、Route A ではないこと。
7. 読者が「Paper 5 は今すぐ実証済み」と誤読しないこと。

これらが満たされるなら、Paper 5 は薄いが強い framework paper として昇格できる。
満たされないなら、review draft に留める。

### 7.12 次段階

次に進める作業は四つある。

1. §1-7 を統合し、main preprint draft
   `v2/5_構造持続における資源項Mの操作的定式化.md` に昇格するか判断する。
2. Paper 5 用の operational dataset 候補を調査する。
   SRE / DevOps / incident-management datasets、software delivery metrics、
   internal operational logs などが候補である。
3. DeltaLint note を Phase 2 preregistration に拡張する。
   これは Paper 5 ではなく、Paper 3 / L-side static-code extension として進める。
4. four-domain comparison を future-work note として作る。

推奨順は 1 → 2 → 3 → 4 である。
Paper 5 本体は、まず §1-7 の一貫性を確認し、main preprint へ昇格できるかを判断する。

---

## §7 で更新される判断

**Resolved by §7 draft:**

- Paper 5 は現段階では framework / protocol paper であり、empirical pilot 完了論文ではない。
- Software / SaaS は Route C として扱い、Route A とは呼ばない。
- $\hat L_{\mathrm{pilot}}$ は true $L$ ではなく、software operational proxy として扱う。
- Mode / channel signals は direct measurement ではなく、事前固定された indicator として扱う。
- Observational intervention-ranking support は causal proof ではない。
- Underpowered pilot の non-significant result は strong non-support と読まない。
- $\rho_i$, $\Phi$, $A_j$ の一意性は主張せず、robustness validation の対象とする。
- Dynamic collapse / recovery profile は future work とする。
- Four-domain comparison は first draft には入れず、future work とする。
- DeltaLint は Paper 5 validation ではなく、Paper 3 / L-side static-code extension として分離する。

**Still open after §7:**

- §1-7 を main preprint に昇格するか。
- Paper 5 用 operational dataset をどこから取るか。
- 最初の primary outcome を何にするか。
- DeltaLint Phase 2 preregistration をいつ起草するか。

## 次のアクション候補

1. §1-7 を統合して main preprint draft を作る。
2. その前に §1-7 全体レビュー用の short summary を作る。
3. Paper 5 operational dataset 候補を調査する。
4. DeltaLint Phase 2 preregistration note を起草する。

推奨順: 2 → 1 → 3 → 4。
