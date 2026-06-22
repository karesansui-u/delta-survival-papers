# M側補論

Temporal effective support claim としての M

2026年6月6日

## 概要

本補論で残す主張は二つだけである。

第一に、構造持続理論における $M$ は、名目資源 $R$ の量ではない。$M$ は、ある $F/K$ を、ある期限、前提、到達経路、証明書のもとで実際に支えてよい qualified support claim である。資金、人員、設備、病床、GPU、部品、制度、信用、時間は $M$ claim の source になりうるが、それだけでは $M$ ではない。

第二に、現在の evidence は、$M$ 側の分離が必要であることを示す有限 anchor と protocol-facing support を持つが、外部実ドメイン一般で $M$ の予測力が検証済みである、とは主張しない。M 側は理論核としては必要であり、形式面では $L$ と同じ typed accounting interface に載っている。しかし経験面では、$L_{\mathrm{mass}}$ の held-out support と M 側の anti-collapse / licensing anchor は証拠の種類が違う。

したがって本補論は、M 側の包括的レビューではない。主論文の読みを支えるための最小限の境界メモである。

```text
R = nominal source / stock
M = scoped, qualified, temporally eligible support
S = M * exp(-L) or certificate-scoped variant
```

ここで $S$ は accounting potential であり、survival prediction ではない。また、実務で扱う多くの値は、真の $S$ ではなく、proxy と certificate から作られる報告量 $\hat S$ である。$\hat S\simeq 0$ を真の $S=0$ と同一視するには、誤差境界、測定プロトコル、bridge certificate が必要である。

### M 測定・主張強度ラダー

本理論は、完全に分解された $M$ だけを使う理論ではない。粗い $M$ proxy でも、事前固定された対象、期限、endpoint、baseline のもとで予測や介入判断に効くなら使ってよい。ただし、粗い proxy は粗い claim だけを license する。

| Level | 読み | 許される claim |
|---|---|---|
| 0. informal diagnosis | 「M が足りないかもしれない」という探索的読み | 仮説・探索メモ |
| 1. proxy M | 粗い M proxy を事前固定する | この proxy は、この対象・期限・endpoint の候補説明変数 |
| 2. validated proxy M | held-out / matched / intervention / audit で proxy が効く | この domain / horizon / endpoint では M readout として使える |
| 3. licensed M | target、horizon、assumptions、path、certificate が揃う | support claim licensing に使える |
| 4. frontier / normalized M | $M_{\mathrm{available}}/M_{\mathrm{required}}$、support threshold、frontier certificate が揃う | support shortfall、non-license、finite bound を言える |

構造持続理論が禁止するのは粗い proxy そのものではなく、粗い proxy から強い claim を無断で出すことである。

---

## 1. M は raw resource ではない

構造持続理論の読み取り主線は、直列ではなく二枝合流で読む。

```text
構造側:
  F, K -> V_K, m -> L/B

資源・支える側:
  claim scope, horizon, assumptions, path, certificates
  + optional R sources
  -> M

境界 readout:
  (L/B, M) -> S
```

$M$ は $m$ や $L$ の後段から出る量ではなく、次の条件によって資格づけられる support projection である。

- target: 何を維持・回復・支援するのか。
- horizon: いつまでに、どの期間で支えるのか。
- assumptions: どの前提、互換性、制度、契約、状態を仮定するのか。
- path: source から target へ実際に届く経路があるのか。
- certificate: その支えを claim に使ってよい証明書があるのか。
- lifecycle: その claim は active / valid / compatible な現在射影に入ってよいのか。

したがって $M$ は source list ではなく claim list である。次の読みは避ける。

- 「資源量が多いから $M$ が大きい」
- 「$R$ と $M$ は同じもの」
- 「単純な支えの合計がそのまま $M$」
- 「後から有効だったものだけを選べば $M$」
- 「$M$ が正なら生存予測になる」

安全な読みは狭い。

> 与えられた target / horizon / assumptions / path / certificate のもとで、
> claim に使ってよい qualified support が $M$ である。

Temporal resource では、過去に発行された claim が後から失効、毀損、訂正されることがある。このとき過去の claim を書き換えない。append-only な lifecycle event を追加し、現在の projection では active / valid / compatible な claim だけを読む。

### M側 log readout

M 側で対数読みを使う場合も、裸の `log M` は使わない。log ledger に入るのは、同じ文脈に scoped された required support に対する無次元比だけである。

```text
support_ratio = M_available / M_required
support_log_margin = log(M_available / M_required)
signed_support_log_shortfall = log(M_required / M_available)
```

正の支え領域では、required-normalized な S-potential deficit が L 側損失と M 側 shortfall の和として読める。

```text
D_nats = -log((M_available * exp(-L)) / M_required)
       = L + log(M_required / M_available)

D_bits = D_nats / log 2
```

これは形式的な accounting identity であり、M 側の経験的検証を意味しない。$D_{\mathrm{nats}}$ を failure / recovery / support-license 境界の経験仮説に使うには、target、horizon、endpoint、cutoff、$L$ proxy、$M_{\mathrm{available}}$ projection、$M_{\mathrm{required}}$ certificate、baseline、held-out split、negative / shuffled-M control を結果を見る前に固定する。外れた後で「真の $M$ は別だった」と言い直す場合は、新しい仮説として再登録し、同じデータで支持を主張しない。この仮説の位置づけは主論文の第3節・第14節で述べた。

### M の近似測定規律

$M$ の測定が難しいのは、$M$ が関係量だからである。$L$ は対象の状態からある程度内在的に読めるが、$M$ は target / horizon / path / certificate との関係でしか決まらず、$M_{\mathrm{required}}$ に至っては反事実量である。しかし、このことは「$M$ は正確に測れないから使えない」を意味しない。要求されるのは正確さではなく、**誤差の向き**、または判定マージン以下の誤差である。

第一の規律は、片側近似の健全性である。保守的な下界 proxy $\hat M_{\mathrm{lower}} \le M$ だけがあれば、$M_{\mathrm{required}} \le \hat M_{\mathrm{lower}}$ から support threshold の認可が健全に出る。保守的な上界 proxy $M \le \hat M_{\mathrm{upper}}$ だけがあれば、$\hat M_{\mathrm{upper}} < M_{\mathrm{required}}$ から非認可が健全に出る。両方あれば区間 $[\hat M_{\mathrm{lower}}, \hat M_{\mathrm{upper}}]$ になり、**区間全体で不変な判定だけが真の座標へ射影される**。閾値をまたぐ区間は、どちら向きの判定も運ばない。これらは Lean 側で固定済みである: 片側証明書は `ConservativeResourceLowerProxy` / `ConservativeResourceUpperProxy`、束ねと判定健全性、不確定帯が判定を運ばないことの有限 witness、$D_{\mathrm{nats}}$ の区間転送（真の赤字は端点読みの間に挟まる）は `StructuralPersistenceResourceIntervalDecision` にある。

第二の規律は、対数読みによる必要精度の逆算である。$\ell_M = \log(M_{\mathrm{required}}/M_{\mathrm{available}})$ なので、$M$ の相対誤差がそのまま nat 単位の絶対誤差になる。判定マージンが誤差より十分大きい claim は保守的に運べる、というのは proxy robustness 層の一般原則であり、M 側ではこの形で具体化する。「$M$ を相対 20% で測れれば、約 0.22 nat 以上のマージンを持つ判定まで使える」という形で、claim ごとに必要精度が決まる（log 誤差は下振れ側 $-\log(1-\varepsilon)$ が支配するため、保守側で読む）。

第三の規律は、近似対象の選択である。$M$ を直接スカラー化せず、変換係数へ分解する。

```text
M_available = sum_g q_g * r_g
```

$r_g$ は名目チャネルの存在（R 側。ログ・台帳から読める）、$q_g \in [0,1]$ はそのチャネルの資格・変換係数（target / horizon / path / 権限に照らして実際に使える度合い）である。難しさは $q_g$ に局在し、$q_g$ は有界でチャネルごとに独立に測定・監査・改善できる。なお、この和の形自体がチャネル独立加法という宣言済みの合成選択であり、チャネル間の相互作用（担当者がいても担当グループが未確定なら効かない、など）を係数の中に押し込んでいる。相互作用が効くドメインでは、結合チャネルを一つの $g$ として切り直すか、合成規則を別途証明書として宣言する。$q_g$ の測定にはコスト昇順のラダーがある。

1. **構造的上下界**: 上界は全開チャネルを $q=1$ と読む。下界は明示証明書つきチャネルのみ数える。測定なしで区間 $M$ が立つ。
2. **凍結チェックリスト rubric**: 権限・期限内到達・手順の現行性・承認状態などを事前凍結したチェックリストで読み、$q_g$ を充足率または全充足 min 型で与える。監査上の認識要件と同型の測定である。
3. **期限分割で校正した実績 $q$**: チャネルの過去の別期限での実績から $q_g$ を推定する。outcome を使う fitted proxy なので、評価対象より前の窓への凍結（leakage 遮断）と、proxy validation certificate、二段構え報告を要する。
4. **介入応答**: $M$ は定義上「使えるか」なので、最上位の測定は支え注入への応答である。名目 $R$ を足しても変わらなければ変換不全の証拠、権限付与や承認解除で変われば $M$ が束縛座標だった証拠になる。

この分解は、上のラダーの Level 1 から Level 2 への昇格を具体化するものである。なお、$M$ と $M_{\mathrm{required}}$ に固有単位が最初からあるドメイン（人員時間、ランウェイ日数、在庫カバー、病床数など）は、$q \approx 1$ で済む特殊ケースとして安価だが、固有単位がないドメインを適用範囲から外す理由にはならない。対象、期限、チャネル、資格証明書を固定できる限り、$q$ 分解、区間 $M$、マージン規律によって、同じ読み方を試すことができる。

### Lean artifact との対応

Lean artifact が保証するのは、証明書つき入力からの readout である。たとえば、temporal M claim の current projection eligibility、support threshold と certified upper bound からの non-licensing、supplied exact / search / network frontier certificate による支え閾値境界、protocol-scoped frontier の no-leakage / provenance guard、supplied necessary / sufficient bridge による domain claim predicate への限定接続、required-normalized support ratio の符号 readout、raw `R` と qualified `M` を同一視しない finite witness、scalar potential から M/L 座標を復元できない non-identification witness などである。

M 側の限界定理レイヤーは、現時点では **certified finite frontier** である。supplied capacity certificate があるときに、不可能側と達成可能側を同じ $C$ で挟む。capacity の発見、実ドメイン妥当性、recovery / survival bridge は別問題として残る。

一方、Lean は次を保証しない。

- 実ドメインで $M$ proxy が正しく測られていること
- 外部 operational log で M が held-out recovery を予測すること
- あるドメインの M claim を別ドメインへ転送してよいこと
- intervention が成功すること
- $S>0$ が survival prediction であること

Lean は reading interface を閉じる。外部世界の測定、妥当性、転送、予測利用は、別の certificate または validation layer の責任である。

---

## 2. 現在の evidence 境界

M 側の最小の読みは、次である。

> 同じ raw resource や単純 support 和を持っていても、qualified support gate、
> path、license、lifecycle、target compatibility が違えば、claim に使える $M$ は
> 変わりうる。

M 側の現在の evidence は、この anti-collapse claim を支えるためのものとして読む。

### 現時点で言ってよいこと

- M は raw resource や単純和と同一視できない。
- qualified support gate / path / license の差は、有限 readout 上で消えない場合がある。
- supplied exact finite frontier がある場合、`required <= capacity` と support
  threshold satisfaction の同値を Lean で検証できる。
- QSA finite benchmark と SRE-H1 operational-shaped matched benchmark は、
  frozen code / frozen package の計算再現性を持つ。
- これらは M 側の finite-benchmark support signal であり、M 側を理論から削るべきでない
  ことを支える。ただし、support は package-scoped である。

### 現時点で言ってはいけないこと

- M 側が外部実ドメイン一般で検証済みである。
- QSA や SRE-H1 が real-domain typicality を証明した。
- M が L と経験面で同格に確立された。
- M proxy がどのドメインでも sound である。
- M claim が別ドメインへ自動的に転送できる。
- $M$ を入れると recovery prediction が一般に改善する。
- M 側 finite support が intervention success を証明する。

### 外部 SRE 系列の現在地

外部 incident archive 側の現在地は、一つの branch-local 結果に要約できる。

UCI の ServiceNow 由来 incident event log から、pre-terminal operational cutoff を持つ 12,600 cases を `SRE-H1-UCI-Early` branch として凍結した。row admission、encoder / reconstruction certificate、outcome 非依存 split、shuffled-M / missingness / report-style controls、model matrix、outcome label の各 gate は、いずれも結果を見る前に design として凍結・監査されてから実行された。各工程の凍結記録と監査は `outputs/` の `sre_h1_uci_early_*` 系 ledger に残してある。

この frozen protocol のもとで、`L_R_M_primary` は held-out test NLL で `R_plus_L`、`L_R_shuffled_M`、control-only baselines を上回り、decision は `uci_early_qualified_M_incremental_information_candidate_under_frozen_protocol` となった。post-fit audit、8 点 learner sensitivity grid、feature leakage guard も通過した。外部再実行では、fit-only rerun が semantic diff 0 で再現され、raw zip からの raw-to-fit full rerun も、二度の packaging defect 修正を経た第三返送で design audit と全 41 phase を通過した。41 manifest 中 37 は byte 一致、4 は float64 最終桁 drift のみで、semantic diff は 0 である。

したがって、ここで license されるのは、frozen protocol 下の UCI-Early branch-local pipeline reproduction までである。SRE-H1-Full admission、一般 external SRE support、一般 external M signal、cross-archive transport、recovery / survival theorem は license されない。

同じ UCI-Early 枝で、$\alpha=\beta=1$ を事前固定したスカラー持続赤字 $D_{\mathrm{nats}}$ の第一号検査も行った（全 fold 使用済みのため、データ再利用申告つき。設計と決定化は結果接触前に凍結・commit 済み）。点推定では全基準線を上回ったが、最良基準線である $L$ スカラー単独に対する bootstrap 下限が負であり、凍結規則上 no-support 記録となった。凍結済みの棄却順序に従う診断は、重みではなくスカラー化の縮退である。M ブロック（どの担当・どのグループが支えるか）は held-out で効くのに、gate 開数（いくつ開いているか）への圧縮はその情報のほぼ全てを捨てた。これは、$M$ の予測内容が量ではなく資格・質に宿るという本補論の主張の、負の側からの確認として読む。上の近似測定規律の言葉では、全チャネル $q=1$ の gate 開数は上界 proxy としては正当だが、点推定として使ったことが誤りだった。記録は `sre_h1_uci_early_dnat_unit_weight_*` 系 ledger に残す。

### 何が次の support になるか

M 側を経験面で強くするには、次の形が必要である。

```text
same or controlled R
same or controlled L/B
frozen M proxy / certificate
pre-outcome decision cutoff
held-out recovery or support-claim readout
missingness and leakage guards
negative / shuffled-M controls
external or independently rerunnable archive
```

この条件のもとで、qualified temporal M support が held-out readout に残るなら、M 側の empirical support claim は強くなる。逆に、これがない場合は、finite anchor と protocol-facing support に留める。M 側の未決性は弱点ではなく、claim boundary の一部である。L 側の支持を M 側へ水増ししない。M 側の no-support や silence を失敗として隠さない。

### 主論文へ持ち込む最小文言

主論文では、M 側について次の短い文言で足りる。

> $M$ は名目資源 $R$ ではなく、target、horizon、assumptions、path、certificate、
> lifecycle によって資格づけられた temporal effective support claim の現在射影である。
> 現在の有限 benchmark は、$M$ を raw resource や単純和へ潰せないことを支持する。
> ただし、外部実ドメインでの予測利用、介入成功、ドメイン間転送は未検証であり、
> 別途 proxy soundness、validation、transport certificate を要する。

これ以上の詳細は、個別の output / protocol artifact に残せばよい。プレプリント本体で必要なのは、M が理論上なぜ必要か、そして現時点でどこまでしか言えないかである。

---

## 結論

M 側補論の役割は、M 側の全履歴を保存することではない。残すべき点は二つだけである。

第一に、$M$ は raw $R$ ではない。$M$ は、対象、時間、前提、到達経路、証明書、lifecycle によって資格づけられた temporal effective support claim である。

第二に、現在の evidence は、この分離を消してはいけないことを支える有限 anchor を持つが、外部実ドメイン一般での予測力や転送可能性を証明してはいない。

この二点を守れば、M 側は過大主張なしに主論文へ接続できる。
