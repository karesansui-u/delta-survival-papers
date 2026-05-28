# Information Qualification Control (IQC) Failure Suite 最新結果サマリ

Status: published implementation-side benchmark summary
Date recorded: 2026-05-27
Evaluator: bare environment / hybrid judge
Claim boundary: empirical benchmark summary, not Lean theorem-side evidence

Implementation source:

- Repository: `karesansui-u/delta-zero`
- PR: <https://github.com/karesansui-u/delta-zero/pull/2>
- Merged commit: `8d0b3b2909280db8c45b08df3818612729440323`
- Commit title: `feat(iqc): publish failure suite and L5 readout controls`
- Final integration validation reported by the implementation package:
  220 passed, 2 warnings

このメモは、Information Qualification Control (IQC; 情報資格制御) の
failure-suite benchmark の最新整理を
公開 evidence 層に固定するための読者向けサマリである。raw output、runner
log、実装差分、個別 transcript は implementation-side artifact として扱い、
この公開 v3 bundle では数値、読み方、境界、既知の残課題だけを記録する。

ここでの Information Qualification Control とは、情報を保存、検索、回答、
行動、学習更新に使う前に、その情報が source-attributed / confirmed / storable /
current / in-scope かどうかを明示的に資格づける制御層を指す。

ここでの hybrid judge は keyword-first + LLM fallback の採点器を指す。
したがって、これは「LLM judge だけ」の結果ではない。

## Runner Correction

旧 runner では、benchmark setup を通常対話に近い経路で投入していたため、
setup 投入だけで応答生成、timeout、memory pollution、代謝タイミングが混ざりうる
状態だった。最新 runner では setup / update を `/session/inject` 経路に揃え、
setup / update を「記憶注入のみ」として扱う。

さらに M3 の no-store 系では、benchmark 用の injection 経路が本番の
no-store policy と一致していない問題が見つかった。通常対話では
non-persistent 入力を L1 / L2 に保存しない一方、旧 benchmark injection 経路では
WorkingMemory に先に入っていたため、L3 に昇格していなくても probe 時に
直近会話として参照されうる。この経路を修正し、non-persistent injected user turn
を L1 / L2 に残さないようにした後の結果をここに記録する。

Implementation-side regression state:

- benchmark packet assembly note: focused regression subset recorded
  115 passed, 2 warnings before public merge
- final published integration validation: 220 passed, 2 warnings
- M3 focused rerun artifact: `results_iqc_m3_compare.json`
- M3 no-store leak after correction: 0 / 20

これらの implementation-side artifacts は、この v3 public tree の theorem-side
artifact ではない。

## Latest Results

| Qualification type | Failure mode | raw | context_only | naive_rag | IQC control layer |
|---|---:|---:|---:|---:|---:|
| source | M1 引用誤昇格 | 96% | 96% | 100% | 96% |
| speechAct | M2 弱い相槌 | 95% | 90% | 85% | 100% |
| permission | M3 保存禁止違反 | 80% | 80% | 85% | 100% |
| versionState | M4 依存更新失敗 | 52% | 88% | 96% | 96% |

## Cross-LLM Reproducibility (3 LLM family, n=90)

上の qwen3.5:27b 主結果に加えて、同じ failure suite を別 LLM family
(gemma4:31b, openai gpt-4o-mini) で再実行した。3 LLM が直接比較できる 4 backend
(raw / context_only / naive_rag / naive_rag_qualified) について全体 PASS 率は
次である。

| backend | qwen3.5:27b | gemma4:31b | openai gpt-4o-mini |
|---|---:|---:|---:|
| raw | 55.6% | 45.6% | 41.1% |
| context_only | 68.9% | 62.2% | 43.3% |
| naive_rag | 72.2% | 62.2% | 50.0% |
| naive_rag_qualified | 90.0% | 92.2% | 78.9% |

prompt 向上量 (PR(naive_rag_qualified) − PR(raw)) を case-paired bootstrap
(5000 iter, 95% CI) で取った結果は次である。

| LLM family | prompt 向上量 | 95% CI |
|---|---:|---|
| qwen3.5:27b | +34.4pp | [+22.2pp, +46.7pp] |
| gemma4:31b | +46.7pp | [+35.6pp, +57.8pp] |
| openai gpt-4o-mini | +37.8pp | [+25.6pp, +50.0pp] |

3 LLM family いずれにおいても CI 下端が +22pp を上回り、prompt / control-layer
側の効果が LLM family 非依存に再現することを示す。iqc / iqc_no_fastpath の
比較は本節では行わない (openai は agent 統合未実施、gemma は IQC pipeline の
1 ケース所要時間が試行時間予算を超過したため構造的に除外)。したがって本節の
主張は「prompt / control-layer 側の cross-LLM 再現性」に限定し、full IQC
pipeline の cross-LLM 優位性ではない。

## Reading

M2 speechAct tracking:

Information Qualification Control (IQC) は単独最高である。naive_rag より +15 pt、context_only より +10 pt。
弱い相槌や曖昧な同意を確定事実へ誤昇格させる失敗が、この suite では 0 件だった。

M3 permission tracking:

Information Qualification Control (IQC) は L1 injection policy correction 後に単独最高である。raw / context_only
より +20 pt、naive_rag より +15 pt。no-store / non-persistent 入力を
通常の memory path と同じ保存ポリシーで扱った後、no-store leak は 0 / 20 になった。

M4 versionState tracking:

Information Qualification Control (IQC) は naive_rag と同率最高である。raw より +44 pt。これは、依存更新問題が
記憶アーキテクチャだけでも大きく改善しうること、そして Information Qualification Control がその水準に到達することを
示す。残った `m4_22` は旧値誤用ではなく、「保存済み記憶にはない / 確認が必要」
という abstention / retrieval miss である。したがって、versionState が旧値利用を
防げなかった失敗ではなく、更新値 recall の取りこぼしとして読む。

M1 source tracking:

Information Qualification Control (IQC) は raw / context_only と同等であり、naive_rag には 4 pt 届かない。
この suite では source attribution はベース LLM / retrieval でも比較的扱いやすい。
したがって、M1 は Information Qualification Control の追加優位を示す主結果ではなく neutral result として読む。

## Main Empirical Claim

この suite が支える安全な主張は次である。

> Information Qualification Control (IQC) は、単なる retrieval ではなく、speechAct / permission / versionState の
> qualification を明示的に管理することで、長期記憶由来の誤昇格、保存禁止違反、
> 前提更新ミスを低減する候補である。この failure suite では M2 / M3 で全比較対象を
> 上回り、M4 では naive_rag と同等最高性能を示した。一方、source attribution 型の
> M1 では追加優位は限定的だった。

## Boundaries

このメモは次を主張しない。

- Lean が実 LLM の意味論、性能、memory safety を証明したこと。
- Information Qualification Control が任意自然会話、実 product traffic、任意 memory backend で安全であること。
- source / speechAct / permission / versionState 以外の memory qualification
  failure を解いたこと。
- M3 の修正前結果を support として読むこと。
- implementation-side runner が自然言語意味論を完全に検証していること。

外部説明では、この結果は theorem-side result ではなく、
package-scoped empirical benchmark summary として引用する。
