# Structural Persistence Theory for Language-Model Systems — English Overview

This note is a short English entry point to the `delta-survival-paper` repository.
It explains the main claim, the supporting evidence, and the architectural implications without requiring the Japanese preprints first.
For a one-page version, see [`v2/pdf用/ENGLISH_ABSTRACT.pdf`](v2/pdf%E7%94%A8/ENGLISH_ABSTRACT.pdf).

## Core Claim

The central claim is simple: reasoning degradation in long conversations and catastrophic forgetting under continual learning may be two expressions of the same structural problem in language-model systems. In both cases, unresolved contradictions and premise-changing updates reduce the set of states that can still preserve coherent behavior. Here, “structure” does not mean generic form, but the relations, functions, and identity whose persistence is at issue in the system under study.

This means the project is not only about giving long-horizon systems a persistent state. Durable state is the substrate, but the stronger claim is that persistence as that structure depends on explicitly reducing contradiction load and maintaining coherence through revision.

## Minimal Theory

At the theoretical core, structural loss is defined by the log-ratio of successive shrinkage in the set of states that can still sustain the structure.

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

In this framework, the exponential form is not an extra empirical assumption. It follows directly from representing cumulative structural loss as successive multiplicative shrinkage measured in log-ratio form. In that sense, collapse here means loss of persistence as that structure, not necessarily annihilation of the underlying substrate.

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

- Japanese preprints (`v2/1` to `v2/4`)
- an integrated Japanese overview: [`v2/0_構造持続理論の統合版.md`](v2/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.md)
- PDFs in [`v2/pdf用/`](v2/pdf%E7%94%A8/)
- Lean 4 formalization in [`lean/`](lean/)
- raw data and summaries in [`DATA.md`](DATA.md)

## Suggested Reading Path

If you want the shortest route:

1. [`v2/0_構造持続理論の統合版.md`](v2/0_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E7%90%86%E8%AB%96%E3%81%AE%E7%B5%B1%E5%90%88%E7%89%88.md)
2. [`v2/3_構造持続と推論性能の劣化.md`](v2/3_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%A8%E6%8E%A8%E8%AB%96%E6%80%A7%E8%83%BD%E3%81%AE%E5%8A%A3%E5%8C%96.md)
3. [`v2/4_構造持続と継続学習における破滅的忘却.md`](v2/4_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%A8%E7%B6%99%E7%B6%9A%E5%AD%A6%E7%BF%92%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B%E7%A0%B4%E6%BB%85%E7%9A%84%E5%BF%98%E5%8D%B4.md)

If you want the theoretical core:

1. [`v2/1_構造持続の最小形式.md`](v2/1_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9C%80%E5%B0%8F%E5%BD%A2%E5%BC%8F.md)
2. [`v2/2_構造持続の条件つき導出.md`](v2/2_%E6%A7%8B%E9%80%A0%E6%8C%81%E7%B6%9A%E3%81%AE%E6%9D%A1%E4%BB%B6%E3%81%A4%E3%81%8D%E5%B0%8E%E5%87%BA.md)

## Scope and Caution

This project does **not** claim that all long-horizon failure in AI has already been fully explained or formally proven.

The stronger claim is intentionally avoided.
The current claim is narrower:

- the minimal exponential form is a consequence of the chosen representation of structural loss
- the contradiction-related reasoning results are empirical and directional
- the continual-learning results show limits of a specific update regime rather than all possible training regimes

The value of the framework, at this stage, is that it offers a common language connecting theory, experiments, and architecture.
