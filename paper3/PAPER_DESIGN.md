# Paper Design: Cognitive Sleep for LLMs

## For Reviewers / Co-authors / LLM Review

This document contains everything needed to evaluate the paper design: the claim structure, all experimental data, known weaknesses, and the intended narrative. Read this before the tex file.

**Revision history**:
- v1 (2026-03-30): Initial design
- v2 (2026-03-30): Incorporated review feedback — title change, sign test aggregation, ablation confounds, anchoring claim level adjustment

---

## 1. Paper Identity

**Title**: "Cognitive Sleep for LLMs: How Contradiction Metabolism Prevents Context Rot"

**One-sentence summary**: LLMs degrade in long conversations not because the context is too long, but because contradictions accumulate — and an external "sleep" mechanism that resolves contradictions during idle time prevents this collapse with statistical significance (p<0.001, d=8.80).

**Target venue**: EMNLP 2026 Findings, or ACL Workshop on LLM Robustness

**Relation to prior work by same author**:
- Paper 1 ("Structural Collapse as Information Loss", Sunagawa 2026) proved that S = e^{-δ} — contradiction accumulation causes exponential decay. This paper is the **engineering sequel**: "now that we know δ causes collapse, here's how to keep δ near zero."
- Exp35 data (6 models, δ=0 vs δ>0) is shared between both papers. Cited, not duplicated.

---

## 2. Claim Structure

The paper makes **three claims** at different confidence levels:

### Claim 1 (Strong): Context rot is caused by contradiction accumulation, not context length.
**Evidence**: Exp35 (6 models, 4 vendors)

| Model | Vendor | Context Window | δ=0 | δ>0 | Drop |
|-------|--------|---------------|-----|-----|------|
| GPT-4o-mini | OpenAI | 96K | 100% | 10.4% | -89.6pp |
| Gemini 2.5 Flash | Google | 64K | 100% | 0% | -100pp |
| Gemini 3.1 FL | Google | **1M** | 88.6% | 40.8% | -47.8pp |
| Sonnet 4 (prev) | Anthropic | 8K | 100% | 74.0% | -26.0pp |
| Sonnet 4.6 | Anthropic | 128K | 100% | 100%* | 0pp |
| Llama 3.1:8b | Meta | 8K | 34.0% | 2.7% | -31.3pp |

*Recognition accuracy; strict parsing = 82.6% due to output format variability.

**Key argument — length vs contradiction contrast**:
```
8K  + contradictions → -26.0pp (Sonnet 4)
1M  + contradictions → -47.8pp (Gemini 3.1 FL)
Any + no contradictions → accuracy maintains
```
Context length increases 125× (8K→1M) but degradation *worsens*, not improves. Removing contradictions (δ=0) restores accuracy regardless of length. The causal variable is contradiction density, not token count.

**Sonnet 4.6 exception**: The only model that resists (recognition=100%). But it doesn't *manage* contradictions — it tolerates them. For the other 5/6 models, collapse is severe. Even Sonnet's tolerance doesn't address knowledge management (fact retrieval degrades over time regardless).

### Claim 2 (Strong): External metabolism prevents collapse with high statistical significance.
**Evidence**: Two experiments.

**Experiment A — Cross-Model Sign Test** (8 models, 11 pairs, 180 turns):

| # | Model | Params | ON | OFF | Diff |
|---|-------|--------|-----|------|------|
| 1 | gemma3:27b T1 | 27B | 40.0% | 25.0% | +15.0pp |
| 2 | deepseek-r1:14b T1 | 14B | 24.4% | 15.6% | +8.9pp |
| 3 | deepseek-r1:14b T2 | 14B | 17.8% | 8.9% | +8.9pp |
| 4 | gemma3:12b T1 | 12B | 24.4% | 6.7% | +17.8pp |
| 5 | llama3.1:8b T1 | 8B | 31.1% | 11.1% | +20.0pp |
| 6 | llama3.1:8b T2 | 8B | 11.1% | 2.2% | +8.9pp |
| 7 | mistral-nemo:12b T1 | 12B | 22.2% | 13.3% | +8.9pp |
| 8 | gemma3:12b (gemma) T1 | 12B | 31.1% | 15.6% | +15.6pp |
| 9 | qwen2.5:14b T1 | 14B | 17.8% | 20.0% | -2.2pp |
| 10 | llama3.1:8b T3 | 8B | 17.8% | 17.8% | +0.0pp |
| 11 | mistral-nemo:12b T2 | 12B | 57.8% | 15.6% | +42.2pp |

**Sign test results (report both)**:

| Aggregation | Pairs | ON wins | p (one-sided) | Note |
|-------------|-------|---------|---------------|------|
| All pairs | 10 (excl TIE) | 9 | **0.0107** | Treats trials as independent |
| Per-model (median) | 7 | 6 | 0.0625 | Conservative, borderline |

The paper should report both. The per-model aggregation is borderline because n=7 is small, not because the effect is weak (6/7 models show ON>OFF). The n=3 three-condition experiment (Claim 2b below) provides stronger per-model evidence.

phi4 excluded (pre-registered criterion: both ON and OFF rule_application < 10% at T90 indicates model failure, not metabolism failure).

Cumulative effect: 3 pairs flipped from OFF/TIE→ON between T90 and T180.

**Experiment B — Controlled Ablation** (mistral-nemo:12b):

| Condition | Code Version | Overall (corrected) |
|-----------|-------------|-------------------|
| ON | New (temporal integration + SCALE_FACTOR 3.0) | **57.8%** |
| ON | Old (pre-temporal, SCALE_FACTOR 5.0) | 8.9% |
| OFF | New | 15.6% |
| OFF | Old | 22.2% |

OFF unchanged across code versions (15.6% vs 22.2%, within noise). ON jumps +48.9pp.

**Confound disclosure**: The code change includes temporal integration (main change) AND SCALE_FACTOR adjustment (5.0→3.0). These were introduced simultaneously. The paper should report this as "temporal integration with adjusted scale factor" rather than attributing the effect to temporal integration alone.

Old code ON (8.9%) < OFF (22.2%): pre-temporal metabolism made things *worse* by flooding information. The code change turned a net-negative into a net-positive.

**Experiment C — Three-Condition Comparison** (gemma3:27b, n=3, 180 turns):

fact + rule accuracy (30 questions per trial, corrected judgment):

| Condition | Trial 2 | Trial 3 | Trial 4 | Mean | SD |
|-----------|---------|---------|---------|------|-----|
| **Metabolism ON** | **22/30** | **20/30** | **24/30** | **73.3%** | **6.7%** |
| No contradiction (δ=0) | 18/30 | 15/30 | 18/30 | 56.7% | 5.8% |
| Metabolism OFF | 5/30 | 8/30 | 6/30 | 21.1% | 5.1% |

SD is computed over the 3 trial proportions (e.g., ON trials: 73.3%, 66.7%, 80.0% → SD=6.7%). For the paper, report as: Mean% (SD%) with n=3.

| Comparison | p-value | Cohen's d |
|------------|---------|-----------|
| ON vs OFF | 0.0004 | 8.80 |
| ON vs NC | 0.031 | 2.67 |
| NC vs OFF | 0.001 | 6.53 |
| ANOVA | 0.0001 | η²=0.954 |

### Claim 3 (Exploratory): Metabolism provides a knowledge anchoring effect beyond contradiction resolution.
**Confidence level**: Replicated observation with proposed mechanism (NOT confirmed causal finding).

**Observation**: ON (73.3%) > NC (56.7%) in all 3 trials (+4, +5, +6 questions).

**Proposed mechanism**: In NC condition, setup facts become unsearchable after 180 turns (10/15 fact questions answered "I don't have that information"). In ON condition, contradiction pairs act as search anchors — linked records maintain retrieval visibility.

**What is NOT established**: Direct measurement of search hit rates. The mechanism is inferred from the failure pattern, not directly measured.

**How to present**: As an "unexpected observation" in the results, with proposed explanation. NOT as a main claim in the abstract or conclusion. Future work should directly measure retrieval probabilities.

### Two-Tier Claim Strategy for Distributed Metabolism (v3 addition, 2026-04-03)

The paper's central evidence comes from **coupled mode** (dialogue_llm == metabolism_llm). This is deliberate:

**Tier 1 — Main evidence (coupled mode):**
- dialogue_llm == metabolism_llm (same model for both)
- All Claim 1–3 experiments use this configuration
- **Why this is strongest**: proves the *architecture* is effective, not a specific model's capability
- "The LLM fixes its own contradictions during sleep" is the cleanest narrative
- Sonnet 4.6, gemma3:27b, mistral-nemo:12b all demonstrate this

**Tier 2 — Supplementary evidence (decoupled mode):**
- dialogue_llm != metabolism_llm (e.g., local model for dialogue, Sonnet for metabolism)
- Demonstrates the architecture's **modularity**: resolver can be independently upgraded
- **What it shows**:
  - The metabolism engine is a separable module, not welded to a specific model
  - When a local model's resolver is weak, a stronger external resolver can compensate
  - The failure mode of weak local resolvers (pending_review flood) is diagnosable
- **What it does NOT show**: that the architecture "only works with strong models"

**How to present in the paper:**
- §4 Experiments: all results from coupled mode (Tier 1)
- §5.4 Future Work or Appendix: "In distributed configurations, the metabolism resolver can be replaced independently. Preliminary evidence suggests stronger resolvers improve resolution quality (fewer pending_review transitions). See delta-wake implementation (GitHub)."
- Do NOT present decoupled results as primary evidence — it weakens the "architecture works" narrative

**For patent (L79/L80) — different framing:**
- Patent emphasizes the **structural separation** as the invention
- "The resolver is independently replaceable" is an explicit claim (L79 §0004)
- Patent実施例 includes both coupled and decoupled configurations
- This is correct: patent protects the structure, paper proves the effect

**Summary:**
```
Paper:  "The same LLM can fix its own contradictions during sleep"     → coupled = main proof
Patent: "The metabolism resolver is an independently replaceable module" → structure = main claim
Both:   "Stronger resolvers make it better, but the architecture is the contribution"
```

**Data status (2026-04-03):**
- Coupled mode: 8 models × 180 turns (existing), Sonnet 4.6 × 30 turns (frontier pilot)
- Decoupled mode: PostgreSQL E2E confirmed (gemma3 dialogue + Sonnet resolver tested), formal experiment not yet run
- Proxy simulation: 4 models × 180 turns, FIFO vs δ-priority, average +14.8% S-value improvement

---

## 3. Architecture (What Was Built)

### Design Principles
| # | Principle | Description |
|---|-----------|-------------|
| P1 | Read-only during dialogue | Metabolism runs only during idle time ("cognitive sleep") |
| P2 | Prioritize δ resolution | Reducing δ has exponential effect (S = μ × e^{-δ×k}) |
| P3 | Don't integrate low-confidence | Prevents δ_eff runaway |
| P4 | Let logic decay, preserve facts | 90-day TTL demotion for unreferenced rules |
| P5 | If it breaks, roll it back | Pre-metabolism snapshots + auto-rollback |

### 4-Layer Memory
| Layer | Name | Role | Storage |
|-------|------|------|---------|
| L1 | Working | Current conversation context | deque + SQLite |
| L2 | Pending | Unprocessed conversation logs | SQLite |
| L3 | Active Logic | Rules, preferences, contradiction pairs | ChromaDB (vector) |
| L4 | Dormant Fact | Facts and demoted rules | SQLite + ChromaDB |

### Metabolism Pipeline (runs during idle)
```
L2 (pending logs)
  → Extract: classify as fact/rule/preference (LLM call)
  → Detect: pairwise contradiction check against L3 (LLM call)
  → Resolve: one of three strategies:
      a) Direct contradiction → preserve both as linked pair, mark newer
      b) Temporal change → stack with timestamps
      c) Different scope → treat as conditional branches (not contradiction)
  → Forget: demote rules unreferenced for 90 days (L3→L4)
  → Monitor: compute S-value, auto-rollback if sharp drop
```

### Temporal Integration (key innovation)
When contradictions are detected, both old and new claims are preserved as a linked pair. During retrieval, the pair is formatted chronologically:

```
[Value transition]
  → IF asked about favorite food THEN likes curry (T=5, earlier)
  → IF asked about favorite food THEN likes ramen (T=23, latest)
```

The LLM is instructed to **report, not judge**: "You said X at time A, then Y at time B" — without deciding which is correct.

### Three Resolution Strategies
These emerged from implementation, not top-down design:

| Strategy | When | Mechanism |
|----------|------|-----------|
| Priority (recency) | Direct contradiction (A vs ¬A) | Keep both, mark newer |
| Temporal stacking | State change over time | Preserve with timestamps |
| Scope reinterpretation | Different conditions | Parallel branches |

---

## 4. Experimental Design Details

### Benchmark
- 45 questions per measurement: 15 fact_recall + 15 rule_application + 15 contradiction_detection
- Measured at Turn 90 and Turn 180 (180-turn sessions)
- Dialogue LLM: Ollama local models ($0 cost)
- Judgment: keyword matching → Claude CLI rejudge (corrected)
- **Results reported using fact + rule only (30 questions)**

### Why fact + rule only (excluding contradiction_detection)
The contradiction_detection benchmark has a structural paradox: if metabolism successfully resolves a contradiction, the contradiction no longer exists when the benchmark asks "is there a contradiction?" Stronger metabolism → lower contra score. This is a benchmark limitation, not a system failure. Mentioned briefly in §4.1 Setup, detailed in Appendix.

### 180-turn Session Structure
- 70% normal conversation
- 15% information injection
- 10% contradiction injection (0% for NC condition)
- 5% benchmark slots

### Judgment Correction
Original keyword matching → Claude CLI rejudge ($0 via subscription). All reported results use corrected judgment.

---

## 5. Known Weaknesses

### Statistical
- **n=3 per condition**. Effect sizes are extremely large (d=8.80) but n=3 is small.
- **Model-aggregated sign test is borderline** (p=0.0625). Report both aggregation levels.

### Scope
- **Core evidence is still local-model-heavy (8B-27B)**, but we now have 30-turn full-pipeline frontier replications on Sonnet 4.6 and Gemini 3.1 Flash Lite.
- **Single model for n=3**. Three-condition experiment uses gemma3:27b only.
- **Japanese prompts and benchmarks**. Cross-language validation needed.

### Methodology
- **Keyword + LLM rejudge**. Not a standardized benchmark.
- **Ablation confound**: temporal integration + SCALE_FACTOR changed simultaneously.
- **Knowledge anchoring not directly measured**. Mechanism is inferred from failure patterns.

### What This Paper Does NOT Claim
- That this approach is universal across frontier models
- That 73.3% is production-ready
- That the sleep metaphor is more than a useful analogy
- That knowledge anchoring is a confirmed causal mechanism

---

## 6. Narrative Arc

1. **Everyone thinks context rot = context too long.** Google makes 1M-token windows. The assumption: more space = less rot.

2. **We show it's not length, it's contradictions.** 8K with contradictions: -26pp. 1M with contradictions: -47.8pp. Remove contradictions: accuracy holds. The variable is δ, not token count.

3. **Biology solved this: sleep.** Humans consolidate memory during sleep. LLMs have no equivalent. They accumulate everything without processing.

4. **We built it.** DeltaZero: external metabolism during idle time. No model modification.

5. **It works.** Three-condition gemma3:27b gives ON vs OFF: +52.2pp, Kruskal-Wallis p=0.027, with complete rank separation. Across 8 models, the sign test still points the same way. Effect grows over time.

6. **Unexpected observation.** ON exceeds the δ=0 baseline. Contradiction pairs may act as knowledge anchors. Exploratory finding, mechanism proposed but not directly measured.

7. **Frontier transfer is now real, but narrow.** Sonnet 4.6 and Gemini 3.1 Flash Lite both show ON ≈ NC and ON >> OFF on 30-turn full-pipeline runs. GPT-4o is supportive but quarantine-limited secondary evidence.

---

## 7. Paper Structure

```
Abstract (150 words)

1. Introduction (1.5 pages)
   1.1 The Context Rot Problem
   1.2 Not Length, But Contradictions (8K vs 1M contrast)
   1.3 Cognitive Sleep: The Biological Analogy
   1.4 Contributions

2. Related Work (0.75 pages)
   2.1 Long-Context LLMs and Memory Systems
   2.2 Knowledge Conflicts in RAG
   2.3 The Survival Equation [cite Paper 1]

3. Metabolic Architecture (2 pages)
   3.1 Design Principles
   3.2 4-Layer Memory
   3.3 Metabolism Pipeline
   3.4 Temporal Integration and Pair Preservation

4. Experiments (3 pages)
   4.1 Setup (models, benchmark, judgment, contra exclusion note)
   4.2 Exp 1: Cross-Model Sign Test (Table + both aggregation levels)
   4.3 Exp 2: Controlled Ablation (2×2, confound disclosed)
   4.4 Exp 3: Three-Condition Comparison (n=3, full statistics)
   4.5 Unexpected Observation: ON > δ=0 (0.75 pages, anchoring as proposed explanation)

5. Discussion (1 page)
   5.1 Redefining Context Rot
   5.2 The Sonnet Exception
   5.3 Distributed Metabolism: Decoupling Dialogue and Resolution (0.5 page, new)
       — Coupled mode is the main evidence; decoupled mode shows modularity
       — Resolver can be independently upgraded without changing dialogue path
       — Priority ordering (δ-based) improves S-value by ~15% across 4 models
   5.4 Limitations
   5.5 Future Work

6. Conclusion (0.5 page)

Appendix A: Full 11-pair data with T90/T180
Appendix B: Benchmark examples (5 representative questions, full set on GitHub)
Appendix C: Rejudge methodology and contra_detection paradox detail

Estimated total: ~10 pages + appendix
```

---

## 8. Figures Needed

| # | Content | Section |
|---|---------|---------|
| 1 | Exp35 bar chart: 6 models, δ=0 vs δ>0 | §1.2 |
| 2 | Architecture diagram (dialogue + metabolism pipeline) | §3 |
| 3 | Forest plot: 11-pair ON-OFF differences | §4.2 |
| 4 | Ablation 2×2 bar chart | §4.3 |
| 5 | Three-condition bar chart with error bars (n=3) | §4.4 |

---

## 9. Review Questions

1. Is the 8K vs 1M contrast sufficient to establish "not length"?
2. Should we report the 11-pair sign test (p=0.0107) or model-aggregated (p=0.0625) as primary?
3. Is the ablation confound (temporal integration + SCALE_FACTOR) acceptable with disclosure?
4. Is "unexpected observation" the right framing for ON>NC, or should it be promoted/demoted?
5. Does the paper need a frontier model experiment to be publishable?
6. Is 10 pages the right length for EMNLP Findings?

---

## 10. Post-Preprint Experiment Plan

Preprint投稿後、査読期間中に以下の追加実験を実施する。

### Priority 1: サンプルサイズ拡大（$0、ローカル）

| 実験 | 内容 | 期待される効果 |
|:--|:--|:--|
| gemma3:27b n=3→n=6 | 三条件実験を3試行追加 | MW最小p: 0.05→0.004到達可能。パラメトリック検定も正当化 |
| mistral-nemo:12b 三条件n=3 | 新モデルで三条件実験 | 「single model for n=3」批判を解消 |
| deepseek-r1:14b 三条件n=3 | 第3モデルで三条件実験 | 3モデル×n=3で汎化性を実証 |

### Priority 2: Frontier Model 検証（要APIコスト見積もり）

| 実験 | 内容 | 見積もりコスト |
|:--|:--|:--|
| GPT-4o 三条件n=3 | 180ターン×9 run | ~$10-30 |
| Claude 三条件n=3 | 同上 | サブスク内CLI利用を先に検討 |

### Priority 3: 標準ベンチマーク（工数大）

| 実験 | 内容 | 備考 |
|:--|:--|:--|
| MMLU subset | 代謝ON/OFF下でMMLU精度を比較 | ベンチマーク設計の大幅変更が必要 |

### 論文更新方針
- Priority 1完了後: Table 5/6を更新、統計手法をパラメトリックに戻せる可能性
- Priority 2完了後: Table 1にfrontier modelの代謝結果を追加
- arXiv v2として更新、EMNLP camera-readyに反映

---

## 11. Repository Links

- **DeltaZero** (full system): https://github.com/karesansui-u/delta-zero
- **delta-prune** (middleware): https://github.com/karesansui-u/delta-prune
- **Paper 1** (survival equation): https://github.com/karesansui-u/delta-survival-papers
