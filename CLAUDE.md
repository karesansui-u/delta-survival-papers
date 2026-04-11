# delta-survival-paper — Project Rules

## 数式表記ルール

- 数式行（インデント行）: `e^{-L}` を使う（美しい形）
- 本文中の引用: `exp(-L)` を使う（読みやすい形）
- 中心式: `S = Me^{-L}`
- 記号体系: S（持続力）、M（有効維持資源）、L（累積損失）で統一。δ は使わない

## 言語ルール

- 論文本文は日本語で書く
- 技術固有名詞（LoRA, DAG, SAT, LLM, T2 collapse）と数式記号（S, M, L, μ, N_eff）はそのまま
- それ以外の英語表現は日本語に置き換える（例: proxy → 代理指標、overwrite → 上書き、retention fidelity → 保持忠実度）

## ファイル構成（v2/）

### 本編（4本）
- 1_構造持続の最小形式.md — 骨格。S = Me^{-L}
- 2_構造持続の条件つき導出.md — 数学的基盤。A1-A3、弱依存境界、Lean検証
- 3_構造持続と推論性能の劣化.md — 推論時の性能劣化 + 実験（30ターンON/OFF/NC, 100ターン長期）
- 4_構造持続と継続学習における破滅的忘却.md — 継続学習のLoRA実験 + 三層統合（§7.5、旧Paper 5を統合）

### 補足資料（2本）
- 補論_計算コストの構造的予測.md — SAT Route A。Lが直接計算できるドメインでの最硬の土台
- 補論_構造持続写像フレーム.md — DSMF。任意ドメインへの適用手順。Route A/B/C、反証条件、基準モデル比較、予測頑健性テスト（手順10.5）

### 予測記録
- prediction_qwen35_27b.md — §1-6: 初回予測と結果照合。§7: Sonnet代謝+案C再実験の事前予測

## 実験データ・スクリプトの所在

プレプリント公開時に整理・公開が必要。現時点で全て揃っている。

### Paper 3（推論の崩壊）関連
| 項目 | 場所 |
|------|------|
| gemma4:31b 30ターン実験データ (ON/OFF/NC, n=3) | delta-zero `data/experiments/stageb_gemma4_31b/` |
| qwen3.5:9b 100ターン実験データ | delta-zero `data/experiments/stageb_qwen35_9b_latestcorr_smoke/` |
| experiment_runner.py | delta-zero `scripts/` |
| benchmark_runner.py | delta-zero `scripts/` |
| scenario_generator.py | delta-zero `scripts/` |
| rejudge スクリプト | delta-zero `scripts/rejudge_benchmarks.py`, `rejudge_contra.py` |
| contra_audit_smoke.py | delta-zero `scripts/` |

### Paper 4（学習の崩壊）関連
| 項目 | 場所 |
|------|------|
| LoRA実験データ（7モデル） | delta-infinity-seed 配下（各モデルディレクトリ） |
| E-lite, F-v2c, F-multi 実装 | delta-infinity-seed `src/phase2_lora_premise.py` 等 |
| headquarters DAG生成 | delta-infinity-seed `src/phase2_data.py` |
| Lean形式検証コード | https://github.com/karesansui-u/delta-survival-papers/tree/main/lean |
