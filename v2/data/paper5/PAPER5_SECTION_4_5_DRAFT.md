# Paper 5 §4-5 Review Draft

Status: review draft, not a main preprint.

Date: 2026-04-22

Source: `PAPER5_DRAFT_PLAN.md`, `PAPER5_SECTION_1_2_DRAFT.md`, `PAPER5_SECTION_3_DRAFT.md`, `paper5_メモ.md`, `chatgpt_2026-04-22_ソフトウェア.md`

Target file on promotion: `v2/5_構造持続における資源項Mの操作的定式化.md`

Scope of this draft: §4 software / SaaS mapping と §5 intervention-ranking prediction のみ。§6 empirical validation protocol は後続 draft で起草する。

---

## 4. Software / SaaS における写像

本稿の最初の具体ドメインは、software / SaaS / 継続運用される業務システムである。この選択は、ソフトウェアが最も普遍的な対象であるという主張ではない。むしろ、Paper 5 の目的である $M$ の操作的定式化にとって、software / SaaS が扱いやすい Route C ドメインだからである。

理由は三つある。第一に、維持したい機能 $F$ と、それを担う構造 $\Sigma$ を比較的具体的に書ける。第二に、障害、変更、rollback、MTTR、lead time、deploy history などの観測ログが存在しうる。第三に、介入が内部 mode ($I_b, I_r, I_a$) と外部供給 channel ($I_{x\to b}, I_{x\to r}, I_{x\to a}$) として比較的自然に定義できる。

### 4.1 Route C としての位置づけ

Software / SaaS は、SAT や Mixed-CSP のような Route A ドメインではない。安全な変更経路や有効運用状態の集合を概念的に置くことはできるが、その残存比率 $m(V^{(n)})/m(V^{(0)})$ を自然測度で直接数えることは難しい。したがって、本稿では software を Route C として扱う。

Route C としての勝ち筋は次である。

\begin{quote}
事前固定した代理損失 $\hat L$ と mode predictor が、raw size / age / churn / incident count などの基準モデルより、held-out outcome をよく予測するかを見る。
\end{quote}

したがって、§4-5 は定理的閉包ではなく、実証可能な写像を定義する節である。ここでの目標は、後続の §6 で validation protocol を置けるだけの $F,\Sigma,R,\hat L,M_i,I_i$ を事前に固定することである。

### 4.2 Target function $F$

Software / SaaS では、$F$ を二段階で定義する。

第一に、本稿全体の broad framing として、
\[
  F_{\mathrm{broad}} = \text{safe change continuity}
\]
を置く。これは、可用性、正確性、データ整合性、安全な変更継続、障害からの回復可能性を含む広い機能である。

第二に、最初の empirical pilot の narrow target として、
\[
  F_{\mathrm{pilot}} = \text{change-introduced bug detection / localization}
\]
を置く。これは、変更によって導入される不具合を、release 前後の短い時間窓で検出・局所化できるか、という限定された機能である。

二段階に分ける理由は、broad $F$ が Paper 5 の実務的射程を保つ一方で、narrow $F_{\mathrm{pilot}}$ は検証可能性を与えるからである。最初から「安全な変更継続」全体を評価対象にすると、outcome が広すぎて baseline 比較が曖昧になる。まずは bug detection / localization に絞り、そこで構造持続型 proxy が raw baseline を上回るかを検査するのが安全である。

### 4.3 構造 $\Sigma$: code だけではない

Software の $\Sigma$ は、ソースコードの文字列だけではない。$F$ を担うのは、コード・設定・データ・運用が組になった関係構造である。

代表的には次が含まれる。

- モジュール境界
- 依存関係
- API contract
- 認証・認可境界
- データ整合性制約
- ストレージ構成
- CI/CD 導線
- 監視と alert 設定
- deploy / rollback path
- incident runbook
- code review checklist
- operational procedure

ここで、Paper 3 における prompt design との対応が明確になる。Paper 3 の in-context scope marker は、LLM 呼び出し内の protocol / context structure として働いた。Software / SaaS では、runbook、checklist、CI/CD、contract test、review rule、deployment protocol が同じ位置にある。すなわち、これらは単なる raw resource $R$ ではなく、機能を担う構造 $\Sigma$ の一部である。

したがって、§3 で残した tension への本稿の答えは次である。

\[
  \text{prompt design / operational protocol / runbook} \in \Sigma.
\]

これにより、$\gamma_i(R,\Sigma,F)$ は context / protocol の違いを自然に受け取れる。たとえば、同じ SRE team time という $R$ があっても、rollback procedure が $\Sigma$ に存在しなければ $M_r$ へ変換されにくい。

### 4.4 Raw resource $R$

Software / SaaS の $R$ は raw stock であり、それ自体はまだ有効維持能力ではない。

例として次がある。

- server capacity
- cache capacity
- spare compute / storage
- backup storage
- engineer time
- SRE / on-call time
- test infrastructure
- observability tooling
- deployment tooling
- budget
- vendor contract

重要なのは、これらを $M_i$ と同一視しないことである。engineer time があっても、権限・手順・依存関係が詰まっていれば rollback はできない。server capacity があっても、failover path がなければ $M_b$ は小さい。vendor contract があっても、incident response に接続されていなければ $M_{x\to r}$ は実効化しない。

この区別が、Paper 5 の中心である。

### 4.5 代理損失 $\hat L$

Software では真の $L$ を直接測るのが難しいため、最初は代理損失 $\hat L$ を事前固定する。

候補は次である。

| proxy | 定義の例 | 対応する損失 |
|---|---|---|
| boundary-crossing count | 1 change が横断する module / service / ownership boundary 数 | 影響範囲の拡大 |
| rollback-impossibility rate | 失敗時に即時 rollback できない change の比率 | 回復経路の喪失 |
| hidden dependency score | 明示 contract 外の呼び出し、逆流依存、設定共有 | 因果追跡不能 |
| special-case density | customer / environment / exception branch 密度 | 特例蓄積 |
| untested branch rate | 変更影響下で test coverage がない branch 比率 | 検証不能性 |
| observability gap | failure localization に必要な signal 欠落 | 原因同定困難 |

最初の pilot では、指標を増やしすぎない。推奨する最小構成は次である。

\[
  \hat L_{\mathrm{pilot}}
  =
  w_1 \cdot \text{boundary-crossing count}
  +
  w_2 \cdot \text{rollback-impossibility rate}.
\]

この二つは、safe change continuity と bug localization の両方に直接関係する。前者は「どれだけ広い構造を一つの変更が巻き込むか」を表し、後者は「失敗時に戻せるか」を表す。LOC、cyclomatic complexity、churn、age といった raw baseline と比較しやすい点も利点である。

### 4.6 Mode mapping

Software / SaaS における $M_i$ は、内部 mode と外部供給 channel を分けて操作化する。

| layer | software interpretation | candidate signals |
|---|---|---|
| $M_b^{\mathrm{int}}$ | 内在的に耐える力 | redundancy, graceful degradation, queue/cache slack, rate limit, circuit breaker, spare capacity |
| $M_r^{\mathrm{int}}$ | 内在的に戻す力 | rollback path, restore test, patch path, incident runbook, monitoring, localization, SRE response |
| $M_a^{\mathrm{int}}$ | 内在的に作り変える力 | feature flag, failover, modular replacement, boundary redesign, schema migration strategy, refactoring capacity |
| $M_{x\to b}$ | 外部から供給される buffering | managed service redundancy, cloud provider failover, external capacity burst |
| $M_{x\to r}$ | 外部から供給される repair | vendor incident response, external SRE, managed rollback support, upstream maintainer fix |
| $M_{x\to a}$ | 外部から供給される adaptation | consultant-led migration, upstream architectural change, external refactoring support |

§3 の区別に従えば、$M_x$ は同列の第四 mode ではなく、外部から他 mode を供給する channel / externalization profile である。たとえば、vendor support が incident rollback を支援するなら $M_{x\to r}$、managed service が redundancy を提供するなら $M_{x\to b}$、external consultant が boundary redesign を支援するなら $M_{x\to a}$ と読む。本文中で "$M_x$-supplied $M_r$" と書く場合、それは $M_{x\to r}$ の shorthand である。

有効 mode は、

\[
  \widetilde M_j = A_j(M_j^{\mathrm{int}}, M_{x\to j}),
  \qquad j\in\{b,r,a\},
\]

として記録する。$A_j$ は少なくとも単調非減少である。最初の pilot では加法型を baseline として使ってよいが、外部支援が内部能力を置き換えるのか、内部能力と相乗するのかは domain ごとに検査すべきである。

ただし、本稿では外部供給依存をそれ自体で善とみなさない。外部供給 channel は短期維持を強める一方で、自律的な $M_b^{\mathrm{int}}, M_r^{\mathrm{int}}, M_a^{\mathrm{int}}$ を置き換えない場合がある。したがって、software mapping では「外部支援が何を供給しているか」と「base system 側にその能力が内在化しているか」を分けて記録する。

### 4.7 $M_a$ の制限: architecture change と $F$ 保存

Software では、$M_a$ に architecture change, modular replacement, boundary redesign を含める。しかしこれは §2.3 の制限を受ける。

すなわち、$M_a$ は target function $F$ を保ったまま構造 $\Sigma$ を再編する能力である。たとえば、API contract を保ったまま内部 module 境界を整理する、feature flag で段階的に新実装へ移行する、schema migration に backward-compatible path を持たせる、などは $M_a$ に含めてよい。

一方、機能そのものを捨てる、SLA を下げる、対応しない顧客を切り捨てる、別プロダクトへ転換する、という変更は $F$ の変更であり、本稿の $M_a$ ではない。

## 5. 介入順位予測

本稿の主予測は、collapse profile の完全予測ではなく、介入順位予測である。

同じ $\hat L$、同じ raw resource $R$、同じ scalar $M_{\mathrm{total}}$ を持つ二つの software system でも、mode composition が違えば、有効な介入順位が異なる。

### 5.1 Intervention families

各 mode に対応する介入族を次のように置く。

| intervention | 対応 mode / channel | software examples |
|---|---|---|
| $I_b$ | $M_b^{\mathrm{int}}$ を増やす | spare capacity, redundancy, caching, queue buffer, graceful degradation |
| $I_r$ | $M_r^{\mathrm{int}}$ を増やす | rollback automation, restore drill, observability, incident runbook, patch path, contract test |
| $I_a$ | $M_a^{\mathrm{int}}$ を増やす | feature flag, failover design, boundary redesign, modular replacement, migration tooling |
| $I_{x\to b}$ | $M_{x\to b}$ を増やす | managed service redundancy, cloud failover, external capacity burst |
| $I_{x\to r}$ | $M_{x\to r}$ を増やす | vendor escalation, external SRE, managed rollback support, upstream maintainer fix |
| $I_{x\to a}$ | $M_{x\to a}$ を増やす | consultant-led migration, upstream redesign, external refactoring support |

この分類は、介入の名前ではなく、介入がどの持続様式をどの channel から増やすかによって決まる。たとえば「vendor support」は、それが rollback を代行するなら $I_{x\to r}$、容量を提供するなら $I_{x\to b}$ である。

### 5.2 Main prediction

本稿の最小主張は次である。

\begin{quote}
Comparable $\hat L$, comparable raw $R$, and comparable scalar $M_{\mathrm{total}}$ のもとで、mode composition が異なる software systems は、異なる intervention ranking を持つ。
\end{quote}

より具体的には、

- $M_b$ は高いが $M_r$ が低い系では、追加 capacity より rollback / restore / localization の改善が効きやすい。
- $M_r$ は十分だが $M_a$ が低い系では、局所 patch の追加より feature flag / boundary redesign / migration tooling が効きやすい。
- $M_{x\to r}$ 依存が高く内部 $M_r^{\mathrm{int}}$ が低い系では、短期維持は改善するが、同じ failure class が反復する場合、自律的 $M_r^{\mathrm{int}}$ または $M_a^{\mathrm{int}}$ への移行が必要になる。

これは「どの介入も常に効く」という主張ではない。むしろ、同じ総資源量に見える系でも、ボトルネック mode が異なれば、最初に投資すべき介入が変わるという主張である。

### 5.3 Example predictions

以下は §6 で validation protocol に落とす候補である。

**Case A: high $M_b$, low $M_r$**

システムには redundancy や spare capacity があるが、rollback path が遅い、restore drill がない、observability が弱い。障害時には耐えられる時間はあるが、原因同定と復旧が遅れる。

Prediction:

\[
  I_r > I_b
\]

すなわち、追加サーバや cache を増やすより、rollback automation、restore test、observability、incident runbook の改善が change failure impact や MTTR をより強く下げる。

**Case B: sufficient $M_r$, low $M_a$**

rollback と patch はできるが、同じ種類の変更で繰り返し障害が起きる。責務境界が崩れ、local patch が別の箇所を壊し続ける。

Prediction:

\[
  I_a > I_r
\]

すなわち、さらに rollback を改善するより、feature flag、boundary redesign、modular replacement、migration tooling の方が incident recurrence や lead time 悪化を下げる。

**Case C: high $M_{x\to r}$, low internal $M_r$**

vendor や managed service による外部復旧は強いが、base team 内に原因同定・rollback・再発防止の能力が蓄積しない。

Prediction:

\[
  I_r^{\mathrm{internal}} \text{ eventually outranks additional } I_{x\to r}
\]

短期には $I_{x\to r}$ が最も効くが、同じ failure class が反復する場合、内部 $M_r^{\mathrm{int}}$ の形成が長期の recurrence reduction には必要になる。

### 5.4 DeltaLint との分離

DeltaLint-like structural diagnostics は、software domain における強い候補である。ただし、本稿の主張である $M$ の mode decomposition / intervention-ranking prediction を直接検査するものではない。

DeltaLint が主に観測するのは、静的コード内の未整理な前提不整合、scope mismatch、guard 欠落、順序依存、設定干渉である。これは $M$ 側というより、局所的な $\hat L$ または $\Delta L$ risk の観測に近い。したがって、DeltaLint は Paper 5 の主 validation には含めない。

本稿では、DeltaLint を次のように位置づける。

- DeltaLint は Paper 5 の $M$-framework の実証柱ではない。
- DeltaLint は Paper 3 の unscoped contradiction / attribution repair に近い L-side static-code extension として、別 note で扱う。
- DeltaLint の既存実績は、Paper 5 においては動機づけ以上には使わない。
- DeltaLint が $M_r$ に関与するのは、triage、patch、CI gate、rollback、migration などの repair workflow に接続された場合に限られる。

この分離により、Paper 5 は $M$ 側の薄い主張を保ち、DeltaLint は静的コードにおける L-side predictor として、独立の baseline-controlled validation を持てる。

### 5.5 Non-claims

本節では、次を主張しない。

1. Software / SaaS が Route A ドメインであるとは主張しない。
2. $\hat L$ が真の $L$ と同一であるとは主張しない。
3. $M_i$ が単一の universal metric で測れるとは主張しない。
4. DeltaLint の既存実績だけで Paper 5 が実証されたとは主張しない。DeltaLint は本稿の主 validation から切り離し、Paper 3 / L-side の static-code extension として別 note で扱う。
5. 外部供給 channel が常に望ましいとは主張しない。外部支援は短期維持を助けるが、自律的能力を代替しない場合がある。
6. $M_a$ によって $F$ 自体を変更してよいとは主張しない。

---

## §4-5 で更新される判断

**Resolved by §4-5 draft:**

- Software / SaaS は Route C として扱う。
- Broad $F$ は safe change continuity、pilot $F$ は change-introduced bug detection / localization とする。
- Prompt design / runbook / checklist / CI-CD / operational protocol は $R$ ではなく $\Sigma$ 側として扱う。
- $M_x$ は同列の第四 mode ではなく、$M_{x\to b},M_{x\to r},M_{x\to a}$ として外部から各 mode を供給する channel として扱う。
- 最初の $\hat L_{\mathrm{pilot}}$ 候補は boundary-crossing count + rollback-impossibility rate を中心に置く。
- DeltaLint は Paper 5 の主 validation に含めず、Paper 3 / L-side の static-code extension として別 note に切り出す。

**Still open after §4-5:**

- Q7: time-split primary / leave-one-project-out secondary の具体設計。
- §6: baseline set, held-out outcome, metric, $\rho_i$ variation, $\Phi$ robustness の事前固定。
- §7 以降: limitations, future work, four-domain comparison の扱い。

## 次のアクション候補

1. §6 empirical validation protocol を起草する。
2. §1-5 全体を読み直し、main preprint に昇格する前の章構成を整える。
3. §7 limitations / non-claims / future work を起草する。
4. DeltaLint static-code extension note を Paper 5 とは別に拡張する。

推奨順: 1 → 2 → 3 → 4。§4-5 で software mapping は置けたため、次は Paper 5 固有の検証手順を固定するのが自然である。
