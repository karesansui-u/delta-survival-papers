# 日本語プレプリント用語監査メモ

このメモは、`PREPRINT_THEORY_ja.md` と `PREPRINT_LEAN_ARTIFACT_ja.md` の日本語説明を、旧 v3 文書
`01_theory/02_accounting_framework.md` の読みやすさに寄せるための用語方針である。

## 基本方針

本文では日本語を主にする。

英語を残すのは、次の三つに限る。

1. 数式記号として使うもの。
   例: `F`, `K`, `V_K`, `m`, `L`, `B`, `R`, `M`, `S`, `C_req`
2. Lean の宣言名・型名・ファイル名。
   例: `StructuralPersistenceWellFormed`, `CanRecoverTo`, `PROOF_AUDIT.md`
3. 日本語だけでは既存分野との接続が弱くなる定着語。
   例: Lean, Ising, Gibbs, ESG, AI

それ以外の説明語は、日本語へ寄せる。

## 置換する語

| 混ざりやすい語 | 本文での推奨語 | 備考 |
|---|---|---|
| readout | 読み取り | Lean 宣言名に含まれる場合だけ英語のまま |
| failure readout | 失敗読み取り | 「故障モード」より広い |
| runtime readout | 実行時読み取り | Lean 型名 `RuntimeFailure` は残す |
| diagnostic report | 診断報告 | |
| cross-domain report | 領域横断報告 | |
| proxy | 代理測定 | 初出で「proxy」と併記してもよい |
| proxy candidate | 代理測定候補 | |
| proxy certificate | 代理測定証明書 | |
| validation protocol | 検証手順 | |
| theorem fuel | 定理の入力 | 比喩が強いので本文では避ける |
| raw resource | 名目資源 | `R` の説明では「生資源」より自然 |
| effective resource | 有効資源 | `M` |
| effective support | 有効な支え | |
| reported label | 報告ラベル | |
| certified readout | 証明済み読み取り | |
| certificate | 証明書 | Lean 名の一部なら英語のまま |
| witness | 証人 / 証拠 | 数理文脈では証人、一般文脈では証拠 |
| boundary | 境界 | |
| target-relative | ターゲット相対 | |
| identity-relative | 同一性相対 | |
| function-relative | 機能相対 | |
| coupling | 結合 | |
| externality | 外部性 | |
| bottleneck | ボトルネック | 定着語として可 |
| adapter | 接続層 / アダプタ | Lean ファイル名では英語のまま |
| frontier | 境界候補 / フロンティア | 実装名以外は境界候補 |
| policy | 方針 | Lean 定義名では英語のまま |

## 残してよい語

| 語 | 理由 |
|---|---|
| Lean | 固有名 |
| Ising | 固有モデル名 |
| Gibbs | 固有名・定着した物理/確率語 |
| ESG | 固有略語 |
| AI | 固有略語 |
| CanRecoverTo | Lean の定義名 |
| RuntimeFailure | Lean の型名 |
| Admission / Ontology / Handoff | Lean 層名として残してよい。ただし本文説明では日本語を添える |

## 旧 v3 文書が読みやすい理由

旧文書は、英語の型名ではなく、読者がすでに持っている問いから入っている。

- 「構造は、資源が残っていても保てなくなりうる」
- 「何を保てば同じものとして続いていると言えるか」
- 「観測前に固定する」
- 「これは経験法則ではなく、事前固定された残存比の会計である」

この順序では、数式は読者の問いに答えるために出てくる。

新しい文書は、Lean 実装の棚である `Admission`, `Ontology`, `RuntimeFailure`, `Proxy` が早く出るため、
理論の直感より先に実装境界が見えてしまう。結果として、厳密だが「何のための理論か」が遅れて届く。

## 新文書で守る順番

1. まず現象を言う。
   例: 「資源が残っていても、構造は保てなくなりうる」
2. 次に分離を言う。
   例: 「だから `L/B` と `M` を分ける」
3. その後に主導線を出す。
   例: `F -> K -> V_K,m -> L/B -> R/M -> S`
4. 最後に Lean の役割を出す。
   例: 「証明書として入った後の会計帰結を検証する」

Lean 用プレプリントでも、この順序を崩さない。
