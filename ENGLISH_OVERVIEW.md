# Structural Persistence Theory for Language-Model Systems — English Overview

This note is a short English entry point to the `delta-survival-paper` repository.
It explains the main claim, the supporting evidence, and the architectural implications without requiring the Japanese preprints first.
For the shortest PDF entry point, see [`v2/pdf用/ENGLISH_ABSTRACT.pdf`](v2/pdf%E7%94%A8/ENGLISH_ABSTRACT.pdf).

## Core Claim

The central claim is simple: reasoning degradation in long conversations and catastrophic forgetting under continual learning may be two expressions of the same structural problem in language-model systems. In both cases, unresolved contradictions and premise-changing updates reduce the set of states that can still preserve coherent behavior. Here, “structure” does not mean generic form, but the relations, functions, and identity whose persistence is at issue in the system under study.

This means the project is not only about giving long-horizon systems a persistent state. Durable state is the substrate, but the stronger claim is that persistence as that structure depends on explicitly reducing contradiction load and maintaining coherence through revision.

## Minimal Theory

At the theoretical core, structural loss is defined by the log-ratio of successive shrinkage in the set of states that can still sustain the structure.
The intended reading is that of a representation theorem for a pre-fixed structure-maintenance problem, not a license to redefine the target structure after seeing the outcome.

If a system starts with a structure-preserving state set
\[
V^{(0)} \supseteq V^{(1)} \supseteq \cdots \supseteq V^{(n)},
\]
and the stage loss is defined as
\[
l_i = -\ln \frac{m(V^{(i)})}{m(V^{(i-1)})},
\]
then the remaining survivable region takes the exponential form
\[
m(V^{(n)}) = m(V^{(0)}) e^{-L}, \qquad L = \sum_i l_i.
\]

In the current v2 core, the log-ratio form itself is no longer treated as a mere definition. Paper 1 characterizes it axiomatically on ratio space, in explicit analogy with the Hartley/Shannon style of uniqueness arguments. The exponential form is therefore not an extra empirical assumption; it follows from cumulative multiplicative shrinkage once the loss scale is fixed in that way. In that sense, collapse here means loss of persistence as that structure, not necessarily annihilation of the underlying substrate.

## Formal Layer and Limited-Class Unification

The Lean 4 side currently contains 177 direct top-level `Survival.*` imports in
`lean/Survival.lean`, matching 177 `lean/Survival/*.lean` module files, with
`sorry = 0` and `axiom = 0` in the imported target. The formal layer includes
the minimal exponential kernel, finite-horizon SAT / Bernoulli-CSP skeletons,
admissible-map and saturation-defect wrappers, Foster-Lyapunov / queueing
templates, Repair-Maintenance templates, the Phase 7 cross-class interface,
and the LLM-style epistemic-control bridge with finite memory, reasoning,
dependency-budget, and software-contract toy instantiations.

The strongest cross-class statement is intentionally phrased as limited-class unification rather than as a universal law over all domains. In Phase 7 v2, Bernoulli-CSP, Foster-Lyapunov / queueing, and Repair-Maintenance are registered as limited classes that instantiate a common structural-persistence interface:

- an ordered Sigma carrier
- a nonnegative tendency driver
- a finite-horizon certificate route
- an admissible-transfer guard

This means that the project has a machine-checked interface closure for registered classes. It does not claim a single universal inequality for arbitrary domains. New domains must either be registered as new limited classes or treated as structural-inference settings whose support depends on frozen validation.

## Two Experimental Regimes

### 1. Inference-time reasoning degradation

The inference-side experiments study what happens when contradictory or unresolved updates accumulate inside a conversation. The key observation is:

- long context by itself does not explain the full degradation
- unresolved contradiction accumulation degrades logical consistency much more sharply
- externally organizing contradictions into old/new state relations preserves coherence better than leaving the same contradictions unresolved

That points to contradiction management rather than sheer context length as the main issue in these settings.

### 2. Continual-learning structural forgetting

The continual-learning experiments study premise-changing updates under LoRA-based sequential training. Not all forgetting looks the same. When an upstream premise changes, many dependency-linked pieces of knowledge must be reorganized together. If that reorganization fails, the system does not merely miss one fact; it falls into an internally inconsistent state.

Across the tested settings, LoRA-style sequential updating often overwrote old organization instead of adding cleanly to it. Dependency-aware replay improved consistency, and multi-adapter separation reduced some interference, but neither fully kept older knowledge intact.

## Architectural Implication

The target here is a system that can stay coherent through revision, not just answer well in isolated sessions. That likely requires more than better prompting or more training alone.

The work points toward an architecture with:

- external contradiction metabolism
- multi-layer memory rather than a single undifferentiated memory store
- premise-dependent reorganization of knowledge
- rollbackable state management
- maintenance of an internal model across time

The intended target is not just a stronger stateless chatbot, but a system that can remain coherent across updates, revisions, and long-running interaction.

## What This Repository Contains

- a Japanese structure map: [`v2/補論_構造持続理論の構成地図.md`](v2/補論_構造持続理論の構成地図.md)
- an integrated Japanese overview: [`v2/0_構造持続理論の統合版.md`](v2/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.md)
- Japanese main theory spine (`v2/1`, `v2/2`) and technical supplements
- an operational discipline note: [`v2/補論_構造持続理論の運用規律.md`](v2/補論_構造持続理論の運用規律.md)
- a specification-fixed finite-CSP layer anchor: [`v2/補論_有限CSPにおける構造持続の予測力.md`](v2/%E8%A3%9C%E8%AB%96_%E6%9C%89%E9%99%90CSP%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E4%BA%88%E6%B8%AC%E5%8A%9B.md)
- structural-inference LLM companion anchors (`v2/Companion_RouteC_推論時の構造劣化.md`, `v2/Companion_RouteC_継続学習時の構造的忘却.md`)
- PDFs in [`v2/pdf用/`](v2/pdf%E7%94%A8/)
- Lean 4 formalization in [`lean/`](lean/)
- raw data and summaries in [`DATA.md`](DATA.md)

## Suggested Reading Path

For external readers, the cleanest route is:

1. Structure map: [`v2/補論_構造持続理論の構成地図.md`](v2/補論_構造持続理論の構成地図.md)
2. Integrated overview: [`v2/0_構造持続理論の統合版.md`](v2/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.md)
3. Minimal form: [`v2/1_構造持続の最小形式.md`](v2/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.md)
4. Balance principle: [`v2/2_構造持続の収支原理.md`](v2/2_構造持続の収支原理.md)
5. Operational discipline: [`v2/補論_構造持続理論の運用規律.md`](v2/補論_構造持続理論の運用規律.md)
6. Specification-fixed structural layer / finite CSP: [`v2/補論_有限CSPにおける構造持続の予測力.md`](v2/%E8%A3%9C%E8%AB%96_%E6%9C%89%E9%99%90CSP%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E4%BA%88%E6%B8%AC%E5%8A%9B.md)
7. Structural-inference layer / LLM anchors: [`v2/Companion_RouteC_推論時の構造劣化.md`](v2/Companion_RouteC_推論時の構造劣化.md), [`v2/Companion_RouteC_継続学習時の構造的忘却.md`](v2/Companion_RouteC_継続学習時の構造的忘却.md)
8. Resource term \(M\): [`v2/補論_構造持続における資源項Mの操作的定式化.md`](v2/補論_構造持続における資源項Mの操作的定式化.md)
9. Bridges to existing theory: [`v2/補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み.md`](v2/補論_構造持続の収支原理とFoster-Lyapunovドリフトの形式的埋め込み.md), [`v2/補論_非CSP古典例における構造持続の収支原理の最小アンカー.md`](v2/補論_非CSP古典例における構造持続の収支原理の最小アンカー.md)
10. Lean and technical details: [`lean/PAPER_MAPPING.md`](lean/PAPER_MAPPING.md), [`v2/補論_構造持続の条件つき導出.md`](v2/補論_構造持続の条件つき導出.md), [`v2/補論_構造持続の収支原理の詳細展開.md`](v2/補論_構造持続の収支原理の詳細展開.md)

If you want the logical dependency order:

1. [`v2/1_構造持続の最小形式.md`](v2/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.md)
2. [`v2/2_構造持続の収支原理.md`](v2/2_構造持続の収支原理.md)
3. [`v2/補論_構造持続の条件つき導出.md`](v2/補論_構造持続の条件つき導出.md)

## Scope and Caution

This project does **not** claim that all long-horizon failure in AI has already been fully explained or formally proven.

The stronger claim is intentionally avoided.
The current claim is narrower:

- the minimal exponential form is a consequence of a pre-fixed representation of structural loss
- the contradiction-related reasoning results are empirical and directional
- the continual-learning results show limits of a specific update regime rather than all possible training regimes

The framework only has empirical bite when the target structure, measure, stage boundaries, and time horizon are fixed in advance in a non-trivial and representationally stable way. If those are allowed to vary post hoc, the same mathematics can be made to fit arbitrary finite monotone sequences and the theory becomes vacuous. The value of the framework, at this stage, is that it offers a common language connecting theory, experiments, and architecture without hiding that scope condition.

As of 2026-04-28, both frozen specification-fixed finite-domain packages have also been rerun by three outside executors each. Mixed-CSP returned three clean 12,000-row primary runs with zero checked core-field mismatches and all support flags true. Exp43c q-coloring returned three clean 4,000-row primary runs with zero checked core-field mismatches, zero timeouts, zero malformed rows, and the same qualitative support decision. This strengthens package-level reproducibility for the specification-fixed layer, but it is not a claim that the full replication program is closed.
