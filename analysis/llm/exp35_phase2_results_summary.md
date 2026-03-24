# Experiment 35: Phase 2 Full Results (GPT-4o-mini)

Date: 2026-03-23
Model: gpt-4o-mini
Trials per cell: 30
Task: a + b + c (3-digit addition, target at prompt start)

## Results (128K excluded — API context window limit artifact)

| Context Length | δ=0 Accuracy | δ=0 (n) | δ>0 Accuracy | δ>0 (n) |
|:--|:--|:--|:--|:--|
| 500 | 1.00 | 30/30 | 0.10 | 3/30 |
| 1,000 | 1.00 | 30/30 | 0.20 | 6/30 |
| 2,000 | 1.00 | 30/30 | 0.03 | 1/30 |
| 4,000 | 1.00 | 30/30 | 0.10 | 3/30 |
| 8,000 | 1.00 | 30/30 | 0.07 | 2/30 |
| 16,000 | 1.00 | 30/30 | 0.10 | 3/30 |
| 32,000 | 1.00 | 30/30 | 0.07 | 2/30 |
| 64,000 | 1.00 | 30/30 | 0.07 | 2/30 |
| 96,000 | 1.00 | 30/30 | 0.20 | 6/30 |
| **128,000** | **0.00** | **0/30** | **0.00** | **0/30** |

## Aggregate (excluding 128K)

- δ=0: **270/270 = 100.0%** — zero degradation up to 96K tokens
- δ>0: **28/270 = 10.4%** — catastrophic across all lengths
- Effect size: infinite (δ=0 has zero variance)

## 128K Note

Both δ=0 and δ>0 returned `answer: null` at 128K. Response time dropped from ~283s (96K) to ~65s (128K), indicating API truncation/failure at context window limit. This is an infrastructure artifact, not δ-related.

## Hypothesis Evaluation

- **H₁ (δ=0 graceful)**: STRONGLY SUPPORTED — not even graceful degradation; perfect flat line at 100%
- **H₂ (δ>0 collapse)**: MODIFIED SUPPORT — collapse is immediate upon δ injection, not length-dependent. Phase transition threshold is δ itself, not context length
- **H₃ (qualitative difference)**: SUPPORTED — δ=0 is constant 1.0; δ>0 is noisy 0.03-0.20. Qualitatively distinct curves

## Replication: Llama3.1:8b (local, $0)

Date: 2026-03-23
Model: llama3.1:8b (Ollama, local)
Trials per cell: 30
Max context: 8K

| Context Length | δ=0 Accuracy | δ=0 (n) | δ>0 Accuracy | δ>0 (n) |
|:--|:--|:--|:--|:--|
| 500 | 0.13 | 4/30 | 0.07 | 2/30 |
| 1,000 | 0.20 | 6/30 | 0.00 | 0/30 |
| 2,000 | 0.43 | 13/30 | 0.07 | 2/30 |
| 4,000 | 0.60 | 18/30 | 0.00 | 0/30 |
| 8,000 | 0.43 | 13/30 | 0.00 | 0/30 |

### Aggregate

- δ=0: **54/150 = 36.0%** — baseline ability limited (8B model struggles with 3-digit addition)
- δ>0: **4/150 = 2.7%** — near-zero across all lengths
- δ=0 vs δ>0 gap: consistent at every length (δ>0 always lower)

### Interpretation

- 8B model has low baseline ability for 3-digit addition → δ=0 ceiling effect
- Despite low baseline, **δ>0 consistently destroys remaining accuracy** (36% → 3%)
- Core finding replicates: structural contradiction (δ>0), not context length, is the dominant factor
- H₁ supported (log_linear preferred for δ=0)
- Caveat: task difficulty confound — a simpler task (e.g., 2-digit addition) might show cleaner δ=0 baseline for small models

## Replication: Claude Sonnet 4 (Batch API, $1.39)

Date: 2026-03-24
Model: claude-sonnet-4-20250514 (Anthropic Batch API, 50% off)
Trials per cell: 30
Max context: 8K

| Context Length | δ=0 Accuracy | δ=0 (n) | δ>0 Accuracy | δ>0 (n) |
|:--|:--|:--|:--|:--|
| 500 | 1.00 | 30/30 | 0.87 | 26/30 |
| 1,000 | 1.00 | 30/30 | 0.90 | 27/30 |
| 2,000 | 1.00 | 30/30 | 0.67 | 20/30 |
| 4,000 | 1.00 | 30/30 | 0.50 | 15/30 |
| 8,000 | 1.00 | 30/30 | 0.77 | 23/30 |

### Aggregate

- δ=0: **150/150 = 100.0%** — perfect, identical to GPT-4o-mini
- δ>0: **111/150 = 74.0%** — significantly higher than GPT-4o-mini (10.4%)

### Interpretation

- **H₁ fully replicated**: δ=0 → 100% across all lengths, no degradation
- **δ>0 耐性にモデル能力差**: Sonnetは矛盾をかなり無視できる（74%）が完全ではない
- GPT-4o-mini（10%）→ Sonnet（74%）: より大きなモデルほどδ耐性が高い
- ただし4Kで50%に落ちて8Kで77%に戻る — n=30でもノイズが残る（矛盾テンプレートのランダム性による）
- **核心的発見は再現**: δ=0は常に完璧、δ>0は常に劣化。差は統計的に有意

## Replication: Gemini 2.5 Flash (Google API, ~$0.15)

Date: 2026-03-24
Model: gemini-2.5-flash (Google Generative AI API)
Trials per cell: 30
Max context: 8K

| Context Length | δ=0 Accuracy | δ=0 (n) | δ>0 Accuracy | δ>0 (n) |
|:--|:--|:--|:--|:--|
| 500 | 1.00 | 30/30 | 0.00 | 0/30 |
| 1,000 | 1.00 | 30/30 | 0.00 | 0/30 |
| 2,000 | 1.00 | 30/30 | 0.00 | 0/30 |
| 4,000 | 1.00 | 30/30 | 0.00 | 0/30 |
| 8,000 | 1.00 | 30/30 | 0.00 | 0/30 |

### Aggregate

- δ=0: **150/150 = 100.0%** — perfect
- δ>0: **0/150 = 0.0%** — complete annihilation, most extreme result of all models

### Interpretation

- **最も劇的な結果**: δ>0で正答率0%。GPT-4o-mini（10%）より極端
- Gemini 2.5 Flashは矛盾に対して最も脆弱 — 矛盾テンプレートに完全に従ってしまう
- δ=0は他モデルと同じく100%完璧

## Replication: Gemini 3.1 Flash Lite (Google API, ~$0.15)

Date: 2026-03-24
Model: gemini-3.1-flash-lite-preview (Google Generative AI API)
Trials per cell: 30
Max context: 8K

| Context Length | δ=0 Accuracy | δ=0 (n) | δ>0 Accuracy | δ>0 (n) |
|:--|:--|:--|:--|:--|
| 500 | 1.00 | 30/30 | 0.53 | 16/30 |
| 1,000 | 1.00 | 30/30 | 0.40 | 12/30 |
| 2,000 | 1.00 | 30/30 | 0.40 | 12/30 |
| 4,000 | 1.00 | 30/30 | 1.00 | 30/30 |
| 8,000 | 1.00 | 30/30 | 0.87 | 26/30 |

### Aggregate

- δ=0: **150/150 = 100.0%** — perfect
- δ>0: **96/150 = 64.0%** — high variance, preview model

### Interpretation

- δ=0は完璧だがδ>0の挙動が不安定（4Kで100%、2Kで40%）
- previewモデルのため矛盾テンプレートへの反応が一貫しない
- 核心的発見は再現: δ=0 > δ>0

## Llama3.1:8b 追試（2桁タスク）

Date: 2026-03-24
Model: llama3.1:8b (Ollama, local, --easy flag)
Task: 2-digit addition (e.g., 23+47+61=131)

| Context Length | δ=0 Accuracy | δ>0 Accuracy |
|:--|:--|:--|
| 500 | 0.00 | 0.00 |
| 1,000 | 0.00 | 0.03 |
| 2,000 | 0.10 | 0.00 |
| 4,000 | 0.23 | 0.00 |
| 8,000 | 0.27 | 0.00 |

### Interpretation

- bareテスト（フィラーなし）では5/5正答 → 2桁の計算能力自体はある
- 500トークンのフィラーを入れるだけでδ=0でも0%に落ちる
- 8Bモデルはフィラーの存在自体に脆弱（δとは無関係の注意力限界）
- **結論: Llama 8Bはδの効果を分離する対照群として機能しない**

### Cross-Model Summary (論文掲載対象のみ)

| Model | Vendor | δ=0 Accuracy | δ>0 Accuracy | δ Gap |
|:--|:--|:--|:--|:--|
| GPT-4o-mini | OpenAI | 100.0% (270/270) | 10.4% (28/270) | 89.6pp |
| Gemini 2.5 Flash | Google | 100.0% (150/150) | 0.0% (0/150) | 100.0pp |
| Gemini 3.1 Flash Lite | Google | 100.0% (150/150) | 64.0% (96/150) | 36.0pp |
| Claude Sonnet 4 | Anthropic | 100.0% (150/150) | 74.0% (111/150) | 26.0pp |

- **δ=0は全モデル・全ベンダーで100%**（不変条件）
- δ>0耐性はモデルにより0%〜74%と大幅に異なるが、δ=0を超えるモデルはない
- 3ベンダー（OpenAI / Google / Anthropic）×4モデルで再現
- Llama:8bは除外（ベースライン能力不足、フィラー自体に脆弱）

## Raw Data Files

- `exp35_delta_zero_control_results.json` — aggregated results (overwritten by last run: Gemini 3.1 Flash Lite)
- `exp35_delta_zero_control_trials.json` — all trial data (overwritten by last run)
- `exp35_delta_zero_control_visualization.png` — 3-panel plot
- `exp35_sonnet_batch/` — Claude Sonnet 4 raw data (preserved)
- **Note**: Gemini 2.5 Flash raw data was overwritten by subsequent Gemini 3.1 Flash Lite run. Aggregated results preserved in this summary.
