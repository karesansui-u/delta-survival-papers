情報資格制御ノート
====================

これは「Information Qualification Control (IQC; 情報資格制御)」の、外向けに短く追える版です。

IQC は LLM の意味論全体を証明する枠組みではなく、
長期記憶・推論・更新を使う前提で情報の“資格”を明示し、
抽象 kernel の中で再利用可能な形に落とす設計境界です。


制御対象
--------

保存・検索・回答・更新の各段階で、次の情報属性で情報を評価します。

- source（出所）
- speechAct（発話行為：要求/訂正/事実報告/雑談の区別）
- permission（保存・利用許可）
- scope（用途・人物・守秘性の文脈一致）
- versionState（前提の最新性）
- use condition（安定性、再利用適合性）

この判定で、

- `qualified`（許可）
- `blocked`（拒否）
- `invalidate`（無効化）
- `repair`（更新反映）
- `abstain`（保留）

のいずれかへ分岐させます。


Lean 連結の主張（3段）
----------------------

1. `EpistemicControlBridge` が「contradiction update」「repair update」「filter」「dependency rewrite」を
   有限 `ProblemSpec` に載せる。

2. `EpistemicControlComparison` と `EpistemicControlEvaluationContract` が、
   同一初期質量 + 同一地平 + net-action 不悪化の条件で
   `coherentMass_controlled >= coherentMass_baseline` を与える。

3. `EpistemicBenchmarkProtocol` / `EpistemicBenchmarkResultCertificate` / `SoftwareEvidenceNetActionBridge`
   が、実験結果アーティファクトの witness 前提を明示し、上の比較定理を起動する。

要するに Lean は、

```text
前提付きの qualification 契約と witness がそろえば
  -> NetActionNoWorse
  -> coherent mass の下界比較
```

を示します。これが本研究の中心主張です。


中身非依存の前段（sentinel 契約）
---------------------------------

IQC 本体に入る前に、入力タプルだけを見て「即時拒否」「上位への昇格」「保留」「受理」を
判定する前段層を置く設計がある。これを抽象的に取り扱うのが
`EpistemicSentinelContract` モジュールで、以下を Lean 側に追加する。

- `SentinelDecision` と `SentinelStepReadout`：1 ステップ分の判定面と読み出し。
- `SentinelPolicyContract`：「hot path で意味解釈を行わない」「hard reject が健全」
  「escalate path が健全」という設計時前提を、外部証拠（仕様・テスト・ベンチマーク）
  によって満たすべき命題として明示する。
- `SentinelEvaluationMetrics` / `SentinelOperationalDominance`：judge 呼出回数・
  escalation recall・false abstention の 3 指標について、controlled が baseline を
  下回らないという有限地平の dominance 仮定を持ち込む。
- 橋渡し定理 `sentinel_metrics_controlled_coherentMass_ge_baseline` が、
  sentinel 側の dominance 仮定を既存の `coherentMass_controlled >= coherentMass_baseline`
  に接続する。

ここでも Lean は「具体的な実装が中身非依存である」ことや「経験的に最適である」
ことは証明しない。これらは外部証拠の側で示すべき項目として `SentinelPolicyContract`
の中に Prop として明記され、定理側の形だけを固定する。


実装側の読み替え
----------------

`v3/05_evidence/iqc_failure_suite_final_result_ja.md` に最新の実装サマリがあります。

注入経路の整合を直した設定では、表は次の通りです。

- M1（source attribution）: 96%
- M2（speechAct）: 100%
- M3（permission）: 100%
- M4（versionState）: 96%

実装結果は、M2/M3 は単独最高、M4 は naive RAG と同率最高、M1 は中立（neutral）という
読みを与えています。これは IQC の最終結論ではなく、実装 surface 上の package-scoped な
ベンチマーク観測です。

Lean の theorem side ではないため、以下は別です。

- 実 LLM の意味論が正しいこと
- ベンチマーク分布の完全な妥当性
- プロダクト信頼性の一般定理


読み筋（外部向け）
-------------------

- Lean: witness が与えられれば比較定理が使える
- Runner: 形式化したスキーマと集約処理を検査
- Manifest: task surface / readout / horizon を事前固定
- 証拠: 運用 run が witness を供給

`support` 判定の強さは、実行結果がこの3層を一貫して通る時にだけ上がります。


次に読む場所
------------

- `v3/01_theory/en/04_information_qualification_control_note.md`（英語版）
- `v3/01_theory/figures/figure5_iqc_assumption_to_guarantee_chain_en.svg`
- `v3/03_domains/02_structurally_inferred/llm_epistemic_control_bridge.md`
- `v3/CLAIMS.md`
- `lean/Survival/EpistemicBenchmarkResultCertificate.lean`
- `lean/Survival/EpistemicSentinelContract.lean`
- `v3/05_evidence/iqc_failure_suite_final_result_ja.md`

